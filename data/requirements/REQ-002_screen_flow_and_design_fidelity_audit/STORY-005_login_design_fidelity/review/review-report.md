# Review Report: STORY-005 Design Fidelity — Login (Round 3, rendered-evidence gate)

Reviewer: Iris-QC
Mode: compact-story-review (mobile lane, UI-bearing, design source configured)
Scope: REQ-002 / STORY-005_login_design_fidelity
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-005`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-005`
Diff baseline: `273d91340e32d87b1d78e6c1db43fb215a0271c0`
Design source: `cupid-app-design-system` (locked). Design screen resolved:
`cupid-app-design-system/project/Cupid Screens.dc.html`, `<sc-if value="{{ isLogin }}">`
block, lines 1425-1458.

Outcome: PATCH_REQUIRED

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
