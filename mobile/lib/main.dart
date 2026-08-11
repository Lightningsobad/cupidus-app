import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/cupid_app.dart';
import 'core/di/service_locator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Firebase must be initialized before anything can touch FirebaseAuth.
  // Without this the app red-screens on launch with
  // "[core/no-app] No Firebase App '[DEFAULT]' has been created": the service
  // locator registers CupidSession and the auth token provider against
  // FirebaseAuth.instance, and the first widget that resolves either of them
  // brings the whole tree down. The registrations are lazy, which is why the
  // failure surfaces at first use rather than at setupServiceLocator().
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupServiceLocator();
  runApp(const CupidApp());
}
