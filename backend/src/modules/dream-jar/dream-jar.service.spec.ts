import { Test, TestingModule } from '@nestjs/testing';
import { DreamJarService } from './dream-jar.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DreamJar, DreamJarStatus } from './entities/dream-jar.entity';
import { Contribution } from './entities/contribution.entity';
import { User } from '../users/entities/user.entity';
import { DataSource } from 'typeorm';
import { NotFoundException, BadRequestException } from '@nestjs/common';

import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

describe('DreamJarService', () => {
    let service: DreamJarService;
    let jarRepoMock: any;
    let contribRepoMock: any;
    let userRepoMock: any;
    let dataSourceMock: any;
    let queryRunnerMock: any;
    let dispatcherMock: any;

    const userA = 'user-aaa';
    const userB = 'user-bbb';
    const coupleId = [userA, userB].sort().join(':');
    const mockUser = { id: userA, partnerId: userB } as Partial<User> as User;
    const mockUserNoPartner = { id: userA, partnerId: undefined } as Partial<User> as User;

    const createDto = { name: 'Bali Trip', targetAmount: 50000000 };

    beforeEach(async () => {
        queryRunnerMock = {
            connect: jest.fn(),
            startTransaction: jest.fn(),
            commitTransaction: jest.fn(),
            rollbackTransaction: jest.fn(),
            release: jest.fn(),
            manager: {
                create: jest.fn((entity, dto) => dto),
                save: jest.fn((entity) => Promise.resolve({ id: 'new-id', ...entity })),
                findOne: jest.fn(),
            },
        };

        jarRepoMock = {
            create: jest.fn((dto) => dto),
            save: jest.fn((entity) => Promise.resolve({ id: 'jar-1', ...entity })),
            find: jest.fn(),
            findOne: jest.fn(),
            remove: jest.fn(),
        };

        contribRepoMock = {
            create: jest.fn((dto) => dto),
            save: jest.fn((entity) => Promise.resolve({ id: 'contrib-1', ...entity })),
            find: jest.fn(),
            count: jest.fn(),
        };

        userRepoMock = {
            findOne: jest.fn(),
        };

        dataSourceMock = {
            createQueryRunner: jest.fn().mockReturnValue(queryRunnerMock),
        };

        dispatcherMock = {
            dispatchToPartner: jest.fn().mockResolvedValue(undefined),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                DreamJarService,
                { provide: getRepositoryToken(DreamJar), useValue: jarRepoMock },
                { provide: getRepositoryToken(Contribution), useValue: contribRepoMock },
                { provide: getRepositoryToken(User), useValue: userRepoMock },
                { provide: DataSource, useValue: dataSourceMock },
                { provide: CoupleNotificationDispatcher, useValue: dispatcherMock },
            ],
        }).compile();

        service = module.get<DreamJarService>(DreamJarService);
    });


    describe('create', () => {
        it('should create a dream jar for the couple with PENDING status', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);

            const result = await service.create(userA, createDto);

            expect(result.name).toBe('Bali Trip');
            expect(result.targetAmount).toBe(50000000);
            expect(result.currentAmount).toBe(0);
            expect(result.coupleId).toBe(coupleId);
            expect(result.createdById).toBe(userA);
            expect(result.status).toBe(DreamJarStatus.PENDING);
            expect(jarRepoMock.save).toHaveBeenCalled();
        });

        it('should throw NotFoundException if user has no partner', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserNoPartner);

            await expect(service.create(userA, createDto)).rejects.toThrow(NotFoundException);
        });
    });

    describe('approve', () => {
        it('should allow partner to approve a pending jar', async () => {
            const pendingJar = {
                id: 'jar-1',
                name: 'Bali Trip',
                coupleId,
                createdById: userA,
                status: DreamJarStatus.PENDING,
            };
            const mockPartner = { id: userB, partnerId: userA } as Partial<User> as User;
            userRepoMock.findOne.mockResolvedValue(mockPartner);
            jarRepoMock.findOne.mockResolvedValue({ ...pendingJar });

            const result = await service.approve(userB, 'jar-1');

            expect(result.status).toBe(DreamJarStatus.ACTIVE);
            expect(jarRepoMock.save).toHaveBeenCalledWith(expect.objectContaining({ status: DreamJarStatus.ACTIVE }));
        });

        it('should throw BadRequestException if creator attempts to self-approve', async () => {
            const pendingJar = {
                id: 'jar-1',
                name: 'Bali Trip',
                coupleId,
                createdById: userA,
                status: DreamJarStatus.PENDING,
            };
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue({ ...pendingJar });

            await expect(service.approve(userA, 'jar-1')).rejects.toThrow(BadRequestException);
        });

        it('should throw BadRequestException if jar is not pending', async () => {
            const activeJar = {
                id: 'jar-1',
                name: 'Bali Trip',
                coupleId,
                createdById: userA,
                status: DreamJarStatus.ACTIVE,
            };
            const mockPartner = { id: userB, partnerId: userA } as Partial<User> as User;
            userRepoMock.findOne.mockResolvedValue(mockPartner);
            jarRepoMock.findOne.mockResolvedValue({ ...activeJar });

            await expect(service.approve(userB, 'jar-1')).rejects.toThrow(BadRequestException);
        });
    });

    describe('reject', () => {
        it('should allow partner to reject a pending jar', async () => {
            const pendingJar = {
                id: 'jar-1',
                name: 'Bali Trip',
                coupleId,
                createdById: userA,
                status: DreamJarStatus.PENDING,
            };
            const mockPartner = { id: userB, partnerId: userA } as Partial<User> as User;
            userRepoMock.findOne.mockResolvedValue(mockPartner);
            jarRepoMock.findOne.mockResolvedValue({ ...pendingJar });

            const result = await service.reject(userB, 'jar-1');

            expect(result.status).toBe(DreamJarStatus.REJECTED);
            expect(jarRepoMock.save).toHaveBeenCalledWith(expect.objectContaining({ status: DreamJarStatus.REJECTED }));
        });

        it('should throw BadRequestException if creator attempts to self-reject', async () => {
            const pendingJar = {
                id: 'jar-1',
                name: 'Bali Trip',
                coupleId,
                createdById: userA,
                status: DreamJarStatus.PENDING,
            };
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue({ ...pendingJar });

            await expect(service.reject(userA, 'jar-1')).rejects.toThrow(BadRequestException);
        });
    });

    describe('findAll', () => {
        it('should return jars for the couple with pagination', async () => {
            const jars = [{ id: 'jar-1', name: 'Bali Trip', coupleId }];
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.find.mockResolvedValue(jars);

            const result = await service.findAll(userA, 10, 0);

            expect(result).toEqual(jars);
            expect(jarRepoMock.find).toHaveBeenCalledWith({
                where: { coupleId },
                order: { createdAt: 'DESC' },
                take: 10,
                skip: 0,
            });
        });
    });

    describe('findOne', () => {
        it('should return a single jar', async () => {
            const jar = { id: 'jar-1', name: 'Bali Trip', coupleId };
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue(jar);

            const result = await service.findOne(userA, 'jar-1');
            expect(result.name).toBe('Bali Trip');
        });

        it('should throw NotFoundException if jar does not exist', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue(null);

            await expect(service.findOne(userA, 'jar-999')).rejects.toThrow(NotFoundException);
        });
    });

    describe('update', () => {
        it('should update jar name', async () => {
            const jar = { id: 'jar-1', name: 'Bali Trip', coupleId, targetAmount: 50000000 };
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue(jar);

            await service.update(userA, 'jar-1', { name: 'Tokyo Trip' });

            expect(jarRepoMock.save).toHaveBeenCalledWith(expect.objectContaining({ name: 'Tokyo Trip' }));
        });

        it('should update jar status to archived', async () => {
            const jar = { id: 'jar-1', name: 'Trip', coupleId, status: DreamJarStatus.ACTIVE };
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue(jar);

            await service.update(userA, 'jar-1', { status: DreamJarStatus.ARCHIVED });

            expect(jarRepoMock.save).toHaveBeenCalledWith(expect.objectContaining({ status: DreamJarStatus.ARCHIVED }));
        });
    });

    describe('remove', () => {
        it('should delete jar with 0 contributions', async () => {
            const jar = { id: 'jar-1', name: 'Bali Trip', coupleId };
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue(jar);
            contribRepoMock.count.mockResolvedValue(0);

            await service.remove(userA, 'jar-1');

            expect(jarRepoMock.remove).toHaveBeenCalledWith(jar);
        });

        it('should throw BadRequestException if jar has contributions', async () => {
            const jar = { id: 'jar-1', name: 'Bali Trip', coupleId };
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue(jar);
            contribRepoMock.count.mockResolvedValue(3);

            await expect(service.remove(userA, 'jar-1')).rejects.toThrow(BadRequestException);
        });
    });

    describe('addContribution', () => {
        const activeJar = { id: 'jar-1', name: 'Bali Trip', coupleId, currentAmount: 10000000, targetAmount: 50000000, currency: 'VND', status: DreamJarStatus.ACTIVE };

        it('should add contribution within a transaction with pessimistic lock', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue({ ...activeJar });
            const lockedJar = { ...activeJar };
            queryRunnerMock.manager.findOne.mockResolvedValue(lockedJar);

            await service.addContribution(userA, 'jar-1', { amount: 5000000, note: 'Monthly save' });

            // Verify pessimistic lock was used
            expect(queryRunnerMock.manager.findOne).toHaveBeenCalledWith(
                expect.anything(),
                expect.objectContaining({ lock: { mode: 'pessimistic_write' } }),
            );
            // Verify transaction lifecycle
            expect(queryRunnerMock.connect).toHaveBeenCalled();
            expect(queryRunnerMock.startTransaction).toHaveBeenCalled();
            expect(queryRunnerMock.commitTransaction).toHaveBeenCalled();
            expect(queryRunnerMock.release).toHaveBeenCalled();
            // Verify jar amount was updated
            expect(lockedJar.currentAmount).toBe(15000000);
            expect(queryRunnerMock.manager.save).toHaveBeenCalledTimes(2);
        });

        it('should throw BadRequestException when contribution exceeds target', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue({ ...activeJar, currentAmount: 45000000 });
            queryRunnerMock.manager.findOne.mockResolvedValue({ ...activeJar, currentAmount: 45000000 });

            await expect(
                service.addContribution(userA, 'jar-1', { amount: 10000000 }),
            ).rejects.toThrow(BadRequestException);
        });

        it('should reject contributions to COMPLETED jars', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue({ ...activeJar });
            queryRunnerMock.manager.findOne.mockResolvedValue({ ...activeJar, status: DreamJarStatus.COMPLETED });

            await expect(
                service.addContribution(userA, 'jar-1', { amount: 5000000 }),
            ).rejects.toThrow(BadRequestException);
        });

        it('should auto-transition to COMPLETED when target is reached', async () => {
            const jar = { ...activeJar, currentAmount: 45000000 };
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue({ ...jar });
            queryRunnerMock.manager.findOne.mockResolvedValue(jar);

            await service.addContribution(userA, 'jar-1', { amount: 5000000 });

            expect(jar.status).toBe(DreamJarStatus.COMPLETED);
            expect(jar.currentAmount).toBe(50000000);
        });

        it('should rollback transaction on failure', async () => {
            const jar = { ...activeJar, currentAmount: 0 };
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue({ ...jar });
            queryRunnerMock.manager.findOne.mockResolvedValue(jar);
            queryRunnerMock.manager.save.mockRejectedValueOnce(new Error('DB error'));

            await expect(
                service.addContribution(userA, 'jar-1', { amount: 5000000 }),
            ).rejects.toThrow('DB error');

            expect(queryRunnerMock.rollbackTransaction).toHaveBeenCalled();
            expect(queryRunnerMock.release).toHaveBeenCalled();
        });
    });

    describe('getContributions', () => {
        it('should return contributions for a jar with pagination', async () => {
            const contribs = [{ id: 'c-1', amount: 5000000, dreamJarId: 'jar-1' }];
            userRepoMock.findOne.mockResolvedValue(mockUser);
            jarRepoMock.findOne.mockResolvedValue({ id: 'jar-1', coupleId });
            contribRepoMock.find.mockResolvedValue(contribs);

            const result = await service.getContributions(userA, 'jar-1');

            expect(result).toEqual(contribs);
            expect(contribRepoMock.find).toHaveBeenCalledWith({
                where: { dreamJarId: 'jar-1' },
                order: { createdAt: 'DESC' },
                take: 50,
                skip: 0,
            });
        });
    });
});
