// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_gallery_item_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateGalleryItemDtoCWProxy {
  CreateGalleryItemDto filename(String filename);

  CreateGalleryItemDto mimeType(String? mimeType);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateGalleryItemDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateGalleryItemDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateGalleryItemDto call({String filename, String? mimeType});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateGalleryItemDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateGalleryItemDto.copyWith.fieldName(...)`
class _$CreateGalleryItemDtoCWProxyImpl
    implements _$CreateGalleryItemDtoCWProxy {
  const _$CreateGalleryItemDtoCWProxyImpl(this._value);

  final CreateGalleryItemDto _value;

  @override
  CreateGalleryItemDto filename(String filename) => this(filename: filename);

  @override
  CreateGalleryItemDto mimeType(String? mimeType) => this(mimeType: mimeType);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateGalleryItemDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateGalleryItemDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateGalleryItemDto call({
    Object? filename = const $CopyWithPlaceholder(),
    Object? mimeType = const $CopyWithPlaceholder(),
  }) {
    return CreateGalleryItemDto(
      filename: filename == const $CopyWithPlaceholder()
          ? _value.filename
          // ignore: cast_nullable_to_non_nullable
          : filename as String,
      mimeType: mimeType == const $CopyWithPlaceholder()
          ? _value.mimeType
          // ignore: cast_nullable_to_non_nullable
          : mimeType as String?,
    );
  }
}

extension $CreateGalleryItemDtoCopyWith on CreateGalleryItemDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateGalleryItemDto.copyWith(...)` or like so:`instanceOfCreateGalleryItemDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateGalleryItemDtoCWProxy get copyWith =>
      _$CreateGalleryItemDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateGalleryItemDto _$CreateGalleryItemDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateGalleryItemDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['filename']);
  final val = CreateGalleryItemDto(
    filename: $checkedConvert('filename', (v) => v as String),
    mimeType: $checkedConvert('mimeType', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$CreateGalleryItemDtoToJson(
  CreateGalleryItemDto instance,
) => <String, dynamic>{
  'filename': instance.filename,
  'mimeType': ?instance.mimeType,
};
