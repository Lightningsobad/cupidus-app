import { Controller, Get, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ZodiacService } from './zodiac.service';
import { UsersService } from '../users/users.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { ZodiacRedFlagTodayResponse } from './dto/zodiac-red-flag-today.dto';

@ApiTags('Zodiac Red Flag')
@ApiBearerAuth('firebase-jwt')
@Controller('zodiac')
@UseGuards(JwtAuthGuard)
export class ZodiacController {
    constructor(
        private readonly zodiacService: ZodiacService,
        private readonly usersService: UsersService,
    ) { }

    @Get('red-flag/today')
    @ApiOperation({ summary: "Get today's zodiac red-flag reading for the couple" })
    async getRedFlagToday(@Request() req): Promise<ZodiacRedFlagTodayResponse> {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.zodiacService.getRedFlagToday(user);
    }
}
