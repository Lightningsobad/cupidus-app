# UX Spec: STORY-001 Anti-Ghost Alert Banner Design Fidelity

Story: `STORY-001_antighost_alert_banner_design_fidelity`
Requirement: `REQ-010_home_dashboard_deferred_scope_completion`
Screen: Home dashboard — anti-ghost entry/alert card
Widget: `AntiGhostEntryCard` (`mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart`)
Configuration audited: dark theme + `vi` locale (per story's locked scope; light theme not in scope)

## 0. Design source

- `cupid-app-design-system/Cupid Screens.dc.html`, `isHome` block, `ghostAlert`
  conditional banner, lines 266-272:
  ```html
  <sc-if value="{{ ghostAlert }}">
  <div onClick="{{ goChat }}" style="display:flex;gap:13px;align-items:center;padding:15px;border-radius:var(--r-card);background:rgba(255,201,126,.15);border:1px solid rgba(255,201,126,.4);cursor:pointer">
  <div style="flex:none;width:42px;height:42px;border-radius:14px;background:rgba(255,201,126,.24);display:flex;align-items:center;justify-content:center;animation:wiggle 1.4s ease-in-out infinite"><span data-icon style="font-size:23px;color:var(--amber)">sentiment_dissatisfied</span></div>
  <div style="flex:1"><div style="font-size:14.5px;font-weight:800;color:var(--amber)">{{ ghostAlertTitle }}</div><div style="font-size:12px;color:var(--tx2);margin-top:2px">{{ ghostAlertBody }}</div></div>
  <span data-icon style="font-size:20px;color:var(--tx2)">chevron_right</span>
  </div>
  </sc-if>
  ```
- Dark theme token values (`Cupid Screens.dc.html` line 23, 26):
  `--amber:#FFC97E`, `--tx2:#B4A6CE`, `--r-card:24px` (`md`/Material platform).
- This is the only design element STORY-017 explicitly excluded for this
  widget (`visual-fidelity-report.md` line 49, finding `F3`: `"Seen 5 phút
  rồi đấy" banner | later feature story (route absent)`). Closing `F3` for
  this widget is this story's job.

## 1. Current implementation vs design — deviations

Read: `mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart`,
class `_AntiGhostEntryCardChrome`.

| # | Element | Current | Design | Fix |
|---|---------|---------|--------|-----|
| D1 | Card background | `colors.colorSurface` (neutral card surface) | `rgba(255,201,126,.15)` — amber wash | `colors.colorAmber.withValues(alpha: 0.15)` |
| D2 | Card border | none | `1px solid rgba(255,201,126,.4)` | Add `Border.all(color: colors.colorAmber.withValues(alpha: 0.4), width: 1)` on the card `Container`/`Material` decoration |
| D3 | Icon tile background | `colors.colorAccentPurple.withValues(alpha: 0.16)` | `rgba(255,201,126,.24)` — amber tile | `colors.colorAmber.withValues(alpha: 0.24)` |
| D4 | Icon glyph | `CupidIcons.timer` | `sentiment_dissatisfied` (concerned/sad face) | See §2 — icon substitution needs a font-cmap check before mobile-dev picks the final glyph |
| D5 | Icon color | `colors.colorAccentPurple` | `var(--amber)` | `colors.colorAmber` |
| D6 | Title color | `colors.colorText` (always) | `var(--amber)` (always — not conditional) | `colors.colorAmber`, unconditionally (drop the `isPending` branch for this) |
| D7 | Secondary pending badge icon (small amber timer icon next to title, shown when `isPending`) | present | not present in design — the design banner has no extra icon beyond the leading tile and trailing chevron | Remove; the subtitle copy already conveys pending state |
| D8 | Subtitle/body color | `isPending ? colors.colorAmber : colors.colorTextMuted` | `var(--tx2)` (always — one fixed color, no pending variant) | `colors.colorTextMuted`, unconditionally |
| D9 | Trailing chevron | absent | `chevron_right`, `20px`, `var(--tx2)` | Add `CupidIcon(CupidIcons.chevronRight, size: 20, color: colors.colorTextMuted)` as the last child of the `Row`, vertically centered |
| D10 | Motion (`wiggle` on the icon tile) | absent | `animation:wiggle 1.4s ease-in-out infinite` | Out of scope — matches STORY-017 disposition `F1`: "Motion is not a static-fidelity concern." Do not add. |

Everything else already matches or is intentionally unaffected:
- Container shape/radius: `context.cupidPlatform.radiusCard` already maps to
  `--r-card` — keep.
- Row layout (icon tile leading, text column expanded, gap between them):
  already structurally correct — keep `CupidSpacing.md` for the icon↔text
  gap and card padding; the design's raw `15px`/`13px` are the token
  system's already-established approximation for `md` (`16px`), consistent
  with how the sibling Vibe/Pet cards on the same screen already round
  design pixel values to spacing tokens — do not chase sub-pixel parity.
- Tap target sizing (`tapTarget` min-height): already correct, keep.
- Copy (`AppL10n` strings for each lifecycle state): design uses template
  bindings (`{{ ghostAlertTitle }}`/`{{ ghostAlertBody }}`), not literal
  text, and the story's own scope note allows "equivalent" copy — keep the
  existing `l10n.anti_ghost_*` strings as-is. No l10n change needed.

## 2. Icon substitution — verification required, do not invent a codepoint

`CupidIcons` (`mobile/lib/design_system/icons/cupid_icons.dart`) currently
has no `sentiment_dissatisfied`/concerned-face glyph, and no generic "ghost
alert" glyph either. Per this codebase's established rule (`STORY-017`
finding `F2` disposition: "`CupidIcons` carries no verified codepoint for it
and that file's sourcing rule forbids inventing one"), mobile-dev must not
invent a codepoint.

Fix path for D4, in order:
1. Verify whether the bundled icon font's cmap contains a codepoint for
   Material Symbols `sentiment_dissatisfied` (commonly `0xe811`, but the
   bundled font must be checked directly, the same way every other
   `CupidIcons` entry in this file documents its confirmed codepoint).
2. If confirmed: add `CupidIcons.sentimentDissatisfied` following the exact
   documented pattern already used for every other entry in that file, and
   use it for D4/D5.
3. If not confirmed: do not substitute the glyph. Keep the existing
   `CupidIcons.timer` glyph for this pass only, apply the D3/D5 color fix
   (amber tile + amber icon tint) around it, and record the glyph gap as a
   deferred icon-set item — same disposition class as `F2`, not a story
   blocker. All other deviations in §1 (D1-D3, D5-D9) are independent of
   this and must still be corrected.

## 3. Explicitly unchanged (Out of Scope / AC3 pins)

- Tap destination: the story's `AC3` requires the banner continue reaching
  "the already-shipped anti-ghosting screen/flow" (`AntiGhostScreen`) — do
  **not** change `onTap` to the design's `goChat` action. The design source
  routes this banner to chat; this story deliberately does not follow that
  because it would add a new entry point, which `AC3`/Out of Scope forbid.
- Underlying anti-ghosting detection/lifecycle logic (`AntiGhostCubit`,
  `_copyFor` state branching): unchanged — this is a chrome/token-only
  fidelity fix, not a logic change.
- The four lifecycle states this card already renders (`active`, `pending
  mine`, `pending partner`, `pending unknown role`, `not set up`) all reuse
  the same corrected chrome (§1) — the design shows one persistent
  amber-styled banner, so all states get the same amber treatment uniformly
  (no more per-state color branching beyond what the lifecycle text itself
  already conveys).

## 4. Responsive / platform behavior

- No layout breakpoint change. Card remains full-width within the existing
  Home dashboard column inset (`R5` rhythm, owned by `STORY-017`, unaffected
  here).
- `context.cupidPlatform.radiusCard`/`tapTarget` already resolve per-platform
  (iOS `--r-card:26px`/`--tap:44px` vs Material `--r-card:24px`/`--tap:48px`)
  — no new platform branching needed; reuse the existing accessor.

## 5. Accessibility

- Existing `Semantics(button: true, label: ...)` wrapper is correct and
  unaffected by this story's chrome-only changes — keep as-is.
- Color is not the sole signal: the amber wash/border/title color change is
  paired with the lifecycle text itself (title + subtitle copy), consistent
  with this app's existing "no colour-only signalling" convention (see the
  widget's own class doc comment) — no additional non-color affordance
  needed beyond what already exists (chevron affordance for tappability is
  itself new per D9, and is a plain directional icon, not a signal).
- Contrast: `colors.colorAmber` (`0xFFFFC97E` dark theme) on
  `colors.colorSurface`-derived amber-wash background — this pairing is
  already used elsewhere in the app for amber/pending states (e.g. the
  now-removed pending badge, and `colorAmber` icon usage on `me_screen.dart`
  precedent for warning-toned content), so no new contrast risk is
  introduced.

## Completion

`UX Design (UI/UX Designer)` artifact checklist item may be checked in
`story_master.md` once this file is committed — this spec's §1 table is the
literal fix list for Tech Lead/Mobile Dev to implement; §2 defines the one
open verification step (icon codepoint) that must not block the rest.
