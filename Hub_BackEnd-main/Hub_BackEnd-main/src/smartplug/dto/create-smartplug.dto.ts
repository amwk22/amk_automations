// src/smartplug/dto/create-smartplug.dto.ts

import {
  IsNotEmpty,
  IsString,
  IsBoolean,
  IsNumber,
  IsOptional,
} from 'class-validator';

export class CreateSmartPlugDto {
  @IsNotEmpty({ message: 'Zigbee address is required' })
  @IsString({ message: 'Zigbee address must be a string' })
  zigbeeAddress: string;

  @IsNotEmpty({ message: 'Name is required' })
  @IsString({ message: 'Name must be a string' })
  name: string;

  @IsOptional() //this is optional means that it can be null
  @IsBoolean({ message: 'Status must be true or false' })
  status?: boolean;

  @IsOptional()
  @IsNumber({}, { message: 'Estimated amps must be a number' })
  estimatedAmps?: number;

  @IsNotEmpty({ message: 'User ID is required' })
  userID: number;
}
