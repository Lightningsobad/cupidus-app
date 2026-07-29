import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from '@nestjs/common';
import { AlarmsService } from './alarms.service';
import { CreateAlarmDto } from './dto/create-alarm.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 3 - Synced Alarms')
@ApiBearerAuth('firebase-jwt')
@Controller('alarms')
@UseGuards(JwtAuthGuard)
export class AlarmsController {
    constructor(
        private readonly alarmsService: AlarmsService,
        private readonly usersService: UsersService,
    ) { }

    @Post()
    @ApiOperation({ summary: 'Create or update synced alarm time' })
    async create(@Request() req, @Body() createAlarmDto: CreateAlarmDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.alarmsService.createOrUpdateAlarm(user.id, new Date(createAlarmDto.time));
    }

    @Get()
    @ApiOperation({ summary: 'Get current coupled alarm setup' })
    async findOne(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.alarmsService.getAlarmForUser(user.id);
    }

    @Patch(':id/confirm')
    @ApiOperation({ summary: 'Confirm alarm time set by partner' })
    async confirm(@Request() req, @Param('id') id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.alarmsService.confirmAlarm(user.id, id);
    }

    @Patch(':id/stop')
    @ApiOperation({ summary: 'Stop alarm while ringing' })
    async stop(@Request() req, @Param('id') id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.alarmsService.stopAlarm(user.id, id);
    }
}
