import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/adaptive/cupid_primary_button.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../activity_cards/domain/activity_card.dart';
import '../../../activity_cards/domain/activity_card_repository.dart';
import '../../domain/invite_payload_repository.dart';
import '../../domain/preset_catalogue.dart';
import '../invite_composer_cubit.dart';
import 'frame_chip_strip.dart';

/// `mobile/lib/l10n/` is outside this story's write scope, so the composer uses
/// the same file-local bilingual helper the hub and Home surfaces already use
/// instead of adding ARB keys. Invite *content* never passes through here — it
/// comes from the content pack (R-15a).
String _composerText(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;

/// Sheet height as a fraction of the screen (`ux/uiux-spec.md` §1: "cao ~70%",
/// kéo giãn tới full-screen).
const double _initialSheetExtent = 0.7;
const double _minSheetExtent = 0.5;
const double _maxSheetExtent = 1;

const double _grabHandleWidth = 40;
const double _grabHandleHeight = 4;

/// Minimum preview height, so a one-line invite still reads as an editable
/// block rather than as a caption.
const double _previewMinHeight = 120;

/// Opens the invite composer for [card] (`ux/uiux-spec.md` §1).
///
/// [categoryId] is a hidden parameter (§6): the sheet shows no category picker
/// and the user cannot change it from inside. This is the single entry point
/// STORY-007/008 reuse, which is why the pack is loaded *before* the sheet is
/// shown — a composer that opens with no frames would be the empty state §1
/// forbids. Returns `true` only when an invite was exported.
Future<bool> showInviteComposerSheet(
  BuildContext context,
  ActivityCard card,
  String categoryId, {
  InviteComposerCubit Function()? createCubit,
}) async {
  final InviteComposerCubit cubit = createCubit != null
      ? createCubit()
      : InviteComposerCubit(
          card: card,
          categoryId: categoryId,
          catalogue: getIt<PresetCatalogue>(),
          payloads: getIt<InvitePayloadRepository>(),
          cards: getIt<ActivityCardRepository>(),
          share: shareInviteText,
        );
  await cubit.load();
  if (cubit.state.status != InviteComposerStatus.ready || !context.mounted) {
    await cubit.close();
    return false;
  }
  final CupidColorTokens colors = context.cupidColors;
  final CupidPlatformTokens platform = context.cupidPlatform;
  final bool? exported = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: colors.colorSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(platform.radiusSheet),
      ),
    ),
    builder: (BuildContext _) => BlocProvider<InviteComposerCubit>.value(
      value: cubit,
      child: const InviteComposerSheet(),
    ),
  );
  await cubit.close();
  return exported ?? false;
}

/// Hands the finished invite to the OS Share Sheet.
///
/// Fire-and-forget by contract (R-1b/AC-16/AC-19): the call's return value is
/// discarded and no delivery state, retry, or "đã gửi" marker is derived from
/// it. `share_plus` 13.3.0 API, matching the app's existing share surface in
/// `features/home/presentation/home_screen.dart`.
Future<void> shareInviteText(String text) async {
  await SharePlus.instance.share(ShareParams(text: text));
}

/// The composer body (`ux/uiux-spec.md` §2). Expects an [InviteComposerCubit]
/// already loaded into `ready` above it.
class InviteComposerSheet extends StatefulWidget {
  const InviteComposerSheet({super.key});

  @override
  State<InviteComposerSheet> createState() => _InviteComposerSheetState();
}

class _InviteComposerSheetState extends State<InviteComposerSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _editing = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing(String text) {
    setState(() {
      _editing = true;
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return BlocConsumer<InviteComposerCubit, InviteComposerState>(
      listenWhen: (InviteComposerState previous, InviteComposerState current) =>
          previous.frameIndex != current.frameIndex || current.exported,
      listener: (BuildContext context, InviteComposerState state) {
        if (state.exported) {
          // §4: after export the user goes straight back to the card, where
          // STORY-001's existing toggle already reflects `invited`.
          Navigator.of(context).pop(true);
          return;
        }
        if (_editing) {
          final String text = state.text;
          _controller.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }
      },
      builder: (BuildContext context, InviteComposerState state) {
        final InviteComposerCubit cubit = context.read<InviteComposerCubit>();
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: _initialSheetExtent,
          minChildSize: _minSheetExtent,
          maxChildSize: _maxSheetExtent,
          builder: (BuildContext context, ScrollController scrollController) {
            return Column(
              key: const Key('invite_composer_sheet'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: CupidSpacing.sm),
                Center(
                  child: Container(
                    width: _grabHandleWidth,
                    height: _grabHandleHeight,
                    decoration: BoxDecoration(
                      color: colors.colorLine,
                      borderRadius: BorderRadius.circular(_grabHandleHeight),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CupidSpacing.md,
                    CupidSpacing.md,
                    CupidSpacing.md,
                    CupidSpacing.md,
                  ),
                  child: Text(
                    _composerText(context, 'Soạn lời mời', 'Write the invite'),
                    style: type.cardTitle.copyWith(color: colors.colorText),
                  ),
                ),
                FrameChipStrip(
                  labels: <String>[
                    for (final preset in state.presets) preset.frame,
                  ],
                  selectedIndex: state.frameIndex,
                  onSelected: cubit.selectFrame,
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      CupidSpacing.md,
                      CupidSpacing.md,
                      CupidSpacing.md,
                      CupidSpacing.sm,
                    ),
                    children: <Widget>[
                      _PreviewBlock(
                        text: state.text,
                        editing: _editing,
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: cubit.editText,
                        onTap: () => _startEditing(state.text),
                        colors: colors,
                        platform: platform,
                        type: type,
                      ),
                      if (state.failure != null)
                        Padding(
                          padding: const EdgeInsets.only(top: CupidSpacing.sm),
                          child: Text(
                            _composerText(
                              context,
                              'Chưa lưu được lời mời, thử lại nhé.',
                              'The invite could not be saved, please try again.',
                            ),
                            style: type.caption.copyWith(color: colors.colorRed),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    CupidSpacing.md,
                    CupidSpacing.sm,
                    CupidSpacing.md,
                    CupidSpacing.md +
                        MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: CupidPrimaryButton(
                    key: const Key('invite_composer_share'),
                    label: _composerText(context, 'Chia sẻ', 'Share'),
                    onPressed: state.exporting ? null : cubit.share,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// The invite preview (`ux/uiux-spec.md` §2.3). Tapping turns the block itself
/// into a text field — deliberately not a push to a separate editor screen,
/// which would lose the frame strip and the live re-render.
class _PreviewBlock extends StatelessWidget {
  const _PreviewBlock({
    required this.text,
    required this.editing,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onTap,
    required this.colors,
    required this.platform,
    required this.type,
  });

  final String text;
  final bool editing;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;
  final CupidColorTokens colors;
  final CupidPlatformTokens platform;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    final TextStyle bodyStyle = type.body.copyWith(color: colors.colorText);
    return GestureDetector(
      key: const Key('invite_composer_preview'),
      onTap: editing ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: _previewMinHeight),
        padding: const EdgeInsets.all(CupidSpacing.md),
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(platform.radiusCard),
          border: Border.all(color: colors.colorLine),
        ),
        child: editing
            ? TextField(
                key: const Key('invite_composer_preview_field'),
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                maxLines: null,
                style: bodyStyle,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              )
            : Text(text, style: bodyStyle),
      ),
    );
  }
}
