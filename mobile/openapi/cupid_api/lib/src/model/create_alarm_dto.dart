//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_alarm_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateAlarmDto {
  /// Returns a new [CreateAlarmDto] instance.
  CreateAlarmDto({

    required  this.time,
  });

      /// Alarm time in ISO 8601 format
  @JsonKey(
    
    name: r'time',
    required: true,
    includeIfNull: false,
  )


  final String time;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateAlarmDto &&
      other.time == time;

    @override
    int get hashCode =>
        time.hashCode;

  factory CreateAlarmDto.fromJson(Map<String, dynamic> json) => _$CreateAlarmDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAlarmDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

