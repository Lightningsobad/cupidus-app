import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from '../users/entities/user.entity';
import { ConflictException } from '@nestjs/common';

describe('AuthService', () => {
    let service: AuthService;

    const mockUserRepository = {
        findOne: jest.fn(),
        save: jest.fn(),
        create: jest.fn(),
    };

    beforeEach(async () => {
        jest.clearAllMocks();
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                AuthService,
                {
                    provide: getRepositoryToken(User),
                    useValue: mockUserRepository,
                },
            ],
        }).compile();

        service = module.get<AuthService>(AuthService);
    });

    it('should be defined', () => {
        expect(service).toBeDefined();
    });

    describe('loginUser', () => {
        it('should return null when user not found', async () => {
            mockUserRepository.findOne.mockResolvedValue(null);
            const result = await service.loginUser({ uid: 'test-uid' });
            expect(result).toBeNull();
            expect(mockUserRepository.findOne).toHaveBeenCalledWith({ where: { firebaseUid: 'test-uid' } });
        });

        it('should return user when found', async () => {
            const mockUser = { id: 1, firebaseUid: 'test-uid', email: 'test@test.com' };
            mockUserRepository.findOne.mockResolvedValue(mockUser);
            const result = await service.loginUser({ uid: 'test-uid' });
            expect(result).toEqual(mockUser);
        });
    });

    describe('registerUser', () => {
        it('should create a new user when not existing', async () => {
            mockUserRepository.findOne.mockResolvedValue(null);
            const newUser = { firebaseUid: 'new-uid', email: 'new@test.com', displayName: 'New', photoUrl: null };
            mockUserRepository.create.mockReturnValue(newUser);
            mockUserRepository.save.mockResolvedValue({ id: 2, ...newUser });

            const result = await service.registerUser({ uid: 'new-uid', email: 'new@test.com', name: 'New', picture: null });

            expect(mockUserRepository.create).toHaveBeenCalledWith({
                firebaseUid: 'new-uid',
                email: 'new@test.com',
                displayName: 'New',
                photoUrl: null,
            });
            expect(mockUserRepository.save).toHaveBeenCalledWith(newUser);
            expect(result).toHaveProperty('id', 2);
        });

        it('should throw ConflictException when user already exists', async () => {
            mockUserRepository.findOne.mockResolvedValue({ id: 1, firebaseUid: 'existing-uid' });

            await expect(
                service.registerUser({ uid: 'existing-uid', email: 'x@test.com', name: 'X', picture: null }),
            ).rejects.toThrow(ConflictException);
        });
    });
});
