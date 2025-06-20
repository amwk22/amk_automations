// src/energylog/dto/create-energylog.dto.ts

import { IsNotEmpty, IsOptional, IsNumber, Min } from 'class-validator';

export class CreateEnergyLogDto {
  @IsNotEmpty({ message: 'Plug ID is required' })
  // The SmartPlug's primary key (numeric) is provided here.
  plugId: number;

  @IsNotEmpty({ message: 'Power usage is required' })
  @IsNumber({}, { message: 'Power usage must be a number' })
  @Min(0)
  powerUsage: number;

  @IsNotEmpty({ message: 'Current is required' })
  @IsNumber({}, { message: 'Current must be a number' })
  @Min(0)
  current: number;

  @IsNotEmpty({ message: 'Voltage is required' })
  @IsNumber({}, { message: 'Voltage must be a number' })
  @Min(0)
  voltage: number;

  @IsOptional()
  @IsNumber({}, { message: 'Energy consumed must be a number' })
  @Min(0)
  energyConsumed?: number;

  @IsNotEmpty({ message: 'System Settings ID is required' })
  // The SystemSettings's primary key (numeric) is provided here.
  systemSettingsId: number;
}
