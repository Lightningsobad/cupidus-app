import { Injectable, Logger, Inject, forwardRef } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { UsersService } from '../users/users.service';

export interface SendPushOptions {
    title?: string;
    body?: string;
    eventName: string;
    eventId?: string;
    payload?: any;
    highPriority?: boolean;
    channelId?: string;
}

@Injectable()
export class FcmService {
    private readonly logger = new Logger(FcmService.name);

    constructor(
        @Inject(forwardRef(() => UsersService))
        private readonly usersService: UsersService,
    ) { }


    private isFirebaseReady(): boolean {
        return admin.apps.length > 0;
    }

    async sendToTokens(tokens: string[], options: SendPushOptions): Promise<{ successCount: number; failureCount: number }> {
        if (!tokens || tokens.length === 0) {
            return { successCount: 0, failureCount: 0 };
        }

        const dataPayload: Record<string, string> = {
            cupid_event: options.eventName,
            cupid_event_id: options.eventId || '',
            cupid_payload: JSON.stringify(options.payload || {}),
        };

        if (!this.isFirebaseReady()) {
            this.logger.log(
                `[FCM MOCK] (Firebase not initialized) Send to ${tokens.length} token(s): event=${options.eventName}, title="${options.title}", body="${options.body}"`,
            );
            return { successCount: tokens.length, failureCount: 0 };
        }

        const channelId = options.channelId || (options.highPriority ? 'cupid_critical_alerts' : 'cupid_general');

        const message: admin.messaging.MulticastMessage = {
            tokens,
            data: dataPayload,
            notification: options.title ? {
                title: options.title,
                body: options.body || '',
            } : undefined,
            android: {
                priority: options.highPriority ? 'high' : 'normal',
                notification: {
                    channelId,
                    sound: 'default',
                    priority: options.highPriority ? 'max' : 'default',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        contentAvailable: true,
                    },
                },
            },
        };

        try {
            const response = await admin.messaging().sendEachForMulticast(message);
            this.logger.log(
                `[FCM] Sent event "${options.eventName}": ${response.successCount} success, ${response.failureCount} failed`,
            );

            // Clean up invalid tokens
            if (response.failureCount > 0) {
                const invalidTokens: string[] = [];
                response.responses.forEach((resp, idx) => {
                    if (!resp.success && resp.error) {
                        const errorCode = resp.error.code;
                        if (
                            errorCode === 'messaging/invalid-registration-token' ||
                            errorCode === 'messaging/registration-token-not-registered'
                        ) {
                            invalidTokens.push(tokens[idx]);
                        }
                    }
                });

                if (invalidTokens.length > 0) {
                    await this.usersService.removeInvalidTokens(invalidTokens);
                }
            }

            return {
                successCount: response.successCount,
                failureCount: response.failureCount,
            };
        } catch (error) {
            this.logger.error(`[FCM] Error sending multicast: ${error.message}`, error.stack);
            return { successCount: 0, failureCount: tokens.length };
        }
    }
}
