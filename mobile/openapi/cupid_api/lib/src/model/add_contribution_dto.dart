//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'add_contribution_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AddContributionDto {
  /// Returns a new [AddContributionDto] instance.
  AddContributionDto({

    required  this.amount,

     this.note,
  });

      /// Contribution amount
          // minimum: 1
  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final num amount;



      /// Optional note for this contribution
  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AddContributionDto &&
      other.amount == amount &&
      other.note == note;

    @override
    int get hashCode =>
        amount.hashCode +
        note.hashCode;

  factory AddContributionDto.fromJson(Map<String, dynamic> json) => _$AddContributionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AddContributionDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

