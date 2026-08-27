import { Test, TestingModule } from '@nestjs/testing';
import { PetsService } from './pets.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { Pet, PetSpecies } from './entities/pet.entity';
import { User } from '../users/entities/user.entity';
import { NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';

import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

describe('PetsService', () => {
    let service: PetsService;
    let petRepoMock: any;
    let userRepoMock: any;
    let dataSourceMock: any;
    let queryRunnerMock: any;
    let eventEmitterMock: any;
    let dispatcherMock: any;

    const userA = 'user-aaa';
    const userB = 'user-bbb';
    const coupleId = [userA, userB].sort().join(':');
    const oldDate = new Date(Date.now() - 48 * 60 * 60 * 1000); // 48 hours ago
    const recentDate = new Date(Date.now() - 2 * 60 * 60 * 1000); // 2 hours ago
    const mockUserA = { id: userA, partnerId: userB, createdAt: oldDate } as Partial<User> as User;
    const mockUserRecent = { id: userA, partnerId: userB, createdAt: recentDate } as Partial<User> as User;
    const mockUserNoPartner = { id: userA, partnerId: null, createdAt: oldDate } as unknown as User;

    const adoptDto = { species: PetSpecies.CAT, name: 'Whiskers' };

    beforeEach(async () => {
        petRepoMock = {
            create: jest.fn(),
            save: jest.fn(),
            findOne: jest.fn(),
        };

        userRepoMock = {
            findOne: jest.fn(),
        };

        queryRunnerMock = {
            connect: jest.fn(),
            startTransaction: jest.fn(),
            commitTransaction: jest.fn(),
            rollbackTransaction: jest.fn(),
            release: jest.fn(),
            manager: {
                findOne: jest.fn(),
                create: jest.fn(),
                save: jest.fn(),
            },
        };

        dataSourceMock = {
            createQueryRunner: jest.fn().mockReturnValue(queryRunnerMock),
        };

        eventEmitterMock = {
            emit: jest.fn(),
        };

        dispatcherMock = {
            dispatchToPartner: jest.fn().mockResolvedValue(undefined),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                PetsService,
                { provide: getRepositoryToken(Pet), useValue: petRepoMock },
                { provide: getRepositoryToken(User), useValue: userRepoMock },
                { provide: DataSource, useValue: dataSourceMock },
                { provide: EventEmitter2, useValue: eventEmitterMock },
                { provide: CoupleNotificationDispatcher, useValue: dispatcherMock },
            ],
        }).compile();

        service = module.get<PetsService>(PetsService);
    });


    describe('adopt', () => {
        it('should adopt a pet for a paired couple', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            queryRunnerMock.manager.findOne.mockResolvedValue(null);
            const created = { id: 'pet-1', coupleId, ...adoptDto, happiness: 50, level: 1 };
            queryRunnerMock.manager.create.mockReturnValue(created);
            queryRunnerMock.manager.save.mockResolvedValue(created);

            const result = await service.adopt(userA, adoptDto);

            expect(result.species).toBe(PetSpecies.CAT);
            expect(result.name).toBe('Whiskers');
            expect(queryRunnerMock.manager.save).toHaveBeenCalled();
            expect(queryRunnerMock.commitTransaction).toHaveBeenCalled();
        });

        it('should throw NotFoundException if user not found', async () => {
            userRepoMock.findOne.mockResolvedValue(null);
            await expect(service.adopt('nobody', adoptDto)).rejects.toThrow(NotFoundException);
        });

        it('should throw BadRequestException if no partner', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserNoPartner);
            await expect(service.adopt(userA, adoptDto)).rejects.toThrow(BadRequestException);
        });

        it('should throw BadRequestException if paired less than 24 hours', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserRecent);
            await expect(service.adopt(userA, adoptDto)).rejects.toThrow(BadRequestException);
        });

        it('should throw ConflictException if couple already has a pet', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            queryRunnerMock.manager.findOne.mockResolvedValue({ id: 'existing', name: 'Fluffy' });
            await expect(service.adopt(userA, adoptDto)).rejects.toThrow(ConflictException);
        });
    });

    describe('getPet', () => {
        it('should return pet for couple', async () => {
            const pet = { id: 'pet-1', coupleId, species: PetSpecies.DOG, name: 'Rex' };
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(pet);

            const result = await service.getPet(userA);

            expect(result?.name).toBe('Rex');
        });

        it('should return null if no partner', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserNoPartner);

            const result = await service.getPet(userA);

            expect(result).toBeNull();
        });

        it('should return the same pet for both partners (L3 fix)', async () => {
            const pet = { id: 'pet-1', coupleId, species: PetSpecies.CAT, name: 'Whiskers' };
            const mockUserB = { id: userB, partnerId: userA, createdAt: oldDate } as Partial<User> as User;

            // Partner A sees the pet
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(pet);
            const resultA = await service.getPet(userA);

            // Partner B sees the same pet (coupleId is sorted, so order doesn't matter)
            userRepoMock.findOne.mockResolvedValue(mockUserB);
            petRepoMock.findOne.mockResolvedValue(pet);
            const resultB = await service.getPet(userB);

            expect(resultA?.id).toBe(resultB?.id);
            expect(resultA?.name).toBe('Whiskers');
            expect(resultB?.name).toBe('Whiskers');

            // Verify both calls used the same coupleId
            const calls = petRepoMock.findOne.mock.calls;
            expect(calls[calls.length - 2][0].where.coupleId)
                .toBe(calls[calls.length - 1][0].where.coupleId);
        });
    });

    describe('interact', () => {
        it('should increase happiness and interactions', async () => {
            const pet = { id: 'pet-1', coupleId, happiness: 50, level: 1, totalInteractions: 0, lastInteraction: null };
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(pet);
            petRepoMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.interact(userA);

            expect(result.happiness).toBe(55);
            expect(result.totalInteractions).toBe(1);
        });

        it('should cap happiness at 100', async () => {
            const pet = { id: 'pet-1', coupleId, happiness: 98, level: 1, totalInteractions: 0, lastInteraction: null };
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(pet);
            petRepoMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.interact(userA);

            expect(result.happiness).toBe(100);
        });

        it('should level up at 50 interactions', async () => {
            const pet = { id: 'pet-1', coupleId, happiness: 50, level: 1, totalInteractions: 49, lastInteraction: null };
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(pet);
            petRepoMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.interact(userA);

            expect(result.level).toBe(2);
            expect(result.totalInteractions).toBe(50);
        });

        it('should throw NotFoundException if no pet', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(null);

            await expect(service.interact(userA)).rejects.toThrow(NotFoundException);
        });

        it('should throw BadRequestException if cooldown not expired', async () => {
            const pet = { id: 'pet-1', coupleId, happiness: 50, level: 1, totalInteractions: 5, lastInteraction: new Date() };
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(pet);

            await expect(service.interact(userA)).rejects.toThrow(BadRequestException);
        });

        it('should emit milestone event at 50 interactions', async () => {
            const pet = { id: 'pet-1', coupleId, name: 'Whiskers', happiness: 50, level: 1, totalInteractions: 49, lastInteraction: null };
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(pet);
            petRepoMock.save.mockImplementation((entity) => Promise.resolve(entity));

            await service.interact(userA);

            expect(eventEmitterMock.emit).toHaveBeenCalledWith(
                'pet.milestone.reached',
                expect.objectContaining({ milestone: 50, petName: 'Whiskers' }),
            );
        });
    });

    describe('getStatus', () => {
        it('should return ecstatic mood for high happiness recent interaction', async () => {
            const pet = {
                id: 'pet-1', coupleId, happiness: 90, level: 2, totalInteractions: 60,
                lastInteraction: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
            };
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(pet);

            const result = await service.getStatus(userA);

            expect(result?.mood).toBe('ecstatic');
            expect(result?.decayedHappiness).toBe(90);
            expect(result?.milestone).toBe('50 interactions!');
        });

        it('should return sick mood when ignored for > 48 hours', async () => {
            const pet = {
                id: 'pet-1', coupleId, happiness: 80, level: 1, totalInteractions: 10,
                lastInteraction: new Date(Date.now() - 50 * 60 * 60 * 1000), // 50 hours ago
            };
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(pet);
            petRepoMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.getStatus(userA);

            expect(result?.mood).toBe('sick');
        });

        it('should decay happiness after 12 hours idle', async () => {
            const pet = {
                id: 'pet-1', coupleId, happiness: 60, level: 1, totalInteractions: 5,
                lastInteraction: new Date(Date.now() - 22 * 60 * 60 * 1000), // 22 hours ago → 10 decay hours → -20
            };
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(pet);
            petRepoMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.getStatus(userA);

            expect(result?.decayedHappiness).toBe(40); // 60 - 20
        });

        it('should return null if no pet', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(null);

            const result = await service.getStatus(userA);

            expect(result).toBeNull();
        });

        it('should calculate streak and badges correctly in getStatus', async () => {
            const todayStr = new Date().toISOString().slice(0, 10);
            const pet = {
                id: 'pet-1', coupleId, happiness: 90, level: 2, totalInteractions: 100,
                streak: 5, lastStreakDate: todayStr,
                lastInteraction: new Date(),
            };
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(pet);

            const result = await service.getStatus(userA);

            expect(result?.streak).toBe(5);
            // 1 base adoption badge + 2 achieved milestones (50, 100) = 3 badges
            expect(result?.badgesCount).toBe(3);
        });

        it('should reset active streak to 0 in getStatus if missed more than 1 day', async () => {
            const threeDaysAgoStr = new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);
            const pet = {
                id: 'pet-1', coupleId, happiness: 90, level: 2, totalInteractions: 100,
                streak: 5, lastStreakDate: threeDaysAgoStr,
                lastInteraction: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
            };
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            petRepoMock.findOne.mockResolvedValue(pet);
            petRepoMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.getStatus(userA);

            expect(result?.streak).toBe(0);
        });
    });
});
