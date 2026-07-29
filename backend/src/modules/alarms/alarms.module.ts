import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AlarmsService } from './alarms.service';
import { AlarmsGateway } from './alarms.gateway';
import { Alarm } from './entities/alarm.entity';
import { UsersModule } from '../users/users.module';
import { User } from '../users/entities/user.entity';

import { AlarmsController } from './alarms.controller';

@Module({
    imports: [
        TypeOrmModule.forFeature([Alarm, User]),
        UsersModule,
    ],
    controllers: [AlarmsController],
    providers: [AlarmsService, AlarmsGateway],
    exports: [AlarmsService],
})
export class AlarmsModule { }
