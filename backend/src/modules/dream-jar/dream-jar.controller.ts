import { Controller, Get, Post, Patch, Delete, Param, Body, Query, UseGuards, Request, ParseUUIDPipe } from '@nestjs/common';
import { DreamJarService } from './dream-jar.service';
import { CreateDreamJarDto, UpdateDreamJarDto, AddContributionDto } from './dto/dream-jar.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 5 - Dream Jar')
@ApiBearerAuth('firebase-jwt')
@Controller('dream-jar')
@UseGuards(JwtAuthGuard)
export class DreamJarController {
    constructor(
        private readonly dreamJarService: DreamJarService,
        private readonly usersService: UsersService,
    ) { }

    @Post()
    @ApiOperation({ summary: 'Create a new Dream Jar' })
    async create(@Request() req, @Body() dto: CreateDreamJarDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.dreamJarService.create(user.id, dto);
    }

    @Get()
    @ApiOperation({ summary: 'Get all Dream Jars' })
    async findAll(@Request() req, @Query('limit') limit?: string, @Query('offset') offset?: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.dreamJarService.findAll(user.id, Number(limit) || 50, Number(offset) || 0);
    }

    @Get(':id')
    @ApiOperation({ summary: 'Get a specific Dream Jar' })
    async findOne(@Request() req, @Param('id', ParseUUIDPipe) id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.dreamJarService.findOne(user.id, id);
    }

    @Patch(':id')
    @ApiOperation({ summary: 'Update a Dream Jar' })
    async update(@Request() req, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateDreamJarDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.dreamJarService.update(user.id, id, dto);
    }

    @Patch(':id/approve')
    @ApiOperation({ summary: 'Approve a pending Dream Jar (partner only)' })
    async approve(@Request() req, @Param('id', ParseUUIDPipe) id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.dreamJarService.approve(user.id, id);
    }

    @Patch(':id/reject')
    @ApiOperation({ summary: 'Reject a pending Dream Jar (partner only)' })
    async reject(@Request() req, @Param('id', ParseUUIDPipe) id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.dreamJarService.reject(user.id, id);
    }

    @Delete(':id')
    @ApiOperation({ summary: 'Delete a Dream Jar' })
    async remove(@Request() req, @Param('id', ParseUUIDPipe) id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.dreamJarService.remove(user.id, id);
    }

    // --- Contributions ---

    @Post(':id/contributions')
    @ApiOperation({ summary: 'Add a contribution to a Dream Jar' })
    async addContribution(@Request() req, @Param('id', ParseUUIDPipe) id: string, @Body() dto: AddContributionDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.dreamJarService.addContribution(user.id, id, dto);
    }

    @Get(':id/contributions')
    @ApiOperation({ summary: 'Get contribution history of a Dream Jar' })
    async getContributions(
        @Request() req,
        @Param('id', ParseUUIDPipe) id: string,
        @Query('limit') limit?: string,
        @Query('offset') offset?: string,
    ) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.dreamJarService.getContributions(user.id, id, Number(limit) || 50, Number(offset) || 0);
    }

    @Delete(':id/contributions/:contributionId')
    @ApiOperation({ summary: 'Delete/Undo a contribution in a Dream Jar' })
    async removeContribution(
        @Request() req,
        @Param('id', ParseUUIDPipe) id: string,
        @Param('contributionId', ParseUUIDPipe) contributionId: string,
    ) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.dreamJarService.removeContribution(user.id, id, contributionId);
    }
}
