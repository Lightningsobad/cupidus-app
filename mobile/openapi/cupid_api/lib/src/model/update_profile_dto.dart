//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_profile_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateProfileDto {
  /// Returns a new [UpdateProfileDto] instance.
  UpdateProfileDto({

     this.displayName,

     this.birthday,

     this.relationshipStartDate,

     this.zodiacSign,

     this.language,

     this.photoUrl,

     this.coupleType,

     this.isGhostModeEnabled,
  });

      /// The display name of the user
  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



      /// The birthday of the user in ISO 8601 format
  @JsonKey(
    
    name: r'birthday',
    required: false,
    includeIfNull: false,
  )


  final String? birthday;



      /// The relationship start date in ISO 8601 format
  @JsonKey(
    
    name: r'relationshipStartDate',
    required: false,
    includeIfNull: false,
  )


  final String? relationshipStartDate;



      /// Zodiac sign
  @JsonKey(
    
    name: r'zodiacSign',
    required: false,
    includeIfNull: false,
  )


  final String? zodiacSign;



      /// Primary language
  @JsonKey(
    
    name: r'language',
    required: false,
    includeIfNull: false,
  )


  final String? language;



      /// Avatar URL
  @JsonKey(
    
    name: r'photoUrl',
    required: false,
    includeIfNull: false,
  )


  final String? photoUrl;



      /// Couple type
  @JsonKey(
    
    name: r'coupleType',
    required: false,
    includeIfNull: false,
  )


  final UpdateProfileDtoCoupleTypeEnum? coupleType;



      /// Is ghost mode enabled globally
  @JsonKey(
    
    name: r'isGhostModeEnabled',
    required: false,
    includeIfNull: false,
  )


  final bool? isGhostModeEnabled;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateProfileDto &&
      other.displayName == displayName &&
      other.birthday == birthday &&
      other.relationshipStartDate == relationshipStartDate &&
      other.zodiacSign == zodiacSign &&
      other.language == language &&
      other.photoUrl == photoUrl &&
      other.coupleType == coupleType &&
      other.isGhostModeEnabled == isGhostModeEnabled;

    @override
    int get hashCode =>
        displayName.hashCode +
        birthday.hashCode +
        relationshipStartDate.hashCode +
        zodiacSign.hashCode +
        language.hashCode +
        photoUrl.hashCode +
        coupleType.hashCode +
        isGhostModeEnabled.hashCode;

  factory UpdateProfileDto.fromJson(Map<String, dynamic> json) => _$UpdateProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Couple type
enum UpdateProfileDtoCoupleTypeEnum {
    /// Couple type
@JsonValue(r'SAME_CITY')
SAME_CITY(r'SAME_CITY'),
    /// Couple type
@JsonValue(r'LONG_DISTANCE')
LONG_DISTANCE(r'LONG_DISTANCE'),
    /// Couple type
@JsonValue(r'LIVING_TOGETHER')
LIVING_TOGETHER(r'LIVING_TOGETHER'),
    /// Couple type
@JsonValue(r'DATING')
DATING(r'DATING');

const UpdateProfileDtoCoupleTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


