import {
    Injectable,
    NotFoundException,
    BadRequestException,
    Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CoupleEmoji } from './entities/couple-emoji.entity';
import { User } from '../users/entities/user.entity';
import { getCoupleId } from '../../common/utils/couple.util';
import { EMOJI_CATALOG, EmojiPackDefinition } from './emojis.catalog';

@Injectable()
export class EmojisService {
    private readonly logger = new Logger(EmojisService.name);

    constructor(
        @InjectRepository(CoupleEmoji)
        private coupleEmojiRepository: Repository<CoupleEmoji>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
    ) { }

    private async getUserAndCoupleId(userId: string): Promise<{ user: User; coupleId: string }> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user) {
            throw new NotFoundException('User not found');
        }
        if (!user.partnerId) {
            // If unpaired, provide a single-user fallback coupleId
            return { user, coupleId: `single:${userId}` };
        }
        const coupleId = getCoupleId(userId, user.partnerId);
        return { user, coupleId };
    }

    getEmojiCatalog(): EmojiPackDefinition[] {
        return EMOJI_CATALOG;
    }

    async getCoupleEmojiState(userId: string): Promise<CoupleEmoji> {
        const { coupleId } = await this.getUserAndCoupleId(userId);
        let state = await this.coupleEmojiRepository.findOne({ where: { coupleId } });

        if (!state) {
            state = this.coupleEmojiRepository.create({
                coupleId,
                activePackId: 'mochi-cat',
                downloadedPackIds: ['mochi-cat', 'baby-dino'],
            });
            state = await this.coupleEmojiRepository.save(state);
        }

        return state;
    }

    async unlockOrDownloadPack(userId: string, packId: string): Promise<CoupleEmoji> {
        const { coupleId } = await this.getUserAndCoupleId(userId);
        const pack = EMOJI_CATALOG.find((p) => p.id === packId);
        if (!pack) {
            throw new NotFoundException(`Emoji pack "${packId}" not found in catalog`);
        }

        const state = await this.getCoupleEmojiState(userId);
        if (!state.downloadedPackIds.includes(packId)) {
            state.downloadedPackIds.push(packId);
            await this.coupleEmojiRepository.save(state);
            this.logger.log(`Couple ${coupleId} downloaded emoji pack ${packId}`);
        }

        return state;
    }

    async setActivePack(userId: string, packId: string): Promise<CoupleEmoji> {
        const pack = EMOJI_CATALOG.find((p) => p.id === packId);
        if (!pack) {
            throw new NotFoundException(`Emoji pack "${packId}" not found`);
        }

        const state = await this.getCoupleEmojiState(userId);
        state.activePackId = packId;
        return this.coupleEmojiRepository.save(state);
    }
}
