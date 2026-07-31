import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/design_system.dart';
import '../../data/gallery_repository.dart';
import '../gallery_cubit.dart';
import '../gallery_state.dart';
import '../widgets/gallery_locked_view.dart';

/// State-driven host for the shared gallery
/// (`coding-plan/phase-P1-gallery-shell-and-gate.md` §3). Renders
/// [GalleryLockedView] for the AC3 gate and temporary placeholders for
/// `empty`/`loaded`/`failure` until P2 lands the real grid.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key, this.createCubit, this.onPairingCta});

  /// Overridable for tests; defaults to a real [GalleryCubit] resolved from
  /// [getIt] (`core/di/service_locator.dart`'s STORY-013 P0 registration).
  final GalleryCubit Function()? createCubit;

  /// Overridable for tests; defaults to [_showPairingFlowUnavailable].
  final VoidCallback? onPairingCta;

  GalleryCubit _defaultCubit() =>
      GalleryCubit(repository: getIt<GalleryRepository>());

  /// STORY-002 pairing invite/joincode screens are not present in this
  /// worktree yet (only `auth`, `gallery`, and the placeholder `home`
  /// features exist at this story's `BaseHead`), so there is no concrete
  /// screen to push to. Surfaces a snackbar instead of silently doing
  /// nothing, so the CTA's tap target stays verifiably wired; Scrum
  /// Master/Tech Lead should route the real pairing screen link into
  /// [onPairingCta] once those screens merge into the integration branch
  /// (see `coding-plan/master-plan.md` §5 P1 row commentary).
  void _showPairingFlowUnavailable(BuildContext context) {
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isVi
              ? 'Màn hình ghép đôi sẽ sớm có mặt ở đây.'
              : 'The pairing screen will appear here soon.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GalleryCubit>(
      create: (_) => (createCubit ?? _defaultCubit)()..load(),
      child: _GalleryView(
        onPairingCta: onPairingCta ?? () => _showPairingFlowUnavailable(context),
      ),
    );
  }
}

class _GalleryView extends StatelessWidget {
  const _GalleryView({required this.onPairingCta});

  final VoidCallback onPairingCta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupidHeader(
        title: Localizations.localeOf(context).languageCode == 'vi'
            ? 'Gallery chung'
            : 'Shared gallery',
      ),
      body: BlocBuilder<GalleryCubit, GalleryState>(
        builder: (context, state) {
          return switch (state) {
            GalleryLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            GalleryLocked() => GalleryLockedView(onPairingCta: onPairingCta),
            // Temporary placeholders: P2 replaces these with the responsive
            // grid + empty-state widgets (`coding-plan/master-plan.md` §5).
            GalleryEmpty() => Center(
              child: Text(
                Localizations.localeOf(context).languageCode == 'vi'
                    ? 'Chưa có ảnh nào'
                    : 'No photos yet',
              ),
            ),
            GalleryLoaded(:final items) => Center(
              child: Text('${items.length} photos'),
            ),
            GalleryFailure() => Center(
              child: Text(
                Localizations.localeOf(context).languageCode == 'vi'
                    ? 'Không tải được gallery'
                    : 'Could not load the gallery',
              ),
            ),
          };
        },
      ),
    );
  }
}
