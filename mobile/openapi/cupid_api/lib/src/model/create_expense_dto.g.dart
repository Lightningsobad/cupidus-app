// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_expense_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateExpenseDtoCWProxy {
  CreateExpenseDto category(CreateExpenseDtoCategoryEnum category);

  CreateExpenseDto amount(num amount);

  CreateExpenseDto description(String? description);

  CreateExpenseDto date(String date);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateExpenseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateExpenseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateExpenseDto call({
    CreateExpenseDtoCategoryEnum category,
    num amount,
    String? description,
    String date,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateExpenseDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateExpenseDto.copyWith.fieldName(...)`
class _$CreateExpenseDtoCWProxyImpl implements _$CreateExpenseDtoCWProxy {
  const _$CreateExpenseDtoCWProxyImpl(this._value);

  final CreateExpenseDto _value;

  @override
  CreateExpenseDto category(CreateExpenseDtoCategoryEnum category) =>
      this(category: category);

  @override
  CreateExpenseDto amount(num amount) => this(amount: amount);

  @override
  CreateExpenseDto description(String? description) =>
      this(description: description);

  @override
  CreateExpenseDto date(String date) => this(date: date);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateExpenseDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateExpenseDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateExpenseDto call({
    Object? category = const $CopyWithPlaceholder(),
    Object? amount = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
  }) {
    return CreateExpenseDto(
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as CreateExpenseDtoCategoryEnum,
      amount: amount == const $CopyWithPlaceholder()
          ? _value.amount
          // ignore: cast_nullable_to_non_nullable
          : amount as num,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as String,
    );
  }
}

extension $CreateExpenseDtoCopyWith on CreateExpenseDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateExpenseDto.copyWith(...)` or like so:`instanceOfCreateExpenseDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateExpenseDtoCWProxy get copyWith => _$CreateExpenseDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateExpenseDto _$CreateExpenseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateExpenseDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['category', 'amount', 'date']);
      final val = CreateExpenseDto(
        category: $checkedConvert(
          'category',
          (v) => $enumDecode(_$CreateExpenseDtoCategoryEnumEnumMap, v),
        ),
        amount: $checkedConvert('amount', (v) => v as num),
        description: $checkedConvert('description', (v) => v as String?),
        date: $checkedConvert('date', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CreateExpenseDtoToJson(CreateExpenseDto instance) =>
    <String, dynamic>{
      'category': _$CreateExpenseDtoCategoryEnumEnumMap[instance.category]!,
      'amount': instance.amount,
      'description': ?instance.description,
      'date': instance.date,
    };

const _$CreateExpenseDtoCategoryEnumEnumMap = {
  CreateExpenseDtoCategoryEnum.food: 'food',
  CreateExpenseDtoCategoryEnum.date: 'date',
  CreateExpenseDtoCategoryEnum.travel: 'travel',
  CreateExpenseDtoCategoryEnum.shopping: 'shopping',
  CreateExpenseDtoCategoryEnum.other: 'other',
};
