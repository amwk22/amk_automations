import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';

@Entity()
export class PlugSchedule {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  onTime: string; // Format: "HH:mm"

  @Column()
  offTime: string; // Format: "HH:mm"

  @Column('simple-array')
  days: string[]; // e.g., ["Monday", "Wednesday", "Friday"]

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => SmartPlug, (plug) => plug.schedules, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'plugID' })
  plug: SmartPlug;
}
