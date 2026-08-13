# Review Report: STORY-008 Design Fidelity — Forgot Password

Reviewer: Iris-QC
Mode: compact-story-review
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-008 Design Fidelity — Forgot Password
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-008`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Reviewed commit: `625cb09`

Outcome: DEFERRED_ONLY

## Scope reviewed

Diff `8396273..HEAD` — 4 files, +551/-20:

- `mobile/lib/features/auth/presentation/screens/forgot_screen.dart` (rework)
- `mobile/test/features/auth/presentation/screens/forgot_screen_test.dart` (new)
- `data/.../STORY-008_forgot_password_design_fidelity/visual-fidelity/visual-fidelity-report.md` (new)
- `data/.../STORY-008_forgot_password_design_fidelity/story_master.md` (artifact checkbox)

No file outside the declared WriteScope was modified. Worktree is clean; the
change is sealed in one commit on the story branch.

## Design-source comparison

Source of truth: `cupid-app-design-system/project/Cupid Screens.dc.html`,
`<sc-if value="{{ isForgot }}">` block, lines 1513-1530. I re-read the block
directly and compared it element by element against the rendered widget tree,
rather than accepting the developer's own writeup.

| Design source element | Source spec | Implementation | Verdict |
| --- | --- | --- | --- |
| Screen frame | `padding:20px 20px 40px; gap:16px` | `_screenPadding = fromLTRB(20,20,20,40)`, uniform `CupidSpacing.md` (16) between top-level sections | MATCH |
| Hero badge | `72x72; radius 26; rgba(183,140,245,.2)`; glyph 36px in `--purple` | 72x72 `Container`, `circular(26)`, `colorAccentPurple @ 0.2`, `CupidIcon` size 36 in `colorAccentPurple` | MATCH except glyph identity (R1) |
| Title | Nunito / w900 / 25px / 1.25 | `type.display.copyWith(fontSize: 25, height: 1.25)`; `display` is Nunito w900 (verified in `cupid_typography_tokens.dart:31-35`) | MATCH |
| Lead paragraph | 13px / 1.6 / `--tx2`, margin-top 9 | `type.caption` (13px, verified line 46-50) `.copyWith(height: 1.6)` in `colorTextMuted`, `SizedBox(height: 9)`; both locale strings restored verbatim | MATCH |
| Field card | `--surf`; `--r-card`; `padding:13px 16px`; `--shadow` | `colorSurface`, `platform.radiusCard` (24 md / 26 ios), `symmetric(h:16, v:13)`, `platform.elevationShadow` (md = `rgba(80,30,110,.16) 0 6 18`, identical to the source's md `--shadow`) | MATCH |
| Field label | 11px / `.06em` / uppercase / `--tx2`, 6px gap | `type.caption.copyWith(fontSize: 11, letterSpacing: 11*0.06 = 0.66)` uppercased, `SizedBox(height: 6)` | MATCH |
| Input | borderless, transparent, `--fs-ui` 16px, `--tx` | `isCollapsed`, `InputBorder.none`, `contentPadding: zero`, `type.body.copyWith(fontSize: 16)` in `colorText` | MATCH |
| Primary CTA copy | "Gửi link đặt lại" / "Send reset link" | identical | MATCH |
| Primary CTA container | `height:54; --r-btn; --grad-hot; 16.5px/800; --glow` | `CupidPrimaryButton`: flat `colorAccentPink`, `platform.tapTarget` height (48 md / 44 ios), `type.body` label, no gradient, no glow | DEVIATION (R2) |
| Privacy note | `padding:15px 16px; --r-card; rgba(121,226,205,.12); border 1px rgba(121,226,205,.32)`; glyph 20px `--mint`; 12.5px/1.55 `--tx2` with `<strong>` in `--tx` | `colorMint @ 0.12`, `Border.all(colorMint @ 0.32)`, `platform.radiusCard`, `symmetric(h:16, v:15)`, icon 20 in `colorMint`, 11px gap, `Text.rich` at 12.5/1.55 with the emphasised span at w700 in `colorText`; both locale strings verbatim | MATCH except glyph identity (R1) |

Token equivalence table in the visual-fidelity report is accurate — I spot-checked
`radiusCard`, `elevationShadow`, `tapTarget` against
`mobile/lib/design_system/tokens/cupid_platform_tokens.dart:27-63` and the
`display`/`body`/`caption` roles against
`mobile/lib/design_system/tokens/cupid_typography_tokens.dart:31-50`. No invented
values; the raw numbers that have no token step (20/26/9/13/11/6/12.5/1.55/…) are
hoisted to named `const`s with a comment citing the design source, following the
existing `_materialPrimaryCtaRadius` precedent.

## Acceptance criteria

- AC 1 (layout / spacing / token / typography match exactly): MET IN SCOPE,
  two residual deviations deferred (R1, R2) — both live in
  `mobile/lib/design_system/**`, outside this story's WriteScope.
- AC 2 (deviations corrected in the app, not merely documented): MET. D1-D7 are
  real code changes in `forgot_screen.dart`, each covered by the diff and by
  assertions in the new test.
- AC 3 (form-field / response states): MET. Empty and filled match the source.
  The error and confirmation states are genuinely absent from the `isForgot`
  block (I confirmed this by reading lines 1513-1530 — the source CTA jumps
  straight to `login`), so retaining the app's existing lines re-styled to the
  block's own 12.5/1.55 supporting-text scale in `--red` / `--mint` is the
  correct call. Nothing visual was invented beyond the source's own scale.
- AC 4 (no new entry point): MET. `ForgotScreen`'s constructor, its route and
  the `LoginScreen` push site are untouched in the diff.

## Verification re-run by reviewer

Run in the story worktree with the repository's Flutter SDK:

1. `flutter analyze lib/features/auth/presentation/screens/forgot_screen.dart test/features/auth/presentation/screens/forgot_screen_test.dart`
   → `No issues found! (ran in 1.7s)`
2. `flutter test test/features/auth/presentation/screens/forgot_screen_test.dart test/design_system/no_fork_guard_test.dart`
   → `+5: All tests passed!` (4 forgot cases + the no-fork guard)

The no-fork guard passing independently confirms the screen carries no raw color
literal, no `Colors.` reference and no platform branch. The developer's
full-suite result (924 passed) and project-wide analyze (77 pre-existing infos,
none in this story's files) were not re-run; the scoped re-run above plus the
guard is sufficient for a compact gate on a single-screen change.

Test quality is adequate for a fidelity story: the assertions check the actual
rendered `TextStyle` family/weight/size/color and the actual `BoxDecoration`
tints rather than just widget presence, so a regression on D2/D4/D1/D6 would
fail the test rather than pass silently.

## Deferred deviations (do not block this story, must not be dropped)

### R1 — Icon glyphs are substitutes

- Design source uses `lock_reset` (hero badge, line 1515) and `shield_moon`
  (privacy note, line 1526). Both slots currently render `CupidIcons.lock`
  (`forgot_screen.dart:120` and `forgot_screen.dart:231`).
- Confirmed real: `mobile/lib/design_system/icons/cupid_icons.dart` exposes
  neither `lockReset` nor `shieldMoon`, and its own contract requires codepoints
  verified against the bundled `MaterialSymbolsRounded-Variable.ttf` cmap.
  That file is outside this story's WriteScope, so the developer could not have
  fixed it without breaking the declared scope boundary.
- Required follow-up: add `lockReset` and `shieldMoon` with cmap-verified
  codepoints to `mobile/lib/design_system/icons/cupid_icons.dart`, then swap the
  two call sites above.

### R2 — Primary CTA container styling (shared component, recurring this wave)

- Design source (line 1524): `height:54px; border-radius:var(--r-btn);`
  `background:var(--grad-hot); color:#fff; font-size:16.5px; font-weight:800;`
  `box-shadow:var(--glow)`.
- Confirmed real in `mobile/lib/design_system/adaptive/cupid_primary_button.dart:42-56`:
  a `SizedBox` at `platformTokens.tapTarget` (48 material / 44 iOS, verified in
  `cupid_platform_tokens.dart:34,55`) wrapping an `ElevatedButton` with a flat
  `colors.colorAccentPink` fill, a 20dp material radius, and a `type.body`
  (17px / w400) label. No gradient fill, no glow shadow.
- Accepting the deferral is the correct engineering call here: forking a
  screen-local gradient CTA inside `forgot_screen.dart` would violate
  `architecture/solution.md` D3 / ADR-004 (feature code consumes the design
  system's adaptive widgets, never a per-screen fork), would be caught by the
  no-fork guard test, and would leave `forgot` inconsistent with `login`,
  `register` and `otp`.
- Required follow-up: one design-system story fixing `CupidPrimaryButton`
  (54px height, `gradientHot` fill, `glowShadow`, 16.5px/w800 label) once for
  every screen with a primary CTA. This is the same gap flagged on sibling
  auth-screen stories in this wave — it should be raised to a single tracked
  REQ-002 follow-up story rather than re-deferred per screen indefinitely.

## Residual risks

- Rendered-pixel verification was done by reading the design-source CSS against
  the widget tree and by token-level assertions in the widget test, not by a
  golden/screenshot diff. A purely optical difference that survives identical
  token values (e.g. font metric differences between the HTML preview and
  Nunito as bundled) would not be caught by this gate.
- Only dark theme + `vi` was audited, per the story's Out of Scope and OQ5.
  Light theme and `en` remain unverified visually; the tokens used are
  theme-aware, so this is a QA-coverage risk, not a known defect.
- Until R2 lands, every REQ-002 Scope B auth screen will keep shipping a CTA
  that visibly differs from the design source. The count of screens carrying
  this deferral is growing across the wave.

## Decision

DEFERRED_ONLY. Everything inside this story's declared WriteScope matches the
locked design source and is verified by re-run analyze and tests. The two
remaining deviations are real and user-visible but are owned by shared
`design_system/**` files this story was explicitly not allowed to modify;
neither is a defect introduced by this change, and neither can be fixed here
without violating the architecture's no-fork rule. Story may be marked DONE
provided R1 and R2 are carried forward as tracked follow-up work.
