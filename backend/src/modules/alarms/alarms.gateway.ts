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
        @MessageBody() payload: { time: string; userId: string; description?: string; weekdays?: string[]; isActive?: boolean },
        @ConnectedSocket() client: Socket,
    ) {
        const userId = payload.userId;
        const alarm = await this.alarmsService.createAlarm(userId, {
            time: payload.time,
            description: payload.description,
            weekdays: payload.weekdays,
            isActive: payload.isActive,
        });

        // Notify partner
        this.server.to(alarm.partnerId).emit(ALARM_EVENTS.NEW_ALARM_REQUEST, alarm);
        // Inform sender
        client.emit(ALARM_EVENTS.NEW_ALARM_REQUEST, alarm);
    }

    @SubscribeMessage(ALARM_EVENTS.UPDATE_ALARM)
    async handleUpdateAlarm(
        @MessageBody() payload: { alarmId: string; userId: string; time?: string; description?: string; weekdays?: string[]; isActive?: boolean },
        @ConnectedSocket() client: Socket,
    ) {
        const alarm = await this.alarmsService.updateAlarm(payload.userId, payload.alarmId, {
            time: payload.time,
            description: payload.description,
            weekdays: payload.weekdays,
            isActive: payload.isActive,
        });

        this.server.to(alarm.partnerId).emit(ALARM_EVENTS.NEW_ALARM_REQUEST, alarm);
        client.emit(ALARM_EVENTS.NEW_ALARM_REQUEST, alarm);
    }

    @SubscribeMessage(ALARM_EVENTS.TOGGLE_ALARM)
    async handleToggleAlarm(
        @MessageBody() payload: { alarmId: string; userId: string; isActive: boolean },
        @ConnectedSocket() client: Socket,
    ) {
        const alarm = await this.alarmsService.requestToggle(payload.userId, payload.alarmId, payload.isActive);
        this.server.to(alarm.partnerId).emit(ALARM_EVENTS.NEW_ALARM_REQUEST, alarm);
        client.emit(ALARM_EVENTS.NEW_ALARM_REQUEST, alarm);
    }

    @SubscribeMessage(ALARM_EVENTS.DELETE_ALARM)
    async handleDeleteAlarm(
        @MessageBody() payload: { alarmId: string; userId: string },
        @ConnectedSocket() client: Socket,
    ) {
        const alarm = await this.alarmsService.requestDelete(payload.userId, payload.alarmId);
        this.server.to(alarm.partnerId).emit(ALARM_EVENTS.NEW_ALARM_REQUEST, alarm);
        client.emit(ALARM_EVENTS.NEW_ALARM_REQUEST, alarm);
    }

    @SubscribeMessage(ALARM_EVENTS.CONFIRM_ALARM)
    async handleConfirmAlarm(
        @MessageBody() payload: { alarmId: string; userId: string },
    ) {
        await this.alarmsService.confirmAlarm(payload.userId, payload.alarmId);
    }

    @SubscribeMessage(ALARM_EVENTS.REJECT_ALARM)
    async handleRejectAlarm(
        @MessageBody() payload: { alarmId: string; userId: string },
    ) {
        await this.alarmsService.rejectAlarm(payload.userId, payload.alarmId);
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
            this.server.to(partnerId).emit(ALARM_EVENTS.ALARM_STOPPED_BY_PARTNER, { stopperId: payload.userId, alarmId: alarm.id });
        }
    }

    triggerAlarm(alarm: Alarm) {
        this.server.to(alarm.requesterId).emit(ALARM_EVENTS.TRIGGER_ALARM, alarm);
        this.server.to(alarm.partnerId).emit(ALARM_EVENTS.TRIGGER_ALARM, alarm);
    }
}
