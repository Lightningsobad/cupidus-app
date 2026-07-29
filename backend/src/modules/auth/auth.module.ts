import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { FirebaseAuthStrategy } from './firebase-auth.strategy';
import { AuthController } from './auth.controller';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [
        PassportModule.register({ defaultStrategy: 'firebase-jwt' }),
        UsersModule,
    ],
    providers: [AuthService, FirebaseAuthStrategy],
    controllers: [AuthController],
    exports: [AuthService],
})
export class AuthModule { }
