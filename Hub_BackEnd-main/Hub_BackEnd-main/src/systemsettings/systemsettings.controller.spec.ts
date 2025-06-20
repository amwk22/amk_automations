import { Test, TestingModule } from '@nestjs/testing';
import { SystemsettingsController } from './systemsettings.controller';
import { SystemsettingsService } from './systemsettings.service';

describe('SystemsettingsController', () => {
  let controller: SystemsettingsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [SystemsettingsController],
      providers: [SystemsettingsService],
    }).compile();

    controller = module.get<SystemsettingsController>(SystemsettingsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
