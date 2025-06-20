import { Test, TestingModule } from '@nestjs/testing';
import { SmartplugController } from './smartplug.controller';
import { SmartplugService } from './smartplug.service';

describe('SmartplugController', () => {
  let controller: SmartplugController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [SmartplugController],
      providers: [SmartplugService],
    }).compile();

    controller = module.get<SmartplugController>(SmartplugController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
