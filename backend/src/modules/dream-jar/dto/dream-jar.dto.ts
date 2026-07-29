import { IsString, IsNumber, IsOptional, Min, Max, IsDateString, IsEnum } from 'class-validator';
import { DreamJarStatus } from '../entities/dream-jar.entity';
import { ApiProperty } from '@nestjs/swagger';

export class CreateDreamJarDto {
    @ApiProperty({ description: 'Name of the Dream Jar', example: 'Trip to Paris' })
    @IsString()
    name: string;

    @ApiProperty({ description: 'Target amount to save', example: 50000000, minimum: 1 })
    @IsNumber()
    @Min(1)
    @Max(999999999999)
    targetAmount: number;

    @ApiProperty({ description: 'Target date to reach the goal (ISO string)', required: false })
    @IsOptional()
    @IsDateString()
    deadline?: string;

    @ApiProperty({ description: 'Currency code', required: false, example: 'VND', default: 'VND' })
    @IsOptional()
    @IsString()
    currency?: string;
}

export class UpdateDreamJarDto {
    @ApiProperty({ description: 'Name of the Dream Jar', required: false })
    @IsOptional()
    @IsString()
    name?: string;

    @ApiProperty({ description: 'Target amount to save', required: false, minimum: 1 })
    @IsOptional()
    @IsNumber()
    @Min(1)
    @Max(999999999999)
    targetAmount?: number;

    @ApiProperty({ description: 'Target date to reach the goal (ISO string)', required: false })
    @IsOptional()
    @IsDateString()
    deadline?: string;

    @ApiProperty({ description: 'Status of the Dream Jar', enum: DreamJarStatus, required: false })
    @IsOptional()
    @IsEnum(DreamJarStatus)
    status?: DreamJarStatus;
}

export class AddContributionDto {
    @ApiProperty({ description: 'Contribution amount', example: 500000, minimum: 1 })
    @IsNumber()
    @Min(1)
    @Max(999999999999)
    amount: number;

    @ApiProperty({ description: 'Optional note for this contribution', required: false })
    @IsOptional()
    @IsString()
    note?: string;
}
