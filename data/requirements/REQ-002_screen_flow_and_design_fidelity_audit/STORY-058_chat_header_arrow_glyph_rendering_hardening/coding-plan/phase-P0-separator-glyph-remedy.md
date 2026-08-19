# Phase P0 – Chat Header Separator Glyph Remedy

## 1. Objective

The chat header's pairing separator renders as a monochrome text glyph matching
the header typography on the audited Android/dark/`vi` configuration, proven by a
fresh capture, with `CupidHeader.title`'s `String` contract unchanged and the
STORY-052 D-S1 documentation line corrected.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-separator-glyph-remedy.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/chat/presentation/chat_strings.dart` (Path A)
  - `mobile/test/features/chat/presentation/chat_design_fidelity_test.dart`
    (Path A)
  - `mobile/lib/design_system/adaptive/cupid_header.dart` (Path B only)
  - `../visual-fidelity/visual-fidelity-report.md` (this story's own evidence)
  - `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-052_chat_header_partner_presence_hardening/visual-fidelity/visual-fidelity-report.md`
    — the single §7 line (currently line 317) only
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE (device work is the visual audit in section 6)
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Risk Surfaces:
  - Separator glyph presentation
  - Shared `CupidHeader` cross-consumer rendering
  - Accessible pairing announcement
  - Glyph literal drift
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` sections 1, 4, 6
  - consumer contract: `CupidHeader.title` stays `String` (unchanged)
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC1-AC7,
    `## Business Rules And Guardrails`
  - architecture: `../architecture/solution.md`
  - UX constraints: `../ux/uiux-spec.md` `## Decision summary for Tech Lead`
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one separator-glyph remedy plus its evidence and the folded
    one-line D-S1 doc correction.
  - Source/Test File Count: 2 on Path A, 3 on Path B (plus 2 doc files)
  - Split Required: NO
  - Split Rationale: single lane, single behavior cluster, well inside one
    specialist lifecycle.

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md` `## Decision summary for Tech Lead`

## 3. Tasks

Execute the steps in order. The path is selected by evidence, not preference.

**Step 0 — static font coverage check (no build).** Inspect the `cmap` of
`mobile/assets/fonts/Nunito-Variable.ttf` and
`mobile/assets/fonts/Roboto-Variable.ttf` for U+2194 and U+27F7 (for example
with `fontTools`: `ttx -t cmap`, or any equivalent inspector). Record all four
answers in `../visual-fidelity/visual-fidelity-report.md`. Nunito is expected to
lack both; the load-bearing answer is whether the bundled Roboto covers U+2194,
because that decides whether Path B is even available. Per
`../architecture/solution.md` Key Discovery 2, Flutter cannot exclude the
colour-emoji font — Path B works only by naming a family that positively covers
the codepoint.

**Step 1 — apply Path A.** In `chat_strings.dart`, change the separator argument
passed to `_joinPair` in `headerPairingTitle` (line 61) from `'↔'` to `'⟷'`
(U+27F7). Update the two `↔` mentions in that method's dartdoc (lines 46, 50)
and the one in `headerPairingSemanticLabel`'s dartdoc (line 63). Rewrite the
dartdoc paragraph at lines 52-57: it currently states the fix is out of scope and
D-1 is open, which becomes false — replace it with what was chosen and why,
while **keeping** the U+FE0E/VS15 dead-end warning so it is not re-attempted.
Update all five test literals in `chat_design_fidelity_test.dart` (lines 521,
526, 653, 667, 677). Do not introduce a shared separator constant that the test
imports — the test must assert the literal expected glyph independently.

**Step 2 — build, install, capture.** Build and install on the audited
configuration (Android, dark theme, `vi` locale) and capture the chat header.

**Step 3 — evaluate the capture.**
- Monochrome arrow → Path A succeeded. Go to Step 5.
- Colour tile → unexpected under Path A; stop and report, do not improvise.
- Tofu / missing-glyph box → Path A failed. Go to Step 4.

**Step 4 — Path B (only if Step 0 confirmed Roboto covers U+2194).** Revert
Step 1 in full (both source and tests back to `↔`, keeping any dartdoc
improvements factual). Then add `fontFamilyFallback: const <String>['Roboto']`
to exactly two places in `cupid_header.dart`: `_IosHeader`'s title
`style: type.display.copyWith(...)` (line 167) and `_MaterialHeader`'s
`titleTextStyle:` block (lines 223-228). Change no other `TextStyle` property.
Do not edit line 242 (`title: Text(title, ...)`) — it inherits `titleTextStyle`.
Do not edit `cupid_typography_tokens.dart`. Re-capture and re-evaluate. If Step 0
showed Roboto lacks U+2194, or if the Path B capture still shows a tile or tofu,
revert everything to the STORY-052 baseline and stop with
`GLYPH_FALLBACK_EXHAUSTED`, attaching the Step-0 coverage table and both
captures.

**Step 5 — evidence and closure.** Write
`../visual-fidelity/visual-fidelity-report.md` recording the executed path, the
Step-0 coverage table, the fresh capture paired with the `chat` design
reference, a `MATCH` verdict for the separator glyph specifically, and the
statement that it closes RWB-20260816-026. If Path B was executed, also record
the AC2(b) exception explicitly (what changed, and the AC3 argument that
`fontFamilyFallback` is consulted only for codepoints Nunito lacks, so the other
16 consumers are unaffected). Record any deviation beyond the separator glyph as
a new finding rather than fixing it here. Note iOS as an unverified documented
follow-up per `../architecture/solution.md` section 6.

**Step 6 — AC6 D-S1 correction.** In STORY-052's
`visual-fidelity/visual-fidelity-report.md` §7, change only the single stale
line (currently line 317) so it states that the real runtime-smoke evidence
lives in that story's own `coding-plan/test-results.md` `## Story Runtime
Startup Smoke` section, instead of claiming a `NOT_APPLICABLE` registry
exemption. Touch no other line or file in that directory.

## 4. Acceptance Criteria

- The separator renders monochrome on the audited config, evidenced by a fresh
  capture (AC1, AC4).
- `cupid_header.dart`'s title style block is byte-unchanged (AC2(a)), or changed
  only in `fontFamilyFallback` with the AC2(b) exception recorded (Path B).
- `CupidHeader.title` is still `String`; `chat_screen.dart` and
  `adaptive_widgets_test.dart` are untouched (AC3, AC7).
- No `↔` remains under `mobile/` on Path A; no VS15 constant is reintroduced.
- `flutter analyze` and `flutter test` pass clean (AC5).
- Exactly one line changed in STORY-052's report (AC6).

## 5. Planned Outputs

- Code: `chat_strings.dart` (Path A) or `cupid_header.dart` (Path B), plus
  `chat_design_fidelity_test.dart` on Path A.
- Notes or evidence: `../visual-fidelity/visual-fidelity-report.md`,
  `test-results.md`, and the one corrected STORY-052 line.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `chat` header on Android / dark / `vi`.
- Required levels:
  - unit/widget: `flutter test test/features/chat/presentation/chat_design_fidelity_test.dart`
  - mobile build/type-check/static-analysis: `flutter analyze`, plus registry
    `buildCommand` (`flutter build apk --debug`)
  - visual inspection: the fresh header capture from Step 2/Step 4
- Required checks:
  - `flutter test test/design_system/adaptive_widgets_test.dart` passes with the
    file **unchanged** — this is the AC3 cross-consumer proof; do not add a new
    assertion to it.
  - Repo grep for `↔` under `mobile/` returns zero hits when Path A ships.
  - Step-0 font coverage table recorded before any build.
- Minimum gates by risk surface:
  - Separator glyph presentation → the fresh capture verdict.
  - Shared `CupidHeader` cross-consumer rendering → unchanged
    `adaptive_widgets_test.dart` green.
  - Accessible pairing announcement → the semantics test at
    `chat_design_fidelity_test.dart:646-658` green against the new literal.
  - Glyph literal drift → `flutter analyze` clean plus the grep above.
- Required regression or contract coverage: full `flutter test` suite green; no
  new test is required for the other 16 consumers because the `title` contract
  does not change on either path.
- Evidence format: `coding-plan/test-results.md` with exact commands and
  pass/fail counts; capture PNG path referenced from
  `../visual-fidelity/visual-fidelity-report.md`.
- Requirement mobile visual audit: YES — the Android/dark/`vi` chat header
  capture is the AC1/AC4 gate.

## 7. Status

- Status: DONE
- Last updated: 2026-08-19
- Executed remedy path: **Path A** (separator glyph swap, U+2194 → U+27F7 in
  `ChatStrings.headerPairingTitle`).

### Why Path A and not Path B

Step 0 was decisive and it inverted the fallback branch this phase left open.
`fontTools` `cmap` inspection found that the app-bundled `Roboto-Variable.ttf`
does **not** cover U+2194 either:

| Font | U+2194 | U+27F7 |
|------|--------|--------|
| `Nunito-Variable.ttf` (app asset) | ABSENT | ABSENT |
| `Roboto-Variable.ttf` (app asset) | ABSENT | ABSENT |
| `NotoColorEmoji.ttf` (emulator) | PRESENT (`arrowboth`) | ABSENT |
| `NotoSansSymbols-Regular-Subsetted.ttf` (emulator) | PRESENT (`arrowboth`) | PRESENT (`uni27F7`) |
| `NotoSansSymbols-Regular-Subsetted2.ttf` (emulator) | ABSENT | ABSENT |

Path B was therefore structurally **unavailable**, not merely less preferred:
`fontFamilyFallback` is additive and cannot exclude a font, so
`fontFamilyFallback: ['Roboto']` would have fallen straight through to
`NotoColorEmoji` and left the colour tile unchanged. It was skipped rather
than attempted-and-reverted, which is why `cupid_header.dart` is byte-unchanged
and AC2(a) holds with no AC2(b) exception invoked.

The two emulator `/system/fonts` rows are beyond this phase's required minimum.
They were added because they convert the remedy from a guess into a prediction:
U+27F7 has no route into `NotoColorEmoji` and a covering monochrome family
already exists on-device. That collapsed the anticipated two build/install/
capture cycles into one, and the capture confirmed the prediction.

### Gate results

| Gate | Result |
|------|--------|
| `flutter analyze` on the two changed files | `No issues found!` |
| `flutter analyze lib test` | `80 issues found` — 0 errors/warnings, unchanged from the STORY-052 baseline |
| `flutter test .../chat_design_fidelity_test.dart` | 19/19 passed |
| `flutter test .../adaptive_widgets_test.dart` (file byte-unchanged) | 25/25 passed |
| Full `flutter test` | 1314 passed, 2 skipped, 0 failed |
| `flutter build apk --debug` (registry `buildCommand`) | Built `app-debug.apk` |
| Repo grep for `↔` under `mobile/` | 0 hits |
| Android/dark/`vi` capture verdict | `MATCH` — closes RWB-20260816-026 |
| AC6 STORY-052 §7 doc correction | 1 file, 1 insertion, 1 deletion |

Evidence: `test-results.md` (exact commands and counts),
`../visual-fidelity/visual-fidelity-report.md` (Step-0 table, captures,
verdict). iOS was not device-verified — recorded as a documented follow-up in
that report §7, per `ux/uiux-spec.md` §4.
