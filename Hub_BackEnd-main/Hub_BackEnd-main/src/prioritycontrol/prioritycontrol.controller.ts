// src/prioritycontrol/prioritycontrol.controller.ts

import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ParseUUIDPipe,
} from '@nestjs/common';
import { PriorityControlService } from './prioritycontrol.service';
import { CreatePriorityControlDto } from './dto/create-prioritycontrol.dto';
import { UpdatePriorityControlDto } from './dto/update-prioritycontrol.dto';

@Controller('prioritycontrol')
export class PriorityControlController {
  constructor(
    private readonly priorityControlService: PriorityControlService,
  ) {}

  @Post()
  create(@Body() createDto: CreatePriorityControlDto) {
    return this.priorityControlService.create(createDto);
  }

  @Get()
  findAll() {
    return this.priorityControlService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.priorityControlService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateDto: UpdatePriorityControlDto) {
    return this.priorityControlService.update(id, updateDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.priorityControlService.remove(id);
  }
}
