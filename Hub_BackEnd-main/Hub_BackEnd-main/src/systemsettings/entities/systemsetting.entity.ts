// src/entities/systemsettings.entity.ts

import { EnergyLog } from 'src/energylog/entities/energylog.entity';
import { RequestQueue } from 'src/requestqueue/entities/requestqueue.entity';
import { Users } from 'src/users/entities/user.entity';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';

@Entity()
export class SystemSettings {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  settingKey: string;

  @Column({ type: 'text' })
  settingValue: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Force the foreign key column to be named "userID"
  @ManyToOne(() => Users, (users) => users.systemsettings, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'userID' })
  userID: Users;

  @OneToMany(
    () => RequestQueue,
    (requestqueue) => requestqueue.systemSettingsID,
  )
  request: RequestQueue[];

  @OneToMany(() => EnergyLog, (energylog) => energylog.systemSettingsID)
  energylog: EnergyLog[];
}
