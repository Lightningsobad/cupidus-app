import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/icons/cupid_icons.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../domain/activity_card.dart';
import '../../domain/activity_card_repository.dart';
import '../../domain/activity_type.dart';
import '../../domain/time_of_day_slot.dart';
import '../activity_card_detail_cubit.dart';
import '../formatters/vi_field_format.dart';
import '../widgets/activity_card_tile.dart';
import '../widgets/activity_status_filter.dart';
import '../widgets/card_detail_overflow_menu.dart';
import '../widgets/delete_card_dialog.dart';
import '../widgets/status_change_picker.dart';
import '../widgets/time_of_day_slot_picker.dart';

/// One card, full screen (`ux/uiux-spec.md` §5).
///
/// Full screen rather than a bottom sheet on purpose: STORY-006/007 nest the
/// memory blocks inside this screen, and a sheet has no room to grow into
/// them. "Ghi lại" (*Đã đi rồi*) and "xem lại" (*Đã thành kỷ niệm*) are two
/// modes of this one screen, not two destinations (AC-13), and both keep the
/// status-change and delete rows, so neither mode is a dead end.
class ActivityCardDetailScreen extends StatelessWidget {
  const ActivityCardDetailScreen({
    super.key,
    required this.card,
    this.repository,
    this.onDeleted,
  });

  final ActivityCard card;

  /// Test/preview seam, matching `ActivityCardHubView.repository`. Left null in
  /// production so the screen resolves the same composition-root registration.
  final ActivityCardRepository? repository;

  /// Called once the card is gone, so the caller can drop it from its list
  /// before this screen pops.
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ActivityCardDetailCubit>(
      create: (_) => ActivityCardDetailCubit(
        repository: repository ?? getIt<ActivityCardRepository>(),
        card: card,
      ),
      child: _ActivityCardDetailBody(onDeleted: onDeleted),
    );
  }
}

class _ActivityCardDetailBody extends StatefulWidget {
  const _ActivityCardDetailBody({this.onDeleted});

  final VoidCallback? onDeleted;

  @override
  State<_ActivityCardDetailBody> createState() =>
      _ActivityCardDetailBodyState();
}

class _ActivityCardDetailBodyState extends State<_ActivityCardDetailBody> {
  late final TextEditingController _title;
  late final TextEditingController _note;
  late final TextEditingController _sourceLink;
  late final TextEditingController _price;
  late final TextEditingController _distance;
  late final TextEditingController _duration;
  late final TextEditingController _linkSourceLabel;

  /// Holds only what the user is currently typing. The saved keywords live in
  /// the card, so this is cleared the moment one is added.
  final TextEditingController _noteKeyword = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();
  final FocusNode _noteKeywordFocus = FocusNode();
  final FocusNode _linkSourceLabelFocus = FocusNode();
  final FocusNode _sourceLinkFocus = FocusNode();
  final FocusNode _priceFocus = FocusNode();
  final FocusNode _distanceFocus = FocusNode();
  final FocusNode _durationFocus = FocusNode();
  final GlobalKey _memoryQuoteKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final ActivityCard card = context.read<ActivityCardDetailCubit>().state.card;
    _title = TextEditingController(text: card.title);
    _note = TextEditingController(text: card.note ?? '');
    _sourceLink = TextEditingController(text: card.sourceLink ?? '');
    // A-2: a field starts unfocused, so it starts formatted.
    _price = TextEditingController(text: formatPriceVnd(card.priceVnd));
    _distance = TextEditingController(text: formatDistanceKm(card.distanceKm));
    _duration = TextEditingController(
      text: formatDurationMinutes(card.durationMinutes),
    );
    _linkSourceLabel = TextEditingController(text: card.linkSourceLabel ?? '');
    _commitOnBlur(_titleFocus, _commitTitle);
    _commitOnBlur(_noteFocus, _commitNote);
    _commitOnBlur(_noteKeywordFocus, _commitNoteKeyword);
    _commitOnBlur(_linkSourceLabelFocus, _commitLinkSourceLabel);
    _commitOnBlur(_sourceLinkFocus, _commitSourceLink);
    _bindNumericField(
      node: _priceFocus,
      controller: _price,
      commit: _commitPrice,
      format: (String text) => formatPriceVnd(parsePriceVnd(text)),
      unformat: (String text) => rawPriceVnd(parsePriceVnd(text)),
    );
    _bindNumericField(
      node: _distanceFocus,
      controller: _distance,
      commit: _commitDistance,
      format: (String text) => formatDistanceKm(parseDistanceKm(text)),
      unformat: (String text) => rawDistanceKm(parseDistanceKm(text)),
    );
    _bindNumericField(
      node: _durationFocus,
      controller: _duration,
      commit: _commitDuration,
      format: (String text) => formatDurationMinutes(parseDurationMinutes(text)),
      unformat: (String text) => rawDurationMinutes(parseDurationMinutes(text)),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _sourceLink.dispose();
    _price.dispose();
    _distance.dispose();
    _duration.dispose();
    _linkSourceLabel.dispose();
    _noteKeyword.dispose();
    _titleFocus.dispose();
    _noteFocus.dispose();
    _noteKeywordFocus.dispose();
    _linkSourceLabelFocus.dispose();
    _sourceLinkFocus.dispose();
    _priceFocus.dispose();
    _distanceFocus.dispose();
    _durationFocus.dispose();
    super.dispose();
  }

  ActivityCardDetailCubit get _cubit => context.read<ActivityCardDetailCubit>();

  /// A text field writes when the user is finished with it — on submit, or the
  /// moment it loses focus — never per keystroke: one sentence typed into the
  /// note is one row write, not forty. Discrete controls (chips, toggles, the
  /// date picker) still write the instant they settle.
  void _commitOnBlur(FocusNode node, VoidCallback commit) {
    node.addListener(() {
      if (!node.hasFocus) {
        commit();
      }
    });
  }

  /// A-2 for the three numeric fields: focused → raw buffer, unfocused →
  /// formatted string (`master-plan.md` §11.1). The swap happens here and
  /// only here — never through a per-keystroke [TextInputFormatter], which is
  /// what invariant 3 forbids. [commit] stays the single write gate; this
  /// wraps it rather than replacing it.
  void _bindNumericField({
    required FocusNode node,
    required TextEditingController controller,
    required VoidCallback commit,
    required String Function(String text) format,
    required String Function(String text) unformat,
  }) {
    node.addListener(() {
      if (!mounted) {
        return;
      }
      if (node.hasFocus) {
        _replaceText(controller, unformat(controller.text));
      } else {
        commit();
        _replaceText(controller, format(controller.text));
      }
      // The formatted string carries its own unit, so the decoration's suffix
      // is drawn only while the field is raw. That is a build-time read of
      // `node.hasFocus`, hence the rebuild.
      setState(() {});
    });
  }

  /// Writes [value] straight into [controller]. Programmatic assignment does
  /// not run `inputFormatters`, which is why the formatted price survives the
  /// digits-only filter on that field.
  void _replaceText(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _commitTitle() {
    if (!mounted) {
      return;
    }
    final String trimmed = _title.text.trim();
    // AC-6: the title is the one field a card cannot lose, so an empty edit is
    // never written through. The field is put back to the stored title rather
    // than left showing a value the store does not hold (S6-F-6).
    if (trimmed.isEmpty) {
      _title.text = _cubit.state.card.title;
      return;
    }
    _cubit.editTitle(trimmed);
  }

  void _commitNote() {
    if (!mounted) {
      return;
    }
    final String value = _note.text;
    _cubit.editNote(value.trim().isEmpty ? null : value);
  }

  void _commitSourceLink() {
    if (!mounted) {
      return;
    }
    // Kept verbatim (AC-7): only "blank" is normalised, to `null`.
    final String value = _sourceLink.text;
    _cubit.editSourceLink(value.trim().isEmpty ? null : value);
  }

  void _commitLinkSourceLabel() {
    if (!mounted) {
      return;
    }
    final String value = _linkSourceLabel.text.trim();
    _cubit.editLinkSourceLabel(value.isEmpty ? null : value);
  }

  /// Appends what the field holds to the saved keywords and empties it. The
  /// field accepts a comma-separated run, so one paste can add several; blank
  /// items are dropped by [parseNoteKeywords] rather than stored.
  void _commitNoteKeyword() {
    if (!mounted) {
      return;
    }
    final List<String> added = parseNoteKeywords(_noteKeyword.text);
    _noteKeyword.clear();
    if (added.isEmpty) {
      return;
    }
    final List<String> next = <String>[
      ...parseNoteKeywords(_cubit.state.card.noteKeywords),
      ...added,
    ];
    _cubit.editNoteKeywords(formatNoteKeywords(next));
  }

  /// Tapping a chip deletes it. Removing the last one writes `null`, not `''`
  /// — [formatNoteKeywords] owns that rule.
  void _removeNoteKeyword(int index) {
    final List<String> next =
        parseNoteKeywords(_cubit.state.card.noteKeywords);
    if (index < 0 || index >= next.length) {
      return;
    }
    next.removeAt(index);
    _cubit.editNoteKeywords(formatNoteKeywords(next));
  }

  // The three gates below are the only place a number reaches the data layer
  // (§11.1, invariant 4). They parse rather than forward text, so a field left
  // in its formatted state — `180.000đ`, never re-focused — still commits the
  // integer 180000.
  void _commitPrice() {
    if (!mounted) {
      return;
    }
    _cubit.editPriceVnd(parsePriceVnd(_price.text));
  }

  void _commitDistance() {
    if (!mounted) {
      return;
    }
    _cubit.editDistanceKm(parseDistanceKm(_distance.text));
  }

  void _commitDuration() {
    if (!mounted) {
      return;
    }
    _cubit.editDurationMinutes(parseDurationMinutes(_duration.text));
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final ActivityCardDetailCubit cubit =
        context.read<ActivityCardDetailCubit>();

    return Scaffold(
      backgroundColor: colors.colorBackground,
      body: SafeArea(
        child: MultiBlocListener(
          listeners: <BlocListener<ActivityCardDetailCubit,
              ActivityCardDetailState>>[
            BlocListener<ActivityCardDetailCubit, ActivityCardDetailState>(
              listenWhen: (
                ActivityCardDetailState previous,
                ActivityCardDetailState current,
              ) =>
                  previous.pendingRegression != current.pendingRegression &&
                  current.pendingRegression != null,
              listener: (BuildContext context, ActivityCardDetailState state) =>
                  _askAboutScheduledDate(context, cubit),
            ),
            BlocListener<ActivityCardDetailCubit, ActivityCardDetailState>(
              listenWhen: (
                ActivityCardDetailState previous,
                ActivityCardDetailState current,
              ) =>
                  !previous.deleted && current.deleted,
              listener: (BuildContext context, ActivityCardDetailState state) {
                widget.onDeleted?.call();
                Navigator.of(context).maybePop();
              },
            ),
          ],
          child: BlocBuilder<ActivityCardDetailCubit, ActivityCardDetailState>(
            builder: (BuildContext context, ActivityCardDetailState state) =>
                _content(context, state, cubit),
          ),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    ActivityCardDetailState state,
    ActivityCardDetailCubit cubit,
  ) {
    final ActivityCard card = state.card;

    return CustomScrollView(
      key: const Key('activity_card_detail'),
      slivers: <Widget>[
        SliverToBoxAdapter(child: _header(context, card, cubit)),
        SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CupidSpacing.lg,
              ),
              // A-4's order: title -> meta -> note -> chip -> link -> CTA. The
              // three lifecycle blocks that used to sit between the link and
              // the CTA are reachable from the header overflow instead (A-1).
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _titleField(context, state),
                  if (state.isReviewing) ...<Widget>[
                    const SizedBox(height: CupidSpacing.md),
                    _memoryPhotoPlaceholder(context),
                  ],
                  const SizedBox(height: CupidSpacing.md),
                  _metaBlock(context, card),
                  const SizedBox(height: CupidSpacing.md),
                  _noteBlock(context, state),
                  const SizedBox(height: CupidSpacing.md),
                  _chipRow(context, state, cubit),
                  const SizedBox(height: CupidSpacing.md),
                  _sourceLinkRow(context, card),
                  const SizedBox(height: CupidSpacing.lg),
                  _primaryAction(context, state, cubit),
                  const SizedBox(height: CupidSpacing.xl),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _header(
    BuildContext context,
    ActivityCard card,
    ActivityCardDetailCubit cubit,
  ) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final bool memory = card.status == ActivityCardStatus.memory;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CupidSpacing.md,
        CupidSpacing.sm,
        CupidSpacing.lg,
        CupidSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Semantics(
            button: true,
            child: GestureDetector(
              key: const Key('card_detail_back'),
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: SizedBox(
                width: platform.tapTarget,
                height: platform.tapTarget,
                child: Icon(
                  CupidIcons.arrowBack,
                  size: 20,
                  color: colors.colorAccentPink,
                  semanticLabel: activityHubText(context, 'Quay lại', 'Back'),
                ),
              ),
            ),
          ),
          const SizedBox(width: CupidSpacing.sm),
          // A-3, a closed exception: on A8 alone the pill sits at the right
          // edge. One conditional `Spacer` on either side of it, not a
          // per-status alignment parameter.
          if (memory) const Spacer(),
          DecoratedBox(
            key: const Key('card_detail_status_pill'),
            decoration: BoxDecoration(
              color: memory
                  ? colors.colorButter.withValues(alpha: 0.18)
                  : colors.colorAccentPink.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(platform.radiusButton),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CupidSpacing.sm + CupidSpacing.xs,
                vertical: CupidSpacing.xs + 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          memory ? colors.colorButter : colors.colorAccentPink,
                    ),
                  ),
                  const SizedBox(width: CupidSpacing.xs + 2),
                  Text(
                    activityStatusLabel(context, card.status).toUpperCase(),
                    style: type.caption.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color:
                          memory ? colors.colorButter : colors.colorAccentPink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!memory) const Spacer(),
          const SizedBox(width: CupidSpacing.sm),
          CardDetailOverflowMenu(
            onSelected: (CardDetailOverflowAction action) =>
                _runOverflowAction(context, action, cubit),
          ),
        ],
      ),
    );
  }

  /// A-1: each of the three overflow choices reaches its own dialog or sheet
  /// directly. Nothing here opens a second menu or a step in between.
  void _runOverflowAction(
    BuildContext context,
    CardDetailOverflowAction action,
    ActivityCardDetailCubit cubit,
  ) {
    switch (action) {
      case CardDetailOverflowAction.changeStatus:
        _pickStatus(context, cubit, cubit.state.card.status);
      case CardDetailOverflowAction.delete:
        _confirmDelete(context, cubit);
      case CardDetailOverflowAction.markReply:
        _markReply(context, cubit);
    }
  }

  /// AC-17's two flags, in one sheet at one level. They keep their own keys and
  /// their own two-state behaviour: this only changes where they are reached
  /// from, and the sheet stays open across a tap so the pair still reads as the
  /// user's own bookkeeping rather than a wizard.
  Future<void> _markReply(
    BuildContext context,
    ActivityCardDetailCubit cubit,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cupidColors.colorSurface,
      builder: (BuildContext sheetContext) => BlocProvider<
          ActivityCardDetailCubit>.value(
        value: cubit,
        child: SafeArea(
          key: const Key('card_detail_reply_sheet'),
          child: Padding(
            padding: const EdgeInsets.all(CupidSpacing.lg),
            child: BlocBuilder<ActivityCardDetailCubit, ActivityCardDetailState>(
              builder: (
                BuildContext context,
                ActivityCardDetailState state,
              ) =>
                  _invitedBlock(context, state, cubit),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleField(BuildContext context, ActivityCardDetailState state) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return TextField(
      key: const Key('card_detail_title_field'),
      controller: _title,
      focusNode: _titleFocus,
      maxLines: null,
      textInputAction: TextInputAction.done,
      onSubmitted: (String _) => _commitTitle(),
      style: type.display.copyWith(
        fontSize: state.isReviewing ? 27 : 30,
        color: colors.colorText,
        height: 1.15,
      ),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: activityHubText(context, 'Tên thẻ', 'Card title'),
        hintStyle: type.display.copyWith(
          fontSize: state.isReviewing ? 27 : 30,
          color: colors.colorTextMuted,
        ),
      ),
    );
  }

  /// A8's 4:3 photo band. The photo picker itself belongs to the memory-capture
  /// story, so this is the empty frame that story fills — it carries no fake
  /// image and no "add photo" affordance this phase cannot honour.
  Widget _memoryPhotoPlaceholder(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return AspectRatio(
      key: const Key('card_detail_memory_photo'),
      aspectRatio: 4 / 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(platform.radiusCard),
        ),
        child: Center(
          child: Icon(
            CupidIcons.image,
            size: 30,
            color: colors.colorTextMuted,
            semanticLabel: activityHubText(
              context,
              'Chưa có ảnh',
              'No photo yet',
            ),
          ),
        ),
      ),
    );
  }

  Widget _noteBlock(BuildContext context, ActivityCardDetailState state) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final String label = state.isReviewing
        ? activityHubText(context, 'Câu bạn viết tối đó', 'What you wrote')
        : state.isRecording
            ? activityHubText(context, 'Ghi lại buổi đó', 'Write it down')
            : activityHubText(context, 'Sổ tay có ghi', 'Your notes');

    return Container(
      key: state.isReviewing ? _memoryQuoteKey : null,
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            key: const Key('card_detail_memory_quote'),
            style: type.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colors.colorTextMuted,
            ),
          ),
          const SizedBox(height: CupidSpacing.sm),
          TextField(
            key: const Key('card_detail_note_field'),
            controller: _note,
            focusNode: _noteFocus,
            maxLines: null,
            minLines: 2,
            style: type.body.copyWith(fontSize: 14, color: colors.colorText),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: activityHubText(
                context,
                'Ghi vài dòng cho chính mình',
                'A few lines for yourself',
              ),
              hintStyle: type.body.copyWith(
                fontSize: 14,
                color: colors.colorTextMuted,
              ),
            ),
          ),
          ..._noteKeywordStrip(context, state.card),
        ],
      ),
    );
  }

  /// The `note_keywords` chips, under the note inside the same block (§13.3a).
  /// Returns nothing at all when the column is empty, so an unused card keeps
  /// today's shape instead of growing a blank row.
  List<Widget> _noteKeywordStrip(BuildContext context, ActivityCard card) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final List<String> keywords = parseNoteKeywords(card.noteKeywords);

    return <Widget>[
      if (keywords.isNotEmpty) ...<Widget>[
        const SizedBox(height: CupidSpacing.sm),
        Wrap(
          key: const Key('card_detail_note_keywords'),
          spacing: CupidSpacing.xs,
          runSpacing: CupidSpacing.xs,
          children: <Widget>[
            for (int i = 0; i < keywords.length; i++)
              Semantics(
                button: true,
                child: GestureDetector(
                  key: Key('card_detail_note_keyword_$i'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _removeNoteKeyword(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CupidSpacing.sm,
                      vertical: CupidSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.colorSurfaceAlt,
                      borderRadius:
                          BorderRadius.circular(platform.radiusButton),
                    ),
                    child: Text(
                      keywords[i],
                      style: type.caption.copyWith(color: colors.colorText),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
      const SizedBox(height: CupidSpacing.xs),
      TextField(
        key: const Key('card_detail_note_keyword_field'),
        controller: _noteKeyword,
        focusNode: _noteKeywordFocus,
        textInputAction: TextInputAction.done,
        onSubmitted: (String _) => _commitNoteKeyword(),
        style: type.caption.copyWith(color: colors.colorText),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: activityHubText(context, 'Thêm từ khoá', 'Add a keyword'),
          hintStyle: type.caption.copyWith(color: colors.colorTextMuted),
        ),
      ),
    ];
  }

  /// A-4's meta block: the card's structured facts, directly under the title.
  /// The date leads it, then the canvas 2x2 — THỜI LƯỢNG beside KHUNG GIỜ, then
  /// KHOẢNG CÁCH beside GIÁ. Indoor/outdoor is the sixth fact and stays a
  /// tappable chip in the block below, so it is stated once, not twice.
  Widget _metaBlock(BuildContext context, ActivityCard card) {
    return Column(
      key: const Key('card_detail_meta'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _metaDateRow(context, card),
        const SizedBox(height: CupidSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _statCard(
                context,
                fieldKey: const Key('card_detail_duration_field'),
                label: activityHubText(context, 'Thời lượng', 'Duration'),
                controller: _duration,
                focusNode: _durationFocus,
                hint: activityHubText(context, 'chưa rõ', 'not set'),
                unit: activityHubText(context, 'phút', 'min'),
                onCommit: _commitDuration,
                digitsOnly: true,
              ),
            ),
            const SizedBox(width: CupidSpacing.sm),
            Expanded(child: _timeSlotCard(context, card.timeOfDaySlot)),
          ],
        ),
        const SizedBox(height: CupidSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _statCard(
                context,
                fieldKey: const Key('card_detail_distance_field'),
                label: activityHubText(context, 'Khoảng cách', 'Distance'),
                controller: _distance,
                focusNode: _distanceFocus,
                hint: activityHubText(context, 'chưa rõ', 'not set'),
                unit: 'km',
                onCommit: _commitDistance,
              ),
            ),
            const SizedBox(width: CupidSpacing.sm),
            Expanded(
              child: _statCard(
                context,
                fieldKey: const Key('card_detail_price_field'),
                label: activityHubText(context, 'Giá', 'Price'),
                controller: _price,
                focusNode: _priceFocus,
                hint: activityHubText(context, 'chưa rõ', 'not set'),
                unit: 'đ',
                onCommit: _commitPrice,
                digitsOnly: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metaDateRow(BuildContext context, ActivityCard card) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final String? scheduledOn = card.scheduledOn;

    return Row(
      children: <Widget>[
        Icon(
          CupidIcons.event,
          size: 16,
          color: colors.colorTextMuted,
          semanticLabel: activityHubText(context, 'Ngày hẹn', 'Date'),
        ),
        const SizedBox(width: CupidSpacing.sm),
        Expanded(
          child: Text(
            scheduledOn ??
                activityHubText(context, 'chưa hẹn ngày', 'no date yet'),
            key: const Key('card_detail_meta_date'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: type.caption.copyWith(
              color: scheduledOn == null
                  ? colors.colorTextMuted
                  : colors.colorText,
            ),
          ),
        ),
      ],
    );
  }

  /// KHUNG GIỜ. The cell keeps the shape its three neighbours in the A-4 grid
  /// have, but it is a tap target rather than a text field: the column holds a
  /// closed vocabulary, so it is picked, not typed (§13.2).
  Widget _timeSlotCard(BuildContext context, TimeOfDaySlot? slot) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      button: true,
      child: GestureDetector(
        key: const Key('card_detail_time_slot_cell'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _pickTimeOfDaySlot(slot),
        child: Container(
          padding: const EdgeInsets.all(CupidSpacing.md),
          decoration: BoxDecoration(
            color: colors.colorSurface,
            borderRadius: BorderRadius.circular(platform.radiusSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                activityHubText(context, 'Khung giờ', 'Time of day')
                    .toUpperCase(),
                style: type.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: colors.colorTextMuted,
                ),
              ),
              const SizedBox(height: CupidSpacing.xs),
              Text(
                _timeOfDaySlotLabel(context, slot),
                key: const Key('card_detail_time_slot'),
                style: type.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      slot == null ? colors.colorTextMuted : colors.colorText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTimeOfDaySlot(TimeOfDaySlot? current) async {
    final TimeOfDaySlotChoice? choice = await showTimeOfDaySlotPicker(
      context,
      current: current,
    );
    // A dismissed sheet is not an answer: only a tap writes, and *Chưa rõ* is
    // one of the taps.
    if (choice == null || !mounted) {
      return;
    }
    await _cubit.editTimeOfDaySlot(timeOfDaySlotForChoice(choice));
  }

  String _timeOfDaySlotLabel(BuildContext context, TimeOfDaySlot? slot) {
    switch (slot) {
      case null:
        return activityHubText(context, 'chưa rõ', 'not set');
      case TimeOfDaySlot.morning:
        return activityHubText(context, 'Sáng', 'Morning');
      case TimeOfDaySlot.noon:
        return activityHubText(context, 'Trưa', 'Midday');
      case TimeOfDaySlot.afternoon:
        return activityHubText(context, 'Chiều', 'Afternoon');
      case TimeOfDaySlot.evening:
        return activityHubText(context, 'Tối', 'Evening');
    }
  }

  Widget _statCard(
    BuildContext context, {
    required Key fieldKey,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required String unit,
    required VoidCallback onCommit,
    bool digitsOnly = false,
  }) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: type.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colors.colorTextMuted,
            ),
          ),
          const SizedBox(height: CupidSpacing.xs),
          TextField(
            key: fieldKey,
            controller: controller,
            focusNode: focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: digitsOnly
                ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
                : null,
            textInputAction: TextInputAction.done,
            onSubmitted: (String _) => onCommit(),
            style: type.body.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.colorText,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: type.body.copyWith(color: colors.colorTextMuted),
              // A-2: the unfocused value already reads `180.000đ`, so drawing
              // the suffix beside it would print the unit twice. It comes back
              // the moment the field goes raw.
              suffixText: focusNode.hasFocus ? unit : null,
              suffixStyle: type.caption.copyWith(
                fontSize: 12,
                color: colors.colorTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipRow(
    BuildContext context,
    ActivityCardDetailState state,
    ActivityCardDetailCubit cubit,
  ) {
    final ActivityCard card = state.card;

    return Wrap(
      spacing: CupidSpacing.sm,
      runSpacing: CupidSpacing.sm,
      children: <Widget>[
        _ActivityTypeChip(
          selected: card.activityType,
          onSelected: cubit.editActivityType,
        ),
        _DetailChip(
          chipKey: const Key('card_detail_booking_chip'),
          label: card.needsBooking ?? false
              ? activityHubText(context, 'cần đặt trước', 'booking needed')
              : activityHubText(
                  context,
                  'không cần đặt trước',
                  'no booking needed',
                ),
          active: card.needsBooking ?? false,
          onTap: () => cubit.editNeedsBooking(!(card.needsBooking ?? false)),
        ),
        _DetailChip(
          chipKey: const Key('card_detail_indoor_outdoor_chip'),
          label: switch (card.indoorOutdoor) {
            ActivityCardIndoorOutdoor.indoor =>
              activityHubText(context, 'trong nhà', 'indoor'),
            ActivityCardIndoorOutdoor.outdoor =>
              activityHubText(context, 'ngoài trời', 'outdoor'),
            null => activityHubText(context, 'trong hay ngoài?', 'in or out?'),
          },
          active: card.indoorOutdoor != null,
          onTap: () => cubit.editIndoorOutdoor(
            switch (card.indoorOutdoor) {
              null => ActivityCardIndoorOutdoor.indoor,
              ActivityCardIndoorOutdoor.indoor =>
                ActivityCardIndoorOutdoor.outdoor,
              ActivityCardIndoorOutdoor.outdoor => null,
            },
          ),
        ),
      ],
    );
  }

  Widget _sourceLinkRow(BuildContext context, ActivityCard card) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CupidSpacing.md,
        vertical: CupidSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusSmall + 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ..._linkProvenanceRow(context, card),
          Row(
            children: <Widget>[
              Icon(
                CupidIcons.link,
                size: 18,
                color: colors.colorMint,
                semanticLabel:
                    activityHubText(context, 'Link gốc', 'Source link'),
              ),
              const SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: TextField(
                  key: const Key('card_detail_source_link_field'),
                  controller: _sourceLink,
                  focusNode: _sourceLinkFocus,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (String _) => _commitSourceLink(),
                  style: type.caption.copyWith(color: colors.colorText),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: activityHubText(
                      context,
                      'Dán link nếu có',
                      'Paste a link if you have one',
                    ),
                    hintStyle:
                        type.caption.copyWith(color: colors.colorTextMuted),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// D-22's provenance line, above the link itself: what the user called the
  /// source, and the short date it was saved. Drawn only when the card has at
  /// least one of the two — with neither, the block keeps its old one-line
  /// shape rather than printing a "chưa rõ" the user never asked about.
  ///
  /// The label is an input; the date is not. `link_saved_at` follows the link
  /// (§13.4), so there is nothing here to type it into.
  List<Widget> _linkProvenanceRow(BuildContext context, ActivityCard card) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final String savedAt = formatShortViDate(card.linkSavedAt);
    if (card.linkSourceLabel == null && savedAt.isEmpty) {
      return const <Widget>[];
    }

    return <Widget>[
      Row(
        key: const Key('card_detail_link_provenance'),
        children: <Widget>[
          Expanded(
            child: TextField(
              key: const Key('card_detail_link_source_label_field'),
              controller: _linkSourceLabel,
              focusNode: _linkSourceLabelFocus,
              textInputAction: TextInputAction.done,
              onSubmitted: (String _) => _commitLinkSourceLabel(),
              style: type.caption.copyWith(color: colors.colorTextMuted),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: activityHubText(
                  context,
                  'Link này từ đâu?',
                  'Where is this link from?',
                ),
                hintStyle: type.caption.copyWith(color: colors.colorTextMuted),
              ),
            ),
          ),
          if (savedAt.isNotEmpty) ...<Widget>[
            const SizedBox(width: CupidSpacing.sm),
            Text(
              activityHubText(context, 'lưu $savedAt', 'saved $savedAt'),
              key: const Key('card_detail_link_saved_at'),
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ],
        ],
      ),
      const SizedBox(height: CupidSpacing.xs),
    ];
  }

  /// AC-17/AC-18. "Đã rủ" has exactly two values and moves only on this tap.
  /// Nothing beside it records when the tap happened, whether the other person
  /// opened anything, or how often — the reply chip is likewise a flag this
  /// user sets by hand about their own bookkeeping.
  Widget _invitedBlock(
    BuildContext context,
    ActivityCardDetailState state,
    ActivityCardDetailCubit cubit,
  ) {
    final ActivityCard card = state.card;

    return Wrap(
      spacing: CupidSpacing.sm,
      runSpacing: CupidSpacing.sm,
      children: <Widget>[
        _DetailChip(
          chipKey: const Key('card_detail_invited_chip'),
          label: card.invited
              ? activityHubText(context, 'Đã rủ', 'Invited')
              : activityHubText(context, 'Chưa rủ', 'Not invited yet'),
          active: card.invited,
          onTap: cubit.toggleInvited,
        ),
        if (card.invited)
          _DetailChip(
            chipKey: const Key('card_detail_reply_chip'),
            label: card.replyState == ActivityCardReplyState.answered
                ? activityHubText(context, 'Đã trả lời', 'Answered')
                : activityHubText(context, 'Chưa trả lời', 'No reply yet'),
            active: card.replyState == ActivityCardReplyState.answered,
            onTap: cubit.toggleReplyState,
          ),
      ],
    );
  }

  /// Exactly one primary action. D-18 lets this screen word it in its own
  /// voice instead of the fixed SC-4 label the P4 tile still uses; only the
  /// wording is loosened, so the action identifier, the tap handler, and the
  /// resulting transition all still come from [primaryActionFor].
  /// *Đã thành kỷ niệm* draws it outlined instead of on `gradientHot`,
  /// following A8: a memory is worth re-reading, not worth shouting about.
  Widget _primaryAction(
    BuildContext context,
    ActivityCardDetailState state,
    ActivityCardDetailCubit cubit,
  ) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final ActivityCardStatus status = state.card.status;
    final ActivityCardPrimaryAction action = primaryActionFor(status);
    final bool outlined = action == ActivityCardPrimaryAction.review;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          button: true,
          child: GestureDetector(
            key: const Key('card_detail_primary_action'),
            behavior: HitTestBehavior.opaque,
            onTap: () => _runPrimaryAction(context, action, cubit),
            child: Container(
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: outlined ? null : colors.gradientHot,
                color: outlined ? colors.colorSurface : null,
                border: outlined
                    ? Border.all(color: colors.colorLine, width: 1.5)
                    : null,
                borderRadius: BorderRadius.circular(platform.radiusButton),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    outlined ? CupidIcons.menuBook : CupidIcons.schedule,
                    size: 18,
                    color: outlined ? colors.colorButter : colors.colorText,
                  ),
                  const SizedBox(width: CupidSpacing.sm),
                  // D-18's wording runs longer than the fixed SC-4 label, so
                  // the pill shrinks the text rather than truncating it: a
                  // half-shown CTA is worse than a slightly smaller one.
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _screenPrimaryActionLabel(context, status),
                        maxLines: 1,
                        style: type.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.colorText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: CupidSpacing.sm),
        // D-19's single secondary line. Inert prose, not a second CTA: no
        // `gradientHot` pill, its own row below the button, and no tap target —
        // every route it hints at is already reachable from the fields above,
        // so making it interactive would invent a transition SC-4 does not have.
        //
        // R8-F-1/D-28 tints it with the lilac accent so the line reads as an
        // offer rather than as disabled help text. Lilac and not pink: pink is
        // the CTA's own colour, and matching it would make this look like the
        // second button D-19 forbids. Weight, size and alignment are untouched.
        Text(
          _screenSecondaryLine(context, status),
          key: const Key('card_detail_secondary_line'),
          textAlign: TextAlign.center,
          style: type.caption.copyWith(color: colors.colorAccentLilac),
        ),
      ],
    );
  }

  /// D-18: A4's own CTA wording. The two *Mới nghĩ ra* / *Đã thành kỷ niệm*
  /// strings are the ones the AC quotes from the canvas; the other two follow
  /// the same voice.
  String _screenPrimaryActionLabel(
    BuildContext context,
    ActivityCardStatus status,
  ) {
    switch (status) {
      case ActivityCardStatus.idea:
        return activityHubText(context, 'Chốt ngày đi thôi', 'Lock in a day');
      case ActivityCardStatus.scheduled:
        return activityHubText(
          context,
          'Chuẩn bị cho tươm tất',
          'Get it all ready',
        );
      case ActivityCardStatus.done:
        return activityHubText(
          context,
          'Ghi lại buổi đó đi',
          'Write that one down',
        );
      case ActivityCardStatus.memory:
        return activityHubText(
          context,
          'Đọc lại · rủ đi lần nữa',
          'Read it again · ask again',
        );
    }
  }

  /// D-19: the one secondary line under the CTA. Lower case on purpose — it
  /// reads as an aside, not as a button that lost its background.
  String _screenSecondaryLine(
    BuildContext context,
    ActivityCardStatus status,
  ) {
    switch (status) {
      case ActivityCardStatus.idea:
        return activityHubText(
          context,
          'hoặc soạn lời rủ cho ngọt · để dành hôm khác',
          'or word the invite nicely · keep it for another day',
        );
      case ActivityCardStatus.scheduled:
        return activityHubText(
          context,
          'hoặc ngó lại ghi chú · để mai tính tiếp',
          'or glance at the notes · settle it tomorrow',
        );
      case ActivityCardStatus.done:
        return activityHubText(
          context,
          'hoặc thêm ảnh sau · viết dần cũng được',
          'or add a photo later · write it bit by bit',
        );
      case ActivityCardStatus.memory:
        return activityHubText(
          context,
          'hoặc để yên đó · lúc nào nhớ thì mở lại',
          'or leave it be · open it when you miss it',
        );
    }
  }

  Future<void> _runPrimaryAction(
    BuildContext context,
    ActivityCardPrimaryAction action,
    ActivityCardDetailCubit cubit,
  ) async {
    switch (action) {
      case ActivityCardPrimaryAction.scheduleDate:
        await _pickDate(context, cubit);
      case ActivityCardPrimaryAction.prepare:
        // STORY-002 owns preparation. Saying so is the honest state; inventing
        // a checklist here would put a second story's surface on this screen.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              activityHubText(
                context,
                'Phần chuẩn bị nằm ở bước sau.',
                'Preparation comes in a later step.',
              ),
            ),
          ),
        );
      case ActivityCardPrimaryAction.recordMemory:
        _noteFocus.requestFocus();
      case ActivityCardPrimaryAction.review:
        final BuildContext? quoteContext = _memoryQuoteKey.currentContext;
        if (quoteContext != null) {
          await Scrollable.ensureVisible(quoteContext, alignment: 0.1);
        }
    }
  }

  /// AC-12: one gesture picks the date, saves it, and moves the card to
  /// *Đã hẹn ngày* — there is no separate "now change the status" step.
  Future<void> _pickDate(
    BuildContext context,
    ActivityCardDetailCubit cubit,
  ) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 5),
    );
    if (picked == null) {
      return;
    }
    await cubit.scheduleDate(_isoDate(picked));
  }

  Future<void> _pickStatus(
    BuildContext context,
    ActivityCardDetailCubit cubit,
    ActivityCardStatus current,
  ) async {
    final ActivityCardStatus? next =
        await showStatusChangePicker(context, current: current);
    if (next == null) {
      return;
    }
    await cubit.changeStatus(next);
  }

  Future<void> _askAboutScheduledDate(
    BuildContext context,
    ActivityCardDetailCubit cubit,
  ) async {
    final ScheduledDateChoice? choice =
        await showScheduledDateChoiceDialog(context);
    if (choice == null) {
      cubit.cancelRegression();
      return;
    }
    await cubit.resolveRegression(choice);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ActivityCardDetailCubit cubit,
  ) async {
    if (!await showDeleteCardDialog(context)) {
      return;
    }
    await cubit.deleteCard();
  }
}

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

class _ActivityTypeChip extends StatelessWidget {
  const _ActivityTypeChip({required this.selected, required this.onSelected});

  final ActivityType? selected;
  final ValueChanged<ActivityType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return PopupMenuButton<String>(
      key: const Key('card_detail_activity_type_chip'),
      color: colors.colorSurface,
      tooltip: activityHubText(context, 'Loại hoạt động', 'Activity type'),
      onSelected: (String wireValue) =>
          onSelected(activityTypeFromWireValue(wireValue)),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          key: const Key('card_detail_activity_type_none'),
          value: '',
          child: Text(
            activityTypeSemanticLabel(context, null),
            style: type.body.copyWith(color: colors.colorText),
          ),
        ),
        for (final ActivityType option in ActivityType.values)
          PopupMenuItem<String>(
            key: Key('card_detail_activity_type_${option.wireValue}'),
            value: option.wireValue,
            child: Text(
              activityTypeSemanticLabel(context, option),
              style: type.body.copyWith(color: colors.colorText),
            ),
          ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(platform.radiusButton),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CupidSpacing.md,
            vertical: CupidSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                activityTypeIcon(selected),
                size: 14,
                color: colors.colorTextMuted,
              ),
              const SizedBox(width: CupidSpacing.xs),
              Text(
                activityTypeSemanticLabel(context, selected),
                style: type.caption.copyWith(color: colors.colorText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.chipKey,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final Key chipKey;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        key: chipKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: active ? colors.colorAccentLilac : colors.colorSurfaceAlt,
            borderRadius: BorderRadius.circular(platform.radiusButton),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CupidSpacing.md,
              vertical: CupidSpacing.sm,
            ),
            child: Text(
              label,
              style: type.caption.copyWith(
                color: active ? colors.colorBackground : colors.colorText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
