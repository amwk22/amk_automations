// src/prioritycontrol/dto/update-prioritycontrol.dto.ts

import { PartialType } from '@nestjs/mapped-types';
import { CreatePriorityControlDto } from './create-prioritycontrol.dto';

export class UpdatePriorityControlDto extends PartialType(
  CreatePriorityControlDto,
) {}
