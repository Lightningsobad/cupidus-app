import { IsString, IsOptional, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateConfigDto {
    @ApiProperty({ description: 'Configuration value (can be any type: string, number, boolean, object)' })
    @IsNotEmpty()
    value: any;

    @ApiProperty({ description: 'Optional description or reason for update', required: false })
    @IsOptional()
    @IsString()
    description?: string;
}
