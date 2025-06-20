// src/prioritycontrol/dto/create-prioritycontrol.dto.ts

import { IsOptional, IsInt, Min, Max, IsBoolean } from 'class-validator';

export class CreatePriorityControlDto {
  // Optional: The priority level for the plug (default is 3 in the entity)
  @IsOptional()
  @IsInt({ message: 'Priority level must be an integer' })
  @Min(1, { message: 'Priority level must be at least 1' })
  @Max(5, { message: 'Priority level cannot be more than 5' })
  priorityLevel?: number;

  // Optional: Indicates if the device is critical
  @IsOptional()
  @IsBoolean({ message: 'Critical device flag must be a boolean' })
  criticalDevice?: boolean;
}
