import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { DreamJar } from './dream-jar.entity';

@Entity('contributions')
export class Contribution {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    dreamJarId: string;

    @Column()
    userId: string;

    @Column({ type: 'decimal', precision: 15, scale: 2 })
    amount: number;

    @Column({ nullable: true })
    note: string;

    @ManyToOne(() => DreamJar)
    @JoinColumn({ name: 'dreamJarId' })
    dreamJar: DreamJar;

    @CreateDateColumn()
    createdAt: Date;
}
