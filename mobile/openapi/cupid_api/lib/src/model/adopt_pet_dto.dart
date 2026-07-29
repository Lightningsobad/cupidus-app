//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'adopt_pet_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdoptPetDto {
  /// Returns a new [AdoptPetDto] instance.
  AdoptPetDto({

    required  this.species,

    required  this.name,
  });

      /// Species of the pet
  @JsonKey(
    
    name: r'species',
    required: true,
    includeIfNull: false,
  )


  final AdoptPetDtoSpeciesEnum species;



      /// Name of the pet
  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdoptPetDto &&
      other.species == species &&
      other.name == name;

    @override
    int get hashCode =>
        species.hashCode +
        name.hashCode;

  factory AdoptPetDto.fromJson(Map<String, dynamic> json) => _$AdoptPetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AdoptPetDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Species of the pet
enum AdoptPetDtoSpeciesEnum {
    /// Species of the pet
@JsonValue(r'cat')
cat(r'cat'),
    /// Species of the pet
@JsonValue(r'dog')
dog(r'dog'),
    /// Species of the pet
@JsonValue(r'bunny')
bunny(r'bunny');

const AdoptPetDtoSpeciesEnum(this.value);

final String value;

@override
String toString() => value;
}


