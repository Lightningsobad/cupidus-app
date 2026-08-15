# Story Review — STORY-007 Design Fidelity: OTP Verification

Outcome: DEFERRED_ONLY

Round: 1
Review mode: compact-story-review
Reviewer: Iris-QC
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-007`
BaseHead: `4eadb3d871890a9a830d1e9ddb8a161e69a7d6a3`
Reviewed HEAD: `a25cf043aff955556d81a11e8c9825b620f2d2f0`
Merge target: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`

The branch carries three commits (`3c52c376` code + evidence, `3b450e31`
report wording, `a25cf043` story-artifact gate note). Only `3c52c376` changes
code; the later two touch `story_master.md` /
`visual-fidelity-report.md` only. The gate runs and capture review below were
re-confirmed valid against `a25cf043` — `otp_screen.dart`,
`main_preview.dart`, and `otp_screen_test.dart` are byte-identical across all
three commits.

## Diff scope (verified)

`git diff 4eadb3d..a25cf043` — 7 files, 905 insertions, 3 deletions:

- `mobile/lib/features/auth/presentation/screens/otp_screen.dart` (new, 485)
- `mobile/lib/main_preview.dart` (+10 / -1)
- `mobile/test/features/auth/otp_screen_test.dart` (new, 221)
- `.../STORY-007_otp_design_fidelity/story_master.md`
- `.../visual-fidelity/visual-fidelity-report.md` + two PNGs

No shared design-system, routing, or sibling-story file is touched. Write
scope is clean; working tree is clean.

## Acceptance criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC1 layout/spacing/colour/typography match, dark + `vi` | PASS on this story's own surface; 2 shared-chrome deltas DEFERRED | Two-image comparison + canvas transcription below |
| AC2 deviations corrected in the app, not merely documented | PASS | 5 deltas fixed in code and re-captured |
| AC3 states present in the design source match | PASS | 3 composed states implemented + unit-tested; 2 states absent from source |
| AC4 no new entry point | PASS | Independently verified by reference grep |

### AC1 — verified against the locked canvas

The design block is `Cupid Screens.dc.html:1495-1511` (`sc-if isOtp`). I
compared the implementation element by element against that source; every
in-scope value matches:

- Container padding `20px 20px 40px` = `EdgeInsets.fromLTRB(20, 20, 20, 40)`
- Badge `78x78`, radius `28`, `rgba(255,127,182,.18)` = `--pink` @ 18%,
  `mark_email_unread` glyph at 40px pink, `popIn .5s ease-out`
- Title Nunito w900 24px, margin-top 20
- Subtitle 13px / line-height 1.6 / `--tx2`, margin-top 9, email `<strong>`
  in `--tx`
- Code row gap 9, margin-top 28; cells radius 16, `--surf`, 1.5px border,
  `--pink` + `var(--glow)` when filled, `--line` when empty, Nunito w900 24px
- Caret cell: `--line` border with a pink `|` (canvas line 1504)
- Cooldown 12.5px `--tx2`, margin-top 22, `00:42` in `--tx` Roboto Mono
- CTA margin-top 26, height 54, `--r-btn`, `--grad-hot`, `var(--glow)`,
  16.5px w800
- Header title `Xác thực` / `Verify` — confirmed against `t_otp` at canvas
  line 1769. Mobile-dev's correction away from `Xác thực OTP` is right; that
  longer string is the prototype-only screen-index FAB label.

The two captures
(`visual-fidelity/design-reference-otp-android.png`,
`visual-fidelity/implemented-otp-emulator-5560.png`) agree on every one of
these landmarks. I found no third delta beyond the two deferred below.

Three intentional deviations are documented and I accept each:

1. Cell painted `49x59` rather than the literal `46x56` — the canvas has no
   `box-sizing:border-box`, so `46 + 2x1.5px` border paints 49x59. Flutter
   insets borders, so the outer box must carry them. Painted result identical.
2. CTA label uses `colorText` rather than raw `#fff` — required by the
   no-fork guard (ADR-004), which forbids raw colour literals in `features/`.
3. Subtitle `max-width` raised 280 -> 300 — the literal cap wraps
   `minh@gmail.com` onto a second line under Android's Roboto and pushes the
   whole lower stack down ~27dp. The 300 cap reproduces the design's single
   line. This is the correct trade: it preserves the design's rendered
   result rather than its literal number.

### AC3 — states

Three states are composed in the canvas and are implemented and unit-tested:
empty, partially entered, and resend-cooldown. Assertions check real tokens
(`CupidColorTokens.dark()`), not just widget presence — filled cells are
asserted to carry `colorAccentPink` + `glowShadow`, empty cells `colorLine`
and no shadow.

Two states have no design-source basis, and AC3 is explicitly conditioned on
states "present in the design source":

- **error/invalid code — N/A, correctly not invented.** I confirmed `isOtp`
  holds exactly one composed frame with no error styling, copy, or colour.
  Inventing one would have been the wrong call for a fidelity story.
- **resend-available — extrapolated, non-blocking.** The canvas composes only
  the cooldown. The implementation renders `Gửi lại mã` / `Resend code` in
  `colorAccentPink` at w700, reusing the canvas's own inline-action idiom —
  `<strong style="color:var(--pink)">`, verified at canvas line 1491 (the
  `Đăng nhập` / `Log in` inline action). This is a minimal, faithful
  extrapolation from an idiom the source actually uses, not an invention. I
  judge it reasonable and non-blocking. It is correctly flagged for
  ui-ux-designer confirmation if the design source ever gains the state; no
  PO/UX follow-up is required to close this story.

### AC4 — no new entry point (independently verified)

Confirmed, not taken on trust. `grep -rn "OtpScreen\|otp_screen" mobile/lib
mobile/test` returns references only from:

- `mobile/lib/main_preview.dart:63,520` — the preview harness
- `mobile/lib/features/auth/presentation/screens/otp_screen.dart` — the
  definition
- `mobile/test/features/auth/otp_screen_test.dart:2,22` — its test

No route, no navigator call, no production reference. `mobile/lib/main.dart`
and app routing are untouched by the diff. Removing `'otp'` from
`_notImplementedCanvasIds` changes the preview harness only. AC4 holds.

The story's stated premise ("the current otp screen, already reachable in the
shipped app") was false — no OTP screen existed in `mobile/lib`, and `otp` sat
on the approved REQ-001 scope-cut list (STORY-018 OQ-1). Building it
presentational/preview-only follows the STORY-009 `permissions` precedent from
the same scope-cut list. I agree with delivering rather than blocking, and the
premise correction is properly recorded in `story_master.md`.

## Gates — rerun independently by the reviewer

| Gate | Result |
|---|---|
| `flutter analyze --no-fatal-infos` (whole `mobile/`) | 11028 issues repo-wide, **0 in `otp_screen.dart`, 0 in `main_preview.dart`, 0 error-severity anywhere**. All noise is pre-existing info/warning (generated `openapi/` unused imports, `prefer_initializing_formals`). PASS for this story. |
| `flutter test test/features/auth/otp_screen_test.dart test/design_system/adaptive_widgets_test.dart` | **21/21 pass** |
| `flutter test test/design_system/no_fork_guard_test.dart test/features/reminders/reminder_copy_guard_test.dart` | 2 failures — both pre-existing, see below |

I did not accept mobile-dev's gate claims; every result above is from a fresh
run in this worktree.

## Pre-existing red — confirmed, accepted as deferred

Per Scrum Master ruling, recorded here and not re-raised as a blocker. I
independently confirmed each item is present at BaseHead and absent from this
story's diff:

- **`no_fork_guard_test.dart`** — 7 violations in
  `ghost_settings_screen.dart:211,411`,
  `notification_settings_screen.dart:360`,
  `reminder_schedule_screen.dart:449,450,453`,
  `reminder_weekday_chips.dart:71`. None of these files appears in this
  story's diff, so they are byte-identical to BaseHead. No violation names
  `otp_screen.dart` or `main_preview.dart` — this story introduces no new
  guard violation.
- **`reminder_copy_guard_test.dart`** — `permissions_screen.dart:80,81` ship
  the banned string `Synced Alarm`. Verified byte-identical at BaseHead and
  HEAD via `git grep "Synced Alarm" <ref> -- mobile/lib`. This is a
  product-rule (ADR-002) violation on already-merged work.

Owners per Scrum Master: STORY-019/031/021/009. Both are queued as a separate
bug after this wave. Mobile-dev's analysis that four of the `no_fork_guard`
violations are `Colors.transparent` with no in-scope fix (the guard is a blunt
substring match with no allowlist) is accurate and is a genuine
tech-lead/design-system decision, not something this story could have closed.

## Deferred items — shared chrome, correctly out of scope

Both were independently confirmed as (a) genuinely visible in the capture
comparison and (b) genuinely design-system-layer, not local to this screen:

| # | Delta | Verification | Owner |
|---|---|---|---|
| D1 | Header back arrow renders white; the design paints it `var(--pink)` at 26px | Design source `Cupid Screens.dc.html:52` confirms `font-size:26px;color:var(--pink)`. App side is `mobile/lib/design_system/adaptive/cupid_header.dart:168`, `color: colors.colorText`, inside the shared `CupidHeader` widget. `OtpScreen` only passes `onBack:` and cannot override the arrow colour without editing the shared widget. Affects every screen with a back affordance. | design-system / `CupidHeader` |
| D2 | Background is flat `colorBackground`; the design paints `var(--sky), var(--bg)` — three radial washes plus faint stars — behind the app shell, with a transparent header over it | Design source `Cupid Screens.dc.html:44` (`background:var(--sky),var(--bg)`), `:45-47` (three twinkling stars), `:50` (`background:transparent;backdrop-filter:blur(16px)`). App side: `CupidColorTokens.skyGradient` exists but is a `final String` CSS value that no widget renders (`cupid_color_tokens.dart:209`); the only Flutter transcription is private to `waiting_screen.dart`. Painting it is an app-shell change. Every screen shipped so far has the same gap. | app-shell / design-system |

Neither is fixable inside `otp_screen.dart`. Deferring rather than restyling
every screen from a single-screen story mid-wave was the correct call.

Attribution note for Scrum Master: STORY-032 and STORY-033 do not yet exist as
directories on `main` or on the integration branch, so I could not verify the
owner attribution from inside this worktree. This does not affect the
technical conclusion — the deltas are design-system-layer regardless — but the
owning story ids should be confirmed when those stories materialise.

`VISUAL_FIDELITY: FAIL` in the mobile-dev report is an honest verdict about
the composited screen, driven entirely by D1 and D2. Every delta inside this
story's own surface is fixed.

## Findings requiring action

None. No PATCH_REQUIRED item.

## Residual risks

1. D1 and D2 remain user-visible on the OTP screen until the shared-chrome
   owner ships. Low risk — the screen is preview-only and has no entry point.
2. The `resend-available` treatment is an extrapolation; if the design source
   later composes that state, it should be re-checked against it.
3. The cooldown does not tick. Correctly scoped out — ticking is flow
   behaviour owned by the `register -> otp -> permissions` navigation story.
4. `_markEmailUnreadIcon` hardcodes codepoint `0xf18a` against the bundled
   Material Symbols font. Documented as read from the font's cmap, and
   covered by a test. It will need revisiting only if that font asset is
   swapped.
5. Pre-existing guard red remains repo-wide until the queued bug is fixed;
   any future story touching those files will hit it.

## Verdict

Every acceptance criterion this story can close is met. The only unmet part of
AC1 is attributable to two confirmed shared-chrome deltas outside this story's
write scope, correctly deferred with named owners. This story's own scoped
gates are green and it introduces no regression.

Outcome: DEFERRED_ONLY
Merge eligible: YES
