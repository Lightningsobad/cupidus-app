import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Expense, ExpenseCategory } from './entities/expense.entity';
import { User } from '../users/entities/user.entity';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { getCoupleId } from '../../common/utils/couple.util';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

@Injectable()
export class ExpensesService {
    private readonly logger = new Logger(ExpensesService.name);

    constructor(
        @InjectRepository(Expense)
        private expenseRepository: Repository<Expense>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
        private readonly dispatcher: CoupleNotificationDispatcher,
    ) { }

    private async getUserAndCoupleId(userId: string): Promise<{ user: User; coupleId: string }> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            throw new NotFoundException('User not found or not paired');
        }
        return { user, coupleId: getCoupleId(userId, user.partnerId) };
    }

    private async getCoupleIdForUser(userId: string): Promise<string> {
        const { coupleId } = await this.getUserAndCoupleId(userId);
        return coupleId;
    }

    async create(userId: string, dto: CreateExpenseDto): Promise<Expense> {
        const { user, coupleId } = await this.getUserAndCoupleId(userId);

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

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: user.partnerId,
            eventName: 'expense:created',
            eventId: saved.id,
            title: 'Khoản chi tiêu mới 💸',
            body: `${user.displayName || 'Bae'} vừa thêm khoản chi: "${dto.description || dto.category}" - ${Number(dto.amount).toLocaleString()} VND`,
            payload: saved,
            emitToSenderToo: true,
        });

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
        const { user, coupleId } = await this.getUserAndCoupleId(userId);
        // M4: Intentionally checks coupleId only (not userId) — either partner can delete
        // shared expenses. This is a design decision for shared finance management.
        const expense = await this.expenseRepository.findOne({
            where: { id: expenseId, coupleId },
        });

        if (!expense) {
            throw new NotFoundException('Expense not found');
        }

        await this.expenseRepository.remove(expense);

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: user.partnerId,
            eventName: 'expense:deleted',
            payload: { expenseId },
        });
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
