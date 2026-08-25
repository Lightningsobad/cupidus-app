import { ApiProperty } from '@nestjs/swagger';
import type { ZodiacSignKey } from '../content/zodiac-sign';
import type { DailyTipIcon, DailyTipTint } from '../content/daily-tips.content';

export type ZodiacMissingReason = 'partner_link' | 'self_zodiac' | 'partner_zodiac';
export type ZodiacPartnerRole = 'self' | 'partner';

export class ZodiacPartnerDto {
    @ApiProperty({ enum: ['self', 'partner'] })
    role: ZodiacPartnerRole;

    @ApiProperty({ nullable: true, example: 'Minh' })
    displayName: string | null;

    @ApiProperty({ example: 'cancer' })
    zodiacSign: ZodiacSignKey;
}

export class ZodiacConflictIndexDto {
    @ApiProperty({ example: 7 })
    score: number;

    @ApiProperty({ example: 10 })
    scoreMax: number;

    @ApiProperty({ example: 'Cự Giải và Song Ngư' })
    headline: string;

    @ApiProperty({ example: 'Cự Giải và Song Ngư dễ tìm được tiếng nói chung.' })
    body: string;
}

export class ZodiacDailyTipDto {
    @ApiProperty({ example: 'tip-04' })
    id: string;

    @ApiProperty({ example: 'videocam' })
    icon: DailyTipIcon;

    @ApiProperty({ example: 'mint' })
    tint: DailyTipTint;

    @ApiProperty()
    title: string;

    @ApiProperty()
    body: string;
}

export class ZodiacRedFlagReadyResponseDto {
    @ApiProperty({ enum: ['ready'] })
    status: 'ready';

    @ApiProperty({ example: '2026-08-25' })
    contentDate: string;

    @ApiProperty({ type: ZodiacConflictIndexDto })
    conflictIndex: ZodiacConflictIndexDto;

    @ApiProperty({ type: [ZodiacPartnerDto] })
    partners: [ZodiacPartnerDto, ZodiacPartnerDto];

    @ApiProperty({ type: [ZodiacDailyTipDto] })
    dailyTips: ZodiacDailyTipDto[];
}

export class ZodiacRedFlagIncompleteProfileResponseDto {
    @ApiProperty({ enum: ['incomplete_profile'] })
    status: 'incomplete_profile';

    @ApiProperty({ example: '2026-08-25' })
    contentDate: string;

    @ApiProperty({
        enum: ['partner_link', 'self_zodiac', 'partner_zodiac'],
        isArray: true,
        example: ['partner_zodiac'],
    })
    missing: ZodiacMissingReason[];
}

export type ZodiacRedFlagTodayResponse =
    | ZodiacRedFlagReadyResponseDto
    | ZodiacRedFlagIncompleteProfileResponseDto;
