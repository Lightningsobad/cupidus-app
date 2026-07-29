//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_ghost_config_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateGhostConfigDto {
  /// Returns a new [CreateGhostConfigDto] instance.
  CreateGhostConfigDto({

    required  this.timeoutMinutes,

    required  this.penalty,
  });

      /// Ghosting timeout in minutes (1-120)
  @JsonKey(
    
    name: r'timeoutMinutes',
    required: true,
    includeIfNull: false,
  )


  final num timeoutMinutes;



      /// Penalty type
  @JsonKey(
    
    name: r'penalty',
    required: true,
    includeIfNull: false,
  )


  final CreateGhostConfigDtoPenaltyEnum penalty;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateGhostConfigDto &&
      other.timeoutMinutes == timeoutMinutes &&
      other.penalty == penalty;

    @override
    int get hashCode =>
        timeoutMinutes.hashCode +
        penalty.hashCode;

  factory CreateGhostConfigDto.fromJson(Map<String, dynamic> json) => _$CreateGhostConfigDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateGhostConfigDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Penalty type
enum CreateGhostConfigDtoPenaltyEnum {
    /// Penalty type
@JsonValue(r'emoji_storm')
emojiStorm(r'emoji_storm'),
    /// Penalty type
@JsonValue(r'noise')
noise(r'noise'),
    /// Penalty type
@JsonValue(r'none')
none(r'none');

const CreateGhostConfigDtoPenaltyEnum(this.value);

final String value;

@override
String toString() => value;
}


