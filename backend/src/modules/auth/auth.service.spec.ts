import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import { User } from '../users/entities/user.entity';
import { EmailVerification } from './entities/email-verification.entity';
import { MailService } from '../mail/mail.service';
import { ConflictException, BadRequestException, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;

  const mockUserRepository = {
    findOne: jest.fn(),
    save: jest.fn(),
    create: jest.fn(),
  };

  const mockEmailVerificationRepository = {
    findOne: jest.fn(),
    save: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  };

  const mockJwtService = {
    sign: jest.fn().mockReturnValue('mock-jwt-token'),
  };

  const mockMailService = {
    sendVerificationEmail: jest.fn().mockResolvedValue(true),
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
        {
          provide: getRepositoryToken(EmailVerification),
          useValue: mockEmailVerificationRepository,
        },
        {
          provide: JwtService,
          useValue: mockJwtService,
        },
        {
          provide: MailService,
          useValue: mockMailService,
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('register', () => {
    it('should register a new user and send OTP verification email', async () => {
      mockUserRepository.findOne.mockResolvedValue(null);
      const newUser = {
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: false,
      };
      mockUserRepository.create.mockReturnValue(newUser);
      mockUserRepository.save.mockResolvedValue(newUser);
      mockEmailVerificationRepository.create.mockImplementation((dto) => dto);
      mockEmailVerificationRepository.save.mockResolvedValue({ id: 'v-1' });

      const result = await service.register({
        email: 'test@example.com',
        password: 'Password123!',
        displayName: 'Test User',
      });

      expect(result.success).toBe(true);
      expect(result.email).toBe('test@example.com');
      expect(mockMailService.sendVerificationEmail).toHaveBeenCalled();
    });

    it('should throw ConflictException when user is already registered and verified', async () => {
      mockUserRepository.findOne.mockResolvedValue({
        id: 'user-1',
        email: 'test@example.com',
        isEmailVerified: true,
      });

      await expect(
        service.register({
          email: 'test@example.com',
          password: 'Password123!',
        }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('verifyOtp', () => {
    it('should verify valid OTP and return JWT token', async () => {
      const validVerification = {
        id: 'v-1',
        email: 'test@example.com',
        otpCode: '123456',
        isUsed: false,
        expiresAt: new Date(Date.now() + 10000),
      };
      mockEmailVerificationRepository.findOne.mockResolvedValue(validVerification);

      const user = {
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: false,
      };
      mockUserRepository.findOne.mockResolvedValue(user);
      mockUserRepository.save.mockResolvedValue({ ...user, isEmailVerified: true });

      const result = await service.verifyOtp({
        email: 'test@example.com',
        code: '123456',
      });

      expect(result.success).toBe(true);
      expect(result.accessToken).toBe('mock-jwt-token');
      expect(validVerification.isUsed).toBe(true);
    });

    it('should throw BadRequestException if OTP is invalid or expired', async () => {
      mockEmailVerificationRepository.findOne.mockResolvedValue(null);

      await expect(
        service.verifyOtp({
          email: 'test@example.com',
          code: '000000',
        }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('login', () => {
    it('should return token when password matches and email is verified', async () => {
      const hash = await bcrypt.hash('Password123!', 10);
      const user = {
        id: 'user-1',
        email: 'test@example.com',
        passwordHash: hash,
        isEmailVerified: true,
      };
      mockUserRepository.findOne.mockResolvedValue(user);

      const result = await service.login({
        email: 'test@example.com',
        password: 'Password123!',
      });

      expect(result.success).toBe(true);
      expect(result.accessToken).toBe('mock-jwt-token');
    });

    it('should prompt requireVerification if user email is not verified', async () => {
      const hash = await bcrypt.hash('Password123!', 10);
      const user = {
        id: 'user-1',
        email: 'test@example.com',
        passwordHash: hash,
        isEmailVerified: false,
      };
      mockUserRepository.findOne.mockResolvedValue(user);

      const result = await service.login({
        email: 'test@example.com',
        password: 'Password123!',
      });

      expect(result.requireVerification).toBe(true);
    });

    it('should throw UnauthorizedException when password mismatch', async () => {
      const hash = await bcrypt.hash('OtherPassword', 10);
      const user = {
        id: 'user-1',
        email: 'test@example.com',
        passwordHash: hash,
        isEmailVerified: true,
      };
      mockUserRepository.findOne.mockResolvedValue(user);

      await expect(
        service.login({
          email: 'test@example.com',
          password: 'WrongPassword',
        }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });
});
