import { Test, TestingModule } from '@nestjs/testing';
import { AdminService } from './admin.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { AdminConfig } from './entities/admin-config.entity';
import { User } from '../users/entities/user.entity';
import { DataExport } from '../data-export/entities/data-export.entity';
import { NotFoundException } from '@nestjs/common';

describe('AdminService', () => {
    let service: AdminService;
    let configRepoMock: any;
    let userRepoMock: any;
    let exportRepoMock: any;

    beforeEach(async () => {
        configRepoMock = {
            find: jest.fn().mockResolvedValue([]),
            findOne: jest.fn(),
            create: jest.fn((dto) => dto),
            save: jest.fn((entity) => Promise.resolve({ id: 'cfg-1', ...entity })),
        };

        userRepoMock = {
            count: jest.fn().mockResolvedValue(100),
            createQueryBuilder: jest.fn().mockReturnValue({
                where: jest.fn().mockReturnThis(),
                getCount: jest.fn().mockResolvedValue(42),
            }),
        };

        exportRepoMock = {
            count: jest.fn().mockResolvedValue(5),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                AdminService,
                { provide: getRepositoryToken(AdminConfig), useValue: configRepoMock },
                { provide: getRepositoryToken(User), useValue: userRepoMock },
                { provide: getRepositoryToken(DataExport), useValue: exportRepoMock },
            ],
        }).compile();

        service = module.get<AdminService>(AdminService);
    });

    describe('getAllConfigs', () => {
        it('should return all configs sorted by key', async () => {
            const configs = [{ key: 'a' }, { key: 'b' }];
            configRepoMock.find.mockResolvedValue(configs);

            const result = await service.getAllConfigs();
            expect(result).toEqual(configs);
            expect(configRepoMock.find).toHaveBeenCalledWith({ order: { key: 'ASC' } });
        });
    });

    describe('getConfig', () => {
        it('should return a config by key', async () => {
            const config = { key: 'emojiStormEnabled', value: true };
            configRepoMock.findOne.mockResolvedValue(config);

            const result = await service.getConfig('emojiStormEnabled');
            expect(result).toEqual(config);
        });

        it('should throw NotFoundException for unknown key', async () => {
            configRepoMock.findOne.mockResolvedValue(null);

            await expect(service.getConfig('unknown')).rejects.toThrow(NotFoundException);
        });
    });

    describe('updateConfig', () => {
        it('should update an existing config', async () => {
            const existing = { key: 'maxPushPerDay', value: 50, updatedBy: null };
            configRepoMock.findOne.mockResolvedValue(existing);

            const result = await service.updateConfig('admin-1', 'maxPushPerDay', { value: 20 });

            expect(configRepoMock.save).toHaveBeenCalled();
            expect(existing.value).toBe(20);
            expect(existing.updatedBy).toBe('admin-1');
        });

        it('should create a new config if key does not exist', async () => {
            configRepoMock.findOne.mockResolvedValue(null);

            await service.updateConfig('admin-1', 'newKey', { value: 'newVal', description: 'testing' });

            expect(configRepoMock.create).toHaveBeenCalledWith({
                key: 'newKey',
                value: 'newVal',
                description: 'testing',
                updatedBy: 'admin-1',
            });
            expect(configRepoMock.save).toHaveBeenCalled();
        });
    });

    describe('getMetrics', () => {
        it('should return platform metrics including totalExports', async () => {
            userRepoMock.count
                .mockResolvedValueOnce(100)  // totalUsers
                .mockResolvedValueOnce(60);  // pairedUsers

            const result = await service.getMetrics();

            expect(result.totalUsers).toBe(100);
            expect(result.totalCouples).toBe(30); // 60 / 2
            expect(result.activeToday).toBe(42);
            expect(result.totalExports).toBe(5); // from exportRepoMock
            expect(exportRepoMock.count).toHaveBeenCalled();
        });
    });

    describe('seedDefaults', () => {
        it('should seed config when empty', async () => {
            configRepoMock.findOne.mockResolvedValue(null);

            await service.seedDefaults();

            expect(configRepoMock.create).toHaveBeenCalledTimes(3);
            expect(configRepoMock.save).toHaveBeenCalledTimes(3);
        });

        it('should not overwrite existing configs', async () => {
            configRepoMock.findOne.mockResolvedValue({ key: 'existing' });

            await service.seedDefaults();

            expect(configRepoMock.save).not.toHaveBeenCalled();
        });
    });
});
