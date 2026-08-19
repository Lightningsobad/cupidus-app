# STORY-059 — Architecture Solution

Story: STORY-059_cupid_header_action_slot_sizing_hardening
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Complexity: standard | Lane: mobile-dev (single lane)
Author: tech-lead
Date: 2026-08-19

## 0. Path correction (verified, supersedes the handoff)

The handoff named `mobile/lib/features/design_system/widgets/cupid_header.dart`.
That path does not exist. Verified real paths (repo-wide glob):

- `mobile/lib/design_system/adaptive/cupid_header.dart`
- `mobile/lib/design_system/adaptive/cupid_add_action.dart`

All line references below are against the verified files.

## 1. Decision required of Tech Lead

UX (`ux/uiux-spec.md` §"Secondary, complementary fix" item 5) deferred exactly
one decision: how `CupidHeader` detects that its `actions` need a toolbar band
taller than the framework's 56pt `kToolbarHeight`.

**Decision: explicit opt-in constructor parameter. Rejected: marker/type
inspection of the `actions` list.**

### 1.1 Why marker/type inspection is rejected (evidence, not preference)

A `actions.any((Widget w) => w is CupidAddAction)` check fails on the only
real-world placement of `CupidAddAction` in `CupidHeader.actions` that exists in
this repository. `dream_jar_list_screen.dart:71-79` puts a `Semantics` wrapper
between the list and the FAB:

```dart
DreamJarListEmpty() || DreamJarListReady() => <Widget>[
  Semantics(
    button: true,
    label: l10n.dream_jar_new_jar_cta,
    child: CupidAddAction(...),
  ),
],
```

The list element is `Semantics`, not `CupidAddAction`. Any wrapper —
`Semantics`, `Tooltip`, `Padding`, `Visibility`, a `Builder` — defeats the type
test, and the header silently keeps the 56pt band and re-clamps the FAB to
60x56. The failure is worse than the current known bug in one specific way: the
AC2 pinned test constructs `CupidAddAction` **unwrapped**
(`adaptive_widgets_test.dart:633`), so the heuristic would pass its own
regression test while reproducing the defect in production. A guard that
green-lights its own test and fails at the real call site is not an acceptable
outcome for a retro-hardening story whose whole purpose is closing this class of
gap.

Two supporting reasons:

- `CupidHeader.preferredSize` (`cupid_header.dart:62-63`) is a context-free,
  pre-layout getter. It cannot measure children, so detection can only be
  static. Static introspection of an opaque `List<Widget>` is exactly the
  unreliable mechanism described above.
- Type inspection would make `cupid_header.dart` import `cupid_add_action.dart`
  and turn the band into a closed allow-list: every future oversized action
  would require editing the shared header.

### 1.2 The chosen contract

```dart
class CupidHeader extends StatelessWidget implements PreferredSizeWidget {
  const CupidHeader({
    super.key,
    required this.title,
    this.titleSemanticLabel,
    this.onBack,
    this.backLabel,
    this.actions = const <Widget>[],
    this.hasOversizedAction = false,
    this.trailing,
  });

  /// Declared by a caller whose [actions] contain an element taller than the
  /// framework's 56pt `kToolbarHeight` — for example `CupidAddAction`'s 60pt
  /// Material FAB. Raises the Material toolbar band (and [preferredSize]) to
  /// [_oversizedActionToolbarHeight] so that action renders unclamped. Callers
  /// declare it rather than the header inferring it: an action wrapped in
  /// `Semantics`/`Tooltip`/`Padding` is undetectable by type, and
  /// [preferredSize] is resolved before layout so nothing can be measured.
  final bool hasOversizedAction;
}
```

Contract properties:

- Default `false` — every existing call site compiles and renders byte-identical
  to today. This is what makes AC4 hold structurally, not by inspection.
- Opt-in is a caller declaration, immune to wrapper widgets.
- `cupid_add_action.dart` is not imported and not modified (AC3 holds
  trivially).

## 2. Sizing constant and the exact band value

```dart
/// Toolbar band for a header that declares an oversized action. 60 matches
/// `CupidAddAction`'s Material FAB box (`cupid_add_action.dart`
/// `_materialFabSize`, transcribed from `Cupid Screens.dc.html` line 881).
const double _oversizedActionToolbarHeight = 60;
```

**60 exactly — not 60 plus padding, not a rounded-up value.** Mechanism:
Flutter's `AppBar` lays `actions` into
`Row(crossAxisAlignment: CrossAxisAlignment.stretch, ...)`, so each action
receives a *tight* cross-axis constraint equal to the toolbar height. That
stretch is precisely why the shipped FAB measures 60x56 today. Consequences:

- `toolbarHeight: 60` -> the FAB renders `Size(60, 60)`, satisfying AC2.
- `toolbarHeight: 64` (or any value > 60) -> the FAB renders `Size(60, 64)`,
  i.e. a *new* deviation in the opposite direction. Do not add breathing room.

## 3. Component changes

### 3.1 `mobile/lib/design_system/adaptive/cupid_header.dart`

1. Add the `hasOversizedAction` field + constructor parameter (§1.2) and the
   file-level `_oversizedActionToolbarHeight` constant (§2), placed next to the
   existing `_trailingGap` constant at line 16.
2. Add a private band getter on `CupidHeader`:
   ```dart
   double get _bandHeight =>
       hasOversizedAction ? _oversizedActionToolbarHeight : kToolbarHeight;
   ```
3. `preferredSize` (currently `const Size.fromHeight(kToolbarHeight)`, lines
   62-63) becomes `Size.fromHeight(_bandHeight)`. The `const` goes away.
4. Thread the value into `_MaterialHeader` as a new required
   `toolbarHeight` field and set `AppBar(toolbarHeight: toolbarHeight, ...)`.
   Both must move together: an `AppBar` with `toolbarHeight: 60` inside a
   `Scaffold` slot sized by a 56pt `preferredSize` clips/overflows.
5. `_IosHeader` receives no new parameter and is not modified.

### 3.2 `preferredSize` cannot branch on platform — accepted reconciliation

UX spec item 4 asks that the conditional height apply "for Material only".
`PreferredSizeWidget.preferredSize` is read by `Scaffold` off the widget
instance with no `BuildContext`, so `CupidPlatform.of(context)` is unavailable
there; a platform branch is impossible without changing the widget's public
shape (e.g. requiring callers to pass the platform in), which is unjustified
scope for this story.

Resolution: `preferredSize` tracks `hasOversizedAction` on both platforms.
This does not affect iOS in practice — the flag defaults to `false`, and no iOS
consumer sets it (iOS renders `CupidAddAction` as a plain `IconButton` that
already fits). If some future iOS caller did opt in, the effect is a 60pt
instead of 56pt band, which is benign. Recorded here so the review gate reads
this as a deliberate, evidenced reconciliation rather than a spec deviation.

### 3.3 `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart`

Replace the `switch (state)` expression at lines 70-81 with
`actions: const <Widget>[]`. Both arms (`DreamJarListEmpty`,
`DreamJarListReady`) lose their `Semantics`-wrapped `CupidAddAction`; the `_`
arm was already empty, so the whole switch collapses.

This screen does **not** set `hasOversizedAction` — after the removal it has no
actions at all.

Not touched: `_openCreateSheet` (still reached by both body CTAs), the
`CupidPrimaryButton` at `_EmptyJarsView` lines 197-200, the `CupidPrimaryButton`
at `_JarListBody` lines 228-234.

Import hygiene: if `CupidAddAction`'s symbol becomes unused in this file, the
import must be removed only if it is a direct import; the screen imports the
barrel `design_system/design_system.dart`, which stays.

## 4. Consumer impact (AC4 evidence)

Repo-wide grep for `actions:` against `CupidHeader` constructions returns
exactly two consumers:

| Call site | `actions` content | Post-change |
| --- | --- | --- |
| `dream_jar_list_screen.dart:70` | `Semantics(CupidAddAction)` | becomes `const <Widget>[]` (AC1) |
| `profile_edit_screen.dart:110` | `TextButton` only | untouched, flag defaults `false`, 56pt band unchanged (AC4) |

`CupidAddAction` call sites outside `CupidHeader.actions` — confirmed
unaffected, no code path reaches them (AC3):
`gallery_empty_view.dart:78`, `expense_history_screen.dart:159`
(`Scaffold.floatingActionButton`).

## 5. Test contract

| AC | Test | File |
| --- | --- | --- |
| AC2 | Pin flip: header with `hasOversizedAction: true` + `CupidAddAction` asserts explicit `const Size(60, 60)` | `mobile/test/design_system/adaptive_widgets_test.dart:614-644` |
| AC4 | Default header (flag unset) with a `TextButton` action keeps a 56pt band | same file, same group (new) |
| AC1 | Dream Jar list renders no `CupidAddAction` in empty or ready state; body CTA still present | `mobile/test/features/dream_jar/presentation/dream_jar_list_screen_test.dart` (new, uses existing `_harness(repository)`) |
| AC3 | Covered by existing untouched `CupidAddAction` tests at `adaptive_widgets_test.dart:554-612` and `expense_history_screen_fidelity_test.dart:112` | no change |

Line 643's `expect(size.height, kToolbarHeight)` becomes false after the fix and
must be replaced, not left in place. The doc comment at lines 614-618 explains
the old out-of-scope rationale and must be rewritten with it.

Verified: no existing test asserts the Dream Jar header action (grep for
`CupidAddAction` / `dream_jar_new_jar_cta` across `mobile/test` returns no
dream_jar hits), so the AC1 removal breaks nothing.

## 6. Risks

| Risk | Mitigation |
| --- | --- |
| Implementer "rounds up" the band above 60 | §2 — `CrossAxisAlignment.stretch` makes any value > 60 a new deviation |
| `preferredSize` left at 56 while `AppBar.toolbarHeight` moves to 60 | §3.1 items 3-4 must land in the same edit; the AC4 test asserts `preferredSize.height` |
| Implementer "fixes" the clamp inside `cupid_add_action.dart` | AC3 forbids it; that file is outside write scope |
| Implementer keeps the `Semantics` wrapper with an empty child | §3.3 — the whole switch collapses to `const <Widget>[]` |

## 7. Out of scope

`cupid_add_action.dart`, `gallery_empty_view.dart`, `expense_history_screen.dart`,
`kToolbarHeight` global override, any `CupidHeader` behavior unrelated to the
action-slot band, backend/frontend/devops surfaces, e2e/emulator verification.
