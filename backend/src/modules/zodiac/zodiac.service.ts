import { BadRequestException, Inject, Injectable, Optional } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';
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
        @Optional()
        private readonly dispatcher?: CoupleNotificationDispatcher,
    ) { }

    async remindPartner(self: User): Promise<{ success: boolean; message: string }> {
        if (!self.partnerId) {
            throw new BadRequestException('Bạn chưa kết nối với người ấy');
        }

        const senderName = self.displayName || 'Người ấy';
        const cuteMessage = `${senderName} đang chờ bạn điền ngày sinh để Cupid giải mã tương hợp tình yêu cho hai bạn nè! 💕✨`;

        if (this.dispatcher) {
            await this.dispatcher.dispatchToPartner({
                senderId: self.id,
                partnerId: self.partnerId,
                eventName: 'toast:show',
                title: '✨ Cung hoàng đạo',
                body: cuteMessage,
                payload: {
                    type: 'zodiac_reminder',
                    title: '✨ Cung hoàng đạo',
                    message: cuteMessage,
                },
            });
        }

        return {
            success: true,
            message: 'Đã gửi lời nhắc siêu dễ thương đến đối phương rồi nè! 💌✨',
        };
    }

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
