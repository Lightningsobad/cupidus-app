import { Injectable, NotFoundException, BadRequestException, ConflictException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Invitation } from './entities/invitation.entity';
import { UsersService } from '../users/users.service';
import { randomBytes } from 'crypto';

export interface ValidateCodeResult {
    invitation: Invitation;
    inviter: { id: string; displayName: string; photoUrl: string };
}

@Injectable()
export class InvitationsService {
    private readonly logger = new Logger(InvitationsService.name);
    constructor(
        @InjectRepository(Invitation)
        private invitationRepository: Repository<Invitation>,
        private usersService: UsersService,
    ) { }

    async generateCode(userId: string): Promise<Invitation> {
        this.logger.debug(`generateCode called for userId: ${userId}`);

        // Check if active code exists
        const existing = await this.invitationRepository.findOne({
            where: { inviterId: userId, isActive: true },
        });

        if (existing) {
            this.logger.debug(`Found existing active code: ${existing.code}`);
            // Check expiry? For MVP, just return existing or recreate if old
            return existing;
        }

        const code = randomBytes(3).toString('hex').toUpperCase(); // 6 chars
        this.logger.debug(`Generated new code string: ${code}`);

        const invitation = this.invitationRepository.create({
            inviterId: userId,
            code,
            isActive: true,
            expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24h
        });

        this.logger.debug(`Saving invitation...`);
        try {
            const saved = await this.invitationRepository.save(invitation);
            this.logger.debug(`Invitation saved successfully: ${saved.id}`);
            return saved;
        } catch (e) {
            this.logger.error(`Failed to save invitation: ${e.message}`, e.stack);
            throw e;
        }
    }

    async validateCode(code: string): Promise<ValidateCodeResult> {
        this.logger.debug(`validateCode called with code: ${code}`);
        const invitation = await this.invitationRepository.findOne({
            where: { code, isActive: true },
        });

        if (!invitation) {
            this.logger.warn(`Invitation not found or inactive for code: ${code}`);
            throw new NotFoundException('Invalid or expired code');
        }

        this.logger.debug(`Found invitation: ${invitation.id}, check expiry...`);
        if (invitation.expiresAt && invitation.expiresAt < new Date()) {
            this.logger.warn(`Invitation expired: ${invitation.expiresAt}`);
            throw new BadRequestException('Code expired');
        }

        this.logger.debug(`Finding inviter: ${invitation.inviterId}`);
        const inviter = await this.usersService.findOne(invitation.inviterId);

        this.logger.debug(`Inviter found: ${inviter.id}, returning result.`);
        return {
            invitation,
            inviter: {
                id: inviter.id,
                displayName: inviter.displayName,
                photoUrl: inviter.photoUrl,
            },
        };
    }

    async acceptInvitation(userId: string, code: string): Promise<{ success: boolean }> {
        const user = await this.usersService.findOne(userId);
        if (user.partnerId) {
            throw new ConflictException('You are already paired with a partner');
        }

        const { invitation } = await this.validateCode(code);

        if (invitation.inviterId === userId) {
            throw new ConflictException('Cannot invite yourself');
        }

        const inviter = await this.usersService.findOne(invitation.inviterId);
        if (inviter.partnerId) {
            throw new ConflictException('This person is already paired with a partner');
        }

        // Link users
        // Set partnerId for BOTH users
        await this.usersService.setPartner(userId, invitation.inviterId);
        await this.usersService.setPartner(invitation.inviterId, userId);

        const today = new Date().toISOString().split('T')[0];
        if (!user.relationshipStartDate) {
            await this.usersService.updateProfile(userId, {
                relationshipStartDate: today,
                coupleType: user.coupleType || 'SAME_CITY',
            });
        }
        if (!inviter.relationshipStartDate) {
            await this.usersService.updateProfile(invitation.inviterId, {
                relationshipStartDate: today,
                coupleType: inviter.coupleType || 'SAME_CITY',
            });
        }

        // Deactivate invitation
        invitation.isActive = false;
        await this.invitationRepository.save(invitation);

        return { success: true };
    }
}
