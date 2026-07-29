import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

export enum ExpenseCategory {
    FOOD = 'food',
    DATE = 'date',
    TRAVEL = 'travel',
    SHOPPING = 'shopping',
    OTHER = 'other',
}

@Entity('expenses')
export class Expense {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    coupleId: string;

    @Column()
    userId: string;

    @Column({ type: 'enum', enum: ExpenseCategory, default: ExpenseCategory.OTHER })
    category: ExpenseCategory;

    @Column({ type: 'decimal', precision: 15, scale: 2 })
    amount: number;

    @Column({ nullable: true })
    description: string;

    @Column({ type: 'date' })
    date: string;

    @CreateDateColumn()
    createdAt: Date;
}
