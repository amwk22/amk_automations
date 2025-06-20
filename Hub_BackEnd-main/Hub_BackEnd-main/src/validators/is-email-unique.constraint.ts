import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import {
  ValidationArguments,
  ValidatorConstraint,
  ValidatorConstraintInterface,
} from 'class-validator';
import { Users } from 'src/users/entities/user.entity';
import { Repository } from 'typeorm';

@ValidatorConstraint({ async: true })
@Injectable()
export class IsEmailUniqueConstraint implements ValidatorConstraintInterface {
  constructor(
    @InjectRepository(Users)
    private readonly UserRepository: Repository<Users>,
  ) {}
  // eslint-disable-next-line prettier/prettier
  async validate(email: string): Promise<boolean> {
    const user = await this.UserRepository.findOne({ where: { email } });
    return !user;
  }
  defaultMessage(args: ValidationArguments): string {
    return `Email '${args.value}' already exists`;
  }
}
/**
 * ✅ @Validate() accepts a class, NOT a standalone function
The @Validate() decorator in class-validator expects a custom constraint class 
(not a regular function) as its argument.

🔵 It specifically requires a class that:
Is decorated with @ValidatorConstraint().
Implements the ValidatorConstraintInterface.
Contains a validate() method inside that class.
 */
