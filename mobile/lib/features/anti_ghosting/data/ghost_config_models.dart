/// Frozen `ghost-config` wire contract (`architecture/solution.md` §2, §4;
/// `backend/src/modules/ghost-config/entities/ghost-config.entity.ts`). This
/// module is a pure consumer and must never widen or reinterpret the
/// contract.
library;

/// Wire values: `emoji_storm` | `noise` | `none`
/// (`ghost-config.entity.ts` `Penalty`). An unrecognized wire value falls
/// back to [none] rather than throwing, since `none` is already the
/// contract's "no penalty" case.
enum Penalty {
  emojiStorm('emoji_storm'),
  noise('noise'),
  none('none');

  const Penalty(this.wireValue);

  final String wireValue;

  static Penalty fromWire(String? value) {
    for (final penalty in Penalty.values) {
      if (penalty.wireValue == value) {
        return penalty;
      }
    }
    return Penalty.none;
  }
}

/// Wire values: `active` | `pending_approval` | `rejected` | `superseded`
/// (`ghost-config.entity.ts` `ConfigStatus`). [unknown] is a client-only
/// fallback for an unrecognized wire value — the server never sends it and
/// this repository never sends [ConfigStatus] to the server.
enum ConfigStatus {
  active('active'),
  pendingApproval('pending_approval'),
  rejected('rejected'),
  superseded('superseded'),
  unknown('unknown');

  const ConfigStatus(this.wireValue);

  final String wireValue;

  static ConfigStatus fromWire(String? value) {
    for (final status in ConfigStatus.values) {
      if (status.wireValue == value) {
        return status;
      }
    }
    return ConfigStatus.unknown;
  }
}

/// `ghost-config.entity.ts` `GhostConfig` entity fields consumed by mobile.
class GhostConfig {
  const GhostConfig({
    required this.id,
    required this.coupleId,
    required this.timeoutMinutes,
    required this.penalty,
    required this.publicCountdown,
    required this.proposedBy,
    required this.approvedBy,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GhostConfig.fromJson(Map<String, dynamic> json) {
    return GhostConfig(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      timeoutMinutes: json['timeoutMinutes'] as int,
      penalty: Penalty.fromWire(json['penalty'] as String?),
      // Nullable-tolerant by contract (`architecture/contract-summary.md` §4):
      // mobile must build against a backend that has not deployed the column
      // yet, and `true` is byte-identical to the persisted column default.
      publicCountdown: json['publicCountdown'] as bool? ?? true,
      proposedBy: json['proposedBy'] as String,
      approvedBy: json['approvedBy'] as String?,
      status: ConfigStatus.fromWire(json['status'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String coupleId;
  final int timeoutMinutes;
  final Penalty penalty;
  final bool publicCountdown;
  final String proposedBy;
  final String? approvedBy;
  final ConfigStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// `GET /ghost-config/storm-status/:partnerId` response
/// (`architecture/solution.md` §2): `{eligible: bool, penalty: string|null}`.
/// `penalty` is legitimately `null` (no active config / not eligible), which
/// is distinct from an unrecognized wire string.
class StormStatus {
  const StormStatus({required this.eligible, required this.penalty});

  factory StormStatus.fromJson(Map<String, dynamic> json) {
    final rawPenalty = json['penalty'] as String?;
    return StormStatus(
      eligible: json['eligible'] as bool,
      penalty: rawPenalty == null ? null : Penalty.fromWire(rawPenalty),
    );
  }

  final bool eligible;
  final Penalty? penalty;
}
