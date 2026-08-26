import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class WishlistThemeDto {
    @ApiProperty({ description: 'Theme ID to add/remove from wishlist', example: 'sakura' })
    @IsString()
    @IsNotEmpty()
    themeId: string;
}
