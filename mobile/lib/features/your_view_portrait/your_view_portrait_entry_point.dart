/// The portrait's whole contact surface with the rest of the app
/// (`architecture/contract-summary.md` §3).
///
/// Deliberately absent: the screen widget, the cubit, the repository, the DAO,
/// and any `routeName`. There is no way to build the screen from outside this
/// feature library, which is how the location lock is enforced at compile time
/// rather than by navigation convention (AC-2/AC-3).
library;

import 'package:flutter/material.dart';

import '../../core/database/cupid_database.dart';
import '../../core/di/service_locator.dart';
import '../../core/realtime/backend_user_id_store.dart';
import 'data/portrait_answer_dao.dart';
import 'data/portrait_answer_repository.dart';
import 'presentation/screens/your_view_portrait_screen.dart';

/// Where the user came from. STORY-008 adds `dateScript` as a **value**; a new
/// route, menu item, tab, or deep link is not the extension point (§3).
enum PortraitEntrySource { giftIdeas }

/// Pushes the portrait onto the source flow's own [Navigator].
///
/// Not `pushReplacement`, not `rootNavigator: true`, not `popUntil`: closing the
/// portrait must hand the user back to the flow they left, with its state
/// intact (AC-4).
Future<void> openYourViewPortrait(
  BuildContext context, {
  required PortraitEntrySource from,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext _) => YourViewPortraitScreen(
        answers: PortraitAnswerRepository(
          dao: PortraitAnswerDao(getIt<CupidDatabase>()),
          ownerKeyStore: getIt<BackendUserIdStore>(),
        ),
      ),
    ),
  );
}
