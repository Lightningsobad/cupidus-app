# Story Requirements: STORY-056 Contract Evidence State Realignment

## Source Artifacts

- Requirement master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/req_master.md`
- Story master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-056_contract_evidence_state_realignment/story_master.md`
- Additional input files: `data/retro-audit/rework-backlog.md` item
  RWB-20260816-023 (source finding, already extracted into story master's own
  `## Background (Rework Item)`); STORY-046's `review/review-report.md` cycle
  2, finding DEF-2 (the finding that opened this item); STORY-049's own
  `story_master.md` `## Mobile Implementation` D-10 write-up (proves the
  design canvas's signed branch is unreachable — see story master's
  `## Product Owner Triage`).

## Business Summary

- Primary actor: none directly — this is an evidence-correctness hardening
  item; the requesting party is the REQ-002 design-fidelity audit trail (via
  RWB-20260816-023).
- Problem to solve: STORY-046's own `contract` rendered-evidence pair
  compares two different app states — the implemented capture shows the
  `partnerAlreadySigned` state, the design reference shows the canvas's
  unsigned/pre-signature state — so its AC3 content-column `MATCH` verdict
  rests on structural correspondence only, not a genuine same-state visual
  comparison.
- Business outcome: the `contract` screen has a real same-state
  design-vs-implementation content/layout comparison on record, closing
  RWB-20260816-023, without reopening or changing the outcome of STORY-015,
  STORY-039, or STORY-046 (all remain `DONE`, none are touched).
- Success signal: this story's own `visual-fidelity/visual-fidelity-report.md`
  records a same-state `contract` pair (both sides in the unsigned state) and
  a fresh `MATCH`/`DEVIATION` verdict for header band, clause rows, divider,
  CTA/hold-to-sign affordance, and encryption footer.
- Complexity: trivial (routing rule: no new screens, no new UX decisions, no
  new architecture decisions, single implementation lane, no
  `mobile/lib/**` production file touched).
- Why this complexity: the remediation is either reusing an existing evidence
  pair (STORY-049's) as-is or reproducing it with already-proven tooling and
  an already-existing fixture (`main_preview.dart`'s
  `PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned` case, added by STORY-049).
  No new design decision, no new code path, and only the `mobile` lane —
  same trivial classification basis already applied to STORY-047/049/050 in
  this same rework series.
- Primary implementation lane: mobile (single lane; evidence artifacts only).

## Scope Decision

### In Scope

1. Establish a genuine same-state `contract` evidence pair (both sides in
   the unsigned/pre-signature state — Vietnamese clause copy, the
   "+ Thêm điều khoản của riêng tụi mình" add-clause affordance, no
   signature line) and file it in this story's own `visual-fidelity/`
   directory:
   - Design side: reuse
     `STORY-049_contract_unsigned_state_render_coverage/visual-fidelity/design-reference-contract-myunsigned-android.png`
     as-is if the `contract` design source is confirmed unchanged since that
     render, otherwise re-render via the sanctioned
     `render-design-canvas.js --screen=contract` invocation STORY-046 already
     used.
   - Implementation side: reuse
     `STORY-049_contract_unsigned_state_render_coverage/visual-fidelity/implemented-contract-requesterunsigned-emulator-5560.png`
     as-is if the `contract` screen source is confirmed unchanged since that
     capture, otherwise re-capture with
     `--dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned` (the
     fixture STORY-049 already added to `main_preview.dart` — no fixture
     change needed).
   - Do not attempt to re-render the design reference in a signed state:
     STORY-049's own D-10 finding already confirmed the canvas's `mySigned`
     branch is unreachable (two `--click` attempts on the hold-to-sign
     control produced output byte-identical to the unclicked baseline).
2. Using that same-state pair, re-run the `contract` content/layout
   comparison DEF-2 flagged as unverified in a matched state — header band,
   clause rows, divider, CTA/hold-to-sign affordance, encryption footer —
   and record a fresh per-element `MATCH`/`DEVIATION` verdict in this
   story's own `visual-fidelity/visual-fidelity-report.md`, explicitly
   naming that it supersedes STORY-046's AC3 content-column verdict for
   `contract` (a mismatched-state comparison) and closes RWB-20260816-023.
3. Reuse the file-naming and `VISUAL_FIDELITY: PASS/FAIL` reporting
   convention already established in
   `STORY-046_shared_backdrop_occlusion_hardening/visual-fidelity/visual-fidelity-report.md`
   and `STORY-049_contract_unsigned_state_render_coverage/visual-fidelity/visual-fidelity-report.md`
   so the evidence is directly comparable to both.

### Out of Scope

- Any `mobile/lib/**` production file change. No shipped app behavior is
  modified by this story.
- Any change to `mobile/lib/main_preview.dart` — the `requesterUnsigned`
  fixture this story depends on already exists (added by STORY-049).
- Reopening or editing the closed git boundary/branch of STORY-015,
  STORY-039, or STORY-046. Their `DONE` status and their own recorded
  verdicts are unchanged by this story.
- Re-attempting a signed-state design-canvas render (already proven
  unreachable by STORY-049's D-10 finding).
- Any content, layout, spacing, typography, or component-level fidelity
  change to the `contract` screen — this story only re-verifies against an
  existing screen state, it does not correct any newly found deviation. If a
  genuine new deviation surfaces during the AC-2 comparison, record it as a
  new finding and do not silently expand this story's scope to fix it.
- RWB-20260816-024 (DEF-3, `joincode` and related structural deviations) —
  already routed separately to `STORY-047_pairing_chain_deviation_triage`,
  not this story.

## System Integration And Discoverability

- UI-facing story: NO — evidence/documentation artifacts only, no app-facing
  change.
- Existing user-visible surface: N/A — the `contract` screen's existing
  reachability, navigation, and behavior are unchanged.

## Business Rules And Guardrails

- The same-state pair must have both sides in the same sign-status state;
  a pair where the two sides depict different states must not be recorded
  as a `MATCH` on content/layout.
- If reusing STORY-049's evidence pair, confirm (and record how it was
  confirmed) that the `contract` screen's source and the design source are
  both unchanged since that capture before treating it as current evidence.
- If a genuine new deviation is found during the AC-2 re-comparison (not
  the state-mismatch DEF-2 already named), record it as a new finding and do
  not silently expand this story's scope to fix it.

## Acceptance Criteria

1. Given the `contract` screen's implemented capture and its design
   reference, when this story files its own `visual-fidelity/` evidence,
   then both sides depict the same sign-status state (the unsigned
   pre-signature state), either by reusing
   STORY-049_contract_unsigned_state_render_coverage's existing pair
   as-is (after confirming the `contract` source is unchanged since) or by
   producing a fresh pair with the existing `requesterUnsigned` fixture and
   the existing design-canvas render tooling — with no attempt to re-render
   the design reference in a signed state, since STORY-049's D-10 finding
   already proved that state unreachable.
2. Given the AC-1 same-state pair, when the `contract` content/layout is
   re-compared, then this story's own
   `visual-fidelity/visual-fidelity-report.md` records a fresh
   `MATCH`/`DEVIATION` verdict for each of: header band, clause rows,
   divider, CTA/hold-to-sign affordance, encryption footer — explicitly
   noting that this supersedes STORY-046's AC3 content-column verdict for
   `contract` and closes RWB-20260816-023.
3. Given this story's scope, when it is delivered, then no `mobile/lib/**`
   production file and no `mobile/lib/main_preview.dart` fixture is changed
   — only this story's own `visual-fidelity/` evidence directory and its own
   `story_master.md`/`requirements/requirements.md` are written.

## Dependencies

- Depends on: NONE. Independent of every other REQ-002 story; must not
  reopen the closed git boundary/branch of STORY-015, STORY-039, or
  STORY-046.
- Must not require any future story: confirmed — this closes
  RWB-20260816-023 within this story's own scope.

## Open Question Impact

No open question touches this story's scope — it is a same-state
evidence-pair correctness fix with no OQ dependency.

### Scope Items BLOCKED in this story

- None.

### Scope Items NOT BLOCKED in this story

- All acceptance criteria (1-3) are unblocked.
