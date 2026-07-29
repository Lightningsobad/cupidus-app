import { Test, TestingModule } from '@nestjs/testing';
import { ExpensesController } from './expenses.controller';
import { ExpensesService } from './expenses.service';
import { ExpenseCategory } from './entities/expense.entity';

describe('ExpensesController', () => {
    let controller: ExpensesController;
    let serviceMock: any;

    const mockReq = { user: { id: 'user-aaa' } };
    const mockExpense = { id: 'exp-1', category: ExpenseCategory.FOOD, amount: 200000, date: '2026-02-15' };
    const mockReport = { period: '2026-02-01 to 2026-02-15', total: 850000, byCategory: { food: 350000, date: 500000 }, count: 3 };

    beforeEach(async () => {
        serviceMock = {
            create: jest.fn().mockResolvedValue(mockExpense),
            findAll: jest.fn().mockResolvedValue([mockExpense]),
            remove: jest.fn().mockResolvedValue(undefined),
            getReport: jest.fn().mockResolvedValue(mockReport),
        };

        const module: TestingModule = await Test.createTestingModule({
            controllers: [ExpensesController],
            providers: [{ provide: ExpensesService, useValue: serviceMock }],
        }).compile();

        controller = module.get<ExpensesController>(ExpensesController);
    });

    it('should create an expense', async () => {
        const dto = { category: ExpenseCategory.FOOD, amount: 200000, date: '2026-02-15' };
        const result = await controller.create(mockReq, dto);
        expect(serviceMock.create).toHaveBeenCalledWith('user-aaa', dto);
        expect(result.category).toBe(ExpenseCategory.FOOD);
    });

    it('should return all expenses with default pagination', async () => {
        const result = await controller.findAll(mockReq);
        expect(serviceMock.findAll).toHaveBeenCalledWith('user-aaa', 50, 0);
        expect(result).toEqual([mockExpense]);
    });

    it('should get report with default period (month)', async () => {
        const result = await controller.getReport(mockReq, 'month');
        expect(serviceMock.getReport).toHaveBeenCalledWith('user-aaa', 'month');
        expect(result.total).toBe(850000);
    });

    it('should get report with week period', async () => {
        await controller.getReport(mockReq, 'week');
        expect(serviceMock.getReport).toHaveBeenCalledWith('user-aaa', 'week');
    });

    it('should delete an expense', async () => {
        await controller.remove(mockReq, 'exp-1');
        expect(serviceMock.remove).toHaveBeenCalledWith('user-aaa', 'exp-1');
    });
});
