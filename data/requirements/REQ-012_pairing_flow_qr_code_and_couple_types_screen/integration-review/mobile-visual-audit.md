# REQ-012 Requirement Mobile Visual Audit

- Requirement: REQ-012_pairing_flow_qr_code_and_couple_types_screen
- Mode: `requirement-mobile-visual-audit` (closes integration finding IF-2)
- Platform / device: Android, `emulator-5554` (already-running device reused; not booted, reset, or repaired)
- Worktree HEAD audited: `8f3c38331c2c081c2393147025c0b7b95d2b7396`
- Date: 2026-08-26
- Result: **PASS with 4 non-blocking findings** — no blocking cross-screen visual breakage

## Scope

IF-2 states that each REQ-012 screen has its own per-story visual-fidelity capture, but
nothing audits the three restyled screens as one connected flow. This audit walks the
flow screen-to-screen with real taps and inspects every captured frame.

Screens audited (design canvas ids in `cupid-app-design-system/Cupid Screens.dc.html`):

| # | Screen | Canvas id | Entry surface |
|---|--------|-----------|---------------|
| 1 | Pairing-method choice (STORY-001) | `pairstart` | app entry for an unpaired user |
| 2 | Create code / Couple Types (STORY-002) | `invite` | `pairstart` row 1 "Tạo mã ghép đôi" |
| 3 | Join with code (STORY-003 host) | `joincode` | `pairstart` rows 2/3 |
| 4 | Scan code overlay (STORY-003) | `scan` (`isScanLive`) | `joincode` "Quét QR" pill |

## Method

The shipped `main.dart` entry gates every pairing screen behind an authenticated
session (`mobile/lib/app/cupid_app.dart` → `home: SplashScreen`), so the flow is not
reachable by tapping through a signed-out product build. The audit therefore ran the
`main_preview.dart` harness APK started at `--dart-define=PREVIEW=pairstart` and then
**navigated with real taps** through the shipped widgets and the shipped
`onboardingRouteBuilders()` registry — the screens, routes, and push edges under test
are production code, only the entry point is the harness.

- Capture tool: `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh --max-edge=900`
- No `--width` / `--density` override: display was never resized, so tap coordinates and
  density stayed constant across the whole walk (native 1080x2400 → 405x900 captures).
- No Appium / Maestro / Detox / Espresso / XCUITest / UIAutomator / Playwright and no e2e
  suite was run. Screenshot capture plus visual inspection only.
- Every frame was byte-size sanity-checked before acceptance (a settled `pairstart` frame
  is ~161 KB; a splash frame is ~16 KB) so no pre-settle frame entered the evidence set.

### In-session verification (mobile lane build gate)

The product build/runtime gate was already closed by devops on this exact HEAD
(`integration-review/build-runtime-evidence.md`) and was **not** re-run. The mobile lane's
own in-session evidence:

| Command | Result |
|---|---|
| `flutter build apk --flavor local --debug -t lib/main_preview.dart` (worktree `mobile/`) | exit 0 |
| `flutter test test/features/pairing` (worktree `mobile/`) | `+234: All tests passed!` |

## Captured evidence

All paths relative to `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/integration-review/mobile-screenshots/`.
All frames 405x900, device `emulator-5554`.

| Step | Screenshot | What it shows | Visual result |
|---|---|---|---|
| 1 | `implemented-flow-01-pairstart-emulator-5554.png` | pairing-method choice, cold start | OK |
| 2 | `implemented-flow-02-invite-pushed-emulator-5554.png` | create-code screen pushed live from row 1 | Loading spinner (backend unreachable from harness) — see Note H1 |
| 3 | `implemented-flow-03-back-at-pairstart-emulator-5554.png` | back returns to pairstart, no state loss | OK |
| 4 | `implemented-flow-04-joincode-pushed-emulator-5554.png` | join-with-code screen pushed from row 3 | OK |
| 5 | `implemented-flow-05-scan-entry-immediate-emulator-5554.png` | first frame after "Quét QR" tap | OK (no flash of unstyled chrome) |
| 6 | `implemented-flow-06-scan-overlay-settled-emulator-5554.png` | OS camera-permission dialog over the overlay | See CF-3 |
| 7 | `implemented-flow-07-scan-overlay-granted-emulator-5554.png` | scan overlay with a **live** camera feed | See CF-2 |
| 8 | `implemented-flow-08-back-at-joincode-emulator-5554.png` | overlay dismissed, half-typed state intact | OK |
| 9 | `implemented-flow-09-invite-from-joincode-crosslink-emulator-5554.png` | after tapping "Tôi mới là người tạo mã →" | Unchanged join-code screen — see CF-4 |
| 10 | `implemented-flow-10-back-after-crosslink-emulator-5554.png` | back lands on pairstart, proving nothing was pushed | Confirms CF-4 |
| 11 | `implemented-flow-11-invite-seeded-populated-emulator-5554.png` | create-code screen in its populated state (QR + couple-type card) via `cupidpreview://screen/invite` | OK |
| 12 | `implemented-flow-12-crosslink-retry-emulator-5554.png` | cross-link retry on a clean cold start | Confirms CF-4 |

## Cross-screen findings

No screen showed clipping, overlap, misalignment, safe-area intrusion, wrong-density
rendering, or a missing CTA when entered through the live flow rather than in isolation.
Header, background gradient, spacing rhythm, and type ramp are continuous across all four
screens. The four findings below are the only cross-screen defects observed, and none of
them blocks REQ-012 integration.

### CF-1 — "8 ký tự" on pairstart vs a 6-character code downstream (non-blocking, PO/UX decision)

- Where: `pairstart` row 1 body copy vs the create-code and join-code screens.
- Observed: step 1 promises `Nhận mã 8 ký tự + QR, gửi cho người ấy` / `Get an 8-char code
  + QR to send them`, but the code the flow actually produces and accepts is 6 characters.
- Source of truth: `mobile/lib/features/pairing/presentation/pairing_code_parser.dart:2`
  → `const int pairingCodeLength = 6;`, mirrored by `_codeLength` in `joincode_screen.dart`
  (6 entry slots, visible in steps 4 and 8).
- Attribution: the implementation is **faithful to the locked design source** —
  `cupid-app-design-system/Cupid Screens.dc.html:1586` carries the same "8 ký tự" string.
  This is a copy defect in the design source, not implementation drift, so it is out of
  mobile's authority to change.
- Why per-story capture missed it: the promise and the contradiction live on two different
  screens; each screen is internally consistent.
- Recommendation: Product Owner / UI-UX decide whether the copy or the code length is
  wrong, then queue the change. Not a rendering defect.

### CF-2 — scan overlay chrome sits directly on the live camera with no scrim (non-blocking)

- Where: `scan` overlay, live state (step 7, the only frame in the requirement with a real
  camera feed).
- Observed: with a bright emulator scene behind it, the muted caption
  `Đưa camera vào mã QR của người ấy` is hard to read, and the letterbox bands above and
  below the camera aspect expose the purple `CupidAppBackground` gradient, which reads as a
  seam between two unrelated surfaces.
- Design expectation: `Cupid Screens.dc.html:1683` gives `isScanLive` an opaque
  `background:#0B0812` backdrop, and the caption at line 1690 uses the muted `--tx2` token,
  which is only legible against that near-black backdrop. `scan_code_screen.dart` defines
  `_dimmedViewfinderOpacity = 0.35` for the invalid-card state only; there is no
  scrim/backdrop constant for the live state.
- Why per-story capture missed it: STORY-003's own
  `implemented-scan-live-emulator-5554.png` used the harness placeholder, i.e. a
  full-screen black camera surface, which accidentally satisfies the design backdrop.
  Contrast against a real feed could not be evaluated until this flow walk.
- Recommendation: queue a follow-up to add the live-state scrim/backdrop. Cosmetic
  legibility, not a functional break — the viewfinder, scan line, and controls all render
  correctly.

### CF-3 — camera permission dialog says "cupid_mobile", not "Cupid" (non-blocking, cosmetic)

- Where: OS runtime-permission dialog in step 6, now unavoidable in the flow because
  STORY-003 made CAMERA a runtime request at the "Quét QR" tap.
- Observed: "Allow **cupid_mobile** to take pictures and record video?" — the first
  user-visible product-name surface in the pairing flow shows the module name.
- Source: `android:label="cupid_mobile"` in
  `mobile/android/app/src/main/AndroidManifest.xml`.
- Attribution: pre-existing manifest string, not REQ-012 code. It only became
  user-visible because REQ-012 introduced the permission prompt.
- Recommendation: DevOps/mobile follow-up to set the display label; out of scope here.

### CF-4 — dead cross-link "Tôi mới là người tạo mã →" on the join-code screen (non-blocking, pre-existing)

- Where: join-code screen bottom cross-link, the flow's only direct join-code → create-code
  edge (steps 9, 10, 12).
- Observed: the tap lands (an ink ripple is visible in a held-press capture) but nothing
  navigates after 5–8 s; Android back from the join-code screen then returns to `pairstart`,
  proving no route was ever pushed. Reproduced twice, including on a clean cold start.
- Root cause, source-verified: `joincode_screen.dart` calls
  `_router.push(context, OnboardingNode.invite)`, while
  `mobile/lib/core/di/service_locator.dart:393-399` documents that
  `OnboardingNode.invite` is **deliberately not registered** in
  `onboardingRouteBuilders()` (it needs a `createInviteCubit` seam no `WidgetBuilder` can
  supply), so `OnboardingRouter._routeFor` cannot produce a route for it. The other edge on
  the same screen (`_openScanner`) uses a direct `Navigator.push` and works, which isolates
  the registry lookup as the failing element.
- Attribution: introduced by REQ-002 STORY-047 (`696c1aa`), **not** by REQ-012. Widget
  tests inject a fake `router`, so the dead edge is invisible to unit tests, and per-story
  captures never crossed the two screens.
- Recommendation: file a bug-queue item against the pairing navigation registry. Deliberately
  **not** fixed here — this audit is forbidden from changing product behavior.

## Notes

- **H1 (harness artefact, not a product defect):** in step 2 the create-code screen pushed
  from `pairstart` shows a spinner because `PairingChoiceScreen` forwards
  `createInviteCubit: null`, so the real `InviteCubit` calls a backend the capture machine
  cannot reach. The same screen's populated design state is captured in step 11 through the
  seeded `cupidpreview://screen/invite` entry (full QR card + couple-type card). No product
  finding is raised from step 2.
- **Device state left behind:** `emulator-5554` currently holds the preview-entrypoint debug
  APK. It shares `applicationId com.snapsofts.cupid` with the product build devops installed,
  so it replaced that install; product code is identical, only `main` differs. Reinstall the
  product entrypoint before reusing this emulator for product runtime evidence. No rebuild
  was performed to restore it, per the handoff's do-not-rebuild instruction.

## Conclusion

The three restyled REQ-012 screens hold together as one connected flow: every entry point
resolves, every push and back edge preserves state, and no broken, clipped, overlapping,
misaligned, wrong-density, or safe-area-violating component appeared on any screen when
entered live. Four non-blocking findings are recorded above, two of them (CF-1, CF-4)
attributable to sources outside REQ-012 and two (CF-2, CF-3) cosmetic follow-ups.

IF-2 is closed. `MOBILE_VISUAL_AUDIT_COMPLETE: YES`
