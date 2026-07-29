//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_config_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateConfigDto {
  /// Returns a new [UpdateConfigDto] instance.
  UpdateConfigDto({

    required  this.value,

     this.description,
  });

      /// Configuration value (can be any type: string, number, boolean, object)
  @JsonKey(
    
    name: r'value',
    required: true,
    includeIfNull: false,
  )


  final Object value;



      /// Optional description or reason for update
  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateConfigDto &&
      other.value == value &&
      other.description == description;

    @override
    int get hashCode =>
        value.hashCode +
        description.hashCode;

  factory UpdateConfigDto.fromJson(Map<String, dynamic> json) => _$UpdateConfigDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateConfigDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

