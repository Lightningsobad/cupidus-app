# Review Report: STORY-046 Hardening - Shared Screen Backdrop Occlusion Fix

Story: `REQ-002_screen_flow_and_design_fidelity_audit/STORY-046_shared_backdrop_occlusion_hardening`
Review type: `compact-story-review` (Tier 1), cycle 2 (re-review of an additive evidence patch)
Reviewer: Iris-QC
Date: 2026-08-18
BaseHead: `524434ca9a3e78b3f512f6a15c7eedc9f575165c`

Outcome: DEFERRED_ONLY

## Scope Gate

- Review type: `compact-story-review`; no separate `scope-gate.md` (skill rule 5a).
- Cycle 2 scope, per the Scrum Master continuation: re-verify **BLK-1, BLK-2,
  DEF-1 only**. Not re-verified (already CLEAN in cycle 1 and confirmed
  byte-identical by Scrum Master via `git status`/`git diff`): the 6 screen
  source edits, `shared_backdrop_occlusion_test.dart`, and the analyze/test
  evidence.
- Evidence files in scope: `visual-fidelity/visual-fidelity-report.md`
  (marker line + `## Rendered design-fidelity comparison`);
  all 12 PNGs in `visual-fidelity/`; `requirements/requirements.md`
  `## In Scope` item 3; `data/devops/system/design-fidelity-config.json`.
- Query keys: `VISUAL_FIDELITY`; per-screen Backdrop / Content-layout columns;
  AC7 vow hero-gradient compositing; `contract` A/B; DEF-1 reference provenance.
- Phase 2 proceeded.

## Outcome And Rationale

Both blocking findings from cycle 1 are discharged. The patch was additive
exactly as required — no source, probe test, or analyze/test evidence changed.
The story can close with deferred notes.

I opened all 12 PNGs rather than counting them (rule 12e3: counting files is
what the stop gate already does, and it is not review). All 12 are genuine
device/canvas renders of the correct screen — no placeholder, no error frame, no
spinner, no wrong-screen reference. The sky wash is visibly rendering on every
implemented capture, which is the delivered fix.

Three deferred findings are recorded. None is caused by this story, and one
(DEF-3) is a scoping caveat about how the `VISUAL_FIDELITY: PASS` on this story
should be read downstream. They belong to the requirement-level audit and to
other stories, not here — reviewer rule 7.

## Cycle 1 Blocking Findings — Both Resolved

### BLK-1 (rendered design-fidelity evidence) — RESOLVED

| Requirement | Status |
|---|---|
| Top-level `VISUAL_FIDELITY: PASS` line | Present, line 1 of `visual-fidelity-report.md` |
| 6x `implemented-<screen>-emulator-5560.png` | All present, all genuine renders |
| 6x `design-reference-<screen>-android.png` | All present, all genuine renders |
| Correct screen per pair | Verified by opening each pair; `otp`, `contract`, `profile`, `permissions`, `joincode`, `vow` each depict their own screen on both sides |
| `Design-Screen:` ids resolved and recorded | Yes (already satisfied in cycle 1) |
| Provenance | References rendered fresh via `render-design-canvas.js` against the locked source (`content_fingerprint: sha256:44c8b209…`, `locked: true`), using the config's own `location`/`entry`. No self-provisioned design source, no reuse of a possibly-stale earlier render |
| State reached by faking, not by driving | Yes — preview entrypoint plus `--dart-define=PREVIEW_PROFILE=fixture` / `PREVIEW_CONTRACT_SIGN_STATUS=partnerAlreadySigned`, captured via `capture-mobile-screen.sh`. No live navigation or player driving |

Rendering all 6 references fresh rather than copying was the right call beyond
what I asked for: it removes the stale/mis-scaled-reference failure mode that
STORY-045 actually hit, which the story's own carry-forward note warned about.

### BLK-2 (AC2-AC7 "content/layout unchanged" clause) — RESOLVED

The new `## Rendered design-fidelity comparison` section separates the Backdrop
column from the Content/layout/typography column per screen, which is the split
BLK-2 asked for. The decisive evidence is the pre-change A/B, because that is
the only control that isolates *this story's* effect:

- **AC7 `vow`** — checked twice, against the design reference and against
  `STORY-016_fingerprint_vow_design_fidelity/visual-fidelity/implemented-vow-emulator-5560.png`.
  I confirmed in the image: the `VowPalette.heroWash` radial gradient now
  composites over the sky wash rather than over the flat fill, and the eyebrow,
  two-line headline, subtitle, fingerprint disc, both initial avatars and their
  "đang đợi" labels are all in position at unchanged size. The compositing risk
  I raised in cycle 1 resolved in the direction of the reference, not away from
  it.
- **AC3 `contract`** — before/after A/B against
  `STORY-039_love_contract_design_fidelity_hardening/visual-fidelity/implemented-contract-emulator-5560.png`,
  confirming the change is backdrop-only on a second, card-heavy screen where a
  translucent card sits over the backdrop.
- **AC2, AC4, AC5, AC6** — per-screen rows with concrete element inventories; the
  implemented captures show those elements in the reference's positions.

## Deferred Findings

### DEF-1 — `requirements.md` still overstates reusable design references (owner: product-owner) — REMAINS DEFERRED

The *evidence* side is fully resolved: `contract`'s reference was rendered fresh,
and both `visual-fidelity-report.md` and `story_master.md` now say so. The
implementer routed around the bad instruction correctly.

The *artifact* is still wrong. `requirements/requirements.md` `## In Scope` item
3 lines 101-103 still read: "Existing design-reference renders for all 6 screens
(from STORY-007, STORY-009, STORY-010, STORY-012, STORY-015, STORY-016
respectively) are reusable as-is". `STORY-015_love_contract_design_fidelity/visual-fidelity/`
contains only `visual-fidelity-report.md` and no PNG, so that claim is false for
`contract` and would mislead the next reader who trusts it.

Keeping this deferred rather than closing it, per the Scrum Master's explicit
option. Non-blocking: it cannot affect this story's delivered outcome. Correct
the sentence when `requirements.md` is next touched.

### DEF-2 — the `contract` pair compares mismatched states (owner: product-owner / requirement-level audit)

Undisclosed by the report and found by opening the images. The implemented
`contract` capture is the `partnerAlreadySigned` state with English fixture
clause text ("Always tell the truth", "Don't sleep angry", "Check in once a day",
"Say sorry first, argue about it later"), a "2/20 điều khoản" counter and a
"Minh Anh đã ký, đến lượt bạn" line. The design reference depicts a different
state: Vietnamese clause copy ("Không giận quá 24 giờ", …), a
"+ Thêm điều khoản của riêng tụi mình" affordance, and no signature line.

So the AC3 row's `MATCH` on the content column rests on structural
correspondence (header band, clause rows, divider, CTA, encryption footer), not
on a same-state comparison. That does not change this story's outcome, because
the STORY-039 pre-change A/B independently answers the question BLK-2 actually
asked. But the `contract` screen has not, in this story, been compared against a
same-state reference. Re-check it in the requirement-level audit.

### DEF-3 — `VISUAL_FIDELITY: PASS` is scoped to this story, not to the 6 screens (owner: requirement-level audit)

The report honestly records four categories of deviation from the design
references, and I confirmed each by opening the pairs:

- no app-bar chrome on `otp`, `profile`, `permissions`, `joincode`, where the
  references draw a titled header (governed by `ux/uiux-spec.md` Chrome Rules —
  an approved deviation)
- `profile`: filled person-glyph avatar vs the reference's dashed
  "Ảnh đại diện" ring; CTA "Tiếp tục → Love Contract" vs "Tiếp tục → Ghép đôi"
- `permissions`: notification body "Nhắc nhớ đồng bộ và Emoji Storm" vs
  "Synced Alarm và Emoji Storm"
- `joincode` (the largest): a single 6-character free-text field vs the
  reference's 8-character segmented `CPD-8…` cells, and no "Dán" / "Quét QR" /
  "Tôi mới là người tạo mã →" affordances

All predate this story, none moved in its diff, and every one is owned by
STORY-007 / STORY-009 / STORY-010 / STORY-012. Reviewer rule 7 makes them
deferred, not blocking: this story made the backdrop better and made none of
them worse, and reopening them here would reopen four closed stories against
this story's own explicit Out of Scope list.

Recording them because a future reader who sees `VISUAL_FIDELITY: PASS` on
STORY-046 must not conclude that these 6 screens match the design source. The
`PASS` means "the backdrop fix landed and this story moved nothing else". Per
rule 12g2 the requirement-level
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/integration-review/mobile-visual-audit.md`
remains a separate blocking cross-screen check before REQ-002 closure; `joincode`
in particular should be triaged there.

## Carried Forward From Cycle 1 — Verified, Do Not Reopen

AC1-AC10 all PASS. Source edits, probe test, `flutter analyze lib test` (80
issues, all `info`, zero warnings/errors) and the probe suite (6/6) were
independently re-run by me in cycle 1 and are unchanged in this patch. AC2-AC7's
previously-partial "content/layout unchanged" clause is now PASS via the rendered
comparison above.

## Touched Risk Surfaces And Critical Gates

| Surface | Gate | Result |
|---------|------|--------|
| Mobile presentation paint layer | Widget probe + static `Scaffold.backgroundColor == null` assertion | PASS (cycle 1) |
| Mobile static analysis | `flutter analyze lib test` clean vs baseline | PASS (cycle 1) |
| Mobile regression | 1276 passing / 0 failing / 6 new | PASS (cycle 1) |
| Mobile design fidelity (12e2/12e3/12g2) | Rendered pairs + `VISUAL_FIDELITY` verdict, images opened and judged | PASS (cycle 2) |
| Mobile navigation / discoverability | No navigation code touched; 6 pre-existing reachable screens | NOT APPLICABLE — no new capability to make reachable (rule 12e1 satisfied by scope) |
| Runtime startup smoke (12g) | — | NOT REQUIRED — rule 12g applies to non-trivial stories; `Complexity: trivial`. Note: the 6 emulator captures incidentally demonstrate the app builds, installs and launches without an error screen |
| Setup / configuration | `deployment/configuration-guide.md` | NOT REQUIRED — pure presentation change |

## Traceability

- Requirements: `requirements/requirements.md` — AC1-AC10 all satisfied; the 6
  authoritative paths in `## In Scope` item 1 match the diff exactly. Item 3's
  reusable-reference claim is wrong but was correctly routed around (DEF-1).
- UX / Architecture: `SKIPPED:trivial` per `story_master.md`, consistent with
  rule 9 and the single `mobile` lane (rule 15 satisfied).
- Open questions: OQ5 RESOLVED and non-blocking for shared-token-level fixes;
  triage present, no blocked scope claimed, no unblocked AC omitted (rule 12).
- Design source: `data/devops/system/design-fidelity-config.json` —
  `ui_surface: true`, `design_source` present and `locked: true`. Neither audited
  scope-out applies, and the rendered gate is now satisfied on its own terms.
- Testing evidence: `visual-fidelity/visual-fidelity-report.md`, all 12 PNGs
  opened and judged by this review.

## State Recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE`.
- RWB-20260816-013 can be resolved.
- Carry DEF-1 to product-owner, and DEF-2 / DEF-3 to the REQ-002 requirement-level
  `integration-review/mobile-visual-audit.md` before requirement closure.

Blocking findings: 0. Deferred findings: 3.
