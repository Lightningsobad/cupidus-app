import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsOptional, IsString, Length, MinLength } from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'linh@example.com', description: 'User email' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  @IsNotEmpty({ message: 'Email không được để trống' })
  email: string;

  @ApiProperty({ example: 'Password123!', description: 'User password' })
  @IsString()
  @MinLength(6, { message: 'Mật khẩu phải có ít nhất 6 ký tự' })
  @IsNotEmpty({ message: 'Mật khẩu không được để trống' })
  password: string;

  @ApiPropertyOptional({ example: 'Linh', description: 'Display name' })
  @IsOptional()
  @IsString()
  displayName?: string;
}

export class VerifyOtpDto {
  @ApiProperty({ example: 'linh@example.com', description: 'User email' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  @IsNotEmpty({ message: 'Email không được để trống' })
  email: string;

  @ApiProperty({ example: '482906', description: '6-digit OTP verification code' })
  @IsString()
  @Length(6, 6, { message: 'Mã OTP phải gồm 6 chữ số' })
  @IsNotEmpty({ message: 'Mã OTP không được để trống' })
  code: string;
}

export class ResendOtpDto {
  @ApiProperty({ example: 'linh@example.com', description: 'User email' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  @IsNotEmpty({ message: 'Email không được để trống' })
  email: string;
}

export class LoginDto {
  @ApiProperty({ example: 'linh@example.com', description: 'User email' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  @IsNotEmpty({ message: 'Email không được để trống' })
  email: string;

  @ApiProperty({ example: 'Password123!', description: 'User password' })
  @IsString()
  @IsNotEmpty({ message: 'Mật khẩu không được để trống' })
  password: string;
}

export class ForgotPasswordDto {
  @ApiProperty({ example: 'linh@example.com', description: 'User email' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  @IsNotEmpty({ message: 'Email không được để trống' })
  email: string;
}

export class ResetPasswordDto {
  @ApiProperty({ example: 'linh@example.com', description: 'User email' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  @IsNotEmpty({ message: 'Email không được để trống' })
  email: string;

  @ApiProperty({ example: '482906', description: '6-digit OTP code' })
  @IsString()
  @Length(6, 6, { message: 'Mã OTP phải gồm 6 chữ số' })
  @IsNotEmpty({ message: 'Mã OTP không được để trống' })
  code: string;

  @ApiProperty({ example: 'NewPassword123!', description: 'New password' })
  @IsString()
  @MinLength(6, { message: 'Mật khẩu mới phải có ít nhất 6 ký tự' })
  @IsNotEmpty({ message: 'Mật khẩu mới không được để trống' })
  newPassword: string;
}
