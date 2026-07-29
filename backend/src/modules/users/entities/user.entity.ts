import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column({ unique: true })
  firebaseUid: string;

  @Column({ nullable: true })
  displayName: string;

  @Column({ nullable: true })
  photoUrl: string;

  @Column({ type: 'date', nullable: true })
  birthday: Date;

  @Column({ type: 'date', nullable: true })
  relationshipStartDate: Date;

  @Column({ nullable: true })
  zodiacSign: string;

  @Column({ default: 'vi' })
  language: string;

  @Column({ nullable: true })
  partnerId: string;

  @Column({ nullable: true })
  coupleType: string;

  @Column({ default: false })
  vowTaken: boolean;

  @Column({ default: true })
  isGhostModeEnabled: boolean;

  @Column({ type: 'enum', enum: ['user', 'admin'], default: 'user' })
  role: 'user' | 'admin';

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
