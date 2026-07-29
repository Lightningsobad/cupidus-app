//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_dream_jar_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateDreamJarDto {
  /// Returns a new [CreateDreamJarDto] instance.
  CreateDreamJarDto({

    required  this.name,

    required  this.targetAmount,

     this.deadline,

     this.currency = 'VND',
  });

      /// Name of the Dream Jar
  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



      /// Target amount to save
          // minimum: 1
  @JsonKey(
    
    name: r'targetAmount',
    required: true,
    includeIfNull: false,
  )


  final num targetAmount;



      /// Target date to reach the goal (ISO string)
  @JsonKey(
    
    name: r'deadline',
    required: false,
    includeIfNull: false,
  )


  final String? deadline;



      /// Currency code
  @JsonKey(
    defaultValue: 'VND',
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateDreamJarDto &&
      other.name == name &&
      other.targetAmount == targetAmount &&
      other.deadline == deadline &&
      other.currency == currency;

    @override
    int get hashCode =>
        name.hashCode +
        targetAmount.hashCode +
        deadline.hashCode +
        currency.hashCode;

  factory CreateDreamJarDto.fromJson(Map<String, dynamic> json) => _$CreateDreamJarDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDreamJarDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

