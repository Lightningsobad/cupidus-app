import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { ThemesService } from './themes.service';
import { CoupleTheme } from './entities/couple-theme.entity';
import { User } from '../users/entities/user.entity';
import { BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';
import { THEME_CATALOG } from './themes.catalog';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

describe('ThemesService', () => {

    let service: ThemesService;

    const userA = 'user-aaa-111';
    const userB = 'user-bbb-222';
    const coupleId = [userA, userB].sort().join(':');

    const mockUserA: Partial<User> = { id: userA, partnerId: userB };
    const mockUserB: Partial<User> = { id: userB, partnerId: userA };
    const mockSingleUser: Partial<User> = { id: 'user-single', partnerId: undefined };

    let mockCoupleTheme: CoupleTheme;
    let coupleThemeRepoMock: any;
    let usersRepoMock: any;
    let dataSourceMock: any;

    beforeEach(async () => {
        mockCoupleTheme = {
            coupleId,
            activeThemeId: 'nebula',
            ownedThemeIds: ['nebula'],
            heartsBalance: 1240,
            pendingThemeId: null,
            pendingRequestedBy: null,
            pendingRequestedAt: null,
            wishlistThemeId: null,
            wishlistSavedBy: null,
            createdAt: new Date(),
            updatedAt: new Date(),
        };

        coupleThemeRepoMock = {
            findOne: jest.fn().mockImplementation(({ where }) => {
                if (where.coupleId === coupleId) {
                    return Promise.resolve({ ...mockCoupleTheme });
                }
                return Promise.resolve(null);
            }),
            create: jest.fn().mockImplementation((dto) => ({ ...dto })),
            save: jest.fn().mockImplementation((entity) => {
                mockCoupleTheme = { ...entity };
                return Promise.resolve(mockCoupleTheme);
            }),
        };

        usersRepoMock = {
            findOne: jest.fn().mockImplementation(({ where }) => {
                if (where.id === userA) return Promise.resolve(mockUserA);
                if (where.id === userB) return Promise.resolve(mockUserB);
                if (where.id === 'user-single') return Promise.resolve(mockSingleUser);
                return Promise.resolve(null);
            }),
        };

        dataSourceMock = {
            transaction: jest.fn().mockImplementation(async (callback) => {
                const manager = {
                    save: jest.fn().mockImplementation((entityClass, entity) => {
                        mockCoupleTheme = { ...entity };
                        return Promise.resolve(mockCoupleTheme);
                    }),
                };
                return callback(manager);
            }),
        };

        const module: TestingModule = await Test.createTestingModule({

            providers: [
                ThemesService,
                { provide: getRepositoryToken(CoupleTheme), useValue: coupleThemeRepoMock },
                { provide: getRepositoryToken(User), useValue: usersRepoMock },
                { provide: DataSource, useValue: dataSourceMock },
                {
                    provide: CoupleNotificationDispatcher,
                    useValue: { dispatchToPartner: jest.fn().mockResolvedValue(undefined) },
                },
            ],
        }).compile();


        service = module.get<ThemesService>(ThemesService);
    });

    describe('getThemeCatalog', () => {
        it('should return all 8 themes in catalog', () => {
            const catalog = service.getThemeCatalog();
            expect(catalog).toHaveLength(8);
            expect(catalog.map((t) => t.id)).toContain('nebula');
            expect(catalog.map((t) => t.id)).toContain('sunset');
            expect(catalog.map((t) => t.id)).toContain('sakura');
            expect(catalog.map((t) => t.id)).toContain('butter');
        });
    });

    describe('getCoupleThemeState', () => {
        it('should throw BadRequestException if user is not paired', async () => {
            await expect(service.getCoupleThemeState('user-single')).rejects.toThrow(
                BadRequestException,
            );
        });

        it('should return existing couple theme state', async () => {
            const state = await service.getCoupleThemeState(userA);
            expect(state.coupleId).toBe(coupleId);
            expect(state.activeThemeId).toBe('nebula');
            expect(state.heartsBalance).toBe(1240);
        });

        it('should create default couple theme state if not found', async () => {
            coupleThemeRepoMock.findOne.mockResolvedValueOnce(null);
            const state = await service.getCoupleThemeState(userA);
            expect(coupleThemeRepoMock.create).toHaveBeenCalled();
            expect(state.activeThemeId).toBe('nebula');
            expect(state.ownedThemeIds).toEqual(['nebula']);
        });
    });

    describe('requestTheme', () => {
        it('should throw NotFoundException for unknown theme', async () => {
            await expect(service.requestTheme(userA, 'non-existent')).rejects.toThrow(
                NotFoundException,
            );
        });

        it('should throw BadRequestException if requesting currently active theme', async () => {
            await expect(service.requestTheme(userA, 'nebula')).rejects.toThrow(
                BadRequestException,
            );
        });

        it('should throw BadRequestException if not enough hearts in wallet for unowned theme', async () => {
            mockCoupleTheme.heartsBalance = 100; // sunset costs 320
            await expect(service.requestTheme(userA, 'sunset')).rejects.toThrow(
                BadRequestException,
            );
        });

        it('should successfully set pending theme request', async () => {
            const result = await service.requestTheme(userA, 'sunset');
            expect(result.pendingThemeId).toBe('sunset');
            expect(result.pendingRequestedBy).toBe(userA);
            expect(result.pendingRequestedAt).toBeInstanceOf(Date);
        });
    });

    describe('approveTheme', () => {
        it('should throw BadRequestException if no pending theme', async () => {
            await expect(service.approveTheme(userB)).rejects.toThrow(BadRequestException);
        });

        it('should throw ForbiddenException if requester tries to approve own request', async () => {
            mockCoupleTheme.pendingThemeId = 'sunset';
            mockCoupleTheme.pendingRequestedBy = userA;
            await expect(service.approveTheme(userA)).rejects.toThrow(ForbiddenException);
        });

        it('should deduct hearts, unlock theme, activate theme and clear pending on approval', async () => {
            mockCoupleTheme.pendingThemeId = 'sunset';
            mockCoupleTheme.pendingRequestedBy = userA;
            mockCoupleTheme.heartsBalance = 1240;

            const result = await service.approveTheme(userB);
            expect(result.activeThemeId).toBe('sunset');
            expect(result.ownedThemeIds).toContain('sunset');
            expect(result.heartsBalance).toBe(1240 - 320); // 920
            expect(result.pendingThemeId).toBeNull();
            expect(result.pendingRequestedBy).toBeNull();
        });

        it('should switch active theme without deducting hearts if theme was already owned', async () => {
            mockCoupleTheme.ownedThemeIds = ['nebula', 'sunset'];
            mockCoupleTheme.pendingThemeId = 'sunset';
            mockCoupleTheme.pendingRequestedBy = userA;
            mockCoupleTheme.heartsBalance = 1240;

            const result = await service.approveTheme(userB);
            expect(result.activeThemeId).toBe('sunset');
            expect(result.heartsBalance).toBe(1240); // no deduction
            expect(result.pendingThemeId).toBeNull();
        });
    });

    describe('rejectTheme', () => {
        it('should throw BadRequestException if no pending theme', async () => {
            await expect(service.rejectTheme(userB)).rejects.toThrow(BadRequestException);
        });

        it('should throw ForbiddenException if requester tries to reject own request', async () => {
            mockCoupleTheme.pendingThemeId = 'sunset';
            mockCoupleTheme.pendingRequestedBy = userA;
            await expect(service.rejectTheme(userA)).rejects.toThrow(ForbiddenException);
        });

        it('should clear pending request on partner rejection', async () => {
            mockCoupleTheme.pendingThemeId = 'sunset';
            mockCoupleTheme.pendingRequestedBy = userA;

            const result = await service.rejectTheme(userB);
            expect(result.pendingThemeId).toBeNull();
            expect(result.pendingRequestedBy).toBeNull();
        });
    });

    describe('toggleWishlist', () => {
        it('should set wishlist theme and toggle off when called again', async () => {
            const res1 = await service.toggleWishlist(userA, 'sakura');
            expect(res1.wishlistThemeId).toBe('sakura');
            expect(res1.wishlistSavedBy).toBe(userA);

            const res2 = await service.toggleWishlist(userA, 'sakura');
            expect(res2.wishlistThemeId).toBeNull();
            expect(res2.wishlistSavedBy).toBeNull();
        });
    });
});
