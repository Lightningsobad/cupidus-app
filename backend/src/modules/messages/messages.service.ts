import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Message } from './entities/message.entity';

@Injectable()
export class MessagesService {
    constructor(
        @InjectRepository(Message)
        private messagesRepository: Repository<Message>,
    ) { }

    async create(createMessageDto: Partial<Message>): Promise<Message> {
        const message = this.messagesRepository.create(createMessageDto);
        return this.messagesRepository.save(message);
    }

    async findAll(senderId: string, receiverId: string, page: number = 1, limit: number = 20) {
        const skip = (page - 1) * limit;
        return this.messagesRepository.find({
            where: [
                { senderId, receiverId },
                { senderId: receiverId, receiverId: senderId },
            ],
            order: { createdAt: 'DESC' }, // Newest first for chat history usually, then reversed in UI
            skip,
            take: limit,
        });
    }

    async markAsSeen(receiverId: string, senderId: string) {
        // Update all messages sent by senderId to receiverId that are not yet seen
        // "I (receiver) have seen messages from sender"
        return this.messagesRepository.update(
            {
                senderId: senderId,
                receiverId: receiverId,
                status: 'sent' // Update 'sent' or 'delivered' to 'seen'. Simplified to just not 'seen' if needed. 
            },
            {
                status: 'seen',
                readAt: new Date()
            }
        );
    }

    async markAsDelivered(receiverId: string, senderId: string) {
        // Update all 'sent' messages to 'delivered'
        return this.messagesRepository.update(
            {
                senderId: senderId,
                receiverId: receiverId,
                status: 'sent'
            },
            {
                status: 'delivered'
            }
        );
    }
}
