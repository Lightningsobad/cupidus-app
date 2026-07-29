import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GalleryItem } from './entities/gallery-item.entity';
import { CreateGalleryItemDto } from './dto/create-gallery-item.dto';

@Injectable()
export class GalleryService {
    private readonly logger = new Logger(GalleryService.name);

    constructor(
        @InjectRepository(GalleryItem)
        private galleryRepository: Repository<GalleryItem>,
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
    }

    async count(userId: string): Promise<number> {
        return this.galleryRepository.count({ where: { userId } });
    }
}
