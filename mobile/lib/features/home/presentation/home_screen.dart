import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/data/notification_preferences_store.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/account/presentation/screens/notification_settings_screen.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_hub_view.dart';
import 'package:cupid_mobile/features/auth/presentation/auth_strings.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/dream_jar_list_screen.dart';
import 'package:cupid_mobile/features/pet/data/pet_repository.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart';
import 'package:cupid_mobile/features/timeline/presentation/screens/timeline_screen.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_cubit.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_countdown_card.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_entry_point_card.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../vibes/presentation/vibe_cubit.dart';
import '../../vibes/presentation/vibe_screen.dart';
import '../../vibes/presentation/widgets/vibe_entry_card.dart';
import '../../reminders/presentation/reminder_strings.dart';
import '../../reminders/presentation/screens/reminder_schedule_screen.dart';
import '../../anti_ghosting/anti_ghosting.dart';
import '../../pet/presentation/widgets/pet_preview_card.dart';
import '../../zodiac/presentation/zodiac_red_flag_screen.dart';
import 'widgets/themed_days_counter_nurture.dart';

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

/// Hero header actions group, `Cupid Screens.dc.html` lines 248-249 via
/// `ux/uiux-spec.md` §1: `height:38px`, glyph `font-size:23px`, `gap:2px`.
/// Off the `CupidSpacing` scale and kept literal, same rule as the constants
/// around it — `2` must not be rounded up to `CupidSpacing.xs` (4).
const double _headerActionHeight = 38;
const double _headerActionIconSize = 23;
const double _headerActionGap = 2;
const double _daysUnitBaselineLift = 9;
const double _heroCaptionTopMargin = 10;
const double _milestoneTopMargin = 16;
const double _milestonePaddingHorizontal = 15;
const double _milestonePaddingVertical = 10;
const double _heroGlowDiameter = 180;
const double _heroGlowTop = -30;
const double _heroGlowRight = -40;
const double _headerActionNotificationIconSize = 24;
const double _headerActionDotDiameter = 8;
const double _headerActionDotTop = 4;
const double _headerActionDotRight = 1;
const double _headerActionDotGlowBlur = 9;

/// Quick-grid tile geometry, transcribed verbatim from the design source's
/// `isHome` grid block (`Cupid Screens.dc.html:305-312`) via `ux/ux-spec.md`
/// §3: `gap:12px`, `padding:16px`, a `38x38` icon plate at `alpha .2` holding
/// a `22px` glyph, then `11px`, a `14px/800` title, `3px`, an `11.5px`
/// subtitle. Off the `CupidSpacing` scale and kept literal, same rule as the
/// constants above.
const double _quickGridGap = 12;
const double _quickGridTilePadding = 16;
const double _quickGridIconBoxSize = 38;
const double _quickGridIconSize = 22;
const double _quickGridIconBoxAlpha = 0.2;
const double _quickGridIconTitleGap = 11;
const double _quickGridTitleSubtitleGap = 3;
const double _quickGridTitleFontSize = 14;
const double _quickGridSubtitleFontSize = 11.5;

/// Same literal in `vi` and `en`, mirroring `zodiac_red_flag_screen.dart:40-42`
/// — the design source's locale maps carry one `t_zodiac` string, so this tile
/// must not introduce a translated l10n key.
const String _zodiacTileTitle = 'Zodiac Red Flag';

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
    Future<bool> Function()? resolveNotificationsUnconfigured,
    PetRepository? petRepository,
    ActivityCardRepository? activityCardRepository,
  }) :
       // ignore: prefer_initializing_formals
       _activityCardRepository = activityCardRepository,
       // ignore: prefer_initializing_formals
       _resolvePairingStatus = resolvePairingStatus,
       // ignore: prefer_initializing_formals
       _createTimelineCubit = createTimelineCubit,
       // ignore: prefer_initializing_formals
       _resolveProfile = resolveProfile,
       // ignore: prefer_initializing_formals
       _resolveNotificationsUnconfigured = resolveNotificationsUnconfigured,
       // ignore: prefer_initializing_formals
       _petRepository = petRepository;

  final Future<PairingStatus> Function()? _resolvePairingStatus;
  final TimelineCubit Function()? _createTimelineCubit;
  final Future<CupidProfile> Function()? _resolveProfile;
  final Future<bool> Function()? _resolveNotificationsUnconfigured;

  /// STORY-003: hands [PetPreviewCard] a fixture repository so the
  /// design-fidelity capture harness can photograph the `PetReady` variant
  /// instead of the unauthenticated load-failure state. Omitted everywhere
  /// else, leaving the card's own `getIt<PetRepository>()` lookup untouched.
  final PetRepository? _petRepository;

  /// REQ-016 STORY-001 P4: same fixture seam as [_petRepository], so an
  /// entry-point test can render the solo hub without a composition root.
  final ActivityCardRepository? _activityCardRepository;

  static Future<PairingStatus> _defaultResolvePairingStatus() =>
      getIt<CouplePairingStore>().resolve();

  static TimelineCubit _defaultCreateTimelineCubit() =>
      TimelineCubit(getIt<TimelineRepository>());

  /// `async` so an unregistered [AccountRepository] surfaces as a failed
  /// [Future] the header can render around, not as a synchronous throw during
  /// `build` — callers that only exercise an entry card never register one.
  static Future<CupidProfile> _defaultResolveProfile() async =>
      getIt<AccountRepository>().fetchProfile();

  /// AC3's "unconfigured" signal: the signed-in user has never saved a choice
  /// on the Notifications screen. Device-local read of state the Notifications
  /// feature already keeps — no new tracking system, no network call.
  static Future<bool> _defaultResolveNotificationsUnconfigured() async =>
      !await getIt<NotificationPreferencesStore>().hasStoredPreferences();

  @override
  Widget build(BuildContext context) {
    return _SoloHomeGate(
      resolvePairingStatus:
          _resolvePairingStatus ?? _defaultResolvePairingStatus,
      soloBuilder: (BuildContext context) => _SoloStageOneShell(
        muonLamBuilder: (BuildContext context) =>
            ActivityCardHubView(repository: _activityCardRepository),
      ),
      coupleBuilder: _buildCoupleHome,
    );
  }

  /// The couple dashboard exactly as it was before REQ-016 STORY-001 P4 —
  /// the solo branch is added beside it, never inside it.
  Widget _buildCoupleHome(BuildContext context) {
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
                resolveNotificationsUnconfigured:
                    _resolveNotificationsUnconfigured ??
                    _defaultResolveNotificationsUnconfigured,
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
                    VibeEntryCard(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const VibeScreen(),
                          ),
                        );
                        if (getIt.isRegistered<VibeCubit>()) {
                          getIt<VibeCubit>().refresh();
                        }
                      },
                    ),
                    const SizedBox(height: _cardGap),
                    PetPreviewCard(repository: _petRepository),
                    const SizedBox(height: _cardGap),
                    const _QuickGridRow(),
                    _TimelineEntryPointGate(
                      resolvePairingStatus:
                          _resolvePairingStatus ?? _defaultResolvePairingStatus,
                      createTimelineCubit:
                          _createTimelineCubit ?? _defaultCreateTimelineCubit,
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

/// The four destinations of the stage-1 solo surface (AC-22, D-3), in the
/// order `ux/uiux-spec.md` §1 draws them. [muonLam] is first, is the default,
/// and is the activity-card hub; the other three are navigation shells this
/// story owns and later stories fill, and none of them may become a second
/// card store (AC-21/SC-1').
enum SoloStageOneTab { muonLam, yTuong, soTay, nhatKy }

/// The tab bar that replaces the app shell's on the solo surface. Only the
/// solo branch mounts it — the paired branch keeps the existing shell.
class _SoloStageOneShell extends StatefulWidget {
  const _SoloStageOneShell({required this.muonLamBuilder});

  final WidgetBuilder muonLamBuilder;

  @override
  State<_SoloStageOneShell> createState() => _SoloStageOneShellState();
}

class _SoloStageOneShellState extends State<_SoloStageOneShell> {
  SoloStageOneTab _tab = SoloStageOneTab.muonLam;

  static const Map<SoloStageOneTab, IconData> _icons =
      <SoloStageOneTab, IconData>{
        SoloStageOneTab.muonLam: CupidIcons.checkCircle,
        SoloStageOneTab.yTuong: CupidIcons.autoAwesome,
        SoloStageOneTab.soTay: CupidIcons.draw,
        SoloStageOneTab.nhatKy: CupidIcons.schedule,
      };

  String _label(BuildContext context, SoloStageOneTab tab) {
    final bool vi = Localizations.localeOf(context).languageCode == 'vi';
    switch (tab) {
      case SoloStageOneTab.muonLam:
        return vi ? 'Muốn làm' : 'To do';
      case SoloStageOneTab.yTuong:
        return vi ? 'Ý tưởng' : 'Ideas';
      case SoloStageOneTab.soTay:
        return vi ? 'Sổ tay' : 'Notebook';
      case SoloStageOneTab.nhatKy:
        return vi ? 'Nhật ký' : 'Journal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('solo_stage_one_shell'),
      body: IndexedStack(
        index: _tab.index,
        children: <Widget>[
          for (final SoloStageOneTab tab in SoloStageOneTab.values)
            if (tab == SoloStageOneTab.muonLam)
              widget.muonLamBuilder(context)
            else
              _SoloTabPlaceholder(tab: tab, label: _label(context, tab)),
        ],
      ),
      bottomNavigationBar: CupidTabBar(
        key: const Key('solo_stage_one_tab_bar'),
        currentIndex: _tab.index,
        onTap: (int index) =>
            setState(() => _tab = SoloStageOneTab.values[index]),
        items: <CupidTabBarItem>[
          for (final SoloStageOneTab tab in SoloStageOneTab.values)
            CupidTabBarItem(
              icon: _icons[tab]!,
              label: _label(context, tab),
            ),
        ],
      ),
    );
  }
}

/// A tab this story only frames. It uses the same neutral "sắp có" answer
/// `ux/uiux-spec.md` §6 prescribes for an entry point whose owning story has
/// not shipped, so the destination is reachable and is never a dead end.
class _SoloTabPlaceholder extends StatelessWidget {
  const _SoloTabPlaceholder({required this.tab, required this.label});

  final SoloStageOneTab tab;
  final String label;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final bool vi = Localizations.localeOf(context).languageCode == 'vi';

    return Center(
      key: Key('solo_tab_placeholder_${tab.name}'),
      child: Text(
        vi ? '$label — sắp có' : '$label — coming soon',
        style: context.cupidType.body.copyWith(color: colors.colorTextMuted),
      ),
    );
  }
}

/// REQ-016 STORY-001 P4 entry point (AC-22): an unpaired session gets the
/// stage-1 solo surface — its own four-item tab bar with the activity-card hub
/// as the default "Muốn làm" tab — instead of the couple dashboard. Every
/// other pairing outcome (`paired`, `unknown`, still pending, failed) keeps the
/// existing dashboard and the existing app shell, so a paired session never
/// flashes the solo surface. Resolves once per mount, the same shape
/// [_TimelineEntryPointGate] already uses.
class _SoloHomeGate extends StatefulWidget {
  const _SoloHomeGate({
    required this.resolvePairingStatus,
    required this.soloBuilder,
    required this.coupleBuilder,
  });

  final Future<PairingStatus> Function() resolvePairingStatus;
  final WidgetBuilder soloBuilder;
  final WidgetBuilder coupleBuilder;

  @override
  State<_SoloHomeGate> createState() => _SoloHomeGateState();
}

class _SoloHomeGateState extends State<_SoloHomeGate> {
  late final Future<PairingStatus> _pairingStatus =
      widget.resolvePairingStatus();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PairingStatus>(
      future: _pairingStatus,
      builder:
          (BuildContext context, AsyncSnapshot<PairingStatus> snapshot) {
            if (snapshot.data == PairingStatus.unpaired) {
              return widget.soloBuilder(context);
            }
            return widget.coupleBuilder(context);
          },
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
  const _CoupleHeroHeader({
    required this.resolveProfile,
    required this.resolveNotificationsUnconfigured,
  });

  final Future<CupidProfile> Function() resolveProfile;
  final Future<bool> Function() resolveNotificationsUnconfigured;

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
          resolveNotificationsUnconfigured:
              widget.resolveNotificationsUnconfigured,
        );
      },
    );
  }
}

class _CoupleHero extends StatelessWidget {
  const _CoupleHero({
    super.key,
    required this.profile,
    required this.resolveNotificationsUnconfigured,
  });

  final CupidProfile profile;
  final Future<bool> Function() resolveNotificationsUnconfigured;

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
        : TimelineCountdown.since(startDate, now: DateTime.now()).daysTogether;
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: _PresenceRow(
                        displayName: profile.displayName,
                        photoUrl: profile.photoUrl,
                        partnerDisplayName: profile.partnerDisplayName,
                        partnerPhotoUrl: profile.partnerPhotoUrl,
                        coupleTypeLabel: coupleType,
                        isPaired: profile.partnerId != null,
                      ),
                    ),
                    _HeaderActionsRow(
                      actions: <Widget>[
                        // No shareable value means no share affordance
                        // (`ux/uiux-spec.md` §2) — the same `days != null`
                        // gate the counter block below already uses.
                        if (days != null)
                          _ShareDaysAction(
                            key: const Key('home_header_share_action'),
                            days: days,
                          ),
                        _NotificationsAction(
                          key: const Key('home_header_notifications_action'),
                          resolveUnconfigured: resolveNotificationsUnconfigured,
                        ),
                      ],
                    ),
                  ],
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

/// Trailing actions group of the hero header's top row (`ux/uiux-spec.md` §1;
/// design source line 248 `display:flex;align-items:center;gap:2px`).
///
/// Takes a child list rather than one hard-coded action so a second header
/// icon can be appended as a sibling, correctly gapped, without reworking any
/// existing action's subtree.
class _HeaderActionsRow extends StatelessWidget {
  const _HeaderActionsRow({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < actions.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: _headerActionGap),
          actions[i],
        ],
      ],
    );
  }
}

/// Header share affordance (`ux/uiux-spec.md` §1 table; design source line
/// 249). Opens the OS share sheet with the §2 days-together text.
///
/// `share_plus` 13.3.0 API, read from the resolved package's own `README.md`
/// and `lib/share_plus.dart` in the pub cache: `SharePlus.instance.share()`
/// takes a `ShareParams`; the older static `Share.share(String)` is deprecated
/// in this version. This is the app's first native-share surface.
class _ShareDaysAction extends StatelessWidget {
  const _ShareDaysAction({super.key, required this.days});

  final int days;

  /// Fire-and-forget by contract (AC3): a dismissed sheet is a normal outcome,
  /// so the [ShareResult] is deliberately not inspected and no snackbar, error
  /// state, or retry hangs off it.
  Future<void> _share(BuildContext context) async {
    final String text = _viEn(
      context,
      '$days ngày bên nhau rồi 💕',
      '$days days together 💕',
    );
    // iPad presents the sheet as a popover anchored to this rect (`share_plus`
    // README, "iPad"); ignored on every other platform.
    final RenderBox? box = context.findRenderObject() as RenderBox?;

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Semantics(
      label: _viEn(context, 'Chia sẻ số ngày bên nhau', 'Share days together'),
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _share(context),
        child: SizedBox(
          width: context.cupidPlatform.tapTarget,
          height: _headerActionHeight,
          child: Center(
            child: CupidIcon(
              CupidPlatform.of(context) == CupidPlatform.ios
                  ? CupidIcons.iosShare
                  : CupidIcons.share,
              variant: CupidIconVariant.line,
              size: _headerActionIconSize,
              color: colors.colorTextMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlapping avatar pair plus the couple label, rendering the design's
/// `Minh & Linh` title from the `displayName` and `partnerDisplayName` keys of
/// `GET /users/me`.
class _PresenceRow extends StatelessWidget {
  const _PresenceRow({
    required this.displayName,
    this.photoUrl,
    required this.partnerDisplayName,
    this.partnerPhotoUrl,
    required this.coupleTypeLabel,
    required this.isPaired,
  });

  final String? displayName;
  final String? photoUrl;
  final String? partnerDisplayName;
  final String? partnerPhotoUrl;
  final String? coupleTypeLabel;
  final bool isPaired;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final String? initial = (displayName == null || displayName!.isEmpty)
        ? null
        : displayName!.substring(0, 1).toUpperCase();
    // A missing partner name is a legal degraded state, never an error: the
    // title drops the `&` and the partner disc stays gradient-only.
    final bool hasPartnerName =
        partnerDisplayName != null && partnerDisplayName!.isNotEmpty;
    final String? partnerInitial = hasPartnerName
        ? partnerDisplayName!.substring(0, 1).toUpperCase()
        : null;
    final String? coupleTitle = (displayName == null || displayName!.isEmpty)
        ? null
        : hasPartnerName
        ? '${displayName!} & ${partnerDisplayName!}'
        : displayName!;

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
                photoUrl: photoUrl,
              ),
              if (isPaired)
                Positioned(
                  left: _avatarDiameter + _avatarOverlap,
                  child: _Avatar(
                    gradient: CouplePresencePalette.partnerAvatarGradient,
                    initial: partnerInitial,
                    photoUrl: partnerPhotoUrl,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: _avatarLabelGap),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (coupleTitle != null)
                Text(
                  coupleTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        ),
      ],
    );
  }
}

/// The header's `goNotifs` action (`isHome` block, header icon row): a
/// trailing-aligned notifications glyph inside a full platform tap target,
/// with the design's unread indicator dot.
///
/// This is an entry point only — it pushes the Notifications screen already
/// shipped by REQ-002 STORY-031 and introduces no notifications feed of its
/// own. The dot is re-resolved after that screen pops so it clears as soon as
/// the user saves a preference there.
class _NotificationsAction extends StatefulWidget {
  const _NotificationsAction({super.key, required this.resolveUnconfigured});

  final Future<bool> Function() resolveUnconfigured;

  @override
  State<_NotificationsAction> createState() => _NotificationsActionState();
}

class _NotificationsActionState extends State<_NotificationsAction> {
  late Future<bool> _unconfigured = widget.resolveUnconfigured();

  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationSettingsScreen(
          store: getIt<NotificationPreferencesStore>(),
        ),
      ),
    );
    if (!mounted) return;
    final Future<bool> refreshed = widget.resolveUnconfigured();
    setState(() {
      _unconfigured = refreshed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return FutureBuilder<bool>(
      future: _unconfigured,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        final bool unconfigured = snapshot.data ?? false;
        return Semantics(
          button: true,
          label: unconfigured
              ? _viEn(context, 'Thông báo · chưa xem', 'Notifications · unread')
              : _viEn(context, 'Thông báo', 'Notifications'),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _open,
            child: SizedBox(
              width: context.cupidPlatform.tapTarget,
              height: _headerActionHeight,
              child: Stack(
                // `justify-content:flex-end` in the source: the glyph sits
                // flush to the tap target's trailing edge, not centered.
                alignment: Alignment.centerRight,
                children: <Widget>[
                  CupidIcon(
                    CupidIcons.notifications,
                    variant: CupidIconVariant.line,
                    size: _headerActionNotificationIconSize,
                    color: colors.colorTextMuted,
                  ),
                  if (unconfigured)
                    Positioned(
                      key: const Key('home_header_notifications_dot'),
                      top: _headerActionDotTop,
                      right: _headerActionDotRight,
                      child: Container(
                        width: _headerActionDotDiameter,
                        height: _headerActionDotDiameter,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.colorAccentPink,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: colors.colorAccentPink,
                              blurRadius: _headerActionDotGlowBlur,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.gradient,
    required this.initial,
    this.photoUrl,
  });

  final Gradient gradient;
  final String? initial;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final bool hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Container(
      width: _avatarDiameter,
      height: _avatarDiameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasPhoto ? null : gradient,
        image: hasPhoto
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
        border: Border.all(
          color: colors.colorBackground,
          width: _avatarRing,
        ),
        boxShadow: context.cupidPlatform.elevationShadow,
      ),
      child: hasPhoto
          ? null
          : (initial == null
              ? null
              : Text(
                  initial!,
                  style: type.caption.copyWith(
                    fontSize: _avatarInitialFontSize,
                    fontWeight: FontWeight.w800,
                    color: CouplePresencePalette.avatarInitial,
                  ),
                )),
    );
  }
}

/// The days count in the §2 Display role (Nunito 900, 34pt) painted with
/// `CupidColorTokens.gradientDream`, enhanced with theme-reactive living
/// nurturing aura, ambient spores, shimmer sweep, and tap interaction.
class _DaysCounter extends StatelessWidget {
  const _DaysCounter({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return ThemedDaysCounterNurture(days: days);
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

/// The two-column quick grid that replaced the full-width Synced Alarm entry
/// card at this list position (`ux/ux-spec.md` §3). `IntrinsicHeight` is what
/// makes `CrossAxisAlignment.stretch` legal here: this `Row` sits in a
/// scrollable `Column`, so its cross axis is unbounded and `stretch` alone
/// would resolve to an infinite tight height.
class _QuickGridRow extends StatelessWidget {
  const _QuickGridRow();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: _QuickGridTile(
                  key: const Key('home_reminder_entry_card'),
                  icon: CupidIcons.notificationsActive,
                  accent: colors.colorAmber,
                  title: context.reminderNotificationsRowTitle,
                  subtitle: context.reminderNotificationsRowSubtitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ReminderScheduleScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: _quickGridGap),
              Expanded(
                child: _QuickGridTile(
                  key: const Key('home_zodiac_entry_tile'),
                  icon: CupidIcons.autoAwesome,
                  accent: colors.colorPeach,
                  title: _zodiacTileTitle,
                  subtitle: _viEn(
                    context,
                    'Xem chỉ số xung đột hôm nay',
                    "See today's conflict index",
                  ),
                  subtitleColor: colors.colorPeach,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ZodiacRedFlagScreen.routeName),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _quickGridGap),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: _QuickGridTile(
                  key: const Key('home_dream_jar_entry_card'),
                  icon: CupidIcons.savings,
                  accent: colors.colorMint,
                  title: 'Dream Jar',
                  subtitle: _viEn(
                    context,
                    'Hũ Ước Mơ',
                    'Savings jar',
                  ),
                  subtitleColor: colors.colorMint,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DreamJarListScreen(
                        repository: getIt<DreamJarRepository>(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: _quickGridGap),
              Expanded(
                child: _QuickGridTile(
                  key: const Key('home_anti_ghost_entry_tile'),
                  icon: CupidIcons.blurOn,
                  accent: colors.colorAccentPurple,
                  title: 'Anti-Ghosting',
                  subtitle: _viEn(
                    context,
                    'Chống bơ tin nhắn',
                    'Anti-ghosting',
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AntiGhostScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One half-width quick-grid tile (`ux/ux-spec.md` §3 tile internals). The
/// shadow lives on a [DecoratedBox] behind the [Material] because `Material`'s
/// `borderRadius` form paints no `boxShadow` of its own.
class _QuickGridTile extends StatelessWidget {
  const _QuickGridTile({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.subtitleColor,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// `Cupid Screens.dc.html:305-326` colours each tile's subtitle
  /// individually: Zodiac is `var(--peach)` (L314) while Synced Alarm keeps
  /// `var(--tx2)` (L309). Null means the shared muted colour.
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final BorderRadius radius = BorderRadius.circular(
      platformTokens.radiusCard,
    );

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '$title. $subtitle',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: platformTokens.elevationShadow,
        ),
        child: Material(
          color: colors.colorSurface,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
              child: Padding(
                padding: const EdgeInsets.all(_quickGridTilePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: _quickGridIconBoxSize,
                      height: _quickGridIconBoxSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: _quickGridIconBoxAlpha),
                        borderRadius: BorderRadius.circular(
                          platformTokens.radiusSmall,
                        ),
                      ),
                      child: CupidIcon(
                        icon,
                        size: _quickGridIconSize,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: _quickGridIconTitleGap),
                    Text(
                      title,
                      style: type.body.copyWith(
                        fontSize: _quickGridTitleFontSize,
                        fontWeight: FontWeight.w800,
                        color: colors.colorText,
                      ),
                    ),
                    const SizedBox(height: _quickGridTitleSubtitleGap),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: type.caption.copyWith(
                        fontSize: _quickGridSubtitleFontSize,
                        color: subtitleColor ?? colors.colorTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      TimelineScreen(createCubit: widget.createTimelineCubit),
                ),
              );
              if (getIt.isRegistered<TimelineRepository>()) {
                getIt<TimelineRepository>().refresh();
              }
            },
          ),
        );
      },
    );
  }
}
