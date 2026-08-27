import { Test, TestingModule } from '@nestjs/testing';
import { VibesService } from './vibes.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Vibe, Mood } from './entities/vibe.entity';
import { User } from '../users/entities/user.entity';
import { NotFoundException } from '@nestjs/common';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

describe('VibesService', () => {
    let service: VibesService;
    let vibeRepoMock: any;
    let userRepoMock: any;
    let dispatcherMock: any;

    const mockUserId = 'user-123';
    const mockPartnerId = 'partner-456';
    const mockUser = { id: mockUserId, partnerId: mockPartnerId } as Partial<User> as User;
    const mockUserNoPartner = { id: mockUserId, partnerId: null } as unknown as User;

    beforeEach(async () => {
        vibeRepoMock = {
            create: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
            findOne: jest.fn(),
        };

        userRepoMock = {
            findOne: jest.fn(),
        };

        dispatcherMock = {
            dispatchToPartner: jest.fn().mockResolvedValue(undefined),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                VibesService,
                {
                    provide: getRepositoryToken(Vibe),
                    useValue: vibeRepoMock,
                },
                {
                    provide: getRepositoryToken(User),
                    useValue: userRepoMock,
                },
                {
                    provide: CoupleNotificationDispatcher,
                    useValue: dispatcherMock,
                },
            ],
        }).compile();

        service = module.get<VibesService>(VibesService);
    });


    describe('create', () => {
        it('should create a vibe and return it', async () => {
            const dto = { mood: Mood.HAPPY };
            const savedVibe = { id: 'vibe-1', userId: mockUserId, mood: Mood.HAPPY, note: null, createdAt: new Date() };

            userRepoMock.findOne.mockResolvedValue(mockUser);
            vibeRepoMock.create.mockReturnValue(savedVibe);
            vibeRepoMock.save.mockResolvedValue(savedVibe);

            const result = await service.create(mockUserId, dto);

            expect(result.mood).toBe(Mood.HAPPY);
            expect(vibeRepoMock.save).toHaveBeenCalled();
            expect(dispatcherMock.dispatchToPartner).toHaveBeenCalledWith(
                expect.objectContaining({
                    senderId: mockUserId,
                    partnerId: mockPartnerId,
                    eventName: 'vibe:posted',
                }),
            );
            expect(dispatcherMock.dispatchToPartner).not.toHaveBeenCalledWith(
                expect.objectContaining({
                    emitToSenderToo: true,
                }),
            );
        });

        it('should throw NotFoundException if user not found', async () => {
            userRepoMock.findOne.mockResolvedValue(null);

            await expect(service.create('nonexistent', { mood: Mood.SAD }))
                .rejects.toThrow(NotFoundException);
        });

        it('should create a vibe with optional note', async () => {
            const dto = { mood: Mood.TIRED, note: 'Long day' };
            const savedVibe = { id: 'vibe-2', userId: mockUserId, mood: Mood.TIRED, note: 'Long day', createdAt: new Date() };

            userRepoMock.findOne.mockResolvedValue(mockUserNoPartner);
            vibeRepoMock.create.mockReturnValue(savedVibe);
            vibeRepoMock.save.mockResolvedValue(savedVibe);

            const result = await service.create(mockUserId, dto);

            expect(result.note).toBe('Long day');
            expect(result.mood).toBe(Mood.TIRED);
        });
    });

    describe('getHistory', () => {
        it('should return vibes for user within date range', async () => {
            const mockVibes = [
                { id: 'v1', userId: mockUserId, mood: Mood.HAPPY, createdAt: new Date() },
                { id: 'v2', userId: mockUserId, mood: Mood.SAD, createdAt: new Date() },
            ];
            vibeRepoMock.find.mockResolvedValue(mockVibes);

            const result = await service.getHistory(mockUserId, 30);

            expect(result).toHaveLength(2);
            expect(vibeRepoMock.find).toHaveBeenCalledWith(
                expect.objectContaining({
                    where: expect.objectContaining({ userId: mockUserId }),
                    order: { createdAt: 'DESC' },
                }),
            );
        });

        it('should default to 30 days', async () => {
            vibeRepoMock.find.mockResolvedValue([]);

            await service.getHistory(mockUserId);

            expect(vibeRepoMock.find).toHaveBeenCalled();
        });
    });

    describe('getPartnerHistory', () => {
        it('should return partner vibes when partner exists', async () => {
            const partnerVibes = [{ id: 'pv1', userId: mockPartnerId, mood: Mood.HORNY }];
            userRepoMock.findOne.mockResolvedValue(mockUser);
            vibeRepoMock.find.mockResolvedValue(partnerVibes);

            const result = await service.getPartnerHistory(mockUserId);

            expect(result).toHaveLength(1);
        });

        it('should return empty array when user has no partner', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserNoPartner);

            const result = await service.getPartnerHistory(mockUserId);

            expect(result).toEqual([]);
        });

        it('should return empty array when user not found', async () => {
            userRepoMock.findOne.mockResolvedValue(null);

            const result = await service.getPartnerHistory('nonexistent');

            expect(result).toEqual([]);
        });
    });

    describe('getTodayVibe', () => {
        it('should return today\'s vibe if exists', async () => {
            const todayVibe = { id: 'tv1', userId: mockUserId, mood: Mood.ANGRY, createdAt: new Date() };
            vibeRepoMock.findOne.mockResolvedValue(todayVibe);

            const result = await service.getTodayVibe(mockUserId);

            expect(result).toBeDefined();
            expect(result?.mood).toBe(Mood.ANGRY);
        });

        it('should return null if no vibe today', async () => {
            vibeRepoMock.findOne.mockResolvedValue(null);

            const result = await service.getTodayVibe(mockUserId);

            expect(result).toBeNull();
        });
    });
});
