import { Test, TestingModule } from '@nestjs/testing';
import { AlarmsService } from './alarms.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Alarm } from './entities/alarm.entity';
import { User } from '../users/entities/user.entity';
import { AlarmsGateway } from './alarms.gateway';
import { Repository } from 'typeorm';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

describe('AlarmsService', () => {
    let service: AlarmsService;
    let alarmRepo: Repository<Alarm>;
    let gateway: AlarmsGateway;

    const mockAlarmRepo = {
        find: jest.fn(),
        findOne: jest.fn(),
        save: jest.fn(),
        create: jest.fn(),
        remove: jest.fn(),
        manager: {
            transaction: jest.fn().mockImplementation((cb) => cb({ save: mockAlarmRepo.save })),
        },
    };

    const mockUserRepo = {
        findOne: jest.fn(),
    };

    const mockGateway = {
        triggerAlarm: jest.fn(),
    };

    const mockDispatcher = {
        dispatchToPartner: jest.fn().mockResolvedValue(undefined),
    };

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                AlarmsService,
                {
                    provide: getRepositoryToken(Alarm),
                    useValue: mockAlarmRepo,
                },
                {
                    provide: getRepositoryToken(User),
                    useValue: mockUserRepo,
                },
                {
                    provide: AlarmsGateway,
                    useValue: mockGateway,
                },
                {
                    provide: CoupleNotificationDispatcher,
                    useValue: mockDispatcher,
                },
            ],
        }).compile();

        service = module.get<AlarmsService>(AlarmsService);
        alarmRepo = module.get<Repository<Alarm>>(getRepositoryToken(Alarm));
        gateway = module.get<AlarmsGateway>(AlarmsGateway);
    });

    it('should be defined', () => {
        expect(service).toBeDefined();
    });

    describe('createAlarm', () => {
        it('should create a new alarm with pending_confirmation status', async () => {
            const requesterId = 'req1';
            const partnerId = 'part1';
            const time = new Date().toISOString();

            mockUserRepo.findOne.mockResolvedValue({ id: requesterId, partnerId });
            mockAlarmRepo.create.mockReturnValue({
                requesterId,
                partnerId,
                time: new Date(time),
                description: 'Thức dậy',
                weekdays: ['1', '2', '3'],
                status: 'pending_confirmation',
            });
            mockAlarmRepo.save.mockResolvedValue({
                id: 'alarm1',
                requesterId,
                partnerId,
                time: new Date(time),
                description: 'Thức dậy',
                weekdays: ['1', '2', '3'],
                status: 'pending_confirmation',
            });

            const result = await service.createAlarm(requesterId, {
                time,
                description: 'Thức dậy',
                weekdays: ['1', '2', '3'],
            });

            expect(result).toBeDefined();
            expect(result.status).toBe('pending_confirmation');
            expect(mockAlarmRepo.create).toHaveBeenCalled();
            expect(mockAlarmRepo.save).toHaveBeenCalled();
            expect(mockDispatcher.dispatchToPartner).toHaveBeenCalled();
        });
    });

    describe('requestToggle', () => {
        it('should set alarm status to pending_toggle with targetIsActive', async () => {
            const alarm = { id: 'a1', requesterId: 'u1', partnerId: 'u2', isActive: true, status: 'scheduled' };
            mockAlarmRepo.findOne.mockResolvedValue(alarm);
            mockUserRepo.findOne.mockResolvedValue({ id: 'u1', partnerId: 'u2' });
            mockAlarmRepo.save.mockImplementation(a => Promise.resolve(a));

            const result = await service.requestToggle('u1', 'a1', false);

            expect(result.status).toBe('pending_toggle');
            expect(result.targetIsActive).toBe(false);
            expect(mockDispatcher.dispatchToPartner).toHaveBeenCalled();
        });
    });

    describe('confirmAlarm', () => {
        it('should confirm pending_toggle and apply isActive', async () => {
            const alarm = { id: 'a1', requesterId: 'u1', partnerId: 'u2', isActive: true, targetIsActive: false, status: 'pending_toggle' };
            mockAlarmRepo.findOne.mockResolvedValue(alarm);
            mockAlarmRepo.save.mockImplementation(a => Promise.resolve(a));

            const result = await service.confirmAlarm('u2', 'a1');

            expect(result.isActive).toBe(false);
            expect(result.status).toBe('scheduled');
            expect(result.targetIsActive).toBeNull();
        });

        it('should confirm pending_deletion and remove alarm', async () => {
            const alarm = { id: 'a1', requesterId: 'u1', partnerId: 'u2', status: 'pending_deletion' };
            mockAlarmRepo.findOne.mockResolvedValue(alarm);
            mockAlarmRepo.remove.mockResolvedValue(alarm);

            const result = await service.confirmAlarm('u2', 'a1');

            expect(result.deleted).toBe(true);
            expect(mockAlarmRepo.remove).toHaveBeenCalledWith(alarm);
        });
    });

    describe('stopAlarm', () => {
        it('should stop alarm locally (ringing -> stop) and not fully stop if only 1 person stopped', async () => {
            const alarm = { id: 'a1', status: 'ringing', stopperIds: [], requesterId: 'u1', partnerId: 'u2' };
            mockAlarmRepo.findOne.mockResolvedValue(alarm);
            mockUserRepo.findOne.mockResolvedValue({ id: 'u1', displayName: 'User 1' });
            mockAlarmRepo.save.mockImplementation(a => Promise.resolve(a));

            const result = await service.stopAlarm('u1', 'a1');

            expect(result.stopperIds).toContain('u1');
            expect(result.status).toBe('ringing'); // Not fully stopped yet
        });

        it('should fully stop alarm if both people stop it', async () => {
            const alarm = { id: 'a1', status: 'ringing', stopperIds: ['u2'], requesterId: 'u1', partnerId: 'u2' };
            mockAlarmRepo.findOne.mockResolvedValue(alarm);
            mockUserRepo.findOne.mockResolvedValue({ id: 'u1', displayName: 'User 1' });
            mockAlarmRepo.save.mockImplementation(a => Promise.resolve(a));

            const result = await service.stopAlarm('u1', 'a1');

            expect(result.stopperIds).toContain('u1');
            expect(result.stopperIds).toContain('u2');
            expect(result.status).toBe('stopped');
        });
    });
});
