//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_expense_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateExpenseDto {
  /// Returns a new [CreateExpenseDto] instance.
  CreateExpenseDto({

    required  this.category,

    required  this.amount,

     this.description,

    required  this.date,
  });

      /// Expense category
  @JsonKey(
    
    name: r'category',
    required: true,
    includeIfNull: false,
  )


  final CreateExpenseDtoCategoryEnum category;



      /// Expense amount
          // minimum: 1
  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final num amount;



      /// Optional description of the expense
  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



      /// Date of the expense (ISO string, cannot be future date)
  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final String date;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateExpenseDto &&
      other.category == category &&
      other.amount == amount &&
      other.description == description &&
      other.date == date;

    @override
    int get hashCode =>
        category.hashCode +
        amount.hashCode +
        description.hashCode +
        date.hashCode;

  factory CreateExpenseDto.fromJson(Map<String, dynamic> json) => _$CreateExpenseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateExpenseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Expense category
enum CreateExpenseDtoCategoryEnum {
    /// Expense category
@JsonValue(r'food')
food(r'food'),
    /// Expense category
@JsonValue(r'date')
date(r'date'),
    /// Expense category
@JsonValue(r'travel')
travel(r'travel'),
    /// Expense category
@JsonValue(r'shopping')
shopping(r'shopping'),
    /// Expense category
@JsonValue(r'other')
other(r'other');

const CreateExpenseDtoCategoryEnum(this.value);

final String value;

@override
String toString() => value;
}


