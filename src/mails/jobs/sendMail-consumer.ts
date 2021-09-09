import { MailerService } from '@nestjs-modules/mailer';
import {
  OnQueueActive,
  OnQueueCompleted,
  OnQueueProgress,
  Process,
  Processor,
} from '@nestjs/bull';
import { Job } from 'bull';
import { CreateUserDto } from 'src/users/dto/create-user.dto';

@Processor('sendMail-queue')
class SendMailConsumer {
  constructor(private mailService: MailerService) {}

  @Process('sendMail-job')
  async sendMailJob(job: Job<CreateUserDto>) {
    const { data } = job;

    await this.mailService.sendMail({
      to: data.email,
      from: 'Arel Team <arel@support.com>',
      subject: 'Seja bem vindo(a)!',
      text: `Olá ${data.name}, seu cadastro foi realizado com sucesso!`,
    });
  }

  @OnQueueCompleted()
  onCompleted(job: Job) {
    console.log(`On completed ${job.name}`);
  }

  @OnQueueProgress()
  onProgress(job: Job) {
    console.log(`On progress ${job.name}`);
  }

  @OnQueueActive()
  onActive(job: Job) {
    console.log(`On active ${job.name}`);
  }
}

export { SendMailConsumer };
