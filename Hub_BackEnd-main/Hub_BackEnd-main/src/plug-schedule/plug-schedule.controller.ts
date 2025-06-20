import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Put,
  Delete,
} from '@nestjs/common';
import { PlugScheduleService } from './plug-schedule.service';
import { CreatePlugScheduleDto } from './dto/create-plug-schedule.dto';
import { UpdatePlugScheduleDto } from './dto/update-plug-schedule.dto';

@Controller('schedule')
export class PlugScheduleController {
  constructor(private readonly service: PlugScheduleService) {}

  @Post()
  create(@Body() dto: CreatePlugScheduleDto) {
    return this.service.create(dto);
  }

  @Get(':plugId')
  findAllForPlug(@Param('plugId') plugId: number) {
    return this.service.findAllForPlug(plugId);
  }

  @Put(':id')
  update(@Param('id') id: number, @Body() dto: UpdatePlugScheduleDto) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: number) {
    return this.service.remove(id);
  }
}
