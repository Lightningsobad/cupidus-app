import {
  Injectable,
  ConflictException,
  BadRequestException,
  UnauthorizedException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { randomBytes } from 'crypto';
import { User } from '../users/entities/user.entity';
import { EmailVerification } from './entities/email-verification.entity';
import { MailService } from '../mail/mail.service';
import {
  RegisterDto,
  VerifyOtpDto,
  ResendOtpDto,
  LoginDto,
  ForgotPasswordDto,
  ResetPasswordDto,
} from './dto/auth.dto';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(EmailVerification)
    private emailVerificationRepository: Repository<EmailVerification>,
    private jwtService: JwtService,
    private mailService: MailService,
  ) {}

  /**
   * Register a new user and send a 6-digit OTP verification email via Resend SMTP
   */
  async register(registerDto: RegisterDto) {
    const { email, password, displayName } = registerDto;
    const normalizedEmail = email.trim().toLowerCase();

    const existingUser = await this.userRepository.findOne({
      where: { email: normalizedEmail },
    });

    if (existingUser && existingUser.isEmailVerified) {
      throw new ConflictException('Email này đã được đăng ký tài khoản');
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    let user = existingUser;
    if (!user) {
      user = this.userRepository.create({
        email: normalizedEmail,
        passwordHash,
        displayName: displayName || normalizedEmail.split('@')[0],
        isEmailVerified: false,
      });
    } else {
      user.passwordHash = passwordHash;
      if (displayName) {
        user.displayName = displayName;
      }
    }
    user = await this.userRepository.save(user);

    // Generate 6-digit OTP code & verify token
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const verifyToken = randomBytes(16).toString('hex');
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 mins

    // Invalidate old unverified OTPs for this email
    await this.emailVerificationRepository.update(
      { email: normalizedEmail, isUsed: false },
      { isUsed: true },
    );

    const verification = this.emailVerificationRepository.create({
      email: normalizedEmail,
      otpCode,
      verifyToken,
      expiresAt,
      isUsed: false,
    });
    await this.emailVerificationRepository.save(verification);

    // Send email using custom Cupid template
    await this.mailService.sendVerificationEmail({
      to: normalizedEmail,
      name: user.displayName,
      otpCode,
      verifyToken,
    });

    return {
      success: true,
      message: 'Mã xác thực OTP đã được gửi đến email của bạn',
      email: normalizedEmail,
    };
  }

  /**
   * Verify 6-digit OTP and return JWT access token
   */
  async verifyOtp(verifyOtpDto: VerifyOtpDto) {
    const { email, code } = verifyOtpDto;
    const normalizedEmail = email.trim().toLowerCase();

    const verification = await this.emailVerificationRepository.findOne({
      where: {
        email: normalizedEmail,
        otpCode: code.trim(),
        isUsed: false,
        expiresAt: MoreThan(new Date()),
      },
      order: { createdAt: 'DESC' },
    });

    if (!verification) {
      throw new BadRequestException('Mã xác nhận không đúng hoặc đã hết hạn');
    }

    verification.isUsed = true;
    await this.emailVerificationRepository.save(verification);

    let user = await this.userRepository.findOne({
      where: { email: normalizedEmail },
    });

    if (!user) {
      throw new NotFoundException('Không tìm thấy thông tin tài khoản');
    }

    user.isEmailVerified = true;
    user = await this.userRepository.save(user);

    const accessToken = this.generateToken(user);

    return {
      success: true,
      message: 'Xác thực tài khoản thành công',
      accessToken,
      user: this.sanitizeUser(user),
    };
  }

  /**
   * Resend 6-digit OTP verification email with 60s cooldown
   */
  async resendOtp(resendOtpDto: ResendOtpDto) {
    const { email } = resendOtpDto;
    const normalizedEmail = email.trim().toLowerCase();

    const user = await this.userRepository.findOne({
      where: { email: normalizedEmail },
    });

    if (!user) {
      throw new NotFoundException('Không tìm thấy tài khoản với email này');
    }

    if (user.isEmailVerified) {
      throw new BadRequestException('Tài khoản đã được xác thực trước đó');
    }

    // Cooldown check (60 seconds with 5s clock skew grace window)
    const recentVerification = await this.emailVerificationRepository.findOne({
      where: {
        email: normalizedEmail,
        createdAt: MoreThan(new Date(Date.now() - 55 * 1000)),
      },
      order: { createdAt: 'DESC' },
    });

    if (recentVerification) {
      const elapsed = Math.floor((Date.now() - recentVerification.createdAt.getTime()) / 1000);
      const remaining = Math.max(1, 60 - elapsed);
      throw new BadRequestException(`Vui lòng đợi ${remaining} giây trước khi yêu cầu gửi lại mã`);
    }

    // Invalidate existing unused OTPs
    await this.emailVerificationRepository.update(
      { email: normalizedEmail, isUsed: false },
      { isUsed: true },
    );

    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const verifyToken = randomBytes(16).toString('hex');
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    const verification = this.emailVerificationRepository.create({
      email: normalizedEmail,
      otpCode,
      verifyToken,
      expiresAt,
      isUsed: false,
    });
    await this.emailVerificationRepository.save(verification);

    await this.mailService.sendVerificationEmail({
      to: normalizedEmail,
      name: user.displayName,
      otpCode,
      verifyToken,
    });

    return {
      success: true,
      message: 'Đã gửi lại mã OTP xác nhận đến email của bạn',
    };
  }

  /**
   * Verify account via email link ("Cách 2: Bấm một nút")
   */
  async verifyLink(token: string): Promise<string> {
    if (!token) {
      return this.renderLinkResultHtml(false, 'Đường dẫn xác nhận không hợp lệ.');
    }

    const verification = await this.emailVerificationRepository.findOne({
      where: {
        verifyToken: token,
        isUsed: false,
        expiresAt: MoreThan(new Date()),
      },
    });

    if (!verification) {
      return this.renderLinkResultHtml(
        false,
        'Liên kết kích hoạt đã hết hạn hoặc đã được sử dụng. Vui lòng mở ứng dụng để yêu cầu mã mới.',
      );
    }

    verification.isUsed = true;
    await this.emailVerificationRepository.save(verification);

    const user = await this.userRepository.findOne({
      where: { email: verification.email },
    });

    if (user) {
      user.isEmailVerified = true;
      await this.userRepository.save(user);
    }

    return this.renderLinkResultHtml(
      true,
      `Tài khoản (${verification.email}) đã được kích hoạt thành công! Bạn có thể quay lại ứng dụng Cupid để tiếp tục.`,
    );
  }

  /**
   * Password login
   */
  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;
    const normalizedEmail = email.trim().toLowerCase();

    const user = await this.userRepository.findOne({
      where: { email: normalizedEmail },
    });

    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('Email hoặc mật khẩu không chính xác');
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      throw new UnauthorizedException('Email hoặc mật khẩu không chính xác');
    }

    if (!user.isEmailVerified) {
      return {
        success: false,
        requireVerification: true,
        message: 'Tài khoản chưa được xác thực email. Vui lòng nhập mã OTP đã gửi.',
        email: user.email,
      };
    }

    const accessToken = this.generateToken(user);

    return {
      success: true,
      accessToken,
      user: this.sanitizeUser(user),
    };
  }

  /**
   * Send OTP for forgot password
   */
  async forgotPassword(dto: ForgotPasswordDto) {
    const normalizedEmail = dto.email.trim().toLowerCase();
    const user = await this.userRepository.findOne({
      where: { email: normalizedEmail },
    });

    if (!user) {
      // Do not reveal email existence for security, return generic success
      return {
        success: true,
        message: 'Nếu email tồn tại trong hệ thống, mã khôi phục đã được gửi.',
      };
    }

    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const verifyToken = randomBytes(16).toString('hex');
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    const verification = this.emailVerificationRepository.create({
      email: normalizedEmail,
      otpCode,
      verifyToken,
      expiresAt,
      isUsed: false,
    });
    await this.emailVerificationRepository.save(verification);

    await this.mailService.sendVerificationEmail({
      to: normalizedEmail,
      name: user.displayName,
      otpCode,
      verifyToken,
    });

    return {
      success: true,
      message: 'Mã khôi phục mật khẩu đã được gửi đến email của bạn.',
    };
  }

  /**
   * Reset password with OTP code
   */
  async resetPassword(dto: ResetPasswordDto) {
    const { email, code, newPassword } = dto;
    const normalizedEmail = email.trim().toLowerCase();

    const verification = await this.emailVerificationRepository.findOne({
      where: {
        email: normalizedEmail,
        otpCode: code.trim(),
        isUsed: false,
        expiresAt: MoreThan(new Date()),
      },
    });

    if (!verification) {
      throw new BadRequestException('Mã xác nhận không đúng hoặc đã hết hạn');
    }

    verification.isUsed = true;
    await this.emailVerificationRepository.save(verification);

    const user = await this.userRepository.findOne({
      where: { email: normalizedEmail },
    });

    if (!user) {
      throw new NotFoundException('Không tìm thấy tài khoản');
    }

    const salt = await bcrypt.genSalt(10);
    user.passwordHash = await bcrypt.hash(newPassword, salt);
    user.isEmailVerified = true;
    await this.userRepository.save(user);

    const accessToken = this.generateToken(user);

    return {
      success: true,
      message: 'Đổi mật khẩu thành công',
      accessToken,
      user: this.sanitizeUser(user),
    };
  }

  /**
   * Legacy Firebase helpers for backward compatibility
   */
  async loginUser(firebaseUser: any): Promise<User | null> {
    const { uid, email } = firebaseUser;
    return this.userRepository.findOne({
      where: [{ firebaseUid: uid }, { email }],
    });
  }

  async registerUser(firebaseUser: any): Promise<User> {
    const { uid, email, name, picture } = firebaseUser;
    const existing = await this.userRepository.findOne({
      where: [{ firebaseUid: uid }, { email }],
    });
    if (existing) {
      throw new ConflictException('User already registered');
    }
    const user = this.userRepository.create({
      firebaseUid: uid,
      email,
      displayName: name,
      photoUrl: picture,
      isEmailVerified: true,
    });
    return this.userRepository.save(user);
  }

  public decodeToken(token: string): any {
    return this.jwtService.decode(token);
  }

  public generateToken(user: User): string {
    const payload = {
      sub: user.id,
      uid: user.id,
      email: user.email,
    };
    return this.jwtService.sign(payload);
  }

  public sanitizeUser(user: User) {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, ...safeUser } = user;
    return safeUser;
  }

  private renderLinkResultHtml(success: boolean, message: string): string {
    const title = success ? 'Kích hoạt thành công!' : 'Xác nhận không thành công';
    const icon = success ? '💖' : '⚠️';
    const color = success ? '#FF7FB6' : '#FFAB93';

    return `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${title} - Cupid</title>
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: #141024;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      color: #FFFFFF;
    }
    .card {
      background-color: #241B42;
      border: 1px solid #3A2F5E;
      border-radius: 24px;
      padding: 48px 36px;
      max-width: 440px;
      width: 90%;
      text-align: center;
      box-shadow: 0 20px 40px rgba(0,0,0,0.4);
    }
    .icon {
      font-size: 56px;
      margin-bottom: 20px;
    }
    h1 {
      font-size: 26px;
      color: #FFFFFF;
      margin: 0 0 16px 0;
    }
    p {
      color: #C9BEDC;
      font-size: 16px;
      line-height: 24px;
      margin: 0 0 32px 0;
    }
    .btn {
      display: inline-block;
      background: linear-gradient(135deg, #FF7FB6 0%, #FFAB93 100%);
      color: #2A1140;
      font-weight: 700;
      font-size: 16px;
      padding: 14px 32px;
      border-radius: 999px;
      text-decoration: none;
      box-shadow: 0 8px 24px rgba(255, 127, 182, 0.3);
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">${icon}</div>
    <h1 style="color:${color}">${title}</h1>
    <p>${message}</p>
    <a href="cupid://" class="btn">Mở ứng dụng Cupid</a>
  </div>
</body>
</html>`;
  }
}
