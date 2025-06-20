import { Test, TestingModule } from '@nestjs/testing';
import { PlugScheduleController } from './plug-schedule.controller';
import { PlugScheduleService } from './plug-schedule.service';

describe('PlugScheduleController', () => {
  let controller: PlugScheduleController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PlugScheduleController],
      providers: [PlugScheduleService],
    }).compile();

    controller = module.get<PlugScheduleController>(PlugScheduleController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
