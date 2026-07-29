//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_dream_jar_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateDreamJarDto {
  /// Returns a new [UpdateDreamJarDto] instance.
  UpdateDreamJarDto({

     this.name,

     this.targetAmount,

     this.deadline,

     this.status,
  });

      /// Name of the Dream Jar
  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



      /// Target amount to save
          // minimum: 1
  @JsonKey(
    
    name: r'targetAmount',
    required: false,
    includeIfNull: false,
  )


  final num? targetAmount;



      /// Target date to reach the goal (ISO string)
  @JsonKey(
    
    name: r'deadline',
    required: false,
    includeIfNull: false,
  )


  final String? deadline;



      /// Status of the Dream Jar
  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final UpdateDreamJarDtoStatusEnum? status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateDreamJarDto &&
      other.name == name &&
      other.targetAmount == targetAmount &&
      other.deadline == deadline &&
      other.status == status;

    @override
    int get hashCode =>
        name.hashCode +
        targetAmount.hashCode +
        deadline.hashCode +
        status.hashCode;

  factory UpdateDreamJarDto.fromJson(Map<String, dynamic> json) => _$UpdateDreamJarDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDreamJarDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Status of the Dream Jar
enum UpdateDreamJarDtoStatusEnum {
    /// Status of the Dream Jar
@JsonValue(r'active')
active(r'active'),
    /// Status of the Dream Jar
@JsonValue(r'completed')
completed(r'completed'),
    /// Status of the Dream Jar
@JsonValue(r'archived')
archived(r'archived');

const UpdateDreamJarDtoStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


