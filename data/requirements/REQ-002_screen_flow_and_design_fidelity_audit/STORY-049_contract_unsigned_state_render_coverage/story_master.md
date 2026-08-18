# STORY-049: Contract Unsigned-State Render Coverage

Status: DONE
Retro-Type: RED-PATCH
Fixes: STORY-015_love_contract_design_fidelity
Complexity: trivial
Story-Class: standard
Implementation Lane: mobile

## Artifacts

- [x] Requirements (Product Owner) — this file, `## Product Owner Triage`
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial (Complexity: trivial, single mobile lane, single file `mobile/lib/main_preview.dart`; same pattern as STORY-034/038/047/048)
- [x] Architecture (Tech Lead) — SKIPPED:trivial (same basis)
- [x] Implementation (Development) — this file, `## Mobile Implementation` — rework 2026-08-18: `review/review-report.md` B-1 and B-2 both addressed, see `### Rework (Review B-1/B-2)`
- [x] Review (Reviewer) — `Iris-QC` `compact-story-review`, cycle 2, Outcome: DEFERRED_ONLY (0 blocking, 4 deferred: DEF-1/DEF-2/DEF-4/DEF-5, none blocking). Evidence: review/review-report.md

## Background (Rework Item)

Source: `data/retro-audit/rework-backlog.md` — RWB-20260816-014, surfaced by
`STORY-039_love_contract_design_fidelity_hardening`'s reviewer
(`review/review-report.md`, finding V-1) while re-verifying STORY-015's
D-1..D-13.

D-7 and D-8 (add-clause row) and D-10/D-13 (signed card / sign-action error
banner) were re-confirmed by widget test / widget-tree structure only, not by
the rendered pair: `main_preview.dart:328-354` exposes only
`partnerAlreadySigned` and `bothSigned` contract fixtures, so a
requester-unsigned capture (needed to paint the add-clause row) is
unavailable without editing `main_preview.dart`, which was outside
STORY-039's write scope; D-10/D-13 additionally have no design-side reference
at all (the canvas only paints its `myUnsigned` branch). No D-item is
unverified or regressed — this is a coverage gap, not an open defect.

Originally stated remediation: add a requester-unsigned preview fixture to
`main_preview.dart` so the add-clause row can be render-compared, and confirm
whether the design canvas can render signed/error branches at all before
requiring a rendered comparison of a state the design source does not paint.

~~**Update discovered during STORY-048 (2026-08-18):** the Mobile Developer
independently confirmed that `capture-mobile-screen.sh` and
`render-design-canvas.js` — the tooling this remediation note's "design
canvas" half refers to — do not exist anywhere in this repository's working
tree or Git history (`git log --all -- "*capture-mobile-screen.sh"` returns
empty; same for `render-design-canvas.js`). Only the committed
`mobile/lib/main_preview.dart` preview harness is real, in-repo tooling.~~
**Correction (2026-08-18, per this story's `review/review-report.md` B-1 and
`## Mobile Implementation` rework):** the above was wrong. Both tools exist at
`.ai-team-bundle/runtime/tools/` (an untracked install-artifact tree projected
by `install.sh`, never committed — that is why `git log --all` returned
empty; an empty git log proves "not version-controlled", not "absent from
disk"). `render-design-canvas.js` was subsequently run for real against the
`contract` screen; see `## Mobile Implementation` and
`visual-fidelity/visual-fidelity-report.md` for the recorded output. The
"confirm whether the design canvas can render signed/error branches" half of
the original remediation was therefore answerable, and was answered: the
`mySigned` branch has no `hint-placeholder-val` in the design source and is
structurally unreachable regardless of tooling. Product Owner triage below
(AC-2) still correctly scoped D-10/D-13 as document-and-close, now for the
stronger, tool-confirmed reason instead of an absent-tool assumption.

## Product Owner Triage

Complexity: trivial — a single new preview fixture case plus one rendered
capture, and a document-only disposition for the other sub-item. No shipped
app behaviour changes. Implementation Lane: mobile (single lane;
`mobile/lib/main_preview.dart` is the only touched file).

Confirmed against `mobile/lib/main_preview.dart:472-523`
(`_contractFixtureFor`): today it switches on `partnerAlreadySigned` /
`bothSigned` only, so a `requesterUnsigned` case is a direct, additive
extension of the existing pattern — achievable as stated.

### Acceptance Criteria

**AC-1 (D-7/D-8 — add-clause row: close with a real rendered comparison)**
- Add a `requesterUnsigned` case to `_contractFixtureFor()` in
  `mobile/lib/main_preview.dart`, selectable via
  `--dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned`, mirroring
  the existing `partnerAlreadySigned`/`bothSigned` cases:
  `viewerRole: ContractViewerRole.requester`, `signedAtRequester: null`,
  `signedAtPartner: null`.
- Capture the rendered `requesterUnsigned` preview state and compare it
  against the design source's `myUnsigned` branch (the add-clause row).
- File this capture as this story's own `visual-fidelity/` evidence pair
  under
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-049_contract_unsigned_state_render_coverage/visual-fidelity/visual-fidelity-report.md`.
  This story adds a newly capturable state and renders it, so it owns fresh
  evidence — this is distinct from, and does not modify, STORY-015's
  original evidence pair.
- This closes D-7/D-8's render-coverage gap with an actual
  design-vs-implementation comparison, superseding STORY-039's
  test/structure-only re-confirmation.

**AC-2 (D-10/D-13 — signed card / sign-action error banner: document and
close, no fix possible)**
- Record explicitly, in this story's evidence/closure notes, that D-10/D-13
  cannot be closed by a rendered design-vs-implementation comparison: the
  design source's canvas paints only the `myUnsigned` branch and has no
  signed-state or error-state reference to compare against. ~~No in-repo tool
  exists to render additional canvas branches (`capture-mobile-screen.sh` /
  `render-design-canvas.js` are confirmed absent from this repository's
  working tree and Git history, per STORY-048's independent check).~~
  **Correction (2026-08-18):** both tools exist at
  `.ai-team-bundle/runtime/tools/` (untracked install-artifact output; an
  empty `git log --all` proves "not version-controlled", not "absent"). The
  renderer was run against the `mySigned` branch during this story's rework —
  see `## Mobile Implementation` — and D-10 now closes on that recorded
  output (the branch is structurally unreachable in the design source, not
  merely un-rendered for want of a tool).
- Accept STORY-039's existing widget-test / widget-tree structure-level
  verification as sufficient closure for D-10/D-13. No new fixture,
  tooling, or design-canvas capability is required or in scope.
- The story's DONE gate must not require an impossible rendered comparison
  for D-10/D-13 — the documented disposition above is the closure artifact
  for these two items.

**AC-3 (scope boundary)**
- Do not build a design-side render tool or attempt to reconstruct
  `capture-mobile-screen.sh` / `render-design-canvas.js`. New design-canvas
  tooling is out of scope for this LOW-priority coverage-gap item.
- No live app behaviour changes: `main_preview.dart` is a preview-only
  harness; the shipped `LoveContractScreen`/`LoveContractRepository` code
  is not modified by this story.

## Mobile Implementation

Completed 2026-08-18. Flutter 3.44.1 stable / Dart 3.12.1.

### Change

One additive change, in one preview-only file:
`mobile/lib/main_preview.dart` — a `requesterUnsigned` case in
`_contractFixtureFor()` (`viewerRole: ContractViewerRole.requester`,
`signedAtRequester: null`, `signedAtPartner: null`, clauses
`['Always tell the truth', "Don't sleep angry"]`, the same pair the existing
`partnerAlreadySigned` fixture uses so the two captures differ only by viewer
role and sign state). The doc comment above `_contractSignStatusFixture` now
lists the third accepted value and records why it exists.

No shipped app code was modified. `love_contract_screen.dart`,
`love_contract_repository.dart`, `clause_toggle_row.dart`, and
`hold_to_sign_button.dart` are untouched.

### Rework (Review B-1/B-2), 2026-08-18

Scoped rework after `review/review-report.md` returned PATCH_REQUIRED. AC-1 and
AC-3 were PASS and were not re-touched; no fixture, capture, or measurement
changed.

**B-1 — false tooling-absence claim, and the untried `mySigned` render.**
`.ai-team-bundle/runtime/tools/render-design-canvas.js` and
`capture-mobile-screen.sh` do exist; they are untracked install-artifact output,
which is why `git log --all` was empty. The renderer was then actually run:
`--list-screens` resolved `Design-Screen: contract`, and two `--click` attempts
on the hold-to-sign control both exited 0 yet produced output byte-identical to
the unclicked baseline, because `mySigned` (`Cupid Screens.dc.html:154`) has no
`hint-placeholder-val` and the hold bindings are design-time placeholders. D-10
now closes on that recorded output instead of on an assertion. New evidence file
`visual-fidelity/design-reference-contract-mysigned-attempt-android.png`;
`Design-Screen: contract` recorded in the report per rule 12e2; the false
statements corrected in this file (AC-2) and in the report (three places).
D-13's closure was not touched.

**B-2 — false doc comment.** `mobile/lib/main_preview.dart` claimed
`requesterUnsigned` "is the only state that paints the add-clause row". That is
wrong: `love_contract_state.dart:74` derives `canEditClauses` from `viewerRole`
alone and `love_contract_screen.dart:427` gates the row on it, so the
pre-existing `bothSigned` fixture (also `viewerRole: requester`) paints it too.
The comment now says `requesterUnsigned` is the only fixture that paints the row
*in the same sign state as the design's `myUnsigned` branch*. Comment-only
change; the fixture itself is unchanged and remains the correct choice, since
`bothSigned` would compare a signed card against an unsigned design branch.

### AC Results

**AC-1 — MET.** The fixture is selectable via
`--dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned` and renders the
add-clause row, which no prior fixture could paint *in the unsigned state the
design's `myUnsigned` branch shows* (`bothSigned` also paints it, but signed;
`partnerAlreadySigned` never does — ADR-019e hides it from the `partner`
viewer). Captured on `emulator-5560` and compared against the design
canvas's `myUnsigned` branch. Result `VISUAL_FIDELITY: PASS`; D-7 (single `+`
glyph) and D-8 (add-clause row is the last child of the clause list block) are
now closed by an actual rendered comparison, superseding STORY-039's
structure-only re-confirmation. Key measurements, in image px: add-clause label
bottom to the dashed rule below it is **22 on both sides**; left inset from the
card edge is 19 (design) vs 20 (implementation).

The design reference is STORY-039's `design-reference-contract-android.png`
reused byte-for-byte — `shasum -a 256` is
`2acd1045727564cf7ff167fd36e13f3a418c65509be7debc35060ba6498514b3` on both
copies. STORY-015's and STORY-039's evidence directories were not modified.

Two differences the new render makes visible for the first time are recorded in
the report but are outside D-7/D-8: the add-clause label copy (`Thêm điều khoản
riêng` vs the design's `Thêm điều khoản của riêng tụi mình` — the shipped `vi`
ARB string, quoted and accepted in STORY-015's own D-7 write-up), and the clause
counter row (already dispositioned as A-1 in STORY-015).

**AC-2 — MET, document-and-close, now on rendered evidence.** D-10 and D-13 are
closed by disposition, not comparison.

D-10 is backed by the sanctioned renderer's own output. The design canvas's
`mySigned` branch (`Cupid Screens.dc.html:154`) carries no
`hint-placeholder-val`, unlike `myUnsigned` (line 160), so the static prototype
never paints it. `render-design-canvas.js --list-screens` resolved this screen's
id as `contract`; two `--click` attempts on the hold-to-sign control (at span
level and at the handler-div level) both exited 0 with the click reported as
matched, and both produced PNGs **byte-identical** to the unclicked baseline
(`2acd1045…14b3`). A deliberately wrong selector returned
`DESIGN_CANVAS_CLICK_TARGET_MISSING` / exit 1, proving failed clicks are
reported rather than swallowed. The branch is therefore unreachable from the
design source as shipped, so no signed-state reference is obtainable. Probe
output stored as `visual-fidelity/design-reference-contract-mysigned-attempt-android.png`.

D-13 is unchanged and rests on independent grounds: it has no design counterpart
in any branch (STORY-015 recorded the sign-action error banner under A-3 as
app-only).

STORY-039's widget-test / widget-tree verification stands as sufficient closure
for both. The DONE gate must not require a rendered comparison for these two
items.

**Correction (2026-08-18 rework).** An earlier revision of this section claimed
`capture-mobile-screen.sh` and `render-design-canvas.js` "do not exist in this
repository's working tree or Git history". That was wrong. Both exist at
`.ai-team-bundle/runtime/tools/` (20011 and 23087 bytes); they are untracked
because that tree is projected by `install.sh` and never committed, so
`git log --all` reports nothing for them. An empty `git log` proves a path is
not version-controlled, never that it is absent from disk. The claim was
inherited from STORY-048 and repeated here without a filesystem check.

Two Scrum-Master-owned places carried the same inherited claim and were **not**
edited by this mobile-lane rework because they are outside the mobile lane:
`## Background (Rework Item)`'s "Update discovered during STORY-048" paragraph,
and `## Product Owner Triage` AC-2's first bullet ("no in-repo tool exists ...
confirmed absent ... per STORY-048's independent check"). **Corrected 2026-08-18
(Scrum Master):** both are now struck through with a dated correction at their
source. AC-2's *outcome* was unaffected throughout — D-10 still closes by
disposition, now for a stronger reason.

**AC-3 — MET.** No design-canvas render tool was built or reconstructed, and no
live app behaviour changed.

### Verification

- `flutter test --no-pub` (full suite): **1285 passed, 2 skipped, 0 failures.**
- `flutter analyze --no-pub lib test`: **80 issues, all `info`**, all
  pre-existing; zero errors, zero warnings. (`analyze` exits non-zero for any
  issue, including `info`.)
- `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=contract --dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned`:
  succeeded.

Re-run after the B-2 doc-comment edit (2026-08-18 rework), both unchanged:
`flutter analyze --no-pub lib test` → 80 issues, all `info`;
`flutter test --no-pub` → `+1285 ~2: All other tests passed!`, exit 0.

### Evidence

- `visual-fidelity/visual-fidelity-report.md`
- `visual-fidelity/design-reference-contract-myunsigned-android.png`
- `visual-fidelity/implemented-contract-requesterunsigned-emulator-5560.png`
- `visual-fidelity/design-reference-contract-mysigned-attempt-android.png`
  (B-1 rework: the renderer's own `mySigned`-forcing output)

## Next Valid Step

Route to UI/UX Designer, then Tech Lead (both eligible for
`SKIPPED:trivial` given `Complexity: trivial` and the single-file,
single-lane scope — Scrum Master to confirm and mark in `## Artifacts`),
then Mobile Developer for AC-1 implementation + evidence capture and AC-2's
documented disposition, then Reviewer at the trivial/compact tier.

Do Not Re-read: `rework-backlog.md` RWB-20260816-014 detail section (already
captured verbatim above); STORY-015/STORY-039's own artifacts beyond what's
summarized here.
