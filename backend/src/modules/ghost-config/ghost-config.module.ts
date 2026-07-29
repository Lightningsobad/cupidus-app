import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GhostConfigService } from './ghost-config.service';
import { GhostConfigController } from './ghost-config.controller';
import { GhostConfig } from './entities/ghost-config.entity';
import { User } from '../users/entities/user.entity';
import { Message } from '../messages/entities/message.entity';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([GhostConfig, User, Message]),
        UsersModule,
    ],
    controllers: [GhostConfigController],
    providers: [GhostConfigService],
    exports: [GhostConfigService],
})
export class GhostConfigModule { }
