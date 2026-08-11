// Preview entrypoint — render ONE screen, already in the state you want to
// photograph, as the root of the app. DEV-ONLY scaffolding; never a release
// entrypoint, and it ships no real credentials.
//
// Why this exists: 35 of the design's screens sit behind auth, pairing and
// live backend data, so driving the real app to reach one is slow, flaky on a
// headless emulator, and dependent on state we do not control. A design-
// fidelity capture must FAKE the state, not navigate to it.
//
//   flutter run -t lib/main_preview.dart -d <device> --dart-define=PREVIEW=home
//
// Omit PREVIEW for an index of everything registered. Capture with:
//   .ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
//     --out=<story>/visual-fidelity --label=<screen> --width=540
//
// The keys are the DESIGN canvas screen ids (render-design-canvas.js
// --list-screens), so an implementation capture and its design reference are
// named the same thing and cannot be mismatched by accident.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'design_system/theme/cupid_platform.dart';
import 'design_system/theme/cupid_theme.dart';
import 'firebase_options.dart';
import 'l10n/generated/app_l10n.dart';
import 'features/account/presentation/screens/privacy_screen.dart';
import 'features/anti_ghosting/presentation/screens/anti_ghost_screen.dart';
import 'features/gallery/presentation/screens/gallery_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/pairing/presentation/screens/invite_screen.dart';
import 'features/pairing/presentation/screens/joincode_screen.dart';
import 'features/pairing/presentation/screens/paired_screen.dart';
import 'features/pet/presentation/pet_screen.dart';
import 'features/reminders/presentation/screens/reminder_schedule_screen.dart';
import 'features/vibes/presentation/vibe_screen.dart';

/// Screens that render from their own defaults today.
final Map<String, WidgetBuilder> previewScreens = <String, WidgetBuilder>{
  'alarm': (BuildContext context) => const ReminderScheduleScreen(),
  'antighost': (BuildContext context) => const AntiGhostScreen(),
  'gallery': (BuildContext context) => const GalleryScreen(),
  'home': (BuildContext context) => const HomeScreen(),
  'invite': (BuildContext context) => const InviteScreen(),
  'joincode': (BuildContext context) => const JoincodeScreen(),
  'paired': (BuildContext context) => const PairedScreen(),
  'pet': (BuildContext context) => const PetScreen(),
  'privacy': (BuildContext context) => const PrivacyScreen(),
  'vibe': (BuildContext context) => const VibeScreen(),
};

/// Registered in the design but not yet previewable: their constructors take
/// required repositories, cubits or row data, so they need authored fixtures
/// before they can be captured. Listed rather than omitted so the gap is
/// visible instead of looking like the design has fewer screens than it does.
const List<String> needsFixtures = <String>[
  'chat', // ChatScreen
  'contract', // LoveContractScreen
  'expense', // ExpenseHistoryScreen
  'forgot', // ForgotScreen
  'gallery', // GalleryViewerScreen
  'ghostset', // GhostSettingsScreen
  'jar', // DreamJarDetailScreen
  'jarlist', // DreamJarListScreen
  'jarnew', // ContributionHistoryScreen
  'login', // LoginScreen
  'me', // MeScreen
  'notifs', // NotificationSettingsScreen
  'profile', // ProfileEditScreen
  'register', // RegisterScreen
  'splash', // SplashScreen
  'timeline', // TimelineScreen
  'waiting', // WaitingScreen
  'welcome', // WelcomeScreen
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupServiceLocator();
  runApp(const PreviewApp());
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  static const String _target = String.fromEnvironment('PREVIEW');
  static const String _brightness =
      String.fromEnvironment('PREVIEW_BRIGHTNESS', defaultValue: 'dark');

  @override
  Widget build(BuildContext context) {
    final CupidPlatform platform = CupidPlatform.of(context);
    final Brightness brightness =
        _brightness == 'light' ? Brightness.light : Brightness.dark;
    final WidgetBuilder? screen = previewScreens[_target];

    return MaterialApp(
      title: 'Cupid preview',
      // The debug banner overlaps the top-right of every capture and would read
      // as a design delta that is not real.
      debugShowCheckedModeBanner: false,
      // Reuse the app's own theme builder rather than a stand-in: a preview
      // rendered against different tokens would prove nothing about fidelity.
      theme: buildCupidTheme(platform: platform, brightness: brightness),
      themeMode: ThemeMode.light,
      // Pin locale and text scale. A host device with a system font-size
      // override would silently change every measurement in the capture.
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      builder: (BuildContext context, Widget? child) =>
          MediaQuery.withNoTextScaling(child: child ?? const SizedBox.shrink()),
      home: screen != null ? Builder(builder: screen) : const _PreviewIndex(),
    );
  }
}

/// Shown when PREVIEW is unset or names an unregistered screen. Listing the
/// valid keys turns a typo into a one-line fix instead of a blank screen.
class _PreviewIndex extends StatelessWidget {
  const _PreviewIndex();

  @override
  Widget build(BuildContext context) {
    final List<String> keys = previewScreens.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Preview screens')),
      body: ListView(
        children: <Widget>[
          for (final String k in keys)
            ListTile(
              title: Text(k),
              subtitle: Text('--dart-define=PREVIEW=$k'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: previewScreens[k]!),
              ),
            ),
          const Divider(),
          const ListTile(
            title: Text('Needs fixtures'),
            subtitle: Text('constructors require repositories/cubits/row data'),
          ),
          for (final String k in needsFixtures)
            ListTile(dense: true, title: Text(k, style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}
