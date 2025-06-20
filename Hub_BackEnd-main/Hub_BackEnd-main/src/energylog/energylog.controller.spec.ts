import { Test, TestingModule } from '@nestjs/testing';
import { EnergylogController } from './energylog.controller';
import { EnergylogService } from './energylog.service';

describe('EnergylogController', () => {
  let controller: EnergylogController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [EnergylogController],
      providers: [EnergylogService],
    }).compile();

    controller = module.get<EnergylogController>(EnergylogController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
