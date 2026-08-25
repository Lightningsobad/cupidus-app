import '../../../design_system/icons/cupid_zodiac_icon.dart';

/// The `GET /zodiac/red-flag/today` response union
/// (`architecture/contract-summary.md` §1). Parsing lives in
/// `data/zodiac_repository.dart`, the only file allowed to know the payload
/// keys; this file holds the parsed shape only.
sealed class ZodiacRedFlagToday {
  const ZodiacRedFlagToday({required this.contentDate});

  /// Server-local calendar day, `YYYY-MM-DD`. Always the server's value —
  /// never `DateTime.now()` (contract §3 row 1).
  final String contentDate;
}

/// The `ready` variant: a full three-card payload.
final class ZodiacRedFlagReady extends ZodiacRedFlagToday {
  const ZodiacRedFlagReady({
    required super.contentDate,
    required this.conflictIndex,
    required this.partners,
    required this.dailyTips,
  });

  final ZodiacConflictIndex conflictIndex;

  /// Exactly 2 entries with `partners[0].role == self` (contract §3 row 5).
  final List<ZodiacPartner> partners;

  /// Exactly 3 entries in wire order (contract §3 row 7).
  final List<ZodiacDailyTip> dailyTips;
}

/// The `incomplete_profile` variant, and the landing point for any
/// unrecognised `status` (contract §1: fail honest, never `ready`). It carries
/// no card content at all, so a partial render cannot fabricate one.
final class ZodiacRedFlagIncompleteProfile extends ZodiacRedFlagToday {
  const ZodiacRedFlagIncompleteProfile({
    required super.contentDate,
    required this.missing,
  });

  /// Present for logging and future copy only — the degraded card is neutral
  /// and must not branch on this (contract §4).
  final List<String> missing;
}

class ZodiacConflictIndex {
  const ZodiacConflictIndex({
    required this.score,
    required this.scoreMax,
    required this.headline,
    required this.body,
  });

  final int score;
  final int scoreMax;
  final String headline;
  final String body;

  /// Bar fill, the one value mobile derives (contract §3 row 3). Never
  /// hardcode `10` or `70%`.
  double get fillFraction =>
      scoreMax <= 0 ? 0 : (score / scoreMax).clamp(0.0, 1.0);
}

enum ZodiacPartnerRole { self, partner }

class ZodiacPartner {
  const ZodiacPartner({
    required this.role,
    required this.displayName,
    required this.sign,
  });

  final ZodiacPartnerRole role;

  /// May be absent on the wire (contract §3 row 6).
  final String? displayName;

  final CupidZodiacSign sign;

  /// Falls back to the sign's Vietnamese label, never a placeholder name
  /// (contract §3 row 6).
  String get label => displayName ?? sign.viLabel;
}

class ZodiacDailyTip {
  const ZodiacDailyTip({
    required this.id,
    required this.icon,
    required this.tint,
    required this.title,
    required this.body,
  });

  final String id;
  final ZodiacTipIcon icon;
  final ZodiacTipTint tint;
  final String title;
  final String body;
}

/// Tip tile tints (contract §2). Member names are the wire values.
enum ZodiacTipTint {
  mint,
  pink,
  amber,
  lilac,
  peach,

  /// Not a wire value: the fallback for any tint outside the vocabulary,
  /// rendered as a neutral `colorTextMuted` tile. The pool is append-only, so
  /// an unknown tint must resolve here rather than throw (contract §2).
  neutral;

  static ZodiacTipTint fromWire(Object? value) =>
      values.firstWhere((tint) => tint.name == value, orElse: () => neutral);
}

/// Tip glyphs (contract §2). Wire values are snake_case, so each member
/// carries its own [wireValue] instead of matching on `name`.
enum ZodiacTipIcon {
  videocam('videocam'),
  block('block'),
  localCafe('local_cafe'),
  nightlight('nightlight'),
  favorite('favorite'),
  chatBubble('chat_bubble'),
  savings('savings'),
  selfImprovement('self_improvement');

  const ZodiacTipIcon(this.wireValue);

  final String wireValue;

  /// [favorite] is the neutral fallback for an unknown glyph (contract §2).
  static ZodiacTipIcon fromWire(Object? value) => values.firstWhere(
    (icon) => icon.wireValue == value,
    orElse: () => favorite,
  );
}
