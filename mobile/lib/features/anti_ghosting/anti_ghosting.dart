/// STORY-008 feature barrel (`architecture/solution.md` §2 Mobile contract):
/// the cross-story export surface for the anti-ghosting feature. P3 appends
/// `GhostStormCubit` and `GhostStateRow` exports here for STORY-007's chat
/// mount seam.
library;

export 'data/ghost_config_repository.dart';
export 'presentation/anti_ghost_cubit.dart';
export 'presentation/ghost_storm_cubit.dart';
export 'presentation/screens/anti_ghost_screen.dart';
export 'presentation/widgets/anti_ghost_entry_card.dart';
export 'presentation/widgets/ghost_state_row.dart';
