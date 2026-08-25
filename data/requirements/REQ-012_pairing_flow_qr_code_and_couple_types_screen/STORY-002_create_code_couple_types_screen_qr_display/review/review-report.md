# Review Report — REQ-012 / STORY-002 Create-Code (Couple Types) Screen QR Display

Outcome: PATCH_REQUIRED

Reviewer: Iris-QC (compact-story-review)
Date: 2026-08-26
Branch: `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-002_create_code_couple_types_screen_qr_display`
BaseHead: `d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b`
Implementation commit: `76b25fdaa8aa100e740ca54d4ae419a52b604334` (`89860c9` on top is docs-only)

## Scope Gate

- Review type: `compact-story-review` (no separate `scope-gate.md` per skill rule 5a).
- Report path: `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-002_create_code_couple_types_screen_qr_display/review/review-report.md`
- Source/test files in scope (5 of 8 budget):
  - `mobile/lib/features/pairing/presentation/widgets/invite_qr_frame.dart` (new)
  - `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`
  - `mobile/lib/design_system/tokens/qr_palette.dart` (new), `mobile/lib/design_system/design_system.dart`
  - `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart` (entry-point verification only)
  - test suites: `invite_qr_frame_test.dart`, `invite_screen_test.dart`, `post_code_navigation_guard_test.dart`
- Evidence files in scope: `story_master.md`, `coding-plan/test-results.md`, `data/devops/system/design-fidelity-config.json`, `data/retro-audit/rework-backlog.md` (gate check only).
- Query keys: AC1–AC5, `InviteQrFrame`, `QrErrorCorrectLevel`, `_pushWaiting`, `WaitingScreen`, `VowScreen`, `Entry Point Reachability`, `Story Runtime Startup Smoke`, `VISUAL_FIDELITY`, `Design-Screen`.
- Retro gate (rule 1a): `data/retro-audit/rework-backlog.md` registry table checked — all 29 `RWB-*` rows are `RESOLVED`/`DONE`. No `PENDING`/`IN_PROGRESS` item blocks this handoff.
- Phase 2 proceeded; review completes with `PATCH_REQUIRED` on missing mandatory evidence gates.

## Acceptance Criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — live QR above the text code, design treatment | PASS | `invite_screen.dart` `_InviteCodeCard`: `InviteQrFrame(code: invitation.code)` is the first child of the card `Column`, followed by `SizedBox(height: _qrToCodeGap)` then the label/code. `invite_screen_test.dart` "AC1/AC2: the card carries one QR frame, above the text code…" asserts frame centre above code centre from one mounted tree. |
| AC2 — QR resolves to the same code as the text | PASS | Same `invitation.code` instance feeds both. `invite_qr_frame_test.dart` "AC2: the art encodes the bare code…" rasterizes the mounted `QrPainter` via `toImageData(154)` and byte-compares against reference painters for the bare code, `toUpperCase()`, and a URL-wrapped variant; fixture code is lower-case so an alphanumeric-mode upper-caser cannot pass. `errorCorrectionLevel: QrErrorCorrectLevel.H` asserted on both the widget arg and the resolved painter. |
| AC3 — picker stays after the code/QR block | PASS | `_CoupleTypeRow` position is unchanged by the diff (only a formatter reflow of the `coupleTypes.indexed` loop). `invite_screen_test.dart` "AC1: the picker sits between the code card and the CTA, in catalog order" still passes unmodified. |
| AC4 — Continue lands on Waiting-for-partner, never Fingerprint Vow | PASS | `invite_screen.dart` `_submitCoupleType` → `_pushWaiting(context, invitation)` → `MaterialPageRoute(builder: (_) => WaitingScreen(...))`. `VowScreen` is not referenced on the CTA path. Asserted positively and negatively by "AC4: Continue advances to waiting on a successful save" and by `post_code_navigation_guard_test.dart` "AC1/AC2: the post-code action lands on waiting and no vow surface". REQ-009 locked contract honoured. |
| AC5 — dark theme + `vi` matches `cupid-app-design-system`, including the new QR | **FAIL (unproven)** | No rendered evidence exists. See B1. |

Independent test verification (rule 18, handoff asked to verify not trust): re-ran
`flutter test test/features/pairing/presentation/widgets/invite_qr_frame_test.dart test/features/pairing/presentation/invite_screen_test.dart test/core/navigation/post_code_navigation_guard_test.dart`
in the story worktree → **31/31 `All tests passed!`**, matching the implementer's reported counts.

## Touched Risk Surfaces And Critical Gates

| Surface | Gate | Status |
| --- | --- | --- |
| Mobile interaction (new QR widget, animation clock) | targeted widget tests | PASS (verified above) |
| Mobile navigation / discoverability | entry point exists in code + `## Entry Point Reachability` evidence section | Code PASS, **evidence section MISSING** — B3 |
| Design-system token addition (`qr_palette.dart`) | no-fork-guard / static analysis on story files | PASS (`flutter analyze` on all story files: `No issues found!`; zero no-fork-guard violations in story files) |
| Package dependency (`qr_flutter 4.1.0`, `qr 3.0.2`) | resolution + lockfile | PASS |
| UI-bearing screen (design fidelity, AC5) | rendered `visual-fidelity/` pair + `VISUAL_FIDELITY` verdict | **MISSING** — B1 |
| App lifecycle / runtime | `## Story Runtime Startup Smoke` | **MISSING** — B2 |

Configuration-guide check: not applicable — no env var, external integration, or manual setup step is introduced by this diff.

## Blocking Findings

### B1 — No rendered design-fidelity evidence; AC5 is unverifiable as delivered
Owner: `mobile-dev`

The story directory has **no `visual-fidelity/` directory at all**: no
`implemented-<screen>-<device>.png`, no `design-reference-<screen>-<device>.png`,
no `visual-fidelity-report.md`, and no `VISUAL_FIDELITY:` verdict line anywhere.
`coding-plan/test-results.md` §6 "Visual Inspection" is prose reasoning about
widget order — which is exactly the substitute reviewer rule 12e2 refuses ("with
RENDERED IMAGES, not prose").

This is not waivable here. `data/devops/system/design-fidelity-config.json`
records `ui_surface: true` and a locked `design_source`
(`type: claude-design`, `location: cupid-app-design-system`,
`entry: Cupid App.dc.html`, `id: cupid-app`, `surface: mobile`,
`locked: true`), so neither audited scope-out applies. The immediately prior
requirement's UI stories both carry the evidence pair (for example
`data/requirements/REQ-011_.../STORY-001_zodiac_red_flag_screen/visual-fidelity/`
with `design-reference-zodiac-android.png` + `implemented-zodiac-emulator-5554.png`
+ `VISUAL_FIDELITY: PASS`), which is the established shape to reproduce.

AC5 names layout, spacing, color/token usage and typography **including the new
QR element** — the QR frame transcribes ~12 non-8pt design metrics
(`_frameSize 186`, `_framePadding 16`, `_frameRadius 28`, `_glowSize 290`,
`_badgeSize 40`, `_badgeRingWidth 5`, `_scanBandHeight 26`, …) plus two animation
loops and a new `ClipRRect` on the card. Every one of those is a value only a
render can confirm; none is covered by the widget tests.

Action:
1. Capture per the mobile lane path (`mobile-dev/references/visual-fidelity.md`,
   reviewer rule 12e3/12g2), matching REQ-011's method: preview-harness entry +
   `capture-mobile-screen.sh` at the canvas' own logical width, and
   `render-design-canvas.js --screen=<id>` for the reference.
2. Write `visual-fidelity/visual-fidelity-report.md` with a top-level
   `VISUAL_FIDELITY: PASS|FAIL`, the concrete per-element comparison (name the
   states compared, not a bare token), and the device/theme/locale used
   (dark + `vi`, per AC5).

### B2 — Missing `## Story Runtime Startup Smoke` evidence
Owner: `devops` (or `mobile-dev` if it owns the launch capture)

Reviewer rule 12g makes registry-backed runtime startup smoke a mandatory
story-level gate for a non-trivial story in the `shared`/`mobile` lane, unless
`story_master.md` records `Runtime-Smoke: WAIVED — <reason>`. `story_master.md`
carries no such line, and `coding-plan/test-results.md` has sections 1–6 with no
`## Story Runtime Startup Smoke` heading. For this lane the smoke is that the app
LAUNCHES on the provided device/emulator and reaches its first screen without a
crash or error screen. The DONE gate enforces this independently, so the story
cannot close without it.

Note this story adds a first-party runtime dependency (`qr_flutter`) and a new
`AnimationController` that repeats indefinitely on a hot path — a launch smoke is
the proportionate proof, not a formality.

### B3 — Missing `## Entry Point Reachability` evidence section
Owner: `mobile-dev`

`story_master.md` declares "UI-facing story: YES" and "Direct URL only
acceptable: NO", so rule 12e1 requires `coding-plan/test-results.md` to record a
`## Entry Point Reachability` section with `Reachable: YES` and the concrete
path. That section does not exist.

The **implementation** side is fine — I verified the path independently rather
than on trust: `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart:39`
pushes `InviteScreen(router: router, createInviteCubit: _createInviteCubit)`, and
`pairing_choice_screen_test.dart` "the primary action opens invite" exercises it.
This is a documentation gap only; record the section naming that file:line and
the CTA, then it closes.

### B4 — `Design-Screen: TBD` was never resolved
Owner: `mobile-dev`

`story_master.md:16-17` reads `Design-Screen: TBD (implementer resolves and
records after rendering candidates)` and is still `TBD` after implementation.
Rule 12e2 treats an unrecorded screen id as a finding in its own right: without
it nobody can re-check which canvas screen the reference depicts, and a story
compared against the wrong screen is indistinguishable from a correct one in the
file listing. Resolve and record the id (`Design-Surface: cupid-app` is already
set) as part of B1's capture.

## Deferred Findings

| Id | Finding | Disposition |
| --- | --- | --- |
| D1 | `no_fork_guard_test.dart` RED on `pet_preview_card.dart:229-230` (`Colors.` literals) | DEFERRED — confirmed pre-existing and byte-identical at BaseHead; tracked as `BUG-20260825-002`; `lib/features/pet/**` is outside this story's write scope. Not a STORY-002 regression and does not contribute to this outcome. |
| D2 | `gallery_cubit_test.dart:276` off-screen AppShell nav destination on the 800x600 test surface | DEFERRED — pre-existing at BaseHead, unrelated to pairing/QR/design-system. Not tracked as a bug yet; worth filing. |
| D3 | `Implementation Lane: shared` mislabels a diff that is entirely under `mobile/` | DEFERRED (doc) — the label is what makes the fidelity-capture owner ambiguous between the browser-render path and the mobile-capture path. `design_source.surface: mobile` and `Design-Surface: cupid-app` settle it in favour of the mobile path; correcting the lane to `mobile` would remove the ambiguity for the next reader. Scrum Master owns `story_master.md`. |
| D4 | Two documented deviations from phase P1 §6 "must still pass unmodified" (navigation assertion relocated; `pumpAndSettle` → bounded pumps in 3 sibling suites) | DEFERRED — both are correct and well-justified: the old assertion encoded "this phase must not navigate", which is precisely what AC4 replaces, and the UX spec's two infinite loops make `pumpAndSettle` time out by construction. Same pattern the repo already uses for `PairedScreen`. No production code outside write scope was touched. Accepted as recorded. |

## Traceability

- Requirements: `story_master.md` AC1–AC5, In Scope 1–5, `Open Question Impact` (OQ2 RESOLVED — CTA destination unchanged from REQ-009, carried into AC4 and honoured by `_pushWaiting`). No unresolved OQ affects this story.
- UX: `ux/ux-spec.md` "Screen Structure" order (QR → label → code → caption → expiry → Share/Copy) matches the delivered `_InviteCodeCard` column; the two mandated loops (`breathe 4.5s`, `qrScan 3.4s`) are implemented on one 153s least-common-period clock (34 and 45 exact cycles, so the loops cannot drift).
- Architecture: `architecture/contract-summary.md` §3 payload contract (bare string, never URL/prefix/case transform) is enforced by the rasterized byte-comparison test; the center-badge occlusion is compensated with `QrErrorCorrectLevel.H` as specified.
- Design source: `cupid-app-design-system/Cupid Screens.dc.html` lines 170-224 (`isInvite`) — transcribed in code comments but **not verified by render** (B1).
- Testing: `coding-plan/test-results.md` §2–§4, independently re-run (31/31 PASS).

## State Recommendation

- Uncheck `Implementation (Development)`; leave `Review (Reviewer)` unchecked.
- Story status: `IN_PROGRESS`.
- Route back to `mobile-dev` for B1, B3, B4 (and B2 if it owns the launch capture; otherwise `devops` for B2).
- Blocking findings: 4. Deferred findings: 4.

The code itself is in good shape — AC1–AC4 are correct, well-tested and
well-documented, and the QR widget is careful work (payload identity proven by
rasterization rather than asserted, animation clock disposed with the widget,
zero raw color literals). What is missing is the evidence that this story renders
like the design and that the app still boots; both are mandatory gates the DONE
gate enforces independently, so they cannot be carried as deferred notes.
