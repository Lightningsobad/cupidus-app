import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/design_system.dart';
import '../../../activity_cards/domain/activity_card.dart';
import '../../../activity_cards/domain/activity_card_repository.dart';
import '../../../activity_cards/presentation/widgets/quick_capture_sheet.dart';
import '../../../invite_composer/domain/preset_catalogue.dart';
import '../../../invite_composer/presentation/widgets/invite_composer_sheet.dart';
import '../../../journal/journal_entry_point.dart';

/// `mobile/lib/l10n/` is outside this story's write scope, so this surface uses
/// the same file-local bilingual helper the rest of screen (9) uses.
String _exitText(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;

/// Below this width the three pills stack instead of sharing a row
/// (`ux/uiux-spec.md` §2.5). Set above the common 360dp phone: three Vietnamese
/// labels share that row only by wrapping each one onto two lines, which is
/// exactly the squeezed reading the spec asks to avoid.
const double _stackBelowWidth = 380;

/// Opens STORY-002's invite composer. Completes `true` once the user finished
/// exporting, which is what makes screen (9) close behind them.
typedef InviteExit = Future<bool> Function(BuildContext context, ActivityCard card);

/// Opens STORY-001's capture form. Completes with the created card, or `null`
/// when the user backed out.
typedef NewCardExit = Future<ActivityCard?> Function(BuildContext context);

/// Opens STORY-003's journal composer seeded with the source card. Completes
/// with the saved entry id, or `null` when the user left without saving.
typedef JournalExit = Future<String?> Function(BuildContext context, ActivityCard card);

Future<bool> _defaultInviteExit(BuildContext context, ActivityCard card) =>
    showInviteComposerSheet(context, card, inviteCategoryId);

Future<ActivityCard?> _defaultNewCardExit(BuildContext context) =>
    QuickCaptureSheet.show(
      context,
      mode: QuickCaptureMode.title,
      repository: getIt<ActivityCardRepository>(),
      origin: ActivityCardOrigin.dateScript,
    );

Future<String?> _defaultJournalExit(BuildContext context, ActivityCard card) =>
    openJournalComposer(
      context,
      seed: JournalComposerSeed(originRef: dateScriptOriginRef(card)),
    );

/// The provenance tag the journal stores verbatim beside an entry written from
/// screen (9). Opaque by contract: the journal never parses it.
String dateScriptOriginRef(ActivityCard card) => 'date_script:${card.id}';

/// The sticky footer of screen (9): the three ways out of the script
/// (`ux/uiux-spec.md` §2.5, §3).
///
/// Screen (9) is not a place to stay (BR-6), so every exit here hands off to
/// the flow that already owns it — STORY-002's composer, STORY-001's capture
/// form, STORY-003's journal composer — and then lets the screen close. None of
/// the three schedules anything: no reminder, no notification, no timer, which
/// is the J7 line the whole feature sits behind (AC-13…AC-16/BR-3).
///
/// Outline pills rather than the filled `CupidPrimaryButton`: a filled control
/// here would read as a second card-level primary action (AC-6/SC-4).
class DateScriptExitBar extends StatelessWidget {
  const DateScriptExitBar({
    super.key,
    required this.card,
    required this.onExitCompleted,
    this.inviteExit,
    this.newCardExit,
    this.journalExit,
  });

  final ActivityCard card;

  /// Called after an exit finished its own flow. Screen (9) closes itself here
  /// rather than the bar popping a route it does not own.
  final VoidCallback onExitCompleted;

  /// Test/preview seams. Left null in production so each button reaches the one
  /// shipped implementation of its flow and never a copy of it.
  @visibleForTesting
  final InviteExit? inviteExit;
  @visibleForTesting
  final NewCardExit? newCardExit;
  @visibleForTesting
  final JournalExit? journalExit;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    final List<Widget> buttons = <Widget>[
      _ExitButton(
        buttonKey: const Key('date-script-exit-invite'),
        label: _exitText(context, 'Xuất lời mời', 'Export the invite'),
        onTap: () => _runExit(
          context,
          () async => (await (inviteExit ?? _defaultInviteExit)(context, card)),
        ),
      ),
      _ExitButton(
        buttonKey: const Key('date-script-exit-new-card'),
        label: _exitText(context, 'Tạo thẻ mới', 'New card'),
        onTap: () => _runExit(context, () => _createCard(context)),
      ),
      _ExitButton(
        buttonKey: const Key('date-script-exit-journal'),
        label: _exitText(context, 'Ghi vào nhật ký', 'Write in the journal'),
        onTap: () => _runExit(
          context,
          () async =>
              (await (journalExit ?? _defaultJournalExit)(context, card)) != null,
        ),
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.colorSurface,
        border: Border(top: BorderSide(color: colors.colorLine)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(CupidSpacing.md),
          child: LayoutBuilder(
            key: const Key('date-script-exit-bar'),
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth < _stackBelowWidth) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (int i = 0; i < buttons.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == buttons.length - 1 ? 0 : CupidSpacing.sm,
                        ),
                        child: buttons[i],
                      ),
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  for (int i = 0; i < buttons.length; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: i == buttons.length - 1 ? 0 : CupidSpacing.sm,
                        ),
                        child: buttons[i],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Runs one exit and closes screen (9) only when that exit actually finished.
  /// A cancelled exit leaves the reader exactly where they were, on the part
  /// they were reading (`ux/uiux-spec.md` §3).
  Future<void> _runExit(
    BuildContext context,
    Future<bool> Function() exit,
  ) async {
    final bool completed = await exit();
    if (completed && context.mounted) {
      onExitCompleted();
    }
  }

  Future<bool> _createCard(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String confirmation = _exitText(
      context,
      'Đã tạo thẻ mới trong kho hoạt động',
      'New card added to the activity store',
    );
    final ActivityCard? created =
        await (newCardExit ?? _defaultNewCardExit)(context);
    if (created == null) {
      return false;
    }
    // Shown on the app-level messenger, so it survives screen (9) closing
    // behind it.
    messenger.showSnackBar(SnackBar(content: Text(confirmation)));
    return true;
  }
}

class _ExitButton extends StatelessWidget {
  const _ExitButton({
    required this.buttonKey,
    required this.label,
    required this.onTap,
  });

  final Key buttonKey;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      button: true,
      child: GestureDetector(
        key: buttonKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platform.tapTarget),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(platform.radiusButton),
              border: Border.all(color: colors.colorAccentPink),
            ),
            // `heightFactor: 1` rather than a plain `Center`: as a
            // `bottomNavigationBar` the bar is laid out against the full screen
            // height, and a centring box with no height factor would take all
            // of it and leave the script itself zero pixels to render in.
            child: Align(
              heightFactor: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CupidSpacing.xs,
                  vertical: CupidSpacing.sm,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: type.body.copyWith(color: colors.colorAccentPink),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
