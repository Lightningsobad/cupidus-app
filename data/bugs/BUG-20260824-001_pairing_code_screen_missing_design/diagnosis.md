# Diagnosis: BUG-20260824-001 pairing_code_screen_missing_design

Bug: `BUG-20260824-001_pairing_code_screen_missing_design`
Scope classification: **backlog escalation** (mobile / UX-flow product scope, not a narrow fidelity patch)
Outcome: `ESCALATE_TO_BACKLOG`

## Input Anchors

- Reported screen: "Mã ghép đôi của bạn" — design canvas node id `invite`
  (`isInvite`), app screen
  `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`
- Governing ACs: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-011_invite_code_design_fidelity/story_master.md`
  AC1-3
- Last delivered fix: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-037_invite_design_fidelity_hardening/`
- Design source: `cupid-app-design-system/Cupid Screens.dc.html`, `isInvite`
  block lines 168-203
- Runtime id: `mobile-app` (`data/devops/system/runtime-command-registry.json`)

## Pre-Fix Reproduction Gate

- **Original failure anchor:** rendered `invite` screen ("Mã ghép đôi của bạn")
  in dark theme + `vi` locale, reported as visually wrong / missing elements.
  No stack trace, no failing test — visual/design defect.
- **Reproduction method and modality:** same modality as the report — real
  rendered screen captured from a booted Android emulator, then compared to the
  locked design source markup and to STORY-037's own design reference render.
- **Exact path:**
  1. `"$HOME/Library/Android/sdk/emulator/emulator" -avd Medium_Phone_API_36.0 -no-snapshot-save` (background) → `adb devices` reports `emulator-5554 device`
  2. `cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build apk --debug --target=lib/main_preview.dart --dart-define=PREVIEW=invite`
     → `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk`
  3. `adb -s emulator-5554 install build/app/outputs/flutter-apk/app-local-debug.apk` → `Success`
  4. `adb -s emulator-5554 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` → `Status: ok`
  5. `adb -s emulator-5554 exec-out screencap -p > evidence/reproduction-invite-emulator-5554.png`
  - The `main_preview.dart` harness with `--dart-define=PREVIEW=invite` is the
    same capture path STORY-037 used; it seeds the `InviteCubit` fixture
    (`CPD-8F2K`) so the code card renders without a live authenticated,
    paired backend session.
- **Environment notes:** first install attempt failed with
  `java.io.IOException: Requested internal only, but not enough space`
  (`adb shell df /data` → 454 MB free). Resolved by
  `adb -s emulator-5554 uninstall com.snapsofts.cupid` (stale prior build) and
  reinstalling; second install returned `Success`.
- **Expected result:** the rendered screen matches the `isInvite` node of
  `cupid-app-design-system` — code card, then the "Tụi mình thuộc kiểu nào?"
  couple-type picker (4 cards), then the full-width continue CTA.
- **Actual result:** only the code card renders. Everything below the card is
  empty background for roughly two thirds of the screen height. Captured at
  `data/bugs/BUG-20260824-001_pairing_code_screen_missing_design/evidence/reproduction-invite-emulator-5554.png`.
- **Result: REPRODUCED**

## Expected vs Observed

| Design source element (`Cupid Screens.dc.html`) | Rendered app |
| --- | --- |
| L170-178 code card: label, mono gradient code, expiry caption, share pill + copy icon button | Present, matches (STORY-037 measured this pair as PASS) |
| L179-200 section "Tụi mình thuộc kiểu nào?" + subtitle + 2×2 couple-type grid (`typeList`, 4 entries) | **Absent** |
| L201 CTA `Tiếp tục → Fingerprint Vow` (`onClick={{ goVow }}`) | **Absent** |

## Root Cause

Not a rendering, layout, or token defect. The block is absent because it was
never implemented, by an explicit and reviewer-approved delivery decision:

- STORY-011 `visual-fidelity/visual-fidelity-report.md` lines 27-30:
  "the design source's couple-type picker and 'Continue → Fingerprint Vow' CTA
  (source lines 179-199) are deliberately excluded from this screen and were
  **not** added by this story — they are separate product scope, not a fidelity
  deviation."
- STORY-037 `visual-fidelity/visual-fidelity-report.md` G4 carried the same
  waiver into the hardening story, and its Reviewer gate approved it.

So the current app state is exactly what REQ-002 approved. The user is reporting
the approved gap, not a regression against it.

### Design-source drift finding (handoff item)

`detect_design_source.py` reports `DESIGN_SOURCE_DRIFTED`
(`sha256:ac2cd52…` → `sha256:a430b91…`, since 2026-08-22T02:17:06Z). Verified
against git: the only design-system commit after that lock is `9aa0aed`
("fix(design-canvas): preserve flex shorthand on dc-import host style"), which
touches `cupid-app-design-system/support.js` only. **The invite screen markup
did not change in the drift.** Working tree for `cupid-app-design-system/` is
clean.

A *different*, older change is material, and it postdates the last delivered
evidence. STORY-037 landed 2026-08-17; `3d74a75` changed
`Cupid Screens.dc.html` on 2026-08-20:

- invite CTA retargeted: `onClick={{ goWaiting }}` / "Tiếp tục → Đợi ghép"
  → `onClick={{ goVow }}` / "Tiếp tục → Fingerprint Vow"
- the whole `isPairingChoice` node was **deleted** from the canvas, along with
  its index entry, its `NO_CHROME`/`NO_TABS` entries and `goPairingChoice`
- `BACK_TO` rewired: `invite: 'pairingchoice'` → `invite: 'profile'`,
  `joincode: 'pairingchoice'` → `joincode: 'invite'`

The app still ships `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
(added as canvas scope by STORY-034), which no longer has a design node at all.
So the onboarding flow in the design source and the onboarding flow in the app
have diverged beyond this one screen.

## Root-Cause Family And Cluster Boundary

Family: "invite/onboarding node content and flow not implemented to the current
design canvas".

Same family (all blocked on the same product/UX decision, none of them a narrow
patch):
- missing couple-type picker on `invite`
- missing continue CTA on `invite`, and its retargeting to `vow`
- orphaned `pairing_choice_screen.dart` with no remaining design node
- `joincode` back-target change

Not in this family: everything STORY-037 measured PASS inside the code card
(geometry, tokens, mono treatment, gradients, share/copy actions).

## Why This Is Not A Narrow Bugfix

Closing the gap is not a spacing/token correction. It requires, at minimum:

1. A couple-type catalog as product content — 4 types with `vi`/`en` labels,
   hints and icons, plus l10n entries.
2. Selection state and persistence semantics. `coupleType` exists on
   `CupidProfile` / `account_repository.dart`, but nothing defines when it is
   written from this screen, what the default is, whether it can be skipped, or
   how a failed write behaves.
3. A navigation decision. The design now sends invite → Fingerprint Vow; the
   app sends invite → waiting. STORY-011's own Out of Scope section assigns
   inter-screen navigation correctness to REQ-002 Scope A
   (STORY-001/STORY-002), not to this screen's fidelity scope.
4. A decision about `pairing_choice_screen.dart`, whose design node was deleted
   on 2026-08-20.

Items 2-4 are product/UX decisions that no existing approved artifact answers,
and item 1 plus the onboarding-chain change is more than a narrow patch. Per
Bug Fixer rule 16 this stops here rather than inventing the flow.

## Touched Risk Surfaces

- Frontend interaction (mobile) — would gain a new selection interaction
- Runtime/configuration — onboarding chain / routing
- Persistence contract — `CupidProfile.coupleType` write path
- No security, auth, migration, or job surface touched

## Files And Ranges Inspected

| Path | Range / query |
| --- | --- |
| `data/bugs/BUG-20260824-001_pairing_code_screen_missing_design/bug_master.md` | full (small) |
| `data/bugs/BUG-20260824-001_pairing_code_screen_missing_design/scrum-master-checkpoint.md` | full (small) |
| `data/devops/system/runtime-command-registry.json` | full — needed `mobile-app` start/readiness contract |
| `data/requirements/.../STORY-011_invite_code_design_fidelity/story_master.md` | full (86 lines) |
| `data/requirements/.../STORY-011_.../visual-fidelity/visual-fidelity-report.md` | lines 1-120 |
| `data/requirements/.../STORY-037_.../visual-fidelity/visual-fidelity-report.md` | full |
| `data/requirements/.../STORY-037_.../visual-fidelity/design-reference-invite-android.png` | rendered comparison |
| `cupid-app-design-system/Cupid Screens.dc.html` | lines 150-219 only, located by grep for `ghép đôi của bạn` / `isInvite` / `typeList` |
| `mobile/lib/main_preview.dart` | lines 1-80 — harness invocation contract only |
| git plumbing | `log --follow`, `show --stat 9aa0aed`, `diff 0808f71 3d74a75` on the design system; `ls-files` for pairing screens |

No implementation file was patched, so no source file beyond the preview
harness header was opened.

Large-file note: `Cupid Screens.dc.html` is 241 KB and was never full-read —
only two ranged reads around grep hits.

## Risk Notes

- No patch applied, so no regression risk introduced by this run.
- The emulator's installed `com.snapsofts.cupid` build is now the
  `main_preview.dart` preview entrypoint, not the normal app entrypoint. Any
  follow-up run that needs the real app must rebuild with the default target.

## Recommendation

Route to backlog as REQ-002 Scope A/B follow-up work covering the whole
divergence family above, with Product Owner deciding the couple-type
interaction and UI/UX Designer deciding the post-invite flow, rather than
patching this screen in isolation.
