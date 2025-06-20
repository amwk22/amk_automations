import { Test, TestingModule } from '@nestjs/testing';
import { RequestqueueService } from './requestqueue.service';

describe('RequestqueueService', () => {
  let service: RequestqueueService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [RequestqueueService],
    }).compile();

    service = module.get<RequestqueueService>(RequestqueueService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
