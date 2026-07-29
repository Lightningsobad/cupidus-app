import { IsISO8601 } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateAlarmDto {
    @ApiProperty({ description: 'Alarm time in ISO 8601 format', example: '2024-01-01T07:00:00.000Z' })
    @IsISO8601()
    time: string;
}
