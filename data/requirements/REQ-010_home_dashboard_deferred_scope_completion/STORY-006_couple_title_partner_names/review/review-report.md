# Review Report — STORY-006 Couple Title Shows Both Partner Names

Outcome: PATCH_REQUIRED

- Review type: `compact-story-review` (`Flow: parallel-story`)
- Requirement: REQ-010 Home dashboard deferred scope completion
- Story: STORY-006 (`Complexity: standard`, `Implementation Lane: backend + mobile`)
- Reviewer run: 2026-08-25
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-010_home_dashboard_deferred_scope_completion-STORY-006`
- Branch: `codex/REQ-010_home_dashboard_deferred_scope_completion-STORY-006`
- Scope gate: `review/scope-gate.md` (also summarized inline below)

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

The implementation is correct and the acceptance criteria are met in code and
in the rendered output. The story fails the gate on three MISSING critical
gates that are enforced independently by the reviewer stop gate and the DONE
gate. No code change is required for F-1..F-3; they are evidence and artifact
obligations the mobile lane can still supply.

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

## Blocking Findings

### F-1 — `## Story Runtime Startup Smoke` is missing (rule 12g)

`coding-plan/test-results.md` records no `## Story Runtime Startup Smoke`
section, and `story_master.md` records no `Runtime-Smoke: WAIVED — <reason>`.
This is a non-trivial story on a `mobile` lane, so the smoke — the app launches
on the provided device/emulator and reaches its first screen without a crash or
an error screen — is mandatory and the DONE gate enforces it independently.
An `emulator-5554` instance is reported as booted, so the gate is suppliable.

Owner: `mobile-dev` (with `devops` if emulator/APK provisioning is needed).

### F-2 — `## Entry Point Reachability` section is missing (rule 12e1)

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

### F-3 — Visual-fidelity artifact contract unmet (rules 12e2 / 12e3 / 12g2)

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
| Entry point reachability evidence | **MISSING — F-2** |
| Story runtime startup smoke | **MISSING — F-1** |
| Design fidelity artifact contract | **MISSING — F-3** |

## Action Items

1. `[mobile-dev]` Add `## Story Runtime Startup Smoke` to
   `coding-plan/test-results.md` with the mobile launch smoke result, or have
   `scrum-master` record `Runtime-Smoke: WAIVED — <reason>` in
   `story_master.md`. (F-1)
2. `[mobile-dev]` Add `## Entry Point Reachability` to
   `coding-plan/test-results.md` with `Reachable: YES` and the concrete path
   (Home dashboard `Nhà` tab → couple-presence header, `_CoupleHero` /
   `_PresenceRow` in `home_screen.dart`). (F-2)
3. `[mobile-dev]` Add a literal `VISUAL_FIDELITY: PASS` line to
   `visual-fidelity/visual-fidelity-report.md`. (F-3 item 1)
4. `[mobile-dev]` Write the paired `implemented-<screen>-<device>.png` and
   `design-reference-<screen>-<device>.png` into this story's
   `visual-fidelity/`. (F-3 items 2-3)
5. `[mobile-dev]` Record the resolved `Design-Screen: <id>` from the locked
   mobile canvas (`Cupid App.dc.html`, `design_source.id: cupid-app`) in
   `story_master.md`, and correct the anchor citation that currently points at
   `Cupid Screens.dc.html`. (F-3 item 4)
6. `[scrum-master]` Rule on whether F-3 item 3 requires an on-device/emulator
   capture or a recorded scoped exception, given the P1 phase file forbade an
   emulator lifecycle and an APK build.
7. `[scrum-master]` Correct the handoff `WriteScope`/`OutputPath`, which named a
   non-existent `STORY-006_account_screen_cupid_profile_summary` directory.
8. `[scrum-master]` Consider a follow-up bug for D-1 (narrow-width Home
   dashboard `RenderFlex` overflow).

## State Recommendation

- Uncheck `Implementation (Development)` in `story_master.md`.
- Leave `Review (Reviewer)` unchecked.
- Story status: `IN_PROGRESS` (currently recorded as `PENDING`, which is stale
  either way — `scrum-master` owns the field).
- Return to the `mobile-dev` lane with findings F-1, F-2, and F-3.
