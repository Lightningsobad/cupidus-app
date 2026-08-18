import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../onboarding_strings.dart';

/// Material Symbols Rounded glyphs this screen needs that `CupidIcons` does
/// not expose yet (`design_system/icons/cupid_icons.dart` is outside this
/// story's write scope). Codepoints were read from the bundled
/// `assets/fonts/MaterialSymbolsRounded-Variable.ttf` cmap with `fontTools`,
/// not recalled from another icon font's PUA range.
const IconData _fingerprintIcon = IconData(
  0xe90d,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _photoLibraryIcon = IconData(
  0xe413,
  fontFamily: CupidIcons.fontFamily,
);

/// The three device permissions the design source's `permList` fixture
/// declares, in its order.
enum OnboardingPermission { notifications, biometric, photos }

/// `permissions` screen (design canvas id `permissions`, `isPermissions`
/// block of `cupid-app-design-system/project/Cupid Screens.dc.html`).
///
/// Presentational only: the design source's interactions are the three
/// per-permission toggles plus the two footer actions, so no OS permission
/// request, repository, or route is wired here. [onContinue] and [onSkip] are
/// left for the navigation story that owns inter-screen flow.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({
    super.key,
    this.initiallyGranted = const <OnboardingPermission>{},
    this.onContinue,
    this.onSkip,
  });

  /// Permissions already granted when the screen opens. Everything else
  /// renders in the not-yet-decided state.
  final Set<OnboardingPermission> initiallyGranted;

  final VoidCallback? onContinue;
  final VoidCallback? onSkip;

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  late final Set<OnboardingPermission> _granted = <OnboardingPermission>{
    ...widget.initiallyGranted,
  };

  void _toggle(OnboardingPermission permission) {
    setState(() {
      if (!_granted.remove(permission)) {
        _granted.add(permission);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isIos = CupidPlatform.of(context) == CupidPlatform.ios;
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final List<_PermissionCopy> permissions = <_PermissionCopy>[
      _PermissionCopy(
        permission: OnboardingPermission.notifications,
        icon: CupidIcons.notificationsActive,
        accent: colors.colorAmber,
        title: context.viEn('Thông báo', 'Notifications'),
        body: context.viEn(
          'Nhắc nhở đồng bộ và Emoji Storm cần cái này. Tối đa 15 cái/ngày.',
          'Synced Reminder and Emoji Storm need this. Max 15 a day.',
        ),
      ),
      _PermissionCopy(
        permission: OnboardingPermission.biometric,
        icon: _fingerprintIcon,
        accent: colors.colorAccentPink,
        title: isIos ? 'Face ID' : context.viEn('Vân tay', 'Fingerprint'),
        body: context.viEn(
          'Dùng để mở Private Gallery và ký Love Contract.',
          'Unlocks the Private Gallery and signs the Love Contract.',
        ),
      ),
      _PermissionCopy(
        permission: OnboardingPermission.photos,
        icon: _photoLibraryIcon,
        accent: colors.colorAccentPurple,
        title: context.viEn('Thư viện ảnh', 'Photos'),
        body: context.viEn(
          'Chỉ những ảnh bạn chọn. Không quét gì hết.',
          'Only the photos you pick. Nothing is scanned.',
        ),
      ),
    ];

    return Scaffold(
      // No app-bar chrome: `ux/uiux-spec.md` Chrome Rules apply unconditionally
      // to every onboarding-chain node.
      // backgroundColor override intentionally removed (REQ-002 STORY-032
      // AC1): the shared CupidAppBackground app-shell layer now paints the
      // sky-gradient wash behind every screen; a Scaffold-level solid fill
      // here would occlude it.
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.viEn('Cho phép vài thứ nhé', 'A few permissions'),
                    style: type.display.copyWith(
                      color: colors.colorText,
                      fontSize: 25,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.viEn(
                      'Bạn có thể từ chối hết. App vẫn chạy, chỉ là kém vui hơn.',
                      'You can decline everything. The app still works, just '
                          'less fun.',
                    ),
                    style: type.caption.copyWith(color: colors.colorTextMuted),
                  ),
                ],
              ),
            ),
            for (final _PermissionCopy copy in permissions) ...<Widget>[
              const SizedBox(height: _gap),
              _PermissionCard(
                copy: copy,
                granted: _granted.contains(copy.permission),
                onToggle: () => _toggle(copy.permission),
                colors: colors,
                type: type,
                platformTokens: platformTokens,
              ),
            ],
            const SizedBox(height: _gap + 4),
            _GradientCta(
              label: context.viEn('Tiếp tục', 'Continue'),
              onPressed: widget.onContinue,
              colors: colors,
              type: type,
              platformTokens: platformTokens,
            ),
            const SizedBox(height: _gap),
            Center(
              child: TextButton(
                onPressed: widget.onSkip,
                child: Text(
                  context.viEn('Để sau', 'Maybe later'),
                  style: type.caption.copyWith(
                    color: colors.colorTextMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vertical rhythm between the screen's stacked blocks (design source
/// `gap:13px` on the `isPermissions` column).
const double _gap = 13;

@immutable
class _PermissionCopy {
  const _PermissionCopy({
    required this.permission,
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
  });

  final OnboardingPermission permission;
  final IconData icon;

  /// Drives both the glyph color and, at 20% alpha, its rounded tile.
  final Color accent;

  final String title;
  final String body;
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.copy,
    required this.granted,
    required this.onToggle,
    required this.colors,
    required this.type,
    required this.platformTokens,
  });

  final _PermissionCopy copy;
  final bool granted;
  final VoidCallback onToggle;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: copy.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: CupidIcon(copy.icon, size: 23, color: copy.accent),
          ),
          const SizedBox(width: _gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  copy.title,
                  style: type.body.copyWith(
                    color: colors.colorText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  copy.body,
                  style: type.caption.copyWith(
                    color: colors.colorTextMuted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: _gap),
          Semantics(
            toggled: granted,
            label: copy.title,
            child: GestureDetector(
              key: Key('permissions-toggle-${copy.permission.name}'),
              onTap: onToggle,
              child: _TogglePill(granted: granted, colors: colors),
            ),
          ),
        ],
      ),
    );
  }
}

/// Granted vs. not-yet-decided pill (design source `permList` `sw`/`j`
/// fields): the granted track carries the hot gradient with the knob at the
/// end, the undecided track is the flat line token with the knob at the start.
class _TogglePill extends StatelessWidget {
  const _TogglePill({required this.granted, required this.colors});

  final bool granted;
  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 50,
      height: 30,
      padding: const EdgeInsets.all(3),
      alignment: granted ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: granted ? colors.gradientHot : null,
        color: granted ? null : colors.colorLine,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.colorText,
          shape: BoxShape.circle,
        ),
        child: const SizedBox(width: 24, height: 24),
      ),
    );
  }
}

/// The screen's primary action. `CupidPrimaryButton` renders a flat
/// `colorAccentPink` fill, which does not match this screen's design source
/// (`background:var(--grad-hot)` plus `box-shadow:var(--glow)`); correcting
/// the shared widget would change every screen and is outside this story's
/// write scope, so the design-accurate treatment is built here.
class _GradientCta extends StatelessWidget {
  const _GradientCta({
    required this.label,
    required this.onPressed,
    required this.colors,
    required this.type,
    required this.platformTokens,
  });

  final String label;
  final VoidCallback? onPressed;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(
      platformTokens.radiusButton,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: colors.gradientHot,
        borderRadius: radius,
        boxShadow: colors.glowShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox(
            height: 54,
            child: Center(
              child: Text(
                label,
                style: type.body.copyWith(
                  color: colors.colorText,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
