import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../modules/users/entities/user.entity';

@Injectable()
export class AdminGuard implements CanActivate {
    // Simple in-memory cache: userId → { role, expiresAt }
    private roleCache = new Map<string, { role: string; expiresAt: number }>();
    private static readonly CACHE_TTL_MS = 60_000; // 1 minute

    constructor(
        @InjectRepository(User)
        private usersRepository: Repository<User>,
    ) { }

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const request = context.switchToHttp().getRequest();
        const userId = request.user?.id;

        if (!userId) {
            throw new ForbiddenException('Authentication required');
        }

        const role = await this.getUserRole(userId);

        if (role !== 'admin') {
            throw new ForbiddenException('Admin access required');
        }

        return true;
    }

    private async getUserRole(userId: string): Promise<string | null> {
        const cached = this.roleCache.get(userId);
        if (cached && cached.expiresAt > Date.now()) {
            return cached.role;
        }

        const user = await this.usersRepository.findOne({
            where: { id: userId },
            select: ['id', 'role'],
        });

        if (!user) return null;

        this.roleCache.set(userId, {
            role: user.role,
            expiresAt: Date.now() + AdminGuard.CACHE_TTL_MS,
        });

        return user.role;
    }
}
