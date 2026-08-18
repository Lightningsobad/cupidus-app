# STORY-053: Anti-Ghosting Public-Countdown Penalty Row

Status: DONE
Retro-Type: RED-PATCH
Fixes: STORY-022_anti_ghosting_settings_design_fidelity
Complexity: standard
Story-Class: standard
Design-Screen: antighost
Implementation Lane: shared (product-owner + tech-lead scope the new
persisted setting, then backend-dev field/API support, ui-ux-designer
confirms the amber-tile row spec, mobile-dev adds the row + l10n keys)

## Artifacts

- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer)
- [x] Architecture (Tech Lead)
- [x] Implementation (Development)
- [x] Review (Reviewer)

## Background (Rework Item)

Source: `data/retro-audit/rework-backlog.md` — RWB-20260816-018, split out
of `STORY-041_anti_ghosting_settings_design_fidelity_hardening`'s Product
Owner scoping (finding D-05, carried forward from STORY-022's own
`review/review-report.md`).

The design source's penalty card has three rows (design source lines
555-571); the app implements only two (Emoji Storm, sound) and omits the
first row entirely: `Đếm ngược công khai` / "Public countdown", an amber
tile (`rgba(255,201,126,.2)`, `var(--amber)` `timer` glyph). Reviewer
confirmed this needs a new persisted setting plus a backend field and new
l10n keys — the same blocker class as D-01. Not folded into STORY-041: it is
excluded by that story's own Out of Scope ("any new feature, new screen
state, or new interaction") and is not a pure rendering fix a screen-scoped
hardening story can absorb.

Exact remediation suggested by the surfacing reviewer: Product Owner/Tech
Lead to scope a new persisted anti-ghosting setting ("public countdown")
plus its backend field, then Backend Developer adds the field/API support,
UI/UX Designer confirms the amber-tile row spec, Mobile Developer adds the
row to `anti_ghost_screen.dart` with new l10n keys under
`mobile/lib/l10n/arb/`, scoped as its own story rather than folded into a
future anti-ghosting hardening pass.

Related, still-`PENDING` sibling item in the same screen family:
`RWB-20260816-019` (sound-penalty row label mismatch, l10n-only, no new
setting/backend needed) is a separate, smaller rework item — Product Owner
may evaluate whether it is efficient to fold RWB-019's l10n string fix into
this story's mobile-lane phase (same screen, same l10n file family) or keep
it fully separate; either is acceptable, record the decision here.

Design source confirmed directly (`cupid-app-design-system/project/Cupid
Screens.dc.html` lines 562-579, the `isAnti` penalty card): it holds three
independent toggle rows (own `Switch`-style control each, not a single-select
group) — row 1 `Đếm ngược công khai`/`Public countdown` (amber tile
`rgba(255,201,126,.2)`, `timer` glyph `var(--amber)`, subtitle `Hiện trên
dashboard cả hai`/`Shown on both dashboards`, switch rendered ON), row 2
`Emoji Storm` (switch rendered ON), row 3 `Phát âm thanh`/`Sound override`
(switch rendered OFF, "off by default" copy). The app's existing
`_PenaltyRadioGroup` in `anti_ghost_screen.dart` implements rows 2-3 as a
**mutually-exclusive radio selection** over the backend's single-value
`penalty` enum (`emoji_storm | noise | none`, `ghost-config.entity.ts`), not
as independent toggles — already reviewed and accepted in STORY-022/
STORY-041, not reopened here. Row 1 has no such precedent: it is not a
`Penalty` value and must not become a fourth radio option. It needs its own
independent boolean field alongside `penalty` on the same `GhostConfig`
persisted record (`backend/src/modules/ghost-config/entities/
ghost-config.entity.ts`, `dto/create-ghost-config.dto.ts`), submitted through
the same `POST /ghost-config` propose → partner-approval flow already used
for `timeoutMinutes`/`penalty` (`ghost-config.controller.ts`,
`mobile/lib/features/anti_ghosting/data/ghost_config_repository.dart`
`propose()`), since it lives on the same row/record and that record has no
existing per-field mutation path.

The design mock's row-1 subtitle ("shown on both dashboards") describes the
*motivation* for the setting, not a second deliverable: no live/ticking
public countdown display exists anywhere in the app today (the home
dashboard's `AntiGhostEntryCard`,
`mobile/lib/features/anti_ghosting/presentation/widgets/
anti_ghost_entry_card.dart`, shows only a static "active X minutes / penalty
Y" summary text, confirmed by direct read — no countdown timer widget at
all, for any penalty type). Building an actual live public-countdown display
component is a materially larger, un-scoped feature with its own UX/
architecture surface, inconsistent with this story's `standard` complexity
and its `Implementation Lane` framing (settings-row addition only: Tech
Lead/Backend field, UI/UX row spec confirmation, Mobile row + l10n). This
story delivers the **persisted setting and its settings-screen row only**;
wiring a real dashboard countdown display to it is explicitly out of scope
(see `## Out of Scope`) and not implied by "the setting exists."

**RWB-20260816-019 disposition — folded in.** RWB-019 (found by Iris-QC-6,
`STORY-041/review/review-report.md` finding RV-1) is a single-value l10n
correction: `anti_ghost_penalty_noise`'s `vi` value reads `"Gây ồn"`
(`mobile/lib/l10n/arb/app_vi.arb` line 58) but the design source's row-3 `vi`
label reads `"Phát âm thanh"` (`Cupid Screens.dc.html` line 577); the `en`
value (`"Noise"`) is not flagged by RWB-019 and is left untouched to avoid
re-litigating an unflagged string. Folded into this story's mobile-lane
phase rather than opened as its own story: it is a one-line existing-key
value edit (no new key, no rename) in the exact same `mobile/lib/l10n/arb/`
file family this story is already touching for the new row's keys, carries
no backend/persisted-setting dependency, and is LOW priority with no
blocking relationship to anything else — spinning up a separate
Requirements → UX → Architecture → Implementation → Review cycle for a
single string value would be disproportionate. An explicit AC is added below
(AC6) so Reviewer and Scrum Master can verify it landed; `rework-backlog.md`
itself is not edited by this story (Scrum Master owns that registry file).

## In Scope
1. New persisted boolean field on the `GhostConfig` record —
   `publicCountdown` (backend: `backend/src/modules/ghost-config/entities/
   ghost-config.entity.ts` `@Column` + `dto/create-ghost-config.dto.ts`;
   default `true`, matching the design mock's rendered ON switch state for
   this row, the same convention `timeoutMinutes`/`penalty` already use for
   their own defaults) — submitted, returned, and persisted through the
   existing `POST /ghost-config` propose → partner-approval flow and
   `GET /ghost-config` read, exactly like `timeoutMinutes`/`penalty`; no new
   endpoint, no new mutation path.
2. Mobile wire-model update: `mobile/lib/features/anti_ghosting/data/
   ghost_config_models.dart` `GhostConfig.fromJson`/constructor gains
   `publicCountdown`; `ghost_config_repository.dart`'s `propose()` request
   body gains `"publicCountdown": <bool>` alongside `timeoutMinutes`/
   `penalty`.
3. New settings-screen row in `anti_ghost_screen.dart`, rendered as the
   FIRST row inside the existing Penalty card/section (above the current
   `_PenaltyRadioGroup`), matching the design source's row 1 exactly: 40x40
   rounded-14 tile, `rgba(255,201,126,.2)` background, `timer` glyph in
   `var(--amber)` at 21px; title `Đếm ngược công khai`/`Public countdown`;
   subtitle `Hiện trên dashboard cả hai`/`Shown on both dashboards`; a
   toggle switch bound to `publicCountdown` (not a `RadioListTile`, not a
   member of the `Penalty` group). Both title and subtitle are rendered —
   unlike the pre-existing D-03 gap on rows 2-3 (deferred, l10n-blocked at
   the time), this row is new and its l10n keys are being added in this
   story regardless, so there is no reason to ship it subtitle-less.
4. New l10n keys in both `mobile/lib/l10n/arb/app_vi.arb` and `app_en.arb`
   for the new row's title and subtitle (exact key names left to Tech
   Lead/Mobile Developer, following the existing `anti_ghost_*` naming
   convention — e.g. `anti_ghost_public_countdown_title` /
   `anti_ghost_public_countdown_subtitle`, not `anti_ghost_penalty_*` since
   this is not a `Penalty` enum member).
5. RWB-20260816-019 fold-in: correct `anti_ghost_penalty_noise`'s `vi` value
   in `app_vi.arb` from `"Gây ồn"` to `"Phát âm thanh"` to match the design
   source's row-3 `vi` label. Existing key, value-only change, no rename, no
   `en` change (RWB-019 does not flag `en`).
6. Widget-test coverage: new/updated assertions in
   `mobile/test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart`
   covering the new row's tokens (tile background/glyph/color), copy (title
   + subtitle, both locales), toggle state reflecting `publicCountdown`, and
   the corrected `anti_ghost_penalty_noise` `vi` string.
7. Backend test coverage: extend `ghost-config.service.spec.ts` (or the
   nearest existing backend test for this module) to cover
   `publicCountdown`'s default and persistence through `create()`/`getActive()`.

## Out of Scope
- A live/ticking public-countdown display component on the home dashboard
  (`AntiGhostEntryCard` or elsewhere): the design mock's "shown on both
  dashboards" subtitle is the setting's motivation copy, not a second
  deliverable. No such display exists today for any penalty type; building
  one is a materially larger, un-scoped feature with its own UX/architecture
  surface, inconsistent with this story's `standard` complexity and its
  settings-row-only `Implementation Lane`. Confirmed by direct read of
  `anti_ghost_entry_card.dart`: it renders only a static summary string
  today, no timer/countdown widget of any kind.
- Any change to the mutually-exclusive `Penalty` selection (`emoji_storm |
  noise | none`) or `_PenaltyRadioGroup`: `publicCountdown` is an
  independent boolean field, never a fourth `Penalty` value. The existing
  radio-vs-toggle design mismatch on rows 2-3 was already reviewed and
  accepted in STORY-022/STORY-041 and is not reopened here.
- D-01 (storm-emoji-set card), D-02 (handshake consent callout), D-03
  (per-row penalty subtitles on the EXISTING rows 2-3): all remain out of
  scope, unchanged disposition from STORY-041's own Out of Scope — this
  story does not re-litigate them. (Row 1's own subtitle, added fresh as
  part of this new row in item 3 above, is not a D-03 fix; D-03 is about
  rows 2-3 only.)
- A separate/unilateral mutation path for `publicCountdown` outside the
  existing propose → partner-approval flow (e.g. an instant self-only
  toggle with no partner approval): out of scope. It persists on the same
  `GhostConfig` row as `timeoutMinutes`/`penalty`, which has no per-field
  mutation path today; inventing one is a larger architecture change than
  this story's scope.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source's row-1 spec.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet), consistent with every prior REQ-002 hardening
  story on this screen (STORY-022, STORY-041).
- STORY-022's and STORY-041's own `story_master.md` `Status: DONE` records:
  left undisturbed, no reopening of their closed git boundaries/branches.
- Anti-ghosting business logic beyond the one new field (ghost storm cubit,
  timer/timeout evaluation, notification delivery): untouched.

## Acceptance Criteria
1. Given the `GhostConfig` backend record, when a new config is proposed via
   `POST /ghost-config`, then the request/response payload includes a
   `publicCountdown` boolean field (default `true` when not supplied),
   persisted and returned identically to `timeoutMinutes`/`penalty` through
   the same partner-approval propose flow — no new endpoint, no new
   mutation path.
2. Given the Anti-Ghosting settings screen rendered in dark theme + `vi`
   locale, when the Penalty card renders, then a new row appears as its
   FIRST row (above the existing Emoji Storm/Sound radio rows) with a
   40x40 rounded-14 amber tile (`rgba(255,201,126,.2)`, `timer` glyph
   `var(--amber)`, 21px), title `Đếm ngược công khai`, subtitle `Hiện trên
   dashboard cả hai`, and a toggle switch reflecting the persisted
   `publicCountdown` value — matching the design source
   (`Cupid Screens.dc.html` lines 562-567) with no visible deviation.
3. Given the same screen in `en` locale, when the row renders, then the
   title reads `Public countdown` and the subtitle reads `Shown on both
   dashboards`, sourced from new l10n keys in `app_en.arb` (no hardcoded
   literal strings).
4. Given the user toggles the new row's switch, when the change is
   submitted, then it goes through the existing propose → partner-approval
   flow (a new pending config), consistent with how `timeoutMinutes`/
   `penalty` changes are already submitted — the toggle is never applied
   unilaterally without partner approval.
5. Given the existing `_PenaltyRadioGroup` (Emoji Storm/Sound/None
   selection), when this story is delivered, then it is functionally and
   visually unchanged — `publicCountdown` is not added as a fourth radio
   option and the `Penalty` enum/wire contract is untouched.
6. Given RWB-20260816-019 (the `noise` row's `vi` label mismatch), when this
   story is delivered, then `anti_ghost_penalty_noise`'s `vi` value in
   `app_vi.arb` reads `"Phát âm thanh"` (matching the design source's row-3
   `vi` label), with no change to its `en` value or key name.
7. Given the new field and the corrected string, when this story is
   delivered, then `anti_ghost_screen_test.dart` has passing widget-test
   assertions (dark + `vi`, and `en` for the new row's copy) covering the
   new row's tokens/copy/toggle-state and the corrected `noise` `vi` string,
   and a backend test covers `publicCountdown`'s default and persistence.
8. Given no live dashboard countdown display exists today, when this story
   is delivered, then `anti_ghost_entry_card.dart` and the home dashboard
   are unchanged — the new field is persisted and settable but not yet
   consumed by any dashboard display, consistent with `## Out of Scope`.
9. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.
