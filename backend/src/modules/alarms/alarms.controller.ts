import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from '@nestjs/common';
import { AlarmsService } from './alarms.service';
import { CreateAlarmDto } from './dto/create-alarm.dto';
import { UpdateAlarmDto } from './dto/update-alarm.dto';
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

    @Get()
    @ApiOperation({ summary: 'Get all synced alarms for couple' })
    async findAll(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.alarmsService.getAlarmsForUser(user.id);
    }

    @Get(':id')
    @ApiOperation({ summary: 'Get single alarm by id' })
    async findOne(@Request() req, @Param('id') id: string) {
        return this.alarmsService.getAlarmById(id);
    }

    @Post()
    @ApiOperation({ summary: 'Create new synced alarm' })
    async create(@Request() req, @Body() createAlarmDto: CreateAlarmDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.alarmsService.createAlarm(user.id, createAlarmDto);
    }

    @Patch(':id')
    @ApiOperation({ summary: 'Update synced alarm' })
    async update(@Request() req, @Param('id') id: string, @Body() updateAlarmDto: UpdateAlarmDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.alarmsService.updateAlarm(user.id, id, updateAlarmDto);
    }

    @Patch(':id/toggle')
    @ApiOperation({ summary: 'Request toggle on/off for alarm' })
    async toggle(@Request() req, @Param('id') id: string, @Body() body: { isActive: boolean }) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.alarmsService.requestToggle(user.id, id, body.isActive);
    }

    @Delete(':id')
    @ApiOperation({ summary: 'Request deletion of synced alarm' })
    async delete(@Request() req, @Param('id') id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.alarmsService.requestDelete(user.id, id);
    }

    @Patch(':id/confirm')
    @ApiOperation({ summary: 'Confirm alarm action (create, edit, toggle, or delete) set by partner' })
    async confirm(@Request() req, @Param('id') id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.alarmsService.confirmAlarm(user.id, id);
    }

    @Patch(':id/reject')
    @ApiOperation({ summary: 'Reject alarm action proposed by partner' })
    async reject(@Request() req, @Param('id') id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.alarmsService.rejectAlarm(user.id, id);
    }

    @Patch(':id/stop')
    @ApiOperation({ summary: 'Stop alarm while ringing' })
    async stop(@Request() req, @Param('id') id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.alarmsService.stopAlarm(user.id, id);
    }
}
