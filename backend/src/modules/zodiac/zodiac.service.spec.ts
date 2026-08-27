import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ZodiacService, ZODIAC_CLOCK } from './zodiac.service';
import { User } from '../users/entities/user.entity';

describe('ZodiacService', () => {
    let service: ZodiacService;
    let usersRepository: { findOne: jest.Mock };

    const pinnedDate = new Date('2026-08-25T10:00:00Z');

    function makeUser(overrides: Partial<User> = {}): User {
        return {
            id: 'self-id',
            email: 'self@example.com',
            firebaseUid: 'firebase-self',
            displayName: 'Minh',
            photoUrl: null,
            birthday: null,
            relationshipStartDate: null,
            zodiacSign: 'cancer',
            language: 'vi',
            partnerId: 'partner-id',
            coupleType: null,
            vowTaken: false,
            isGhostModeEnabled: true,
            role: 'user',
            createdAt: new Date(),
            updatedAt: new Date(),
            ...overrides,
        } as User;
    }

    beforeEach(async () => {
        usersRepository = { findOne: jest.fn() };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                ZodiacService,
                { provide: getRepositoryToken(User), useValue: usersRepository },
                { provide: ZODIAC_CLOCK, useValue: () => pinnedDate },
            ],
        }).compile();

        service = module.get(ZodiacService);
    });

    it('returns a ready payload with 2 partners and 3 distinct tips when both signs resolve', async () => {
        const self = makeUser({ zodiacSign: 'Cancer' });
        const partner = makeUser({ id: 'partner-id', displayName: 'Linh', zodiacSign: 'pisces' });
        usersRepository.findOne.mockResolvedValueOnce(partner);

        const result = await service.getRedFlagToday(self);

        expect(result.status).toBe('ready');
        if (result.status !== 'ready') throw new Error('expected ready status');
        expect(result.contentDate).toBe('2026-08-25');
        expect(result.partners).toHaveLength(2);
        expect(result.partners[0].role).toBe('self');
        expect(result.partners[1].role).toBe('partner');
        expect(result.dailyTips).toHaveLength(3);
        expect(new Set(result.dailyTips.map((tip) => tip.id)).size).toBe(3);
        expect(result).not.toHaveProperty('missing');
    });

    it('returns incomplete_profile with reason partner_link and no content keys when unpaired', async () => {
        const self = makeUser({ partnerId: null as unknown as string });

        const result = await service.getRedFlagToday(self);

        expect(result.status).toBe('incomplete_profile');
        if (result.status !== 'incomplete_profile') throw new Error('expected incomplete_profile status');
        expect(result.missing).toEqual(['partner_link']);
        expect(result).not.toHaveProperty('conflictIndex');
        expect(result).not.toHaveProperty('partners');
        expect(result).not.toHaveProperty('dailyTips');
    });

    it('returns incomplete_profile with reason self_zodiac when self sign is unset', async () => {
        const self = makeUser({ zodiacSign: null as unknown as string });
        const partner = makeUser({ id: 'partner-id', zodiacSign: 'pisces' });
        usersRepository.findOne.mockResolvedValueOnce(partner);

        const result = await service.getRedFlagToday(self);

        expect(result.status).toBe('incomplete_profile');
        if (result.status !== 'incomplete_profile') throw new Error('expected incomplete_profile status');
        expect(result.missing).toEqual(['self_zodiac']);
    });

    it('returns incomplete_profile with reason partner_zodiac when partner sign is unrecognised', async () => {
        const self = makeUser();
        const partner = makeUser({ id: 'partner-id', zodiacSign: 'ophiuchus' });
        usersRepository.findOne.mockResolvedValueOnce(partner);

        const result = await service.getRedFlagToday(self);

        expect(result.status).toBe('incomplete_profile');
        if (result.status !== 'incomplete_profile') throw new Error('expected incomplete_profile status');
        expect(result.missing).toEqual(['partner_zodiac']);
    });

    it('produces a stable contentDate from the injected clock', async () => {
        const self = makeUser({ partnerId: null as unknown as string });

        const result = await service.getRedFlagToday(self);

        expect(result.contentDate).toBe('2026-08-25');
    });

    it('successfully dispatches reminder when partner is linked', async () => {
        const self = makeUser({ partnerId: 'partner-123', displayName: 'Minh' });
        const result = await service.remindPartner(self);

        expect(result.success).toBe(true);
        expect(result.message).toContain('Đã gửi lời nhắc');
    });

    it('throws BadRequestException when partner is not linked', async () => {
        const self = makeUser({ partnerId: null as unknown as string });
        await expect(service.remindPartner(self)).rejects.toThrow();
    });
});
