// src/requestqueue/dto/create-requestqueue.dto.ts

import { IsEnum, IsNotEmpty, IsNumber, IsOptional } from 'class-validator';
import { RequestAction, RequestStatus } from '../entities/requestqueue.entity';

export class CreateRequestQueueDto {
  @IsNotEmpty({ message: 'SmartPlug ID is required' })
  @IsNumber({}, { message: 'SmartPlug ID must be a number' })
  smartplugId: number;

  @IsNotEmpty({ message: 'System Settings ID is required' })
  @IsNumber({}, { message: 'System Settings ID must be a number' })
  systemSettingsId: number;

  @IsOptional()
  @IsNumber({}, { message: 'Priority ID must be a number' })
  priorityId?: number;

  @IsOptional()
  @IsEnum(RequestAction, { message: 'Action must be either turnOn or turnOff' })
  action?: RequestAction;

  @IsOptional()
  @IsEnum(RequestStatus, {
    message: 'Status must be pending, executed, or skipped',
  })
  status?: RequestStatus;
}
