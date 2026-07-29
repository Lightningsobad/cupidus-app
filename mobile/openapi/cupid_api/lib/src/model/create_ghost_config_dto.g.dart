// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_ghost_config_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateGhostConfigDtoCWProxy {
  CreateGhostConfigDto timeoutMinutes(num timeoutMinutes);

  CreateGhostConfigDto penalty(CreateGhostConfigDtoPenaltyEnum penalty);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateGhostConfigDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateGhostConfigDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateGhostConfigDto call({
    num timeoutMinutes,
    CreateGhostConfigDtoPenaltyEnum penalty,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateGhostConfigDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateGhostConfigDto.copyWith.fieldName(...)`
class _$CreateGhostConfigDtoCWProxyImpl
    implements _$CreateGhostConfigDtoCWProxy {
  const _$CreateGhostConfigDtoCWProxyImpl(this._value);

  final CreateGhostConfigDto _value;

  @override
  CreateGhostConfigDto timeoutMinutes(num timeoutMinutes) =>
      this(timeoutMinutes: timeoutMinutes);

  @override
  CreateGhostConfigDto penalty(CreateGhostConfigDtoPenaltyEnum penalty) =>
      this(penalty: penalty);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateGhostConfigDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateGhostConfigDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateGhostConfigDto call({
    Object? timeoutMinutes = const $CopyWithPlaceholder(),
    Object? penalty = const $CopyWithPlaceholder(),
  }) {
    return CreateGhostConfigDto(
      timeoutMinutes: timeoutMinutes == const $CopyWithPlaceholder()
          ? _value.timeoutMinutes
          // ignore: cast_nullable_to_non_nullable
          : timeoutMinutes as num,
      penalty: penalty == const $CopyWithPlaceholder()
          ? _value.penalty
          // ignore: cast_nullable_to_non_nullable
          : penalty as CreateGhostConfigDtoPenaltyEnum,
    );
  }
}

extension $CreateGhostConfigDtoCopyWith on CreateGhostConfigDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateGhostConfigDto.copyWith(...)` or like so:`instanceOfCreateGhostConfigDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateGhostConfigDtoCWProxy get copyWith =>
      _$CreateGhostConfigDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateGhostConfigDto _$CreateGhostConfigDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateGhostConfigDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['timeoutMinutes', 'penalty']);
  final val = CreateGhostConfigDto(
    timeoutMinutes: $checkedConvert('timeoutMinutes', (v) => v as num),
    penalty: $checkedConvert(
      'penalty',
      (v) => $enumDecode(_$CreateGhostConfigDtoPenaltyEnumEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$CreateGhostConfigDtoToJson(
  CreateGhostConfigDto instance,
) => <String, dynamic>{
  'timeoutMinutes': instance.timeoutMinutes,
  'penalty': _$CreateGhostConfigDtoPenaltyEnumEnumMap[instance.penalty]!,
};

const _$CreateGhostConfigDtoPenaltyEnumEnumMap = {
  CreateGhostConfigDtoPenaltyEnum.emojiStorm: 'emoji_storm',
  CreateGhostConfigDtoPenaltyEnum.noise: 'noise',
  CreateGhostConfigDtoPenaltyEnum.none: 'none',
};
