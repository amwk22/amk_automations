import { Test, TestingModule } from '@nestjs/testing';
import { SmartplugService } from './smartplug.service';

describe('SmartplugService', () => {
  let service: SmartplugService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [SmartplugService],
    }).compile();

    service = module.get<SmartplugService>(SmartplugService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
