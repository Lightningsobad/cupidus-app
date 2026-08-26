import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthService } from './auth.service';
import { JwtStrategy, FirebaseJwtCompatStrategy } from './jwt.strategy';
import { AuthController } from './auth.controller';
import { UsersModule } from '../users/users.module';
import { User } from '../users/entities/user.entity';
import { EmailVerification } from './entities/email-verification.entity';
import { MailModule } from '../mail/mail.module';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'cupid_jwt_secret_dev_key_2026_snapsofts',
      signOptions: { expiresIn: '30d' },
    }),
    TypeOrmModule.forFeature([User, EmailVerification]),
    UsersModule,
    MailModule,
  ],
  providers: [AuthService, JwtStrategy, FirebaseJwtCompatStrategy],
  controllers: [AuthController],
  exports: [AuthService, JwtModule],
})
export class AuthModule {}
