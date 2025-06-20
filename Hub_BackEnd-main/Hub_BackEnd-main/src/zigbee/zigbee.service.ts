import {
  Injectable,
  Logger,
  OnModuleInit,
  OnModuleDestroy,
} from '@nestjs/common';
import { SerialPort } from 'serialport';

/* CommonJS import */
const { XBeeAPI } = require('xbee-api'); // eslint-disable-line @typescript-eslint/no-var-requires

/* Zigbee frame‑type bytes */
const RX_FRAME = 0x90; // Receive Packet
const TX_FRAME = 0x10; // Transmit Request

@Injectable()
export class ZigbeeService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(ZigbeeService.name);

  private xbee = new XBeeAPI({ api_mode: 2 });
  private port?: SerialPort;
  private portOpen = false;

  private devices = new Map<string, { addr16: string; seen: number }>();
  private wss?: any;

  /* ───────── lifecycle ───────── */

  onModuleInit(): void {
    const path = process.env.ZIGBEE_PORT || 'COM12'; // set COM12 on Windows
    this.openSerial(path, 9600);
  }

  onModuleDestroy(): void {
    this.port?.close();
    this.logger.log('Serial port closed');
  }

  /* ───────── gateway hooks ───────── */

  setWebSocketServer(wss: any): void {
    this.wss = wss;
  }

  sendCommand(cmd: 'ON' | 'OFF', remote64: string): void {
    if (!this.portOpen) throw new Error('Zigbee serial not ready');

    const dev = this.devices.get(remote64);
    const dest16 = dev?.addr16 ?? 'FFFE';

    const frame = {
      type: TX_FRAME,
      id: 1,
      destination64: remote64,
      destination16: dest16,
      broadcastRadius: 0x00,
      options: 0x00,
      data: Buffer.from(cmd + '\n', 'utf8'),
    };

    this.xbee.builder.write(frame);
    this.logger.log(`0x10 ${cmd} → ${remote64} (16‑bit ${dest16})`);
  }

  /* ───────── helpers ───────── */

  private openSerial(path: string, baud: number): void {
    this.port = new SerialPort({ path, baudRate: baud });

    this.port.on('open', () => {
      this.portOpen = true;
      this.logger.log(`Serial ${path} @ ${baud} open`);
    });

    this.port.on('error', (e) => this.logger.error(e.message));

    this.port.pipe(this.xbee.parser);
    this.xbee.builder.pipe(this.port);

    this.xbee.parser.on('data', (frame: any) => {
      if (frame.type !== RX_FRAME) return;

      const remote64 = frame.remote64 as string;
      const remote16 = frame.remote16 as string;
      this.devices.set(remote64, { addr16: remote16, seen: Date.now() });

      /* parse JSON payload if possible */
      let data: any;
      try {
        data = JSON.parse(frame.data.toString('utf8'));
      } catch {
        return; // ignore non‑JSON
      }

      const msg = { source: remote64, data };
      this.logger.debug(msg);

      /* broadcast to connected WS clients */
      if (this.wss) {
        this.wss.clients.forEach((ws: any) => ws.send(JSON.stringify(msg)));
      }
    });
  }
}
