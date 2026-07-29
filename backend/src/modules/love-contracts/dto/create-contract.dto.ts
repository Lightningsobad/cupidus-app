import { IsArray, IsString, ArrayMinSize, ArrayMaxSize } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateContractDto {
    @ApiProperty({ description: 'List of contract clauses', example: ['We will communicate openly', 'We will prioritize each other'], type: [String] })
    @IsArray()
    @IsString({ each: true })
    @ArrayMinSize(1)
    @ArrayMaxSize(20)
    clauses: string[];
}
