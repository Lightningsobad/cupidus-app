# STORY-058 Review Report — Chat Header Arrow Glyph Rendering Hardening

Outcome: PATCH_REQUIRED

- Review type: `compact-story-review`
- Reviewer: Iris-QC
- Date: 2026-08-19
- Story: `REQ-002_screen_flow_and_design_fidelity_audit/STORY-058_chat_header_arrow_glyph_rendering_hardening`
- Complexity: `standard` · Implementation Lane: `shared` (mobile-dev implemented)
- Implementation commit reviewed: `62feaf75b0661ded6017ccc0400d76e7766b69e3`
  (diff baseline `8f1ea7162aa549aff9b1d45de80170524ce0e568`). The handoff's
  `BaseHead` `46a780a` is a trailing docs-only commit and was excluded from
  implementation scope, as instructed.

## Scope Gate

- Source/test files in scope (2): `mobile/lib/features/chat/presentation/chat_strings.dart`,
  `mobile/test/features/chat/presentation/chat_design_fidelity_test.dart`
- Non-diff files verified as unchanged (2): `mobile/lib/design_system/adaptive/cupid_header.dart`,
  `mobile/test/design_system/adaptive_widgets_test.dart`
- Evidence files in scope: this story's `coding-plan/test-results.md`,
  `visual-fidelity/visual-fidelity-report.md`, 3 PNG captures; `ux/uiux-spec.md`
  §§1-5 + Decision summary; STORY-052's `visual-fidelity-report.md` §7 (AC6 line only)
- Query keys: `headerPairingTitle`, `headerPairingSemanticLabel`, `_joinPair`,
  U+2194/U+27F7, `titleTextStyle`, `Runtime-Smoke`, `VISUAL_FIDELITY`, AC1-AC7
- Retro discipline: this story is the RWB-20260816-026 rework carrier
  (`Retro-Type: RED-PATCH`), so rule 1a does not refuse the handoff.

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Status |
|---|---|---|
| Mobile interaction (shared header text rendering) | `chat_design_fidelity_test.dart` 19/19; full suite 1314 pass / 2 skip / 0 fail | PASS |
| Shared-component regression (17 `CupidHeader` call sites) | `adaptive_widgets_test.dart` 25/25 with the file byte-unchanged | PASS |
| Mobile build / static analysis | `flutter analyze` on both changed files clean; `flutter analyze lib test` = 80 info-level, unchanged from STORY-052 baseline, 0 errors/warnings; `flutter build apk --debug` green | PASS |
| Mobile design fidelity (12e2/12e3) | Both images exist, open, and were read; comparison is real | PASS in substance, FAILS on the required verdict token — see B-2 |
| App lifecycle / runtime startup (12g) | `## Story Runtime Startup Smoke` | NOT SATISFIED — see B-1 |
| Persistence, config, external integration, deep link, permissions | — | Not touched; no gate required |

Setup/configuration impact: none. No env var, dependency, registry entry, or
manual step changed, so `deployment/configuration-guide.md` needs no update.

## Verification Performed

Independent checks, not evidence read on trust:

- `cupid_header.dart` and `adaptive_widgets_test.dart` are genuinely absent
  from the implementation commit; their most recent touching commits are
  `38bb1c3` / `72bf3df` / `6b71078` (STORY-052/055), and the working tree is
  clean apart from an unrelated retro checkpoint file. AC2(a) and the AC3
  cross-consumer proof therefore hold on evidence, not assertion.
- Opened `implemented-chat-header-separator-emulator-5560.png` and
  `implemented-chat-emulator-5560.png`: the built app's chat screen renders
  `Minh ⟷ Linh` with a thin, single-stroke, **monochrome** double-headed arrow
  in the same white as the surrounding Nunito title — no colour tile, no tofu
  box, no error or loading frame. The presence chip, ghost-typing row, and
  bottom nav all paint normally.
- Opened `design-reference-chat-android.png`: it depicts the `chat` screen
  (correct screen, not a neighbouring canvas screen), header `Minh ↔ Linh` as a
  monochrome arrow. Nothing I see contradicts the `MATCH` verdict; the only
  separator delta is U+27F7's longer shaft, as the report states.
- The Step-0 `cmap` table is self-supporting: bundled `Roboto-Variable.ttf`
  lacks U+2194, so a `fontFamilyFallback: ['Roboto']` could not have supplied
  the glyph and would have fallen through to `NotoColorEmoji`. Path B was
  correctly skipped rather than tried and reverted, and the capture confirms
  the U+27F7 prediction empirically.
- `ux/uiux-spec.md` §1/§2/§5 and the Decision summary authorize exactly what
  shipped: direction (b) glyph swap, fence untouched under AC2(a), and the
  design-fidelity judgment that AC4 is a rendered-capture verdict against
  visual/semantic intent rather than a codepoint diff. The delivered glyph swap
  is a governing approved decision, not an implementer substitution, so rule 14
  is satisfied.

## Acceptance Criteria

| AC | Verdict | Basis |
|---|---|---|
| AC1 monochrome separator on audited stack | PASS | Both captures opened; monochrome arrow confirmed |
| AC2 fence status | PASS — (a) | `cupid_header.dart` byte-unchanged; no (b) exception invoked |
| AC3 other 16 consumers unchanged | PASS | `title` still `String`; `adaptive_widgets_test.dart` 25/25, file unchanged |
| AC4 `MATCH` verdict closing RWB-20260816-026 | PASS on substance | Verdict recorded with named screen/device/states; reference freshness proven by md5 identity across 4 stories. Missing gate token tracked as B-2 |
| AC5 analyze + suite clean | PASS | Changed files clean; lint count unchanged vs baseline; 1314/2/0 |
| AC6 one-line D-S1 doc correction | PASS | STORY-052 §7: exactly 1 insertion / 1 deletion, no other file or line touched |
| AC7 no new entry point | PASS on substance | Chat reached via the existing, unchanged `Trò chuyện` bottom-nav tab, observed active in the capture. Evidence-section gap tracked as B-3 |

## Blocking Findings

**B-1 — story runtime startup smoke gate not satisfied (rule 12g). Owner: mobile-dev.**
The story is non-trivial with `Implementation Lane: shared`, so a registry-backed
runtime startup smoke is mandatory. `story_master.md` records no
`Runtime-Smoke: WAIVED — <reason>` line — the only escape the rule allows — and
`coding-plan/test-results.md` `## Story Runtime Startup Smoke` records
`NOT_APPLICABLE`, citing `phase-P0-separator-glyph-remedy.md` §1B. A phase file
cannot waive a story-level gate. Substantively, the only launch performed was
`main_preview.dart` with `--dart-define=PREVIEW=chat`, i.e. the capture harness,
not the production `lib/main.dart` bootstrap, so nothing here proves the shipped
app still boots.

This is worth stating plainly given what this story is: AC6 exists precisely to
correct STORY-052's stale self-declared `NOT_APPLICABLE` startup-smoke exemption.
The same shape of self-waiver reappears in this story's own evidence, one section
above the correction.

Resolution — either is acceptable:
1. (preferred, cheap) Re-launch the production entrypoint on the already-provisioned
   `emulator-5560`: `flutter build apk --debug` + install + `am start` of
   `lib/main.dart`, confirm a clean cold boot to the first screen with no crash and
   no red error screen, and replace the `NOT_APPLICABLE` text with that result.
   STORY-052 recorded exactly this evidence and it is the current baseline for the
   surface.
2. Scrum Master records `Runtime-Smoke: WAIVED — <reason>` in `story_master.md`,
   on the genuine merit that this change is one string literal with no DI,
   bootstrap, routing, Firebase, or platform-channel surface. Reviewer cannot
   write that line.

**B-2 — `VISUAL_FIDELITY:` verdict token absent from the visual-fidelity report. Owner: mobile-dev.**
`visual-fidelity/visual-fidelity-report.md` has zero occurrences of
`VISUAL_FIDELITY`. It records `### Verdict — separator glyph: MATCH`, which
satisfies AC4's own wording, but rules 12e2/12e3 require a top-level
`VISUAL_FIDELITY: PASS` line, and both `verify-story-visual-fidelity-gate.sh`
and `validate-done-gate.sh` read that exact literal independently.

I want to be exact about severity: the comparison behind it is real. I opened
both images and the `MATCH` is correct — this is a missing token, not a
manufactured verdict. But a passing outcome cannot be recorded while the gate
literal both downstream gates read is absent. Add a top-level
`VISUAL_FIDELITY: PASS` line to that report; no re-capture is needed and none
should be performed.

**B-3 — `## Entry Point Reachability` evidence section absent (rule 12e1). Owner: mobile-dev.**
`requirements/requirements.md` marks this UI-facing: YES, so
`coding-plan/test-results.md` must carry the section with `Reachable: YES` and
the concrete path. It is absent. Substance is verified — the chat screen is
reached through its existing, unchanged `Trò chuyện` bottom-nav tab, which I
observed rendered and active in `implemented-chat-emulator-5560.png`, and AC7
requires no new entry point. Add the section stating the unchanged path; bundle
it into the same pass as B-1 and B-2.

## Deferred Findings

| Id | Finding | Rationale |
|---|---|---|
| D-1 | iOS not device-verified | Explicitly authorized by `ux/uiux-spec.md` §4 and recorded in `visual-fidelity-report.md` §7 with mechanism reasoning and a named Scrum Master follow-up. Recorded, not silent — which is the exact failure mode this story exists to correct. No action in this story. |
| D-2 | Capture filename device suffixes differ (`design-reference-chat-android.png` vs `implemented-chat-emulator-5560.png`) | Cosmetic. Both files exist, open as real images, and depict the same screen. Rename only if a downstream gate requires the matched `<screen>-<device>` pair. |

## State Recommendation

- Uncheck `Implementation (Development)` in `story_master.md` `## Artifacts`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS` (currently `PENDING`, which is separately stale —
  Scrum Master owns that correction)
- Route B-1, B-2, and B-3 back to mobile-dev as one bundled evidence pass. No
  source code change is required; all three are evidence/gate-record items, and
  only B-1 route 1 needs the device. Re-review can be a completion/resume pass
  against these three findings rather than a fresh story review.
