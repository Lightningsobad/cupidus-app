import { Controller, Get, Post, Delete, Param, Body, Query, UseGuards, Request, ParseUUIDPipe } from '@nestjs/common';
import { ExpensesService } from './expenses.service';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Epic 5 - Expenses')
@ApiBearerAuth('firebase-jwt')
@Controller('expenses')
@UseGuards(JwtAuthGuard)
export class ExpensesController {
    constructor(
        private readonly expensesService: ExpensesService,
        private readonly usersService: UsersService,
    ) { }

    @Post()
    @ApiOperation({ summary: 'Log a new shared expense' })
    async create(@Request() req, @Body() dto: CreateExpenseDto) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.expensesService.create(user.id, dto);
    }

    @Get()
    @ApiOperation({ summary: 'Get all expenses' })
    async findAll(@Request() req, @Query('limit') limit?: string, @Query('offset') offset?: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.expensesService.findAll(user.id, Number(limit) || 50, Number(offset) || 0);
    }

    @Get('report')
    @ApiOperation({ summary: 'Get expense summary report (week/month)' })
    async getReport(@Request() req, @Query('period') period: 'week' | 'month' = 'month') {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.expensesService.getReport(user.id, period);
    }

    @Delete(':id')
    @ApiOperation({ summary: 'Delete an expense log' })
    async remove(@Request() req, @Param('id', ParseUUIDPipe) id: string) {
        const user = await this.usersService.findByFirebaseUid(req.user.uid);
        return this.expensesService.remove(user.id, id);
    }
}
