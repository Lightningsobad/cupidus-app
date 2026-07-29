import { Test, TestingModule } from '@nestjs/testing';
import { GhostConfigService } from './ghost-config.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { GhostConfig, ConfigStatus, Penalty } from './entities/ghost-config.entity';
import { User } from '../users/entities/user.entity';
import { Message } from '../messages/entities/message.entity';
import { NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { DataSource } from 'typeorm';

describe('GhostConfigService', () => {
    let service: GhostConfigService;
    let configRepoMock: any;
    let userRepoMock: any;

    let dataSourceMock: any;
    let messageRepoMock: any;

    const userA = 'user-aaa';
    const userB = 'user-bbb';
    const coupleId = [userA, userB].sort().join(':');
    const mockUserA = { id: userA, partnerId: userB } as Partial<User> as User;
    const mockUserB = { id: userB, partnerId: userA } as Partial<User> as User;
    const mockUserNoPartner = { id: userA, partnerId: null } as unknown as User;

    beforeEach(async () => {
        configRepoMock = {
            create: jest.fn(),
            save: jest.fn(),
            findOne: jest.fn(),
            find: jest.fn(),
            update: jest.fn(),
        };

        userRepoMock = {
            findOne: jest.fn(),
        };

        dataSourceMock = {
            transaction: jest.fn(async (cb) => {
                const manager = {
                    update: jest.fn(),
                    save: jest.fn((entity) => Promise.resolve(entity)),
                };
                return cb(manager);
            }),
        };

        messageRepoMock = {
            findOne: jest.fn(),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                GhostConfigService,
                { provide: getRepositoryToken(GhostConfig), useValue: configRepoMock },
                { provide: getRepositoryToken(User), useValue: userRepoMock },
                { provide: getRepositoryToken(Message), useValue: messageRepoMock },
                { provide: DataSource, useValue: dataSourceMock },
            ],
        }).compile();

        service = module.get<GhostConfigService>(GhostConfigService);
    });

    describe('create', () => {
        const dto = { timeoutMinutes: 15, penalty: Penalty.EMOJI_STORM };

        it('should create a pending config', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            const created = { id: 'cfg-1', coupleId, ...dto, proposedBy: userA, status: ConfigStatus.PENDING_APPROVAL };
            configRepoMock.create.mockReturnValue(created);
            configRepoMock.save.mockResolvedValue(created);

            const result = await service.create(userA, dto);

            expect(result.status).toBe(ConfigStatus.PENDING_APPROVAL);
            expect(result.proposedBy).toBe(userA);
            expect(configRepoMock.save).toHaveBeenCalled();
        });

        it('should throw NotFoundException if user not found', async () => {
            userRepoMock.findOne.mockResolvedValue(null);
            await expect(service.create('nobody', dto)).rejects.toThrow(NotFoundException);
        });

        it('should throw BadRequestException if user has no partner', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserNoPartner);
            await expect(service.create(userA, dto)).rejects.toThrow(BadRequestException);
        });
    });

    describe('approve', () => {
        it('should approve a pending config and supersede previous', async () => {
            const pending = { id: 'cfg-1', coupleId, proposedBy: userA, status: ConfigStatus.PENDING_APPROVAL };
            configRepoMock.findOne.mockResolvedValue(pending);
            userRepoMock.findOne.mockResolvedValue(mockUserB);

            const result = await service.approve(userB, 'cfg-1');

            expect(result.status).toBe(ConfigStatus.ACTIVE);
            expect(result.approvedBy).toBe(userB);
            expect(dataSourceMock.transaction).toHaveBeenCalled();
        });

        it('should throw ForbiddenException if approving own config', async () => {
            const pending = { id: 'cfg-1', coupleId, proposedBy: userA, status: ConfigStatus.PENDING_APPROVAL };
            configRepoMock.findOne.mockResolvedValue(pending);

            await expect(service.approve(userA, 'cfg-1')).rejects.toThrow(ForbiddenException);
        });

        it('should throw NotFoundException if config not found', async () => {
            configRepoMock.findOne.mockResolvedValue(null);
            await expect(service.approve(userB, 'nonexistent')).rejects.toThrow(NotFoundException);
        });

        it('should throw BadRequestException if config is not pending', async () => {
            const active = { id: 'cfg-1', coupleId, proposedBy: userA, status: ConfigStatus.ACTIVE };
            configRepoMock.findOne.mockResolvedValue(active);
            await expect(service.approve(userB, 'cfg-1')).rejects.toThrow(BadRequestException);
        });
    });

    describe('reject', () => {
        it('should reject a pending config', async () => {
            const pending = { id: 'cfg-1', coupleId, proposedBy: userA, status: ConfigStatus.PENDING_APPROVAL };
            configRepoMock.findOne.mockResolvedValue(pending);
            userRepoMock.findOne.mockResolvedValue(mockUserB);
            configRepoMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.reject(userB, 'cfg-1');

            expect(result.status).toBe(ConfigStatus.REJECTED);
        });

        it('should throw ForbiddenException if rejecting own config', async () => {
            const pending = { id: 'cfg-1', coupleId, proposedBy: userA, status: ConfigStatus.PENDING_APPROVAL };
            configRepoMock.findOne.mockResolvedValue(pending);

            await expect(service.reject(userA, 'cfg-1')).rejects.toThrow(ForbiddenException);
        });

        it('should throw BadRequestException if config is not pending', async () => {
            const active = { id: 'cfg-1', coupleId, proposedBy: userA, status: ConfigStatus.ACTIVE };
            configRepoMock.findOne.mockResolvedValue(active);
            await expect(service.reject(userB, 'cfg-1')).rejects.toThrow(BadRequestException);
        });
    });

    describe('getActive', () => {
        it('should return active config for couple', async () => {
            const active = { id: 'cfg-1', coupleId, status: ConfigStatus.ACTIVE, timeoutMinutes: 10, penalty: Penalty.NONE };
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            configRepoMock.findOne.mockResolvedValue(active);

            const result = await service.getActive(userA);

            expect(result?.status).toBe(ConfigStatus.ACTIVE);
        });

        it('should return null if no partner', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserNoPartner);

            const result = await service.getActive(userA);

            expect(result).toBeNull();
        });
    });

    describe('getPending', () => {
        it('should return pending configs for couple', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            configRepoMock.find.mockResolvedValue([{ id: 'cfg-2', status: ConfigStatus.PENDING_APPROVAL }]);

            const result = await service.getPending(userA);

            expect(result).toHaveLength(1);
        });

        it('should return empty array if no partner', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserNoPartner);

            const result = await service.getPending(userA);

            expect(result).toEqual([]);
        });
    });

    describe('getStormStatus', () => {
        it('should return eligible when timeout has passed and no reply', async () => {
            const seenAt = new Date(Date.now() - 20 * 60 * 1000); // 20 min ago
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            configRepoMock.findOne.mockResolvedValue({
                coupleId, timeoutMinutes: 10, penalty: Penalty.EMOJI_STORM, status: ConfigStatus.ACTIVE,
            });
            messageRepoMock.findOne
                .mockResolvedValueOnce({ readAt: seenAt, senderId: userA, receiverId: userB, status: 'seen' })
                .mockResolvedValueOnce(null); // no partner reply

            const result = await service.getStormStatus(userA, userB);

            expect(result.eligible).toBe(true);
            expect(result.penalty).toBe(Penalty.EMOJI_STORM);
        });

        it('should return not eligible when partner replied after seen', async () => {
            const seenAt = new Date(Date.now() - 20 * 60 * 1000);
            const repliedAt = new Date(Date.now() - 5 * 60 * 1000);
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            configRepoMock.findOne.mockResolvedValue({
                coupleId, timeoutMinutes: 10, penalty: Penalty.EMOJI_STORM, status: ConfigStatus.ACTIVE,
            });
            messageRepoMock.findOne
                .mockResolvedValueOnce({ readAt: seenAt })
                .mockResolvedValueOnce({ createdAt: repliedAt });

            const result = await service.getStormStatus(userA, userB);

            expect(result.eligible).toBe(false);
        });

        it('should return not eligible when no active config', async () => {
            userRepoMock.findOne.mockResolvedValue(mockUserA);
            configRepoMock.findOne.mockResolvedValue(null);

            const result = await service.getStormStatus(userA, userB);

            expect(result.eligible).toBe(false);
            expect(result.penalty).toBeNull();
        });

        it('should return not eligible when user has no partner match', async () => {
            userRepoMock.findOne.mockResolvedValue({ ...mockUserA, partnerId: 'other-user' });

            const result = await service.getStormStatus(userA, userB);

            expect(result.eligible).toBe(false);
        });
    });
});
