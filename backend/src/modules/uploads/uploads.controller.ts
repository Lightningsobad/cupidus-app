import { Controller, Post, UseInterceptors, UploadedFile, UseGuards } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { v4 as uuidv4 } from 'uuid';
import { extname } from 'path';
import { UploadsService } from './uploads.service';
import { AuthGuard } from '@nestjs/passport'; // Or Firebase guard

@Controller('uploads')
export class UploadsController {
    constructor(private readonly uploadsService: UploadsService) { }

    @Post()
    @UseGuards(AuthGuard('firebase-jwt'))
    @UseInterceptors(FileInterceptor('file', {
        storage: diskStorage({
            destination: './uploads',
            filename: (req, file, cb) => {
                const uniqueSuffix = uuidv4();
                const ext = extname(file.originalname);
                cb(null, `${uniqueSuffix}${ext}`);
            },
        }),
        limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
    }))
    uploadFile(@UploadedFile() file: Express.Multer.File) {
        // file.filename contains the saved name
        const url = this.uploadsService.getUpdloadUrl(file.filename);
        return {
            url: url,
            filename: file.filename,
            originalName: file.originalname,
            mimeType: file.mimetype,
            size: file.size,
        };
    }
}
