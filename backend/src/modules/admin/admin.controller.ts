import { Controller, Get, Patch, Param, Body, UseGuards, Request } from '@nestjs/common';
import { AdminService } from './admin.service';
import { UpdateConfigDto } from './dto/admin.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AdminGuard } from '../../common/guards/admin.guard';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 6 - Admin Configurations')
@ApiBearerAuth('firebase-jwt')
@Controller('admin')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminController {
    constructor(private readonly adminService: AdminService) { }

    @Get('config')
    @ApiOperation({ summary: 'Get all system configurations' })
    getAllConfigs() {
        return this.adminService.getAllConfigs();
    }

    @Get('config/:key')
    @ApiOperation({ summary: 'Get a specific system configuration' })
    getConfig(@Param('key') key: string) {
        return this.adminService.getConfig(key);
    }

    @Patch('config/:key')
    @ApiOperation({ summary: 'Update a specific system configuration' })
    updateConfig(@Request() req, @Param('key') key: string, @Body() dto: UpdateConfigDto) {
        return this.adminService.updateConfig(req.user.id, key, dto);
    }

    @Get('metrics')
    @ApiOperation({ summary: 'Get system metrics (users, couples, etc.)' })
    getMetrics() {
        return this.adminService.getMetrics();
    }
}
