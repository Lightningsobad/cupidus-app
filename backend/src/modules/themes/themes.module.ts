import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThemesService } from './themes.service';
import { ThemesController } from './themes.controller';
import { CoupleTheme } from './entities/couple-theme.entity';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([CoupleTheme]),
        UsersModule,
    ],
    controllers: [ThemesController],
    providers: [ThemesService],
    exports: [ThemesService],
})
export class ThemesModule { }
