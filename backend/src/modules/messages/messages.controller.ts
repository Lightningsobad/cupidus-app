import { Controller, Get, Post, Body, Query, UseGuards, Request } from '@nestjs/common';
import { MessagesService } from './messages.service';
import { AuthGuard } from '@nestjs/passport';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 2 - Communication / Messages')
@ApiBearerAuth('firebase-jwt')
@Controller('messages')
@UseGuards(AuthGuard('firebase-jwt'))
export class MessagesController {
    constructor(
        private readonly messagesService: MessagesService,
        private readonly usersService: UsersService,
    ) { }

    @Post()
    @ApiOperation({ summary: 'Create a new chat message (fallback for websocket)' })
    async create(@Request() req, @Body() createMessageDto: any) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        // Force senderId to be the authenticated user
        return this.messagesService.create({ ...createMessageDto, senderId: user.id });
    }

    @Get()
    @ApiOperation({ summary: 'Get messages history' })
    async findAll(
        @Request() req,
        @Query('partnerId') partnerId: string,
        @Query('page') page: number = 1,
        @Query('limit') limit: number = 20
    ) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.messagesService.findAll(user.id, partnerId, page, limit);
    }
}
