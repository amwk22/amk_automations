import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Users } from './entities/user.entity';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { NotFoundException } from '@nestjs/common';
import { UpdatePasswordDto } from './dto/update-password.dto';
type UserWithoutPassword = Omit<Users, 'passwordHash'>;
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(Users)
    private readonly userRepository: Repository<Users>,
  ) {}

  async create(createUserDto: CreateUserDto): Promise<Users> {
    let hashedPassword: string;
    try {
      hashedPassword = await bcrypt.hash(createUserDto.password, 10);
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (error) {
      throw new Error('Error hashing password');
    }
    try {
      const user = this.userRepository.create({
        ...createUserDto,
        passwordHash: hashedPassword, // ✅ save it in the correct column
      });
      return this.userRepository.save(user);
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (error) {
      throw new Error('Error creating user');
    }
  }

  async findAll(): Promise<Users[]> {
    try {
      return this.userRepository.find({
        select: ['id', 'username', 'email'],
      });
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (error) {
      throw new Error('Error finding users');
    }
  }
  async findone(id: string): Promise<UserWithoutPassword> {
    console.log('Finding user with ID:', id);
    const userId = parseInt(id, 10);
    try {
      const user = await this.userRepository.findOneBy({ id: userId });
      if (!user) {
        throw new Error(`User with id ${id} not found`);
      }

      const { passwordHash, ...UserWithoutPassword } = user;
      return UserWithoutPassword;

      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (error) {
      throw new Error('Error finding user');
    }
  }
  async update(id: string, updateUserDto: UpdateUserDto): Promise<Users> {
    try {
      const user = await this.userRepository.findOne({
        where: { id: parseInt(id, 10) },
      });

      if (!user) {
        throw new Error(`User with id ${id} not found`);
      }

      if (updateUserDto.email !== undefined) {
        user.email = updateUserDto.email;
      }

      if (updateUserDto.username !== undefined) {
        user.username = updateUserDto.username;
      }

      return this.userRepository.save(user);
    } catch (error) {
      throw new Error('Error updating user');
    }
  }

  async remove(id: string): Promise<string> {
    const result = await this.userRepository.delete({ id: parseInt(id, 10) });
    if (result.affected === 0) {
      throw new NotFoundException(`User with id ${id} not found`);
    }
    return 'User deleted';
  }

  async updatePassword(
    id: string,
    dto: UpdatePasswordDto,
  ): Promise<{ message: string }> {
    const user = await this.userRepository.findOne({
      where: { id: parseInt(id, 10) },
    });

    if (!user) throw new Error('User not found');

    const isMatch = await bcrypt.compare(dto.oldPassword, user.passwordHash);
    if (!isMatch) throw new Error('Old password is incorrect');

    const hashedNewPassword = await bcrypt.hash(dto.newPassword, 10);
    user.passwordHash = hashedNewPassword;

    await this.userRepository.save(user);

    return { message: 'Password updated successfully' };
  }

  async deleteAccount(
    id: string,
    password: string,
  ): Promise<{ message: string }> {
    const user = await this.userRepository.findOne({
      where: { id: parseInt(id, 10) },
    });

    if (!user) {
      throw new Error('User not found');
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      throw new Error('Incorrect password');
    }

    await this.userRepository.remove(user);
    return { message: 'Account successfully deleted' };
  }
}
