import { Injectable, NotFoundException, Inject, forwardRef, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual } from 'typeorm';
import { Alarm } from './entities/alarm.entity';
import { User } from '../users/entities/user.entity';
import { AlarmsGateway } from './alarms.gateway';

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
            // Find scheduled alarms that are due
            const dueAlarms = await this.alarmsRepository.find({
                where: {
                    status: 'scheduled',
                    time: LessThanOrEqual(now),
                    isActive: true
                }
            });

            for (const alarm of dueAlarms) {
                this.logger.log(`Triggering alarm ${alarm.id} due at ${alarm.time}`);

                // Update status to ringing
                alarm.status = 'ringing';
                await this.alarmsRepository.save(alarm);

                // Emitting event via Gateway
                this.alarmsGateway.triggerAlarm(alarm);

                // Also send Push Notification (Critical)
                await this.triggerPushNotification(
                    [alarm.requesterId, alarm.partnerId],
                    "WAKE UP!",
                    "It's time to wake up together! ❤️"
                );
            }
        } catch (error) {
            this.logger.error('Error in alarm scheduler', error);
        } finally {
            this.isChecking = false;
        }
    }

    async getAlarmForUser(userId: string): Promise<Alarm | null> {
        // Find alarm where user is requester or partner
        return this.alarmsRepository.findOne({
            where: [
                { requesterId: userId },
                { partnerId: userId }
            ],
            order: { createdAt: 'DESC' } // Get latest? Or should we only have one active alarm?
        });
    }

    async createOrUpdateAlarm(requesterId: string, time: Date): Promise<Alarm> {
        return this.alarmsRepository.manager.transaction(async transactionalEntityManager => {
            const requester = await this.usersRepository.findOne({ where: { id: requesterId } });
            if (!requester || !requester.partnerId) {
                throw new NotFoundException('User or partner not found');
            }

            // Check if existing alarm exists (LOCKing would be better, but simple find is ok for MVP)
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
                    stopperIds: []
                });
            }

            // Trigger fallback notification
            await this.triggerPushNotification([requesterId, requester.partnerId], "Wake Up!", "Synced Alarm is Set!");

            return transactionalEntityManager.save(Alarm, alarm);
        });
    }

    async confirmAlarm(userId: string, alarmId: string): Promise<Alarm> {
        const alarm = await this.alarmsRepository.findOne({ where: { id: alarmId } });
        if (!alarm) throw new NotFoundException('Alarm not found');

        alarm.status = 'scheduled';
        return this.alarmsRepository.save(alarm);
    }

    async stopAlarm(userId: string, alarmId: string): Promise<Alarm> {
        const alarm = await this.alarmsRepository.findOne({ where: { id: alarmId } });
        if (!alarm) throw new NotFoundException('Alarm not found');

        if (!alarm.stopperIds.includes(userId)) {
            alarm.stopperIds.push(userId);
        }

        if (alarm.stopperIds.length >= 2) {
            alarm.status = 'stopped';
        } else {
            alarm.status = 'ringing';
        }

        return this.alarmsRepository.save(alarm);
    }

    private async triggerPushNotification(userIds: string[], title: string, body: string) {
        // STUB: Real implementation would use Firebase Admin SDK or APNs
        console.log(`[PUSH NOTIFICATION] To: ${userIds.join(', ')} | Title: ${title} | Body: ${body}`);
        // In a real app:
        // const tokens = await this.getDeviceTokens(userIds);
        // await this.notificationService.sendMulticast(tokens, { title, body });
    }
}
