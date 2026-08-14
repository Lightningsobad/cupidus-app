import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pairing_repository.dart';
import '../joincode_cubit.dart';
import '../pairing_failure_text.dart';
import '../pairing_strings.dart';

/// `joincode` screen (`ux/uiux-spec.md` §4, §5, §9) — invitee's manual
/// code-entry path. Has header, back target `invite` (§1 — back just pops,
/// mirroring `InviteScreen`'s `onBack`); tab bar hidden (`NO_TABS`).
///
/// [onPaired] fires once `accept` succeeds (AC2, immediate — no
/// intermediate `waiting` step for the invitee). It has no default
/// navigation target: `paired_screen.dart` is a later phase (plan §3 P4) not
/// yet built, so this stays a caller-supplied seam, mirroring
/// `WaitingScreen.onPaired`.
class JoincodeScreen extends StatelessWidget {
  const JoincodeScreen({
    super.key,
    this.onPaired,
    JoincodeCubit Function()? createJoincodeCubit,
  }) : _createJoincodeCubit = createJoincodeCubit;

  final void Function(BuildContext context)? onPaired;
  final JoincodeCubit Function()? _createJoincodeCubit;

  JoincodeCubit _defaultJoincodeCubit() => JoincodeCubit(
    acceptInvitation: getIt<PairingRepository>().acceptInvitation,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoincodeCubit>(
      create: (_) => (_createJoincodeCubit ?? _defaultJoincodeCubit)(),
      child: _JoincodeView(onPaired: onPaired),
    );
  }
}

class _JoincodeView extends StatefulWidget {
  const _JoincodeView({required this.onPaired});

  final void Function(BuildContext context)? onPaired;

  @override
  State<_JoincodeView> createState() => _JoincodeViewState();
}

class _JoincodeViewState extends State<_JoincodeView> {
  final TextEditingController _codeController = TextEditingController();
  bool _pairedHandled = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final String code = _codeController.text.trim().toUpperCase();
    context.read<JoincodeCubit>().submit(code);
  }

  void _handlePairedOnce(BuildContext context) {
    if (_pairedHandled) return;
    _pairedHandled = true;
    widget.onPaired?.call(context);
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;

    return BlocConsumer<JoincodeCubit, JoincodeState>(
      listener: (context, state) {
        if (state is! JoincodeSuccess) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) _handlePairedOnce(context);
        });
      },
      builder: (context, state) {
        final bool isBusy = state is JoincodeInProgress;
        final String? errorText = state is JoincodeFailed
            ? pairingFailureMessage(context, state.failure)
            : null;

        return Scaffold(
          appBar: CupidHeader(
            title: context.viEn('Nhập mã ghép đôi', 'Enter pairing code'),
            onBack: () => Navigator.of(context).maybePop(),
            backLabel: context.viEn('Quay lại', 'Back'),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(CupidSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // A single accessible field backs the 6-character entry
                    // (§9): not six independently-focusable visual boxes.
                    TextField(
                      controller: _codeController,
                      enabled: !isBusy,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 6,
                      style: context.cupidType.labelMono.copyWith(
                        fontSize: 28,
                        letterSpacing: 8,
                        color: colors.colorText,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: context.viEn(
                          'Mã ghép đôi (6 ký tự)',
                          'Pairing code (6 characters)',
                        ),
                        // Ties the inline rejection line to the field via an
                        // accessible description, not color alone (§9),
                        // rather than a separate untethered error [Text].
                        errorText: errorText,
                        errorMaxLines: 3,
                      ),
                    ),
                    SizedBox(height: CupidSpacing.lg),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CupidPrimaryButton(
                          label: isBusy
                              ? ''
                              : context.viEn('Ghép đôi', 'Pair up'),
                          onPressed: isBusy ? null : () => _submit(context),
                        ),
                        if (isBusy)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
