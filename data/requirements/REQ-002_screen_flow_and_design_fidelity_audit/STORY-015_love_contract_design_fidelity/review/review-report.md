# Review Report: STORY-015 Design Fidelity — Love Contract

Reviewer: Iris-QC (compact story review)
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-015_love_contract_design_fidelity
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-015`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Implementation commit: `76980ca6ae76f73f41c037b0517d2e109c00e51a`
Diff: 4 files, +796 / -172

## Outcome: DEFERRED_ONLY

The 13 in-scope fixes are real, correct, and land in the rendered app rather
than in a document. Verification was reproduced independently and passes. The
residual gaps are either outside the implementer's declared `WriteScope` or are
design-system token-vs-source decisions that cannot be resolved inside one
screen file. No defect requires a patch before merge.

## Files Reviewed

- `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`
- `mobile/test/features/love_contracts/presentation/screens/love_contract_screen_fidelity_test.dart`
- `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-015_love_contract_design_fidelity/visual-fidelity/visual-fidelity-report.md`
- `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-015_love_contract_design_fidelity/story_master.md`

Design source verified against: `cupid-app-design-system/project/Cupid Screens.dc.html`
lines 121-166 (`isContract` block) and the CSS variable blocks at lines 23-27.

## Independent Verification

Re-run by the reviewer in the story worktree, not taken on report:

- `flutter analyze lib/features/love_contracts test/features/love_contracts`
  -> `No issues found!` (Flutter 3.44.1, Dart 3.12.1)
- `flutter test test/features/love_contracts` -> `All tests passed!`, 76/76,
  including the 7 new fidelity cases, the 12 pre-existing screen cases, and the
  `hold_to_sign_button_test.dart` signing integration case. No regression from
  the card restructure.
- `flutter gen-l10n` required once in the worktree (generated tree is
  gitignored). Matches the implementer's note.
- Worktree is clean (`git status --porcelain` empty); the committed tree is
  what was reviewed.

## Claims Checked Against Code, Not Accepted On Report

Each of D-1 through D-13 was traced to the actual source. All are present and
correctly implemented. Spot-verified anchors:

- D-1/D-2/D-3 unified card, dashed rules, header wash —
  `love_contract_screen.dart:258-314`, `_DashedRule` at `:480-520`.
- D-4 sequence label `fontSize: 10`, `letterSpacing: 1.8`, `.toUpperCase()`,
  `colorAccentPink` — `:288-295`. Matches design line 125 (10px, `.18em` of
  10px = 1.8, uppercase).
- D-7 duplicated plus — confirmed real. The `vi` string is
  `+ Thêm điều khoản riêng` (it already carries the leading plus), so the prior
  `TextButton.icon` rendered two plus marks. The icon is gone and the existing
  20-clause cap test still passes with the same widget key.
- D-8 clause-list padding `fromLTRB(8, 8, 8, 4)` — `:315-321`. Exact match to
  design line 129 `padding:8px 8px 4px`.
- D-9 caption hoisted out of the state branch — `:417-426`. Correct: design
  line 145 places the caption above the `mySigned`/`myUnsigned` `sc-if` pair,
  so it must render in the signed states too.
- D-10 signed card — `:574-615`. Alpha 0.12 fill, 0.4 hairline, `radiusCard`,
  `minHeight: 64`, centred column, 2px gap, `w700` green heading. `minHeight`
  instead of a fixed `height: 64px` is the right call: a fixed height would
  clip long partner display names.
- D-13 error banner re-homed inside the card sign section — `:399-405`.

## Tap Targets (44pt iOS / 48dp Material via `CupidPlatformTokens`)

No finding. All interactive elements on this screen clear the minimum:

- Add-clause `TextButton` (`:369`) and the retry `TextButton`s (`:186`, `:659`):
  `buildCupidTheme` (`cupid_theme.dart:39-51`) sets no
  `materialTapTargetSize` override, so `ThemeData` keeps the
  `MaterialTapTargetSize.padded` default and the hit box expands to 48x48.
- `ClauseToggleRow` (`clause_toggle_row.dart:49-50`):
  `BoxConstraints(minHeight: platformTokens.tapTarget)` = 44/48.
- `HoldToSignButton` (`hold_to_sign_button.dart:125`):
  `tapTarget + CupidSpacing.sm` = 52 (iOS) / 56 (Material).

## Shared Design-System Component Check

`CupidPrimaryButton` is **not** used by `love_contract_screen.dart`. It is
reached only indirectly through `add_clause_sheet.dart:101` (the add-clause
modal), which is outside this story's `WriteScope`. Recording the pointer per
the requirement-wide watch item rather than silently passing it — see DEF-4.
Nothing in this diff changes `CupidPrimaryButton` or its call site.

## Acceptance Criteria Status

- **AC1 (layout/spacing/colour/typography match exactly)** — PARTIALLY MET.
  Met for every structural property inside `love_contract_screen.dart`.
  Not met for the items in DEF-1 through DEF-3 and F-1/F-2 below. The
  implementer's report records AC1 as "MET for the screen file"; that
  qualification is accurate for the file but the rendered screen still carries
  visible deviations, so this gate records AC1 as partially met.
- **AC2 (deviations corrected, not merely documented)** — MET. All 13 fixes are
  in shipped app code and covered by tests.
- **AC3 (per-partner sign states match)** — MET. `unsigned`, `signedByMe`,
  `bothSigned` all verified by assertion, not by inspection. The app-only
  fourth state `partnerAlreadySigned` (REQ-001 ADR-019e) correctly reuses the
  design's `myUnsigned` branch.
- **AC4 (clause ids use the mono treatment)** — MET at the type-treatment level
  (`type.labelMono` + `colorTextMuted`, asserted). Size and position deferred as
  DEF-1.
- **AC5 (no new entry point)** — MET. No navigation code touched; confirmed by
  diff.

## Deferrals (outside implementer `WriteScope` — verified, not taken on trust)

The mobile-dev run state
(`data/runtime/parallel-runs/RUN-REQ-002_screen_flow_and_design_fidelity_audit-STORY-015-mobile-dev.json`)
declares `write_scope` as the screen file, the screens test directory, and the
two story artifacts. `clause_toggle_row.dart` and `hold_to_sign_button.dart` are
genuinely excluded. These deferrals are boundary compliance, not scope evasion.

- **DEF-1 — `clause_toggle_row.dart` does not match design lines 131-139.**
  Highest visual impact of the three. Design: 24x24 rounded checkbox
  (radius 9, `--grad-hot` fill when on, `1.5px solid var(--line)` when off) on
  the **left**, clause text at 15.5px/1.4 in the middle, `§N` mono id on the
  **right** at 9.5px with 4px top padding. Current row
  (`clause_toggle_row.dart:53-81`): `§N` first in a 32px box at the inherited
  mono size, then a circular check/radio glyph, then the text. Order, glyph
  shape, and id size all differ.
- **DEF-2 — `hold_to_sign_button.dart` does not match design line 153.**
  Design: `height:64px`, `border-radius:var(--r-card)`, `box-shadow:var(--glow)`,
  right-to-left dim overlay plus a conic-gradient touch puck. Current widget:
  `tapTarget + sm` height (52/56), `radiusButton` (pill), no glow, left-to-right
  fill plus a trailing `CircularProgressIndicator`.
- **DEF-3 — both-signed CTA absent (design line 162).**
  `Cả hai đã ký → Ghép đôi`, `--green` fill, `#04231E` label, 52px, `--r-btn`,
  navigating to `invite`. Correctly routed to REQ-002 Scope A
  (STORY-001/STORY-002) since it is an inter-screen navigation affordance — but
  it is also a visible element, so its absence keeps AC1 partially open until
  Scope A lands it.
- **DEF-4 — `CupidPrimaryButton` CTA spec divergence** (flagged by sibling
  reviewers on other REQ-002 stories). Not touched here and not on this screen;
  reachable only via `add_clause_sheet.dart:101`. Carrying the pointer so the
  requirement integration review sees it once, centrally.

## Findings (in-scope, non-blocking — recorded, not patched)

- **F-1 — Header wash and signed-card tint use token hues, not the design's
  literal rgba values.**
  The design source deliberately uses literals here, not its own CSS variables:
  header gradient is `rgba(255,75,140,.18) -> rgba(123,47,190,.18)`
  (`#FF4B8C -> #7B2FBE`, line 124) while `--pink`/`--purple` are `#FF7FB6`/`#B78CF5`
  (line 23); the signed card is `rgba(0,201,167,…)` (`#00C9A7`, line 147) while
  `--green` is `#79E2CD` (line 23). The implementation substitutes
  `colorAccentPink`/`colorAccentPurple`/`colorGreen`
  (`cupid_color_tokens.dart:47,49,53`), so alpha and geometry match but the base
  hues do not — the purple end of the wash is the largest gap (light lavender vs
  deep violet). The visual-fidelity report presents D-3 and D-10 as exact
  matches; they match the alpha, not the hue, and its own stated policy says
  no-token structural values are reproduced directly. Not patched here:
  hardcoding raw rgba into a screen would break the token discipline REQ-001
  established, and the correct fix is a design-system-level decision about
  whether these literals need their own tokens. Needs a Scrum Master / Tech Lead
  call, not a screen-local edit.
- **F-2 — Type-size snaps are larger than the design source and undisclosed as
  gaps.** Contract title uses `type.display` = 34px
  (`cupid_typography_tokens.dart:34`) against design 30px (line 126); the
  signed-card heading and the add-clause label use `type.body` = 17px
  (`:44`) against design 15px (lines 148, 142). Same token-vs-source tension as
  F-1. The `height: 1.1` line-height fix (D-5) is correct and does apply.
- **F-3 — Card-internal horizontal padding is 16, design is 20.**
  Header (`:269-274`) and sign section (`:390-395`) use `CupidSpacing.md` = 16
  against design `padding:22px 20px 18px` (line 124) and `16px 20px 22px`
  (line 144). Nearest-token snap, consistent with the report's declared policy,
  but not itemised anywhere in the report — D-12 covers only the outer block.
- **F-4 — No rendered evidence.** The visual-fidelity report is code-level
  reasoning plus widget assertions; the `visual-fidelity/` directory contains
  only the markdown file, no screenshot or emulator capture and no side-by-side
  against the design source. For a story whose AC1 is phrased as a visual
  comparison this is an evidence gap. It is mitigated here more than on a typical
  fidelity story: the 7 new tests assert concrete numeric design values
  (10px, 1.8 tracking, alpha 0.12, alpha 0.4, `radiusCard`, 64px minHeight,
  18px glyph) rather than asserting that widgets merely exist, which is objective
  evidence a screenshot would not add much to. Recording it so the requirement
  integration review can decide whether REQ-002 needs a uniform capture standard.
- **F-5 — Add-clause copy differs from the design source.** App renders
  `+ Thêm điều khoản riêng`; design line 142 reads
  `+ Thêm điều khoản của riêng tụi mình`. Pre-existing REQ-001 copy, not
  introduced here, and copy is not enumerated in AC1's property list. Noted only.

## Residual Risks

- AC1 stays partially open until DEF-1, DEF-2, and DEF-3 are scheduled. DEF-1 is
  the one a user would notice first: the clause checkbox is the dominant repeated
  element on this screen and currently has the wrong glyph shape and the wrong
  column order.
- F-1 and F-2 will recur on every remaining REQ-002 Scope B story, because they
  are properties of the shared token layer rather than of this screen. Deciding
  them once at requirement level is cheaper than re-litigating per story.
- Pre-existing accessibility nuance, **not** introduced by this diff (traced to
  REQ-001 STORY-019, commit `1bd16e4`): `love_contract_screen.dart:347-353`
  wraps each `ClauseToggleRow` in `IgnorePointer` for the read-only partner
  viewer, but `ClauseToggleRow` still exposes `Semantics(button: true, toggled:)`.
  On Flutter 3.44 `IgnorePointer` blocks hit-testing only, so a screen-reader
  user in that state hears every clause announced as an actionable toggle that
  does nothing. Out of scope for this story; worth a bug-queue entry.
- No process blocker, but recording a mismatch: both this handoff and the
  mobile-dev run state name
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-015/scrum-master-checkpoint.md`,
  which does not exist. The real story directory is
  `STORY-015_love_contract_design_fidelity/`. Review proceeded from the handoff
  scope and the story master.

## Merge Judgement

Merge-eligible into `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`.
Scrum Master should schedule DEF-1 and DEF-2 as follow-up scope (either a
widget-level story or an explicit `WriteScope` extension), confirm DEF-3 is
covered by STORY-001/STORY-002, and route F-1/F-2 to a requirement-level token
decision.
