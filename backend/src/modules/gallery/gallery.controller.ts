import { Controller, Get, Post, Delete, Param, Body, Query, UseGuards, Request, ParseUUIDPipe } from '@nestjs/common';
import { GalleryService } from './gallery.service';
import { CreateGalleryItemDto } from './dto/create-gallery-item.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 4 - Private Gallery')
@ApiBearerAuth('firebase-jwt')
@Controller('gallery')
@UseGuards(JwtAuthGuard)
export class GalleryController {
    constructor(
        private readonly galleryService: GalleryService,
        private readonly usersService: UsersService,
    ) { }

    @Post()
    @ApiOperation({ summary: 'Add a new encrypted photo reference to Gallery' })
    async create(@Request() req, @Body() dto: CreateGalleryItemDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.galleryService.create(user.id, dto);
    }

    @Get()
    @ApiOperation({ summary: 'Get gallery photos list' })
    async findAll(@Request() req, @Query('limit') limit?: string, @Query('offset') offset?: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.galleryService.findAll(user.id, Number(limit) || 50, Number(offset) || 0);
    }

    @Delete(':id')
    @ApiOperation({ summary: 'Delete a photo from Gallery' })
    async remove(@Request() req, @Param('id', ParseUUIDPipe) id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.galleryService.remove(user.id, id);
    }
}
