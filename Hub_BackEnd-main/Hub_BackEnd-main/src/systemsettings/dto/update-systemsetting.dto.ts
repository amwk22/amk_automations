// src/systemsettings/dto/update-systemsettings.dto.ts

import { PartialType } from '@nestjs/mapped-types';
import { CreateSystemSettingsDto } from './create-systemsetting.dto';
import { IsOptional, IsString, IsNumber } from 'class-validator';

export class UpdateSystemSettingsDto extends PartialType(
  CreateSystemSettingsDto,
) {
  @IsOptional()
  @IsString({ message: 'Setting key must be a string' })
  settingKey?: string;

  @IsOptional()
  @IsString({ message: 'Setting value must be a string' })
  settingValue?: string;

  @IsOptional()
  @IsNumber()
  userId?: number;
}
