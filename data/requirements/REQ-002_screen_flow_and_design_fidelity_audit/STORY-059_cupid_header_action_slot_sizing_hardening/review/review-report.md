# Review Report: STORY-059 CupidHeader Action-Slot FAB Sizing Hardening

Outcome: DEFERRED_ONLY

Reviewer mode: `compact-story-review` | Flow: story | Reviewer: Iris-QC
Story: `REQ-002_screen_flow_and_design_fidelity_audit/STORY-059_cupid_header_action_slot_sizing_hardening`
Complexity: standard | Implementation Lane: shared (mobile-only in practice)
Retro-Type: RED-PATCH — fixes STORY-028, source RWB-20260816-027
Diff baseline: `git show d243864..fe124f3` (declared `BaseHead` `fe124f3` == worktree HEAD)

## Scope Gate

- Review type: compact story review. Scope gate recorded in `review/scope-gate.md`
  (written during the re-verification pass; the original pass relied on this
  inline section only).
- Source/test files in scope (5, within the 8-file compact budget):
  - `mobile/lib/design_system/adaptive/cupid_header.dart`
  - `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart`
  - `mobile/lib/main_preview.dart` (authorized write-scope extension)
  - `mobile/test/design_system/adaptive_widgets_test.dart`
  - `mobile/test/features/dream_jar/presentation/dream_jar_list_screen_test.dart`
- Evidence files in scope: `coding-plan/test-results.md`, `coding-plan/phase-P1-cupid-header-oversized-action-contract.md`, `visual-fidelity/visual-fidelity-report.md` and its 6 PNGs, `story_master.md`, `requirements/requirements.md`, `data/devops/system/runtime-command-registry.json`, checkpoint section "Active item: RWB-027 -> STORY-059".
- Query keys: AC1-AC4, `hasOversizedAction`, `_bandHeight`, `_oversizedActionToolbarHeight`, `PREVIEW_JARLIST_FIXTURE`, `Design-Screen: jarlist`, `Runtime-Smoke`.
- Not opened: `architecture/solution.md`, `ux/uiux-spec.md` (no contract question arose — the `hasOversizedAction` opt-in rationale is fully carried in the phase file and the code doc comment), STORY-034..058 artifacts.

## Outcome rationale

All four acceptance criteria are implemented correctly and are backed by real,
verified evidence: the code change is minimal and behaviour-compatible on the
default path, the AC2 regression pin was genuinely inverted rather than deleted,
and the on-device visual-fidelity comparison is real (I opened all three
captures — they show the actual `jarlist` screen, not a splash, error frame, or
wrong screen, and the header right side is empty in both design and build).

One mandatory operational gate was absent in that pass, which is why it did not
pass at the time — the story carried no registry-backed runtime startup smoke
for the shipped app entrypoint, and `story_master.md` records no `Runtime-Smoke: WAIVED`.
The on-device work that exists does not substitute for it — see BLK-1.

This rationale describes the original pass. BLK-1 was subsequently closed with
registry-backed evidence; see `## Re-Verification` at the end of this report for
the current verdict.

## Acceptance criteria

| AC | Verdict | Evidence verified |
|---|---|---|
| AC1 — no header add action on Dream Jar list, body CTAs remain sole entry point | PASS | Diff replaces the 12-line state-switched `actions` with `actions: const <Widget>[]`; both switch arms gone, no residual `Semantics` wrapper. `_openCreateSheet` and both `CupidPrimaryButton` CTAs are outside the diff hunk, so provably unmodified. Two new widget tests assert `CupidAddAction` `findsNothing` **and** `'New Dream Jar'` `findsOneWidget` in empty and ready states; the ready case correctly uses 2 jars to avoid the single-jar detail bypass at `dream_jar_list_screen.dart:59`. Confirmed on device in both captures. |
| AC2 — pin flips to an explicit correct `Size` | PASS | `adaptive_widgets_test.dart` test renamed and rewritten: `expect(size, const Size(60, 60))` plus `expect(size.height, greaterThan(kToolbarHeight))`. The old `Size(60, 56)` / `== kToolbarHeight` assertions are replaced, not dropped. Explicit `Size` retained per AC2's wording. |
| AC3 — `CupidAddAction` intrinsic size unchanged outside headers | PASS | `cupid_add_action.dart`, `gallery_empty_view.dart` and `expense_history_screen.dart` are absent from `fe124f3 --stat`, so untouched. Change is confined to `CupidHeader`'s own band, not the action's box. |
| AC4 — ordinary header consumers unchanged | PASS | `hasOversizedAction` defaults `false`; `_bandHeight` then returns `kToolbarHeight` on both `preferredSize` and the threaded `AppBar.toolbarHeight`. New test asserts all three heights `== kToolbarHeight`. Independent corroboration: `profile_edit_screen_test.dart` is a real action-bearing consumer and passes **unmodified** (not in the diff), so the default path is behaviour-compatible rather than re-baselined. |

Design-conformance AC required by the RWB item is present and satisfied (AC1 is
that AC, and it is verified against the literal design source, not restated
capability criteria).

## Risk surfaces and critical gates

| Touched surface | Critical gate | Status |
|---|---|---|
| Mobile interaction / shared design-system component contract | Targeted widget + regression tests | PASS — `flutter test` 115/115, re-run after the `main_preview.dart` extension landed, so it reflects the final tree |
| Mobile static analysis | `flutter analyze` on touched files | PASS — 5 items, no issues. Repo-wide failures verified pre-existing and confined to vendored FlutterFire sources under `build/ios/SourcePackages/` |
| Mobile navigation / discoverability | Reachable create-jar entry point after removing the header affordance | PASS on substance (body CTAs verified in code, in tests, and in both captures); the named `## Entry Point Reachability` evidence section is missing — see DEF-1 |
| Design fidelity (design source configured, mobile lane) | Implementer capture + compare, reviewer verifies the artifacts | PASS — verified by opening the images, not by trusting the token. See below |
| Runtime / operational (app boot) | Registry-backed runtime startup smoke | **MISSING** — see BLK-1 |
| Setup/configuration | `deployment/configuration-guide.md` | Not required — no env var, secret, dependency, or manual setup step is introduced |

Visual fidelity verification (skill rule 12e3, performed by reading the images):
`Design-Screen: jarlist` is recorded and resolved from the canvas listing. The
reference PNG genuinely depicts the Dream Jar list (jar collection, create-jar
CTA, "Ví chung" tab active) — it is the screen this story is about, not a
plausible-looking neighbour. Both implemented captures show the real built app
in the correct state with a header carrying no action, matching the reference's
own header. Nothing I saw contradicts the `VISUAL_FIDELITY: PASS`. The report's
two disclosed limits are accurate and correctly scoped: AC2's 60pt band has no
on-device consumer left (widget-test-only, and AC2's own text is about the
widget test, so this is not an evidence shortfall), and the empty-state body was
not compared because the canvas has no empty-state `jarlist` screen — the header
contract, which is state-independent in the design, was still compared.

Authorized write-scope extension verified: `mobile/lib/main_preview.dart` is
confined to the preview harness. The diff adds only `PREVIEW_JARLIST_FIXTURE`,
a fixture jar list, and `_PreviewDreamJarListRepository` overriding `fetchJars`
alone; `_buildJarlist`'s default switch arm still returns
`getIt<DreamJarRepository>()`, so omitting the define leaves the live path
unchanged. Nothing under the shipped `lib/main.dart` entrypoint reads it. The
authorization is recorded by Scrum Master in the checkpoint (2026-08-19), and
the precedent (STORY-020 §7) matches the existing `PREVIEW_EXPENSE_FIXTURE` /
`PREVIEW_JAR_FIXTURE` pattern in the same file. Not a scope violation.

## Blocking findings

**BLK-1 — Registry-backed runtime startup smoke is missing (skill rule 12g).**
Owner: `devops` (or `mobile-dev`, who already holds the `emulator-5560` capture
lease path).

`story_master.md` records `Complexity: standard` and `Implementation Lane:
shared`, so the story-level runtime startup smoke is mandatory, and no
`Runtime-Smoke: WAIVED — <reason>` line exists. No `## Story Runtime Startup
Smoke` section exists in `coding-plan/test-results.md`, and the phase file
states "No emulator, device, e2e, or Playwright gate applies to this phase"
(superseded only for the visual render, not for the boot gate).

The visual-fidelity work does **not** satisfy this gate, and this is the
substantive point rather than a heading technicality: every capture was built
with `-t lib/main_preview.dart`, so the APK launched on `emulator-5560` was the
preview harness, not the shipped app. `lib/main.dart` and its bootstrap
(Firebase init, DI, routing) were never launched in this story. That is exactly
the class of failure 12g exists to catch, and it also means the emulator
currently carries a preview build under the shipped applicationId
`com.snapsofts.cupid`.

Suppliable now — everything needed is already defined in
`data/devops/system/runtime-command-registry.json` under `mobile-app`:

1. Build and install the shipped entrypoint: `buildCommand` `flutter build apk
   --debug`, then install on `emulator-5560`.
2. Run `mobile-app.readiness.command`: `adb -s emulator-5560 shell am start -W
   -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`, then poll
   `dumpsys activity activities` for `ResumedActivity` on that activity
   (`expectExitCode: 0`, `timeoutSecs: 90`).
3. Shut down with `readiness.shutdownCommand` (`am force-stop`).
4. Record the result as a `## Story Runtime Startup Smoke` section in
   `coding-plan/test-results.md` with the exact command and pass line, i.e. the
   app reaches its first screen with no crash and no error screen.

If a documented environment or device constraint prevents step 2, the correct
response is a typed blocker plus a `Runtime-Smoke: WAIVED — <reason>` line in
`story_master.md`, not silent omission.

No other blocking finding. No implementation rework is required to the four
in-scope source/test files — BLK-1 is an evidence gate, and the code as written
should be left exactly as it is.

## Deferred findings

- **DEF-1 — `## Entry Point Reachability` section absent from
  `coding-plan/test-results.md`.** The substance is fully satisfied and I
  verified it independently in code, tests and captures: the create-jar
  capability keeps a discoverable entry point via the `CupidPrimaryButton` CTAs
  in `_EmptyJarsView` and `_JarListBody`, both wired to `_openCreateSheet`, both
  outside the diff. Deferred rather than blocking because the discoverability
  risk the gate guards against is demonstrably absent here (the story removes a
  redundant duplicate affordance and adds none). Cheapest to add during the
  BLK-1 pass, in the same file.
- **DEF-2 — 11 pre-existing `jarlist` design deviations** itemized in
  `visual-fidelity/visual-fidelity-report.md` (missing summary pill, jar
  illustrations, deadline row, "Đang xem" badge, completed-jars row; title and
  CTA copy including an English noun in a `vi` build; shell tab-bar shape). This
  story's diff — one opt-in bool plus one `actions` removal — cannot have caused
  any of them, and no open story owns them. Endorsing mobile-dev's
  recommendation: raise a new RWB item for UI/UX Designer + Product Owner
  scoping rather than absorbing them into this story.
- **DEF-3 — no back chevron on the implemented header** where the design shows
  one (deviation row 2). Pre-existing and correctly explained: the screen is a
  shell tab root at runtime, not a pushed route, so `CupidHeader` has nothing to
  pop. Not an AC1 failure — AC1's operative clause is the absence of the action
  slot, which is satisfied. Belongs with DEF-2's scoping item.

## Traceability

- Requirements: `requirements/requirements.md` AC1-AC4, all four verified above.
  `## Open Question Impact` reviewed — OQ5 (light theme / EN locale) is
  correctly assessed as not relevant to component sizing; no OQ was over- or
  under-applied, so no OQ-driven scope defect.
- UX / architecture: the revised UX finding (shared `showHeader` template has no
  icon-action slot) is the basis of AC1 and is confirmed by the design reference
  I opened. The Tech Lead `hasOversizedAction` opt-in contract is implemented as
  specified, including the deliberate choice of 60 over 64 — correct, since
  `AppBar` stretches actions to a tight cross-axis constraint equal to the band,
  making the band the exact rendered height rather than a ceiling.
- Testing evidence: `coding-plan/test-results.md` (analyze clean, 115/115),
  `coding-plan/phase-P1-...md` Status DONE,
  `visual-fidelity/visual-fidelity-report.md` `VISUAL_FIDELITY: PASS` with six
  PNGs, three of which I opened and confirmed.
- Git: implementation commit `fe124f3`, baseline `d243864`, 5 source/test files.

## State recommendation

- Leave `Review (Reviewer)` **unchecked** in `story_master.md`.
- Leave `Implementation (Development)` **unchecked** (skill rule 7 for
  `PATCH_REQUIRED`).
- Story status: `IN_PROGRESS`.
- Route BLK-1 to `devops` (or `mobile-dev`) as an evidence-only pass — no source
  change. Fold DEF-1 into the same pass. Do not re-run the visual-fidelity
  capture; it is verified and complete.
- Do not mark STORY-059 or RWB-20260816-027 resolved until BLK-1 is recorded.
- DEF-2/DEF-3 warrant a new RWB item, not rework inside this story.

> Superseded by `## Re-Verification` below. The state recommendation above
> describes the original `PATCH_REQUIRED` pass and is retained for traceability
> only; the authoritative verdict is the single verdict line at the top of this
> report.

## Re-Verification

Re-verification pass (evidence-only, no re-review of AC1-AC4 and no re-read of
the implementation diff — those passed in the original pass and nothing in that
evidence changed). Scope: confirm BLK-1 and DEF-1 are genuinely closed.

Evidence read: `coding-plan/test-results.md` `## Story Runtime Startup Smoke`
(lines 106-137) and `## Entry Point Reachability` (lines 139-155), cross-checked
against `data/devops/system/runtime-command-registry.json` `runtimes.mobile-app`
(registry lines 119-204).

**BLK-1 — CLOSED.** All five checks pass:

- Runtime Id `mobile-app` matches `runtimes.mobile-app` (registry line 119),
  which is the correct scoped app for this mobile-only story.
- Shipped entrypoint confirmed: build is `flutter build apk --debug` (identical
  to registry `buildCommand`, line 134) with the default target, explicitly not
  `-t lib/main_preview.dart`. This is the substantive fix — the preview-harness
  substitution that caused BLK-1 is gone, and `lib/main.dart` bootstrap
  (Firebase init, DI, routing) was actually launched. Corroborated
  independently: `mobile/build/app/outputs/flutter-apk/app-debug.apk` exists,
  234,663,753 bytes, mtime 2026-08-20 10:38 — a real debug build, not a
  transcribed claim.
- Readiness command matches registry `readiness.command` (line 187): `adb -s
  "$MOBILE_DEVICE_SERIAL" shell am start -W -n
  com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`, then a 30x/2s
  `dumpsys activity activities` poll for `ResumedActivity` on that same
  activity. The only textual difference is the omitted `>/dev/null` redirect,
  which is what made `Status: ok` / `LaunchState: COLD` / `TotalTime: 10712`ms
  observable — a strictly evidence-improving deviation, not a substitution.
  `readiness.type` is `command` (live-process probe per devops/SKILL.md 14b1),
  so the section's argument that no `backend-api` round-trip is required is
  correct and the stale `CUPID_API_BASE_URL` default does not gate this.
- `Result: **PASS**` and `Shutdown: **PASS**` are both literally present with
  evidence: launch reached `ResumedActivity` on the first poll (exit 0, 10.7s
  vs. the 90s `timeoutSecs`), and shutdown used registry
  `readiness.shutdownCommand` `am force-stop com.snapsofts.cupid` (exit 0) with
  a post-check confirming the app was no longer the resumed activity.
- Install deviation accepted: `adb install -r` on the exact debug APK instead of
  the precondition's `flutter install`. The stated reason (plain `flutter
  install` silently rebuilds/installs a release variant) is correct and makes
  the evidence stronger, since it guarantees the launched binary is the debug
  APK that was just built.

**DEF-1 — CLOSED.** `## Entry Point Reachability` now documents the surviving
create-jar entry point as the `CupidPrimaryButton` CTA in both `_EmptyJarsView`
(empty state) and `_JarListBody` (ready state), both wired to the same
`_openCreateSheet` handler the removed header action called. This matches what I
verified independently in the original pass from code, the AC1 widget tests, and
the on-device captures recorded under `## AC coverage` in this same file. The
section is correctly marked documentation-only with no re-capture claimed.

**DEF-2 / DEF-3 — unchanged, still deferred.** Pre-existing `jarlist` design
deviations and the missing back chevron are outside this story's two-line diff
and belong to a new RWB item. Not re-opened here and not blocking.

Revised verdict, from `PATCH_REQUIRED` to `DEFERRED_ONLY`. No blocking findings
remain. Implementation code is unchanged since the original pass and must stay
as written.

Revised state recommendation:

- Mark `Implementation (Development)` and `Review (Reviewer)` **checked** in
  `story_master.md`.
- STORY-059 is eligible for `DONE` (Scrum Master owns that transition).
- RWB-20260816-027 may be marked resolved.
- File DEF-2/DEF-3 as a new RWB item; they do not block this story.
