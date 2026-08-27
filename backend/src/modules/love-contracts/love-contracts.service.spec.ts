import { Test, TestingModule } from '@nestjs/testing';
import { LoveContractsService } from './love-contracts.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { LoveContract, ContractStatus } from './entities/love-contract.entity';
import { User } from '../users/entities/user.entity';
import { LoveContractResponseDto } from './dto/love-contract-response.dto';
import { ConflictException, NotFoundException } from '@nestjs/common';
import { CoupleNotificationDispatcher } from '../notifications/couple-notification-dispatcher.service';

describe('LoveContractsService', () => {
    let service: LoveContractsService;
    let contractRepositoryMock: any;
    let usersRepositoryMock: any;
    let dispatcherMock: any;

    const mockUser = 'user-123';
    const mockPartner = 'partner-456';
    const mockClauses = ['Rule 1', 'Rule 2'];

    beforeEach(async () => {
        contractRepositoryMock = {
            findOne: jest.fn(),
            create: jest.fn(),
            save: jest.fn(),
        };
        usersRepositoryMock = {
            findOne: jest.fn(),
        };
        dispatcherMock = {
            dispatchToPartner: jest.fn().mockResolvedValue(undefined),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                LoveContractsService,
                {
                    provide: getRepositoryToken(LoveContract),
                    useValue: contractRepositoryMock,
                },
                {
                    provide: getRepositoryToken(User),
                    useValue: usersRepositoryMock,
                },
                {
                    provide: CoupleNotificationDispatcher,
                    useValue: dispatcherMock,
                },
            ],
        }).compile();

        service = module.get<LoveContractsService>(LoveContractsService);
    });


    describe('create', () => {
        it('writes partnerId from the paired User.partnerId when creating a new contract', async () => {
            contractRepositoryMock.findOne.mockResolvedValue(null);
            usersRepositoryMock.findOne.mockResolvedValue({ id: mockUser, partnerId: mockPartner });
            contractRepositoryMock.create.mockImplementation((entity) => entity);
            contractRepositoryMock.save.mockImplementation((entity) => Promise.resolve({ id: '1', ...entity }));

            const result = await service.create(mockUser, { clauses: mockClauses });

            expect(result.status).toBe(ContractStatus.CREATED);
            expect(result.partnerId).toBe(mockPartner);
        });

        it('leaves partnerId null when creating a new contract for an unpaired requester', async () => {
            contractRepositoryMock.findOne.mockResolvedValue(null);
            usersRepositoryMock.findOne.mockResolvedValue({ id: mockUser, partnerId: null });
            contractRepositoryMock.create.mockImplementation((entity) => entity);
            contractRepositoryMock.save.mockImplementation((entity) => Promise.resolve({ id: '1', ...entity }));

            const result = await service.create(mockUser, { clauses: mockClauses });

            expect(result.partnerId).toBeFalsy();
        });

        it('updates an existing pending contract owned by the requester', async () => {
            const existing = { id: '1', requesterId: mockUser, partnerId: null, status: ContractStatus.CREATED, clauses: ['Old'], signedAtRequester: null, signedAtPartner: null };
            contractRepositoryMock.findOne.mockResolvedValue(existing);
            usersRepositoryMock.findOne.mockResolvedValue({ id: mockUser, partnerId: null });
            contractRepositoryMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.create(mockUser, { clauses: mockClauses });

            expect(result.clauses).toEqual(mockClauses);
            expect(result.status).toBe(ContractStatus.CREATED);
        });

        it('throws ConflictException when the caller is the partner of an existing contract', async () => {
            const existingContract = {
                id: '1',
                requesterId: mockPartner,
                partnerId: mockUser,
                status: ContractStatus.CREATED,
                clauses: ['Existing'],
                signedAtRequester: null,
                signedAtPartner: null,
            };
            contractRepositoryMock.findOne.mockResolvedValue(existingContract);
            usersRepositoryMock.findOne.mockResolvedValue({ id: mockUser, partnerId: mockPartner });

            await expect(service.create(mockUser, { clauses: mockClauses })).rejects.toThrow(ConflictException);
            expect(contractRepositoryMock.save).not.toHaveBeenCalled();
        });

        it('resets status to CREATED and nulls both timestamps when the requester edits a signed contract', async () => {
            const existingSignedContract = {
                id: '1',
                requesterId: mockUser,
                partnerId: mockPartner,
                status: ContractStatus.SIGNED_PARTNER,
                clauses: ['old clause'],
                signedAtRequester: new Date(),
                signedAtPartner: new Date(),
            };
            contractRepositoryMock.findOne.mockResolvedValue(existingSignedContract);
            usersRepositoryMock.findOne.mockResolvedValue({ id: mockUser, partnerId: mockPartner });
            contractRepositoryMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.create(mockUser, { clauses: mockClauses });

            expect(result.status).toBe(ContractStatus.CREATED);
            expect(result.signedAtRequester).toBeNull();
            expect(result.signedAtPartner).toBeNull();
            expect(result.clauses).toEqual(mockClauses);
        });
    });

    describe('getMyContract', () => {
        // Where-clause-matching stub: filters `rows` by whatever shape the
        // service passes as `where` (single object or OR-array) and returns
        // the newest match. Implementation-agnostic on purpose, so these
        // tests discriminate on resolver *behavior*, not on call count.
        const makeFindOneStub = (rows: any[]) => (query: any) => {
            const clauses = Array.isArray(query.where) ? query.where : [query.where];
            const matches = rows.filter((row) =>
                clauses.some((clause: any) =>
                    Object.entries(clause).every(([key, value]) => row[key] === value),
                ),
            );
            if (matches.length === 0) {
                return Promise.resolve(null);
            }
            const newestFirst = [...matches].sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
            return Promise.resolve(newestFirst[0]);
        };

        it('resolves for the partner via the partnerId branch', async () => {
            const contract = { id: '1', requesterId: mockPartner, partnerId: mockUser, status: ContractStatus.CREATED };
            contractRepositoryMock.findOne
                .mockResolvedValueOnce(null)
                .mockResolvedValueOnce(contract);

            const result = await service.getMyContract(mockUser);

            expect(result).toBe(contract);
            expect(usersRepositoryMock.findOne).not.toHaveBeenCalled();
        });

        it('resolves via the step-2 fallback and backfills partnerId when it is null', async () => {
            const partnerOwnedContract = { id: '1', requesterId: mockPartner, partnerId: null, status: ContractStatus.CREATED };
            contractRepositoryMock.findOne
                .mockResolvedValueOnce(null)
                .mockResolvedValueOnce(null)
                .mockResolvedValueOnce(partnerOwnedContract);
            usersRepositoryMock.findOne.mockResolvedValue({ id: mockUser, partnerId: mockPartner });
            contractRepositoryMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.getMyContract(mockUser);

            expect(result?.partnerId).toBe(mockUser);
            expect(contractRepositoryMock.save).toHaveBeenCalledWith(expect.objectContaining({ partnerId: mockUser }));
        });

        it('resolver precedence: a caller who owns a row resolves to it via the requester-first query, without the partner fallback', async () => {
            const ownRow = { id: 'own-row', requesterId: mockUser, partnerId: null, status: ContractStatus.CREATED };
            contractRepositoryMock.findOne.mockResolvedValueOnce(ownRow);

            const result = await service.getMyContract(mockUser);

            expect(contractRepositoryMock.findOne).toHaveBeenNthCalledWith(1, {
                where: { requesterId: mockUser },
                order: { createdAt: 'DESC' },
            });
            expect(contractRepositoryMock.findOne).toHaveBeenCalledTimes(1);
            expect(result).toBe(ownRow);
            expect(usersRepositoryMock.findOne).not.toHaveBeenCalled();
        });

        it('resolver precedence: a caller who is requester on one row and partner on another resolves to their own row when it is the newer row', async () => {
            const ownRow = { id: 'own-newer', requesterId: mockUser, partnerId: null, status: ContractStatus.CREATED, createdAt: new Date('2026-02-01T00:00:00Z') };
            const partnerRow = { id: 'partner-older', requesterId: mockPartner, partnerId: mockUser, status: ContractStatus.CREATED, createdAt: new Date('2026-01-01T00:00:00Z') };
            contractRepositoryMock.findOne.mockImplementation(makeFindOneStub([ownRow, partnerRow]));

            const result = await service.getMyContract(mockUser);

            expect(result).toBe(ownRow);
        });

        it('resolver precedence: a caller who is requester on one row and partner on another resolves to their own row even when it is the older row', async () => {
            const ownRow = { id: 'own-older', requesterId: mockUser, partnerId: null, status: ContractStatus.CREATED, createdAt: new Date('2026-01-01T00:00:00Z') };
            const partnerRow = { id: 'partner-newer', requesterId: mockPartner, partnerId: mockUser, status: ContractStatus.CREATED, createdAt: new Date('2026-02-01T00:00:00Z') };
            contractRepositoryMock.findOne.mockImplementation(makeFindOneStub([ownRow, partnerRow]));

            const result = await service.getMyContract(mockUser);

            expect(result).toBe(ownRow);
        });
    });

    describe('sign', () => {
        it('sets signedAtRequester and SIGNED_REQUESTER when the requester signs', async () => {
            const contract = { id: '1', requesterId: mockUser, partnerId: mockPartner, status: ContractStatus.CREATED, signedAtRequester: null, signedAtPartner: null };
            contractRepositoryMock.findOne.mockResolvedValue(contract);
            contractRepositoryMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.sign(mockUser);

            expect(result.status).toBe(ContractStatus.SIGNED_REQUESTER);
            expect(result.signedAtRequester).toBeInstanceOf(Date);
            expect(result.signedAtPartner).toBeNull();
        });

        it('sets signedAtPartner and SIGNED_PARTNER when the partner signs, preserving signedAtRequester', async () => {
            const requesterSignedAt = new Date('2026-01-01T00:00:00Z');
            const contract = { id: '1', requesterId: mockPartner, partnerId: mockUser, status: ContractStatus.SIGNED_REQUESTER, signedAtRequester: requesterSignedAt, signedAtPartner: null };
            contractRepositoryMock.findOne.mockResolvedValue(contract);
            contractRepositoryMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.sign(mockUser);

            expect(result.status).toBe(ContractStatus.SIGNED_PARTNER);
            expect(result.signedAtPartner).toBeInstanceOf(Date);
            expect(result.signedAtRequester).toBe(requesterSignedAt);
        });

        it('is idempotent when the caller has already signed', async () => {
            const alreadySignedAt = new Date('2026-01-01T00:00:00Z');
            const contract = { id: '1', requesterId: mockUser, partnerId: mockPartner, status: ContractStatus.SIGNED_REQUESTER, signedAtRequester: alreadySignedAt, signedAtPartner: null };
            contractRepositoryMock.findOne.mockResolvedValue(contract);

            const result = await service.sign(mockUser);

            expect(result).toBe(contract);
            expect(contractRepositoryMock.save).not.toHaveBeenCalled();
        });

        it('throws NotFoundException for an unpaired caller with no contract (AC4 regression guard)', async () => {
            contractRepositoryMock.findOne.mockResolvedValue(null);
            usersRepositoryMock.findOne.mockResolvedValue({ id: mockUser, partnerId: null });

            await expect(service.sign(mockUser)).rejects.toThrow(NotFoundException);
        });
    });

    describe('LoveContractResponseDto.from', () => {
        it('sets viewerRole to requester for the creator and partner for the other side', () => {
            const contract = {
                id: '1',
                requesterId: mockUser,
                partnerId: mockPartner,
                clauses: mockClauses,
                status: ContractStatus.CREATED,
                signedAtRequester: null,
                signedAtPartner: null,
                createdAt: new Date(),
                updatedAt: new Date(),
            } as LoveContract;

            expect(LoveContractResponseDto.from(contract, mockUser).viewerRole).toBe('requester');
            expect(LoveContractResponseDto.from(contract, mockPartner).viewerRole).toBe('partner');
        });
    });
});
