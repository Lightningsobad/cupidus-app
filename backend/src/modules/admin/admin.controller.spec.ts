import { Test, TestingModule } from '@nestjs/testing';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { AdminGuard } from '../../common/guards/admin.guard';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from '../users/entities/user.entity';

describe('AdminController', () => {
    let controller: AdminController;
    let serviceMock: any;

    const mockReq = { user: { id: 'admin-1' } };

    beforeEach(async () => {
        serviceMock = {
            getAllConfigs: jest.fn().mockResolvedValue([{ key: 'emojiStormEnabled', value: true }]),
            getConfig: jest.fn().mockResolvedValue({ key: 'maxPushPerDay', value: 50 }),
            updateConfig: jest.fn().mockResolvedValue({ key: 'maxPushPerDay', value: 20 }),
            getMetrics: jest.fn().mockResolvedValue({ totalUsers: 100, totalCouples: 30, activeToday: 42, totalExports: 0 }),
        };

        const module: TestingModule = await Test.createTestingModule({
            controllers: [AdminController],
            providers: [
                { provide: AdminService, useValue: serviceMock },
                { provide: getRepositoryToken(User), useValue: { findOne: jest.fn() } },
            ],
        }).compile();

        controller = module.get<AdminController>(AdminController);
    });

    it('should list all configs', async () => {
        const result = await controller.getAllConfigs();
        expect(serviceMock.getAllConfigs).toHaveBeenCalled();
        expect(result).toHaveLength(1);
    });

    it('should get a config by key', async () => {
        const result = await controller.getConfig('maxPushPerDay');
        expect(serviceMock.getConfig).toHaveBeenCalledWith('maxPushPerDay');
        expect(result.value).toBe(50);
    });

    it('should update a config value', async () => {
        const result = await controller.updateConfig(mockReq, 'maxPushPerDay', { value: 20 });
        expect(serviceMock.updateConfig).toHaveBeenCalledWith('admin-1', 'maxPushPerDay', { value: 20 });
        expect(result.value).toBe(20);
    });

    it('should return metrics', async () => {
        const result = await controller.getMetrics();
        expect(result.totalUsers).toBe(100);
        expect(result.totalCouples).toBe(30);
    });
});
