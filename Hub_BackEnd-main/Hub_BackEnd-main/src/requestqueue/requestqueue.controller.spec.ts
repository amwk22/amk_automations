import { Test, TestingModule } from '@nestjs/testing';
import { RequestqueueController } from './requestqueue.controller';
import { RequestqueueService } from './requestqueue.service';

describe('RequestqueueController', () => {
  let controller: RequestqueueController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [RequestqueueController],
      providers: [RequestqueueService],
    }).compile();

    controller = module.get<RequestqueueController>(RequestqueueController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
