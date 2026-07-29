import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, AfterLoad } from 'typeorm';

export enum DreamJarStatus {
    ACTIVE = 'active',
    COMPLETED = 'completed',
    ARCHIVED = 'archived',
}

@Entity('dream_jars')
export class DreamJar {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    coupleId: string;

    @Column()
    name: string;

    @Column({ type: 'decimal', precision: 15, scale: 2 })
    targetAmount: number;

    @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
    currentAmount: number;

    @Column({ type: 'timestamp', nullable: true })
    deadline: Date;

    @Column({ default: 'VND' })
    currency: string;

    @Column({ type: 'enum', enum: DreamJarStatus, default: DreamJarStatus.ACTIVE })
    status: DreamJarStatus;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;

    progress: number;

    @AfterLoad()
    computeProgress() {
        if (!this.targetAmount || this.targetAmount === 0) {
            this.progress = 0;
        } else {
            this.progress = Math.min(100, Math.round((Number(this.currentAmount) / Number(this.targetAmount)) * 100));
        }
    }
}
