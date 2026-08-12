import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LoveContract } from './entities/love-contract.entity';
import { User } from '../users/entities/user.entity';
import { LoveContractsService } from './love-contracts.service';
import { LoveContractsController } from './love-contracts.controller';

import { UsersModule } from '../users/users.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([LoveContract, User]),
        UsersModule,
    ],
    controllers: [LoveContractsController],
    providers: [LoveContractsService],
    exports: [LoveContractsService],
})
export class LoveContractsModule { }
