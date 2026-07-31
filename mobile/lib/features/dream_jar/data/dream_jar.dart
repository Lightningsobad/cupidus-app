/// STORY-014 P1 domain models (`architecture/solution.md` §4 `Contracts And
/// Integrations`). `part`s with `contribution.dart` so both models share the
/// one private tolerant-numeric parser required by ADR-014c: TypeORM
/// `decimal` columns (`targetAmount`, `currentAmount`, `Contribution.amount`)
/// serialize as JSON strings, not numbers.
library;

part 'contribution.dart';

/// Decoded from the lowercase wire value; an unrecognized value falls back
/// to [active] rather than throwing, so an additive backend status never
/// crashes the app.
enum DreamJarStatus {
  active,
  completed,
  archived;

  static DreamJarStatus fromWire(String? value) => DreamJarStatus.values
      .firstWhere((status) => status.name == value, orElse: () => active);
}

/// Accepts `num`, a numeric `String` (the wire shape for `decimal` columns),
/// or `null` (defaults to `0`).
num _parseAmount(Object? value) {
  if (value == null) return 0;
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

class DreamJar {
  const DreamJar({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.currency,
    required this.status,
    required this.serverProgress,
    required this.createdAt,
  });

  final String id;
  final String name;
  final num targetAmount;
  final num currentAmount;
  final DateTime? deadline;
  final String currency;
  final DreamJarStatus status;

  /// Raw server-computed `progress` field, when present. `null` when the
  /// payload omits it, in which case [progressPercent] falls back to the
  /// client-side computation.
  final int? serverProgress;
  final DateTime createdAt;

  factory DreamJar.fromJson(Map<String, dynamic> json) {
    final deadline = json['deadline'] as String?;
    return DreamJar(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: _parseAmount(json['targetAmount']),
      currentAmount: _parseAmount(json['currentAmount']),
      deadline: deadline == null ? null : DateTime.parse(deadline),
      currency: json['currency'] as String? ?? 'VND',
      status: DreamJarStatus.fromWire(json['status'] as String?),
      serverProgress: (json['progress'] as num?)?.round(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Clamped `0..100`. Prefers the server-provided `progress`; otherwise
  /// computes `min(100, round(current / target * 100))`, treating a
  /// non-positive [targetAmount] as `0` to avoid a division by zero
  /// (`architecture/solution.md` §4 `Risk Surfaces And Source Of Truth`).
  int get progressPercent {
    final serverValue = serverProgress;
    if (serverValue != null) {
      return serverValue.clamp(0, 100);
    }
    if (targetAmount <= 0) return 0;
    final computed = (currentAmount / targetAmount * 100).round();
    return computed.clamp(0, 100);
  }
}
