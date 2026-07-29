import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, JoinColumn, CreateDateColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum Mood {
    HAPPY = 'happy',
    SAD = 'sad',
    ANGRY = 'angry',
    HORNY = 'horny',
    TIRED = 'tired',
}

@Entity('vibes')
export class Vibe {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    userId: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'userId' })
    user: User;

    @Column({ type: 'enum', enum: Mood })
    mood: Mood;

    @Column({ nullable: true })
    note: string;

    @CreateDateColumn()
    createdAt: Date;
}
