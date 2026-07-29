import { Controller, Post, UseGuards, Request, NotFoundException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 1 - Auth')
@Controller('auth')
export class AuthController {
    constructor(private authService: AuthService) { }

    @Post('login')
    @UseGuards(AuthGuard('firebase-jwt'))
    @ApiBearerAuth('firebase-jwt')
    @ApiOperation({ summary: 'Login user' })
    async login(@Request() req) {
        const user = await this.authService.loginUser(req.user);
        if (!user) {
            throw new NotFoundException('User not registered. Please sign up first.');
        }
        return user;
    }

    @Post('register')
    @UseGuards(AuthGuard('firebase-jwt'))
    @ApiBearerAuth('firebase-jwt')
    @ApiOperation({ summary: 'Register a new authenticated Firebase user' })
    async register(@Request() req) {
        return this.authService.registerUser(req.user);
    }
}
