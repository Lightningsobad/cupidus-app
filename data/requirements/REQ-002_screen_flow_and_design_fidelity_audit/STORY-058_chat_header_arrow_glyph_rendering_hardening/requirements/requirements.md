# Story Requirements: STORY-058 Chat Header Arrow Glyph Rendering Hardening

## Source Artifacts

- Requirement master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/req_master.md`
- Story master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-058_chat_header_arrow_glyph_rendering_hardening/story_master.md`
- Additional input files: `data/retro-audit/rework-backlog.md` item
  RWB-20260816-026 (source finding, already extracted into story master's own
  `## Background (Rework Item)`);
  `STORY-052_chat_header_partner_presence_hardening/review/review-report.md`
  §4 ("Disposition of D-1 / F3") and §5 (deferred findings table, D-1/D-S1
  rows) — the surfacing reviewer's full root-cause and disposition reasoning,
  summarized in story master;
  `STORY-052_chat_header_partner_presence_hardening/visual-fidelity/visual-fidelity-report.md`
  §4 (D-1 deviation detail) and §7 line 317 (the D-S1 stale claim);
  `mobile/lib/features/chat/presentation/chat_strings.dart:46-78`
  (`headerPairingTitle`/`headerPairingSemanticLabel`/`_joinPair`, including
  the in-code dartdoc recording the reverted VS15 attempt);
  `mobile/lib/design_system/adaptive/cupid_header.dart` (the shared header
  widget, both `_IosHeader`/`_MaterialHeader` title rendering);
  `mobile/lib/features/chat/presentation/screens/chat_screen.dart:166-183`
  (the header call site); `mobile/pubspec.yaml:104-115` (bundled font
  families, confirming an icon-font precedent already exists via
  `Material Symbols Rounded`/`CupidIcons`) (all confirmed current at time of
  scoping).

## Business Summary

- Primary actor: none directly — this is a rendering-fidelity hardening
  item; the requesting party is the REQ-002 design-fidelity audit trail (via
  RWB-20260816-026).
- Problem to solve: the `chat` screen header's pairing-title separator glyph
  (U+2194, `↔`) renders as a coloured emoji tile on the audited Android
  device/font stack, where the locked design source specifies a thin
  monochrome arrow matching the header's single-weight typography — a
  disclosed, previously-untried-to-completion defect (one remedy attempt was
  tested and disproved) blocked from an in-story fix by STORY-052's own
  governing `ux/uiux-spec.md` §1.2 fence.
- Business outcome: the header's separator glyph renders as plain monochrome
  text matching the design source, without regressing any of `CupidHeader`'s
  other 16 existing consumers, closing RWB-20260816-026 (STORY-052 review
  finding D-1) without reopening STORY-018, STORY-040, or STORY-052.
- Success signal: a fresh device capture of the `chat` header shows the
  separator glyph as plain monochrome text, not a coloured tile; the fix's
  approach (glyph choice / font-fallback / structural) is recorded with an
  explicit decision by UI/UX Designer and Tech Lead; this story's own
  `visual-fidelity/visual-fidelity-report.md` records a `MATCH` for that
  glyph and states it closes RWB-20260816-026.
- Complexity: standard (routing rule: this story carries at least two live
  UX/architecture decisions — whether the remedy touches the fenced title
  style block, and which concrete remedy to use among glyph swap, font
  fallback, or a structural icon-based title — so it cannot bypass UX/Tech
  Lead).
- Why this complexity: `.claude/skills/product-owner/references/complexity-routing.md`
  classifies a story as `standard` when it needs a new UX decision or a new
  architecture decision. This story has both: UI/UX Designer must decide
  whether the design-fidelity-faithful remedy changes the separator glyph
  itself or only its font presentation, and whether that requires an
  explicit exception to the existing fenced style block; Tech Lead must
  decide the concrete mechanism (font-fallback declaration vs. restructuring
  `CupidHeader.title` into a mixed text/icon composition) and its
  backward-compatibility contract across the shared component's 17 call
  sites. Per the routing reference's Lane Consistency Rule, any story with a
  live UX or architecture decision uses `Implementation Lane: shared`, even
  though only `mobile-dev` ultimately writes code.
- Primary implementation lane: shared (UI/UX Designer decision, then Tech
  Lead component/font-contract decision, then `mobile-dev` implementation;
  no backend or other lane is touched).

## Scope Decision

### In Scope

1. Investigate and resolve why the chat header's pairing-title separator
   glyph (U+2194, `↔`) renders as a coloured emoji tile on the audited
   Android device/font stack instead of the plain monochrome arrow the
   locked design source specifies, covering at minimum the five
   investigation questions captured in story master's `## Product Owner
   Triage` (VS15 failure mechanism / `fontFamilyFallback` viability;
   alternate-glyph viability; icon-asset/structural-title viability;
   whether the remedy touches the `ux/uiux-spec.md` §1.2 fenced style block;
   iOS-affected-or-not).
2. UI/UX Designer records the chosen remedy's design decision in this
   story's own `ux/uiux-spec.md`, including an explicit statement of whether
   the existing fenced title style block
   (`mobile/lib/design_system/adaptive/cupid_header.dart`'s
   `type.display`/`titleTextStyle` blocks) is left untouched, or changed
   with a named, reviewed exception.
3. Tech Lead records the chosen remedy's mechanism and component-contract
   impact (if any) in this story's own `architecture/solution.md`, including
   explicit confirmation that `CupidHeader`'s other 16 existing consumers
   (the list already enumerated in STORY-052's `story_master.md` `##
   Product Owner Triage`) are unaffected or, if the `title` contract shape
   changes, how backward compatibility is preserved for them.
4. Mobile implementation of the chosen remedy, touching only the files named
   in story master's `Write scope` line: `cupid_header.dart`,
   `chat_strings.dart`, and — only if the `title` contract shape changes —
   `chat_screen.dart`'s header call site and
   `mobile/test/design_system/adaptive_widgets_test.dart`.
5. Update the existing separator-glyph literals/assertions in
   `mobile/test/features/chat/presentation/chat_design_fidelity_test.dart`
   (currently lines 521-526, 653, 667, 677) to match whatever glyph the
   chosen remedy ships, keeping the existing pairing-format, degradation,
   and semantic-label assertions intact.
6. Produce a fresh implementation-side `chat` header capture on the same
   audited configuration (Android, dark theme, `vi` locale) that STORY-052
   used, pair it with the existing (or freshly re-confirmed, if the design
   source is found stale) `chat` design reference, and record a
   glyph-specific `MATCH`/`DEVIATION` verdict in this story's own
   `visual-fidelity/visual-fidelity-report.md`, stating that it closes
   RWB-20260816-026.
7. Fold in the D-S1 doc-correction: correct the single stale line at
   `STORY-052_chat_header_partner_presence_hardening/visual-fidelity/visual-fidelity-report.md`
   §7 (currently line 317, `Runtime startup smoke | — | NOT_APPLICABLE per
   data/devops/system/runtime-command-registry.json (mobile-app)`) to state
   that the real runtime-smoke evidence is in that story's own
   `coding-plan/test-results.md` `## Story Runtime Startup Smoke` section
   (currently line 428). No other line, section, or file in STORY-052's
   directory is touched.
8. `flutter analyze` and the existing `flutter test` suite pass clean after
   the change (no new unused-import/unused-variable warnings, no unrelated
   test regressions).

### Out of Scope

- Reopening or editing the closed git boundary/branch of STORY-018,
  STORY-040, or STORY-052.
- Any change to the partner-pairing/self-display-name data sourcing,
  presence-chip content, or presence-chip accessibility label — STORY-052
  already delivered and proved these; not reopened here.
- Wiring the fixed title-rendering approach into any `CupidHeader` consumer
  other than `chat` — the other 16 consumers must render unchanged, not
  gain a new capability.
- Any other visible difference between the design reference and the
  implementation already dispositioned by STORY-052's own
  `visual-fidelity-report.md` §4/§5 (D-2 through D-5, expected/intentional)
  or §5's pre-existing-difference table — not re-litigated here.
- A new real-time/backend presence feature — untouched, out of scope,
  already the case in STORY-052.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet; same precedent exclusion as every other REQ-002
  hardening story).
- Any new screen, new navigation entry point, or new interaction.

## System Integration And Discoverability

- UI-facing story: YES (one existing screen, one existing header element;
  no new UI surface).
- Existing user-visible surface, workflow, or state where the actor starts:
  the `chat` screen's existing header, reached through the existing chat
  navigation path — unchanged by this story.
- Required entry point, navigation item, CTA, or in-flow discovery path:
  unchanged; this story only corrects how one glyph renders.
- Direct URL only acceptable: N/A — existing reachable screen, not new.
- Which screen of the design source this story covers: `chat`, the shared
  header's pairing-title separator glyph — already confirmed/recorded by
  STORY-018/STORY-040/STORY-052.
- Existing user journey affected: none — the chat flow keeps its existing
  order and behavior; only the separator glyph's rendering changes.
- Out-of-scope integration surfaces: any screen other than `chat`; any of
  `CupidHeader`'s other 16 consumers; any navigation, persistence, or
  backend surface (this is a pure rendering-fidelity fix).

## Business Rules And Guardrails

- The chosen remedy must not re-attempt the disproven bare-string U+FE0E
  (VS15) fix without a materially new mechanism (for example a
  `fontFamilyFallback` declaration alongside it) — STORY-052 already fully
  tested, disproved, and reverted that exact attempt.
- The chosen remedy must not alter `CupidHeader`'s existing `onBack`,
  `backLabel`, `actions`, or `trailing` contract, and any change to `title`
  or `titleSemanticLabel` must keep a safe (no-visible-change) default for
  the other 16 existing consumers.
- If the remedy touches the fenced style block named by STORY-052's
  `ux/uiux-spec.md` §1.2, this story's own `ux/uiux-spec.md` must record
  that exception explicitly — not a silent edit — naming exactly what
  changed and why it is safe for the other 16 consumers.
- If UI/UX Designer selects a different separator glyph (rather than a
  font-fallback/rendering-only fix), the accessible/semantic substitution
  behavior in `headerPairingSemanticLabel` (dropping the visual glyph in
  favor of "và"/"and", `chat_strings.dart:63-71`) must still hold — the
  assistive-tech announcement must not regress to reading a meaningless
  glyph name.
- The D-S1 doc-correction (AC6 below) may change only the one named line in
  STORY-052's `visual-fidelity-report.md` §7 — no other content in that
  story's directory is in scope.
- If the AC4 comparison surfaces any deviation beyond the now-corrected
  separator glyph, record it as a new finding and do not silently expand
  this story's scope to fix it.

## User Story

As a user viewing the chat screen's header in the audited Vietnamese/dark
configuration,
I want the pairing title's separator to render as the plain, single-weight
arrow the design specifies,
So that the header's typography matches the confirmed design source instead
of showing an unintended coloured emoji tile.

## Edge Cases And Failure Behavior

- If the design source is found changed since STORY-052's last confirmed
  `chat` header render, the design-side capture must be re-rendered rather
  than reused, and re-checked against the design canvas before treating it
  as the comparison target.
- If the chosen remedy requires restructuring `CupidHeader.title` from a
  `String` into a widget/mixed-content shape, every one of the other 16
  existing consumers must be proven unchanged (equivalent to STORY-052's
  Material tree-identity approach for its own `trailing` slot), not merely
  asserted.
- If iOS is found to share the same emoji-tile defect during investigation,
  the remedy must not fix Android while silently leaving iOS in a worse or
  unverified state; if iOS is out of this story's verification scope, that
  must be stated explicitly, not left ambiguous.
- If `flutter analyze` reports a new warning after the change (e.g., an
  unused import), it must be cleaned up as part of this same story, not
  deferred.

## Acceptance Criteria

1. Given the chat screen header rendered on the audited Android
   device/font stack (dark theme, `vi` locale), when the pairing title's
   separator glyph is inspected, then it renders as a plain, single-weight,
   monochrome text glyph matching the header's existing typography — not a
   coloured emoji tile — closing RWB-20260816-026 / STORY-052's D-1 finding.
2. Given the resolved rendering fix, when compared against the existing
   fenced title style block named by STORY-052's `ux/uiux-spec.md` §1.2
   (`cupid_header.dart`'s title `TextStyle`/`titleTextStyle`), then either
   (a) that style block is left byte-unchanged because the fix is
   glyph-choice or font-fallback-only, or (b) it is changed with an
   explicit, UI/UX-Designer-reviewed exception recorded in this story's own
   `ux/uiux-spec.md`, naming exactly what changed and confirming it is safe
   for `CupidHeader`'s other 16 consumers — the choice between (a) and (b)
   is UI/UX Designer's and Tech Lead's decision.
3. Given the shared `CupidHeader` component, if its title-rendering
   contract changes to resolve AC1, then every one of the other 16 existing
   `CupidHeader` consumers (the list in STORY-052's `story_master.md` `##
   Product Owner Triage`) continues to render exactly as before — no
   visible regression — proven by test coverage; if the contract does not
   change, this AC is satisfied by that fact alone (no new regression risk
   introduced).
4. Given the AC1 fix, when a fresh implementation-side `chat` header
   capture is taken on the audited configuration (Android, dark theme, `vi`
   locale) and paired with the existing (or freshly re-rendered, if stale)
   `chat` design reference, then this story's own
   `visual-fidelity/visual-fidelity-report.md` records a `MATCH` verdict for
   the separator-glyph rendering specifically and states that it closes
   RWB-20260816-026.
5. Given this story's touched scope, when `flutter analyze` and the
   existing `flutter test` suite (including
   `chat_design_fidelity_test.dart` and, if touched,
   `adaptive_widgets_test.dart`) are run, then both pass clean with no new
   warnings, errors, or failing tests attributable to this story's changes.
6. Given `STORY-052_chat_header_partner_presence_hardening`'s
   `visual-fidelity/visual-fidelity-report.md` §7 stale line recording
   `Runtime startup smoke | — | NOT_APPLICABLE per
   data/devops/system/runtime-command-registry.json (mobile-app)`, when
   corrected, then that single line instead states the real runtime-smoke
   evidence lives in that story's own `coding-plan/test-results.md` `##
   Story Runtime Startup Smoke` section — closing D-S1 — with no other line
   or file in STORY-052's directory touched.
7. Given a user already on the existing chat screen (reached through its
   existing unchanged navigation path), the actor sees the corrected glyph
   rendering with no new entry point or navigation change required by this
   story.

## Dependencies

- Depends on: NONE. Independent of every other REQ-002 story; must not
  reopen the closed git boundary/branch of STORY-018, STORY-040, or
  STORY-052.
- Must not require any future story: confirmed — this closes
  RWB-20260816-026 within this story's own scope. If AC5's iOS-affected
  investigation question surfaces a real iOS-specific defect that is
  genuinely out of this story's verification scope, UI/UX Designer or Tech
  Lead may flag a follow-up item for Scrum Master rather than silently
  leaving it unrecorded — mirroring the precedent this story itself exists
  to fix (STORY-052's disclosed-but-unregistered D-1 finding).

## Assumptions (only if needed)

- The file paths and line numbers verified in `## In Scope` and story
  master's `Write scope` were current at the time of this scoping pass
  (2026-08-19); if a concurrent change has since shifted a line number, the
  implementer locates the same named function/literal by content, not by a
  stale line number.
- The audited device/font stack for this REQ's fidelity evidence is
  Android, dark theme, `vi` locale, matching every prior REQ-002 hardening
  story's evidence configuration; this story's own fresh capture uses the
  same configuration unless UI/UX Designer or Tech Lead's iOS investigation
  finds a reason to add a second configuration.

## Open Question Impact

No open question touches this story's scope — it is a rendering-fidelity
fix with no OQ dependency (OQ5 covers light theme / `en` locale, neither of
which this story changes).

### Scope Items BLOCKED in this story

- None.

### Scope Items NOT BLOCKED in this story

- All acceptance criteria (1-7) are unblocked.
