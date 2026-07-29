import { IsEnum, IsString, MinLength, MaxLength } from 'class-validator';
import { PetSpecies } from '../entities/pet.entity';
import { ApiProperty } from '@nestjs/swagger';

export class AdoptPetDto {
    @ApiProperty({ description: 'Species of the pet', enum: PetSpecies, example: PetSpecies.DOG })
    @IsEnum(PetSpecies)
    species: PetSpecies;

    @ApiProperty({ description: 'Name of the pet', example: 'Buddy', minLength: 1, maxLength: 30 })
    @IsString()
    @MinLength(1)
    @MaxLength(30)
    name: string;
}
