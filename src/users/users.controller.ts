import { Controller, Post, Body } from '@nestjs/common';
import { SendMailProducerService } from 'src/mails/jobs/sendMail-producer.service';
import { CreateUserDto } from './dto/create-user.dto';

@Controller('users')
export class UsersController {
  constructor(private sendMailProducerService: SendMailProducerService) {}

  @Post()
  async create(@Body() createUserDto: CreateUserDto) {
    await this.sendMailProducerService.sendMail(createUserDto);

    return createUserDto;
  }
}
