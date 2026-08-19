# Story Master: STORY-057 Contract Add-Clause Copy Alignment

Status: PENDING
Complexity: trivial
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-015_love_contract_design_fidelity
Scope: Retro-hardening (RWB-20260816-025)
Screens: `contract` (Love Contract) only — the add-clause affordance label
named by DEF-1/RWB-20260816-025. No other screen is in scope.
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`). No new canvas render is required: the canvas's
`myUnsigned` branch was already rendered fresh by STORY-049 as
`design-reference-contract-myunsigned-android.png` and reused byte-identical
by STORY-056 (confirmed by matching `sha256` against STORY-039's original
render). Re-render only if that file is found stale against the current
design source.
Write scope: this story's own directory (`story_master.md`,
`requirements/requirements.md`, and its own `visual-fidelity/` evidence
directory); `mobile/lib/l10n/arb/app_vi.arb` — value only, on the single key
named below (key name and `@`-description untouched);
`mobile/test/features/love_contracts/presentation/screens/love_contract_screen_fidelity_test.dart`
— the single expected-string literal at line 223 only, to keep it aligned
with the corrected `vi` value; and the regenerated
`mobile/lib/l10n/generated/` output produced by the standard Flutter l10n
codegen step (not hand-edited). No other `mobile/lib/**` file is write
scope.

## Artifacts
- [x] Requirements (Product Owner) — this file, `## Product Owner Triage`
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial (Complexity: trivial,
  single mobile lane, a verbatim l10n value correction with an established
  precedent decision and no layout/width constraint on the affected
  `Text` widget — confirmed by Scrum Master)
- [x] Architecture (Tech Lead) — SKIPPED:trivial (same basis; no
  architecture decision, no new code path, a single ARB value edit plus a
  matching test-literal update — confirmed by Scrum Master)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Background (Rework Item)

Source: `data/retro-audit/rework-backlog.md` — RWB-20260816-025, surfaced by
`STORY-049_contract_unsigned_state_render_coverage`'s reviewer
(`review/review-report.md` cycle 2, DEF-1) while re-verifying B-1/B-2:

"The implementation renders the add-clause affordance as `+ Thêm điều khoản
riêng`; the design canvas's `myUnsigned` branch paints `+ Thêm điều khoản của
riêng tụi mình`. Same single-plus glyph, same position (D-7/D-8 pass on
structure and glyph count) — the delta is wording only, made visible for the
first time by STORY-049's new `requesterUnsigned` render, since no prior
fixture painted this row against this design branch. The shipped `vi` ARB
string was already quoted verbatim in STORY-015's own D-7 write-up and
accepted there (D-7's defect was the duplicated glyph, not the wording), so
this is not a regression — it is a previously-undisclosed, now-rendered
content difference. Same class as RWB-20260816-016/017/018/019 (l10n/ARB
surface, out of scope for the screen-lane story that exposed it)."

Anchor story (tracking anchor for the `contract` screen's fidelity scope, not
reopened here): `STORY-015_love_contract_design_fidelity` — remains
DONE/unmodified. `STORY-046_shared_backdrop_occlusion_hardening` and
`STORY-049_contract_unsigned_state_render_coverage` are also not reopened.

## Product Owner Triage

Complexity: trivial — a single ARB string-value correction plus a matching
test-literal update and a same-state evidence re-capture, no new UX
decision, no new architecture decision, single (`mobile`) implementation
lane.
Implementation Lane: mobile (single lane; the only touched production path
is one l10n value and its generated output, plus one test literal).

**Decision: correct the shipped `vi` copy to match the design string
verbatim.** This is the same l10n/design-annotation-delta class already
resolved twice in this requirement — RWB-20260816-018/019
(`STORY-053_antighost_public_countdown_penalty_hardening`, AC6) — and both
times the resolution was to correct the app's `vi` ARB value to match the
design source (`Gây ồn` → `Phát âm thanh`), not to treat the design
annotation as stale. Applying the same policy here for consistency:

- No concrete reason to diverge was found. The affected `Text` widget
  (`love_contract_screen.dart:435-443`) sits inside a left-aligned
  `TextButton` with no `maxWidth`, `maxLines`, or `overflow` constraint — a
  longer label has nowhere it would visibly clip or wrap awkwardly, so there
  is no text-fit reason to prefer the shorter shipped copy.
  STORY-015's own D-7 finding quoted the shipped string verbatim and
  disposed of it as fine at the time, but that finding's actual defect was
  the duplicated plus glyph, not a considered wording decision — D-7 never
  compared the wording against the design source.
- Exact change: `mobile/lib/l10n/arb/app_vi.arb`, key
  `loveContractAddClauseAction` (currently line 700), value only:
  - Old: `"+ Thêm điều khoản riêng"`
  - New: `"+ Thêm điều khoản của riêng tụi mình"`
  Key name and the `@loveContractAddClauseAction` description block are
  unchanged. Do not hand-edit `mobile/lib/l10n/generated/` — regenerate it
  with the project's standard Flutter l10n codegen step, matching the
  precedent recorded in STORY-053's `architecture/solution.md:133`.
  `mobile/lib/l10n/arb/app_en.arb`'s `loveContractAddClauseAction` (`"+ Add
  our own clause"`) is not part of this finding and is not touched.
- Consequence needing an explicit AC: one existing test asserts the exact
  old string —
  `mobile/test/features/love_contracts/presentation/screens/love_contract_screen_fidelity_test.dart:223`,
  `expect(find.text('+ Thêm điều khoản riêng'), findsOneWidget);` inside the
  test named "the add-clause affordance renders a single leading plus, not
  the localized plus plus a duplicate add icon" (the D-7 single-glyph
  regression guard). That literal must be updated to the new string so the
  test keeps passing and keeps guarding the single-glyph invariant; the rest
  of that test (the icon-absence assertion) is untouched.
- Evidence: because this is a real code change (unlike STORY-056's
  documentation-only evidence realignment), the implementation side of the
  `contract` same-state pair must be freshly captured after the ARB change
  — STORY-056's `implemented-contract-requesterunsigned-emulator-5560.png`
  cannot be reused as-is, since it depicts the pre-fix string. The design
  side (`design-reference-contract-myunsigned-android.png`) may be reused
  byte-for-byte if the design source is confirmed unchanged since STORY-056's
  render (same confirmation method: re-render and compare `sha256`, or diff
  the source since the last confirmed commit).

### Acceptance Criteria

See `requirements/requirements.md` for the numbered AC set.

## Next Valid Step

Route to UI/UX Designer, then Tech Lead (both eligible for `SKIPPED:trivial`
given `Complexity: trivial` and the single-file-family, single-lane scope
with an established precedent decision — Scrum Master to confirm and mark in
`## Artifacts`), then Mobile Developer for the ARB edit, codegen
regeneration, test-literal update, and evidence capture, then Reviewer at
the trivial/compact tier.

Do Not Re-read: `rework-backlog.md` RWB-20260816-025 detail section (already
captured verbatim above); RWB-20260816-018/019's detail sections (already
summarized above); STORY-015/STORY-046/STORY-049/STORY-053's own artifacts
beyond what's summarized here.
