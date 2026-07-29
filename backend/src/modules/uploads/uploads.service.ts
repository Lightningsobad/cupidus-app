import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class UploadsService {
    constructor(private configService: ConfigService) { }

    getUpdloadUrl(filename: string): string {
        // Construct full URL based on host/port
        const host = this.configService.get('HOST') || 'localhost';
        const port = this.configService.get('PORT') || 3000;
        // Check if we are in dev/local environment
        // For simplicity, return relative path or full URL
        return `http://${host}:${port}/uploads/${filename}`;
    }
}
