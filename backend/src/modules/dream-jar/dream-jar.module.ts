import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DreamJarService } from './dream-jar.service';
import { DreamJarController } from './dream-jar.controller';
import { DreamJar } from './entities/dream-jar.entity';
import { Contribution } from './entities/contribution.entity';
import { User } from '../users/entities/user.entity';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([DreamJar, Contribution, User]),
        UsersModule,
    ],
    controllers: [DreamJarController],
    providers: [DreamJarService],
    exports: [DreamJarService],
})
export class DreamJarModule { }
