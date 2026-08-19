# Visual Fidelity Report: STORY-057 Contract Add-Clause Copy Alignment

VISUAL_FIDELITY: PASS
Design-Screen: contract

## What This Report Establishes

RWB-20260816-025 recorded a wording delta on the `contract` screen's add-clause
affordance: the implementation rendered `+ Thêm điều khoản riêng` while the
design canvas's `myUnsigned` branch paints `+ Thêm điều khoản của riêng tụi
mình`. This story corrected the shipped `vi` ARB value to match the design
source verbatim.

This report is the post-fix same-state pair. Both sides now render the same
add-clause label, so the delta is closed. **It closes RWB-20260816-025.**

STORY-015, STORY-039, STORY-046, STORY-049, and STORY-056 are not reopened.
Their recorded verdicts and `DONE` status are unchanged; STORY-056's evidence
directory was read only, never written.

## Evidence Pair

| Side | File | Size | `shasum -a 256` |
|------|------|------|-----------------|
| Design reference | `design-reference-contract-myunsigned-android.png` | 406x900 | `2acd1045727564cf7ff167fd36e13f3a418c65509be7debc35060ba6498514b3` |
| Implementation | `implemented-contract-requesterunsigned-emulator-5560.png` | 405x900 | `dd1e53774b3afbacf688c8009e6b159786cbd5bda9e81fed35a6992fd37d7958` |

Conditions match STORY-039's, STORY-049's, and STORY-056's approved pairs: dark
theme, `vi` locale, Android 412x915dp design frame vs `emulator-5560` at
1080x2400 @420dpi, `font_scale` 1.0, both sides bounded to 900 px tall.

## Design Side — Re-rendered, Reproduces The Stored Hash

The design side was not reused on assertion. It was re-rendered and the hash
compared, per the story's own AC-4 condition:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --entry="Cupid App.dc.html" \
  --screen=contract --platform=android --theme=dark --lang=vi \
  --out=<this story's visual-fidelity/> --label=contract-myunsigned
```

→ `DESIGN_CANVAS: OK … 406x900`, exit 0. The output is **byte-identical**
(`2acd1045…14b3`) to the reference stored by STORY-039, STORY-049, and
STORY-056. That identity confirms by rendering, not by assertion, that the
design source has not moved since STORY-056's confirmation. The fresh render is
what is filed here.

## Implementation Side — Rebuilt After The ARB Change And Re-captured

STORY-056's implementation capture could not be reused: it depicts the pre-fix
string. A fresh capture was required and taken.

1. `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=contract --dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned`
   → `✓ Built build/app/outputs/flutter-apk/app-debug.apk`, exit 0.
   Required, because `PREVIEW_CONTRACT_SIGN_STATUS` is a compile-time
   `String.fromEnvironment`. **`main_preview.dart` was not modified** — the
   `requesterUnsigned` fixture STORY-049 added is used as-is.
2. `adb -s emulator-5560 install -r …/app-debug.apk`
3. `adb -s emulator-5560 shell settings put system font_scale 1.0`
4. `am force-stop com.snapsofts.cupid`, then `am start` of
   `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
5. `capture-mobile-screen.sh --device=emulator-5560 --label=contract-requesterunsigned --mode=implemented --platform=android --max-edge=900 --settle-ms=45000`
   → `MOBILE_CAPTURE: OK … 405x900`, exit 0.

Steps 2-5 ran inside a single `--lease-exec` device lease, so no concurrent
worker could disturb the device mid-capture.

STORY-056's harness note was applied rather than rediscovered: a 12000 ms settle
is not enough for this debug build, so `--settle-ms=45000` was used on the first
attempt. The capture was then **content-verified** before being trusted — it
shows the rendered Love Contract screen, not the Flutter splash. No capture was
discarded.

The implementation hash necessarily differs from STORY-056's stored capture:
the string changed, and the status-bar clock is baked into every screenshot.
Byte equality is not available here and is not claimed.

## Same-State Confirmation

The implementation capture carries no `đã ký` signature line, both sign-state
affordances are pre-signature, and the hold-to-sign control is unpressed. The
design reference shows the same. This is a genuine same-state pair, on the same
terms STORY-056 established.

## Per-Element Verdict — Add-Clause Row (AC-4 Subject)

| # | Element | Verdict | Basis |
|---|---------|---------|-------|
| 1 | Add-clause row **text** | **MATCH** | Design paints `Thêm điều khoản của riêng tụi mình`; the implementation capture now renders `+ Thêm điều khoản của riêng tụi mình`. Character-for-character identical label copy. This is the delta RWB-20260816-025 recorded, and it is closed. |
| 2 | Add-clause row **glyph count** | **MATCH** | One leading `+` on both sides. No duplicate add icon on either. Unchanged from D-7/D-8, which already passed on structure and glyph count; the correction did not disturb it. |
| 3 | Add-clause row **position / pink accent** | **MATCH** | Row sits directly below the fourth clause and directly above the lower dashed rule on both sides, in the pink accent treatment on both. The longer label did not clip, wrap, or displace the rule — confirming the Product Owner's no-text-fit-constraint finding for this unconstrained left-aligned `TextButton`. |

The design canvas paints the `+` as a separate span with a wider gap before the
label; the implementation renders `+ ` as the leading characters of a single
text run. That is the pre-existing single-glyph rendering already accepted by
D-7/D-8 and is not a wording difference.

## AC-6: Entry Point Unchanged

The corrected label is reached through the existing Love Contract screen and its
existing unchanged navigation path. This story added no screen, no route, and no
navigation entry point; `mobile/lib/features/love_contracts/` was not modified.

## New Deviations Beyond The Corrected Text: NONE

Per the story's own guardrail, the pair was checked for anything beyond the
add-clause text. Every remaining difference is one already dispositioned by
STORY-056's approved report, re-confirmed here, and none is newly introduced:

- **Clause-counter row `2/20 điều khoản`** — present in the implementation,
  absent from the design source. Dispositioned as A-1 by STORY-015 and
  re-confirmed as CC-1 by STORY-050, both keep-and-exclude.
- **Subtitle** — design `Giữa Minh & Linh · có hiệu lực đến khi cả hai cùng
  huỷ` vs the implementation's neutral fallback. The preview harness supplies no
  `myDisplayName`. Fixture state, recorded by STORY-049 and STORY-056.
- **Clause selection** — design selects 3 of 4 preset clauses, the fixture
  selects 2. Fixture state; equally true of STORY-039's, STORY-049's, and
  STORY-056's approved pairs.
- **Clause label language** — the implementation renders the preview fixture's
  English strings where the design renders its Vietnamese preset copy. Preview
  fixture **data**, not shipped copy.

No new finding is raised by this story.

## Scope Boundary Held

Working-tree diff against `BaseHead` `62f23e8` is exactly two files:

```
mobile/lib/l10n/arb/app_vi.arb                                     | 2 +-
.../screens/love_contract_screen_fidelity_test.dart                | 2 +-
2 files changed, 2 insertions(+), 2 deletions(-)
```

`mobile/lib/l10n/generated/` is regenerated build output and is gitignored
(`mobile/.gitignore:41`), so codegen produces no tracked diff; it was
regenerated with `flutter gen-l10n`, never hand-edited. No other `mobile/lib/**`
file was touched, including `main_preview.dart` and
`mobile/lib/l10n/arb/app_en.arb`. The design source was rendered read-only with
`--out` pointing at this story's own evidence directory.

## Verification State

Run in this session from `/Users/alantravala/workspace/snapsofts/cupid-apps/mobile`,
Flutter 3.44.1 stable / Dart 3.12.1:

- `flutter gen-l10n` → exit 0.
- `flutter analyze lib test` → `80 issues found`, all `info`, zero errors, zero
  warnings. **Identical to the baseline STORY-049, STORY-050, and STORY-056 each
  recorded**, so this story introduced no new analyzer issue. Exit code 1 is
  `flutter analyze`'s normal result whenever any issue exists including
  `info`-level ones, and is not a failure signal.
- `flutter analyze lib/l10n test/features/love_contracts` (this story's exact
  touched scope, including the regenerated output) → `No issues found!`, exit 0.
- `flutter test` (full suite) → `+1314 ~2: All other tests passed!`, exit 0.
  1314 passed, 2 skipped, 0 failures — the same count STORY-056 recorded, as
  expected since this story adds no test.
- `flutter test test/features/love_contracts/presentation/screens/love_contract_screen_fidelity_test.dart`
  → `+9: All tests passed!`, exit 0, including
  `the add-clause affordance renders a single leading plus, not the localized
  plus plus a duplicate add icon` with its updated expected literal and its
  no-duplicate-icon assertion intact.

A bare repo-wide `flutter analyze` additionally reports errors under
`build/ios/SourcePackages/checkouts/flutterfire/…`. Those are vendored
third-party SwiftPM checkouts left inside `build/` by a prior iOS build, not
project source; `analysis_options.yaml` declares no `exclude`. They are
pre-existing environment noise, unrelated to and untouched by this story, which
is why the project-scoped `lib test` form is the one recorded above — the same
form STORY-049/050/056 used.

VISUAL_FIDELITY: PASS
