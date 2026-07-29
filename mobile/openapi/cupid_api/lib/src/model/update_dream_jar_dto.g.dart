// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_dream_jar_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateDreamJarDtoCWProxy {
  UpdateDreamJarDto name(String? name);

  UpdateDreamJarDto targetAmount(num? targetAmount);

  UpdateDreamJarDto deadline(String? deadline);

  UpdateDreamJarDto status(UpdateDreamJarDtoStatusEnum? status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateDreamJarDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateDreamJarDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateDreamJarDto call({
    String? name,
    num? targetAmount,
    String? deadline,
    UpdateDreamJarDtoStatusEnum? status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateDreamJarDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateDreamJarDto.copyWith.fieldName(...)`
class _$UpdateDreamJarDtoCWProxyImpl implements _$UpdateDreamJarDtoCWProxy {
  const _$UpdateDreamJarDtoCWProxyImpl(this._value);

  final UpdateDreamJarDto _value;

  @override
  UpdateDreamJarDto name(String? name) => this(name: name);

  @override
  UpdateDreamJarDto targetAmount(num? targetAmount) =>
      this(targetAmount: targetAmount);

  @override
  UpdateDreamJarDto deadline(String? deadline) => this(deadline: deadline);

  @override
  UpdateDreamJarDto status(UpdateDreamJarDtoStatusEnum? status) =>
      this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateDreamJarDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateDreamJarDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateDreamJarDto call({
    Object? name = const $CopyWithPlaceholder(),
    Object? targetAmount = const $CopyWithPlaceholder(),
    Object? deadline = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return UpdateDreamJarDto(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      targetAmount: targetAmount == const $CopyWithPlaceholder()
          ? _value.targetAmount
          // ignore: cast_nullable_to_non_nullable
          : targetAmount as num?,
      deadline: deadline == const $CopyWithPlaceholder()
          ? _value.deadline
          // ignore: cast_nullable_to_non_nullable
          : deadline as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as UpdateDreamJarDtoStatusEnum?,
    );
  }
}

extension $UpdateDreamJarDtoCopyWith on UpdateDreamJarDto {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateDreamJarDto.copyWith(...)` or like so:`instanceOfUpdateDreamJarDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateDreamJarDtoCWProxy get copyWith =>
      _$UpdateDreamJarDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateDreamJarDto _$UpdateDreamJarDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UpdateDreamJarDto', json, ($checkedConvert) {
      final val = UpdateDreamJarDto(
        name: $checkedConvert('name', (v) => v as String?),
        targetAmount: $checkedConvert('targetAmount', (v) => v as num?),
        deadline: $checkedConvert('deadline', (v) => v as String?),
        status: $checkedConvert(
          'status',
          (v) => $enumDecodeNullable(_$UpdateDreamJarDtoStatusEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UpdateDreamJarDtoToJson(UpdateDreamJarDto instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'targetAmount': ?instance.targetAmount,
      'deadline': ?instance.deadline,
      'status': ?_$UpdateDreamJarDtoStatusEnumEnumMap[instance.status],
    };

const _$UpdateDreamJarDtoStatusEnumEnumMap = {
  UpdateDreamJarDtoStatusEnum.active: 'active',
  UpdateDreamJarDtoStatusEnum.completed: 'completed',
  UpdateDreamJarDtoStatusEnum.archived: 'archived',
};
