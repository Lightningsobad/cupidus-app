import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DataExport, ExportStatus } from './entities/data-export.entity';
import { User } from '../users/entities/user.entity';
import { LoveContract } from '../love-contracts/entities/love-contract.entity';
import { Message } from '../messages/entities/message.entity';
import { Expense } from '../expenses/entities/expense.entity';
import { DreamJar } from '../dream-jar/entities/dream-jar.entity';
import { Contribution } from '../dream-jar/entities/contribution.entity';
import { Vibe } from '../vibes/entities/vibe.entity';
import { TimelineEvent } from '../timeline/entities/timeline-event.entity';
import { GalleryItem } from '../gallery/entities/gallery-item.entity';
import * as fs from 'fs';
import * as path from 'path';
import archiver from 'archiver';

@Injectable()
export class DataExportService {
    private readonly logger = new Logger(DataExportService.name);

    constructor(
        @InjectRepository(DataExport)
        private exportRepository: Repository<DataExport>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
        @InjectRepository(LoveContract)
        private contractsRepository: Repository<LoveContract>,
        @InjectRepository(Message)
        private messagesRepository: Repository<Message>,
        @InjectRepository(Expense)
        private expensesRepository: Repository<Expense>,
        @InjectRepository(DreamJar)
        private dreamJarRepository: Repository<DreamJar>,
        @InjectRepository(Contribution)
        private contributionRepository: Repository<Contribution>,
        @InjectRepository(Vibe)
        private vibesRepository: Repository<Vibe>,
        @InjectRepository(TimelineEvent)
        private timelineRepository: Repository<TimelineEvent>,
        @InjectRepository(GalleryItem)
        private galleryRepository: Repository<GalleryItem>,
    ) { }

    async requestExport(userId: string): Promise<DataExport> {
        // Check for existing pending/processing export
        const existing = await this.exportRepository.findOne({
            where: [
                { userId, status: ExportStatus.PENDING },
                { userId, status: ExportStatus.PROCESSING },
            ],
        });

        if (existing) {
            throw new BadRequestException('An export is already in progress. Please wait for it to complete.');
        }

        const exportRecord = this.exportRepository.create({
            userId,
            status: ExportStatus.PENDING,
        });

        let saved: DataExport;
        try {
            saved = await this.exportRepository.save(exportRecord);
        } catch (error) {
            // Handle race condition: concurrent request may have created an export
            if (error?.code === '23505') {
                throw new BadRequestException('An export is already in progress. Please wait for it to complete.');
            }
            throw error;
        }

        this.logger.log(`[DATA EXPORT] Export requested by user ${userId} — ID: ${saved.id}`);

        // Fire-and-forget: process export in background so the HTTP response returns immediately
        this.processExport(saved.id, userId).catch(err =>
            this.logger.error(`[DATA EXPORT] Background processing failed for ${saved.id}: ${err.message}`),
        );

        return saved;
    }

    private async processExport(exportId: string, userId: string): Promise<void> {
        const record = await this.exportRepository.findOne({ where: { id: exportId } });
        if (!record) return;

        record.status = ExportStatus.PROCESSING;
        await this.exportRepository.save(record);

        try {
            // Collect all user data
            const userData = await this.collectUserData(userId);

            // Create exports directory if it doesn't exist
            const exportsDir = path.join(process.cwd(), 'exports');
            if (!fs.existsSync(exportsDir)) {
                fs.mkdirSync(exportsDir, { recursive: true });
            }

            // Write JSON data file
            const jsonPath = path.join(exportsDir, `${exportId}.json`);
            fs.writeFileSync(jsonPath, JSON.stringify(userData, null, 2));

            // Create ZIP archive
            const zipPath = path.join(exportsDir, `${exportId}.zip`);
            await this.createZipArchive(jsonPath, zipPath, exportId);

            // Clean up JSON file
            fs.unlinkSync(jsonPath);

            // Update record
            record.status = ExportStatus.COMPLETED;
            record.filePath = zipPath;
            record.completedAt = new Date();
            await this.exportRepository.save(record);

            this.logger.log(`[DATA EXPORT] Export ${exportId} completed for user ${userId}`);
        } catch (error) {
            record.status = ExportStatus.FAILED;
            record.errorMessage = error.message;
            await this.exportRepository.save(record);

            this.logger.error(`[DATA EXPORT] Export ${exportId} failed: ${error.message}`);
        }
    }

    private async collectUserData(userId: string): Promise<Record<string, any>> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });

        // Determine coupleId for couple-scoped data
        let coupleId: string | null = null;
        if (user?.partnerId) {
            coupleId = [userId, user.partnerId].sort().join(':');
        }

        const [contracts, messages, expenses, dreamJars, contributions, vibes, timeline, gallery] = await Promise.all([
            this.contractsRepository.find({ where: [{ requesterId: userId }, { partnerId: userId }] }),
            this.messagesRepository.find({ where: [{ senderId: userId }, { receiverId: userId }], order: { createdAt: 'DESC' } }),
            coupleId ? this.expensesRepository.find({ where: { coupleId } }) : [],
            coupleId ? this.dreamJarRepository.find({ where: { coupleId } }) : [],
            this.contributionRepository.find({ where: { userId } }),
            this.vibesRepository.find({ where: { userId }, order: { createdAt: 'DESC' } }),
            coupleId ? this.timelineRepository.find({ where: { coupleId } }) : [],
            this.galleryRepository.find({ where: { userId } }),
        ]);

        return {
            exportDate: new Date().toISOString(),
            dataLevels: {
                level1_deviceOnly: ['Private Gallery photos (encrypted on device, metadata only exported)'],
                level2_encrypted: ['Messages (E2E encrypted)'],
                level3_backend: ['Profile', 'Contracts', 'Expenses', 'Dream Jars', 'Vibes', 'Timeline'],
            },
            profile: user ? {
                id: user.id,
                email: user.email,
                displayName: user.displayName,
                birthday: user.birthday,
                zodiacSign: user.zodiacSign,
                language: user.language,
                coupleType: user.coupleType,
                createdAt: user.createdAt,
            } : null,
            loveContracts: contracts,
            messages: messages.map(m => ({
                id: m.id,
                senderId: m.senderId,
                receiverId: m.receiverId,
                content: m.content,
                status: m.status,
                createdAt: m.createdAt,
            })),
            expenses,
            dreamJars,
            contributions,
            vibes,
            timeline,
            galleryMetadata: gallery.map(g => ({
                id: g.id,
                createdAt: g.createdAt,
                note: 'Photo data stored on device only (Level 1)',
            })),
        };
    }

    private createZipArchive(jsonPath: string, zipPath: string, exportId: string): Promise<void> {
        return new Promise((resolve, reject) => {
            const output = fs.createWriteStream(zipPath);
            const archive = archiver('zip', { zlib: { level: 9 } });

            output.on('close', resolve);
            archive.on('error', reject);

            archive.pipe(output);
            archive.file(jsonPath, { name: `cupid-data-export-${exportId}.json` });
            archive.finalize();
        });
    }

    async getExports(userId: string): Promise<DataExport[]> {
        return this.exportRepository.find({
            where: { userId },
            order: { createdAt: 'DESC' },
            take: 10,
        });
    }

    async getExportFile(userId: string, exportId: string): Promise<string> {
        const record = await this.exportRepository.findOne({
            where: { id: exportId, userId },
        });

        if (!record) {
            throw new NotFoundException('Export not found');
        }

        if (record.status !== ExportStatus.COMPLETED) {
            throw new BadRequestException(`Export is not ready. Status: ${record.status}`);
        }

        if (!record.filePath || !fs.existsSync(record.filePath)) {
            throw new NotFoundException('Export file not found on disk');
        }

        // Schedule cleanup: delete the file after 1 hour to prevent disk space leak
        const cleanupTimer = setTimeout(() => {
            try {
                if (fs.existsSync(record.filePath)) {
                    fs.unlinkSync(record.filePath);
                    this.logger.log(`[DATA EXPORT] Cleaned up file: ${record.filePath}`);
                }
            } catch (err) {
                this.logger.warn(`[DATA EXPORT] Cleanup failed for ${record.filePath}: ${err.message}`);
            }
        }, 60 * 60 * 1000);
        cleanupTimer.unref();

        return record.filePath;
    }
}
