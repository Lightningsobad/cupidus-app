import 'dart:io';

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/journal/journal_media_store.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../data/journal_repository.dart';
import '../../domain/journal_entry.dart';
import '../journal_list_cubit.dart';

/// Square photo thumbnail edge (`ux/uiux-spec.md` §2: "ảnh thu nhỏ nếu có (hình
/// vuông nhỏ, `--r-sm`)"). The spec fixes the shape and the radius token but no
/// size, so this is the row rhythm's own value rather than a token lookup.
const double _thumbnailSize = 56;

/// Collapsed excerpt length (`ux/uiux-spec.md` §2: "1-2 dòng trích").
const int _excerptMaxLines = 2;

/// How many thumbnails a row shows, matching the design reference's two-square
/// cluster. The cap is the row's width budget, not a data limit, and it is
/// deliberately not paired with a `+N` badge: a count on this screen is what
/// AC-1 and BR-4 rule out.
const int _maxThumbnails = 2;

/// Yesterday and the six days before it read as a weekday; older entries fall
/// back to the absolute date (`visual-fidelity-report.md` P3 delta 2).
const int _relativeDateWindowDays = 7;

/// The write date in the design reference's warm relative form. It is still a
/// date and nothing else — no "ngày thứ N", no streak (AC-1, BR-4).
String journalEntryDateLabel(AppL10n l10n, DateTime createdAt, DateTime now) {
  final DateTime day = DateTime(createdAt.year, createdAt.month, createdAt.day);
  final int daysAgo = DateTime(now.year, now.month, now.day).difference(day).inDays;
  if (daysAgo == 0) {
    return l10n.journal_entry_date_today(createdAt);
  }
  if (daysAgo == 1) {
    return l10n.journal_entry_date_yesterday(createdAt);
  }
  if (daysAgo > 1 && daysAgo < _relativeDateWindowDays) {
    return l10n.journal_entry_date_weekday(createdAt);
  }
  return l10n.journal_entry_date(createdAt);
}

/// Every journal menu row this screen may ever have. `PopupMenuButton` reports
/// a null selection as a dismissal, so each row needs a real value; keeping the
/// values in one closed enum also makes an added share/export row visible as a
/// source change rather than an inline literal.
enum _JournalMenuAction { deleteEntry, deleteAll }

/// The private journal list (`coding-plan/phase-P3-journal-list-screen-and-delete.md`).
///
/// The absences here are load-bearing, not omissions to fill in later: no entry
/// count, no day streak, no progress bar anywhere on the screen (AC-1, BR-4),
/// and no share, export or copy affordance in any menu, disabled or hidden
/// (AC-6). `journal_screen_test.dart` asserts both by walking the built tree.
class JournalScreen extends StatelessWidget {
  const JournalScreen({
    super.key,
    required this.repository,
    required this.mediaStore,
    this.onCompose,
  });

  final JournalRepository repository;

  /// Sole owner of journal photo paths — the screen resolves a thumbnail
  /// through it rather than building a path of its own
  /// (`architecture/solution.md` §4 Boundaries And Ownership).
  final JournalMediaStore mediaStore;

  /// Opens the composer. P3 delivers the list only, so the default is a no-op
  /// and P5 supplies the real callback; the CTA is present and testable either
  /// way.
  final Future<void> Function()? onCompose;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JournalListCubit>(
      create: (_) => JournalListCubit(repository: repository),
      child: _JournalView(mediaStore: mediaStore, onCompose: onCompose),
    );
  }
}

class _JournalView extends StatelessWidget {
  const _JournalView({required this.mediaStore, this.onCompose});

  final JournalMediaStore mediaStore;
  final Future<void> Function()? onCompose;

  Future<void> _confirmDeleteEntry(BuildContext context, String id) async {
    final AppL10n l10n = AppL10n.of(context);
    final JournalListCubit cubit = context.read<JournalListCubit>();
    final bool confirmed = await _showConfirmDialog(
      context,
      title: l10n.journal_delete_entry_title,
      confirmLabel: l10n.journal_delete_action,
    );
    if (confirmed) {
      await cubit.deleteEntry(id);
    }
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final AppL10n l10n = AppL10n.of(context);
    final JournalListCubit cubit = context.read<JournalListCubit>();
    final bool confirmed = await _showConfirmDialog(
      context,
      title: l10n.journal_delete_all_title,
      body: l10n.journal_delete_all_body,
      confirmLabel: l10n.journal_delete_all_confirm,
    );
    if (confirmed) {
      await cubit.deleteAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      appBar: CupidHeader(
        title: l10n.journal_screen_title,
        onBack: Navigator.of(context).canPop()
            ? () => Navigator.of(context).maybePop()
            : null,
        actions: <Widget>[
          _JournalHeaderMenu(onDeleteAll: () => _confirmDeleteAll(context)),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: BlocBuilder<JournalListCubit, JournalListState>(
                builder: (BuildContext context, JournalListState state) {
                  // Loading renders as the empty state rather than a spinner:
                  // a progress indicator here would be the "tiến trình" AC-1
                  // forbids on this screen, and the first repository emission
                  // is a local query away.
                  final JournalListReady? ready = state is JournalListReady
                      ? state
                      : null;
                  if (ready == null || ready.entries.isEmpty) {
                    return const _JournalEmptyState();
                  }
                  return _JournalEntryList(
                    ready: ready,
                    mediaStore: mediaStore,
                    onDelete: (String id) => _confirmDeleteEntry(context, id),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(CupidSpacing.md),
              child: CupidPrimaryButton(
                key: const Key('journal-compose-cta'),
                label: l10n.journal_compose_cta,
                onPressed: () => onCompose?.call(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One neutral line, no illustration, no urging (`ux/uiux-spec.md` §7). The
/// single CTA lives in [_JournalView]'s bottom bar and is shared with the
/// populated state, so this state cannot drift into having a second one.
class _JournalEmptyState extends StatelessWidget {
  const _JournalEmptyState();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: CupidSpacing.xl),
        child: Text(
          l10n.journal_empty_body,
          key: const Key('journal-empty-body'),
          textAlign: TextAlign.center,
          style: type.body.copyWith(color: colors.colorTextMuted),
        ),
      ),
    );
  }
}

class _JournalEntryList extends StatelessWidget {
  const _JournalEntryList({
    required this.ready,
    required this.mediaStore,
    required this.onDelete,
  });

  final JournalListReady ready;
  final JournalMediaStore mediaStore;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    // Entries, then the optional "show more" row, then the privacy footnote
    // that always closes the list.
    final int loadMoreIndex = ready.hasMore ? ready.entries.length : -1;
    final int footnoteIndex = ready.entries.length + (ready.hasMore ? 1 : 0);

    return ListView.builder(
      key: const Key('journal-entry-list'),
      padding: EdgeInsets.symmetric(horizontal: CupidSpacing.md),
      itemCount: footnoteIndex + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == footnoteIndex) {
          return const _JournalPrivacyFootnote();
        }
        if (index == loadMoreIndex) {
          return Padding(
            padding: EdgeInsets.only(bottom: CupidSpacing.sm),
            child: TextButton(
              key: const Key('journal-load-more'),
              onPressed: () => context.read<JournalListCubit>().loadMore(),
              child: Text(l10n.journal_load_more),
            ),
          );
        }
        final JournalEntry entry = ready.entries[index];
        return Padding(
          padding: EdgeInsets.only(bottom: CupidSpacing.sm),
          child: _JournalEntryTile(
            entry: entry,
            mediaStore: mediaStore,
            onDelete: () => onDelete(entry.id),
          ),
        );
      },
    );
  }
}

/// Closes the list with the privacy facts the screen already enforces, so the
/// promise is readable and not merely structural. It is text only: giving it a
/// tap target would be the export/share surface AC-6 forbids.
class _JournalPrivacyFootnote extends StatelessWidget {
  const _JournalPrivacyFootnote();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Padding(
      padding: EdgeInsets.only(bottom: CupidSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        ),
        child: Padding(
          padding: EdgeInsets.all(CupidSpacing.md),
          child: Text(
            l10n.journal_privacy_footnote,
            key: const Key('journal-privacy-footnote'),
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
        ),
      ),
    );
  }
}

class _JournalEntryTile extends StatefulWidget {
  const _JournalEntryTile({
    required this.entry,
    required this.mediaStore,
    required this.onDelete,
  });

  final JournalEntry entry;
  final JournalMediaStore mediaStore;
  final VoidCallback onDelete;

  @override
  State<_JournalEntryTile> createState() => _JournalEntryTileState();
}

class _JournalEntryTileState extends State<_JournalEntryTile> {
  /// Tapping a row reveals the entry's full text in place (`ux/uiux-spec.md`
  /// §2, "Chạm mở toàn văn"). Expanding beats pushing a reader route because
  /// the text never leaves the list that owns it — there is no second surface
  /// that could grow its own share affordance.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final JournalEntry entry = widget.entry;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: InkWell(
        key: Key('journal-entry-${entry.id}'),
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: EdgeInsets.all(CupidSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      journalEntryDateLabel(
                        l10n,
                        DateTime.fromMillisecondsSinceEpoch(
                          entry.createdAt,
                          isUtc: true,
                        ).toLocal(),
                        DateTime.now(),
                      ),
                      style: type.caption.copyWith(color: colors.colorTextMuted),
                    ),
                    SizedBox(height: CupidSpacing.xs),
                    Text(
                      entry.bodyText,
                      style: type.body.copyWith(color: colors.colorText),
                      maxLines: _expanded ? null : _excerptMaxLines,
                      overflow: _expanded
                          ? TextOverflow.clip
                          : TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              for (final JournalEntryPhoto photo
                  in entry.photos.take(_maxThumbnails)) ...<Widget>[
                SizedBox(width: CupidSpacing.sm),
                _JournalThumbnail(
                  mediaStore: widget.mediaStore,
                  photo: photo,
                ),
              ],
              _JournalEntryMenu(onDelete: widget.onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalThumbnail extends StatelessWidget {
  const _JournalThumbnail({required this.mediaStore, required this.photo});

  final JournalMediaStore mediaStore;
  final JournalEntryPhoto photo;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return ClipRRect(
      borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
      child: SizedBox.square(
        dimension: _thumbnailSize,
        child: FutureBuilder<File>(
          future: mediaStore.resolvePhoto(photo.relativePath),
          builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
            final File? file = snapshot.data;
            if (file == null) {
              return ColoredBox(color: colors.colorSurfaceAlt);
            }
            return Image.file(
              file,
              fit: BoxFit.cover,
              semanticLabel: l10n.journal_entry_photo_label,
              // A photo whose file went missing degrades to a neutral square:
              // the entry still reads, and nothing about the failure suggests
              // a recovery path that AC-13 says does not exist.
              errorBuilder: (BuildContext context, Object error, StackTrace? _) =>
                  ColoredBox(color: colors.colorSurfaceAlt),
            );
          },
        ),
      ),
    );
  }
}

/// The one and only per-entry context menu. It holds exactly one action.
/// Adding a share, export or "copy all" row here — even hidden or disabled —
/// is what AC-6 forbids, and `journal_screen_test.dart` fails if one appears.
class _JournalEntryMenu extends StatelessWidget {
  const _JournalEntryMenu({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;

    return PopupMenuButton<_JournalMenuAction>(
      key: const Key('journal-entry-menu'),
      icon: Icon(Icons.more_horiz, color: colors.colorTextMuted),
      tooltip: l10n.journal_entry_menu_label,
      onSelected: (_) => onDelete(),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_JournalMenuAction>>[
        PopupMenuItem<_JournalMenuAction>(
          key: const Key('journal-delete-entry-action'),
          value: _JournalMenuAction.deleteEntry,
          child: Text(
            l10n.journal_delete_action,
            style: TextStyle(color: colors.colorRed),
          ),
        ),
      ],
    );
  }
}

/// Header menu carrying the single delete-everything row (`ux/uiux-spec.md`
/// §5). Same rule as [_JournalEntryMenu]: one row, and no export beside it.
class _JournalHeaderMenu extends StatelessWidget {
  const _JournalHeaderMenu({required this.onDeleteAll});

  final VoidCallback onDeleteAll;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;

    return PopupMenuButton<_JournalMenuAction>(
      key: const Key('journal-header-menu'),
      icon: Icon(Icons.more_horiz, color: colors.colorText),
      tooltip: l10n.journal_header_menu_label,
      onSelected: (_) => onDeleteAll(),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_JournalMenuAction>>[
        PopupMenuItem<_JournalMenuAction>(
          key: const Key('journal-delete-all-action'),
          value: _JournalMenuAction.deleteAll,
          child: Text(
            l10n.journal_delete_all_action,
            style: TextStyle(color: colors.colorRed),
          ),
        ),
      ],
    );
  }
}

/// Neutral confirmation used by both delete flows: no reason prompt, no second
/// step, no retype-to-confirm, and no undo snackbar afterwards (AC-12, AC-13).
Future<bool> _showConfirmDialog(
  BuildContext context, {
  required String title,
  String? body,
  required String confirmLabel,
}) async {
  final AppL10n l10n = AppL10n.of(context);
  final CupidColorTokens colors = context.cupidColors;

  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: <Widget>[
        TextButton(
          key: const Key('journal-delete-cancel'),
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.journal_delete_cancel),
        ),
        TextButton(
          key: const Key('journal-delete-confirm'),
          style: TextButton.styleFrom(foregroundColor: colors.colorRed),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
