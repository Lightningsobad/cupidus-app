# Review Report — STORY-001 Invite Couple-Type Picker

- Reviewer: Iris-QC
- Mode: `compact-story-review` (cycle 3)
- Date: 2026-08-24
- Requirement: REQ-009_invite_couple_type_and_pairing_navigation
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-009_invite_couple_type_and_pairing_navigation-STORY-001_invite_couple_type_picker`
- Branch: `codex/REQ-009_invite_couple_type_and_pairing_navigation-STORY-001_invite_couple_type_picker`
- BaseHead: `90f531f1ec7e1b0960e000c2e27d45d1be7ad1ef` → HEAD `32e2391a63499fb60b2e1e61cc9368cc2ef9e58c`

Outcome: BLOCKED

## Scope Gate

- Review type: `compact-story-review`, re-review of cycle-2 findings F3/F4 plus full AC1-AC7 re-check.
- Source/test files in scope (6 changed under `mobile/`):
  `lib/features/pairing/presentation/screens/invite_screen.dart`,
  `lib/features/pairing/presentation/couple_type.dart`,
  `lib/features/pairing/presentation/invite_cubit.dart`,
  `lib/main_preview.dart`,
  `test/features/pairing/presentation/invite_screen_test.dart`,
  `test/features/pairing/presentation/invite_cubit_test.dart`.
- Evidence files in scope: `coding-plan/test-results.md`, `visual-fidelity/visual-fidelity-report.md`,
  `visual-fidelity/design-reference-invite-couple-type-android.png`, `ux/ux-spec.md` §6.5/§6.8,
  `story_master.md`, `data/devops/system/design-fidelity-config.json`.
- Query keys: F3 layout deltas 1-4, R1-R8, F4 §6.8 retractions, AC1-AC7, `## Entry Point Reachability`,
  `## Story Runtime Startup Smoke`, `VISUAL_FIDELITY:`, `ui_surface`, `design_sources[]`.
- Retro gate: `data/retro-audit/rework-backlog.md` has 0 `PENDING` / 0 `IN_PROGRESS` items — ordinary review permitted.

## Prior finding disposition

| Finding | Cycle-2 status | Cycle-3 verdict |
| --- | --- | --- |
| F3 — 4 confirmed AC6 layout deltas landed as evidence-only, no code change | BLOCKING | **RESOLVED** |
| F4 — 3 false statements in `ux-spec.md` §6.8 | BLOCKING | **RESOLVED** |

F3 verified against the diff, not the summary. All four deltas are real code in
`invite_screen.dart`: the supporting subtext `Text` exists in `_CoupleTypeSection`
(heading → `_coupleHeadingSubtextGap` 4 → subtext → `_coupleSubtextGridGap` 12 → grid);
the glyph is wrapped in a 38x38 `Container` at `:737-757` with `BorderRadius.circular(13)`,
`gradient: colors.gradientHot` selected / `color: colors.colorSurfaceAlt` unselected and
`_coupleIconSize = 21`, with state-driven glyph color (`colorOnAccent` / `colorTextMuted`);
the cell `Column` carries `crossAxisAlignment: CrossAxisAlignment.start` at `:735` with no
`textAlign` on either `Text`; cell padding is `vertical: CupidSpacing.md` / `horizontal:
_coupleCellHorizontalPadding` (14). R1/R2/R3/R6 and both heading gaps are transcribed as the
named literals. R4/R5/R7/R8 carry accepted-deviation rationale that is now stated identically
in the build, `ux-spec.md` §6.8, and the visual-fidelity report — the cycle-2 spec/build
contradiction is gone.

F4 verified by direct read. `ux-spec.md:205-223` carries an explicit
`Retraction (PATCH_REQUIRED F4)` paragraph withdrawing both the `design_sources[]`
registration claim and the DevOps-dependency claim; the render command at `:249` is corrected
to `--entry='Cupid App.dc.html' --screen=invite`. I independently confirmed the retraction is
factually right: `data/devops/system/design-fidelity-config.json` `design_sources[]` holds
exactly `cupid-app` and `cupid-web`, no `cupid-screens`. R1/R2 corrections did land this time
(`:260` icon-tile→label 10px, `:266` alpha 0.22/0.22).

## Acceptance criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 four cards in catalog order between code card and CTA | PASS | `invite_screen_test.dart` `AC1:` — re-run by Reviewer, green; now also asserts subtext ordering and shared left edge |
| AC2 CTA disabled at 0 selections | PASS | widget `AC2:` + cubit no-op case |
| AC3 single-select, second tap swaps | PASS | widget `AC3:` + cubit replace case |
| AC4 Continue persists to `CupidProfile.coupleType` | PASS | widget `AC4:` (`SAME_CITY`) + cubit submit case (`LIVING_TOGETHER`) |
| AC5 persisted value pre-selected on first paint | PASS | widget `AC5:` + cubit first-ready case |
| AC6 matches the design reference with no visible deviation | **UNVERIFIABLE** | see B1 — no rendered implemented-side image exists |
| AC7 joincode carries no picker | PASS | widget `AC7:` |

Tests independently re-run by Reviewer in the story worktree (not trusted from the report):

- `flutter test test/features/pairing/presentation/invite_screen_test.dart` → `+16 All tests passed!`
- `flutter test test/features/pairing/presentation/invite_cubit_test.dart` → `+17 All tests passed!`
- `flutter test test/design_system/no_fork_guard_test.dart` → `+1 All tests passed!`
- `flutter analyze` over the 4 touched `lib/` files → `No issues found!`

## Touched risk surfaces and critical gates

| Surface | Gate | Status |
| --- | --- | --- |
| Mobile interaction (selection state machine) | targeted widget + cubit tests | PASS |
| Typed/generated contract (`UpdateProfileDtoCoupleTypeEnum` mapping) | `every wire value exists in the generated client enum` guards `_wireCoupleType`'s `firstWhere` | PASS |
| Design-system integrity | `no_fork_guard_test.dart` re-run after new token lookups | PASS |
| Mobile navigation/discoverability | `## Entry Point Reachability`, `Reachable: YES`; chain re-verified in code (`pair_gate_shell.dart:139` → `pairing_choice_screen_test.dart:46-66` → real `InviteScreen`) | PASS |
| Mobile design fidelity (12e2/12e3/12g2) | implemented-side device capture | **BLOCKED — B1** |
| App lifecycle / runtime startup (12g) | `## Story Runtime Startup Smoke` | **BLOCKED — B2** |

Configuration-guide verification: not applicable — no setup, env var, external integration, or
runtime-configuration surface is touched by this story.

## Blocking findings

### B1 — `VISUAL_FIDELITY: PASS` is recorded with no implemented-side image

`visual-fidelity/` contains exactly two files: `design-reference-invite-couple-type-android.png`
and `visual-fidelity-report.md`. There is no `implemented-invite-couple-type-android.png`. The
report states `VISUAL_FIDELITY: PASS` at line 11 and again at line 136, while line 38 records
`DEVICE_CAPTURE_BLOCKED` and line 44 states plainly that "the implemented side is compared from
source and from widget-test geometry assertions, not from a device screenshot."

I read the design reference: it is a real, correct image of this story's screen (invite screen,
`CPD-8F2K` code card, "Tụi mình thuộc kiểu nào?" heading, subtext line, 2x2 grid with card 2
selected). The design side is sound. The implemented side was never rendered, so no comparison
happened.

AC6's exact text is "when compared to the design reference, then it matches the design source
... with no visible deviation." Reading Dart constants cannot establish absence of *visible*
deviation — it cannot catch text overflow or wrapping in `vi` at real device width, `IntrinsicHeight`
row-height behaviour with uneven subtext lengths, glyph rasterisation inside the new 38x38 tile,
or the gradient/glow composite. Those are exactly the failure modes a picture catches and a
constant does not. Reviewer rule 12e3 is explicit that missing images under a `PASS` do not pass,
and the reviewer stop gate and the DONE gate both enforce the rendered verdict independently, so
a passing outcome here would be rejected regardless of my judgment.

Neither audited scope-out applies: `design-fidelity-config.json` has `ui_surface: true` and a
configured, locked `design_source` (`cupid-app`, `surface: "mobile"`).

Separately, and fixable in-lane regardless of the device: the `PASS` token itself should not be
written for a comparison that did not occur. The honest verdict for this artifact today is a
blocked/undetermined one, not `PASS`. The per-state tables are good work and should be kept — it
is only the top-level verdict line that overstates them.

### B2 — mandatory story runtime startup smoke is absent

Reviewer rule 12g makes registry-backed runtime startup smoke a mandatory story-level gate for
every non-trivial story on the `frontend`, `shared`, `backend`, or `mobile` lane. This story is
`Complexity: standard`, `Implementation Lane: shared`, with all real work on the mobile lane.
`coding-plan/test-results.md` has no `## Story Runtime Startup Smoke` section (sections present:
1 Icon Codepoint, 2 Static Analysis, 3 Targeted Tests, 4 Build, 5 Coverage, Visual Fidelity,
Entry Point Reachability, 6 Files Changed, PATCH_REQUIRED F3/F4 Rework), and `story_master.md`
records no `Runtime-Smoke: WAIVED — <reason>` line.

For a mobile story the smoke is that the app launches on the device/emulator and reaches its
first screen without a crash or error screen. `flutter build apk --debug` (section 4) proves the
APK assembles; it does not prove the app boots. This gate was not raised in cycles 1 or 2, but
the DONE gate enforces it independently, so it would fail closure now even if I passed the story.

## Why BLOCKED rather than PATCH_REQUIRED

B1 and B2 have the same single root cause — no usable device/emulator, per the known storage
constraint recorded as under DevOps remediation — and that cause sits outside the implementation
lane. Reviewer rules 12c and 12g both direct `BLOCKED` when an environment prevents a critical
gate, rather than `PATCH_REQUIRED`. Routing this back to mobile-dev as a patch would ask a lane
that structurally cannot capture a device screenshot or launch an emulator to produce exactly
those two artifacts, which yields cycle 4 returning the same two findings. The decision that
actually unblocks this story — remediate the emulator, or record an explicit, owned waiver — is
Scrum Master's, not mobile-dev's.

One caveat worth stating: the emulator constraint was carried forward from an earlier pass and
explicitly "not retried" this cycle, so nobody has confirmed it is still present. It may already
be resolved.

## Action items

- **[devops]** Remediate the emulator storage constraint, or confirm whether it still exists —
  it has not been retried since it was first recorded.
- **[mobile-dev]** Once a device/emulator is available: capture
  `visual-fidelity/implemented-invite-couple-type-android.png` for the invite screen, compare it
  against the existing design reference, and record the per-state result (default, one-selected,
  pre-filled) against the design reference.
- **[mobile-dev]** Add `## Story Runtime Startup Smoke` to `coding-plan/test-results.md` with the
  app launching on the device and reaching its first screen without a crash or error screen.
- **[mobile-dev]** Correct `visual-fidelity-report.md`'s two `VISUAL_FIDELITY: PASS` lines (11 and
  136) so the verdict does not assert a comparison that has not happened. Keep the per-state
  tables and the accepted-deviation list — both are sound and re-usable once the capture exists.
- **[scrum-master]** If the emulator cannot be remediated in a reasonable window, this needs an
  explicit owned decision (a recorded `Runtime-Smoke: WAIVED — <reason>` and a design-fidelity
  disposition), not a silent carry-forward. That is a user-facing call.

## Deferred findings

- **D1** — Card 4 "Gắn bó lâu dài" maps to the existing `LIVING_TOGETHER` wire value; accepted
  semantic drift already recorded as a REQ-009 follow-up in `architecture/solution.md` §6.
  Carried forward unchanged from cycles 1 and 2.
- **D2** — In Scope item 5 (design-system node for the cards) was not done: the 3 new `IconData`
  constants stay file-local because the phase write scope excludes `mobile/lib/design_system/`,
  as `phase-P1-couple-type-picker.md` directs. Carried forward unchanged.

## State recommendation

implementation_status_recommendation: UNCHECK is NOT required — the F3/F4 code rework is complete
and correct, and every code-level gate passes. The two open items are missing device-dependent
evidence, not defective code.

- `Implementation (Development)`: KEEP CHECKED
- `Review (Reviewer)`: leave unchecked
- Story status: **BLOCKED**

REVIEW_COMPLETE
