// src/energylog/energylog.service.ts

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { EnergyLog } from './entities/energylog.entity';
import { CreateEnergyLogDto } from './dto/create-energylog.dto';
import { UpdateEnergyLogDto } from './dto/update-energylog.dto';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';
import { SystemSettings } from 'src/systemsettings/entities/systemsetting.entity';

@Injectable()
export class EnergyLogService {
  constructor(
    @InjectRepository(EnergyLog)
    private readonly energyLogRepo: Repository<EnergyLog>,

    @InjectRepository(SmartPlug)
    private readonly smartPlugRepo: Repository<SmartPlug>,

    @InjectRepository(SystemSettings)
    private readonly systemSettingsRepo: Repository<SystemSettings>,
  ) {}

  async create(dto: CreateEnergyLogDto): Promise<EnergyLog> {
    const plug = await this.smartPlugRepo.findOne({
      where: { Id: dto.plugId },
    });
    if (!plug) throw new NotFoundException('Smart plug not found');

    let systemSetting: SystemSettings | null = null;
    if (dto.systemSettingsId) {
      systemSetting = await this.systemSettingsRepo.findOne({
        where: { id: dto.systemSettingsId },
      });
      if (!systemSetting)
        throw new NotFoundException('System setting not found');
    }

    const log = this.energyLogRepo.create({
      powerUsage: dto.powerUsage,
      current: dto.current,
      voltage: dto.voltage,
      energyConsumed: dto.energyConsumed,
      plugID: plug,
      systemSettingsID: systemSetting || undefined,
    });

    const savedLog = await this.energyLogRepo.save(log);
    if (Array.isArray(savedLog)) {
      throw new Error('Unexpected array response from save operation');
    }
    return savedLog;
  }

  findAll(): Promise<EnergyLog[]> {
    return this.energyLogRepo.find({
      relations: ['plugID', 'systemSettingsID'],
    });
  }

  async findOne(id: string): Promise<EnergyLog> {
    const log = await this.energyLogRepo.findOne({
      where: { id: parseInt(id, 10) },
      relations: ['plugID', 'systemSettingsID'],
    });
    if (!log) throw new NotFoundException('Energy log not found');
    return log;
  }

  async update(id: string, dto: UpdateEnergyLogDto): Promise<EnergyLog> {
    const log = await this.findOne(id);

    if (dto.plugId) {
      const plug = await this.smartPlugRepo.findOne({
        where: { Id: dto.plugId },
      });
      if (!plug) throw new NotFoundException('Smart plug not found');
      log.plugID = plug;
    }

    if (dto.systemSettingsId) {
      const setting = await this.systemSettingsRepo.findOne({
        where: { id: dto.systemSettingsId },
      });
      if (!setting) throw new NotFoundException('System setting not found');
      log.systemSettingsID = setting;
    }

    if (dto.powerUsage !== undefined) log.powerUsage = dto.powerUsage;
    if (dto.current !== undefined) log.current = dto.current;
    if (dto.voltage !== undefined) log.voltage = dto.voltage;
    if (dto.energyConsumed !== undefined)
      log.energyConsumed = dto.energyConsumed;

    return this.energyLogRepo.save(log);
  }

  async remove(id: string): Promise<{ message: string }> {
    const log = await this.findOne(id);
    await this.energyLogRepo.remove(log);
    return { message: 'Energy log deleted successfully' };
  }
  async findByPlugId(plugId: string): Promise<EnergyLog> {
    const log = await this.energyLogRepo.findOne({
      where: { plugID: { Id: parseInt(plugId, 10) } },
      relations: ['plugID', 'systemSettingsID'],
    });
    if (!log) throw new NotFoundException('Energy log not found');
    return log;
  }
}
