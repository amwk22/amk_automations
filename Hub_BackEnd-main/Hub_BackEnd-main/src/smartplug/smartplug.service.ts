import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SmartPlug } from './entities/smartplug.entity';
import { CreateSmartPlugDto } from './dto/create-smartplug.dto';
import { UpdateSmartplugDto } from './dto/update-smartplug.dto';
import { Users } from 'src/users/entities/user.entity';

@Injectable()
export class SmartplugService {
  constructor(
    @InjectRepository(SmartPlug)
    private readonly smartplugRepository: Repository<SmartPlug>,

    @InjectRepository(Users)
    private readonly userRepository: Repository<Users>,
  ) {}

  // Create a Smart Plug
  async create(createDto: CreateSmartPlugDto): Promise<SmartPlug> {
    const user = await this.userRepository.findOne({
      where: { id: createDto.userID },
    });

    if (!user) throw new NotFoundException('User not found');

    const plug = this.smartplugRepository.create({
      zigbeeAddress: createDto.zigbeeAddress,
      name: createDto.name,
      estimatedAmps: createDto.estimatedAmps,
      users: user, // establish relation
    });

    return await this.smartplugRepository.save(plug);
  }

  // Get all plugs
  findAll(): Promise<SmartPlug[]> {
    return this.smartplugRepository.find({ relations: ['users'] });
  }

  // Get a single plug
  async findOne(id: number): Promise<SmartPlug> {
    const plug = await this.smartplugRepository.findOne({
      where: { Id: id },
      relations: ['users'],
    });
    if (!plug) throw new NotFoundException('Smart plug not found');
    return plug;
  }

  // Update plug
  async update(
    id: number,
    updateDto: UpdateSmartplugDto,
    user: any,
  ): Promise<SmartPlug> {
    const plug = await this.findOne(id);
    if (!plug) throw new NotFoundException('Smart plug not found');

    // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
    if (plug.users.id !== user.id)
      throw new NotFoundException('You are not authorized to update this plug');

    Object.assign(plug, updateDto);
    return this.smartplugRepository.save(plug);
  }

  // Delete plug
  async remove(id: number): Promise<{ message: string }> {
    const plug = await this.findOne(id);
    await this.smartplugRepository.remove(plug);
    return { message: 'Smart plug deleted successfully' };
  }

  async findAllByUserId(userId: number): Promise<SmartPlug[]> {
    return this.smartplugRepository.find({
      where: { users: { id: userId } },
      relations: ['users'],
    });
  }
}
