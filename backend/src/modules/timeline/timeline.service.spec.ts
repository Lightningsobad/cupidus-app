import { Test, TestingModule } from '@nestjs/testing';
import { TimelineService } from './timeline.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { TimelineEvent, TimelineEventType } from './entities/timeline-event.entity';
import { User } from '../users/entities/user.entity';
import { NotFoundException, BadRequestException } from '@nestjs/common';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

describe('TimelineService', () => {
    let service: TimelineService;
    let timelineRepoMock: any;
    let userRepoMock: any;
    let dispatcherMock: any;

    const userA = 'user-aaa';
    const userB = 'user-bbb';
    const coupleId = [userA, userB].sort().join(':');
    const mockUser = { id: userA, partnerId: userB } as Partial<User> as User;
    const mockUserNoPartner = { id: userA, partnerId: null } as unknown as User;

    beforeEach(async () => {
        timelineRepoMock = {
            create: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
            findOne: jest.fn(),
            remove: jest.fn(),
        };

        userRepoMock = {
            findOne: jest.fn(),
        };

        dispatcherMock = {
            dispatchToPartner: jest.fn().mockResolvedValue(undefined),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                TimelineService,
                { provide: getRepositoryToken(TimelineEvent), useValue: timelineRepoMock },
                { provide: getRepositoryToken(User), useValue: userRepoMock },
                { provide: CoupleNotificationDispatcher, useValue: dispatcherMock },
            ],
        }).compile();


        service = module.get<TimelineService>(TimelineService);
    });

    describe('addEvent', () => {
        it('should add a memory event', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);
            const dto = { title: 'Our first date', description: 'It was magical' };
            const created = { id: 'ev-1', coupleId, type: TimelineEventType.MEMORY, ...dto, icon: '💝' };
            timelineRepoMock.create.mockReturnValue(created);
            timelineRepoMock.save.mockResolvedValue(created);

            const result = await service.addEvent(userA, dto);

            expect(result.title).toBe('Our first date');
            expect(result.type).toBe(TimelineEventType.MEMORY);
        });

        it('should throw if no partner', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserNoPartner);
            await expect(service.addEvent(userA, { title: 'test' })).rejects.toThrow(NotFoundException);
        });
    });

    describe('getTimeline', () => {
        it('should return couple timeline events', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);
            const events = [
                { id: '1', coupleId, title: 'First date', type: TimelineEventType.MEMORY },
                { id: '2', coupleId, title: '1 Week Together!', type: TimelineEventType.MILESTONE },
            ];
            timelineRepoMock.find.mockResolvedValue(events);

            const result = await service.getTimeline(userA);

            expect(result).toHaveLength(2);
        });

        it('should return empty array if no partner', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserNoPartner);

            const result = await service.getTimeline(userA);

            expect(result).toEqual([]);
        });
    });

    describe('addMilestone', () => {
        it('should add a milestone event', async () => {
            const milestone = { id: 'ev-m', coupleId, type: TimelineEventType.MILESTONE, title: '1 Week Together!', icon: '🏆' };
            timelineRepoMock.create.mockReturnValue(milestone);
            timelineRepoMock.save.mockResolvedValue(milestone);

            const result = await service.addMilestone(coupleId, '1 Week Together!');

            expect(result.type).toBe(TimelineEventType.MILESTONE);
        });
    });

    describe('deleteEvent', () => {
        it('should delete a memory event', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);
            const event = { id: 'ev-1', coupleId, type: TimelineEventType.MEMORY };
            timelineRepoMock.findOne.mockResolvedValue(event);

            await service.deleteEvent(userA, 'ev-1');

            expect(timelineRepoMock.remove).toHaveBeenCalledWith(event);
        });

        it('should not allow deleting milestone events', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);
            const milestone = { id: 'ev-m', coupleId, type: TimelineEventType.MILESTONE };
            timelineRepoMock.findOne.mockResolvedValue(milestone);

            await expect(service.deleteEvent(userA, 'ev-m')).rejects.toThrow(BadRequestException);
        });

        it('should throw if event not found', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);
            timelineRepoMock.findOne.mockResolvedValue(null);

            await expect(service.deleteEvent(userA, 'missing')).rejects.toThrow(NotFoundException);
        });
    });
});
