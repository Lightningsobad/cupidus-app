import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TimelineService } from './timeline.service';
import { TimelineController } from './timeline.controller';
import { TimelineEvent } from './entities/timeline-event.entity';
import { User } from '../users/entities/user.entity';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([TimelineEvent, User]),
        UsersModule,
    ],
    controllers: [TimelineController],
    providers: [TimelineService],
    exports: [TimelineService],
})
export class TimelineModule { }
