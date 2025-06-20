// src/energylog/energylog.module.ts

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EnergyLogService } from './energylog.service';
import { EnergyLogController } from './energylog.controller';
import { EnergyLog } from './entities/energylog.entity';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';
import { SystemSettings } from 'src/systemsettings/entities/systemsetting.entity';

@Module({
  imports: [TypeOrmModule.forFeature([EnergyLog, SmartPlug, SystemSettings])],
  controllers: [EnergyLogController],
  providers: [EnergyLogService],
})
export class EnergyLogModule {}
