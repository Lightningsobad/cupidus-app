import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ZodiacService, ZODIAC_CLOCK } from './zodiac.service';
import { ZodiacController } from './zodiac.controller';
import { User } from '../users/entities/user.entity';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([User]),
        UsersModule,
    ],
    controllers: [ZodiacController],
    providers: [
        ZodiacService,
        { provide: ZODIAC_CLOCK, useValue: () => new Date() },
    ],
    exports: [ZodiacService],
})
export class ZodiacModule { }
