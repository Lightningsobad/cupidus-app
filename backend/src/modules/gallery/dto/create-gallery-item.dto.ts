import { IsString, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateGalleryItemDto {
    @ApiProperty({ description: 'Encrypted filename or cloud reference ID' })
    @IsString()
    filename: string;

    @ApiProperty({ description: 'MIME type of the media', required: false })
    @IsString()
    @IsOptional()
    mimeType?: string;
}
