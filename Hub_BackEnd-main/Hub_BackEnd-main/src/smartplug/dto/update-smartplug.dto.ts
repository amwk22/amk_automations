// src/smartplug/dto/update-smartplug.dto.ts

import { PartialType } from '@nestjs/mapped-types';
import { CreateSmartPlugDto } from './create-smartplug.dto';
import { IsOptional, IsBoolean, IsString, IsNumber } from 'class-validator';

export class UpdateSmartplugDto extends PartialType(CreateSmartPlugDto) {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  zigbeeAddress?: string;

  @IsOptional()
  @IsBoolean()
  status?: boolean;

  @IsOptional()
  @IsNumber()
  estimatedAmps?: number;
}
