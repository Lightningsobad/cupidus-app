import 'dart:async' show unawaited;

import 'package:flutter/services.dart' show MissingPluginException,
    PlatformException;
import 'package:home_widget/home_widget.dart';

import '../../../core/content/content_package.dart';
import '../../activity_cards/domain/activity_card.dart';
import '../../activity_cards/domain/activity_card_repository.dart';
import '../../before_you_go/domain/before_you_go_resolver.dart' show civilDateIso;
import '../domain/phase_content.dart';
import '../domain/solo_phase.dart';
import '../domain/wealth_counter.dart';
import '../presentation/phase_status_cubit.dart';
import '../presentation/phase_status_line.dart' show civilDaysUntil;
import 'phase_content_repository.dart';

/// Native key names, copied verbatim from `architecture/contract-summary.md`
/// §2. A mismatch here is a silent miss on the native side — no compile error
/// and no log — which is why the whole set lives in one place and is asserted
/// against the contract by test rather than reviewed by eye.
const String widgetKeyPhaseId = 'phase_id';
const String widgetKeyPrimaryLine = 'primary_line';
const String widgetKeySecondaryLine = 'secondary_line';
const String widgetKeyCardId = 'card_id';
const String widgetKeyComputedOn = 'computed_on';

/// The complete key set, in contract order. Every push writes all five, using
/// `null` for the absent ones, so a key left over from an earlier phase cannot
/// survive into the next payload (`WIDGET-STALE`).
const List<String> widgetPayloadKeys = <String>[
  widgetKeyPhaseId,
  widgetKeyPrimaryLine,
  widgetKeySecondaryLine,
  widgetKeyCardId,
  widgetKeyComputedOn,
];

/// The one `phase_id` value the native widget branches on, for the date-day
/// background the design gives that phase alone (D-12). An identifier the
/// payload already carries, not a sixth key and not display copy — the widget
/// still draws only `primary_line` and `secondary_line`.
const String widgetPhaseIdDateDay = 'date_day';

const String widgetAndroidProviderName = 'CupidPhaseWidgetProvider';
const String widgetIosName = 'CupidPhaseWidget';
const String widgetAppGroupId = 'group.com.snapsofts.cupid';

/// The one place a payload is built, and a pure function: no clock read, no
/// store access, no asset load, no plugin call.
///
/// Every readable character it can emit comes from [phaseContent]. The only
/// other values it can produce are the four ASCII phase identifiers, a card
/// UUID, and a civil date — so no title, note, keyword, journal line or gift
/// name the user typed has a path onto a lock screen (AC-11/AC-12/BR-11).
/// [PhaseResolution] carries no such field to begin with; this function keeps
/// that guarantee by never taking an [ActivityCard].
///
/// Returns an empty map when the package has nothing to say for the phase.
/// The caller pushes that as-is, clearing the widget to a textless frame
/// rather than inventing a reassuring default (AC-37/BR-15).
Map<String, String> buildWidgetPayload({
  required PhaseResolution resolution,
  required ContentPackage<PhaseContentItem> phaseContent,
  required DateTime today,
  int? memoryCount,
}) {
  final int? number = _numberFor(resolution, today, memoryCount);
  final PhaseContentItem? item = _widgetLineFor(
    phaseContent,
    resolution.phase,
    number,
  );
  if (item == null) {
    return const <String, String>{};
  }

  return <String, String>{
    widgetKeyPhaseId: resolution.phase.wireValue,
    widgetKeyPrimaryLine: _fill(item.primary, number),
    if (item.secondary != null)
      widgetKeySecondaryLine: _fill(item.secondary!, number),
    if (resolution.cardId != null) widgetKeyCardId: resolution.cardId!,
    widgetKeyComputedOn: civilDateIso(today),
  };
}

/// The single number a phase is allowed to put on a public surface.
///
/// `upcoming` counts down to a date the user chose. `quiet` states how many
/// memories are kept. `waiting` and `date_day` get `null` — and because a
/// package item carrying `{n}` is skipped when no number is available, that
/// makes "how many days have I been waiting" unrenderable rather than merely
/// unwritten (AC-7).
int? _numberFor(PhaseResolution resolution, DateTime today, int? memoryCount) {
  switch (resolution.phase) {
    case SoloPhase.upcoming:
      final String? on = resolution.scheduledOn;
      return on == null
          ? null
          : civilDaysUntil(scheduledOnIso: on, today: today);
    case SoloPhase.quiet:
      return memoryCount;
    case SoloPhase.waiting:
    case SoloPhase.dateDay:
      return null;
  }
}

/// Package order is the priority order (BR-15): the quiet pack lists the
/// memory-count line before the neutral one, so an empty store falls through
/// to the neutral line without any Dart deciding that it should.
///
/// Separate from `PhaseStatusCubit`'s screen-side selection because the two
/// surfaces read different items — `allowsWidget` against `allowsScreen` — and
/// draw their number from different sources.
PhaseContentItem? _widgetLineFor(
  ContentPackage<PhaseContentItem> package,
  SoloPhase phase,
  int? number,
) {
  for (final PhaseContentItem item in package.items) {
    if (item.phaseId.wireValue != phase.wireValue || !item.surface.allowsWidget) {
      continue;
    }
    final bool needsNumber = item.displayStrings.any(
      (String text) => text.contains(phaseContentNumberPlaceholder),
    );
    if (needsNumber && number == null) {
      continue;
    }
    return item;
  }
  return null;
}

String _fill(String text, int? number) => number == null
    ? text
    : text.replaceAll(phaseContentNumberPlaceholder, '$number');

/// Where a built payload is written. Split from [buildWidgetPayload] so the
/// build stays pure and so a test can observe a push without a platform.
typedef WidgetPayloadWriter = Future<void> Function(Map<String, String> payload);

/// Publishes the resolution the hub just drew (AC-9/AC-10).
///
/// There is no timer, alarm, work manager or isolate on this path. The payload
/// moves only when [pushWidgetPayload] is called, which `PhaseStatusCubit` does
/// on hub mount, on app resume, and after a card status change — a payload may
/// therefore be as old as the last app open, which the architecture accepts
/// rather than compensates for (`WIDGET-STALE`).
class HomeWidgetPhasePublisher implements PhaseWidgetPublisher {
  HomeWidgetPhasePublisher(
    this._repository, {
    PhaseContentRepository? content,
    DateTime Function()? clock,
    WidgetPayloadWriter? writer,
  })  : _content = content ?? PhaseContentRepository(),
        _clock = clock ?? DateTime.now,
        _writer = writer ?? writeHomeWidgetPayload;

  final ActivityCardRepository _repository;
  final PhaseContentRepository _content;
  final DateTime Function() _clock;
  final WidgetPayloadWriter _writer;

  @override
  Future<void> pushWidgetPayload(PhaseResolution resolution) async {
    final DateTime today = _clock();

    final Map<String, String> payload;
    try {
      payload = buildWidgetPayload(
        resolution: resolution,
        phaseContent: (await _content.catalogue()).phaseContent,
        today: today,
        memoryCount: resolution.phase == SoloPhase.quiet
            ? const WealthCounter().count(await _repository.countsByStatus())
            : null,
      );
    } catch (_) {
      // The widget is a supplementary surface: a store or pack failure leaves
      // whatever is already on the home screen and costs the app nothing
      // (AC-13). Clearing here would turn a transient read error into a
      // visible blank tile.
      return;
    }

    // Not awaited: the sentence the hub is about to draw must never wait on a
    // home-screen round-trip it does not need (AC-13). The platform call is
    // also unbounded — under a test binding it never completes at all — so
    // awaiting it would hold `PhaseStatusCubit.refresh` open indefinitely.
    unawaited(_writer(payload));
  }
}

/// Writes the payload into the store `home_widget` shares with the native
/// side, then asks both platforms to redraw.
///
/// Keys missing from [payload] are written as `null`, which clears them.
/// Platform failures are swallowed on purpose — no widget is installed, the
/// iOS extension has not shipped yet, or the host refused the redraw — and
/// none of those may surface as an app-level error (AC-13).
Future<void> writeHomeWidgetPayload(Map<String, String> payload) async {
  try {
    await HomeWidget.setAppGroupId(widgetAppGroupId);
    for (final String key in widgetPayloadKeys) {
      await HomeWidget.saveWidgetData<String>(
        key,
        payload[key],
        deleteFile: false,
      );
    }
    await HomeWidget.updateWidget(
      androidName: widgetAndroidProviderName,
      iOSName: widgetIosName,
    );
  } on PlatformException {
    return;
  } on MissingPluginException {
    return;
  }
}
