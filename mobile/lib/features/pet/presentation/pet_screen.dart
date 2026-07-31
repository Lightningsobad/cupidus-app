import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/pet_models.dart';
import '../data/pet_repository.dart';
import 'pet_cubit.dart';
import 'pet_state.dart';
import 'pet_strings.dart';
import 'widgets/pet_action_row.dart';
import 'widgets/pet_guard_states.dart';
import 'widgets/pet_hero_card.dart';
import 'widgets/pet_reactions_card.dart';
import 'widgets/pet_stats_row.dart';
import 'widgets/pet_xp_card.dart';

/// `pet` tab screen (`ux/uiux-spec.md` §2.1 item 1, §2.3): renders one branch
/// per [PetState]. Never calls [PetRepository] directly — all reads/writes go
/// through [PetCubit] (`architecture/solution.md` §4: "`PetScreen` →
/// `PetCubit` → `PetRepository`").
class PetScreen extends StatelessWidget {
  const PetScreen({super.key, this.repository});

  /// Overrides the default `getIt<PetRepository>()` lookup; used by widget
  /// tests to inject a fake without touching the global service locator.
  final PetRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PetCubit>(
      create: (_) =>
          PetCubit(repository: repository ?? getIt<PetRepository>())..load(),
      child: const _PetView(),
    );
  }
}

class _PetView extends StatelessWidget {
  const _PetView();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      backgroundColor: colors.colorBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(CupidSpacing.lg),
          child: BlocBuilder<PetCubit, PetState>(
            builder: (context, state) => switch (state) {
              PetLoading() => const _LoadingState(),
              PetLocked() => const PetLockedCard(),
              PetNoPet() => PetAdoptPromptCard(
                  // P7 wires this to the adopt sheet.
                  onAdopt: () {},
                ),
              PetReady() => _ReadyState(
                  status: state.status,
                  cooldownRemaining: state.cooldownRemaining,
                ),
              PetFailure() => _FailureState(failure: state.failure),
            },
          ),
        ),
      ),
    );
  }
}

class _ReadyState extends StatelessWidget {
  const _ReadyState({required this.status, required this.cooldownRemaining});

  final PetStatus status;
  final Duration? cooldownRemaining;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PetHeroCard(status: status),
        SizedBox(height: CupidSpacing.md),
        PetXpCard(status: status),
        SizedBox(height: CupidSpacing.md),
        PetActionRow(cooldownRemaining: cooldownRemaining),
        SizedBox(height: CupidSpacing.md),
        PetStatsRow(status: status),
        SizedBox(height: CupidSpacing.md),
        const PetReactionsCard(),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(CupidSpacing.xxl),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _FailureState extends StatelessWidget {
  const _FailureState({required this.failure});

  final Object failure;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Container(
      padding: EdgeInsets.all(CupidSpacing.lg),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _petFailureMessage(context, failure),
            textAlign: TextAlign.center,
            style: context.cupidType.body.copyWith(color: colors.colorText),
          ),
          SizedBox(height: CupidSpacing.md),
          CupidPrimaryButton(
            label: context.viEn('Thử lại', 'Try again'),
            onPressed: () => context.read<PetCubit>().load(),
          ),
        ],
      ),
    );
  }
}

/// Maps the closed [CupidApiFailure] set to one short user-facing line
/// (`ux/uiux-spec.md` §6: never expose a raw `CupidApiFailure` to the UI).
/// Kept local to this screen rather than in `pet_strings.dart` — this
/// phase's write scope does not include that file.
String _petFailureMessage(BuildContext context, Object failure) {
  return switch (failure) {
    NetworkUnavailableFailure() =>
      context.viEn('Không có kết nối mạng', 'No internet connection'),
    TimeoutFailure() => context.viEn(
        'Kết nối quá chậm, vui lòng thử lại',
        'Connection timed out, please try again',
      ),
    _ => context.viEn(
        'Đã có lỗi xảy ra. Vui lòng thử lại.',
        'Something went wrong. Please try again.',
      ),
  };
}
