import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum ContractStatus {
    CREATED = 'created',
    SIGNED_REQUESTER = 'signed_requester',
    SIGNED_PARTNER = 'signed_partner',
}

@Entity('love_contracts')
export class LoveContract {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ type: 'uuid' })
    requesterId: string;

    @Column({ type: 'uuid', nullable: true })
    partnerId: string;

    @Column('jsonb', { default: [] })
    clauses: string[];

    @Column({
        type: 'enum',
        enum: ContractStatus,
        default: ContractStatus.CREATED,
    })
    status: ContractStatus;

    @Column({ type: 'timestamp', nullable: true })
    signedAtRequester: Date | null;

    @Column({ type: 'timestamp', nullable: true })
    signedAtPartner: Date | null;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
