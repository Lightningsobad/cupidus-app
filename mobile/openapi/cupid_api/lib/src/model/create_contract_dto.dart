//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_contract_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateContractDto {
  /// Returns a new [CreateContractDto] instance.
  CreateContractDto({

    required  this.clauses,
  });

      /// List of contract clauses
  @JsonKey(
    
    name: r'clauses',
    required: true,
    includeIfNull: false,
  )


  final List<String> clauses;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateContractDto &&
      other.clauses == clauses;

    @override
    int get hashCode =>
        clauses.hashCode;

  factory CreateContractDto.fromJson(Map<String, dynamic> json) => _$CreateContractDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateContractDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

