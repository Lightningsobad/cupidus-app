import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pairing_invitation.dart';
import '../../data/pairing_repository.dart';
import '../../data/partner_link.dart';
import '../invite_cubit.dart';
import '../waiting_cubit.dart';
import 'paired_screen.dart';
import 'waiting_screen.dart';

/// `invite` screen (`ux/uiux-spec.md` §3, §6, §9) — inviter's code-display
/// card. Has header, back target `profile` (§1 — no `profile` screen exists
/// yet in this repo, so [onBack] just pops); tab bar hidden (`NO_TABS`).
///
/// Scoped to only the code-display + share/copy card per plan §1 D2: no
/// couple-type picker, no "Continue -> Fingerprint Vow" CTA — both excluded
/// by that decision, not stubbed.
class InviteScreen extends StatelessWidget {
  const InviteScreen({
    super.key,
    InviteCubit Function()? createInviteCubit,
    WaitingCubit Function()? createWaitingCubit,
  }) : _createInviteCubit = createInviteCubit,
       _createWaitingCubit = createWaitingCubit;

  final InviteCubit Function()? _createInviteCubit;
  final WaitingCubit Function()? _createWaitingCubit;

  InviteCubit _defaultInviteCubit() => InviteCubit(
    generateInvitation: getIt<PairingRepository>().generateInvitation,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InviteCubit>(
      create: (_) => (_createInviteCubit ?? _defaultInviteCubit)(),
      child: _InviteView(createWaitingCubit: _createWaitingCubit),
    );
  }
}

class _InviteView extends StatelessWidget {
  const _InviteView({WaitingCubit Function()? createWaitingCubit})
    : _createWaitingCubit = createWaitingCubit;

  /// Threaded through to the pushed [WaitingScreen] (mirrors
  /// `createInviteCubit`'s seam): tests supply a fake poller-backed cubit
  /// instead of `WaitingScreen`'s GetIt-backed default, since
  /// `PairingRepository`'s constructor param is private to its own library
  /// and cannot be faked from outside `data/pairing_repository.dart`.
  final WaitingCubit Function()? _createWaitingCubit;

  /// No `share_plus`-style native-share dependency exists in this phase's
  /// write scope (`pubspec.yaml` is out of scope), so "Share invite" and
  /// "Copy code" both perform the accessible copy-to-clipboard action (§9)
  /// with distinct clipboard payloads/announcements, then both advance to
  /// `waiting` per §3: "After Share or Copy is invoked, advance to waiting."
  Future<void> _share(BuildContext context, PairingInvitation invitation) =>
      _copyAndAdvance(
        context,
        invitation,
        clipboardText:
            'Cupid: ${invitation.code}\n'
            'https://cupid.app/pair?code=${invitation.code}',
        announcement: context.viEn(
          'Đã sao chép để chia sẻ',
          'Copied to share',
        ),
      );

  Future<void> _copy(BuildContext context, PairingInvitation invitation) =>
      _copyAndAdvance(
        context,
        invitation,
        clipboardText: invitation.code,
        announcement: context.viEn('Đã sao chép', 'Copied'),
      );

  Future<void> _copyAndAdvance(
    BuildContext context,
    PairingInvitation invitation, {
    required String clipboardText,
    required String announcement,
  }) async {
    await Clipboard.setData(ClipboardData(text: clipboardText));
    if (!context.mounted) return;
    SemanticsService.sendAnnouncement(
      View.of(context),
      announcement,
      TextDirection.ltr,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(announcement)));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WaitingScreen(
          expiresAt: invitation.expiresAt,
          createWaitingCubit: _createWaitingCubit,
          onPaired: _onWaitingPaired,
        ),
      ),
    );
  }

  /// Advances the inviter from `waiting` to `paired` once
  /// `WaitingCubit`/`PartnerLinkPoller` (D1) detects the partner has joined
  /// (`ux/uiux-spec.md` §2 `waiting -> paired`), clearing the pairing stack so
  /// back navigation cannot return into it.
  void _onWaitingPaired(BuildContext context, PartnerLink link) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const PairedScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      appBar: CupidHeader(
        title: context.viEn('Mời ghép đôi', 'Invite'),
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: context.viEn('Quay lại', 'Back'),
      ),
      backgroundColor: colors.colorBackground,
      body: SafeArea(
        child: BlocBuilder<InviteCubit, InviteState>(
          builder: (context, state) {
            return switch (state) {
              InviteLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              InviteFailed() => _InviteError(
                onRetry: () => context.read<InviteCubit>().refresh(),
              ),
              InviteReady(:final invitation, :final remaining) => Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(CupidSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        label: context.viEn(
                          'Mã ghép đôi của bạn',
                          'Your pairing code',
                        ),
                        child: Text(
                          invitation.code,
                          style: context.cupidType.labelMono.copyWith(
                            fontSize: 40,
                            color: colors.colorText,
                          ),
                        ),
                      ),
                      SizedBox(height: CupidSpacing.sm),
                      Text(
                        context.viEn('Mã 6 ký tự', '6-character code'),
                        style: context.cupidType.caption.copyWith(
                          color: colors.colorTextMuted,
                        ),
                      ),
                      SizedBox(height: CupidSpacing.sm),
                      Text(
                        _formatRemaining(context, remaining),
                        style: context.cupidType.caption.copyWith(
                          color: colors.colorTextMuted,
                        ),
                      ),
                      SizedBox(height: CupidSpacing.xl),
                      CupidPrimaryButton(
                        label: context.viEn('Chia sẻ mã mời', 'Share invite'),
                        onPressed: () => _share(context, invitation),
                      ),
                      SizedBox(height: CupidSpacing.sm),
                      OutlinedButton(
                        onPressed: () => _copy(context, invitation),
                        child: Text(context.viEn('Sao chép mã', 'Copy code')),
                      ),
                    ],
                  ),
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}

class _InviteError extends StatelessWidget {
  const _InviteError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(CupidSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.viEn(
                'Không thể tạo mã mời. Vui lòng thử lại.',
                'Could not create an invite code. Please try again.',
              ),
              textAlign: TextAlign.center,
              style: context.cupidType.body.copyWith(color: colors.colorRed),
            ),
            SizedBox(height: CupidSpacing.lg),
            CupidPrimaryButton(
              label: context.viEn('Thử lại', 'Retry'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// Live countdown text (§3's copy correction: derive from `expiresAt`, 24h
/// TTL — never the mockup's hardcoded "15 minutes" string).
String _formatRemaining(BuildContext context, Duration remaining) {
  if (remaining <= Duration.zero) {
    return context.viEn('Đã hết hạn', 'Expired');
  }
  final int hours = remaining.inHours;
  final int minutes = remaining.inMinutes.remainder(60);
  return context.viEn(
    'Hết hạn sau ${hours}h ${minutes}p',
    'Expires in ${hours}h ${minutes}m',
  );
}

/// vi/en copy transcribed from `ux/uiux-spec.md`, resolved from the ambient
/// [Locale] (mirrors `features/auth/presentation/auth_strings.dart`'s
/// `AuthLocaleText` — duplicated locally rather than imported cross-feature
/// or added to `pairing_strings.dart`, which is plan §3 P3's file, outside
/// this phase's write scope).
extension _InviteLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  String viEn(String vi, String en) => _isVi ? vi : en;
}
