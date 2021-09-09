import { MailerModule } from '@nestjs-modules/mailer';
import { BullModule } from '@nestjs/bull';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { UsersController } from './users/users.controller';
import { UsersModule } from './users/users.module';
import { MailsModule } from './mails/mails.module';

@Module({
  imports: [ConfigModule.forRoot(), UsersModule, MailsModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
