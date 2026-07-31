import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/design_system.dart';
import '../../data/gallery_repository.dart';
import '../../domain/gallery_item.dart';
import '../gallery_cubit.dart';
import '../gallery_state.dart';
import '../widgets/gallery_empty_view.dart';
import '../widgets/gallery_grid_view.dart';
import '../widgets/gallery_locked_view.dart';
import 'gallery_viewer_screen.dart';

/// State-driven host for the shared gallery
/// (`coding-plan/phase-P1-gallery-shell-and-gate.md` §3). Renders
/// [GalleryLockedView] for the AC3 gate, [GalleryEmptyView]/[GalleryGridView]
/// for the loaded states, and pushes [GalleryViewerScreen] when a grid tile
/// is tapped (`coding-plan/master-plan.md` §5 P4).
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

/// P3 (upload sheet) has not landed in this worktree yet
/// (`coding-plan/master-plan.md` §5), so the add-photo affordance has no
/// real destination. Mirrors `GalleryScreen`'s pairing-CTA placeholder
/// pattern rather than silently doing nothing.
void _showUploadFlowUnavailable(BuildContext context) {
  final isVi = Localizations.localeOf(context).languageCode == 'vi';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isVi
            ? 'Tính năng thêm ảnh sẽ sớm có mặt ở đây.'
            : 'Adding photos will be available here soon.',
      ),
    ),
  );
}

void _openViewer(
  BuildContext context, {
  required List<GalleryItem> items,
  required String currentUserId,
  required int initialIndex,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => GalleryViewerScreen(
        items: items,
        currentUserId: currentUserId,
        initialIndex: initialIndex,
      ),
    ),
  );
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
            GalleryEmpty() => GalleryEmptyView(
              onAddPhoto: () => _showUploadFlowUnavailable(context),
            ),
            GalleryLoaded(
              :final items,
              :final currentUserId,
              :final hasMore,
              :final isLoadingMore,
            ) =>
              GalleryGridView(
                items: items,
                currentUserId: currentUserId,
                hasMore: hasMore,
                isLoadingMore: isLoadingMore,
                onTileTap: (index) => _openViewer(
                  context,
                  items: items,
                  currentUserId: currentUserId,
                  initialIndex: index,
                ),
                onAddPhoto: () => _showUploadFlowUnavailable(context),
                onRefresh: () => context.read<GalleryCubit>().refresh(),
                onLoadMore: () => context.read<GalleryCubit>().loadMore(),
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
