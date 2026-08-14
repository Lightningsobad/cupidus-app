# Review Report — STORY-027 Design Fidelity: Dream Jar

Outcome: PATCH_REQUIRED

Review type: `compact-story-review` (round 2, verifying round-1 rework)
Scope gate: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-027_dream_jar_design_fidelity/review/scope-gate.md`
Story: STORY-027 — Complexity `trivial`, Story-Class `standard`, Implementation Lane `mobile`
Diff baseline: `46187354f3356c3f7b46d21de11e9d7330f2e712` → `cda60734a0f32d2ce9da347d933ca038dc65e08a`
Files reviewed: 5 (2 `mobile/lib`, 1 `mobile/test`, 2 evidence)
Round-1 report: superseded by this file; see git history at `73c6414`.

## Rationale

Round 1 raised two blocking findings. B2 (three uncorrected `vi` copy strings)
is fully and correctly fixed — verified in the ARB source and confirmed
visually by opening the re-captured emulator PNG against the design reference.

B1 (comparison card mis-attribution on the real navigation path) is only
partially fixed. The wiring was added, but the store it reads from is never
populated on a warm app restart, so the shipped screen still shows the round-1
defect on the dominant real-world path. The same change also breaks an existing
green test in a suite outside the gates this story runs.

Both remaining items are small and available to the implementation lane, so
this is rework rather than a blocked story.

## Round-1 action item verification

Each item was verified against code and evidence, not against the task list.

| # | Claim | Verified | Result |
| --- | --- | --- | --- |
| A1 | Signed-in id threaded into the production call sites | `dream_jar_list_screen.dart:36` resolves `getIt<BackendUserIdStore>().backendUserId`; passed at `:60` (single-jar shortcut) and `:243` (jar card tap) | PARTIAL — wiring present, but the value is `null` for a whole session after restart (B4), and the `getIt` lookup breaks an existing test (B3) |
| A2 | Widget test covering production-wiring split attribution | `dream_jar_list_screen_test.dart:191` and `:212` mount `DreamJarListScreen(repository:)` with no `currentUserId` override, register the real `BackendUserIdStore` in `getIt`, and assert `2,18tr` / `1,72tr` / `You're 460.000₫ ahead` on both call sites | DONE — both tests present and green |
| A3 | Three `vi` strings corrected and l10n regenerated | `app_vi.arb` now `Còn {amount} nữa thôi`, `Đầy rồi! Đặt vé thôi`, `Ai thương cái hũ hơn`. Grep for the three old values across `mobile/lib` and `mobile/test` returns nothing. Generated l10n is untracked (only the two `.arb` files are in `git ls-files mobile/lib/l10n`), so no stale generated output can be committed | DONE |
| A4 | Capture re-taken and report restated | Opened `implemented-jar-emulator-5554.png` (141083 B, replaced in this commit) and `design-reference-jar-android.png` side by side. Both render `Còn 1.100.000₫ nữa thôi` and `Ai thương cái hũ hơn`; both show `2,18tr` / `1,72tr`. Round-1's two visible copy deltas are gone | DONE — see B4 for one overstated report row |
| A5 | `## Entry Point Reachability` section | Present in `visual-fidelity-report.md` with `Reachable: YES`, the Home → list → jar card path, and the three code hops | DONE |

Round-1 B2 is resolved. Round-1 B1 is not (B4 below).

## Blocking findings

### B3 — The A1 change breaks an existing green test

`DreamJarListScreen.build` now calls `getIt<BackendUserIdStore>()` unguarded
(`mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart:36`).
`mobile/test/features/home/home_screen_test.dart` mounts `HomeScreen`,
registers only `DreamJarRepository` in `getIt` (`:26-28`), and taps through to
`DreamJarListScreen` (`:60-63`). That now throws:

```
Bad state: GetIt: Object/factory with type BackendUserIdStore is not registered inside GetIt.
#5  DreamJarListScreen.build (dream_jar_list_screen.dart:36:29)
The relevant error-causing widget was:
  DreamJarListScreen ... home_screen.dart:123:39
```

`flutter test test/features/home/home_screen_test.dart` → `00:00 +0 -1: Some
tests failed.` I ran this myself; it is not a stale result.

The story's own gate command (`test/features/dream_jar test/design_system`)
cannot see this, which is why it passed at 115. The break is test-only —
production registers the store lazily at `service_locator.dart:118` — but a red
test in the repository blocks the build gate regardless.

Cheapest correct fix: register `BackendUserIdStore` in that test's `setUp`,
exactly as `dream_jar_list_screen_test.dart:104-107` now does. Do **not** fix it
by making the production lookup fall back to `null` on
`getIt.isRegistered<...>()` — that would silently reintroduce B1/B4.

### B4 — Round-1 B1 still reproduces after a warm app restart

`BackendUserIdStore` holds a plain in-memory field and documents itself as
`null` "before the first successful sign-in of this session"
(`mobile/lib/core/realtime/backend_user_id_store.dart:10-14`). The only writer
in shipped code is `AuthRepository._syncBackendProfile()`
(`auth_repository.dart:119-132`), and it is called only from the five explicit
sign-in/register entry points (`:52, :66, :72, :78, :84`). Grep for
`updateFromLoginResponse` across `mobile/lib` returns exactly those two writers
plus `preview/preview_session_bootstrap.dart:38`.

The restart path never touches any of them. `SessionGateCubit._resolveSignedIn`
(`session_gate_cubit.dart:97-118`) restores a persisted Firebase session, reads
an id token, and emits `SessionGateAuthenticated` straight to Home — no
`AuthRepository` sign-in call, so no backend profile sync.

So for every session that begins with "user opens the already-signed-in app",
`getIt<BackendUserIdStore>().backendUserId` is `null` for the entire session,
`DreamJarListScreen` passes `null` down, and `PartnerSplitTotals.of` attributes
every contribution to the partner (`partner_split_card.dart:30-34`). The user
sees "Bạn" = 0 with an empty bar and the whole jar total under "Người ấy" —
the identical round-1 B1 symptom, on what is the more common of the two paths.

The dartdoc at `partner_split_card.dart:20-22` states the `null` case
"attributes every contribution to the partner rather than guessing, so the card
never mislabels a contribution as the user's own". That reasoning is inverted:
attributing the user's own contributions to the partner *is* a mislabel, and it
is silent.

Fixing the auth/session bootstrap is out of scope for a design-fidelity story
and is an app-wide gap this story did not create. But there is an in-scope,
precedent-backed mitigation inside the Dream Jar feature: when `currentUserId`
is `null`, do not render a fabricated split. This repository already models
exactly that choice — `AntiGhostPendingUnknownRole`
(`anti_ghost_cubit.dart:103-110`) exists specifically because
"`BackendUserIdStore.backendUserId` has not resolved yet, so mine-vs-partner
cannot be derived", and it degrades to a read-only summary "rather than
guessing". `PartnerSplitCard` should degrade the same way instead of showing
confident wrong numbers.

Evidence follow-on: `visual-fidelity-report.md` row 17 currently records the
production route as fixed outright ("Split attributed to the signed-in user").
Restate it to cover only the fresh-sign-in session, and record the restart
limitation.

## Action items

| # | Owner | Action |
| --- | --- | --- |
| A6 | `mobile-dev` | Register `BackendUserIdStore` in `mobile/test/features/home/home_screen_test.dart`'s `setUp` (mirror `dream_jar_list_screen_test.dart:104-107`) so the suite is green again. Requires `mobile/test/features/home/` in the write scope. |
| A7 | `mobile-dev` | Make `PartnerSplitCard` degrade when `currentUserId == null` instead of attributing the whole jar to the partner — follow the `AntiGhostPendingUnknownRole` precedent. Correct the inverted dartdoc at `partner_split_card.dart:20-22`. Add a test pinning the `null` case. |
| A8 | `mobile-dev` | Restate `visual-fidelity-report.md` row 17 so it does not claim the real route is fixed unconditionally; note the warm-restart limitation and the A7 degradation. |
| A9 | `mobile-dev` | Re-run `flutter test test/features/dream_jar test/design_system test/features/home` — widen the recorded gate command so a `getIt` dependency added to a screen cannot again break a caller's suite unseen. |

## Residual risks

| # | Risk | Disposition |
| --- | --- | --- |
| R1 | `BackendUserIdStore` is never repopulated on session restore, so every consumer (`expenses_route.dart:58`, chat, reminders, realtime `joinRoom`) sees `null` after a warm restart. | App-wide, pre-existing, and outside this story. Raise as a separate REQ-002 or platform bug; A7 only stops Dream Jar from rendering wrong data because of it. |

## Deferred findings

Round-1 D1-D4 were re-confirmed as correctly deferred and are not re-argued
here. See `73c6414` for their full text.

| # | Finding | Why deferred |
| --- | --- | --- |
| D1 | `_loadContributions()` swallows every error silently. | Deliberate best-effort behaviour for a cosmetic aggregate. |
| D2 | Comparison totals reflect only the loaded contributions page. | Pre-existing backend-aggregate gap. |
| D3 | Capture shows the 3-tab shell bar and shell FAB versus the design's 5 tabs. | App-shell surfaces owned by other REQ-002 stories. |
| D4 | `DreamJarAmountFormat.vnd` dropped the space before `₫` app-wide. | Matches the design source's global `fmt()`. |

## Risk surfaces and critical gates

| Surface | Gate | Result |
| --- | --- | --- |
| Mobile interaction | `flutter test test/features/dream_jar test/design_system` | PASS — re-run this round, `All tests passed!` at 115 (round 1 was 113; A2 added 2). |
| Regression outside the story's gate scope | `flutter test test/features/home/home_screen_test.dart` | FAIL — B3. Introduced by this commit. |
| Mobile rendering / token usage | `flutter analyze lib/features/dream_jar lib/design_system lib/main_preview.dart test/features/dream_jar` | PASS — re-run this round; 2 issues, both pre-existing `prefer_initializing_formals` infos in the untouched `contribution_history_cubit.dart:70-71`. Nothing new. |
| Mobile navigation / discoverability (rule 12e1, AC5) | Entry point verified in code and now documented | PASS — A5 section present and accurate; the diff does not add or move an entry point. |
| Design fidelity, mobile lane (rules 12e2/12e3) | Both images opened and compared | PASS — round-1's two visible copy deltas are gone. Hero pill and comparison title now match the reference exactly. `Design-Screen: jar` still correct. |
| Runtime startup smoke (rule 12g) | App launches to first screen | NOT REQUIRED — `Complexity: trivial`. |
| Setup/configuration (rule 12a) | `deployment/configuration-guide.md` | NOT REQUIRED — no env, dependency, or runtime-config surface in the round-2 diff. |

Not touched, therefore not gated: persistence/schema/migration, security/auth,
external integration, async job/workflow, payment provider, deep link/push,
permissions/device API, local storage/offline, operational command,
generated/typed contract, local Docker/Compose/registry.

## Traceability

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — layout/spacing/colour/typography match exactly | PASS | Round-1's two visible copy deviations are corrected and confirmed in the re-capture. |
| AC2 — every deviation corrected, not merely documented | PASS | All 16 recorded deviations are now corrected in code; the "Deltas NOT corrected" section is empty. |
| AC3 — animated SVG fill-level component | PASS | Unchanged this round; verified in round 1. |
| AC4 — quick-add presets and per-partner comparison, every design state | FAIL | Quick-add matches. The comparison card is correct on a fresh sign-in but still mis-attributes the entire jar after a warm restart (B4). |
| AC5 — reached through the existing navigation path, no new entry point | PASS | Verified in code; now also documented (A5) and covered by the two new tests. |
| OQ5 (light theme / `en`) | Correctly applied | The `vi`-only ARB edits respect the OQ; `app_en.arb` untouched. |

## State recommendation

- Leave `Implementation (Development)` unchecked in `story_master.md`.
- Leave `Review (Reviewer)` unchecked.
- Story status: `IN_PROGRESS`.
- Return to `mobile-dev` with action items A6-A9. Extend the write scope to
  include `mobile/test/features/home/` and
  `mobile/lib/features/dream_jar/presentation/widgets/partner_split_card.dart`.
- Story is not merge-eligible into
  `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration` until the
  re-review passes.
