import 'package:flutter/material.dart';

import '../../../../core/content/content_package.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../data/context_notebook_repository.dart';
import '../../domain/ask_cadence_policy.dart';
import '../../domain/context_content.dart';
import '../../domain/context_notebook_models.dart';
import '../widgets/ask_on_the_spot_slot.dart';
import '../widgets/context_inline_add_row.dart';

/// This screen's entry point id (`architecture/contract-summary.md` §2).
const String skillProfileEntryPointId = 'skill_profile';

/// Every row action the "..." menu may ever carry — same closed set as the
/// notebook's, for the same reason (AC-9).
enum _SkillRowAction { edit, delete }

/// "Những gì bạn giỏi" (`coding-plan/phase-P4-notebook-and-skill-screens-and-menu-entry.md`).
///
/// A row is a name and nothing else. No score, no star, no level bar, no tier
/// badge and no "kỹ năng phụ" sub-group — AC-12 and `ux/uiux-spec.md` Phần C
/// ban them here specifically, including the gamified skill pattern the design
/// system draws elsewhere.
///
/// While the list is empty the screen leads with the shared ask card, so the
/// user meets the shipped seed chips before any box asking them to type
/// (AC-10/AC-11).
class SkillProfileScreen extends StatefulWidget {
  const SkillProfileScreen({
    super.key,
    required this.repository,
    this.contentLoader,
    this.sessionSkips,
  });

  final ContextNotebookRepository repository;

  @visibleForTesting
  final ContentPackageLoader? contentLoader;

  @visibleForTesting
  final AskSessionSkips? sessionSkips;

  @override
  State<SkillProfileScreen> createState() => _SkillProfileScreenState();
}

class _SkillProfileScreenState extends State<SkillProfileScreen> {
  late Future<List<SkillEntry>> _skills = widget.repository.skills();

  bool _adding = false;
  String? _editingId;

  void _reload() {
    setState(() {
      _adding = false;
      _editingId = null;
      _skills = widget.repository.skills();
    });
  }

  Future<void> _add(ContextInlineAddResult result) async {
    await widget.repository.addSkill(
      label: result.value,
      source: ContextEntrySource.manual,
    );
    if (mounted) {
      _reload();
    }
  }

  Future<void> _update(String id, ContextInlineAddResult result) async {
    await widget.repository.updateSkill(id: id, label: result.value);
    if (mounted) {
      _reload();
    }
  }

  Future<void> _delete(String id) async {
    await widget.repository.deleteSkill(id);
    if (mounted) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      appBar: CupidHeader(
        title: l10n.skill_profile_screen_title,
        onBack: Navigator.of(context).canPop()
            ? () => Navigator.of(context).maybePop()
            : null,
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<SkillEntry>>(
          future: _skills,
          builder: (
            BuildContext context,
            AsyncSnapshot<List<SkillEntry>> snapshot,
          ) {
            final List<SkillEntry> skills =
                snapshot.data ?? const <SkillEntry>[];
            return ListView(
              key: const Key('skill-profile-list'),
              padding: const EdgeInsets.all(CupidSpacing.md),
              children: <Widget>[
                if (skills.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: CupidSpacing.md),
                    child: AskOnTheSpotSlot(
                      entryPointId: skillProfileEntryPointId,
                      neededFieldIds: <String>[AskTarget.skill.wireValue],
                      onContextChanged: _reload,
                      repository: widget.repository,
                      contentLoader: widget.contentLoader,
                      sessionSkips: widget.sessionSkips,
                    ),
                  ),
                for (final SkillEntry skill in skills)
                  Padding(
                    padding: const EdgeInsets.only(bottom: CupidSpacing.sm),
                    child: _editingId == skill.id
                        ? ContextInlineAddRow(
                            hintText: l10n.skill_profile_add_hint,
                            initialValue: skill.label,
                            saveLabel: l10n.context_save_action,
                            cancelLabel: l10n.context_cancel_action,
                            onCancel: () => setState(() => _editingId = null),
                            onSubmit: (ContextInlineAddResult r) =>
                                _update(skill.id, r),
                          )
                        : _SkillRow(
                            skill: skill,
                            onEdit: () => setState(() {
                              _editingId = skill.id;
                              _adding = false;
                            }),
                            onDelete: () => _delete(skill.id),
                          ),
                  ),
                if (_adding)
                  ContextInlineAddRow(
                    hintText: l10n.skill_profile_add_hint,
                    saveLabel: l10n.context_save_action,
                    cancelLabel: l10n.context_cancel_action,
                    onCancel: () => setState(() => _adding = false),
                    onSubmit: _add,
                  )
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const Key('skill-profile-add'),
                      onPressed: () => setState(() {
                        _adding = true;
                        _editingId = null;
                      }),
                      child: Text(
                        l10n.context_add_own_action,
                        style: context.cupidType.body.copyWith(
                          color: context.cupidColors.colorAccentPurple,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.skill,
    required this.onEdit,
    required this.onDelete,
  });

  final SkillEntry skill;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Container(
      key: Key('skill-entry-${skill.id}'),
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
            child: Text(
              skill.label,
              style: type.body.copyWith(color: colors.colorText),
            ),
          ),
          PopupMenuButton<_SkillRowAction>(
            key: Key('skill-entry-menu-${skill.id}'),
            icon: Icon(Icons.more_horiz, color: colors.colorTextMuted),
            tooltip: l10n.context_row_menu_label,
            onSelected: (_SkillRowAction action) {
              switch (action) {
                case _SkillRowAction.edit:
                  onEdit();
                case _SkillRowAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_SkillRowAction>>[
                  PopupMenuItem<_SkillRowAction>(
                    key: Key('skill-edit-action-${skill.id}'),
                    value: _SkillRowAction.edit,
                    child: Text(l10n.context_edit_action),
                  ),
                  PopupMenuItem<_SkillRowAction>(
                    key: Key('skill-delete-action-${skill.id}'),
                    value: _SkillRowAction.delete,
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
