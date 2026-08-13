# Review Report — STORY-012 Join / Enter Pairing Code Design Fidelity

Reviewer: Iris-QC
Mode: compact-story-review
Scope: REQ-002 / STORY-012_join_code_design_fidelity
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-012`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Implementation commit: `f284985dad5a3028f0460e2ae2d48c01c88a9096`
Design source (locked): `cupid-app-design-system/project/Cupid Screens.dc.html`,
`<sc-if value="{{ isJoinCode }}">`, lines 1550-1570

Outcome: PATCH_REQUIRED

## Reviewed surface

- `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart` (+102/-8)
- `mobile/test/features/pairing/presentation/screens/joincode_screen_design_test.dart` (new, 4 tests)
- `data/requirements/.../STORY-012_join_code_design_fidelity/visual-fidelity/visual-fidelity-report.md` (new)
- `data/requirements/.../STORY-012_join_code_design_fidelity/story_master.md` (artifact checkbox)

## Independently verified and confirmed

Mobile Dev's claims were re-checked against the design source and the token
layer rather than accepted from the report.

| Claim | Verification |
| --- | --- |
| Token mapping table | Exact. `--bg` #171129, `--surf` #241B42, `--line` rgba(247,238,251,.11), `--tx2` #B4A6CE, `--pink` #FF7FB6, `--red` #FF6F91 all match `CupidColorTokens.dark()` (`cupid_color_tokens.dart:41-57`) |
| `radiusSmall` = design 16px | Confirmed, `cupid_platform_tokens.dart:31,50` (16 on both platforms) |
| Heading role | Design line 1553 `Nunito;900;25px;line-height:1.25` vs `display` (Nunito/w900) + `copyWith(fontSize: 25, height: 1.25)` — matches |
| Sub-copy role | Design line 1554 `13px;line-height:1.6;--tx2;max-width:280px` vs `caption` (fontSize 13) + `height: 1.6` + `ConstrainedBox(maxWidth: 280)` — matches |
| Code entry typography | Design line 1556 `'Roboto Mono';500;21px` vs `labelMono.copyWith(w500, 21)` — matches |
| Border side 1.5px per state | Matches design lines 1556/1560 (`--line` default, `--pink` active) |
| App-bar copy | Design `t_joincode` lines 1770/1782 — matches both locales |
| Back target `invite` | `BACK_TO.joincode = 'invite'` confirmed at design line 1853 |
| `NO_TABS` | Confirmed at design line 1952 |
| `CupidIcons` has no `link` | Confirmed — `cupid_icons.dart` defines 19 glyphs, none is `link`. Deferral 1 is justified |
| CTA is shared, not screen-local | Confirmed — `cupid_primary_button.dart:42-56` renders solid `colorAccentPink` at `tapTarget` with `type.body`. Deferral 2 is justified |
| `flutter analyze lib/features/pairing test/features/pairing` | Re-run: 9 issues, all pre-existing `prefer_initializing_formals` **info**, 0 errors, 0 warnings |
| Test suite green | Re-run: joincode design + behaviour tests **12 passed**; `no_fork_guard_test.dart` **passed** |

Also checked and clean:

- **Tap targets — no finding.** `CupidPrimaryButton` height = `platformTokens.tapTarget`
  (44 iOS / 48 Material). The code `TextField` resolves to roughly 57 logical px
  (`contentPadding` 16 vertical each side + 21px mono line). `CupidHeader`'s back
  affordance is wrapped in `ConstrainedBox(minWidth/minHeight: tapTarget)` on both
  platform branches. All meet the 44pt/48dp minimums.
- **No shared-widget regression.** The diff touches only the feature screen; no
  `design_system/` file is modified, so sibling screens are unaffected.
- **`errorStyle` contrast.** `colorRed` #FF6F91 on `colorBackground` #171129
  measures ~6.9:1 — passes AA.
- **`dart format` is not a regression.** Both changed files are non-clean under
  `dart format --set-exit-if-changed`, but so are 12 untouched files under
  `lib/features/pairing` and `lib/design_system`. Pre-existing repo baseline.
- **`story_master.md` header line says `NO_CHROME`** for this screen. The design
  source disagrees: `NO_CHROME` (line 1951) does not list `joincode`. The
  implementation keeping `CupidHeader` is correct, and the visual-fidelity report
  correctly labels the screen `NO_TABS` only. Product Owner artifact wording, not
  an implementation defect — noted, not blocking.

## Findings

### F1 — No rendered evidence for a visual acceptance criterion (blocking AC1, AC2)

The visual-fidelity report is entirely CSS-to-Dart prose transcription plus
widget-test token assertions. It closes with "No device install, emulator, or
release configuration was involved." There is no design-source render, no
implemented-screen capture, and no side-by-side verdict.

AC1 requires that "layout, spacing, color/token usage, and typography match
exactly with no visible deviation", and AC2 requires each fix be "re-verified
against the design source". Token equality does not establish either. The
report's own snapped values are exactly what only a render can settle:

- design `margin-top:9px` sub-copy gap → `CupidSpacing.sm` (8)
- design `margin-top:26px` before the code row → `CupidSpacing.lg` (24)
- design container `padding:20px 20px 40px` → `24/24/24/32`
- "`contentPadding` … lands the field at roughly the design's 56px slot height"
  — "roughly" is an unmeasured claim

This is feasible in-repo with no new tooling: `mobile/lib/main_preview.dart:160`
already registers a `joincode` preview entry, and the preview shell pins
`locale: const Locale('vi')` (`main_preview.dart:529`).

Required: a design-source render of the `isJoinCode` state, an implemented
dark + `vi` capture, and an explicit comparison verdict in the report — the same
bar STORY-003 is being held to in this requirement.

### F2 — The new design test only exercises the `en` branch (blocking AC1, AC3 for the audited config)

`_harness()` builds `MaterialApp` with no `locale` and no localization
delegates, so `Localizations.localeOf(context).languageCode` is not `vi`
(`pairing_strings.dart:8,11`) and every assertion runs against the English
strings — `find.text('Enter their code')`, `find.text('Ask Bae to read you the
6-character code on their phone.')`, `find.text('Pair up')`.

Production pins `Locale('vi')` while `enableEnLocale` is off
(`mobile/lib/app/cupid_app.dart:38`), and this story audits dark + `vi`
explicitly. The consequence is concrete, not theoretical: the Vietnamese
sub-copy `Bảo Bae đọc mã 6 ký tự trên máy họ cho bạn.` sits inside
`ConstrainedBox(maxWidth: 280)`, a width the design source measured against the
English string. Its wrapped line count and any overflow are unverified by both
test and render.

Required: pin the harness to `Locale('vi')` (or add a `vi` case), and let F1's
capture cover the `vi` rendering.

### F3 — Largest residual visible deviation is missing from the "not fixed" list (report accuracy)

Design lines 1555-1562 render the entry as five 46x56 boxes at `gap:9px` with a
`–` separator between the third and fourth, the active box switching to `--pink`
plus `box-shadow:var(--glow)`. The app renders one full-width field.

D3 discloses the substitution in passing and the code comment cites
`uiux-spec.md` §9, so the decision itself is defensible and this review does not
ask for it to be reversed. But "Deviations NOT fixed" is the section Scrum
Master routes from, and this — the single biggest remaining visual difference on
the screen — is absent from it. Two further sub-deviations also go unlisted: the
per-slot `--glow` box shadow has no counterpart in the implementation, and the
design's active-slot caret box uses `--pink` at weight 400 rather than 500.

Required: list the six-slot row as an explicitly accepted deviation with its §9
rationale, including the missing `--glow` treatment.

### F4 — Deferral 3's justification misreads the story's Out of Scope (report accuracy)

The report defers `Dán`/`Paste` and `Quét QR`/`Scan QR` (design lines 1564-1565)
as "new interactions — out of scope per this story's Out of Scope". That clause
reads: "Any new feature, new screen state, or new interaction **not already
present in the locked design source**." Both buttons are present in the locked
design source, so the clause does not cover them.

The deferral is probably still the right call — clipboard and camera capability
is feature work well beyond a trivial single-screen fidelity fix — but it needs
the correct reason and an explicit routing ask rather than a scope clause that
does not apply. Same wording issue applies in weaker form to deferral 4
(the `Tôi mới là người tạo mã →` cross-link, design line 1568): its *presence* is
design fidelity even though its *target* is Scope A's.

Required: restate deferrals 3 and 4 as scope-escalation asks for Product Owner /
Scrum Master routing, not as Out-of-Scope exclusions.

## Residual risks — route, do not patch in this story

These are correctly deferred and need Scrum Master routing, not rework here.

1. **Hero icon badge absent** (design line 1552): 78x78, radius 28,
   `rgba(183,140,245,.2)`, `link` glyph at 38px in `--purple`. Needs a
   `CupidIcons.link` constant with a cmap-verified codepoint — design-system
   layer, outside this story's write scope. Confirmed accurate.
2. **Primary CTA styling** (design line 1567): 54px height, `--grad-hot` fill,
   `--glow`, 16.5px/w800 vs the shared button's 44/48px, solid `colorAccentPink`,
   `type.body` 17/w400, `elevation: 2`, no glow. Design-system-level story;
   affects every screen using the shared CTA.
3. **Paste / Scan QR secondary actions** (design lines 1564-1565): clipboard and
   camera capability — needs Product Owner scope decision (see F4).
4. **`Tôi mới là người tạo mã →` cross-link** (design line 1568): navigation
   affordance owned by Scope A (STORY-001/STORY-002).
5. **Code length 8 vs 6**: design source says 8 characters (line 1554) and the
   waiting screen renders `CPD-8F2K` (line 1583); the shipped app issues and
   accepts 6. Mobile Dev transcribed `6` to stay truthful to shipped behaviour,
   which is the right interim call. Product Owner decision needed on which is
   canonical — it spans `joincode`, `invite`, and `waiting`.

## Acceptance criteria assessment

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — exact match, dark + `vi` | NOT MET | F1 (no render), F2 (`vi` never exercised), plus the residual deviations above |
| AC2 — deviations corrected, not just documented | PARTIAL | 7 deviations genuinely fixed in code and verified; "re-verified against the design source" has no rendered basis (F1) |
| AC3 — code-entry states | PARTIAL | Empty / focused / error token treatment is asserted by test and correct; asserted in `en` only (F2) |
| AC4 — no navigation change | MET | Diff touches presentation only; `onPaired` seam and back behaviour unchanged |

## Required patch set

1. Add rendered evidence to `visual-fidelity/visual-fidelity-report.md`: design
   `isJoinCode` render + implemented dark/`vi` capture + explicit verdict (F1).
2. Pin `_harness()` in `joincode_screen_design_test.dart` to `Locale('vi')` so
   the audited configuration is the one asserted (F2).
3. Add the six-slot code row (and its missing `--glow`) to "Deviations NOT
   fixed" as an accepted deviation with the §9 rationale (F3).
4. Restate deferrals 3 and 4 as scope-escalation asks rather than Out-of-Scope
   exclusions (F4).

No code change is required to `joincode_screen.dart` for items 1, 3, or 4 — the
implementation as committed is sound and its token usage is exact. The patch set
is evidence and reporting completeness plus a one-line test locale fix.
