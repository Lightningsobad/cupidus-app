import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../design_system/icons/cupid_icons.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../activity_cards/domain/activity_card.dart';
import '../../data/before_you_go_dismissal_store.dart';
import '../../domain/before_you_go_content.dart';
import '../before_you_go_cubit.dart';

/// `mobile/lib/l10n/` is outside this story's write scope, so the block follows
/// the same file-local bilingual helper the activity-card surfaces already use
/// instead of adding ARB keys. Only chrome goes through here: every checklist
/// row's wording comes from the shipped pack (AC-29/BR-15).
String _text(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;

/// The pack's `icon` allowlist mapped to glyphs. Codepoints read from the
/// bundled `MaterialSymbolsRounded-Variable.ttf` cmap with `fontTools`, never
/// invented — the same rule [CupidIcons] follows. They live here rather than in
/// [CupidIcons] because that file is outside this phase's write scope; the keys
/// are pinned to `beforeYouGoAllowedIcons` by a test, so the two cannot drift.
const Map<String, IconData> beforeYouGoHintIcons = <String, IconData>{
  'payments': IconData(0xef63, fontFamily: CupidIcons.fontFamily),
  'local_gas_station': IconData(0xe546, fontFamily: CupidIcons.fontFamily),
  'umbrella': IconData(0xf1ad, fontFamily: CupidIcons.fontFamily),
  'event_available': IconData(0xe614, fontFamily: CupidIcons.fontFamily),
  'share_location': IconData(0xf05f, fontFamily: CupidIcons.fontFamily),
};

/// Test/preview seams for [BeforeYouGoSection], mirroring
/// `ActivityCardDetailScreen.repository`. All null in production, so the
/// section resolves the shipped asset, the real store, and the OS Share Sheet.
@immutable
class BeforeYouGoOptions {
  const BeforeYouGoOptions({this.today, this.pack, this.store, this.share});

  /// Pins the civil date the block is resolved against. The clock read itself
  /// lives on the detail screen, so this module stays free of one (AC-10).
  final DateTime? today;

  final BeforeYouGoPack? pack;
  final BeforeYouGoDismissalStore? store;
  final BeforeYouGoShare? share;
}

/// The mount point the detail screen keeps in its column.
///
/// It renders [BeforeYouGoBlock] only once the phase resolves to something
/// worth drawing, so a card on another day — or a card too sparse to match a
/// single row — leaves no block widget, no frame, and no placeholder in the
/// tree at all (AC-2/AC-3/AC-14).
class BeforeYouGoSection extends StatefulWidget {
  const BeforeYouGoSection({
    super.key,
    required this.card,
    required this.today,
    this.options,
  });

  final ActivityCard card;
  final DateTime today;
  final BeforeYouGoOptions? options;

  @override
  State<BeforeYouGoSection> createState() => _BeforeYouGoSectionState();
}

class _BeforeYouGoSectionState extends State<BeforeYouGoSection> {
  late final BeforeYouGoCubit _cubit;

  @override
  void initState() {
    super.initState();
    final BeforeYouGoOptions? options = widget.options;
    _cubit = BeforeYouGoCubit(
      card: widget.card,
      today: widget.today,
      store: options?.store,
      pack: options?.pack,
      share: options?.share,
    );
    unawaited(_cubit.load());
  }

  @override
  void didUpdateWidget(BeforeYouGoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The detail cubit hands out a new card object only when a field actually
    // changed, so identity is the cheap correct trigger here.
    if (!identical(oldWidget.card, widget.card)) {
      unawaited(_cubit.updateCard(widget.card));
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BeforeYouGoCubit>.value(
      value: _cubit,
      child: BlocBuilder<BeforeYouGoCubit, BeforeYouGoState>(
        builder: (BuildContext context, BeforeYouGoState state) =>
            state.isVisible
                ? BeforeYouGoBlock(state: state, cubit: _cubit)
                : const SizedBox.shrink(),
      ),
    );
  }
}

/// The "Trước giờ đi" block (`ux/uiux-spec.md` mục 2-3).
///
/// A nested sub-block at the secondary-action tier: layered surface, `--r-sm`
/// corners, indented one `md` from the Chuẩn bị region's edge. It is never a
/// second card-level CTA — the outline pill at its foot is the block's own
/// action, not the card's (AC-4).
class BeforeYouGoBlock extends StatelessWidget {
  const BeforeYouGoBlock({
    super.key,
    required this.state,
    required this.cubit,
  });

  final BeforeYouGoState state;
  final BeforeYouGoCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('before_you_go_block'),
      padding: const EdgeInsets.only(
        top: CupidSpacing.md,
        left: CupidSpacing.md,
      ),
      child: state.isDismissed ? _collapsed(context) : _open(context),
    );
  }

  /// The compact one-line row left behind after "Xong hết rồi, đi thôi"
  /// (mục 3). The tick is a neutral line glyph on purpose: a `--mint`/`--green`
  /// "task complete" mark would read as a score, which this feature does not
  /// keep (AC-27).
  Widget _collapsed(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Row(
      key: const Key('before_you_go_collapsed'),
      children: <Widget>[
        Text(
          _text(context, 'Trước giờ đi', 'Before you head out'),
          style: type.body.copyWith(color: colors.colorTextMuted),
        ),
        const SizedBox(width: CupidSpacing.xs),
        Icon(CupidIcons.check, size: 16, color: colors.colorTextMuted),
        const Spacer(),
        _TextAction(
          actionKey: const Key('before_you_go_reopen'),
          label: _text(context, 'Mở lại', 'Open again'),
          onTap: cubit.reopen,
        ),
      ],
    );
  }

  Widget _open(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        border: Border.all(color: colors.colorLine),
        borderRadius: BorderRadius.circular(platform.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: colors.gradientHot,
                  borderRadius: BorderRadius.circular(CupidSpacing.sm),
                ),
                child: Icon(
                  CupidIcons.checklist,
                  size: 18,
                  color: colors.colorText,
                ),
              ),
              const SizedBox(width: CupidSpacing.sm),
              Text(
                _text(context, 'Trước giờ đi', 'Before you head out'),
                style: type.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.colorText,
                ),
              ),
            ],
          ),
          const SizedBox(height: CupidSpacing.xs),
          for (final ChecklistHint hint in state.hints) _row(context, hint),
          const SizedBox(height: CupidSpacing.sm),
          _dismissPill(context),
        ],
      ),
    );
  }

  /// One hint. No checkbox and no done-marker: this is a list read to
  /// remember, not a tally that accumulates (AC-27). Skipping the share row
  /// leaves no warning glyph and no second prompt (AC-21) because nothing here
  /// observes whether it was tapped.
  Widget _row(BuildContext context, ChecklistHint hint) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return ConstrainedBox(
      key: Key('before_you_go_row_${hint.id}'),
      constraints: const BoxConstraints(minHeight: 40),
      child: Row(
        children: <Widget>[
          Icon(
            beforeYouGoHintIcons[hint.icon] ?? CupidIcons.label,
            size: 20,
            color: colors.colorTextMuted,
          ),
          const SizedBox(width: CupidSpacing.sm),
          Expanded(
            child: Text(
              hint.labelVi,
              style: type.body.copyWith(color: colors.colorText),
            ),
          ),
          if (hint.action == HintAction.shareLocation)
            _TextAction(
              actionKey: const Key('before_you_go_share'),
              label: _text(context, 'Chia sẻ', 'Share'),
              onTap: cubit.shareLocation,
            ),
        ],
      ),
    );
  }

  /// The block's own action: an outline pill, never the `gradientHot` fill the
  /// card-level CTA owns. One tap closes the block, with no confirmation
  /// dialog and no congratulation (AC-17).
  Widget _dismissPill(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      button: true,
      child: GestureDetector(
        key: const Key('before_you_go_dismiss'),
        behavior: HitTestBehavior.opaque,
        onTap: cubit.dismiss,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: CupidSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: colors.colorLine, width: 1.5),
            borderRadius: BorderRadius.circular(platform.radiusButton),
          ),
          child: Text(
            _text(context, 'Xong hết rồi, đi thôi', 'All set, let us go'),
            style: type.body.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.colorText,
            ),
          ),
        ),
      ),
    );
  }
}

/// A trailing text button at the `caption 13pt` size the spec asks for: no
/// fill, no border, sized to stay tappable without looking like a second CTA.
class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.actionKey,
    required this.label,
    required this.onTap,
  });

  final Key actionKey;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      button: true,
      child: GestureDetector(
        key: actionKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CupidSpacing.sm,
            vertical: CupidSpacing.sm,
          ),
          child: Text(
            label,
            style: type.caption.copyWith(color: colors.colorAccentPink),
          ),
        ),
      ),
    );
  }
}
