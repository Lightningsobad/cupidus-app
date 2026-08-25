# STORY-003 Scoped-Slice Review — Slice 3 of 3: Screen States, Entry Point, Preview

REVIEW_SLICE_COMPLETE: YES
Slice-Outcome: CLEAN (2 DEFERRED doc/polish items, 1 UNVERIFIED a11y detail — none blocking)
Reviewer: Iris-QC (`reviewer`, Mode `scoped-slice`)
RunId: RUN-REQ-012-STORY-003-reviewer-slice3
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-003_scan_code_screen_qr_scanning_capability`
BaseHead: `d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b`

This slice reports its own findings only. It does not render a story Outcome or a
DONE recommendation — that is Final Synthesis's decision.

## 1. Slice scope confirmed

`git -C <Worktree> diff --name-only <BaseHead> -- mobile/` returns 16 files. The 6
in this slice, and only these, were reviewed:

| # | File | Diff |
|---|------|------|
| 1 | `mobile/lib/features/pairing/presentation/screens/scan_code_screen.dart` | +590 (new) |
| 2 | `mobile/test/features/pairing/presentation/screens/scan_code_screen_test.dart` | +527 (new) |
| 3 | `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart` | +83 / -17 |
| 4 | `mobile/test/features/pairing/presentation/joincode_screen_test.dart` | +177 |
| 5 | `mobile/lib/features/pairing/presentation/scan_code_route.dart` | +55 (new) |
| 6 | `mobile/lib/main_preview.dart` | +89 |

Permission-gate logic (Slice 1) and cubit/parser logic (Slice 2) were not
re-reviewed. The post-BaseHead commit adding `review/review-report.md` touches no
`mobile/` source and was ignored as instructed.

## 2. AC verdicts

### AC3 — UI half (denied/unavailable falls back to manual entry, unblocked) — PASS

| Requirement | Evidence |
|---|---|
| State 5 renders a clear message, no camera | `scan_code_screen.dart:172-182` `_MessageState` with `_noPhotographyIcon` + "Cupid cần quyền camera để quét mã QR"; capture `implemented-scan-denied-emulator-5554.png` shows exactly that; test `State 5 … explains the block and offers manual entry, no camera` asserts `lifecycle.mounts == 0`, i.e. no camera surface is ever built (`scan_code_screen_test.dart:388-401`) |
| State 6 points at Settings AND keeps a manual way out | `scan_code_screen.dart:183-192` (primary `Mở Cài đặt` → `openSettings`, secondary `onManualEntry`); capture `implemented-scan-blocked-…png` shows both; tests at `scan_code_screen_test.dart:415-446` assert copy, both actions, `openSettingsCalls == 1`, and that the overlay stays open |
| State 7 offers exactly one way forward, no Settings link | `scan_code_screen.dart:193-201`; capture `implemented-scan-unavailable-…png`; test at `scan_code_screen_test.dart:449-462` asserts `Open Settings` and `Try again` are both `findsNothing` |
| Fallback returns to the *same* screen, unchanged | `ScanCodeRoute` is an opaque `PageRouteBuilder` (`scan_code_route.dart:28-53`), so `JoincodeScreen` below stays mounted; `joincode_screen.dart:178-193` `_openScanner` awaits the pop and touches neither `_codeController` nor its text; test `a dismissed scan leaves the half-typed code untouched` (`joincode_screen_test.dart` new group) asserts `3F9` and its slot glyphs survive |
| Close control present in every state | `scan_code_screen.dart:145-153` renders `_CloseControl` outside the state switch; visible in all 5 captures; test `close control is present and labelled in every state` loops `CameraPermissionState.values` |

AC3's logic half was verified in Slice 1 and was not redone.

### AC4 — UI-rendering half (honest invalid-code state, retry or manual) — PASS

| Requirement | Evidence |
|---|---|
| Honest error copy, no fabricated success | `scan_code_screen.dart:368-420` `_InvalidCard` — error icon in `colors.colorRed`, copy "Mã QR không hợp lệ hoặc đã hết hạn"; capture `implemented-scan-invalid-emulator-5554.png` confirms; test at `scan_code_screen_test.dart:290-303` additionally asserts `accept.codes` is empty and `exits` is empty (no network call, no false exit) |
| Retry resumes live scanning | `_InvalidCard` primary → `onRetry`; test `Try again re-arms scanning immediately` (`scan_code_screen_test.dart:320-336`) asserts the card is gone, State 2 helper copy is back, and a subsequent valid emit reaches `acceptInvitation` with `ABC123` |
| Manual-entry fallback from the error state | `scan_code_screen.dart:413`; test at `:373-385` asserts `exits == [manualEntry]` and `lifecycle.disposals == 1` (camera released) |
| Camera keeps running behind the card (ux-spec:102-103) | `scan_code_screen.dart:261-280` keeps one `previewBuilder` instance across States 2/3/4; test at `:305-318` asserts `mounts == 1`, `disposals == 0` while the card shows; the capture shows the pink viewfinder still framing the card |
| Card auto-dismisses after ~3s (ux-spec:117-120) | `scan_code_screen.dart:53` `_invalidAutoDismiss = 3s`, `:121-131` timer cancelled/rearmed per state; test `the card steps aside on its own after ~3s` (`:338-355`) |

AC4's cubit logic was verified in Slice 2 and was not redone.

### AC5 — dark theme + `vi` design fidelity — PASS (1 DEFERRED deviation, see §5)

Verified by reading the capture PNGs, not only the report text.

**Entry point, independently re-derived from the design source.** I read
`cupid-app-design-system/Cupid Screens.dc.html:1628-1637` directly rather than
trusting the fidelity report's table, and compared it to
`joincode_screen.dart:606-645`:

| Design source (`Cupid Screens.dc.html`) | Implementation | Result |
|---|---|---|
| `:1630` `display:flex;gap:10px;margin-top:24px` | `Row` of two `Expanded`, `_pillGap = 10`, `SizedBox(height: CupidSpacing.lg)` = 24 | match |
| `:1631-1632` two `flex:1` children, `height:48px` | two `Expanded`, `_pasteHeight = 48` | match |
| `:1631-1632` `border-radius:var(--r-btn)`, `1.5px solid var(--line)` | `platformTokens.radiusButton`, `colors.colorLine`, `_slotBorderWidth` (`joincode_screen.dart:608-621`) | match |
| `:1631` `content_paste` 19px `var(--tx2)` + Dán/Paste | `_contentPasteIcon`, `_pasteIconSize = 19`, `colorTextMuted` | match |
| `:1632` `qr_code_scanner` 19px `var(--tx2)` + Quét QR/Scan QR | `_qrCodeScannerIcon` (`0xf206`), same sizing | match |
| `:1631-1632` `font-size:14px;font-weight:700` | `_pasteLabelFontSize = 14`, `FontWeight.w700` | match |
| `:1634` CTA `margin-top:14px` | `_actionGap = 14` | match |
| `:1621-1628` code row, `:1634` Ghép đôi, `:1635` switch link untouched | absent from the diff hunks | match |

Capture `implemented-joincode-two-pill-row-emulator-5554.png` shows the two pills
sharing one row at equal width above `Ghép đôi`, with the 6-box code row, paste
pill, CTA and switch link visually unchanged. No overflow banner. This closes
AC5's "preserve existing manual UI unchanged" half and In-Scope item 5.

**Overlay states, against `ux/ux-spec.md`** (the design canvas has no `sc-if`
block for the scan surface — I confirmed the `isJoinCode` block ends at
`Cupid Screens.dc.html:1637` with no scan sibling, so the UX spec is correctly the
only comparison source):

| Spec | Capture read | Result |
|---|---|---|
| `:68-73` full-viewport preview, centred viewfinder in `var(--pink)` at ~70% of the shorter edge | `implemented-scan-live-…png`: pink rounded frame spanning ≈283/405 px ≈ 70% of width (the shorter edge); `scan_code_screen.dart:296-312` computes exactly `min(w,h) * 0.7` | match |
| `:78-80` helper copy at caption size, `var(--tx2)` | "Đưa camera vào mã QR của người ấy" visible, muted; `scan_code_screen.dart:349-356` `type.caption` + `colorTextMuted` | match |
| `:81-84` manual-entry link pinned low, pink, w700, 13px | visible bottom-centre in pink; `scan_code_screen.dart:496-504` `_linkFontSize = 13`, `w700`, `colorAccentPink` | match |
| `:52-54` top-left close icon, ≥44x44 | X glyph top-left in all 5 captures; `scan_code_screen.dart:525-538` `platformTokens.tapTarget` constraints + `tooltip` | match |
| `:99-116` State 4 card: `var(--surf)` fill, `var(--line)` border, failure icon, copy, `Thử lại` primary + manual secondary | all present in `implemented-scan-invalid-…png` | match except corner radius — §4 |
| `:122-135` / `:137-147` / `:149-155` States 5/6/7 copy and actions | all three captures carry the exact spec strings and exactly the specified actions | match |
| `:157-165` Fallback Guarantee | a manual-entry path is visible in all 5 captured states | match |
| `:167-177` reused tokens only | every colour read through `CupidColorTokens`/`CupidPlatformTokens`; no raw `Color(0x`/`Colors.` in `lib/features/pairing` (pinned by `no_fork_guard_test.dart`, a test rather than a grep) | match |
| `:74-77` "subtle animated scan-line or pulsing frame border" in State 2 | **not implemented** — see §5.1 | deviation, DEFERRED |

States 1 and 3 are ≤400ms transients and are not frame-grabbed; they are covered
by `scan_code_screen_test.dart` (`State 1 — opening …`, three `State 3 —
recognized …` tests). Withholding a capture for them is correct, not a gap.

## 3. Entry Point Reachability — VERDICT: REACHABLE (confirmed independently)

Chain, traced in source rather than accepted from prose:

1. `pairing_choice_screen.dart:44-53` — `_openJoincode` pushes `JoincodeScreen`
   from the "Tôi đã có mã" / "I already have a code" `TextButton`
   (`:105-110`). This screen is the pairing-stack root for an unpaired user
   (`:10-16`) and is **not** in this story's diff, so the host screen was already
   reachable before STORY-003.
2. `joincode_screen.dart:324-352` — the `Quét QR` / `Scan QR` `_ActionPill` is a
   real, enabled control in the two-pill row, disabled only while `isBusy`.
3. `joincode_screen.dart:178-193` — its `onPressed` calls `_openScanner`, which
   pushes `ScanCodeRoute`.
4. `scan_code_route.dart:28-53` — builds `ScanCodeScreen` under
   `BlocProvider<JoincodeCubit>.value` with the **join-code screen's own** cubit
   instance.
5. `joincode_screen.dart:73-121` — `scanPermissionGate` defaults to
   `const PermissionHandlerCameraGate()` and `scanPreviewBuilder` to `null`
   (→ `_mobileScannerPreview`, `scan_code_screen.dart:70`). The production path
   therefore uses the real gate and the real `mobile_scanner`; the injected fakes
   are test/preview-only seams, not the shipped default.

No `--dart-define`, debug flag, or preview-only route is required. Reachability is
also asserted at runtime by `tapping the scan pill opens the scan overlay`
(`expect(find.byType(ScanCodeScreen), findsOneWidget)`) in
`joincode_screen_test.dart`.

**DEFERRED-1 (documentation only).** The handoff asked me to verify a
`## Entry Point Reachability` section in `coding-plan/test-results.md`. **That
section does not exist.** I read all 559 lines of that file (ranges 1-100,
100-180, 180-559); its headings are P1, P2, P3, P4 and `## Story Runtime Startup
Smoke`. Reachability is only stated indirectly, inside the P4 test narrative at
`test-results.md:318-332`. The substantive claim holds — I verified it from source
above — so this is a missing-heading gap in the evidence artifact, not a defect in
the delivered screen. Recommend the section be added (or the checkpoint's
reference to it corrected) rather than treating it as a functional finding.

## 4. `_InvalidCard` radius deviation — VERDICT: CLEAN (acceptable as shipped)

`ux/ux-spec.md:104-106` asks the State 4 card for "rounded corners matching
`var(--r-btn)` radius convention", and `:175` lists `var(--r-btn)` as the
"button/card corner radius". `Cupid Screens.dc.html:24-25` defines `--r-btn` as
`999px`. `scan_code_screen.dart:388` instead uses `platformTokens.radiusCard`
(24 Material / 26 iOS).

Ruled **CLEAN**, for five reasons:

1. **The spec names a convention, not a literal.** `:105` says "matching
   `var(--r-btn)` radius convention used elsewhere on this screen" — and
   everywhere `--r-btn` is used on this screen (`:1631`, `:1632`, `:1634`) it sits
   on a 48-54px-tall control, where 999px resolves to a stadium *because the
   element is short*. A 280dp-wide, ~200dp-tall card is not that class of element.
2. **The literal reading contradicts the spec's own intent.** `ux-spec.md:200-202`
   requires States 4-7 to "cap card width consistently with other dialog/card
   patterns already in this design system". `radiusCard` is that design system's
   card pattern; `radiusButton` at 999 renders the same box as a stadium blob,
   which is what the first capture pass actually showed
   (`visual-fidelity-report.md:147-150`).
3. **No token was invented.** `radiusCard` is an existing `CupidPlatformTokens`
   member whose own doc reads "Card/content container corner radius", and
   `_Viewfinder` in the same file already reaches for `radiusSheet`
   (`scan_code_screen.dart:311`). `ux-spec.md:167-177`'s "no new tokens" constraint
   still holds.
4. **Non-regressive.** The change is confined to one `BorderRadius.circular`
   argument on a surface this story introduced. No pre-existing screen, token, or
   shared widget is affected.
5. **Documented, not absorbed silently.** Flagged at
   `visual-fidelity-report.md:137-160` and `test-results.md:462-473`, found by
   looking at a capture rather than by a test, and reverting is a one-token edit.
   That is the behaviour the process wants to reward.

I verified this against the capture: `implemented-scan-invalid-emulator-5554.png`
shows a correctly bounded card with content sitting properly inside its corners.
Forcing 999px here would degrade the shipped result to satisfy a token name.

**DEFERRED-2 (documentation only, non-blocking).** The artifact should stop
contradicting the shipped code. Adopt the fidelity report's own recommendation
(`visual-fidelity-report.md:158-160`): amend `ux/ux-spec.md:104-106` and `:175` to
name a card radius for card-shaped surfaces. This is a UI-UX doc edit, not a code
patch, and must not gate this story.

## 5. Additional findings

### 5.1 DEFERRED — State 2's animated pulse / scan-line is not implemented

`ux/ux-spec.md:74-77` specifies for State 2 a "Subtle animated scan-line or
pulsing frame border … a simple opacity/border pulse is sufficient".

`scan_code_screen.dart:301-324` `_Viewfinder` uses an `AnimatedContainer` whose
`duration` is `_recognizedFlashDuration` and whose border colour depends only on
`recognized`. It animates **once**, on the State 2 → State 3 transition. There is
no repeating animation controller, so the live-scanning frame is static.

Why DEFERRED rather than PATCH_REQUIRED: AC5 enumerates "layout, spacing,
color/token usage, and typography" — motion is not among them, so this does not
fail the acceptance criterion as written. It affects no function, no accessibility
path, and no fallback guarantee. It is genuinely absent, though, and
`visual-fidelity-report.md:112` reports State 2 as an unqualified "match" without
disclosing it — a still capture cannot reveal missing motion, which is exactly why
this needed a source read. Recommend Final Synthesis either queue it as a small
follow-up or record an explicit UX waiver; either way the fidelity report's State 2
row should be annotated.

### 5.2 UNVERIFIED — focus is not explicitly returned to the "Quét QR" pill on plain dismiss

`ux/ux-spec.md:190-193` requires the overlay to "return focus to the 'Quét QR'
button (or the manual entry code boxes, if the user chose manual fallback) on
dismiss".

`joincode_screen.dart:186-192` restores focus only on
`ScanCodeExit.manualEntry` (`_codeFocusNode.requestFocus()`); on
`ScanCodeExit.dismissed` it deliberately returns without touching focus
(`:181-185` records that as intentional). In practice Flutter's `Navigator`
restores the prior route's `FocusScope` on pop, so focus very likely does land
back on the pill — but nothing in the two test files asserts it, and I did not
have a screen-reader/keyboard run to confirm it. Marked UNVERIFIED rather than
FAIL. The focus-*trap* half of `:190-193` is satisfied structurally: an opaque
pushed route owns its own focus scope, so the join-code screen underneath is not
tabbable while the overlay is open.

### 5.3 CLEAN — preview registration

`main_preview.dart:256-265` registers a `'scan'` key in the `previewScreens` map
with a `seedNote`, and `:1284-1360` supplies `_buildScan`, driving state from
`--dart-define=PREVIEW_SCAN_STATE` through both of the seams `ScanCodeScreen`
exposes. The entry is present in the registry map — not merely defined as an
orphan builder — so `cupidpreview://screen/scan` resolves. The `Colors.black`
literal in `_PreviewScanSurface` is harness-only; `no_fork_guard_test.dart` scans
`lib/features`, `lib/app`, `lib/core` and by design excludes `lib/main_preview.dart`
(`visual-fidelity-report.md:168-174`). Not a fork violation.

### 5.4 CLEAN — test quality spot-check

I read the test harnesses rather than only the pass counts, to confirm the 23
State-1..7 assertions are substantive and not tautological.
`scan_code_screen_test.dart:13-92` builds a real `_AcceptInvitationStub` (records
the exact submitted string, can hold the call open so State 3 is observable) and a
`_PreviewLifecycle` that counts mounts/disposals — so "the camera session dies with
the subtree" and "the camera keeps running under the card" are measured, not
asserted by comment. `joincode_screen_test.dart`'s AC2 parity test drives one stub
twice under distinct `MaterialApp` keys and asserts
`submitted == ['3F9A2B','3F9A2B']` plus `find.byType(ScanCodeScreen), findsNothing`
— identity of outcome, not merely of call. Tests exercise `en` strings while the
captures cover `vi`; together the two locales are covered.

### 5.5 Noted, not a slice finding

- The `+279 -1` / `+297 -1` suite failures are the pre-existing
  `no_fork_guard_test.dart` hit on `pet_preview_card.dart:229-230`, a file absent
  from this worktree's diff against BaseHead. Outside this story's write scope;
  Scrum Master's to queue separately.
- No `scrum-master-checkpoint.md` exists under the STORY-003 directory in this
  worktree, though the handoff cites that path. Flagged for Scrum Master; it does
  not affect any verdict in this slice.

## 6. Runtime startup smoke — evidence accepted for this slice

`test-results.md:522-559` records Result PASS, owner Scrum Master, on
`emulator-5554`, using the `mobile-app` runtime registry entry: `flutter build apk
--debug` succeeded, the debug APK was installed via `adb install -r`, the
registry's exact `readiness.command` (`am start -W` + resumed-activity poll)
returned exit 0 on the first poll, and the registry's exact
`readiness.shutdownCommand` (`am force-stop`) left the device clean. The narrative
names the concrete workaround it needed (the registry's `flutter install` picked
the release flavor and failed) instead of glossing it, and it states its own limit
plainly at `:556-559`: the smoke covers app launch to first screen only, not the
scan flow, permission prompt, or decode path.

That limit is the right one for this slice. Slice 3's surface is exercised by the
23 + 5 widget tests and the 6 device captures above, both of which are runtime
evidence on the actual states. The smoke's job here is to prove the app still boots
with `mobile_scanner`, `permission_handler`, and the new manifest/Info.plist
entries linked in — which it does. **Sufficient. Not re-requested, not routed back
to mobile-dev.**

## 7. Slice result

| Item | Verdict |
|---|---|
| AC3 — UI half | PASS |
| AC4 — UI-rendering half | PASS |
| AC5 — design fidelity, dark + `vi` | PASS (with 5.1 deferred) |
| Entry Point Reachability | REACHABLE — confirmed from source (DEFERRED-1: named evidence section missing) |
| `_InvalidCard` radius deviation | **CLEAN** — intentional, documented, non-regressive, acceptable as shipped (DEFERRED-2: amend the UX spec text) |
| Design-fidelity image comparison (6 PNGs read) | PASS |
| Preview registration | CLEAN |
| Runtime startup smoke evidence | Genuine and sufficient for this slice |

No PATCH_REQUIRED item in this slice. Three non-blocking carry-forwards for Final
Synthesis: DEFERRED-1 (add the reachability section), DEFERRED-2 (amend
`ux-spec.md:104-106`/`:175` to name a card radius), and 5.1 (State 2 pulse absent —
queue or waive). One UNVERIFIED a11y detail: 5.2.

REVIEW_SLICE_COMPLETE: YES
