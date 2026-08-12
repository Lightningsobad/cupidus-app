import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LoveContract, ContractStatus } from './entities/love-contract.entity';
import { CreateContractDto } from './dto/create-contract.dto';
import { User } from '../users/entities/user.entity';

@Injectable()
export class LoveContractsService {
    constructor(
        @InjectRepository(LoveContract)
        private contractRepository: Repository<LoveContract>,
        @InjectRepository(User)
        private usersRepository: Repository<User>,
    ) { }

    // Single lookup shared by getMyContract() and sign(). Precedence order is
    // load-bearing: a caller who owns a contract must always resolve to their
    // own row before the partner fallback runs (ADR-019a). This must be two
    // separately ordered queries, not one combined OR query ordered by
    // createdAt alone: a caller can be requester on one row and partner on a
    // newer row (re-pairing), and a single createdAt-DESC OR query would pick
    // the newer partnered row over the caller's own, older row.
    private async findContractForUser(userId: string): Promise<LoveContract | null> {
        const ownedRow = await this.contractRepository.findOne({
            where: { requesterId: userId },
            order: { createdAt: 'DESC' },
        });

        if (ownedRow) {
            return ownedRow;
        }

        const partneredRow = await this.contractRepository.findOne({
            where: { partnerId: userId },
            order: { createdAt: 'DESC' },
        });

        if (partneredRow) {
            return partneredRow;
        }

        const user = await this.usersRepository.findOne({ where: { id: userId } });
        if (!user || !user.partnerId) {
            return null;
        }

        const partnerContract = await this.contractRepository.findOne({
            where: { requesterId: user.partnerId },
            order: { createdAt: 'DESC' },
        });

        if (!partnerContract) {
            return null;
        }

        if (!partnerContract.partnerId) {
            partnerContract.partnerId = userId;
            return this.contractRepository.save(partnerContract);
        }

        return partnerContract;
    }

    async create(userId: string, createContractDto: CreateContractDto): Promise<LoveContract> {
        const user = await this.usersRepository.findOne({ where: { id: userId } });
        const existing = await this.findContractForUser(userId);

        if (existing) {
            if (existing.requesterId !== userId) {
                // Caller is the partner of an existing contract: partners never
                // write clauses (ADR-019e). This is the durable server-side
                // backstop for the client's sign-only path.
                throw new ConflictException('Only the requester can edit contract clauses');
            }

            if (existing.status !== ContractStatus.CREATED) {
                // Editing clauses on a signed contract resets both signatures,
                // not just the requester's (ADR-019f).
                existing.status = ContractStatus.CREATED;
                existing.signedAtRequester = null;
                existing.signedAtPartner = null;
            }

            if (!existing.partnerId && user?.partnerId) {
                existing.partnerId = user.partnerId;
            }

            existing.clauses = createContractDto.clauses;
            return this.contractRepository.save(existing);
        }

        const contract = this.contractRepository.create({
            requesterId: userId,
            partnerId: user?.partnerId ?? undefined,
            clauses: createContractDto.clauses,
            status: ContractStatus.CREATED,
        });

        return this.contractRepository.save(contract);
    }

    async sign(userId: string): Promise<LoveContract> {
        const contract = await this.findContractForUser(userId);

        if (!contract) {
            throw new NotFoundException('No pending contract found to sign');
        }

        if (contract.requesterId === userId) {
            if (contract.signedAtRequester) {
                return contract;
            }
            contract.signedAtRequester = new Date();
            contract.status = ContractStatus.SIGNED_REQUESTER;
        } else {
            if (contract.signedAtPartner) {
                return contract;
            }
            contract.signedAtPartner = new Date();
            contract.status = ContractStatus.SIGNED_PARTNER;
        }

        return this.contractRepository.save(contract);
    }

    async getMyContract(userId: string): Promise<LoveContract | null> {
        return this.findContractForUser(userId);
    }
}
