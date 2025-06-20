// src/smartplug/smartplug.module.ts

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SmartplugService } from './smartplug.service';
import { SmartplugController } from './smartplug.controller';
import { SmartPlug } from './entities/smartplug.entity';
import { Users } from 'src/users/entities/user.entity';
import { EnergyLog } from 'src/energylog/entities/energylog.entity';

@Module({
  imports: [TypeOrmModule.forFeature([SmartPlug, Users, EnergyLog])],
  controllers: [SmartplugController],
  providers: [SmartplugService],
})
export class SmartplugModule {}
