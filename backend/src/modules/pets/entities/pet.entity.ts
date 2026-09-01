import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum PetSpecies {
    CAT = 'cat',
    DOG = 'dog',
    BUNNY = 'bunny',
    BEAR = 'bear',
    CHICK = 'chick',
    PANDA = 'panda',
    BUN = 'bun',
    BO = 'bo',
    SUA = 'sua',
    MOCHI = 'mochi',
    XOAI = 'xoai',
    KEM = 'kem',
    SHIBA = 'shiba',
}

@Entity('pets')
export class Pet {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ unique: true })
    coupleId: string;

    @Column({ type: 'enum', enum: PetSpecies })
    species: PetSpecies;

    @Column()
    name: string;

    @Column({ type: 'int', default: 50 })
    happiness: number;

    @Column({ type: 'int', default: 1 })
    level: number;

    @Column({ type: 'int', default: 0 })
    totalInteractions: number;

    @Column({ type: 'int', default: 0 })
    streak: number;

    @Column({ type: 'date', nullable: true })
    lastStreakDate: string | null;

    @Column({ type: 'timestamp', nullable: true })
    lastInteraction: Date;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
