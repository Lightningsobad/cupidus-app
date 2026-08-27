import { Injectable, NotFoundException, Logger, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { User } from './entities/user.entity';
import { UserDeviceToken } from './entities/user-device-token.entity';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

@Injectable()
export class UsersService {
    private readonly logger = new Logger(UsersService.name);

    constructor(
        @InjectRepository(User)
        private userRepository: Repository<User>,
        @InjectRepository(UserDeviceToken)
        private deviceTokenRepository: Repository<UserDeviceToken>,
        @Inject(forwardRef(() => CoupleNotificationDispatcher))
        private readonly dispatcher: CoupleNotificationDispatcher,
    ) { }


    async findOne(id: string): Promise<User> {
        const user = await this.userRepository.findOne({ where: { id } });
        if (!user) {
            throw new NotFoundException(`User with ID ${id} not found`);
        }
        return user;
    }

    async findByFirebaseUid(uidOrId: string): Promise<User> {
        let user = await this.userRepository.findOne({ where: { firebaseUid: uidOrId } });
        if (!user) {
            user = await this.userRepository.findOne({ where: { id: uidOrId } });
        }
        if (!user) {
            throw new NotFoundException(`User with identifier ${uidOrId} not found`);
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
        const saved = await this.userRepository.save(user);

        if (user.partnerId) {
            await this.dispatcher.dispatchToPartner({
                senderId: userId,
                partnerId: user.partnerId,
                eventName: 'vow:partner_ready',
                title: 'Lời thề tình yêu 🤝',
                body: `${user.displayName || 'Bae'} đang chờ bạn cùng chạm ngón tay để hoàn tất Lời thề!`,
                payload: { userId },
            });
        }

        return saved;
    }


    async saveDeviceToken(userId: string, fcmToken: string, platform = 'unknown'): Promise<UserDeviceToken> {
        let tokenRecord = await this.deviceTokenRepository.findOne({ where: { fcmToken } });
        if (tokenRecord) {
            tokenRecord.userId = userId;
            tokenRecord.platform = platform;
        } else {
            tokenRecord = this.deviceTokenRepository.create({
                userId,
                fcmToken,
                platform,
            });
        }
        const saved = await this.deviceTokenRepository.save(tokenRecord);
        this.logger.log(`[FCM] Saved device token for user ${userId} (${platform})`);
        return saved;
    }

    async removeDeviceToken(userId: string, fcmToken: string): Promise<void> {
        await this.deviceTokenRepository.delete({ userId, fcmToken });
        this.logger.log(`[FCM] Removed device token for user ${userId}`);
    }

    async getDeviceTokens(userId: string): Promise<string[]> {
        const records = await this.deviceTokenRepository.find({ where: { userId } });
        return records.map((r) => r.fcmToken);
    }

    async removeInvalidTokens(tokens: string[]): Promise<void> {
        if (!tokens.length) return;
        await this.deviceTokenRepository.delete({ fcmToken: In(tokens) });
        this.logger.log(`[FCM] Cleaned up ${tokens.length} invalid tokens`);
    }
}

