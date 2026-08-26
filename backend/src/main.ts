import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as admin from 'firebase-admin';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  // Initialize Firebase Admin if service-account.json is present (for push notifications)
  if (!admin.apps.length) {
    try {
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      const serviceAccount = require('../service-account.json');
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    } catch {
      // Firebase service account not present, continuing with JWT auth
    }
  }

  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({ whitelist: true }));

  const config = new DocumentBuilder()
    .setTitle('Cupid App Backend Integration API')
    .setDescription('The Cupid API description for Android, iOS, and Web clients.')
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter JWT access token',
        in: 'header',
      },
      'jwt',
    )
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter JWT access token',
        in: 'header',
      },
      'firebase-jwt',
    )
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document);

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
