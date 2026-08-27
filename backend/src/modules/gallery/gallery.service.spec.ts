import { Test, TestingModule } from '@nestjs/testing';
import { GalleryService } from './gallery.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { GalleryItem } from './entities/gallery-item.entity';
import { NotFoundException } from '@nestjs/common';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

describe('GalleryService', () => {
    let service: GalleryService;
    let repoMock: any;
    let dispatcherMock: any;

    const userId = 'user-aaa';

    beforeEach(async () => {
        repoMock = {
            create: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
            findOne: jest.fn(),
            remove: jest.fn(),
            count: jest.fn(),
        };

        dispatcherMock = {
            dispatchToPartner: jest.fn().mockResolvedValue(undefined),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                GalleryService,
                { provide: getRepositoryToken(GalleryItem), useValue: repoMock },
                { provide: CoupleNotificationDispatcher, useValue: dispatcherMock },
            ],
        }).compile();


        service = module.get<GalleryService>(GalleryService);
    });

    describe('create', () => {
        it('should create an encrypted gallery item', async () => {
            const dto = { filename: 'photo.enc', mimeType: 'image/jpeg' };
            const created = { id: 'item-1', userId, ...dto, isEncrypted: true };
            repoMock.create.mockReturnValue(created);
            repoMock.save.mockResolvedValue(created);

            const result = await service.create(userId, dto);

            expect(result.isEncrypted).toBe(true);
            expect(result.filename).toBe('photo.enc');
        });
    });

    describe('findAll', () => {
        it('should return user gallery items', async () => {
            const items = [
                { id: '1', userId, filename: 'a.enc' },
                { id: '2', userId, filename: 'b.enc' },
            ];
            repoMock.find.mockResolvedValue(items);

            const result = await service.findAll(userId);

            expect(result).toHaveLength(2);
            expect(repoMock.find).toHaveBeenCalledWith({
                where: { userId },
                order: { createdAt: 'DESC' },
                take: 50,
                skip: 0,
            });
        });
    });

    describe('remove', () => {
        it('should remove a gallery item', async () => {
            const item = { id: 'item-1', userId, filename: 'photo.enc' };
            repoMock.findOne.mockResolvedValue(item);
            repoMock.remove.mockResolvedValue(item);

            await service.remove(userId, 'item-1');

            expect(repoMock.remove).toHaveBeenCalledWith(item);
        });

        it('should throw NotFoundException if item not found', async () => {
            repoMock.findOne.mockResolvedValue(null);

            await expect(service.remove(userId, 'missing-id')).rejects.toThrow(NotFoundException);
        });

        it('should not allow deleting other users items', async () => {
            repoMock.findOne.mockResolvedValue(null); // findOne with { userId } won't match

            await expect(service.remove(userId, 'other-users-item')).rejects.toThrow(NotFoundException);
        });
    });

    describe('count', () => {
        it('should return count', async () => {
            repoMock.count.mockResolvedValue(5);

            const result = await service.count(userId);

            expect(result).toBe(5);
        });
    });
});
