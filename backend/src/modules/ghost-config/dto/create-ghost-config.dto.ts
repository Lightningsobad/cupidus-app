import { IsEnum, IsInt, Min, Max } from 'class-validator';
import { Penalty } from '../entities/ghost-config.entity';
import { ApiProperty } from '@nestjs/swagger';

export class CreateGhostConfigDto {
    @ApiProperty({ description: 'Ghosting timeout in minutes (1-120)', example: 10 })
    @IsInt()
    @Min(1)
    @Max(120)
    timeoutMinutes: number;

    @ApiProperty({ description: 'Penalty type', enum: Penalty, example: Penalty.EMOJI_STORM })
    @IsEnum(Penalty)
    penalty: Penalty;
}
