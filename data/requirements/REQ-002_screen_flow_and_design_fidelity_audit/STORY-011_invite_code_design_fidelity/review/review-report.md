# Review Report: STORY-011 Design Fidelity — Invite / Create Pairing Code

Outcome: DEFERRED_ONLY

Reviewer: Iris-QC
Review tier: compact story review (UI lane, design fidelity)
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-011_invite_code_design_fidelity
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-011`
Diff baseline: `8396273e6a5e6a2798557aa68864f0ef24cd939b` → `abcb85b`
Worktree:
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-011`

## Scope Of Diff

Four files, all inside story scope:

| File | Change |
|---|---|
| `mobile/lib/features/pairing/presentation/screens/invite_screen.dart` | +249 / -50 |
| `mobile/test/features/pairing/presentation/invite_screen_test.dart` | +82 / -41 |
| `.../STORY-011_invite_code_design_fidelity/visual-fidelity/visual-fidelity-report.md` | new |
| `.../STORY-011_invite_code_design_fidelity/story_master.md` | Implementation checkbox only |

No out-of-scope file touched. `design_system/`, routing, and pairing business
logic are unmodified.

## Design Source Verification

Each deviation D1-D11 was re-checked by the reviewer against the raw markup,
not accepted from the implementer's table.

Source of truth read directly:
`cupid-app-design-system/project/Cupid Screens.dc.html`

- Lines 168-178 (`<sc-if value="{{ isInvite }}">` card block): confirms
  screen padding `18px 20px 40px` (D10), card `background:var(--surf)` /
  `border-radius:var(--r-card)` / `padding:22px 20px` / `box-shadow:var(--shadow)`
  (D1), label `font-size:12.5px;color:var(--tx2)` (D2), code
  `'Roboto Mono' / 500 / 36px / letter-spacing:.16em` (D3) with
  `linear-gradient(95deg,var(--pink),var(--purple))` background-clip (D4) and
  `margin:10px 0 4px` (D5), caption `font-size:11.5px;color:var(--tx2)` (D6),
  action row `display:flex;gap:9px;margin-top:18px` (D7), share pill
  `flex:1;height:48px;var(--r-btn);var(--grad-hot);gap:8px;15px/700;var(--glow)`
  with `ios_share` at 19px (D8), and the icon-only copy control
  `48x48;var(--r-btn);border:1.5px solid var(--line)` with `content_copy` at
  19px in `var(--tx2)` (D9).
- Lines 1764 / 1776 (`VI`/`EN` maps): `t_invite` = `'Ghép đôi'` / `'Pair up'`,
  confirming D11's header title correction.
- Lines 179-201 (couple-type picker and "Continue → Fingerprint Vow"):
  correctly excluded — separate product scope per `uiux-spec.md` §1, not a
  fidelity gap.

Every claimed metric matches the source markup. Token mapping is sound:
`CupidSpacing.xs == 4` and `CupidSpacing.sm == 8` verified in
`mobile/lib/design_system/tokens/cupid_spacing.dart`, so the 4px code margin
and the 8px share icon-to-label gap are token-exact rather than literal.

Icon codepoints independently verified against the bundled font's cmap rather
than trusted from the report: `0xe6b8 -> ios_share` and `0xe14d -> content_copy`
in `mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf`. Both use
`CupidIcons.fontFamily`, so ADR-004d (single icon family) holds.

## Verification Reproduced

Both gates were re-run by the reviewer in the story worktree, not read from the
implementer's report.

- `flutter test test/features/pairing test/design_system/no_fork_guard_test.dart`
  → `00:12 +71: All tests passed!` — matches the reported 71.
- `flutter analyze lib/features/pairing/presentation/screens/invite_screen.dart test/features/pairing/presentation/invite_screen_test.dart`
  → 3 issues, all `prefer_initializing_formals` infos at
  `invite_screen.dart:73:8`, `:74:8`, `:94:7`. Those lines sit in the
  untouched cubit-factory constructors — no diff hunk covers them — so they
  are confirmed pre-existing. Zero errors, zero warnings, nothing new.

## Test File Location Question (raised in handoff)

Confirmed legitimate, not a stray edit. `git ls-tree` at the diff baseline
shows `mobile/test/features/pairing/presentation/invite_screen_test.dart`
already existed there, alongside all seven sibling pairing tests
(`joincode_screen_test.dart`, `paired_screen_test.dart`,
`waiting_screen_test.dart`, and the cubit tests). No
`mobile/test/features/pairing/presentation/screens/` directory exists in the
tree. The declared write scope named a path that has never existed; the
implementer edited the real, conventional location.

The edit itself is forced by the design change: making the copy action
icon-only (D9) removes the `Copy code` text node, so the two existing taps had
to move from `find.text('Copy code')` to `find.byTooltip('Copy code')`. That is
the minimum correct adaptation and it preserves the assertions' intent. The
reformatting churn in the third hunk is `dart format` output, not logic change.

## Acceptance Criteria

| AC | Verdict | Basis |
|---|---|---|
| 1 — layout/spacing/color-token/typography match in dark + `vi` | MET | D1-D11 each re-verified against source lines 168-178; token mapping checked against `cupid_spacing.dart` and `CupidColorTokens` |
| 2 — deviations corrected in the app, not merely documented | MET | All eleven landed in `invite_screen.dart`; the new `the code card matches the design source treatment` test asserts card surface/radius/shadow, the `ShaderMask`, the Roboto Mono 36/w500/.16em style, and the 48x48 icon-only copy control |
| 3 — code display/share component matches, incl. mono treatment | MET | D3/D4/D8/D9 verified against source lines 172, 175, 176 |
| 4 — no new entry point required | MET | Navigation, `_share`/`_copy` payloads, `SemanticsService` announcements, and the `waiting` advance are unchanged in the diff |

## Deferred Findings

### DF-1 — Share CTA Vietnamese label diverges from the design source

- Where: `mobile/lib/features/pairing/presentation/screens/invite_screen.dart:339`
- Current: `context.viEn('Chia sẻ mã mời', 'Share invite')`
- Design source (line 175): `<span data-vi>Gửi link mời</span><span data-en>Share invite</span>`

The English label matches the source exactly; the Vietnamese one does not, and
`vi` is the audited locale. The visual-fidelity report neither fixes this nor
lists it under Deliberate Non-Changes, so it is an unrecorded divergence — and
the same story did correct header-title copy (D11) from the same source, so
copy was treated as in scope elsewhere.

Deferred rather than blocking because it is content, not one of the four
attributes AC1 enumerates (layout, spacing, color/token, typography), and
because there is a real product tension behind it: no `share_plus` dependency
exists in this phase, so the button performs a clipboard copy. The clipboard
payload does include `https://cupid.app/pair?code=...`, which makes the
source's "Gửi link mời" defensible — but swapping user-facing copy is a Product
Owner call, not a reviewer-mandated string edit.

Route to: Product Owner, to either align the `vi` label to the source or record
it as an accepted copy correction alongside the existing STORY-005 §3
code-format/expiry corrections.

### DF-2 — Icon constants not promoted to `CupidIcons`

- Where: `invite_screen.dart` private `_iosShareIcon` / `_contentCopyIcon`

`mobile/lib/design_system/icons/cupid_icons.dart` documents the convention that
glyphs become named `CupidIcons` members as widgets consume them. This story
could not follow it because `design_system/` is outside its write scope. The
implementer already flagged this as a follow-up; the reviewer confirms the
constraint was real and the workaround is correct (same font family, verified
codepoints, no second icon package).

Route to: a later story whose write scope includes
`mobile/lib/design_system/`.

## Residual Risks

- No pixel-level rendered screenshot diff was produced. Fidelity was verified
  as design-source-markup versus code, plus widget-tree assertions in the
  Flutter test harness. Sub-pixel rendering differences between the CSS mockup
  and Flutter's layout engine would not be caught by this method — including
  the implementer's own known approximation 4 (CSS `letter-spacing` adds
  trailing space after the last character, nudging code centering by ~2.9px).
- Share CTA foreground uses `colorText` (`#F7EEFB` in dark) where the source
  specifies `#fff`. No pure-white token exists; this matches the existing
  `CupidPrimaryButton` precedent, so it is consistent rather than novel.
- The card renders two 11.5px caption lines ("Mã 6 ký tự" + live countdown)
  where the source has one. Both are documented carry-forwards of STORY-005 §3
  corrections driven by the frozen backend contract (6-char code, 24h TTL);
  reverting them would regress accepted behaviour.
- Light theme and `en` locale received no dedicated visual pass, per the
  story's Out of Scope and OQ5. Fixes are token-based, so they should hold, but
  this is unverified by design.

## Conclusion

All four acceptance criteria are met, both quality gates reproduce
independently, and the diff stays inside story scope with no collateral change
to the design system, routing, or pairing logic. Two findings are recorded as
deferred; neither blocks an acceptance criterion.

Outcome: DEFERRED_ONLY
