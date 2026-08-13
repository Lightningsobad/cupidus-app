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
