import { Injectable, NotFoundException, ForbiddenException, BadRequestException, Logger, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { GhostConfig, ConfigStatus } from './entities/ghost-config.entity';
import { User } from '../users/entities/user.entity';
import { Message } from '../messages/entities/message.entity';
import { CreateGhostConfigDto } from './dto/create-ghost-config.dto';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

@Injectable()
export class GhostConfigService {
    private readonly logger = new Logger(GhostConfigService.name);

    constructor(
        @InjectRepository(GhostConfig)
        private configRepository: Repository<GhostConfig>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
        @InjectRepository(Message)
        private messagesRepository: Repository<Message>,
        private dataSource: DataSource,
        @Inject(forwardRef(() => CoupleNotificationDispatcher))
        private readonly dispatcher: CoupleNotificationDispatcher,
    ) { }


    private getCoupleId(userId: string, partnerId: string): string {
        return [userId, partnerId].sort().join(':');
    }

    async create(userId: string, dto: CreateGhostConfigDto): Promise<GhostConfig> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user) {
            throw new NotFoundException('User not found');
        }
        if (!user.partnerId) {
            throw new BadRequestException('You must be paired with a partner to set anti-ghosting rules');
        }

        const coupleId = this.getCoupleId(userId, user.partnerId);

        const config = this.configRepository.create({
            coupleId,
            timeoutMinutes: dto.timeoutMinutes,
            penalty: dto.penalty,
            publicCountdown: dto.publicCountdown ?? true,
            proposedBy: userId,
            status: ConfigStatus.PENDING_APPROVAL,
        });

        const saved = await this.configRepository.save(config);

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: user.partnerId,
            eventName: 'ghost_config:requested',
            eventId: saved.id,
            title: 'Đề xuất đổi luật Anti-Ghosting 👻',
            body: `${user.displayName || 'Bae'} muốn đổi thời gian phản hồi thành ${dto.timeoutMinutes} phút. Bấm để xem và duyệt nhé!`,
            payload: saved,
        });

        return saved;
    }

    async approve(userId: string, configId: string): Promise<GhostConfig> {
        const config = await this.configRepository.findOne({ where: { id: configId } });
        if (!config) {
            throw new NotFoundException('Config not found');
        }

        if (config.status !== ConfigStatus.PENDING_APPROVAL) {
            throw new BadRequestException('Only pending configs can be approved');
        }

        if (config.proposedBy === userId) {
            throw new ForbiddenException('Cannot approve your own config change');
        }

        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            throw new ForbiddenException('Not authorized');
        }

        const coupleId = this.getCoupleId(userId, user.partnerId);
        if (config.coupleId !== coupleId) {
            throw new ForbiddenException('Not authorized for this config');
        }

        const approvedConfig = await this.dataSource.transaction(async (manager) => {
            await manager.update(GhostConfig,
                { coupleId, status: ConfigStatus.ACTIVE },
                { status: ConfigStatus.SUPERSEDED },
            );

            config.approvedBy = userId;
            config.status = ConfigStatus.ACTIVE;
            return manager.save(config);
        });

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: user.partnerId,
            eventName: 'ghost_config:updated',
            eventId: approvedConfig.id,
            title: 'Luật Anti-Ghosting đã được duyệt! 👻',
            body: `${user.displayName || 'Bae'} đã đồng ý áp dụng luật Anti-Ghosting mới.`,
            payload: approvedConfig,
            emitToSenderToo: true,
        });

        return approvedConfig;
    }

    async reject(userId: string, configId: string): Promise<GhostConfig> {
        const config = await this.configRepository.findOne({ where: { id: configId } });
        if (!config) {
            throw new NotFoundException('Config not found');
        }

        if (config.status !== ConfigStatus.PENDING_APPROVAL) {
            throw new BadRequestException('Only pending configs can be rejected');
        }

        if (config.proposedBy === userId) {
            throw new ForbiddenException('Cannot reject your own config change');
        }

        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            throw new ForbiddenException('Not authorized');
        }

        const coupleId = this.getCoupleId(userId, user.partnerId);
        if (config.coupleId !== coupleId) {
            throw new ForbiddenException('Not authorized for this config');
        }

        config.status = ConfigStatus.REJECTED;
        const saved = await this.configRepository.save(config);

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: user.partnerId,
            eventName: 'ghost_config:updated',
            eventId: saved.id,
            title: 'Luật Anti-Ghosting bị từ chối',
            body: `${user.displayName || 'Bae'} chưa đồng ý thay đổi luật Anti-Ghosting.`,
            payload: saved,
        });

        return saved;
    }

    async getActive(userId: string): Promise<GhostConfig | null> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            return null;
        }

        const coupleId = this.getCoupleId(userId, user.partnerId);
        return this.configRepository.findOne({
            where: { coupleId, status: ConfigStatus.ACTIVE },
            order: { updatedAt: 'DESC' },
        });
    }

    async getPending(userId: string): Promise<GhostConfig[]> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            return [];
        }

        const coupleId = this.getCoupleId(userId, user.partnerId);
        return this.configRepository.find({
            where: { coupleId, status: ConfigStatus.PENDING_APPROVAL },
            order: { createdAt: 'DESC' },
        });
    }

    async getStormStatus(userId: string, partnerId: string): Promise<{ eligible: boolean; penalty: string | null }> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || user.partnerId !== partnerId) {
            return { eligible: false, penalty: null };
        }

        const coupleId = this.getCoupleId(userId, partnerId);
        const config = await this.configRepository.findOne({
            where: { coupleId, status: ConfigStatus.ACTIVE },
        });

        if (!config) {
            return { eligible: false, penalty: null };
        }

        const lastSeenMessage = await this.messagesRepository.findOne({
            where: {
                senderId: userId,
                receiverId: partnerId,
                status: 'seen',
            },
            order: { readAt: 'DESC' },
        });

        if (!lastSeenMessage || !lastSeenMessage.readAt) {
            return { eligible: false, penalty: config.penalty };
        }

        const seenAt = new Date(lastSeenMessage.readAt).getTime();
        const now = Date.now();
        const timeoutMs = config.timeoutMinutes * 60 * 1000;

        const partnerReply = await this.messagesRepository.findOne({
            where: {
                senderId: partnerId,
                receiverId: userId,
            },
            order: { createdAt: 'DESC' },
        });

        if (partnerReply && new Date(partnerReply.createdAt).getTime() > seenAt) {
            return { eligible: false, penalty: config.penalty };
        }

        const eligible = (now - seenAt) > timeoutMs;
        return { eligible, penalty: config.penalty };
    }
}

