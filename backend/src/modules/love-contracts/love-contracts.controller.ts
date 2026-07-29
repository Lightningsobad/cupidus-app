import { Controller, Get, Post, Body, UseGuards, Request, Patch } from '@nestjs/common';
import { LoveContractsService } from './love-contracts.service';
import { CreateContractDto } from './dto/create-contract.dto';
import { AuthGuard } from '@nestjs/passport';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 1 - Love Contracts')
@ApiBearerAuth('firebase-jwt')
@Controller('love-contracts')
@UseGuards(AuthGuard('firebase-jwt'))
export class LoveContractsController {
    constructor(
        private readonly loveContractsService: LoveContractsService,
        private readonly usersService: UsersService,
    ) { }

    @Post()
    @ApiOperation({ summary: 'Create a new love contract' })
    async create(@Request() req, @Body() createContractDto: CreateContractDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.loveContractsService.create(user.id, createContractDto);
    }

    @Patch('sign')
    @ApiOperation({ summary: 'Sign the pending love contract' })
    async sign(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.loveContractsService.sign(user.id);
    }

    @Get('my-pending')
    @ApiOperation({ summary: 'Get current pending love contract' })
    async getMyPending(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.loveContractsService.getMyContract(user.id);
    }
}
