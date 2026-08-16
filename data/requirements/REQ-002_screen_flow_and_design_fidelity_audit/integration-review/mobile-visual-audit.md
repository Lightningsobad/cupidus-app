# REQ-002 Requirement Mobile Visual Audit

- Requirement: `REQ-002_screen_flow_and_design_fidelity_audit` (33 stories merged)
- Scope: requirement-level rollup verification of the merged integration build.
  Not a from-scratch re-audit; per-story design-fidelity findings already closed
  at their story gates are not re-litigated here.
- Platform / device: Android, `emulator-5560` (pre-existing runtime handed over
  by the DevOps Round 2 pass; not booted, reset, wiped, or repaired by this pass)
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
- Screenshots: `integration-review/mobile-screenshots/` — 31 PNG, 405x900 each,
  3.7 MB total
- **visual_fidelity_verdict: PASS_WITH_NOTES**

## Verdict Summary

30 of 31 audited screens show no broken, clipped, overlapping, misaligned,
unreadable, wrong-density, or missing UI components at integration scope.

One screen (`welcome`) has a background-gradient token defect that produces a
white-on-pale-lavender contrast failure. It is traceable to a per-story deferral
(STORY-004 D1/D13) but its severity is only observable now, and the constraint
that forced the deferral no longer exists at requirement scope. Recommend
routing IF-1 before REQ-002 is marked DONE.

## Runtime And Capture Method

The merged app was exercised through the existing Flutter preview entrypoint
(`mobile/lib/main_preview.dart`), driven by the STORY-018 P6 DEC-1 runtime deep
link `cupidpreview://screen/<id>`, so all 31 screens were captured from a single
build of the integration HEAD rather than 31 rebuild cycles.

| Item | Value |
|---|---|
| Build | `flutter build apk --debug --target-platform=android-arm64 -t lib/main_preview.dart` — exit 0 |
| Capture tool | `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh --max-edge=900` |
| Screen switch | `cupidpreview://screen/<id>` (debug-only intent filter) |
| Session | Authenticated preview fixture session (`PREVIEW_EMAIL` / `PREVIEW_PASSWORD`), backend reachable at `http://10.0.2.2:3000` |

Capture caveat: installing the preview APK replaced the DevOps `lib/main.dart`
debug build on `emulator-5560` (same `applicationId`). The emulator lifecycle
itself was untouched. Re-install the `lib/main.dart` debug build if a later pass
needs the production entrypoint on this device.

Harness caveat (important for reviewers): on shell-wrapped registry entries the
bottom tab bar and the pink circular account FAB are rendered by
`mobile/lib/preview/preview_app_shell_chrome.dart`, which composes the
production `CupidTabBar` and mirrors `core/navigation/app_shell.dart`'s FAB.
Tab-bar *inventory* seen in these captures is therefore faithful to production,
but tab-bar *presence* on a given screen is registry-driven, not proof that the
real navigation stack renders shell chrome there. FAB-over-content overlap seen
on `notifs` / `privacy` / `gallery` is a preview-composition artifact and is
**not** filed as a defect.

## Coverage

31 of 38 design canvas screens audited. Not covered, with reason:

| Screen | Reason |
|---|---|
| `zodiac` | STORY-023 DEFERRED; not implemented |
| `themes`, `themedetail` | No implementation (`_notImplementedCanvasIds`) |
| `sharepick`, `shareedit`, `shareapprove`, `shareok` | No implementation (`_notImplementedCanvasIds`) |

## Audited Screens

All screenshots are `mobile-screenshots/implemented-<id>-emulator-5560.png` on
`emulator-5560`.

| # | Screen | Result | Finding |
|---|---|---|---|
| 1 | `splash` | PASS | No broken/misaligned mobile UI components observed |
| 2 | `welcome` | FAIL | IF-1 — background gradient renders pale lavender→pink; white text and footnote near-illegible |
| 3 | `login` | PASS | No broken/misaligned mobile UI components observed |
| 4 | `register` | PASS | No broken/misaligned mobile UI components observed |
| 5 | `otp` | PASS | IF-4 (minor) — backdrop flatter/darker than the ambient wash on sibling auth screens |
| 6 | `forgot` | PASS | No broken/misaligned mobile UI components observed |
| 7 | `permissions` | PASS | No broken/misaligned mobile UI components observed |
| 8 | `profile` | PASS | No broken/misaligned mobile UI components observed |
| 9 | `pairingchoice` | PASS | No broken/misaligned mobile UI components observed |
| 10 | `invite` | PASS | IF-2 — header shows a bare back arrow with no title |
| 11 | `joincode` | PASS | IF-2 — header shows a bare back arrow with no title |
| 12 | `waiting` | PASS | No broken/misaligned mobile UI components observed |
| 13 | `paired` | PASS | No broken/misaligned mobile UI components observed |
| 14 | `contract` | PASS | No broken/misaligned mobile UI components observed |
| 15 | `vow` | PASS | No broken/misaligned mobile UI components observed |
| 16 | `home` | PASS | No broken/misaligned mobile UI components observed |
| 17 | `chat` | PASS | IF-3 — no partner header; content starts at the Level 1 privacy pill |
| 18 | `ghostset` | PASS | No broken/misaligned mobile UI components observed |
| 19 | `vibe` | PASS | No broken/misaligned mobile UI components observed |
| 20 | `alarm` | PASS | Routed deltas 5 and 6 resolved at integration scope (see below) |
| 21 | `antighost` | PASS | No broken/misaligned mobile UI components observed |
| 22 | `pet` | PASS | No broken/misaligned mobile UI components observed |
| 23 | `timeline` | PASS | No broken/misaligned mobile UI components observed |
| 24 | `gallery` | PASS | IF-5 — photo tiles render as empty dark rectangles (date chip + badge only) |
| 25 | `jar` | PASS | No broken/misaligned mobile UI components observed |
| 26 | `jarlist` | PASS | No broken/misaligned mobile UI components observed |
| 27 | `jarnew` | PASS | IF-6 — bare Material underline text fields, no back affordance; captured outside its normal modal-sheet host |
| 28 | `expense` | PASS | IF-2 — title with no back affordance |
| 29 | `me` | PASS | No broken/misaligned mobile UI components observed |
| 30 | `privacy` | PASS | No broken/misaligned mobile UI components observed |
| 31 | `notifs` | PASS | Routed delta 4 still open (banner copy) |

## Integration-Scope Findings

Only deviations visible at requirement scope, i.e. that a single story-scoped
review could not have owned.

### IF-1 — `welcome` background gradient uses the CTA button token — HIGH

`welcome_screen.dart:155` paints the full-screen backdrop with
`colors.gradientHot.colors.reversed`. `gradientHot` is the two-stop *button*
gradient `[#FF7FB6, #B78CF5]` (`cupid_color_tokens.dart:99-103`), so reversed it
renders light purple → light pink. The locked design specifies the three-stop
brand backdrop `linear-gradient(165deg, #7B2FBE 0%, #FF4B8C 58%, #FF3366 100%)`.

Consequence: every foreground element on the screen is white, over a pale
backdrop. The sub-copy and the centred legal footnote ("Đăng ký nghĩa là bạn
chấp nhận bị dỗi khi seen không trả lời.") are near-illegible, the 52x4 accent
rule is almost invisible, and the outlined "Dùng email" CTA has very low
contrast. Compare `mobile-screenshots/implemented-welcome-emulator-5560.png`
against `STORY-033_app_shell_design_system_deltas/visual-fidelity/design-reference-welcome-android.png`.

Why this is integration scope, not a re-litigation: STORY-004 corrected the
composition (D1–D11 — left-aligned wordmark, accent rule, tagline, sub-copy, CTA
stack all now match) and explicitly deferred the literal brand hexes as D13,
because `lib/design_system/` was outside that story's WriteScope. That
constraint is gone now that STORY-032/STORY-033 are merged, and with the layout
fixed the remaining colour defect is no longer cosmetic — it is a contrast
failure on the app's first post-splash screen.

Recommend Scrum Master route a fix (add the three-stop welcome backdrop gradient
as a design-system token) before REQ-002 is marked DONE. Not fixed here: this is
an audit pass.

### IF-2 — Inconsistent screen header affordances — MEDIUM

Three header patterns coexist across the merged build:

- back arrow + title: `otp`, `forgot`, `permissions`, `profile`, `vibe`,
  `alarm`, `antighost`, `timeline`, `contract`, `ghostset`, `jar`, `jarlist`,
  `privacy`, `notifs`
- back arrow, no title: `invite`, `joincode`
- title, no back arrow: `expense`, `jarnew`

`expense` and `jarnew` have no visible back affordance at all. Observed in the
preview harness, so confirm against the live navigation stack before changing
code — a host route may supply the leading control. No single per-screen story
owned the shared header contract.

### IF-3 — `chat` has no partner header — LOW

`chat` opens directly on the "Level 1 · chỉ nằm trên máy hai người" privacy pill
with no partner identity header, unlike every other paired-context screen.
Possibly fixture-dependent.

### IF-4 — `otp` backdrop inconsistent with sibling auth screens — LOW

`otp` renders a noticeably flatter, darker backdrop than the ambient purple wash
on `forgot` / `permissions` / `profile`.

### IF-5 — `gallery` photo tiles render empty — LOW / needs data caveat

Tiles show only the date chip and badge over empty dark rectangles; no
thumbnails. Likely seeded-data dependent rather than a layout defect. Re-check
with a seeded media fixture before routing.

### IF-6 — `jarnew` field styling off the design system — LOW

Uses bare Material underline `TextField`s rather than the rounded filled field
cards used on `login` / `register`. Note `jarnew` is normally a modal sheet
(`CreateDreamJarSheet`) and was captured in a bare Scaffold, and it has no
canvas id of its own, so it may have no locked design counterpart.

### IF-7 — Evidence gap: STORY-004 shipped with no image evidence — PROCESS

`STORY-004_welcome_design_fidelity/visual-fidelity/` contains only
`visual-fidelity-report.md`; there is no `implemented-*.png` or
`design-reference-*.png` in it. This is why IF-1 was not caught at the story
gate. Relevant to the requirement integration review's evidence assessment.

### IF-8 — Stale claim in STORY-030 report — PROCESS

`STORY-030_privacy_my_data_design_fidelity/visual-fidelity/visual-fidelity-report.md`
states that `data/devops/system/design-fidelity-config.json` "does not exist
anywhere in this repository". The file is present at integration HEAD with
`design_source.locked: true`. Documentation-only correction.

## Status Of The 7 Deltas STORY-033 Routed To This Review

`STORY-033_app_shell_design_system_deltas/visual-fidelity/visual-fidelity-report.md`
(section "Out-of-scope deltas observed") routed seven items here. Re-checked
against the merged build:

| # | Screen | Delta | Status at integration scope |
|---|---|---|---|
| 1 | notifs, alarm | Flat dark navy backdrop instead of aurora sky wash | RESOLVED — both now render the ambient purple/magenta wash |
| 2 | notifs | 3-tab bar (Trang chủ / Trò chuyện / Thư viện ảnh), no active pill; design has 5 (Nhà / Trò chuyện / Pet / Ví chung / Tôi) with an active pill | STILL OPEN — `core/navigation/app_shell.dart` ships 3 destinations; no REQ-002 story owns the tab bar |
| 3 | notifs | Pink circular FAB absent from the design canvas | STILL OPEN — real, at `app_shell.dart:199-206` (`heroTag: 'account-hub-entry'`) |
| 4 | notifs | Banner copy truncated to "Tối đa 15 thông báo/ngày."; design also carries the Do Not Disturb sentence | STILL OPEN — confirmed in the capture |
| 5 | alarm | Weekday chips stack vertically instead of one horizontal row | RESOLVED — T2..CN now render in a single row |
| 6 | alarm | Hero card shows bright `gradientDream` in a backend-error state | RESOLVED — dark translucent hero card with real 06:30 content |
| 7 | welcome | Composition differs broadly | PARTIALLY RESOLVED — composition now matches; colour/contrast remains as IF-1 |

Deltas 2 and 3 are shared app-shell scope with no owning story inside REQ-002.
They need an explicit Scrum Master decision: accept as intended divergence, or
open a follow-up app-shell/navigation story. Delta 4 is content/localisation.

## Blockers

None. The provided runtime was reachable and all 31 target screens were
captured.

MOBILE_VISUAL_AUDIT_COMPLETE: YES
