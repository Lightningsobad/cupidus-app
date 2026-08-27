import { Test, TestingModule } from '@nestjs/testing';
import { InvitationsService } from './invitations.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Invitation } from './entities/invitation.entity';
import { UsersService } from '../users/users.service';
import { NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

describe('InvitationsService', () => {
  let service: InvitationsService;
  let repositoryMock: any;
  let usersServiceMock: any;
  let dispatcherMock: any;

  const mockUser = 'user-123';
  const mockPartner = 'partner-456';

  beforeEach(async () => {
    repositoryMock = {
      findOne: jest.fn(),
      create: jest.fn(),
      save: jest.fn(),
    };

    usersServiceMock = {
      findOne: jest.fn(),
      setPartner: jest.fn(),
      updateProfile: jest.fn(),
    };

    dispatcherMock = {
      dispatchToPartner: jest.fn().mockResolvedValue(undefined),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InvitationsService,
        {
          provide: getRepositoryToken(Invitation),
          useValue: repositoryMock,
        },
        {
          provide: UsersService,
          useValue: usersServiceMock,
        },
        {
          provide: CoupleNotificationDispatcher,
          useValue: dispatcherMock,
        },
      ],
    }).compile();

    service = module.get<InvitationsService>(InvitationsService);
  });


  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('generateCode', () => {
    it('should create a new invitation', async () => {
      repositoryMock.findOne.mockResolvedValue(null);
      repositoryMock.create.mockReturnValue({ code: 'ABCDEF' });
      repositoryMock.save.mockResolvedValue({ code: 'ABCDEF' });

      const result = await service.generateCode(mockUser);
      expect(result.code).toBe('ABCDEF');
      expect(repositoryMock.save).toHaveBeenCalled();
    });

    it('should return existing active invitation', async () => {
      const existing = { code: 'EXISTING', isActive: true };
      repositoryMock.findOne.mockResolvedValue(existing);

      const result = await service.generateCode(mockUser);
      expect(result).toBe(existing);
      expect(repositoryMock.save).not.toHaveBeenCalled();
    });
  });

  describe('validateCode', () => {
    it('should return valid invitation and inviter', async () => {
      const invitation = { inviterId: mockUser, isActive: true, expiresAt: new Date(Date.now() + 10000) };
      repositoryMock.findOne.mockResolvedValue(invitation);
      usersServiceMock.findOne.mockResolvedValue({ id: mockUser, displayName: 'Test' });

      const result = await service.validateCode('CODE');
      expect(result.invitation).toBe(invitation);
      expect(result.inviter.id).toBe(mockUser);
    });

    it('should throw NotFound if invalid', async () => {
      repositoryMock.findOne.mockResolvedValue(null);
      await expect(service.validateCode('INVALID')).rejects.toThrow(NotFoundException);
    });

    it('should throw BadRequest if expired', async () => {
      const invitation = { inviterId: mockUser, isActive: true, expiresAt: new Date(Date.now() - 10000) };
      repositoryMock.findOne.mockResolvedValue(invitation);
      await expect(service.validateCode('EXPIRED')).rejects.toThrow(BadRequestException);
    });
  });

  describe('acceptInvitation', () => {
    it('should link users and deactivate invitation', async () => {
      const invitation = { inviterId: mockUser, isActive: true, expiresAt: new Date(Date.now() + 10000) };
      repositoryMock.findOne.mockResolvedValue(invitation);
      usersServiceMock.findOne.mockResolvedValue({ id: mockUser });

      await service.acceptInvitation(mockPartner, 'CODE');

      expect(usersServiceMock.setPartner).toHaveBeenCalledWith(mockPartner, mockUser);
      expect(usersServiceMock.setPartner).toHaveBeenCalledWith(mockUser, mockPartner);
      expect(invitation.isActive).toBe(false);
      expect(repositoryMock.save).toHaveBeenCalledWith(invitation);
    });

    it('should throw Conflict if inviting self', async () => {
      const invitation = { inviterId: mockUser, isActive: true, expiresAt: new Date(Date.now() + 10000) };
      repositoryMock.findOne.mockResolvedValue(invitation);
      usersServiceMock.findOne.mockResolvedValue({ id: mockUser });

      await expect(service.acceptInvitation(mockUser, 'CODE')).rejects.toThrow(ConflictException);
    });
  });
});
