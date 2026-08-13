import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/cupid_api_failure.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../data/account_repository.dart';
import '../../domain/cupid_profile.dart';
import '../profile_edit_cubit.dart';

/// `photo_camera` glyph, confirmed in the bundled
/// `MaterialSymbolsRounded-Variable.ttf` cmap at 0xe412 (0xe3b0 aliases to
/// the identical glyph), and `person` at 0xe7fd. Declared file-locally
/// because `design_system/icons/` is outside this story's write scope.
const IconData _iconPhotoCamera = IconData(
  0xe412,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _iconPerson = IconData(
  0xe7fd,
  fontFamily: CupidIcons.fontFamily,
);

/// Avatar slot geometry transcribed verbatim from the locked design source's
/// `profile` canvas (`cupid-app-design-system` "Cupid Screens", `isProfile`
/// block): a 104px circle carrying the camera badge at `right:-10px;
/// bottom:-6px`, the badge itself 36px with a 3px background-colored ring and
/// a 19px glyph. No spacing token covers these, so they follow the
/// `CupidPrimaryButton._materialPrimaryCtaRadius` precedent of transcribing
/// the design value rather than inventing a token.
const double _avatarDiameter = 104;
const double _avatarBadgeDiameter = 36;
const double _avatarBadgeRingWidth = 3;
const double _avatarBadgeIconSize = 19;
const double _avatarBadgeRightOffset = -10;
const double _avatarBadgeBottomOffset = -6;

/// `profile edit` sub-screen (`coding-plan/master-plan.md` §6.2 P2,
/// `ux/uiux-spec.md` §3). Avatar renders read-only from `photoUrl`; the
/// camera badge is inert, the option §6.2 P2 sanctions until P3 wires
/// upload ("the camera badge is either absent or inert until P3").
class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({
    super.key,
    required this.accountRepository,
    required this.profile,
  });

  final AccountRepository accountRepository;
  final CupidProfile profile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileEditCubit>(
      create: (_) =>
          ProfileEditCubit(repository: accountRepository, profile: profile),
      child: _ProfileEditView(photoUrl: profile.photoUrl),
    );
  }
}

class _ProfileEditView extends StatefulWidget {
  const _ProfileEditView({required this.photoUrl});

  final String? photoUrl;

  @override
  State<_ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<_ProfileEditView> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final ProfileEditState initial = context.read<ProfileEditCubit>().state;
    _nameController = TextEditingController(text: initial.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null && context.mounted) {
      context.read<ProfileEditCubit>().birthdayChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    String pad2(int value) => value.toString().padLeft(2, '0');
    return '${pad2(date.day)}/${pad2(date.month)}/${date.year}';
  }

  String? _submitFailureMessage(AppL10n l10n, Object? failure) {
    if (failure == null) return null;
    return switch (failure) {
      NetworkUnavailableFailure() || TimeoutFailure() =>
        l10n.account_error_network,
      _ => l10n.account_error_generic,
    };
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return BlocConsumer<ProfileEditCubit, ProfileEditState>(
      listenWhen: (previous, current) => current.submittedProfile != null,
      listener: (context, state) {
        Navigator.of(context).pop(state.submittedProfile);
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.colorBackground,
          appBar: CupidHeader(
            title: l10n.profile_edit_title,
            onBack: () => Navigator.of(context).maybePop(),
            backLabel: l10n.me_hub_title,
            actions: <Widget>[
              TextButton(
                onPressed: (state.isSubmitting || !state.isDirty)
                    ? null
                    : () => context.read<ProfileEditCubit>().submit(),
                child: Text(
                  l10n.profile_edit_save,
                  style: type.body.copyWith(
                    color: state.isDirty
                        ? colors.colorAccentPink
                        : colors.colorTextMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(CupidSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _AvatarSlot(photoUrl: widget.photoUrl),
                  SizedBox(height: CupidSpacing.lg),
                  _FieldCard(
                    label: l10n.profile_edit_name_label,
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                    child: TextField(
                      controller: _nameController,
                      onChanged: (value) =>
                          context.read<ProfileEditCubit>().nameChanged(value),
                      style: type.body.copyWith(
                        color: colors.colorText,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (state.showNameError) ...<Widget>[
                    SizedBox(height: CupidSpacing.xs),
                    Text(
                      l10n.profile_edit_name_error,
                      style: type.caption.copyWith(color: colors.colorRed),
                    ),
                  ],
                  SizedBox(height: CupidSpacing.sm),
                  _FieldCard(
                    label: l10n.profile_edit_dob_label,
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                    onTap: () => _pickDate(context, state.birthday),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                state.birthday == null
                                    ? '—'
                                    : _formatDate(state.birthday!),
                                style: type.body.copyWith(
                                  color: colors.colorText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (state.zodiacSign != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: CupidSpacing.sm,
                                  vertical: CupidSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.colorSurfaceAlt,
                                  borderRadius: BorderRadius.circular(
                                    platformTokens.radiusButton,
                                  ),
                                ),
                                child: Text(
                                  state.zodiacSign!,
                                  style: type.caption.copyWith(
                                    color: colors.colorText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: CupidSpacing.sm),
                        Text(
                          l10n.profile_edit_zodiac_helper,
                          style: type.caption.copyWith(
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.showDobError) ...<Widget>[
                    SizedBox(height: CupidSpacing.xs),
                    Text(
                      l10n.profile_edit_dob_error,
                      style: type.caption.copyWith(color: colors.colorRed),
                    ),
                  ],
                  if (state.submitFailure != null) ...<Widget>[
                    SizedBox(height: CupidSpacing.md),
                    Text(
                      _submitFailureMessage(l10n, state.submitFailure)!,
                      style: type.caption.copyWith(color: colors.colorRed),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Avatar block of the design source's `profile` canvas: a circular slot, the
/// camera badge overhanging its lower-right, and the crop caption below.
///
/// The design source fills the slot with `<image-slot>`, which is the
/// authoring tool's own drag-and-drop scaffold (`image-slot.js` opens with
/// `@ds-adherence-ignore -- omelette starter scaffold`), so only its rendered
/// frame — 104px, circle-cropped, `--shadow` — is product design. Its empty
/// "drop an image" chrome is canvas tooling and is replaced here by the app's
/// own person-glyph placeholder.
class _AvatarSlot extends StatelessWidget {
  const _AvatarSlot({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final bool isVi = Localizations.localeOf(context).languageCode == 'vi';

    return Column(
      children: <Widget>[
        SizedBox(
          width: _avatarDiameter,
          height: _avatarDiameter,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: _avatarDiameter,
                height: _avatarDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.colorSurfaceAlt,
                  boxShadow: platformTokens.elevationShadow,
                  image: photoUrl == null
                      ? null
                      : DecorationImage(
                          image: NetworkImage(photoUrl!),
                          fit: BoxFit.cover,
                        ),
                ),
                child: photoUrl == null
                    ? Center(
                        child: CupidIcon(
                          _iconPerson,
                          size: _avatarDiameter / 2,
                          color: colors.colorTextMuted,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: _avatarBadgeRightOffset,
                bottom: _avatarBadgeBottomOffset,
                // Inert per `coding-plan/master-plan.md` §6.2 P2 until upload
                // lands in P3; hidden from a11y so it is never announced as a
                // button that does nothing.
                child: ExcludeSemantics(
                  child: Container(
                    width: _avatarBadgeDiameter,
                    height: _avatarBadgeDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: colors.gradientHot,
                      border: Border.all(
                        color: colors.colorBackground,
                        width: _avatarBadgeRingWidth,
                      ),
                      boxShadow: colors.glowShadow,
                    ),
                    child: Center(
                      child: CupidIcon(
                        _iconPhotoCamera,
                        size: _avatarBadgeIconSize,
                        color: colors.colorText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: CupidSpacing.sm),
        Text(
          isVi ? 'Ảnh sẽ được crop tròn' : 'Photo is cropped to a circle',
          style: type.caption.copyWith(color: colors.colorTextMuted),
        ),
      ],
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.label,
    required this.child,
    required this.colors,
    required this.type,
    required this.platformTokens,
    this.onTap,
  });

  final String label;
  final Widget child;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: type.caption.copyWith(
              color: colors.colorTextMuted,
              letterSpacing: 0.6,
            ),
          ),
          SizedBox(height: CupidSpacing.xs),
          child,
        ],
      ),
    );
    return onTap == null
        ? content
        : InkWell(
            borderRadius: BorderRadius.circular(platformTokens.radiusCard),
            onTap: onTap,
            child: content,
          );
  }
}
