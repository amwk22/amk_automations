import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  MinLength,
  validate,
  Validate,
} from 'class-validator';
import { userRole } from '../entities/user.entity';
import { IsEmailUniqueConstraint } from 'src/validators/is-email-unique.constraint';
import { IsUsernameUniqueConstraint } from 'src/validators/is-username-unique.constraints';

export class CreateUserDto {
  @IsNotEmpty({ message: 'Username is required' })
  @Validate(IsUsernameUniqueConstraint, { message: 'username already exists' })
  username: string;
  @IsEmail({}, { message: 'Invalid email' })
  email: string;
  @Validate(IsEmailUniqueConstraint, { message: 'Email aleady exits' })
  @IsNotEmpty({ message: 'password is required' })
  @MinLength(8, { message: 'password must be at least 8 characters' })
  password: string;
  @IsEnum(userRole, { message: 'role must be either admin or user' })
  role: userRole;
}
