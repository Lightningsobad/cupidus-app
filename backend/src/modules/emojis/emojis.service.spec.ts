import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { EmojisService } from './emojis.service';
import { CoupleEmoji } from './entities/couple-emoji.entity';
import { User } from '../users/entities/user.entity';

describe('EmojisService', () => {
    let service: EmojisService;

    const userA = 'user-aaa-111';
    const userB = 'user-bbb-222';
    const coupleId = [userA, userB].sort().join(':');

    const mockUserA: Partial<User> = { id: userA, partnerId: userB };
    let mockCoupleEmoji: CoupleEmoji;
    let coupleEmojiRepoMock: any;
    let usersRepoMock: any;

    beforeEach(async () => {
        mockCoupleEmoji = {
            coupleId,
            activePackId: 'mochi-cat',
            downloadedPackIds: ['mochi-cat', 'baby-dino'],
            createdAt: new Date(),
            updatedAt: new Date(),
        };

        coupleEmojiRepoMock = {
            findOne: jest.fn().mockImplementation(({ where }) => {
                if (where.coupleId === coupleId) {
                    return Promise.resolve({ ...mockCoupleEmoji });
                }
                return Promise.resolve(null);
            }),
            create: jest.fn().mockImplementation((dto) => ({ ...dto })),
            save: jest.fn().mockImplementation((entity) => {
                mockCoupleEmoji = { ...entity };
                return Promise.resolve(mockCoupleEmoji);
            }),
        };

        usersRepoMock = {
            findOne: jest.fn().mockImplementation(({ where }) => {
                if (where.id === userA) return Promise.resolve(mockUserA);
                return Promise.resolve(null);
            }),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                EmojisService,
                { provide: getRepositoryToken(CoupleEmoji), useValue: coupleEmojiRepoMock },
                { provide: getRepositoryToken(User), useValue: usersRepoMock },
            ],
        }).compile();

        service = module.get<EmojisService>(EmojisService);
    });

    describe('getEmojiCatalog', () => {
        it('should return all emoji packs with 20 expressions each', () => {
            const catalog = service.getEmojiCatalog();
            expect(catalog).toHaveLength(2);
            expect(catalog.find((p) => p.id === 'mochi-cat')?.emojis).toHaveLength(20);
            expect(catalog.find((p) => p.id === 'baby-dino')?.emojis).toHaveLength(20);
        });
    });

    describe('getCoupleEmojiState', () => {
        it('should return couple emoji state', async () => {
            const state = await service.getCoupleEmojiState(userA);
            expect(state.downloadedPackIds).toContain('mochi-cat');
            expect(state.downloadedPackIds).toContain('baby-dino');
        });
    });

    describe('setActivePack', () => {
        it('should update active emoji pack', async () => {
            const updated = await service.setActivePack(userA, 'baby-dino');
            expect(updated.activePackId).toBe('baby-dino');
        });
    });
});
