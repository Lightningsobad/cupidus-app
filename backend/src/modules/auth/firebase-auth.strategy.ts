import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, ExtractJwt } from 'passport-firebase-jwt';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseAuthStrategy extends PassportStrategy(Strategy, 'firebase-jwt') {
    constructor() {
        super({
            jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
        });
    }

    async validate(token: string) {
        try {
            const firebaseUser = await admin.auth().verifyIdToken(token, true);
            if (!firebaseUser) {
                throw new UnauthorizedException();
            }
            return firebaseUser;
        } catch (err) {
            console.log(err);
            throw new UnauthorizedException();
        }
    }
}
