# Review Report: STORY-005 Design Fidelity — Login

Reviewer: Iris-QC
Mode: compact-story-review (mobile lane, UI-bearing, design source configured)
Scope: REQ-002 / STORY-005_login_design_fidelity
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-005`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-005`
Design source: `cupid-app-design-system` (locked). Design screen resolved:
`cupid-app-design-system/project/Cupid Screens.dc.html`, `<sc-if value="{{ isLogin }}">`
block, lines 1425-1458.

Latest round: 4 (patch re-review, 2026-08-16)
Diff baseline for round 4: `db1382daebad31b04c7bd620dc248a957071a392`

Outcome: DEFERRED_ONLY

---

# Round 4 — Patch Re-Review (authoritative)

Re-review of this reviewer's own round-3 blocking findings BF-01..BF-06 against
the 3-commit delta since `db1382d`: `1ca0320` (mobile-dev code patch),
`51f60db` (devops re-capture + field states), `987fe52` (re-verified
`visual-fidelity-report.md`, `VISUAL_FIDELITY: PASS`).

## Rationale

I re-opened all four post-patch PNGs and the design reference myself rather
than reading the `PASS` token, and I re-ran the build gate in the story
worktree rather than trusting the transcribed results.

The empty capture now shows, directly and unmistakably: an eye-with-slash
glyph at the password card's right edge, a four-colour Google "G" and a blue
Facebook roundel before their labels, and two field cards that are visibly the
same proportion as the reference's. Those are the three deltas I could see in
round 3; they are gone. The biometric row is still absent — expected, and now a
recorded scope cut, not a finding.

The re-measurement is credible because it does not claim a tolerance, it claims
identity: 167 px in the capture against 167 px in the reference, in all four
states. The report also volunteers its own measurement hazard (a centre-column
scan is broken by typed glyphs on the filled/error frames, so a text-free column
at x 850 was used). Evidence that names the way it could have fooled itself is
evidence I can rely on.

BF-04's Facebook caveat holds up, and I checked it two ways rather than
accepting the argument. `Cupid Screens.dc.html:1454` authors the mark as an
**icon-font ligature** (`<span data-icon style="font-size:18px;color:#1877F2">facebook</span>`),
not as inline SVG — and an unresolvable ligature is exactly the thing headless
Chromium font-falls-back. Opening `design-reference-login-android.png`
confirms it: that button renders a blue emoji-style face plus a blue rectangle,
which is fallback output, not a Facebook logo. So the reference PNG is genuinely
not pixel-truth for this one mark, and the authored source plus the
`0xFF1877F2` assertion is the right comparison basis. The reasoning is sound and
the caveat is correctly flagged for future readers.

I also spot-checked the Google mark against the authored SVG rather than the
render: `_googleLayers` in `cupid_icons.dart` transcribes
`Cupid Screens.dc.html:1449` verbatim — `M45.1 24.5c0-1.6-.1-3.2-.4-4.7H24v8.9h11.8…`
maps exactly onto `moveTo(45.1, 24.5) / cubicTo(45.1, 22.9, 45, 21.3, 44.7, 19.8) /
lineTo(24, 19.8) / lineTo(24, 28.7) / lineTo(35.8, 28.7)…`, with the authored
19 px / 8 px and 18 px / 7 px mark-and-gap metrics carried across as
`_googleMarkSize`/`_googleMarkGap` and `_facebookMarkSize`/`_facebookMarkGap`.

On BF-05 I applied the same rule as round 3 — open the captures, do not accept
a token — and the four frames do carry real, distinguishable states: the filled
frame shows `minh@gmail.com` typed, ten password bullets, a live pink caret and
a fully rendered Gboard; the error frame shows "Email hoặc mật khẩu không đúng"
in `--red` below the field group with the layout reflowed and both cards' chrome
untouched. The AC 3 conclusion is the right one for this design source: it
authors no `:focus` and no error styling, so fidelity means adding no
unauthored treatment, and the app adds none.

One weakness in that evidence, which I resolved rather than waved through. The
`login-android-focused.png` frame carries no caret and no full keyboard, so on
its own it cannot prove the EMAIL field was focused; and
`test-results.md`'s explanation for that ("the soft keyboard did not render in
`screencap` output — a known emulator/adb limitation") is simply wrong, because
the filled frame in the same set has a fully rendered keyboard. What actually
carries the point is that the focused frame does show a partial IME surface
absent from the empty frame, the tap was logged at `540,527` inside the
`uiautomator`-resolved EMAIL bounds `[95,503][985,551]`, and — decisively — the
**filled** frame is itself an unambiguous focused frame (visible caret, keyboard
up) and shows the card chrome unchanged. So the AC 3 claim stands on evidence I
can see; only the stated explanation is wrong. Recorded below as a non-blocking
documentation defect (ND-01), not a re-open.

BF-01 was not re-litigated. Per the handoff and `story_master.md`
`## Out of Scope`, it is an accepted user scope cut of 2026-08-15; I confirmed
only that the exclusion is documented accurately, which it is.

## Round 3 Findings — Disposition

| Id | Round-3 finding | Disposition | Evidence I verified |
|---|---|---|---|
| BF-01 | Biometric quick-unlock row absent | **Accepted scope cut — not re-opened** | `story_master.md` `## Out of Scope` records the 2026-08-15 user decision, the three options offered, the choice (defer + new story), and states it does not block AC 1/AC 2. `visual-fidelity-report.md` carries VF-01 as `EXCLUDED — deferred by scope cut`, still-absent confirmed, not silently dropped. Documented accurately |
| BF-02 | Password `visibility_off` toggle absent | **CLOSED** | `_PasswordVisibilityToggle` renders in `_FieldCard`'s new `trailing` slot; glyph visible at the password card's right edge in all four captures. `CupidIcons.visibilityOff` (0xe8f5) / `visibility` (0xe8f4) added. Design source line 1441 authors exactly 21 px / `--tx2` / line variant — matched. Widget test taps it and asserts `obscureText` flips and the glyph swaps, so it is functional, not decorative |
| BF-03 | Field cards +8.4 dp (72.0 vs 63.6) | **CLOSED** | `SizedBox(height: _fieldCardHeight /* 63.6 */)` plus explicit `TextStyle.height` on both label and input, `isCollapsed: true` added. Re-measured 167 px in the capture against the reference's own 167 px — identity, not tolerance — in all four states. Widget test asserts 63.6 ±0.01 over both cards, so it now fails the suite rather than needing another capture |
| BF-04 | Google/Facebook brand marks absent | **CLOSED** | `CupidBrandMarkIcon` paints transcribed vector paths; both marks visible in the capture. Google path data verified verbatim against `Cupid Screens.dc.html:1449`. Facebook caveat independently verified (see Rationale) — reference PNG is font-fallback output, authored source is the correct basis. `no_fork_guard_test.dart` guards only `lib/features`, `lib/app`, `lib/core`; the brand literals sit in `lib/design_system/icons/`, which the guard permits by design, and `login_screen.dart` introduces no literal. Guard passes in my own run |
| BF-05 | AC 3 had no runtime evidence | **CLOSED** | Four distinct on-device frames, opened and inspected. Filled and error frames are unambiguous. Focused-state proof is corroborated as described in the Rationale; ND-01 records the one wrong explanation |
| BF-06 | Missing `## Entry Point Reachability` heading | **CLOSED** | The heading now exists in `coding-plan/test-results.md` with the static wiring (`welcome_screen.dart:317-333`), the runtime `uiautomator` node bounds, the tap, and the confirming second dump. Correctly labelled as a heading fix, not a re-verification |

## Critical Gates (re-run by me in the story worktree)

| Gate | Required | Status |
|---|---|---|
| Mobile static analysis | Yes | PASS — `flutter analyze` on `login_screen.dart`, `cupid_icons.dart`, `login_screen_test.dart` → `No issues found! (ran in 2.3s)` |
| Mobile unit/widget tests | Yes | PASS — `flutter test test/features/auth test/design_system` → `+156: All tests passed!`, zero skipped. Count moved 151 → 156, matching exactly the five added tests. Targeted `--plain-name "measure the design-source"` run confirms the card-height test executes and passes rather than being counted-but-skipped |
| Rendered visual fidelity (12e2/12e3) | Yes | PASS — `VISUAL_FIDELITY: PASS`; four post-patch captures opened and corroborated against the design reference and the authored source |
| Entry-point reachability (12e1) | Yes | PASS — evidence heading now present; reachability itself was already verified real in round 3 |
| Story runtime startup smoke (12g) | Yes | PASS — rebuild, reinstall, `ResumedActivity` confirmed on `emulator-5560`, clean `force-stop`. iOS `IOS_NO_SIMULATOR` under accepted Android-only scope |
| Configuration guide | No | Not applicable — no setup/configuration surface touched |

## Blocking Findings

None. All of BF-02..BF-06 are closed on evidence I verified directly, and BF-01
is an accepted scope cut.

## Non-Blocking / Deferred

- **ND-01 — wrong explanation in AC 3 evidence.** `coding-plan/test-results.md`
  `### Field states` claims the soft keyboard "did not render in the emulator's
  `screencap` output — a known emulator/adb `screencap` limitation". That is
  contradicted by `login-android-filled.png` in the same capture set, which
  renders a full Gboard. The AC 3 conclusion is unaffected and independently
  corroborated, but the sentence should be corrected so a later reader does not
  inherit a false constraint about `screencap`. Documentation only.
- **RR-01 — fixed card height vs system text scaling (new, introduced by this
  patch).** `_FieldCard` is now pinned to `SizedBox(height: 63.6)` while the
  label and input line boxes are multipliers of fixed font sizes. No
  `TextScaler`/`textScaler` clamp exists anywhere in `mobile/lib`, so at an
  enlarged system font scale the column's content exceeds the pinned box (at
  1.3x it computes to roughly 73 dp against the 63.6 dp constraint) and would
  overflow, where the previous content-sized card grew instead. Not blocking:
  this story's ACs are rendered fidelity at the audited default scale, no
  accessibility/dynamic-type AC is in scope, and no capture or test in this
  story exercises a scaled text environment — so this is a reasoned risk, not an
  observed failure. Worth a deferred follow-up item at requirement level, since
  the same pinning pattern will spread to the other field-bearing screens.
- **Stale sibling artifacts.** `visual-fidelity/implemented-login-android.png`
  and `side-by-side-login-android.png` are pre-patch. The report flags this
  explicitly under `## Artifacts` ("Note on staleness"), which is enough; noted
  so nobody re-derives a delta from them.
- **Stale line in `story_master.md`.** The `Patch round 3` bullet still reads
  "**BF-05** … is still open", written before `51f60db`/`987fe52` closed it.
  Scrum Master should reconcile that line when moving the checkboxes.
- **iOS deferral** — typed blocker `IOS_NO_SIMULATOR`, unchanged and still
  accepted under the user's Android-only decision. AC 4's iOS half remains
  widget-test-only. A later iOS pass should re-run the same comparison with
  `data-plat="ios"` and should also settle the Apple button's 16 px glyph
  (`Cupid Screens.dc.html:1451`), which is iOS-only and was never in this
  story's Android scope.
- **VF-05** (2.3 dp social-button height, border-box vs content-box reading) and
  **VF-06** (20 dp Material CTA radius, AC 4-mandated) — unchanged accepted
  non-defects, no action.

## Traceability

- AC 1 — PASS within the story's declared scope. Every measured property matches;
  the only authored element still missing is the biometric row, excluded by the
  2026-08-15 user decision. Flagged as scope-conditional rather than unqualified,
  because the AC text says "no visible deviation" and one authored element is
  still not rendered.
- AC 2 — PASS. VF-02, VF-03 and VF-04 are corrected in the rendered app
  (`1ca0320`) and confirmed in the render (`51f60db`), not merely documented.
- AC 3 — PASS. Four states captured at runtime; card geometry 63.62 dp in every
  state; no unauthored focus or error treatment introduced, matching a design
  source that authors none.
- AC 4 — PARTIAL. Android verified at runtime; iOS deferred under
  `IOS_NO_SIMULATOR`.
- AC 5 — PASS. No entry point added or changed; the WelcomeScreen → "Dùng email"
  → LoginScreen path is now recorded under its own heading.

## Why DEFERRED_ONLY And Not CLEAN

No blocking finding remains, so this is not `PATCH_REQUIRED`. It is not `CLEAN`
either, because two ACs do not close unconditionally: AC 1 passes only by virtue
of an explicit scope cut that leaves a design-authored element unrendered, and
AC 4 stays PARTIAL with the iOS half unverified at runtime. Both are recorded,
user-accepted deferrals rather than unresolved defects — which is exactly the
`DEFERRED_ONLY` case.

## State Recommendation

- Check `Implementation (Development)` in `story_master.md`
- Check `Patch round 3 (Mobile Developer)`, and correct its stale "BF-05 is still
  open" sentence
- Check `Review (Reviewer)` — round 4 `Outcome: DEFERRED_ONLY`
- Story eligible for `DONE` and for merge into
  `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
- Route to requirement-level deferred follow-up: the biometric login story (not
  yet created), the iOS visual pass, RR-01, and the ND-01 documentation fix

REVIEW_COMPLETE: YES

---

# Round 3 — Rendered-Evidence Gate (superseded by Round 4)

Diff baseline: `273d91340e32d87b1d78e6c1db43fb215a0271c0`

Outcome (round 3, superseded): PATCH_REQUIRED

## Review History And Supersession

- Round 1 verdict: PATCH_REQUIRED (PATCH-01, PATCH-02 — touch targets).
- Round 2 verdict: CLEAN. That pass was a code/diff review plus PATCH-03
  documentation confirmation. It explicitly did **not** assess rendered pixel
  evidence; no runtime capture existed at that time.
- Round 3 (this pass) is the first review with rendered Android evidence and is
  the authoritative verdict for this story. The Round 2 CLEAN is superseded, not
  contradicted: its code-level conclusions (PATCH-01/PATCH-02 resolved) still
  hold and were not re-litigated here.

## Scope Gate

Scope gate file: `review/scope-gate.md` (`SCOPE_GATE_COMPLETE: YES`). The handoff
asked for an inline gate only, but `validate-reviewer-two-phase.sh` requires the
separate file; both carry the same scope.

Review type: `compact-story-review`, rendered visual-fidelity gate (skill 12e2/12e3).
Report path: this file.

Source files in scope (4):
- `mobile/lib/features/auth/presentation/screens/login_screen.dart` (ranges 280-314)
- `mobile/lib/design_system/adaptive/cupid_primary_button.dart` (ranges 12-61)
- `mobile/lib/features/auth/presentation/screens/welcome_screen.dart` (range 305-334, entry point)

Evidence files in scope:
- `visual-fidelity/visual-fidelity-report.md` (ranged reads: verdict, measured
  comparison, findings, AC table, iOS deferral, verification)
- `visual-fidelity/implemented-login-android.png` (opened and inspected)
- `visual-fidelity/design-reference-login-android.png` (opened and inspected)
- `visual-fidelity/side-by-side-login-android.png` (opened and inspected)
- `coding-plan/test-results.md` (full, 58 lines)
- `story_master.md`, `scrum-master-checkpoint.md`
- prior `review/review-report.md` (lines 1-70)

Query keys: VF-01..VF-06, DEF-04, AC1..AC5, `isDense`, `contentPadding`,
`_primaryCtaHeight`, `gradientHot`, `glowShadow`, `onUseEmail`.

Risk surfaces touched: mobile interaction (UI-only login screen). No
persistence, auth-contract, payment, migration, or runtime-config surface is
touched by this story's changes.

## Rationale

I opened both rendered images myself rather than accepting the verdict token.
The implemented capture is a genuine Android runtime frame of **this story's
screen** (status bar, DEBUG banner, gesture pill; heading "Mừng bạn quay lại",
EMAIL/MẬT KHẨU cards, "Quên mật khẩu?", "Đăng nhập", "hoặc", Google/Facebook,
"Chưa có tài khoản? Đăng ký") — not a placeholder, error frame, or wrong screen.
The reference depicts the same login screen at identical 1080x2400 metrics, so
the comparison is real and the `FAIL` verdict is corroborated, not asserted.

Four deltas are visible to me directly in the images, independent of the
report's measurements: the biometric row and the password eye toggle are present
in the reference and absent in the build; the social buttons carry brand marks in
the reference and are text-only in the build; and the two field cards are
plainly taller in the build than in the reference (measured ~13% overshoot,
consistent with the report's 72.0 dp vs 63.6 dp).

AC 1 states layout, spacing, colour/token usage and typography must match "with
no visible deviation". Three authored elements are missing and one geometry is
wrong, so AC 1 and AC 2 fail on the exact AC text (skill rule 14 — no
"spirit of the AC" pass). AC 3 has no runtime evidence at all: only the empty
state was captured. Mobile-dev still has the emulator and can force focused,
filled and error states, so this is a supplyable missing critical gate
(`PATCH_REQUIRED`), not a `BLOCKED` and not a `DEFERRED_ONLY` — it is the
primary proof of AC 3 (skill rule 12c).

Verified claims that hold up:
- VF-03 root cause is real: `login_screen.dart:287-291` and `:304-308` both pass
  `InputDecoration(border: none, isDense: true, contentPadding: EdgeInsets.zero)`.
  The authored constants are correct; the extra height is `TextField` /
  `InputDecorator` intrinsic metrics surviving those flags. The fix belongs in
  the field's height constraint, not in the spacing constants.
- DEF-04 is genuinely resolved: `cupid_primary_button.dart:20` `_primaryCtaHeight = 54`,
  `:53` `gradient: colors.gradientHot`, `:55` `boxShadow: colors.glowShadow`.
  Treated as struck, correctly.
- VF-06 is not a defect: `_materialPrimaryCtaRadius = 20` at
  `cupid_primary_button.dart:14`, applied only on Material with `radiusButton`
  reserved for iOS (`:44-46`) — exactly what AC 4 requires.
- VF-05 (49.9 vs 52.2 dp) is a content-box vs border-box measurement artifact,
  correctly accepted rather than silently dropped.

## Blocking Findings

| Id | Finding | Evidence | Owner |
|---|---|---|---|
| BF-01 | Biometric quick-unlock row absent from the build (design authors a 52 dp `--surf` pill with `fingerprint` glyph + "Đăng nhập bằng vân tay" between CTA and divider). Visible in reference, absent in capture. | VF-01, design line 1446, both PNGs | mobile-dev |
| BF-02 | Password `visibility_off` toggle absent. Reference password card carries a right-aligned 21 px `--tx2` glyph; build card has no trailing ink. | VF-02, design line 1441, both PNGs | mobile-dev |
| BF-03 | Both field cards render 72.0 dp vs design 63.6 dp (+8.4 dp, repeated twice). Root cause confirmed at `login_screen.dart:287-291` and `:304-308`. | VF-03, measured comparison | mobile-dev |
| BF-04 | Google/Facebook social buttons render text-only; design draws a 19 px Google mark and an 18 px `#1877F2` Facebook mark before each label. | VF-04, design lines 1449/1454, both PNGs | mobile-dev |
| BF-05 | AC 3 has no runtime evidence. Only the empty field state was captured; focused, filled and error states were never rendered. Static reading is not evidence for a rendered-fidelity AC. | `visual-fidelity-report.md` AC table | mobile-dev |
| BF-06 | `coding-plan/test-results.md` has no `## Entry Point Reachability` section. I verified reachability independently and it is REAL — `welcome_screen.dart:317-333` wires the "Dùng email" `OutlinedButton` to `onUseEmail` (`_openLogin` -> `OnboardingNode.login`), and the smoke run tapped it and confirmed LoginScreen nodes via `uiautomator dump`. This is a missing evidence heading only, not a missing entry point; fold it into the same patch round. | test-results.md lines 27-37 | mobile-dev |

BF-01, BF-02 and BF-04 need work outside `login_screen.dart` (biometric
capability + a `CupidIcons` codepoint, that codepoint alone, and an asset/SVG
pipeline). If Scrum Master judges any of them to exceed this story's scope, the
correct move is an explicit scope decision recorded in `story_master.md` — not a
silent pass, because AC 1 and AC 2 name them.

## Accepted / Non-Blocking

- **iOS deferral** — typed blocker `IOS_NO_SIMULATOR`, no simulator runtime
  installed, under the user's explicit "Android-only, defer iOS" decision.
  Treated as documented Android-only scope, **not** a missing-evidence failure
  and **not** a blocker. The iOS half of AC 4 stays unverified at runtime with
  widget-test coverage only; any later iOS pass re-runs the same comparison with
  `data-plat="ios"`.
- **VF-05** — 2.3 dp social-button height delta is a border-box vs content-box
  reading. Implementation reading is the sane one. Accepted, no action.
- **VF-06** — Material 20 dp CTA radius is AC 4-mandated platform adaptation,
  not drift. Accepted, no action.

## Critical Gates

| Gate | Required | Status |
|---|---|---|
| Mobile static analysis | Yes | PASS — `flutter analyze login_screen.dart cupid_primary_button.dart` → `No issues found!` |
| Mobile unit/widget tests | Yes | PASS — `flutter test test/features/auth test/design_system` → `+151`; full `flutter test` → `+1242 ~2` (2 skipped) |
| Rendered visual fidelity (12e2/12e3) | Yes — mobile lane, UI-bearing, design source locked | **FAIL** — `VISUAL_FIDELITY: FAIL`, images present and inspected, verdict corroborated |
| Entry-point reachability (12e1) | Yes | Reachable in code and at runtime; evidence heading missing (BF-06) |
| Story runtime startup smoke (12g) | Yes — mobile lane | PASS (Android, `emulator-5560`, `ResumedActivity` confirmed, shutdown clean). iOS `IOS_NO_SIMULATOR` under accepted Android-only scope |
| Configuration guide | No | Not applicable — no setup/configuration surface touched |

Note: the mobile analyze/test evidence lives in `visual-fidelity-report.md`
(`## Verification For This Audit Run`), not in `coding-plan/test-results.md`,
which carries only the DevOps runtime-smoke section. Worth consolidating, but not
a finding.

## Traceability

- AC 1 — FAIL (BF-01..BF-04)
- AC 2 — FAIL (VF-01/02/04 documented-only; VF-03 newly surfaced, uncorrected)
- AC 3 — NOT VERIFIED (BF-05)
- AC 4 — PARTIAL: Android verified (54.1 dp, `--grad-hot`, `--glow`, 20 dp Material
  radius); iOS deferred under accepted scope
- AC 5 — PASS: no entry point added or changed; existing WelcomeScreen → "Dùng
  email" → LoginScreen path confirmed in code and at runtime
- OQ discipline — OQ5 (light theme / `en` locale) correctly triaged as
  out-of-scope in `story_master.md` and not over-applied: the audit covered the
  dark + `vi` combination that is actually user-facing. No blocked scope was
  implemented and no unblocked AC was skipped on OQ grounds.

## State Recommendation

- Uncheck `Implementation (Development)` in `story_master.md`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Route BF-01..BF-06 back to the mobile lane (Mobile Developer)
