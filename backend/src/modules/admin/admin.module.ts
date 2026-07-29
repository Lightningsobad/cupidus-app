import { Module, OnModuleInit } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminService } from './admin.service';
import { AdminController } from './admin.controller';
import { AdminConfig } from './entities/admin-config.entity';
import { User } from '../users/entities/user.entity';
import { DataExport } from '../data-export/entities/data-export.entity';

@Module({
    imports: [TypeOrmModule.forFeature([AdminConfig, User, DataExport])],
    controllers: [AdminController],
    providers: [AdminService],
    exports: [AdminService],
})
export class AdminModule implements OnModuleInit {
    constructor(private readonly adminService: AdminService) { }

    async onModuleInit() {
        await this.adminService.seedDefaults();
    }
}
