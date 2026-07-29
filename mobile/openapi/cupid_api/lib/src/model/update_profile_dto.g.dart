// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateProfileDtoCWProxy {
  UpdateProfileDto displayName(String? displayName);

  UpdateProfileDto birthday(String? birthday);

  UpdateProfileDto relationshipStartDate(String? relationshipStartDate);

  UpdateProfileDto zodiacSign(String? zodiacSign);

  UpdateProfileDto language(String? language);

  UpdateProfileDto photoUrl(String? photoUrl);

  UpdateProfileDto coupleType(UpdateProfileDtoCoupleTypeEnum? coupleType);

  UpdateProfileDto isGhostModeEnabled(bool? isGhostModeEnabled);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateProfileDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateProfileDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateProfileDto call({
    String? displayName,
    String? birthday,
    String? relationshipStartDate,
    String? zodiacSign,
    String? language,
    String? photoUrl,
    UpdateProfileDtoCoupleTypeEnum? coupleType,
    bool? isGhostModeEnabled,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateProfileDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateProfileDto.copyWith.fieldName(...)`
class _$UpdateProfileDtoCWProxyImpl implements _$UpdateProfileDtoCWProxy {
  const _$UpdateProfileDtoCWProxyImpl(this._value);

  final UpdateProfileDto _value;

  @override
  UpdateProfileDto displayName(String? displayName) =>
      this(displayName: displayName);

  @override
  UpdateProfileDto birthday(String? birthday) => this(birthday: birthday);

  @override
  UpdateProfileDto relationshipStartDate(String? relationshipStartDate) =>
      this(relationshipStartDate: relationshipStartDate);

  @override
  UpdateProfileDto zodiacSign(String? zodiacSign) =>
      this(zodiacSign: zodiacSign);

  @override
  UpdateProfileDto language(String? language) => this(language: language);

  @override
  UpdateProfileDto photoUrl(String? photoUrl) => this(photoUrl: photoUrl);

  @override
  UpdateProfileDto coupleType(UpdateProfileDtoCoupleTypeEnum? coupleType) =>
      this(coupleType: coupleType);

  @override
  UpdateProfileDto isGhostModeEnabled(bool? isGhostModeEnabled) =>
      this(isGhostModeEnabled: isGhostModeEnabled);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateProfileDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateProfileDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateProfileDto call({
    Object? displayName = const $CopyWithPlaceholder(),
    Object? birthday = const $CopyWithPlaceholder(),
    Object? relationshipStartDate = const $CopyWithPlaceholder(),
    Object? zodiacSign = const $CopyWithPlaceholder(),
    Object? language = const $CopyWithPlaceholder(),
    Object? photoUrl = const $CopyWithPlaceholder(),
    Object? coupleType = const $CopyWithPlaceholder(),
    Object? isGhostModeEnabled = const $CopyWithPlaceholder(),
  }) {
    return UpdateProfileDto(
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      birthday: birthday == const $CopyWithPlaceholder()
          ? _value.birthday
          // ignore: cast_nullable_to_non_nullable
          : birthday as String?,
      relationshipStartDate:
          relationshipStartDate == const $CopyWithPlaceholder()
          ? _value.relationshipStartDate
          // ignore: cast_nullable_to_non_nullable
          : relationshipStartDate as String?,
      zodiacSign: zodiacSign == const $CopyWithPlaceholder()
          ? _value.zodiacSign
          // ignore: cast_nullable_to_non_nullable
          : zodiacSign as String?,
      language: language == const $CopyWithPlaceholder()
          ? _value.language
          // ignore: cast_nullable_to_non_nullable
          : language as String?,
      photoUrl: photoUrl == const $CopyWithPlaceholder()
          ? _value.photoUrl
          // ignore: cast_nullable_to_non_nullable
          : photoUrl as String?,
      coupleType: coupleType == const $CopyWithPlaceholder()
          ? _value.coupleType
          // ignore: cast_nullable_to_non_nullable
          : coupleType as UpdateProfileDtoCoupleTypeEnum?,
      isGhostModeEnabled: isGhostModeEnabled == const $CopyWithPlaceholder()
          ? _value.isGhostModeEnabled
          // ignore: cast_nullable_to_non_nullable
          : isGhostModeEnabled as bool?,
    );
  }
}

extension $UpdateProfileDtoCopyWith on UpdateProfileDto {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateProfileDto.copyWith(...)` or like so:`instanceOfUpdateProfileDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateProfileDtoCWProxy get copyWith => _$UpdateProfileDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileDto _$UpdateProfileDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UpdateProfileDto', json, ($checkedConvert) {
      final val = UpdateProfileDto(
        displayName: $checkedConvert('displayName', (v) => v as String?),
        birthday: $checkedConvert('birthday', (v) => v as String?),
        relationshipStartDate: $checkedConvert(
          'relationshipStartDate',
          (v) => v as String?,
        ),
        zodiacSign: $checkedConvert('zodiacSign', (v) => v as String?),
        language: $checkedConvert('language', (v) => v as String?),
        photoUrl: $checkedConvert('photoUrl', (v) => v as String?),
        coupleType: $checkedConvert(
          'coupleType',
          (v) =>
              $enumDecodeNullable(_$UpdateProfileDtoCoupleTypeEnumEnumMap, v),
        ),
        isGhostModeEnabled: $checkedConvert(
          'isGhostModeEnabled',
          (v) => v as bool?,
        ),
      );
      return val;
    });

Map<String, dynamic> _$UpdateProfileDtoToJson(
  UpdateProfileDto instance,
) => <String, dynamic>{
  'displayName': ?instance.displayName,
  'birthday': ?instance.birthday,
  'relationshipStartDate': ?instance.relationshipStartDate,
  'zodiacSign': ?instance.zodiacSign,
  'language': ?instance.language,
  'photoUrl': ?instance.photoUrl,
  'coupleType': ?_$UpdateProfileDtoCoupleTypeEnumEnumMap[instance.coupleType],
  'isGhostModeEnabled': ?instance.isGhostModeEnabled,
};

const _$UpdateProfileDtoCoupleTypeEnumEnumMap = {
  UpdateProfileDtoCoupleTypeEnum.SAME_CITY: 'SAME_CITY',
  UpdateProfileDtoCoupleTypeEnum.LONG_DISTANCE: 'LONG_DISTANCE',
  UpdateProfileDtoCoupleTypeEnum.LIVING_TOGETHER: 'LIVING_TOGETHER',
  UpdateProfileDtoCoupleTypeEnum.DATING: 'DATING',
};
