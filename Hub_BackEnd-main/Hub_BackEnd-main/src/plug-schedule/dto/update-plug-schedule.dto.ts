import { PartialType } from '@nestjs/mapped-types';
import { CreatePlugScheduleDto } from './create-plug-schedule.dto';

export class UpdatePlugScheduleDto extends PartialType(CreatePlugScheduleDto) {}
