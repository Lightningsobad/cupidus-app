# STORY-022 Review Report — Anti-Ghosting Settings Design Fidelity

- Reviewer: Iris-QC (compact-story-review)
- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-022`
- BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd`
- Worktree HEAD: `988d8a0ca21f721c6f700a2e1e17871d0c9d80cd`
- Reviewed: 2026-08-13

Outcome: DEFERRED_ONLY

## Scope Gate

- Diff is 4 files (2 source/test, 2 artifacts), all inside the mobile-dev run's
  declared `write_scope` (`mobile/lib/features/anti_ghosting`,
  `mobile/test/features/anti_ghosting`, the story `visual-fidelity/` dir, and
  `story_master.md`). No scope violation.
- No routing, shell, l10n, token, or backend file touched — consistent with AC4
  and with the story's Out of Scope list.
- Story has `Depends On: NONE` and no OQ blocks any AC. OQ5 (light theme / `en`
  locale) maps only to the story's own Out of Scope item; the delivered work
  respects that boundary. Scope decisions honoured.
- Deliberate divergence from the design source (radio-group single-select
  semantics instead of three independent toggles) is disclosed in the fidelity
  report and traced to a pre-existing `ux/uiux-spec.md` §2.3 decision, not a new
  deviation. Accepted.

## Evidence Verified

Design source read directly at `cupid-app-design-system/project/Cupid Screens.dc.html`
lines 537-591 and `thresholdOpts` lines 2252-2256. The fidelity report's
transcription of the source is accurate on every value I checked: screen box
`8px 16px 40px` / `gap:13px`, hero `padding:20px` + `linear-gradient(145deg,
rgba(183,140,245,.26), rgba(255,171,147,.18))` + `1px solid var(--line)`, card
`padding:17px`, track `gap:8px;padding:4px;border-radius:999px;background:
var(--surf2)`, segment `flex:1;height:40px;font-size:13.5px;font-weight:800`,
selected `var(--grad-hot)`/`#fff` vs unselected `transparent`/`var(--tx2)`,
penalty card `padding:6px 17px` with `40x40` / `radius 14px` tiles, `21px`
glyphs, `14.5px/700` titles, and `1px var(--line)` dividers.

Token bindings check out exactly against `cupid_color_tokens.dart` and
`cupid_spacing.dart`: dark `colorAccentPurple` `#B78CF5` = `rgb(183,140,245)`,
`colorPeach` `#FFAB93` = `rgb(255,171,147)`, `xs/sm/md` = `4/8/16` matching the
source's `4px` track inset, `8px` segment gap, and `16px` horizontal padding.
The `145deg` hero vectors `(-0.5736, -0.8192)` / `(0.5736, 0.8192)` follow the
same `begin = (-sin, cos)` convention already encoded for the `120deg` token
gradients, so the gradient direction is correct, not an invented second
convention.

Reran independently in the worktree's `mobile/`:

| Command | Result |
| --- | --- |
| `flutter analyze --no-fatal-infos lib/features/anti_ghosting test/features/anti_ghosting` | Reproduced — 7 info-level `prefer_initializing_formals`, all in `ghost_config_repository.dart` / `anti_ghost_cubit.dart` / `ghost_storm_cubit.dart`, none in a touched file. PASS |
| `flutter test test/features/anti_ghosting --reporter compact` | Reproduced — `+63: All tests passed!` PASS |

Full-suite `+921` and the single-file `+6` runs are taken from the recorded run
evidence; the two gates I reran matched it exactly, so I did not re-execute the
full suite.

Rendered-fidelity gate: no screenshots exist (simulator provisioning is outside
the mobile lane's authority). Fidelity is evidenced instead by the new dark +
`vi` widget test asserting painted decorations against
`const CupidColorTokens.dark()` / `const CupidPlatformTokens.material()` — two
`colorSurface` cards at `radiusCard` with `elevationShadow`, a `colorSurfaceAlt`
track at radius 999, exactly one `gradientHot` segment, exactly one
`colorPeach @ 0.2` tile, and the `vi` strings rendering rather than the `en`
fallback. That is an acceptable substitute for this repository's mobile lane and
is sufficient for AC1/AC3 in dark + `vi`.

## Findings

### D-05 (minor, evidence completeness) — undisclosed design-source row

The design source's penalty card has three rows (lines 555-571). The fidelity
report documents only two treatments (Emoji Storm peach, sound neutral) and
omits the first row entirely: `Đếm ngược công khai` / `Public countdown`, an
amber tile `rgba(255,201,126,.2)` with a `var(--amber)` `timer` glyph
(lines 556-557). It is neither implemented nor listed in the Deferred table.

Implementing it needs a new persisted setting plus a backend field and new l10n
keys — the same class of blocker as D-01, and excluded by the story's own Out of
Scope ("any new feature, new screen state, or new interaction"). So this is not
a code defect and not a patch this story can absorb; it is a gap in the
deferral inventory. Recording it here as **D-05** preserves the downstream
visibility that the missing table row would otherwise have lost.

The app's `none` row (`notificationsOff` glyph) has no design-source
counterpart; the report does disclose that and applies the source's neutral
off-state treatment. Accepted.

### R-1 (residual) — selected segment label is `colorText`, not literal white

`_TimeoutSegment` paints the selected label with `colors.colorText`. In dark
that is `#F7EEFB`, effectively the source's `#fff`, so AC1/AC3 hold for the
audited configuration. In light theme the same code renders `#3E2645` on the
hot gradient, which departs from the source's `#fff` and is a contrast risk.
Out of scope here per OQ5/D-04, but light-theme QA must revisit this specific
token choice rather than assume the tokens carry over.

### R-2 (residual) — four equal-width segments at narrow widths

The app adds a fourth app-only `Tuỳ chỉnh` segment to the source's three. At
`flex:1` inside a 16px-padded card on a ~360dp device each segment gets roughly
66dp, and the label is `maxLines: 1` with ellipsis. The 800x600 test viewport
cannot catch truncation at phone widths. Worth one narrow-width check during
integration verification; not blocking, and the previous `Wrap` of chips is not
a regression baseline that still applies.

### R-3 (observation) — State B lost its Material disabled chrome

Replacing disabled `ChoiceChip`s with segments means the disabled preview now
paints the selected segment at full `gradientHot` with no dimming. The muted
section headings, the `IgnorePointer`, the `Semantics(enabled: false)`, and the
`anti_ghost_pending_mine_disabled_reason` label all remain and are asserted by
the updated test, and the design source has no disabled state, so this is not
an AC3 miss. Flagging only so it is a conscious visual choice.

## Deferred Items Carried Forward

D-01 (storm emoji set card), D-02 (handshake consent callout), D-03 (per-row
penalty subtitles), D-04 (light / `en` QA) from the fidelity report, plus D-05
above. D-01/D-02/D-03/D-05 all confirmed present in the design source and all
blocked on `mobile/lib/l10n/arb/` being outside this story's write scope, and in
D-01/D-05's case on a new setting plus backend field. None is fixable within
this story's boundary.

## Recommendation

Approve. The in-scope fidelity work is correct, token-bound, verified against
the locked design source, and non-regressing across the feature and full mobile
suites. Scrum Master should log a follow-up story covering D-01, D-02, D-03, and
D-05 with `mobile/lib/l10n/arb/` inside its write scope, and route R-1 to
light-theme QA when OQ5 resolves.

REVIEW_COMPLETE: YES
