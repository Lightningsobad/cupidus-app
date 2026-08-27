import {
    WebSocketGateway,
    SubscribeMessage,
    MessageBody,
    WebSocketServer,
    ConnectedSocket,
} from '@nestjs/websockets';
import { Inject, forwardRef } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { MessagesService } from './messages.service';
import { UsersService } from '../users/users.service';
import { GhostConfigService } from '../ghost-config/ghost-config.service';
import { FcmService } from '../notifications/fcm.service';
import { CHAT_EVENTS } from './chat.constants';

@WebSocketGateway({
    cors: {
        origin: '*',
    },
})
export class ChatGateway {
    @WebSocketServer()
    server: Server;

    constructor(
        private readonly messagesService: MessagesService,
        @Inject(forwardRef(() => UsersService))
        private readonly usersService: UsersService,
        @Inject(forwardRef(() => GhostConfigService))
        private readonly ghostConfigService: GhostConfigService,
        private readonly fcmService: FcmService,
    ) { }


    @SubscribeMessage(CHAT_EVENTS.SEND_MESSAGE)
    async handleMessage(
        @MessageBody() createMessageDto: any,
        @ConnectedSocket() client: Socket,
    ) {
        const message = await this.messagesService.create(createMessageDto);
        this.server.to(message.receiverId).emit(CHAT_EVENTS.NEW_MESSAGE, message);

        // Send Push Notification if receiver is in background
        try {
            const sender = await this.usersService.findOne(message.senderId);
            const tokens = await this.usersService.getDeviceTokens(message.receiverId);
            if (tokens && tokens.length > 0) {
                const bodyText = message.type === 'image' ? '📷 [Đã gửi một hình ảnh]' : (message.content || 'Tin nhắn mới');
                await this.fcmService.sendToTokens(tokens, {
                    title: sender?.displayName || 'Bae',
                    body: bodyText,
                    eventName: CHAT_EVENTS.NEW_MESSAGE,
                    eventId: message.id,
                    payload: message,
                });
            }
        } catch (err) {
            console.error('Failed to send FCM push for chat message:', err);
        }

        return message;
    }


    async handleConnection(client: Socket) {
        // MOCK AUTH: In a real app, verify token from client.handshake.auth.token
        // For MVP, we'll try to get userId from query or handshake if possible
        // Let's assume the client sends userId in handshake for now, OR valid JWT
        // client.data.userId = validatedUserId;

        // Since we don't have full Auth guard here yet:
        // We'll trust the joinRoom for now but we should really be identifying here.
        // Let's rely on joinRoom to set client.data.userId
        console.log(`Client connected: ${client.id}`);
    }

    @SubscribeMessage(CHAT_EVENTS.JOIN_ROOM)
    handleJoinRoom(
        @MessageBody() userId: string,
        @ConnectedSocket() client: Socket,
    ) {
        console.log(`Socket client ${client.id} joined room for user: ${userId}`);
        client.join(userId);
        client.data.userId = userId; // Store for future secure checks
        return { event: CHAT_EVENTS.JOINED_ROOM, data: userId };
    }

    @SubscribeMessage(CHAT_EVENTS.TYPING)
    async handleTyping(
        @MessageBody() payload: { content: string; senderId: string; receiverId: string },
        @ConnectedSocket() client: Socket,
    ) {
        // Privacy Check: Verify sender has Ghost Mode enabled
        try {
            const sender = await this.usersService.findOne(payload.senderId);
            if (!sender.isGhostModeEnabled) {
                // User has disabled ghost mode, do not broadcast
                return;
            }
        } catch (error) {
            console.error(`Error checking ghost mode for user ${payload.senderId}:`, error);
            return;
        }

        this.server.to(payload.receiverId).emit(CHAT_EVENTS.GHOST_TYPING, {
            content: payload.content,
            senderId: payload.senderId,
        });
    }

    @SubscribeMessage(CHAT_EVENTS.STOP_TYPING)
    handleStopTyping(
        @MessageBody() payload: { senderId: string; receiverId: string },
        @ConnectedSocket() client: Socket,
    ) {
        this.server.to(payload.receiverId).emit(CHAT_EVENTS.GHOST_STOP_TYPING, {
            senderId: payload.senderId,
        });
    }

    @SubscribeMessage(CHAT_EVENTS.MARK_SEEN)
    async handleMarkSeen(
        @MessageBody() payload: { senderId: string; receiverId: string },
        @ConnectedSocket() client: Socket,
    ) {
        // SECURITY: Ensure the person marking as seen (receiverId) is the connected client
        const currentUserId = client.data.userId;
        if (!currentUserId || currentUserId !== payload.receiverId) {
            console.warn(`Unauthorized markSeen attempt. Socket User: ${currentUserId}, Claimed: ${payload.receiverId}`);
            return;
        }

        // 1. Update DB
        await this.messagesService.markAsSeen(payload.receiverId, payload.senderId);

        // 2. Notify original sender
        this.server.to(payload.senderId).emit(CHAT_EVENTS.MESSAGE_SEEN, {
            seenBy: payload.receiverId,
            readAt: new Date(),
        });
    }

    @SubscribeMessage(CHAT_EVENTS.MARK_DELIVERED)
    async handleMarkDelivered(
        @MessageBody() payload: { senderId: string; receiverId: string },
        @ConnectedSocket() client: Socket,
    ) {
        // SECURITY: Ensure the person marking as delivered (receiverId) is the connected client
        const currentUserId = client.data.userId;
        if (!currentUserId || currentUserId !== payload.receiverId) {
            return; // Silent fail
        }

        // 1. Update DB
        await this.messagesService.markAsDelivered(payload.receiverId, payload.senderId);

        // 2. Notify original sender
        this.server.to(payload.senderId).emit(CHAT_EVENTS.MESSAGE_DELIVERED, {
            deliveredTo: payload.receiverId,
            deliveredAt: new Date(),
        });
    }

    @SubscribeMessage(CHAT_EVENTS.EMOJI_STORM)
    async handleEmojiStorm(
        @MessageBody() payload: { senderId: string; receiverId: string },
        @ConnectedSocket() client: Socket,
    ) {
        const currentUserId = client.data.userId;
        if (!currentUserId || currentUserId !== payload.senderId) {
            return;
        }

        try {
            const config = await this.ghostConfigService.getActive(payload.senderId);
            const penalty = config?.penalty || 'emoji_storm';

            this.server.to(payload.receiverId).emit(CHAT_EVENTS.EMOJI_STORM_RECEIVED, {
                senderId: payload.senderId,
                penalty,
            });

            // Send High Priority FCM push notification
            const sender = await this.usersService.findOne(payload.senderId);
            const tokens = await this.usersService.getDeviceTokens(payload.receiverId);
            if (tokens && tokens.length > 0) {
                await this.fcmService.sendToTokens(tokens, {
                    title: 'BÃO EMOJI ĐANG DỘI XUỐNG! 💣🔥',
                    body: `${sender?.displayName || 'Bae'} vừa thả bão Emoji vì bạn dám ghost quá lâu!`,
                    eventName: CHAT_EVENTS.EMOJI_STORM_RECEIVED,
                    payload: { senderId: payload.senderId, penalty },
                    highPriority: true,
                });
            }
        } catch (error) {
            console.error('Emoji storm error:', error);
        }
    }

    @SubscribeMessage('in_app:action')
    handleInAppAction(
        @MessageBody() payload: { room?: string; partnerId?: string; actionType: string; title?: string; body?: string; data?: any },
        @ConnectedSocket() client: Socket,
    ) {
        const targetRoom = payload.room || payload.partnerId;
        if (targetRoom) {
            this.server.to(targetRoom).emit('in_app:action', payload);
            console.log(`Relayed in_app:action to room ${targetRoom}:`, payload.actionType);
        }
    }
}

