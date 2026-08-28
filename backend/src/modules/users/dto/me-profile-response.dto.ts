import { ApiProperty } from '@nestjs/swagger';

export class MeProfileResponseDto {
    @ApiProperty({ description: 'The user id', example: 'user-123' })
    id: string;

    @ApiProperty({ description: 'The user email', example: 'user@example.com' })
    email: string;

    @ApiProperty({ description: 'The display name of the user', example: 'Minh', nullable: true })
    displayName: string | null;

    @ApiProperty({ description: 'Avatar URL', nullable: true })
    photoUrl: string | null;

    @ApiProperty({ description: 'The birthday of the user', nullable: true })
    birthday: Date | null;

    @ApiProperty({ description: 'The relationship start date', nullable: true })
    relationshipStartDate: Date | null;

    @ApiProperty({ description: 'Zodiac sign', nullable: true })
    zodiacSign: string | null;

    @ApiProperty({ description: 'Primary language' })
    language: string;

    @ApiProperty({ description: 'Paired partner id, if any', nullable: true })
    partnerId: string | null;

    @ApiProperty({ description: 'Couple type', nullable: true })
    coupleType: string | null;

    @ApiProperty({ description: 'Whether the biometric vow has been taken' })
    vowTaken: boolean;

    @ApiProperty({ description: 'Whether ghost mode is enabled globally' })
    isGhostModeEnabled: boolean;

    @ApiProperty({
        description:
            "The paired partner's display name, resolved from partnerId. Null when unpaired, when partnerId points at a deleted row, or when the partner has no displayName. Never an empty-string sentinel.",
        example: 'Linh',
        nullable: true,
    })
    partnerDisplayName: string | null;

    @ApiProperty({
        description:
            "The paired partner's photo/avatar URL, resolved from partnerId. Null when unpaired, when partnerId points at a deleted row, or when the partner has no photoUrl.",
        example: 'https://example.com/avatar.jpg',
        nullable: true,
    })
    partnerPhotoUrl: string | null;

    @ApiProperty({ description: 'Whether the partner has taken biometric vow' })
    partnerVowTaken: boolean;
}
