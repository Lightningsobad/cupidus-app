import { Test, TestingModule } from '@nestjs/testing';
import { DataExportController } from './data-export.controller';
import { DataExportService } from './data-export.service';
import { ExportStatus } from './entities/data-export.entity';

import { UsersService } from '../users/users.service';

describe('DataExportController', () => {
    let controller: DataExportController;
    let serviceMock: any;
    let usersServiceMock: any;

    const mockReq = { user: { id: 'user-aaa', uid: 'user-aaa' } };
    const mockExport = { id: 'export-1', userId: 'user-aaa', status: ExportStatus.COMPLETED };

    beforeEach(async () => {
        usersServiceMock = {
            findByFirebaseUid: jest.fn().mockResolvedValue({ id: 'user-aaa' }),
        };
        serviceMock = {
            requestExport: jest.fn().mockResolvedValue(mockExport),
            getExports: jest.fn().mockResolvedValue([mockExport]),
            getExportFile: jest.fn().mockResolvedValue('/path/to/file.zip'),
        };

        const module: TestingModule = await Test.createTestingModule({
            controllers: [DataExportController],
            providers: [
                { provide: DataExportService, useValue: serviceMock },
                { provide: UsersService, useValue: usersServiceMock },
            ],
        }).compile();

        controller = module.get<DataExportController>(DataExportController);
    });

    it('should request an export', async () => {
        const result = await controller.requestExport(mockReq);
        expect(serviceMock.requestExport).toHaveBeenCalledWith('user-aaa');
        expect(result.status).toBe(ExportStatus.COMPLETED);
    });

    it('should list exports', async () => {
        const result = await controller.getExports(mockReq);
        expect(serviceMock.getExports).toHaveBeenCalledWith('user-aaa');
        expect(result).toEqual([mockExport]);
    });
});
