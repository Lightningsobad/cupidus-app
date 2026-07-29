import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DataExportService } from './data-export.service';
import { DataExportController } from './data-export.controller';
import { DataExport } from './entities/data-export.entity';
import { User } from '../users/entities/user.entity';
import { LoveContract } from '../love-contracts/entities/love-contract.entity';
import { Message } from '../messages/entities/message.entity';
import { Expense } from '../expenses/entities/expense.entity';
import { DreamJar } from '../dream-jar/entities/dream-jar.entity';
import { Contribution } from '../dream-jar/entities/contribution.entity';
import { Vibe } from '../vibes/entities/vibe.entity';
import { TimelineEvent } from '../timeline/entities/timeline-event.entity';
import { GalleryItem } from '../gallery/entities/gallery-item.entity';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([
            DataExport,
            User,
            LoveContract,
            Message,
            Expense,
            DreamJar,
            Contribution,
            Vibe,
            TimelineEvent,
            GalleryItem,
            GalleryItem,
        ]),
        UsersModule,
    ],
    controllers: [DataExportController],
    providers: [DataExportService],
    exports: [DataExportService],
})
export class DataExportModule { }
