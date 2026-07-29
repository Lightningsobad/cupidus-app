import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('gallery_items')
export class GalleryItem {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    userId: string;

    @Column()
    filename: string;

    @Column({ nullable: true })
    thumbnailUrl: string;

    @Column({ default: true })
    isEncrypted: boolean;

    @Column({ nullable: true })
    encryptionKeyId: string;

    @Column({ nullable: true })
    mimeType: string;

    @CreateDateColumn()
    createdAt: Date;
}
