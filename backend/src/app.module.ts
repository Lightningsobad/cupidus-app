import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EventEmitterModule } from '@nestjs/event-emitter';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';
import { UploadsModule } from './modules/uploads/uploads.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { LoveContractsModule } from './modules/love-contracts/love-contracts.module';
import { InvitationsModule } from './modules/invitations/invitations.module';
import { MessagesModule } from './modules/messages/messages.module';
import { AlarmsModule } from './modules/alarms/alarms.module';
import { VibesModule } from './modules/vibes/vibes.module';
import { GhostConfigModule } from './modules/ghost-config/ghost-config.module';
import { PetsModule } from './modules/pets/pets.module';
import { GalleryModule } from './modules/gallery/gallery.module';
import { TimelineModule } from './modules/timeline/timeline.module';
import { DreamJarModule } from './modules/dream-jar/dream-jar.module';
import { ExpensesModule } from './modules/expenses/expenses.module';
import { DataExportModule } from './modules/data-export/data-export.module';
import { AdminModule } from './modules/admin/admin.module';
import { ZodiacModule } from './modules/zodiac/zodiac.module';
import { MailModule } from './modules/mail/mail.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    EventEmitterModule.forRoot(),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.POSTGRES_HOST || 'localhost',
      port: parseInt(process.env.POSTGRES_PORT || '5432', 10),
      username: process.env.POSTGRES_USER || 'postgres',
      password: process.env.POSTGRES_PASSWORD || 'password',
      database: process.env.POSTGRES_DB || 'cupid',
      autoLoadEntities: true,
      synchronize: true, // Auto-create tables for dev
    }),
    AuthModule,
    UsersModule,
    LoveContractsModule,
    InvitationsModule,
    UploadsModule,
    ServeStaticModule.forRoot({
      rootPath: join(process.cwd(), 'uploads'),
      serveRoot: '/uploads',
    }),
    MessagesModule,
    AlarmsModule,
    VibesModule,
    GhostConfigModule,
    PetsModule,
    GalleryModule,
    TimelineModule,
    DreamJarModule,
    ExpensesModule,
    DataExportModule,
    AdminModule,
    ZodiacModule,
    MailModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
