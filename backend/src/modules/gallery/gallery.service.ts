import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GalleryItem } from './entities/gallery-item.entity';
import { CreateGalleryItemDto } from './dto/create-gallery-item.dto';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

@Injectable()
export class GalleryService {
    private readonly logger = new Logger(GalleryService.name);

    constructor(
        @InjectRepository(GalleryItem)
        private galleryRepository: Repository<GalleryItem>,
        private readonly dispatcher: CoupleNotificationDispatcher,
    ) { }

    async create(userId: string, dto: CreateGalleryItemDto): Promise<GalleryItem> {
        const item = this.galleryRepository.create({
            userId,
            filename: dto.filename,
            mimeType: dto.mimeType || 'image/jpeg',
            isEncrypted: true,
        });

        const saved = await this.galleryRepository.save(item);
        this.logger.log(`[GALLERY] User ${userId} added encrypted photo: ${dto.filename}`);

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            eventName: 'gallery:item_added',
            eventId: saved.id,
            title: 'Album kỷ niệm có ảnh mới 📸',
            body: 'Bae vừa tải ảnh mới vào kho ảnh riêng tư của 2 bạn!',
            payload: saved,
            emitToSenderToo: true,
        });

        return saved;
    }

    async findAll(userId: string, limit = 50, offset = 0): Promise<GalleryItem[]> {
        return this.galleryRepository.find({
            where: { userId },
            order: { createdAt: 'DESC' },
            take: limit,
            skip: offset,
        });
    }

    async remove(userId: string, itemId: string): Promise<void> {
        const item = await this.galleryRepository.findOne({
            where: { id: itemId, userId },
        });

        if (!item) {
            throw new NotFoundException('Gallery item not found');
        }

        await this.galleryRepository.remove(item);
        this.logger.log(`[GALLERY] User ${userId} removed photo: ${item.filename}`);

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            eventName: 'gallery:item_deleted',
            payload: { itemId },
        });
    }

    async count(userId: string): Promise<number> {
        return this.galleryRepository.count({ where: { userId } });
    }
}

