# Review Report — STORY-006 Couple Title Shows Both Partner Names

Outcome: DEFERRED_ONLY

- Review type: `compact-story-review` (`Flow: parallel-story`)
- Requirement: REQ-010 Home dashboard deferred scope completion
- Story: STORY-006 (`Complexity: standard`, `Implementation Lane: backend + mobile`)
- Reviewer run: 2026-08-25 (round 1: `PATCH_REQUIRED`; round 2 re-verification:
  `DEFERRED_ONLY`)
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-010_home_dashboard_deferred_scope_completion-STORY-006`
- Branch: `codex/REQ-010_home_dashboard_deferred_scope_completion-STORY-006`
- Scope gate: `review/scope-gate.md` (also summarized inline below)

## Round 2 — Patch Re-verification (2026-08-25)

Re-verified F-1, F-2, and F-3 only. AC1-AC3 were not re-verified and did not
need to be: `git diff --name-status 190f5c3..9380603` shows the patch round
touched only `data/**` artifacts — no file under `mobile/lib/**`,
`mobile/test/**`, or `backend/**` changed — so the code the ACs passed against
in round 1 is byte-identical. No new defect was introduced.

Range re-inspected: `9e6f3796..9380603` (both phases plus the patch round and
the Scrum Master story-boundary seal commit on top of it).

| Finding | Round 2 verdict | Evidence I checked myself |
| --- | --- | --- |
| F-1 startup smoke | **RESOLVED** | `## Story Runtime Startup Smoke` present with `Result: PASS`; screenshot opened as an image and confirmed a real painted first screen |
| F-2 entry reachability | **RESOLVED** | `## Entry Point Reachability` present with `Reachable: YES` and a 5-step concrete path |
| F-3 fidelity artifact contract | **RESOLVED** | `VISUAL_FIDELITY: PASS` literal present; contract image pair present and byte-verified; `Design-Screen` recorded; anchor citations re-checked line by line against the locked canvas |

All three previously blocking findings are closed. Only the two pre-existing
deferred findings (D-1, D-2) carry forward, which is what makes the outcome
`DEFERRED_ONLY` rather than `CLEAN`.

### F-1 re-verification detail

`coding-plan/test-results.md:227` carries the required `## Story Runtime Startup
Smoke` heading, and `:229` the literal `Result: PASS`. The section is
substantive, not a placeholder: it records the `am start -W` output
(`Status: ok`, `LaunchState: COLD`, `Complete`), a resumed-activity poll that
exits 0, an empty `adb logcat -b crash` buffer, and a surviving app pid.

I opened `visual-fidelity/runtime-smoke-home-emulator-5554.png` as an image
rather than trusting the prose. It is a genuine 1080x2400 emulator frame of the
fully painted Home dashboard — couple-presence header, `247 ngày bên nhau`
counter, the `Còn 53 ngày nữa tới mốc 300` pill, the entry-card column, and the
bottom nav with `Nhà` selected. No Flutter red error screen, no blank frame, no
splash, no spinner. The gate's assertion (launches, reaches first screen, does
not crash) is met.

Two honesty checks passed, and they matter more than the PASS line itself:

- The frame shows the **pre-story `Minh`-only title** with a letterless partner
  disc, and the evidence says so explicitly — the APK on `emulator-5554`
  predates P1 because the phase file forbade an APK build. The section states
  in its own words that this is "**not** AC1-AC3 evidence." That disclosure is
  accurate against the pixels I looked at, and it is the correct scoping: a
  startup smoke is a launch/no-crash gate, not an AC gate.
- The `DioException [connection error]` on `GET /users/me` is disclosed rather
  than hidden, with the correct reading — the app degrades to cached/fixture
  data and still renders its first screen. No dependency service was started,
  consistent with the shared-infrastructure contract.

The claimed readiness probe is real: `com.snapsofts.cupid` resolves in
`data/devops/system/runtime-command-registry.json`, so the commands were taken
from the registered `mobile-app` runtime rather than improvised.

### F-2 re-verification detail

`coding-plan/test-results.md:288` carries `## Entry Point Reachability` and
`:290` the literal `Reachable: YES`. The path is concrete and ordered — launch
`com.snapsofts.cupid` → `MainActivity` → default `Nhà` bottom-nav tab → Home
dashboard → topmost couple-presence header → `HomeScreen` mounts `_CoupleHero`
→ `_PresenceRow` (`home_screen.dart:336`) — and each hop is backed by something
checkable rather than by assertion: the cold start above, the selected `Nhà`
tab visible in the smoke screenshot, and the widget tests that reach their
assertions through the `home_couple_hero` key inside a real mounted
`HomeScreen` tree. It correctly records that no new route, deep link, or flag
was introduced. This matches the entry point I verified independently in code
in round 1.

### F-3 re-verification detail

All four round-1 contract items are closed, and I verified each against the
artifact rather than against the patch report.

1. **`VISUAL_FIDELITY: PASS`** — present as a literal line at
   `visual-fidelity/visual-fidelity-report.md:3`, in the file header where the
   stop gate and DONE gate read it. The prose `**MATCH.**` verdict remains as
   narrative below it.
2. **Contract image pair present in this story's own folder** — both
   `implemented-home-header-widget-test.png` and
   `design-reference-home-header-widget-test.png` now exist under this story's
   `visual-fidelity/`. I verified the content by Git blob id, not filename:
   - `implemented-home-header-widget-test.png` is blob `116a32a`, byte-identical
     to `header-both-names.png` — the AC1+AC2 golden of the real `HomeScreen`
     tree that I opened and validated in round 1.
   - `design-reference-home-header-widget-test.png` is blob `efb9b55`, which is
     the exact same blob as
     `REQ-002.../STORY-017.../visual-fidelity/design-reference-home-android.png`
     — the design render I opened in round 1 and confirmed genuinely depicts
     this screen with `Minh & Linh` and the `M`/`L` discs. So the design side of
     the pair is the real reference render, not a duplicate of the implemented
     capture or a placeholder. The cross-story prose pointer is now a local
     side-by-side pair, which is what the contract asked for.
3. **Capture method — scoped exception verified present and accurate.** Per the
   Scrum Master ruling of 2026-08-25 I did not re-litigate the widget-test
   capture method; I verified the exception line exists and is honest.
   `visual-fidelity-report.md:84-102` carries the heading `### Why not an
   on-device capture — SCOPED EXCEPTION` and an explicit line attributing the
   exception to the Scrum Master ruling and to the P1 phase file's write-scope
   restriction. It is accurate on both counts: the phase file §6 language it
   quotes ("Do not run the full `flutter test` suite, an emulator/simulator
   lifecycle, or an APK build for this phase") is the same constraint round 1
   independently confirmed. The exception is also carried in the filename — the
   `<device>` slot of `implemented-<screen>-<device>.png` holds `widget-test` —
   so a later reader cannot mistake the golden for an on-device frame. The
   runtime-smoke screenshot is correctly labeled as runtime evidence outside the
   fidelity pair, i.e. treated as bonus evidence, not as a substitute capture.
4. **`Design-Screen` recorded and anchor corrected.** `Design-Screen: home` now
   appears both in `visual-fidelity-report.md:4` and in `story_master.md`,
   together with `Design-Source: cupid-app (LOCKED, surface: mobile, entry
   cupid-app-design-system/Cupid App.dc.html)` and an explicit supersession note
   for the wrong round-1 citation. I re-checked every line reference in the new
   anchor against the actual canvas files, because a corrected citation that is
   itself wrong would be worse than the original defect:

   | Claim | Verified |
   | --- | --- |
   | `Cupid App.dc.html` exposes `data-screen-btn="home"` | present |
   | `Cupid App.dc.html:239` = `dc-import name="Cupid Screens" side="a" platform="ios"` | exact match |
   | `Cupid App.dc.html:251` = `dc-import ... side="b" platform="md"` | exact match |
   | `Cupid Screens.dc.html:2173` = `isHome: sc === 'home'` | exact match |
   | `Cupid Screens.dc.html:238-246` = `<sc-if value="{{ isHome }}">` … `Minh &amp; Linh` + `{{ coupleTypeLabel }}` | exact match; 244/245 are the `M`/`L` gradient discs, 246 the title + couple-type subtitle |

   The anchor now resolves as locked entry + screen id rather than a bare
   pointer into an imported sibling component, which is what makes the `MATCH`
   verdict re-checkable later. With two locked design sources in the repository
   (`cupid-app` / mobile, `cupid-web` / web), that distinction is load-bearing.

The patch lane's re-run gate evidence (`test-results.md:212-225`) is consistent
with my round-1 independent re-runs: 17 passed / 0 failed and `No issues found!`
on the four changed files. Since no source file changed this round, I did not
re-run them a third time.

### Round 1 findings below

The sections that follow are the original round-1 record, kept for
traceability. F-1, F-2, and F-3 are closed by the re-verification above.

## Scope Gate

Diff baseline `9e6f379..190f5c3` (full story, both phases). The handoff's
`BaseHead` `d124f68` is itself a story-boundary seal commit carrying this
story's own backend phase, so it hides P0; both baselines were inspected.

Source/test files reviewed (7, within the compact 8-file budget):
`backend/src/modules/users/dto/me-profile-response.dto.ts`,
`backend/src/modules/users/users.controller.ts`,
`backend/src/modules/users/users.controller.spec.ts`,
`mobile/lib/features/account/domain/cupid_profile.dart`,
`mobile/lib/features/home/presentation/home_screen.dart`,
`mobile/test/features/account/domain/cupid_profile_test.dart`,
`mobile/test/features/home/home_screen_test.dart`.

Evidence in scope: `story_master.md`, `coding-plan/test-results.md`,
`visual-fidelity/visual-fidelity-report.md`, the three `visual-fidelity/*.png`
captures (opened as images), `data/devops/system/design-fidelity-config.json`,
and the cross-story anchor
`REQ-002.../STORY-017_home_dashboard_design_fidelity/visual-fidelity/design-reference-home-android.png`
(opened as an image).

Query keys: AC1/AC2/AC3, `partnerDisplayName`, `_PresenceRow`, `_CoupleHero`,
`Entry Point Reachability`, `Story Runtime Startup Smoke`, `VISUAL_FIDELITY`,
`Design-Screen`.

## Outcome Rationale

Round 1: the implementation was correct and the acceptance criteria were met in
code and in the rendered output, but the story failed on three MISSING critical
gates enforced independently by the reviewer stop gate and the DONE gate. No
code change was required for F-1..F-3 — they were evidence and artifact
obligations.

Round 2: the mobile lane supplied all three, and each was verified against the
artifact itself rather than against the completion report — the smoke screenshot
was opened as an image, the fidelity pair was checked by Git blob id, and every
corrected design-anchor line reference was re-read in the canvas files. All
three are genuinely satisfied, no source file changed, and no new defect was
introduced. The two remaining findings (D-1, D-2) are pre-existing and
non-blocking, so the outcome is `DEFERRED_ONLY`.

## Independent Verification Performed

| Check | Command | Result |
| --- | --- | --- |
| Targeted mobile tests | `flutter test test/features/home/home_screen_test.dart test/features/account/domain/cupid_profile_test.dart` | `00:00 +17: All tests passed!`, exit 0 — matches the claimed 17/0 |
| Mobile static analysis | `flutter analyze --no-pub` on the 4 changed files | `No issues found! (ran in 0.9s)` — matches the claim |
| Captures | Read all three PNGs as images | real frames, correct screen, no error/blank/spinner |
| Design anchor | Read `design-reference-home-android.png` | genuinely depicts this screen with `Minh & Linh` + `M`/`L` discs |

## Acceptance Criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — couple title shows both names in "A & B" | PASS | `home_screen.dart` `_PresenceRow` composes `'${displayName} & ${partnerDisplayName}'`; test `STORY-006 AC1/AC2` passes; `header-both-names.png` renders `Minh & Linh` |
| AC2 — partner avatar disc shows the partner initial | PASS | `partnerInitial = partnerDisplayName!.substring(0,1).toUpperCase()` passed to the partner `_Avatar`; `header-both-names.png` shows `L` on the mint disc |
| AC3 — degrades honestly when partner data is absent | PASS | `hasPartnerName` guard yields self-name-only with `partnerInitial == null`; three tests cover `null`, `''`, and an absent JSON key, each asserting no `&` and no `'L'`; `header-degraded.png` confirms `Minh` alone with a letterless partner disc |

No AC substitution was made; the exact AC text is satisfied. `Open Question
Impact: NONE`, so no OQ triage was required.

## Blocking Findings (all RESOLVED in round 2)

### F-1 — RESOLVED — `## Story Runtime Startup Smoke` is missing (rule 12g)

`coding-plan/test-results.md` records no `## Story Runtime Startup Smoke`
section, and `story_master.md` records no `Runtime-Smoke: WAIVED — <reason>`.
This is a non-trivial story on a `mobile` lane, so the smoke — the app launches
on the provided device/emulator and reaches its first screen without a crash or
an error screen — is mandatory and the DONE gate enforces it independently.
An `emulator-5554` instance is reported as booted, so the gate is suppliable.

Owner: `mobile-dev` (with `devops` if emulator/APK provisioning is needed).

### F-2 — RESOLVED — `## Entry Point Reachability` section is missing (rule 12e1)

`story_master.md` declares `UI-facing story: YES`, but
`coding-plan/test-results.md` carries no `## Entry Point Reachability` section
and no `Reachable: YES` line with a concrete path.

I independently verified the entry point in code and it is real: `_CoupleHero`
mounts `_PresenceRow` inside `HomeScreen`
(`mobile/lib/features/home/presentation/home_screen.dart:336`), the Home
dashboard is the default `Nhà` bottom-nav tab, and the pre-existing widget test
`AC1: the couple-presence signal renders both avatar discs, the couple name and
the couple-type label` passes against the real `HomeScreen` tree. So this is a
missing evidence section, not a missing entry point — but the section itself is
non-waivable and DONE-gated.

Owner: `mobile-dev`.

### F-3 — RESOLVED — Visual-fidelity artifact contract unmet (rules 12e2 / 12e3 / 12g2)

`data/devops/system/design-fidelity-config.json` has `ui_surface: true` and a
locked mobile `design_source` (`cupid-app-design-system`, entry
`Cupid App.dc.html`, `surface: mobile`), so the per-story rendered check applies
in full — the no-design-source exemption does not apply. Four contract items
are unmet:

1. **No `VISUAL_FIDELITY: PASS` line.** `visual-fidelity-report.md` writes the
   verdict as `**MATCH.**`. The reviewer stop gate and the DONE gate both read
   the literal `VISUAL_FIDELITY:` token; a passing outcome is rejected without
   it.
2. **No `design-reference-<screen>-<device>.png` in this story's
   `visual-fidelity/`.** The directory holds only `header-both-names.png`,
   `header-degraded.png`, `header-long-names.png`. The reference is cited by
   path into `REQ-002/STORY-017`, which is a prose pointer, not the required
   side-by-side artifact pair in this story's own folder.
3. **Implemented captures are not named `implemented-<screen>-<device>.png`,**
   and they are cropped header goldens produced by
   `RepaintBoundary.toImage` inside the widget-test renderer rather than a
   capture of the built app on the device/emulator. `visual-fidelity-report.md`
   §"Why not an on-device capture" explains the phase file forbade an emulator
   lifecycle and an APK build for P1, which is a legitimate constraint but not a
   substitution the fidelity gate recognizes.
4. **No resolved `Design-Screen: <id>` is recorded** in `story_master.md` or in
   the fidelity report, and the report's anchor cites
   `cupid-app-design-system/Cupid Screens.dc.html` lines 243-246 — a sibling
   canvas that is not the locked `design_source.entry` (`Cupid App.dc.html`).
   The repository holds two design sources (`cupid-app` / mobile and
   `cupid-web` / web), which is exactly the case where an unrecorded screen id
   makes a `MATCH` unverifiable after the fact.

Substantive note for the next lane: I opened all three captures and the REQ-002
`design-reference-home-android.png`. The rendered implementation genuinely
matches the design — overlapping `M`/`L` gradient discs, bold `Minh & Linh`,
muted `Cùng thành phố` beneath, days counter untouched — and the degraded and
long-name states behave as the report describes (`header-long-names.png` shows a
real ellipsis at `Nguyễn Thị Minh Khai Phương & T…`). Nothing I saw contradicts
the `MATCH` verdict. F-3 is an artifact/contract defect, not a fidelity defect.
Remediation should therefore be cheap: emit the paired, correctly named images
into this story's `visual-fidelity/`, add the `VISUAL_FIDELITY: PASS` line, and
record the resolved `Design-Screen: <id>` against the locked mobile canvas.
Whether item 3's on-device capture is required or is instead recorded as a
scoped exception is a Scrum Master call, since the phase file's write scope is
what forbade it.

Owner: `mobile-dev`; `scrum-master` to rule on item 3.

## Deferred Findings

### D-1 — Pre-existing 84 px `RenderFlex` overflow at 320 px width

`coding-plan/test-results.md` §"Pre-existing 320px overflow" documents that the
long-name widget test drains a `RenderFlex overflowed by 84 pixels on the right`
at 320x640, and that a control run with short `Minh`/`Linh` names and with
`partnerDisplayName` left `null` fires the identical overflow. The lane's
reasoning holds: the overflow originates elsewhere in the Home dashboard layout
at the narrowest supported width, this story did not make it worse, and fixing
it would require re-laying-out surfaces outside the phase write scope. The title
paragraph itself truncates correctly (`didExceedMaxLines == true`,
`maxLines: 1`, `TextOverflow.ellipsis`), which is what AC-level behavior names.

Recommend a follow-up bug for the Home dashboard's narrow-width layout. Not
blocking for STORY-006.

### D-2 — Whole-app analyze baseline is red (pre-existing)

`flutter analyze --no-pub lib test` reports 75 `info`-severity issues (74
`prefer_initializing_formals`, one `use_null_aware_elements`, one
`deprecated_member_use`), none in a file this story touched. Pre-existing
repository baseline, unchanged by this story.

## Traceability

- **Requirements:** `story_master.md` AC1-AC3 — all PASS, see the AC table. The
  Tech Lead architecture note that In Scope item 1's premise was stale
  (`GET /users/me` already returned `partnerDisplayName`) is honored: P0
  publishes and regression-locks the existing field via `MeProfileResponseDto` +
  `@ApiOkResponse` and a new controller spec, rather than building a new
  endpoint. `users.controller.ts`'s method body is unchanged and still delegates
  to `usersService.getProfileWithPartner`, so no runtime response shape moved.
- **Out of scope respected:** no profile-editing UI touched; no avatar disc
  layout, couple-type label, or days-counter token changed. The only layout
  change is the `Flexible` + `maxLines`/`overflow` wrapper required by the
  ellipsis behavior, which is additive.
- **UX:** `ux/uiux-spec.md` §6.8 design anchor — matched in the rendered
  captures (see F-3 note); the citation defect is recorded in F-3 item 4.
- **Architecture:** `architecture/solution.md` §1 Key Discovery and
  `contract-summary.md` — the delivered contract matches (`partnerDisplayName:
  string | null`, null on unpaired / dangling `partnerId` / null partner
  `displayName`, never an empty-string sentinel). The mobile side reads
  `json['partnerDisplayName'] as String?`, so an absent key reads `null`, and
  the `hasPartnerName` guard additionally tolerates `''` — consistent with the
  documented contract and defensive beyond it.
- **Testing evidence:** `coding-plan/test-results.md` Phase P0 (backend, 10
  tests, `nest build` exit 0) and Phase P1 (mobile, 17 tests, analyze clean).
  P1 re-run independently by this review with identical results. P0 was not
  re-run: the evidence is internally consistent, the controller body is
  unchanged in the diff, and the backend phase is outside the mobile handoff's
  declared scope.

## Configuration Guide

Not applicable. The story introduces no env var, external integration, manual
environment step, or runtime/config change — P0 is a Swagger-annotation and
spec-only change and P1 is presentation-layer only. No
`deployment/configuration-guide.md` verification was required.

## Critical Gate Summary

| Gate | Status |
| --- | --- |
| Backend targeted unit tests | PASS (evidence read, 10/10) |
| Backend build / type-check | PASS (evidence read, `nest build` exit 0) |
| Mobile targeted widget + unit tests | PASS (re-run, 17/0) |
| Mobile static analysis | PASS (re-run, `No issues found!`) |
| Entry point reachability evidence | PASS (round 2 — F-2 resolved) |
| Story runtime startup smoke | PASS (round 2 — F-1 resolved, screenshot verified) |
| Design fidelity artifact contract | PASS (round 2 — F-3 resolved, pair blob-verified, scoped exception recorded) |

## Action Items

Round 1 items 1-6 are all closed by the round-2 patch and its re-verification.
Remaining items are non-blocking:

1. `[scrum-master]` Correct the handoff `WriteScope`/`OutputPath` for this
   story, which named a non-existent
   `STORY-006_account_screen_cupid_profile_summary` directory. Review artifacts
   were written to the real `STORY-006_couple_title_partner_names` directory.
   Carried forward from round 1; not blocking.
2. `[scrum-master]` Consider a follow-up bug for D-1 (narrow-width Home
   dashboard `RenderFlex` overflow at 320 px). Pre-existing, not introduced by
   this story.
3. `[scrum-master]` D-2 (red whole-app `flutter analyze` baseline, 75
   `info`-severity issues, none in a file this story touched) remains a
   repository-level cleanup candidate, not story work.

## State Recommendation

- Check `Review (Reviewer)` in `story_master.md`.
- `recommended_story_status: DONE`.
- Outcome `DEFERRED_ONLY`: zero blocking findings; D-1 and D-2 carry forward as
  pre-existing deferrals, consistent with the sibling-story convention in this
  requirement.
- Story branch is merge-eligible into
  `codex/REQ-010_home_dashboard_deferred_scope_completion-integration`.
