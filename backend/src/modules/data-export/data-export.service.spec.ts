import { Test, TestingModule } from '@nestjs/testing';
import { DataExportService } from './data-export.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DataExport, ExportStatus } from './entities/data-export.entity';
import { User } from '../users/entities/user.entity';
import { LoveContract } from '../love-contracts/entities/love-contract.entity';
import { Message } from '../messages/entities/message.entity';
import { Expense } from '../expenses/entities/expense.entity';
import { DreamJar } from '../dream-jar/entities/dream-jar.entity';
import { Contribution } from '../dream-jar/entities/contribution.entity';
import { Vibe } from '../vibes/entities/vibe.entity';
import { TimelineEvent } from '../timeline/entities/timeline-event.entity';
import { GalleryItem } from '../gallery/entities/gallery-item.entity';
import { BadRequestException, NotFoundException } from '@nestjs/common';

describe('DataExportService', () => {
    let service: DataExportService;
    let exportRepoMock: any;
    let userRepoMock: any;

    const userId = 'user-aaa';
    const partnerId = 'user-bbb';
    const mockUser = { id: userId, partnerId, email: 'test@test.com', displayName: 'Test' } as Partial<User> as User;

    const createRepoMock = () => ({
        find: jest.fn().mockResolvedValue([]),
        findOne: jest.fn(),
        create: jest.fn((dto) => dto),
        save: jest.fn((entity) => Promise.resolve({ id: 'export-1', ...entity })),
        count: jest.fn(),
    });

    beforeEach(async () => {
        exportRepoMock = {
            ...createRepoMock(),
            find: jest.fn().mockResolvedValue([]),
            findOne: jest.fn().mockResolvedValue(null),
        };

        userRepoMock = {
            ...createRepoMock(),
            findOne: jest.fn().mockResolvedValue(mockUser),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                DataExportService,
                { provide: getRepositoryToken(DataExport), useValue: exportRepoMock },
                { provide: getRepositoryToken(User), useValue: userRepoMock },
                { provide: getRepositoryToken(LoveContract), useValue: createRepoMock() },
                { provide: getRepositoryToken(Message), useValue: createRepoMock() },
                { provide: getRepositoryToken(Expense), useValue: createRepoMock() },
                { provide: getRepositoryToken(DreamJar), useValue: createRepoMock() },
                { provide: getRepositoryToken(Contribution), useValue: createRepoMock() },
                { provide: getRepositoryToken(Vibe), useValue: createRepoMock() },
                { provide: getRepositoryToken(TimelineEvent), useValue: createRepoMock() },
                { provide: getRepositoryToken(GalleryItem), useValue: createRepoMock() },
            ],
        }).compile();

        service = module.get<DataExportService>(DataExportService);
    });

    describe('getExports', () => {
        it('should return user exports ordered by createdAt DESC', async () => {
            const exports = [{ id: 'e-1', status: ExportStatus.COMPLETED }];
            exportRepoMock.find.mockResolvedValue(exports);

            const result = await service.getExports(userId);

            expect(result).toEqual(exports);
            expect(exportRepoMock.find).toHaveBeenCalledWith({
                where: { userId },
                order: { createdAt: 'DESC' },
                take: 10,
            });
        });
    });

    describe('getExportFile', () => {
        it('should return file path for completed export', async () => {
            const fs = require('fs');
            const existsSyncSpy = jest.spyOn(fs, 'existsSync').mockReturnValue(true);

            exportRepoMock.findOne.mockResolvedValue({
                id: 'export-1',
                userId,
                status: ExportStatus.COMPLETED,
                filePath: '/some/path.zip',
            });

            const result = await service.getExportFile(userId, 'export-1');
            expect(result).toBe('/some/path.zip');

            existsSyncSpy.mockRestore();
        });

        it('should throw NotFoundException for non-existent export', async () => {
            exportRepoMock.findOne.mockResolvedValue(null);

            await expect(service.getExportFile(userId, 'bad-id')).rejects.toThrow(NotFoundException);
        });

        it('should throw BadRequestException for non-completed export', async () => {
            exportRepoMock.findOne.mockResolvedValue({
                id: 'export-1',
                userId,
                status: ExportStatus.PROCESSING,
            });

            await expect(service.getExportFile(userId, 'export-1')).rejects.toThrow(BadRequestException);
        });

        it('should throw NotFoundException when file missing from disk', async () => {
            const fs = require('fs');
            const existsSyncSpy = jest.spyOn(fs, 'existsSync').mockReturnValue(false);

            exportRepoMock.findOne.mockResolvedValue({
                id: 'export-1',
                userId,
                status: ExportStatus.COMPLETED,
                filePath: '/deleted/path.zip',
            });

            await expect(service.getExportFile(userId, 'export-1')).rejects.toThrow(NotFoundException);

            existsSyncSpy.mockRestore();
        });
    });

    describe('requestExport', () => {
        it('should reject if export is already in progress', async () => {
            exportRepoMock.findOne.mockResolvedValueOnce({ id: 'export-1', status: ExportStatus.PROCESSING });

            await expect(service.requestExport(userId)).rejects.toThrow(BadRequestException);
        });

        it('should create a PENDING export and fire-and-forget processing', async () => {
            // No existing export
            exportRepoMock.findOne.mockResolvedValueOnce(null);

            const savedExport = { id: 'new-export', userId, status: ExportStatus.PENDING };
            exportRepoMock.save.mockResolvedValueOnce(savedExport);

            const result = await service.requestExport(userId);

            expect(result.status).toBe(ExportStatus.PENDING);
            expect(exportRepoMock.create).toHaveBeenCalledWith({
                userId,
                status: ExportStatus.PENDING,
            });
        });

        it('should catch DB constraint violation as duplicate export', async () => {
            exportRepoMock.findOne.mockResolvedValueOnce(null);
            exportRepoMock.save.mockRejectedValueOnce({ code: '23505', message: 'unique violation' });

            await expect(service.requestExport(userId)).rejects.toThrow(BadRequestException);
        });
    });
});
