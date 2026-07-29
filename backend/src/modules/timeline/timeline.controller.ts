import { Controller, Get, Post, Delete, Param, Body, Query, UseGuards, Request } from '@nestjs/common';
import { TimelineService } from './timeline.service';
import { CreateTimelineEventDto } from './dto/create-timeline-event.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 4 - Love Timeline')
@ApiBearerAuth('firebase-jwt')
@Controller('timeline')
@UseGuards(JwtAuthGuard)
export class TimelineController {
    constructor(
        private readonly timelineService: TimelineService,
        private readonly usersService: UsersService,
    ) { }

    @Post()
    @ApiOperation({ summary: 'Add a manual memory to the timeline' })
    async addEvent(@Request() req, @Body() dto: CreateTimelineEventDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.timelineService.addEvent(user.id, dto);
    }

    @Get()
    @ApiOperation({ summary: 'Get timeline events' })
    async getTimeline(@Request() req, @Query('limit') limit?: string, @Query('offset') offset?: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.timelineService.getTimeline(user.id, Number(limit) || 50, Number(offset) || 0);
    }

    @Delete(':id')
    @ApiOperation({ summary: 'Delete a timeline event' })
    async deleteEvent(@Request() req, @Param('id') id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.timelineService.deleteEvent(user.id, id);
    }
}
