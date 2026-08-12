VISUAL_FIDELITY: PASS

Both AC1 states captured from the live app on `emulator-5554`. The amber
"Seen, no reply" line renders between the Typing-Ghost bubble area and the
composer when the storm status is eligible, and the no-eligible layout is
pixel-identical to it everywhere except the row's own band — the composer does
not move by a single pixel. That is exactly `../ux/uiux-spec.md` §4's
verification expectation.

Supersedes the BLOCKED version of this report. The blocker it described
(`ChatScreen` crashing under the preview harness) was resolved by the
authorized `preview_session_bootstrap.dart` grant in
`../architecture/solution.md` §7; its crashed-screen attempt capture has been
removed rather than kept, since it no longer documents an open condition.

## What was captured

- `implemented-chat-eligibleStorm-emulator-5554.png` (405x900) — paired user,
  `storm-status` `{eligible: true, penalty: emoji_storm}`. Shows the amber
  timer icon + amber "Đã xem, chưa trả lời" ("Seen, no reply") caption, with
  the pink "Bắn Emoji Storm" pill directly beneath it, sitting between the
  message list / Typing-Ghost bubble area and the composer.
- `implemented-chat-noEligibleState-emulator-5554.png` (405x900) — same
  screen, same session, `storm-status` `{eligible: false, penalty: null}`.
  `GhostStateRow` collapses to `SizedBox.shrink()`; no caption, no pill, no
  spacing, no divider.

Both captures show the four seeded preview messages, the privacy chip, the
ghost-mode `OFF` toggle, the composer, and the app-shell bottom nav — i.e.
`ChatScreen` rendering for real, which is what the prior BLOCKED report could
not obtain.

## Placement and idle-cost verification (§4)

Pixel diff of the two captures (both 405x900, same session, same device):

```
bbox of all differing pixels: (34, 4, 363, 767)
differing rows: 62 total
  rows 4..39    — status-bar clock only (7:15 vs 7:17)
  rows 717..766 — the ghost-state row's own band (50px)
rows 767..899 — IDENTICAL (composer + bottom nav)
rows 40..716  — IDENTICAL (message list, privacy chip, all four bubbles)
```

This is the strongest form of the §4 claim available:

- **Placement** — the row occupies rows 717-766, strictly below the message
  list / bubble area (unchanged through row 716) and strictly above the
  composer (unchanged from row 767 down). Ordering is confirmed by pixel
  position, not by inspection.
- **Zero idle cost** — the composer and bottom nav are byte-identical between
  the two states, so mounting the row costs no height when the status is not
  eligible. The 50px the row occupies when eligible is taken from the
  message list's empty `Expanded` space, not from any sibling.
- **Not colour-alone** — the eligible state pairs an amber timer icon with the
  amber caption, as `../ux/uiux-spec.md` §3 requires; neither was stripped or
  restyled by mounting.

`../ux/uiux-spec.md` §4 also asks that the no-eligible layout be
"pixel-identical to its pre-mount state". A literal diff against the
pre-mount screen is not obtainable: the only pre-mount chat capture in the
repo (STORY-018's `implemented-chat-emulator-5554.png`) is the crashed empty
scaffold, not a render of `ChatScreen`. The equivalent evidence is the
composer/nav identity above plus the P1 widget test, which asserts directly
that no extra height is introduced when the status is not eligible.

## Design reference

No design-canvas diff is included. This story adds no new screen or component
to the canvas — it mounts an existing STORY-008 widget whose own visual design
was already signed off — and the canvas has no composed `chat` state carrying
an eligible storm status to diff against. Verification for this story is
placement and idle-cost, which the pixel diff above establishes directly.

## How the states were produced

The eligible state was authored over the public HTTP API only, per the
"Backend state authorization" in `../architecture/solution.md` §7, using the
pre-seeded `preview.dev.a@cupid.test` / `preview.dev.b@cupid.test` accounts
against the dev backend on port 3005. No backend code, schema, or seed-script
change. The exact mutation is recorded in `../coding-plan/test-results.md`.

The no-eligible capture was taken first, against the untouched pre-existing
state (no ghost config, `{eligible: false, penalty: null}`), so it is a
genuine idle state rather than one manufactured by tearing the eligible state
back down.

## Preview harness change

`mobile/lib/preview/preview_session_bootstrap.dart` only — the exact file
granted in `../architecture/solution.md` §7. After the existing Firebase
sign-in, and inside the existing `PREVIEW_EMAIL`/`PREVIEW_PASSWORD` empty
guard, it now performs `POST /auth/login` via `getIt<CupidApi>().dio`, feeds
the body to `BackendUserIdStore.updateFromLoginResponse(...)`, and awaits
`ChatPartnerStore.refreshFromServer()`. The block is wrapped in a
catch-and-continue so an unreachable backend cannot take down the other
preview screens. No `/auth/register` fallback, no committed credential, no new
dependency, no new `getIt` registration.

Grant verification bullet, all three satisfied:

1. `flutter analyze lib/preview/preview_session_bootstrap.dart` → "No issues
   found!". Full `flutter analyze lib` reports 77 pre-existing `info` lints
   (`prefer_initializing_formals`, `use_null_aware_elements`,
   `deprecated_member_use`), none of them in this file or in any file this
   story touched.
2. Both AC1 captures produced — above.
3. No-op path intact: `--dart-define=PREVIEW=login` with `PREVIEW_EMAIL` and
   `PREVIEW_PASSWORD` unset still renders the login screen fully (form,
   social buttons, footer link). Proof capture kept out of this directory so
   it is not mistaken for AC1 evidence.

## Known follow-up, not corrected here

STORY-018's `chat` entry in its 37/37 coverage claim was never a real
`ChatScreen` render; its baseline capture is the same crashed empty scaffold.
The §7 grant repairs the underlying cause, so a re-capture would now succeed,
but STORY-018's coverage record is deliberately left alone per §7 "Known
follow-up, not this story's scope".
