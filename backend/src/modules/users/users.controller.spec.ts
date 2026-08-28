import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

describe('UsersController', () => {
    let controller: UsersController;
    let serviceMock: any;

    const mockReq = { user: { uid: 'firebase-uid-1' } };
    const mockProfileWithPartner = {
        id: 'user-123',
        displayName: 'Minh',
        partnerId: 'partner-456',
        isGhostModeEnabled: true,
        partnerDisplayName: 'Linh',
        partnerPhotoUrl: 'http://example.com/linh.jpg',
    };

    beforeEach(async () => {
        serviceMock = {
            getProfileWithPartner: jest.fn().mockResolvedValue(mockProfileWithPartner),
            findByFirebaseUid: jest.fn(),
        };

        const module: TestingModule = await Test.createTestingModule({
            controllers: [UsersController],
            providers: [{ provide: UsersService, useValue: serviceMock }],
        }).compile();

        controller = module.get<UsersController>(UsersController);
    });

    it('delegates to getProfileWithPartner, not findByFirebaseUid', async () => {
        const result = await controller.getProfile(mockReq);

        expect(serviceMock.getProfileWithPartner).toHaveBeenCalledWith('firebase-uid-1');
        expect(serviceMock.findByFirebaseUid).not.toHaveBeenCalled();
        expect(result).toBe(mockProfileWithPartner);
    });

    it('includes partnerDisplayName and partnerPhotoUrl on the result', async () => {
        const result = await controller.getProfile(mockReq);

        expect(result.partnerDisplayName).toBe('Linh');
        expect(result.partnerPhotoUrl).toBe('http://example.com/linh.jpg');
    });

    it('preserves the caller identity keys alongside partnerDisplayName', async () => {
        const result = await controller.getProfile(mockReq);

        expect(result.id).toBe('user-123');
        expect(result.displayName).toBe('Minh');
        expect(result.partnerId).toBe('partner-456');
        expect(result.isGhostModeEnabled).toBe(true);
    });
});
