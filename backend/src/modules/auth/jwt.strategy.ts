import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, ExtractJwt } from 'passport-jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';

export interface JwtPayload {
  sub: string;
  email: string;
  uid?: string;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'cupid_jwt_secret_dev_key_2026_snapsofts',
    });
  }

  async validate(payload: JwtPayload) {
    const userId = payload.sub || payload.uid;
    const user = await this.userRepository.findOne({
      where: [{ id: userId }, { email: payload.email }],
    });

    if (!user) {
      throw new UnauthorizedException('User not found or invalid token');
    }

    // Return user info in req.user, keeping compatibility with existing controllers
    return {
      id: user.id,
      uid: user.firebaseUid || user.id,
      email: user.email,
      displayName: user.displayName,
      role: user.role,
    };
  }
}

/**
 * Compatible strategy for controllers still referencing 'firebase-jwt'
 */
@Injectable()
export class FirebaseJwtCompatStrategy extends PassportStrategy(Strategy, 'firebase-jwt') {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'cupid_jwt_secret_dev_key_2026_snapsofts',
    });
  }

  async validate(payload: JwtPayload) {
    const userId = payload.sub || payload.uid;
    const user = await this.userRepository.findOne({
      where: [{ id: userId }, { email: payload.email }],
    });

    if (!user) {
      throw new UnauthorizedException('User not found or invalid token');
    }

    return {
      id: user.id,
      uid: user.firebaseUid || user.id,
      email: user.email,
      displayName: user.displayName,
      role: user.role,
    };
  }
}
