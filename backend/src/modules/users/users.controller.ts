import { Controller, Get, Body, Patch, UseGuards, Request, Post } from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { MeProfileResponseDto } from './dto/me-profile-response.dto';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiOkResponse } from '@nestjs/swagger';

@ApiTags('Epic 1 - Users')
@ApiBearerAuth('firebase-jwt')
@Controller('users')
@UseGuards(AuthGuard('firebase-jwt'))
export class UsersController {
    constructor(private readonly usersService: UsersService) { }

    @Get('me')
    @ApiOperation({ summary: 'Get current user profile' })
    @ApiOkResponse({ type: MeProfileResponseDto })
    getProfile(@Request() req) {
        // req.user is Firebase user (from strategy). Fetch DB user + partner display name.
        return this.usersService.getProfileWithPartner(req.user.uid);
    }

    @Patch('me')
    @ApiOperation({ summary: 'Update current user profile' })
    async updateProfile(@Request() req, @Body() updateProfileDto: UpdateProfileDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.usersService.updateProfile(user.id, updateProfileDto);
    }

    @Post('vow')
    @ApiOperation({ summary: 'Mark biometric vow as taken' })
    async markVowTaken(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.usersService.markVowTaken(user.id);
    }
}
