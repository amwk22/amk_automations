import { Test, TestingModule } from '@nestjs/testing';
import { EnergylogService } from './energylog.service';

describe('EnergylogService', () => {
  let service: EnergylogService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [EnergylogService],
    }).compile();

    service = module.get<EnergylogService>(EnergylogService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
