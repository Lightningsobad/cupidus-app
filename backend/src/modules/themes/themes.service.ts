import {
    Injectable,
    NotFoundException,
    ForbiddenException,
    BadRequestException,
    Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { CoupleTheme } from './entities/couple-theme.entity';
import { User } from '../users/entities/user.entity';
import { getCoupleId } from '../../common/utils/couple.util';
import { THEME_CATALOG, ThemeDefinition } from './themes.catalog';

@Injectable()
export class ThemesService {
    private readonly logger = new Logger(ThemesService.name);

    constructor(
        @InjectRepository(CoupleTheme)
        private coupleThemeRepository: Repository<CoupleTheme>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
        private dataSource: DataSource,
    ) { }

    private async getUserAndCoupleId(userId: string): Promise<{ user: User; coupleId: string }> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user) {
            throw new NotFoundException('User not found');
        }
        if (!user.partnerId) {
            throw new BadRequestException('You must be paired with a partner to use Theme Store');
        }
        const coupleId = getCoupleId(userId, user.partnerId);
        return { user, coupleId };
    }

    getThemeCatalog(): ThemeDefinition[] {
        return THEME_CATALOG;
    }

    async getCoupleThemeState(userId: string): Promise<CoupleTheme> {
        const { coupleId } = await this.getUserAndCoupleId(userId);
        let state = await this.coupleThemeRepository.findOne({ where: { coupleId } });

        if (!state) {
            state = this.coupleThemeRepository.create({
                coupleId,
                activeThemeId: 'nebula',
                ownedThemeIds: ['nebula'],
                heartsBalance: 1240,
                pendingThemeId: null,
                pendingRequestedBy: null,
                pendingRequestedAt: null,
                wishlistThemeId: null,
                wishlistSavedBy: null,
            });
            state = await this.coupleThemeRepository.save(state);
        }

        return state;
    }

    async requestTheme(userId: string, themeId: string): Promise<CoupleTheme> {
        const { user, coupleId } = await this.getUserAndCoupleId(userId);
        const theme = THEME_CATALOG.find((t) => t.id === themeId);
        if (!theme) {
            throw new NotFoundException(`Theme with id "${themeId}" not found in catalog`);
        }

        const state = await this.getCoupleThemeState(userId);

        if (state.activeThemeId === themeId) {
            throw new BadRequestException('This theme is already active');
        }

        const isOwned = state.ownedThemeIds.includes(themeId);
        if (!isOwned && state.heartsBalance < theme.price) {
            throw new BadRequestException(
                `Not enough hearts in shared wallet. Required: ${theme.price}, Available: ${state.heartsBalance}`,
            );
        }

        state.pendingThemeId = themeId;
        state.pendingRequestedBy = userId;
        state.pendingRequestedAt = new Date();

        const saved = await this.coupleThemeRepository.save(state);
        this.logger.log(`[THEME_REQUEST] User ${userId} requested theme ${themeId} for couple ${coupleId}`);
        return saved;
    }

    async approveTheme(userId: string): Promise<CoupleTheme> {
        const { coupleId } = await this.getUserAndCoupleId(userId);
        const state = await this.coupleThemeRepository.findOne({ where: { coupleId } });

        if (!state || !state.pendingThemeId) {
            throw new BadRequestException('No pending theme request to approve');
        }

        if (state.pendingRequestedBy === userId) {
            throw new ForbiddenException('Cannot approve your own theme request');
        }

        const theme = THEME_CATALOG.find((t) => t.id === state.pendingThemeId);
        if (!theme) {
            throw new NotFoundException(`Requested theme "${state.pendingThemeId}" not found`);
        }

        return this.dataSource.transaction(async (manager) => {
            const isOwned = state.ownedThemeIds.includes(theme.id);
            if (!isOwned) {
                if (state.heartsBalance < theme.price) {
                    throw new BadRequestException('Not enough hearts in shared wallet');
                }
                state.heartsBalance -= theme.price;
                state.ownedThemeIds = [...state.ownedThemeIds, theme.id];
            }

            state.activeThemeId = theme.id;
            state.pendingThemeId = null;
            state.pendingRequestedBy = null;
            state.pendingRequestedAt = null;

            const saved = await manager.save(CoupleTheme, state);
            this.logger.log(`[THEME_APPROVED] Couple ${coupleId} switched active theme to ${theme.id}`);
            return saved;
        });
    }

    async rejectTheme(userId: string): Promise<CoupleTheme> {
        const { coupleId } = await this.getUserAndCoupleId(userId);
        const state = await this.coupleThemeRepository.findOne({ where: { coupleId } });

        if (!state || !state.pendingThemeId) {
            throw new BadRequestException('No pending theme request to reject');
        }

        if (state.pendingRequestedBy === userId) {
            throw new ForbiddenException('Cannot reject your own theme request');
        }

        state.pendingThemeId = null;
        state.pendingRequestedBy = null;
        state.pendingRequestedAt = null;

        const saved = await this.coupleThemeRepository.save(state);
        this.logger.log(`[THEME_REJECTED] Partner rejected pending theme request for couple ${coupleId}`);
        return saved;
    }

    async toggleWishlist(userId: string, themeId: string): Promise<CoupleTheme> {
        const state = await this.getCoupleThemeState(userId);
        const theme = THEME_CATALOG.find((t) => t.id === themeId);
        if (!theme) {
            throw new NotFoundException(`Theme with id "${themeId}" not found in catalog`);
        }

        if (state.wishlistThemeId === themeId) {
            state.wishlistThemeId = null;
            state.wishlistSavedBy = null;
        } else {
            state.wishlistThemeId = themeId;
            state.wishlistSavedBy = userId;
        }

        return this.coupleThemeRepository.save(state);
    }
}
