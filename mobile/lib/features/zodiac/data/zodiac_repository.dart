import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../design_system/icons/cupid_zodiac_icon.dart';
import '../domain/zodiac_red_flag.dart';

/// The only file under `mobile/lib` aware of `/zodiac` paths and the payload
/// JSON keys (`architecture/solution.md` §4 Mobile Lane). Rethrows the mapped
/// [CupidApiFailure] from `DioException.error` (never the raw [DioException]),
/// matching `VibesRepository`.
class ZodiacRepository {
  ZodiacRepository(this._api);

  final CupidApi _api;

  /// `GET /zodiac/red-flag/today`. Always `200` for an authenticated caller —
  /// the incomplete-profile case is a payload state, not a 4xx
  /// (`architecture/contract-summary.md` §1).
  Future<ZodiacRedFlagToday> fetchToday() async {
    try {
      final response = await _api.dio.get<Object?>('/zodiac/red-flag/today');
      return parseZodiacRedFlagToday(response.data);
    } on DioException catch (e) {
      throw (e.error as CupidApiFailure?) ?? const UnexpectedFailure();
    }
  }
}

/// Matches `status` textually. Anything that is not `ready` — including an
/// unrecognised value — becomes [ZodiacRedFlagIncompleteProfile], never
/// `ready` (`architecture/contract-summary.md` §1).
///
/// A `ready` body missing a required key is a contract violation and throws
/// [UnexpectedFailure] so the caller surfaces its generic error state; no
/// default is substituted (§3).
@visibleForTesting
ZodiacRedFlagToday parseZodiacRedFlagToday(Object? data) {
  if (data is! Map<String, dynamic>) {
    throw const UnexpectedFailure();
  }

  final contentDate = _requiredString(data, 'contentDate');

  if (data['status'] != 'ready') {
    final missing = data['missing'];
    return ZodiacRedFlagIncompleteProfile(
      contentDate: contentDate,
      missing: missing is List
          ? missing.whereType<String>().toList(growable: false)
          : const [],
    );
  }

  return ZodiacRedFlagReady(
    contentDate: contentDate,
    conflictIndex: _parseConflictIndex(data['conflictIndex']),
    partners: _parseList(data['partners'], _parsePartner),
    dailyTips: _parseList(data['dailyTips'], _parseDailyTip),
  );
}

ZodiacConflictIndex _parseConflictIndex(Object? raw) {
  final json = _asObject(raw);
  return ZodiacConflictIndex(
    score: _requiredInt(json, 'score'),
    scoreMax: _requiredInt(json, 'scoreMax'),
    headline: _requiredString(json, 'headline'),
    body: _requiredString(json, 'body'),
  );
}

ZodiacPartner _parsePartner(Map<String, dynamic> json) {
  final role = _requiredString(json, 'role');
  final sign = CupidZodiacSign.tryParse(_requiredString(json, 'zodiacSign'));
  if (sign == null) {
    throw const UnexpectedFailure();
  }
  return ZodiacPartner(
    role: ZodiacPartnerRole.values.firstWhere(
      (candidate) => candidate.name == role,
      orElse: () => throw const UnexpectedFailure(),
    ),
    displayName: _optionalString(json, 'displayName'),
    sign: sign,
  );
}

ZodiacDailyTip _parseDailyTip(Map<String, dynamic> json) {
  return ZodiacDailyTip(
    id: _requiredString(json, 'id'),
    icon: ZodiacTipIcon.fromWire(json['icon']),
    tint: ZodiacTipTint.fromWire(json['tint']),
    title: _requiredString(json, 'title'),
    body: _requiredString(json, 'body'),
  );
}

List<T> _parseList<T>(Object? raw, T Function(Map<String, dynamic>) parse) {
  if (raw is! List) {
    throw const UnexpectedFailure();
  }
  return raw.map((entry) => parse(_asObject(entry))).toList(growable: false);
}

Map<String, dynamic> _asObject(Object? raw) {
  if (raw is! Map<String, dynamic>) {
    throw const UnexpectedFailure();
  }
  return raw;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw const UnexpectedFailure();
  }
  return value;
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is String ? value : null;
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw const UnexpectedFailure();
  }
  return value;
}
