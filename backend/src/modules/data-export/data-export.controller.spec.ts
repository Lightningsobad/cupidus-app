import { Test, TestingModule } from '@nestjs/testing';
import { DataExportController } from './data-export.controller';
import { DataExportService } from './data-export.service';
import { ExportStatus } from './entities/data-export.entity';

describe('DataExportController', () => {
    let controller: DataExportController;
    let serviceMock: any;

    const mockReq = { user: { id: 'user-aaa' } };
    const mockExport = { id: 'export-1', userId: 'user-aaa', status: ExportStatus.COMPLETED };

    beforeEach(async () => {
        serviceMock = {
            requestExport: jest.fn().mockResolvedValue(mockExport),
            getExports: jest.fn().mockResolvedValue([mockExport]),
            getExportFile: jest.fn().mockResolvedValue('/path/to/file.zip'),
        };

        const module: TestingModule = await Test.createTestingModule({
            controllers: [DataExportController],
            providers: [{ provide: DataExportService, useValue: serviceMock }],
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
