import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MessagesService } from './messages.service';
import { MessagesController } from './messages.controller';
import { Message } from './entities/message.entity';
import { ChatGateway } from './chat.gateway';
import { UsersModule } from '../users/users.module';
import { GhostConfigModule } from '../ghost-config/ghost-config.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([Message]),
        forwardRef(() => UsersModule),
        forwardRef(() => GhostConfigModule),
    ],
    controllers: [MessagesController],
    providers: [MessagesService, ChatGateway],
    exports: [MessagesService, ChatGateway],
})
export class MessagesModule { }


