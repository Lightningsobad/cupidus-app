/// The conversation-starter flow's whole contact surface with the rest of the
/// app (`architecture/contract-summary.md` §3).
///
/// The activity hub reaches screen (6) through this file and nothing else, and
/// STORY-007 will too. Deliberately absent: the selector, the calendar-event
/// service, the cubit and every internal widget, plus anything that would let a
/// caller read a starter line without the screen — a headless "one line for
/// you" helper here is how a starter surfaces outside the one place the user
/// asked for it.
library;

import 'package:flutter/material.dart';

import 'presentation/screens/conversation_starters_screen.dart';

export 'presentation/screens/conversation_starters_screen.dart'
    show ConversationStartersScreen, conversationStartersEntryPointId;

/// Pushes "Mồi chuyện", full-screen and on its own route
/// (`ux/uiux-spec.md` §1: a destination with a back button, not a bottom
/// sheet).
///
/// This is where the clock is read. Everything below takes [today] as an
/// argument, so the rendered round is a pure function of its inputs and a test
/// can pin the date (AC-17).
Future<void> openConversationStartersScreen(
  BuildContext context, {
  DateTime? now,
}) {
  final String today = civilDateOf(now ?? DateTime.now());
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext _) => ConversationStartersScreen(today: today),
    ),
  );
}

/// A local `YYYY-MM-DD` date, the civil-date shape both shipped packs use.
String civilDateOf(DateTime moment) {
  final String month = moment.month.toString().padLeft(2, '0');
  final String day = moment.day.toString().padLeft(2, '0');
  return '${moment.year}-$month-$day';
}
