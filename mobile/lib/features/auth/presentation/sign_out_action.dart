import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';
import 'auth_failure_text.dart';
import 'auth_strings.dart';
import 'screens/welcome_screen.dart';
import 'sign_out_confirm_dialog.dart';
import 'sign_out_cubit.dart';

/// AC4 sign-out entry point (`ux/uiux-spec.md` section 5), reusable from
/// wherever a future screen places the sign-out action (e.g. the epic-6 Me
/// screen menu item) without re-implementing the confirm + teardown +
/// navigate sequence. This story defines only the behavior, not a new
/// screen or navigation route — no destination for this widget is wired
/// into the app here.
class SignOutAction extends StatelessWidget {
  const SignOutAction({super.key, required this.authRepository, this.focusNode});

  final AuthRepository authRepository;

  /// Exposed so a caller (e.g. a settings list) can restore focus to this
  /// action after the confirm dialog closes — `showDialog`/`AlertDialog`
  /// already do this automatically (section 7 accessibility), this only
  /// lets a caller also observe/drive that same node if needed.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignOutCubit>(
      create: (_) => SignOutCubit(repository: authRepository),
      child: _SignOutListTile(
        authRepository: authRepository,
        focusNode: focusNode,
      ),
    );
  }
}

class _SignOutListTile extends StatelessWidget {
  const _SignOutListTile({required this.authRepository, this.focusNode});

  final AuthRepository authRepository;
  final FocusNode? focusNode;

  Future<void> _onTap(BuildContext context) async {
    final bool confirmed = await showSignOutConfirmDialog(context);
    if (!confirmed || !context.mounted) return;
    await context.read<SignOutCubit>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignOutCubit, SignOutState>(
      listener: (context, state) {
        if (state is SignOutSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
              builder: (_) => WelcomeScreen(authRepository: authRepository),
            ),
            (route) => false,
          );
        } else if (state is SignOutFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authFailureMessage(context, state.failure))),
          );
        }
      },
      builder: (context, state) {
        final bool isBusy = state is SignOutInProgress;
        final CupidColorTokens colors = context.cupidColors;
        return ListTile(
          focusNode: focusNode,
          enabled: !isBusy,
          leading: isBusy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.logout, color: colors.colorRed),
          title: Text(
            context.viEn('Đăng xuất', 'Log out'),
            style: context.cupidType.body.copyWith(color: colors.colorRed),
          ),
          onTap: isBusy ? null : () => _onTap(context),
        );
      },
    );
  }
}
