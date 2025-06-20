// src/entities/prioritycontrol.entity.ts
import { RequestQueue } from 'src/requestqueue/entities/requestqueue.entity';
import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';

@Entity()
export class PriorityControl {
  @PrimaryGeneratedColumn()
  id: number;

  // Priority level for the plug (e.g., 1 = High, 2 = Medium, 3 = Low)
  @Column({ type: 'integer', default: 3 })
  priorityLevel: number;

  // Indicates if the device is critical and should not be turned off automatically
  @Column({ default: false })
  criticalDevice: boolean;
  @OneToMany(() => RequestQueue, (requestqueue) => requestqueue.priorityID)
  request: RequestQueue[];
}
