import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ExecutionContext } from '@nestjs/common';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { JwtAuthGuard } from '../src/common/guards/jwt-auth.guard';
import { AlarmsService } from '../src/modules/alarms/alarms.service';
import { AlarmsGateway } from '../src/modules/alarms/alarms.gateway';
import { User } from '../src/modules/users/entities/user.entity';
import { Alarm } from '../src/modules/alarms/entities/alarm.entity';
import { UsersService } from '../src/modules/users/users.service';
import { CoupleNotificationDispatcher } from '../src/modules/notifications/couple-notification-dispatcher.service';

describe('Synced Alarms E2E Full Lifecycle', () => {
    let app: INestApplication;
    let alarmsService: AlarmsService;
    let alarmsGateway: AlarmsGateway;
    let usersRepository: Repository<User>;
    let alarmsRepository: Repository<Alarm>;
    let dispatcher: CoupleNotificationDispatcher;

    const userA = {
        id: '11111111-1111-4111-8111-111111111111',
        firebaseUid: 'firebase-uid-a',
        email: 'userA@test.com',
        displayName: 'Anh Yêu',
        partnerId: '22222222-2222-4222-8222-222222222222',
        isEmailVerified: true,
        language: 'vi',
    };

    const userB = {
        id: '22222222-2222-4222-8222-222222222222',
        firebaseUid: 'firebase-uid-b',
        email: 'userB@test.com',
        displayName: 'Em Yêu',
        partnerId: '11111111-1111-4111-8111-111111111111',
        isEmailVerified: true,
        language: 'vi',
    };

    let currentUser = userA;

    const mockUsersService = {
        findByFirebaseUid: jest.fn().mockImplementation((uid: string) => {
            if (uid === userB.firebaseUid || uid === userB.id) return Promise.resolve(userB);
            return Promise.resolve(userA);
        }),
    };

    const mockDispatcher = {
        dispatchToPartner: jest.fn().mockResolvedValue(true),
        sendPush: jest.fn().mockResolvedValue(true),
    };

    beforeAll(async () => {
        const moduleFixture: TestingModule = await Test.createTestingModule({
            imports: [AppModule],
        })
            .overrideGuard(JwtAuthGuard)
            .useValue({
                canActivate: (context: ExecutionContext) => {
                    const req = context.switchToHttp().getRequest();
                    req.user = { uid: currentUser.firebaseUid };
                    return true;
                },
            })
            .overrideProvider(UsersService)
            .useValue(mockUsersService)
            .overrideProvider(CoupleNotificationDispatcher)
            .useValue(mockDispatcher)
            .compile();

        app = moduleFixture.createNestApplication();
        await app.init();

        alarmsService = moduleFixture.get<AlarmsService>(AlarmsService);
        alarmsGateway = moduleFixture.get<AlarmsGateway>(AlarmsGateway);
        usersRepository = moduleFixture.get<Repository<User>>(getRepositoryToken(User));
        alarmsRepository = moduleFixture.get<Repository<Alarm>>(getRepositoryToken(Alarm));
        dispatcher = moduleFixture.get<CoupleNotificationDispatcher>(CoupleNotificationDispatcher);

        // Seed users into database
        await usersRepository.save(usersRepository.create(userA));
        await usersRepository.save(usersRepository.create(userB));
    });

    afterAll(async () => {
        if (usersRepository && alarmsRepository) {
            await alarmsRepository.delete({ requesterId: userA.id });
            await alarmsRepository.delete({ requesterId: userB.id });
            await usersRepository.delete([userA.id, userB.id]);
        }
        if (app) {
            await app.close();
        }
    });

    beforeEach(() => {
        jest.clearAllMocks();
        currentUser = userA;
    });

    describe('1. Create Synced Alarm Proposal (User A -> User B)', () => {
        it('should propose a new alarm with status pending_confirmation and dispatch realtime event to partner', async () => {
            const targetTime = new Date(Date.now() + 3600000).toISOString();

            const res = await request(app.getHttpServer())
                .post('/alarms')
                .send({
                    time: targetTime,
                    description: 'Dậy đi ăn sáng nè',
                    weekdays: ['1', '2', '3', '4', '5'],
                    isActive: true,
                })
                .expect(201);

            expect(res.body).toBeDefined();
            expect(res.body.id).toBeDefined();
            expect(res.body.description).toBe('Dậy đi ăn sáng nè');
            expect(res.body.status).toBe('pending_confirmation');
            expect(res.body.requesterId).toBe(userA.id);
            expect(res.body.partnerId).toBe(userB.id);

            // Verification of partner notification
            expect(mockDispatcher.dispatchToPartner).toHaveBeenCalledWith(
                expect.objectContaining({
                    senderId: userA.id,
                    partnerId: userB.id,
                    eventName: 'alarm:newAlarmRequest',
                    eventId: res.body.id,
                }),
            );
        });
    });

    describe('2. Confirm Alarm Proposal (User B confirms -> Scheduled)', () => {
        it('should transition alarm to scheduled when partner confirms', async () => {
            // User A creates alarm
            currentUser = userA;
            const created = await alarmsService.createAlarm(userA.id, {
                time: new Date(Date.now() + 60000).toISOString(),
                description: 'Báo thức chung',
                weekdays: [],
                isActive: true,
            });

            expect(created.status).toBe('pending_confirmation');

            // User B confirms
            currentUser = userB;
            const res = await request(app.getHttpServer())
                .patch(`/alarms/${created.id}/confirm`)
                .expect(200);

            expect(res.body.id).toBe(created.id);
            expect(res.body.status).toBe('scheduled');
            expect(res.body.isActive).toBe(true);

            // Verify both notified that alarm is scheduled
            expect(mockDispatcher.dispatchToPartner).toHaveBeenCalledWith(
                expect.objectContaining({
                    eventName: 'alarm:alarmScheduled',
                    eventId: created.id,
                    emitToSenderToo: true,
                }),
            );
        });
    });

    describe('3. Scheduler Ringing & Dismissal Lifecycle', () => {
        it('should ring when due, require both to stop, and fully stop on 2nd dismissal', async () => {
            // Create a scheduled one-off alarm due now
            currentUser = userA;
            const alarm = await alarmsService.createAlarm(userA.id, {
                time: new Date(Date.now() - 5000).toISOString(), // 5 seconds ago
                description: 'Đến giờ hẹn hò',
                weekdays: [],
                isActive: true,
            });

            // Confirm it so it is scheduled
            await alarmsService.confirmAlarm(userB.id, alarm.id);

            // Spy on Gateway trigger
            const gatewayTriggerSpy = jest.spyOn(alarmsGateway, 'triggerAlarm').mockImplementation(() => {});

            // Trigger scheduler check
            await (alarmsService as any).checkAlarms();

            // Verify it transitioned to ringing
            const ringingAlarm = await alarmsService.getAlarmById(alarm.id);
            expect(ringingAlarm?.status).toBe('ringing');
            expect(gatewayTriggerSpy).toHaveBeenCalled();
            expect(mockDispatcher.dispatchToPartner).toHaveBeenCalledWith(
                expect.objectContaining({
                    eventName: 'alarm:triggerAlarm',
                    highPriority: true,
                    emitToSenderToo: true,
                }),
            );

            // User A stops first
            currentUser = userA;
            const stopRes1 = await request(app.getHttpServer())
                .patch(`/alarms/${alarm.id}/stop`)
                .expect(200);

            expect(stopRes1.body.status).toBe('ringing');
            expect(stopRes1.body.stopperIds).toContain(userA.id);

            // Verify partner notified that User A stopped
            expect(mockDispatcher.dispatchToPartner).toHaveBeenCalledWith(
                expect.objectContaining({
                    eventName: 'alarm:alarmStoppedByPartner',
                }),
            );

            // User B stops second -> Fully stopped
            currentUser = userB;
            const stopRes2 = await request(app.getHttpServer())
                .patch(`/alarms/${alarm.id}/stop`)
                .expect(200);

            expect(stopRes2.body.status).toBe('stopped');
            expect(stopRes2.body.stopperIds).toEqual(expect.arrayContaining([userA.id, userB.id]));

            // Verify fully stopped notification
            expect(mockDispatcher.dispatchToPartner).toHaveBeenCalledWith(
                expect.objectContaining({
                    eventName: 'alarm:alarmFullyStopped',
                    emitToSenderToo: true,
                }),
            );
        });

        it('recurring alarms return to scheduled state instead of stopped when both finish stopping', async () => {
            currentUser = userA;
            const recurringAlarm = await alarmsService.createAlarm(userA.id, {
                time: new Date().toISOString(),
                description: 'Tập thể dục mỗi ngày',
                weekdays: ['1', '2', '3', '4', '5', '6', '7'],
                isActive: true,
            });

            await alarmsService.confirmAlarm(userB.id, recurringAlarm.id);

            // Set to ringing
            recurringAlarm.status = 'ringing';
            await alarmsRepository.save(recurringAlarm);

            // User A stops
            await alarmsService.stopAlarm(userA.id, recurringAlarm.id);
            // User B stops
            const finalAlarm = await alarmsService.stopAlarm(userB.id, recurringAlarm.id);

            // Recurring alarm should reset to scheduled for next occurrence!
            expect(finalAlarm.status).toBe('scheduled');
            expect(finalAlarm.stopperIds).toEqual([]);
        });
    });

    describe('4. Mutual Toggle On/Off Flow', () => {
        it('should allow proposing a toggle and apply it only after partner confirmation', async () => {
            currentUser = userA;
            const alarm = await alarmsService.createAlarm(userA.id, {
                time: new Date(Date.now() + 3600000).toISOString(),
                description: 'Nhắc uống nước',
                isActive: true,
            });
            await alarmsService.confirmAlarm(userB.id, alarm.id);

            // User A requests toggle OFF
            currentUser = userA;
            const toggleReq = await request(app.getHttpServer())
                .patch(`/alarms/${alarm.id}/toggle`)
                .send({ isActive: false })
                .expect(200);

            expect(toggleReq.body.status).toBe('pending_toggle');
            expect(toggleReq.body.targetIsActive).toBe(false);

            // User B confirms toggle
            currentUser = userB;
            const confirmToggle = await request(app.getHttpServer())
                .patch(`/alarms/${alarm.id}/confirm`)
                .expect(200);

            expect(confirmToggle.body.status).toBe('scheduled');
            expect(confirmToggle.body.isActive).toBe(false);
        });
    });

    describe('5. Mutual Deletion & Rejection Flow', () => {
        it('should delete alarm when partner confirms deletion proposal', async () => {
            currentUser = userA;
            const alarm = await alarmsService.createAlarm(userA.id, {
                time: new Date(Date.now() + 3600000).toISOString(),
                description: 'Báo thức tạm thời',
                isActive: true,
            });
            await alarmsService.confirmAlarm(userB.id, alarm.id);

            // User A requests delete
            currentUser = userA;
            const delReq = await request(app.getHttpServer())
                .delete(`/alarms/${alarm.id}`)
                .expect(200);

            expect(delReq.body.status).toBe('pending_deletion');

            // User B confirms delete
            currentUser = userB;
            const confirmDel = await request(app.getHttpServer())
                .patch(`/alarms/${alarm.id}/confirm`)
                .expect(200);

            expect(confirmDel.body.deleted).toBe(true);

            // Verify alarm no longer exists in DB
            const check = await alarmsService.getAlarmById(alarm.id);
            expect(check).toBeNull();
        });

        it('should cancel new alarm if partner rejects proposal', async () => {
            currentUser = userA;
            const alarm = await alarmsService.createAlarm(userA.id, {
                time: new Date(Date.now() + 3600000).toISOString(),
                description: 'Đề xuất bị từ chối',
                isActive: true,
            });

            expect(alarm.status).toBe('pending_confirmation');

            // User B rejects
            currentUser = userB;
            const rejectRes = await request(app.getHttpServer())
                .patch(`/alarms/${alarm.id}/reject`)
                .expect(200);

            expect(rejectRes.body.deleted).toBe(true);

            const check = await alarmsService.getAlarmById(alarm.id);
            expect(check).toBeNull();
        });
    });
});
