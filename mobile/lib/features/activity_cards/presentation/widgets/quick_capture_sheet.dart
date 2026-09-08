import 'package:flutter/material.dart';

import '../../../../design_system/adaptive/cupid_add_action.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../domain/activity_card.dart';
import '../../domain/activity_card_repository.dart';
import 'activity_status_filter.dart';

/// Which single field the capture sheet asks for. There is no third mode: a
/// capture that needs two fields is a form, and `ux/uiux-spec.md` §4a forbids
/// one on this path.
enum QuickCaptureMode {
  /// AC-7 — the pasted link. [NewActivityCard.title] goes out blank and the
  /// repository derives it from the link's host, so a link with no title and
  /// no image still becomes a card.
  link,

  /// AC-6 — the manual "+" entry, title only.
  title,
}

/// One-field capture (`ux/uiux-spec.md` §4a). Submitting the field writes the
/// card immediately: there is deliberately no confirm button, no second step,
/// and no other field to fill.
class QuickCaptureSheet extends StatefulWidget {
  const QuickCaptureSheet({
    super.key,
    required this.mode,
    required this.repository,
  });

  final QuickCaptureMode mode;
  final ActivityCardRepository repository;

  /// Opens the sheet and completes with the created card, or `null` when the
  /// user dismissed it without entering anything.
  static Future<ActivityCard?> show(
    BuildContext context, {
    required QuickCaptureMode mode,
    required ActivityCardRepository repository,
  }) {
    final CupidPlatformTokens platform = context.cupidPlatform;
    return showModalBottomSheet<ActivityCard>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cupidColors.colorSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(platform.radiusSheet),
        ),
      ),
      builder: (BuildContext _) =>
          QuickCaptureSheet(mode: mode, repository: repository),
    );
  }

  @override
  State<QuickCaptureSheet> createState() => _QuickCaptureSheetState();
}

class _QuickCaptureSheetState extends State<QuickCaptureSheet> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Padding(
      key: const Key('activity_quick_capture_sheet'),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(CupidSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _prompt(context, widget.mode),
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
            const SizedBox(height: CupidSpacing.sm),
            TextField(
              key: const Key('activity_quick_capture_field'),
              autofocus: true,
              enabled: !_saving,
              keyboardType: widget.mode == QuickCaptureMode.link
                  ? TextInputType.url
                  : TextInputType.text,
              textInputAction: TextInputAction.done,
              onSubmitted: _submit,
              style: type.body.copyWith(color: colors.colorText),
              decoration: InputDecoration(
                hintText: _hint(context, widget.mode),
                hintStyle: type.body.copyWith(color: colors.colorTextMuted),
                filled: true,
                fillColor: colors.colorSurfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(platform.radiusSmall),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: CupidSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(String value) async {
    if (_saving) {
      return;
    }
    final String trimmed = value.trim();
    final NavigatorState navigator = Navigator.of(context);
    if (trimmed.isEmpty) {
      navigator.pop();
      return;
    }
    setState(() => _saving = true);
    final ActivityCard card = await widget.repository.createCard(
      widget.mode == QuickCaptureMode.link
          ? NewActivityCard(
              title: '',
              origin: ActivityCardOrigin.pastedLink,
              sourceLink: trimmed,
            )
          : NewActivityCard(
              title: trimmed,
              origin: ActivityCardOrigin.manual,
            ),
    );
    if (!mounted) {
      return;
    }
    navigator.pop(card);
  }
}

/// The manual "+" entry (AC-6). It is deliberately absent while the store is
/// empty: `ux/uiux-spec.md` §4a gives Minute-1 exactly two invitations, and a
/// third affordance next to them is a choice the user has no basis to make
/// yet.
class QuickCaptureAddAction extends StatelessWidget {
  const QuickCaptureAddAction({
    super.key,
    required this.repository,
    required this.storeCount,
    this.onCardCreated,
  });

  final ActivityCardRepository repository;

  /// Cards held by the whole store, not by the selected pane: an empty pane
  /// beside a filled store is not Minute-1.
  final int storeCount;
  final ValueChanged<ActivityCard>? onCardCreated;

  @override
  Widget build(BuildContext context) {
    if (storeCount == 0) {
      return const SizedBox.shrink(
        key: Key('activity_quick_capture_add_hidden'),
      );
    }
    return KeyedSubtree(
      key: const Key('activity_quick_capture_add'),
      child: CupidAddAction(onPressed: () => _capture(context)),
    );
  }

  Future<void> _capture(BuildContext context) async {
    final ActivityCard? card = await QuickCaptureSheet.show(
      context,
      mode: QuickCaptureMode.title,
      repository: repository,
    );
    if (card != null) {
      onCardCreated?.call(card);
    }
  }
}

String _prompt(BuildContext context, QuickCaptureMode mode) {
  switch (mode) {
    case QuickCaptureMode.link:
      return activityHubText(context, 'Dán link vào đây', 'Paste the link here');
    case QuickCaptureMode.title:
      return activityHubText(context, 'Muốn làm gì?', 'What do you want to do?');
  }
}

String _hint(BuildContext context, QuickCaptureMode mode) {
  switch (mode) {
    case QuickCaptureMode.link:
      return 'https://';
    case QuickCaptureMode.title:
      return activityHubText(context, 'Một điều nhỏ thôi', 'One small thing');
  }
}
