import { Controller, Get, Post, Body, Query, UseGuards, Request } from '@nestjs/common';
import { VibesService } from './vibes.service';
import { CreateVibeDto } from './dto/create-vibe.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 3 - Daily Vibe Check')
@ApiBearerAuth('firebase-jwt')
@Controller('vibes')
@UseGuards(JwtAuthGuard)
export class VibesController {
    constructor(
        private readonly vibesService: VibesService,
        private readonly usersService: UsersService,
    ) { }

    private parseDays(days?: string): number {
        if (!days) return 30;
        const parsed = parseInt(days, 10);
        if (isNaN(parsed) || parsed < 1) return 30;
        return Math.min(parsed, 365);
    }

    @Post()
    @ApiOperation({ summary: 'Post daily mood / vibe' })
    async create(@Request() req, @Body() createVibeDto: CreateVibeDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.vibesService.create(user.id, createVibeDto);
    }

    @Get('today')
    @ApiOperation({ summary: 'Get current user\'s vibe for today' })
    async getToday(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.vibesService.getTodayVibe(user.id);
    }

    @Get('history')
    @ApiOperation({ summary: 'Get user\'s vibe history' })
    async getHistory(@Request() req, @Query('days') days?: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.vibesService.getHistory(user.id, this.parseDays(days));
    }

    @Get('partner')
    @ApiOperation({ summary: 'Get partner\'s vibe history' })
    async getPartnerHistory(@Request() req, @Query('days') days?: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.vibesService.getPartnerHistory(user.id, this.parseDays(days));
    }
}
