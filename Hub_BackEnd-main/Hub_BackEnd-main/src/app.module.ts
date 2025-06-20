import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersModule } from './users/users.module';
import { SmartplugModule } from './smartplug/smartplug.module';
import { RequestqueueModule } from './requestqueue/requestqueue.module';
import { EnergyLogModule } from './energylog/energylog.module';
import { PriorityControlModule } from './prioritycontrol/prioritycontrol.module';
import { SystemSettingsModule } from './systemsettings/systemsettings.module';
import { AuthModule } from './auth/auth.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { PlugScheduleModule } from './plug-schedule/plug-schedule.module';
import { ZigbeeModule } from './zigbee/zigbee.module';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'mariadb',
      host: 'localhost',
      port: 3306,
      username: 'root',
      password: 'root',
      database: 'hub_db',
      autoLoadEntities: true,
      synchronize: true,
    }),
    UsersModule,
    SmartplugModule,
    RequestqueueModule,
    EnergyLogModule,
    PriorityControlModule,
    SystemSettingsModule,
    AuthModule,
    DashboardModule,
    PlugScheduleModule,
    ZigbeeModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
