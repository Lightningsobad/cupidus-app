# STORY-052 Visual Fidelity Report — chat header pairing title + partner presence chip

VISUAL_FIDELITY: PASS

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-052_chat_header_partner_presence_hardening
- Phase: P2 (header slot + presence chip)
- Role: mobile-dev
- Date: 2026-08-18
- Branch: `main`
- BaseHead: `ecf1303990347e1e9e47937dd155169becc4b180`
- Worktree: `/Users/alantravala/workspace/snapsofts/cupid-apps`
- Audited configuration: Android, dark theme, `vi` locale, `chat` screen
- Design source: `data/devops/system/design-fidelity-config.json` —
  `locked: true`, `ui_surface: true`, `entry: "Cupid App.dc.html"`,
  `project_dir: cupid-app-design-system/project`,
  `content_fingerprint: sha256:44c8b209b27dc5f8a4728a151caf7fa164d38d4f4a144b3157c291b2c1cf2c58`

## 1. Evidence set

| Artifact | Path | Size | Origin |
| --- | --- | --- | --- |
| Design reference | `visual-fidelity/design-reference-chat-android.png` | 406x900 | Rendered fresh for this story from the locked canvas bundle |
| Implemented capture | `visual-fidelity/implemented-chat-emulator-5560.png` | 405x900, 135575 bytes | Captured from the delivered source on `emulator-5560` |

Both files are this story's own pair. STORY-040's pair was not reused, per
`coding-plan/phase-P2-header-slot-and-presence-chip.md` §6.

### Design reference render command

```bash
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system/project \
  --entry='Cupid App.dc.html' \
  --out=data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-052_chat_header_partner_presence_hardening/visual-fidelity \
  --screen=chat --platform=android --theme=dark --lang=vi \
  --label=chat --max-edge=900
```

Result: `DESIGN_CANVAS: OK .../design-reference-chat-android.png 406x900`

`--location` and `--entry` are required here: the bundle holds several
`.dc.html` files, so an unqualified run stops with
`DESIGN_CANVAS_ENTRY_AMBIGUOUS`. Both values are read from the locked
`design-fidelity-config.json`, not chosen by hand.

### Implemented capture commands

The preview build carries P1's populated chat fixture
(`mobile/lib/main_preview.dart:405-410` — `selfDisplayName: 'Minh'`,
`partnerDisplayName: 'Linh'`), so both identity halves are exercised:

```bash
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=chat --dart-define=PREVIEW_CHAT_GHOST=on
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

```bash
.ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
  --lease-exec --device=emulator-5560 -- bash -c '
    adb -s emulator-5560 shell am start -a android.intent.action.VIEW \
      -d "cupidpreview://screen/chat"
    sleep 22
    .ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
      --out=data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-052_chat_header_partner_presence_hardening/visual-fidelity \
      --label=chat --device=emulator-5560 \
      --width=406 --density=160 --settle-ms=1500'
```

Result: `MOBILE_CAPTURE: OK .../implemented-chat-emulator-5560.png 405x900 135575`

Notes on capture method:

- The first attempt used a 6s settle and caught the Flutter splash screen; a
  cold debug-build boot needs longer. Raised to 22s plus `--settle-ms=1500`.
- `--density=160` makes 1dp = 1px, so every measurement below is a direct
  dp reading with no scaling arithmetic.
- The device display resize is temporary and restored on EXIT by the tool.
  Post-run state confirmed clean: `wm size` -> `Physical size: 1080x2400`,
  `wm density` -> `Physical density: 420`.
- `emulator-5560` was already running and was not provisioned by this lane.

## 2. Why this report measures geometry instead of diffing pixels

STORY-051 proved its change with a per-pixel `ImageChops.difference` equality
check. That method does not transfer here. The design reference renders inside
a bezel device frame at a different scale (412x915 logical, emitted at 406x900),
while the implemented capture is device-native at 405x900 with no frame. A
per-pixel diff across those two coordinate spaces measures the frame offset,
not fidelity.

So the audit below pairs measured pixel geometry from the implemented capture
against the design source's declared metrics, and backs each claim with the
corresponding widget assertion in
`mobile/test/features/chat/presentation/chat_design_fidelity_test.dart`.

## 3. AC-by-AC audit

### AC2 — the header title is the pairing string, not a single name

Design source: `t_chat: 'Minh ↔ Linh'` (`Cupid Screens.dc.html`, lines
1773/1785) — a `<self> ↔ <partner>` composition.

Before this phase, `chat_screen.dart:167` passed
`title: widget.partnerDisplayName ?? ''`, which after P1's getter split
resolved to the partner's name alone. It now passes
`ChatStrings.headerPairingTitle(selfDisplayName:, partnerDisplayName:)`.

- Measured: title glyph run occupies the header's left region, ending well
  clear of the chip's left edge at x=299.
- Asserted: `expect(find.text('Minh ↔ Linh'), findsOneWidget)` with a store
  supplying the two halves independently (`_NamedPartnerStore`), so a header
  wired to the wrong getter cannot pass.
- Degradation asserted: a null/empty partner renders the self half alone, and
  a null/empty self renders the partner half alone. `find.textContaining('↔')`
  and `find.textContaining('null')` are both `findsNothing` in the
  missing-partner case — the separator is never left stranded and the string
  `"null"` never reaches the screen.

### AC3 — the presence chip renders the partner, with the v1 stub status

- Measured pill: x approximately 299-404, y approximately 59-91, so w approximately 106, h approximately 33.
  Expected height from the design source is 5 + 24 + 5 = 34; the 33px reading
  is the antialiased top/bottom edge row eroding by one.
- Measured width arithmetic: 6 (left pad) + 24 (avatar) + 7 (gap) + 58
  (measured `đang online` glyph run) + 10 (right pad) = 105 against a measured
  106. This independently confirms `EdgeInsets.fromLTRB(6, 5, 10, 5)` and the
  7dp gap without reading them back out of the widget.
- Measured corner radius: the pill's right cap insets from x=403 at y=70
  (vertical centre) to x=397 at y=62. For a fully rounded cap on a 33px-tall
  pill, the inset at 8px above centre is 16.5 − sqrt(16.5² − 13²) = 6.35.
  Measured 6. Matches `Radius.circular(999)` geometry exactly.
- Measured avatar: gradient bounding box 23x23 strict (24dp with one row of
  antialias erosion on each axis).
- Measured gradient direction: (310,66) = (7,192,168) ≈ `#00C9A7` at the
  top-left, ramping to (326,76) = (101,75,186) and (316,87) = (95,65,172)
  toward `#7B2FBE` at the bottom-right. This is the 135deg CSS direction the
  design source specifies, encoded as
  `Alignment(-0.7071067811865476, -0.7071067811865476)` ->
  `Alignment(0.7071067811865476, 0.7071067811865476)` in
  `mobile/lib/design_system/tokens/partner_chip_palette.dart`, following the
  `couple_presence_palette.dart:20-27` precedent.
- Measured online dot: peak (325,85) = (120,224,204) ≈ `#79E2CD` (121,226,205),
  landing exactly where an 8dp dot pinned at `right: -1, bottom: -1` on a 24dp
  avatar falls.
- Asserted: pill fill is `colorSurface` with `Radius.circular(999)` and
  `EdgeInsets.fromLTRB(6, 5, 10, 5)`; the gap `SizedBox.width == 7`; exactly
  two circular `BoxDecoration`s where `.first.gradient` is identically
  `PartnerChipPalette.avatarGradient` and `.last.color` is
  `_dark.colorGreen`; initial glyph fontSize 10 / w700 /
  `CouplePresencePalette.avatarInitial`; status text fontSize 11 /
  `colorTextMuted`; `Positioned.right == -1 && Positioned.bottom == -1`; and
  `circleSizes == <Size>[Size(24, 24), Size(8, 8)]`.
- Partner-scoped identity asserted: with `partner: 'linh'`, the avatar shows
  `'L'` and `find.text('M')` is `findsNothing`. The initial is uppercased from
  the partner's name, never the self's.
- Status copy asserted: `find.text('đang online')` under the `vi` locale.
  This is a fixed v1 stub per `story_master.md` AC3 — no real presence signal
  backs it, and the dartdoc on `ChatStrings.presenceChipStatus` says so.

### AC3 — the dot rings in the chip's own fill, not the page background

`ux/uiux-spec.md` §1.4 calls this out specifically. The chip sits on the
header's `colorSurface` pill, so a `colorBackground` ring (which is what
`home_screen.dart:458` correctly uses on the page background) would cut a
visibly wrong-coloured notch into the pill here.

- Asserted positively: `Border.all(color: _dark.colorSurface, width: 2)`.
- Asserted negatively: `isNot(Border.all(color: _dark.colorBackground, width: 2))`.
  The negative assertion is what stops a future copy-paste from
  `home_screen.dart` landing silently.
- An inline comment in `partner_presence_chip.dart` names the trap and points
  at the spec section.

### AC4 — accessibility

`ux/uiux-spec.md` §4 requires a semantics label on the title, because
assistive tech reads `↔` as "left right arrow", which carries no meaning.

- The title announces `Minh và Linh` — asserted via
  `tester.getSemantics(find.text('Minh ↔ Linh')).label`.
- The chip announces one coherent phrase, `Linh đang online`, replacing the
  three separate fragments it renders visually (initial glyph, colour swatch,
  status word). Asserted: `chip.label == 'Linh đang online'` and
  `chip.childrenCount == 0` (the `ExcludeSemantics` collapse).
- The chip carries no tap action:
  `chip.getSemanticsData().hasAction(SemanticsAction.tap)` is `isFalse`. It is
  a status indicator, not a control.

`CupidHeader.title` is a `String`, so §4's requirement was structurally
unreachable without an API addition — see deviation D-3.

### AC5 / AC6 — the other 16 `CupidHeader` consumers render identically

`CupidHeader` has 17 `lib/` consumers. The 16 that do not pass `trailing` must
build the exact tree they built before.

- iOS branch: an unset slot adds neither the widget nor the 10dp gap —
  asserted by filtering the header `Row` for `SizedBox` and expecting `empty`.
- Material branch: the required tree-identity assertion is
  `expect(tester.widget<AppBar>(find.byType(AppBar)).actions, same(actions));`
  — the `trailing == null` ternary hands back the caller's *own* list
  instance, so this is a literal identity check, not a structural equality
  check that a rebuilt-but-equal list would also satisfy.
- `titleSemanticLabel` defaults to null on both branches, leaving
  `Text.semanticsLabel` unset — asserted `isNull` for both platforms, which is
  exactly pre-change behavior.
- Both branches are wired. A single-branch wiring would have shipped a
  platform-only feature; the `${platform.name}` loop test covers
  `CupidPlatform.values` so neither branch can regress alone.

### ADR-004 — no forked platform/colour logic

`flutter test test/design_system/no_fork_guard_test.dart` passes. The new
gradient lives in `design_system/tokens/`, and no `Color(0x`, `Colors.`,
`Platform.is`, or `defaultTargetPlatform` was introduced under `lib/features`,
`lib/app`, or `lib/core`.

## 4. Deviations

### D-1 — `↔` renders as a colour emoji tile on Android (OPEN, routed out)

- Symptom: the design source shows a monochrome arrow. Android renders U+2194
  through the emoji font, producing a coloured tile in the header title.
- Root cause: U+2194 has an emoji presentation default.
- Attempted fix: appending U+FE0E (VARIATION SELECTOR-15, text presentation)
  to force the text form. Built, installed, and re-captured. The zoomed crop
  was visually identical — Flutter's Android font fallback still resolves the
  emoji font, so VS15 is a no-op here. The experiment was **fully reverted**:
  the production constant was removed and both test literals restored to
  `'Minh ↔ Linh'`. The chat suite was re-run green after the revert, and the
  evidence capture above was taken from the reverted (delivered) build.
- Remaining options, both out of this story's scope: (a) declare an explicit
  text-presentation font on the header title style, or (b) replace the glyph
  with a non-emoji separator. `ux/uiux-spec.md` §1.2 says "Text content only;
  do not touch this existing style block", so the header title style is not
  this story's to change. **Routed to UI/UX Designer and Tech Lead.**
- Recorded in-code as a dartdoc on `ChatStrings.headerPairingTitle` so the
  next reader does not re-run the same failed VS15 experiment.

### D-2 — reference PNG shows "M", implementation shows "L" (EXPECTED, not a defect)

`ux/uiux-spec.md` lines 17-37 pre-empts this: the design source's chip is
partner-scoped (`partnerInitial: this.mine ? 'L' : 'M'`,
`partnerName: this.mine ? 'Linh' : 'Minh'`, source lines 2118-2119). The
captured reference PNG happens to show a self-looking "M" only because that
demo toggle was `false` at capture time. The implementation renders the
partner's initial, which is spec-correct. This divergence between the two
images is documented and expected.

### D-3 — new `CupidHeader.titleSemanticLabel` parameter

`ux/uiux-spec.md` §4 requires a semantics label on the header title, but
`CupidHeader.title` is a `String`, not a `Widget` — there was no way to attach
one. Added a second additive, optional, null-defaulting `titleSemanticLabel`
parameter, threaded to both platform branches as
`Text(title, semanticsLabel: titleSemanticLabel)`.

Story In-Scope #1 and AC6 both say "parameter(s)", so this stays inside the
story's contract, but it does deviate from phase-P2 §3's literal
single-`trailing` task list. Null-default behavior is locked in by test 7 of
the `CupidHeader trailing slot` group.

### D-4 — `partner_chip_palette.dart` location

Placed at `mobile/lib/design_system/tokens/partner_chip_palette.dart`, per the
phase file's Write Scope and AC. The handoff message said
`design_system/adaptive/tokens/`, which does not exist and would have split
the token tree. Followed the phase file.

### D-5 — one line outside the literal write scope

`mobile/lib/design_system/design_system.dart` gained
`export 'tokens/partner_chip_palette.dart';`. The barrel rule requires feature
code to import only `package:cupid_mobile/design_system/design_system.dart`,
so without this line the new token is unreachable from the chip. One export
line, no other change to the file.

## 5. Pre-existing, out-of-scope differences between the two images

These are visible when comparing the pair and are **not** introduced by this
story. Listed so the reviewer does not re-litigate them:

| Difference | Note |
| --- | --- |
| Shell has 3 tabs plus an account-hub FAB; the reference shows 5 tabs | Deliberate navigation decision from earlier REQ-002 work |
| Reference shows a "Đã seen 5 phút…" / "Bắn Emoji Storm" row | Not implemented; outside chat header scope |
| Privacy chip vertical position differs slightly | Pre-existing, outside this story's write scope |
| FAB occludes part of the message list | Known STORY-040 finding N2, already recorded |
| Status-bar clock differs | Capture-time artifact |

## 6. Changes delivered

| File | Change |
| --- | --- |
| `mobile/lib/design_system/adaptive/cupid_header.dart` | Added optional `trailing` and `titleSemanticLabel`, wired into **both** `_IosHeader` and `_MaterialHeader`; `_trailingGap = 10` transcribed from the design source |
| `mobile/lib/design_system/tokens/partner_chip_palette.dart` | New — `PartnerChipPalette.avatarGradient`, the 135deg `#00C9A7` -> `#7B2FBE` ramp |
| `mobile/lib/design_system/design_system.dart` | Barrel export for the new token |
| `mobile/lib/features/chat/presentation/widgets/partner_presence_chip.dart` | New — the pill, gradient avatar, initial, and ringed online dot; `partnerDisplayName` is non-nullable so the "does the chip exist" decision stays with the caller |
| `mobile/lib/features/chat/presentation/chat_strings.dart` | `presenceChipStatus`, `presenceChipSemanticLabel`, `headerPairingTitle`, `headerPairingSemanticLabel`, `_joinPair` |
| `mobile/lib/features/chat/presentation/screens/chat_screen.dart` | Threads `selfDisplayName` into `_ChatView`; header composes the pairing title, its semantic label, and the chip; chip omitted entirely when there is no partner name |
| `mobile/test/design_system/adaptive_widgets_test.dart` | +7 tests for the trailing slot, including the Material tree-identity assertion |
| `mobile/test/features/chat/presentation/chat_design_fidelity_test.dart` | +8 tests for the pairing title, chip geometry, chip identity, and accessibility |

## 7. Verification

| Gate | Command | Result |
| --- | --- | --- |
| Lint / type-check | `flutter analyze --no-fatal-infos lib test` | `80 issues found. (ran in 2.4s)` — 0 errors, 0 warnings, identical to the P1 baseline |
| Full test suite | `flutter test` | `00:33 +1305 ~2: All tests passed!` (baseline 1290, +15 new) |
| Build | `flutter build apk --debug` | `✓ Built build/app/outputs/flutter-apk/app-debug.apk` |
| Header component | `flutter test test/design_system/adaptive_widgets_test.dart` | `00:00 +22: All tests passed!` (was 15, +7) |
| Chat fidelity | `flutter test test/features/chat/presentation/chat_design_fidelity_test.dart` | `00:01 +19: All tests passed!` (was 11, +8) |
| ADR-004 | `flutter test test/design_system/no_fork_guard_test.dart` | `00:00 +1: All tests passed!` |
| Format | `dart format` on the 7 touched files | `Formatted 7 files (5 changed)` |
| Runtime startup smoke | — | NOT_APPLICABLE per `data/devops/system/runtime-command-registry.json` (`mobile-app`) |

Lint, full suite, and build were all re-run against the exact delivered source
after the D-1 revert, so the passing gates cover what is actually being handed
off.

Mutation checks confirming the new assertions are not tautological are
transcribed in `coding-plan/test-results.md`, P2 section.
