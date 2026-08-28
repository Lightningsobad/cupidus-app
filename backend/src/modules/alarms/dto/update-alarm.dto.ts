import { IsISO8601, IsOptional, IsString, IsArray, IsBoolean } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateAlarmDto {
    @ApiPropertyOptional({ description: 'Alarm time in ISO 8601 format', example: '2024-01-01T07:00:00.000Z' })
    @IsOptional()
    @IsISO8601()
    time?: string;

    @ApiPropertyOptional({ description: 'Alarm label or description', example: 'Thức dậy cùng Bae' })
    @IsOptional()
    @IsString()
    description?: string;

    @ApiPropertyOptional({ description: 'Repeated weekdays (1=Mon..7=Sun)', example: ['1', '2', '3', '4', '5'] })
    @IsOptional()
    @IsArray()
    weekdays?: string[];

    @ApiPropertyOptional({ description: 'Active state', example: true })
    @IsOptional()
    @IsBoolean()
    isActive?: boolean;
}
