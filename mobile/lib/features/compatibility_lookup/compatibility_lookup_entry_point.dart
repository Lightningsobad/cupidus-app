/// The compatibility table's whole contact surface with the rest of the app
/// (`architecture/contract-summary.md` §1 B).
///
/// Deliberately absent: the cubit, the repository, the screen's own widgets,
/// and — above all — a route name. Screen (10) is position-locked (AC-2/AC-3):
/// it is reachable only by calling [openCompatibilityLookup] from a surface
/// that already knows why the reader is here, so there is no typed route, no
/// deep link, no `routes:` entry in `cupid_app.dart`, and no menu or tab cell.
/// A `routeName` constant here would be enough to break that on its own,
/// because the next caller would use it.
library;

import 'package:flutter/material.dart';

import 'presentation/screens/compatibility_lookup_screen.dart';

export 'presentation/screens/compatibility_lookup_screen.dart'
    show CompatibilityLookupScreen;

/// The surfaces allowed to open screen (10)
/// (`architecture/contract-summary.md` §2, row "Cửa vào hợp lệ").
///
/// Append-only, like every other wire vocabulary in this requirement: a new
/// entry point is a new value, never a rename or a reordering of these two.
enum CompatibilityEntry {
  giftIdeas('gift_ideas'),
  dateScript('date_script');

  const CompatibilityEntry(this.wireValue);

  final String wireValue;
}

/// Pushes "Bảng tra ăn khớp", full-screen, on an anonymous route.
///
/// [from] has no default on purpose. A caller that cannot say which surface it
/// came from is a caller that should not be opening this screen, and the
/// missing-argument compile error is a cheaper guard than a review note.
///
/// The route carries no `settings.name`: an unnamed route cannot be reached by
/// `Navigator.pushNamed`, which is what makes the position lock testable rather
/// than merely intended (`coding-plan/phase-P4-...` §10).
Future<void> openCompatibilityLookup(
  BuildContext context, {
  required CompatibilityEntry from,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext _) => CompatibilityLookupScreen(from: from),
    ),
  );
}
