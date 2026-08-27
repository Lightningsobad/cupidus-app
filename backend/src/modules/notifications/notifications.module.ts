import { Module, Global, forwardRef } from '@nestjs/common';
import { FcmService } from './fcm.service';
import { CoupleNotificationDispatcher } from './couple-notification-dispatcher.service';
import { UsersModule } from '../users/users.module';
import { MessagesModule } from '../messages/messages.module';

@Global()
@Module({
    imports: [
        forwardRef(() => UsersModule),
        forwardRef(() => MessagesModule),
    ],
    providers: [FcmService, CoupleNotificationDispatcher],
    exports: [FcmService, CoupleNotificationDispatcher],
})
export class NotificationsModule { }

