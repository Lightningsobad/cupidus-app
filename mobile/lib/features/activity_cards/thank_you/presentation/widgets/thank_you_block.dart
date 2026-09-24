import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/content/content_package.dart';
import '../../../../../core/database/cupid_database.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../design_system/icons/cupid_icons.dart';
import '../../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../../conversation_starters/domain/starter_content.dart';
import '../../../domain/activity_card.dart';
import '../../../domain/activity_card_repository.dart';
import '../../../domain/occasion_suggestion_service.dart' show civilDate;
import '../../data/thank_you_activation_dao.dart';
import '../../data/thank_you_activation_repository_impl.dart';
import '../../domain/next_plan_suggestion_service.dart';
import '../../domain/thank_you_activation_service.dart';
import '../next_plan_cubit.dart';
import '../thank_you_block_cubit.dart';
import 'next_plan_section.dart';
import 'thanks_section.dart';

/// `mobile/lib/l10n/` is outside this story's write scope, so the block follows
/// the same file-local bilingual helper the other activity-card surfaces use
/// instead of adding ARB keys.
String _text(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;

/// The three sections the block is a frame for, top to bottom
/// (`ux/uiux-spec.md` mục 3). P2 ships the frame and this contract only; P3,
/// P4 and P5 fill one field each.
///
/// A null slot puts nothing in the widget tree — no placeholder and no grey
/// row — which is also the shape P4's "card with no photo" empty state needs
/// (AC-15/BR-9).
@immutable
class ThankYouSlots {
  const ThankYouSlots({this.thanks, this.photo, this.nextPlan});

  /// Phần 1 — soạn lời cảm ơn (P3).
  final Widget? thanks;

  /// Phần 2 — đính ảnh (P4).
  final Widget? photo;

  /// Phần 3 — chốt việc kế tiếp (P5).
  final Widget? nextPlan;
}

/// Test/preview seams for [ThankYouSection], mirroring
/// `ActivityCardDetailScreen.repository`. All null in production, so the
/// section resolves the registered database.
@immutable
class ThankYouOptions {
  const ThankYouOptions({
    this.service,
    this.thanks,
    this.nextPlan,
    this.slots = const ThankYouSlots(),
  });

  final ThankYouActivationService? service;

  /// Seams for phần 1. Null in production, so the section resolves the
  /// registered catalogue and opens STORY-002's real composer sheet.
  final ThanksOptions? thanks;

  /// Seams for phần 3. Null in production, so the section reads the device
  /// clock, the shipped occasion pack and the registered card store.
  final NextPlanOptions? nextPlan;

  final ThankYouSlots slots;
}

/// Test/preview seams for phần 3 (`ux/uiux-spec.md` mục 3).
@immutable
class NextPlanOptions {
  const NextPlanOptions({
    this.today,
    this.package,
    this.loader,
    this.repository,
  });

  /// Pins the civil day the occasions are resolved against, so a test renders
  /// the same chips on any run day (AC-19).
  final DateTime? today;

  final ContentPackage<CalendarEvent>? package;
  final ContentPackageLoader? loader;
  final ActivityCardRepository? repository;
}

/// The mount point the card-detail screen keeps at the foot of its
/// photo/notes column (`architecture/solution.md` §3 UI Delivery Anchor).
///
/// Costs one `SizedBox.shrink` on every card that is not a *Đã đi rồi* card
/// holding an unspent turn, which after the block's single presentation is
/// every card forever (AC-3).
class ThankYouSection extends StatefulWidget {
  const ThankYouSection({super.key, required this.card, this.options});

  final ActivityCard card;
  final ThankYouOptions? options;

  @override
  State<ThankYouSection> createState() => _ThankYouSectionState();
}

class _ThankYouSectionState extends State<ThankYouSection> {
  late final ThankYouBlockCubit _cubit;

  /// Built here but loaded only once the block is actually visible, so opening
  /// any other card never reaches the occasion pack at all.
  NextPlanCubit? _nextPlan;

  bool _thanksAvailable = false;

  @override
  void initState() {
    super.initState();
    _cubit = ThankYouBlockCubit(
      cardId: widget.card.id,
      isRecording: widget.card.status == ActivityCardStatus.done,
      service: () => widget.options?.service ?? _registeredService(),
    );
    unawaited(_resolve());
  }

  Future<void> _resolve() async {
    await _cubit.resolve();
    if (!mounted || !_cubit.state.isVisible) {
      return;
    }
    if (widget.options?.slots.thanks == null) {
      final bool available = await thankYouPresetsAvailable(
        widget.options?.thanks?.catalogue,
      );
      if (!mounted) {
        return;
      }
      setState(() => _thanksAvailable = available);
    }
    if (widget.options?.slots.nextPlan != null) {
      // A caller that already put its own widget in the slot gets exactly
      // that; phần 3 does not resolve a pack behind it.
      return;
    }
    final NextPlanOptions options =
        widget.options?.nextPlan ?? const NextPlanOptions();
    final NextPlanCubit next = NextPlanCubit(
      today: civilDate(options.today ?? DateTime.now()),
      service: NextPlanSuggestionService(
        repository: options.repository ?? getIt<ActivityCardRepository>(),
      ),
      package: options.package,
      loader: options.loader ?? const ContentPackageLoader(),
    );
    setState(() => _nextPlan = next);
    await next.load();
  }

  /// The ledger has no composition-root registration of its own: it is one
  /// table behind a DAO, and building it here keeps the whole sub-feature
  /// inside `features/activity_cards/thank_you/`.
  ThankYouActivationService _registeredService() => ThankYouActivationService(
        ThankYouActivationRepositoryImpl(
          ThankYouActivationDao(getIt<CupidDatabase>()),
        ),
      );

  @override
  void dispose() {
    _nextPlan?.close();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThankYouBlockCubit>.value(
      value: _cubit,
      child: BlocBuilder<ThankYouBlockCubit, ThankYouBlockState>(
        builder: (BuildContext context, ThankYouBlockState state) =>
            state.isVisible ? _block() : const SizedBox.shrink(),
      ),
    );
  }

  Widget _block() {
    final ThankYouSlots declared =
        widget.options?.slots ?? const ThankYouSlots();
    // A category that does not resolve to a pack with presets leaves the slot
    // itself out of the tree, so the entry point is never a row that opens an
    // empty sheet (AC-27).
    final Widget? thanks = declared.thanks ??
        (_thanksAvailable
            ? ThanksSection(
                card: widget.card,
                options: widget.options?.thanks ?? const ThanksOptions(),
              )
            : null);
    final NextPlanCubit? next = _nextPlan;
    if (next == null || declared.nextPlan != null) {
      return ThankYouBlock(
        cubit: _cubit,
        slots: ThankYouSlots(
          thanks: thanks,
          photo: declared.photo,
          nextPlan: declared.nextPlan,
        ),
      );
    }

    return BlocProvider<NextPlanCubit>.value(
      value: next,
      child: BlocBuilder<NextPlanCubit, NextPlanState>(
        // An occasion pack with nothing upcoming leaves `nextPlan` null, which
        // keeps the slot itself out of the tree: no header over an empty row,
        // no placeholder chip (AC-35).
        builder: (BuildContext context, NextPlanState state) => ThankYouBlock(
          cubit: _cubit,
          slots: ThankYouSlots(
            thanks: thanks,
            photo: declared.photo,
            nextPlan: state.suggestions.isEmpty
                ? null
                : NextPlanSection(suggestions: state.suggestions),
          ),
        ),
      ),
    );
  }
}

/// The "Cảm ơn + chốt việc kế tiếp" block (`ux/uiux-spec.md` mục 1-2).
///
/// Deliberately the same container as STORY-006's "Trước giờ đi" block —
/// `--r-sm` corners, layered surface, indented one `md`. The two never share a
/// card because they belong to different statuses, so one visual pattern for
/// both is consistency rather than collision (mục 6).
///
/// Everything inside sits at the secondary-action tier. The block adds no
/// card-level CTA: "Ghi lại" stays the card's single primary action
/// (AC-6/AC-7, BR-1).
class ThankYouBlock extends StatelessWidget {
  const ThankYouBlock({
    super.key,
    required this.cubit,
    this.slots = const ThankYouSlots(),
  });

  final ThankYouBlockCubit cubit;
  final ThankYouSlots slots;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Padding(
      key: const Key('thank_you_block'),
      padding: const EdgeInsets.only(
        top: CupidSpacing.md,
        left: CupidSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(CupidSpacing.md),
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt,
          border: Border.all(color: colors.colorLine),
          borderRadius: BorderRadius.circular(platform.radiusSmall),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _header(context),
            _slot(const Key('thank_you_slot_thanks'), slots.thanks),
            _slot(const Key('thank_you_slot_photo'), slots.photo),
            _slot(const Key('thank_you_slot_next_plan'), slots.nextPlan),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            _text(
              context,
              'Cảm ơn + chốt việc kế tiếp',
              'Say thanks, then pick what is next',
            ),
            style: type.body.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.colorText,
            ),
          ),
        ),
        Semantics(
          button: true,
          child: GestureDetector(
            key: const Key('thank_you_close'),
            behavior: HitTestBehavior.opaque,
            onTap: cubit.dismiss,
            child: SizedBox(
              width: platform.tapTarget,
              height: platform.tapTarget,
              child: Icon(
                CupidIcons.close,
                size: 20,
                color: colors.colorTextMuted,
                semanticLabel: _text(context, 'Đóng', 'Close'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// An unfilled slot draws nothing at all, so the P2 frame is a header and
  /// its border rather than three empty rows waiting to be filled.
  Widget _slot(Key key, Widget? child) => child == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: CupidSpacing.sm),
          child: KeyedSubtree(key: key, child: child),
        );
}
