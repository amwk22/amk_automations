// src/dashboard/dashboard.service.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';
import { EnergyLog } from 'src/energylog/entities/energylog.entity';
import { Repository } from 'typeorm';
import { SystemSettings } from 'src/systemsettings/entities/systemsetting.entity';

@Injectable()
export class DashboardService {
  constructor(
    @InjectRepository(SmartPlug)
    private smartPlugRepo: Repository<SmartPlug>,

    @InjectRepository(EnergyLog)
    private energyLogRepo: Repository<EnergyLog>,
    @InjectRepository(SystemSettings)
    private settingsRepo: Repository<SystemSettings>,
  ) {}

  async getCostPerKwh(userId?: number): Promise<number> {
    if (!userId) {
      throw new Error('User ID is required to fetch cost per kWh.');
    }

    const userSetting = await this.settingsRepo.findOne({
      where: {
        settingKey: 'cost_per_kwh',
        userID: { id: userId },
      },
      relations: ['userID'],
    });

    if (userSetting && !isNaN(Number(userSetting.settingValue))) {
      return parseFloat(userSetting.settingValue);
    }

    throw new Error(`Cost per kWh setting not found for user ID ${userId}`);
  }
  async getUserDashboard(userId: number) {
    const plugs = await this.smartPlugRepo.find({
      where: { users: { id: userId } },
    });
    const totalPlugs = plugs.length;

    const plugIds = plugs.map((p) => p.Id);
    const logs = await this.energyLogRepo
      .createQueryBuilder('log')
      .where('log.plugID IN (:...plugIds)', { plugIds })
      .orderBy('log.recordedAt', 'DESC')
      .getMany();

    const currentPowerUsage = logs.reduce(
      (sum, log) => sum + log.energyConsumed,
      0,
    );
    const costPerKwh = await this.getCostPerKwh(userId);
    const currentCost = currentPowerUsage * costPerKwh; // assuming 0.10 KD/kWh

    return {
      totalPlugs,
      currentPowerUsage,
      estimatedCost: currentCost.toFixed(2),
    };
  }
}
