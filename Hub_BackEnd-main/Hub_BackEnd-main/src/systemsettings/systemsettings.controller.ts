// src/systemsettings/systemsettings.controller.ts

import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  ParseUUIDPipe,
  UseGuards,
  Req,
} from '@nestjs/common';
import { SystemSettingsService } from './systemsettings.service';
import { CreateSystemSettingsDto } from './dto/create-systemsetting.dto';
import { UpdateSystemSettingsDto } from './dto/update-systemsetting.dto';
import { AuthGuard } from '@nestjs/passport';

@Controller('systemsettings')
export class SystemSettingsController {
  constructor(private readonly systemSettingsService: SystemSettingsService) {}

  @Post()
  create(@Body() createDto: CreateSystemSettingsDto) {
    return this.systemSettingsService.create(createDto);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('by-user')
  getByUserId(@Req() req) {
    const userId = req.user.id;
    return this.systemSettingsService.findByUserId(userId);
  }
  @Get()
  findAll() {
    return this.systemSettingsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.systemSettingsService.findOne(Number(id));
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateDto: UpdateSystemSettingsDto) {
    return this.systemSettingsService.update(Number(id), updateDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.systemSettingsService.remove(Number(id));
  }
}
