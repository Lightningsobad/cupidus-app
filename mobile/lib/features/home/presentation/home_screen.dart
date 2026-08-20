import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/auth/presentation/auth_strings.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/dream_jar_list_screen.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/dream_jar_entry_card.dart';
import 'package:cupid_mobile/features/expenses/expenses_route.dart';
import 'package:cupid_mobile/features/expenses/presentation/expense_strings.dart';
import 'package:cupid_mobile/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart';
import 'package:cupid_mobile/features/timeline/presentation/screens/timeline_screen.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_cubit.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_entry_point_card.dart';
import 'package:flutter/material.dart';

import '../../vibes/presentation/vibe_screen.dart';
import '../../vibes/presentation/widgets/vibe_entry_card.dart';
import '../../reminders/presentation/reminder_strings.dart';
import '../../reminders/presentation/screens/reminder_schedule_screen.dart';
import '../../anti_ghosting/anti_ghosting.dart';
import '../../pet/presentation/widgets/pet_preview_card.dart';
import '../../love_contracts/presentation/widgets/love_contract_entry_tile.dart';

/// Design-source measurements with no `CupidSpacing` equivalent, transcribed
/// verbatim from the `isHome` block rather than rounded onto the 8pt scale
/// (same sourcing rule as `cupid_tab_bar.dart`'s `_iosTabIconSize`).
const double _heroPaddingTop = 6;
const double _heroPaddingHorizontal = 20;
const double _cardColumnPaddingHorizontal = 16;
const double _cardGap = 13;
const double _screenPaddingBottom = 30;
const double _avatarDiameter = 42;
const double _avatarRing = 2.5;
const double _avatarOverlap = -13;
const double _avatarLabelGap = 11;
const double _daysRowTopMargin = 26;
const double _daysRowGap = 11;
const double _daysUnitBaselineLift = 9;
const double _heroCaptionTopMargin = 10;
const double _milestoneTopMargin = 16;
const double _milestonePaddingHorizontal = 15;
const double _milestonePaddingVertical = 10;
const double _heroGlowDiameter = 180;
const double _heroGlowTop = -30;
const double _heroGlowRight = -40;

/// `rgba(255,127,182,.42)` — `colorAccentPink` at 42% alpha.
const int _heroGlowAlpha = 107;

/// Explicit extension override: this file transitively imports both
/// `AuthLocaleText` and `ExpenseLocaleText`, which both declare `viEn`, so a
/// bare `_viEn(context,...)` is ambiguous.
String _viEn(BuildContext context, String vi, String en) =>
    AuthLocaleText(context).viEn(vi, en);

const double _coupleNameFontSize = 15;
const double _coupleTypeFontSize = 11.5;
const double _avatarInitialFontSize = 14;
const double _daysUnitFontSize = 19;
const double _heroCaptionFontSize = 13.5;
const double _milestoneFontSize = 12.5;

/// Home dashboard (`cupid-app-design-system/project/Cupid Screens.dc.html`,
/// `isHome` block). `NO_CHROME` in that source lists `home`, so the screen
/// paints no [AppBar]; the couple-presence header below is the design's own
/// top-of-screen treatment. The bottom tab bar is owned by `AppShell`'s
/// platform-adaptive `CupidTabBar`, not by this screen.
///
/// Mounts [VibeEntryCard] as the discoverable entry point to the `vibe`
/// screen (`architecture/solution.md` §4 D-010-5); v1 passes no mood
/// snapshot so no duplicate fetch happens ahead of `VibeScreen`'s own load.
/// Additive only — no `AppShell`/tab-bar restructure (out of this phase's
/// scope).
///
/// STORY-009 P4 mounts the Synced Reminder entry card here as the feature's
/// second discoverable navigation edge (`ux/uiux-spec.md` entry-point
/// paragraph before §1.1) -- additive only, no bottom nav bar or router
/// package introduced. The pre-existing readiness `Text` below is left
/// exactly as it was.
///
/// STORY-014 P5 mounts the Dream Jar entry card here as the feature's sole
/// discoverable navigation edge (`ux/uiux-spec.md` entry-point paragraph
/// before §1.1) — no bottom nav bar or router package is introduced.
///
/// STORY-011 mounts [PetPreviewCard] as the Bun Pet feature's discoverable
/// entry point (`architecture/solution.md` §4 Boundaries And Ownership) —
/// additive only, appended after the existing entry cards.
///
/// STORY-012 mounts [TimelineEntryPointCard] (gated behind
/// [_TimelineEntryPointGate]) as the Love Timeline feature's discoverable
/// entry point, appended after the existing entry cards. [resolvePairingStatus]
/// and [createTimelineCubit] default to `getIt`-backed factories (STORY-012
/// P3/P7), matching `SplashScreen`'s `createSessionGateCubit` pattern, so this
/// screen stays testable with a fake pairing store.
///
/// STORY-015 P5 mounts [_ExpensesEntryCard] as the shared-expenses feature's
/// discoverable entry point (`ux/uiux-spec.md` entry-point paragraph before
/// §1.1; R-015.2), appended after the Timeline entry. It always navigates to
/// [ExpensesEntryPoint], which resolves the AC4 pairing gate itself -- this
/// screen does not duplicate that check.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    Future<PairingStatus> Function()? resolvePairingStatus,
    TimelineCubit Function()? createTimelineCubit,
    Future<CupidProfile> Function()? resolveProfile,
  }) :
       // ignore: prefer_initializing_formals
       _resolvePairingStatus = resolvePairingStatus,
       // ignore: prefer_initializing_formals
       _createTimelineCubit = createTimelineCubit,
       // ignore: prefer_initializing_formals
       _resolveProfile = resolveProfile;

  final Future<PairingStatus> Function()? _resolvePairingStatus;
  final TimelineCubit Function()? _createTimelineCubit;
  final Future<CupidProfile> Function()? _resolveProfile;

  static Future<PairingStatus> _defaultResolvePairingStatus() =>
      getIt<CouplePairingStore>().resolve();

  static TimelineCubit _defaultCreateTimelineCubit() =>
      TimelineCubit(getIt<TimelineRepository>());

  /// `async` so an unregistered [AccountRepository] surfaces as a failed
  /// [Future] the header can render around, not as a synchronous throw during
  /// `build` — callers that only exercise an entry card never register one.
  static Future<CupidProfile> _defaultResolveProfile() async =>
      getIt<AccountRepository>().fetchProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Wrapped in a scrollable container because each additive feature
        // story (anti-ghosting, vibe, reminders, dream jar, bun pet, love
        // contracts, timeline, ...) appends one more discoverable entry
        // card here; a fixed, non-scrolling Column overflows once enough
        // cards accumulate. No entry card's own layout changes.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _CoupleHeroHeader(
                resolveProfile: _resolveProfile ?? _defaultResolveProfile,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _cardColumnPaddingHorizontal,
                ),
                child: Column(
                  key: const Key('home_screen_ready_signal'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // STORY-008 P2: additive discoverable entry point.
                    const AntiGhostEntryCard(),
                    const SizedBox(height: _cardGap),
                    VibeEntryCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const VibeScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: _cardGap),
                    _ReminderEntryCard(
                      key: const Key('home_reminder_entry_card'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ReminderScheduleScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: _cardGap),
                    DreamJarEntryCard(
                      key: const Key('home_dream_jar_entry_card'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DreamJarListScreen(
                            repository: getIt<DreamJarRepository>(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: _cardGap),
                    const PetPreviewCard(),
                    const SizedBox(height: _cardGap),
                    const LoveContractEntryTile(),
                    _TimelineEntryPointGate(
                      resolvePairingStatus:
                          _resolvePairingStatus ?? _defaultResolvePairingStatus,
                      createTimelineCubit:
                          _createTimelineCubit ?? _defaultCreateTimelineCubit,
                    ),
                    const SizedBox(height: _cardGap),
                    _ExpensesEntryCard(
                      key: const Key('home_expenses_entry_card'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ExpensesEntryPoint(),
                        ),
                      ),
                    ),
                    const SizedBox(height: _cardGap),
                    _GalleryEntryCard(
                      key: const Key('home_gallery_entry_card'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GalleryScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _screenPaddingBottom),
            ],
          ),
        ),
      ),
    );
  }
}

/// The dashboard's couple-presence signal and days counter (`isHome` block,
/// first `<div>`): overlapping partner avatars, couple label, the Dream
/// Gradient days counter, and the next-milestone pill.
///
/// Renders nothing until the profile resolves, and nothing at all when it
/// fails — the same "resolve once per mount, hide when unavailable" shape
/// [_TimelineEntryPointGate] already uses below.
class _CoupleHeroHeader extends StatefulWidget {
  const _CoupleHeroHeader({required this.resolveProfile});

  final Future<CupidProfile> Function() resolveProfile;

  @override
  State<_CoupleHeroHeader> createState() => _CoupleHeroHeaderState();
}

class _CoupleHeroHeaderState extends State<_CoupleHeroHeader> {
  late final Future<CupidProfile> _profile = widget.resolveProfile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CupidProfile>(
      future: _profile,
      builder: (BuildContext context, AsyncSnapshot<CupidProfile> snapshot) {
        final CupidProfile? profile = snapshot.data;
        if (profile == null) {
          return const SizedBox.shrink();
        }
        return _CoupleHero(
          key: const Key('home_couple_hero'),
          profile: profile,
        );
      },
    );
  }
}

class _CoupleHero extends StatelessWidget {
  const _CoupleHero({super.key, required this.profile});

  final CupidProfile profile;

  /// The design source marks every 100th day (`247 → 300`, and the timeline
  /// card's "200-day mark"), so the next milestone is the next multiple of
  /// 100.
  static int _nextMilestone(int days) => (days ~/ 100 + 1) * 100;

  String? _coupleTypeLabel(BuildContext context) {
    switch (profile.coupleType) {
      case 'SAME_CITY':
        return _viEn(context,'Cùng thành phố', 'Same city');
      case 'LONG_DISTANCE':
        return _viEn(context,'Yêu xa', 'Long distance');
      // `LIVING_TOGETHER` and `DATING` exist in the API enum but carry no
      // label in the design source's `COUPLE_TYPES` table; the line is
      // omitted rather than given invented copy.
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final DateTime? startDate = profile.relationshipStartDate;
    final int? days = startDate == null
        ? null
        : DateTime.now().difference(startDate).inDays;
    final String? coupleType = _coupleTypeLabel(context);

    // `overflow:hidden` in the design source: the decorative glow is clipped
    // to the hero block instead of bleeding into the card column below.
    return ClipRect(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: _heroGlowTop,
            right: _heroGlowRight,
            child: IgnorePointer(
              child: Container(
                width: _heroGlowDiameter,
                height: _heroGlowDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      colors.colorAccentPink.withAlpha(_heroGlowAlpha),
                      colors.colorAccentPink.withAlpha(0),
                    ],
                    stops: const <double>[0, 0.7],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _heroPaddingHorizontal,
              _heroPaddingTop,
              _heroPaddingHorizontal,
              CupidSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _PresenceRow(
                  displayName: profile.displayName,
                  coupleTypeLabel: coupleType,
                  isPaired: profile.partnerId != null,
                ),
                if (days != null) ...<Widget>[
                  const SizedBox(height: _daysRowTopMargin),
                  _DaysCounter(days: days),
                  const SizedBox(height: _heroCaptionTopMargin),
                  Text(
                    _viEn(context,
                      'Chịu đựng nhau được $days ngày rồi, giỏi quá 🎀',
                      '$days days of putting up with each other. Proud of us 🎀',
                    ),
                    style: type.caption.copyWith(
                      fontSize: _heroCaptionFontSize,
                      color: colors.colorTextMuted,
                    ),
                  ),
                  const SizedBox(height: _milestoneTopMargin),
                  _MilestonePill(days: days, milestone: _nextMilestone(days)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlapping avatar pair plus the couple label.
///
/// The design source shows both partners' names (`Minh & Linh`), but
/// `GET /users/me` exposes only the signed-in user's `displayName` and the
/// partner's opaque `partnerId` — the partner avatar therefore renders as the
/// design's gradient disc without an initial, and the label carries the one
/// name the API does return. Closing that gap needs a partner-profile API
/// surface (see this story's visual-fidelity report).
class _PresenceRow extends StatelessWidget {
  const _PresenceRow({
    required this.displayName,
    required this.coupleTypeLabel,
    required this.isPaired,
  });

  final String? displayName;
  final String? coupleTypeLabel;
  final bool isPaired;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final String? initial = (displayName == null || displayName!.isEmpty)
        ? null
        : displayName!.substring(0, 1).toUpperCase();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: isPaired
              ? _avatarDiameter * 2 + _avatarOverlap
              : _avatarDiameter,
          height: _avatarDiameter,
          child: Stack(
            children: <Widget>[
              _Avatar(
                gradient: CouplePresencePalette.selfAvatarGradient,
                initial: initial,
              ),
              if (isPaired)
                Positioned(
                  left: _avatarDiameter + _avatarOverlap,
                  child: const _Avatar(
                    gradient: CouplePresencePalette.partnerAvatarGradient,
                    initial: null,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: _avatarLabelGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (displayName != null && displayName!.isNotEmpty)
              Text(
                displayName!,
                style: type.display.copyWith(
                  fontSize: _coupleNameFontSize,
                  fontWeight: FontWeight.w800,
                  color: colors.colorText,
                ),
              ),
            if (coupleTypeLabel != null)
              Text(
                coupleTypeLabel!,
                style: type.caption.copyWith(
                  fontSize: _coupleTypeFontSize,
                  color: colors.colorTextMuted,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.gradient, required this.initial});

  final Gradient gradient;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      width: _avatarDiameter,
      height: _avatarDiameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        border: Border.all(
          color: colors.colorBackground,
          width: _avatarRing,
        ),
        boxShadow: context.cupidPlatform.elevationShadow,
      ),
      child: initial == null
          ? null
          : Text(
              initial!,
              style: type.caption.copyWith(
                fontSize: _avatarInitialFontSize,
                fontWeight: FontWeight.w800,
                color: CouplePresencePalette.avatarInitial,
              ),
            ),
    );
  }
}

/// AC3: the days count in the §2 Display role (Nunito 900, 34pt) painted with
/// `CupidColorTokens.gradientDream`. The `isHome` prototype renders the same
/// element at 66px; §2's locked type scale is the authority the story names.
class _DaysCounter extends StatelessWidget {
  const _DaysCounter({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ShaderMask(
          key: const Key('home_days_counter'),
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) =>
              colors.gradientDream.createShader(bounds),
          child: Text(
            '$days',
            // Any opaque color works under `BlendMode.srcIn`; the gradient
            // shader replaces it. `colorText` keeps the token contract.
            style: type.display.copyWith(color: colors.colorText),
          ),
        ),
        const SizedBox(width: _daysRowGap),
        Padding(
          padding: const EdgeInsets.only(bottom: _daysUnitBaselineLift),
          child: Text(
            _viEn(context,'ngày bên nhau', 'days together'),
            style: type.display.copyWith(
              fontSize: _daysUnitFontSize,
              fontWeight: FontWeight.w800,
              color: colors.colorTextMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// "Còn 53 ngày nữa tới mốc 300" pill. The design source's leading `bedtime`
/// glyph is omitted: `CupidIcons` carries no verified codepoint for it and
/// inventing one is forbidden by that file's sourcing rule.
class _MilestonePill extends StatelessWidget {
  const _MilestonePill({required this.days, required this.milestone});

  final int days;
  final int milestone;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final int remaining = milestone - days;
    final TextStyle base = type.caption.copyWith(
      fontSize: _milestoneFontSize,
      color: colors.colorTextMuted,
    );
    final TextStyle strong = base.copyWith(
      color: colors.colorText,
      fontWeight: FontWeight.w800,
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _milestonePaddingHorizontal,
          vertical: _milestonePaddingVertical,
        ),
        decoration: BoxDecoration(
          color: colors.colorSurface,
          borderRadius: BorderRadius.circular(
            context.cupidPlatform.radiusButton,
          ),
          boxShadow: context.cupidPlatform.elevationShadow,
        ),
        child: Text.rich(
          TextSpan(
            style: base,
            children: <InlineSpan>[
              TextSpan(text: _viEn(context,'Còn ', '')),
              TextSpan(
                text: _viEn(context,'$remaining ngày', '$remaining days'),
                style: strong,
              ),
              TextSpan(
                text: _viEn(context,
                  ' nữa tới mốc $milestone',
                  ' to the $milestone mark',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Labelled, tappable affordance into [ReminderScheduleScreen]
/// (`../../coding-plan/phase-P4-entry-point-and-copy-guard.md`: "discoverable
/// navigation affordance ... not direct-route-only access"). Kept private to
/// this file since P4's write scope is `home_screen.dart` plus `app_shell.dart`
/// only -- not a new design-system or feature widget file.
class _ReminderEntryCard extends StatelessWidget {
  const _ReminderEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Material(
      color: colors.colorSurface,
      borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        child: Padding(
          padding: EdgeInsets.all(CupidSpacing.md),
          child: Row(
            children: [
              CupidIcon(
                CupidIcons.notificationsActive,
                size: 24,
                color: colors.colorText,
              ),
              SizedBox(width: CupidSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.reminderNotificationsRowTitle,
                      style: type.body.copyWith(
                        color: colors.colorText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: CupidSpacing.xs),
                    Text(
                      context.reminderNotificationsRowSubtitle,
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Labelled, tappable affordance into [ExpensesEntryPoint]
/// (`ux/uiux-spec.md` entry-point paragraph before §1.1: "discoverable
/// navigation affordance ... not direct-route-only access" -- same precedent
/// as [_ReminderEntryCard]). Kept private to this file since P5's write scope
/// is `home_screen.dart` plus the `expenses` feature files only -- not a new
/// design-system or feature widget file. Always navigable; the AC4 pairing
/// gate is resolved by [ExpensesEntryPoint] itself, not this card.
class _ExpensesEntryCard extends StatelessWidget {
  const _ExpensesEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Material(
      color: colors.colorSurface,
      borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        child: Padding(
          padding: EdgeInsets.all(CupidSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 24,
                color: colors.colorText,
              ),
              SizedBox(width: CupidSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ExpenseStrings.screenTitle(context),
                      style: type.body.copyWith(
                        color: colors.colorText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: CupidSpacing.xs),
                    Text(
                      ExpenseStrings.addActionLabel(context),
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// STORY-061 P2 (PO Decision 1, `story_master.md`): the design's 5-tab shell
/// has no Gallery slot, and `app_shell.dart`'s Gallery tab was
/// [GalleryScreen]'s only production entry point. This card replaces it in the
/// same phase that removes the tab, so the shipped epic-4 Gallery feature is
/// never left unreachable. Same private-to-this-file pattern as
/// [_ExpensesEntryCard].
class _GalleryEntryCard extends StatelessWidget {
  const _GalleryEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Material(
      color: colors.colorSurface,
      borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        child: Padding(
          padding: EdgeInsets.all(CupidSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 24,
                color: colors.colorText,
              ),
              SizedBox(width: CupidSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _viEn(context, 'Thư viện ảnh', 'Gallery'),
                      style: type.body.copyWith(
                        color: colors.colorText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: CupidSpacing.xs),
                    Text(
                      _viEn(
                        context,
                        'Khoảnh khắc hai đứa đã lưu',
                        'Moments the two of you saved',
                      ),
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resolves [PairingStatus] once per mount rather than on every rebuild --
/// calling [resolvePairingStatus] directly inside `FutureBuilder.future`
/// would hand it a fresh, never-settling [Future] on every parent rebuild.
class _TimelineEntryPointGate extends StatefulWidget {
  const _TimelineEntryPointGate({
    required this.resolvePairingStatus,
    required this.createTimelineCubit,
  });

  final Future<PairingStatus> Function() resolvePairingStatus;
  final TimelineCubit Function() createTimelineCubit;

  @override
  State<_TimelineEntryPointGate> createState() =>
      _TimelineEntryPointGateState();
}

class _TimelineEntryPointGateState extends State<_TimelineEntryPointGate> {
  late final Future<PairingStatus> _pairingStatus = widget
      .resolvePairingStatus();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PairingStatus>(
      future: _pairingStatus,
      builder: (BuildContext context, AsyncSnapshot<PairingStatus> snapshot) {
        if (snapshot.data != PairingStatus.paired) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: _cardGap),
          child: TimelineEntryPointCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    TimelineScreen(createCubit: widget.createTimelineCubit),
              ),
            ),
          ),
        );
      },
    );
  }
}
