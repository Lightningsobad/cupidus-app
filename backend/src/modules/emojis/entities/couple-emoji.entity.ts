import { Entity, Column, PrimaryColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('couple_emojis')
export class CoupleEmoji {
    @PrimaryColumn()
    coupleId: string;

    @Column({ default: 'mochi-cat' })
    activePackId: string;

    @Column('simple-array', { default: 'mochi-cat,baby-dino' })
    downloadedPackIds: string[];

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
