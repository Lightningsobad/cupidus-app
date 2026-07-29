import { Controller, Get, Post, Patch, Body, UseGuards, Request } from '@nestjs/common';
import { PetsService } from './pets.service';
import { AdoptPetDto } from './dto/adopt-pet.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 4 - Love Pet')
@ApiBearerAuth('firebase-jwt')
@Controller('pets')
@UseGuards(JwtAuthGuard)
export class PetsController {
    constructor(
        private readonly petsService: PetsService,
        private readonly usersService: UsersService,
    ) { }

    @Post('adopt')
    @ApiOperation({ summary: 'Adopt a new Love Pet' })
    async adopt(@Request() req, @Body() dto: AdoptPetDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.petsService.adopt(user.id, dto);
    }

    @Get()
    @ApiOperation({ summary: 'Get current Love Pet details' })
    async getPet(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.petsService.getPet(user.id);
    }

    @Get('status')
    @ApiOperation({ summary: 'Get Love Pet dynamic status' })
    async getStatus(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.petsService.getStatus(user.id);
    }

    @Patch('interact')
    @ApiOperation({ summary: 'Interact with the Love Pet (feed/play) to increase happiness' })
    async interact(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.petsService.interact(user.id);
    }
}
