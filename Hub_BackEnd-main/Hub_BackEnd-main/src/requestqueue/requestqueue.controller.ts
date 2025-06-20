// src/requestqueue/requestqueue.controller.ts

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
import { RequestqueueService } from './requestqueue.service';
import { CreateRequestQueueDto } from './dto/create-requestqueue.dto';
import { UpdateRequestQueueDto } from './dto/update-requestqueue.dto';

@Controller('requestqueue')
export class RequestqueueController {
  constructor(private readonly requestQueueService: RequestqueueService) {}

  @Post()
  create(@Body() createDto: CreateRequestQueueDto) {
    return this.requestQueueService.create(createDto);
  }

  @Get()
  findAll() {
    return this.requestQueueService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.requestQueueService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateDto: UpdateRequestQueueDto) {
    console.log(updateDto);
    return this.requestQueueService.update(id, updateDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.requestQueueService.remove(id);
  }
}
