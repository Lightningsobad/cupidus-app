/// The date script flow's whole contact surface with the rest of the app
/// (`architecture/contract-summary.md` §1).
///
/// The prepare sheet of a *Đã hẹn ngày* card reaches screen (9) through this
/// file and nothing else. Deliberately absent: the cubit, the renderer, the
/// selector and every internal widget, plus anything that would let a caller
/// read a rendered script without opening the screen — a headless "today's
/// script" helper here is how the script surfaces somewhere the user never
/// asked for it (BR-1a).
library;

import 'package:flutter/material.dart';

import '../activity_cards/domain/activity_card.dart';
import 'presentation/screens/date_script_screen.dart';

export 'presentation/screens/date_script_screen.dart'
    show DateScriptScreen, dateScriptEntryPointId;

/// Pushes "Kịch bản buổi hẹn", full-screen and over the card detail.
///
/// An anonymous route: no `settings.name`, no registered route table entry, no
/// deep link. [card] is a required positional parameter, so opening the screen
/// without a source card does not compile — which is what makes "no context, no
/// screen" a property of the code rather than a runtime redirect (AC-4/BR-1a).
Future<void> openDateScriptScreen(BuildContext context, ActivityCard card) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext _) => DateScriptScreen(card: card),
    ),
  );
}
