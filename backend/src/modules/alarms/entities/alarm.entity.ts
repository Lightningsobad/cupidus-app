import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity()
export class Alarm {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ type: 'timestamp' })
    time: Date;

    @Column({ default: 'Nhắc nhở đồng bộ' })
    description: string;

    // Days of week repeat: [1, 2, 3, 4, 5, 6, 7] (1=Monday..7=Sunday)
    @Column('simple-array', { default: '' })
    weekdays: string[];

    @Column({ default: true })
    isActive: boolean; // Is the alarm enabled?

    // Target state when user requests to toggle on/off: pending partner confirmation
    @Column({ type: 'boolean', nullable: true })
    targetIsActive: boolean | null;

    // 'pending_confirmation' | 'pending_toggle' | 'pending_deletion' | 'scheduled' | 'ringing' | 'stopped'
    @Column({ default: 'pending_confirmation' })
    status: string;

    @Column()
    requesterId: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'requesterId' })
    requester: User;

    @Column()
    partnerId: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'partnerId' })
    partner: User;

    // Use JSON to store who has stopped the ringing alarm: ["userId1", "userId2"]
    @Column('simple-array', { default: '' })
    stopperIds: string[];

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
