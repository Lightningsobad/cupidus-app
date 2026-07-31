import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../adopt_cubit.dart';
import '../adopt_state.dart';
import '../pet_cubit.dart';
import '../pet_strings.dart';
import 'species_picker.dart';

/// Opens the adopt bottom sheet (`ux/uiux-spec.md` §2.2 item 2, §6, §8):
/// content-height sheet using `CupidPlatformTokens.radiusSheet`, no new sheet
/// variant. `showModalBottomSheet` already traps focus within the sheet and
/// returns it to the triggering control on pop/cancel (§7) — the same
/// framework-default reliance already codified for `showDialog` in
/// `sign_out_confirm_dialog.dart` — so no extra focus handling is added here.
///
/// [context] must have a `PetCubit` ancestor (`PetScreen` provides one): it is
/// captured before the sheet route is pushed so `AdoptSucceeded` can trigger a
/// reload without the sheet's own (sibling, not descendant) route subtree
/// needing its own `PetCubit` lookup.
Future<void> showAdoptSheet(
  BuildContext context, {
  required AdoptCubit cubit,
}) {
  final PetCubit petCubit = context.read<PetCubit>();
  final CupidColorTokens colors = context.cupidColors;
  final CupidPlatformTokens platformTokens = context.cupidPlatform;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.colorSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(platformTokens.radiusSheet),
      ),
    ),
    builder: (sheetContext) => MultiBlocProvider(
      providers: [
        BlocProvider<AdoptCubit>.value(value: cubit),
        BlocProvider<PetCubit>.value(value: petCubit),
      ],
      child: const _AdoptSheetContent(),
    ),
  );
}

class _AdoptSheetContent extends StatefulWidget {
  const _AdoptSheetContent();

  @override
  State<_AdoptSheetContent> createState() => _AdoptSheetContentState();
}

class _AdoptSheetContentState extends State<_AdoptSheetContent> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdoptCubit, AdoptState>(
      listener: (context, state) {
        // AC: success dismisses the sheet and reloads the underlying
        // `PetCubit` so `PetScreen` swaps to the new pet's hero card.
        if (state is AdoptSucceeded) {
          context.read<PetCubit>().load();
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: CupidSpacing.lg,
            right: CupidSpacing.lg,
            top: CupidSpacing.lg,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + CupidSpacing.lg,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _bodyFor(context, state),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _bodyFor(BuildContext context, AdoptState state) {
    return switch (state) {
      AdoptEditing() => _editingBody(context, state),
      AdoptSubmitting() => _submittingBody(context),
      // The `listener` above pops the sheet synchronously on the same state
      // change, so this branch never actually paints.
      AdoptSucceeded() => const <Widget>[SizedBox.shrink()],
      AdoptConflict() => _conflictBody(context, state),
      AdoptRejectedNotYet() => _rejectedBody(context),
      AdoptFailed() => _failedBody(context, state),
    };
  }

  List<Widget> _editingBody(BuildContext context, AdoptEditing state) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return <Widget>[
      Semantics(
        header: true,
        child: Text(
          context.viEn('Nhận nuôi Bún', 'Adopt a Bun'),
          style: type.cardTitle.copyWith(color: colors.colorText),
        ),
      ),
      SizedBox(height: CupidSpacing.md),
      SpeciesPicker(
        selected: state.species,
        onSelected: (species) =>
            context.read<AdoptCubit>().selectSpecies(species),
      ),
      SizedBox(height: CupidSpacing.md),
      TextField(
        controller: _nameController,
        style: TextStyle(color: colors.colorText),
        decoration: InputDecoration(
          labelText: context.viEn('Tên Bún', "Bun's name"),
        ),
        onChanged: (value) => context.read<AdoptCubit>().nameChanged(value),
      ),
      SizedBox(height: CupidSpacing.md),
      CupidPrimaryButton(
        label: context.petAdoptCta,
        onPressed: state.isValid
            ? () => context.read<AdoptCubit>().submit()
            : null,
      ),
    ];
  }

  List<Widget> _submittingBody(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    return <Widget>[
      Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: CupidSpacing.xl),
          child: CircularProgressIndicator(color: colors.colorAccentPink),
        ),
      ),
    ];
  }

  List<Widget> _conflictBody(BuildContext context, AdoptConflict state) {
    final String headline = state.existingName != null
        ? context.viEn(
            'Bạn đã có Bún rồi, đón chào ${state.existingName}!',
            'You already have a Bun — say hi to ${state.existingName}!',
          )
        : context.viEn('Bạn đã có Bún rồi!', 'You already have a Bun!');
    return _messageBody(
      context,
      headline: headline,
      buttonLabel: context.viEn('Xong', 'Done'),
      onDone: () {
        context.read<PetCubit>().load();
        Navigator.of(context).pop();
      },
    );
  }

  List<Widget> _rejectedBody(BuildContext context) {
    // AC: no HTTP status, no error icon, and no computed countdown
    // (`architecture/solution.md` D3) — a friendly "not yet" line only.
    return _messageBody(
      context,
      headline: context.viEn(
        'Chưa đủ điều kiện nhận nuôi lúc này. Thử lại sau nhé.',
        "Not quite ready to adopt yet. Please try again later.",
      ),
      buttonLabel: context.viEn('Đóng', 'Close'),
      onDone: () => Navigator.of(context).pop(),
    );
  }

  List<Widget> _failedBody(BuildContext context, AdoptFailed state) {
    return _messageBody(
      context,
      headline: _adoptFailureMessage(context, state.failure),
      buttonLabel: context.viEn('Đóng', 'Close'),
      onDone: () => Navigator.of(context).pop(),
    );
  }

  List<Widget> _messageBody(
    BuildContext context, {
    required String headline,
    required String buttonLabel,
    required VoidCallback onDone,
  }) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    return <Widget>[
      Text(
        headline,
        textAlign: TextAlign.center,
        style: type.body.copyWith(color: colors.colorText),
      ),
      SizedBox(height: CupidSpacing.md),
      CupidPrimaryButton(label: buttonLabel, onPressed: onDone),
    ];
  }
}

/// Maps the closed `CupidApiFailure` set to one short user-facing line, local
/// to this file for the same reason as `pet_screen.dart`'s own
/// `_petFailureMessage` (`pet_strings.dart` is outside this phase's write
/// scope).
String _adoptFailureMessage(BuildContext context, Object failure) {
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
