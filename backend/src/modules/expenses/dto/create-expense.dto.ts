import { IsString, IsNumber, IsOptional, Min, Max, IsEnum, IsDateString, Validate, ValidatorConstraint, ValidatorConstraintInterface, ValidationArguments } from 'class-validator';
import { ExpenseCategory } from '../entities/expense.entity';
import { ApiProperty } from '@nestjs/swagger';

@ValidatorConstraint({ name: 'isNotFutureDate', async: false })
class IsNotFutureDate implements ValidatorConstraintInterface {
    validate(value: string) {
        if (!value) return true;
        const inputDate = new Date(value);
        const today = new Date();
        today.setHours(23, 59, 59, 999);
        return inputDate <= today;
    }

    defaultMessage(args: ValidationArguments) {
        return 'Expense date cannot be in the future';
    }
}

export class CreateExpenseDto {
    @ApiProperty({ description: 'Expense category', enum: ExpenseCategory, example: ExpenseCategory.FOOD })
    @IsEnum(ExpenseCategory)
    category: ExpenseCategory;

    @ApiProperty({ description: 'Expense amount', example: 250000, minimum: 1 })
    @IsNumber()
    @Min(1)
    @Max(999999999999)
    amount: number;

    @ApiProperty({ description: 'Optional description of the expense', required: false })
    @IsOptional()
    @IsString()
    description?: string;

    @ApiProperty({ description: 'Date of the expense (ISO string, cannot be future date)', example: '2023-10-25T14:30:00.000Z' })
    @IsDateString()
    @Validate(IsNotFutureDate)
    date: string;
}
