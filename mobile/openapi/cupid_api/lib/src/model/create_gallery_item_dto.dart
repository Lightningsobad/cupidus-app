//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_gallery_item_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateGalleryItemDto {
  /// Returns a new [CreateGalleryItemDto] instance.
  CreateGalleryItemDto({

    required  this.filename,

     this.mimeType,
  });

      /// Encrypted filename or cloud reference ID
  @JsonKey(
    
    name: r'filename',
    required: true,
    includeIfNull: false,
  )


  final String filename;



      /// MIME type of the media
  @JsonKey(
    
    name: r'mimeType',
    required: false,
    includeIfNull: false,
  )


  final String? mimeType;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateGalleryItemDto &&
      other.filename == filename &&
      other.mimeType == mimeType;

    @override
    int get hashCode =>
        filename.hashCode +
        mimeType.hashCode;

  factory CreateGalleryItemDto.fromJson(Map<String, dynamic> json) => _$CreateGalleryItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateGalleryItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

