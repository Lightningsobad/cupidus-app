// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adopt_pet_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdoptPetDtoCWProxy {
  AdoptPetDto species(AdoptPetDtoSpeciesEnum species);

  AdoptPetDto name(String name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdoptPetDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdoptPetDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AdoptPetDto call({AdoptPetDtoSpeciesEnum species, String name});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdoptPetDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdoptPetDto.copyWith.fieldName(...)`
class _$AdoptPetDtoCWProxyImpl implements _$AdoptPetDtoCWProxy {
  const _$AdoptPetDtoCWProxyImpl(this._value);

  final AdoptPetDto _value;

  @override
  AdoptPetDto species(AdoptPetDtoSpeciesEnum species) => this(species: species);

  @override
  AdoptPetDto name(String name) => this(name: name);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdoptPetDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdoptPetDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AdoptPetDto call({
    Object? species = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return AdoptPetDto(
      species: species == const $CopyWithPlaceholder()
          ? _value.species
          // ignore: cast_nullable_to_non_nullable
          : species as AdoptPetDtoSpeciesEnum,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
    );
  }
}

extension $AdoptPetDtoCopyWith on AdoptPetDto {
  /// Returns a callable class that can be used as follows: `instanceOfAdoptPetDto.copyWith(...)` or like so:`instanceOfAdoptPetDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdoptPetDtoCWProxy get copyWith => _$AdoptPetDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdoptPetDto _$AdoptPetDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AdoptPetDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['species', 'name']);
      final val = AdoptPetDto(
        species: $checkedConvert(
          'species',
          (v) => $enumDecode(_$AdoptPetDtoSpeciesEnumEnumMap, v),
        ),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AdoptPetDtoToJson(AdoptPetDto instance) =>
    <String, dynamic>{
      'species': _$AdoptPetDtoSpeciesEnumEnumMap[instance.species]!,
      'name': instance.name,
    };

const _$AdoptPetDtoSpeciesEnumEnumMap = {
  AdoptPetDtoSpeciesEnum.cat: 'cat',
  AdoptPetDtoSpeciesEnum.dog: 'dog',
  AdoptPetDtoSpeciesEnum.bunny: 'bunny',
};
