import { Test, TestingModule } from '@nestjs/testing';
import { ExpensesService } from './expenses.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Expense, ExpenseCategory } from './entities/expense.entity';
import { User } from '../users/entities/user.entity';
import { NotFoundException } from '@nestjs/common';

describe('ExpensesService', () => {
    let service: ExpensesService;
    let expenseRepoMock: any;
    let userRepoMock: any;

    const userA = 'user-aaa';
    const userB = 'user-bbb';
    const coupleId = [userA, userB].sort().join(':');
    const mockUser = { id: userA, partnerId: userB } as Partial<User> as User;

    const createDto = {
        category: ExpenseCategory.FOOD,
        amount: 200000,
        description: 'Dinner at Gyu-Kaku',
        date: '2026-02-15',
    };

    beforeEach(async () => {
        expenseRepoMock = {
            create: jest.fn((dto) => dto),
            save: jest.fn((entity) => Promise.resolve({ id: 'exp-1', ...entity })),
            find: jest.fn(),
            findOne: jest.fn(),
            remove: jest.fn(),
        };

        userRepoMock = {
            findOne: jest.fn(),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                ExpensesService,
                { provide: getRepositoryToken(Expense), useValue: expenseRepoMock },
                { provide: getRepositoryToken(User), useValue: userRepoMock },
            ],
        }).compile();

        service = module.get<ExpensesService>(ExpensesService);
    });

    describe('create', () => {
        it('should create an expense for the couple', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);

            const result = await service.create(userA, createDto);

            expect(result.category).toBe(ExpenseCategory.FOOD);
            expect(result.amount).toBe(200000);
            expect(result.coupleId).toBe(coupleId);
            expect(expenseRepoMock.save).toHaveBeenCalled();
        });
    });

    describe('findAll', () => {
        it('should return expenses with pagination', async () => {
            const expenses = [{ id: 'exp-1', category: ExpenseCategory.FOOD, amount: 200000 }];
            userRepoMock.findOne.mockResolvedValue(mockUser);
            expenseRepoMock.find.mockResolvedValue(expenses);

            const result = await service.findAll(userA, 10, 0);

            expect(result).toEqual(expenses);
            expect(expenseRepoMock.find).toHaveBeenCalledWith(expect.objectContaining({
                take: 10,
                skip: 0,
            }));
        });
    });

    describe('remove', () => {
        it('should remove an expense', async () => {
            const expense = { id: 'exp-1', coupleId, userId: userA };
            userRepoMock.findOne.mockResolvedValue(mockUser);
            expenseRepoMock.findOne.mockResolvedValue(expense);

            await service.remove(userA, 'exp-1');

            expect(expenseRepoMock.remove).toHaveBeenCalledWith(expense);
        });

        it('should throw NotFoundException if expense does not exist', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);
            expenseRepoMock.findOne.mockResolvedValue(null);

            await expect(service.remove(userA, 'exp-999')).rejects.toThrow(NotFoundException);
        });
    });

    describe('getReport', () => {
        it('should aggregate expenses by category for the period', async () => {
            const expenses = [
                { category: ExpenseCategory.FOOD, amount: 200000 },
                { category: ExpenseCategory.FOOD, amount: 150000 },
                { category: ExpenseCategory.DATE, amount: 500000 },
            ];
            userRepoMock.findOne.mockResolvedValue(mockUser);
            expenseRepoMock.find.mockResolvedValue(expenses);

            const result = await service.getReport(userA, 'month');

            expect(result.total).toBe(850000);
            expect(result.byCategory.food).toBe(350000);
            expect(result.byCategory.date).toBe(500000);
            expect(result.count).toBe(3);
        });

        it('should return empty report when no expenses', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);
            expenseRepoMock.find.mockResolvedValue([]);

            const result = await service.getReport(userA, 'week');

            expect(result.total).toBe(0);
            expect(result.count).toBe(0);
        });
    });
});
