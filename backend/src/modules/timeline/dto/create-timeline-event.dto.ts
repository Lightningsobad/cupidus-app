import { IsString, IsOptional, IsEnum, MaxLength } from 'class-validator';
import { TimelineEventType } from '../entities/timeline-event.entity';
import { ApiProperty } from '@nestjs/swagger';

export class CreateTimelineEventDto {
    @ApiProperty({ description: 'Event title', example: 'First Date', maxLength: 100 })
    @IsString()
    @MaxLength(100)
    title: string;

    @ApiProperty({ description: 'Event description', required: false, maxLength: 500 })
    @IsString()
    @IsOptional()
    @MaxLength(500)
    description?: string;

    @ApiProperty({ description: 'Photo URL associated with the event', required: false })
    @IsString()
    @IsOptional()
    photoUrl?: string;

    @ApiProperty({ description: 'Event icon name', required: false })
    @IsString()
    @IsOptional()
    icon?: string;

    @ApiProperty({ description: 'Event type', enum: TimelineEventType, required: false })
    @IsEnum(TimelineEventType)
    @IsOptional()
    type?: TimelineEventType;

    @ApiProperty({ description: 'Date of the event (ISO string)', required: false })
    @IsString()
    @IsOptional()
    date?: string;
}
