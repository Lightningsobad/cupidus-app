// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_dream_jar_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateDreamJarDtoCWProxy {
  CreateDreamJarDto name(String name);

  CreateDreamJarDto targetAmount(num targetAmount);

  CreateDreamJarDto deadline(String? deadline);

  CreateDreamJarDto currency(String? currency);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateDreamJarDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateDreamJarDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateDreamJarDto call({
    String name,
    num targetAmount,
    String? deadline,
    String? currency,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateDreamJarDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateDreamJarDto.copyWith.fieldName(...)`
class _$CreateDreamJarDtoCWProxyImpl implements _$CreateDreamJarDtoCWProxy {
  const _$CreateDreamJarDtoCWProxyImpl(this._value);

  final CreateDreamJarDto _value;

  @override
  CreateDreamJarDto name(String name) => this(name: name);

  @override
  CreateDreamJarDto targetAmount(num targetAmount) =>
      this(targetAmount: targetAmount);

  @override
  CreateDreamJarDto deadline(String? deadline) => this(deadline: deadline);

  @override
  CreateDreamJarDto currency(String? currency) => this(currency: currency);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateDreamJarDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateDreamJarDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateDreamJarDto call({
    Object? name = const $CopyWithPlaceholder(),
    Object? targetAmount = const $CopyWithPlaceholder(),
    Object? deadline = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
  }) {
    return CreateDreamJarDto(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      targetAmount: targetAmount == const $CopyWithPlaceholder()
          ? _value.targetAmount
          // ignore: cast_nullable_to_non_nullable
          : targetAmount as num,
      deadline: deadline == const $CopyWithPlaceholder()
          ? _value.deadline
          // ignore: cast_nullable_to_non_nullable
          : deadline as String?,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String?,
    );
  }
}

extension $CreateDreamJarDtoCopyWith on CreateDreamJarDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateDreamJarDto.copyWith(...)` or like so:`instanceOfCreateDreamJarDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateDreamJarDtoCWProxy get copyWith =>
      _$CreateDreamJarDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDreamJarDto _$CreateDreamJarDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateDreamJarDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'targetAmount']);
      final val = CreateDreamJarDto(
        name: $checkedConvert('name', (v) => v as String),
        targetAmount: $checkedConvert('targetAmount', (v) => v as num),
        deadline: $checkedConvert('deadline', (v) => v as String?),
        currency: $checkedConvert('currency', (v) => v as String? ?? 'VND'),
      );
      return val;
    });

Map<String, dynamic> _$CreateDreamJarDtoToJson(CreateDreamJarDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'targetAmount': instance.targetAmount,
      'deadline': ?instance.deadline,
      'currency': ?instance.currency,
    };
