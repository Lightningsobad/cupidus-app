---
story_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-08-26
reviewed_by: Reviewer
---

# Review Report: REQ-012 Pairing Flow QR Code & Couple Types Screen — Requirement Integration

Outcome: DEFERRED_ONLY

_This is the report's single verdict line (SKILL rule 8), carried across three
review passes rather than duplicated. It read `PATCH_REQUIRED` for rounds 1 and
2, and was changed to `DEFERRED_ONLY` by the round-3 re-review once the last two
blocking items closed. `DEFERRED_ONLY` rather than `CLEAN` because DF-1..DF-4
and CF-1..CF-4 remain open as tracked, non-blocking, follow-up items. Per-round
detail: `## Round 2 Re-Review`, `## Round 3 Re-Review`._

## Reviewed Inputs

- Review gate: `requirement-integration-review`
- Scope Gate: `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/integration-review/scope-gate.md`
- Requirements: `data/requirements/REQ-012_.../req_master.md`; the three
  `story_master.md` files (STORY-001, STORY-002, STORY-003 — all `Status: DONE`)
- Bug Report / Diagnosis / Fix Evidence: `N/A`
- UX: `N/A` at requirement level (per-story UX adjudicated at story review)
- Architecture: `N/A` at requirement level (per-story architecture adjudicated at
  story review); cross-story contract verified in code instead
- Coding Plan: `N/A` at requirement level
- Test Results: the three `coding-plan/test-results.md` files (queried sections
  only: `flutter test` / `flutter analyze` rows, `## Story Runtime Startup
  Smoke`, `## Entry Point Reachability`)
- Previous review findings: STORY-001 `Outcome: DEFERRED_ONLY`
  (`review/review-report.md:12`), STORY-002 `Outcome: DEFERRED_ONLY`
  (`review/review-report.md:3`), STORY-003 `Outcome: CLEAN`
  (`review/review-report.md:367`, §11.8 rework re-review)

## Reviewed Scope

- Story complexity: `N/A` (requirement-level gate; STORY-001/002 standard,
  STORY-003 complex)
- Bug status: `N/A`
- Integration branch: `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-integration`,
  BaseHead `d32f02f3` → HEAD `2e2f297f`, 40 commits, worktree clean, no pending
  merge
- Merged story landings verified as ancestors of HEAD: STORY-001 `33b0cf14`,
  STORY-002 `49896490`, STORY-003 `2e2f297f`
- Code scope reviewed (cross-story seams only; per-story internals were already
  gated at story review):
  `mobile/pubspec.yaml`, `mobile/pubspec.lock`,
  `mobile/lib/features/pairing/presentation/widgets/invite_qr_frame.dart`,
  `mobile/lib/features/pairing/presentation/pairing_code_parser.dart`,
  `mobile/lib/features/pairing/presentation/scan_code_cubit.dart`,
  `mobile/lib/features/pairing/presentation/scan_code_route.dart`,
  `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`,
  `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart`,
  `mobile/lib/features/pairing/presentation/screens/invite_screen.dart` (QR mount
  point only), `mobile/lib/main_preview.dart`,
  `mobile/android/app/src/main/AndroidManifest.xml`,
  `mobile/ios/Runner/Info.plist`,
  `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`,
  `mobile/test/.../pairing_choice_screen_test.dart`,
  `mobile/test/.../pair_gate_cubit_test.dart`,
  plus `backend/src/modules/invitations/invitations.service.ts` (read only to
  establish the real pairing-code shape the QR contract depends on)
- Evidence reviewed: three `test-results.md`, three `review-report.md`, three
  `visual-fidelity-report.md` verdict lines, `deployment/configuration-guide.md`,
  `req_master.md`, `scrum-master-checkpoint.md`
- Risk surfaces reviewed: shared/typed contract (QR payload producer↔consumer),
  package-dependency set, permissions/device API (camera, Android + iOS),
  runtime/configuration, mobile navigation & discoverability (3-screen flow),
  app lifecycle (scan overlay), mobile interaction
- Critical gates reviewed: G1 QR contract, G2 dependency coexistence, G3
  end-to-end flow, G4 merged shared-file coherence, G5 configuration-guide
  accuracy, G6 integration build + runtime, G7 requirement mobile visual audit
- Backend targeted verification gates: `NOT_APPLICABLE` (no backend change in
  this requirement; `invitations.service.ts` was read, not modified — confirmed
  absent from the combined diff)
- Story runtime startup smoke: `PASS` at story level for all three stories
  (each `test-results.md` carries `## Story Runtime Startup Smoke`, Result PASS,
  run by Scrum Master). Requirement-level integration smoke: see IF-1.
- Frontend targeted verification gates: `NOT_APPLICABLE` (no web lane)
- Frontend discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement frontend visual audit: `NOT_APPLICABLE` (no frontend
  participation; all three stories are mobile/shared)
- Mobile targeted verification gates: `PATCH_REQUIRED` — green per story, never
  run on the merged tree (IF-1)
- Mobile discoverability/navigation integration: `PASS` (G3 below)
- Requirement mobile visual audit: `PATCH_REQUIRED` (IF-2)
- OQ context reviewed: OQ1 RESOLVED (STORY-003, scan mechanism — full-screen
  overlay, permission requested at tap time); OQ2 RESOLVED (STORY-002, continue
  CTA destination unchanged, "Fingerprint Vow" wiring correctly not
  implemented). No unresolved OQ remains at requirement level.

## Outcome Summary

- Review outcome: PATCH_REQUIRED
- Rationale: the three stories integrate correctly *as code* — the requirement's
  one genuine cross-story contract (STORY-002's QR producer ↔ STORY-003's QR
  consumer) holds, the end-to-end pairing flow is wired and reachable, the three
  new mobile packages coexist in `pubspec.yaml`, and the shared files each story
  touched merged coherently (STORY-002 even repaired STORY-001's tests for the
  never-settling QR animation before landing). What is missing is proof that the
  *merged* tree resolves, builds and boots: the requirement carries no
  `## Integration Build & Runtime` evidence, and I established that no such run
  has ever happened — STORY-003's green suite ran on a tree that contains
  neither STORY-001's nor STORY-002's code. The requirement-level mobile visual
  audit is also absent. Both are named, non-waivable requirement-closure gates.
  Neither is a code defect, so no story goes back to a development lane; this
  needs an integration-verification pass, not rework.
- Blocking findings: 3
- Deferred findings: 4
- Dismissed observations: 1

## Traceability Summary

- Requirements: `req_master.md` business intent items 1-4 are each delivered —
  (1) three-row pairing-method screen (STORY-001 AC1-AC4), (2) QR on the
  create-code screen (STORY-002 AC1-AC5), (3) camera QR scanning on the
  scan-code screen (STORY-003 AC1-AC5), (4) the create-code screen remains the
  existing Couple Types screen, updated in place — `invite_screen.dart` was
  modified (190 changed lines), no new screen file was added, and the
  couple-type picker still follows the code/QR block on the same screen.
- Cross-story AC pair: STORY-002 AC2 ("a scanned QR resolves to the same code as
  the displayed text code") and STORY-003 AC2 ("a scanned code produces an
  identical pairing outcome to a typed code") are the only ACs neither story
  could verify alone. Both PASS — see G1 and G3.
- Open Questions: OQ1 and OQ2 both RESOLVED and carried into ACs; no OQ was
  over-applied (STORY-003 implemented the full AC1-4 functional scope that OQ1
  explicitly did not block).
- UX / Architecture: adjudicated per story; the three per-story
  `visual-fidelity-report.md` files all record `VISUAL_FIDELITY: PASS`
  (STORY-003 with `OPEN_OBSERVATIONS: VF-7`, accepted deferred). The three
  verdicts are mutually consistent; no story's design decision contradicts
  another's.
- Testing evidence: per-story suites green (STORY-003 `flutter test
  test/features/pairing` → `+223: All tests passed!`; `flutter analyze` at the
  unchanged 8-info baseline). No merged-tree run exists — IF-1.
- Merge refs: all three landings confirmed ancestors of HEAD via
  `git merge-base --is-ancestor`.

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| Shared/typed contract — QR payload | STORY-002 AC2 ↔ STORY-003 AC2 | G1 producer/consumer agreement | PASS | `invite_qr_frame.dart:197` encodes `data: code` byte-for-byte (documented at `:57-65`); `pairing_code_parser.dart:18-31` extracts the tail after the last `/` or `:`, strips non-alphanumerics, uppercases, and accepts `^[A-Z0-9]{6}$`; the server issues exactly that shape — `backend/src/modules/invitations/invitations.service.ts:36`, `randomBytes(3).toString('hex').toUpperCase()` = 6 uppercase hex chars. A real inviter QR therefore decodes to precisely the code shown as text. |
| Package dependencies | `mobile/pubspec.yaml` | G2 three-package coexistence | PARTIAL → IF-1 | `pubspec.yaml:61-63` carries `qr_flutter: ^4.1.0` (STORY-002), `mobile_scanner: ^7.4.0` and `permission_handler: ^12.0.1` (STORY-003) together, and both stories' `pubspec.lock` additions merged without collision. Declaration is correct; resolution/build of the combined set has never been executed — folded into IF-1. |
| Mobile navigation / discoverability | `req_master.md` items 1-3 | G3 end-to-end flow | PASS | choice → create-code: `pairing_choice_screen.dart:227` → `_openInvite` (`:114` push of `InviteScreen`). choice → join-code: `:247` and `:268` → `_openJoincode` (`:123`). join-code → scanner: `joincode_screen.dart:343-346` "Quét QR" → `_openScanner` (`:185-193`, pushes `ScanCodeRoute`). scanner → pairing: `scan_code_route.dart:42-48` shares the join-code screen's own `JoincodeCubit` via `BlocProvider.value`, and `scan_code_cubit.dart:112-121` parses then calls `_joincodeCubit.submit(code)` — literally the same call manual entry makes, so the scanned and typed outcomes cannot diverge. |
| App lifecycle — scan overlay | STORY-003 UX spec States 1-7 | Overlay does not own the shared cubit's lifecycle | PASS | `scan_code_route.dart:38-48` uses `.value`, not `create`; `scan_code_cubit.dart:154` cancels its join-code subscription on close. The screen below stays mounted, so typed characters survive the overlay. |
| Merged shared files | Combined diff | G4 coherence across three landings | PASS | `main_preview.dart`: STORY-001 renamed the `pairingchoice` key to the real canvas id `pairstart`, STORY-003 added a separate `scan` entry — no duplicate or clobbered keys. The two doubly-edited test files are the one place a real cross-story regression appeared and it was caught before landing: STORY-002 replaced `pumpAndSettle` with bounded pumps in STORY-001's `pairing_choice_screen_test.dart:87-90,158-170` and in `pair_gate_cubit_test.dart:173-176`, because the new QR frame animates forever and no frame is ever quiet once `InviteScreen` mounts. `pet_preview_card.dart:226-233` is STORY-001's in-scope BUG-20260825-002 fix, consistent with the additive `colorGlowCore` token — not a scope leak. |
| Permissions / device API | `deployment/configuration-guide.md` | G5 guide matches shipped config | PASS (content) | `AndroidManifest.xml` adds `android.permission.CAMERA` plus `android.hardware.camera` `required="false"`; `Info.plist` adds `NSCameraUsageDescription`. The guide documents both verbatim, plus the `permission_handler` 12.x pin rationale (`permission_handler_android` 14.0.0 wants platform hash `android-37`, which the SDK does not publish), the minSdk analysis, Play Data Safety, and the iOS `PERMISSION_CAMERA` macro caveat. Every claim I could check against the diff is accurate. Requirement-level bookkeeping around it is stale — IF-3. |
| Runtime / configuration — merged tree | SKILL 12g3 | G6 integration build + runtime smoke | PATCH_REQUIRED | IF-1 |
| Mobile design fidelity — cross-screen | SKILL 12g2 | G7 requirement mobile visual audit | PATCH_REQUIRED | IF-2 |

## Blocking Findings

### IF-1 — The merged tree has never been built, resolved, analyzed, or booted

SKILL 12g3 requires `data/requirements/REQ-012_.../integration-review/` to carry
a `## Integration Build & Runtime` section with `- Build: PASS — <command +
result>` and `- Runtime/Smoke: PASS — <startup smoke command + result>` in the
same file. The `integration-review/` directory did not exist before this review
run, so neither line exists anywhere under the requirement, and `req_master.md`
records no `Integration-Verify: WAIVED — <reason>`.

This is not a paperwork gap. The merged combination has demonstrably never been
exercised:

- STORY-003's evidence run (`flutter test test/features/pairing` →
  `+223: All tests passed!`, `coding-plan/test-results.md:591`) was executed at
  `bb089dc84f`.
- `git cat-file -e bb089dc84f:mobile/lib/features/pairing/presentation/widgets/invite_qr_frame.dart`
  → the file does not exist in that tree.
- `git diff --stat bb089dc84f HEAD -- mobile/` → 15 files, +1309/-167: all of
  STORY-001's redesigned `pairing_choice_screen.dart`, all of STORY-002's
  `invite_qr_frame.dart` / `qr_palette.dart` / rebuilt `invite_screen.dart`, the
  `qr_flutter` dependency, and the two repaired test files land *after* that run.

So no `flutter pub get`, `flutter analyze`, `flutter test`, or app launch has
ever run against the three-package dependency set (`qr_flutter ^4.1.0` +
`mobile_scanner ^7.4.0` + `permission_handler ^12.0.1`) or against the merged
`main_preview.dart`. Given that the guide itself documents a real Android
resolution failure in this exact dependency family (the `permission_handler` 12.x
pin), an unverified combined resolve is a concrete, not theoretical, risk.

I did not run these myself: my declared `WriteScope` is
`integration-review/*`, and `flutter pub get` / `flutter test` write
`.dart_tool/` and build output into the worktree, outside that scope. SKILL 12g3
routes this to the integration-verification pass.

### IF-2 — Requirement-level mobile visual audit is missing

SKILL 12g2 keeps `data/requirements/REQ-012_.../integration-review/mobile-visual-audit.md`
as a separate, still-blocking cross-screen check before requirement closure, and
states explicitly that the per-story captures do not substitute for it in either
direction. All three stories carry passing per-story evidence
(`VISUAL_FIDELITY: PASS` x3), which satisfies 12e2/12g2's *per-story* half only.
The cross-screen concern this requirement actually raises is real and unexamined:
three adjacent screens in one flow were restyled by three different implementers
against three different canvas blocks (`pairstart`, `invite`, `isJoinCode` +
the newly authored scan-overlay states), and no one has looked at them
side by side for shell, navigation, and visual-consistency breakage.

### IF-3 — Requirement-level state records contradict the delivered work

Three stale records under `data/requirements/REQ-012_.../`, all Scrum Master
owned, all cheap to correct, all of which would otherwise be carried into
closure:

- `req_master.md:9-13` — `## Configuration Documentation` says
  `Status: NOT_REQUIRED` with an empty `Last Updated`, while
  `deployment/configuration-guide.md` documents store-facing, build-time camera
  configuration (Android permission + feature declaration, iOS usage
  description, a deliberate dependency version pin). SKILL 12a puts
  requirement-level configuration-guide consistency in this gate's scope.
- `req_master.md:66-69` — the User Stories table lists all three stories
  `PENDING`; all three `story_master.md` files record `Status: DONE`.
- `scrum-master-checkpoint.md` on this branch is still at the UX phase
  ("Current Phase: UI/UX Design (Pink-Designer) for all 3 stories"), naming a
  Next Valid Step that completed weeks of work ago.

## Deferred Findings

- **DF-1 — `qr_flutter` absent from the configuration guide's dependency table.**
  The guide (`## New Third-Party Dependencies`) lists `mobile_scanner` and
  `permission_handler` but not STORY-002's `qr_flutter ^4.1.0`. The guide is
  camera-scoped by title and `qr_flutter` is pure Dart with no native, store, or
  permission implication, so nothing operational is missing — but the
  requirement's dependency footprint is three packages, not two. Owner: DevOps,
  one table row.
- **DF-2 — "Scan the QR" and "They already have a code" have identical
  destinations.** `pairing_choice_screen.dart:247` and `:268` both call
  `_openJoincode`, so a user who explicitly picked *scan* still has to tap
  "Quét QR" on the join-code screen to reach the scanner that now exists. This
  is exactly what STORY-001 AC3 approved ("both routes land on the existing
  join-code screen, matching current design's own routing") and was decided
  before STORY-003 made the scanner real, so it is not a defect. Worth a
  Product Owner look now that the third row leads somewhere. Owner: Product
  Owner.
- **DF-3 — STORY-002 describes the pairing code as 8 characters; it ships as 6.**
  `story_master.md` In Scope item 2 says "the existing 8-character text code"
  (inherited from the design source's mock). Reality is 6 everywhere:
  `invitations.service.ts:36` (`randomBytes(3)` hex), `joincode_screen.dart:39`
  (`_codeLength = 6`), `pairing_code_parser.dart:2` (`pairingCodeLength = 6`).
  Documentation-only; the QR encodes whatever the real code is, so behavior is
  unaffected and G1 still holds.
- **DF-4 — Story-level deferred items carried forward, not re-adjudicated here.**
  STORY-001 D-1 (escape link, resolved by Product Owner DROP decision);
  STORY-002's five deferred items (pre-existing BUG-20260825-002, pre-existing
  `gallery_cubit_test.dart:276` flake, two documented plan deviations, QR
  module-ink colour); STORY-003 DF-2/DF-4/DF-5 and UV-1. All were accepted at
  story review; none became worse through integration.

## Dismissed Observations

- The scan path *rejects* a payload that does not normalize to exactly 6
  alphanumerics, while the manual Paste path *truncates* to the first 6
  (`joincode_screen.dart:162-170`). The asymmetry is deliberate and documented
  at `pairing_code_parser.dart:14-17`: truncating would read
  `https://cupid.app/join/ABC123` as `HTTPS:` and turn a malformed scan into a
  real backend call the user cannot act on. Correct as written; not a finding.

## Implementation Action Items

- `[devops]` `data/requirements/REQ-012_.../integration-review/` — run the
  integration-verification pass on this branch and record, in ONE file, a
  `## Integration Build & Runtime` section containing both
  `- Build: PASS — <command + result>` and
  `- Runtime/Smoke: PASS — <startup smoke command + result>`. The build must
  exercise the merged dependency set (`cd mobile && flutter pub get` then
  `flutter build apk --debug`, the only gate the configuration guide says
  catches the `permission_handler` platform-hash failure), and the smoke must be
  an app launch on the provided emulator reaching its first screen without a
  crash or error screen. A merged `flutter test test/features/pairing` +
  `flutter analyze lib/features/pairing lib/main_preview.dart test/features/pairing`
  should be recorded alongside it, since no suite has yet run against all three
  stories' code together. (IF-1)
- `[mobile-dev]` `data/requirements/REQ-012_.../integration-review/mobile-visual-audit.md`
  — cross-screen audit of the three restyled screens as one flow (pairstart →
  invite → joincode → scan overlay) on the provided device/emulator, checking
  shell, navigation and visual consistency between screens rather than
  re-adjudicating any single screen. (IF-2)
- `[scrum-master]` `data/requirements/REQ-012_.../req_master.md` — set
  `## Configuration Documentation` `Status` to reflect the delivered
  `deployment/configuration-guide.md` and fill `Last Updated`; update the User
  Stories table rows to `DONE`. (IF-3)
- `[scrum-master]` `data/requirements/REQ-012_.../scrum-master-checkpoint.md` —
  refresh to the current phase (requirement integration review) instead of the
  UX phase. (IF-3)

## Workflow State Recommendation

- Story status: `N/A` — all three stories stay `DONE`. No finding in this report
  returns any story to a development lane; every blocking item is
  requirement-level evidence or requirement-level bookkeeping.
- Requirement status: `IN_PROGRESS` — do not mark REQ-012 `DONE`.
- Bug status: `N/A`
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `LEAVE_UNCHECKED`
- Next step: route the integration-verification pass (IF-1) and the requirement
  mobile visual audit (IF-2), apply the IF-3 record corrections, then return for
  a re-review that verifies only those three items against this report. The
  cross-story code review (G1-G5) is complete and does not need repeating.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.

## Round 2 Re-Review

Date: 2026-08-26. Scope: verify only the closure of round-1's three blocking
findings, plus a sanity check that the deferred/dismissed set still stands.
Round-1's cross-story code review (G1-G5) was not repeated and is not reopened.

Baseline: HEAD `c647a075`, against round-1's reviewed HEAD `2e2f297f`.
`git diff --stat 2e2f297f HEAD -- mobile/ backend/ cupid-app-design-system/`
returns **empty**. No product code changed between the two reviews, so every
round-1 code conclusion carries forward unmodified. Only requirement-level
evidence and bookkeeping files were added.

Result: **two of the three blocking findings are closed; IF-3 is two-thirds
closed, and one new format-level blocker (IF-4) is raised against IF-1's
evidence file.** Both open items are small, document-only edits owned by roles
other than Reviewer. No story returns to a development lane.

### IF-1 — CLOSED (substance), see IF-4 for format

`integration-review/build-runtime-evidence.md` (commit `8f3c383`) records all
five commands with real quoted output: `flutter pub get` (`permission_handler`
12.0.3 / `permission_handler_android` 13.0.1, confirming the pin documented in
the configuration guide holds on the merged whole), `flutter build apk --debug`
(`✓ Built build/app/outputs/flutter-apk/app-local-debug.apk`, 49.0s),
install + `am start -W` on `emulator-5554` (`Status: ok`, `LaunchState: COLD`,
`READINESS_EXIT=0`) with registry-based readiness and `am force-stop` shutdown,
`flutter test test/features/pairing` (`00:07 +234`), and `flutter analyze`
(8 `info`-level `prefer_initializing_formals` only — the unchanged baseline).

The decisive check was not that the commands are present but that they ran
against the *merged* tree, since round-1's IF-1 existed precisely because
STORY-003's green `+223` suite predated the merge. The evidence names BaseHead
`b31de7d2`. `invite_qr_frame.dart` (STORY-002's QR producer, absent from the
tree STORY-003 tested) **is** present at `b31de7d2`, and
`git diff --stat b31de7d2 HEAD -- mobile/` is **empty**. Devops therefore built,
launched, tested and analyzed exactly the mobile code now on the branch. The
round-1 failure mode does not recur, and 234 tests (up from 223) is consistent
with all three stories' suites running together for the first time.

### IF-2 — CLOSED

`integration-review/mobile-visual-audit.md` (175 lines) plus 12 device captures
in `integration-review/mobile-screenshots/`, commit `ec2bcdb`, audited at HEAD
`8f3c383`. The connected walk required by round-1's action item was performed:
pairstart → invite (pushed live from row 1) → back → joincode → scan overlay
including a real camera-permission grant → back → cross-link, with real taps
through shipped widgets and the shipped `onboardingRouteBuilders()` registry.
Only the entry point is harness (`main_preview.dart`), which is the documented
consequence of the product entry gating pairing behind an authenticated session.

Per SKILL 12e3 (mobile lane: verify, do not recapture) I opened four frames
rather than trusting the prose, and each one independently confirms what the
audit claims: `flow-01` (pairstart, "Nhận mã 8 ký tự"), `flow-07` (a genuine
live camera scene with overlay chrome painted straight onto it), `flow-11`
(populated QR card + couple-type grid + "Mã 6 ký tự"), `flow-04` (six code
slots + Dán/Quét QR + the cross-link). These are real device captures, not
placeholders, and the audit is not a stub. Density is constant at 405x900 with
no `--width`/`--density` override, so cross-screen spacing comparisons are
sound. Note H1 (spinner in step 2 from an unreachable backend) is correctly
scoped as a harness artefact, since step 11 captures the same screen populated.

### IF-3 — PARTIALLY CLOSED (2 of 3); one item remains open

Closed:

- `req_master.md` User Stories table now records `DONE` for STORY-001/002/003,
  matching the three `story_master.md` files (commit `5f23607`).
- `master_requirements_list.md:25` records REQ-012 as `IN_PROGRESS` — correct,
  and correctly *not* `DONE`, since this gate had not yet returned.
- `scrum-master-checkpoint.md` is current: it names the requirement integration
  review as the live phase and records round-1's `PATCH_REQUIRED` and the
  IF-1/IF-2/IF-3 remediation. The UX-phase staleness is gone.

**Still open — `req_master.md:9-13`.** The `## Configuration Documentation`
block is unchanged from round 1: `Status: NOT_REQUIRED` with an empty
`Last Updated`. Commit `5f23607` corrected the story table but not this block,
and round-1's action item named both halves. The record is factually wrong:
`deployment/configuration-guide.md` exists on this branch (139 lines, 6.3 KB,
delivered in STORY-003's implementation commit `1bceabe`) and documents
store-facing, build-time camera configuration — the `mobile_scanner` /
`permission_handler` dependency additions, the deliberate 12.x pin and its
`compileSdk = 37` rationale, the Android permission + feature declaration, and
the iOS usage description. Devops' own IF-1 evidence cites that same guide by
path as the source of the pin it verified.

This is not bookkeeping pedantry: `Status: NOT_REQUIRED` with
`Pending User Setup: NONE` is the field the deployment lane reads. Carried into
closure, it tells a release engineer that REQ-012 introduced no configuration
to honour, on the one requirement that introduced the app's first camera
permission and its first store-submission usage-description requirement. SKILL
12a puts requirement-level configuration-guide consistency inside this gate.

### IF-4 — NEW (blocking, format only): 12g3 verdict lines do not match the required literal

`build-runtime-evidence.md:10-13` has the required `## Integration Build &
Runtime` heading and puts the verdict first after each colon, but the two lines
read:

```
Build: PASS
Runtime-Smoke: PASS
```

SKILL 12g3 specifies `- Build: PASS — <command + result>` and
`- Runtime/Smoke: PASS — <startup smoke command + result>`. Three deviations:
no list-item prefix, `Runtime-Smoke` instead of `Runtime/Smoke`, and no inline
command + result (the commands are complete, but in a numbered list below).
Round-1's action item quoted both required literals verbatim.

The substance behind these lines is complete and genuine — this is purely the
token the gate reads. I am flagging rather than fixing it: it is devops' file,
and a reviewer editing another role's evidence to make a gate pass is the
reviewer-manufacturing-evidence failure mode SKILL rule 7 exists to prevent.
I also cannot confirm the gate's exact matcher, because reading `.claude/hooks/**`
is forbidden to me; SKILL 12g3 states the DONE gate enforces this independently,
so the risk is a blocked DONE attempt, not a wrong verdict. Normalizing the two
lines costs one edit and removes the uncertainty.

### Adjudication of the audit's four new findings (CF-1..CF-4)

Reviewed independently rather than accepted on the mobile-dev's classification.
All four are correctly **non-blocking**; none changes this gate's verdict.

- **CF-1 ("8 ký tự" on pairstart vs a 6-character code downstream)** — confirmed
  with my own eyes: `flow-01` promises "Nhận mã 8 ký tự", while `flow-11` says
  "Mã 6 ký tự" and `flow-04` renders exactly six entry slots. This is a real,
  user-visible cross-screen copy contradiction and is more serious than round-1's
  doc-only DF-3, which described the same 8-vs-6 confusion in prose. It is
  nonetheless not blocking here: the implementation is faithful to the locked
  design source (`Cupid Screens.dc.html:1586` carries the same string) and to
  STORY-001 AC1, which required matching copy. Under SKILL rule 14 the exact AC
  text controls, and the AC was met. This is a Product Owner copy decision
  against the design source, not implementation drift. Recommend queueing it
  together with DF-3 — they are one issue with two symptoms.
- **CF-2 (no scrim behind live-camera overlay chrome)** — confirmed in `flow-07`:
  a real bright camera scene with the muted caption over it and gradient
  letterbox bands. Genuine legibility regression against the design's opaque
  `#0B0812` backdrop, and genuinely invisible to per-story review, whose capture
  used a black placeholder feed that accidentally satisfied the backdrop.
  Cosmetic, not functional: viewfinder, scan line and controls all render.
  Deferred, follow-up candidate.
- **CF-3 (permission dialog shows "cupid_mobile")** — pre-existing
  `android:label`, merely newly visible. Cosmetic. Deferred.
- **CF-4 (dead "Tôi mới là người tạo mã" cross-link)** — attribution verified
  independently rather than taken on trust:
  `git log -S "OnboardingNode.invite" -- .../joincode_screen.dart` returns
  `696c1aa` (REQ-002 / STORY-047), and the call is present at round-1's BaseHead
  `d32f02f3`. Genuinely pre-existing and outside REQ-012's diff. It is a real
  user-facing dead end, so it warrants a bug-queue item, but blocking REQ-012 on
  a defect REQ-012 did not introduce would be scope error.

### Note recorded to prevent a future wrong "fix"

`flow-11` displays the seeded code `CPD-8F2K` — seven alphanumerics plus a
hyphen, which `parsePairingCode` would correctly reject. This is a harness-only
seed (`main_preview.dart:180`, `:953`, `:1508`, the design canvas' own sample
invitation), not a product value. `invite_screen.dart:405` and `:427` pass the
same raw `invitation.code` to both the QR and the text render, so G1 (the
producer/consumer contract) is unaffected. Recording it explicitly so nobody
later widens the parser to accept 7 characters on the strength of this
screenshot.

### Round-1 deferred and dismissed findings — re-confirmed

Re-confirmed as unaffected, on the strength of the empty code diff above rather
than by re-deriving them: **DF-1** (`qr_flutter` missing from the guide's
dependency table — still absent, still non-operational), **DF-2** (scan and
"already have a code" share a destination — still AC3-approved), **DF-3**
(STORY-002 doc says 8 characters, ships 6 — now corroborated by CF-1 at the UI
level), **DF-4** (story-level deferred items carried forward). The dismissed
observation (scan rejects vs paste truncates) stands: the asymmetry remains
deliberate and correctly documented.

### What remains open

1. `[scrum-master]` `req_master.md:9-13` — set `## Configuration Documentation`
   `Status` to reflect the delivered `deployment/configuration-guide.md`, fill
   `Last Updated`, and reconsider `Pending User Setup: NONE` against the guide's
   store-submission items. (IF-3, remaining third)
2. `[devops]` `build-runtime-evidence.md:12-13` — normalize the two verdict
   lines to 12g3's literal form, `- Build: PASS — <command + result>` and
   `- Runtime/Smoke: PASS — <startup smoke command + result>`. Evidence content
   is already sufficient; only the two lines change. (IF-4)

Neither item requires a code change, a rebuild, a re-test, or a re-capture. A
re-review scoped to these two edits is sufficient to close the gate.

### Handoff note — one literal verdict line, by rule

The round-2 handoff asked for "one new literal `Outcome:` line" appended here.
SKILL rule 8 forbids a second `Outcome:` token in the report and the DONE gate
reads that single line, so a second one would break the gate it is meant to
feed. Resolved by keeping exactly one verdict line, at the top of the report,
re-affirmed for round 2 and cross-referenced to this section. The round-2
verdict is the one stated there; it is unchanged in value because two blocking
items remain, not because round 1 was copied forward.

### Workflow state after round 2

- Story status: `N/A` — all three stories stay `DONE`.
- Requirement status: `IN_PROGRESS` — REQ-012 is still not `DONE`.
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `LEAVE_UNCHECKED`
- State update owner: `scrum-master` only.

## Round 3 Re-Review

Date: 2026-08-26. Scope: the two items in round 2's `### What remains open`,
and nothing else. HEAD `cdfe4466`.

Baseline unchanged. `git diff --stat 2e2f297f HEAD -- mobile/ backend/
cupid-app-design-system/` is still **empty** across all three sync points, so no
product code has changed since the round-1 review. Both fixes are document-only.

**Both items are closed. This gate now passes.**

### IF-3 — CLOSED (final third)

`req_master.md:9-13` now reads `Status: DELIVERED` with
`Last Updated: 2026-08-26` (commit `5ffa129`), against
`Source of Truth: deployment/configuration-guide.md`. That matches the guide I
reviewed in round 2: a delivered, substantive document, not a placeholder.

I also checked the one sub-item round 2 asked to be reconsidered rather than
merely re-typed — `Pending User Setup: NONE`. It is correct as written. The
guide's own scope statement rules out runtime configuration ("no new environment
variable, no new dart-define, and no new backend key"), and both native
declarations are already committed: the Android permission/feature block, and
`NSCameraUsageDescription` in `mobile/ios/Runner/Info.plist:106-107`. The only
forward-looking caveats are conditional on a Podfile this repository does not
check in, and a note that on-device QR confirmation needs a real handset — a
testing constraint, not a setup action. Nothing is pending on a human operator,
so `NONE` is accurate rather than merely convenient.

### IF-4 — CLOSED

`build-runtime-evidence.md:12-13` (commit `192c5da`) now reads:

```
- Build: PASS — `flutter build apk --debug` (mobile/): ... ✓ Built build/app/outputs/flutter-apk/app-local-debug.apk, no errors.
- Runtime/Smoke: PASS — installed on reused `emulator-5554`, launched via `adb shell am start -W -n ...` (`Status: ok`, `LaunchState: COLD`), resumed foreground activity confirmed on first `dumpsys activity activities` poll (`READINESS_EXIT=0`), then force-stopped cleanly.
```

This matches SKILL 12g3's required literal form on all three points that
deviated: list-item prefix present, `Runtime/Smoke` (not `Runtime-Smoke`), and
command + result inline on each line. Both lines are in the same file under the
`## Integration Build & Runtime` heading, with the verdict as the first word
after each colon. The underlying evidence is unchanged — this was a format
correction only, and the numbered command log below it still carries the full
output. Nothing was re-run to satisfy the format, which is correct: the
substance was already verified in round 2 against the merged tree.

### Verdict

`DEFERRED_ONLY`, not `CLEAN`. No blocking findings remain at requirement level:
IF-1, IF-2, IF-3 and IF-4 are all closed, the cross-story contract (G1-G5) was
verified in round 1 against code that has not changed since, and the merged
whole has been built, launched, tested and audited as one flow. What keeps this
off `CLEAN` is the tracked non-blocking set carried to closure — DF-1..DF-4 from
round 1 and CF-1..CF-4 from the requirement visual audit. None of them blocks
REQ-012; all of them should survive requirement closure as queued follow-ups
rather than being silently dropped.

Two worth naming for whoever picks up the queue, because they are real
user-facing defects that simply are not REQ-012's to fix: **CF-1/DF-3** (the
"8 ký tự" promise on pairstart against a 6-character code everywhere
downstream — one issue, two symptoms, needs a Product Owner decision against the
locked design source) and **CF-4** (the dead join-code → create-code cross-link,
source-verified to REQ-002 STORY-047).

### Workflow state after round 3

- Story status: all three stories stay `DONE`.
- Requirement status: **clear to mark `DONE`** by Scrum Master. This gate no
  longer withholds closure.
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `CHECK` — the review gate has passed.
- The report's frontmatter `story_status_recommendation` was updated from
  `IN_PROGRESS` to `DONE` in this round so the report's metadata does not itself
  become the kind of stale record IF-3 was raised about twice.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files, and did not.
