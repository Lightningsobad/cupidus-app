# Story Master: STORY-056 Contract Evidence State Realignment

Status: IN_PROGRESS
Complexity: trivial
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-015_love_contract_design_fidelity
Scope: Retro-hardening (RWB-20260816-023)
Screens: `contract` (Love Contract) only — the same-state evidence-pair
realignment named by DEF-2/RWB-20260816-023. No other screen is in scope.
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`). No new canvas render is strictly required: the
canvas's default/`myUnsigned` `contract` branch was already rendered fresh by
STORY-049 as `design-reference-contract-myunsigned-android.png`
(byte-identical to STORY-039's original `design-reference-contract-android.png`,
confirmed by matching `sha256`). Re-render only if that file is found stale
against the current design source.
Write scope: this story's own
`visual-fidelity/` evidence directory plus this file and
`requirements/requirements.md`. No `mobile/lib/**` production file is write
scope — this is a documentation/evidence correctness fix, not a code change.
`mobile/lib/main_preview.dart` already exposes the needed
`--dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned` fixture (added
by STORY-049) and does not need to be touched again.

## Artifacts
- [x] Requirements (Product Owner) — this file, `## Product Owner Triage`
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial (Complexity: trivial,
  single mobile lane, evidence-only, no UX decision — confirmed by Scrum
  Master)
- [x] Architecture (Tech Lead) — SKIPPED:trivial (same basis; no
  architecture decision, no new code path, evidence-only scope — confirmed
  by Scrum Master)
- [x] Implementation (Development) — Mobile Developer: filed a fresh same-state
  `contract` pair in this story's own `visual-fidelity/` (design re-rendered,
  reproduces the stored `2acd1045…14b3` hash; implementation rebuilt with the
  existing `requesterUnsigned` fixture and re-captured) and recorded a fresh
  per-element MATCH verdict for all five elements in
  `visual-fidelity/visual-fidelity-report.md` — `VISUAL_FIDELITY: PASS`, no new
  deviation, no `mobile/lib/**` file touched
- [ ] Review (Reviewer)

## Background (Rework Item)

Source: `data/retro-audit/rework-backlog.md` — RWB-20260816-023, surfaced by
`STORY-046_shared_backdrop_occlusion_hardening`'s reviewer
(`review/review-report.md` cycle 2, finding DEF-2) while independently
opening all 12 rendered PNGs added by that story's patch — undisclosed by the
mobile-dev's own report.

The implemented `contract` capture
(`STORY-046_shared_backdrop_occlusion_hardening/visual-fidelity/implemented-contract-emulator-5560.png`)
depicts the `partnerAlreadySigned` state: English fixture clause text
("Always tell the truth", "Don't sleep angry", "Check in once a day", "Say
sorry first, argue about it later"), a "2/20 điều khoản" counter, and a
"Minh Anh đã ký, đến lượt bạn" line. The design reference rendered fresh for
that same story
(`STORY-046_shared_backdrop_occlusion_hardening/visual-fidelity/design-reference-contract-android.png`)
depicts a different state: Vietnamese clause copy ("Không giận quá 24 giờ",
…), a "+ Thêm điều khoản của riêng tụi mình" affordance, and no signature
line.

Classification (from the review, not reopened here): not a regression and
does not change STORY-046's own outcome — that story's own question was
independently answered by a same-screen pre/post-change A/B against
STORY-039's pre-change capture, which does not depend on the reference's
state matching. But STORY-046's AC3 row's `MATCH` verdict for `contract`'s
content column rests only on structural correspondence (header band, clause
rows, divider, CTA, encryption footer), not on a same-state comparison, so it
does not independently confirm content fidelity in the signed state shown.
The reviewer routed this to the REQ-002 requirement-level audit rather than
blocking STORY-046.

Anchor story: `STORY-015_love_contract_design_fidelity/` is the tracking
anchor named by RWB-20260816-023 (the story that originally owns the
`contract` screen's fidelity scope), not STORY-046 itself — this story does
not reopen STORY-015 or STORY-046, both remain `DONE`/unmodified.

## Product Owner Triage

Complexity: trivial — a same-state evidence-pair correctness fix with an
already-precise remediation, achievable with existing tooling and an
existing fixture; no `mobile/lib/**` production code needs to change.
Implementation Lane: mobile (single lane; the only touched paths are this
story's own `visual-fidelity/` evidence files).

**Only one of RWB-20260816-023's two named remediation options is actually
achievable — this matters for the implementer.** The finding names two
options: (a) re-render the design reference in the `partnerAlreadySigned`
state, or (b) re-capture the implementation in the reference's unsigned
state. Option (a) is a dead end already proven by
`STORY-049_contract_unsigned_state_render_coverage`'s own D-10 finding: the
design canvas's signed branch (`mySigned`, `Cupid Screens.dc.html:154`) has
no `hint-placeholder-val`, and two `--click` attempts on the hold-to-sign
control both exited 0 yet produced PNG output byte-identical to the
unclicked baseline — the signed state is structurally unreachable from the
design source as shipped, not merely un-rendered for want of effort. Do not
re-attempt it. Option (b) is therefore the only viable path, and it is
already partially done: STORY-049 added a `requesterUnsigned` fixture to
`main_preview.dart` (`--dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned`)
and captured exactly this pair —
`design-reference-contract-myunsigned-android.png` (reused byte-for-byte from
STORY-039's original render) against
`implemented-contract-requesterunsigned-emulator-5560.png` — for its own
narrower AC-1 purpose (the add-clause row only, D-7/D-8). This story's gap is
that no one has re-run the *full* content/layout comparison DEF-2 flagged
(header band, clause rows, divider, CTA, encryption footer) on a same-state
pair — only the narrow add-clause-row check exists today.

Implementer's choice, in order of preference (most mechanical first):
1. Reuse STORY-049's existing pair as-is, after confirming the `contract`
   screen's source is unchanged since that capture (the same
   `git diff <STORY-049 commit>..HEAD -- mobile/lib/features/love_contracts/
   cupid-app-design-system/` emptiness check STORY-050 used) — no new
   render, no new build required.
2. If the source has changed, produce a fresh pair with the already-proven
   commands (`render-design-canvas.js --screen=contract ...` /
   `flutter build apk --debug -t lib/main_preview.dart
   --dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned` +
   `capture-mobile-screen.sh`) — no `main_preview.dart` edit needed either
   way, since the fixture already exists.

Either way, file the pair (reused or fresh) in this story's own
`visual-fidelity/` directory — the DONE evidence gate requires each
`contract`-screen story to carry its own `implemented-contract-*.png` /
`design-reference-contract-*.png` pair, per the precedent already applied to
STORY-047/STORY-049/STORY-050.

### Acceptance Criteria

See `requirements/requirements.md` for the numbered AC set.

## Mobile Implementation (2026-08-19)

Full evidence in `visual-fidelity/visual-fidelity-report.md`. Summary:

**AC-1 HOLDS — fresh pair, not a reuse.** The Product Owner's preferred reuse
path was tested and **failed its own precondition**, so it was not taken.
`git diff --stat d58da5f..HEAD` is empty for `mobile/lib/features/love_contracts/`
and empty for `cupid-app-design-system/`, but **not** empty for `mobile/lib/`
(20 files, +659/-78) — the broader check STORY-050 actually used. That diff
includes `design_system/adaptive/cupid_header.dart`, and
`love_contract_screen.dart:114` renders through `CupidHeader`. The new slots are
null-guarded and `contract` passes neither, so the change is very likely
visually inert, but a fresh pair settles it by render instead of by inspection.
The design side was re-rendered with `render-design-canvas.js` and reproduces
STORY-049's stored hash `2acd1045…14b3` byte-for-byte, which independently
confirms the design source is unmoved. The implementation side was rebuilt with
the existing `--dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned`
fixture and re-captured. No signed-state render was attempted.

**AC-2 HOLDS.** All five named elements re-compared on the same-state pair and
recorded per-element: header band, clause rows, divider, CTA/hold-to-sign
affordance, encryption footer — **all MATCH**, `VISUAL_FIDELITY: PASS`. The
report states it supersedes STORY-046's AC3 content-column verdict for
`contract` and closes the evidence-state finding tracked as item 023. Vertical
scale was proven 1:1 by three invariants (clause pitch 47/47, CTA pill height
62/62, add-clause→rule 19.5/19.5) before any verdict was drawn.

**AC-3 HOLDS.** No `mobile/lib/**` file modified, `main_preview.dart` included.

**No new deviation found.** Every measured difference resolves into an
already-dispositioned item (the `2/20 điều khoản` counter = A-1/CC-1, which
alone accounts for the 19.5 px inter-rule span difference; the add-clause label
copy = D-7), a documented fixture-state/fixture-data difference (subtitle
fallback, 3-vs-2 clause selection, English fixture clause labels), or a
few-px text line-box tolerance whose spacing tokens D-6 already reconciled.

**Harness note worth carrying forward:** a 12000 ms settle is too short for this
debug build — the first capture attempt returned the Flutter splash screen while
still exiting 0 with a plausible `405x900`. Exit status alone does not tell a
good capture from a bad one; the discarded attempt was caught only by opening
the PNG. A 45 s settle produced the real screen.

## Next Valid Step

Route to UI/UX Designer, then Tech Lead (both eligible for `SKIPPED:trivial`
given `Complexity: trivial` and the single-file-family, single-lane,
evidence-only scope — Scrum Master to confirm and mark in `## Artifacts`),
then Mobile Developer for AC-1/AC-2 evidence work, then Reviewer at the
trivial/compact tier.

Do Not Re-read: `rework-backlog.md` RWB-20260816-023 detail section (already
captured verbatim above); STORY-046's `review/review-report.md` DEF-2 section
(already captured verbatim above); STORY-015/STORY-039/STORY-046's own
artifacts beyond what's summarized here.
