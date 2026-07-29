// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_vibe_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateVibeDtoCWProxy {
  CreateVibeDto mood(CreateVibeDtoMoodEnum mood);

  CreateVibeDto note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateVibeDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateVibeDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateVibeDto call({CreateVibeDtoMoodEnum mood, String? note});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateVibeDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateVibeDto.copyWith.fieldName(...)`
class _$CreateVibeDtoCWProxyImpl implements _$CreateVibeDtoCWProxy {
  const _$CreateVibeDtoCWProxyImpl(this._value);

  final CreateVibeDto _value;

  @override
  CreateVibeDto mood(CreateVibeDtoMoodEnum mood) => this(mood: mood);

  @override
  CreateVibeDto note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateVibeDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateVibeDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateVibeDto call({
    Object? mood = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return CreateVibeDto(
      mood: mood == const $CopyWithPlaceholder()
          ? _value.mood
          // ignore: cast_nullable_to_non_nullable
          : mood as CreateVibeDtoMoodEnum,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $CreateVibeDtoCopyWith on CreateVibeDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateVibeDto.copyWith(...)` or like so:`instanceOfCreateVibeDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateVibeDtoCWProxy get copyWith => _$CreateVibeDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateVibeDto _$CreateVibeDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateVibeDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['mood']);
      final val = CreateVibeDto(
        mood: $checkedConvert(
          'mood',
          (v) => $enumDecode(_$CreateVibeDtoMoodEnumEnumMap, v),
        ),
        note: $checkedConvert('note', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CreateVibeDtoToJson(CreateVibeDto instance) =>
    <String, dynamic>{
      'mood': _$CreateVibeDtoMoodEnumEnumMap[instance.mood]!,
      'note': ?instance.note,
    };

const _$CreateVibeDtoMoodEnumEnumMap = {
  CreateVibeDtoMoodEnum.happy: 'happy',
  CreateVibeDtoMoodEnum.sad: 'sad',
  CreateVibeDtoMoodEnum.angry: 'angry',
  CreateVibeDtoMoodEnum.horny: 'horny',
  CreateVibeDtoMoodEnum.tired: 'tired',
};
