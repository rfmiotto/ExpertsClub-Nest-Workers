import { Module } from '@nestjs/common';
import { MailsModule } from 'src/mails/mails.module';
import { UsersController } from './users.controller';

@Module({
  imports: [MailsModule],
  controllers: [UsersController],
  providers: [],
})
export class UsersModule {}
