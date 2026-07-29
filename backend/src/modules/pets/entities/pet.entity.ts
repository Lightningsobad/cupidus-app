import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum PetSpecies {
    CAT = 'cat',
    DOG = 'dog',
    BUNNY = 'bunny',
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

    @Column({ type: 'timestamp', nullable: true })
    lastInteraction: Date;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
