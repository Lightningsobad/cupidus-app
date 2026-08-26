import { Injectable, NotFoundException, BadRequestException, ConflictException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { Pet } from './entities/pet.entity';
import { User } from '../users/entities/user.entity';
import { AdoptPetDto } from './dto/adopt-pet.dto';
import { getCoupleId } from '../../common/utils/couple.util';
import { PetMilestoneReachedEvent } from '../../common/events/pet-milestone.event';

@Injectable()
export class PetsService {
    private readonly logger = new Logger(PetsService.name);

    constructor(
        @InjectRepository(Pet)
        private petRepository: Repository<Pet>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
        private dataSource: DataSource,
        private eventEmitter: EventEmitter2,
    ) { }


    async adopt(userId: string, dto: AdoptPetDto): Promise<Pet> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user) {
            throw new NotFoundException('User not found');
        }
        if (!user.partnerId) {
            throw new BadRequestException('You must be paired with a partner to adopt a pet');
        }

        // Check 24-hour pairing requirement (using createdAt as proxy — no pairedAt field)
        const hoursSincePairing = (Date.now() - new Date(user.createdAt).getTime()) / (1000 * 60 * 60);
        if (hoursSincePairing < 24) {
            throw new BadRequestException('You must be paired for at least 24 hours to adopt a pet');
        }

        const coupleId = getCoupleId(userId, user.partnerId);

        // Use transaction to prevent race condition (H3 fix)
        const queryRunner = this.dataSource.createQueryRunner();
        await queryRunner.connect();
        await queryRunner.startTransaction();

        try {
            const existing = await queryRunner.manager.findOne(Pet, { where: { coupleId } });
            if (existing) {
                throw new ConflictException('Your couple already has a pet! Say hi to ' + existing.name);
            }

            const pet = queryRunner.manager.create(Pet, {
                coupleId,
                species: dto.species,
                name: dto.name,
                happiness: 50,
                level: 1,
                totalInteractions: 0,
                streak: 0,
                lastStreakDate: null,
            });

            const saved = await queryRunner.manager.save(pet);
            await queryRunner.commitTransaction();

            this.logger.log(`[PET ADOPTED] Couple ${coupleId} adopted a ${dto.species} named "${dto.name}"`);
            return saved;
        } catch (error) {
            await queryRunner.rollbackTransaction();
            throw error;
        } finally {
            await queryRunner.release();
        }
    }

    async getPet(userId: string): Promise<Pet | null> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            return null;
        }

        const coupleId = getCoupleId(userId, user.partnerId);
        return this.petRepository.findOne({ where: { coupleId } });
    }

    async interact(userId: string): Promise<Pet> {
        const pet = await this.getPet(userId);
        if (!pet) {
            throw new NotFoundException('No pet found. Adopt one first!');
        }

        // Rate limiting: 5-second cooldown between interactions (M1 fix)
        if (pet.lastInteraction) {
            const secondsSince = (Date.now() - new Date(pet.lastInteraction).getTime()) / 1000;
            if (secondsSince < 5) {
                throw new BadRequestException('Slow down! You can interact again in a few seconds.');
            }
        }

        pet.totalInteractions += 1;
        pet.lastInteraction = new Date();

        // Calculate daily streak
        const todayStr = pet.lastInteraction.toISOString().slice(0, 10);
        if (!pet.lastStreakDate) {
            pet.streak = 1;
            pet.lastStreakDate = todayStr;
        } else if (pet.lastStreakDate === todayStr) {
            if (!pet.streak || pet.streak === 0) {
                pet.streak = 1;
            }
        } else {
            const lastDate = new Date(pet.lastStreakDate);
            const currentDate = new Date(todayStr);
            const diffDays = Math.round((currentDate.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24));
            if (diffDays === 1) {
                pet.streak = (pet.streak || 0) + 1;
                pet.lastStreakDate = todayStr;
            } else {
                pet.streak = 1;
                pet.lastStreakDate = todayStr;
            }
        }

        // Increase happiness (capped at 100)
        pet.happiness = Math.min(100, pet.happiness + 5);

        // Level up every 50 interactions
        const newLevel = Math.floor(pet.totalInteractions / 50) + 1;
        if (newLevel > pet.level) {
            pet.level = newLevel;
            this.logger.log(`[PET LEVEL UP] ${pet.name} is now level ${pet.level}!`);
        }

        const saved = await this.petRepository.save(pet);

        // H2 fix: Emit milestone event for auto-timeline generation
        const milestoneThresholds = [50, 100, 500, 1000];
        if (milestoneThresholds.includes(pet.totalInteractions)) {
            this.eventEmitter.emit(
                'pet.milestone.reached',
                new PetMilestoneReachedEvent(pet.coupleId, pet.name, pet.totalInteractions, pet.level),
            );
        }

        return saved;
    }

    async getStatus(userId: string): Promise<{
        pet: Pet;
        mood: string;
        decayedHappiness: number;
        milestone: string | null;
        nextMilestone: number;
        streak: number;
        badgesCount: number;
    } | null> {
        const pet = await this.getPet(userId);
        if (!pet) {
            return null;
        }

        const decayedHappiness = this.computeDecayedHappiness(pet);
        const mood = this.computeMood(decayedHappiness, pet.lastInteraction);
        const milestone = this.getCurrentMilestone(pet.totalInteractions);
        const nextMilestone = this.getNextMilestone(pet.totalInteractions);

        // Calculate active streak
        const todayStr = new Date().toISOString().slice(0, 10);
        let activeStreak = pet.streak || 0;
        if (pet.lastStreakDate && pet.lastStreakDate !== todayStr) {
            const lastDate = new Date(pet.lastStreakDate);
            const currentDate = new Date(todayStr);
            const diffDays = Math.round((currentDate.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24));
            if (diffDays > 1) {
                activeStreak = 0;
            }
        } else if (!pet.lastStreakDate) {
            activeStreak = 0;
        }

        // Calculate badges count: 1 adoption badge + 1 per achieved milestone
        const achievedMilestones = PetsService.MILESTONES.filter(m => pet.totalInteractions >= m);
        const badgesCount = 1 + achievedMilestones.length;

        // Persist decayed happiness if it changed
        if (decayedHappiness !== pet.happiness) {
            pet.happiness = decayedHappiness;
            await this.petRepository.save(pet);
        }

        return { pet, mood, decayedHappiness, milestone, nextMilestone, streak: activeStreak, badgesCount };
    }

    private computeDecayedHappiness(pet: Pet): number {
        if (!pet.lastInteraction) {
            return pet.happiness;
        }

        const hoursSinceInteraction = (Date.now() - new Date(pet.lastInteraction).getTime()) / (1000 * 60 * 60);

        // Start decay after 12 hours idle: -2 happiness per hour
        if (hoursSinceInteraction > 12) {
            const decayHours = hoursSinceInteraction - 12;
            const decay = Math.floor(decayHours * 2);
            return Math.max(0, pet.happiness - decay);
        }

        return pet.happiness;
    }

    private computeMood(happiness: number, lastInteraction: Date | null): string {
        if (!lastInteraction) {
            return 'content';
        }

        const hoursSince = (Date.now() - new Date(lastInteraction).getTime()) / (1000 * 60 * 60);

        // Sick if ignored for > 48 hours
        if (hoursSince > 48) {
            return 'sick';
        }

        if (happiness >= 80) return 'ecstatic';
        if (happiness >= 60) return 'happy';
        if (happiness >= 40) return 'content';
        if (happiness >= 20) return 'sad';
        return 'sick';
    }

    private static readonly MILESTONES = [50, 100, 250, 500, 1000, 2500, 5000];

    private getCurrentMilestone(interactions: number): string | null {
        // Return the highest achieved milestone
        const achieved = PetsService.MILESTONES.filter(m => interactions >= m);
        if (achieved.length === 0) return null;
        const highest = achieved[achieved.length - 1];
        return `${highest} interactions!`;
    }

    private getNextMilestone(interactions: number): number {
        const next = PetsService.MILESTONES.find(m => m > interactions);
        return next || PetsService.MILESTONES[PetsService.MILESTONES.length - 1];
    }
}
