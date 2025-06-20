import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';
import {
  IsEnum,
  IsNotEmpty,
  IsOptional,
  Validate,
  IsEmpty,
} from 'class-validator';
import { userRole } from '../entities/user.entity';
import { IsEmailUniqueConstraint } from 'src/validators/is-email-unique.constraint';
import { IsUsernameUniqueConstraint } from 'src/validators/is-username-unique.constraints';

export class UpdateUserDto extends PartialType(CreateUserDto) {
  @IsEmpty({ message: 'ID cannot be updated' })
  readonly id: number;
  @IsOptional()
  @IsNotEmpty({ message: 'Username is required' })
  @Validate(IsUsernameUniqueConstraint, { message: 'username already exists' })
  username: string;
  @IsOptional()
  @IsNotEmpty({ message: 'Email is required' })
  @Validate(IsEmailUniqueConstraint, { message: 'email already exists' })
  email: string;
  @IsOptional()
  @IsNotEmpty({ message: 'Password is required' })
  password: string;
  @IsOptional()
  @IsEnum(userRole, { message: 'role must be either admin or user' })
  role: userRole;
}
