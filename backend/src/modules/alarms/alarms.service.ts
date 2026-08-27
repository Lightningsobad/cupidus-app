import { Injectable, NotFoundException, Inject, forwardRef, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual } from 'typeorm';
import { Alarm } from './entities/alarm.entity';
import { User } from '../users/entities/user.entity';
import { AlarmsGateway } from './alarms.gateway';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

@Injectable()
export class AlarmsService implements OnModuleInit, OnModuleDestroy {
    private readonly logger = new Logger(AlarmsService.name);
    private schedulerInterval: NodeJS.Timeout;
    private isChecking = false;

    constructor(
        @InjectRepository(Alarm)
        private alarmsRepository: Repository<Alarm>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
        @Inject(forwardRef(() => AlarmsGateway))
        private alarmsGateway: AlarmsGateway,
        private readonly dispatcher: CoupleNotificationDispatcher,
    ) { }

    onModuleInit() {
        this.startScheduler();
    }

    onModuleDestroy() {
        if (this.schedulerInterval) {
            clearInterval(this.schedulerInterval);
            this.logger.log('Alarm Scheduler stopped');
        }
    }

    private startScheduler() {
        this.logger.log('Starting Alarm Scheduler...');
        this.schedulerInterval = setInterval(() => {
            this.checkAlarms();
        }, 15000); // Check every 15 seconds
    }

    private async checkAlarms() {
        if (this.isChecking) {
            this.logger.warn('Previous alarm check still running, skipping this cycle');
            return;
        }

        this.isChecking = true;
        try {
            const now = new Date();
            const dueAlarms = await this.alarmsRepository.find({
                where: {
                    status: 'scheduled',
                    time: LessThanOrEqual(now),
                    isActive: true,
                },
            });

            for (const alarm of dueAlarms) {
                this.logger.log(`Triggering alarm ${alarm.id} due at ${alarm.time}`);

                alarm.status = 'ringing';
                await this.alarmsRepository.save(alarm);

                // Emitting event via Gateway
                this.alarmsGateway.triggerAlarm(alarm);

                // Critical Push Notification & Socket Event
                await this.dispatcher.dispatchToPartner({
                    senderId: alarm.requesterId,
                    partnerId: alarm.partnerId,
                    eventName: 'alarm:triggerAlarm',
                    eventId: alarm.id,
                    title: 'WAKE UP! ⏰',
                    body: "Đến giờ thức dậy cùng nhau rồi Bae ơi! ❤️",
                    payload: alarm,
                    highPriority: true,
                    emitToSenderToo: true,
                });
            }
        } catch (error) {
            this.logger.error('Error in alarm scheduler', error);
        } finally {
            this.isChecking = false;
        }
    }

    async getAlarmForUser(userId: string): Promise<Alarm | null> {
        return this.alarmsRepository.findOne({
            where: [
                { requesterId: userId },
                { partnerId: userId },
            ],
            order: { createdAt: 'DESC' },
        });
    }

    async createOrUpdateAlarm(requesterId: string, time: Date): Promise<Alarm> {
        const requester = await this.usersRepository.findOne({ where: { id: requesterId } });
        if (!requester || !requester.partnerId) {
            throw new NotFoundException('User or partner not found');
        }

        let alarm = await this.getAlarmForUser(requesterId);

        if (alarm) {
            alarm.time = time;
            alarm.status = 'pending_confirmation';
            alarm.requesterId = requesterId;
            alarm.stopperIds = [];
        } else {
            alarm = this.alarmsRepository.create({
                requesterId,
                partnerId: requester.partnerId,
                time,
                status: 'pending_confirmation',
                stopperIds: [],
            });
        }

        const saved = await this.alarmsRepository.save(alarm);
        const timeFormatted = new Date(time).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });

        await this.dispatcher.dispatchToPartner({
            senderId: requesterId,
            partnerId: requester.partnerId,
            eventName: 'alarm:newAlarmRequest',
            eventId: saved.id,
            title: 'Yêu cầu hẹn giờ báo thức ⏰',
            body: `${requester.displayName || 'Bae'} muốn đặt báo thức lúc ${timeFormatted}. Hãy vào xem và xác nhận nhé!`,
            payload: saved,
        });

        return saved;
    }

    async confirmAlarm(userId: string, alarmId: string): Promise<Alarm> {
        const alarm = await this.alarmsRepository.findOne({ where: { id: alarmId } });
        if (!alarm) throw new NotFoundException('Alarm not found');

        alarm.status = 'scheduled';
        const saved = await this.alarmsRepository.save(alarm);
        const targetPartnerId = alarm.requesterId === userId ? alarm.partnerId : alarm.requesterId;

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: targetPartnerId,
            eventName: 'alarm:alarmScheduled',
            eventId: saved.id,
            title: 'Báo thức đã lên lịch! ⏰',
            body: 'Giờ báo thức đôi đã được xác nhận thành công.',
            payload: saved,
            emitToSenderToo: true,
        });

        return saved;
    }

    async stopAlarm(userId: string, alarmId: string): Promise<Alarm> {
        const alarm = await this.alarmsRepository.findOne({ where: { id: alarmId } });
        if (!alarm) throw new NotFoundException('Alarm not found');

        const user = await this.usersRepository.findOne({ where: { id: userId } });

        if (!alarm.stopperIds.includes(userId)) {
            alarm.stopperIds.push(userId);
        }

        const isFullyStopped = alarm.stopperIds.length >= 2;
        if (isFullyStopped) {
            alarm.status = 'stopped';
        } else {
            alarm.status = 'ringing';
        }

        const saved = await this.alarmsRepository.save(alarm);
        const targetPartnerId = alarm.requesterId === userId ? alarm.partnerId : alarm.requesterId;

        if (isFullyStopped) {
            await this.dispatcher.dispatchToPartner({
                senderId: userId,
                partnerId: targetPartnerId,
                eventName: 'alarm:alarmFullyStopped',
                eventId: saved.id,
                title: 'Chào buổi sáng! ☀️',
                body: 'Cả hai đã cùng thức dậy thành công!',
                payload: saved,
                emitToSenderToo: true,
            });
        } else {
            await this.dispatcher.dispatchToPartner({
                senderId: userId,
                partnerId: targetPartnerId,
                eventName: 'alarm:alarmStoppedByPartner',
                eventId: saved.id,
                title: 'Bae đã dậy rồi! ☀️',
                body: `${user?.displayName || 'Bae'} đã tắt chuông báo thức rồi kìa!`,
                payload: { stopperId: userId, alarmId: saved.id },
            });
        }

        return saved;
    }
}

