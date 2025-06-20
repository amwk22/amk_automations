import { EnergyLog } from 'src/energylog/entities/energylog.entity';
import { Users } from 'src/users/entities/user.entity';
import { PlugSchedule } from 'src/plug-schedule/entities/plug-schedule.entity';
import {
  Column,
  CreateDateColumn,
  Entity,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity()
export class SmartPlug {
  @PrimaryGeneratedColumn()
  Id: number;

  @Column({ unique: true })
  zigbeeAddress: string;

  @Column()
  name: string;

  @Column({ default: false })
  status: boolean;

  @Column({ type: 'float', nullable: true })
  estimatedAmps: number;

  @CreateDateColumn()
  createdAt: Date;
  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => Users, (users) => users.smartplugs, { onDelete: 'CASCADE' })
  users: Users;
  @OneToMany(() => EnergyLog, (energylog) => energylog.plugID)
  energylogs: EnergyLog[];
  @OneToMany(() => PlugSchedule, (schedule) => schedule.plug)
  schedules: PlugSchedule[];
}
