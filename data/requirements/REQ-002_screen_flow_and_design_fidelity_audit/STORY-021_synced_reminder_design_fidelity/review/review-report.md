# Review Report: STORY-021 Design Fidelity — Synced Reminder (Round 2)

Outcome: PATCH_REQUIRED

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-021 (`Complexity: trivial`, `Implementation Lane: mobile`)
- Review type: `full-story-review` (Tier 2) — supersedes the round-1
  `compact-story-review` in this same file
- Scope gate: `review/scope-gate.md`
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-021`
- BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd` → worktree HEAD `51fb91dc`
  (round 1 reviewed `d297cdfb`; `6aa77cb`, `a96c3d8`, `51fb91d` are new)
- Blocking findings: 1 · Deferred findings: 3

## What changed since round 1

Round 1 blocked on F-1: no rendered visual-fidelity evidence existed at all.
That has been substantially addressed and the work is good — but it lands one
step short of the mobile-lane gate, and the final commit introduced a contradiction
the report does not acknowledge.

Delivered this round: both design references rendered from the locked canvas,
both AC-bearing states rendered from the implementation, `Design-Screen: alarm`
resolved and recorded, round-1 D-1/D-2/D-3 all closed, and three real deviations
(F34 vertical centring, F35 flat CTA, F36 mint chips) found *by* the render that
the static per-property trace had missed. That last point is exactly why this
gate exists, and it vindicates the round-1 block.

## Critical Gate Results

| Gate | Rule | Result |
| --- | --- | --- |
| Rendered design fidelity | 12e2 / 12e3 | **FAIL** — see F-1 |
| Mobile static analysis | 12e0 | PASS — `flutter analyze --no-fatal-infos lib/features/reminders test/features/reminders` = 6 info-level, all pre-existing at BaseHead |
| Mobile targeted widget tests | 12e0 | PASS — `flutter test test/features/reminders` = `+71 ~2`; `+73` with `CAPTURE_VISUALS=true`. All 7 claimed fidelity tests verified present |
| AC3 copy guard | story AC3 | PASS — `reminder_copy_guard_test.dart` = `+2`; also confirmed visually in both renders (no "báo thức"/"alarm" anywhere on screen) |
| Entry-point reachability | 12e1 | PASS — independently verified: `mobile/lib/features/home/presentation/home_screen.dart:110-117` mounts `ReminderScheduleScreen` from `_ReminderEntryCard`, a labelled tappable Home affordance (`:157`). Diff changes no route or navigation |
| Runtime startup smoke | 12g | Not required — `Complexity: trivial`. See F-1 note 4: the blank device frame is nonetheless unexplained runtime behaviour |

## Blocking Finding

### F-1 (round 2) — The only built-app capture is a blank frame, and it is undocumented

`visual-fidelity/implemented-alarm-emulator-5554.png` (11,947 bytes) renders as
an Android device frame — status bar `5:10`, wifi/signal/battery, home indicator
— with the **entire content area black and empty**. No app UI at all.

Rule 12e3 is explicit: a capture showing an error screen, a loading spinner, or
the wrong screen is `PATCH_REQUIRED` "no matter what the report says". A frame
that paints nothing is squarely in that class, and it is the story's only
evidence of the app actually running on a device.

Four compounding problems:

1. **It is undocumented.** The file was added by the final commit `51fb91d`
   ("complete story boundary"). `visual-fidelity-report.md` never mentions it:
   the §4.5 artifact table lists four files, and §7 states "four PNGs in this
   directory". Five exist. Nothing in the report tells a reader this capture was
   taken, let alone that it is empty.

2. **The report's stated reason for skipping the device capture is false at HEAD.**
   §4.5 and §8 say the emulator route was "attempted and abandoned deliberately"
   because the needed fixture "belongs in `mobile/lib/main_preview.dart`, outside
   this story's `WriteScope`", and "a one-file scope extension was requested from
   Scrum Master and no decision came back, so that file was left untouched."
   Commit `51fb91d` **does** modify `main_preview.dart` (+15/-1) and **does** add
   `mobile/lib/preview/preview_reminder_fixture.dart` (180 lines). The stated
   blocker was removed and the capture was attempted; the report still argues it
   could not be.

3. **The substitute evidence is explicitly not device evidence.** The two
   `412x915` PNGs are in-process `flutter_test` `RepaintBoundary` renders via
   `visual_capture_support.dart:57` `captureAtReferenceViewport`, not the built
   app. The report concedes this: "not evidence for anything that depends on the
   real device: platform font fallback, actual touch behaviour, or system insets."
   That caveat is load-bearing here — the schedule capture shows a **missing-glyph
   box** after "Đã xác nhận" (U+2713 absent from Nunito, no fallback in the
   harness), which the report asks us to accept "resolves on device". AC1 requires
   "matches exactly with no visible deviation"; the capture that would settle
   whether a tofu box ships to users is the blank one.

4. **Probable root cause, and a real defect in the new fixture.**
   `preview_reminder_fixture.dart:112-118` — the `FutureBuilder` returns
   `SizedBox.shrink()` whenever `snapshot.data == null` and has **no error
   branch**. If `_seedBloc()` throws, or its
   `bloc.stream.firstWhere((s) => !s.isLoading)` (`:71-75`) never completes, the
   preview paints a permanently empty screen — precisely the committed capture.
   The failure is silent by construction.

To be clear about what is *not* wrong: I opened all four other images. The
references depict the correct canvas screen (`alarm` schedule and the
`alarmRinging` overlay), the implementation renders depict this story's screen,
and they match well — hero gradient card, 06:30 gradient clock, 44dp steppers,
T2-T6 `grad-hot` chips, centred confirmation cards, gradient glow CTA, rule
card; and on the overlay, the 96dp amber badge, the new 52dp clock readout
(F30), the amber radial scrim (F31), the partner row with its hairline divider,
and the 60dp gradient dismiss pill. The stated residual deltas are honest and
correctly classified. The comparison work is sound; the device leg is not done.

**Owner: mobile-dev.** Required to clear F-1:

1. Fix `preview_reminder_fixture.dart`'s `FutureBuilder` to surface failure
   instead of rendering empty — handle `snapshot.hasError` and the pending state
   visibly, so a broken seed can never masquerade as a screenshot.
2. Re-capture both AC-bearing states from the preview build on `emulator-5554`
   (`-t lib/main_preview.dart --dart-define=PREVIEW=alarm
   --dart-define=PREVIEW_REMINDER_STATE=schedule|ringing`) via
   `capture-mobile-screen.sh`, following the STORY-020 recipe that produced
   `implemented-vibe-emulator-5554.png`.
3. Confirm on the device capture whether the "Đã xác nhận" tick renders as a
   real glyph or a tofu box. If it is tofu on device, that is an AC1 visible
   deviation and must be fixed (D9 already proposes `CupidIcons.check`).
4. Replace or delete the blank `implemented-alarm-emulator-5554.png`. No failed
   capture may remain in the evidence directory.
5. Update `visual-fidelity-report.md` §4.5, §7 and §8 to match HEAD: correct the
   artifact inventory, withdraw the "left untouched / scope extension not
   granted" narrative, and re-state each `VISUAL_FIDELITY` verdict against the
   device captures.

The in-process renders should be **kept** alongside the device ones. They are
what caught F34/F35/F36, and they are reproducible in CI in a way a device
capture is not.

## Deferred / Secondary Findings

- **D-1 — Evidence filenames do not pair.** References are
  `design-reference-alarm[-ringing]-android.png`; implementations are
  `implemented-alarm-{schedule,ringing}-412x915.png`. Rule 12e3 expects
  `implemented-<screen>-<device>.png` paired with
  `design-reference-<screen>-<device>.png`, and sibling stories (STORY-020, -003,
  -024) use `-emulator-5554`. Align during the re-capture so the pairing is
  legible from the file listing.
- **D-2 — WriteScope bookkeeping (Scrum Master).** `main_preview.dart` was
  modified in `51fb91d` after the report recorded that no scope extension had
  been granted. The change itself is safe — `String.fromEnvironment` defaults to
  empty, so the un-defined path still returns the live `ReminderScheduleScreen`
  and production behaviour is unchanged — but the scope decision should be
  recorded rather than left implicit in a commit.
- **D-3 — D8 remains a genuine cross-story contract conflict.** `ux/uiux-spec.md`
  §6 specifies a flat filled button at 20dp radius app-wide, while this screen's
  design source specifies a `grad-hot` pill with glow. F35 resolved it locally
  via `_ConfirmCta`; the shared `cupid_primary_button.dart` still disagrees.
  This needs a UX/design-system decision, not a mobile-dev one, and it is
  correctly out of scope for this story. Route separately.

Round-1 findings D-1 (stepper 44dp), D-2 (chip a11y trade-off) and D-3 (citation
drift) are all closed: F33 pins the painted circle at 44 inside a 48dp hit area
with a test, and D7 now records the horizontal-hit-area trade-off explicitly
with rationale and an escalation path.

The round-2 reversal of D3 (restoring the overlay's 52dp clock and amber scrim)
is **correct**. The rendered reference confirms the clock is the dominant element
after the badge and is plain type on a scrim, not system chrome; AC4 forbids the
OS alarm paradigm, and the one genuinely system-alarm element — the alarm-clock
glyph — remains correctly substituted with `notificationsActive`. Both additions
are visible and right in the implemented overlay render.

## Traceability

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — dark + `vi` matches the design source exactly | **UNVERIFIED (device)** | In-process comparison passes and is convincing; no built-app capture supports it, and the harness leaves an unresolved visible glyph box (F-1) |
| AC2 — deviations corrected in the app, not documented | MET | 750 insertions / 137 deletions across 5 `lib/` files; every §3/§3.9/§3.10 row lands in code per `git diff bf80848` |
| AC3 — copy reads "nhắc nhở đồng bộ", never "báo thức"/"alarm" | MET | Copy guard passes; confirmed visually in both renders (title, eyebrow, rule card, dismiss CTA). Remaining `alarm` tokens are wire-protocol identifiers, allowed by `story_master.md:45-47` |
| AC4 — dual swipe-to-dismiss visual matches, no system-alarm treatment | **UNVERIFIED (device)** | Overlay render matches the reference closely and stays an in-app `Material` scrim; same missing device leg as AC1 |
| AC5 — no new entry point | MET | No route, navigation or `AppShell` change in the diff; Home affordance independently verified at `home_screen.dart:110-117` |

OQ discipline: `story_master.md` triages OQ5 explicitly; no blocked scope was
implemented and no unblocked AC was omitted. No OQ defect.

Configuration guide: not applicable — no setup, env, or runtime configuration
impact in the diff. The new `PREVIEW_REMINDER_STATE` define is a dev-only capture
affordance with a safe default.

## Recommendation

- Uncheck `Implementation (Development)`; leave `Review (Reviewer)` unchecked.
- Story status: `IN_PROGRESS`. Return to **mobile-dev** for F-1 (items 1-5), with
  D-1 folded into the same pass.
- D-2 is a Scrum Master scope-bookkeeping item; D-3 needs a UX/design-system
  decision and should not gate this story.
- The fidelity work itself is good and the fixture that unblocks the device
  capture already exists in the branch. This is a short, well-defined pass.

REVIEW_COMPLETE
