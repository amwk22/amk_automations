import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';
import { SystemSettings } from 'src/systemsettings/entities/systemsetting.entity';
import {
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum userRole {
  ADMIN = 'admin',
  USER = 'user',
}

@Entity()
export class Users {
  @PrimaryGeneratedColumn()
  id: number;
  @Column({ unique: true })
  username: string;
  @Column({ unique: true })
  email: string;
  @Column()
  passwordHash: string;
  @Column({
    type: 'enum',
    enum: userRole,
    default: userRole.ADMIN,
  })
  role: userRole;
  @CreateDateColumn()
  createdAt: Date;
  @UpdateDateColumn()
  updatedAt: Date;

  @OneToMany(() => SmartPlug, (smartplug) => smartplug.users)
  smartplugs: SmartPlug[];

  @OneToMany(() => SystemSettings, (systemsettings) => systemsettings.userID)
  systemsettings: SystemSettings[];
}
