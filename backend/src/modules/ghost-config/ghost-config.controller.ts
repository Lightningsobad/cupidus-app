import { Controller, Get, Post, Patch, Param, Body, UseGuards, Request } from '@nestjs/common';
import { GhostConfigService } from './ghost-config.service';
import { CreateGhostConfigDto } from './dto/create-ghost-config.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 2/3 - Ghost Config & Anti-Ghosting')
@ApiBearerAuth('firebase-jwt')
@Controller('ghost-config')
@UseGuards(JwtAuthGuard)
export class GhostConfigController {
    constructor(
        private readonly ghostConfigService: GhostConfigService,
        private readonly usersService: UsersService,
    ) { }

    @Post()
    @ApiOperation({ summary: 'Create or update Ghost Config (requires partner approval)' })
    async create(@Request() req, @Body() dto: CreateGhostConfigDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.ghostConfigService.create(user.id, dto);
    }

    @Get()
    @ApiOperation({ summary: 'Get current active Ghost Config' })
    async getActive(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.ghostConfigService.getActive(user.id);
    }

    @Get('pending')
    @ApiOperation({ summary: 'Get pending (unapproved) Ghost Configs' })
    async getPending(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.ghostConfigService.getPending(user.id);
    }

    @Patch(':id/approve')
    @ApiOperation({ summary: 'Approve a pending config request' })
    async approve(@Request() req, @Param('id') id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.ghostConfigService.approve(user.id, id);
    }

    @Patch(':id/reject')
    @ApiOperation({ summary: 'Reject a pending config request' })
    async reject(@Request() req, @Param('id') id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.ghostConfigService.reject(user.id, id);
    }

    @Get('storm-status/:partnerId')
    @ApiOperation({ summary: 'Check if user is allowed to send an Emoji Storm' })
    async getStormStatus(@Request() req, @Param('partnerId') partnerId: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.ghostConfigService.getStormStatus(user.id, partnerId);
    }
}
