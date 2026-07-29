// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_contract_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateContractDtoCWProxy {
  CreateContractDto clauses(List<String> clauses);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateContractDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateContractDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateContractDto call({List<String> clauses});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateContractDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateContractDto.copyWith.fieldName(...)`
class _$CreateContractDtoCWProxyImpl implements _$CreateContractDtoCWProxy {
  const _$CreateContractDtoCWProxyImpl(this._value);

  final CreateContractDto _value;

  @override
  CreateContractDto clauses(List<String> clauses) => this(clauses: clauses);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateContractDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateContractDto(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateContractDto call({Object? clauses = const $CopyWithPlaceholder()}) {
    return CreateContractDto(
      clauses: clauses == const $CopyWithPlaceholder()
          ? _value.clauses
          // ignore: cast_nullable_to_non_nullable
          : clauses as List<String>,
    );
  }
}

extension $CreateContractDtoCopyWith on CreateContractDto {
  /// Returns a callable class that can be used as follows: `instanceOfCreateContractDto.copyWith(...)` or like so:`instanceOfCreateContractDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateContractDtoCWProxy get copyWith =>
      _$CreateContractDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateContractDto _$CreateContractDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateContractDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['clauses']);
      final val = CreateContractDto(
        clauses: $checkedConvert(
          'clauses',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CreateContractDtoToJson(CreateContractDto instance) =>
    <String, dynamic>{'clauses': instance.clauses};
