import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { DreamJar, DreamJarStatus } from './entities/dream-jar.entity';
import { Contribution } from './entities/contribution.entity';
import { User } from '../users/entities/user.entity';
import { CreateDreamJarDto, UpdateDreamJarDto, AddContributionDto } from './dto/dream-jar.dto';
import { getCoupleId } from '../../common/utils/couple.util';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

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
        private readonly dispatcher: CoupleNotificationDispatcher,
    ) { }

    private async getUserAndCoupleId(userId: string): Promise<{ user: User; coupleId: string }> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            throw new NotFoundException('User not found or not paired');
        }
        return { user, coupleId: getCoupleId(userId, user.partnerId) };
    }

    async create(userId: string, dto: CreateDreamJarDto): Promise<DreamJar> {
        const { user, coupleId } = await this.getUserAndCoupleId(userId);

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

        // Dispatch Realtime Socket + Push Notification to partner
        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: user.partnerId,
            eventName: 'dream_jar:created',
            eventId: saved.id,
            title: 'Hũ ước mơ mới! 🐷',
            body: `${user.displayName || 'Bae'} vừa tạo hũ "${dto.name}". Hãy vào xem và duyệt nhé!`,
            payload: saved,
        });

        return saved;
    }

    async approve(userId: string, jarId: string): Promise<DreamJar> {
        const { user } = await this.getUserAndCoupleId(userId);
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

        // Dispatch notification
        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: user.partnerId,
            eventName: 'dream_jar:status_changed',
            eventId: saved.id,
            title: 'Hũ ước mơ đã được duyệt! 🎉',
            body: `${user.displayName || 'Bae'} đã duyệt hũ "${jar.name}". Cùng nhau tiết kiệm nhé!`,
            payload: { jarId: saved.id, status: DreamJarStatus.ACTIVE, name: saved.name },
            emitToSenderToo: true,
        });

        return saved;
    }

    async reject(userId: string, jarId: string): Promise<DreamJar> {
        const { user } = await this.getUserAndCoupleId(userId);
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

        // Dispatch notification
        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: user.partnerId,
            eventName: 'dream_jar:status_changed',
            eventId: saved.id,
            title: 'Hũ ước mơ bị từ chối',
            body: `${user.displayName || 'Bae'} chưa đồng ý tạo hũ "${jar.name}".`,
            payload: { jarId: saved.id, status: DreamJarStatus.REJECTED, name: saved.name },
        });

        return saved;
    }

    async findAll(userId: string, limit = 50, offset = 0): Promise<DreamJar[]> {
        const { coupleId } = await this.getUserAndCoupleId(userId);

        const jars = await this.dreamJarRepository.find({
            where: { coupleId },
            order: { createdAt: 'DESC' },
            take: limit,
            skip: offset,
        });
        return jars;
    }

    async findOne(userId: string, jarId: string): Promise<DreamJar> {
        const { coupleId } = await this.getUserAndCoupleId(userId);
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
        const { user } = await this.getUserAndCoupleId(userId);
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

        await this.dispatcher.dispatchToPartner({
            senderId: userId,
            partnerId: user.partnerId,
            eventName: 'dream_jar:deleted',
            payload: { jarId },
        });
    }

    // --- Contributions ---

    async addContribution(userId: string, jarId: string, dto: AddContributionDto): Promise<Contribution> {
        const { user } = await this.getUserAndCoupleId(userId);
        await this.findOne(userId, jarId);

        const queryRunner = this.dataSource.createQueryRunner();
        await queryRunner.connect();
        await queryRunner.startTransaction();

        try {
            const jar = await queryRunner.manager.findOne(DreamJar, {
                where: { id: jarId },
                lock: { mode: 'pessimistic_write' },
            });

            if (!jar) {
                throw new NotFoundException('Dream Jar not found');
            }

            if (jar.status !== DreamJarStatus.ACTIVE) {
                throw new BadRequestException(
                    jar.status === DreamJarStatus.PENDING
                        ? 'Cannot contribute to a pending Dream Jar. Your partner must approve it first.'
                        : `Cannot contribute to a ${jar.status} Dream Jar.`,
                );
            }

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

            jar.currentAmount = newAmount;
            const isCompleted = newAmount >= Number(jar.targetAmount);

            if (isCompleted) {
                jar.status = DreamJarStatus.COMPLETED;
                this.logger.log(`[DREAM JAR] "${jar.name}" reached its target! 🎉`);
            }

            await queryRunner.manager.save(jar);
            const savedContribution = await queryRunner.manager.save(contribution);
            await queryRunner.commitTransaction();

            this.logger.log(`[CONTRIBUTION] User ${userId} added ${dto.amount} to "${jar.name}" — now at ${jar.currentAmount}/${jar.targetAmount}`);

            // Dispatch Realtime Socket + Push Notification for contribution (only to partner)
            await this.dispatcher.dispatchToPartner({
                senderId: userId,
                partnerId: user.partnerId,
                eventName: 'dream_jar:contributed',
                eventId: savedContribution.id,
                title: 'Vừa có tiền vào hũ! 💰',
                body: `${user.displayName || 'Bae'} vừa bỏ thêm ${dto.amount.toLocaleString()} ${jar.currency} vào "${jar.name}".`,
                payload: {
                    jarId: jar.id,
                    name: jar.name,
                    amount: dto.amount,
                    currentAmount: jar.currentAmount,
                    targetAmount: jar.targetAmount,
                    currency: jar.currency,
                    contributorId: userId,
                },
            });

            // If target reached, dispatch celebration event to both
            if (isCompleted) {
                await this.dispatcher.dispatchToPartner({
                    senderId: userId,
                    partnerId: user.partnerId,
                    eventName: 'dream_jar:completed',
                    eventId: jar.id,
                    title: 'Hũ ước mơ đã về đích! 🏆🎉',
                    body: `Chúc mừng 2 bạn! Hũ "${jar.name}" đã chính thức đạt 100% mục tiêu!`,
                    payload: {
                        jarId: jar.id,
                        name: jar.name,
                        targetAmount: jar.targetAmount,
                        currency: jar.currency,
                    },
                    emitToSenderToo: true,
                });
            }

            return savedContribution;
        } catch (error) {
            await queryRunner.rollbackTransaction();
            throw error;
        } finally {
            await queryRunner.release();
        }
    }

    async removeContribution(userId: string, jarId: string, contributionId: string): Promise<DreamJar> {
        const { user } = await this.getUserAndCoupleId(userId);
        const queryRunner = this.dataSource.createQueryRunner();
        await queryRunner.connect();
        await queryRunner.startTransaction();

        try {
            const jar = await queryRunner.manager.findOne(DreamJar, {
                where: { id: jarId },
                lock: { mode: 'pessimistic_write' },
            });

            if (!jar) {
                throw new NotFoundException('Dream Jar not found');
            }

            const contribution = await queryRunner.manager.findOne(Contribution, {
                where: { id: contributionId, dreamJarId: jarId },
            });

            if (!contribution) {
                throw new NotFoundException('Contribution not found');
            }

            if (contribution.userId !== userId) {
                throw new BadRequestException('You can only undo your own contributions.');
            }

            const newAmount = Math.max(0, Number(jar.currentAmount) - Number(contribution.amount));
            jar.currentAmount = newAmount;

            if (jar.status === DreamJarStatus.COMPLETED && newAmount < Number(jar.targetAmount)) {
                jar.status = DreamJarStatus.ACTIVE;
            }

            await queryRunner.manager.remove(Contribution, contribution);
            const savedJar = await queryRunner.manager.save(jar);
            await queryRunner.commitTransaction();

            this.logger.log(`[CONTRIBUTION] User ${userId} removed contribution ${contributionId} (${contribution.amount}) from "${jar.name}"`);

            await this.dispatcher.dispatchToPartner({
                senderId: userId,
                partnerId: user.partnerId,
                eventName: 'dream_jar:status_changed',
                payload: {
                    jarId: jar.id,
                    name: jar.name,
                    currentAmount: jar.currentAmount,
                    targetAmount: jar.targetAmount,
                    currency: jar.currency,
                },
            });

            return savedJar;
        } catch (error) {
            await queryRunner.rollbackTransaction();
            throw error;
        } finally {
            await queryRunner.release();
        }
    }

    async getContributions(userId: string, jarId: string, limit = 50, offset = 0): Promise<Contribution[]> {
        await this.findOne(userId, jarId);

        return this.contributionRepository.find({
            where: { dreamJarId: jarId },
            order: { createdAt: 'DESC' },
            take: limit,
            skip: offset,
        });
    }
}

