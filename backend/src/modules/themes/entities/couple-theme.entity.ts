import { Entity, Column, PrimaryColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('couple_themes')
export class CoupleTheme {
    @PrimaryColumn()
    coupleId: string;

    @Column({ default: 'nebula' })
    activeThemeId: string;

    @Column('simple-array', { default: 'nebula' })
    ownedThemeIds: string[];

    @Column({ type: 'int', default: 1240 })
    heartsBalance: number;

    @Column({ type: 'varchar', nullable: true })
    pendingThemeId: string | null;

    @Column({ type: 'varchar', nullable: true })
    pendingRequestedBy: string | null;

    @Column({ type: 'timestamp', nullable: true })
    pendingRequestedAt: Date | null;

    @Column({ type: 'varchar', nullable: true })
    wishlistThemeId: string | null;

    @Column({ type: 'varchar', nullable: true })
    wishlistSavedBy: string | null;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
