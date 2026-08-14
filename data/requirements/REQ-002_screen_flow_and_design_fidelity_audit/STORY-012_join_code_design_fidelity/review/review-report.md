# Review Report — STORY-012 Join / Enter Pairing Code Design Fidelity (Round 3)

Reviewer: Iris-QC
Mode: compact-story-review
Round: 3 (round 1 PATCH_REQUIRED / F1-F4; round 2 PATCH_REQUIRED / F5-F6)
Scope: REQ-002 / STORY-012_join_code_design_fidelity
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-012`
BaseHead: `fda7f60afb83dd075bccf8c6aec8dc8e8001822d` (round-2 reviewed HEAD)
HEAD reviewed: `176aaa940655aa28e5f5c1ea65b2116d6c71e0ed`
Commit reviewed: `176aaa9` (round-3 fix + boundary seal)
Design source (locked): `cupid-app-design-system`, `Cupid Screens.dc.html`,
`<sc-if value="{{ isJoinCode }}">`, lines 1550-1570

Outcome: PATCH_REQUIRED

The remaining patch is a **Scrum Master / Product Owner artifact decision, not
mobile-dev code work.** Round 3's code pass is accepted in full and nothing is
returned to the implementation lane. See "Required patch set".

## Scope Gate

- Review type: `compact-story-review`, round-3 re-review of a `PATCH_REQUIRED`
  story. Mobile lane, trivial, single-lane.
- Diff baseline: `git diff fda7f60..176aaa9`. Worktree clean at HEAD; BaseHead
  confirmed an ancestor of HEAD.
- Round-3 diff surface (6 files): `joincode_screen.dart`, `cupid_icons.dart`,
  `joincode_screen_design_test.dart`, `visual-fidelity-report.md`,
  `implemented-joincode-emulator-5554.png`, round-2 `review-report.md`.
- Confirmed untouched by the round-3 diff: `story_master.md`, `ux/`,
  `architecture/`.
- Verification limited per handoff to the round-3 diff plus the two gate
  commands. AC1-AC4 baseline verdicts from rounds 1-2 were not re-derived.

## Round-2 findings

| Finding | Status | Verification |
| --- | --- | --- |
| F6 — `VISUAL_FIDELITY` token missing (mechanical) | **CLOSED** | `visual-fidelity-report.md` line 3 carries the literal `VISUAL_FIDELITY: FAIL`, directly under the H1 at line 1. The token is machine-readable and does not overclaim: the verdict stays `FAIL` on purpose, and lines 5-9 explain that the token reports the rendered comparison, not the completeness of this story's own patch set. Correct and honest. |
| F5 items 3-4 — the two authorized code fixes | **CLOSED** | Both verified in the diff; details below. |
| F5 item 2 — Scrum Master decision on AC text vs write scope | **OPEN** | Neither branch fully executed. This is the sole reason the story cannot close. |
| F1-F4 (round 1) | Not reopened | The round-3 diff touches none of the F1-F4 surfaces except to re-capture the implemented PNG, which F1 required be current. |

### F5 item 3 — top-aligned content column: CLOSED

The `Center` wrapper around the body `SingleChildScrollView` is removed, so the
column now flows from the top. The remainder of the 255-line diff on
`joincode_screen.dart` is pure re-indentation from dropping that nesting level —
I read it through and it carries no semantic change. A comment records why the
wrapper must not come back (`flex-direction:column` with no `justify-content`
in the design source), which is the right place for that constraint.

### F5 item 4 — hero badge: CLOSED

Rendered as a 78x78 `Container` with:

- `borderRadius: BorderRadius.circular(platformTokens.radiusSheet)` —
  `radiusSheet` is **28 on both** `CupidPlatformTokens.ios()` (line 30) and
  `.material()` (line 51), so the design's `r28` holds on either platform
  without a literal.
- `color: colors.colorAccentPurple.withValues(alpha: 0.2)` — token-derived, not
  transcribed. `colorAccentPurple` is `0xFFB78CF5` = rgb(183,140,245), which is
  exactly the design's `rgba(183,140,245,.2)`. Verified, not assumed.
- A 38px `CupidIcon(CupidIcons.link)` in `colors.colorAccentPurple`.

`CupidIcons.link` was added additively to `cupid_icons.dart` as
`IconData(0xe157, fontFamily: fontFamily)`. It is the only new symbol in that
file; no existing constant was altered (the `notificationsOff` hunk is
formatter-only line wrapping). The doc comment records the cmap confirmation and
the 0xe250-aliases-to-0xe157 note against the existing `chevronLeft`/0xe408
precedent. The refusal to fork an inline `IconData` in feature code — which
round 2 asked be preserved — was preserved.

Both fixes are backed by new regression tests rather than left to manual
recapture, which was not asked for and is the right call:

- `hero badge renders the design source 78x78 r28 link tile` asserts size,
  `radiusSheet` radius, the alpha-0.2 purple, the `CupidIcons.link` glyph, size
  38 and the icon colour.
- `content column flows from the top, not vertically centred` asserts the badge
  top sits exactly `CupidSpacing.lg` below the viewport top, which pins the
  regression rather than the symptom.

### Deferred blocks: confirmed untouched

All six remain exactly as round 2 routed them — background gradient, app-bar
blend, CTA gradient/glow, `Dán`/`Quét QR` pills, cross-link, and the 8-vs-6 code
length. The fidelity report's verdict table still lists them as `NOT FIXED` /
`ACCEPTED DEVIATION` with owners attached. No scope creep in either direction.

## Why the story still cannot close

Round 2's patch-set item 2 offered Scrum Master a choice: widen the write scope,
**or** amend AC1/AC2 so the story's stated bar matches what it is permitted to
deliver. It also stated plainly that *"passing AC1 as currently written is not
available on this evidence"* — that is, even with items 3-4 delivered.

Round 3 executed the scope-widening branch for items 3-4 only, and the handoff
for this round states that AC text amendment is out of scope for this lane. So
neither branch was carried to completion, and AC1 is unchanged in
`story_master.md`:

> layout, spacing, color/token usage, and typography **match exactly with no
> visible deviation**.

Against that literal text the screen still fails, and its own evidence says so:
`VISUAL_FIDELITY: FAIL`. Two of this screen's own content blocks (the
`Dán`/`Quét QR` row and the `Tôi mới là người tạo mã →` cross-link) are absent
and a third (the 5-slot code row) is substituted. Those three are screen
content, not shared chrome — unlike the background, app-bar and CTA items, which
are legitimately owned by a design-system story.

Recording `CLEAN` or `DEFERRED_ONLY` here would make the story eligible to be
marked `DONE`, which would certify "match exactly with no visible deviation"
against a rendered comparison that refutes it, and against a `FAIL` token in the
story's own artifact. That is the precise failure mode this gate exists to catch,
so I will not record it. The problem is the mismatch between the AC text and the
delivered bar — not the round-3 work.

## Required patch set

One step. No mobile-dev work; no code change.

1. **Scrum Master / Product Owner:** make the story's stated bar match its
   permitted scope, by either:
   - amending AC1/AC2 in `story_master.md` to the scope-limited bar this story
     was actually authorized to hit (token/typography/composition fidelity for
     the blocks inside this lane's write scope), **and** registering the three
     residual screen-content items (`Dán`/`Quét QR` row, cross-link, 5-slot code
     row) as named REQ-002 follow-up stories; or
   - explicitly carrying the AC1 gap to REQ-002 integration review as a named
     blocking item, with the same three follow-up stories registered.

Once the AC text matches the delivered bar, **this exact code state passes** —
re-running this gate needs no new implementation. This is a single cheap
artifact edit, not another implementation round.

Gate interaction Scrum Master should expect: `VISUAL_FIDELITY: FAIL` is correct
and must stay `FAIL`. Because the DONE gate reads that literal token, this story
cannot be marked `DONE` on the strength of a story-review outcome alone while the
token reads `FAIL`. That needs an explicit, recorded decision — not a token flip.

## Deferred — route, do not patch here

Unchanged from round 2 and still correctly documented. None is mobile-dev's to
fix inside this story.

1. Primary CTA gradient / glow / 54px / w800 — shared `CupidPrimaryButton`.
2. Page background gradient + particles (N2) — shared surface.
3. App bar blend and pink chevron (N3) — shared app-bar theme.
4. `Dán` / `Quét QR` — clipboard + camera plugins, `pubspec.yaml`, platform
   permission manifests. Genuine feature work.
5. `Tôi mới là người tạo mã →` cross-link — owner story must be confirmed.
6. Code length 8 (design) vs 6 (shipped) — Product Owner decision, spans
   `joincode`, `invite`, `waiting`.

Items 1-3 cluster into one design-system story. Items 4-5 are the screen-content
residual named in the patch set above; item 6 is a copy/business decision.

## Acceptance criteria

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — exact match, dark + `vi` | FAIL | Improved by the badge and top-alignment fixes, but two own-screen content blocks are still absent and a third substituted. Fails the literal "no visible deviation" bar. |
| AC2 — deviations corrected in the rendered app | FAIL | Nine deviations now genuinely fixed in code, and the round-3 pair are real. The residual screen content is still not rendered. |
| AC3 — code-entry states | PASS (for the delivered entry treatment) | Unchanged from round 2; empty / focused / error token treatment correct and asserted in `vi`. Inherits AC1's substitution caveat. |
| AC4 — no navigation change | PASS | Round-3 diff is presentation-only; no route, `onPaired` seam or back behaviour touched. |

## Critical gates

| Gate | Result |
| --- | --- |
| Static analysis | **PASS** — re-ran `flutter analyze --no-fatal-infos lib/features/pairing lib/design_system test/features/pairing test/design_system` in the worktree: `9 issues found`, **exit 0**, 0 errors, 0 warnings. All 9 are `prefer_initializing_formals` infos on the pre-existing cubit/screen baseline. 8 of 9 sit outside this story's write scope; the 1 in-scope site (`joincode_screen.dart:25`) is a false positive under Dart's private-field/public-parameter rule and is not fixable as suggested. Not a defect signal. |
| Targeted widget tests | **PASS** — re-ran `flutter test test/features/pairing test/design_system`: **`+109: All tests passed!`**, exit 0. Up from +107 in round 2; the two added tests are the F5 regression tests described above. |
| Rendered design fidelity (12e2/12e3) | **FAIL** (intentional, and correctly reported) — `VISUAL_FIDELITY: FAIL` present and machine-readable. The two fixed blocks now read as matches in the report's own verdict table; the six routed blocks still do not. |
| Entry point reachability (12e1) | PASS — existing shipped screen, unchanged (AC4). |
| Runtime startup smoke (12g) | Not required — `trivial` story. |
| Configuration guide (12a) | Not required — no setup/configuration surface touched. |
| Shared-widget regression (12d) | PASS — `cupid_icons.dart` gained one additive constant and altered none; `flutter test test/design_system` green within the +109. |

## Recommendation

- Story status: `IN_PROGRESS` (Scrum Master owns the transition).
- `story_master.md` checkboxes need **no edit**: `Implementation (Development)`
  is correctly `[x]` (round 3 delivered everything authorized) and
  `Review (Reviewer)` correctly stays `[ ]` under a non-passing outcome. I made
  no change to that file.
- Do **not** return this to `mobile-dev`. Round 3 delivered exactly the
  authorized scope, with tests, and reported it honestly.
- Resolve patch-set item 1, then re-run this gate against the same commit.

Round-3 note for the record: the implementation lane did precisely what it was
authorized to do, pinned both fixes with regression tests it was not asked to
write, derived the badge colour from the token instead of transcribing the
design literal, and left the `FAIL` verdict standing rather than quietly
softening it. The `PATCH_REQUIRED` is about an AC text that no longer matches the
story's permitted scope — it is not a mark against the round-3 pass.

---

# Round 4 — AC amendment resolution check

Reviewer: Iris-QC
Mode: completion/resume, documentation-only re-check (fresh reviewer session)
Round: 4
Commit reviewed: `17f8419acd15b3445439a102b0854e9ee4a3b048` (artifact-only;
implementation unchanged since `176aaa9`)
Question for this round: does the AC1/AC2 amendment close the round-3 gap?

Not re-run, per handoff: `flutter analyze`, `flutter test`, and the code diff.
The code is unchanged since `176aaa9` and passed clean at round 3. Beyond the
two handoff-named files I made one ranged read (lines 1-75) of
`visual-fidelity/visual-fidelity-report.md` to check two factual claims the new
AC text makes about the evidence. Both checks failed — see F7 and F8.

Outcome: PATCH_REQUIRED

## What the amendment gets right

The shape is correct. AC1/AC2 are now scoped to an enumerated element list
instead of a blanket "no visible deviation" bar, and a new
`## Follow-Up Scope (Deferred)` section registers screen-content residuals with
owners and reasons. That is what round-3 patch item 1 asked for, and it removes
round 3's core objection: the story no longer claims a whole-screen exact match.
Two of the three registered follow-ups — the `Dán`/`Quét QR` row and the
`Tôi mới là người tạo mã →` cross-link — are correctly justified and are
legitimately outside AC1/AC2's bar now.

## F7 — `page background` sits inside AC1's pass bar but is a documented NOT FIXED deviation

Amended AC1 enumerates "page background" as an element that must "match exactly
with no visible deviation". The story's own evidence says the opposite:

- `visual-fidelity-report.md` verdict table: `Page background | vertical
  gradient (purple top -> near-black bottom) plus faint drifting particles |
  flat --bg, no gradient, no particles | DEVIATION — see N2`.
- Round 3 above lists the same item among the six deferred blocks "confirmed
  untouched", routed to a shared design-system owner.

The amendment therefore moved a known-failing, deliberately deferred element
*into* the pass bar, and `## Follow-Up Scope (Deferred)` does not cover it: the
three shared-chrome deferrals (page background gradient/particles N2, app-bar
blend + pink chevron N3, primary CTA gradient/glow) are registered nowhere.
Read literally, amended AC1 still fails — the same failure mode round 3 declined
to certify. AC1's other three elements (hero badge, content-column
top-alignment, code-entry row token styling) do match the delivered code and are
correctly scoped.

## F8 — the code-entry wording inverts the evidence

Amended AC1 says "the code-entry input row styling (5-slot layout as shipped)",
and Follow-Up item 3 says "5-slot delivered vs. the design source's stated
value ... confirm the design source's actual slot count". Both are backwards.
The fidelity report records the reverse: the *design source* specifies 5 slot
boxes (46x56, r16, pink active slot + `--glow`), and the *shipped* screen
substitutes one full-width rounded field with a letter-spaced `Mã ghép đôi`
hint (`ACCEPTED DEVIATION — item 6`). So the design's slot count is already
established, not an open question, and the real follow-up decision is whether to
build the 5-slot row. The separate 8-vs-6 character-count item (round-3 deferred
item 6, Product Owner decision, spans `joincode`/`invite`/`waiting`) was folded
into item 3 and partly lost. As written, item 3 will send its owner to
re-answer a question the evidence already closes.

## Required patch set — two wording edits, no code

Both live in `story_master.md`. No implementation work, no re-verification.

1. Remove `page background` from AC1's enumerated element list, or keep it and
   explicitly exclude the gradient + particles. Either way, register the three
   shared-chrome deferrals (N2 page background gradient/particles, N3 app-bar
   blend + pink chevron, primary CTA gradient/glow) under
   `## Follow-Up Scope (Deferred)` with the design-system owner round 3
   identified.
2. Correct Follow-Up item 3 to state that the design source specifies a 5-slot
   code row while the shipped screen delivers a single full-width field, and
   keep the 8-vs-6 character-count question named separately. Align AC1's
   parenthetical with the same fact.

After those two edits this exact code state passes; re-running the gate needs no
new implementation.

## Carried forward unchanged from round 3

- `VISUAL_FIDELITY: FAIL` is correct and must stay `FAIL`. The DONE gate reads
  that literal token, so closing this story still needs an explicit recorded
  Scrum Master decision, not a token flip.
- `story_master.md` line 3 still reads `Status: PENDING` while
  `Implementation (Development)` is `[x]`. Scrum Master owns that field; flagged
  here, not edited.
- Nothing returns to `mobile-dev`. The round-3 code pass remains accepted in
  full.

---

# Round 5 — AC-wording patch verification

Reviewer: Iris-QC
Mode: compact-story-review
Round: 5 (round 1 PATCH_REQUIRED / F1-F4; round 2 PATCH_REQUIRED / F5-F6;
round 3 PATCH_REQUIRED / AC-text mismatch; round 4 PATCH_REQUIRED / F7-F8)
Scope: REQ-002 / STORY-012_join_code_design_fidelity
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-012`
BaseHead: `176aaa940655aa28e5f5c1ea65b2116d6c71e0ed` (round-3 reviewed HEAD)
HEAD reviewed: `7721d006de77e320decfc47a2144d485ad5ee685`
Question for this round: do the two round-4 wording edits close F7 and F8?

Outcome: DEFERRED_ONLY

## Scope gate

Documentation-only round, scoped by handoff to the `story_master.md` AC-wording
patch. Not re-reviewed: implementation code, tests, `flutter analyze`,
`flutter test`, phase-P3 visual-fidelity evidence, and rounds 1-4 code verdicts —
all already accepted, and all unchanged since `176aaa9`.

Verified rather than assumed:

- `git diff 176aaa9..HEAD --numstat` returns exactly two files:
  `story_master.md` (+44/-5) and this `review-report.md` (+249/-158, the round-4
  record). No implementation file appears in the range.
- The `story_master.md` change is two hunks only — the AC1/AC2 rewrite at line 51
  and the new `## Follow-Up Scope (Deferred)` section at line 71. Their line
  counts (13 + 31 insertions, 5 deletions) account for the full +44/-5, so no
  third hunk is hidden elsewhere in the file.
- `176aaa9` is an ancestor of HEAD; worktree clean at HEAD.

## Round-4 findings

| Finding | Status | Verification |
| --- | --- | --- |
| F7 — `page background` inside AC1's pass bar; three shared-chrome deferrals registered nowhere | **CLOSED** | Both halves executed. |
| F8 — code-entry wording inverts the evidence; 8-vs-6 folded into item 3 | **CLOSED** | Both halves executed. |

### F7 — CLOSED

`page background` is gone from AC1's enumerated element list. AC1 now binds three
elements only — hero badge (size, radius, color, icon), content-column
layout/top-alignment, and the code-entry input row styling — which is exactly the
set round 4 confirmed does match the delivered code. AC1 and AC2 each carry an
explicit clause excluding everything under `## Follow-Up Scope (Deferred)`, so the
exclusion is stated on the criteria themselves and does not depend on a reader
cross-referencing the section.

All three shared-chrome deferrals are now registered as Follow-Up items 5-7 —
page background gradient + particles (N2), app-bar blend + pink chevron (N3),
primary CTA gradient/glow/54px/w800 — each with the design-system owner round 3
identified, plus a closing note that items 5-7 cluster into one shared
design-system story. Item 5's description ("vertical gradient (purple top ->
near-black bottom) plus faint drifting particles" against a flat shipped
background) reproduces the fidelity report's verdict-table wording that F7
quoted, so the registration is evidence-accurate, not paraphrased into drift.

### F8 — CLOSED

The inversion is corrected in both places round 4 named:

- Follow-Up item 3 now reads that *the design source* specifies a 5-slot code row
  (46x56, r16, pink active slot + glow) while *the shipped screen* delivers one
  full-width field — the correct direction — and states the real open decision
  ("confirm whether to build the design source's 5-slot row") instead of
  re-asking a question the evidence already answers.
- AC1's parenthetical now reads "single full-width field as shipped", matching
  the same fact.
- The character-count question is split back out as its own item 4 (design 8 vs
  shipped 6, Product Owner decision, spans `joincode`/`invite`/`waiting`), so it
  is no longer folded into and partly lost inside item 3.

## Regression check on the rest of the file

Nothing else in `story_master.md` moved — In Scope, Out of Scope, AC3, AC4,
System Integration, Dependencies, and Open Question Impact are byte-identical to
`176aaa9`. Two pre-existing tensions are now more visible because the deferrals
are written into the file for the first time. Neither is a regression, neither is
introduced by this patch, and neither is grounds to hold the gate a fifth time —
round 4 committed that this exact state passes after the two named edits, and
re-scoping now would be goalpost movement. Recorded as optional tidy-up:

1. `In Scope` item 1 still lists "primary CTA styling" and item 2 still says
   "correct every deviation found", while Follow-Up item 7 defers the CTA
   gradient/glow. The audit-vs-fix distinction resolves this (the CTA *was*
   audited; only its fix is deferred) and AC1/AC2 are the binding bar, but a
   one-line qualifier on In Scope item 2 would remove the ambiguity.
2. AC3 (code-entry states) is unchanged and still says states match the design
   source exactly; it inherits AC1's substitution caveat, exactly as round 3
   graded it (`PASS (for the delivered entry treatment)`). The Follow-Up preamble
   scopes its exclusions to "AC1/AC2 above" and does not name AC3.

## Acceptance criteria

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — exact match for the enumerated in-scope elements | PASS | The three bound elements are the ones rounds 3-4 verified as matching. The failing elements that made AC1 fail in rounds 3-4 are now excluded by explicit clause and registered as deferrals. |
| AC2 — deviations corrected in the rendered app | PASS | Same scoping; the nine deviations fixed in code stand, and the residual is now bounded by the Follow-Up section rather than silently inside the bar. |
| AC3 — code-entry states | PASS (for the delivered entry treatment) | Unchanged from rounds 2-4, with the inherited caveat noted above. |
| AC4 — no navigation change | PASS | Unchanged; no code in the round-5 range. |

## Critical gates

| Gate | Result |
| --- | --- |
| Static analysis | Not re-run (per handoff) — PASS at `176aaa9`, code unchanged. |
| Targeted widget tests | Not re-run (per handoff) — `+109: All tests passed!` at `176aaa9`, code unchanged. |
| Rendered design fidelity (12e2/12e3) | `VISUAL_FIDELITY: FAIL` — correct and must stay `FAIL`. See the Scrum Master note below. |
| Entry point reachability (12e1) | PASS — unchanged. |
| Runtime startup smoke (12g) | Not required — `trivial` story. |
| Shared-widget regression (12d) | PASS — unchanged. |

## Why DEFERRED_ONLY and not CLEAN

Every remaining gap on this screen is now a named, owned, deliberately deferred
item registered in `story_master.md` — none is an unaddressed defect and none
returns to `mobile-dev`. That is the definition of `DEFERRED_ONLY`, and it is the
honest verdict: `CLEAN` would imply the screen fully matches its design source,
which the story's own `VISUAL_FIDELITY: FAIL` token correctly denies.

## Scrum Master notes — carried forward, not blocking this outcome

1. `VISUAL_FIDELITY: FAIL` stays `FAIL`. The DONE gate reads that literal token,
   so marking this story `DONE` needs an explicit recorded decision that the
   `FAIL` reflects the seven registered deferrals rather than unfinished
   in-scope work — not a token flip.
2. `story_master.md` line 3 still reads `Status: PENDING` while
   `Implementation (Development)` is `[x]`. Scrum Master owns that field.
3. `Review (Reviewer)` is still `[ ]`; it can now be checked on this outcome.
4. Follow-Up items 1-7 are registered in the story but not yet REQ-002 backlog
   stories. Items 5-7 should become one shared design-system story; items 3-4
   need a Product Owner decision and span `joincode`, `invite`, and `waiting`.

Round-5 note for the record: Product Owner executed both wording edits precisely
as scoped, drew the deferral descriptions from the fidelity evidence rather than
paraphrasing them, and split the character-count item back out instead of leaving
it merged. No code was touched to make a documentation finding go away.
