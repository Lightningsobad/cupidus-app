import {
  Controller,
  Post,
  Get,
  Body,
  Query,
  UseGuards,
  Request,
  Header,
  UnauthorizedException,
} from '@nestjs/common';
import * as admin from 'firebase-admin';
import { AuthService } from './auth.service';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiOkResponse, ApiQuery } from '@nestjs/swagger';
import {
  RegisterDto,
  VerifyOtpDto,
  ResendOtpDto,
  LoginDto,
  ForgotPasswordDto,
  ResetPasswordDto,
} from './dto/auth.dto';

@ApiTags('Epic 1 - Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({
    summary: 'Đăng ký tài khoản và gửi mã OTP 6 số qua email (Resend SMTP)',
  })
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('verify-otp')
  @ApiOperation({
    summary: 'Xác thực mã OTP 6 số và nhận JWT token',
  })
  async verifyOtp(@Body() verifyOtpDto: VerifyOtpDto) {
    return this.authService.verifyOtp(verifyOtpDto);
  }

  @Post('resend-otp')
  @ApiOperation({
    summary: 'Gửi lại mã OTP 6 số (cooldown 60s)',
  })
  async resendOtp(@Body() resendOtpDto: ResendOtpDto) {
    return this.authService.resendOtp(resendOtpDto);
  }

  @Get('verify-link')
  @Header('content-type', 'text/html')
  @ApiOperation({
    summary: 'Xác thực qua đường link trong email ("Cách 2: Bấm một nút")',
  })
  @ApiQuery({ name: 'token', required: true, description: 'Verify token from email' })
  async verifyLink(@Query('token') token: string) {
    return this.authService.verifyLink(token);
  }

  @Post('login')
  @ApiOperation({
    summary: 'Đăng nhập bằng email & mật khẩu',
  })
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Post('forgot-password')
  @ApiOperation({
    summary: 'Yêu cầu mã OTP khôi phục mật khẩu',
  })
  async forgotPassword(@Body() forgotPasswordDto: ForgotPasswordDto) {
    return this.authService.forgotPassword(forgotPasswordDto);
  }

  @Post('reset-password')
  @ApiOperation({
    summary: 'Đặt lại mật khẩu với mã OTP',
  })
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
    return this.authService.resetPassword(resetPasswordDto);
  }

  @Get('me')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth('jwt')
  @ApiOperation({ summary: 'Lấy thông tin tài khoản hiện tại' })
  getMe(@Request() req) {
    return req.user;
  }

  /**
   * Endpoint for Google / Apple / Firebase social token login
   */
  @Post('firebase-login')
  @ApiOperation({ summary: 'Social / Firebase token login' })
  async legacyLogin(
    @Request() req,
    @Body() body?: { idToken?: string },
  ) {
    const authHeader = req.headers['authorization'];
    const rawToken =
      body?.idToken ||
      (authHeader?.startsWith('Bearer ') ? authHeader.substring(7) : null);

    if (!rawToken && !req.user) {
      throw new UnauthorizedException('Missing token');
    }

    let firebaseUser: any = req.user;

    if (!firebaseUser && rawToken) {
      try {
        if (admin.apps.length) {
          firebaseUser = await admin.auth().verifyIdToken(rawToken);
        } else {
          const decoded = this.authService.decodeToken(rawToken);
          if (decoded && (decoded.user_id || decoded.sub || decoded.uid)) {
            firebaseUser = {
              uid: decoded.user_id || decoded.sub || decoded.uid,
              email: decoded.email,
              name: decoded.name,
              picture: decoded.picture,
            };
          }
        }
      } catch (err) {
        const decoded = this.authService.decodeToken(rawToken);
        if (decoded && (decoded.user_id || decoded.sub || decoded.uid)) {
          firebaseUser = {
            uid: decoded.user_id || decoded.sub || decoded.uid,
            email: decoded.email,
            name: decoded.name,
            picture: decoded.picture,
          };
        } else {
          throw new UnauthorizedException('Invalid Firebase ID token');
        }
      }
    }

    if (!firebaseUser) {
      throw new UnauthorizedException('Unable to authenticate with Google');
    }

    let user = await this.authService.loginUser(firebaseUser);
    if (!user) {
      user = await this.authService.registerUser(firebaseUser);
    }
    const accessToken = this.authService.generateToken(user);
    return { accessToken, user: this.authService.sanitizeUser(user) };
  }
}
