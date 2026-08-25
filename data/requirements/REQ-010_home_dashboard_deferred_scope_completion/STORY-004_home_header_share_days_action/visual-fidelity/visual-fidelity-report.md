---
story: STORY-004_home_header_share_days_action
requirement: REQ-010_home_dashboard_deferred_scope_completion
written_by: mobile-dev
written_at: 2026-08-25
review_cycle: 1
---

VISUAL_FIDELITY: PASS

## Design-Screen

| Field | Value |
| --- | --- |
| Design-Screen | `home` |
| Render entry | `cupid-app-design-system/Cupid App.dc.html` (registered `cupid-app` source, `screens_from: "dom"`, `surface: "mobile"`) |
| Authoritative markup | `cupid-app-design-system/Cupid Screens.dc.html:247-250` — `:248` is the header actions flex container, `:249` the share glyph |
| Axes | android / dark / vi |
| Design capture | `visual-fidelity/design-reference-home-android.png` (406x900, device frame; screen content ≈ 390 CSS px, so reference px ≈ dp 1:1) |
| Render command | `node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=mobile --entry="Cupid App.dc.html" --location=<worktree>/cupid-app-design-system --screen=home --platform=android --theme=dark --lang=vi --out=<story>/visual-fidelity` |

`Cupid Screens.dc.html` is the screen library, not a render entry — `Cupid App.dc.html`
is the composing shell that owns the `screen`/`platform`/`theme`/`lang` toggles.
No `design-fidelity-config.json` change was needed and none is outstanding.

## Implemented-side capture

| Field | Value |
| --- | --- |
| Capture | `visual-fidelity/implemented-home-android.png` (405x900, downscaled from the 1080x2400 framebuffer by the capture tool's default `--max-edge=900`) |
| Source | `main_preview.dart` with `--dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true`, built (`flutter build apk --debug -t lib/main_preview.dart`), installed and launched on `emulator-5554`, captured under a device lease with `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh --lease-exec` |
| Raw evidence | `coding-plan/test-results.md` → `## Story Runtime Startup Smoke` and `## Visual-fidelity capture` |
| State captured | `_homeFixture` profile: paired, `SAME_CITY`, `relationshipStartDate` = today − 247d, so `days = 247` and the share affordance is in its rendered (non-null) state |
| Device pixel ratio | **2.625** (1080 / 2.625 = 411.4dp, the standard 411dp Android width class) |
| Measurement source | A second, un-downscaled 1080x2400 capture of the same frame; every dp figure below is `px / 2.625`, from pixel scans over the exact `colorTextMuted` fill `(180,166,206)`, not by eye |

## Comparison

The only surface this story adds is the header share action, so the comparison is
scoped to the hero header's top row. Everything below the hero belongs to other
REQ-010 stories and is recorded under "Out-of-scope differences".

| Property | Design (`Cupid Screens.dc.html:249`) | Implemented (measured) | Verdict |
| --- | --- | --- | --- |
| Glyph identity | Material Symbols `share` (three nodes, two links) | Material Symbols `share`, `CupidIconVariant.line` (FILL 0, wght 350) | MATCH — pixel-for-pixel identical stroke topology at 16x upscale |
| Glyph ink box | 16 x 18 px | 44 x 48 px ÷ 2.625 = **16.8 x 18.3 dp** | MATCH (≤ 0.8dp, inside the ±0.4dp/axis measurement noise doubled) |
| Glyph size token | `font-size: 23px` | `_headerActionIconSize = 23` passed to `CupidIcon.size` | MATCH — the 23dp em box yields exactly the design's ink box |
| Glyph colour | muted lavender | dominant exact fill `(180,166,206)` = `#B4A6CE` = `colors.colorTextMuted` | MATCH — exact token, not an approximation |
| Vertical centring | centred against the presence row | avatar-pair centre **50.67dp**, glyph centre **50.86dp** → Δ **0.19dp** | MATCH |
| Horizontal placement | trailing end of the header top row | 48dp tap box right edge at **390.1dp** vs hero content-left inset **21.7–22.5dp** → right inset **21.3dp** | MATCH — the action group is flush with the hero's own content edge, symmetric with the left gutter |
| Actions-row gap | `gap: 2px` (`:248`) | `_headerActionGap = 2`, applied by `_HeaderActionsRow` between siblings | NOT YET OBSERVABLE — only one action exists until STORY-005 adds the second; asserted in source and by `_HeaderActionsRow`'s gap-join, not in pixels |
| Row height | `height: 38px` (`:248`) | `_headerActionHeight = 38` on the action's `SizedBox` | MATCH in source; not independently measurable in pixels because the box is transparent |

Design vs implemented glyph, cropped from both captures and upscaled 16x, confirmed
identical: three circular nodes joined by two diagonal links, same stroke weight,
same node radius, same 120° arrangement.

## Accepted deviations

### V1 — the glyph's ink sits ~9dp further from the screen edge than the design markup's

Design trailing glyph ink stops 28px from the screen's right edge; the implemented
share glyph's ink stops **36.9dp** from it.

This is **mandated, not drifted**. `ux/uiux-spec.md` §1 requires the action's width
to be `context.cupidPlatform.tapTarget` (48dp on Material, 44dp on iOS) for
accessibility; the raw design markup is a bare flex row of glyphs with no tap box.
Centring a 16.8dp-wide ink box inside a 48dp box inserts 15.6dp of transparent
padding on each side. The **box** edge lands at 390.1dp, i.e. 21.3dp from the screen
edge, which matches the hero's own 21.7–22.5dp content-left inset — so the group is
correctly flush; only the ink appears inset. Reducing the gap would mean shrinking
the tap target below the platform minimum, which the spec forbids.

### V2 — the design's notification bell is absent

`Cupid Screens.dc.html:250` places a bell with an unread dot immediately right of
the share glyph. That icon is **STORY-005 scope** and `architecture/solution.md` §4
explicitly forbids adding `goNotifs` here.

`_HeaderActionsRow` takes a `List<Widget>` and gap-joins it with `_headerActionGap`,
so STORY-005 appends the bell as a sibling with no change to the share subtree. When
it does, share shifts left by 48 + 2 = 50dp and the bell takes the trailing slot —
reproducing the design's ordering. The seam the phase file's Task 3 asked for is
present and is the reason this deviation closes without rework.

## Out-of-scope differences (recorded, not defects of this story)

These are visible in the two captures but belong to other stories or predate REQ-010.
None of them touches the header actions row.

- Presence row reads `Minh` where the design reads `Minh & Linh` — the preview
  fixture supplies only the caller's `displayName`; partner-name composition is not
  STORY-004 scope.
- The design's "Seen 5 phút rồi đấy" anti-ghost banner, "Vibe Check" card, pet card
  and the Synced Alarm / Zodiac Red Flag grid differ from the shipped card stack.
  That is the deferred REQ-010 dashboard body, owned by the sibling stories.
- The design's `247` numerals are rendered in a heavier display face than the
  implementation's. Pre-existing; not introduced or touched here.

## Verdict

`VISUAL_FIDELITY: PASS`. Every measurable property of the surface this story adds —
glyph identity, ink box, size token, colour token, vertical centring and horizontal
flush — matches the design source within measurement noise. The two deviations are
both specified: V1 is required by the accessibility tap-target rule in the UX spec,
and V2 is another story's scope with the extension seam already in place.
