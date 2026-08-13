# Review Report — STORY-012 Join / Enter Pairing Code Design Fidelity (Round 2)

Reviewer: Iris-QC
Mode: compact-story-review
Round: 2 (round 1 outcome was PATCH_REQUIRED, findings F1-F4)
Scope: REQ-002 / STORY-012_join_code_design_fidelity
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-012`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Commits reviewed: `f284985` (round-1 implementation), `5038304` (round-2 fix),
`de80b35` (boundary seal)
Design source (locked): `cupid-app-design-system`, `Cupid Screens.dc.html`,
`<sc-if value="{{ isJoinCode }}">`, lines 1550-1570

Scope gate: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-012_join_code_design_fidelity/review/scope-gate.md`
(Phase 1 completed before Phase 2 focused verification; `Phase: SCOPE_GATE`,
`SCOPE_GATE_COMPLETE: YES`)

Outcome: PATCH_REQUIRED

## Scope Gate

- Review type: `compact-story-review`, round-2 re-review of a `PATCH_REQUIRED`
  story. Mobile lane, trivial, single-lane — rule 15 satisfied.
- Report path: this file.
- Source/test files in scope (2):
  `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart`
  (unchanged in round 2),
  `mobile/test/features/pairing/presentation/screens/joincode_screen_design_test.dart`.
- Evidence files in scope (4): `visual-fidelity/visual-fidelity-report.md`,
  `visual-fidelity/design-reference-joincode-android.png`,
  `visual-fidelity/implemented-joincode-emulator-5554.png`,
  round-1 `review/review-report.md`.
- Governing artifact: `story_master.md` (AC1-AC4).
- Query keys: F1, F2, F3, F4, AC1-AC4, `VISUAL_FIDELITY`, `_harness`, `Locale('vi')`,
  "Deviations NOT fixed", N1/N2/N3.
- Touched risk surfaces: mobile interaction, mobile design-system token usage,
  mobile navigation/discoverability (AC4 only). Critical gates: rendered
  design-fidelity comparison (12e2/12e3), targeted widget tests, static analysis.
- Runtime startup smoke: not required — story is `trivial` (rule 12g applies to
  non-trivial stories).

## Round-1 findings: all four are closed

| Finding | Status | Verification |
| --- | --- | --- |
| F1 — no rendered evidence | CLOSED | Both PNGs exist, open as real images, and depict this story's screen. Design reference is the Pixel 6 `md` frame of the locked canvas, dark + `vi`, showing the `joincode` screen — correct screen, not a placeholder or sibling. Implemented capture is `emulator-5554`, 1080x2400, dark + `vi`, real app, no error/loading frame. A per-element side-by-side verdict table now exists at report lines 46-57. |
| F2 — test harness resolved to `en` | CLOSED | `_harness()` now sets `locale: Locale('vi')`, `supportedLocales: [vi, en]` and `GlobalMaterialLocalizations.delegates`; all copy assertions flipped to the Vietnamese strings. The `supportedLocales` detail matters and was handled correctly — `locale` alone would still have fallen back. Re-ran the suite myself: **+107 all passed**. |
| F3 — six-slot row missing from "not fixed" | CLOSED | Now item 6 of "Deviations NOT fixed", with the §9 rationale, the explicit statement that §9 constrains semantics rather than painting, and the two previously unlisted token details (active-slot `--glow`, caret slot w400). |
| F4 — deferrals 3/4 misread Out of Scope | CLOSED | Both restated as escalation asks with the round-1 framing explicitly withdrawn. |

The round-2 patch set was delivered accurately and the reporting is now honest.
This review does not reopen any of F1-F4.

## Why the story still cannot close

F1 asked for the render. The render arrived, and it settles AC1 against the
story. I looked at both images; they do not read as the same screen.

| Design block | Delivered | |
| --- | --- | --- |
| Page background: purple->black vertical gradient + particles | flat `--bg` | absent |
| App bar blended into page, pink chevron | opaque surface bar, hard seam, white chevron | deviation |
| Hero badge 78x78 r28, `link` glyph in `--purple` | nothing | absent |
| Heading, Nunito 900/25/1.25 | present, visually identical | match |
| Sub-copy 13/1.6 `--tx2`, one line | present, one line, `6` not `8` | match except count |
| Code entry: 5 slots 46x56 r16, `–` separator, pink active slot + glow | one full-width field with a letter-spaced hint | substituted |
| `Dán` / `Quét QR` outline pills | nothing | absent |
| Primary CTA: 54px, `--grad-hot`, glow, 16.5/w800 | flat `--pink`, no gradient, no glow | deviation |
| `Tôi mới là người tạo mã →` cross-link | nothing | absent |
| Vertical composition: flows from top | vertically centred, ~27% of the viewport empty above the heading | deviation |

Three of the design's five content blocks are absent, the fourth is
substituted, and the column is centred. `visual-fidelity-report.md` says this
itself, in its own words: *"The screen does not yet match the design source …
Under AC1 this screen is NOT MET at requirement level."*

AC1 is "match exactly with no visible deviation" and AC2 is "the deviation is
corrected in the rendered app (not merely documented)". Rule 14 makes the exact
AC text controlling, and rule 12e2 makes a build that visibly contradicts the
design reference `PATCH_REQUIRED`. A passing verdict here would certify a match
that this story's own screenshots refute — which is precisely the failure mode
the per-story render gate was added to catch.

Scrum Master's handoff directed me not to block solely on N2 (background), N3
(app bar) or the `CupidPrimaryButton` gradient, and not to treat N1 as a
fabricated excuse. Accepted on all three counts, and none of them is the basis
for this outcome. Setting all four aside entirely, the screen is still missing
the hero badge, the segmented code row, the secondary-action row and the
cross-link.

### Gate defect: no machine-readable verdict token

`visual-fidelity-report.md` carries a prose verdict but no literal
`VISUAL_FIDELITY:` line. Rule 12e2 requires a top-level `VISUAL_FIDELITY: PASS`
or `FAIL` token, and both the reviewer stop gate and the DONE gate read that
exact line. As written, the report is unreadable to those gates in either
direction. The correct token for the comparison as captured is
`VISUAL_FIDELITY: FAIL`.

## Findings

### F5 — Rendered comparison fails AC1/AC2 (blocking)

Basis: the two PNGs above plus the report's own verdict table. Not a
re-litigation of a deferral — it is the first time this story has had rendered
evidence, and the evidence is negative.

Owner: `mobile-dev`, but the write scope must be widened first — see the patch
set. The single-line round-2 restriction on `joincode_screen.dart` is what
prevented N1 from being fixed, and `cupid_icons.dart` is what prevents the hero
badge.

### F6 — `VISUAL_FIDELITY` verdict token missing (blocking, mechanical)

Owner: `mobile-dev`. Add the literal token near the top of
`visual-fidelity-report.md`.

## Required patch set

Ordered by cost. Items 1-2 are mechanical; 3-4 need Scrum Master to widen the
write scope before mobile-dev can act.

1. Add the literal `VISUAL_FIDELITY: FAIL` token to
   `visual-fidelity-report.md` (F6).
2. **Scrum Master decision required before items 3-4 can proceed.** Either
   widen this story's write scope as below, or amend AC1/AC2 in
   `story_master.md` so the story's stated bar matches what it is actually
   permitted to deliver. Passing AC1 as currently written is not available on
   this evidence.
3. Top-align the content column (N1). One-line change in
   `joincode_screen.dart`; needs only the round-2 no-touch restriction lifted.
   Highest visible-impact-per-effort item on the screen.
4. Hero icon badge: add a cmap-verified `link` constant to
   `mobile/lib/design_system/icons/cupid_icons.dart`, then the 78x78 r28 badge.
   Requires design-system write scope. The report's refusal to fork an inline
   `IconData` in feature code is correct and should be preserved.

Optional in the same pass if scope allows: paint the six slot boxes over the
existing single accessible `TextField` (a `Stack` or custom decoration driven by
the controller). The report's own analysis is right that §9 constrains semantics,
not painting, so this is buildable without breaking accessibility — but it is
larger than the rest and reasonable to route separately.

## Deferred — route, do not patch here

Correctly deferred and correctly documented. None of these is mobile-dev's to
fix inside this story.

1. Primary CTA gradient / glow / 54px / w800 — shared `CupidPrimaryButton`,
   affects every screen. Design-system story.
2. Page background gradient + particles (N2) — shared surface, same owner as 1.
3. App bar blend and pink chevron (N3) — shared app-bar theme, same owner as 1.
4. `Dán` / `Quét QR` — clipboard + camera plugins, `pubspec.yaml`, and Android/iOS
   permission manifests. Genuine feature work; needs a Product Owner scope
   decision or a follow-up story before REQ-002 integration review closes.
5. `Tôi mới là người tạo mã →` cross-link — Scrum Master must confirm which
   REQ-002 story owns it and verify it actually lands there. If the Scope A
   navigation stories already passed review without it, it needs its own story.
6. Code length 8 (design) vs 6 (shipped) — Product Owner decision; spans
   `joincode`, `invite` and `waiting`. Transcribing the truthful `6` was the
   right interim call.

Items 1-3 cluster into one design-system story; the report's suggestion to fold
them together is sound.

## Acceptance criteria

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — exact match, dark + `vi` | FAIL | F5. Three of five content blocks absent, entry substituted, column centred. |
| AC2 — deviations corrected in the rendered app | FAIL | Seven deviations genuinely fixed in code; the majority of the design's content is still not rendered. |
| AC3 — code-entry states | PASS (for the delivered entry treatment) | Empty / focused / error token treatment is correct and now asserted in `vi`. Scoped to the single-field substitution, so it inherits F5's caveat. |
| AC4 — no navigation change | PASS | Diff touches presentation only; `onPaired` seam and back behaviour unchanged. |

## Critical gates

| Gate | Result |
| --- | --- |
| Rendered design fidelity (12e2/12e3) | **FAIL** — both images real and correct screen, but they visibly contradict each other. Verdict token missing (F6). |
| Targeted widget tests | PASS — re-ran `flutter test test/features/pairing test/design_system`: **+107 all passed**. |
| Static analysis | PASS — re-ran `flutter analyze lib/features/pairing test/features/pairing`: 9 pre-existing `prefer_initializing_formals` info lints, **0 errors, 0 warnings**, unchanged from baseline. |
| Entry point reachability (12e1) | PASS — existing shipped screen, unchanged by this story (AC4). |
| Runtime startup smoke (12g) | Not required — `trivial` story. |
| Configuration guide (12a) | Not required — no setup/configuration surface touched. |
| Shared-widget regression (12d) | PASS — diff touches no `design_system/` file; `no_fork_guard_test.dart` green. |

## Recommendation

- Story status: `IN_PROGRESS`.
- Uncheck `Implementation (Development)`; leave `Review (Reviewer)` unchecked.
- Return to `mobile-dev` with F5 and F6, after Scrum Master resolves patch-set
  item 2 (widen write scope, or amend AC1/AC2).
- Route the six deferred items; items 1-3 as a single design-system story,
  items 4-6 to Product Owner.

Round-2 note for the record: mobile-dev's round-2 work was accurate and
self-critical — it produced the evidence that convicts its own story, withdrew
its own round-1 framing, and volunteered three findings nobody asked for. The
`PATCH_REQUIRED` here is about the screen, not about the round-2 pass.
