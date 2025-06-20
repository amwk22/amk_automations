import { Test, TestingModule } from '@nestjs/testing';
import { PrioritycontrolController } from './prioritycontrol.controller';
import { PrioritycontrolService } from './prioritycontrol.service';

describe('PrioritycontrolController', () => {
  let controller: PrioritycontrolController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PrioritycontrolController],
      providers: [PrioritycontrolService],
    }).compile();

    controller = module.get<PrioritycontrolController>(PrioritycontrolController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
