import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

export enum TimelineEventType {
    MILESTONE = 'milestone',
    MEMORY = 'memory',
    SYSTEM = 'system',
}

@Entity('timeline_events')
export class TimelineEvent {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    coupleId: string;

    @Column({ type: 'enum', enum: TimelineEventType, default: TimelineEventType.MEMORY })
    type: TimelineEventType;

    @Column()
    title: string;

    @Column({ nullable: true })
    description: string;

    @Column({ type: 'text', nullable: true })
    photoUrl: string;

    @Column({ nullable: true })
    icon: string;

    @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
    createdAt: Date;
}
