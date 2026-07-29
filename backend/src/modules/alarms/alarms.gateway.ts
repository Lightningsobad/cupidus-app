import {
    WebSocketGateway,
    SubscribeMessage,
    MessageBody,
    WebSocketServer,
    ConnectedSocket,
} from '@nestjs/websockets';
import { Inject, forwardRef } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { AlarmsService } from './alarms.service';
import { ALARM_EVENTS } from './alarm.constants';
import { Alarm } from './entities/alarm.entity';

@WebSocketGateway({
    cors: {
        origin: '*',
    },
})
export class AlarmsGateway {
    @WebSocketServer()
    server: Server;

    constructor(
        @Inject(forwardRef(() => AlarmsService))
        private readonly alarmsService: AlarmsService
    ) { }

    @SubscribeMessage(ALARM_EVENTS.SET_ALARM)
    async handleSetAlarm(
        @MessageBody() payload: { time: string; userId: string },
        @ConnectedSocket() client: Socket,
    ) {
        // SECURITY: In a real app, use client.data.userId from AuthGuard
        // const userId = client.data.userId; 
        const userId = payload.userId;

        // payload.time is ISO string
        const alarm = await this.alarmsService.createOrUpdateAlarm(userId, new Date(payload.time));

        // Notify partner
        this.server.to(alarm.partnerId).emit(ALARM_EVENTS.NEW_ALARM_REQUEST, alarm);
        // Confirm to sender
        client.emit(ALARM_EVENTS.ALARM_SCHEDULED, alarm);
    }

    @SubscribeMessage(ALARM_EVENTS.CONFIRM_ALARM)
    async handleConfirmAlarm(
        @MessageBody() payload: { alarmId: string; userId: string },
    ) {
        const alarm = await this.alarmsService.confirmAlarm(payload.userId, payload.alarmId);

        // Notify both
        this.server.to(alarm.requesterId).emit(ALARM_EVENTS.ALARM_SCHEDULED, alarm);
        this.server.to(alarm.partnerId).emit(ALARM_EVENTS.ALARM_SCHEDULED, alarm);
    }

    @SubscribeMessage(ALARM_EVENTS.STOP_ALARM)
    async handleStopAlarm(
        @MessageBody() payload: { alarmId: string; userId: string },
    ) {
        const alarm = await this.alarmsService.stopAlarm(payload.userId, payload.alarmId);

        const partnerId = alarm.requesterId === payload.userId ? alarm.partnerId : alarm.requesterId;

        if (alarm.status === 'stopped') {
            // Both stopped
            this.server.to(alarm.requesterId).emit(ALARM_EVENTS.ALARM_FULLY_STOPPED, alarm);
            this.server.to(alarm.partnerId).emit(ALARM_EVENTS.ALARM_FULLY_STOPPED, alarm);
        } else {
            // Just one stopped, tell partner
            this.server.to(partnerId).emit(ALARM_EVENTS.ALARM_STOPPED_BY_PARTNER, { stopperId: payload.userId });
        }
    }

    triggerAlarm(alarm: Alarm) {
        this.server.to(alarm.requesterId).emit(ALARM_EVENTS.TRIGGER_ALARM, alarm);
        this.server.to(alarm.partnerId).emit(ALARM_EVENTS.TRIGGER_ALARM, alarm);
    }
}
