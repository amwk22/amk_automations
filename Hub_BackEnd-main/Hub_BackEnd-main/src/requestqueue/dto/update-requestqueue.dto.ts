// src/requestqueue/dto/update-requestqueue.dto.ts

import { PartialType } from '@nestjs/mapped-types';
import { CreateRequestQueueDto } from './create-requestqueue.dto';
import { IsOptional, IsNumber, IsEnum } from 'class-validator';
import { RequestAction, RequestStatus } from '../entities/requestqueue.entity';

export class UpdateRequestQueueDto extends PartialType(CreateRequestQueueDto) {
  @IsOptional()
  @IsNumber({}, { message: 'SmartPlug ID must be a number' })
  smartplugId?: number;

  @IsOptional()
  @IsNumber({}, { message: 'System Settings ID must be a number' })
  systemSettingsId?: number;

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
