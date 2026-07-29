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
});
