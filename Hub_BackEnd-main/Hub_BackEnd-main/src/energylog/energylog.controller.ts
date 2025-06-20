// src/energylog/energylog.controller.ts

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
import { EnergyLogService } from './energylog.service';
import { CreateEnergyLogDto } from './dto/create-energylog.dto';
import { UpdateEnergyLogDto } from './dto/update-energylog.dto';

@Controller('energylogs')
export class EnergyLogController {
  constructor(private readonly energyLogService: EnergyLogService) {}

  @Post()
  create(@Body() createDto: CreateEnergyLogDto) {
    return this.energyLogService.create(createDto);
  }

  @Get()
  findAll() {
    return this.energyLogService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.energyLogService.findOne(id);
  }
  @Get('ByPlug/:plugID')
  findByPlugId(@Param('plugID') plugID: string) {
    return this.energyLogService.findByPlugId(plugID);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateDto: UpdateEnergyLogDto) {
    return this.energyLogService.update(id, updateDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.energyLogService.remove(id);
  }
}
