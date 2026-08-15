VISUAL_FIDELITY: PASS

Design-Screen: privacy

Scope note: PASS covers the Privacy / My Data screen surface this story owns.
Three visible deltas remain in the captured frames; all three are shared app
chrome or another requirement's approved scope, each is cited below, and none
is a STORY-030 defect. A reviewer who disagrees with any of the three should
overturn this verdict rather than treat it as pre-approved.

## 1. How the design screen id was resolved

Not guessed. Resolved by enumerate -> shortlist -> confirm-by-render:

1. `render-design-canvas.js --list-screens --entry="Cupid App.dc.html"` returns
   37 screen ids, one of which is `privacy`. The `--entry` flag is required:
   the bundle holds 16 `.dc.html` files and the tool otherwise fails with
   `DESIGN_CANVAS_ENTRY_AMBIGUOUS`. `Cupid Screens.dc.html` holds the markup
   but reports `screens: []`, so it cannot be used as the entry.
2. `Cupid Screens.dc.html:1341` binds `isPrivacy: sc === 'privacy'`, tying the
   audited `<sc-if value="{{ isPrivacy }}">` block at `:1342-1378` to canvas
   state `privacy`.
3. Confirmed by rendering and looking at the result, not by trusting the label:
   `design-reference-privacy-android.png` shows the title "Dữ liệu của tôi",
   the LEVEL 1/2/3 tier cards, the export button and the PDPA caption.

Recorded as `Design-Screen: privacy` in `story_master.md`.

## 2. Artifacts

| Artifact | File |
|---|---|
| Design baseline | `design-reference-privacy-android.png` (406x900) |
| Implemented, design-parity viewport | `implemented-privacy-emulator-5560.png` (405x900, 146636 bytes) |
| Implemented, full column | `implemented-privacy-full-emulator-5560.png` (405x900, 96307 bytes) |

Two implemented frames are needed because the implementation carries one card
the design does not (§5 delta 1), so the column no longer fits a design-parity
viewport. Frame 2 lowers display density to fit the whole column rather than
scrolling the live app; the capture tool restores the display on exit.

## 3. Configuration captured

- Device: `emulator-5560`, Android, dark theme, `vi` locale — the enabled
  configuration named in the story's In Scope item 1.
- Design reference rendered for `dark` + `vi` + `android`.

`design-fidelity-config.json` does not exist anywhere in this repository,
despite being cited by earlier REQ-002 review reports. The design source
parameters above were taken from the story text and prior stories' evidence.
Flagging it because those citations are stale and will mislead the next reader.

## 4. How the implemented state was produced

```
flutter run -t lib/main_preview.dart -d emulator-5560 \
  --dart-define=PREVIEW=privacy \
  --dart-define=PREVIEW_EMAIL=preview.dev.a@cupid.test \
  --dart-define=PREVIEW_PASSWORD=CupidPreview!Dev1 \
  --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:3000
```

A real authenticated session, not a mocked state: the ghost-mode pill renders
from the live account's `isGhostModeEnabled`, consistent with the STORY-018 P6
DEC-1/DEC-3 authenticated-preview convention.

Two harness facts worth reusing on other REQ-002 mobile stories:

- **`emulator-5554` cannot be used for preview captures.** Its DNS is broken
  (`ping www.googleapis.com` -> `unknown host`; `emulator-5560` resolves), so
  Firebase sign-in fails with `[firebase_auth/network-request-failed]`. Because
  `preview_session_bootstrap.dart:32`'s `signInWithEmailAndPassword` sits
  *outside* that function's try/catch (the try only opens at `:36`), the
  exception is unhandled, `runApp` is never reached, and the device holds the
  Flutter splash indefinitely.
- **"Flutter run key commands" is not a readiness signal.**
  `bootstrapPreviewSession()` is awaited *before* `runApp`, so the engine
  reports up while the screen is still the splash. The first capture attempt
  produced a Flutter-splash PNG; it was discarded, not reported. Readiness is
  now established by polling frames until they diverge from a splash baseline
  and hold steady across consecutive probes.

## 5. Declared deltas (visible in the frames, none owned by this story)

1. **"TÙY CHỈNH" ghost-mode control card between LEVEL 1 and LEVEL 2.** Not in
   the design canvas. It is approved, reviewed, DONE scope from
   REQ-001/STORY-021 (`req_master.md` § Open Question Triage / Approved Scope
   Change entry #5), satisfying that story's AC2. STORY-030's Out of Scope
   forbids *adding* interactions absent from the design; it does not authorize
   *deleting* another requirement's approved one. Kept deliberately.
2. **Bottom tab bar shows 3 tabs (Trang chủ / Trò chuyện / Thư viện ảnh), the
   design shows 5 (Nhà / Trò chuyện / Pet / Ví chung / Tôi, "Tôi" active).**
   Intentional and already tracked — `mobile/lib/core/navigation/app_shell.dart:39-47`:
   "Pet/money/me destinations arrive with their own stories and are
   intentionally not scaffolded here … without building the 5-tab shell
   (`CupidTabBar` exists but stays otherwise unconsumed for the
   account/pet/money destinations — a separate Scrum Master routing item)."
   Not fixed here: `app_shell.dart` is outside this story's write scope, and
   adding those destinations would create new entry points, which AC5
   ("no new entry point") forbids. Every REQ-002 screen whose design reference
   shows the tab bar inherits this delta.
3. **Gallery FAB overlapping the LEVEL 3 card** in the design-parity frame.
   Same shared-chrome bucket as delta 2. Frame 2 exists so no in-scope element
   is left unverifiable behind it.

## 6. Per-region result, design vs implementation

Every row below was a real deviation found in the re-audit and corrected in app
code, then re-verified against the render. Design values are from
`Cupid Screens.dc.html:1342-1376`.

| Region | Design | Was | Now |
|---|---|---|---|
| Column child gap | 13 | 24, then 16 | 13 (`_privacyGap`) |
| ListView padding | 8/16/40 | `all(24)` | `fromLTRB(16, 8, 16, 40)` |
| Intro caption | 13px, line-height 1.6 | `type.body` 17px | 13px, height 1.6 |
| Card padding | 18 | `CupidSpacing.md` = 16 | 18 |
| Card header alignment | `align-items:center` | `CrossAxisAlignment.start` | center |
| Card header gap | 11 | 8 | 11 |
| Icon box | 40x40, radius 14 | radius `radiusSmall` = 16 | 40x40, radius 14 |
| Icon glyph | 21px | unsized | 21px |
| Level label | 9.5px, letter-spacing .14em | unsized (~14px), ls 1.2 | 9.5px, ls 1.33 |
| Card title | 15.5px, weight 800 | `type.body` 17px | 15.5px, w800 |
| Description | 12.5px, lh 1.55, margin-top 11 | `type.caption` 13px, mt 8 | 12.5px, 1.55, 11 |
| Chips row gap | 7, margin-top 12 | 4, mt 8 | 7, mt 12 |
| Chip padding | 11 x 5 | 8 x 4 | 11 x 5 |
| LEVEL 1 chip fill | `rgba(255,255,255,.12)` | `colorSurfaceAlt` | `rgba(255,255,255,.12)` |
| LEVEL 1 gradient | `linear-gradient(150deg, …)` | topLeft -> bottomRight | 150deg |
| **Export button** | **present** | **absent** | **present** |
| **PDPA caption** | **present** | **absent** | **present** |

Two design values are off the 8pt `CupidSpacing` scale (13, 11, 12, 7, 5, 18)
and cannot be expressed as spacing tokens; they are named constants or literals
with the design line cited at the use site.

The 150deg gradient is mapped with the same convention `CupidColorTokens`
already uses for its 120deg gradients (0deg points "to top", angles rotate
clockwise, so begin is `(-sin, cos)` and end is `(sin, -cos)`).

## 7. AC4 — the PDPA export control

This is the acceptance criterion the story exists to close, and it reverses a
long-standing deferral. REQ-001/STORY-021's review report records "no 'Export
all my data' affordance added" (DEC-5), and the REQ-001 retro audit flagged
that "a separate data-export-button conflict (system UX memory §8 vs AC4) was
flagged by UX and PO but also never escalated".

Implemented to match `Cupid Screens.dc.html:1375-1376` exactly:

| Property | Design | Implemented |
|---|---|---|
| Height | 52 | 52 |
| Radius | `--r-btn` | `platformTokens.radiusButton` (999) |
| Border | 1.5px solid `--line` | 1.5px `colors.colorLine` |
| Icon | `download`, 20px, `--mint` | `Icons.download`, 20, `colors.colorMint` |
| Icon/label gap | 9 | 9 |
| Label | 15px, weight 800 | 15px, w800 |
| Label copy (vi/en) | "Xuất toàn bộ dữ liệu" / "Export all my data" | identical |
| Caption | 11px, `--tx2`, centered, lh 1.5 | 11px, `colorTextMuted`, centered, 1.5 |
| Caption copy (vi) | "File ZIP gửi qua email trong 24 giờ · theo PDPA Việt Nam" | identical |
| Caption copy (en) | "ZIP emailed within 24 hours · Vietnam PDPA compliant" | identical |

**The control renders inert, by design.** The design source gives it
`cursor:pointer` but binds no `onClick`, the app exposes no export endpoint,
and STORY-030's Out of Scope excludes "any change to the underlying PDPA
export/data-handling logic itself". Rendering the affordance without inventing
an action is the only reading that satisfies AC4 without exceeding scope. It is
deliberately not wrapped in button semantics, so assistive technology does not
announce an action the screen cannot honour. If a live export action is wanted,
that is a new story with a backend contract, not a fidelity fix.

**Localization note.** The two export strings use the codebase's local
`viEn(vi, en)` idiom (as in `gallery_empty_view.dart:24-28`, one of 292 `viEn`
call sites) rather than the ARB bundle, because `app_vi.arb` / `app_en.arb` are
outside this story's write scope. Every other string on the screen still comes
from `AppL10n`. This is the one intentional inconsistency in the file; it is
commented at the definition and should fold into the ARB bundle next to the
existing `privacy_*` keys when a story owns those files.

## 8. Verification

- `flutter analyze lib/features/account/presentation/screens/privacy_screen.dart lib/main_preview.dart`
  -> "No issues found!"
- `flutter test test/features/account/presentation/screens/privacy_screen_test.dart`
  -> 9/9 passing.
- The pre-existing test `renders no export button … (DEC-5)`, which asserted
  `find.textContaining('Export')` -> `findsNothing`, directly contradicted AC4
  and was replaced by `renders the PDPA export control with the design copy`,
  asserting the exact design label, caption and icon. The ghost-mode assertions
  it also carried were preserved as their own test.

No golden test was added. The visual-fidelity procedure's step 4 suggests
pinning with `--update-goldens`, but golden files would land outside this
story's declared write scope.

## 9. Preview harness

`main_preview.dart`'s `'privacy'` entry was missing `wrapInShell: true` while
its design reference visibly shows the bottom tab bar — exactly the condition
`preview_screen_entry.dart:5-8` (DEC-4) names, and already set on the sibling
`me` and `notifs` entries with the same `seedNote`. Without it the implemented
capture would have shown a spurious missing-tab-bar delta. Fixed, with the
matching seed note.
