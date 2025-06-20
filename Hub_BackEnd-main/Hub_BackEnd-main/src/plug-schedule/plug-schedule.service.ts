import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PlugSchedule } from './entities/plug-schedule.entity';
import { CreatePlugScheduleDto } from './dto/create-plug-schedule.dto';
import { UpdatePlugScheduleDto } from './dto/update-plug-schedule.dto';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';

@Injectable()
export class PlugScheduleService {
  constructor(
    @InjectRepository(PlugSchedule)
    private scheduleRepo: Repository<PlugSchedule>,

    @InjectRepository(SmartPlug)
    private plugRepo: Repository<SmartPlug>,
  ) {}

  async create(dto: CreatePlugScheduleDto): Promise<PlugSchedule> {
    const plug = await this.plugRepo.findOne({ where: { Id: dto.plugId } });
    if (!plug) throw new Error('Plug not found');

    const schedule = this.scheduleRepo.create({
      onTime: dto.onTime,
      offTime: dto.offTime,
      days: dto.days,
      isActive: dto.isActive,
      plug,
    });

    return this.scheduleRepo.save(schedule);
  }

  findAllForPlug(plugId: number) {
    return this.scheduleRepo.find({
      where: { plug: { Id: plugId } },
      order: { onTime: 'ASC' },
    });
  }

  async update(id: number, dto: UpdatePlugScheduleDto) {
    const schedule = await this.scheduleRepo.findOne({
      where: { id },
      relations: ['plug'],
    });
    if (!schedule) throw new Error('Schedule not found');

    Object.assign(schedule, dto);
    return this.scheduleRepo.save(schedule);
  }

  async remove(id: number) {
    const result = await this.scheduleRepo.delete(id);
    return result.affected === 1;
  }
}
