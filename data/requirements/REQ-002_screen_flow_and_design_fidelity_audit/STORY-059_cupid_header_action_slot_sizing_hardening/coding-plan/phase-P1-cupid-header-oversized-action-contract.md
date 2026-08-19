# P1 — CupidHeader oversized-action contract + Dream Jar call-site removal

Owner: mobile-dev | Lane: mobile | Depends On: NONE | Parallelizable: No
Status: DONE
Story: STORY-059_cupid_header_action_slot_sizing_hardening
Architecture: `../architecture/solution.md`

Status detail (2026-08-19): Steps 1-5 implemented across all four write-scope
files; `flutter analyze` clean, Verification test command passes 115/115
(`test-results.md`); visual fidelity `PASS` with both AC1 states captured on
`emulator-5560` (`../visual-fidelity/visual-fidelity-report.md`). The
`MOBILE_VISUAL_AUDIT_SCREEN_UNREACHABLE` blocker raised on the first pass was
cleared by a Scrum-Master-authorized write-scope extension to
`mobile/lib/main_preview.dart` (fifth touched file, `PREVIEW_JARLIST_FIXTURE`).
Note this file's line "No emulator, device, e2e, or Playwright gate applies to
this phase" was superseded by the handoff, which required an on-device render.

## Write Scope

- `mobile/lib/design_system/adaptive/cupid_header.dart`
- `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart`
- `mobile/test/design_system/adaptive_widgets_test.dart`
- `mobile/test/features/dream_jar/presentation/dream_jar_list_screen_test.dart`

Nothing else. Notably forbidden: `cupid_add_action.dart`,
`gallery_empty_view.dart`, `expense_history_screen.dart`,
`profile_edit_screen.dart`, `profile_edit_screen_test.dart`.

## Step 1 — `cupid_header.dart`: the opt-in contract

Near the existing `_trailingGap` constant (line 16), add:

```dart
/// Toolbar band for a header that declares an oversized action. 60 matches
/// `CupidAddAction`'s Material FAB box (`cupid_add_action.dart`
/// `_materialFabSize`, from `Cupid Screens.dc.html` line 881).
const double _oversizedActionToolbarHeight = 60;
```

On `CupidHeader`:

- Add `this.hasOversizedAction = false` to the constructor, after `actions`.
- Add the field with the doc comment from `../architecture/solution.md` §1.2.
- Add `double get _bandHeight => hasOversizedAction ? _oversizedActionToolbarHeight : kToolbarHeight;`
- Change `preferredSize` (lines 62-63) from
  `const Size.fromHeight(kToolbarHeight)` to `Size.fromHeight(_bandHeight)`.
  The `const` must go.
- Pass `toolbarHeight: _bandHeight` into the `_MaterialHeader(...)` call.
  Do **not** pass it into `_IosHeader(...)`.

On `_MaterialHeader`:

- Add `required this.toolbarHeight` to the constructor and
  `final double toolbarHeight;` to the fields.
- Add `toolbarHeight: toolbarHeight,` to the `AppBar(...)` call.

Do not touch `_IosHeader`.

**Do not raise the band above 60.** `AppBar` stretches each action to a tight
cross-axis constraint equal to `toolbarHeight`
(`Row(crossAxisAlignment: CrossAxisAlignment.stretch)`) — that stretch is the
mechanism producing today's 60x56. A band of 64 would render the FAB 60x64, a
new deviation. See `../architecture/solution.md` §2.

## Step 2 — `dream_jar_list_screen.dart`: remove the header action

At lines 70-81, replace the entire `actions: switch (state) { ... }` expression
with:

```dart
actions: const <Widget>[],
```

Both the `DreamJarListEmpty() || DreamJarListReady()` arm and the `_` arm
disappear with the switch. Do not leave an empty `Semantics` wrapper behind.
Do not set `hasOversizedAction` here — this header now has no actions.

Untouched on this screen: `_openCreateSheet`, the `CupidPrimaryButton` in
`_EmptyJarsView` (lines 197-200), the `CupidPrimaryButton` in `_JarListBody`
(lines 228-234). Those two body CTAs are the design-conformant create-jar entry
point and are the reason removing the header icon loses no capability.

The screen imports the `design_system/design_system.dart` barrel, not
`cupid_add_action.dart` directly — leave imports alone unless `flutter analyze`
reports an unused one.

## Step 3 — `adaptive_widgets_test.dart`: flip the AC2 pin (lines 614-644)

Rewrite the doc comment at 614-618 (it currently explains why the fix was out of
scope) and the test at 619-644:

- Rename the test away from "clamped to 60x56" — e.g.
  `'Material FAB renders unclamped at 60x60 inside CupidHeader.actions when the header declares an oversized action'`.
- Construct the header with the opt-in:
  `CupidHeader(title: 'Hũ Ước Mơ', hasOversizedAction: true, actions: <Widget>[CupidAddAction(onPressed: () {})])`.
- Assert `expect(size, const Size(60, 60));` — an explicit `Size`, per AC2.
- Line 643's `expect(size.height, kToolbarHeight);` is now false and must be
  replaced, not deleted silently. Replace it with an assertion on the declared
  band, e.g. `expect(size.height, greaterThan(kToolbarHeight));`.

## Step 4 — `adaptive_widgets_test.dart`: new AC4 default-band test

In the same group, add a test proving an ordinary action-bearing header is
untouched (this is the `profile_edit_screen.dart` shape):

- Build `CupidHeader(title: ..., actions: <Widget>[TextButton(...)])` with the
  flag left at its default, under the Material override.
- Assert the header's `preferredSize.height == kToolbarHeight`.
- Assert the rendered `AppBar`'s toolbar band is still 56 (e.g. via
  `tester.getSize(find.byType(AppBar))` height or the `AppBar` widget's
  resolved `toolbarHeight`).

Do **not** add a test that pins `CupidAddAction` clamped to 60x56 on the default
path. That would re-pin the defect this story removes.

## Step 5 — `dream_jar_list_screen_test.dart`: new AC1 regression test

Use the existing `_harness(repository)` helper (line ~85) and the existing
`_FakeDreamJarRepository` / `_jar()` fixtures. Follow the existing
`pumpWidget` + double `pump()` pattern at lines 112-118.

Add coverage that, in **both** the empty state (`() async => <DreamJar>[]`) and
the ready state (two or more jars — one jar triggers the single-jar detail
bypass at `dream_jar_list_screen.dart:59`, so use at least two):

- `expect(find.byType(CupidAddAction), findsNothing);`
- the body CTA is still present (the empty-state test at line 123 already uses
  `find.text('New Dream Jar')` as the marker).

## Verification

```bash
cd mobile
flutter analyze
flutter test test/design_system/adaptive_widgets_test.dart \
             test/features/dream_jar/ \
             test/features/account/presentation/screens/profile_edit_screen_test.dart
```

`profile_edit_screen_test.dart` must pass **unmodified** — that is the AC4
evidence. No emulator, device, e2e, or Playwright gate applies to this phase.

## Completion

- All four write-scope files edited as specified.
- `flutter analyze` clean for the touched files.
- All commands above green.
- Report AC1/AC2/AC3/AC4 evidence with test names and result lines.
