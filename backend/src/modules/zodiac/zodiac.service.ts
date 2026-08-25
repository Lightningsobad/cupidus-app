import { Inject, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';
import { normalizeZodiacSign } from './content/zodiac-sign';
import { getConflictIndexEntry } from './content/conflict-index.content';
import { DAILY_TIPS } from './content/daily-tips.content';
import { selectDailyTips } from './content/daily-tip.selector';
import {
    ZodiacMissingReason,
    ZodiacRedFlagTodayResponse,
} from './dto/zodiac-red-flag-today.dto';

export const ZODIAC_CLOCK = 'ZODIAC_CLOCK';
export type ZodiacClock = () => Date;

function toContentDate(date: Date): string {
    const year = date.getFullYear();
    const month = `${date.getMonth() + 1}`.padStart(2, '0');
    const day = `${date.getDate()}`.padStart(2, '0');
    return `${year}-${month}-${day}`;
}

@Injectable()
export class ZodiacService {
    constructor(
        @InjectRepository(User)
        private readonly usersRepository: Repository<User>,
        @Inject(ZODIAC_CLOCK)
        private readonly clock: ZodiacClock,
    ) { }

    async getRedFlagToday(self: User): Promise<ZodiacRedFlagTodayResponse> {
        const contentDate = toContentDate(this.clock());

        const partner = self.partnerId
            ? await this.usersRepository.findOne({ where: { id: self.partnerId } })
            : null;

        const missing: ZodiacMissingReason[] = [];
        if (!partner) {
            missing.push('partner_link');
        }

        const selfSign = normalizeZodiacSign(self.zodiacSign);
        if (!selfSign) {
            missing.push('self_zodiac');
        }

        const partnerSign = partner ? normalizeZodiacSign(partner.zodiacSign) : null;
        if (partner && !partnerSign) {
            missing.push('partner_zodiac');
        }

        if (missing.length > 0) {
            return { status: 'incomplete_profile', contentDate, missing };
        }

        // Every normalized sign pair resolves — the table is exhaustive by construction.
        const conflictIndex = getConflictIndexEntry(selfSign!, partnerSign!)!;

        const coupleKey = [self.id, self.partnerId].sort().join('#');
        const dailyTips = selectDailyTips(coupleKey, contentDate, DAILY_TIPS).map((tip) => ({
            id: tip.id,
            icon: tip.icon,
            tint: tip.tint,
            title: tip.vi.title,
            body: tip.vi.body,
        }));

        return {
            status: 'ready',
            contentDate,
            conflictIndex: {
                score: conflictIndex.score,
                scoreMax: conflictIndex.scoreMax,
                headline: conflictIndex.vi.headline,
                body: conflictIndex.vi.body,
            },
            partners: [
                { role: 'self', displayName: self.displayName ?? null, zodiacSign: selfSign! },
                { role: 'partner', displayName: partner!.displayName ?? null, zodiacSign: partnerSign! },
            ],
            dailyTips,
        };
    }
}
