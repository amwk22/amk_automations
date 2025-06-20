// src/requestqueue/requestqueue.service.ts

import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RequestQueue } from './entities/requestqueue.entity';
import { CreateRequestQueueDto } from './dto/create-requestqueue.dto';
import { UpdateRequestQueueDto } from './dto/update-requestqueue.dto';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';
import { SystemSettings } from 'src/systemsettings/entities/systemsetting.entity';
import { PriorityControl } from 'src/prioritycontrol/entities/prioritycontrol.entity';

@Injectable()
export class RequestqueueService {
  constructor(
    @InjectRepository(RequestQueue)
    private readonly requestQueueRepo: Repository<RequestQueue>,

    @InjectRepository(SmartPlug)
    private readonly smartPlugRepo: Repository<SmartPlug>,

    @InjectRepository(SystemSettings)
    private readonly systemSettingsRepo: Repository<SystemSettings>,

    @InjectRepository(PriorityControl)
    private readonly priorityRepo: Repository<PriorityControl>,
  ) {}

  async create(dto: CreateRequestQueueDto): Promise<RequestQueue> {
    const plug = await this.smartPlugRepo.findOne({
      where: { Id: dto.smartplugId },
    });
    if (!plug) throw new NotFoundException('Smart plug not found');

    const systemSettings = await this.systemSettingsRepo.findOne({
      where: { id: dto.systemSettingsId },
    });
    if (!systemSettings)
      throw new NotFoundException('System settings not found');

    let priority: PriorityControl | null = null;
    if (dto.priorityId) {
      const foundPriority = await this.priorityRepo.findOne({
        where: { id: Number(dto.priorityId) },
      });
      if (!foundPriority) {
        throw new NotFoundException('Priority control entry not found');
      }
      priority = foundPriority;
    }

    const request = this.requestQueueRepo.create({
      action: dto.action,
      status: dto.status,
      smartplug: plug, // Pass the SmartPlug entity
      systemSettingsID: systemSettings, // Pass the SystemSettings entity or null
      priorityID: priority || undefined, // Pass the PriorityControl entity or undefined
    });

    return await this.requestQueueRepo.save(request);
  }

  findAll(): Promise<RequestQueue[]> {
    return this.requestQueueRepo.find({
      relations: ['smartplug', 'systemSettingsID', 'priorityID'],
    });
  }

  async findOne(id: string): Promise<RequestQueue> {
    const request = await this.requestQueueRepo.findOne({
      where: { id: Number(id) },
      relations: ['smartplug', 'systemSettingsID', 'priorityID'],
    });
    if (!request) throw new NotFoundException('Request not found');
    return request;
  }

  async update(id: string, dto: UpdateRequestQueueDto): Promise<RequestQueue> {
    // 1. Fetch the existing RequestQueue record
    const request = await this.findOne(id);
    // e.g., findOne() uses 'Number(id)' because 'id' is numeric in your entity

    // 2. If the user wants to update the SmartPlug relation
    if (dto.smartplugId) {
      const plug = await this.smartPlugRepo.findOne({
        where: { Id: Number(dto.smartplugId) },
      });
      if (!plug) throw new NotFoundException('Smart plug not found');
      request.smartplug = plug;
    }

    // 3. If the user wants to update the SystemSettings relation
    if (dto.systemSettingsId) {
      const setting = await this.systemSettingsRepo.findOne({
        where: { id: Number(dto.systemSettingsId) },
      });
      if (!setting) throw new NotFoundException('System setting not found');
      request.systemSettingsID = setting;
    }

    // 4. If the user wants to update the PriorityControl relation
    if (dto.priorityId) {
      const priority = await this.priorityRepo.findOne({
        where: { id: Number(dto.priorityId) },
      });
      if (!priority) throw new NotFoundException('Priority control not found');
      request.priorityID = priority;
    }

    // 5. Update action/status if provided
    if (dto.action) {
      request.action = dto.action;
    }
    if (dto.status) {
      request.status = dto.status;
    }

    // 6. Save and return the updated RequestQueue
    return this.requestQueueRepo.save(request);
  }

  async remove(id: string): Promise<{ message: string }> {
    const request = await this.findOne(id);
    await this.requestQueueRepo.remove(request);
    return { message: 'Request deleted successfully' };
  }
}
