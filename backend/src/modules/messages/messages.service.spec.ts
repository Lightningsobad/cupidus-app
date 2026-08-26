import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { MessagesService } from './messages.service';
import { Message } from './entities/message.entity';

describe('MessagesService', () => {
    let service: MessagesService;
    let repository: jest.Mocked<Repository<Message>>;

    const mockMessagesRepository = {
        create: jest.fn(),
        save: jest.fn(),
        find: jest.fn(),
        update: jest.fn(),
    };

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                MessagesService,
                {
                    provide: getRepositoryToken(Message),
                    useValue: mockMessagesRepository,
                },
            ],
        }).compile();

        service = module.get<MessagesService>(MessagesService);
        repository = module.get(getRepositoryToken(Message));
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('create', () => {
        it('should create and save a message', async () => {
            const dto = { content: 'hello', senderId: 'user1', receiverId: 'user2' };
            const created = { id: 'msg1', ...dto } as Message;
            repository.create.mockReturnValue(created);
            repository.save.mockResolvedValue(created);

            const result = await service.create(dto);
            expect(repository.create).toHaveBeenCalledWith(dto);
            expect(repository.save).toHaveBeenCalledWith(created);
            expect(result).toEqual(created);
        });
    });

    describe('findAll', () => {
        it('should find messages between two users', async () => {
            const messages = [{ id: 'msg1' }, { id: 'msg2' }] as Message[];
            repository.find.mockResolvedValue(messages);

            const result = await service.findAll('user1', 'user2', 1, 20);
            expect(repository.find).toHaveBeenCalledWith({
                where: [
                    { senderId: 'user1', receiverId: 'user2' },
                    { senderId: 'user2', receiverId: 'user1' },
                ],
                order: { createdAt: 'DESC' },
                skip: 0,
                take: 20,
            });
            expect(result).toEqual(messages);
        });
    });

    describe('markAsSeen', () => {
        it('should update messages with status sent or delivered to seen with readAt timestamp', async () => {
            repository.update.mockResolvedValue({ affected: 2, raw: [], generatedMaps: [] });

            await service.markAsSeen('receiver1', 'sender1');

            expect(repository.update).toHaveBeenCalledWith(
                {
                    senderId: 'sender1',
                    receiverId: 'receiver1',
                    status: In(['sent', 'delivered']),
                },
                expect.objectContaining({
                    status: 'seen',
                    readAt: expect.any(Date),
                }),
            );
        });
    });

    describe('markAsDelivered', () => {
        it('should update messages with status sent to delivered', async () => {
            repository.update.mockResolvedValue({ affected: 1, raw: [], generatedMaps: [] });

            await service.markAsDelivered('receiver1', 'sender1');

            expect(repository.update).toHaveBeenCalledWith(
                {
                    senderId: 'sender1',
                    receiverId: 'receiver1',
                    status: 'sent',
                },
                {
                    status: 'delivered',
                },
            );
        });
    });
});
