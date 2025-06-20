// src/energylog/entities/energylog.entity.ts

import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';
import { SystemSettings } from 'src/systemsettings/entities/systemsetting.entity';

@Entity()
export class EnergyLog {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'float' })
  powerUsage: number;

  @Column({ type: 'float' })
  current: number;

  @Column({ type: 'float' })
  voltage: number;

  @Column({ type: 'float', nullable: true })
  energyConsumed: number;

  @CreateDateColumn()
  recordedAt: Date;

  @ManyToOne(() => SmartPlug, (smartplug) => smartplug.energylogs, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'plugID' })
  plugID: SmartPlug;

  @ManyToOne(
    () => SystemSettings,
    (systemsettings) => systemsettings.energylog,
    { onDelete: 'CASCADE' },
  )
  @JoinColumn({ name: 'systemSettingsID' })
  systemSettingsID: SystemSettings;
}
