import { ApiProperty } from '@nestjs/swagger';
import { LoveContract, ContractStatus } from '../entities/love-contract.entity';

export type LoveContractViewerRole = 'requester' | 'partner';

export class LoveContractResponseDto {
    @ApiProperty()
    id: string;

    @ApiProperty({ type: [String] })
    clauses: string[];

    @ApiProperty({ enum: ContractStatus })
    status: ContractStatus;

    @ApiProperty({ type: Date, nullable: true })
    signedAtRequester: Date | null;

    @ApiProperty({ type: Date, nullable: true })
    signedAtPartner: Date | null;

    @ApiProperty({ enum: ['requester', 'partner'] })
    viewerRole: LoveContractViewerRole;

    @ApiProperty()
    requesterId: string;

    @ApiProperty({ type: String, nullable: true })
    partnerId: string | null;

    @ApiProperty()
    createdAt: Date;

    @ApiProperty()
    updatedAt: Date;

    static from(contract: LoveContract, viewerId: string): LoveContractResponseDto {
        const dto = new LoveContractResponseDto();
        dto.id = contract.id;
        dto.clauses = contract.clauses;
        dto.status = contract.status;
        dto.signedAtRequester = contract.signedAtRequester;
        dto.signedAtPartner = contract.signedAtPartner;
        dto.viewerRole = contract.requesterId === viewerId ? 'requester' : 'partner';
        dto.requesterId = contract.requesterId;
        dto.partnerId = contract.partnerId;
        dto.createdAt = contract.createdAt;
        dto.updatedAt = contract.updatedAt;
        return dto;
    }
}
