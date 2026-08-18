# Phase P2 – Mobile public-countdown row

## 1. Objective

The Anti-Ghosting settings screen renders a new public-countdown toggle row as
the first child of the Penalty card, bound to `publicCountdown`, submitted
through the existing propose flow, in both locales — plus the RWB-20260816-019
`vi` string correction (AC2, AC3, AC4, AC6, AC7).

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-mobile-public-countdown-row.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: YES
- Write Scope:
  - `mobile/lib/features/anti_ghosting/data/ghost_config_models.dart`
  - `mobile/lib/features/anti_ghosting/data/ghost_config_repository.dart`
  - `mobile/lib/features/anti_ghosting/presentation/anti_ghost_cubit.dart`
  - `mobile/lib/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart`
  - `mobile/lib/main_preview.dart`
  - `mobile/lib/l10n/arb/app_vi.arb`
  - `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/lib/l10n/generated/` (regenerated, not hand-edited)
  - `mobile/test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
    (`flutter build apk --debug`)
  - Startup Command Source: N/A for this phase
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - None
- Shared Interfaces Consumed:
  - `publicCountdown` on the `GhostConfig` wire record
    (`../architecture/contract-summary.md` sections 1, 3, 4)
- Risk Surfaces:
  - Missing field crashes settings screen
  - Regression in `_PenaltyRadioGroup` (AC5)
  - l10n keys absent from generated Dart
- Source Of Truth:
  - authoritative artifact or convention:
    `../architecture/contract-summary.md` for the wire field, `../ux/uiux-spec.md`
    for every visual and interaction decision
  - consumer contract: none downstream
- Primary Inputs Summary:
  - requirements: `../requirements/` — In Scope items 2-6, AC2-AC8
  - architecture: `../architecture/contract-summary.md`,
    `../architecture/solution.md` sections 1 (Key Discovery 3) and 4
  - UX constraints: `../ux/uiux-spec.md` sections 1-6 — required, this phase is
    almost entirely UX-specified
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: one wire field surfaced as one settings row, plus one
    co-located string correction
  - Source/Test File Count: 8 hand-authored (`mobile/lib/l10n/generated/` is
    tool output from `flutter gen-l10n`, not authored). Three of the eight are
    single-line or single-entry edits: `main_preview.dart` (+1 constructor
    argument), `app_en.arb` (+2 keys), `app_vi.arb` (+2 keys, 1 value fix).
    Substantive files: 5.
  - Split Required: NO
  - Split Rationale: the only available seam is wire-model/repository/cubit vs.
    screen/l10n/test — but that is a contract-and-its-consumers seam inside a
    single lane with a single owner running in sequence, which `master-plan.md`
    forbids splitting into a standalone contract phase. Splitting anywhere else
    would separate the row widget from the l10n keys and the test that asserts
    both, i.e. one behavior cluster. Kept as one phase.

## 2. Required Reads

- `../requirements/`
- `../ux/uiux-spec.md` sections 1-6
- `../architecture/contract-summary.md`
- `../architecture/solution.md` sections 1 and 4

## 3. Tasks

- `ghost_config_models.dart`: add `required this.publicCountdown` to the
  `GhostConfig` constructor, the `final bool publicCountdown;` field, and
  `publicCountdown: json['publicCountdown'] as bool? ?? true,` in `fromJson`.
  The nullable-tolerant read is required by
  `../architecture/contract-summary.md` section 4 — do not tighten it to
  `as bool`. Do not add the field to `StormStatus`.
- `main_preview.dart:331`: add `publicCountdown: true` to the one direct
  `GhostConfig(...)` construction (the only non-`fromJson` call site).
- `ghost_config_repository.dart`: `propose()` gains
  `bool publicCountdown = true` and sends `'publicCountdown': publicCountdown`
  in the POST body. The parameter is defaulted rather than `required` because
  its default is the same `true` the server column default produces, so the two
  can never disagree; the production call path is still compile-enforced via the
  callback signature below.
- `anti_ghost_cubit.dart:170-177`: `propose()` gains the same
  `bool publicCountdown = true` parameter and forwards it to the repository.
- `anti_ghost_screen.dart`:
  - `_ProposeForm.onSubmit` becomes
    `void Function(int minutes, Penalty penalty, bool publicCountdown)` — a
    non-optional third argument, so the real UI path at line 102 can never omit
    the user's choice.
  - `_ProposeFormState`: add `late bool _publicCountdown;`, seed it in
    `initState` as `widget.prefill?.publicCountdown ?? true` next to the
    existing `_penalty` seeding (UX §3 State A), and pass it in the
    `CupidPrimaryButton` `onPressed` callback.
  - Add a new private stateless row widget rendering: a `_penaltyTileSize` (40)
    square with `context.cupidPlatform.radiusSmall` radius,
    `colors.colorAmber.withValues(alpha: 0.2)` background and
    `CupidIcon(CupidIcons.timer, size: _penaltyGlyphSize, color:
    colors.colorAmber)`; `SizedBox(width: CupidSpacing.md)`; an `Expanded`
    column with title `type.body.copyWith(fontWeight: FontWeight.w700, color:
    <content color>)` and subtitle `type.caption.copyWith(color:
    colors.colorTextMuted)`; and a trailing switch modelled on `_ConsentSwitch`
    (`mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart:375-433`)
    — same `SizedBox(width: 54, height: context.cupidPlatform.tapTarget)`
    wrapper, same 54x32 pill, `colors.gradientHot` when on / `colors.colorLine`
    when off, 26px white knob. Keep it local to `anti_ghost_screen.dart`; do not
    promote `_ConsentSwitch` into the design system in this story.
  - Wrap only the switch in `Semantics(toggled: <value>, enabled: <enabled>,
    label: '<title>. <subtitle>')` (UX §5). Only the switch is tappable — do not
    make the row container tappable (UX §2).
  - Insert the row as the literal first child of the Penalty `_SettingsCard`'s
    `Column` in **both** `_ProposeForm` (line ~729, enabled) and
    `_PendingMineBody` (line ~479, disabled), each followed by a 1px
    `colors.colorLine` divider above the existing
    `Text(l10n.anti_ghost_penalty_label)` heading (UX §1).
  - Disabled rendering (UX §3 State B): tile mutes to `colors.colorSurfaceAlt` /
    `colors.colorTextMuted` and the title mutes to `colors.colorTextMuted`, but
    the switch **track keeps its true on/off fill** — do not grey the track.
    `onTap` becomes `null`.
  - Do not touch `_PenaltyRadioGroup`, `_PenaltyIconTile`, `Penalty`,
    `_PendingPartnerBody`, `_ActiveSummaryBody`, or their l10n strings.
- l10n: add `anti_ghost_public_countdown_title` /
  `anti_ghost_public_countdown_subtitle` to both arb files —
  `vi`: `"Đếm ngược công khai"` / `"Hiện trên dashboard cả hai"`;
  `en`: `"Public countdown"` / `"Shown on both dashboards"`. `app_vi.arb`
  carries `@key` description blocks (the `en` file does not); follow each file's
  own existing convention.
- RWB-20260816-019 (AC6): change `anti_ghost_penalty_noise` in
  `app_vi.arb:58` from `"Gây ồn"` to `"Phát âm thanh"`. Value only — do not
  rename the key and do not touch its `en` value (`"Noise"`).
- Regenerate `mobile/lib/l10n/generated/` (`flutter gen-l10n`, config in
  `mobile/l10n.yaml`) and commit the regenerated files. Never hand-edit them.

## 4. Acceptance Criteria

- The new row is the first child of the Penalty card in States A and B, above
  the `"Penalty"` heading, divider-separated (AC2).
- Row tokens match: 40x40 tile, `radiusSmall`, `colorAmber` at 0.2 alpha
  background, `CupidIcons.timer` glyph at 21px in `colorAmber` (AC2).
- Title/subtitle resolve from the new l10n keys in both locales with no
  hardcoded literals (AC3).
- Toggling the switch and pressing propose issues one `POST /ghost-config`
  whose body carries the chosen `publicCountdown` (AC4).
- `_PenaltyRadioGroup` renders and behaves identically; its existing test passes
  unmodified (AC5).
- `anti_ghost_penalty_noise` `vi` reads `"Phát âm thanh"`; `en` unchanged (AC6).
- `anti_ghost_entry_card.dart` and the home dashboard are untouched (AC8).
- `flutter analyze` is clean.

## 5. Planned Outputs

- Code directories or files: the paths in `Write Scope`
- Contracts or schemas: consumes `../architecture/contract-summary.md`
  sections 1, 3, 4
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter widget tests, `anti_ghost_screen.dart`
- Required levels:
  - unit: N/A — covered by the widget layer below
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks:
  - dark + `vi`: row renders with the amber tile, `Đếm ngược công khai` title
    and `Hiện trên dashboard cả hai` subtitle
  - `en`: `Public countdown` / `Shown on both dashboards`
  - toggle state reflects the seeded `publicCountdown` (assert both `true` and
    `false` seeds)
  - a config JSON served **without** the `publicCountdown` key renders the row
    ON — extend the existing `_configJson` helper with an optional
    `bool? publicCountdown` so the key can be omitted, rather than always
    emitting it
  - propose POST body carries the toggled value, asserted from
    `adapter.requests` (this is the AC4 evidence)
  - `vi` locale renders `Phát âm thanh` for the `noise` penalty option (AC6)
- Mobile discoverability / navigation integration: N/A — AC9, the screen's
  existing entry point is unchanged
- Minimum gates by risk surface:
  - Missing field crashes settings screen: the omitted-key widget test passes
  - Regression in `_PenaltyRadioGroup`: the existing `State A: penalty selector
    exposes single-select radio semantics` test passes **without edits**; if it
    needs editing, stop and report — the edit is itself the AC5 violation
  - l10n keys absent from generated Dart: `flutter analyze` resolves both new
    getters
- Required regression or contract coverage: the full existing
  `anti_ghost_screen_test.dart`, `anti_ghost_cubit_test.dart`, and
  `ghost_config_repository_test.dart` suites pass; the latter two must compile
  unchanged (the defaulted `publicCountdown` parameter is what guarantees this)
- Evidence format: test command + pass/fail summary in
  `coding-plan/test-results.md`
- Requirement mobile visual audit: NO — light theme and `en` visual QA remain
  infra-only per the requirement's Out of Scope
- Verification strategy:
  - Targeted tests: `flutter test test/features/anti_ghosting/` from `mobile/`
  - Build/type-check/lint command: `flutter analyze` from `mobile/`
  - Required assertion evidence: quoted assertions for the `vi` title/subtitle,
    the `en` title/subtitle, the omitted-key default-ON case, and the POST body
    `publicCountdown` value

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-18
