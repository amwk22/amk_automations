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
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';

@Injectable()
export class PriorityControlService {
  constructor(
    @InjectRepository(PriorityControl)
    private readonly priorityRepo: Repository<PriorityControl>,

    @InjectRepository(SmartPlug)
    private readonly smartPlugRepo: Repository<SmartPlug>,
  ) {}

  async create(dto: CreatePriorityControlDto): Promise<PriorityControl> {
    const plug = await this.smartPlugRepo.findOne({
      where: { Id: parseInt(dto.plugId) },
    });

    if (!plug) throw new NotFoundException('Smart plug not found');

    const existing = await this.priorityRepo.findOne({
      where: { plugId: dto.plugId },
    });
    if (existing)
      throw new ConflictException('Priority already set for this plug');

    const priority = this.priorityRepo.create({
      plugId: dto.plugId,
      priorityLevel: dto.priorityLevel ?? 3,
      criticalDevice: dto.criticalDevice ?? false,
    });

    return await this.priorityRepo.save(priority);
  }

  findAll(): Promise<PriorityControl[]> {
    return this.priorityRepo.find();
  }

  async findOne(id: string): Promise<PriorityControl> {
    const item = await this.priorityRepo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Priority rule not found');
    return item;
  }

  async update(
    id: string,
    dto: UpdatePriorityControlDto,
  ): Promise<PriorityControl> {
    const priority = await this.findOne(id);
    Object.assign(priority, dto);
    return this.priorityRepo.save(priority);
  }

  async remove(id: string): Promise<{ message: string }> {
    const item = await this.findOne(id);
    await this.priorityRepo.remove(item);
    return { message: 'Priority control rule deleted successfully' };
  }
}
