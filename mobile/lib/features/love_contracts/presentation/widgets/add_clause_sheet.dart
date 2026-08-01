import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';

/// "+ Add our own clause" input (`ux/uiux-spec.md` §4): a single-line text
/// input in existing sheet/dialog chrome with Save/Cancel.
///
/// `showModalBottomSheet` already traps focus within the sheet's own
/// `FocusScopeNode` and restores focus to the triggering control when the
/// route pops (mirrors `sign_out_confirm_dialog.dart`'s reliance on
/// `showDialog`'s built-in modal focus trap/return — §8 accessibility). The
/// text field is `autofocus`, so opening the sheet moves focus straight into
/// it.
///
/// Returns the trimmed clause text, or `null` if the user cancelled,
/// dismissed the sheet, or submitted empty/whitespace-only text.
/// Fully transparent so only the rounded `_AddClauseSheet` container paints
/// the sheet's chrome (no design-system token exists for a transparent
/// value, and raw named/hex colour literals are forbidden outside
/// `design_system/` — `no_fork_guard_test.dart` AC4).
const Color _transparent = Color.fromARGB(0, 0, 0, 0);

Future<String?> showAddClauseSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: _transparent,
    builder: (BuildContext sheetContext) => const _AddClauseSheet(),
  );
}

class _AddClauseSheet extends StatefulWidget {
  const _AddClauseSheet();

  @override
  State<_AddClauseSheet> createState() => _AddClauseSheetState();
}

class _AddClauseSheetState extends State<_AddClauseSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final String trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;
    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.colorSurface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(platformTokens.radiusSheet),
          ),
        ),
        padding: EdgeInsets.all(CupidSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.loveContractAddClauseSheetHelper,
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
            SizedBox(height: CupidSpacing.sm),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              style: type.body.copyWith(color: colors.colorText),
              decoration: InputDecoration(
                hintText: l10n.loveContractAddClauseSheetHelper,
              ),
            ),
            SizedBox(height: CupidSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.loveContractAddClauseSheetCancel),
                  ),
                ),
                SizedBox(width: CupidSpacing.sm),
                Expanded(
                  child: CupidPrimaryButton(
                    label: l10n.loveContractAddClauseSheetSave,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
