import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Not, IsNull } from 'typeorm';
import { AdminConfig } from './entities/admin-config.entity';
import { User } from '../users/entities/user.entity';
import { DataExport } from '../data-export/entities/data-export.entity';
import { UpdateConfigDto } from './dto/admin.dto';

@Injectable()
export class AdminService {
    private readonly logger = new Logger(AdminService.name);

    constructor(
        @InjectRepository(AdminConfig)
        private configRepository: Repository<AdminConfig>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
        @InjectRepository(DataExport)
        private exportRepository: Repository<DataExport>,
    ) { }

    async getAllConfigs(): Promise<AdminConfig[]> {
        return this.configRepository.find({
            order: { key: 'ASC' },
        });
    }

    async getConfig(key: string): Promise<AdminConfig> {
        const config = await this.configRepository.findOne({ where: { key } });
        if (!config) {
            throw new NotFoundException(`Config key "${key}" not found`);
        }
        return config;
    }

    async updateConfig(adminId: string, key: string, dto: UpdateConfigDto): Promise<AdminConfig> {
        let config = await this.configRepository.findOne({ where: { key } });

        if (!config) {
            // Create new config if it doesn't exist
            config = this.configRepository.create({
                key,
                value: dto.value,
                description: dto.description,
                updatedBy: adminId,
            });
        } else {
            config.value = dto.value;
            if (dto.description !== undefined) {
                config.description = dto.description;
            }
            config.updatedBy = adminId;
        }

        const saved = await this.configRepository.save(config);
        this.logger.log(`[ADMIN CONFIG] Key "${key}" updated by admin ${adminId}`);
        return saved;
    }

    async getMetrics(): Promise<{
        totalUsers: number;
        totalCouples: number;
        activeToday: number;
        totalExports: number;
    }> {
        const totalUsers = await this.usersRepository.count();

        // Count users with a partnerId (each pair counted once)
        const pairedUsers = await this.usersRepository.count({
            where: { partnerId: Not(IsNull()) },
        });
        const totalCouples = Math.floor(pairedUsers / 2);

        // DAU proxy: users updated within last 24 hours
        const oneDayAgo = new Date();
        oneDayAgo.setDate(oneDayAgo.getDate() - 1);
        const activeToday = await this.usersRepository
            .createQueryBuilder('user')
            .where('user.updatedAt >= :oneDayAgo', { oneDayAgo })
            .getCount();

        const totalExports = await this.exportRepository.count();

        return {
            totalUsers,
            totalCouples,
            activeToday,
            totalExports,
        };
    }

    async seedDefaults(): Promise<void> {
        const defaults = [
            { key: 'emojiStormEnabled', value: true, description: 'Global toggle for Emoji Storm feature' },
            { key: 'maxPushPerDay', value: 50, description: 'Maximum push notifications per user per day' },
            { key: 'featureToggles', value: { typingGhost: true, dreamJar: true, vibeCheck: true, gallery: true }, description: 'Feature-level toggles for the entire platform' },
        ];

        for (const def of defaults) {
            const existing = await this.configRepository.findOne({ where: { key: def.key } });
            if (!existing) {
                await this.configRepository.save(this.configRepository.create(def));
                this.logger.log(`[ADMIN CONFIG] Seeded default: ${def.key}`);
            }
        }
    }
}
