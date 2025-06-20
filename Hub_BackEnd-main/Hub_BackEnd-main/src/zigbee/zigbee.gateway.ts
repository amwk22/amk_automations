import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayInit,
  SubscribeMessage,
  MessageBody,
} from '@nestjs/websockets';
import { Server } from 'ws';
import { Logger } from '@nestjs/common';
import { ZigbeeService } from './zigbee.service';

@WebSocketGateway({ path: '/ws' })
export class ZigbeeGateway implements OnGatewayInit {
  private readonly logger = new Logger(ZigbeeGateway.name);

  @WebSocketServer()
  server!: Server;

  constructor(private readonly zigbeeService: ZigbeeService) {}

  afterInit(): void {
    this.logger.log('Raw WS gateway ready on /ws');
  }

  /* ----------  NEW CODE  ---------- */
  @SubscribeMessage('toggle-relay')
  handleToggleRelay(@MessageBody() data: any) {
    const cmd = String(data?.command).toUpperCase();
    const addr = String(data?.address64);

    if ((cmd === 'ON' || cmd === 'OFF') && addr.length === 16) {
      this.logger.log(`toggle‑relay ${cmd} → ${addr}`);

      try {
        this.zigbeeService.sendCommand(cmd as 'ON' | 'OFF', addr);
        // optional ACK back to the same socket
        return { event: 'ack', data: { command: cmd, address64: addr } };
      } catch (e) {
        this.logger.warn(e.message);
        return { event: 'error', data: e.message };
      }
    }

    return { event: 'error', data: 'Invalid payload' };
  }
}
