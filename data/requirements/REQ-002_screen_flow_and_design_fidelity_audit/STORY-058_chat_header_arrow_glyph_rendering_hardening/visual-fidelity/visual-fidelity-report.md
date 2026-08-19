# STORY-058 Visual Fidelity Report – Chat Header Separator Glyph

Scope: the `chat` header's pairing-title separator glyph only. Closes
rework item **RWB-20260816-026** (STORY-052 review finding D-1).

- Date: 2026-08-19
- Screen: `chat`
- Configuration: Android emulator, dark theme, `vi` locale (the audited
  REQ-002 configuration)
- Device: `emulator-5560` — sdk gphone64 arm64, Android 16 (API 36),
  1080x2400 @ 420dpi
- Executed remedy: **Path A** (separator glyph swap). Path B was never
  applied — section 1 shows it was not available.

## 1. Step-0 static font coverage table (recorded before any build)

Method: `fontTools` `getBestCmap()` over each font's `cmap` table. The two
app-bundled fonts are the ones named in `architecture/solution.md` Key
Discovery 3; the two emulator fonts were pulled from `/system/fonts` to
identify which family actually supplies each codepoint at runtime.

| Font | Source | U+2194 (`↔`) | U+27F7 (`⟷`) |
|------|--------|--------------|--------------|
| `Nunito-Variable.ttf` | app asset (`mobile/assets/fonts/`) | ABSENT | ABSENT |
| `Roboto-Variable.ttf` | app asset (`mobile/assets/fonts/`) | ABSENT | ABSENT |
| `NotoColorEmoji.ttf` | emulator `/system/fonts` | PRESENT (`arrowboth`) | ABSENT |
| `NotoSansSymbols-Regular-Subsetted.ttf` | emulator `/system/fonts` | PRESENT (`arrowboth`) | PRESENT (`uni27F7`) |
| `NotoSansSymbols-Regular-Subsetted2.ttf` | emulator `/system/fonts` | ABSENT | ABSENT |

### What the table decided

- **Root cause confirmed exactly as diagnosed.** Nunito carries neither
  arrow, so both codepoints fall through to the platform fallback chain.
  U+2194 is emoji-eligible *and* `NotoColorEmoji` covers it, so Android
  resolved the separator to the colour-emoji font — the tile STORY-052
  captured.
- **Path B was unavailable, not merely unpreferred.** The load-bearing
  question in the phase file was whether the app-bundled Roboto covers
  U+2194. It does **not**. Per `architecture/solution.md` Key Discovery 2,
  Flutter cannot exclude a font; `fontFamilyFallback` only helps when a
  named family positively covers the codepoint. A
  `fontFamilyFallback: ['Roboto']` would therefore have fallen straight
  through to `NotoColorEmoji` and left the tile unchanged. Path B was
  correctly skipped rather than tried and reverted.
- **Path A was predicted to succeed before the build.** `NotoColorEmoji`
  does not cover U+27F7, while the monochrome
  `NotoSansSymbols-Regular-Subsetted` does — so U+27F7 has no route into
  the colour-emoji font and a covering monochrome family exists on-device.
  This is what turned a possible two-cycle build/install/capture loop into
  one, exactly as the phase file intended.

## 2. Change applied (Path A)

`mobile/lib/features/chat/presentation/chat_strings.dart` —
`ChatStrings.headerPairingTitle` now passes `'⟷'` (U+27F7) to `_joinPair`
instead of `'↔'` (U+2194). The stale dartdoc paragraph that declared the fix
out of scope and D-1 open was replaced with the decision actually taken; the
U+FE0E/VS15 dead-end warning was deliberately kept so it is not re-attempted.
The five separator literals in
`mobile/test/features/chat/presentation/chat_design_fidelity_test.dart` were
updated to the same glyph, asserted as literals rather than via a shared
constant, so the fidelity assertion cannot become self-referential.

`headerPairingSemanticLabel` was **not** changed: it already substitutes the
conjunction `và`/`and` for the visual glyph, so assistive tech still announces
"Minh và Linh" and never an arrow name (`ux/uiux-spec.md` §3).

## 3. AC2 fence status

**AC2(a) — satisfied.** `mobile/lib/design_system/adaptive/cupid_header.dart`
is byte-unchanged. `_IosHeader`'s title `style:` and `_MaterialHeader`'s
`titleTextStyle:` block were not touched, so STORY-052's `ux/uiux-spec.md`
§1.2 fence remains fully intact. No AC2(b) exception was invoked, because
Path B was never executed.

## 4. AC3 cross-consumer status

`CupidHeader.title` is still a plain `String`. The component contract did not
change, so AC3 is satisfied by that fact alone and the other 16 consumers
carry no new regression risk. Proven by
`mobile/test/design_system/adaptive_widgets_test.dart` passing **25/25 with
the file byte-unchanged** — no assertion was added or relaxed to make it pass.

## 5. Capture and verdict

| Artifact | Path |
|----------|------|
| Implementation capture | `implemented-chat-emulator-5560.png` |
| Header/separator crop (2x, from the same 1080x2400 frame) | `implemented-chat-header-separator-emulator-5560.png` |
| Design reference | `design-reference-chat-android.png` |

Design-reference freshness: the `chat` design reference held by STORY-018,
STORY-040, STORY-051 and STORY-052 is byte-identical across all four
(md5 `0d0e43b430b99e4c49f77ce0a1c2fbb4`). The design source is therefore not
stale and was reused rather than re-rendered, per AC4's "existing (or freshly
re-rendered, if stale)" clause.

Capture route: the `main_preview.dart` harness
(`--dart-define=PREVIEW=chat --dart-define=PREVIEW_CHAT_GHOST=on`), which
seeds `selfDisplayName: 'Minh'` / `partnerDisplayName: 'Linh'` and pins
`locale: vi` with the dark-brightness theme — the state is faked, not driven.

### Verdict — separator glyph: `MATCH`

The header renders `Minh ⟷ Linh`. The separator is a thin, single-stroke,
**monochrome** double-headed horizontal arrow in the same white as the
surrounding Nunito title text. It is not a coloured emoji tile and not a
tofu/missing-glyph box.

Against the design reference (`Minh ↔ Linh`): both are single-stroke,
symmetric, double-headed horizontal arrows in the header's single typographic
weight and colour. The only difference is U+27F7's slightly longer shaft.
Per `ux/uiux-spec.md` §5, AC4's test is a rendered-capture verdict against
the design's visual and semantic intent — a monochrome, mutual, two-way
connector between two names — not a codepoint-level source-string diff. That
intent is met, so the verdict is `MATCH`.

**This closes RWB-20260816-026 / STORY-052 finding D-1.**

Corroborating detail in the same frame: the message bubbles' genuine emoji
(😩, 🔪) still render in colour. The colour-emoji font is therefore still
present and reachable in the fallback chain — the separator is monochrome
because U+27F7 has no path into that font, which is precisely the mechanism
section 1 predicted, not because emoji rendering was globally disabled.

## 6. Deviations beyond the separator glyph

None newly observed in the header. Per the story's business rules, any
deviation beyond the corrected separator would be recorded here as a new
finding rather than fixed in this story; nothing in this capture required
that.

Deviations already dispositioned by STORY-052's own report (D-2..D-5) and its
pre-existing-difference table are not re-litigated here.

## 7. iOS status — documented follow-up, not verified here

iOS was **not** device-verified in this story, per `ux/uiux-spec.md` §4 and
`architecture/solution.md` section 6. This is a recorded gap, not a silent
one.

Reasoning that makes deferral safe: the remedy is a single shared string
literal consumed identically by `_IosHeader` and `_MaterialHeader`, with no
platform-conditional glyph logic anywhere in the change, so it cannot fix
Android while leaving iOS in a worse state. U+27F7 is not emoji-eligible
under CoreText either. But that is inference, not observation.

Follow-up for Scrum Master: capture the `chat` header on an iOS
simulator the next time an iOS capture is already in flight for other REQ-002
work. Not a new story and not a blocking condition.

## 8. Gates

| Gate | Result |
|------|--------|
| `flutter analyze` on the two changed files | Clean — `No issues found!` |
| `flutter test .../chat_design_fidelity_test.dart` | 19/19 passed |
| `flutter test .../adaptive_widgets_test.dart` (file unchanged) | 25/25 passed |
| Full `flutter test` suite | 1314 passed, 2 skipped, 0 failed |
| `flutter build apk --debug` (registry `buildCommand`) | Built `app-debug.apk` |
| Repo grep for `↔` under `mobile/` | 0 hits |
| Android/dark/`vi` capture verdict | `MATCH` |

Exact commands and counts: `../coding-plan/test-results.md`.
