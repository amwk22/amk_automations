// src/systemsettings/systemsettings.module.ts

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SystemSettings } from './entities/systemsetting.entity';
import { SystemSettingsService } from './systemsettings.service';
import { SystemSettingsController } from './systemsettings.controller';
import { Users } from 'src/users/entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([SystemSettings, Users])],
  controllers: [SystemSettingsController],
  providers: [SystemSettingsService],
})
export class SystemSettingsModule {}
