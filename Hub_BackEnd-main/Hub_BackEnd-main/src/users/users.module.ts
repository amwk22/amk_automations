import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Users } from 'src/users/entities/user.entity';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { IsUsernameUniqueConstraint } from 'src/validators/is-username-unique.constraints';
import { IsEmailUniqueConstraint } from 'src/validators/is-email-unique.constraint';
import { SmartPlug } from 'src/smartplug/entities/smartplug.entity';
import { EnergyLog } from 'src/energylog/entities/energylog.entity';
@Module({
  imports: [TypeOrmModule.forFeature([Users, SmartPlug, EnergyLog])],
  controllers: [UsersController],
  providers: [
    UsersService,
    IsUsernameUniqueConstraint,
    IsEmailUniqueConstraint,
  ],
})
export class UsersModule {}
