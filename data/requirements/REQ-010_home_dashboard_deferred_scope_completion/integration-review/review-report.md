# Requirement Integration Review — REQ-010 Home Dashboard Deferred Scope Completion

Outcome: DEFERRED_ONLY

- Review type: `requirement-integration-review` (`Flow: parallel-requirement`)
- Reviewer: Iris-QC, 2026-08-25 (pass 1: `PATCH_REQUIRED`; pass 2 re-gate: `DEFERRED_ONLY`)
- Scope gate: `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/integration-review/scope-gate.md`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-010_home_dashboard_deferred_scope_completion`
- Branch: `codex/REQ-010_home_dashboard_deferred_scope_completion-integration`
- Diff range: `9e6f3796..5a8349c2` (36 commits; 22 source/test/config files, +3158/-204)
- Re-gate head: `95fda0b3` (docs/evidence only on top of `5a8349c2`; source diff unchanged)
- Blocking findings: 0 (2 raised in pass 1, both closed) · Deferred findings: 9 · Carry-forward deferrals resolved: 5

## Rationale

The merged code is integration-clean. Every cross-story surface I checked in the
merged tree is consistent, the `b0c79fc` integration fix is correct and
substantively closes two carry-forward findings, and one carry-forward finding
that was flagged as possibly affecting all seven stories turns out to be a false
alarm (see R-5).

The two pass-1 blocking findings were both requirement-level *verification gates
that did not yet exist*, not code defects. The handoff scoped pass 1 as
read-only ("do not build or boot the app yourself; that verification step
happens separately"), which is exactly the routing reviewer SKILL rule 12g3
prescribes — so that `PATCH_REQUIRED` meant "run the integration-verification
pass and re-gate", not "the stories were built wrong".

Pass 2 (re-gate): both gates now exist and hold. The merged tree builds and
boots, and a cross-screen visual audit of the running merged build found no
blocking breakage. The verification also improved the finding set rather than
merely satisfying a checklist — it corrected one of my own severity calls
downward (D-3), sized another finding more precisely (D-4), and surfaced two
genuine light-theme findings that are not reachable in the shipped app (D-8,
D-9). Nothing remaining blocks closure, so the outcome is `DEFERRED_ONLY`.

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

## Re-gate (pass 2)

Pass 1 blocked on exactly two requirement-level verification gates that did not
exist. Both are now closed on this branch, and I verified the evidence rather
than accepting the closure claim:

| Gate | Closing commit | Verified |
| --- | --- | --- |
| B-1 | `8ed5c777` | RESOLVED — see B-1 below |
| B-2 | `95fda0b3` | RESOLVED — see B-2 below |

Checks performed in this pass:

- **No source drift behind the evidence.** `git diff --name-only e23f2081 HEAD`
  returns only `integration-review/` docs and screenshots, and `git status`
  is clean. The build in `## Integration Build & Runtime` ran at `e23f2081`,
  whose source tree is identical to `5a8349c2` — the reviewed source diff. The
  build/runtime verdict therefore covers the exact code being gated.
- **The smoke is genuinely registry-backed.** The `readiness.command` and
  `readiness.shutdownCommand` quoted in B-1's evidence match
  `data/devops/system/runtime-command-registry.json:224` and `:227`
  byte-for-byte. It is not an ad-hoc `adb` invocation.
- **The visual audit's supersessions are supported by the pixels**, not just
  asserted — I re-read the crops myself (see the reassessment below).
- No new blocking defect surfaced. Per re-review rules I did not reopen
  story-level code that its own gate already cleared.

### Mobile Visual Audit Reassessment Of My Own Findings

`integration-review/mobile-visual-audit.md` (Result: PASS,
`MOBILE_VISUAL_AUDIT_COMPLETE: YES`) refines three of my carried findings with
direct measurement. I accept all three, on this evidence:

- **D-3 severity reverted (was: "reachable in a real screen today").** The audit
  measured `#241B42` under the chat status-text glyphs at 7.09:1 — passing AA —
  on both a fresh runtime capture and my own `ad6-chat-dark-vi.png` reference.
  `crop-chat-dark-vi-status-banner.png` confirms visually: "đang online" sits on
  the presence chip's own opaque dark pill, not on the wash. The sub-3:1 pixels
  I attributed to text background are the presence avatar's decorative
  teal/blue gradient disc. My pass-1 escalation was wrong; D-3 returns to the
  original STORY-007 test-results severity and stays deferred/UX-owned.
- **D-3's real sub-3:1 instance is on Home and is non-text.** 2.95:1 at the
  gradient "247" numeral, against an AA-large threshold of 3.0:1, on decorative
  display text. `crop-home-dark-vi-hero-d1-region.png` confirms the scale, and
  the informational line beneath it measures 7.02:1. Non-blocking.
- **D-4 does not reproduce on-device at 390dp** with the default fixture. The
  audit is appropriately careful not to claim D-4 is invalid — the harness pins
  `withNoTextScaling` and the fixture uses a short name and a 3-digit count, so
  longer inputs or a font-size override may still hit it. D-4 stays deferred;
  this sizes it, it does not close it.

I also independently confirmed the two claims the audit's non-blocking verdict
rests on, since they are what make F-6/F-7 (D-8/D-9 below) unreachable:
`cupid_feature_flags.dart:7-10` defaults `enableLightTheme` to `false`, and
`cupid_app.dart:49-52` pins `ThemeMode.dark` and `Locale('vi')` when the flags
are off. The shipped app is dark-only and `vi`-only, so the light-theme findings
are pre-exposure, not live defects — and the audit's `en` coverage gap is
justified by the same line rather than being an untested surface.

`implemented-home-dark-vi-emulator-5554.png` shows all six Home-scoped stories
in one frame with no overflow stripe, and
`implemented-home-dark-vi-260dp-header-bound-emulator-5554.png` shows the
merged header under real width pressure resolving cleanly — the couple-type
subtitle wrapping inside its bound while both actions stay right-aligned. That
is the running-app confirmation of `b0c79fc` that pass 1 could not obtain, and
it closes R-1/R-2 behaviourally as well as structurally.

## Blocking Findings

Both findings below were raised in pass 1 and are now **closed**. They are kept
for traceability, each with its closing evidence.

### B-1 — RESOLVED (`8ed5c777`) — Integration build + runtime evidence (reviewer SKILL 12g3)

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

**Closure:** DevOps appended `## Integration Build & Runtime` to this report in
`8ed5c777`, carrying both required lines. `Build: PASS` (`flutter build apk
--debug`, Gradle `assembleLocalDebug`, APK produced) and `Runtime/Smoke: PASS`
(registry `readiness.command` — `am start -W` exit 0, `ResumedActivity` matched
on the first poll — then `readiness.shutdownCommand` exit 0). Verified the
commands against `runtime-command-registry.json:224,227` and verified the build
commit's source tree is identical to the reviewed diff head. The specific risk I
named — that the merged tree's build and boot were asserted by nobody after
`b0c79fc` and the STORY-007 merge landed — is now closed by a run on that exact
tree. `req_master.md` still records no `Integration-Verify: WAIVED`, and none is
needed.

### B-2 — RESOLVED (`95fda0b3`) — Requirement-level mobile visual audit (reviewer SKILL 12g2)

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

**Closure:** `integration-review/mobile-visual-audit.md` plus 21 captures under
`integration-review/mobile-screenshots/` landed in `95fda0b3`. It covers the
cumulative Home (all six Home-scoped stories in one frame) in dark and light at
411/390/320/260dp and scrolled, plus the cross-screen sample the `--sky` rollout
required: chat, timeline, welcome, paired, and me. Result: PASS, no blocking
breakage. This is genuine cross-screen coverage from a running merged build, not
a restatement of per-story evidence, and it is what found F-6/F-7 — the exact
class of app-wide theme interaction I argued no per-story Home capture could
see.

## Deferred Findings

| Id | Severity | Finding |
| --- | --- | --- |
| D-1 | LOW | `_PresenceRow`'s `coupleTypeLabel` `Text` (`home_screen.dart:610-617`) still has no `maxLines`/`overflow`. Under `b0c79fc` it is now width-bounded, so it soft-wraps to a second line rather than overflowing — no RenderFlex risk remains. Current values are short (`Yêu xa`, `Cùng thành phố`), but the design shows a single line, so a longer future label would silently change hero height. |
| D-2 | INFO | The 2dp header-actions gap and the `_HeaderActionsRow` spacing are asserted structurally in source, not against rendered pixels (carries STORY-004 DEF-2). **Partially addressed:** the audit confirms both actions render as a right-aligned grouped pair at every width down to 260dp, so the grouping is now visually verified; the 2dp value itself is still not pixel-measured. Downgraded to a documentation-level gap. |
| D-3 | MEDIUM (severity reverted) | STORY-007 D1 carried forward, still open: `--tx2` (`#B4A6CE`) reaches only ~2.94:1 against the brightest backdrop wash pixel, below WCAG AA 4.5:1. **Superseded in scope by the audit (F-2/F-3):** my pass-1 escalation to "reachable in a real screen today via the chat status banner" is withdrawn — that text sits on the presence chip's opaque pill at 7.09:1, and the low-contrast pixels there are a decorative avatar gradient. The genuine sub-3:1 instance is Home's gradient "247" numeral at 2.95:1, which is decorative AA-large display text missing 3.0:1 by 0.05. Still a real token question, still not fixable inside a review. Route to `ui-ux-designer` with D-8/D-9 as one token/backdrop decision. |
| D-4 | MEDIUM | `_DaysCounter` (`home_screen.dart:762-803`) is a `Row(mainAxisSize.min)` whose two `Text` children have no `Flexible`/`Expanded`, so it overflows (~14px at 390dp, contributing to the ~84px overflow observed at 320px). I confirmed `git log -L 762,803` over `9e6f3796..HEAD` is empty — REQ-010 did not touch it, so it is pre-existing from REQ-002/STORY-017 and correctly deferred. Worth noting that STORY-006 D-1 and STORY-007 D2 are almost certainly the same defect reported at two widths, and it is the same unbounded-`Row`-child class as R-1/R-2. Recommend one follow-up bug covering both, not two. **Sized by the audit (F-5):** does not reproduce on-device at exactly 390dp with the default fixture (short name, 3-digit count, `withNoTextScaling` pinned). It may still reproduce with longer names, a 4-digit count, or a system font-size override, so the finding stands — but the follow-up bug should be written as an input-dependent bound, not an always-on overflow. |
| D-5 | INFO | `home_screen_test.dart:364-370` resolves `find.descendant(of: hero, matching: find.byType(Row)).first`, which after the merge is the outer header `Row`, not `_PresenceRow`'s. The width assertion is therefore weaker than authored. Not a correctness problem: the load-bearing assertions in the same test (`maxLines`, `overflow`, `didExceedMaxLines`) still prove truncation directly, and a returning unbounded overflow would still fail the test, because `tester.takeException()` at `:346` consumes only the one pre-existing exception. |
| D-6 | INFO | `users.service.ts:39` returns `{ ...user, partnerDisplayName }`, so `GET /users/me` serializes the whole `User` entity while `MeProfileResponseDto` documents a 13-field subset — `@ApiOkResponse` types Swagger, it does not filter the response. Pre-existing (the pre-merge controller returned `findByFirebaseUid` with the same shape) and not made worse by STORY-006, but the new DTO now makes the divergence look intentional. Consider a serialization interceptor in a future backend story. |
| D-7 | INFO | State drift, Scrum-Master-owned, not a code issue: the integration branch's committed `req_master.md:127-133` and the seven `story_master.md` files still read `Status: PENDING` with unticked Review boxes, while the control checkout's untracked copies read `Status: DONE`. Closure must land the control-checkout state; a future reader of this branch alone would see stale story state. |
| D-8 | MEDIUM (not user-reachable) | NEW, from the audit (F-6): in **light** theme, secondary body text on the sky wash falls below WCAG AA — Home hero subtitle 3.97:1 and header couple-type subtitle 3.69:1 against a 4.5:1 body threshold (the token is already marginal at 4.45:1 on white; the wash pushes it clearly under). This is the light-theme analogue of D-3 and STORY-007's AD-6 work measured dark theme only, so no per-story capture could have found it. Gated: `CupidFeatureFlags.enableLightTheme` defaults `false` (`cupid_feature_flags.dart:7-10`) and `cupid_app.dart:49-51` therefore pins `ThemeMode.dark` — I verified both. Not reachable in the shipped app, so it is a pre-exposure finding, not a live defect. Must be resolved before that flag is ever flipped. Route to `ui-ux-designer` with D-3. |
| D-9 | LOW (not user-reachable) | NEW, from the audit (F-7): the `welcome` screen is one of AD-3's ratified allowlisted occluders and paints its own theme-invariant saturated gradient art, but its foreground text follows the active theme. In light theme this becomes dark text on saturated art with a visibly low-contrast body line and footnote, and the Google button inverts to a fill that does not match other light-theme surfaces. Pre-existing (STORY-007 changed no files under `mobile/lib/`), non-blocking, and carries the same `enableLightTheme=false` qualifier as D-8. Route with D-3/D-8. |

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
- Integration build/runtime: `## Integration Build & Runtime` below (`8ed5c777`),
  commands matched against `data/devops/system/runtime-command-registry.json:224,227`
- Cross-screen visual evidence: `integration-review/mobile-visual-audit.md` and
  `integration-review/mobile-screenshots/` (21 captures, `95fda0b3`)
- Feature-flag gating behind D-8/D-9: `mobile/lib/core/config/cupid_feature_flags.dart:7-15`,
  `mobile/lib/app/cupid_app.dart:49-52`
- Evidence-vs-source integrity: `git diff --name-only e23f2081 HEAD` returns
  `integration-review/` paths only; `git status` clean at `95fda0b3`

## Recommended Workflow State

- Requirement `REQ-010_home_dashboard_deferred_scope_completion`: eligible to be
  marked `DONE`. Both pass-1 blockers are closed with verified evidence and no
  new blocking defect exists.
- Do not reopen or unmerge any story. All seven story gates stand; no finding in
  this report routes back to a story lane.
- Land the control-checkout state noted in D-7 as part of closure, so the branch
  and the control checkout stop disagreeing about story status.
- Open one follow-up bug for D-4 (unbounded `_DaysCounter` row) covering both
  the 320px and 390dp reports as a single defect. Write it as an
  input-dependent bound: per the audit it does not reproduce at 390dp with the
  default short-name/3-digit fixture.
- Route D-3, D-8, and D-9 to `ui-ux-designer` as **one** token/backdrop decision
  — `--tx2` on the sky wash across both themes — not three separate items. D-8
  and D-9 must be resolved before `enableLightTheme` is ever flipped to `true`.
- No `en`-locale coverage exists in the audit. That is acceptable while
  `enableEnLocale` defaults `false` (`cupid_app.dart:52` pins `Locale('vi')`),
  but any future story that flips that flag must carry its own locale visual
  pass; the current evidence says nothing about `en` layout.

## Integration Build & Runtime

- Build: PASS — `flutter pub get && flutter build apk --debug` (run in `mobile/` at worktree HEAD `e23f20812691b6ae2872584b424c28e835e93a23`); Gradle task `assembleLocalDebug` succeeded, `Built build/app/outputs/flutter-apk/app-local-debug.apk`.
- Runtime/Smoke: PASS — reused already-online `emulator-5554` (`flutter devices` confirmed visibility), installed the built debug APK via `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk` (Success), then ran the registry `readiness.command` `adb -s "$MOBILE_DEVICE_SERIAL" shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity >/dev/null && for _ in $(seq 1 30); do adb -s "$MOBILE_DEVICE_SERIAL" shell dumpsys activity activities | grep -q "ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity" && exit 0; sleep 2; done; exit 1` — `am start -W` exited 0 and `ResumedActivity` matched on the first poll; then ran `readiness.shutdownCommand` `adb -s "$MOBILE_DEVICE_SERIAL" shell am force-stop com.snapsofts.cupid` (exit 0).
