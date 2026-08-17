# STORY-040 — Chat + Typing Ghost Visual Fidelity Report (hardening)

VISUAL_FIDELITY: PASS

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-040 (RWB-20260816-007 hardening of STORY-018)
- Role: mobile-dev
- Date: 2026-08-17
- Branch: `main`
- BaseHead: `9da5d2ce02ae8b0b1529061886057f16d26c371b`
- Worktree: `/Users/alantravala/workspace/snapsofts/cupid-apps`
- Audited configuration: dark theme, `vi` locale, Material platform axis,
  Epic 2 (Communication), chat tab active. Same single-axis precedent as
  STORY-018 and STORY-035..039.

This report closes the gap RWB-20260816-007 named: STORY-018 argued its 25
fixes "from token values, not from a rendered pixel comparison". Every claim
below is now backed by a measurement taken off an actual render.

## Evidence pair

| Artifact | Size | What it shows |
| --- | --- | --- |
| `implemented-chat-emulator-5560.png` | 405x900 | Primary evidence. Live app on `emulator-5560`, dark + `vi`, shell chrome on, **Typing Ghost bubble actively on screen** with the struck faded tail. |
| `design-reference-chat-android.png` | 406x900 | `render-design-canvas.js --screen=chat --entry="Cupid App.dc.html"` against the locked `cupid-app-design-system`. |
| `implemented-chat-composer-draft-emulator-5560.png` | 405x900 | Supplementary. Same app/state with a non-empty draft, so the **enabled** send button (deviation 22) and the **typing-warning row** (deviation 25) are both on screen; captured without the shell so nothing occludes the composer (see N2). |

Capture command (all three):
`.ai-team-bundle/runtime/tools/capture-mobile-screen.sh --label=chat
--device=emulator-5560 --width=406 --density=160 --settle-ms=800`

### Scale note (required to read the numbers below)

The emulator is 1080x2400 @ density 420 (dpr 2.625, logical 411.4 x 914.3).
The capture tool downscales the physical framebuffer to width 405, so
**1 capture px = 0.984 logical px**. Implemented measurements are quoted in
capture px; divide by 0.984 for logical pt. The design canvas renders CSS px
1:1 inside a 388 px-wide device frame, so reference measurements are CSS px
directly. Text-run widths differ by ~4-5% between the two because Chrome and
Flutter shape the same string differently; that is a font-metric artifact, not
a token deviation, and it is called out wherever it appears.

## How the Typing Ghost state was reached

The ghost bubble is pure ephemeral realtime state: it exists only while an
inbound `ghostTyping` diff is live, is never persisted
(`architecture/solution.md` §2 invariant 3), and has no navigation path. It
therefore has no capturable state without a fixture, which is why STORY-018
never rendered it.

Added `--dart-define=PREVIEW_CHAT_GHOST=on` to `mobile/lib/main_preview.dart`.
It swaps the live Drift/`GET /messages` repository and the real
`RealtimeCoordinator` for backend-free preview doubles that replay the design
source's own three-message thread plus a typed-then-deleted `ghostTyping` pair.
The deletion pair is required: the struck tail is a *receiver-side diff of two
consecutive events*, and `GhostCubit` clears the bubble
`ghostReceiverStaleExpiryDuration` (6 s) after the last one, so a one-shot
stream leaves nothing on screen by the time a capture lands. The fixture loops
on a 5.55 s cycle, shorter than the stale expiry.

This is the harness's own documented rule — the state under capture is faked,
not driven through a live backend.

## Reference-coverage gap (disclosed, not a failure)

The design canvas binds the ghost bubble to live prototype state:

```
showGhostBubble: a.ghostOn && !!(partnerDraft || partnerGhosts.length)
```

`render-design-canvas.js` exposes only dark/light and `vi`/`en` toggles, so it
cannot drive `partnerDraft`. `design-reference-chat-android.png` therefore
renders the **idle** chat with no ghost bubble. The ghost-bubble region
(deviations 8-15) is consequently verified against the design *source* —
`cupid-app-design-system/project/Cupid Screens.dc.html` lines 331-389 and the
`@keyframes ghostFade` at line 30 — plus direct measurement off the
implemented render, rather than pixel-to-pixel against the reference PNG. Every
other region is a true rendered-to-rendered comparison.

## Deviation 25-point re-verification

All 25 of STORY-018's claimed fixes were re-checked against the renders. All 25
hold. `R` = reference render, `I` = implemented render, both in px as defined
in the scale note.

### Message bubble (1-7)

| # | Rendered evidence | Verdict |
| --- | --- | --- |
| 1 | Meta row (`20:41`, `20:42`, `20:44` + tick) sits **below** each bubble, end-aligned for own / start-aligned for partner, in both R and I. | HOLDS |
| 2 | Own bubble carries a visible pink glow halo in I; partner bubble carries the flat platform elevation shadow. Matches R. | HOLDS |
| 3 | Bubble band heights: I = 44 (44.7 pt), R = 42-43. Predicted from `11*2 + 15.5*1.4` = 43.7. | HOLDS |
| 4 | Same as 3 — the 44 px band is only reachable with 11 px vertical padding at that line height. | HOLDS |
| 5 | Longest own bubble: I = 246, cap = `405 * 0.78` = 316. Below the cap in this thread, so the cap itself is not exercised by this capture; asserted by the existing widget test. | HOLDS (test-backed) |
| 6 | Timestamps render at the same small size and the same `colorTextMuted` grey on **both** sides in I; matches R. | HOLDS |
| 7 | Read tick is a small mint double-check (`done_all`) in both R and I. Sampled mint, not white/grey. | HOLDS |

### Typing Ghost bubble (8-15) — AC3/AC4 core

Verified off `implemented-chat-emulator-5560.png` and a 16-frame `adb exec-out
screencap` burst at ~0.5 s intervals over the fixture's replay cycle.

| # | Rendered evidence | Verdict |
| --- | --- | --- |
| 8 | **The fade is visible in motion.** Brightest-glyph sample of the struck tail across the burst: `(247,238,251)` at t0 (still styled as kept text, pre-diff) -> `(152,140,179)` -> `(123,107,157)` -> settles at `(115,96,154)` ~1.5 s after the diff, then repeats on the next cycle. The kept run holds `(247,238,251)` throughout. A decelerating profile that lands ~1.3 s after the event and stays put = `ghostFade 1.3s ease-out forwards`. | HOLDS |
| 9 | Strike line row sampled at `(76,71,104)` over a local bubble fill of `(41,38,70)`, spread across two rows by AA. Consistent with `colorGhost` `(180,166,206)` at `0.85 * 0.45` composite; a full-opacity or glyph-coloured strike would read far brighter. | HOLDS |
| 10 | Visible gap between the kept run and the struck tail in I, wider than the inter-word space. | HOLDS |
| 11 | Header row `"Linh đang nghĩ…"` renders above the bubble: small purple `blur_on` glyph, gap, heavy purple label. Matches `Cupid Screens.dc.html` line 2193. | HOLDS |
| 12 | Cursor renders as a solid pink block glyph (`▌`) between kept text and tail, not a purple thin bar. | HOLDS |
| 13 | Bottom-left corner of the ghost bubble is visibly tighter than its other three corners in I (partner-side tail, 7 vs 22). | HOLDS |
| 14 | Dashed border renders as a hairline, not the previous 1.5 stroke. | HOLDS |
| 15 | Settled tail composite `(115,96,154)` against fill `(41,38,70)` matches `colorGhost` at 0.45 on the G channel to within 1/255; bubble padding and line height match the message bubbles' own 15.5/1.5 rhythm. | HOLDS |

**AC3 is satisfied**: the `0.95 -> 0.45` endpoint, the `easeOut` shape, the
`lineThrough` decoration and the `colorGhost @ 85%` decoration colour are all
now confirmed from an actual render, not re-asserted from the widget test.

### Chat screen (16-20)

| # | Rendered evidence | Verdict |
| --- | --- | --- |
| 16 | Chip copy reads `Level 1 · chỉ nằm trên máy hai người` in I, identical string to R. | HOLDS |
| 17 | Chip fill sampled `(36,27,66)` = `colorSurface` (not `colorSurfaceAlt`); lock glyph sampled `(121,226,205)` = mint. Matches R. | HOLDS |
| 18 | Chip height: I = 24 (24.4 pt), R = 23. Width I = 218 vs R = 207 — text-shaping delta only, same string. | HOLDS |
| 19 | Thread is bottom-anchored in I: the three messages sit against the composer with ~300 px of empty gradient above them, exactly as a `reverse: true` list behaves on a short thread. R shows the same flex-end result. | HOLDS |
| 20 | Own bubble 1 ends at y=481, partner bubble starts at y=510; the 29 px between them is the meta row plus the 10 px inter-bubble gap. Right margin of the own bubbles: 405-379 = 26, i.e. 14 px thread padding plus the bubble's own rounded-corner inset. | HOLDS |

### Composer (21-25)

Measured on `implemented-chat-composer-draft-emulator-5560.png` (draft
non-empty, so the enabled/warning states are on screen) and cross-checked on
the primary capture.

| # | Rendered evidence | Verdict |
| --- | --- | --- |
| 21 | Row y=786 samples `(44,47,68)` against the bar background `(22,27,48)` immediately below — the `colorLine` top hairline is present. | HOLDS |
| 22 | Enabled send button measures **36 x 36** (36.6 pt) in I vs **35 x 35** in R; renders as a pink->purple gradient circle with a white upward arrow and a glow halo. Disabled state on the primary capture renders flat `colorSurfaceAlt` with a muted arrow. | HOLDS |
| 23 | Ghost toggle measures **46 x 46** (46.7 pt) in I, x=13..58, y=821..866. Purple @24% fill with the @75% purple border in the ON state, 21 pt `blur_on` above the 7 pt `ON` mono glyph. | HOLDS (and see D2) |
| 24 | Input pill is a stadium with the design's left inset; bar padding measures exactly 12 px on the left edge and the toggle->pill gap measures 9 px at the pill's vertical centre. Height: see V-1. | HOLDS with V-1 |
| 25 | Warning row renders as a small purple `visibility` glyph + gap + heavy purple `Linh đang xem bạn gõ`, above the bar, only while ghost is on and the draft is non-empty. | HOLDS |

## D2 — ghost-toggle 44 pt clamp on the iOS axis (AC4)

**Fixed** in `mobile/lib/features/chat/presentation/widgets/chat_composer.dart`
(`_GhostToggleButton.build`). The tap-target slot is now
`math.max(platformTokens.tapTarget, _ghostButtonSize)` instead of a bare
`platformTokens.tapTarget`, so the 46 x 46 visual `Container` is never squeezed
by its own slot. The `SizedBox` still provides a slot at or above the platform
minimum on both axes.

Verified by a platform-token-parameterized test appended to
`mobile/test/features/chat/presentation/chat_design_fidelity_test.dart`:
`ghost toggle keeps its 46pt visual on both platform silhouettes`, one case per
`CupidPlatformTokens.material()` / `.ios()`, asserting the visual is exactly
`Size(46, 46)` and the slot still clears that platform's `tapTarget`.

The test was confirmed to be a real guard, not a tautology: reverting the fix to
`slot = platformTokens.tapTarget` fails the `ios` case with
`Expected: Size:<Size(46.0, 46.0)> Actual: _DebugSize:<Size(44.0, 44.0)>` while
`material` still passes. Restoring the fix makes both pass.

Additionally confirmed on the Material axis from the render: the toggle
measures 46 x 46 capture px in `implemented-chat-composer-draft-emulator-5560.png`.

## D1 — no `colorOnAccent` token (AC5)

Re-confirmed present and unresolved, and **not** touched here. No file under
`mobile/lib/design_system/` was modified by this story. Tracked as
RWB-20260816-016 per `story_master.md` `## Out of Scope`.

## New findings surfaced by the rendered comparison (AC6)

### N1 — `ChatScreen` crashed on the empty-state -> first-message transition. FIXED.

The very first capture attempt rendered a red `Null check operator used on a
null value` ErrorWidget instead of the chat. Root cause from the on-device run
log:

```
The following _TypeError was thrown building BlocBuilder<ChatCubit, ChatState>
Null check operator used on a null value
#0  ScrollPosition.minScrollExtent (scroll_position.dart:235:49)
#1  _ChatViewState._isPinnedToBottom (chat_screen.dart:133:40)
#2  _ChatViewState._maybeAutoScrollToBottom (chat_screen.dart:139:19)
#3  _ChatViewState.build.<anonymous closure> (chat_screen.dart:187:13)
```

`ScrollPosition.pixels` and `.minScrollExtent` are null-asserted getters. A
`Scrollable` attaches its `ScrollPosition` during **build** but only gets its
dimensions during **layout**, so `hasClients == true` while
`hasContentDimensions == false` is reachable mid-frame — precisely the frame in
which the thread flips from the empty state to its first message. This is
STORY-018 deviation 19's own code (`pin-to-bottom moved to minScrollExtent`)
and it took a real render to surface it; no existing test caught it.

Fixed in `mobile/lib/features/chat/presentation/screens/chat_screen.dart` by
guarding `_isPinnedToBottom` on `position.hasPixels &&
position.hasContentDimensions` and treating the not-yet-laid-out case as pinned.

**No synthetic widget test was added, deliberately.** The failure is a
frame-boundary race, and `flutter_test` drives build, layout and paint
synchronously inside one `drawFrame`, so no microtask can interleave between
attach and layout. Such a test would pass both before and after the fix and
would prove nothing. The on-device stack trace above is the evidence, and the
fixed build now renders the screen cleanly across repeated cold launches.

### N2 — the shell's account-hub FAB completely occludes the chat send button. NOT FIXED — referred out.

In `mobile/lib/core/navigation/app_shell.dart:199-206` the shell `Scaffold`
mounts a `FloatingActionButton` at the default `endFloat` location on **every**
tab, chat included. Measured on the primary capture, the FAB occupies
x=336..386, y=730..786; the composer's send button visual occupies
x=351..386, y=751..786. The send button is **100% covered** and, because the
FAB is painted above the body, untappable — the chat screen's primary action
cannot be reached in production.

`design-reference-chat-android.png` has no FAB at all.

Not fixed in this story, for the same reason D1 was split out: the fix lives in
`core/navigation/app_shell.dart`, outside a chat-screen story's WriteScope, and
choosing between "hide the account-hub entry on the chat tab", "relocate the
FAB", and "inset the chat body" is a navigation/IA decision owned by the shell
story (STORY-016 DEC-4), not a design-fidelity call. This is a functional
defect, not merely a visual one, and is escalated to Scrum Master for a bug
queue entry or a new rework-backlog item.

Because N2 blocks pixel verification of deviations 22 and 25 on the
shell-wrapped capture, the supplementary
`implemented-chat-composer-draft-emulator-5560.png` was taken with the preview
registry's `chat` entry temporarily set to `wrapInShell: false`. **That flag is
restored to `true` in the delivered source** — `git diff` on
`mobile/lib/main_preview.dart` contains no `wrapInShell` change — and the
primary capture was re-taken from a rebuilt, shell-wrapped APK afterwards.

### V-1 — input pill renders 48 pt tall, not the design's 46. RETAINED, by design.

Measured: I = 48 capture px (48.8 pt), R = 45 px. The cause is the outer
`ConstrainedBox(minHeight: platformTokens.tapTarget)` that STORY-018 wrapped
around the pill; on the Material axis `tapTarget` is 48, so it inflates the
46 pt visual by 2 pt.

This is the same *shape* of problem as D2 but the opposite trade-off, and the
opposite answer is correct. The ghost toggle's 46 pt box is a decoration inside
a larger slot, so shrinking it was a pure loss. The input pill **is** the touch
surface for the text field; constraining it back to 46 would drop the primary
text input below the Material 48 pt minimum to buy 2 pt of pixel fidelity.
`ux/uiux-spec.md` §5 already decided that trade in favour of the tap target,
and STORY-018 cited it. Recorded here as a known, re-verified, deliberately
retained 2 pt delta rather than silently "fixed".

## Deviations re-confirmed as out of scope (no re-litigation)

Each was checked against the render, confirmed still divergent, and left alone
per `story_master.md` `## Out of Scope`:

- **D1 / own-bubble `#fff`** — `colors.colorText` (`#F7EEFB` in dark) is
  imperceptible against the gradient in the render, as STORY-018 argued.
  RWB-20260816-016.
- **Composer placeholder copy** — I shows `Đối phương thấy từng chữ…` (ghost-on
  hint); the mock's `Nhắn cho Bae` is PO/UX copy scope.
- **No attachment/image affordance** — R still draws an image glyph inside the
  pill at x≈322-329; ADR-013a removed it deliberately. Not restored.
- **Level-1 chip placement** — I pins the chip at y=118..141 above the scroll
  area; R nests it in the thread at y=441..463. Deliberate AC3-driven
  divergence.
- **`GhostStateRow` / Emoji-Storm seen row** — present in R, absent from I.
  Owned by `features/anti_ghosting/` (STORY-020). In this capture the row also
  self-collapses because the emulator resolves the API base to
  `http://localhost:3000` instead of `10.0.2.2`, so
  `GET /ghost-config/storm-status/...` is refused. Pre-existing preview/emulator
  networking issue, unrelated to this story, no chat code involved.
- **3-tab shell + account-hub FAB vs the reference's 5-tab bar** — STORY-016
  DEC-4, already an accepted requirement-level chrome divergence. N2 above is
  the *new* part of this: not that the FAB exists, but that it covers the send
  button.
- **Light theme / `en` locale** — OQ5, out of scope, no pass run.

## Verification

All commands run in this session from
`/Users/alantravala/workspace/snapsofts/cupid-apps/mobile` with
`PATH="$HOME/flutter/bin:$PATH"` (Flutter 3.44.1 / Dart 3.12.1).

| Gate | Command | Result |
| --- | --- | --- |
| Build | `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=chat --dart-define=PREVIEW_CHAT_GHOST=on` | `✓ Built build/app/outputs/flutter-apk/app-debug.apk`, installed to `emulator-5560` (`Success`) |
| Static analysis | `flutter analyze --no-fatal-infos lib test` | `80 issues found.` — **0 errors, 0 warnings**, all `info`. None in any file this story touched; the delta from STORY-018's 77 comes from `prefer_initializing_formals` in code landed by later stories. |
| Targeted tests | `flutter test test/design_system/no_fork_guard_test.dart test/features/chat --reporter compact` | `+64: All tests passed!` — includes both new AC4 platform cases and the ADR-004 no-fork guard. |
| Full suite | `flutter test --reporter failures-only` | `+1269 ~2: All other tests passed!` — 1269 passed, 2 skipped, 0 failed. |
| Runtime smoke | cold launch via `am start -a android.intent.action.VIEW -d "cupidpreview://screen/chat"` | Chat renders with the Typing Ghost bubble live; no ErrorWidget, no exception in the run log after the N1 fix. |

## Files changed by this story

| File | Change |
| --- | --- |
| `mobile/lib/features/chat/presentation/widgets/chat_composer.dart` | D2 — ghost-toggle slot is `max(tapTarget, 46)`; `dart:math` import. |
| `mobile/lib/features/chat/presentation/screens/chat_screen.dart` | N1 — `_isPinnedToBottom` guards on `hasPixels` / `hasContentDimensions`. |
| `mobile/lib/main_preview.dart` | `PREVIEW_CHAT_GHOST=on` backend-free Typing Ghost capture fixture. |
| `mobile/test/features/chat/presentation/chat_design_fidelity_test.dart` | AC4 — platform-token-parameterized ghost-toggle visual test (2 cases). |

No `design_system/` file, no `features/anti_ghosting/` file, no
`core/navigation/` file, and no chat business logic was modified.
