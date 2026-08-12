import { Controller, Get, Post, Body, UseGuards, Request, Patch } from '@nestjs/common';
import { LoveContractsService } from './love-contracts.service';
import { CreateContractDto } from './dto/create-contract.dto';
import { LoveContractResponseDto } from './dto/love-contract-response.dto';
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
    async create(@Request() req, @Body() createContractDto: CreateContractDto): Promise<LoveContractResponseDto> {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        const contract = await this.loveContractsService.create(user.id, createContractDto);
        return LoveContractResponseDto.from(contract, user.id);
    }

    @Patch('sign')
    @ApiOperation({ summary: 'Sign the pending love contract' })
    async sign(@Request() req): Promise<LoveContractResponseDto> {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        const contract = await this.loveContractsService.sign(user.id);
        return LoveContractResponseDto.from(contract, user.id);
    }

    @Get('my-pending')
    @ApiOperation({ summary: 'Get current pending love contract' })
    async getMyPending(@Request() req): Promise<LoveContractResponseDto | null> {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        const contract = await this.loveContractsService.getMyContract(user.id);
        return contract ? LoveContractResponseDto.from(contract, user.id) : null;
    }
}
