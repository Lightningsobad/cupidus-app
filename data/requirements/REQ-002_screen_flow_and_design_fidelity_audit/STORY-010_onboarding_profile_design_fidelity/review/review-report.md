# Review Report: STORY-010 — Design Fidelity, Onboarding Profile Setup

Outcome: PATCH_REQUIRED

Review type: compact-story-review — **round 2** (supersedes the round-1 report)
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-010 | Lane: mobile (single lane)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-010`
BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd` | Reviewed HEAD: `49c7eab`
Recommended story status: IN_PROGRESS — but the owner is `product-owner`, **not**
`mobile-dev`. No further mobile fidelity work is required unless the scope
decision below resolves toward canvas-`profile` copy.

## Round-1 Finding Closure

**F1 (no rendered evidence) — CLOSED, independently verified.** Both frames now
exist and were opened and read during this review, not taken on the report's word:

- `visual-fidelity/implemented-profile-emulator-5554.png` — a genuine device
  render (Android status bar at 5:04, signal/battery glyphs, gesture pill), not a
  widget-test snapshot or a mock-up.
- `visual-fidelity/design-reference-profile-android.png` — the canvas `profile`
  reference frame.

The report now carries `VISUAL_FIDELITY: FAIL` and `Design-Screen: profile` as
literal top-level lines. The render also earns its keep: it exposed R3, R6, R7 and
R8, four deltas the round-1 static audit structurally could not have found (R8 is a
*wrap* delta that only exists once text is laid out). The capture route is honest —
`--dart-define=PREVIEW_PROFILE=fixture` swaps `AccountRepository.fetchProfile()`
for authored data and is inert without the define, so no other story's capture of
this canvas changes.

**F2 (missing "Ngôn ngữ" field card) — CLOSED, verified in code, test and render.**
`profile_edit_screen.dart` renders it through `_FieldCard` with a new optional
`trailing` slot (label/value stack `Expanded`, chevron right, matching the design's
`justify-content:space-between` at `Cupid Screens.dc.html:112-115`), and it is
visible in the render as "NGÔN NGỮ / Tiếng Việt ›". It is inert (no `onTap`) but
deliberately *not* `ExcludeSemantics`-wrapped — the right call, and the report
explains why: the card carries real content a screen reader should read, unlike the
camera badge which is a pure affordance. A passing widget test asserts both the
content in each locale and the absence of a tap target.

Round-1 D-1 (the imprecise `#fff` exactness claim) is also corrected — the D3 row
now discloses that the glyph is `colors.colorText` (`#F7EEFB`).

## Scope Gate

Recorded in full at `review/scope-gate.md` (`SCOPE_GATE_COMPLETE: YES`), summarized here.

Source/test files in scope (3 changed — comfortably inside the compact budget;
Tier 1 rendered evidence applies at 8 touched files including artifacts):

- `mobile/lib/features/account/presentation/screens/profile_edit_screen.dart` (+217/-62)
- `mobile/lib/main_preview.dart` (+35/-2) — preview-only capture fixture
- `mobile/test/features/account/presentation/screens/profile_edit_screen_test.dart` (+165/-3)

Artifacts in scope: `story_master.md` (one line: Implementation checkbox — correct
implementer bookkeeping; the Review checkbox is untouched),
`visual-fidelity/visual-fidelity-report.md`, and the two PNGs.

Evidence consulted: `Cupid Screens.dc.html:93-119` (the `isProfile` block),
`image-slot.js:1-30`, `features/account/domain/zodiac.dart:15-26`,
`features/account/presentation/profile_edit_cubit.dart:112-139`, and
`data/runtime/parallel-runs/RUN-...-STORY-010-mobile-dev.json`.

Write scope: clean. `main_preview.dart` sits inside the mobile-dev run's declared
`mobile/lib` write scope. Worktree clean, no `Package.resolved` drift, no
navigation code touched, `me_screen.dart` untouched (disjoint from STORY-029).

Critical gates: rendered design-fidelity comparison (12e2/12e3) — **PASS, evidence
now present**; entry-point reachability (12e1) — PASS; mobile static analysis and
widget tests (12e0) — PASS, independently rerun. Runtime startup smoke (12g) not
required.

## Blocking Finding

### F3 — The story was delivered against a different screen than it describes, and that substitution is still unratified (BLOCKING)

This is a scope-record defect, not an implementation defect, and it is the same
rule that produced round-1 F2 — applied consistently.

`story_master.md` scopes this story to "the onboarding profile-setup screen"
(`Screen: profile (onboarding setup step)`, In Scope §1), and In Scope §3
distinguishes it from the Me/Profile screen. The app has no such screen: the
onboarding chain runs `register -> HomeScreen` with no profile step, and
`ProfileEditScreen` is reachable only from the Me hub (`me_screen.dart:59`). The
implementer retargeted the story onto `ProfileEditScreen` via the canvas registry in
`main_preview.dart:185-188`. That retarget is defensible and probably correct — it is
the repository's only implementation of canvas `profile` — but **no governing
artifact records it.** Round 1 raised this as D-2 and assigned ratification to Scrum
Master; `story_master.md` has not changed since, so the story would close on a
premise its own text contradicts.

This now has concrete AC1 consequences rather than being purely a paperwork concern.
Three of the render's remaining deltas sit **inside** this story's write scope and
were left unfixed solely because a review note deferred D-2:

- R7 — name card label "TÊN HIỂN THỊ" vs the canvas's "TÊN GỌI" (`:104`)
- R8 — zodiac helper copy longer than the design's, wrapping to two lines where the
  design fits one (a real *layout* delta, not just copy)
- R3 — header trailing "Lưu" action that the canvas does not have

The implementer's reasoning for not guessing is sound and I want it on the record:
each of these is only correct in one direction, and the direction depends on how the
screen's identity resolves. Editing shared `l10n/` copy on a coin flip would be worse
than a recorded delta. But `story_master.md`'s own OQ triage states "All acceptance
criteria (1-4) are unblocked", and the reviewer rule is explicit that scope deferred
without OQ triage or an approved scope change is `PATCH_REQUIRED`, and that a review
note may not serve as approval to move an acceptance criterion. Round 1 rejected an
OQ-based deferral of an AC1 element on exactly these grounds; a review-note-based
deferral of three more AC1 elements cannot be treated more leniently.

Note that the design source's own English label at `:104` is "Display name", which
agrees with the app's current "TÊN HIỂN THỊ" semantics — so ratifying the Me→Edit
reading may well make R7 a non-delta rather than a fix.

**To clear F3** (`product-owner`, routed by `scrum-master`): amend `story_master.md`
to state which surface this story owns and whether canvas `profile`'s copy governs
it. Then either (a) the Me→Edit reading is ratified — R3/R7/R8 are recorded as
non-deltas and this story needs no code change, or (b) the canvas-`profile` reading
is ratified — `mobile-dev` applies the two `app_vi.arb` strings and decides the save
button, a small follow-up. Re-review is a quick delta check either way.

## Deferred Findings

| # | Finding | Disposition |
|---|---|---|
| D-1 | R1 — app-shell `--sky` gradient absent; `skyGradient` exists in `cupid_color_tokens.dart:209` only as a raw CSS `String` with no Flutter `Gradient` built from it. Genuinely a `design_system/` change, outside a single-screen story. **But its named owner STORY-032 does not exist** — I checked this branch and the integration branch; REQ-002 stories end at STORY-031. The deferral currently points at nothing. | DEFERRED — `scrum-master` must create STORY-032 or reassign before requirement integration review |
| D-2 | R6 — chip shows "Pisces", design shows "Song Ngư". Claim verified, not accepted on assertion: `zodiacSignFor()` returns English (`zodiac.dart:15-25`) and `ProfileEditCubit.submit()` PATCHes that exact string as `zodiacSign` (`profile_edit_cubit.dart:128`). Localizing the display needs a presentation-layer mapping for twelve signs plus a decision on what Zodiac Red Flag reads. Genuinely beyond a fidelity story. | DEFERRED — needs an owner; pairs with D-3 (same chip) and STORY-023 |
| D-3 | R5 — 26px zodiac artwork (`:109` `<dc-import name="Zodiac Icon">`) omitted; no asset exists, `design_system/` outside write scope. Also leaves the chip's asymmetric `5px 12px 5px 5px` padding unmatched, since that padding hugs the icon. | DEFERRED — needs an asset follow-up |
| D-4 | R4 — bottom CTA "Tiếp tục → Love Contract" (`:117`) omitted. Explicitly Scope A navigation per Out of Scope, and would be actively wrong on a Me→Edit screen. | DEFERRED — legitimate, STORY-001/002 |
| D-5 | R2 — header title "Hồ sơ của bạn" (`:1764`) vs "Chỉnh sửa hồ sơ". Coupled to F3. | DEFERRED — resolves with F3 |
| D-6 | Missing onboarding entry point (`permissions -> profile -> invite`, `:1853`). Navigation graph, Scope A. | DEFERRED — route to STORY-001/002 |
| D-7 | R9 — avatar empty state renders a filled circle + person glyph vs the design's dashed ring + "Ảnh đại diện". The report's AC3 reading was verified at source: `image-slot.js:1` opens with `@ds-adherence-ignore -- omelette starter scaffold` and its dartdoc describes a drag-and-drop authoring affordance with a `placeholder` attribute. Only the rendered frame (104px, circle-cropped, `--shadow`) is product design; the dashed chrome is authoring tooling. Sound reading. | DEFERRED — accepted, no action |
| D-8 | Language card value is derived from the active locale (`isVi ? 'Tiếng Việt' : 'English'`) rather than `CupidProfile.language`, while the design binds `{{ langLabel }}`. No visible effect in the only enabled configuration, but it would misreport if a stored profile language ever diverges from the UI locale. | DEFERRED — latent, note for the locale-switcher story |
| D-9 | Report accuracy, three small items: §7 evidence counts are stale (`+8`/`+123` vs the actual `+9`/`+124`) and §7 "Tests added" lists five tests where six exist (the language-card test is missing from the list though §3 references it); §9 "Files Changed" omits `main_preview.dart` and says "No other file was modified", though §2 does disclose that change; §3's D3 row points to "§5" for the `#fff` note but §5 contains only spacing rows. All understate rather than overstate. | DEFERRED — report wording only |
| D-10 | `story_master.md` records `Complexity: trivial` / `Story-Class: trivial`; this round's handoff declared `Story-Class: standard`. Metadata drift worth reconciling. | DEFERRED — `scrum-master` |

## Verified Good

- **Evidence rerun independently in the story worktree, not taken on trust.**
  `flutter analyze lib/features/account test/features/account` -> `No issues found!
  (ran in 2.2s)`. `flutter test .../profile_edit_screen_test.dart` -> `+9: All tests
  passed!` (3 pre-existing behavior tests plus 6 STORY-010 fidelity tests).
  `flutter test test/features/account test/design_system` -> `+124: All tests
  passed!`, including `no_fork_guard_test`, `contrast_test`, `theme_matrix_test` and
  `icon_variant_test`. My counts run one *above* the report's, so the evidence is
  understated, never inflated. `no_fork_guard_test` passing confirms no raw colour
  literal, no `Colors.*` and no platform branch entered `lib/features`.
- **The eight in-scope deviations are real code, confirmed in the render.** D1/D2
  (104px slot with `elevationShadow`), D3 (36px gradient badge, 3px background ring,
  glow, 19px glyph at `right:-10px;bottom:-6px`), D4 (crop caption), D5
  (`Icons.person` -> `CupidIcon`, removing Flutter's second `MaterialIcons` family
  per ADR-004d), D6/D7 (pill radius, `caption` w700 in `colorText`), D8 (helper moved
  inside the DOB card) and D9 (language card) are each visible in the implemented
  frame and each covered by a passing assertion.
- **Codepoint discipline.** `0xe412` / `0xe7fd` were read from the bundled
  `MaterialSymbolsRounded-Variable.ttf` cmap rather than recalled, and declared
  file-locally because `design_system/icons/` is outside write scope — the same
  pattern as `love_contract_screen.dart:429`.
- **AC4 holds.** No navigation code appears in the diff at all; the pre-existing
  `MeScreen -> ProfileEditScreen` push is unchanged, so reachability is untouched
  regardless of how F3 resolves.
- **Preview fixture is contained.** `_PreviewAccountRepository` overrides only
  `fetchProfile()`, activates solely under `--dart-define=PREVIEW_PROFILE=fixture`,
  and follows the existing `_PreviewLoveContractRepository` precedent.

## Acceptance Criteria

| AC | Verdict |
|---|---|
| AC1 — layout/spacing/token/typography match in dark + `vi` | **NOT MET as written** — the render shows eight visible deltas. Five (R1, R2, R4, R5, R9) are legitimately owned elsewhere; R3/R7/R8 sit inside write scope pending F3. |
| AC2 — deviations corrected in the app, not merely documented | **MET** — D1-D9 are all code changes, each test-covered. |
| AC3 — avatar slot matches `<image-slot>` in empty and populated states | **MET** — frame geometry, shadow, badge and caption match; the empty-state chrome exclusion is a verified-sound reading (D-7). |
| AC4 — no new entry point; reachability unchanged | **MET** — no navigation code touched. |

## Action Items

1. `product-owner` (routed by `scrum-master`) — F3: amend `story_master.md` to
   record which surface this story owns and whether canvas `profile` copy governs it.
2. `mobile-dev` — contingent on F3 only: if the canvas-`profile` reading is ratified,
   apply R7/R8 (`app_vi.arb`) and decide R3. Otherwise record them as non-deltas.
   No other mobile work is outstanding.
3. `scrum-master` — D-1: create STORY-032 (app-shell `skyGradient`) or reassign R1;
   the deferral currently names a story that does not exist.
4. `scrum-master` — D-2/D-3: give R5/R6 (zodiac chip artwork and sign localization) a
   real owner before requirement integration review.
5. `mobile-dev` — D-9: correct the three small accuracy items in the visual-fidelity
   report (test counts, `main_preview.dart` in §9, the dangling §5 pointer).
