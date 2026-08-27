import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { OnEvent } from '@nestjs/event-emitter';
import { TimelineEvent, TimelineEventType } from './entities/timeline-event.entity';
import { User } from '../users/entities/user.entity';
import { CreateTimelineEventDto } from './dto/create-timeline-event.dto';
import { getCoupleId } from '../../common/utils/couple.util';
import { PetMilestoneReachedEvent } from '../../common/events/pet-milestone.event';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

@Injectable()
export class TimelineService {
    private readonly logger = new Logger(TimelineService.name);

    constructor(
        @InjectRepository(TimelineEvent)
        private timelineRepository: Repository<TimelineEvent>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
        private readonly dispatcher: CoupleNotificationDispatcher,
    ) { }

    async addEvent(userId: string, dto: CreateTimelineEventDto): Promise<TimelineEvent> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            throw new NotFoundException('User not found or not paired');
        }

        const coupleId = getCoupleId(userId, user.partnerId);

        const event = this.timelineRepository.create({
            coupleId,
            type: dto.type || TimelineEventType.MEMORY,
            title: dto.title,
            description: dto.description,
            photoUrl: dto.photoUrl,
            icon: dto.icon || '💝',
        });

        if (dto.date) {
            event.createdAt = new Date(dto.date);
        }

        const saved = await this.timelineRepository.save(event);
        this.logger.log(`[TIMELINE] Couple ${coupleId} added event: "${dto.title}"`);

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: user.partnerId,
            eventName: 'timeline:event_added',
            eventId: saved.id,
            title: 'Kỷ niệm tình yêu mới 💕',
            body: `${user.displayName || 'Bae'} vừa lưu lại một kỷ niệm: "${dto.title}"`,
            payload: saved,
        });

        return saved;
    }


    async getTimeline(userId: string, limit = 50, offset = 0): Promise<TimelineEvent[]> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            return [];
        }

        const coupleId = getCoupleId(userId, user.partnerId);
        return this.timelineRepository.find({
            where: { coupleId },
            order: { createdAt: 'DESC' },
            take: limit,
            skip: offset,
        });
    }

    async addMilestone(coupleId: string, title: string, icon: string = '🏆'): Promise<TimelineEvent> {
        const event = this.timelineRepository.create({
            coupleId,
            type: TimelineEventType.MILESTONE,
            title,
            icon,
        });

        return this.timelineRepository.save(event);
    }

    /**
     * H2 fix: Auto-generate timeline milestones when pet interaction thresholds are reached.
     */
    @OnEvent('pet.milestone.reached')
    async handlePetMilestone(event: PetMilestoneReachedEvent): Promise<void> {
        const milestoneLabels: Record<number, string> = {
            50: '50 interactions! 🐾',
            100: '100 interactions! 💕',
            500: '500 interactions! 🌟',
            1000: '1000 interactions! 👑',
        };
        const title = `${event.petName} reached ${milestoneLabels[event.milestone] || event.milestone + ' interactions!'}`;
        await this.addMilestone(event.coupleId, title, '🏆');
        this.logger.log(`[AUTO-MILESTONE] ${title} for couple ${event.coupleId}`);
    }

    async deleteEvent(userId: string, eventId: string): Promise<void> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            throw new NotFoundException('User not found or not paired');
        }

        const coupleId = getCoupleId(userId, user.partnerId);
        const event = await this.timelineRepository.findOne({
            where: { id: eventId, coupleId },
        });

        if (!event) {
            throw new NotFoundException('Timeline event not found');
        }

        // Don't allow deleting milestone events
        if (event.type === TimelineEventType.MILESTONE) {
            throw new BadRequestException('Cannot delete milestone events');
        }

        await this.timelineRepository.remove(event);
    }
}
