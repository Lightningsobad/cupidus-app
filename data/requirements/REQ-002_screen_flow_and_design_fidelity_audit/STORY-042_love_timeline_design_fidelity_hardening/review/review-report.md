# Review Report: STORY-042 Hardening — Love Timeline Visual Fidelity Evidence

Outcome: CLEAN

Reviewer: Iris-QC
Mode: compact-story-review
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-042_love_timeline_design_fidelity_hardening
Fixes: STORY-025_love_timeline_design_fidelity (RWB-20260816-009)
Round: 1
BaseHead: 114fd917ea4482ad60682240fff1a359ee480716
Branch: main (Worktree: repository root)

## Review basis

- `story_master.md` `## Acceptance Criteria` AC1-7 (governing scope).
- `visual-fidelity/visual-fidelity-report.md` (implementer evidence,
  `VISUAL_FIDELITY: PASS` claimed).
- Rendered evidence pair, both AC4 crops, and the scrolled diagnostic in
  `visual-fidelity/`.
- Implementation diff vs `BaseHead`.
- Design source of truth: `cupid-app-design-system/project/Cupid Screens.dc.html`
  timeline block, read directly at L699-730.

This review did not accept the implementer's measurements on trust. The
load-bearing pixel claims were re-measured independently from the committed
PNGs, and both gates were re-run from a clean invocation.

## Acceptance criteria verdicts

| AC | Verdict | Basis |
|----|---------|-------|
| AC1 | MET | Dev-only fixture, default-off, verified in source |
| AC2 | MET | Same-screen rendered pair, calibration independently reproduced |
| AC3 | MET | 18/20 re-confirmed as delivered, 2 fixed; spot-verified in pixels |
| AC4 | MET | Conic ring PASS; dashed border FAIL-then-fixed, re-measured |
| AC5 | MET | Connector-dot deviation surfaced, fixed in app code, regression-tested |
| AC6 | MET | Evidence artifacts complete |
| AC7 | MET | No navigation surface in the diff |

### AC1 — dev-only fixture, default-off

Verified in `mobile/lib/main_preview.dart`. `_timelineFixture` is
`bool.fromEnvironment('PREVIEW_TIMELINE_FIXTURE')`, which defaults to `false`.
On the default path `_buildTimeline` returns
`TimelineScreen(createCubit: () => TimelineCubit(getIt<TimelineRepository>()))`
— byte-for-byte the pre-existing behaviour, so live-repository resolution is
unchanged. Double-gated: the file is the `main_preview.dart` dev entrypoint,
not `main.dart`, and the fixture additionally requires the define.

Confirmed no production API was widened: `TimelineScreen`'s `repository` and
`accountRepository` parameters already existed at
`timeline_screen.dart:34-35,48` before this story; the diff for that file
touches only the connector-dot constants. This matches the PO's disposition
that "the seam to inject a fixture already exists".

### AC2/AC3 — rendered comparison and the 20 deviations

The pair is a genuine same-screen render: identical row order, identical
five-row accent cycle (pink/mint/peach/butter/purple), identical glyphs
including `savings` and `draw` with no fallback boxes, and identical dates
(18/01/26, 02/01/26, 11/11/25, 26/11/25) in both images.

The report's stated measurement basis is a load-bearing assumption for every
"MATCH" verdict, so it was validated first. The report claims the design frame
insets screen content by ~8.5 px and scales 0.985 PNG px per CSS px, calibrated
on entry-card edges at CSS 42 and 379.5. Predicted design card edges are
therefore 49.87 and 382.3; measured 50.3 and 381.8 — within half a pixel on
both. The calibration is sound and the derived numbers can be trusted.

Independent spot re-measurements (design values bezel-corrected to screen
coordinates):

- Rail centre: app ink at x=22-24 peaking at 23 (centroid 23.2); design ink at
  x=31-33 peaking at 32 (centroid 23.5 corrected). Deviation #6 confirmed.
- Entry-card left edge: app 41.5 PNG px = 42.2 dp; design 50.3 = CSS 42.0.
  Deviation #7 (`padding-left:26`) confirmed.
- Entry-card right margin: app right edge 388.5 PNG px = 394.7 dp = viewport
  411.4 - 16; design 381.8 = CSS 379.5 = viewport 395.5 - 16. Both are a
  correct 16 px right margin in their own viewport. The differing absolute
  widths are a viewport-width difference (411.4 dp vs ~395.5 CSS px), not a
  deviation — worth stating explicitly because the raw pixel widths differ by
  15 px and could be misread as one.
- Countdown card top edge: first transition at y=113-115 in both. Deviation #1
  confirmed.

18-of-20-as-delivered plus 2 fixed is an accurate characterisation.

### AC4 — the two flagged risks

**Conic ring — PASS confirmed, no fix needed.** `ac4-progress-ring-comparison.png`
shows the pink arc beginning at exactly 12 o'clock and sweeping clockwise in
both, with the `--surf2` remainder in the upper-left, matching arc thickness,
matching 44 px inner disc, and a centred "82%". No seam or start-angle
artifact. `GradientRotation(-math.pi / 2)` does reproduce
`conic-gradient(var(--pink) 82%, var(--surf2) 0)`. M-2 discharged.

**Dashed border — FAIL as delivered, fix independently verified.** The dash
rhythm was re-measured from the committed PNGs rather than taken on trust.

From `ac4-dashed-border-comparison.png` (4x crop), luminance run analysis
across the stroke row: design 17 ink runs at a dominant 20-crop-px period with
mean ink 11.41 crop px; app 17 ink runs at the same dominant 20-crop-px period
with mean ink 11.41 crop px. At 4x that is a 5.0 px period and ~2.85 px ink in
both — the two profiles are effectively identical, and the implementer's stated
numbers are reproduced.

Independently corroborated on the *photo placeholder* frame, which appears in
the sanctioned `design-reference-timeline-android.png` above the fold: app
37 ink runs, period predominantly 5, ink 3; design 37 ink runs, period
predominantly 5, ink 3. Identical run count and rhythm. This matters for
provenance — see Residual risks R-A — because it means AC4's dashed-border
conclusion does not rest solely on the unsanctioned scrolled diagnostic.

The stroke-straddle correction is sound in principle: a CSS border paints
inside the border box while Flutter centres a stroke on its path, so deflating
by `strokeWidth / 2` and reducing the corner radius by the same amount is the
correct compensation. M-3 discharged.

### AC5 — connector dot, the new deviation

The diagnosis was checked against the design source rather than accepted. The
report's whole argument rests on `Cupid Screens.dc.html` having no global
`box-sizing` reset. Confirmed: a repository-wide search finds `box-sizing`
only as per-element inline declarations (switch pills, avatar tiles,
`image-slot` internals) and as the opt-in `.bbox` utility class in
`support.js`. The timeline dot at L710 —
`width:16px;height:16px;border-radius:50%;background:{{ t.dot }};border:3px solid var(--bg)`
— carries no `box-sizing`, so it is content-box. STORY-025's claim that
"`Border.all` inside a fixed-size `Container` is border-box natively, so this
needed no compensation" was therefore wrong in the opposite direction, and the
shipped widget rendered a 10 px fill inside a 16 px box.

Independently measured from the committed renders: app dot fill 16 px wide,
centre x=26.5, vertical extent y=242..257; design dot fill 15 px wide, centre
x=35.0 → 26.5 corrected, vertical extent y=242..256. A sub-pixel match on both
axes and on height.

The off-rail claim also holds and is the non-obvious part of this fix. Rail
centre measures 23.5 in both; the dot fill centre measures 26.5 in both, i.e.
+3.0 px in the design as well as in the app. The design's `left:-26px`
positions the border box, so under content-box the fill centre lands 3 px right
of the rail — the fixed app now reproduces that rather than the on-rail
centring STORY-025 assumed. The fix is correct, not a compensating error.

Vertical positioning is consistent for the same reason: `_dotTop` stays 16
while the box grew, so the fill top moves to 19, exactly as CSS `top:16px` on a
content-box element with a 3 px border does. Confirmed in the measured extents.

Locked by a new widget test asserting the 22 dp box, the 16 dp fill, the 3 dp
`colorBackground` ring, and the 27 dp fill centre — all four of which I
re-derived from the layout constants independently before running it.

### AC6 — evidence completeness

`visual-fidelity/` contains both halves of the pair
(`implemented-timeline-emulator-5560.png`,
`design-reference-timeline-android.png`), the below-fold app capture
(`implemented-timeline-bottom-emulator-5560.png`), both AC4 crops, the scrolled
diagnostic, and a `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS`
with the 20-deviation disposition table, the fixture-setup note, and the
ring/dashed re-verification results. Complete.

### AC7 — navigation

No route, shell entry, or tab wiring appears anywhere in the diff. The only
`timeline_screen.dart` change is the connector-dot box sizing. AC7 MET by
diff containment.

## Diff containment

Four files changed vs `BaseHead`, all within the story's declared lane:

- `mobile/lib/main_preview.dart`
- `mobile/lib/features/timeline/presentation/screens/timeline_screen.dart`
- `mobile/lib/features/timeline/presentation/widgets/timeline_dashed_border.dart`
- `mobile/test/features/timeline/presentation/timeline_design_fidelity_test.dart`

Confirmed:

- No file under `mobile/lib/design_system/` created, modified, or forked.
- No STORY-025 artifact touched; its closed boundary not reopened.
- No `mobile/lib/l10n/arb/` file touched (M-5 respected).
- No shared app-shell file touched (D-1 respected).
- No timeline business logic touched (`TimelineRepository`, `TimelineCubit`,
  remote data source, Drift DAO, create-entry flow all untouched).
- Blast radius of the dashed-border change is contained: `TimelineDashedBorder`
  has exactly two call sites, `timeline_screen.dart:331` (add-memory pill) and
  `timeline_entry_card.dart:214` (photo placeholder), both inside the timeline
  feature. No other screen inherits the new dash rhythm.
- The connector-dot change is inside the private `_TimelineRail` in
  `timeline_screen.dart`; no other surface consumes it.

## Gates re-run independently

| Gate | Result |
|------|--------|
| `flutter analyze` on the four changed files | No issues found |
| `flutter test test/features/timeline/presentation/timeline_design_fidelity_test.dart` | 10/10 passed, including the new dot test |
| `flutter test` (full suite) | +1270, ~2 skipped, 0 failed, exit 0 |

The full-suite numbers reproduce the implementer's claim exactly. The
`no_fork_guard` design-system test is inside the passing full suite.

## Findings

None blocking. No new undisclosed deviation was found.

The full-screen pair, the below-fold pair, and both crops were compared for
anything the report does not already name. Two things looked like candidate
deviations on inspection and both resolved to non-issues once measured, so they
are recorded here rather than left implicit:

- **Add-memory pill left alignment.** On visual inspection the design's
  "Thêm kỷ niệm" pill appears to start well right of the app's, suggesting the
  pill had been indented into the rail gutter. Measured, it is correct in both:
  the pill's top dashed stroke begins at x=34 in the app and x=42 in the design
  (33.5 corrected → CSS 34.0), i.e. 16 px screen padding plus the ~18 px corner
  radius in both. The apparent offset is entirely the design frame's bezel. The
  pill is correctly a sibling of the rail container, outside `padding-left:26px`,
  matching the design's DOM structure.
- **Entry-card raw pixel width differs by 15 px** between the two renders. This
  is the viewport-width difference described under AC2/AC3, not a margin
  deviation; both render a correct 16 px right margin.

## Residual risks

- **R-A — evidence provenance for the below-fold surface.** The AC4
  dashed-border verification of the "Thêm kỷ niệm" button rests on
  `design-reference-timeline-android-scrolled-diagnostic.png`, produced by a
  throwaway Playwright script rather than by the sanctioned
  `render-design-canvas.js`. The implementer labels this honestly and the
  script replicates the tool's own flow, but it is not a reproducible
  artifact. Materially mitigated: I re-verified the identical dash rhythm on
  the photo placeholder frame, which *is* present in the sanctioned above-fold
  design render, with an exact match (37 runs, period 5, ink 3 in both). AC4's
  conclusion therefore stands on sanctioned evidence independently of the
  diagnostic. The underlying tooling gap is already split to its own rework
  item and is not this story's scope.
- **R-1 (implementer-flagged) — entry card renders +5 dp taller** than the
  design's 96.6 CSS, from Nunito line-height metrics rather than any spacing
  constant. Visible in the pair as slightly taller cards. Correcting it means
  overriding `height` on shared typography tokens, which would move every
  screen — the same cross-story class as **M-4**, already carried to
  requirement integration review. Per the handoff, explicitly not this story's
  scope and no fix required here. Confirmed the story's own spacing constants
  (row gap, card width, horizontal padding, 7/10/11 inter-block) do match.
- **R-2 / R-3 / R-4 / R-5 / R-6 (implementer-flagged)** — header copy (M-5
  l10n), preview-harness bottom chrome and FAB (not real app shell), fixture
  milestone date tracking capture day, shared star field (D-1/STORY-032), and
  device chrome. All fall into classes already dispositioned out of scope by
  `story_master.md` `## Out of Scope`. Re-confirmed; no action.
- **Stroke-straddle sub-measurement not reproducible from committed evidence.**
  The 49.93 / 50-51 device-pixel figures were taken from a raw 2x design render
  that is not in the evidence directory. The reasoning is sound and the
  resulting rhythm matches, but that specific number could not be re-derived.
  Non-blocking.
- **Dev-only fixture surface.** `_PreviewTimelineRepository.createEntry` throws
  `UnimplementedError` and the photo placeholder relies on an unreachable host
  to trigger the empty state. Both are documented in-file, mirror the existing
  `_PreviewChatRepository` pattern, and are unreachable from production. Noted
  only; no action.

## Conclusion

All seven acceptance criteria are met. The story delivers what RWB-20260816-009
asked for: STORY-025's source-only fidelity claim is now backed by a real
rendered pair, the two risks its own reviewer flagged as "most likely to differ
once actually rendered" were actually checked instead of deferred again, and
the two deviations that did not survive contact with a real render (#8
connector-dot fill, #19 dashed-border rhythm and straddle) were fixed in app
code with a regression test rather than re-documented.

The evidence report is unusually candid about its own limits, and every
load-bearing claim I re-measured independently reproduced. No new undisclosed
deviation. Story is merge-eligible.

Outcome: CLEAN
