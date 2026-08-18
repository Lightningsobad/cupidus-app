import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class UsersService {
    constructor(
        @InjectRepository(User)
        private userRepository: Repository<User>,
    ) { }

    async findOne(id: string): Promise<User> {
        const user = await this.userRepository.findOne({ where: { id } });
        if (!user) {
            throw new NotFoundException(`User with ID ${id} not found`);
        }
        return user;
    }

    async findByFirebaseUid(firebaseUid: string): Promise<User> {
        const user = await this.userRepository.findOne({ where: { firebaseUid } });
        if (!user) {
            throw new NotFoundException(`User with Firebase UID ${firebaseUid} not found`);
        }
        return user;
    }

    async getProfileWithPartner(firebaseUid: string): Promise<User & { partnerDisplayName: string | null }> {
        const user = await this.findByFirebaseUid(firebaseUid);

        let partnerDisplayName: string | null = null;
        if (user.partnerId) {
            const partner = await this.userRepository.findOne({ where: { id: user.partnerId } });
            partnerDisplayName = partner?.displayName ?? null;
        }

        return { ...user, partnerDisplayName };
    }

    async updateProfile(id: string, updateProfileDto: UpdateProfileDto): Promise<User> {
        const user = await this.findOne(id);

        // Map DTO to entity (simple merge)
        Object.assign(user, updateProfileDto);

        return this.userRepository.save(user);
    }

    async updateAvatar(id: string, avatarUrl: string): Promise<User> {
        const user = await this.findOne(id);
        user.photoUrl = avatarUrl;
        return this.userRepository.save(user);
    }

    async setPartner(userId: string, partnerId: string): Promise<User> {
        const user = await this.findOne(userId);
        user.partnerId = partnerId;
        return this.userRepository.save(user);
    }

    async markVowTaken(userId: string): Promise<User> {
        const user = await this.findOne(userId);
        user.vowTaken = true;
        return this.userRepository.save(user);
    }
}
