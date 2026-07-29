import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Vibe } from './entities/vibe.entity';
import { User } from '../users/entities/user.entity';
import { CreateVibeDto } from './dto/create-vibe.dto';

@Injectable()
export class VibesService {
    private readonly logger = new Logger(VibesService.name);

    constructor(
        @InjectRepository(Vibe)
        private vibesRepository: Repository<Vibe>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
    ) { }

    async create(userId: string, createVibeDto: CreateVibeDto): Promise<Vibe> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user) {
            throw new NotFoundException('User not found');
        }

        const vibe = this.vibesRepository.create({
            userId,
            mood: createVibeDto.mood,
            note: createVibeDto.note,
        });

        const savedVibe = await this.vibesRepository.save(vibe);

        // Notify partner if they exist
        if (user.partnerId) {
            this.logger.log(`[PUSH NOTIFICATION] To: ${user.partnerId} | Bae is feeling ${createVibeDto.mood}`);
            // STUB: Real implementation would use Firebase Admin SDK
            // await this.notificationService.send(user.partnerId, {
            //     title: 'Vibe Check 💕',
            //     body: `Bae is feeling ${createVibeDto.mood}`,
            // });
        }

        return savedVibe;
    }

    async getHistory(userId: string, days: number = 30): Promise<Vibe[]> {
        const since = new Date();
        since.setDate(since.getDate() - days);

        return this.vibesRepository.find({
            where: {
                userId,
                createdAt: Between(since, new Date()),
            },
            order: { createdAt: 'DESC' },
        });
    }

    async getPartnerHistory(userId: string, days: number = 30): Promise<Vibe[]> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            return [];
        }

        return this.getHistory(user.partnerId, days);
    }

    async getTodayVibe(userId: string): Promise<Vibe | null> {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);

        return this.vibesRepository.findOne({
            where: {
                userId,
                createdAt: Between(today, tomorrow),
            },
            order: { createdAt: 'DESC' },
        });
    }
}
