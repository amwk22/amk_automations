import { PriorityControl } from 'src/prioritycontrol/entities/prioritycontrol.entity';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';
import { SystemSettings } from 'src/systemsettings/entities/systemsetting.entity';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  JoinColumn,
  OneToOne,
  ManyToOne,
} from 'typeorm';

export enum RequestAction {
  TURN_ON = 'turnOn',
  TURN_OFF = 'turnOff',
}

export enum RequestStatus {
  PENDING = 'pending',
  EXECUTED = 'executed',
  SKIPPED = 'skipped',
}

@Entity()
export class RequestQueue {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({
    type: 'enum',
    enum: RequestAction,
    default: RequestAction.TURN_ON,
  })
  action: RequestAction;

  @Column({
    type: 'enum',
    enum: RequestStatus,
    default: RequestStatus.PENDING,
  })
  status: RequestStatus;

  @CreateDateColumn()
  timeQueued: Date;
  //
  // Relation to SmartPlug (the owning side)
  @OneToOne(() => SmartPlug, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'smartplug' })
  smartplug: SmartPlug;

  // Relation to SystemSettings
  @ManyToOne(() => SystemSettings, (systemsettings) => systemsettings.request, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'systemSettingsID' })
  systemSettingsID: SystemSettings;

  // Relation to PriorityControl
  @ManyToOne(
    () => PriorityControl,
    (prioritycontrol) => prioritycontrol.request,
    { onDelete: 'CASCADE' },
  )
  @JoinColumn({ name: 'priorityID' })
  priorityID: PriorityControl;
}
