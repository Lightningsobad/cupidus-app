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

    describe('createOrUpdateAlarm', () => {
        it('should create a new alarm if one does not exist', async () => {
            const requesterId = 'req1';
            const partnerId = 'part1';
            const time = new Date();

            mockUserRepo.findOne.mockResolvedValue({ id: requesterId, partnerId });
            mockAlarmRepo.findOne.mockResolvedValue(null); // No existing alarm
            mockAlarmRepo.create.mockReturnValue({ requesterId, partnerId, time, status: 'pending_confirmation' });
            mockAlarmRepo.save.mockResolvedValue({ id: 'alarm1', requesterId, partnerId, time, status: 'pending_confirmation' });

            const result = await service.createOrUpdateAlarm(requesterId, time);

            expect(result).toBeDefined();
            expect(mockAlarmRepo.create).toHaveBeenCalled();
            expect(mockAlarmRepo.save).toHaveBeenCalled();
        });
    });

    describe('stopAlarm', () => {
        it('should stop alarm locally (ringing -> stop) and not fully stop if only 1 person stopped', async () => {
            const alarm = { id: 'a1', status: 'ringing', stopperIds: [] };
            mockAlarmRepo.findOne.mockResolvedValue(alarm);
            mockAlarmRepo.save.mockImplementation(a => Promise.resolve(a));

            const result = await service.stopAlarm('u1', 'a1');

            expect(result.stopperIds).toContain('u1');
            expect(result.status).toBe('ringing'); // Not fully stopped yet
        });

        it('should fully stop alarm if both people stop it', async () => {
            const alarm = { id: 'a1', status: 'ringing', stopperIds: ['u2'] };
            mockAlarmRepo.findOne.mockResolvedValue(alarm);
            mockAlarmRepo.save.mockImplementation(a => Promise.resolve(a));

            const result = await service.stopAlarm('u1', 'a1');

            expect(result.stopperIds).toContain('u1');
            expect(result.stopperIds).toContain('u2');
            expect(result.status).toBe('stopped');
        });
    });
});
