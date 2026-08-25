# Visual Fidelity Report — REQ-010 / STORY-001

VISUAL_FIDELITY: PASS

## Scope

- Story: STORY-001 Anti-Ghost alert banner design fidelity
- Surface: Home dashboard `AntiGhostEntryCard` (`ghostAlert` banner)
- Design-Screen: `home`
- Platform / theme / locale: android / dark / vi

## Screen id resolution

`Design-Screen: home` was resolved from the locked design source, not guessed.
`data/devops/system/design-fidelity-config.json` pins
`design_source.location: cupid-app-design-system`, `entry: Cupid App.dc.html`,
`locked: true`. Inside that source, the anti-ghost banner is the `ghostAlert`
block rendered under the `isHome` branch of `Cupid Screens.dc.html` (L266-272),
so the owning screen id is `home`. The render at `--screen=home` returned the
same banner markup that `ux/uiux-spec.md` §0 quotes, which confirms the id.

## Evidence

| Artifact | Path | Size |
| --- | --- | --- |
| Design reference | `visual-fidelity/design-reference-home-android.png` | 406x900 |
| Implemented capture | `visual-fidelity/implemented-home-emulator-5554.png` | 405x900 |

- Device: Android emulator `emulator-5554`, leased through
  `capture-mobile-screen.sh --lease-exec`.
- Design render command (run from the control checkout, absolute worktree
  paths, because `.ai-team-bundle/` is not checked into the worktree):
  `node .ai-team-bundle/runtime/tools/render-design-canvas.js --location=cupid-app-design-system --screen=home --platform=android --theme=dark --lang=vi --out=<worktree>/.../visual-fidelity`
  → `DESIGN_CANVAS: OK ... 406x900`
- Implemented capture command:
  `flutter run -t lib/main_preview.dart --dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true --dart-define=PREVIEW_ANTIGHOST=state-b`
  then `capture-mobile-screen.sh --out=<...>/visual-fidelity --label=home`
  → `MOBILE_CAPTURE: OK ... 405x900 171096`

### Fixture note (required by the handoff)

The capture uses `--dart-define=PREVIEW_HOME_FIXTURE=true`. The originating bug's
first capture omitted it and photographed an empty/unpopulated Home, producing a
false "catastrophic" verdict. `PREVIEW_ANTIGHOST=state-b` was added on top: the
unauthenticated preview otherwise lands in `AntiGhostLoadFailed`, which renders
the one-line banner and cannot evidence the design's two-line layout.
`state-b` resolves to `AntiGhostPendingMine` — deliberately the state that
previously painted the amber subtitle (D8) and the extra timer badge (D7), so
the capture re-verifies both removals. Both defines are pre-existing preview
entrypoint plumbing in `mobile/lib/main_preview.dart`; no app code was added to
reach the state.

### Capture integrity

The first attempt returned a 16399-byte PNG that, on inspection, was the Flutter
splash screen rather than the Home dashboard — a concurrent teammate had
overwritten the shared scratchpad capture script, and the post-launch settle was
too short. That frame was rejected, not reported. The accepted capture uses a
uniquely-named script and a 25s settle after `Flutter run key commands`, and was
visually inspected before acceptance.

## Deviation verification (`ux/uiux-spec.md` §1)

| Id | Design source | Before | After | Verdict |
| --- | --- | --- | --- | --- |
| D1 | Card background `rgba(255,201,126,.15)` | surface/card token fill | `colorAmber.withValues(alpha: 0.15)` | FIXED |
| D2 | Card border `1px rgba(255,201,126,.4)` | no border | `BorderSide(colorAmber @ 0.4)` | FIXED |
| D3 | `border-radius: var(--r-card)` (24px) | ad-hoc radius | `cupidPlatform.radiusCard` | FIXED |
| D4 | Leading tile `rgba(255,201,126,.24)`, radius 14 | accent-tinted tile | `colorAmber @ 0.24`, `radiusSmall` | FIXED |
| D5 | Glyph `sentiment_dissatisfied` in `var(--amber)` | `timer` glyph in accent | `CupidIcons.sentimentDissatisfied` in `colorAmber` | FIXED |
| D6 | Title in `var(--amber)` | default text colour | `colorAmber` | FIXED |
| D7 | No secondary badge | extra timer badge in pending states | badge removed; one uniform chrome | FIXED |
| D8 | Body in `var(--tx2)` | amber in pending states | `colorTextMuted` in every state | FIXED |
| D9 | Trailing `chevron_right` 20px `var(--tx2)` | absent | `CupidIcons.chevronRight`, 20, `colorTextMuted` | FIXED |
| D10 | `wiggle` motion | absent | still absent | OUT OF SCOPE (see below) |
| D11 | Title 14.5px/800, body 12px | title `cardTitle` 22px/600, body `body` 17px | title `body`+`w800`, body `caption` | FIXED (found during implementation) |

D11 was not in the UX spec's §1 table but AC1 explicitly requires typography to
match. It was resolved by adopting the token mapping the sibling Home card
`VibeEntryCard` already uses (`type.body` + `w800` title, `type.caption`
subtitle), which is both the established repo convention and materially closer
to the design than the previous `cardTitle`/`body` pair.

### Icon codepoint gate (`ux/uiux-spec.md` §2)

The spec forbids inventing a codepoint. Verified against the bundled
`mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` with `fontTools`:
`sentiment_dissatisfied -> 0xe811`, glyph id 6351, and the only cmap entry
mapping to that gid is `0xe811` — a single codepoint with no alias
(`sentiment_neutral`/0xe812 and `sentiment_very_dissatisfied`/0xe814 are
distinct glyphs). This confirmed fix-path step 2 (add the glyph) rather than the
step-3 fallback (keep `timer`, defer the gap).

## Residual deltas (all pre-dispositioned, none is a fidelity failure)

1. **Copy.** The design draws `{{ghostAlertTitle}}` / `{{ghostAlertBody}}`
   template bindings, rendering as "Seen 5 phút rồi đấy" / "Trả lời đi không là
   bị bắn Storm nha". The app renders the existing `l10n.anti_ghost_*` lifecycle
   strings. `ux/uiux-spec.md` §1 rules the design's template bindings out of
   scope and keeps the shipped lifecycle copy.
2. **Leading tile size.** 48px (`cupidPlatform.tapTarget`) vs the design's 42px.
   `ux/uiux-spec.md` §1 keeps the platform token: 42px would drop the leading
   affordance below the platform minimum tap target.
3. **`wiggle` motion.** Absent (D10). Dispositioned to STORY-017 `F1`; motion is
   outside this story's scope.

## AC3 — behaviour unchanged

The design source's `ghostAlert` binds `onTap` to `goChat`. `ux/uiux-spec.md` §3
pins that this must NOT be adopted: the banner keeps
`Navigator.push(AntiGhostScreen())`. No new tap target or navigation destination
was added, and the anti-ghosting detection/business logic (`AntiGhostCubit`,
`GhostConfigRepository`) is untouched. Regression-covered by the pre-existing
tests `tapping the card from HomeScreen pushes AntiGhostScreen` and `a
partner-proposed pending config routes to the review state (State C) on tap`,
both passing.

## Verdict

VISUAL_FIDELITY: PASS — D1-D9 and D11 verified corrected in both the code and
the on-device capture; D10 and the two other residual deltas are explicitly
dispositioned out of scope by the UX spec.
