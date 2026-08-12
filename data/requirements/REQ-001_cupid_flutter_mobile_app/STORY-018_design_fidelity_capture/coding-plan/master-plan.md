# Master Coding Plan – STORY-018 Hardening: Design Fidelity Capture Coverage

## 1. Planning Metadata

- Story ID: REQ-001 / STORY-018_design_fidelity_capture
- Complexity: `standard`, Story-Class `standard`, Implementation Lane `shared`
- Retro-Type: RED-PATCH
- Planning Owner: Tech Lead (`Mode: coding-plan`)
- Source Story:
  `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/story_master.md`
- Source Architecture: none — no architecture document exists or is required
  for this story (see §2 and P1 in §5)
- Evidence root (all captures and the report):
  `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/`
- Final report:
  `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/visual-fidelity-report.md`
- Plan Status: ACTIVE — seven mobile-lane phases planned (P5–P11); the four
  non-mobile lane phases are terminal `NOT_APPLICABLE`

## 2. Feasibility Ruling

Feasible with the tooling already installed. Every capability the story needs
already exists on `main`; nothing here requires a new runtime, a new service, or
a new dependency.

- Design side: `.ai-team-bundle/runtime/tools/render-design-canvas.js` already
  drives the locked canvas by `[data-screen-btn="<id>"]`, freezes animation,
  hides prototype chrome from `design-fidelity-config.json`, and writes
  `design-reference-<label>-<platform>.png`.
- Implementation side:
  `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh` already streams an
  emulator screenshot to `implemented-<label>-<device>.png`, bounds the longest
  edge, and supports `--route=<uri>` and `--width`.
- Harness side: `mobile/lib/main_preview.dart` (commit `c0e01ab`) already
  exists with 10 screens wired, keyed by design canvas screen id, with theme,
  locale, and text-scale pinned. This plan extends it; it does not restart it.
- Design source: locked and fingerprinted in
  `data/devops/system/design-fidelity-config.json`
  (`cupid-app-design-system/project`, entry `Cupid App.dc.html`, commit
  `38ca5bf`). Verified: the canvas exposes exactly **37** `data-screen-btn`
  ids, matching the story's 37.

Three facts found during planning change how the work must be sequenced. They
are recorded here because they are the difference between this story finishing
and it stalling at screen 11:

1. **10 of the 37 design screens have no implementation at all.** See §3.
2. **`--dart-define=PREVIEW=<id>` is compile-time**, so the obvious approach
   costs 37 full Flutter rebuild+install cycles. P6 removes that. See §4.1.
3. **The backend rejects unauthenticated requests with no dev bypass**
   (`backend/src/modules/auth/firebase-auth.strategy.ts` verifies a real
   Firebase ID token via `firebase-admin`; there is no test/seed route and no
   `backend/**/seed*` script). "Backend live" is therefore not sufficient on its
   own — a real signed-in, paired session is required. See §4.3.

## 3. Screen Inventory And The 10-Screen Gap

The 37 canvas ids, verified against
`cupid-app-design-system/project/Cupid App.dc.html`, resolve as follows.

Already wired in `main_preview.dart` (10): `alarm`, `antighost`, `gallery`,
`home`, `invite`, `joincode`, `paired`, `pet`, `privacy`, `vibe`.

Implemented but not yet wired (17) — the widget exists under
`mobile/lib/features/**`, and only a fixture argument is missing:

| Canvas id | Implementation | Missing constructor input |
|---|---|---|
| `splash` | `SplashScreen` | `authRepository` |
| `welcome` | `WelcomeScreen` | `authRepository` |
| `login` | `LoginScreen` | `authRepository` |
| `register` | `RegisterScreen` | `authRepository` |
| `forgot` | `ForgotScreen` | verify in P8 |
| `profile` | `ProfileEditScreen` | `accountRepository`, `profile` |
| `contract` | `LoveContractScreen` | verify in P8 |
| `waiting` | `WaitingScreen` | verify in P8 |
| `chat` | `ChatScreen` | repository, coordinator, stores (5 args) |
| `ghostset` | `GhostSettingsScreen` | coordinator, consent/partner/uid stores |
| `timeline` | `TimelineScreen` | verify in P8 |
| `jar` | `DreamJarDetailScreen` | `jarId`, `repository` |
| `jarlist` | `DreamJarListScreen` | verify in P8 |
| `jarnew` | `ContributionHistoryScreen` | `jarId`, `repository`, `currentUserId` |
| `expense` | `ExpenseHistoryScreen` | verify in P8 |
| `me` | `MeScreen` | `accountRepository` |
| `notifs` | `NotificationSettingsScreen` | `store` |

Every one of those inputs is either a `service_locator` registration
(`getIt<T>()`) or a literal id that the P7 seed makes deterministic. None
requires a new abstraction.

**Not implemented anywhere (10):** `otp`, `permissions`, `vow`, `zodiac`,
`themes`, `themedetail`, `sharepick`, `shareedit`, `shareapprove`, `shareok`.
No matching widget exists under `mobile/lib/features/**`.

This is the story's one genuine open question, raised in §7 OQ-1. It is not a
scope reduction: the plan's default disposition (P8/P10/P11) still produces a
real `implemented-*.png` and a recorded verdict for all ten, so AC1, AC2, and
AC5 are met at 37/37 either way. Only the *wording* of the verdict depends on
the ruling.

Two mapping items the report must state explicitly rather than assume:
`main_preview.dart`'s current `needsFixtures` comment maps `gallery` to
`GalleryViewerScreen` while `gallery` is simultaneously wired to
`GalleryScreen`, and maps `jarnew` to `ContributionHistoryScreen`. Both
mappings are unverified against the canvas. P8 resolves them by reading the
P5 design reference, and the report records the mapping it used.
`GalleryViewerScreen` has no canvas id and is outside the 37.

## 4. Technical Decisions

### 4.1 One install, 37 captures (DEC-1)

`PREVIEW` is a `String.fromEnvironment` compile-time constant, so switching
screens the current way means 37 rebuild+install cycles. Instead, the preview
app observes route pushes and switches the rendered screen at runtime:

- `mobile/android/app/src/debug/AndroidManifest.xml` (a **new debug-only**
  manifest; Gradle merges it for debug builds only, so the shipped release
  manifest is untouched) declares an `intent-filter` for a
  `cupidpreview://screen/<id>` scheme.
- The preview root implements `WidgetsBindingObserver.didPushRouteInformation`
  and rebuilds with the requested registry entry. This uses the framework's
  own route-update channel — no new package.
- Capture then becomes one `flutter run -t lib/main_preview.dart` followed by
  37 × `capture-mobile-screen.sh --route=cupidpreview://screen/<id>`, which the
  tool already supports.

Fallback if the route channel misbehaves on the target emulator: fall back to
per-screen `--dart-define=PREVIEW=<id>` rebuilds. Slower, but the phase must
not hard-block on DEC-1.

### 4.2 One platform, matched viewports (DEC-2)

Capture Android only. The design canvas Android frame renders at 412x915, and
`capture-mobile-screen.sh --width=412` puts the emulator at the same width, so
a pair is directly comparable rather than approximately comparable. Rendering
both platforms would double 74 artifacts to 148 for no added AC coverage.

- Design: `--platform=android --max-edge=900`
- Implementation: `--width=412 --max-edge=900`

### 4.3 Live, authenticated, paired session (DEC-3)

`firebase-auth.strategy.ts` verifies a real Firebase ID token; there is no dev
bypass to add (adding one would be new production auth surface, which this
story must not create). So:

- The preview entrypoint signs in for real before `runApp`, using credentials
  passed at launch: `--dart-define=PREVIEW_EMAIL=` / `--dart-define=PREVIEW_PASSWORD=`.
  **No credential is committed** — this preserves the existing
  "ships no real credentials" property of `main_preview.dart`. Unset means the
  current unauthenticated behaviour, unchanged.
- Seeding runs over the **existing public HTTP API only** (P7), never against
  Postgres directly and never by adding a backend endpoint. Two dev accounts
  are signed in through the Firebase Auth REST endpoint
  (`accounts:signInWithPassword`, using the web API key already present in
  `mobile/lib/firebase_options.dart`), then paired through the real invitation
  endpoints, then populated through the real gallery/timeline/jar/expense/
  message/alarm/vibe endpoints. This is why P2 (backend) is `NOT_APPLICABLE`:
  the state is real, but no backend file changes.

Android emulator networking: `localhost:3005` inside an emulator is the
emulator, not the host. Run `adb reverse tcp:3005 tcp:3005` before capture so
the story's `--dart-define=CUPID_API_BASE_URL=http://localhost:3005` resolves
to the host backend; otherwise use `http://10.0.2.2:3005`. The report must
state which was used.

### 4.4 Chrome wrapping rule (DEC-4)

AC4 says "normally reached through app navigation", which is a per-screen fact,
not a global one. `AppShell` mounts Home / Chat (gated) / Gallery as tab
destinations and pushes everything else as a full-screen route that covers the
tab bar. So the rule is:

Wrap a preview entry in real `AppShell`/`CupidTabBar` chrome when **either**
(a) it is an `AppShell` tab destination (`home`, `chat`, `gallery`), **or**
(b) its P5 design reference visibly shows the bottom tab bar.

This is why P8 depends on P5: the decision is read off the rendered reference
per screen, not guessed. The report records, per screen, whether chrome was
applied and which limb of the rule applied. Chat's tab only exists when
`ChatEntryGate` reports unlocked, which the P7 paired seed guarantees.

## 5. Phases Overview

The following table is mandatory. Keep all columns exactly as shown so Scrum
Master and implementation agents can route phases without guessing.

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P1 | Tech Lead | architecture | None | NO | none | story_master.md | none | n/a | NOT_APPLICABLE |
| P2 | Backend Developer | backend | None | NO | none | story_master.md | none | n/a | NOT_APPLICABLE |
| P3 | Frontend Developer | frontend | None | NO | none | story_master.md | none | n/a | NOT_APPLICABLE |
| P4 | DevOps | devops | None | NO | none | story_master.md | none | n/a | NOT_APPLICABLE |
| P5 | Mobile Developer | mobile | None | YES | `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/` | `cupid-app-design-system/project/Cupid App.dc.html`, `data/devops/system/design-fidelity-config.json`, `render-design-canvas.js` | 37 × `design-reference-<id>-android.png` | tool exit 0 per screen | DONE |
| P6 | Mobile Developer | mobile | None | YES | `mobile/lib/main_preview.dart`, `mobile/lib/preview/`, `mobile/android/app/src/debug/AndroidManifest.xml` | story_master.md, `mobile/lib/core/navigation/app_shell.dart`, `mobile/lib/core/di/service_locator.dart` | runtime screen switching, live-session bootstrap, AppShell chrome wrapper, registry structure | `flutter analyze`, `flutter test` | DONE |
| P7 | Mobile Developer | mobile | None | YES | `mobile/tool/` | `backend/src/modules/**/*.controller.ts`, `mobile/lib/firebase_options.dart` | `mobile/tool/seed_preview_state.mjs`, documented seed procedure | script run against live backend exits 0 | DONE |
| P8 | Mobile Developer | mobile | P5, P6 | NO | `mobile/lib/main_preview.dart`, `mobile/lib/preview/` | §3 inventory, P5 references, `mobile/lib/features/**` | all 37 canvas ids registered incl. not-implemented placeholders | `flutter analyze`, `flutter test` | DONE |
| P9 | Mobile Developer | mobile | P7, P8 | NO | `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/` | live backend, seeded state, booted emulator, `capture-mobile-screen.sh` | 37 × `implemented-<id>-<device>.png` | tool exit 0 per screen | DONE |
| P10 | Mobile Developer | mobile | P5, P9 | NO | `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/` | 19 capture pairs (`alarm`..`jarnew`) | `visual-fidelity-report-part-a.md` | n/a | DONE |
| P11 | Mobile Developer | mobile | P10 | NO | `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/` | 18 capture pairs, part A | `visual-fidelity-report.md` (assembled, 37/37) | n/a | DONE |

Reasons for the terminal `NOT_APPLICABLE` statuses (Status column kept to the
bare token per the mandatory table format; rationale recorded here instead):

- P1 (architecture): the preview harness is dev-only scaffolding that ships in
  no release entrypoint. It introduces no runtime component, no interface, no
  data shape, and no deployment surface. The four decisions this story does
  need (DEC-1..DEC-4, §4) are recorded in this plan; a separate architecture
  document would restate them and nothing else.
- P2 (backend): no file under `backend/` is read-write in this story. Paired
  and populated state is produced by calling the existing public HTTP API
  (DEC-3). Adding a seed endpoint or an auth bypass would be new production
  surface the story does not ask for.
- P3 (frontend): REQ-001 has no web frontend.
- P4 (devops): the backend runtime, the emulator, and the Playwright tooling
  are all already provisioned and already in the runtime registry. Bringing
  the backend up for a capture run is *executing* a registered runtime, not
  changing one. No registry, environment, or deployment file is touched.

The P10/P11 split is by evidence volume, not by file: judging 37 screens means
loading 74 images plus writing 37 sourced verdicts, which does not fit one
specialist pass. Each part is a self-contained set of screens; P11 assembles
the single authoritative report the requirement's Design Conformance AC names
as its coverage baseline.

### 5.2 Phase Detail

**P5 — 37 design references.** Runs before and independently of all harness
work; it needs nothing but the locked bundle. Per DEC-2, `--platform=android`.
Watch for the `hide_selectors matched nothing` warning from
`render-design-canvas.js` — if it fires, the locked selector has gone stale
against the bundle and the phase stops with a blocker rather than shipping 37
references carrying prototype chrome.

**P6 — harness foundation.** Three separable pieces, one file cluster:
runtime screen switching (DEC-1), the optional live-session bootstrap (DEC-3),
and an `AppShell` chrome wrapper the registry can opt a screen into (DEC-4).
Restructure the registry so an entry carries `{builder, wrapInShell, seedNote}`
instead of a bare `WidgetBuilder`; the current 10 entries migrate unchanged.
`main_preview.dart` is the only existing file edited. `needsFixtures` and the
`_PreviewIndex` fallback stay — they are the visible-gap mechanism, and P8
empties the list rather than deleting it.

**P7 — seeding.** One script, HTTP only (DEC-3). It must be idempotent and it
must print, per screen area, exactly what it seeded — AC3 requires the report
to state seeded state per screen, and that text should come from the script's
own output rather than from recollection. Scope the seed to what the 37 screens
actually need to render meaningfully: one paired couple, a few messages, a few
gallery items, a timeline event or two, one dream jar with contributions, a
couple of expenses, one alarm, one vibe.

**P8 — complete the registry.** Wire the 17 implemented screens from §3 using
`getIt<T>()` and seeded ids. For the 10 unimplemented screens, register a real
Flutter-rendered `NOT_IMPLEMENTED` placeholder naming the canvas id, so
`implemented-<id>-*.png` exists and is honest about what the app does today.
Set `wrapInShell` per screen by DEC-4, reading each P5 reference. Resolve the
two questionable mappings from §3. `needsFixtures` must end empty.

**P9 — 37 implementation captures.** `adb reverse tcp:3005 tcp:3005`, backend
live, seed applied, one `flutter run` of the preview target, then 37 `--route`
captures at `--width=412`. Any screen that renders an error or empty state is
a P7 seeding defect to fix and re-capture, **not** a design deviation to
record — that conflation is exactly what the prior audit got wrong.

**P10 / P11 — verdicts.** Per screen: view both PNGs, record `MATCH` or
`DEVIATION` with concrete, specific detail (what element, where, how it
differs). A file-size ratio is not a verdict and satisfies nothing (AC2). Also
record per screen: seeded state (AC3), chrome applied yes/no and why (AC4).
For `alarm` and `home`, whose prior FAIL findings are out of scope to
re-litigate, state explicitly whether the AppShell + backend-live fix changed
the rendered result — never silently overwrite the earlier finding.

## 6. Build And Verification Gate

Source-changing phases (P6, P7, P8):

- `cd mobile && flutter analyze` — clean.
- `cd mobile && flutter test` — no regression against the 890-test baseline
  recorded in `req_master.md` § Deployment Status.

No new unit test is mandated for the preview registry. Its verification is the
74 rendered artifacts, which is stronger evidence than a widget test that would
need Firebase and `getIt` mocked to run at all. AC6 is explicit that tooling
existence proves nothing.

Runtime startup gate (P7, P9), scoped to this story's capture run only:

- Backend live and answering at `http://127.0.0.1:3005` before seeding or
  capturing.
- One booted Android emulator visible to `adb devices`.
- `adb reverse tcp:3005 tcp:3005` established (or `10.0.2.2` substituted, and
  recorded in the report).

Evidence gate (P5, P9, P10, P11) — this is what the story is actually judged on:

- 37 `design-reference-*.png` and 37 `implemented-*.png` present under the
  evidence root (AC1).
- 37 recorded verdicts with concrete detail; zero ratio-only and zero
  zero-evidence rows (AC2, AC5).

## 7. Open Questions

**OQ-1 (Product Owner ruling requested; does not block P5–P9).** The ten
screens in §3 have no implementation. STORY-017's requirement-level AC in
`req_master.md` § Design Conformance Acceptance Criterion says "Every mobile
screen **shipped** under REQ-001 must be captured and compared", which does not
reach an unshipped screen; STORY-018 AC1 says all 37 must have an
`implemented-*.png`. Both are satisfiable at once, and this plan's default does
so: render a real placeholder capture and record
`DEVIATION — screen not implemented` for each of the ten. What needs a ruling
is only whether those ten are then **approved scope cuts** (logged through
`## Open Question Triage / Approved Scope Change`) or **defects** feeding the
downstream code-fix hardening stories. That ruling changes no capture work; it
changes how P11 labels ten rows and what Scrum Master schedules next. It can be
answered any time before P11.

**OQ-2 (resolved inside the story, no external input).** The `gallery` →
`GalleryViewerScreen` and `jarnew` → `ContributionHistoryScreen` mappings
inherited from `main_preview.dart`'s comment are unverified. P8 resolves them
against the P5 design references and records the result.

No UX Designer input is required. The 37 screens are already fully designed in
the locked, fingerprinted bundle, and this story renders that source rather
than interpreting it. No new screen, state, flow, or responsive behaviour is
designed here.

## 8. Result Log

- 2026-08-12 — Tech Lead (`Mode: coding-plan`): confirmed feasibility against
  the tooling on `main`. Verified the canvas exposes exactly 37 screen ids;
  verified 10 of them have no implementation (§3); verified the backend has no
  auth bypass or seed route, making a real signed-in paired session mandatory
  (DEC-3); identified the 37-rebuild cost of compile-time `PREVIEW` and planned
  it out (DEC-1). Single-lane mobile plan: P1–P4 `NOT_APPLICABLE`, P5–P11
  `PENDING`. One Product Owner ruling requested (OQ-1), non-blocking. No
  implementation code written.
</content>
</invoke>
