import '../../../core/network/cupid_api_failure.dart';
import '../domain/zodiac_red_flag.dart';

/// `zodiac` screen state. Sealed and mutually exclusive (contrast `VibeState`):
/// the degraded card replaces the three content cards rather than rendering
/// beside them (`architecture/contract-summary.md` §6).
sealed class ZodiacState {
  const ZodiacState();
}

final class ZodiacLoading extends ZodiacState {
  const ZodiacLoading();
}

final class ZodiacReady extends ZodiacState {
  const ZodiacReady(this.today);

  final ZodiacRedFlagReady today;
}

/// Reached by `incomplete_profile` and by any unrecognised `status`. Not an
/// error (§6) — the screen shows one neutral card.
final class ZodiacIncompleteProfile extends ZodiacState {
  const ZodiacIncompleteProfile(this.today);

  final ZodiacRedFlagIncompleteProfile today;
}

final class ZodiacError extends ZodiacState {
  const ZodiacError(this.failure);

  final CupidApiFailure failure;
}
