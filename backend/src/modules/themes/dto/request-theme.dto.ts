import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RequestThemeDto {
    @ApiProperty({ description: 'Theme ID to switch or unlock', example: 'sunset' })
    @IsString()
    @IsNotEmpty()
    themeId: string;
}
