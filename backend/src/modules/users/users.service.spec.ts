import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { Repository } from 'typeorm';
import { NotFoundException } from '@nestjs/common';

const mockUser = {
    id: 'user-123',
    displayName: 'Old Name',
    birthday: null,
    photoUrl: null,
};

describe('UsersService', () => {
    let service: UsersService;
    let repo: Repository<User>;

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                UsersService,
                {
                    provide: getRepositoryToken(User),
                    useValue: {
                        findOne: jest.fn().mockResolvedValue(mockUser),
                        save: jest.fn().mockImplementation((user) => Promise.resolve(user)),
                    },
                },
            ],
        }).compile();

        service = module.get<UsersService>(UsersService);
        repo = module.get<Repository<User>>(getRepositoryToken(User));
    });

    it('should be defined', () => {
        expect(service).toBeDefined();
    });

    describe('updateProfile', () => {
        it('should update user profile', async () => {
            const dto = {
                displayName: 'New Name',
                birthday: '2000-01-01',
                zodiacSign: 'capricorn',
                language: 'en',
            };

            const result = await service.updateProfile('user-123', dto);

            expect(repo.findOne).toHaveBeenCalledWith({ where: { id: 'user-123' } });
            expect(result.displayName).toEqual('New Name');
            expect(result.zodiacSign).toEqual('capricorn');
            expect(repo.save).toHaveBeenCalled();
        });
    });

    describe('updateAvatar', () => {
        it('should update avatar url', async () => {
            const url = 'http://example.com/avatar.jpg';
            const result = await service.updateAvatar('user-123', url);

            expect(result.photoUrl).toEqual(url);
            expect(repo.save).toHaveBeenCalled();
        });
    });

    describe('getProfileWithPartner', () => {
        const caller = {
            id: 'user-123',
            firebaseUid: 'fb-123',
            displayName: 'Minh',
            partnerId: 'partner-456',
            isGhostModeEnabled: true,
        };

        it('resolves partnerDisplayName for a paired caller and keeps the caller identity keys unchanged', async () => {
            const partner = { id: 'partner-456', displayName: 'Linh' };
            (repo.findOne as jest.Mock).mockImplementation(({ where }) => {
                if (where.firebaseUid) return Promise.resolve(caller);
                if (where.id === 'partner-456') return Promise.resolve(partner);
                return Promise.resolve(null);
            });

            const result = await service.getProfileWithPartner('fb-123');

            expect(result.partnerDisplayName).toEqual('Linh');
            expect(result.id).toEqual(caller.id);
            expect(result.displayName).toEqual(caller.displayName);
            expect(result.partnerId).toEqual(caller.partnerId);
            expect(result.isGhostModeEnabled).toEqual(caller.isGhostModeEnabled);
        });

        it('returns null partnerDisplayName for an unpaired caller', async () => {
            const unpairedCaller = { ...caller, partnerId: null };
            (repo.findOne as jest.Mock).mockImplementation(({ where }) => {
                if (where.firebaseUid) return Promise.resolve(unpairedCaller);
                return Promise.resolve(null);
            });

            const result = await service.getProfileWithPartner('fb-123');

            expect(result.partnerDisplayName).toBeNull();
        });

        it('returns null partnerDisplayName when partnerId points at a deleted row', async () => {
            (repo.findOne as jest.Mock).mockImplementation(({ where }) => {
                if (where.firebaseUid) return Promise.resolve(caller);
                if (where.id === 'partner-456') return Promise.resolve(undefined);
                return Promise.resolve(null);
            });

            const result = await service.getProfileWithPartner('fb-123');

            expect(result.partnerDisplayName).toBeNull();
        });

        it('returns null partnerDisplayName when the partner has a null displayName', async () => {
            const partner = { id: 'partner-456', displayName: null };
            (repo.findOne as jest.Mock).mockImplementation(({ where }) => {
                if (where.firebaseUid) return Promise.resolve(caller);
                if (where.id === 'partner-456') return Promise.resolve(partner);
                return Promise.resolve(null);
            });

            const result = await service.getProfileWithPartner('fb-123');

            expect(result.partnerDisplayName).toBeNull();
        });
    });
});
