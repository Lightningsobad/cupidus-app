import { Injectable, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';

@Injectable()
export class AuthService {
    constructor(
        @InjectRepository(User)
        private userRepository: Repository<User>,
    ) { }

    /**
     * Login: Find existing user by Firebase UID. Returns null if not found.
     */
    async loginUser(firebaseUser: any): Promise<User | null> {
        const { uid } = firebaseUser;
        return this.userRepository.findOne({ where: { firebaseUid: uid } });
    }

    /**
     * Register: Create a new user from Firebase profile. Throws if already exists.
     */
    async registerUser(firebaseUser: any): Promise<User> {
        const { uid, email, name, picture } = firebaseUser;

        const existing = await this.userRepository.findOne({ where: { firebaseUid: uid } });
        if (existing) {
            throw new ConflictException('User already registered');
        }

        const user = this.userRepository.create({
            firebaseUid: uid,
            email,
            displayName: name,
            photoUrl: picture,
        });
        return this.userRepository.save(user);
    }
}
