import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VibesService } from './vibes.service';
import { VibesController } from './vibes.controller';
import { Vibe } from './entities/vibe.entity';
import { User } from '../users/entities/user.entity';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([Vibe, User]),
        UsersModule,
    ],
    controllers: [VibesController],
    providers: [VibesService],
    exports: [VibesService],
})
export class VibesModule { }
