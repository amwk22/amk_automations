import { Module } from '@nestjs/common';
import { ZigbeeService } from './zigbee.service';
import { ZigbeeGateway } from './zigbee.gateway';

@Module({
  providers: [ZigbeeService, ZigbeeGateway],
  exports: [ZigbeeService],
})
export class ZigbeeModule {}
