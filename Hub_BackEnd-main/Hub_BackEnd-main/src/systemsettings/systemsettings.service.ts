// src/systemsettings/systemsettings.service.ts

import {
  Injectable,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SystemSettings } from './entities/systemsetting.entity';
import { CreateSystemSettingsDto } from './dto/create-systemsetting.dto';
import { UpdateSystemSettingsDto } from './dto/update-systemsetting.dto';
import { Users } from 'src/users/entities/user.entity';

@Injectable()
export class SystemSettingsService {
  constructor(
    @InjectRepository(SystemSettings)
    private readonly systemSettingsRepository: Repository<SystemSettings>,
    @InjectRepository(Users)
    private readonly usersRepository: Repository<Users>,
  ) {}

  async create(dto: CreateSystemSettingsDto): Promise<SystemSettings> {
    // Check for unique setting key
    /* const existing = await this.systemSettingsRepository.findOne({
      where: { settingKey: dto.settingKey },
    });
    if (existing) {
      throw new ConflictException('Setting key must be unique');
    } */

    // Find the user if a userId is provided
    let user: Users | null = null;
    if (dto.userId !== undefined) {
      user = await this.usersRepository.findOne({ where: { id: dto.userId } });
      if (!user) {
        throw new NotFoundException(`User with id ${dto.userId} not found`);
      }
    }

    // Create the system setting using the provided DTO values
    const setting = this.systemSettingsRepository.create({
      userID: user || undefined, // Assign the user relation (or undefined if not provided)
      settingKey: dto.settingKey,
      settingValue: dto.settingValue,
    });

    return await this.systemSettingsRepository.save(setting);
  }
  async findByUserId(userId: number): Promise<SystemSettings> {
    const settings = await this.systemSettingsRepository.findOne({
      where: { userID: { id: userId } },
      relations: ['userID'], // if needed
    });

    if (!settings) {
      throw new NotFoundException('System settings not found for user');
    }

    return settings;
  }

  async findAll(): Promise<SystemSettings[]> {
    return this.systemSettingsRepository.find({ relations: ['userID'] });
  }

  async findOne(id: number): Promise<SystemSettings> {
    const setting = await this.systemSettingsRepository.findOne({
      where: { id },
      relations: ['userID'],
    });
    if (!setting) {
      throw new NotFoundException('System setting not found');
    }
    return setting;
  }

  async update(
    id: number,
    dto: UpdateSystemSettingsDto,
  ): Promise<SystemSettings> {
    const setting = await this.findOne(id);

    // If a new userId is provided, fetch the corresponding User entity
    if (dto.userId !== undefined) {
      const user = await this.usersRepository.findOne({
        where: { id: dto.userId },
      });
      if (!user) {
        throw new NotFoundException(`User with id ${dto.userId} not found`);
      }
      setting.userID = user;
    }

    // Update other fields if provided
    if (dto.settingKey !== undefined) {
      setting.settingKey = dto.settingKey;
    }
    if (dto.settingValue !== undefined) {
      setting.settingValue = dto.settingValue;
    }

    return await this.systemSettingsRepository.save(setting);
  }

  async remove(id: number): Promise<{ message: string }> {
    const setting = await this.findOne(id);
    await this.systemSettingsRepository.remove(setting);
    return { message: 'System setting deleted successfully' };
  }
}
