import { Injectable, Logger, Inject, forwardRef } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { FcmService } from './fcm.service';
import { ChatGateway } from '../messages/chat.gateway';

export interface DispatchEventOptions {
    senderId: string;
    partnerId?: string;
    eventName: string;
    eventId?: string;
    title?: string;
    body?: string;
    payload?: any;
    highPriority?: boolean;
    emitToSenderToo?: boolean;
}

@Injectable()
export class CoupleNotificationDispatcher {
    private readonly logger = new Logger(CoupleNotificationDispatcher.name);

    constructor(
        @Inject(forwardRef(() => UsersService))
        private readonly usersService: UsersService,
        private readonly fcmService: FcmService,
        @Inject(forwardRef(() => ChatGateway))
        private readonly chatGateway: ChatGateway,
    ) { }


    async dispatchToPartner(options: DispatchEventOptions): Promise<void> {
        let partnerId = options.partnerId;

        if (!partnerId) {
            try {
                const user = await this.usersService.findOne(options.senderId);
                partnerId = user?.partnerId || undefined;
            } catch (err) {
                this.logger.warn(`Failed to resolve partner for sender ${options.senderId}: ${err.message}`);
            }
        }

        if (!partnerId) {
            this.logger.debug(`User ${options.senderId} has no partner linked. Skipping dispatch for event "${options.eventName}".`);
            return;
        }

        // 1. Emit Realtime WebSocket Event
        try {
            if (this.chatGateway?.server) {
                this.chatGateway.server.to(partnerId).emit(options.eventName, options.payload ?? {});
                if (options.emitToSenderToo) {
                    this.chatGateway.server.to(options.senderId).emit(options.eventName, options.payload ?? {});
                }
                this.logger.log(`[SOCKET EMIT] To partner room "${partnerId}": event="${options.eventName}"`);
            } else {
                this.logger.warn(`ChatGateway server is not initialized yet. Socket emit skipped.`);
            }
        } catch (error) {
            this.logger.error(`[SOCKET ERROR] Failed to emit event "${options.eventName}": ${error.message}`);
        }

        // 2. Dispatch FCM Push Notification (if title is provided)
        if (options.title) {
            try {
                const tokens = await this.usersService.getDeviceTokens(partnerId);
                if (tokens && tokens.length > 0) {
                    await this.fcmService.sendToTokens(tokens, {
                        title: options.title,
                        body: options.body,
                        eventName: options.eventName,
                        eventId: options.eventId,
                        payload: options.payload,
                        highPriority: options.highPriority,
                    });
                } else {
                    this.logger.debug(`No FCM device tokens found for partner ${partnerId}`);
                }
            } catch (error) {
                this.logger.error(`[FCM ERROR] Failed to send push notification: ${error.message}`);
            }
        }
    }
}
