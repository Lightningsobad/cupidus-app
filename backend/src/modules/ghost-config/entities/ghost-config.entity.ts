import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum Penalty {
    EMOJI_STORM = 'emoji_storm',
    NOISE = 'noise',
    NONE = 'none',
}

export enum ConfigStatus {
    ACTIVE = 'active',
    PENDING_APPROVAL = 'pending_approval',
    REJECTED = 'rejected',
    SUPERSEDED = 'superseded',
}

@Entity('ghost_configs')
export class GhostConfig {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    coupleId: string;

    @Column({ type: 'int', default: 10 })
    timeoutMinutes: number;

    @Column({ type: 'enum', enum: Penalty, default: Penalty.NONE })
    penalty: Penalty;

    @Column({ type: 'boolean', default: true })
    publicCountdown: boolean;

    @Column()
    proposedBy: string;

    @Column({ nullable: true })
    approvedBy: string;

    @Column({ type: 'enum', enum: ConfigStatus, default: ConfigStatus.PENDING_APPROVAL })
    status: ConfigStatus;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
