---
story_status_recommendation: "IN_PROGRESS"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-08-24
reviewed_by: Reviewer
---

# Review Report: STORY-001 Invite Couple-Type Picker

Outcome: PATCH_REQUIRED

## Scope Gate

- Review type: `compact-story-review`
- Source/test files in scope (6): `mobile/lib/features/pairing/presentation/couple_type.dart`,
  `mobile/lib/features/pairing/presentation/invite_cubit.dart`,
  `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`,
  `mobile/lib/main_preview.dart`,
  `mobile/test/features/pairing/presentation/invite_cubit_test.dart`,
  `mobile/test/features/pairing/presentation/invite_screen_test.dart`
- Evidence files in scope: `coding-plan/test-results.md`,
  `coding-plan/phase-P1-couple-type-picker.md`, `architecture/solution.md` §4/§6,
  `ux/ux-spec.md` §6.7/§6.8, `data/devops/system/design-fidelity-config.json`
- Focused query keys: AC1-AC7, `_emitReady`, `submitCoupleType`, `_wireCoupleType`,
  `_CoupleTypeCell`, `coupleTypeFromWire`, `design_source`, `Entry Point Reachability`
- Diff baseline: `git -C <worktree> diff 90f531f1` (14 files, +2099/-19)

## Reviewed Inputs

- Review gate: `compact-story-review`
- Scope Gate: `inline`
- Requirements: `story_master.md` AC1-AC7, `requirements/requirements.md` catalog
- UX: `ux/ux-spec.md` §6.5, §6.7, §6.8
- Architecture: `architecture/solution.md` §4/§6, `architecture/contract-summary.md`
- Coding Plan: `coding-plan/master-plan.md`, `coding-plan/phase-P1-couple-type-picker.md`
- Test Results: `coding-plan/test-results.md`
- Previous review findings: `N/A`

## Reviewed Scope

- Story complexity: `standard`, lane `shared` (mobile-only in practice)
- Code scope reviewed: the 6 files above, read as diff against `BaseHead`
- Evidence reviewed: re-ran every reported gate independently (see below)
- Risk surfaces reviewed: typed/generated contract (wire enum), persistence,
  mobile interaction, mobile navigation/discoverability, app lifecycle (countdown
  re-emit), local design-token fidelity
- Mobile targeted verification gates: `PASS`
- Mobile discoverability/navigation integration: `PASS` (code-verified), evidence
  section missing — see F2
- Requirement mobile visual audit: `PATCH_REQUIRED` — see F1
- Story runtime startup smoke: `NOT_APPLICABLE` (mobile)
- Backend/Frontend gates: `NOT_APPLICABLE`
- OQ context reviewed: OQ5 non-blocking, consistent with REQ-002 precedent

## Independent Verification Performed

Not taken on trust — each command was re-run by the reviewer in the story worktree:

| Gate | Reviewer result |
| --- | --- |
| `flutter test test/features/pairing/` | `00:04 +126: All tests passed!` — matches |
| scoped `flutter analyze` (6 changed files) | `No issues found! (ran in 1.5s)` — matches |
| `flutter build apk --debug` | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` — matches |
| fontTools cmap re-lookup | `location_city 0xe7f1`, `auto_awesome 0xe65f`, `all_inclusive 0xeb3d` — byte-identical to the declared `IconData` constants |
| `design_system/` untouched | confirmed — the constants are file-local in `couple_type.dart:10-21` |

AC1-AC5 and AC7 assertions were read, not counted: the widget cases assert layout
order by `dx`/`dy`, `CupidPrimaryButton.onPressed == null`/`isNotNull` for gating,
`selected == true` cardinality across all four cards for single-select, the captured
save argument (`SAME_CITY` widget / `LIVING_TOGETHER` unit), pre-selection on the
first pump, and a real `JoincodeScreen` mount for AC7. `_emitReady`
(`invite_cubit.dart`) carries `selectedCoupleType`/`isSaving` forward from the
previous state, so the 30s tick cannot drop a selection — covered by a real
injected-`timerFactory` test. AC4 persistence is genuinely wired:
`InviteScreen._defaultInviteCubit` binds `saveCoupleType` to
`AccountRepository.updateProfile(coupleType:)` and `fetchCoupleType` to
`fetchProfile().coupleType`, with the generated `UpdateProfileDtoCoupleTypeEnum`
confined to that composition root.

## Outcome Summary

- Review outcome: PATCH_REQUIRED
- Rationale: the behavioural half of the story is well built and independently
  verified. AC6 is not satisfied and its exemption does not hold: a rendered
  design reference for this exact node exists in this repository and was never
  consulted or compared against.
- Blocking findings: 2
- Deferred findings: 2
- Dismissed observations: 1

## Blocking Findings

### F1 — AC6: the "no design source for this node" exemption is factually wrong

`ux/ux-spec.md` §6.8 and `phase-P1-couple-type-picker.md` §6 both assert that no
rendered design-source reference exists for the invite-screen couple-type cards,
and use that to exempt the story from the rendered visual-fidelity gate,
substituting widget-test finder assertions. That premise does not survive checking:

- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/design-reference-invite-android.png`
  is a rendered design reference of this screen **including** the couple-type
  section — heading "Tụi mình thuộc kiểu nào?", a 2x2 grid of four cards with a
  selected state, and the Continue CTA below.
- The node also still exists in the design bundle: `cupid-app-design-system/Cupid Screens.dc.html`
  contains "thuộc kiểu nào" (1 match). The configured entry `Cupid App.dc.html`
  contains 0 matches — which is why the node reads as "removed" when only the
  configured entry is checked. `Cupid Screens.dc.html` is not registered in
  `design-fidelity-config.json` `design_sources[]` at all, even though REQ-001's
  mobile references were captured from it.
- `design-fidelity-config.json` has `ui_surface: true` and a locked mobile
  `design_source`, so neither audited scope-out applies, and no
  `<story>/visual-fidelity/` directory exists for this story at all — no
  implemented capture, no reference, no `visual-fidelity-report.md`.

Reading the available reference against the built widget already shows visual
deltas that the finder assertions cannot detect: the reference puts each card's
glyph in a small rounded tile at the card's **top-left** with **left-aligned**
label and subtext, and carries a supporting line under the heading ("Cupid sẽ
bật/tắt tính năng phù hợp cho kiểu của bạn."). `_CoupleTypeCell`
(`invite_screen.dart:662-751`) renders a centered bare 28px glyph with
`textAlign: TextAlign.center` and no supporting line. This is design substance,
not copy.

Resolving which source is authoritative for this node is ui-ux-designer's job at
story setup, not the reviewer's — this report deliberately does not touch
`design-fidelity-config.json`. It routes the story back so that decision is made
by its owner with the evidence above on the table.

### F2 — Missing `## Entry Point Reachability` evidence section

`coding-plan/test-results.md` has no `## Entry Point Reachability` section with
`Reachable: YES` and a concrete path, which a UI-facing story requires. The entry
point itself is real and I verified it in code rather than assuming it: the story
adds content inside the existing `InviteReady` branch of an already-routed screen
(`OnboardingRouter` builder registry), the widget tests mount the real
`InviteScreen`, and the pre-existing pairing tests that prove reachability
("PairGateShell … reachable 'Pair with your partner' entry action", "renders both
entry actions under the pairing stack key", "the invite cross-link pushes invite")
all still pass. This is therefore a documentation gap on a verified-real entry
point, cheap to close while the story is back for F1.

## Deferred Findings

- D1 — Card 4 semantic drift ("Gắn bó lâu dài" → `LIVING_TOGETHER`) is properly
  recorded, not silently absorbed: `architecture/solution.md` §6 records it as
  ACCEPTED with an explicit REQ-009 follow-up, `story_master.md` repeats it, and
  `couple_type.dart:55-58` carries the rationale at the declaration. No action in
  this story; it becomes real only when couple-type is surfaced in the product.
- D2 — `InviteCubit.submitCoupleType()` returns `false` when `_saveCoupleType` is
  null, so any composition that omits the seam shows the retry snackbar rather
  than a no-op. Production wires the seam, so this is preview/test-only.

## Dismissed Observations

- Copy differences between the REQ-001 reference and the implementation ("Mới
  yêu"→"Mới hẹn hò", "Yêu lâu rồi"→"Gắn bó lâu dài", all four subtexts, and
  "Tiếp tục → Fingerprint Vow"→"Tiếp tục") are deliberate: the catalog is
  PO-authored in `requirements/requirements.md`, and the CTA destination is
  STORY-002's scope. Not defects.

## Implementation Action Items

- `[ui-ux-designer] ux/ux-spec.md` §6.8 + `data/devops/system/design-fidelity-config.json`:
  decide and record which design source is authoritative for the invite screen's
  couple-type node, given `Cupid Screens.dc.html` still contains it and
  `design-reference-invite-android.png` already renders it. Retract or re-justify
  the §6.8 exemption on that basis.
- `[mobile-dev] <story>/visual-fidelity/`: once the source is resolved, capture
  `implemented-invite-<device>.png`, place the matching
  `design-reference-invite-<device>.png`, and write `visual-fidelity-report.md`
  with the resolved `Design-Screen`, the per-state comparison, and a
  `VISUAL_FIDELITY:` verdict. Apply any layout deltas the comparison surfaces
  (icon tile + text alignment + supporting line are the known candidates).
- `[mobile-dev] coding-plan/test-results.md`: add the `## Entry Point Reachability`
  section with `Reachable: YES` and the concrete path.

## Workflow State Recommendation

- Story status: `IN_PROGRESS`
- `Implementation (Development)`: `KEEP_CHECKED` — the code gates all pass on
  re-run; the rework is design-fidelity resolution plus evidence, not a rewrite.
- `Review (Reviewer)`: `LEAVE_UNCHECKED`
- Next step: route to `ui-ux-designer` for the design-source decision, then
  `mobile-dev` for capture/compare and the reachability evidence section, then
  re-review.
- Note for Scrum Master: STORY-002's mobile-dev run also wrote
  `mobile/test/features/pairing/presentation/invite_screen_test.dart` on a sibling
  branch — expect a merge-time conflict on that file. Not a defect in this story.
- Note for Scrum Master: this report does not edit `story_master.md`. The handoff
  asked for the `Review (Reviewer)` status line, but the reviewer skill's output
  rules forbid the Reviewer modifying `story_master.md`; state updates are
  `scrum-master`-owned. The outcome is `PATCH_REQUIRED`, so that box stays
  unchecked either way.
- State update owner: `scrum-master` only.
