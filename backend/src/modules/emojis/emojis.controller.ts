import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { EmojisService } from './emojis.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Emoji Store')
@ApiBearerAuth('firebase-jwt')
@Controller('emojis')
@UseGuards(JwtAuthGuard)
export class EmojisController {
    constructor(
        private readonly emojisService: EmojisService,
        private readonly usersService: UsersService,
    ) { }

    @Get('catalog')
    @ApiOperation({ summary: 'Get the Emoji Packs Catalog' })
    getCatalog() {
        return this.emojisService.getEmojiCatalog();
    }

    @Get('state')
    @ApiOperation({ summary: 'Get current couple emoji state (downloaded packs, active pack)' })
    async getState(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.emojisService.getCoupleEmojiState(user.id);
    }

    @Post('unlock')
    @ApiOperation({ summary: 'Unlock or download an emoji pack' })
    async unlockPack(@Request() req, @Body('packId') packId: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.emojisService.unlockOrDownloadPack(user.id, packId);
    }

    @Post('active')
    @ApiOperation({ summary: 'Set active emoji pack' })
    async setActivePack(@Request() req, @Body('packId') packId: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.emojisService.setActivePack(user.id, packId);
    }
}
