import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EmojisController } from './emojis.controller';
import { EmojisService } from './emojis.service';
import { CoupleEmoji } from './entities/couple-emoji.entity';
import { User } from '../users/entities/user.entity';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([CoupleEmoji, User]),
        UsersModule,
    ],
    controllers: [EmojisController],
    providers: [EmojisService],
    exports: [EmojisService],
})
export class EmojisModule { }
