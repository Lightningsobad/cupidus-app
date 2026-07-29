// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_timeline_event_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateTimelineEventDtoCWProxy {
  CreateTimelineEventDto title(String title);

  CreateTimelineEventDto description(String? description);

  CreateTimelineEventDto photoUrl(String? photoUrl);

  CreateTimelineEventDto icon(String? icon);

  CreateTimelineEventDto type(CreateTimelineEventDtoTypeEnum? type);

  CreateTimelineEventDto date(String? date);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateTimelineEventDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateTimelineEventDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateTimelineEventDto call({
    String title,
    String? description,
    String? photoUrl,
    String? icon,
    CreateTimelineEventDtoTypeEnum? type,
    String? date,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateTimelineEventDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateTimelineEventDto.copyWith.fieldName(...)`
class _$CreateTimelineEventDtoCWProxyImpl
    implements _$CreateTimelineEventDtoCWProxy {
  const _$CreateTimelineEventDtoCWProxyImpl(this._value);

  final CreateTimelineEventDto _value;

  @override
  CreateTimelineEventDto title(String title) => this(title: title);

  @override
  CreateTimelineEventDto description(String? description) =>
      this(description: description);

  @override
  CreateTimelineEventDto photoUrl(String? photoUrl) => this(photoUrl: photoUrl);

  @override
  CreateTimelineEventDto icon(String? icon) => this(icon: icon);

  @override
  CreateTimelineEventDto type(CreateTimelineEventDtoTypeEnum? type) =>
      this(type: type);

  @override
  CreateTimelineEventDto date(String? date) => this(date: date);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateTimelineEventDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateTimelineEventDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateTimelineEventDto call({
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? photoUrl = const $CopyWithPlaceholder(),
    Object? icon = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
  }) {
    return CreateTimelineEventDto(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      photoUrl: photoUrl == const $CopyWithPlaceholder()
          ? _value.photoUrl
          // ignore: cast_nullable_to_non_nullable
          : photoUrl as String?,
      icon: icon == const $CopyWithPlaceholder()
          ? _value.icon
          // ignore: cast_nullable_to_non_nullable
          : icon as String?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as CreateTimelineEventDtoTypeEnum?,
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as String?,
    );
  }
}

extension $CreateTimelineEventDtoCopyWith on CreateTimelineEventDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateTimelineEventDto.copyWith(...)` or like so:`instanceOfCreateTimelineEventDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateTimelineEventDtoCWProxy get copyWith =>
      _$CreateTimelineEventDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTimelineEventDto _$CreateTimelineEventDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateTimelineEventDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['title']);
  final val = CreateTimelineEventDto(
    title: $checkedConvert('title', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String?),
    photoUrl: $checkedConvert('photoUrl', (v) => v as String?),
    icon: $checkedConvert('icon', (v) => v as String?),
    type: $checkedConvert(
      'type',
      (v) => $enumDecodeNullable(_$CreateTimelineEventDtoTypeEnumEnumMap, v),
    ),
    date: $checkedConvert('date', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$CreateTimelineEventDtoToJson(
  CreateTimelineEventDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': ?instance.description,
  'photoUrl': ?instance.photoUrl,
  'icon': ?instance.icon,
  'type': ?_$CreateTimelineEventDtoTypeEnumEnumMap[instance.type],
  'date': ?instance.date,
};

const _$CreateTimelineEventDtoTypeEnumEnumMap = {
  CreateTimelineEventDtoTypeEnum.milestone: 'milestone',
  CreateTimelineEventDtoTypeEnum.memory: 'memory',
  CreateTimelineEventDtoTypeEnum.system: 'system',
};
