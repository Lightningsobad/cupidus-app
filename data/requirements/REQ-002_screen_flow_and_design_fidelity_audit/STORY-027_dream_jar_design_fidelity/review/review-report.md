# Review Report — STORY-027 Design Fidelity: Dream Jar

Outcome: PATCH_REQUIRED

Review type: `full-story-review` (round 1)
Scope gate: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-027_dream_jar_design_fidelity/review/scope-gate.md`
Story: STORY-027 — Complexity `trivial`, Story-Class `trivial`, Implementation Lane `mobile`
Diff baseline: `23fbaf4b8c0107e1374e8fbe2516f61ef2f5641e` → `73c6414`
Files reviewed: 17 (13 `mobile/lib`, 4 `mobile/test`) + `visual-fidelity/` evidence

## Rationale

The visual transcription work is strong and mostly correct: 13 recorded
deviations were genuinely fixed in code, the jar illustration is a faithful
`CustomPainter` transcription with correct clamping, and the regression test
pins real structural values. Two things block closure.

One is a correctness defect this story introduced: the new per-partner
comparison card renders wrong data on the real navigation path, and neither the
emulator capture nor any test exercises that path. The other is that three
design copy strings were left uncorrected while the evidence still records a
passing visual verdict, which AC2 and the story's own In Scope #2 do not allow.

Both fixes are small and fully available to the implementation lane, so this is
rework rather than a blocked story.

## Blocking findings

### B1 — Comparison card mis-attributes every contribution in the shipped app

`DreamJarDetailScreen.currentUserId` is optional and nullable
(`mobile/lib/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart:24`),
and **neither production call site supplies it**:

- `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart:45-48` (single-jar shortcut)
- `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart:219-224` (jar card tap)

With `currentUserId == null`, `PartnerSplitTotals.of` attributes *everything* to
the partner by design
(`mobile/lib/features/dream_jar/presentation/widgets/partner_split_card.dart:30-34`).
So on the real screen every user sees:

- "Bạn" = `0` with an empty bar (`heightFactor` 0 via `partner_split_card.dart:188-190`)
- "Người ấy" = the entire jar total, bar at the 78% lead fill
- footer copy = `dream_jar_partner_split_partner_ahead(<full jar total>)`

This story made the latent nullable parameter user-visible. Before the change,
`DreamJarDetailCubit` never fetched contributions — `_loadContributions()` is
new in this diff (`dream_jar_detail_cubit.dart:130-140`, added at `loadJar()`
line 77 and `addContribution()` line 111) — so `state.contributions` was always
empty and the card had nothing to mis-attribute. Deviation #13 in the fidelity
report states this directly ("The screen never loaded contributions").

Why the evidence did not catch it — every path that renders a correct split
injects an id the production route never provides:

| Path | `currentUserId` |
| --- | --- |
| `main_preview.dart:344-346` (the emulator capture) | `'preview-self'` / `getIt<BackendUserIdStore>().backendUserId` |
| `dream_jar_design_fidelity_test.dart:197, 217, 237` | `'me'` |
| `dream_jar_detail_screen_test.dart:198` | `'me'` |
| `dream_jar_list_screen.dart:45, 222` (production) | *not passed → `null`* |

Fails AC4 ("comparative per-partner contribution display ... matches exactly")
and, for the shipped screen, AC1 and AC2. Same wiring also leaves
`ContributionHistoryScreen` without a self id
(`dream_jar_detail_screen.dart:111`), so history rows never take the self
variant (`contribution_history_screen.dart:244`) — pre-existing, but repaired by
the same fix.

The dependency already exists: `main_preview.dart:346` reads
`getIt<BackendUserIdStore>().backendUserId`. Note `HomeScreen`
(`home_screen.dart:123`) constructs `DreamJarListScreen` without an id either,
so thread it or resolve it in the list screen.

### B2 — Three `vi` copy strings still deviate, under a `VISUAL_FIDELITY: PASS`

`visual-fidelity-report.md` "Deltas NOT corrected" records three uncorrected
design deviations in `mobile/lib/l10n/arb/app_vi.arb` (e.g. `dream_jar_remaining`
at line 178). Two are directly visible in the images I compared:

| Surface | Design reference | Implemented capture |
| --- | --- | --- |
| Hero remaining pill | `Còn 1.100.000₫ nữa thôi` | `Còn thiếu 1.100.000₫ nữa thôi` |
| Comparison card title | `Ai thương cái hũ hơn` | `Ai yêu hũ tiền hơn` |
| Jar-full pill (state not captured) | `Đầy rồi! Đặt vé thôi` | `Đầy rồi! Đặt vé thôi nào` |

AC2 requires that a deviation found during this story's audit "is corrected in
the rendered app (not merely documented)", and In Scope #2 says the same. The
story's Out of Scope section excludes only new features/states/interactions and
light-theme/`en` visual QA — it does not exclude copy. Reviewer rule 12e2 also
makes any visible discrepancy a `FAIL` with the delta recorded, so the recorded
`VISUAL_FIDELITY: PASS` is not supportable as written.

The report attributes the deferral to write scope ("A scope extension was
requested and not granted"). No artifact in the story folder records that
decision, and a worker write-scope window is a scheduling limit rather than an
approved Product Owner scope change, so it does not satisfy the rule-14
exception. Route the rework with `mobile/lib/l10n/arb/app_vi.arb` added to the
write scope, or have Scrum Master record an explicit approved scope carve-out —
in which case the verdict line still needs to change from `PASS`.

Scope note: only the `vi` values are in scope. OQ5 keeps `en` user-facing visual
QA out of scope, so do not treat `app_en.arb` copy as part of this fix beyond
whatever regeneration requires.

## Action items

| # | Owner | Action |
| --- | --- | --- |
| A1 | `mobile-dev` | Pass the signed-in backend user id to `DreamJarDetailScreen` at `dream_jar_list_screen.dart:45` and `:222` (thread from `HomeScreen`, or resolve `getIt<BackendUserIdStore>().backendUserId` in the list screen as `main_preview.dart:346` already does). |
| A2 | `mobile-dev` | Add a widget test that mounts the detail screen through the production wiring (no explicit `currentUserId` override) and asserts the split is attributed correctly — the current suite only covers the injected-id path. |
| A3 | `mobile-dev` | Correct the three `vi` values in `mobile/lib/l10n/arb/app_vi.arb` and regenerate l10n. Requires the write scope extended to `mobile/lib/l10n/arb/`. |
| A4 | `mobile-dev` | Re-capture `implemented-jar-emulator-5554.png` after A1 and A3 and update `visual-fidelity-report.md`: move rows out of "Deltas NOT corrected" and restate the top-level verdict against what the new capture shows. |
| A5 | `mobile-dev` | Record an `## Entry Point Reachability` section with `Reachable: YES` and the concrete path (Home → Dream Jar list → jar card tap) in the story's evidence. Reachability itself is fine — see the gate table — only the written section is missing. |

## Deferred findings

| # | Finding | Why deferred |
| --- | --- | --- |
| D1 | `_loadContributions()` swallows every error silently (`dream_jar_detail_cubit.dart:134-136`), so a persistently failing contributions call is invisible with no telemetry. | Deliberate, documented best-effort behaviour for a cosmetic aggregate; the jar itself still renders. |
| D2 | Comparison totals reflect only the contributions page already loaded (documented at `partner_split_card.dart:44-48`), so a paginated history under-reports. | Pre-existing backend-aggregate gap, not worsened by this story. |
| D3 | Capture shows the 3-tab shell bar (design has 5), the shell FAB, and omits the design's "Chi tiêu chung" row and "Tạo Dream Jar mới" CTA. | App-shell surfaces owned by other REQ-002 stories; correctly identified by the implementer. |
| D4 | `DreamJarAmountFormat.vnd` dropped the space before `₫` app-wide, which also changes the jar list screen's rendering. | Matches the design source's global `fmt()`; list-screen tests were updated and pass. Flagged only so the `jarlist` story's baseline is not surprised. |

## Risk surfaces and critical gates

| Surface | Gate | Result |
| --- | --- | --- |
| Mobile interaction (quick-add, contribution entry) | Targeted widget/unit tests | PASS — `flutter test test/features/dream_jar test/design_system` → 113 passing. Coverage gap on the production wiring is finding B1/A2, not a gate failure. |
| Mobile rendering / token usage | Static analysis | PASS — `flutter analyze` over the changed scope reports only 2 pre-existing `prefer_initializing_formals` infos in the untouched `contribution_history_cubit.dart`. |
| Mobile navigation / discoverability (rule 12e1, AC5) | Entry point independently verified in code | PASS on substance — `home_screen.dart:123` → `DreamJarListScreen`; `dream_jar_list_screen.dart:219-224` `_JarCard.onTap` → `DreamJarDetailScreen`. A real list action, not URL-only, and the diff does not change it, matching AC5. Written evidence section missing (A5). |
| Design fidelity, mobile lane (rules 12e2/12e3) | Both images exist, both opened and read, `Design-Screen: jar` confirmed | FAIL — images are real and both depict the `jar` screen (verified by reading them, not by file count), and the reference matches the recorded `Design-Screen: jar` in `story_master.md:12`. But the implemented capture visibly contradicts the reference on two copy strings, so the `PASS` verdict does not hold (B2). |
| Runtime startup smoke (rule 12g) | App launches to first screen | NOT REQUIRED — gate applies to non-trivial stories; this story is `Complexity: trivial`. |
| Setup/configuration (rule 12a) | `deployment/configuration-guide.md` | NOT REQUIRED — no env, dependency, runtime-config or manual-setup surface in the diff. The `PREVIEW_JAR_FIXTURE` define is confined to `main_preview.dart` and gated on `_jarFixture == 'design'`, so it cannot affect the shipped entrypoint. |

Not touched, therefore not gated: persistence/schema/migration, security/auth,
external integration, async job/workflow, payment provider, deep link/push,
permissions/device API, local storage/offline, operational command,
generated/typed contract, local Docker/Compose/registry.

## Traceability

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — layout/spacing/colour/typography match exactly | FAIL | Layout, gradient, radius, shadow, padding (`dream_jar_detail_screen.dart:81`, `DreamJarPalette`) all match; two visible copy deviations remain (B2). |
| AC2 — every deviation corrected, not merely documented | FAIL | 13 of 16 corrected; 3 documented only (B2). |
| AC3 — animated SVG fill-level component | PASS | `dream_jar_illustration.dart` — `liquidY = 154 - 108 * clamp(progress/100, 0, 1)` (line 120-121) matches the design formula, clip via `_glassBody` rrect, reduce-motion honoured (line 54), controllers disposed (line 74-78). |
| AC4 — quick-add presets and per-partner comparison, every design state | FAIL | Quick-add matches (`dream_jar_quick_add_section.dart` — 3 presets, emphasized third on `gradientHot`, per-tile glyph colour, in-flight tap gating at `dream_jar_detail_screen.dart:92`). Comparison card renders wrong attribution in production (B1). |
| AC5 — reached through the existing navigation path, no new entry point | PASS | Verified in code; the navigation path is untouched by this diff. |
| OQ5 (light theme / `en`) | Correctly applied | No in-scope AC skipped by over-applying the OQ, and no out-of-scope light/`en` work pulled in. |

## State recommendation

- Uncheck `Implementation (Development)` in `story_master.md`.
- Leave `Review (Reviewer)` unchecked.
- Story status: `IN_PROGRESS`.
- Return to `mobile-dev` with action items A1-A5. Extend the write scope to
  include `mobile/lib/l10n/arb/` and
  `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart`.
- Story is not merge-eligible into
  `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration` until the
  re-review passes.
