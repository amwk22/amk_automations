import { Test, TestingModule } from '@nestjs/testing';
import { PlugScheduleService } from './plug-schedule.service';

describe('PlugScheduleService', () => {
  let service: PlugScheduleService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PlugScheduleService],
    }).compile();

    service = module.get<PlugScheduleService>(PlugScheduleService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
