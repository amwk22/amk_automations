import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ParseIntPipe,
  UseGuards,
  Req,
} from '@nestjs/common';
import { SmartplugService } from './smartplug.service';
import { CreateSmartPlugDto } from './dto/create-smartplug.dto';
import { UpdateSmartplugDto } from './dto/update-smartplug.dto';
import { AuthGuard } from '@nestjs/passport';
import { Users } from 'src/users/entities/user.entity';

@Controller('smartplugs')
export class SmartplugController {
  constructor(private readonly smartplugService: SmartplugService) {}

  @Post()
  create(@Body() createSmartplugDto: CreateSmartPlugDto) {
    return this.smartplugService.create(createSmartplugDto);
  }

  @Get()
  findAll() {
    return this.smartplugService.findAll();
  }
  @Get('user')
  @UseGuards(AuthGuard('jwt'))
  getUserPlugs(@Req() req) {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-member-access
    return this.smartplugService.findAllByUserId(req.user.id);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.smartplugService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(AuthGuard('jwt'))
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateSmartplugDto: UpdateSmartplugDto,
    @Req() req,
  ) {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
    return this.smartplugService.update(id, updateSmartplugDto, req.user);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.smartplugService.remove(id);
  }
}
