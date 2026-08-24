// The seams below are private fields fed by public named parameters, so the
// lint's own fix (`this._field`) is not expressible — a named parameter cannot
// start with `_` (same suppression as `core/navigation/app_shell.dart`).
// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/pairing_invitation.dart';
import 'couple_type.dart';

/// `invite` screen state (`ux/uiux-spec.md` §3).
sealed class InviteState {
  const InviteState();
}

class InviteLoading extends InviteState {
  const InviteLoading();
}

/// [remaining] is the live `expiresAt` countdown (§3's copy correction: 24h
/// TTL, not the mockup's "15 minutes"), recomputed on every tick.
class InviteReady extends InviteState {
  const InviteReady({
    required this.invitation,
    required this.remaining,
    this.selectedCoupleType,
    this.isSaving = false,
  });

  final PairingInvitation invitation;
  final Duration remaining;

  /// `null` means no card is selected and the Continue CTA is disabled.
  final CoupleType? selectedCoupleType;

  /// True only while the Continue PATCH is in flight.
  final bool isSaving;
}

/// [failure] is a `CupidApiFailure` (never a raw exception).
class InviteFailed extends InviteState {
  const InviteFailed(this.failure);

  final Object failure;
}

/// Drives the `invite` screen: generates/fetches the active invitation code
/// and ticks a live countdown from [PairingInvitation.expiresAt].
///
/// Backend truth (`generateCode`, plan §1 D1/§3) is idempotent — calling
/// [refresh] again after a ready state is already shown must not flash a
/// loading state, since the returned code is unchanged; [_generate] only
/// emits [InviteLoading] when there is no prior ready state to hold onto.
class InviteCubit extends Cubit<InviteState> {
  InviteCubit({
    required Future<PairingInvitation> Function() generateInvitation,
    Future<String?> Function()? fetchCoupleType,
    Future<void> Function(CoupleType coupleType)? saveCoupleType,
    DateTime Function() now = DateTime.now,
    Timer Function(Duration duration, void Function() callback)?
    timerFactory,
  }) : _generateInvitation = generateInvitation,
       _fetchCoupleType = fetchCoupleType,
       _saveCoupleType = saveCoupleType,
       _now = now,
       _timerFactory = timerFactory ?? Timer.new,
       super(const InviteLoading()) {
    // Started alongside `_generate` and never awaited by it: the code card's
    // render path must not depend on the profile read (AC1-AC4 are fully
    // usable without a pre-selection).
    unawaited(_loadPersistedCoupleType());
    unawaited(_generate());
  }

  static const Duration _tickInterval = Duration(seconds: 30);

  final Future<PairingInvitation> Function() _generateInvitation;
  final Future<String?> Function()? _fetchCoupleType;
  final Future<void> Function(CoupleType coupleType)? _saveCoupleType;
  final DateTime Function() _now;
  final Timer Function(Duration duration, void Function() callback)
  _timerFactory;

  Timer? _tickTimer;

  /// Holds the profile's value when it resolves before the first
  /// [InviteReady], so AC5's pre-selection lands on the first paint.
  CoupleType? _persistedCoupleType;

  /// Re-runs generation. Safe to call repeatedly (idempotent backend), and
  /// does not flash a loading state if a code is already on screen.
  Future<void> refresh() => _generate();

  Future<void> _generate() async {
    final InviteState previous = state;
    if (previous is! InviteReady) {
      emit(const InviteLoading());
    }
    try {
      final PairingInvitation invitation = await _generateInvitation();
      if (isClosed) return;
      _tickTimer?.cancel();
      _emitReady(invitation);
      _scheduleTick(invitation);
    } catch (failure) {
      if (!isClosed) emit(InviteFailed(failure));
    }
  }

  /// Selects [coupleType], replacing any prior selection (never additive).
  void selectCoupleType(CoupleType coupleType) {
    final InviteState current = state;
    if (current is! InviteReady) return;
    _emitReady(current.invitation, coupleType: coupleType);
  }

  /// Persists the current selection. Returns `true` when the write succeeded;
  /// on `false` the selection is kept and the CTA is re-enabled so the caller
  /// can surface a retryable failure.
  Future<bool> submitCoupleType() async {
    final InviteState current = state;
    if (current is! InviteReady || current.isSaving) return false;
    final CoupleType? selected = current.selectedCoupleType;
    final Future<void> Function(CoupleType)? save = _saveCoupleType;
    if (selected == null || save == null) return false;

    _emitReady(current.invitation, isSaving: true);
    try {
      await save(selected);
      _setSaving(false);
      return true;
    } catch (_) {
      _setSaving(false);
      return false;
    }
  }

  Future<void> _loadPersistedCoupleType() async {
    final Future<String?> Function()? fetch = _fetchCoupleType;
    if (fetch == null) return;
    CoupleType? persisted;
    try {
      persisted = coupleTypeFromWire(await fetch());
    } catch (_) {
      // Best-effort only: a failed profile read degrades to "no
      // pre-selection" and must never reach `InviteFailed`.
      persisted = null;
    }
    if (isClosed || persisted == null) return;
    _persistedCoupleType = persisted;
    final InviteState current = state;
    if (current is InviteReady && current.selectedCoupleType == null) {
      _emitReady(current.invitation, coupleType: persisted);
    }
  }

  void _setSaving(bool isSaving) {
    if (isClosed) return;
    final InviteState current = state;
    if (current is! InviteReady) return;
    _emitReady(current.invitation, isSaving: isSaving);
  }

  /// [coupleType] and [isSaving] default to the current state's values so the
  /// 30s countdown re-emit cannot silently drop a selection.
  void _emitReady(
    PairingInvitation invitation, {
    CoupleType? coupleType,
    bool? isSaving,
  }) {
    final InviteState previous = state;
    emit(
      InviteReady(
        invitation: invitation,
        remaining: _remaining(invitation.expiresAt),
        selectedCoupleType:
            coupleType ??
            (previous is InviteReady
                ? previous.selectedCoupleType
                : _persistedCoupleType),
        isSaving: isSaving ?? (previous is InviteReady && previous.isSaving),
      ),
    );
  }

  void _scheduleTick(PairingInvitation invitation) {
    if (isClosed) return;
    if (_remaining(invitation.expiresAt) <= Duration.zero) return;
    _tickTimer = _timerFactory(_tickInterval, () {
      if (isClosed) return;
      _emitReady(invitation);
      _scheduleTick(invitation);
    });
  }

  Duration _remaining(DateTime expiresAt) {
    final Duration diff = expiresAt.difference(_now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  Future<void> close() {
    _tickTimer?.cancel();
    return super.close();
  }
}
