# STORY-031 Review Report — Notifications Design Fidelity

Outcome: DEFERRED_ONLY

Review type: `compact-story-review` (round 1, first reviewer pass)
Reviewer: Iris-QC
Story: STORY-031 — Design Fidelity: Notifications (REQ-002, lane `mobile`,
`Complexity: trivial`)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-031`
Diff baseline: `92930ec` → `ea4b9c3` (single implementation commit)

## Scope Gate

| Field | Value |
| --- | --- |
| Review report path | `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-031_notifications_design_fidelity/review/review-report.md` |
| Source files in scope | `mobile/lib/features/account/presentation/screens/notification_settings_screen.dart` |
| Test files in scope | `mobile/test/features/account/presentation/screens/notification_settings_screen_test.dart` |
| Artifact files in scope | `story_master.md`, `visual-fidelity/visual-fidelity-report.md` |
| Evidence in scope | `visual-fidelity/design-reference-notifs-android.png`, `visual-fidelity/implemented-notifs-android-emulator-5560.png` |
| Query keys | AC1–AC5, `Design-Screen: notifs`, `notifs_cap_banner`, `notifs_row_synced_alarm_*`, `NotificationSettingsScreen` entry point, `VISUAL_FIDELITY` |
| Touched files (total) | 6 (4 in `mobile/`, 2 artifacts) — inside the compact budget |
| Widened beyond gate | `mobile/lib/l10n/arb/app_vi.arb` / `app_en.arb` (read-only, to verify AC3/AC4 copy at source), `mobile/lib/features/account/presentation/screens/me_screen.dart:134` (read-only, 12e1 entry point) |

No `data/retro-audit/rework-backlog.md` exists in this worktree, so no pending
retro rework blocks this gate.

## Acceptance criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — layout/spacing/color/typography match the design source in dark + `vi` | PASS with deferrals | 18 deltas corrected in `notification_settings_screen.dart`; screen-local content matches the reference. Residual differences are app-shell/background chrome owned by other stories (D1–D4). |
| AC2 — deviations corrected in the app, not merely documented | PASS | Every row of the report's delta table maps to a real hunk in the commit diff; the capture was regenerated post-fix from the built APK. |
| AC3 — no DND-bypass claim in user-visible copy | PASS | `notifs_cap_banner` = `Tối đa 15 thông báo/ngày.` (`vi`) / `Max 15 pushes/day.` (`en`). No `Do Not Disturb` / `DND` string in any `notifs_*` key. Pinned by the `shows only the numeric cap copy, no DND-bypass clause (DEC-6)` test. |
| AC4 — synced-reminder wording, never alarm framing | PASS | `notifs_row_synced_alarm_title` = `Nhắc nhở đồng bộ` / `Synced Reminder`; subtitle `Nhắc trên cả hai máy` (design's `Reo` ring-framing dropped). Pinned by the `names the first critical row a reminder, never an alarm` test, which rejects `báo thức` / `alarm` in any rendered text under `vi`. |
| AC5 — no new entry point required | PASS | `me_screen.dart:134` pushes `NotificationSettingsScreen` from the Me-screen notifications row; unchanged by this story. |

## 12e1 Entry point reachability

Independently verified in code, not taken on trust: `me_screen.dart:134`
constructs `NotificationSettingsScreen` inside a `MaterialPageRoute` pushed from
a tappable Me-screen row. Regression-covered by `MeScreen tapping the
notifications row navigates to NotificationSettingsScreen` (passing). Not
direct-URL-only. This story changes no navigation.

## 12e2 / 12e3 Design fidelity (mobile lane — verified, not re-captured)

- Both images exist and open as real images at
  `<story>/visual-fidelity/`: `design-reference-notifs-android.png` (406x900)
  and `implemented-notifs-android-emulator-5560.png` (405x900).
- I opened both. The reference depicts the Notifications settings screen
  (`Thông báo`, CRITICAL / ENGAGEMENT / INFO, the same 7 rows) — it is this
  story's screen, not a different canvas screen, not a placeholder. The
  implemented capture shows that screen in the built app: real content, no
  error frame, no spinner, no wrong screen.
- `Design-Screen: notifs` is recorded in `story_master.md`, and the reference I
  looked at is that screen. The report documents how the id was resolved
  (37 canvas ids, `notifs` the only notification-settings candidate, confirmed
  by rendering it).
- `VISUAL_FIDELITY: PASS` is backed by a concrete comparison: 18 named deltas
  with was/now values sourced to `Cupid Screens.dc.html:1381` and `:2400-2408`,
  a list of values verified-and-left-alone, and two AC-mandated intentional
  deviations. This is a comparison that happened, not a bare token.
- What I see in the two images does not contradict the verdict for the screen
  this story owns. The visible residuals are app-shell and app-background
  chrome (D1–D3) plus one ARB-blocked text-emphasis delta (D4), all recorded
  below rather than absorbed into the PASS.

## Verification re-run independently

| Gate | Command | Result |
| --- | --- | --- |
| Static analysis | `flutter analyze lib/features/account lib/design_system` | No issues found (2.5s) |
| Targeted tests | `flutter test test/features/account` | All tests passed — 86, including both new copy guards |
| Runtime / launch | `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=notifs` + on-device capture (implementer evidence) | Built and rendered on `emulator-5560`; the capture is itself proof the built app launches and paints this screen without a crash or error screen |

## Touched risk surfaces and critical gates

| Surface | Gate | Status |
| --- | --- | --- |
| Mobile interaction (toggle rows) | Widget test asserting toggle flips and persists | PASS |
| Mobile navigation / discoverability | Entry-point verification in code + `MeScreen` navigation test | PASS |
| Design fidelity (rendered) | Device capture vs design reference, per 12e3 | PASS with deferrals |
| User-visible copy correctness | Two locale-scoped copy-guard widget tests + ARB source read | PASS |
| Local storage / offline | Untouched by this diff; existing `NotificationPreferencesStore` tests still pass | Not required |

No persistence, schema, contract, external-integration, permissions, deep-link,
security, or configuration surface was touched. No
`deployment/configuration-guide.md` impact.

## Deferred findings

Each is out of this story's WriteScope (verified against the run file's
`write_scope`: `mobile/lib/l10n/arb/**` and `mobile/lib/core/navigation/**` are
absent from it) or already owned by a named sibling story. Routing is
Scrum Master's call.

- **D1 — Bottom navigation differs from the design.** Design shows 5 tabs with
  `Tôi` active; the app shows 3 tabs plus an account-hub FAB. Already logged as
  STORY-017 finding F7, owner STORY-001 `core/navigation/app_shell.dart`.
  Additional detail this capture adds: the pink FAB **overlaps the Love Timeline
  row's toggle** at the bottom right of the Notifications screen. That is an
  occlusion of an interactive control, not only a tab-count mismatch. It
  resolves when the shell is corrected, but it should be re-checked explicitly
  in the requirement-level `mobile-visual-audit.md` rather than assumed fixed.
- **D2 — App background chrome missing.** Design renders a sky-gradient backdrop
  with twinkle dots behind the content; the app renders flat dark. Already
  logged as STORY-009 items 1 and 3 (app-wide background).
- **D3 — Header back affordance.** Design uses a pink `←` at 26px; the app uses
  a smaller light-tinted arrow. Already logged as STORY-009 review item 2, owner
  a design-system story, affecting every screen with a back affordance.
- **D4 — Banner inline emphasis not reproduced.** The design renders the
  `15 thông báo/ngày` fragment in `--tx` against `--tx2` body text; the app
  renders the whole banner uniformly muted. This one is screen-local, so it is
  named here as an AC1 residual rather than as chrome — but reproducing it needs
  the banner split into new `mobile/lib/l10n/arb/*.arb` entries, and the ARB
  files are outside this story's WriteScope and concurrently owned by sibling
  stories in the active wave. Route to whichever story owns the l10n surface;
  do not patch it here at the cost of a cross-story ARB conflict.
- **D5 — No golden baseline for this screen.** `matchesGoldenFile` would write
  under `test/.../goldens/`, outside this story's WriteScope. The two copy
  guards are the in-scope regression protection that was added; the pixel
  baseline should be established by the story that owns the goldens directory.
- **D6 — Design source spacing is off the 8pt token scale.** The corrections
  hardcode `13`, `17`, `18`, `9.5`, `12.5`, `15/9` because the design column's
  values do not exist in `CupidSpacing`. AC1 demands the exact design values, so
  the hardcoding is correct here and the code documents each source line. But
  sibling design-fidelity stories will keep hitting this, so the design-system
  owner should decide whether to widen the token scale or accept documented
  literals as the convention.

## Blocking findings

None.

## Notes for Scrum Master

- The run file records `story_class: standard` while `story_master.md` records
  `Complexity: trivial` / `Story-Class: trivial`. Under the trivial
  classification rule 12g's registry-backed runtime startup smoke is not
  mandatory; under `standard` it would be, and it is satisfied in substance by
  the debug-APK build plus the on-device capture of this screen. Worth
  reconciling the two records so the DONE gate reads a consistent class, but it
  does not change this outcome.
- Worktree is clean: no untracked files, no modified files, nothing written
  outside the declared WriteScope. The only ARB and `me_screen.dart` access in
  this review was read-only.

## Traceability

- Requirements / AC: `story_master.md` AC1–AC5, `## In Scope` items 1–4,
  `## Open Question Impact` (OQ5 light/`en` is out of scope and blocks no AC;
  UX memory §7's DND conflict is resolved by AC3).
- UX: no separate UX spec — `UX Design (UI/UX Designer) — SKIPPED:trivial`. The
  design source `cupid-app-design-system` screen `notifs` is the UX baseline and
  was compared directly.
- Architecture: `SKIPPED:trivial`; no contract, boundary, or state-management
  change in the diff.
- Testing evidence: `visual-fidelity/visual-fidelity-report.md` `## Verification`,
  independently re-run above.

## State recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE`.
- Route D1–D6 to their named owners; D1's FAB occlusion should be re-verified in
  the requirement-level mobile visual audit before REQ-002 closure.
