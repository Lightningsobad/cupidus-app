import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LoveContract, ContractStatus } from './entities/love-contract.entity';
import { CreateContractDto } from './dto/create-contract.dto';

@Injectable()
export class LoveContractsService {
    constructor(
        @InjectRepository(LoveContract)
        private contractRepository: Repository<LoveContract>,
    ) { }

    async create(userId: string, createContractDto: CreateContractDto): Promise<LoveContract> {
        // Check if user already has an active contract (simplified logic: pending or recently created)
        const existing = await this.contractRepository.findOne({
            where: [
                { requesterId: userId, status: ContractStatus.SIGNED_REQUESTER },
                { requesterId: userId, status: ContractStatus.CREATED },
            ],
        });

        if (existing) {
            if (existing.status === ContractStatus.SIGNED_REQUESTER) {
                // If already signed, we cannot modify clauses unless we reset signature? 
                // For now, prevent modification.
                // Actually, the iOS app calls create() then sign().
                // If the user comes back and edits, they have to re-sign.
                // So we should ALLOW update but RESET status to CREATED.
                existing.status = ContractStatus.CREATED;
                existing.signedAtRequester = null;
            }
            existing.clauses = createContractDto.clauses;
            return this.contractRepository.save(existing);
        }

        const contract = this.contractRepository.create({
            requesterId: userId,
            clauses: createContractDto.clauses,
            status: ContractStatus.CREATED,
        });

        return this.contractRepository.save(contract);
    }

    async sign(userId: string): Promise<LoveContract> {
        const contract = await this.contractRepository.findOne({
            where: { requesterId: userId, status: ContractStatus.CREATED },
        });

        if (!contract) {
            // Maybe it's already signed?
            const signed = await this.contractRepository.findOne({
                where: { requesterId: userId, status: ContractStatus.SIGNED_REQUESTER }
            });
            if (signed) return signed;

            throw new NotFoundException('No pending contract found to sign');
        }

        contract.status = ContractStatus.SIGNED_REQUESTER;
        contract.signedAtRequester = new Date();

        return this.contractRepository.save(contract);
    }

    async getMyContract(userId: string): Promise<LoveContract | null> {
        return this.contractRepository.findOne({
            where: [
                { requesterId: userId },
                { partnerId: userId }
            ],
            order: { createdAt: 'DESC' } // Get latest
        });
    }
}
