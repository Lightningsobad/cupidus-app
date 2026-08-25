# STORY-004_home_header_share_days_action-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-25

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC2 requires the **OS native share sheet**, and the app
  currently has no native-share capability at all. Everything else in the story
  (icon placement, tokens, share text) is already fully determined by the locked
  design source and `ux/uiux-spec.md` §1-§2.
- Architectural invariants / non-goals: no backend change; no custom share
  image/card; no platform-channel/native-code authoring in this repo; the share
  icon renders only when a shareable day count exists.
- Proposed technical direction: add the `share_plus` Flutter plugin to
  `mobile/pubspec.yaml` and invoke it from a new private header-actions row in
  `mobile/lib/features/home/presentation/home_screen.dart`. The exact package
  version and call signature are resolved by `flutter pub add` and read from the
  **resolved package's own README/source in the pub cache** — never written from
  memory (see section 4 risk `Unverified third-party API shape`).
- Why this fits the current system: `home_screen.dart` already owns the `int?
  days` value (line 296), the `'ngày bên nhau' / 'days together'` label (line
  520), the `if (days != null)` gate (line 342), and the `_viEn(context, vi, en)`
  locale helper (line 56). The share action is a pure consumer of state that this
  one file already holds, so it stays a single-file, single-lane change plus one
  dependency line.

### Key Discovery

`ux/uiux-spec.md` §3 flags — correctly — that the story's own named precedent,
`invite_screen.dart`'s "share-sheet integration pattern", **does not open an OS
share sheet**. Reading that file confirms it: `_share()` (line 168) delegates to
a clipboard helper (`Clipboard.setData`, line 192) plus a snackbar, and its own
comment (lines 163-165) states this was a *write-scope* workaround — `pubspec.yaml`
was outside that story's scope — not a considered architectural rejection of
native sharing.

This resolves the decision UX deferred to Tech Lead. Reusing that pattern
verbatim would fail AC2 as written and force an AC-wording escalation to Product
Owner. Since the only thing that ever blocked native sharing was a prior story's
write scope, and this story has no such restriction, **this story adds the
dependency and satisfies AC2 literally**. No PO escalation is required, and the
clipboard-substitute branch of `ux/uiux-spec.md` §3 is not taken.

The reusable part of the precedent is still real and is still reused: the
locale-selected payload string and the "invoke, then let the OS own the
outcome" call shape.

## 3. Scope And Assumptions

- In Scope: one Flutter package dependency; the Home hero header's top row
  restructured to `spaceBetween`; a private header-actions row with one share
  button; the share invocation.
- Out Of Scope: `goNotifs` icon and badge (STORY-005); any change to
  `invite_screen.dart`; any backend, API, or model change; custom share media.
- Assumptions affecting design:
  - `flutter pub add share_plus` can reach pub.dev at implementation time. If it
    cannot, the phase stops with a typed blocker rather than silently falling
    back to the clipboard substitute — the fallback would change AC2 conformance
    and is a Product Owner decision, not an implementer's.
  - `CupidIcons.iosShare` (0xe6b8) and `CupidIcons.share` (0xe80d) already exist
    in `mobile/lib/design_system/icons/cupid_icons.dart` (lines 123, 128) —
    verified; no font or glyph work in this story.
  - `CupidPlatformTokens.tapTarget` exists and is the established minimum-touch
    token (used by `cupid_add_action.dart`, `cupid_header.dart`, `app_shell.dart`)
    — verified.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/home/presentation` (Mobile lane, sole
  owner). Dependency manifest `mobile/pubspec.yaml` is co-owned by the same phase.
- New or changed boundaries: one new outbound boundary — the app now calls an OS
  share intent (`UIActivityViewController` / `ACTION_SEND`) through `share_plus`.
  This is the app's first native-share surface.
- Shared patterns reused: `CupidPlatform.of(context)` / `context.cupidPlatform`
  platform branching (same shape as `CupidAddAction`); the file-local
  `_viEn(context, vi, en)` locale helper; `CupidIcons` glyph constants.

### Affected Modules

- Mobile: `features/home/presentation`, plus the `mobile` package manifest.

### Contracts And Integrations

- Error, retry, timeout, empty-state contract: the share invocation is
  fire-and-forget from the app's perspective. Dismissing the sheet without
  choosing a target is a **normal, non-error outcome** (AC3) — do not surface a
  snackbar, error state, or retry on dismissal, and do not branch on the share
  result status. Empty state: when `days == null` the share icon does not render
  at all (`ux/uiux-spec.md` §2), so there is no "nothing to share" path to handle.
- External or trust-boundary implications: the shared payload is plain text
  derived from data already rendered on screen. No PII beyond the day count, no
  link, no token, no attachment. Once handed to the OS sheet the payload leaves
  the app's trust boundary — this is why the payload must stay exactly the §2
  string and must not be extended with an invite code, deep link, or partner
  identifier.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Unverified third-party API shape | the resolved `share_plus` package in the pub cache (its own `README.md` + `lib/`) | Resolve the version with `flutter pub add share_plus`; read the call signature, required parameters, and any iPad origin-rect requirement from the resolved package itself. Do not write a version constraint or call signature from memory or from an older tutorial. | `flutter analyze` clean on `home_screen.dart` plus a successful `flutter build apk --debug` | `SHARE_PACKAGE_UNRESOLVED` — pub.dev unreachable or no version compatible with Dart SDK `^3.12.1` |
| Native plugin breaks app launch | `data/devops/system/runtime-command-registry.json` id `mobile-app` | First native plugin in the app; plugin registration failure surfaces only at runtime, not in `flutter test`. Keep the dependency addition and the UI change in one phase so one build proves both. | App launches to the Home screen after install (registry `mobile-app` startup smoke) | `MOBILE_STARTUP_SMOKE_UNAVAILABLE` — no device/emulator visible to `flutter devices` |
| Share payload correctness across locale and null-days | `ux/uiux-spec.md` §2; `home_screen.dart` lines 296, 342, 520 | Build the payload from the same `int days` the counter renders, with `_viEn`. Gate the whole share button on the existing `days != null` branch. | Widget tests: icon present with a day count, icon absent when `relationshipStartDate` is null, payload string matches §2 in `vi` and `en` | `HOME_TEST_HARNESS_MISSING` — existing `mobile/test/features/home/home_screen_test.dart` cannot pump the Home screen |
| Header layout regression | `ux/uiux-spec.md` §1; `Cupid Screens.dc.html` line 242, 249 | Wrap `_PresenceRow` and the new actions row in a `spaceBetween` `Row`; `_PresenceRow` keeps intrinsic sizing and gets no `Expanded`. | Existing Home widget tests still pass; visual inspection against the design source | `HOME_TEST_HARNESS_MISSING` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: dependency addition, header row restructure, share button,
  share invocation, widget tests.
- Authoritative inputs: `ux/uiux-spec.md` §1 (tokens, sizes, structure) and §2
  (payload text, null-days rule); this file's section 4.
- Guardrails:
  - Do **not** implement the clipboard-copy branch of `ux/uiux-spec.md` §3. That
    branch is rejected here; taking it silently changes AC2 conformance.
  - Do **not** write a `share_plus` version constraint, import path, or call
    signature from memory. Resolve and read it locally (see risk table row 1).
  - Do **not** modify `invite_screen.dart`. It is precedent context only.
  - Do **not** add the `goNotifs` icon, its badge, or its handler — STORY-005.
  - Build the actions row so a second icon can be appended as a sibling with the
    same `2`px gap, with no rework of the share subtree (`ux/uiux-spec.md` §1).
    STORY-005 appends to this row; it must not have to restructure it.
  - Do **not** round the off-scale literals (`38` height, `23` icon, `2` gap) onto
    `CupidSpacing`. The locked design source wins, per this codebase's precedent.
  - Do **not** attach an error/retry path to share dismissal (AC3).

## 5. Non-Functional Impact

- First native plugin in the app: app size and cold-start link cost increase
  slightly, and the iOS/Android build now has a plugin registration step. This is
  the reason the startup smoke is `REQUIRED` rather than `OPTIONAL` for this story.
- Accessibility: the icon is text-free. Add an accessible label per
  `ux/uiux-spec.md` §1. The `38`px height falls below the 44pt/48dp guidance; this
  matches the locked design source and the already-shipped adjacent `goNotifs`
  box, and is recorded as an accepted deviation, not fixed here.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| `share_plus` plugin | Only path that satisfies AC2 literally without authoring native code | ACCEPTED | One manifest line; version/API resolved locally, not from memory |
| Custom `MethodChannel` (`UIActivityViewController` + `ACTION_SEND`) | Avoids a third-party dependency | REJECTED | Adds Swift + Kotlin + Dart channel files and a per-platform maintenance surface to reimplement a maintained plugin — far larger than the story, for no capability gain |
