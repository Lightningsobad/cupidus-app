# Test Results — STORY-001 Phase P1 (Couple-Type Picker)

- Role: Mobile Developer
- Date: 2026-08-24
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-009_invite_couple_type_and_pairing_navigation-STORY-001_invite_couple_type_picker`
- Branch: `codex/REQ-009_invite_couple_type_and_pairing_navigation-STORY-001_invite_couple_type_picker`
- BaseHead: `f30a17ac6488a999751605e70944bd923015bd4e`
- Flutter SDK: not on PATH; every command below was run with
  `PATH="$HOME/flutter/bin:$PATH"` from the worktree's `mobile/` directory.

## 1. Icon Codepoint Resolution (ordered prerequisite, task 1)

Codepoints were read from the bundled variable font's `cmap`, never from
memory. Command (run from the worktree `mobile/` directory):

```bash
python3 -c "
from fontTools.ttLib import TTFont
font = TTFont('assets/fonts/MaterialSymbolsRounded-Variable.ttf')
reverse = {}
for codepoint, name in font.getBestCmap().items():
    reverse[name] = codepoint
for name in ['location_city', 'auto_awesome', 'all_inclusive', 'flight_takeoff']:
    print(name, hex(reverse[name]))
"
```

Output:

```text
location_city 0xe7f1
auto_awesome 0xe65f
all_inclusive 0xeb3d
flight_takeoff 0xe905
```

`flight_takeoff` is the control: it resolves to `0xe905`, which matches the
already-confirmed `CupidIcons.flightTakeoff`, so the lookup method itself is
verified against a known-good value. The three new codepoints are declared as
file-local `IconData` constants in
`mobile/lib/features/pairing/presentation/couple_type.dart`; `flight_takeoff`
reuses `CupidIcons.flightTakeoff` rather than redeclaring it, and
`mobile/lib/design_system/` was not touched.

## 2. Static Analysis

Scoped run over exactly the files this phase changed (the project convention
established in `REQ-008_android_build_variants_local_prod/STORY-001`: a bare
`flutter analyze` surfaces thousands of pre-existing issues from the generated
`openapi/cupid_api` client and vendored sources, so the scoped run is the gate):

```bash
flutter analyze \
  lib/features/pairing/presentation/couple_type.dart \
  lib/features/pairing/presentation/invite_cubit.dart \
  lib/features/pairing/presentation/screens/invite_screen.dart \
  lib/main_preview.dart \
  test/features/pairing/presentation/invite_cubit_test.dart \
  test/features/pairing/presentation/invite_screen_test.dart
```

Result:

```text
Analyzing 6 items...
No issues found! (ran in 1.9s)
```

PASS — 0 errors, 0 warnings, 0 infos.

### Lint note (why two files gained an `ignore_for_file`)

The first scoped run reported 7 `prefer_initializing_formals` infos — 5 on
pre-existing lines and 2 on the new `fetchCoupleType` / `saveCoupleType`
constructor seams:

```text
   info • ... ('this._generateInvitation') ... • lib/features/pairing/presentation/invite_cubit.dart:59:8 • prefer_initializing_formals
   info • ... ('this._fetchCoupleType') ...    • lib/features/pairing/presentation/invite_cubit.dart:60:8 • prefer_initializing_formals
   info • ... ('this._saveCoupleType') ...     • lib/features/pairing/presentation/invite_cubit.dart:61:8 • prefer_initializing_formals
   info • ... ('this._now') ...                • lib/features/pairing/presentation/invite_cubit.dart:62:8 • prefer_initializing_formals
   info • ... ('this._createInviteCubit') ...  • lib/features/pairing/presentation/screens/invite_screen.dart:98:8 • prefer_initializing_formals
   info • ... ('this._createWaitingCubit') ... • lib/features/pairing/presentation/screens/invite_screen.dart:99:8 • prefer_initializing_formals
   info • ... ('this._createWaitingCubit') ... • lib/features/pairing/presentation/screens/invite_screen.dart:137:8 • prefer_initializing_formals

7 issues found. (ran in 1.8s)
```

Every one is the same inapplicable suggestion: these are private fields fed by
public named parameters, and the lint's own fix (`this._field`) is not
expressible in Dart because a named parameter cannot start with `_`. The
codebase already suppresses exactly this pattern
(`lib/core/navigation/app_shell.dart:4` uses `// ignore_for_file:`, and
`features/expenses/`, `features/home/`, `features/timeline/` use per-line
`// ignore:`), so the same one-line `ignore_for_file` was added to both files
with the reason recorded in the comment. No behavior change.

`dart format` was deliberately NOT run: the files are already non-conformant at
`BaseHead` (verified by formatting the `git show f30a17ac…:<path>` copies in a
scratch directory — `invite_cubit.dart`, `invite_cubit_test.dart`, and
`main_preview.dart` all report "Changed"), so the repository does not enforce
`dart format` and running it would produce a large unrelated diff.

Out-of-scope baseline, unchanged by this phase: a wider
`flutter analyze lib/features/pairing lib/main_preview.dart` reports the same
lint on files this story never touched (`joincode_cubit.dart:40`,
`pair_gate_cubit.dart:45`, `waiting_screen.dart:28`,
`pairing_choice_screen.dart:28-29`). They were left alone.

## 3. Targeted Tests

```bash
flutter test test/features/pairing/ --reporter compact
```

Result:

```text
00:04 +126: All tests passed!
```

PASS — 126 passed, 0 failed. This includes every pre-existing pairing test
(code card, countdown, share/copy, error/retry, joincode, waiting, paired,
pair-gate, repository, poller), all still passing unmodified in intent.

Per-file runs used while iterating:

```text
flutter test test/features/pairing/presentation/invite_cubit_test.dart
  -> 00:00 +17: All tests passed!
flutter test test/features/pairing/presentation/invite_screen_test.dart
  -> 00:01 +16: All tests passed!
```

### New unit cases (`invite_cubit_test.dart`, 13 added)

| Case | Covers |
| --- | --- |
| `exposes the 4 backend literals in catalog order` | wire literals + card order |
| `parses every wire value and degrades unknown ones to null` | all 4 mappings, `LONG_TERM`, `''`, `null` |
| `every wire value exists in the generated client enum` | guards `_wireCoupleType`'s `firstWhere` against a `StateError` at tap time |
| `pre-fills the selection from the profile on the first ready state` | AC5, asserted on the *first* emitted `InviteReady`, not the settled state |
| `a profile read resolving after the code still pre-fills` | late profile read re-emits once |
| `a failing profile read still reaches InviteReady unselected` | profile failure never becomes `InviteFailed` |
| `an unknown persisted value leaves every card unselected` | legacy/unknown inbound value |
| `the selection replaces the previous one instead of adding` | AC3 at cubit level |
| `the selection survives a countdown tick` | the solution.md "most likely defect" row — injected `timerFactory` tick keeps the selection and still advances `remaining` to 23h40m |
| `submitCoupleType persists the selection once and returns true` | AC4, captured argument asserted as `LIVING_TOGETHER` |
| `a second submit while the write is in flight is ignored` | `isSaving` latch, save seam called exactly once |
| `submitCoupleType keeps the selection when the write fails` | failure is retryable in place |
| `submitCoupleType is a no-op with nothing selected` | AC2 at cubit level |

### New widget cases (`invite_screen_test.dart`, 7 added)

All mount the real `InviteScreen` (not the section widget in isolation) in the
`vi` locale named by the phase test scope, on a 600x1400 surface so the CTA is
inside the viewport and `tester.tap` cannot silently miss.

| Case | Covers |
| --- | --- |
| `AC1: the picker sits between the code card and the CTA, in catalog order` | 4 cards present, code card above them, catalog order by dx/dy, CTA last |
| `AC2: the CTA is disabled until a card is chosen` | `CupidPrimaryButton.onPressed == null` at 0 selections, non-null after one tap |
| `AC3: choosing a second card swaps the selection` | exactly one card reports `selected: true` before and after the swap |
| `AC4: Continue persists the chosen card as its wire value` | save seam called once with `SAME_CITY`; screen does not navigate (STORY-002 owns that) |
| `AC5: a persisted couple type is selected on the first paint` | pre-selection visible on the first pump, CTA already enabled |
| `a failed write keeps the selection and offers a retry` | vi snackbar copy, selection kept, CTA re-enabled |
| `AC7: joincode carries no couple-type card` | `JoincodeScreen` renders no heading, no card label, and no card semantics |

Required assertion evidence from the phase test scope:

- Save seam captured its argument as the expected wire literal —
  `expect(saved.single.wireValue, 'LIVING_TOGETHER')` (unit) and
  `expect(saved, <CoupleType>[CoupleType.sameCity])` with
  `expect(saved.single.wireValue, 'SAME_CITY')` (widget).
- Exactly one card reports `selected: true` after a selection change —
  `expect(_coupleCardSemantics(tester).where((p) => p.selected == true), hasLength(1))`,
  asserted after both the first and the second tap.

Harness note: `_harness` now attaches `AppL10n.localizationsDelegates` /
`AppL10n.supportedLocales` and takes an optional `locale`. The pre-REQ-009
cases pass no locale and still resolve to the binding's `en-US`, so their
English assertions are unchanged (confirmed by the 9 pre-existing cases in that
file passing).

## 4. Build

```bash
flutter build apk --debug
```

Result:

```text
Running Gradle task 'assembleLocalDebug'...                        40.7s
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
```

PASS. The `local` flavor is REQ-008's default debug variant, so the plain
`--debug` invocation resolves to `assembleLocalDebug`. Gradle emitted only
pre-existing warnings (JDK restricted-method notice, the `sign_in_with_apple`
KGP deprecation notice, and Java deprecation notes) — none from this change.

## 5. Coverage Of The Phase Acceptance Criteria

| AC | Gate | Result |
| --- | --- | --- |
| AC1 four cards in catalog order below the code card | widget `AC1:` case | PASS |
| AC2 Continue disabled with nothing selected | widget `AC2:` + unit no-op case | PASS |
| AC3 single-select, second tap swaps | widget `AC3:` + unit replace case | PASS |
| AC4 Continue persists the mapped wire value | widget `AC4:` + unit submit case | PASS |
| AC5 persisted value pre-selected on first paint | widget `AC5:` + unit first-ready case | PASS |
| AC7 joincode unaffected | widget `AC7:` case | PASS |
| Selection survives a countdown tick | unit tick case | PASS |
| `flutter analyze` clean, `flutter build apk --debug` succeeds | sections 2 and 4 | PASS |

## Visual Fidelity — Couple-Type Cards

> Added in the PATCH_REQUIRED F1 evidence pass (2026-08-24). Evidence-only:
> no `mobile/lib/` file was modified by this pass. Every delta below is a
> finding for the review gate / a follow-up story, not a fix landed here.
>
> **Superseded by the F3/F4 rework pass — see "PATCH_REQUIRED F3/F4 Rework"
> at the end of this file.** The proposal to defer these deltas was rejected
> at the cycle-2 review gate; all four deltas plus R1/R2/R3/R6 are now fixed
> in `invite_screen.dart`, and R7/R8/R4/R5 carry explicit accepted-deviation
> decisions. The `invite_screen.dart` line numbers cited in the tables below
> are as of that earlier pass and have since moved.

### Render command (design side — RESOLVED)

Run from the CONTROL checkout (`.ai-team-bundle/` is gitignored, so the tool
does not exist inside the story worktree), with `--location` pointed at the
worktree's design bundle:

```bash
# once, this session: Playwright was not provisioned
.ai-team-bundle/runtime/ensure-runtime.sh --capability=visual-inspection
# -> Ensured runtime provider: playwright / Capabilities: visual-inspection

node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --surface=mobile \
  --entry="Cupid App.dc.html" \
  --location="<worktree>/cupid-app-design-system" \
  --screen=invite --platform=android --theme=dark --lang=vi \
  --out="<story>/visual-fidelity"
DESIGN_CANVAS: OK .../design-reference-invite-android.png 406x900
```

Output renamed to
`visual-fidelity/design-reference-invite-couple-type-android.png` (406x900,
android / dark / vi) so it does not collide with REQ-001/STORY-018's
same-named capture.

Entry-file correction vs the handoff wording: the authoritative *markup* for
this node is `cupid-app-design-system/Cupid Screens.dc.html` lines 168-203
(`<sc-if value="{{ isInvite }}">`), and that is what the render shows — but
`Cupid Screens.dc.html` cannot be the `--entry`. Rendered standalone it
enumerates `screens: []` / `screens_from: "none"` and
`--theme=dark` fails with `DESIGN_CANVAS_TOGGLE_MISSING: 'dark' is not a
toggle on this canvas. Available toggles: (none).` It is the screen library;
`Cupid App.dc.html` is the app shell that composes it and owns the
`screen`/`platform`/`theme`/`lang` toggles. `--entry="Cupid App.dc.html"
--screen=invite` enumerates 37 screens including `invite` and renders the
`isInvite` block from `Cupid Screens.dc.html`. Same relationship STORY-002
used for `pairingchoice`.

No `design-fidelity-config.json` edit was attempted or needed — the render
works against an unregistered node via explicit `--entry`/`--location`
flags.

**Implemented-side device capture: DEVICE_CAPTURE_BLOCKED** (known emulator
storage constraint, not retried). The comparison below is therefore
design-render vs source inspection, per the handoff's explicit scope.

### The 4 documented deltas — all CONFIRMED

Design side cited as `Cupid Screens.dc.html:<line>`; built side as
`mobile/lib/features/pairing/presentation/screens/invite_screen.dart:<line>`.
Token values: `CupidSpacing.xs=4`, `sm=8`, `md=16`, `lg=24`
(`mobile/lib/design_system/tokens/cupid_spacing.dart:8-11`).

| # | Delta | Design source | Built side | Verdict |
| --- | --- | --- | --- | --- |
| 1 | Heading subtext line missing | `:181` — `font-size:12.5px;color:var(--tx2);margin-bottom:12px`, "Cupid sẽ bật/tắt tính năng phù hợp cho kiểu của bạn." directly under the `:180` heading | `invite_screen.dart:547-558` — heading `Text` → `SizedBox(height: CupidSpacing.md)` → `_CoupleTypeGrid`. No second `Text` exists between them | CONFIRMED — the line is absent from the build |
| 2 | Icon is a bare glyph, not a 38x38 rounded tile | `:186` selected — `width:38px;height:38px;border-radius:13px;background:var(--grad-hot)` wrapping a `font-size:21px;color:#fff` glyph; `:193` unselected — same box with `background:var(--surf2)` and `font-size:21px;color:var(--tx2)` | `invite_screen.dart:715-721` — `CupidIcon(coupleType.icon, size: _coupleIconSize, color: colors.colorText)` with no wrapping `Container`. `_coupleIconSize = 28` (`:72`) | CONFIRMED — no tile; glyph is 28px not 21px; glyph color is fixed `colorText` in both states, so the selection signal the tile fill carries in the design is missing entirely |
| 3 | Card content centered, not left-aligned | `:185`-`:196` — plain block `div`s with no `text-align` / no flex centering; the 38px tile sits at the block's leading edge, label and hint are left-aligned under it | `invite_screen.dart:712-714` — `Column(mainAxisSize: MainAxisSize.min, ...)` at default `crossAxisAlignment: CrossAxisAlignment.center`, reinforced by `textAlign: TextAlign.center` on the label (`:725`) and the subtext (`:738`) | CONFIRMED |
| 4 | Cell padding transposed | `:185` and `:192` — `padding:16px 14px` = **16 vertical / 14 horizontal** | `invite_screen.dart:677-680` — `EdgeInsets.symmetric(vertical: CupidSpacing.md, horizontal: CupidSpacing.sm)` = **16 vertical / 8 horizontal** | CONFIRMED — vertical matches at 16; horizontal is 8 vs the design's 14 (−6px per side) |

### Refinements found while confirming (not in Pink-Designer's list)

All are on the same node and visible in the render; none is fixed here.

| # | Aspect | Design source | Built side | Note |
| --- | --- | --- | --- | --- |
| R1 | Icon-tile → label gap | `:187`/`:194` — `margin-top:10px` | `invite_screen.dart:722` — `SizedBox(height: CupidSpacing.xs)` = 4 | ux-spec §6.8 specifies `CupidSpacing.xs` (4px); the design says 10px. The **spec** is wrong here, not just the build |
| R2 | Label → subtext gap | `:188`/`:195` — `margin-top:3px` | `invite_screen.dart:735` — `_coupleLabelGap = 2` (`:73`) | 2 vs 3; ux-spec §6.8 also says 2px |
| R3 | Grid gutter | `:182` — `gap:10px` (both axes) | `invite_screen.dart:582` (row gap) and `:616` (column gap), both `CupidSpacing.sm` = 8 | 8 vs 10, both axes |
| R4 | Label / subtext type scale | `:187` label `14.5px`; `:188` hint `11.5px` — visibly two different sizes | `invite_screen.dart:726` and `:739` both use `type.caption` = `fontSize: 13` (`mobile/lib/design_system/tokens/cupid_typography_tokens.dart:53-56`), differing only by weight | The design's label/hint size contrast (14.5 vs 11.5) collapses to a single 13px size in the build; only `w700/w600` vs `w400` distinguishes them |
| R5 | Selected label weight | `:187` — `font-weight:800` | `invite_screen.dart:730-732` — `FontWeight.w700` | matches ux-spec §6.8, which itself says w700 |
| R6 | Selected fill alpha | `:185` — `rgba(255,127,182,.22)` → `rgba(183,140,245,.22)`, i.e. **both .22** | `invite_screen.dart:88-89` — `_coupleSelectedPinkOpacity = 0.3`, `_coupleSelectedPurpleOpacity = 0.26` | Build is denser than the design on both stops. The 0.3/0.26 pair is `_MoodCell`'s, inherited via the "reuse `VibeMoodGrid`'s treatment" decision — an intentional-looking divergence, but a divergence |
| R7 | Section heading size | `:180` — `font-size:16px;font-weight:700` | `invite_screen.dart:552-555` — `type.body` = `fontSize: 17` + `w700` | 17 vs 16 |
| R8 | Vertical rhythm around the section | `:169` — the invite body is `display:flex;flex-direction:column;gap:20px`, so code-card → section → CTA gaps are both 20px | ux-spec §6.8 / build use `CupidSpacing.lg` = 24 | 24 vs 20 |
| R9 | Glyph choice, cards 3 and 4 | `:1827` `icon: 'potted_plant'`; `:1828` `icon: 'diamond'` | `couple_type.dart:48` `_autoAwesomeIcon` (0xe65f); `:61` `_allInclusiveIcon` (0xeb3d) | Deliberate: ux-spec §6.7's glyph table substituted these against the PO catalog's "sparkle-heart"/"infinity-heart" hints. Recorded so the review gate sees the render's plant/diamond glyphs are *not* a build defect |
| R10 | Card copy | `:1825`-`:1828` — labels "Mới yêu" / "Yêu lâu rồi"; hints "Bật cảm giác hiện diện", "Ưu tiên gamification", "Nhắc nhẹ, ít áp lực", "Tập trung tài chính" | `couple_type.dart:33-65` — PO catalog copy ("Mới hẹn hò", "Gắn bó lâu dài", and the four descriptive subtexts) | Build is correct: ux-spec §6.7 states the PO catalog in `requirements/requirements.md` is reused verbatim and supersedes the canvas's placeholder copy. Not a delta to fix |
| R11 | Continue CTA label | `:201` — `onClick="{{ goVow }}"`, "Tiếp tục → Fingerprint Vow" | Build renders "Tiếp tục" and does not navigate (STORY-002 owns the destination, and REQ-009 explicitly removes the post-code vow edge) | Build is correct; the canvas line is the pre-REQ-009 edge |

### What the render confirms structurally

The rendered frame shows, top to bottom: back chrome → code card
(`CPD-8F2K`, expiry line, Share/Copy row) → heading "Tụi mình thuộc kiểu
nào?" → the subtext line → a 2x2 grid of 4 icon-tile cards with the second
card in the selected state (gradient tile, pink border, glow) → full-width
gradient CTA. Ordering, grouping, and the 2x2 shape all match the build
(AC1, asserted at `mobile/test/features/pairing/presentation/invite_screen_test.dart:442-476`).
The deltas are confined to the cards' internal composition and metrics.

## Entry Point Reachability

UI-facing story: YES. **Reachable: YES** — proven by existing tests, no new
test written (this pass is evidence-only).

The couple-type section is not reachable by itself: `_CoupleTypeSection`,
`_CoupleTypeGrid`, `_CoupleTypeRow`, and `_CoupleTypeCell`
(`invite_screen.dart:531`, `:565`, `:593`, `:634`) are all library-private to
`invite_screen.dart` and cannot be mounted in isolation from a test. Every
assertion about them necessarily goes through the real `InviteScreen`.

Chain from real app navigation to the couple-type cards:

| Link | Evidence |
| --- | --- |
| App wiring: the unpaired branch of the pair gate renders the pairing stack | `mobile/lib/core/navigation/pair_gate_shell.dart:139` — `PairGateUnpaired() => PairingChoiceScreen(...)`; the stack key is `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart:64` (`Key('pairing_stack')`). Also route-registered at `mobile/lib/core/di/service_locator.dart:410` (`OnboardingNode.pairingChoice`) |
| The pairing stack really renders and its primary CTA really pushes the real `InviteScreen` | `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart:46-55` (`find.byKey(const Key('pairing_stack'))` `findsOneWidget`) and `:57-66` — taps "Pair with your partner" then `expect(find.byType(InviteScreen), findsOneWidget)` with `pairing_stack` now `findsNothing` (a real push, not a rebuild) |
| The pushed `InviteScreen` renders the couple-type section, in place, in order | `mobile/test/features/pairing/presentation/invite_screen_test.dart:442-476` (AC1) — harness mounts the real `InviteScreen` as `home:` (`:73-104`), then asserts the heading `:456`, the 4 card labels `:457+`, 4 card semantics `:461`, and their dx/dy ordering between the code card and the CTA `:463+` |
| A pushed-route mount (not just `home:`) also reaches the same screen | `mobile/test/features/pairing/presentation/invite_screen_test.dart:397-440` — `InviteScreen` built inside a `MaterialPageRoute` and popped back out |

Re-confirmed by a green run when this section was written, so the claim rests
on a passing suite rather than on reading alone:

```
flutter test --no-pub --reporter compact \
  test/features/pairing/presentation/invite_screen_test.dart \
  test/features/pairing/presentation/screens/pairing_choice_screen_test.dart
00:02 +21: All tests passed!
TEST_EXIT=0
```

Design-side reachability is separately confirmed by the render above:
`--list-screens` on `Cupid App.dc.html` returns `invite` among 37 screens
(`screens_from: "dom"`), so the node is enumerable, not orphaned.

Reachable: YES

(Entry path: `pair_gate_shell.dart:139` (`PairGateUnpaired`)
→ `pairing_choice_screen.dart` (`pairing_stack`) → `invite_screen.dart`
(`InviteScreen`), confirmed via `pairing_choice_screen_test.dart:46-66` and
`invite_screen_test.dart:397-476` (`+21` passed).)

## 6. Files Changed

- `mobile/lib/features/pairing/presentation/couple_type.dart` (new)
- `mobile/lib/features/pairing/presentation/invite_cubit.dart`
- `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`
- `mobile/lib/main_preview.dart`
- `mobile/test/features/pairing/presentation/invite_cubit_test.dart`
- `mobile/test/features/pairing/presentation/invite_screen_test.dart`

Added by the PATCH_REQUIRED F1/F2 evidence pass (no `mobile/` change):

- `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/visual-fidelity/design-reference-invite-couple-type-android.png` (new)

## PATCH_REQUIRED F3/F4 Rework (cycle 3, 2026-08-24)

Closes `review/review-report.md` cycle-2 findings F3 and F4. Unlike the F1/F2
pass, this one **does** modify `mobile/lib/`.

### F3 — the four confirmed deltas, landed

| # | Delta | Change in `invite_screen.dart` |
| --- | --- | --- |
| 1 | Supporting subtext line missing | `_CoupleTypeSection` now renders heading → `4`px → subtext `Text` (`caption`/`w400`/`colorTextMuted`, `viEn('Cupid sẽ bật/tắt tính năng phù hợp cho kiểu của bạn.', 'Cupid tunes default features to your type.')`) → `12`px → grid |
| 2 | Bare glyph, no tile | The glyph is wrapped in a `38`x`38` `Container`, `BorderRadius.circular(13)`, `gradient: colors.gradientHot` when selected / `color: colors.colorSurfaceAlt` when not, `alignment: Alignment.center`. `_coupleIconSize` 28 → `21`. Glyph color is now state-driven: `colors.colorOnAccent` selected / `colors.colorTextMuted` unselected — this is the actual selection signal the design carries and the build did not |
| 3 | Content centered | Cell `Column` gains `crossAxisAlignment: CrossAxisAlignment.start`; both `textAlign: TextAlign.center` occurrences (label, subtext) removed |
| 4 | Cell padding transposed | `horizontal: CupidSpacing.sm` (8) → `_coupleCellHorizontalPadding` (`14`); vertical stays `CupidSpacing.md` (16) |

Token mapping used for the tile, confirmed against
`mobile/lib/design_system/tokens/cupid_color_tokens.dart`: design `--grad-hot`
→ `gradientHot`; `--surf2` → `colorSurfaceAlt`; the selected glyph's `#fff` →
`colorOnAccent`, whose dartdoc names its role as exactly "text/icon glyph
rendered on top of `gradientHot`"; `--tx2` → `colorTextMuted`. No raw color
literal was introduced — `test/design_system/no_fork_guard_test.dart` still
passes (see below).

### R1-R8: every listed divergence now has an explicit decision

| # | Aspect | Design | Decision | Now |
| --- | --- | --- | --- | --- |
| R1 | Icon-tile → label gap | `:187` `margin-top:10px` | **Transcribe.** Reviewer-directed; the spec's `CupidSpacing.xs` was the wrong side of the gap | `_coupleIconLabelGap = 10` |
| R2 | Label → subtext gap | `:188` `margin-top:3px` | **Transcribe.** Reviewer-directed | `_coupleLabelGap` 2 → `3` |
| R3 | Grid gutter, both axes | `:182` `gap:10px` | **Transcribe.** Same family as the already-transcribed 14px cell padding — this grid's own geometry, not shared screen rhythm. The spec's stated reason for using the token ("no off-scale geometry to transcribe") was false once the source resolved | `_coupleGridGutter = 10` |
| R4 | Label vs subtext type scale | `:187` 14.5px / `:188` 11.5px | **Accepted deviation.** Both stay `type.caption` (13px), distinguished by weight | unchanged |
| R5 | Selected label weight | `:187` `font-weight:800` | **Accepted deviation.** Stays `w700`, matching ux-spec §6.8 and every other selected-card label in the app | unchanged |
| R6 | Selected fill alpha | `:185` `.22` on both stops | **Transcribe.** The 0.3/0.26 pair was inherited from `_MoodCell`, never decided for this screen. The 140deg direction pair still comes from `_MoodCell`; only the alphas are this screen's own | `_coupleSelectedPinkOpacity`/`PurpleOpacity` both `0.22` |
| R7 | Section heading size | `:180` 16px | **Accepted deviation.** Stays `type.body` (17px) | unchanged |
| R8 | Section vertical rhythm | `:169` `gap:20px` | **Accepted deviation.** Stays `CupidSpacing.lg` (24px) | unchanged |
| — | Heading → subtext gap | `:180` `margin-bottom:4px` | **Transcribe.** Settles the §6.5:132 / §6.3:107 three-numbers-for-two-gaps inconsistency the reviewer flagged | `_coupleHeadingSubtextGap = 4` |
| — | Subtext → grid gap | `:181` `margin-bottom:12px` | **Transcribe.** Same settlement; §6.3's `CupidSpacing.md` (16) was the third number | `_coupleSubtextGridGap = 12` |

Basis for the three accepted deviations (R4/R5/R7 are one call, R8 another):

- **R4/R5/R7 — type scale.** All three are 0.5-1.5px or one weight step off the
  nearest token. `CupidTypographyTokens.caption`'s own dartdoc records that the
  design source draws small supporting text at five sizes (11/11.5/12/12.5/13px)
  which the `caption` role deliberately collapses into one. Transcribing
  per-call-site literals here would fork the type scale for a single section and
  diverge from every screen already shipped against these tokens. ux-spec §6.8
  prescribes token names for typography, and that prescription is unchanged.
- **R8 — section rhythm.** `CupidSpacing` has no 20px step, and this gap is not
  local to the new section: the design's `gap:20px` is on the invite body's
  outer flex column, so it also governs the spacing above `_InviteCodeCard`,
  which is pre-existing and out of this story's scope. Moving one of the two
  gaps to 20px would make the screen internally inconsistent; moving both would
  edit untouched code. 4px on one gap class, token-driven.

Both decisions are transcribed into `ux/ux-spec.md` §6.7/§6.8 so the spec and
the build no longer disagree.

Nothing from the review's list is left unstated. R9/R10/R11 remain non-defects
on the reviewer's own agreement and were not reopened.

### F4 — `ux-spec.md` §6.8 corrections landed

| Claim | Action |
| --- | --- |
| "This source has been registered as an additional entry in `design_sources[]` (`id: "cupid-screens"`)" | **Retracted** in an explicit `Retraction (PATCH_REQUIRED F4)` paragraph replacing the original sentence. `design-fidelity-config.json` has exactly two entries, `cupid-app` and `cupid-web` |
| "Scrum Master/DevOps must land the registration ... before the rendered-fidelity gate can run automated capture" | **Deleted.** The render was produced with no config change, through the already-registered, locked `cupid-app` source. No DevOps dependency is parked on any later story |
| `render-design-canvas.js --screen=invite` against `Cupid Screens.dc.html` | **Corrected** to `--entry='Cupid App.dc.html' --screen=invite`, with the reason inline (standalone the library enumerates `screens: []` / `screens_from: "none"` and `--theme=dark` fails `DESIGN_CANVAS_TOGGLE_MISSING`). `Cupid Screens.dc.html:168-203` is kept named as the authoritative *markup* |
| R1/R2 corrections `story_master.md` claimed had landed in the spec but had not | **Landed** in both §6.5 and §6.8: icon-tile→label `10`px, label→subtext `3`px |
| §6.5:132 / §6.3:107 gap-number inconsistency | **Reconciled** against design `:180`/`:181` — 4px and 12px, stated identically in §6.3, §6.5, and §6.8 |
| §6.7 "no off-scale custom values needed for this section" | **Corrected** — that rested on the retracted no-design-source premise and contradicted the transcribed values |

### Test evidence (this pass)

`flutter analyze`, touched files only:

```
$ flutter analyze --no-pub \
    lib/features/pairing/presentation/screens/invite_screen.dart \
    test/features/pairing/presentation/invite_screen_test.dart
Analyzing 2 items...
No issues found! (ran in 2.2s)
```

The AC-bearing suite. `AC1:` was updated for the new composition: it now
asserts the subtext line exists and sits between the heading and the grid, and
that the cell block is left-aligned — labels of differing width within a column
share a left edge (`longDistance.dx == dating.dx`), and each cell's subtext
starts on that same edge. Under the old centered layout those equalities were
false, so this is a real regression guard for finding 3, not a relaxed
assertion.

```
$ flutter test --no-pub --reporter compact \
    test/features/pairing/presentation/invite_screen_test.dart
00:03 +16: All tests passed!

$ flutter test --no-pub --reporter compact \
    test/features/pairing/presentation/invite_cubit_test.dart \
    test/features/pairing/presentation/screens/pairing_choice_screen_test.dart
00:03 +22: All tests passed!
```

16 + 22 = 38 cases, matching the reviewer's cycle-2 baseline of 38 — no case
was dropped to make the patch pass.

Because the patch adds token lookups (`gradientHot`, `colorSurfaceAlt`,
`colorOnAccent`), the no-fork guard was re-run:

```
$ flutter test --no-pub --reporter compact \
    test/design_system/no_fork_guard_test.dart
00:02 +1: All tests passed!
```

### AC6 status after this pass

All four confirmed deltas and R1/R2/R3/R6 are fixed in the build. R4/R5/R7/R8
are stated, decided, and now consistent between spec and build. The verdict
itself is in `visual-fidelity/visual-fidelity-report.md`, which this pass adds
so an automated gate can read a `VISUAL_FIDELITY:` line (the cycle-2 residual
risk).

### Files changed by this pass

- `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`
- `mobile/test/features/pairing/presentation/invite_screen_test.dart`
- `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/ux/ux-spec.md`
- `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/coding-plan/test-results.md`

## Story Runtime Startup Smoke

DevOps device-capture pass for cycle-3 review findings B1 (`VISUAL_FIDELITY:
PASS` asserted with no implemented-side device screenshot ever captured) and
B2 (this section was missing entirely).

Build command:

```
$ flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=invite
Running Gradle task 'assembleLocalDebug'...     14.0s
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
```

Install target: `emulator-5554` (`sdk_gphone64_arm64`), package
`com.snapsofts.cupid`, installed via `adb install -r` — `Success`.

Launch/boot confirmation: launched via `adb shell monkey -p com.snapsofts.cupid
-c android.intent.category.LAUNCHER 1`. `adb shell dumpsys window` reported
`mCurrentFocus=Window{... com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity}`
after launch, confirming the app boots to and holds the invite couple-type
picker screen (`PREVIEW=invite`) without crashing. `adb logcat -d "*:E"`
filtered for `com.snapsofts.cupid`/`FATAL`/`AndroidRuntime` returned no
matches — no runtime exception.

Screenshot captured: `adb exec-out screencap -p >
visual-fidelity/implemented-invite-couple-type-android.png` (relative to this
story's directory) — confirms the "Cùng thành phố" card renders selected per
the `fetchCoupleType: () async => 'SAME_CITY'` preview fixture in
`mobile/lib/main_preview.dart`.

This pass captures only the raw device screenshot; it does not edit
`visual-fidelity/visual-fidelity-report.md`'s verdict tables or per-finding
verdict lines — a follow-up mobile-dev pass owns the visual comparison and
verdict correction.
- `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/visual-fidelity/visual-fidelity-report.md` (new)

Result: PASS

(Build succeeded, install succeeded via `adb install -r` → `Success`, launch
confirmed via `adb shell dumpsys window` reporting `mCurrentFocus` on
`com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`, `adb logcat -d
"*:E"` clean of `FATAL`/`AndroidRuntime` across the startup window.)

## D1 — Grid column equal-width fix

Fixes the one blocking defect from the device-capture comparison pass,
`visual-fidelity/visual-fidelity-report.md` → `### D1 — grid columns are
unequal width (FAIL)`: on the captured 411.4dp device the two couple-type
columns measured 185.9dp and 175.6dp instead of the design's equal `1fr 1fr`
tracks (180.7dp each).

### What changed

`mobile/lib/features/pairing/presentation/screens/invite_screen.dart:631-643`
(`_CoupleTypeRow.build`). The inter-card gutter moved from a per-cell `Padding`
inset to a `SizedBox` sibling between the two `Expanded` cells.

Before — the gutter was subtracted from the right cell only, after `Expanded`
had already split the row into two equal flex shares, so that one cell ended up
exactly one gutter (10dp) narrower:

```dart
for (final (int index, CoupleType coupleType) in coupleTypes.indexed)
  Expanded(
    child: Padding(
      padding: EdgeInsets.only(
        left: index == 0 ? 0 : _coupleGridGutter,
      ),
      child: _CoupleTypeCell(...),
    ),
  ),
```

After — the gutter is laid out as a fixed-width sibling first, so `Expanded`
splits only the remaining width and both tracks resolve equal:

```dart
for (final (int index, CoupleType coupleType) in coupleTypes.indexed)
  ...<Widget>[
    if (index > 0) const SizedBox(width: _coupleGridGutter),
    Expanded(
      child: _CoupleTypeCell(...),
    ),
  ],
```

Geometry on the captured device: content width `411.4 - 20 - 20 = 371.4`dp.
Old composition gave `371.4 / 2 = 185.7` and `185.7 - 10 = 175.7` (matching the
report's measured 185.9 / 175.6). New composition gives
`(371.4 - 10) / 2 = 180.7` for both cells — the spec value.

Nothing else moved: `_coupleGridGutter` keeps its `10` value, the row gap, cell
padding, colors, and the 6 accepted deviations in the report are untouched.

### Regression guard added

`mobile/test/features/pairing/presentation/invite_screen_test.dart:504-539`,
`D1: the two grid columns are equal width, split by one gutter`. It measures
each cell's `GestureDetector` rect for both rows and asserts the two column
widths are equal and that the space between them is exactly one
`_coupleGridGutter` (10).

The guard was verified red against the pre-fix composition (old `Padding`
version temporarily restored, guard re-run, fix re-applied):

```
$ flutter test --no-pub --reporter compact \
    --plain-name 'D1: the two grid columns are equal width, split by one gutter' \
    test/features/pairing/presentation/invite_screen_test.dart
Expected: a numeric value within <0.01> of <270.0>
  Actual: <280.0>
   Which:  differs by <10.0>
invite_screen_test.dart line 533
00:02 +0 -1: Some tests failed.
```

280 vs 270 on the 600dp test surface is the same one-gutter asymmetry the device
capture measured at 185.9 / 175.6 — so this is a real regression guard, not a
restatement of the fix.

No existing assertion was weakened or removed; the case count grew 16 → 17 in
`invite_screen_test.dart`.

### Test evidence

```
$ flutter analyze --no-pub \
    lib/features/pairing/presentation/screens/invite_screen.dart \
    test/features/pairing/presentation/invite_screen_test.dart
Analyzing 2 items...
No issues found! (ran in 1.9s)
```

```
$ flutter test --no-pub --reporter compact \
    test/features/pairing/ test/design_system/no_fork_guard_test.dart
00:04 +128: All tests passed!
```

128 = the 126-case `test/features/pairing/` baseline measured before this fix,
plus the new D1 guard, plus the no-fork guard case.

### Out of scope for this pass

No device/emulator recapture was run and
`visual-fidelity/visual-fidelity-report.md` was not edited — D1's verdict line
still reads FAIL there. A separate DevOps recapture plus a narrow mobile-dev
verdict-correction pass owns that update.

### Files changed by this pass

- `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`
- `mobile/test/features/pairing/presentation/invite_screen_test.dart`

## Post-fix device recapture (D1)

DevOps recapture pass for the D1 grid-column-gutter fix landed in commit
`dbaaf7b6b696122858c4c2725db83e9eb323cb25` on this story branch.

Build command:

```
$ flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=invite
Running Gradle task 'assembleLocalDebug'...     12.7s
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
```

Install target: `emulator-5554`, package `com.snapsofts.cupid`, installed via
`adb install -r` — `Success`.

Launch/boot confirmation: launched via `adb shell monkey -p com.snapsofts.cupid
-c android.intent.category.LAUNCHER 1`. `adb shell dumpsys window` reported
`mCurrentFocus=Window{... com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity}`
after launch, confirming the app boots to and holds the invite couple-type
picker screen (`PREVIEW=invite`) without crashing. `adb logcat -d "*:E"`
filtered for `FATAL`/`AndroidRuntime` returned no matches.

Screenshot captured: `adb exec-out screencap -p >
visual-fidelity/implemented-invite-couple-type-android.png` (relative to this
story's directory) — overwrote the prior pre-fix capture. Resulting image:
1080x2400 PNG, "Cùng thành phố" card selected per the
`fetchCoupleType: () async => 'SAME_CITY'` preview fixture.

This pass captures only the raw device screenshot; it does not edit
`visual-fidelity/visual-fidelity-report.md`'s verdict tables or the D1
PASS/FAIL line — a follow-up mobile-dev pass owns the pixel comparison and
verdict correction.
- `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/coding-plan/test-results.md`
