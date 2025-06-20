// src/energylog/dto/update-energylog.dto.ts

import { PartialType } from '@nestjs/mapped-types';
import { CreateEnergyLogDto } from './create-energylog.dto';
import { IsOptional, IsNumber, Min } from 'class-validator';

export class UpdateEnergyLogDto extends PartialType(CreateEnergyLogDto) {
  @IsOptional()
  @IsNumber({}, { message: 'Power usage must be a number' })
  @Min(0)
  powerUsage?: number;

  @IsOptional()
  @IsNumber({}, { message: 'Current must be a number' })
  @Min(0)
  current?: number;

  @IsOptional()
  @IsNumber({}, { message: 'Voltage must be a number' })
  @Min(0)
  voltage?: number;

  @IsOptional()
  @IsNumber({}, { message: 'Energy consumed must be a number' })
  @Min(0)
  energyConsumed?: number;

  // If you allow updating relations via raw IDs, include these as well:
  @IsOptional()
  plugId?: number;

  @IsOptional()
  systemSettingsId?: number;
}
