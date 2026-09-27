import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../../activity_cards/domain/activity_card_repository.dart';
import '../../data/checkin_capture_content_repository.dart';
import '../../data/context_notebook_repository.dart';
import '../../domain/checkin_capture_content.dart';
import '../../domain/checkin_origin_resolver.dart';
import '../../domain/context_notebook_models.dart';
import '../widgets/context_inline_add_row.dart';

/// The notebook's two fixed groups, in the order the screen renders them
/// (`ux/uiux-spec.md` Phần B). The list is closed on purpose: a third group is
/// how a free-text "ghi chú" section, and with it a second write path, gets
/// added by accident (AC-8).
const List<NotebookKind> notebookGroupOrder = <NotebookKind>[
  NotebookKind.interest,
  NotebookKind.event,
];

/// Every row action the "..." menu may ever carry. Two values, closed enum —
/// a share, export or copy-all row would have to appear here first, which is
/// what `notebook_screen_test.dart` walks the tree to rule out (AC-9).
enum _NotebookRowAction { edit, delete }

/// Splits [entries] into the two fixed groups, keeping the repository's
/// newest-first order inside each one.
///
/// Both keys are always present, including when a group is empty: an empty
/// group still renders its header and its "+ tự thêm", because the empty state
/// here is a normal state and not a prompt to fill something in (AC-8).
Map<NotebookKind, List<NotebookEntry>> groupNotebookEntries(
  List<NotebookEntry> entries,
) {
  final Map<NotebookKind, List<NotebookEntry>> grouped =
      <NotebookKind, List<NotebookEntry>>{
        for (final NotebookKind kind in notebookGroupOrder)
          kind: <NotebookEntry>[],
      };
  for (final NotebookEntry entry in entries) {
    grouped[entry.kind]?.add(entry);
  }
  return grouped;
}

/// "Sổ tay người yêu" (`coding-plan/phase-P4-notebook-and-skill-screens-and-menu-entry.md`).
///
/// What is absent is the contract: no count anywhere, no "hoàn thiện hồ sơ"
/// subtitle or progress, no share/export/copy-all in any menu, and no streak,
/// badge or paywall (AC-9, AC-12, AC-25, `contract-summary.md` §6).
class NotebookScreen extends StatefulWidget {
  const NotebookScreen({
    super.key,
    required this.repository,
    this.originCopy,
    this.cardProbe,
  });

  final ContextNotebookRepository repository;

  /// Resolved origin wording. `null` means "read the shipped package", which is
  /// what production does; a package that cannot be read leaves every row
  /// without a label rather than failing the screen (KD-2).
  final CheckinCaptureCopySet? originCopy;

  /// Test seam for the card existence probe. `null` means the real card
  /// repository.
  final ReadableCardProbe? cardProbe;

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

/// Rows plus the origin label for each check-in row, resolved together so the
/// list renders once with both.
class _NotebookView {
  const _NotebookView(this.entries, this.originLabels);

  final List<NotebookEntry> entries;
  final Map<String, String> originLabels;
}

class _NotebookScreenState extends State<NotebookScreen> {
  late Future<_NotebookView> _view = _load();

  /// The group whose add row is expanded, or `null`. One at a time, so the
  /// screen never shows two open composers.
  NotebookKind? _addingTo;

  /// The entry being edited in place, or `null`.
  String? _editingId;

  void _reload() {
    setState(() {
      _addingTo = null;
      _editingId = null;
      _view = _load();
    });
  }

  Future<_NotebookView> _load() async {
    final List<NotebookEntry> entries = await widget.repository.entries();
    return _NotebookView(entries, await _originLabels(entries));
  }

  /// One resolve per screen load, so a list of check-in rows costs one probe
  /// rather than one query per row.
  Future<Map<String, String>> _originLabels(List<NotebookEntry> entries) async {
    final bool anyFromCheckIn = entries.any(
      (NotebookEntry entry) => entry.originCheckInRef != null,
    );
    if (!anyFromCheckIn) {
      return const <String, String>{};
    }

    CheckinCaptureCopySet? copy = widget.originCopy;
    if (copy == null) {
      try {
        copy = await _originContent.load();
      } catch (_) {
        return const <String, String>{};
      }
    }

    return CheckinOriginResolver(
      copy: copy,
      probe: widget.cardProbe ?? _probeReadableCards,
    ).labelsFor(entries);
  }

  Future<void> _add(NotebookKind kind, ContextInlineAddResult result) async {
    await widget.repository.addEntry(
      kind: NotebookKind.fromWireValue(result.optionId ?? kind.wireValue),
      value: result.value,
      detail: result.detail,
      source: ContextEntrySource.manual,
    );
    if (mounted) {
      _reload();
    }
  }

  Future<void> _update(NotebookEntry entry, ContextInlineAddResult result) async {
    await widget.repository.updateEntry(
      id: entry.id,
      value: result.value,
      detail: result.detail,
      eventOn: entry.eventOn,
    );
    if (mounted) {
      _reload();
    }
  }

  /// Deleting takes effect on the tap. No confirmation dialog and no undo
  /// snackbar: the user is removing one line they wrote themselves (AC-9).
  Future<void> _delete(String id) async {
    await widget.repository.deleteEntry(id);
    if (mounted) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      appBar: CupidHeader(
        title: l10n.notebook_screen_title,
        onBack: Navigator.of(context).canPop()
            ? () => Navigator.of(context).maybePop()
            : null,
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<_NotebookView>(
          future: _view,
          builder: (BuildContext context, AsyncSnapshot<_NotebookView> snapshot) {
            // A pending read renders as the empty list rather than a spinner:
            // a progress indicator on this screen is exactly the "tiến trình"
            // AC-25 forbids, and the read is one local query away.
            final _NotebookView? view = snapshot.data;
            final Map<NotebookKind, List<NotebookEntry>> grouped =
                groupNotebookEntries(view?.entries ?? const <NotebookEntry>[]);
            final Map<String, String> originLabels =
                view?.originLabels ?? const <String, String>{};
            return ListView(
              key: const Key('notebook-list'),
              padding: const EdgeInsets.all(CupidSpacing.md),
              children: <Widget>[
                for (final NotebookKind kind in notebookGroupOrder)
                  _NotebookGroup(
                    kind: kind,
                    entries: grouped[kind] ?? const <NotebookEntry>[],
                    originLabels: originLabels,
                    isAdding: _addingTo == kind,
                    editingId: _editingId,
                    onStartAdd: () => setState(() {
                      _addingTo = kind;
                      _editingId = null;
                    }),
                    onStartEdit: (String id) => setState(() {
                      _editingId = id;
                      _addingTo = null;
                    }),
                    onCancel: () => setState(() {
                      _addingTo = null;
                      _editingId = null;
                    }),
                    onAdd: (ContextInlineAddResult r) => _add(kind, r),
                    onUpdate: _update,
                    onDelete: _delete,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotebookGroup extends StatelessWidget {
  const _NotebookGroup({
    required this.kind,
    required this.entries,
    required this.originLabels,
    required this.isAdding,
    required this.editingId,
    required this.onStartAdd,
    required this.onStartEdit,
    required this.onCancel,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  final NotebookKind kind;
  final List<NotebookEntry> entries;
  final Map<String, String> originLabels;
  final bool isAdding;
  final String? editingId;
  final VoidCallback onStartAdd;
  final void Function(String id) onStartEdit;
  final VoidCallback onCancel;
  final Future<void> Function(ContextInlineAddResult result) onAdd;
  final Future<void> Function(NotebookEntry entry, ContextInlineAddResult result)
  onUpdate;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Column(
      key: Key('notebook-group-${kind.wireValue}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: CupidSpacing.sm,
            bottom: CupidSpacing.sm,
          ),
          // The header is the group name and nothing else: the design
          // reference's "SỞ THÍCH · 21" carries a count AC-25 forbids.
          child: Text(
            notebookGroupLabel(l10n, kind),
            style: type.caption.copyWith(
              color: colors.colorTextMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final NotebookEntry entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: CupidSpacing.sm),
            child: editingId == entry.id
                ? ContextInlineAddRow(
                    hintText: l10n.context_add_hint,
                    detailHintText: l10n.context_add_note_hint,
                    initialValue: entry.value,
                    initialDetail: entry.detail,
                    saveLabel: l10n.context_save_action,
                    cancelLabel: l10n.context_cancel_action,
                    onCancel: onCancel,
                    onSubmit: (ContextInlineAddResult r) => onUpdate(entry, r),
                  )
                : _NotebookRow(
                    entry: entry,
                    originLabel: originLabels[entry.id],
                    onEdit: () => onStartEdit(entry.id),
                    onDelete: () => onDelete(entry.id),
                  ),
          ),
        if (isAdding)
          ContextInlineAddRow(
            hintText: l10n.context_add_hint,
            detailHintText: l10n.context_add_note_hint,
            saveLabel: l10n.context_save_action,
            cancelLabel: l10n.context_cancel_action,
            selectedOptionId: kind.wireValue,
            options: <ContextInlineAddOption>[
              for (final NotebookKind option in notebookGroupOrder)
                ContextInlineAddOption(
                  id: option.wireValue,
                  label: notebookGroupLabel(l10n, option),
                ),
            ],
            onCancel: onCancel,
            onSubmit: onAdd,
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: Key('notebook-add-${kind.wireValue}'),
              onPressed: onStartAdd,
              child: Text(
                l10n.context_add_own_action,
                style: type.body.copyWith(color: colors.colorAccentPurple),
              ),
            ),
          ),
        const SizedBox(height: CupidSpacing.md),
      ],
    );
  }
}

/// Caches the parsed package for the process, so reopening the screen does not
/// re-read the asset.
final CheckinCaptureContentRepository _originContent =
    CheckinCaptureContentRepository();

/// Production probe: one pass over the distinct card ids on screen. The card
/// repository has no batch read, so this is as few reads as the contract allows
/// — never one per row. A card that cannot be read is simply absent from the
/// result, which is what degrades its label (AC-9).
Future<Set<String>> _probeReadableCards(Set<String> cardIds) async {
  final ActivityCardRepository cards = getIt<ActivityCardRepository>();
  final Set<String> readable = <String>{};
  for (final String id in cardIds) {
    try {
      if (await cards.cardById(id) != null) {
        readable.add(id);
      }
    } catch (_) {
      // Unreadable is the degrade path, not an error the screen shows.
    }
  }
  return readable;
}

/// The group's own name, resolved from the closed [NotebookKind] set.
String notebookGroupLabel(AppL10n l10n, NotebookKind kind) {
  return switch (kind) {
    NotebookKind.interest => l10n.notebook_group_interests,
    NotebookKind.event => l10n.notebook_group_events,
  };
}

/// One written line: what the user wrote, their own note under it if they left
/// one, and the "..." menu. No leading avatar, no trailing chevron — the row
/// does not open a detail screen, because a detail screen is a second surface
/// that could grow a share affordance.
class _NotebookRow extends StatelessWidget {
  const _NotebookRow({
    required this.entry,
    required this.originLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final NotebookEntry entry;

  /// The resolved origin line, or `null` for a row the user added themselves.
  final String? originLabel;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final String? detail = entry.detail;
    final String? label = originLabel;

    return Container(
      key: Key('notebook-entry-${entry.id}'),
      padding: const EdgeInsets.symmetric(
        horizontal: CupidSpacing.md,
        vertical: CupidSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  entry.value,
                  style: type.body.copyWith(color: colors.colorText),
                ),
                if (detail != null && detail.isNotEmpty)
                  Text(
                    detail,
                    style: type.caption.copyWith(color: colors.colorTextMuted),
                  ),
                // A plain muted caption, not a chip, badge or icon: the origin
                // is context for the line above it, and anything tappable here
                // would be the "xem buổi hẹn gốc" surface AC-15 rules out.
                if (label != null)
                  Text(
                    label,
                    key: Key('notebook-entry-origin-${entry.id}'),
                    style: type.caption.copyWith(color: colors.colorGhost),
                  ),
              ],
            ),
          ),
          PopupMenuButton<_NotebookRowAction>(
            key: Key('notebook-entry-menu-${entry.id}'),
            icon: Icon(Icons.more_horiz, color: colors.colorTextMuted),
            tooltip: l10n.context_row_menu_label,
            onSelected: (_NotebookRowAction action) {
              switch (action) {
                case _NotebookRowAction.edit:
                  onEdit();
                case _NotebookRowAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_NotebookRowAction>>[
                  PopupMenuItem<_NotebookRowAction>(
                    key: Key('notebook-edit-action-${entry.id}'),
                    value: _NotebookRowAction.edit,
                    child: Text(l10n.context_edit_action),
                  ),
                  PopupMenuItem<_NotebookRowAction>(
                    key: Key('notebook-delete-action-${entry.id}'),
                    value: _NotebookRowAction.delete,
                    child: Text(
                      l10n.context_delete_action,
                      style: TextStyle(color: colors.colorRed),
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }
}
