import { Controller, Post, Body, UseGuards, Request, BadRequestException, Logger, Get, Query, InternalServerErrorException } from '@nestjs/common';
import { InvitationsService } from './invitations.service';
import { AuthGuard } from '@nestjs/passport';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 1 - Invitations')
@Controller('invitations')
export class InvitationsController {
    private readonly logger = new Logger(InvitationsController.name);

    constructor(
        private readonly invitationsService: InvitationsService,
        private readonly usersService: UsersService,
    ) { }

    @Post('generate')
    @UseGuards(AuthGuard('firebase-jwt'))
    @ApiBearerAuth('firebase-jwt')
    @ApiOperation({ summary: 'Generate a pairing invitation code' })
    async generate(@Request() req) {
        this.logger.log(`Request to generate code for user: ${req.user.uid}`);
        try {
            const user = await this.usersService.findByFirebaseUid(req.user.uid);
            this.logger.log(`Found user: ${user.id}, generating code...`);
            const result = await this.invitationsService.generateCode(user.id);
            this.logger.log(`Code generated successfully: ${result.code}`);
            return result;
        } catch (error) {
            this.logger.error(`Error generating code: ${error.message}`, error.stack);
            // Return the actual error message to the client for debugging
            throw new InternalServerErrorException(`Debug Error: ${error.message} - Stack: ${error.stack}`);
        }
    }

    @Get('test-generate-debug')
    @ApiOperation({ summary: 'Debug: Test generating code' })
    async testGenerate(@Query('uid') uid: string) {
        this.logger.log(`TEST Request to generate code for UID: ${uid}`);
        try {
            // For debugging, if no UID provided, try to find ANY user to test with
            let user;
            if (uid) {
                user = await this.usersService.findByFirebaseUid(uid);
            } else {
                // This is a HACK for debugging only
                const users = await this.usersService['userRepository'].find({ take: 1 });
                if (users.length > 0) user = users[0];
            }

            if (!user) {
                throw new BadRequestException('No user found to test with');
            }

            this.logger.log(`Test generating for user: ${user.id} (${user.email})`);
            return this.invitationsService.generateCode(user.id);
        } catch (error) {
            this.logger.error(`Test Error: ${error.message}`, error.stack);
            throw new InternalServerErrorException(error.message);
        }
    }

    @Post('accept')
    @UseGuards(AuthGuard('firebase-jwt'))
    @ApiBearerAuth('firebase-jwt')
    @ApiOperation({ summary: 'Accept an invitation using a code' })
    async accept(@Request() req, @Body('code') code: string) {
        if (!code) {
            throw new BadRequestException('Code is required');
        }
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.invitationsService.acceptInvitation(user.id, code);
    }

    @Post('validate')
    // validate might be public? Check original code. If invitee hasn't signed up yet?
    // The original code had class level auth guard, so it WAS protected.
    @UseGuards(AuthGuard('firebase-jwt'))
    @ApiBearerAuth('firebase-jwt')
    @ApiOperation({ summary: 'Validate an invitation code' })
    validate(@Body('code') code: string) {
        if (!code) {
            throw new BadRequestException('Code is required');
        }
        return this.invitationsService.validateCode(code);
    }

    @Get('test-validate-debug')
    @ApiOperation({ summary: 'Debug: Test validating code' })
    async testValidate(@Query('code') code: string) {
        this.logger.log(`TEST Request to validate code: ${code}`);
        try {
            if (!code) {
                throw new BadRequestException('Code is required');
            }
            return this.invitationsService.validateCode(code);
        } catch (error) {
            this.logger.error(`Test Val Error: ${error.message}`, error.stack);
            throw new InternalServerErrorException(error.message);
        }
    }
}
