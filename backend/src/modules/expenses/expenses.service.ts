import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Expense, ExpenseCategory } from './entities/expense.entity';
import { User } from '../users/entities/user.entity';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { getCoupleId } from '../../common/utils/couple.util';

@Injectable()
export class ExpensesService {
    private readonly logger = new Logger(ExpensesService.name);

    constructor(
        @InjectRepository(Expense)
        private expenseRepository: Repository<Expense>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
    ) { }

    private async getCoupleIdForUser(userId: string): Promise<string> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            throw new NotFoundException('User not found or not paired');
        }
        return getCoupleId(userId, user.partnerId);
    }

    async create(userId: string, dto: CreateExpenseDto): Promise<Expense> {
        const coupleId = await this.getCoupleIdForUser(userId);

        const expense = this.expenseRepository.create({
            coupleId,
            userId,
            category: dto.category,
            amount: dto.amount,
            description: dto.description,
            date: dto.date,
        });

        const saved = await this.expenseRepository.save(expense);
        this.logger.log(`[EXPENSE] ${dto.category} — ${dto.amount} VND by ${userId}`);
        return saved;
    }

    async findAll(userId: string, limit = 50, offset = 0): Promise<Expense[]> {
        const coupleId = await this.getCoupleIdForUser(userId);

        return this.expenseRepository.find({
            where: { coupleId },
            order: { date: 'DESC', createdAt: 'DESC' },
            take: limit,
            skip: offset,
        });
    }

    async remove(userId: string, expenseId: string): Promise<void> {
        const coupleId = await this.getCoupleIdForUser(userId);
        // M4: Intentionally checks coupleId only (not userId) — either partner can delete
        // shared expenses. This is a design decision for shared finance management.
        const expense = await this.expenseRepository.findOne({
            where: { id: expenseId, coupleId },
        });

        if (!expense) {
            throw new NotFoundException('Expense not found');
        }

        await this.expenseRepository.remove(expense);
    }

    async getReport(userId: string, period: 'week' | 'month'): Promise<{
        period: string;
        total: number;
        byCategory: Record<string, number>;
        count: number;
    }> {
        const coupleId = await this.getCoupleIdForUser(userId);

        const now = new Date();
        let startDate: Date;

        if (period === 'week') {
            startDate = new Date(now);
            startDate.setDate(now.getDate() - 7);
        } else {
            startDate = new Date(now.getFullYear(), now.getMonth(), 1);
        }

        // M1: Use local date components to avoid UTC timezone offset issues
        const pad = (n: number) => n.toString().padStart(2, '0');
        const toLocalDateStr = (d: Date) =>
            `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
        const startStr = toLocalDateStr(startDate);
        const endStr = toLocalDateStr(now);

        const expenses = await this.expenseRepository.find({
            where: {
                coupleId,
                date: Between(startStr, endStr),
            },
        });

        const byCategory: Record<string, number> = {};
        let total = 0;

        for (const exp of expenses) {
            const amount = Number(exp.amount);
            total += amount;
            byCategory[exp.category] = (byCategory[exp.category] || 0) + amount;
        }

        return {
            period: `${startStr} to ${endStr}`,
            total,
            byCategory,
            count: expenses.length,
        };
    }
}
