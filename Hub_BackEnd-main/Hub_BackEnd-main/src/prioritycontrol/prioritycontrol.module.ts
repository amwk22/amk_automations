// src/prioritycontrol/prioritycontrol.module.ts

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PriorityControlService } from './prioritycontrol.service';
import { PriorityControlController } from './prioritycontrol.controller';
import { PriorityControl } from './entities/prioritycontrol.entity';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';
import { RequestQueue } from 'src/requestqueue/entities/requestqueue.entity';
@Module({
  imports: [
    TypeOrmModule.forFeature([PriorityControl, RequestQueue, SmartPlug]),
  ],
  controllers: [PriorityControlController],
  providers: [PriorityControlService],
})
export class PriorityControlModule {}
