---
story: STORY-004_home_header_share_days_action
requirement: REQ-010_home_dashboard_deferred_scope_completion
reviewer: Iris-QC
review_type: compact-story-review
review_cycle: 1
reviewed_at: 2026-08-25
---

# Review Report: STORY-004 — Home Header Share Days-Together Action

Outcome: DEFERRED_ONLY

## Scope Gate

Also mirrored to
`data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-004_home_header_share_days_action/review/scope-gate.md`,
which `validate-reviewer-two-phase.sh` requires even for `compact-story-review`
(reviewer SKILL rule 5a says the gate should be inline-only for this mode). The
two are identical; no scope decision differs between them.

| Field | Value |
| --- | --- |
| Review type | `compact-story-review` |
| Report path | `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-004_home_header_share_days_action/review/review-report.md` |
| Worktree | `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-010_home_dashboard_deferred_scope_completion-STORY-004` |
| Diff baseline | `git diff 38a5d9da119e41a73317873ae90c10e8b8438c6f` (HEAD `64bb6e3f082181c4d9e86e3b9144fe0655705d7a`) |
| Source/test/config in scope (4) | `mobile/lib/features/home/presentation/home_screen.dart`, `mobile/test/features/home/home_screen_test.dart`, `mobile/pubspec.yaml`, `mobile/pubspec.lock` |
| Evidence in scope | `coding-plan/test-results.md`, `visual-fidelity/visual-fidelity-report.md`, `visual-fidelity/design-reference-home-android.png`, `visual-fidelity/implemented-home-android.png` |
| Governing artifacts | `story_master.md`, `ux/uiux-spec.md` §1-§4, `architecture/solution.md` §1/§3/§4 (ranged) |
| Query keys | `home_header_share_action`, `_HeaderActionsRow`, `_ShareDaysAction`, `SharePlus.instance.share`, `dev.fluttercommunity.plus/share`, `_headerActionHeight/IconSize/Gap`, `days != null`, `colorTextMuted`, `tapTarget` |
| Budget | Within `compact-story-review` (4 files, 0 large governing artifacts full-read) |
| Retro gate | `data/retro-audit/rework-backlog.md` — all 29 RWB rows `RESOLVED`/`DONE`; zero `PENDING`/`IN_PROGRESS`. Ordinary story review permitted without bypass. |
| Phase 2 | PROCEED |

## Independent Gate Verification

Gates were re-executed, not read off the narrative.

| Gate | Claim | Independent result |
| --- | --- | --- |
| Static analysis | `No issues found!` | RE-RAN `flutter analyze lib/features/home test/features/home` → `No issues found! (ran in 1.6s)` — CONFIRMED |
| Widget tests + regression sweep | 20/20, 7 new | RE-RAN `flutter test test/features/home/` → `00:01 +20: All tests passed!`; the 13 pre-existing tests are present in the run output and pass unchanged — CONFIRMED |
| Build gate | `assembleLocalDebug` OK | RE-RAN `flutter build apk --debug` → `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` — CONFIRMED. Proves `share_plus`, the app's first native-share plugin, registers and the manifest merge is clean. The one Gradle warning is pre-existing KGP usage by `sign_in_with_apple`, unrelated to this story. |
| Visual fidelity (12e3, mobile lane) | `VISUAL_FIDELITY: PASS` | VERIFIED BY READING BOTH IMAGES, not by counting files. Both open as real captures of the Home dashboard, android/dark/`vi`. `Design-Screen: home` is recorded, and the reference genuinely depicts Home (247 ngày bên nhau hero), not another canvas screen or a placeholder. The implemented capture shows the built app's Home with the share glyph rendered at the header's trailing end — no error screen, no spinner, no blank frame. Nothing I see contradicts the `PASS`. Report carries concrete per-property deltas and named states, not a bare token. NOT re-captured, per 12e3. |
| Entry point reachability | `Reachable: YES` | VERIFIED IN CODE, not on trust: `_ShareDaysAction` is mounted inside `_CoupleHero`'s header row in `home_screen.dart`, keyed `home_header_share_action`, on the Home dashboard — an always-visible shell tab root. Not direct-URL-only. Test 1 independently asserts the key is a descendant of `home_couple_hero`. |
| Runtime startup smoke (12g, mobile) | PASS on `emulator-5554` | Accepted from recorded evidence with concrete commands and output (build → `adb install -r` → force-stop → monkey launch → Home renders, no plugin-registration failure). Not re-run: device/emulator lifecycle is out of reviewer scope, and my independent build gate covers the plugin-registration risk this smoke exists to catch. |

## Acceptance Criteria

| AC | Verdict | Traceability |
| --- | --- | --- |
| AC1 — share icon in the design-source position and style, dark + `vi` | PASS | `_ShareDaysAction` uses `context.cupidPlatform.tapTarget` width, `_headerActionHeight = 38`, `_headerActionIconSize = 23`, `colors.colorTextMuted`, `CupidIconVariant.line`, and the `iosShare`/`share` platform branch — every value matches `ux/uiux-spec.md` §1's table line-for-line. Tests 1-2 assert the tokens on both platform branches; visual-fidelity comparison table measures glyph ink box, colour `#B4A6CE`, vertical centring Δ0.19dp and flush right inset. |
| AC2 — tap opens the OS share sheet with the displayed day count | PASS | `SharePlus.instance.share(ShareParams(text: ...))` with the §2 payload `'$days ngày bên nhau rồi 💕'` / `'$days days together 💕'` — exact match to `ux/uiux-spec.md` §2. Tests 4-5 assert the composed string end-to-end by mocking the plugin's real `MethodChannel('dev.fluttercommunity.plus/share')` and reading the arguments map the production call path actually sends, in `vi` and `en`. This is a real payload assertion, not a "handler fired" assertion. |
| AC3 — dismissal produces no error state or crash | PASS | `_share` deliberately does not inspect the returned `ShareResult`; nothing hangs off the outcome. Test 6 drives the real `'' → ShareResultStatus.dismissed` mapping and asserts no `SnackBar` with the counter and action still mounted. |

## Traceability

- **UX (`ux/uiux-spec.md` §1/§2)** — every prescribed token, the `justify-content:center` content alignment (correctly *not* the adjacent `goNotifs` `flex-end`), the §2 payload strings, the §1 accessibility `Semantics(label:, button: true)` recommendation, and the §2 "do not render when `days` is null" UX decision are all implemented as written. The `2`dp gap is off-scale and correctly kept literal rather than rounded to `CupidSpacing.xs`.
- **Architecture (`architecture/solution.md` §1 Key Discovery / §3 / §4)** — Tech Lead, not the implementer, resolved the §3 constraint the UX spec deferred: `share_plus` was added so AC2 is satisfied literally and the clipboard-substitute branch is not taken. Implementation follows that decision exactly; no PO escalation was owed. The §4 non-goals hold — no backend change, no platform-channel authoring, no custom share media, `goNotifs` untouched.
- **Third-party API discipline** — the resolved version (13.3.0), the call signature source (the pub-cache README and `lib/share_plus.dart`), and the deliberate avoidance of the deprecated static `Share.share(String)` are all recorded. The architecture's named risk `Unverified third-party API shape` is closed by evidence, not by assertion.
- **Phase §3 Task 3 structural seam** — `_HeaderActionsRow(actions: List<Widget>)` gap-joins children with `_headerActionGap`, so STORY-005 appends the bell as a sibling without touching the share subtree. Verified in source.
- **Scope containment** — the diff touches exactly 4 source/test/config files, all inside the declared write scope. No Android manifest or iOS `Info.plist` change, matching the resolved package's own requirements.

## Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Status |
| --- | --- | --- |
| Mobile interaction (new tappable header affordance) | Targeted widget tests + static analysis | PASS (re-run) |
| Mobile navigation / discoverability | Entry-point reachability verified in code | PASS |
| External integration (first OS share intent) | Debug APK build proving plugin registration + device launch smoke | PASS (build re-run; smoke from recorded evidence) |
| Package dependencies (`share_plus` 13.3.0 + transitives) | Resolved version, SDK-constraint compatibility, lockfile recorded | PASS |
| Design fidelity (mobile lane, 12e2/12e3) | Implementer capture+compare, reviewer reads both images | PASS |

**Configuration guide (12a):** not required. The change adds one Flutter package that needs no manifest, `Info.plist`, env var, credential, or manual setup step — `flutter pub get` is already part of the standard build. No `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/deployment/configuration-guide.md` update is owed by this story.

## Blocking Findings

None.

## Deferred Findings

### DEF-1 — the header row's long-display-name tolerance shrinks by one tap-target width (LOW)

`_CoupleHero` now wraps `_PresenceRow` and `_HeaderActionsRow` in a
`Row(mainAxisAlignment: spaceBetween)` with neither child made flexible, as
`ux/uiux-spec.md` §1 explicitly prescribes ("`_PresenceRow` does not need
`Expanded`"). `_PresenceRow` (`home_screen.dart:510-560`) is itself a
`Row(mainAxisSize: min)` whose `displayName` `Text` carries no `maxLines`,
`overflow`, or `Flexible` guard.

Both children are laid out with unbounded main-axis constraints, so the
available width for the presence group drops by the share action's
`tapTarget` (48dp Material / 44dp iOS). A `displayName` long enough to
overflow previously would now overflow 48dp sooner, surfacing as a
`RenderFlex` overflow stripe rather than an ellipsis.

Not blocking: no AC covers long names, the missing overflow guard is
pre-existing rather than introduced here, and the design source is itself a
bare flex row — this story reduces an existing margin rather than creating
the defect. Recorded because it is the same class as `RWB-20260816-022`
(a story silently removing a layout's tolerance), and because every fixture
and capture in this story's evidence uses the 4-character name `Minh`, so the
long-name path was never exercised.

Suggested future remediation (one line, mobile lane): wrap `_PresenceRow` in
`Flexible` and give the `displayName` `Text` `maxLines: 1` +
`TextOverflow.ellipsis`.

### DEF-2 — the actions-row `2`dp gap is asserted in source only (INFO)

`_headerActionGap` is correct against `Cupid Screens.dc.html:248`, but with a
single action rendered it has no pixel effect and no test observes it. It
first becomes observable when STORY-005 appends the notifications bell.
Recorded so STORY-005's review knows the gap is unproven until then, not as
a defect of this story.

## Accepted Deviations Reviewed

Both deviations recorded by mobile-dev were checked against their stated
justification and stand:

- **V1** — the glyph's ink sits ~9dp further from the screen edge than the raw
  design markup. Mandated by `ux/uiux-spec.md` §1's `tapTarget` accessibility
  requirement; the tap **box** edge is flush at 21.3dp against the hero's own
  21.7-22.5dp content inset. Shrinking it would breach the platform minimum
  the spec requires. Correctly classified.
- **V2** — the design's notification bell is absent. `architecture/solution.md`
  §4 and `ux/uiux-spec.md` §4 both place `goNotifs` in STORY-005 scope, and
  the extension seam is present. Correctly classified as another story's scope,
  not drift.

## State Recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE` (currently `PENDING` in `story_master.md`; Scrum Master
  owns the transition).
- Story branch `codex/REQ-010_home_dashboard_deferred_scope_completion-STORY-004`
  is merge-eligible into
  `codex/REQ-010_home_dashboard_deferred_scope_completion-integration`.
- Carry DEF-1 and DEF-2 forward to the REQ-010 requirement integration review;
  DEF-2 in particular is a direct input to STORY-005's review.
