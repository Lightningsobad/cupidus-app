# STORY-058 Chat Header Arrow Glyph Rendering Hardening – solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-19

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: close RWB-20260816-026 / STORY-052 D-1 without breaking
  the 17 `CupidHeader` consumers, and without re-running STORY-052's disproven
  VS15 experiment.
- Architectural invariants / non-goals: `CupidHeader.title` stays a plain
  `String` (no `Row`/`RichText`/`InlineSpan` restructure, so investigation
  question 3's icon-asset option is closed); the shared `display` typography
  token stays untouched; no font asset is added to `mobile/pubspec.yaml`.
- Proposed technical direction: adopt UX's primary mechanism — swap the
  separator argument in `ChatStrings.headerPairingTitle` from `↔` (U+2194) to
  `⟷` (U+27F7) — gated by a static font-coverage pre-check, with UX's
  pre-authorized `fontFamilyFallback` exception as the single fallback path.
- Why this fits the current system: the separator is already a plain argument to
  `_joinPair` (`chat_strings.dart:61`), so the primary path is a one-token edit
  inside the chat feature and never reaches the fenced header style block.

### Key Discovery

Three findings reshape how the remedy must be executed and verified:

1. **Nunito provably has no U+2194 glyph, and the observed tile is the proof.**
   Skia leaves the declared `fontFamily` only when that family lacks the
   codepoint. So the defect is not "Nunito draws it wrong" — it is "Nunito has
   no glyph, and the first covering font in the platform fallback chain is the
   colour-emoji font". Every viable remedy has exactly one job: put a monochrome
   font that *covers the separator codepoint* ahead of the colour-emoji font in
   resolution order.
2. **Flutter cannot exclude a font.** UX/handoff describe the fallback path as a
   `fontFamilyFallback` that "excludes the platform's colour-emoji font by
   name". No such mechanism exists: `fontFamilyFallback` is an additive priority
   list consulted after `fontFamily` and before the platform chain; it cannot
   remove `NotoColorEmoji` from that chain. If no listed family covers U+2194,
   resolution falls through and the tile returns unchanged. Path B is therefore
   viable **only if a named fallback family actually carries U+2194 as a
   monochrome glyph** — restated below as a positive coverage requirement.
3. **The app bundles its own Roboto** (`mobile/pubspec.yaml:108-110` →
   `assets/fonts/Roboto-Variable.ttf`). A bundled asset family resolves
   deterministically inside the app, independent of OEM/API-level system font
   sets — unlike naming a system family such as `Noto Sans Symbols`, whose
   presence and family-name resolvability vary by device. So Path B's fallback
   list must be `<String>['Roboto']`, not a system symbol-font name.

Corollary that reorders the work: both paths hinge on a `cmap` fact that is
answerable **before any build** — Path A needs a monochrome device font covering
U+27F7 (Supplemental Arrows-B, absent from the Unicode emoji set entirely, so
its failure mode is tofu, not a tile); Path B needs the bundled Roboto to cover
U+2194. Running that static check first turns a possible two-cycle
build/install/capture loop into at most one.

## 3. Scope And Assumptions

- In Scope: the separator argument in `ChatStrings.headerPairingTitle`, its
  dartdoc, the matching test literals, and — only on the fallback path — the
  `fontFamilyFallback` property of the two `CupidHeader` title styles.
- Out Of Scope: iOS verification (UX §4 defers it), `chat_screen.dart` (title
  contract unchanged), `cupid_typography_tokens.dart`, `pubspec.yaml`, and any
  STORY-018/040/052 artifact other than the one AC6 line.
- Assumptions affecting design: Nunito lacks U+2194 (proven by STORY-052's
  capture); Nunito's U+27F7 coverage is unproven and is resolved by the Step-0
  cmap check, not assumed.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/chat/presentation` (separator choice);
  `mobile/lib/design_system/adaptive` owns header title style only on Path B.
- New or changed boundaries: none. The chat feature keeps sole ownership of the
  visible title string; the design-system header keeps sole ownership of its
  style.
- Shared patterns reused: bundled asset font families as deterministic glyph
  sources, already established by `pubspec.yaml`'s four font entries.

### Affected Modules

- Mobile: `features/chat/presentation`, `design_system/adaptive` (Path B only).

### Contracts And Integrations

- Empty-state contract unchanged: `_joinPair` still collapses a missing half to
  the surviving name, so a one-name title never renders a bare separator.
- Compatibility posture: `CupidHeader.title` remains `String` on both paths, so
  AC3 is satisfied by "the contract does not change". Path B's style change is
  additive and only consulted for codepoints Nunito lacks — no other consumer's
  title contains such a codepoint (Vietnamese diacritics are covered by Nunito
  today), so it is a no-visible-change default for the other 16 consumers.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Separator glyph presentation | Design source `Cupid Screens.dc.html:1773/1785`; STORY-052 D-1 | Step-0 cmap check selects the path before any build; Path A glyph swap, else Path B bundled-`Roboto` fallback | Fresh Android/dark/`vi` capture records `MATCH` for the separator in this story's `visual-fidelity/visual-fidelity-report.md` (AC1, AC4) | No Android device/emulator: `MOBILE_DEVICE_CAPTURE_UNAVAILABLE` |
| Shared `CupidHeader` cross-consumer rendering | `cupid_header.dart` and its 17 `lib/` call sites | `title` stays `String`; any Path B edit is confined to `fontFamilyFallback` on the header-local `copyWith`, never the shared `display` token | `mobile/test/design_system/adaptive_widgets_test.dart` passes **unchanged** (AC3) | Suite cannot run: `FLUTTER_TEST_UNAVAILABLE` |
| Accessible pairing announcement | `chat_strings.dart:66-71` `headerPairingSemanticLabel` | Swap touches only `headerPairingTitle`'s argument; the semantic label's `và`/`and` argument is untouched | `chat_design_fidelity_test.dart:646-658` semantics test passes against the updated title literal | Suite cannot run: `FLUTTER_TEST_UNAVAILABLE` |
| Glyph literal drift | The 8 `↔` occurrences: `chat_strings.dart:46,50,61,63` and `chat_design_fidelity_test.dart:521,526,653,667,677` | Update every occurrence in one pass; do **not** introduce a shared separator constant that the tests import — that would make the fidelity assertion self-referential and unable to catch a wrong glyph | `flutter analyze` clean and a repo grep for `↔` under `mobile/` returns zero hits on the chosen path (Path A) | Grep unavailable: read the three named files directly |

### Lane Handoff

#### Mobile Lane

- Responsibilities: run the Step-0 cmap check, apply the selected path, update
  the stale `headerPairingTitle` dartdoc, capture the Android/dark/`vi` header,
  write this story's `visual-fidelity/visual-fidelity-report.md`, and apply the
  AC6 one-line D-S1 correction.
- Authoritative inputs: `ux/uiux-spec.md` `## Decision summary for Tech Lead`,
  `requirements/requirements.md` AC1-AC7, this file section 4, and the phase
  file's decision tree.
- Guardrails:
  - Do not re-attempt bare-string U+FE0E (VS15). STORY-052 disproved it.
  - Do not restructure `CupidHeader.title` away from `String`; do not touch
    `chat_screen.dart`, `cupid_typography_tokens.dart`, or `pubspec.yaml`.
  - On Path B, change **only** the `fontFamilyFallback` property, and only on
    `_IosHeader`'s title `style` (`cupid_header.dart:167`) and
    `_MaterialHeader`'s `titleTextStyle` (`cupid_header.dart:223-228`). Line 242
    (`title: Text(title, ...)`) needs no edit — it inherits `titleTextStyle`.
  - Never ship a tofu/missing-glyph render. If both paths fail their coverage
    check, revert to the STORY-052 baseline and raise the blocker.
  - Touch exactly one line in STORY-052's `visual-fidelity-report.md` (§7,
    currently line 317). No other line or file in that directory.

## 5. Non-Functional Impact

- Accessibility: the visible separator must never become the announced one.
  `headerPairingSemanticLabel` stays the sole source of the assistive-tech
  string on both paths.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Swap separator to U+27F7 in `chat_strings.dart` (Path A) | UX's primary mechanism; non-emoji codepoint, so the colour-emoji font is not a fallback candidate at all; leaves the fenced style block byte-unchanged (AC2(a)) | ACCEPTED | Conditional on the Step-0 / device check; failure mode is tofu, which is a hard stop, not a ship |
| `fontFamilyFallback: <String>['Roboto']` on both header title styles, keeping `↔` (Path B) | UX-pre-authorized fallback; bundled asset font makes resolution device-independent | ACCEPTED (fallback only) | Invokes AC2(b); requires Step-0 to confirm Roboto covers U+2194, since Flutter cannot exclude the emoji font |
| `Icon`/`CupidIcons` glyph inside a restructured title (investigation question 3) | Guaranteed-monochrome bundled icon font | REJECTED | Requires changing `CupidHeader.title` from `String` to a mixed composition, breaking the section 1 invariant and putting all 16 other consumers at regression risk for a one-glyph defect |

### iOS status (follow-up, not verified here)

iOS is **unverified**, not known-unaffected. U+2194 is emoji-capable under
CoreText too, so `_IosHeader` is likely showing the same tile today; Path A's
non-emoji U+27F7 would resolve to a monochrome system font if covered. UX §4
puts iOS verification out of this story's scope — record it as a follow-up item
for Scrum Master rather than expanding scope.
