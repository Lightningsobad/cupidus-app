import { Controller, Get, Post, Param, UseGuards, Request, Res, ParseUUIDPipe, StreamableFile } from '@nestjs/common';
import { DataExportService } from './data-export.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { createReadStream } from 'fs';
import type { Response } from 'express';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 6 - Data Export')
@ApiBearerAuth('firebase-jwt')
@Controller('data-export')
@UseGuards(JwtAuthGuard)
export class DataExportController {
    constructor(
        private readonly dataExportService: DataExportService,
        private readonly usersService: UsersService,
    ) { }

    @Post()
    @ApiOperation({ summary: 'Request a new personal data export' })
    async requestExport(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.dataExportService.requestExport(user.id);
    }

    @Get()
    @ApiOperation({ summary: 'Get list of personal data exports' })
    async getExports(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.dataExportService.getExports(user.id);
    }

    @Get(':id/download')
    @ApiOperation({ summary: 'Download a completed data export zip file' })
    async downloadExport(
        @Request() req,
        @Param('id', ParseUUIDPipe) id: string,
        @Res({ passthrough: true }) res: Response,
    ): Promise<StreamableFile> {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        const filePath = await this.dataExportService.getExportFile(user.id, id);

        res.set({
            'Content-Type': 'application/zip',
            'Content-Disposition': `attachment; filename="cupid-data-export-${id}.zip"`,
        });

        const file = createReadStream(filePath);
        return new StreamableFile(file);
    }
}
