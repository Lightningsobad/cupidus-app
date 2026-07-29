import { Test, TestingModule } from '@nestjs/testing';
import { DreamJarController } from './dream-jar.controller';
import { DreamJarService } from './dream-jar.service';

describe('DreamJarController', () => {
    let controller: DreamJarController;
    let serviceMock: any;

    const mockReq = { user: { id: 'user-aaa' } };
    const mockJar = { id: 'jar-1', name: 'Bali Trip', coupleId: 'user-aaa:user-bbb', currentAmount: 0, targetAmount: 50000000 };

    beforeEach(async () => {
        serviceMock = {
            create: jest.fn().mockResolvedValue(mockJar),
            findAll: jest.fn().mockResolvedValue([mockJar]),
            findOne: jest.fn().mockResolvedValue(mockJar),
            update: jest.fn().mockResolvedValue({ ...mockJar, name: 'Updated' }),
            remove: jest.fn().mockResolvedValue(undefined),
            addContribution: jest.fn().mockResolvedValue({ id: 'c-1', amount: 1000000 }),
            getContributions: jest.fn().mockResolvedValue([]),
        };

        const module: TestingModule = await Test.createTestingModule({
            controllers: [DreamJarController],
            providers: [{ provide: DreamJarService, useValue: serviceMock }],
        }).compile();

        controller = module.get<DreamJarController>(DreamJarController);
    });

    it('should create a jar', async () => {
        const dto = { name: 'Bali Trip', targetAmount: 50000000 };
        const result = await controller.create(mockReq, dto);
        expect(serviceMock.create).toHaveBeenCalledWith('user-aaa', dto);
        expect(result.name).toBe('Bali Trip');
    });

    it('should return all jars with default pagination', async () => {
        const result = await controller.findAll(mockReq);
        expect(serviceMock.findAll).toHaveBeenCalledWith('user-aaa', 50, 0);
        expect(result).toEqual([mockJar]);
    });

    it('should return single jar', async () => {
        const result = await controller.findOne(mockReq, 'jar-1');
        expect(serviceMock.findOne).toHaveBeenCalledWith('user-aaa', 'jar-1');
        expect(result.id).toBe('jar-1');
    });

    it('should update jar', async () => {
        const dto = { name: 'Updated' };
        const result = await controller.update(mockReq, 'jar-1', dto);
        expect(serviceMock.update).toHaveBeenCalledWith('user-aaa', 'jar-1', dto);
        expect(result.name).toBe('Updated');
    });

    it('should delete jar', async () => {
        await controller.remove(mockReq, 'jar-1');
        expect(serviceMock.remove).toHaveBeenCalledWith('user-aaa', 'jar-1');
    });

    it('should add contribution', async () => {
        const dto = { amount: 1000000 };
        const result = await controller.addContribution(mockReq, 'jar-1', dto);
        expect(serviceMock.addContribution).toHaveBeenCalledWith('user-aaa', 'jar-1', dto);
        expect(result.amount).toBe(1000000);
    });

    it('should get contributions', async () => {
        const result = await controller.getContributions(mockReq, 'jar-1');
        expect(serviceMock.getContributions).toHaveBeenCalledWith('user-aaa', 'jar-1', 50, 0);
        expect(result).toEqual([]);
    });
});
