// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_alarm_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateAlarmDtoCWProxy {
  CreateAlarmDto time(String time);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateAlarmDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateAlarmDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateAlarmDto call({String time});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateAlarmDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateAlarmDto.copyWith.fieldName(...)`
class _$CreateAlarmDtoCWProxyImpl implements _$CreateAlarmDtoCWProxy {
  const _$CreateAlarmDtoCWProxyImpl(this._value);

  final CreateAlarmDto _value;

  @override
  CreateAlarmDto time(String time) => this(time: time);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateAlarmDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateAlarmDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateAlarmDto call({Object? time = const $CopyWithPlaceholder()}) {
    return CreateAlarmDto(
      time: time == const $CopyWithPlaceholder()
          ? _value.time
          // ignore: cast_nullable_to_non_nullable
          : time as String,
    );
  }
}

extension $CreateAlarmDtoCopyWith on CreateAlarmDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateAlarmDto.copyWith(...)` or like so:`instanceOfCreateAlarmDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateAlarmDtoCWProxy get copyWith => _$CreateAlarmDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAlarmDto _$CreateAlarmDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateAlarmDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['time']);
      final val = CreateAlarmDto(
        time: $checkedConvert('time', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CreateAlarmDtoToJson(CreateAlarmDto instance) =>
    <String, dynamic>{'time': instance.time};
