// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_config_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateConfigDtoCWProxy {
  UpdateConfigDto value(Object value);

  UpdateConfigDto description(String? description);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateConfigDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateConfigDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateConfigDto call({Object value, String? description});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateConfigDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateConfigDto.copyWith.fieldName(...)`
class _$UpdateConfigDtoCWProxyImpl implements _$UpdateConfigDtoCWProxy {
  const _$UpdateConfigDtoCWProxyImpl(this._value);

  final UpdateConfigDto _value;

  @override
  UpdateConfigDto value(Object value) => this(value: value);

  @override
  UpdateConfigDto description(String? description) =>
      this(description: description);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateConfigDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateConfigDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateConfigDto call({
    Object? value = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
  }) {
    return UpdateConfigDto(
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as Object,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
    );
  }
}

extension $UpdateConfigDtoCopyWith on UpdateConfigDto {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateConfigDto.copyWith(...)` or like so:`instanceOfUpdateConfigDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateConfigDtoCWProxy get copyWith => _$UpdateConfigDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateConfigDto _$UpdateConfigDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UpdateConfigDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['value']);
      final val = UpdateConfigDto(
        value: $checkedConvert('value', (v) => v as Object),
        description: $checkedConvert('description', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$UpdateConfigDtoToJson(UpdateConfigDto instance) =>
    <String, dynamic>{
      'value': instance.value,
      'description': ?instance.description,
    };
