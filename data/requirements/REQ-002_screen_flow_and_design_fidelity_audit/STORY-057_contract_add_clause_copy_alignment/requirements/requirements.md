# Story Requirements: STORY-057 Contract Add-Clause Copy Alignment

## Source Artifacts

- Requirement master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/req_master.md`
- Story master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-057_contract_add_clause_copy_alignment/story_master.md`
- Additional input files: `data/retro-audit/rework-backlog.md` item
  RWB-20260816-025 (source finding, already extracted into story master's own
  `## Background (Rework Item)`); RWB-20260816-018/019 and
  `STORY-053_antighost_public_countdown_penalty_hardening`'s
  `architecture/solution.md`/`review/review-report.md` AC6 (the precedent
  decision this story applies, summarized in story master's `## Product
  Owner Triage`); `mobile/lib/l10n/arb/app_vi.arb:700`,
  `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart:430-445`,
  and
  `mobile/test/features/love_contracts/presentation/screens/love_contract_screen_fidelity_test.dart:217-229`
  (confirmed current at time of scoping).

## Business Summary

- Primary actor: none directly — this is a copy-correctness hardening item;
  the requesting party is the REQ-002 design-fidelity audit trail (via
  RWB-20260816-025).
- Problem to solve: the `contract` screen's add-clause affordance renders
  `+ Thêm điều khoản riêng` in the shipped `vi` locale, while the design
  canvas's `myUnsigned` branch specifies `+ Thêm điều khoản của riêng tụi
  mình` — a previously-undisclosed wording delta, first made visible by
  STORY-049's `requesterUnsigned` render.
- Business outcome: the shipped `vi` copy matches the design source
  verbatim, applying the same match-the-design-string policy already used
  for RWB-20260816-018/019, closing RWB-20260816-025 without reopening
  STORY-015, STORY-046, or STORY-049.
- Success signal: `mobile/lib/l10n/arb/app_vi.arb`'s
  `loveContractAddClauseAction` reads `+ Thêm điều khoản của riêng tụi
  mình`; the regression test that asserts this string is updated and still
  passes; a fresh same-state rendered pair confirms the corrected string on
  screen.
- Complexity: trivial (routing rule: no new screens, no new UX decisions, no
  new architecture decisions, single implementation lane, a single ARB value
  plus one matching test literal).
- Why this complexity: `.claude/skills/product-owner/references/complexity-routing.md`
  classifies a story as `standard` only if it needs new screens, new UX
  decisions, new architecture decisions, or spans more than one
  implementation lane. This story is a verbatim string correction with an
  already-decided precedent policy (RWB-018/019), touches one ARB value, its
  generated output, and one test literal, and only the `mobile` lane. Per
  that reference's Lane Consistency Rule, a single-lane story
  (`Implementation Lane: mobile`) bypassing UX/Architecture must be
  classified `trivial`. UX Design and Architecture are marked
  `SKIPPED:trivial` in the story master, not left open for their normal
  specialists.
- Primary implementation lane: mobile (single lane; never `shared` for a
  `trivial` story per the routing reference).

## Scope Decision

### In Scope

1. Correct `mobile/lib/l10n/arb/app_vi.arb`'s `loveContractAddClauseAction`
   value (currently line 700) from `"+ Thêm điều khoản riêng"` to
   `"+ Thêm điều khoản của riêng tụi mình"`, matching the design canvas's
   `myUnsigned` branch verbatim. The key name and its
   `@loveContractAddClauseAction` description block are unchanged.
   `app_en.arb`'s sibling key (`"+ Add our own clause"`) is not touched —
   RWB-20260816-025 names only the `vi` delta.
2. Regenerate `mobile/lib/l10n/generated/` via the project's standard
   Flutter l10n codegen step. Do not hand-edit any generated file.
3. Update the single expected-string literal at
   `mobile/test/features/love_contracts/presentation/screens/love_contract_screen_fidelity_test.dart:223`
   (`expect(find.text('+ Thêm điều khoản riêng'), findsOneWidget);`) to the
   new string, so the existing single-leading-plus regression test (guarding
   D-7's original duplicated-glyph defect) continues to pass against the
   corrected copy. No other assertion in that test is changed.
4. Produce a fresh implementation-side `contract` capture (unsigned /
   `requesterUnsigned` state, using the existing
   `--dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned` fixture
   already present in `mobile/lib/main_preview.dart`, added by STORY-049) and
   pair it with the existing
   `design-reference-contract-myunsigned-android.png` (reused byte-for-byte
   from STORY-049/STORY-056 if the design source is confirmed unchanged,
   otherwise re-rendered via `render-design-canvas.js --screen=contract`).
   File the pair in this story's own `visual-fidelity/` directory and record
   a `MATCH`/`DEVIATION` verdict for the add-clause row text specifically,
   noting that it closes RWB-20260816-025.
5. `flutter analyze` and the existing `flutter test` suite pass clean after
   the edit (no new unused-import/unused-variable warnings, no unrelated
   test regressions).

### Out of Scope

- `app_en.arb`'s `loveContractAddClauseAction` value — not named by this
  finding.
- Any other content, layout, spacing, typography, or component-level
  fidelity change on the `contract` screen — STORY-015/STORY-046/STORY-049/
  STORY-056 already confirmed those aspects and that scope is not reopened
  here.
- Re-attempting a signed-state design-canvas render — already proven
  unreachable by STORY-049's own D-10 finding; not relevant to this story's
  unsigned-state affordance either way.
- Reopening or editing the closed git boundary/branch of STORY-015,
  STORY-039, STORY-046, STORY-049, or STORY-056.
- Any new screen, new navigation entry point, new interaction, or new
  design decision.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet; same precedent exclusion as every other REQ-002
  hardening story).

## System Integration And Discoverability

- UI-facing story: YES (one existing screen, one existing affordance label;
  no new UI surface).
- Existing user-visible surface, workflow, or state where the actor starts:
  the `contract` screen's existing add-clause affordance, reachable through
  the Love Contract screen's existing navigation path — unchanged by this
  story.
- Required entry point, navigation item, CTA, or in-flow discovery path:
  unchanged; this story only corrects a label's wording.
- Direct URL only acceptable: N/A — existing reachable screen, not new.
- Which screen of the design source this story covers: `contract` (Love
  Contract), `myUnsigned` branch, add-clause affordance row — already
  confirmed/recorded by STORY-015/STORY-049.
- Existing user journey affected: none — the Love Contract flow keeps its
  existing order and behavior; only the affordance's label text changes.
- Out-of-scope integration surfaces: any screen other than `contract`; any
  navigation, persistence, or backend surface (this is a pure copy fix).

## Business Rules And Guardrails

- The value edit is mechanical and scoped to exactly one ARB key's `vi`
  value; do not rename the key, alter the description, or touch the
  matching `en` value.
- Do not hand-edit `mobile/lib/l10n/generated/` — regenerate it with the
  standard codegen step.
- The test-literal update at
  `love_contract_screen_fidelity_test.dart:223` must change only the
  expected string, preserving the test's existing single-glyph/no-duplicate-
  icon assertions intact.
- The implementation-side evidence capture must be fresh (not reused from
  STORY-056), since it depicts the corrected string; the design-side capture
  may be reused only after confirming the design source is unchanged since
  its last confirmed render.
- If the AC-4 comparison surfaces any deviation beyond the now-corrected
  add-clause text, record it as a new finding and do not silently expand
  this story's scope to fix it.

## User Story

As a user of the Love Contract screen reading the add-clause affordance in
Vietnamese,
I want the label to read the same wording the confirmed design specifies,
So that the shipped copy matches the design source instead of carrying an
undisclosed wording difference.

## Edge Cases And Failure Behavior

- If the design source is found changed since STORY-049/STORY-056's last
  confirmed render, the design-side capture must be re-rendered rather than
  reused, and the fresh render re-checked against the design canvas's
  `myUnsigned` branch string before treating it as the comparison target.
- If `flutter analyze` reports a new warning after the edit (e.g., an
  unused import), it must be cleaned up as part of this same story, not
  deferred.
- If regenerating `mobile/lib/l10n/generated/` surfaces any other stale
  generated string unrelated to this key, it must not be corrected here —
  only `loveContractAddClauseAction`'s regenerated output is in scope; an
  unrelated stale string is a new finding.

## Acceptance Criteria

1. Given `mobile/lib/l10n/arb/app_vi.arb`'s `loveContractAddClauseAction` key
   (currently `"+ Thêm điều khoản riêng"` at line 700), when corrected, then
   its value reads `"+ Thêm điều khoản của riêng tụi mình"`, matching the
   design canvas's `myUnsigned` branch verbatim, with the key name and
   `@loveContractAddClauseAction` description unchanged and `app_en.arb`'s
   sibling value untouched.
2. Given the AC-1 value change, when `mobile/lib/l10n/generated/` is
   regenerated via the standard Flutter l10n codegen step, then the
   generated output reflects the new string and no generated file is
   hand-edited.
3. Given
   `mobile/test/features/love_contracts/presentation/screens/love_contract_screen_fidelity_test.dart:223`,
   when the ARB value changes, then its expected-string literal is updated
   to `'+ Thêm điều khoản của riêng tụi mình'` and the test (including its
   existing no-duplicate-icon assertion) passes.
4. Given the AC-1 corrected string, when a fresh implementation-side
   `contract` capture (`requesterUnsigned` state) is taken and paired with
   the existing (or re-rendered, if stale) `myUnsigned` design reference,
   then this story's own `visual-fidelity/visual-fidelity-report.md` records
   a `MATCH` verdict for the add-clause row text and states that it closes
   RWB-20260816-025.
5. Given this story's scope, when `flutter analyze` and the existing
   `flutter test` suite are run, then both pass clean with no new warnings,
   errors, or failing tests attributable to this story's changes.
6. Given a user already on the existing Love Contract screen (no new
   navigation added by this story), the actor reaches the corrected label
   through the existing unchanged entry point.

## Dependencies

- Depends on: NONE. Independent of every other REQ-002 story; must not
  reopen the closed git boundary/branch of STORY-015, STORY-039,
  STORY-046, STORY-049, or STORY-056.
- Must not require any future story: confirmed — this closes
  RWB-20260816-025 within this story's own scope.

## Assumptions (only if needed)

- The file paths and line numbers verified in `## In Scope` were current at
  the time of this scoping pass (2026-08-19); if a concurrent change has
  since shifted a line number, the implementer locates the same
  `loveContractAddClauseAction` key/value and the same test literal by
  content, not by a stale line number.

## Open Question Impact

No open question touches this story's scope — it is a `vi`-locale string
correction with no OQ dependency (OQ5 covers light theme / `en` locale,
neither of which this story changes).

### Scope Items BLOCKED in this story

- None.

### Scope Items NOT BLOCKED in this story

- All acceptance criteria (1-6) are unblocked.
