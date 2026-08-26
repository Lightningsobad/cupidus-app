import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { ThemesService } from './themes.service';
import { RequestThemeDto } from './dto/request-theme.dto';
import { WishlistThemeDto } from './dto/wishlist-theme.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Theme Store')
@ApiBearerAuth('firebase-jwt')
@Controller('themes')
@UseGuards(JwtAuthGuard)
export class ThemesController {
    constructor(
        private readonly themesService: ThemesService,
        private readonly usersService: UsersService,
    ) { }

    @Get('catalog')
    @ApiOperation({ summary: 'Get the Theme Catalog' })
    getCatalog() {
        return this.themesService.getThemeCatalog();
    }

    @Get('state')
    @ApiOperation({ summary: 'Get current couple theme state (active theme, owned themes, wallet hearts, pending requests)' })
    async getState(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.themesService.getCoupleThemeState(user.id);
    }

    @Post('request')
    @ApiOperation({ summary: 'Request to switch to or unlock a theme (pending partner approval)' })
    async requestTheme(@Request() req, @Body() dto: RequestThemeDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.themesService.requestTheme(user.id, dto.themeId);
    }

    @Post('approve')
    @ApiOperation({ summary: 'Partner approves the pending theme change' })
    async approveTheme(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.themesService.approveTheme(user.id);
    }

    @Post('reject')
    @ApiOperation({ summary: 'Partner rejects the pending theme change' })
    async rejectTheme(@Request() req) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.themesService.rejectTheme(user.id);
    }

    @Post('wishlist')
    @ApiOperation({ summary: 'Toggle a theme in the couple wishlist' })
    async toggleWishlist(@Request() req, @Body() dto: WishlistThemeDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.themesService.toggleWishlist(user.id, dto.themeId);
    }
}
