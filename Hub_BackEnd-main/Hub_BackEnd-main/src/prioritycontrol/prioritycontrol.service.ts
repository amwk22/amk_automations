// src/prioritycontrol/prioritycontrol.service.ts

import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PriorityControl } from './entities/prioritycontrol.entity';
import { CreatePriorityControlDto } from './dto/create-prioritycontrol.dto';
import { UpdatePriorityControlDto } from './dto/update-prioritycontrol.dto';

@Injectable()
export class PriorityControlService {
  constructor(
    @InjectRepository(PriorityControl)
    private readonly priorityRepo: Repository<PriorityControl>,
  ) {}

  async create(dto: CreatePriorityControlDto): Promise<PriorityControl> {
    // If you need to enforce uniqueness for a plug, you could add checks here.
    // Currently, we simply create a new PriorityControl record.
    const priority = this.priorityRepo.create({
      priorityLevel: dto.priorityLevel ?? 3,
      criticalDevice: dto.criticalDevice ?? false,
    });
    return await this.priorityRepo.save(priority);
  }

  findAll(): Promise<PriorityControl[]> {
    return this.priorityRepo.find();
  }

  async findOne(id: string): Promise<PriorityControl> {
    const item = await this.priorityRepo.findOne({ where: { id: Number(id) } });
    if (!item) {
      throw new NotFoundException('Priority rule not found');
    }
    return item;
  }

  async update(
    id: string,
    dto: UpdatePriorityControlDto,
  ): Promise<PriorityControl> {
    const priority = await this.findOne(id);
    Object.assign(priority, dto);
    return await this.priorityRepo.save(priority);
  }

  async remove(id: string): Promise<{ message: string }> {
    const item = await this.findOne(id);
    await this.priorityRepo.remove(item);
    return { message: 'Priority control rule deleted successfully' };
  }
}
