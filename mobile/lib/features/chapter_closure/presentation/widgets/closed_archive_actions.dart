import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../activity_cards/presentation/widgets/status_change_picker.dart';
import '../../data/chapter_closure_service.dart';
import '../../data/stage1_wipe_service.dart';
import 'close_chapter_dialog.dart';

/// The two things a user may do with a closed chapter, shown at the top of the
/// "Đã đóng" pane and nowhere else (AC-16): put it back (AC-17), or delete it
/// for good (AC-15).
///
/// Neither action reports success in words. The archive visibly changing — the
/// cards back in their old panes, or the pane itself gone — is the whole
/// answer, and it leaves no room for a congratulation or a comment on the
/// decision (AC-17).
class ClosedArchiveActions extends StatefulWidget {
  const ClosedArchiveActions({
    super.key,
    required this.onChanged,
    this.closureService,
    this.wipeService,
  });

  /// Reloads the hub after the ledger changed.
  final Future<void> Function() onChanged;

  /// Test seams, left null in production so both resolve the same composition
  /// root every other consumer uses.
  final ChapterClosureService? closureService;
  final Stage1WipeService? wipeService;

  @override
  State<ClosedArchiveActions> createState() => _ClosedArchiveActionsState();
}

class _ClosedArchiveActionsState extends State<ClosedArchiveActions> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CupidSpacing.md,
        0,
        CupidSpacing.md,
        CupidSpacing.md,
      ),
      child: Row(
        key: const Key('closed_archive_actions'),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ActivityDialogChoiceButton(
            optionKey: const Key('closed_archive_reopen'),
            label: closeChapterText(context, _reopenLabel),
            color: colors.colorText,
            onTap: _reopen,
          ),
          ActivityDialogChoiceButton(
            optionKey: const Key('closed_archive_purge'),
            label: closeChapterText(context, _purgeLabel),
            color: colors.colorRed,
            onTap: _purge,
          ),
        ],
      ),
    );
  }

  Future<void> _reopen() async {
    await _run(() async {
      final ChapterClosureService service =
          widget.closureService ?? getIt<ChapterClosureService>();
      await service.reopen();
    }, key: const Key('reopen_chapter_dialog'), title: _reopenTitle,
        facts: reopenChapterFacts, confirmLabel: _reopenLabel,
        destructive: false);
  }

  Future<void> _purge() async {
    await _run(() async {
      final Stage1WipeService service =
          widget.wipeService ?? getIt<Stage1WipeService>();
      await service.purgeClosed();
    }, key: const Key('purge_closed_dialog'), title: _purgeTitle,
        facts: purgeClosedFacts, confirmLabel: _purgeLabel, destructive: true);
  }

  /// One confirmation, then the write, then a reload. `_busy` only stops a
  /// double tap from running the write twice; it is not a second step the user
  /// has to pass (AC-2).
  Future<void> _run(
    Future<void> Function() write, {
    required Key key,
    required List<String> title,
    required List<List<String>> facts,
    required List<String> confirmLabel,
    required bool destructive,
  }) async {
    if (_busy) {
      return;
    }
    final bool confirmed = await _confirm(
      context,
      key: key,
      title: title,
      facts: facts,
      confirmLabel: confirmLabel,
      destructive: destructive,
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _busy = true);
    await write();
    await widget.onChanged();
    if (mounted) {
      setState(() => _busy = false);
    }
  }
}

/// The same confirmation surface as `showCloseChapterDialog`: a title, the
/// facts, and two equal choices with only the colour of the primary one
/// differing (`ux/uiux-spec.md` §2).
Future<bool> _confirm(
  BuildContext context, {
  required Key key,
  required List<String> title,
  required List<List<String>> facts,
  required List<String> confirmLabel,
  required bool destructive,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      final CupidColorTokens colors = dialogContext.cupidColors;
      final CupidPlatformTokens platform = dialogContext.cupidPlatform;
      final CupidTypographyTokens type = dialogContext.cupidType;

      return AlertDialog(
        key: key,
        backgroundColor: colors.colorSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(platform.radiusCard),
        ),
        title: Text(
          closeChapterText(dialogContext, title),
          style: type.body.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.colorText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final List<String> line in facts) ...<Widget>[
              Text(
                closeChapterText(dialogContext, line),
                key: Key('closed_archive_fact_${facts.indexOf(line)}'),
                style: type.caption.copyWith(color: colors.colorTextMuted),
              ),
              if (line != facts.last) const SizedBox(height: CupidSpacing.sm),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          ActivityDialogChoiceButton(
            optionKey: const Key('closed_archive_cancel'),
            label: closeChapterText(dialogContext, _cancelLabel),
            color: colors.colorText,
            onTap: () => Navigator.of(dialogContext).pop(false),
          ),
          ActivityDialogChoiceButton(
            optionKey: const Key('closed_archive_confirm'),
            label: closeChapterText(dialogContext, confirmLabel),
            color: destructive ? colors.colorRed : colors.colorText,
            onTap: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

const List<String> _cancelLabel = <String>['Huỷ', 'Cancel'];

const List<String> _reopenLabel = <String>['Mở lại ngăn', 'Reopen'];

const List<String> _purgeLabel = <String>['Xoá hẳn', 'Delete for good'];

const List<String> _reopenTitle = <String>[
  'Mở lại ngăn?',
  'Reopen this chapter?',
];

const List<String> _purgeTitle = <String>[
  'Xoá hẳn phần đã đóng?',
  'Delete the closed part for good?',
];

/// Public so the phase test asserts the rendered strings against the same
/// source the dialogs draw from.
const List<List<String>> reopenChapterFacts = <List<String>>[
  <String>[
    'Mục đã đóng quay lại đúng ô cũ của chúng.',
    'Closed items go back to the panes they came from.',
  ],
  <String>[
    'Kho đã đóng trống sẽ không còn hiện trên dải lọc.',
    'An empty closed drawer stops showing on the filter strip.',
  ],
];

const List<List<String>> purgeClosedFacts = <List<String>>[
  <String>[
    'Xoá vĩnh viễn thẻ, lời mời, sổ tay và câu hỏi nằm trong kho đã đóng.',
    'Permanently deletes the cards, invites, notebook and prompts in the '
        'closed drawer.',
  ],
  <String>[
    'Không hoàn tác được.',
    'This cannot be undone.',
  ],
  <String>[
    'Những gì bạn giữ lại không bị đụng tới.',
    'What you kept is left untouched.',
  ],
];
