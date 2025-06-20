// src/systemsettings/dto/create-systemsettings.dto.ts

import { IsNotEmpty, IsOptional, IsString, IsNumber } from 'class-validator';

export class CreateSystemSettingsDto {
  @IsNotEmpty()
  @IsNumber()
  userId?: number;
  //
  @IsNotEmpty({ message: 'Setting key is required' })
  @IsString({ message: 'Setting key must be a string' })
  settingKey: string;

  @IsNotEmpty({ message: 'Setting value is required' })
  @IsString({ message: 'Setting value must be a string' })
  settingValue: string;
}
