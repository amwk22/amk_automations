import { Test, TestingModule } from '@nestjs/testing';
import { SystemsettingsService } from './systemsettings.service';

describe('SystemsettingsService', () => {
  let service: SystemsettingsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [SystemsettingsService],
    }).compile();

    service = module.get<SystemsettingsService>(SystemsettingsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
