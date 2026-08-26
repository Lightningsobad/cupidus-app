import { Test, TestingModule } from '@nestjs/testing';
import { InvitationsController } from './invitations.controller';
import { InvitationsService } from './invitations.service';

import { UsersService } from '../users/users.service';

describe('InvitationsController', () => {
  let controller: InvitationsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [InvitationsController],
      providers: [
        {
          provide: InvitationsService,
          useValue: {
            generateCode: jest.fn(),
            validateCode: jest.fn(),
            acceptInvitation: jest.fn(),
          },
        },
        {
          provide: UsersService,
          useValue: {
            findByFirebaseUid: jest.fn().mockResolvedValue({ id: 'user-1' }),
          },
        },
      ],
    }).compile();

    controller = module.get<InvitationsController>(InvitationsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
