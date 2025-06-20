// src/requestqueue/requestqueue.module.ts

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RequestqueueService } from './requestqueue.service';
import { RequestqueueController } from './requestqueue.controller';
import { RequestQueue } from './entities/requestqueue.entity';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';
import { SystemSettings } from 'src/systemsettings/entities/systemsetting.entity';
import { PriorityControl } from 'src/prioritycontrol/entities/prioritycontrol.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      RequestQueue,
      SmartPlug,
      SystemSettings,
      PriorityControl,
    ]),
  ],
  controllers: [RequestqueueController],
  providers: [RequestqueueService],
})
export class RequestqueueModule {}
