# Story Master: STORY-040 Hardening - Chat & Typing Ghost Visual Fidelity Evidence

Status: DONE
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-018_chat_typing_ghost_design_fidelity
Scope: Retro-hardening (RWB-20260816-007)
Screen: chat (+ Typing Ghost), Epic 2 (Communication), 5-tab chrome (chat
tab active)
Design-Screen: chat
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development)
- [x] Review (Reviewer)

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-007 (source: REQ-002
audit report, `retro-audit/audit-report.md`) found
STORY-018_chat_typing_ghost_design_fidelity's Design Fidelity evidence had
zero rendered evidence either side — same IF-7-class gap already remediated
for `welcome` (STORY-035), `register` (STORY-036), `invite` (STORY-037),
`paired` (STORY-038), and `contract` (STORY-039).

STORY-018's own review (`STORY-018_chat_typing_ghost_design_fidelity/review/review-report.md`,
Outcome: DEFERRED_ONLY) and its own
`visual-fidelity/visual-fidelity-report.md` are both unusually rich for this
hardening item and must be read directly, not re-derived, before this story
is scoped. Key facts Product Owner must weigh in scoping:

1. **Zero rendered evidence (confirms RWB-007):** STORY-018's own
   `visual-fidelity-report.md` "Not verified" section states plainly: "Static
   widget-tree assertions only. No emulator/simulator screenshot diff or
   on-device visual pass was run... argued from token values, not from a
   rendered pixel comparison." This is the exact defect this hardening story
   exists to fix — capture `implemented-chat-<device>.png` with the
   Typing Ghost UI state actively triggered (not the idle/default chat
   state — AC4's scope is specifically the typing-ghost fade), and render
   `design-reference-chat-<platform>.png` via
   `render-design-canvas.js --screen=chat`.
2. **25 deviations (items 1-25 in `visual-fidelity-report.md`):** found and
   fixed directly in `chat_screen.dart`, `message_bubble.dart`,
   `ghost_bubble.dart`, and `chat_composer.dart` (plus a disclosed
   write-scope exception in `chat_strings.dart` for two AC-required copy
   additions), each verified by one of 7 new widget tests in
   `chat_design_fidelity_test.dart` that read rendered values back out of
   the tree. These are code-verified but never visually confirmed against an
   actual render/screenshot — same re-verification posture as STORY-038's
   D1-D15 and STORY-039's D-1..D-13.
3. **AC4 (Typing Ghost `ghostFade`) is the core re-verification target.**
   The widget test asserts `0.95 -> 0.45` opacity over 1300ms with
   `Curves.easeOut`, `TextDecoration.lineThrough`, and
   `decorationColor == colorGhost @ 85%` — matching the design source's
   `@keyframes ghostFade` and `rgba(180,166,206,.85)` by constant/token
   comparison only. This story must confirm the same treatment is visible in
   an actual rendered capture of the typing-ghost state, not merely re-assert
   the widget test.
4. **D1 (deferred, real, unresolved):** No `colorOnAccent` / inverse-text
   design token. The design source sets `color:#fff` on the own-message
   bubble text and send glyph; `message_bubble.dart:99` and
   `chat_composer.dart:310` use `colors.colorText` instead. Confirmed
   reasonable and non-blocking for this story's audited dark theme (`colorText`
   is `#F7EEFB` there — imperceptible against the gradient), but the delta is
   real in light theme (`colorText` is `#3E2645` there), and light theme is
   OQ5 / explicitly out of scope for this story. Adding the token is a
   `design_system/` change, outside a chat-screen story's natural WriteScope.
   Product Owner must give this an explicit disposition: fold in as a
   design-system change here, or split to a new follow-up RWB item (mirror
   the RWB-014/RWB-015 split-out pattern from RWB-20260816-006) — do not
   silently drop it.
5. **D2 (deferred, reviewer-found regression, real, unresolved):** Ghost
   toggle visual clamps to 44pt on the iOS platform axis.
   `chat_composer.dart:349-360` nests a `Container(46 x 46)` inside a
   `SizedBox` sized to `platformTokens.tapTarget`. On `CupidPlatformTokens
   .material()` (`tapTarget = 48`) the 46pt visual fits and this story's
   audited Material axis is correct; on `CupidPlatformTokens.ios()`
   (`tapTarget = 44`) the same `Container` is silently constrained to
   44 x 44 with no overflow error to surface it — a 2pt fidelity delta on an
   axis this story does not audit. Product Owner must give this an explicit
   disposition: fix it here (size the visual `Container` outside the
   tap-target `SizedBox`) if the iOS axis is judged in scope, or explicitly
   defer to whichever future story audits the iOS platform axis.
6. **O1 (dismissed, not actionable):** Story-class metadata disagreement —
   `story_master.md` declares `Complexity: trivial` / `Story-Class: trivial`
   while run-state files and the review handoff declared `story_class:
   standard`. Established as an expected, by-design two-taxonomy distinction
   (git-boundary `Story-Class` vs. the story's own `Complexity`/`Story-Class`
   field) per STORY-038 precedent, also re-confirmed as STORY-039's V-4
   finding. No reconciliation action needed — carry the note forward only.
7. **Deviations recorded but deliberately not changed (confirmed-correct
   exclusions, not gaps) — re-confirm out of scope only, do not
   re-litigate:** composer placeholder copy (`'Nhắn gì đó…'` vs. mock's
   `'Nhắn cho Bae'`) is Product Owner / UX copy scope, not a visual-fidelity
   fix; no attachment/image affordance (ADR-013a removed it deliberately —
   the mock is stale here); Level-1 lock chip pinned above the scroll area
   rather than nested in the mock's DOM position (deliberate, AC3-driven
   divergence — "visible at all times" overrides mock placement, already
   correctly resolved); `GhostStateRow` (anti-ghosting storm row) is owned by
   `features/anti_ghosting/` (STORY-020), outside this story's write scope,
   untouched.
8. STORY-018's own `story_master.md` `Status: DONE` / all Artifacts checked
   record should be left undisturbed (documented-not-resolved in this
   story's Background only), matching the STORY-015/STORY-039 precedent —
   do not reopen its closed git boundary/branch.

Exact remediation steps: see `rework-backlog.md` RWB-20260816-007 detail
section (already written, do not re-derive).

Disposition decisions (Product Owner):
- **D1 — split out.** Not folded into this story. The gap is real but
  imperceptible in this story's audited dark theme (`colorText` is `#F7EEFB`
  there, effectively invisible against the gradient) and only visible in
  light theme (`colorText` is `#3E2645` there), which is OQ5 and explicitly
  out of scope for this story. Adding an inverse-text token is a
  `design_system/` change, outside a chat-screen story's natural
  `WriteScope` — mirroring the RWB-20260816-014/RWB-20260816-015 split-out
  pattern already used twice in this requirement for findings that fell
  outside a hardening story's natural boundary. Tracked as a new rework-backlog
  item, **RWB-20260816-016** (next unused id; 001-015 are already assigned in
  `data/retro-audit/rework-backlog.md`), for Scrum Master to add to the
  registry and detail section — this story does not edit
  `rework-backlog.md` itself (outside Product Owner's artifact family) and
  does not touch any `design_system/` file.
- **D2 — fix here.** Folded into this story with an explicit acceptance
  criterion. Unlike D1, this is a mechanical sizing fix inside a file this
  story already touches (`chat_composer.dart`), requires no new design token
  and no cross-story policy decision, and is a real reviewer-found
  regression (silent 44pt clamp on the iOS platform axis with no overflow
  signal) — the same profile as STORY-039's DEF-1/DEF-2 (fixed directly,
  in-file, low complexity) rather than STORY-039's F-1/F-2/F-3
  (requirement-level policy question, explicitly deferred). Because this
  story's own rendered evidence pair stays on the Material platform axis
  (per `Design-Screen: chat`, same single-axis precedent as STORY-035-039),
  the fix is verified by a platform-token-parameterized test asserting the
  46x46 visual is unchanged across both `CupidPlatformTokens.material()`
  and `CupidPlatformTokens.ios()`, not by a dedicated iOS rendered capture.
- **O1 — no action.** Re-confirmed as the expected, by-design two-taxonomy
  distinction per STORY-038/STORY-039 precedent; carried forward as a note
  only, no reconciliation performed.

## Depends On
- NONE. Independent of every other REQ-002 hardening item; must not reopen
  STORY-001's, STORY-002's, STORY-004's, STORY-006's, STORY-011's,
  STORY-014's, STORY-015's, STORY-018's, STORY-019's, STORY-034's,
  STORY-035's, STORY-036's, STORY-037's, STORY-038's, or STORY-039's closed
  git boundary/branch.

## User Story
As a Product Owner verifying REQ-002's design fidelity claims, I want the
chat screen's Typing Ghost fidelity evidence to be a real rendered-to-rendered
comparison (an implemented app screenshot with the typing-ghost UI state
actively triggered vs. a rendered design canvas) that re-confirms all 25 of
STORY-018's originally-fixed deviations — especially AC4's `ghostFade`
treatment — and fixes the ghost-toggle's silent 44pt clamp on the iOS
platform axis, so that the screen's claimed fix is backed by proof instead of
a token/constant-only reading.

## In Scope
1. Capture `implemented-chat-<device>.png` with the Typing Ghost UI state
   actively triggered (not the idle/default chat state), in dark theme +
   `vi` locale (STORY-018's own configuration), and render
   `design-reference-chat-<platform>.png` via `render-design-canvas.js
   --screen=chat` (confirm the exact screen id via `--list-screens` if
   `chat` does not resolve).
2. Re-compare the two rendered images against STORY-018's existing claimed
   scope: layout, spacing, color/token usage, typography, and each of the 25
   deviations (per `visual-fidelity/visual-fidelity-report.md` and the 7
   widget tests in `chat_design_fidelity_test.dart`), with particular
   attention to AC4's `ghostFade` opacity/curve/strikethrough/decorationColor
   treatment as actually rendered, not merely re-asserted by the existing
   widget test.
3. Fix D2 in `mobile/lib/features/chat/presentation/widgets/chat_composer.dart`
   (lines ~349-360): the ghost-toggle's 46x46 visual `Container` is nested
   inside a `SizedBox` sized to `platformTokens.tapTarget`, which silently
   clamps the visual to 44x44 on the iOS platform axis
   (`CupidPlatformTokens.ios()`, `tapTarget = 44`) with no overflow signal to
   surface it. Correct it by sizing the visual `Container` independently of
   the tap-target `SizedBox`, so the 46x46 visual renders at its full size on
   both `CupidPlatformTokens.material()` (`tapTarget = 48`) and
   `CupidPlatformTokens.ios()` (`tapTarget = 44`), while the `SizedBox`
   continues to provide the platform-correct tap target.
4. If the rendered-to-rendered comparison finds any of the 25 deviations not
   actually matching the design source, or surfaces any new deviation not
   caught by STORY-018's original audit or review, correct it directly in
   the app code — this is a fix, not merely a re-documentation exercise.
5. Place the matched, same-screen evidence pair
   (`implemented-chat-<device>.png` and
   `design-reference-chat-<platform>.png`) in this story's own
   `visual-fidelity/` directory, with a `visual-fidelity-report.md` that
   records `VISUAL_FIDELITY: PASS` once both images match.

## Out of Scope
- D1 (missing `colorOnAccent` / inverse-text design token): **not** folded
  into this story. Split to a new rework-backlog item, RWB-20260816-016 (see
  `## Background` disposition decision above) — re-confirmed only here, no
  `design_system/` file touched by this story.
- O1 (story-class metadata two-taxonomy distinction): re-confirmed as
  expected/by-design per STORY-038/STORY-039 precedent, no reconciliation
  action needed, carried forward as a note only.
- Composer placeholder copy diff (`'Nhắn gì đó…'` vs. mock's
  `'Nhắn cho Bae'`), the missing attachment/image affordance (ADR-013a
  removed it deliberately), the Level-1 lock chip's pinned-above-scroll
  position (deliberate AC3-driven divergence, already correctly resolved),
  and `GhostStateRow` (owned by `features/anti_ghosting/`, STORY-020): all
  confirmed-correct exclusions, re-confirmed out of scope only, no
  re-investigation performed, no files outside this story's `WriteScope`
  touched.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet). Confirmed still unresolved-but-non-blocking in
  `conflicts_open_questions.md`; consistent with STORY-018's, STORY-035's,
  STORY-036's, STORY-037's, STORY-038's, and STORY-039's own precedent, no
  dedicated light/`en` rendered pass is required for this hardening story.
  This is also the reason D1 is deferred rather than fixed here.
- Re-litigating STORY-018's original scope framing beyond what is already
  carried in `## Background` above — this story only adds the missing
  rendered evidence, fixes D2, tracks D1 as a follow-up item, and fixes
  anything the rendered comparison confirms or newly surfaces.
- STORY-018's own `story_master.md` `Status: DONE` / all-Artifacts-checked
  record: left undisturbed, documented-not-resolved only in this story's
  `## Background`, no reopening of its closed git boundary/branch.
- Chat business logic (messaging cubit, repository, anti-ghosting timer
  state): untouched, per STORY-018's own out-of-scope boundary.

## Acceptance Criteria
1. Given the chat screen rendered in dark theme + `vi` locale with the
   Typing Ghost UI state actively triggered, when
   `implemented-chat-<device>.png` is compared against
   `design-reference-chat-<platform>.png` (rendered via
   `render-design-canvas.js --screen=chat`), then layout, spacing,
   color/token usage, and typography match exactly with no visible
   deviation.
2. Given each of STORY-018's 25 originally-fixed deviations (per its own
   `visual-fidelity/visual-fidelity-report.md` and the 7 widget tests in
   `chat_design_fidelity_test.dart`), when this story's rendered comparison
   is complete, then each is re-confirmed as matching the design source in
   the actual rendered app, not merely re-read as code or widget-test
   assertion.
3. Given AC4's `ghostFade` treatment specifically (`0.95 -> 0.45` opacity
   over 1300ms with `Curves.easeOut`, `TextDecoration.lineThrough`, and
   `decorationColor == colorGhost @ 85%`), when the typing-ghost state is
   actively rendered, then the same treatment is visibly confirmed in the
   actual capture, not merely re-asserted by the existing widget test.
4. Given D2 (ghost-toggle visual silently clamping to 44pt on the iOS
   platform axis), when this story is delivered, then
   `chat_composer.dart` is corrected so the 46x46 visual `Container` renders
   at its full size independent of `platformTokens.tapTarget`, verified by a
   test asserting the visual's dimensions are unchanged across both
   `CupidPlatformTokens.material()` (`tapTarget = 48`) and
   `CupidPlatformTokens.ios()` (`tapTarget = 44`).
5. Given D1 (missing `colorOnAccent` / inverse-text design token), when this
   story is delivered, then no `design_system/` token file is modified by
   this story and the gap is tracked instead in `rework-backlog.md` item
   RWB-20260816-016 for a future light-theme-scoped story.
6. Given any deviation is found by the rendered-to-rendered comparison beyond
   the 25 original deviations or D2 — whether a previously-claimed fix that
   does not actually match or a newly-surfaced deviation — when the story is
   delivered, then it is corrected in the app code (not merely documented)
   and re-verified with a fresh render pair.
7. Given the comparison is complete and passing, when the story is
   delivered, then this story's own `visual-fidelity/` directory contains
   the matched `implemented-chat-<device>.png` and
   `design-reference-chat-<platform>.png` image pair plus a
   `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS` and the
   25-deviations plus D2 re-verification disposition.
8. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current chat screen (+ Typing Ghost
  indicator), already reachable in the shipped app via its existing
  navigation path — unchanged by this story.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE (confirms `## Depends On` above).
- Must not require any future story: confirmed. D1's `design_system/` token
  gap is tracked as RWB-20260816-016, a follow-up recommendation for a
  future light-theme-scoped story, not a dependency of this story's own
  delivery.
- Must not reopen STORY-001's, STORY-002's, STORY-004's, STORY-006's,
  STORY-011's, STORY-014's, STORY-015's, STORY-018's, STORY-019's,
  STORY-034's, STORY-035's, STORY-036's, STORY-037's, STORY-038's, or
  STORY-039's closed git boundary/branch: confirmed.

## Open Question Impact
Re-checked against `data/intake/bootstrap/conflicts_open_questions.md`: OQ5
(light theme / `en` locale) is the only open question touching this screen's
scope, and it is also the reason D1 stays out of scope (D1's visible defect
only exists in light theme). It remains unresolved-but-non-blocking there,
deferred to Product Owner story breakdown per its own working assumption, and
is already excluded from this story's scope for the same reason STORY-018,
STORY-035, STORY-036, STORY-037, STORY-038, and STORY-039 excluded it — dark
+ `vi` is the only enabled user-facing configuration in v1. No other open
item in the registry touches the chat screen or this story's evidence-pairing
scope.

### Scope Items BLOCKED in this story
- None. No open question blocks any in-scope acceptance criterion.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-8) are unblocked.
