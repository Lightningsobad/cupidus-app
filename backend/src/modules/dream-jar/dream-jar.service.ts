import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { DreamJar, DreamJarStatus } from './entities/dream-jar.entity';
import { Contribution } from './entities/contribution.entity';
import { User } from '../users/entities/user.entity';
import { CreateDreamJarDto, UpdateDreamJarDto, AddContributionDto } from './dto/dream-jar.dto';
import { getCoupleId } from '../../common/utils/couple.util';

@Injectable()
export class DreamJarService {
    private readonly logger = new Logger(DreamJarService.name);

    constructor(
        @InjectRepository(DreamJar)
        private dreamJarRepository: Repository<DreamJar>,
        @InjectRepository(Contribution)
        private contributionRepository: Repository<Contribution>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
        private dataSource: DataSource,
    ) { }

    private async getCoupleIdForUser(userId: string): Promise<string> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            throw new NotFoundException('User not found or not paired');
        }
        return getCoupleId(userId, user.partnerId);
    }

    async create(userId: string, dto: CreateDreamJarDto): Promise<DreamJar> {
        const coupleId = await this.getCoupleIdForUser(userId);

        const jar = this.dreamJarRepository.create({
            coupleId,
            createdById: userId,
            name: dto.name,
            targetAmount: dto.targetAmount,
            currentAmount: 0,
            deadline: dto.deadline ? new Date(dto.deadline) : undefined,
            currency: dto.currency || 'VND',
            status: DreamJarStatus.PENDING,
        });

        const saved = await this.dreamJarRepository.save(jar);
        this.logger.log(`[DREAM JAR] Created "${dto.name}" for couple ${coupleId} by user ${userId} — Status: PENDING`);
        return saved;
    }

    async approve(userId: string, jarId: string): Promise<DreamJar> {
        const jar = await this.findOne(userId, jarId);

        if (jar.createdById && jar.createdById === userId) {
            throw new BadRequestException('You cannot approve your own Dream Jar. Your partner must approve it.');
        }

        if (jar.status !== DreamJarStatus.PENDING) {
            throw new BadRequestException(`Dream Jar is not pending approval (current status: ${jar.status}).`);
        }

        jar.status = DreamJarStatus.ACTIVE;
        const saved = await this.dreamJarRepository.save(jar);
        this.logger.log(`[DREAM JAR] "${jar.name}" approved by user ${userId} — Status: ACTIVE`);
        return saved;
    }

    async reject(userId: string, jarId: string): Promise<DreamJar> {
        const jar = await this.findOne(userId, jarId);

        if (jar.createdById && jar.createdById === userId) {
            throw new BadRequestException('You cannot reject your own Dream Jar. Delete it instead.');
        }

        if (jar.status !== DreamJarStatus.PENDING) {
            throw new BadRequestException(`Dream Jar is not pending approval (current status: ${jar.status}).`);
        }

        jar.status = DreamJarStatus.REJECTED;
        const saved = await this.dreamJarRepository.save(jar);
        this.logger.log(`[DREAM JAR] "${jar.name}" rejected by user ${userId} — Status: REJECTED`);
        return saved;
    }

    async findAll(userId: string, limit = 50, offset = 0): Promise<DreamJar[]> {
        const coupleId = await this.getCoupleIdForUser(userId);

        const jars = await this.dreamJarRepository.find({
            where: { coupleId },
            order: { createdAt: 'DESC' },
            take: limit,
            skip: offset,
        });
        return jars;
    }

    async findOne(userId: string, jarId: string): Promise<DreamJar> {
        const coupleId = await this.getCoupleIdForUser(userId);
        const jar = await this.dreamJarRepository.findOne({
            where: { id: jarId, coupleId },
        });
        if (!jar) {
            throw new NotFoundException('Dream Jar not found');
        }
        return jar;
    }

    async update(userId: string, jarId: string, dto: UpdateDreamJarDto): Promise<DreamJar> {
        const jar = await this.findOne(userId, jarId);

        if (dto.name !== undefined) jar.name = dto.name;
        if (dto.targetAmount !== undefined) jar.targetAmount = dto.targetAmount;
        if (dto.deadline !== undefined) jar.deadline = new Date(dto.deadline);
        if (dto.status !== undefined) jar.status = dto.status;

        return this.dreamJarRepository.save(jar);
    }

    async remove(userId: string, jarId: string): Promise<void> {
        const jar = await this.findOne(userId, jarId);

        // Check for contributions
        const contributionCount = await this.contributionRepository.count({
            where: { dreamJarId: jarId },
        });

        if (contributionCount > 0) {
            throw new BadRequestException(
                `Cannot delete Dream Jar "${jar.name}" — it has ${contributionCount} contribution(s). Archive it instead.`,
            );
        }

        await this.dreamJarRepository.remove(jar);
        this.logger.log(`[DREAM JAR] Deleted "${jar.name}"`);
    }

    // --- Contributions ---

    async addContribution(userId: string, jarId: string, dto: AddContributionDto): Promise<Contribution> {
        // Verify user has access (couple scoping)
        await this.findOne(userId, jarId);

        // M5: All reads and writes inside transaction with pessimistic lock to prevent TOCTOU
        const queryRunner = this.dataSource.createQueryRunner();
        await queryRunner.connect();
        await queryRunner.startTransaction();

        try {
            // Re-read jar inside transaction with lock to prevent concurrent modifications
            const jar = await queryRunner.manager.findOne(DreamJar, {
                where: { id: jarId },
                lock: { mode: 'pessimistic_write' },
            });

            if (!jar) {
                throw new NotFoundException('Dream Jar not found');
            }

            // M6: Guard against contributing to non-active jars
            if (jar.status !== DreamJarStatus.ACTIVE) {
                throw new BadRequestException(
                    jar.status === DreamJarStatus.PENDING
                        ? 'Cannot contribute to a pending Dream Jar. Your partner must approve it first.'
                        : `Cannot contribute to a ${jar.status} Dream Jar.`,
                );
            }

            // H2: Overflow check — now inside transaction with locked row
            const newAmount = Number(jar.currentAmount) + dto.amount;
            if (newAmount > Number(jar.targetAmount)) {
                const remaining = Number(jar.targetAmount) - Number(jar.currentAmount);
                throw new BadRequestException(
                    `Contribution exceeds target. Maximum allowed: ${remaining} ${jar.currency}`,
                );
            }

            const contribution = queryRunner.manager.create(Contribution, {
                dreamJarId: jarId,
                userId,
                amount: dto.amount,
                note: dto.note,
            });

            // Atomic update of current amount
            jar.currentAmount = newAmount;

            // H3: Auto-transition to COMPLETED when target is reached
            if (newAmount >= Number(jar.targetAmount)) {
                jar.status = DreamJarStatus.COMPLETED;
                this.logger.log(`[DREAM JAR] "${jar.name}" reached its target! 🎉`);
            }

            await queryRunner.manager.save(jar);
            const saved = await queryRunner.manager.save(contribution);
            await queryRunner.commitTransaction();

            this.logger.log(`[CONTRIBUTION] User ${userId} added ${dto.amount} to "${jar.name}" — now at ${jar.currentAmount}/${jar.targetAmount}`);
            return saved;
        } catch (error) {
            await queryRunner.rollbackTransaction();
            throw error;
        } finally {
            await queryRunner.release();
        }
    }

    async getContributions(userId: string, jarId: string, limit = 50, offset = 0): Promise<Contribution[]> {
        // Verify access
        await this.findOne(userId, jarId);

        return this.contributionRepository.find({
            where: { dreamJarId: jarId },
            order: { createdAt: 'DESC' },
            take: limit,
            skip: offset,
        });
    }
}
