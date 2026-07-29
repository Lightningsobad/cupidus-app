import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('messages')
export class Message {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    content: string;

    @Column({ default: 'text' }) // 'text', 'image', 'video', 'ghost'
    type: string;

    @Column({ name: 'sender_id' })
    senderId: string;

    @Column({ name: 'receiver_id' })
    receiverId: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'sender_id' })
    sender: User;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'receiver_id' })
    receiver: User;

    @Column({ default: 'sent' }) // 'sent', 'delivered', 'seen'
    status: string;

    @Column({ type: 'timestamp', nullable: true })
    readAt: Date;

    @CreateDateColumn()
    createdAt: Date;
}
