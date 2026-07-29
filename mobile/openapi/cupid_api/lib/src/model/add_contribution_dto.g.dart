// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_contribution_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AddContributionDtoCWProxy {
  AddContributionDto amount(num amount);

  AddContributionDto note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AddContributionDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AddContributionDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AddContributionDto call({num amount, String? note});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAddContributionDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAddContributionDto.copyWith.fieldName(...)`
class _$AddContributionDtoCWProxyImpl implements _$AddContributionDtoCWProxy {
  const _$AddContributionDtoCWProxyImpl(this._value);

  final AddContributionDto _value;

  @override
  AddContributionDto amount(num amount) => this(amount: amount);

  @override
  AddContributionDto note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AddContributionDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AddContributionDto(...).copyWith(id: 12, name: "My name")
  /// ````
  AddContributionDto call({
    Object? amount = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return AddContributionDto(
      amount: amount == const $CopyWithPlaceholder()
          ? _value.amount
          // ignore: cast_nullable_to_non_nullable
          : amount as num,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $AddContributionDtoCopyWith on AddContributionDto {
  /// Returns a callable class that can be used as follows: `instanceOfAddContributionDto.copyWith(...)` or like so:`instanceOfAddContributionDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AddContributionDtoCWProxy get copyWith =>
      _$AddContributionDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddContributionDto _$AddContributionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AddContributionDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['amount']);
      final val = AddContributionDto(
        amount: $checkedConvert('amount', (v) => v as num),
        note: $checkedConvert('note', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$AddContributionDtoToJson(AddContributionDto instance) =>
    <String, dynamic>{'amount': instance.amount, 'note': ?instance.note};
