import { Test, TestingModule } from '@nestjs/testing';
import { LoveContractsService } from './love-contracts.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { LoveContract, ContractStatus } from './entities/love-contract.entity';
import { NotFoundException } from '@nestjs/common';

describe('LoveContractsService', () => {
    let service: LoveContractsService;
    let repositoryMock: any;

    const mockUser = 'user-123';
    const mockClauses = ['Rule 1', 'Rule 2'];

    beforeEach(async () => {
        repositoryMock = {
            findOne: jest.fn(),
            create: jest.fn(),
            save: jest.fn(),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                LoveContractsService,
                {
                    provide: getRepositoryToken(LoveContract),
                    useValue: repositoryMock,
                },
            ],
        }).compile();

        service = module.get<LoveContractsService>(LoveContractsService);
    });

    describe('create', () => {
        it('should create a new contract if none exists', async () => {
            repositoryMock.findOne.mockResolvedValue(null);
            repositoryMock.create.mockReturnValue({ requesterId: mockUser, clauses: mockClauses, status: ContractStatus.CREATED });
            repositoryMock.save.mockResolvedValue({ id: '1', requesterId: mockUser, clauses: mockClauses, status: ContractStatus.CREATED });

            const result = await service.create(mockUser, { clauses: mockClauses });
            expect(result.status).toBe(ContractStatus.CREATED);
            expect(repositoryMock.save).toHaveBeenCalled();
        });

        it('should update existing pending contract', async () => {
            const existing = { id: '1', requesterId: mockUser, clauses: ['Old'], status: ContractStatus.CREATED };
            repositoryMock.findOne.mockResolvedValue(existing);
            repositoryMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.create(mockUser, { clauses: mockClauses });
            expect(result.clauses).toEqual(mockClauses);
        });

        it('should reset status to CREATED if updating a SIGNED contract', async () => {
            const existingSignedContract = {
                id: '1',
                requesterId: mockUser,
                status: ContractStatus.SIGNED_REQUESTER,
                clauses: ['old clause'],
                signedAtRequester: new Date(),
            };

            repositoryMock.findOne.mockResolvedValue(existingSignedContract);
            repositoryMock.save.mockImplementation((contract) => Promise.resolve(contract));

            const result = await service.create(mockUser, { clauses: mockClauses });

            expect(result.status).toBe(ContractStatus.CREATED);
            expect(result.signedAtRequester).toBeNull();
            expect(result.clauses).toEqual(mockClauses);
            expect(repositoryMock.save).toHaveBeenCalled();
        });
    });

    describe('sign', () => {
        it('should sign a created contract', async () => {
            const contract = { id: '1', requesterId: mockUser, status: ContractStatus.CREATED };
            repositoryMock.findOne.mockResolvedValue(contract);
            repositoryMock.save.mockImplementation((entity) => Promise.resolve(entity));

            const result = await service.sign(mockUser);
            expect(result.status).toBe(ContractStatus.SIGNED_REQUESTER);
            expect(result.signedAtRequester).toBeDefined();
        });

        it('should throw NotFound if no pending contract', async () => {
            repositoryMock.findOne.mockResolvedValue(null);
            await expect(service.sign(mockUser)).rejects.toThrow(NotFoundException);
        });
    });
});
