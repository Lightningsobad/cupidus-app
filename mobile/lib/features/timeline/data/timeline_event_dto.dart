import 'package:cupid_mobile/features/timeline/domain/timeline_entry.dart';

/// Thrown when a `GET /timeline` response body does not match the frozen
/// wire contract (`architecture/solution.md` §4 Risk Surfaces: untyped
/// REST body), so callers see a typed failure instead of a raw cast or
/// format error.
class TimelineDecodeException implements Exception {
  const TimelineDecodeException(this.message);

  final String message;

  @override
  String toString() => 'TimelineDecodeException: $message';
}

/// Wire contract for `GET /timeline` (frozen `timeline.controller.ts` +
/// `timeline-event.entity.ts`). Decodes the untyped response body; see
/// `TimelineRemoteDataSource` for why the generated client cannot type it.
class TimelineEventDto {
  const TimelineEventDto({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    this.description,
    this.photoUrl,
    this.icon,
  });

  factory TimelineEventDto.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const TimelineDecodeException(
        'Timeline event is missing a valid "id"',
      );
    }
    final title = json['title'];
    if (title is! String) {
      throw const TimelineDecodeException(
        'Timeline event is missing a valid "title"',
      );
    }

    final DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['createdAt'] as String);
    } catch (_) {
      throw const TimelineDecodeException(
        'Timeline event is missing a valid "createdAt"',
      );
    }

    return TimelineEventDto(
      id: id,
      title: title,
      type: _typeFromWire(json['type']),
      createdAt: createdAt,
      description: json['description'] as String?,
      photoUrl: json['photoUrl'] as String?,
      icon: json['icon'] as String?,
    );
  }

  final String id;
  final String title;
  final TimelineEventType type;
  final DateTime createdAt;
  final String? description;
  final String? photoUrl;
  final String? icon;

  /// An unknown or absent wire value falls back to `memory` rather than
  /// throwing (frozen contract, `phase-P2` §3).
  static TimelineEventType _typeFromWire(Object? raw) {
    return switch (raw) {
      'milestone' => TimelineEventType.milestone,
      'system' => TimelineEventType.system,
      _ => TimelineEventType.memory,
    };
  }
}

/// User input for `POST /timeline`. Never carries a `photoUrl` -- photo
/// attachment on create is deferred (D-012-7); photo display of an
/// existing `photoUrl` stays in P5.
class TimelineDraft {
  const TimelineDraft({
    required this.title,
    required this.date,
    this.description,
    this.icon = 'favorite',
  });

  final String title;
  final DateTime date;
  final String? description;
  final String icon;

  /// Emits exactly `title`, optional `description`, `date`, `type`, and
  /// `icon` -- no other field (AC: "sends exactly the fields listed above
  /// and no others").
  Map<String, Object?> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    'date': date.toUtc().toIso8601String(),
    'type': 'memory',
    'icon': icon,
  };
}
