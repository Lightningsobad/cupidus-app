import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/content_package.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../design_system/design_system.dart';
import '../../data/context_notebook_repository.dart';
import '../../domain/ask_cadence_policy.dart';
import '../cubit/ask_on_the_spot_cubit.dart';

/// The route that currently owns the one allowed ask card, keyed by the route
/// object itself so two entry points stacked on one screen cannot both ask.
final Map<Object, _AskOnTheSpotHostState> _routeClaims =
    <Object, _AskOnTheSpotHostState>{};

/// Fallback claim scope for a slot built outside any [Navigator], so "one
/// question at a time" still holds there.
const Object _rootlessScope = Object();

/// The inline ask card (`architecture/contract-summary.md` §3).
///
/// STORY-005/008/009/010 build this widget rather than drawing their own ask,
/// so the "đúng một câu một lần" invariant (AC-2/BR-2) lives here and not in
/// each caller's discipline: a second slot on the same route renders nothing,
/// whatever the caller intended.
class AskOnTheSpotSlot extends StatelessWidget {
  const AskOnTheSpotSlot({
    super.key,
    required this.entryPointId,
    required this.neededFieldIds,
    required this.onContextChanged,
    this.repository,
    this.contentLoader,
    this.sessionSkips,
  });

  /// The caller's entry point from `contract-summary.md` §2, e.g.
  /// `gift_ideas`. Travels with the ask as the caller's own label; the slot
  /// never branches on it, so a new entry point is a new value and not new
  /// machinery.
  final String entryPointId;

  /// `contract-summary.md` §2 target ids, most wanted first.
  final List<String> neededFieldIds;

  /// Called after an answer is written. The caller re-runs whatever it was
  /// showing, in place — this is a filter step, not a save action.
  final VoidCallback onContextChanged;

  @visibleForTesting
  final ContextNotebookRepository? repository;

  @visibleForTesting
  final ContentPackageLoader? contentLoader;

  @visibleForTesting
  final AskSessionSkips? sessionSkips;

  @override
  Widget build(BuildContext context) {
    return _AskOnTheSpotHost(
      neededFieldIds: neededFieldIds,
      onContextChanged: onContextChanged,
      repository: repository,
      contentLoader: contentLoader,
      sessionSkips: sessionSkips,
    );
  }
}

class _AskOnTheSpotHost extends StatefulWidget {
  const _AskOnTheSpotHost({
    required this.neededFieldIds,
    required this.onContextChanged,
    required this.repository,
    required this.contentLoader,
    required this.sessionSkips,
  });

  final List<String> neededFieldIds;
  final VoidCallback onContextChanged;
  final ContextNotebookRepository? repository;
  final ContentPackageLoader? contentLoader;
  final AskSessionSkips? sessionSkips;

  @override
  State<_AskOnTheSpotHost> createState() => _AskOnTheSpotHostState();
}

class _AskOnTheSpotHostState extends State<_AskOnTheSpotHost> {
  Object? _claimKey;
  bool _owns = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object key = ModalRoute.of(context) ??
        Navigator.maybeOf(context) ??
        _rootlessScope;
    if (key == _claimKey) {
      return;
    }
    _release();
    _claimKey = key;
    if (_routeClaims.containsKey(key)) {
      return;
    }
    _routeClaims[key] = this;
    _owns = true;
  }

  void _release() {
    final Object? key = _claimKey;
    if (key != null && identical(_routeClaims[key], this)) {
      _routeClaims.remove(key);
    }
    _claimKey = null;
    _owns = false;
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_owns) {
      return const SizedBox.shrink();
    }
    return BlocProvider<AskOnTheSpotCubit>(
      create: (BuildContext _) => AskOnTheSpotCubit(
        repository: widget.repository ?? getIt<ContextNotebookRepository>(),
        neededFieldIds: widget.neededFieldIds,
        contentLoader: widget.contentLoader ?? const ContentPackageLoader(),
        sessionSkips: widget.sessionSkips,
      ),
      child: BlocBuilder<AskOnTheSpotCubit, AskOnTheSpotState>(
        builder: (BuildContext context, AskOnTheSpotState state) {
          if (state.status != AskSlotStatus.asking) {
            return const SizedBox.shrink();
          }
          return _AskCard(
            state: state,
            onAnswer: (AskChoice choice) async {
              await context.read<AskOnTheSpotCubit>().answer(
                    label: choice.label,
                    seedId: choice.seedId,
                  );
              if (mounted) {
                widget.onContextChanged();
              }
            },
            onSkip: () => context.read<AskOnTheSpotCubit>().skip(),
          );
        },
      ),
    );
  }
}

/// `ux/uiux-spec.md` Phần A: one short question, a tap-to-pick strip, an
/// optional "khác..." field at the end of it, and a plain "Bỏ qua" link.
/// Deliberately absent: a "Lưu vào hồ sơ" button, and any toast or screen
/// after the answer (AC-1).
class _AskCard extends StatefulWidget {
  const _AskCard({
    required this.state,
    required this.onAnswer,
    required this.onSkip,
  });

  final AskOnTheSpotState state;
  final Future<void> Function(AskChoice choice) onAnswer;
  final VoidCallback onSkip;

  @override
  State<_AskCard> createState() => _AskCardState();
}

class _AskCardState extends State<_AskCard> {
  final TextEditingController _freeText = TextEditingController();
  bool _freeTextOpen = false;

  @override
  void dispose() {
    _freeText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Container(
      key: const Key('ask-on-the-spot-card'),
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
        border: Border.all(color: colors.colorLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.state.question!.prompt,
            key: const Key('ask-on-the-spot-prompt'),
            style: type.body.copyWith(color: colors.colorText),
          ),
          const SizedBox(height: CupidSpacing.md),
          Wrap(
            spacing: CupidSpacing.sm,
            runSpacing: CupidSpacing.sm,
            children: <Widget>[
              for (final AskChoice choice in widget.state.choices)
                _SeedChip(
                  key: Key('ask-chip-${choice.seedId ?? choice.label}'),
                  label: choice.label,
                  onTap: () => widget.onAnswer(choice),
                ),
              if (widget.state.allowFreeText && !_freeTextOpen)
                _SeedChip(
                  key: const Key('ask-other-chip'),
                  label: 'Khác...',
                  onTap: () => setState(() => _freeTextOpen = true),
                ),
            ],
          ),
          if (_freeTextOpen) ...<Widget>[
            const SizedBox(height: CupidSpacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    key: const Key('ask-free-text-field'),
                    controller: _freeText,
                    autofocus: true,
                    style: type.body.copyWith(color: colors.colorText),
                    onSubmitted: (String _) => _submitFreeText(),
                  ),
                ),
                TextButton(
                  key: const Key('ask-free-text-submit'),
                  onPressed: _submitFreeText,
                  child: const Text('Xong'),
                ),
              ],
            ),
          ],
          const SizedBox(height: CupidSpacing.sm),
          GestureDetector(
            key: const Key('ask-skip'),
            onTap: widget.onSkip,
            child: Text(
              'Bỏ qua',
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ),
        ],
      ),
    );
  }

  void _submitFreeText() {
    final String typed = _freeText.text.trim();
    if (typed.isEmpty) {
      return;
    }
    widget.onAnswer(AskChoice(label: typed));
  }
}

class _SeedChip extends StatelessWidget {
  const _SeedChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(platform.radiusSmall),
      child: Container(
        constraints: BoxConstraints(minHeight: platform.tapTarget),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: CupidSpacing.md),
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(platform.radiusSmall),
          border: Border.all(color: colors.colorLine),
        ),
        child: Text(
          label,
          style: context.cupidType.body.copyWith(color: colors.colorText),
        ),
      ),
    );
  }
}
