import { Module } from '@nestjs/common';
import { PlugScheduleService } from './plug-schedule.service';
import { PlugScheduleController } from './plug-schedule.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PlugSchedule } from './entities/plug-schedule.entity';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';

@Module({
  imports: [TypeOrmModule.forFeature([PlugSchedule, SmartPlug])],
  controllers: [PlugScheduleController],
  providers: [PlugScheduleService],
  exports: [PlugScheduleService],
})
export class PlugScheduleModule {}
