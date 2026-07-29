import { IsEnum, IsOptional, IsString } from 'class-validator';
import { Mood } from '../entities/vibe.entity';
import { ApiProperty } from '@nestjs/swagger';

export class CreateVibeDto {
    @ApiProperty({ description: 'Mood to check-in', enum: Mood, example: Mood.HAPPY })
    @IsEnum(Mood)
    mood: Mood;

    @ApiProperty({ description: 'Optional mood note', required: false, example: 'Had a great day!' })
    @IsOptional()
    @IsString()
    note?: string;
}
