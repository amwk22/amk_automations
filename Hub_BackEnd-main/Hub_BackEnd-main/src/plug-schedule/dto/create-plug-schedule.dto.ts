import {
  IsArray,
  IsBoolean,
  IsNotEmpty,
  IsString,
  Matches,
  ArrayNotEmpty,
} from 'class-validator';

export class CreatePlugScheduleDto {
  @IsString()
  @Matches(/^([01]\d|2[0-3]):([0-5]\d)$/, {
    message: 'onTime must be in HH:mm format',
  })
  onTime: string;

  @IsString()
  @Matches(/^([01]\d|2[0-3]):([0-5]\d)$/, {
    message: 'offTime must be in HH:mm format',
  })
  offTime: string;

  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  days: string[]; // Example: ["Monday", "Wednesday"]

  @IsBoolean()
  isActive: boolean;

  @IsNotEmpty()
  plugId: number;
}
