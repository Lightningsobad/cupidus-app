import { IsString, IsOptional, IsDateString, IsEnum, IsUrl, IsBoolean } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum CoupleType {
    SAME_CITY = 'SAME_CITY',
    LONG_DISTANCE = 'LONG_DISTANCE',
    LIVING_TOGETHER = 'LIVING_TOGETHER',
    DATING = 'DATING',
}

export class UpdateProfileDto {
    @ApiProperty({ description: 'The display name of the user', example: 'John Doe', required: false })
    @IsString()
    @IsOptional()
    displayName?: string;

    @ApiProperty({ description: 'The birthday of the user in ISO 8601 format', example: '1990-01-01', required: false })
    @IsDateString()
    @IsOptional()
    birthday?: string;

    @ApiProperty({ description: 'The relationship start date in ISO 8601 format', example: '2023-01-01', required: false })
    @IsDateString()
    @IsOptional()
    relationshipStartDate?: string;

    @ApiProperty({ description: 'Zodiac sign', example: 'Aries', required: false })
    @IsString()
    @IsOptional()
    zodiacSign?: string;

    @ApiProperty({ description: 'Primary language', example: 'vi', required: false })
    @IsString()
    @IsOptional()
    language?: string;

    @ApiProperty({ description: 'Avatar URL', required: false })
    @IsOptional()
    @IsUrl()
    photoUrl?: string;

    @ApiProperty({ description: 'Couple type', enum: CoupleType, required: false })
    @IsOptional()
    @IsEnum(CoupleType)
    coupleType?: string;

    @ApiProperty({ description: 'Is ghost mode enabled globally', required: false })
    @IsOptional()
    @IsBoolean()
    isGhostModeEnabled?: boolean;
}
