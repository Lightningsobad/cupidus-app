import { Injectable, NotFoundException, Inject, forwardRef, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Alarm } from './entities/alarm.entity';
import { User } from '../users/entities/user.entity';
import { AlarmsGateway } from './alarms.gateway';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';
import { CreateAlarmDto } from './dto/create-alarm.dto';
import { UpdateAlarmDto } from './dto/update-alarm.dto';

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
            const currentHour = now.getHours();
            const currentMinute = now.getMinutes();
            // JS getDay(): 0=Sun, 1=Mon..6=Sat. Convert to 1=Mon..7=Sun
            const currentWeekday = now.getDay() === 0 ? 7 : now.getDay();

            const scheduledAlarms = await this.alarmsRepository.find({
                where: {
                    status: 'scheduled',
                    isActive: true,
                },
            });

            for (const alarm of scheduledAlarms) {
                const alarmTime = new Date(alarm.time);
                const alarmHour = alarmTime.getHours();
                const alarmMinute = alarmTime.getMinutes();

                let shouldRing = false;
                const weekdays = (alarm.weekdays || []).map(w => parseInt(w, 10)).filter(w => !isNaN(w));

                if (weekdays.length > 0) {
                    // Recurring on specific weekdays: check matching hour, minute, and weekday
                    if (weekdays.includes(currentWeekday) && alarmHour === currentHour && alarmMinute === currentMinute) {
                        shouldRing = true;
                    }
                } else {
                    // One-off alarm: check if alarm time is <= now and within the last 60 seconds
                    if (alarmTime <= now && (now.getTime() - alarmTime.getTime()) < 60000) {
                        shouldRing = true;
                    }
                }

                if (shouldRing) {
                    this.logger.log(`Triggering alarm ${alarm.id} (${alarm.description}) due at ${alarm.time}`);

                    alarm.status = 'ringing';
                    alarm.stopperIds = [];
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
                        body: `${alarm.description || 'Báo thức đồng bộ'}: Đến giờ rồi Bae ơi! ❤️`,
                        payload: alarm,
                        highPriority: true,
                        emitToSenderToo: true,
                    });
                }
            }

            // Clean up stale ringing alarms after 5 minutes (timeout)
            const ringingAlarms = await this.alarmsRepository.find({
                where: {
                    status: 'ringing',
                },
            });
            for (const alarm of ringingAlarms) {
                const alarmTime = new Date(alarm.time).getTime();
                if (now.getTime() - alarmTime > 300000) {
                    const hasRecurring = (alarm.weekdays || []).length > 0;
                    alarm.status = hasRecurring ? 'scheduled' : 'stopped';
                    alarm.stopperIds = [];
                    await this.alarmsRepository.save(alarm);
                    this.logger.log(`Alarm ${alarm.id} timed out after 5 minutes and was reset to ${alarm.status}`);
                }
            }
        } catch (error) {
            this.logger.error('Error in alarm scheduler', error);
        } finally {
            this.isChecking = false;
        }
    }

    async getAlarmsForUser(userId: string): Promise<Alarm[]> {
        return this.alarmsRepository.find({
            where: [
                { requesterId: userId },
                { partnerId: userId },
            ],
            order: { time: 'ASC', createdAt: 'DESC' },
        });
    }

    async getAlarmById(alarmId: string): Promise<Alarm | null> {
        return this.alarmsRepository.findOne({ where: { id: alarmId } });
    }

    async createAlarm(requesterId: string, dto: CreateAlarmDto): Promise<Alarm> {
        const requester = await this.usersRepository.findOne({ where: { id: requesterId } });
        if (!requester || !requester.partnerId) {
            throw new NotFoundException('User or partner not found');
        }

        const alarm = this.alarmsRepository.create({
            requesterId,
            partnerId: requester.partnerId,
            time: new Date(dto.time),
            description: dto.description || 'Nhắc nhở đồng bộ',
            weekdays: dto.weekdays || [],
            isActive: dto.isActive ?? true,
            status: 'pending_confirmation',
            stopperIds: [],
        });

        const saved = await this.alarmsRepository.save(alarm);
        const timeFormatted = new Date(dto.time).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });

        await this.dispatcher.dispatchToPartner({
            senderId: requesterId,
            partnerId: requester.partnerId,
            eventName: 'alarm:newAlarmRequest',
            eventId: saved.id,
            title: 'Đề xuất hẹn giờ mới ⏰',
            body: `${requester.displayName || 'Bae'} đề xuất hẹn giờ "${saved.description}" lúc ${timeFormatted}. Hãy vào xem và xác nhận nhé!`,
            payload: saved,
        });

        return saved;
    }

    async updateAlarm(userId: string, alarmId: string, dto: UpdateAlarmDto): Promise<Alarm> {
        const alarm = await this.getAlarmById(alarmId);
        if (!alarm) throw new NotFoundException('Alarm not found');

        const requester = await this.usersRepository.findOne({ where: { id: userId } });
        const partnerId = alarm.requesterId === userId ? alarm.partnerId : alarm.requesterId;

        if (dto.time) alarm.time = new Date(dto.time);
        if (dto.description !== undefined) alarm.description = dto.description;
        if (dto.weekdays !== undefined) alarm.weekdays = dto.weekdays;
        if (dto.isActive !== undefined) alarm.isActive = dto.isActive;

        alarm.status = 'pending_confirmation';
        alarm.requesterId = userId;
        alarm.partnerId = partnerId;
        alarm.stopperIds = [];

        const saved = await this.alarmsRepository.save(alarm);
        const timeFormatted = new Date(saved.time).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId,
            eventName: 'alarm:newAlarmRequest',
            eventId: saved.id,
            title: 'Thay đổi hẹn giờ ⏰',
            body: `${requester?.displayName || 'Bae'} đã sửa hẹn giờ "${saved.description}" thành ${timeFormatted}. Xác nhận nhé!`,
            payload: saved,
        });

        return saved;
    }

    async requestToggle(userId: string, alarmId: string, targetIsActive: boolean): Promise<Alarm> {
        const alarm = await this.getAlarmById(alarmId);
        if (!alarm) throw new NotFoundException('Alarm not found');

        const requester = await this.usersRepository.findOne({ where: { id: userId } });
        const partnerId = alarm.requesterId === userId ? alarm.partnerId : alarm.requesterId;

        alarm.status = 'pending_toggle';
        alarm.targetIsActive = targetIsActive;
        alarm.requesterId = userId;
        alarm.partnerId = partnerId;

        const saved = await this.alarmsRepository.save(alarm);
        const actionText = targetIsActive ? 'BẬT' : 'TẮT';

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId,
            eventName: 'alarm:newAlarmRequest',
            eventId: saved.id,
            title: `Yêu cầu ${actionText} hẹn giờ ⏰`,
            body: `${requester?.displayName || 'Bae'} muốn ${actionText.toLowerCase()} hẹn giờ "${saved.description}". Xác nhận nhé!`,
            payload: saved,
        });

        return saved;
    }

    async requestDelete(userId: string, alarmId: string): Promise<Alarm> {
        const alarm = await this.getAlarmById(alarmId);
        if (!alarm) throw new NotFoundException('Alarm not found');

        const requester = await this.usersRepository.findOne({ where: { id: userId } });
        const partnerId = alarm.requesterId === userId ? alarm.partnerId : alarm.requesterId;

        alarm.status = 'pending_deletion';
        alarm.requesterId = userId;
        alarm.partnerId = partnerId;

        const saved = await this.alarmsRepository.save(alarm);

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId,
            eventName: 'alarm:newAlarmRequest',
            eventId: saved.id,
            title: 'Yêu cầu XOÁ hẹn giờ 🗑️',
            body: `${requester?.displayName || 'Bae'} muốn xoá hẹn giờ "${saved.description}". Xác nhận nhé!`,
            payload: saved,
        });

        return saved;
    }

    async confirmAlarm(userId: string, alarmId: string): Promise<any> {
        const alarm = await this.getAlarmById(alarmId);
        if (!alarm) throw new NotFoundException('Alarm not found');

        const targetPartnerId = alarm.requesterId === userId ? alarm.partnerId : alarm.requesterId;

        if (alarm.status === 'pending_deletion') {
            await this.alarmsRepository.remove(alarm);

            await this.dispatcher.dispatchToPartner({
                senderId: userId,
                partnerId: targetPartnerId,
                eventName: 'alarm:alarmDeleted',
                eventId: alarmId,
                title: 'Hẹn giờ đã xoá 🗑️',
                body: 'Hẹn giờ đã được xoá thành công sau khi cả hai đồng ý.',
                payload: { id: alarmId, deleted: true },
                emitToSenderToo: true,
            });

            return { id: alarmId, deleted: true };
        }

        if (alarm.status === 'pending_toggle') {
            alarm.isActive = alarm.targetIsActive ?? !alarm.isActive;
            alarm.targetIsActive = null;
            alarm.status = 'scheduled';
        } else {
            // pending_confirmation
            alarm.status = 'scheduled';
            alarm.isActive = true;
        }

        const saved = await this.alarmsRepository.save(alarm);

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: targetPartnerId,
            eventName: 'alarm:alarmScheduled',
            eventId: saved.id,
            title: 'Hẹn giờ đã xác nhận! ⏰',
            body: `Hẹn giờ "${saved.description}" đã được cả hai cùng kích hoạt.`,
            payload: saved,
            emitToSenderToo: true,
        });

        return saved;
    }

    async rejectAlarm(userId: string, alarmId: string): Promise<any> {
        const alarm = await this.getAlarmById(alarmId);
        if (!alarm) throw new NotFoundException('Alarm not found');

        const targetPartnerId = alarm.requesterId === userId ? alarm.partnerId : alarm.requesterId;

        if (alarm.status === 'pending_deletion' || alarm.status === 'pending_toggle') {
            // Revert back to scheduled without the requested change
            alarm.status = 'scheduled';
            alarm.targetIsActive = null;
            const saved = await this.alarmsRepository.save(alarm);

            await this.dispatcher.dispatchToPartner({
                senderId: userId,
                partnerId: targetPartnerId,
                eventName: 'alarm:alarmScheduled',
                eventId: saved.id,
                title: 'Yêu cầu bị từ chối ✋',
                body: `Yêu cầu thay đổi hẹn giờ "${saved.description}" đã không được chấp thuận.`,
                payload: saved,
                emitToSenderToo: true,
            });

            return saved;
        }

        // If it was a new unconfirmed alarm, remove it
        await this.alarmsRepository.remove(alarm);

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: targetPartnerId,
            eventName: 'alarm:alarmDeleted',
            eventId: alarmId,
            title: 'Hẹn giờ đã huỷ ✋',
            body: 'Đề xuất hẹn giờ mới đã bị từ chối.',
            payload: { id: alarmId, deleted: true },
            emitToSenderToo: true,
        });

        return { id: alarmId, deleted: true };
    }

    async stopAlarm(userId: string, alarmId: string): Promise<Alarm> {
        const alarm = await this.getAlarmById(alarmId);
        if (!alarm) throw new NotFoundException('Alarm not found');

        const user = await this.usersRepository.findOne({ where: { id: userId } });

        if (!alarm.stopperIds.includes(userId)) {
            alarm.stopperIds.push(userId);
        }

        const isFullyStopped = alarm.stopperIds.length >= 2;
        if (isFullyStopped) {
            const hasRecurring = (alarm.weekdays || []).length > 0;
            alarm.status = hasRecurring ? 'scheduled' : 'stopped';
            if (hasRecurring) {
                alarm.stopperIds = [];
            }
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
                body: 'Cả hai đã cùng tắt chuông thành công!',
                payload: saved,
                emitToSenderToo: true,
            });
        } else {
            await this.dispatcher.dispatchToPartner({
                senderId: userId,
                partnerId: targetPartnerId,
                eventName: 'alarm:alarmStoppedByPartner',
                eventId: saved.id,
                title: 'Bae đã tắt chuông! ☀️',
                body: `${user?.displayName || 'Bae'} đã tắt chuông rồi kìa!`,
                payload: { stopperId: userId, alarmId: saved.id },
            });
        }

        return saved;
    }
}


