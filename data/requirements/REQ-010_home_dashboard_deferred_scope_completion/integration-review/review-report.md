# Requirement Integration Review — REQ-010 Home Dashboard Deferred Scope Completion

Outcome: PATCH_REQUIRED

- Review type: `requirement-integration-review` (`Flow: parallel-requirement`)
- Reviewer: Iris-QC, 2026-08-25
- Scope gate: `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/integration-review/scope-gate.md`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-010_home_dashboard_deferred_scope_completion`
- Branch: `codex/REQ-010_home_dashboard_deferred_scope_completion-integration`
- Diff range: `9e6f3796..5a8349c2` (36 commits; 22 source/test/config files, +3158/-204)
- Blocking findings: 2 · Deferred findings: 7 · Carry-forward deferrals resolved: 5

## Rationale

The merged code is integration-clean. Every cross-story surface I checked in the
merged tree is consistent, the `b0c79fc` integration fix is correct and
substantively closes two carry-forward findings, and one carry-forward finding
that was flagged as possibly affecting all seven stories turns out to be a false
alarm (see R-5).

The two blocking findings are both requirement-level *verification gates that do
not yet exist*, not code defects. The handoff scoped this pass as read-only
("do not build or boot the app yourself; that verification step happens
separately"), which is exactly the routing reviewer SKILL rule 12g3 prescribes
— so `PATCH_REQUIRED` here means "run the integration-verification pass and
re-gate", not "the stories were built wrong".

## Merged Stories And Their Review Outcomes

| Story | Lane | Story review outcome | Merged |
| --- | --- | --- | --- |
| STORY-001 Anti-ghost alert banner | mobile | CLEAN | yes |
| STORY-002 Vibe-check card | mobile | CLEAN | yes |
| STORY-003 Pet preview card | mobile | DEFERRED_ONLY | yes |
| STORY-004 Header share days action | mobile | DEFERRED_ONLY | yes |
| STORY-005 Header notifications entry | mobile | DEFERRED_ONLY | yes |
| STORY-006 Couple title partner names | backend + mobile | DEFERRED_ONLY | yes |
| STORY-007 `--sky` backdrop rollout | mobile | DEFERRED_ONLY | yes |

No story gate is `PATCH_REQUIRED` or `BLOCKED`. Merge refs: the 36-commit range
above, including the two Scrum Master integration commits `e39969fe`
(STORY-006 × STORY-004/005 combine) and `b0c79fc` (the `_PresenceRow` bound fix),
reviewed here as ordinary branch history.

## Cross-Story Verification Performed

| Cross-story surface | Verdict | Evidence I checked myself |
| --- | --- | --- |
| Merged Home header (STORY-004+005+006 in one `Row`) | PASS | `home_screen.dart:387-416` — `Expanded(_PresenceRow)` + intrinsic `_HeaderActionsRow`; see R-1/R-2 |
| Header actions grouping (STORY-005 F3) | PASS | `_HeaderActionsRow` at `:449-466` now wraps BOTH `goShareDays` and `goNotifs` with `_headerActionGap = 2` (`:52`, applied `:460`) |
| `/users/me` contract producer ↔ consumer (STORY-006) | PASS | DTO `me-profile-response.dto.ts:46` `partnerDisplayName: string \| null` ↔ `cupid_profile.dart:36,52` `String?`; all 13 DTO fields have a mapped consumer field |
| Backend method actually exists post-merge | PASS | `users.service.ts:30 getProfileWithPartner` landed earlier in `22e4a0d` (REQ-002/STORY-052); STORY-006's P0 was DTO + `@ApiOkResponse` + controller spec only — additive, no dangling call |
| `--sky` backdrop reaches every REQ-010 surface | PASS | `cupid_app.dart:59` mounts `CupidAppBackground` in `MaterialApp.builder`; `cupid_theme.dart:45` `scaffoldBackgroundColor: Colors.transparent`; `home_screen.dart:172` `Scaffold(body: SafeArea(...))` sets no background and roots no opaque layer; `app_shell.dart:189` likewise |
| STORY-007 occlusion guard still holds over rewritten cards | PASS | `shared_backdrop_occlusion_guard_test.dart:32-85` scans `lib/**` for opaque `Scaffold.backgroundColor` and opaque root `body:` layers; none of `anti_ghost_entry_card.dart`, `vibe_entry_card.dart`, `pet_preview_card.dart` introduces a `Scaffold`; the only new `colorBackground` use is `home_screen.dart:740`, an avatar ring border |
| Preview-harness fixtures coexist (STORY-003 × STORY-017) | PASS | `main_preview.dart:835 _homeFixture` and `:844 _petFixture` are independent `bool.fromEnvironment` defines, both consumed at `:846-849` |
| Notifications DI reachable from the merged Home | PASS | `service_locator.dart:145` registers `NotificationPreferencesStore`; consumed at `home_screen.dart:168,650`; `_buildHome` correctly falls through to the default resolver |
| Production entry point survives the merge | PASS | `app_shell.dart:152 buildBody: () => const HomeScreen()` — Home tab still mounts the screen carrying all seven stories' output |
| New dependency | PASS | `pubspec.yaml` adds only `share_plus: ^13.3.0`; `pubspec.lock` resolved; no native manifest edits required or present |
| Migrations / generated clients | NOT_APPLICABLE | no migration, no codegen artifact, and no schema change in the diff |
| Configuration guide (rule 12a) | NOT_REQUIRED | `req_master.md:9-13` records `Configuration Documentation … Status: NOT_REQUIRED`; the diff adds no env var, secret, port, or manual setup step |

## Carry-Forward Deferral Reassessment

The handoff carried 12 open deferrals from the seven story gates. Reassessed:

| Id | Origin | Reassessment |
| --- | --- | --- |
| R-1 | STORY-005 F1 (`_PresenceRow` text had no bounded width) | **RESOLVED by `b0c79fc`.** In a `Row`, the non-flex `_HeaderActionsRow` (`mainAxisSize.min`) is laid out first and `Expanded(_PresenceRow)` receives the remainder, so `_PresenceRow`'s inner `Flexible(Column)` (`:594`) now gets a bounded width and the title `Text` (`:600-609`, `maxLines: 1`, `overflow: ellipsis`) truncates instead of overflowing. Proven by `home_screen_test.dart:322-371`, which asserts `paragraph.didExceedMaxLines == true` at 320px — an assertion that can only pass under a bounded width. Residual, non-blocking: see D-1. |
| R-2 | STORY-004 DEF-1 (long-name tolerance shrinks by one tap-target width) | **RESOLVED as a defect class by `b0c79fc`.** The header actions row now consumes its intrinsic width first and the presence block absorbs the remainder by truncating. Losing a tap-target's worth of title width is now the *designed* degradation (earlier ellipsis), not an overflow risk, and it holds for both the 1-action (`days == null`) and 2-action budgets, since `Expanded` re-derives the remainder from whatever `_HeaderActionsRow` actually measures. |
| R-3 | STORY-004 DEF-2 (2dp actions gap asserted in source only) | **RESOLVED at source level.** `_headerActionGap = 2` (`:52`) is applied structurally at `:460` between siblings, so it cannot drift per-action. Still not pixel-asserted; folded into D-2 rather than kept open separately. |
| R-4 | STORY-005 F3 (`goNotifs` not wrapped in the spec's icon row) | **RESOLVED.** STORY-004 did add the wrapper as expected: `_HeaderActionsRow` (`:449-466`) is now the single parent of both header icons. |
| R-5 | STORY-003 D2 (`design-fidelity-config.json` mobile `entry` says `Cupid App.dc.html`, stories cite `Cupid Screens.dc.html` — "potentially affects every mobile story") | **NOT A DEFECT — closed.** `Cupid App.dc.html` is the container canvas: it imports the screen library at `:239` and `:251` (`<dc-import name="Cupid Screens" side="a"/"b" …>`) and owns the screen index, including `data-screen-btn="home"` at `:200`. `Cupid Screens.dc.html` holds the screen bodies (it is the only one of the two containing `isHome`/`goShareDays`/`goNotifs`), which is why the stories cite it for line anchors. The config field is correct as-is and needs no change; every mobile story in this requirement resolved the right design. This clears the one carry-forward finding that was scoped as requirement-wide. |
| D-1..D-7 | remaining | see Deferred Findings below |

## Blocking Findings

### B-1 — Integration build + runtime evidence does not exist (reviewer SKILL 12g3)

`data/requirements/REQ-010_home_dashboard_deferred_scope_completion/integration-review/`
contained no file at review time (verified in both the integration worktree and
the control checkout), so there is no
`## Integration Build & Runtime` section and therefore neither of the two
required lines:

```
- Build: PASS — <command + result>
- Runtime/Smoke: PASS — <startup smoke command + result>
```

`req_master.md` records no `Integration-Verify: WAIVED — <reason>`, so the
waiver branch does not apply.

This is not a formality for this particular merge. Scrum Master's own account
records that combining STORY-006 with STORY-004/005 produced a 708px
`_PresenceRow` overflow that was invisible to both Git and `flutter analyze` and
surfaced only when tests ran against the merged tree. Whatever proved that has
not been recorded as integration evidence, and the branch has since taken the
`b0c79fc` fix plus the STORY-007 merge on top of it. The merged tree's build and
boot are currently asserted by nobody.

Owner: `devops` / `mobile-dev` via the integration-verification pass.
Action: run the merged-branch build and the registry-backed mobile startup smoke
in this worktree, and record both verdict lines in one file under
`integration-review/`.

### B-2 — Requirement-level mobile visual audit does not exist (reviewer SKILL 12g2)

`integration-review/mobile-visual-audit.md` is absent. Rule 12g2 keeps this a
separate, still-blocking cross-screen check before requirement closure, and it
explicitly does not substitute in either direction for the per-story
`visual-fidelity/` evidence (which all seven stories do carry and which their own
gates verified).

REQ-010 is close to the worst case for skipping it: STORY-007 repaints the
backdrop of roughly 37 screens, and its own gate already recorded a cross-screen
contrast concern (D-3 below) that no per-story Home capture can see. The
integration-level breakage this audit exists to catch — navigation, shell, and
cross-screen consistency under the new wash — is exactly what changed here.

Owner: `mobile-dev`.
Action: produce `integration-review/mobile-visual-audit.md` covering the merged
Home plus a representative cross-screen sample under the `--sky` rollout.

## Deferred Findings

| Id | Severity | Finding |
| --- | --- | --- |
| D-1 | LOW | `_PresenceRow`'s `coupleTypeLabel` `Text` (`home_screen.dart:610-617`) still has no `maxLines`/`overflow`. Under `b0c79fc` it is now width-bounded, so it soft-wraps to a second line rather than overflowing — no RenderFlex risk remains. Current values are short (`Yêu xa`, `Cùng thành phố`), but the design shows a single line, so a longer future label would silently change hero height. |
| D-2 | INFO | The 2dp header-actions gap and the `_HeaderActionsRow` spacing are asserted structurally in source, not against rendered pixels (carries STORY-004 DEF-2). B-2's audit is the natural place to close this. |
| D-3 | MEDIUM | STORY-007 D1 carried forward, still open: `--tx2` (`#B4A6CE`) reaches only 2.94:1 against the brightest backdrop wash pixel, below WCAG AA 4.5:1, with a real instance visible in `STORY-007_.../visual-evidence/ad6-chat-dark-vi.png` (status banner row). Not introduced by the merge and not fixable inside a review. Route to `ui-ux-designer` for a token decision. |
| D-4 | MEDIUM | `_DaysCounter` (`home_screen.dart:762-803`) is a `Row(mainAxisSize.min)` whose two `Text` children have no `Flexible`/`Expanded`, so it overflows (~14px at 390dp, contributing to the ~84px overflow observed at 320px). I confirmed `git log -L 762,803` over `9e6f3796..HEAD` is empty — REQ-010 did not touch it, so it is pre-existing from REQ-002/STORY-017 and correctly deferred. Worth noting that STORY-006 D-1 and STORY-007 D2 are almost certainly the same defect reported at two widths, and it is the same unbounded-`Row`-child class as R-1/R-2. Recommend one follow-up bug covering both, not two. |
| D-5 | INFO | `home_screen_test.dart:364-370` resolves `find.descendant(of: hero, matching: find.byType(Row)).first`, which after the merge is the outer header `Row`, not `_PresenceRow`'s. The width assertion is therefore weaker than authored. Not a correctness problem: the load-bearing assertions in the same test (`maxLines`, `overflow`, `didExceedMaxLines`) still prove truncation directly, and a returning unbounded overflow would still fail the test, because `tester.takeException()` at `:346` consumes only the one pre-existing exception. |
| D-6 | INFO | `users.service.ts:39` returns `{ ...user, partnerDisplayName }`, so `GET /users/me` serializes the whole `User` entity while `MeProfileResponseDto` documents a 13-field subset — `@ApiOkResponse` types Swagger, it does not filter the response. Pre-existing (the pre-merge controller returned `findByFirebaseUid` with the same shape) and not made worse by STORY-006, but the new DTO now makes the divergence look intentional. Consider a serialization interceptor in a future backend story. |
| D-7 | INFO | State drift, Scrum-Master-owned, not a code issue: the integration branch's committed `req_master.md:127-133` and the seven `story_master.md` files still read `Status: PENDING` with unticked Review boxes, while the control checkout's untracked copies read `Status: DONE`. Closure must land the control-checkout state; a future reader of this branch alone would see stale story state. |

## Traceability

- Merged stories and gates: the seven `review/review-report.md` files listed in
  `integration-review/scope-gate.md` (line-cited outcomes)
- Merge refs: `9e6f3796..5a8349c2`, integration commits `e39969fe`, `b0c79fc`
- Cross-story contracts: `me-profile-response.dto.ts`, `users.controller.ts`,
  `users.service.ts:30-39`, `cupid_profile.dart`
- Runtime/theme integration: `cupid_app.dart:59`, `cupid_theme.dart:45`,
  `cupid_app_background.dart`, `app_shell.dart:152,189`
- Guard evidence: `shared_backdrop_occlusion_guard_test.dart:32-85`
- Design source resolution: `data/devops/system/design-fidelity-config.json`
  vs `cupid-app-design-system/Cupid App.dc.html:200,239,251`
- Configuration: `req_master.md:9-13` (`NOT_REQUIRED`)
- Integration build/runtime and cross-screen visual evidence: **absent** (B-1, B-2)

## Recommended Workflow State

- Requirement `REQ-010_home_dashboard_deferred_scope_completion`: `IN_PROGRESS`
  — do NOT mark `DONE` yet.
- Do not reopen or unmerge any story. All seven story gates stand; no finding in
  this report routes back to a story lane.
- Route the integration-verification pass for B-1 (`devops` / `mobile-dev`) and
  B-2 (`mobile-dev`) inside this same integration worktree.
- Re-gate this requirement integration review once
  `integration-review/` carries the `## Integration Build & Runtime` verdict
  lines and `mobile-visual-audit.md`. With B-1 and B-2 satisfied and no new
  defect, the expected outcome is `DEFERRED_ONLY` on D-1..D-7.
- Open one follow-up bug for D-4 (unbounded `_DaysCounter` row) covering both
  the 320px and 390dp reports as a single defect.
- Route D-3 (`--tx2` contrast) to `ui-ux-designer` as a token decision.

## Integration Build & Runtime

- Build: PASS — `flutter pub get && flutter build apk --debug` (run in `mobile/` at worktree HEAD `e23f20812691b6ae2872584b424c28e835e93a23`); Gradle task `assembleLocalDebug` succeeded, `Built build/app/outputs/flutter-apk/app-local-debug.apk`.
- Runtime/Smoke: PASS — reused already-online `emulator-5554` (`flutter devices` confirmed visibility), installed the built debug APK via `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk` (Success), then ran the registry `readiness.command` `adb -s "$MOBILE_DEVICE_SERIAL" shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity >/dev/null && for _ in $(seq 1 30); do adb -s "$MOBILE_DEVICE_SERIAL" shell dumpsys activity activities | grep -q "ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity" && exit 0; sleep 2; done; exit 1` — `am start -W` exited 0 and `ResumedActivity` matched on the first poll; then ran `readiness.shutdownCommand` `adb -s "$MOBILE_DEVICE_SERIAL" shell am force-stop com.snapsofts.cupid` (exit 0).
