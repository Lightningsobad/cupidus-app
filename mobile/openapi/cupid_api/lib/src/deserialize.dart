import 'package:cupid_api/src/model/add_contribution_dto.dart';
import 'package:cupid_api/src/model/adopt_pet_dto.dart';
import 'package:cupid_api/src/model/create_alarm_dto.dart';
import 'package:cupid_api/src/model/create_contract_dto.dart';
import 'package:cupid_api/src/model/create_dream_jar_dto.dart';
import 'package:cupid_api/src/model/create_expense_dto.dart';
import 'package:cupid_api/src/model/create_gallery_item_dto.dart';
import 'package:cupid_api/src/model/create_ghost_config_dto.dart';
import 'package:cupid_api/src/model/create_timeline_event_dto.dart';
import 'package:cupid_api/src/model/create_vibe_dto.dart';
import 'package:cupid_api/src/model/update_config_dto.dart';
import 'package:cupid_api/src/model/update_dream_jar_dto.dart';
import 'package:cupid_api/src/model/update_profile_dto.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'AddContributionDto':
          return AddContributionDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdoptPetDto':
          return AdoptPetDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateAlarmDto':
          return CreateAlarmDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateContractDto':
          return CreateContractDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateDreamJarDto':
          return CreateDreamJarDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateExpenseDto':
          return CreateExpenseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateGalleryItemDto':
          return CreateGalleryItemDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateGhostConfigDto':
          return CreateGhostConfigDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateTimelineEventDto':
          return CreateTimelineEventDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateVibeDto':
          return CreateVibeDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateConfigDto':
          return UpdateConfigDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateDreamJarDto':
          return UpdateDreamJarDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateProfileDto':
          return UpdateProfileDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }