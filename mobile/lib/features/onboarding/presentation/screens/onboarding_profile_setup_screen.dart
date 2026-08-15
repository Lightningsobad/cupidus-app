import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../account/domain/cupid_profile.dart';
import '../../../account/domain/zodiac.dart';
import '../widgets/zodiac_glyph.dart';

/// `photo_camera` glyph, confirmed in the bundled
/// `MaterialSymbolsRounded-Variable.ttf` cmap at 0xe412, and `person` at
/// 0xe7fd. Declared file-locally because `design_system/icons/` is outside
/// this story's write scope.
const IconData _iconPhotoCamera = IconData(
  0xe412,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _iconPerson = IconData(0xe7fd, fontFamily: CupidIcons.fontFamily);

/// Geometry transcribed from the locked design source's `profile` canvas
/// (`cupid-app-design-system/project/Cupid Screens.dc.html` lines 93-118). No
/// spacing token covers these values, so they follow the
/// `CupidPrimaryButton._materialPrimaryCtaRadius` precedent of transcribing
/// the design value rather than inventing a token.
const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(20, 22, 20, 40);
const double _sectionGap = 22;
const double _cardGap = 12;
const double _avatarDiameter = 104;
const double _avatarCaptionGap = 12;
const double _avatarBadgeDiameter = 36;
const double _avatarBadgeRingWidth = 3;
const double _avatarBadgeIconSize = 19;
const double _avatarBadgeRightOffset = -10;
const double _avatarBadgeBottomOffset = -6;
const EdgeInsets _cardPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 14,
);
const double _cardLabelGap = 5;

/// `letter-spacing:.06em` on the canvas' 11px card labels.
const double _cardLabelLetterSpacing = 0.66;
const EdgeInsets _zodiacChipPadding = EdgeInsets.fromLTRB(5, 5, 12, 5);
const double _zodiacChipGap = 7;
const double _zodiacGlyphSize = 26;
const double _zodiacHelperGap = 8;

/// The canvas draws this inline helper at 11.5px, smaller than the 13px
/// `caption` sub-copy role. Stated here so the helper keeps its single line
/// without re-pointing the shared token (REQ-002/STORY-033 AC3).
const double _zodiacHelperFontSize = 11.5;
const double _languageChevronSize = 20;
const double _ctaHeight = 52;

/// Rendered when a nullable backend field has no value. Not a design state:
/// `register_screen.dart` only ever sets `displayName`, so `birthday` really
/// can be null at this point in the onboarding chain.
const String _emptyValue = '—';

/// Onboarding profile-setup step — canvas `profile`
/// (`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/
/// STORY-010_onboarding_profile_design_fidelity/coding-plan/master-plan.md`
/// D1). Deliberately distinct from `ProfileEditScreen`, which is the Me-hub's
/// editable surface: this screen only renders what the canvas authors, so it
/// takes an already-fetched [profile] and performs no I/O (D4/D5).
///
/// [onContinue] is required rather than nullable so the CTA can never render
/// greyed out. This story supplies no destination — STORY-002 owns wiring the
/// screen into the onboarding chain (D6).
class OnboardingProfileSetupScreen extends StatelessWidget {
  const OnboardingProfileSetupScreen({
    super.key,
    required this.profile,
    required this.onContinue,
  });

  final CupidProfile profile;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final DateTime? birthday = profile.birthday;

    return Scaffold(
      backgroundColor: colors.colorBackground,
      appBar: CupidHeader(
        title: context.viEn('Hồ sơ của bạn', 'Your profile'),
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: context.viEn('Quay lại', 'Back'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: _bodyPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _AvatarBlock(photoUrl: profile.photoUrl),
              const SizedBox(height: _sectionGap),
              _FieldCard(
                label: context.viEn('Tên gọi', 'Display name'),
                child: _FieldValue(profile.displayName ?? _emptyValue),
              ),
              const SizedBox(height: _cardGap),
              _FieldCard(
                label: context.viEn('Ngày sinh', 'Date of birth'),
                child: _BirthdayValue(birthday: birthday),
              ),
              const SizedBox(height: _cardGap),
              _FieldCard(
                label: context.viEn('Ngôn ngữ', 'Language'),
                // Inert: the canvas puts no `onClick` on this card, so the
                // chevron is a visual affordance only.
                trailing: CupidIcon(
                  CupidIcons.chevronRight,
                  size: _languageChevronSize,
                  color: colors.colorTextMuted,
                ),
                child: _FieldValue(_languageLabel(profile.language)),
              ),
              const SizedBox(height: _sectionGap),
              _ContinueCta(onPressed: onContinue),
            ],
          ),
        ),
      ),
    );
  }
}

/// The canvas' `langLabel`. An unknown code shows verbatim rather than
/// guessing a display name.
String _languageLabel(String code) => switch (code) {
  'vi' => 'Tiếng Việt',
  'en' => 'English',
  _ => code,
};

class _AvatarBlock extends StatelessWidget {
  const _AvatarBlock({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

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
                // The canvas' `<image-slot>` "drop an image" chrome is
                // authoring tooling, not product design, so the empty state
                // uses the app's own person glyph.
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
                // The canvas gives the badge `cursor:pointer` but no
                // `onClick`; hidden from a11y so it is never announced as a
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
        const SizedBox(height: _avatarCaptionGap),
        Text(
          context.viEn(
            'Ảnh sẽ được crop tròn',
            'Photo is cropped to a circle',
          ),
          style: type.caption.copyWith(color: colors.colorTextMuted),
        ),
      ],
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.label, required this.child, this.trailing});

  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final Widget labelAndValue = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: type.caption.copyWith(
            color: colors.colorTextMuted,
            letterSpacing: _cardLabelLetterSpacing,
          ),
        ),
        const SizedBox(height: _cardLabelGap),
        child,
      ],
    );

    return Container(
      padding: _cardPadding,
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: trailing == null
          ? labelAndValue
          : Row(
              children: <Widget>[
                Expanded(child: labelAndValue),
                trailing!,
              ],
            ),
    );
  }
}

class _FieldValue extends StatelessWidget {
  const _FieldValue(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Text(
      value,
      style: context.cupidType.body.copyWith(
        color: colors.colorText,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _BirthdayValue extends StatelessWidget {
  const _BirthdayValue({required this.birthday});

  final DateTime? birthday;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _FieldValue(
                birthday == null
                    ? _emptyValue
                    : DateFormat('dd/MM/yyyy').format(birthday!),
              ),
            ),
            // The canvas has no zodiac chip to show without a birthday.
            if (birthday != null) _ZodiacChip(birthday: birthday!),
          ],
        ),
        const SizedBox(height: _zodiacHelperGap),
        Text(
          context.viEn(
            'Cung hoàng đạo tính tự động — dùng cho Zodiac Red Flag.',
            'Zodiac is auto-derived — powers Zodiac Red Flag.',
          ),
          style: type.caption.copyWith(
            color: colors.colorTextMuted,
            fontSize: _zodiacHelperFontSize,
          ),
        ),
      ],
    );
  }
}

/// Derives the sign from [birthday] rather than reading
/// `CupidProfile.zodiacSign`, so the chip and its "tính tự động" helper text
/// can never disagree.
class _ZodiacChip extends StatelessWidget {
  const _ZodiacChip({required this.birthday});

  final DateTime birthday;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final String sign = zodiacSignFor(birthday);

    return Container(
      padding: _zodiacChipPadding,
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platformTokens.radiusButton),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ZodiacGlyph(sign: sign, size: _zodiacGlyphSize),
          const SizedBox(width: _zodiacChipGap),
          Text(
            zodiacGlyphSpecFor(sign).label(isVi: context.isVi),
            style: type.caption.copyWith(
              color: colors.colorText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Built locally instead of using [CupidPrimaryButton]: that widget renders a
/// flat `colorAccentPink` fill at a 20dp Material radius with `body` weight,
/// while this canvas authors a `--grad-hot` gradient pill (`--r-btn:999px`)
/// with a glow and 700 weight. Changing the shared button would move every
/// other screen's CTA, so the deviation is absorbed here.
class _ContinueCta extends StatelessWidget {
  const _ContinueCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final BorderRadius radius = BorderRadius.circular(
      context.cupidPlatform.radiusButton,
    );

    return Container(
      height: _ctaHeight,
      decoration: BoxDecoration(
        gradient: colors.gradientHot,
        borderRadius: radius,
        boxShadow: colors.glowShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Center(
            child: Text(
              context.viEn(
                'Tiếp tục → Love Contract',
                'Continue → Love Contract',
              ),
              style: type.body.copyWith(
                color: colors.colorText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// vi/en copy transcribed from the locked design canvas, resolved from the
/// ambient [Locale] — the same file-local pattern as `invite_screen.dart`'s
/// `_InviteLocaleText`. Not added to the ARB files: those are a shared
/// cross-story surface in this parallel wave.
extension _ProfileSetupLocaleText on BuildContext {
  bool get isVi => Localizations.localeOf(this).languageCode == 'vi';

  String viEn(String vi, String en) => isVi ? vi : en;
}
