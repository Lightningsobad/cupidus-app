# Review Report: STORY-010 — Design Fidelity, Onboarding Profile Setup

Outcome: PATCH_REQUIRED

Review type: compact-story-review — **round 3** (supersedes rounds 1 and 2)
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-010 | Lane: mobile (single lane)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-010`
BaseHead: `165c0af` | Reviewed HEAD: `a8d0fed`
Recommended story status: IN_PROGRESS

Round 2's blocking finding F3 is **CLOSED**. The screen itself is the best work
this story has produced. What blocks now is not the screen: it is a `FAIL`
fidelity verdict that no governing artifact has ratified, and a branch that still
carries the superseded round-2 rework as an undecided merge payload.

## Scope Gate

`review/scope-gate.md` in this directory is round 2's and is **stale** — it scopes
`profile_edit_screen.dart`. It is outside this run's WriteScope, so it is left as
found; scrum-master should treat this section as the round-3 scope of record.

Source/test files in scope (7 changed, inside the compact budget):

- `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart` (new, 423)
- `mobile/lib/features/onboarding/presentation/onboarding_profile_setup_route.dart` (new, 40)
- `mobile/lib/features/onboarding/presentation/widgets/zodiac_glyph.dart` (new, 418)
- `mobile/lib/main_preview.dart` (+14/-9)
- the three new `mobile/test/features/onboarding/**` test files (353)

Evidence in scope: `visual-fidelity/visual-fidelity-report.md`, both PNGs,
`story_master.md`, and `RUN-...-STORY-010-mobile-dev-r2.json` (write scope).

Critical gates: rendered design fidelity (12e2/12e3) — **FAIL, see F1**; mobile
analyze + widget tests (12e0) — PASS, independently rerun; entry point (12e1) —
PO-scoped to STORY-002, see F3; runtime smoke (12g) — evidence exists but is
filed in the wrong artifact, see F3.

## Round-2 Finding Closure

**F3 (story delivered against a different screen) — CLOSED, independently
verified against the binding product constraint, not taken on the report's word.**
The PO re-scope (`5778c7d`) and tech-lead plan (`165c0af`) settled that this story
builds a new screen. It does:

- `OnboardingProfileSetupScreen` is a new file under
  `mobile/lib/features/onboarding/presentation/screens/`, its own class, its own
  widget tree. All four new source files sit inside the onboarding feature
  directory.
- **No import of, delegation to, or shared implementation with
  `ProfileEditScreen`.** I read every import in both new presentation files: the
  only crossing into `features/account/` is `domain/cupid_profile.dart` and
  `domain/zodiac.dart` — the data model and the date→sign function, not screen
  code. That is the correct kind of sharing and is what the plan's D4/D5 specify.
- `profile_edit_screen.dart` and `profile_edit_cubit.dart` are byte-identical to
  `BaseHead`; no `account/` source file appears in `git diff --name-only 165c0af`.

**Round-2 D-2 and D-3 are also genuinely fixed, not deferred again.** `ZodiacGlyph`
is a `CustomPainter` port of the design component with all twelve signs, element
ink/disc pairs read from the component's own `EL` map, per-sign vi labels from its
`SIGNS` map, the two decorative sparkles, the thinner virgo/scorpio stroke, and
the documented `cancer` fallback for an unknown sign. The chip now reads
"Song Ngư", matching the reference frame — round 2's "Pisces" delta is gone, and
the 26px artwork it said had no asset now exists.

## Blocking Findings

### F1 — `VISUAL_FIDELITY: FAIL` is unratified, and AC1/AC2 are not met as written (BLOCKING)

I opened both frames rather than counting them.
`design-reference-profile-android.png` does depict canvas `profile` — the
onboarding step, with the "Tiếp tục → Love Contract" CTA, not the Me-hub screen.
`implemented-profile-emulator-5554.png` is a genuine device render (status bar
10:28, gesture pill) of **this** story's screen, showing every authored element in
the right order: avatar + camera badge, crop caption, the three cards
(TÊN GỌI / NGÀY SINH + Song Ngư chip / NGÔN NGỮ + chevron), and the gradient CTA.
The report's §3 element table is accurate against what I see.

The four residual deltas in §4 are real and visible in the frames, and I verified
the claim that carries them: mobile-dev's declared write scope was exactly seven
files and does **not** include `mobile/lib/design_system/`. So "outside WriteScope"
is factually correct, not a convenient framing — the implementer could not have
fixed the backdrop, the typography scale, the gradient axis, or `CupidHeader`
without writing outside its lane.

That makes this a scope defect, not an implementation defect. But it is still
blocking, for the same reason round 2 gave: AC1 requires "no visible deviation"
and AC2 requires deviations be "corrected in the rendered app (not merely
documented)". Both are unmet, `story_master.md` still records "All acceptance
criteria (1-4) are unblocked", and no governing artifact scopes the
design-system-level deltas out. A `FAIL` verdict is `PATCH_REQUIRED` by rule, and
a self-recorded deferral cannot move an AC — round 2 rejected exactly that.

Most conspicuous in the side-by-side, in descending order:

- **Ambient backdrop.** The reference carries the aurora wash and sparkle dots;
  the implemented frame is flat `#171129`. This is the largest visible difference
  between the two images by area. `skyGradient` exists in `cupid_color_tokens.dart`
  only as a raw CSS string with no widget consuming it — round 2 raised this as
  D-1 and assigned it to STORY-032, **which still does not exist.**
- **Header back-arrow ink** — pink in the reference, primary text ink in the build
  (`CupidHeader`, shared by every screen).
- **Sub-13px type.** Four elements authored at 11/11.5/12.5px render at `caption`'s
  13px. This has a *layout* consequence the report does not name: the zodiac helper
  wraps to two lines in the build and fits one in the reference, pushing the DOB
  card taller. Round 2 treated an identical wrap as a real layout delta (R8), so it
  should be recorded as one here, not left implicit under a font-size row.
- **CTA gradient axis** 120deg vs the canvas' 95deg. Measurable, not conspicuous.

§4.1 (empty-avatar glyph instead of the dashed `<image-slot>` chrome) I accept as
before: the dashed ring is the design tool's authoring affordance, not product
design. Not a delta.

**To clear F1**, either route clears it — this is a scrum-master routing choice,
not more mobile work on this branch:

- **(a) Ratify, recommended.** `product-owner` amends `story_master.md` to scope
  design-system-level deltas (backdrop, type scale, gradient axis, shared header
  ink) out of AC1/AC2 with named owner stories; `mobile-dev` then re-issues
  `visual-fidelity-report.md` as `PASS` with those exclusions recorded. Low risk,
  and it matches reality: each fix moves every screen in a live parallel wave.
- **(b) Fix.** Expand write scope to `mobile/lib/design_system/` and have
  `mobile-dev` land the backdrop widget, the type steps and the header ink. This is
  a cross-screen change and should be its own story, not a patch to this branch.

Either way STORY-032 (or a replacement owner) must actually exist before
requirement integration review — round 2 asked for this and it has not happened.

### F2 — The branch still carries the superseded round-2 `ProfileEditScreen` rework, disposition undecided (BLOCKING)

`git diff --stat <integration>...HEAD` shows this branch would merge **+279 lines
of `profile_edit_screen.dart`** and **+168 lines of its test** on top of the new
onboarding screen. That is commit `49c7eab` — the round-2 work built on the premise
the user explicitly rejected ("keep screens separate").

`story_master.md` names this as an open decision for scrum-master ("decide whether
`mobile-dev` removes the `ProfileEditScreen` changes from STORY-010's branch … or
Scrum Master reassigns/merges that commit range directly into STORY-029's scope").
It has not been decided. Merging as-is resolves it silently, in the direction
nobody chose, and makes it permanent on the integration branch.

Worse than the source rework: `profile_edit_screen_test.dart` now contains six
passing tests grouped **`STORY-010 design fidelity against the 'profile' canvas`**
that hard-assert canvas-`profile` geometry on `ProfileEditScreen` — 104px avatar,
36px gradient badge, crop caption, chip ink, language card, helper placement. I saw
them pass in my own run. `story_master.md` reserves to STORY-029 the decision of
"whether canvas `profile`'s visual language is in fact the right fidelity target"
for that screen. These tests pre-empt that decision and will fight STORY-029's
implementer, who cannot change the screen without deleting tests attributed to a
story they do not own. The visual report's §7 flags the misleading group name; the
assertions are the sharper half of the problem, and both were outside mobile-dev's
write scope to fix — this is scrum-master's call, correctly escalated.

**To clear F2**: `scrum-master` records the disposition (drop `49c7eab`'s
`ProfileEditScreen` range from this branch, or reassign it into STORY-029 with the
test group renamed and its canvas-`profile` premise re-opened) before this branch
becomes merge-eligible.

### F3 — Required story evidence sections have no artifact to live in (BLOCKING, small)

This story has **no `coding-plan/test-results.md`** — only `master-plan.md`. Two
mandatory sections therefore do not exist anywhere the DONE gate can read them:

- `## Entry Point Reachability`. I accept that the *code-level* entry point is
  STORY-002's by PO decision (AC4 forbids this story touching navigation, and no
  nav file is in the diff — verified). But the section must still exist and state
  that, with `OnboardingProfileSetupRoute` named as the declared-but-unwired entry.
- `## Story Runtime Startup Smoke`. The smoke did happen — the device capture is
  the proof, and `visual-fidelity-report.md` §5 records it. It is filed in the
  wrong artifact. Either write the section or record
  `Runtime-Smoke: WAIVED — <reason>` in `story_master.md`.

`mobile-dev` can supply both in minutes; they are bookkeeping, not new work. The
DONE gate enforces them independently, so the story cannot close without them.

## Verified Good

- **Evidence rerun independently in the story worktree.**
  `flutter analyze lib/features/onboarding test/features/onboarding` →
  `No issues found! (ran in 1.3s)`.
  `flutter test test/features/onboarding test/design_system/no_fork_guard_test.dart test/features/account/.../profile_edit_screen_test.dart`
  → `+25: All tests passed!`, which reconciles exactly with the report's claimed
  15 new + 9 regression + 1 guard. No inflation.
- **`main_preview.dart` repoint is contained and honest.** Canvas `profile` now
  builds `OnboardingProfileSetupScreen`; the `PREVIEW_PROFILE=fixture` define is
  inert without it, and the entry's doc string was updated to say which screen the
  canvas maps to — so the next person capturing this canvas is not misled.
- **The screen renders what the canvas authors, not a form.** Static display text
  per In Scope §2, `_emptyValue` for a null `birthday` (register collects no DOB),
  chip hidden when there is no birthday, zodiac derived from `birthday` rather than
  the stored `zodiacSign` so chip and "tính tự động" helper can never disagree.
- **Design-system discipline held under pressure.** The two no-fork-guard trips
  during the round (a chained `context.cupidColors.` read containing the literal
  `Colors.`, and a doc comment quoting a packed-hex `Color`) were fixed by adopting
  the convention rather than suppressing the guard, and disclosed in §5.
- **AC4 holds.** No navigation file in the diff; the route factory is declared and
  uncalled.

## Acceptance Criteria

| AC | Verdict |
|---|---|
| AC1 — exact match to canvas `profile`, dark + `vi` | **NOT MET as written** — every authored element is present and correct, but four visible deltas remain (backdrop, header ink, sub-13px type incl. the helper wrap, CTA axis). All four are design-system-level and outside the implementer's write scope. See F1. |
| AC2 — deviations corrected in the app, not merely documented | **NOT MET as written** — the in-scope deltas were corrected; the four in F1 are documented only. Ratification or an expanded scope resolves this. |
| AC3 — avatar slot, empty and populated | **MET** — 104dp circle, `elevationShadow`, 36dp gradient badge at `right:-10/bottom:-6` with the 3dp background ring and glow, crop caption; empty state verified in the render, populated state asserted on `DecorationImage`/`BoxFit.cover`. |
| AC4 — renders standalone, adds no live navigation | **MET** — verified in the diff, not just in the test. |

## Deferred Findings

| # | Finding | Disposition |
|---|---|---|
| D-1 | `_ProfileSetupLocaleText` keeps vi/en copy file-local instead of in `app_vi.arb`, deliberately, because ARB is a shared cross-story surface in this parallel wave (precedent: `invite_screen.dart`). Correct call now; it should be folded into ARB once the wave closes. | DEFERRED — post-wave cleanup |
| D-2 | The language card renders `profile.language` (good — this fixes round-2 D-8's latent bug, where the old screen derived it from the active locale). The card is inert while the canvas also gives it no `onClick`, so the chevron promises an interaction nothing delivers. | DEFERRED — locale-switcher story |
| D-3 | `ZodiacGlyph` lives under `features/onboarding/presentation/widgets/`. The file itself names the promotion path to `design_system/icons/` once a second screen needs it. | DEFERRED — accepted, no action |
| D-4 | The canvas CTA targets `contract` (`goContract`) while STORY-002's chain text says `invite`/`join-code`. Flagged in the visual report §7 and worth resolving before STORY-002 wires it. | DEFERRED — `product-owner`, STORY-002 |

## Action Items

1. `scrum-master` — F1: choose route (a) ratify via `product-owner` amendment to
   `story_master.md`, or (b) expand write scope for a design-system pass. Route (a)
   recommended in a live parallel wave.
2. `mobile-dev` — F1, after (a): re-issue `visual-fidelity-report.md` as `PASS`
   with the ratified exclusions, and name the helper-text wrap as a layout
   consequence under §4.2 rather than leaving it implicit.
3. `scrum-master` — F2: record the disposition of `49c7eab`'s `ProfileEditScreen`
   range and the six `STORY-010 design fidelity` tests in
   `profile_edit_screen_test.dart` before this branch becomes merge-eligible.
4. `mobile-dev` — F3: add `coding-plan/test-results.md` with
   `## Entry Point Reachability` and `## Story Runtime Startup Smoke`.
5. `scrum-master` — create STORY-032 (app-shell `skyGradient` backdrop) or give the
   backdrop, type-scale and shared-header-ink findings a real owner before
   requirement integration review. Round 2 asked for this and it is still open.
6. `scrum-master` — REQ-002 cannot close on this screen alone: STORY-002 must land
   the `permissions -> profile` wiring, or the screen ships unreachable.
