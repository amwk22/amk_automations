// src/dashboard/dashboard.module.ts
import { Module } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { DashboardController } from './dashboard.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';
import { EnergyLog } from 'src/energylog/entities/energylog.entity';
import { SystemSettings } from 'src/systemsettings/entities/systemsetting.entity';

@Module({
  imports: [TypeOrmModule.forFeature([SmartPlug, EnergyLog, SystemSettings])],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
