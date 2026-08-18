# STORY-053 Review Report — Anti-Ghosting Public-Countdown Penalty Row

Outcome: CLEAN

Reviewer: Iris-QC
Date: 2026-08-18
Mode: story-review (standard)
Story: `REQ-002_screen_flow_and_design_fidelity_audit/STORY-053_antighost_public_countdown_penalty_hardening`
Rework source: RWB-20260816-018, with RWB-20260816-019 folded in as AC6

## Diff Baseline

`git diff 18df9fa36e02940cfe1a114a87dea52ac8fefc2c..a17b6b3534ad47049139f475438b57fe670f3b75`
(worktree = repo root, inline branch `main`; `18df9fa` is the pre-story commit,
`a17b6b3` the post-implementation HEAD). 18 files, +468/-62.

## Evidence Reproduced Independently

| Gate | Command | Result |
|------|---------|--------|
| Backend unit | `npm test -- ghost-config.service.spec` (from `backend/`) | 20/20 pass, incl. both new `publicCountdown` cases |
| Mobile widget + data | `flutter test test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart test/features/anti_ghosting/data/ghost_config_repository_test.dart` (from `mobile/`) | 31/31 pass |
| Design source | `cupid-app-design-system/project/Cupid Screens.dc.html` lines 562-579 read directly | Row-1 tokens/copy and row-3 `vi` label confirmed |

Backend `npm run build` and full `flutter analyze` were not re-run; relied on
Scrum Master's reproduced evidence plus the P2 phase file's recorded
`flutter analyze lib test` result (0 error, 0 warning, 80 pre-existing `info`).

## Acceptance Criteria Verdicts

### AC1 — backend field on the propose flow: PASS

- `backend/src/modules/ghost-config/entities/ghost-config.entity.ts`:
  `@Column({ type: 'boolean', default: true }) publicCountdown: boolean;`
- `dto/create-ghost-config.dto.ts`: `@IsOptional() @IsBoolean() publicCountdown?: boolean;`
  plus an `@ApiProperty({ required: false })` — matches
  `architecture/contract-summary.md` §2 exactly.
- `ghost-config.service.ts:42`: `publicCountdown: dto.publicCountdown ?? true`
  inside the existing `create()`. No new endpoint, no new mutation path, no
  migration file (correct — `synchronize: true`, per contract §6).
- Read of the whole service confirms no method uses TypeORM `select:` or hand-
  shapes a response object, so `POST`, `GET /ghost-config`,
  `GET /ghost-config/pending`, `PATCH .../approve` and `.../reject` all return
  the full entity and therefore gain the key. `getStormStatus` still returns
  `{eligible, penalty}` only — correctly unchanged per contract §3.

### AC2 — first row of the Penalty card, vi/dark, design-source tokens: PASS

- Rendered as the literal first child of the Penalty `_SettingsCard` column in
  both editable State A (`_ProposeFormState.build`) and disabled State B
  (`_PendingMineBody`), followed by `Divider(height: 1, thickness: 1, color:
  colors.colorLine)` + `SizedBox(height: CupidSpacing.sm)` and only then the
  existing `anti_ghost_penalty_label` heading — the placement `ux/uiux-spec.md`
  §1 mandated.
- Tokens in `_PublicCountdownRow`
  (`mobile/lib/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart`):
  `_penaltyTileSize` (40) square, `context.cupidPlatform.radiusSmall` radius,
  `colors.colorAmber.withValues(alpha: 0.2)` fill, `CupidIcons.timer` at
  `_penaltyGlyphSize` (21) in `colors.colorAmber`. Byte-for-byte the mock's
  `40px/14px radius/rgba(255,201,126,.2)/timer/var(--amber)/21px` (line 564).
- vi copy `Đếm ngược công khai` / `Hiện trên dashboard cả hai` matches the
  design source's `data-vi` spans (line 565) character for character.
- Switch fill reflects the persisted value (`gradientHot` on / `colorLine` off).
- Covered by `AC2/AC3 (dark + vi)` (ordering asserted by `getTopLeft().dy`
  against the `Hình phạt` heading; amber tile asserted unique in the tree) and
  `AC2 (State B)` (off-state fill + `onTap` is null).

### AC3 — `en` copy from l10n keys: PASS

- `app_en.arb` gains `anti_ghost_public_countdown_title` = `"Public countdown"`
  and `anti_ghost_public_countdown_subtitle` = `"Shown on both dashboards"`;
  `app_vi.arb` gains both with `@`-descriptions. Naming follows `ux/uiux-spec.md`
  §6 and correctly avoids the `anti_ghost_penalty_*` prefix.
- The widget reads `l10n.anti_ghost_public_countdown_title` /
  `..._subtitle` — no hardcoded literals anywhere in `_PublicCountdownRow`.
- `mobile/lib/l10n/generated/` is gitignored (`mobile/.gitignore:41`) and
  regenerated at build time, so there is no stale committed artifact to drift.
- Covered by `AC3 (en)`.

### AC4 — goes through propose → partner approval, never unilateral: PASS

- The toggle mutates only local `_ProposeFormState._publicCountdown` via
  `setState`; nothing is sent until the CTA fires
  `widget.onSubmit(_effectiveMinutes, _penalty, _publicCountdown)` →
  `AntiGhostCubit.propose(...)` → `GhostConfigRepository.propose(...)` →
  `POST /ghost-config`, which the backend persists as
  `ConfigStatus.PENDING_APPROVAL`. Identical path to `timeoutMinutes`/`penalty`.
- State B passes `onChanged: null`, which drives `enabled == false` and a null
  `GestureDetector.onTap`, so a pending row cannot be re-toggled in place.
- No self-approve/instant-apply path was introduced.
- Covered by `AC4` (exactly one POST, `publicCountdown: false` in the body).

### AC5 — `_PenaltyRadioGroup` and the `Penalty` contract untouched: PASS (negative requirement verified)

Filtered the screen-file diff for every added/removed line mentioning
`penalt`/`Penalty`. The only hits are:

- the `_ProposeForm.onSubmit` typedef gaining a third parameter
  (`final void Function(int minutes, Penalty penalty, bool publicCountdown)`)
  and its two call sites — this is the enclosing form's callback, not the radio
  group's;
- the new widget's own doc comment and its reuse of the shared
  `_penaltyTileSize` / `_penaltyGlyphSize` constants.

No line inside `class _PenaltyRadioGroup` (line 791) or `class _PenaltyIconTile`
(line 858) changed. The `Penalty` enum, its wire values, the backend `penalty`
column and its DTO validator are all untouched. `publicCountdown` is a separate
`bool` field and never a fourth radio option.

### AC6 — RWB-019 `vi` string fix: PASS

`app_vi.arb`: `"anti_ghost_penalty_noise": "Gây ồn"` → `"Phát âm thanh"`.
Key name unchanged, `@`-description unchanged, `app_en.arb`'s `"Noise"`
untouched (correct — RWB-019 does not flag `en`, and the design source's `en`
label is `Sound override`, deliberately not re-litigated here). Design source
line 577 `data-vi` confirms `Phát âm thanh`. Covered by `AC6 (vi)`, which
asserts both the new string's presence and the old string's absence.

### AC7 — test coverage both lanes: PASS

- Mobile: six new `testWidgets` cases covering dark+vi tokens/copy/ordering,
  `en` copy, State B off + non-interactive, the contract §4 nullable-tolerant
  read (key omitted → renders ON), the propose-body assertion, and the AC6
  string. The pre-existing gradient-token test was correctly tightened from
  value-equality to `identical()` exclusion, because the new pill and the
  selected threshold segment are now value-equal `BoxDecoration`s — a real
  latent false-negative the story author caught rather than papered over.
- Backend: two new `create()` cases (explicit `false` passthrough, omitted →
  `true`).
- Both suites reproduced green above.

### AC8 — dashboard untouched, field not yet consumed: PASS

`anti_ghost_entry_card.dart` and every home-dashboard file are absent from the
diff's 18-file list. `publicCountdown` is persisted and settable but read by
nothing outside the settings row. Matches `## Out of Scope`.

### AC9 — no new entry point: PASS

No router, navigation, or shell file appears in the diff.

## Findings

None at PATCH_REQUIRED or BLOCKED severity.

## Deferred Observations (no action required this story)

- **DEF-1 — switch pill is 54x32/26px knob vs the mock's 52x31/25px.** This is a
  verbatim reuse of the app's existing `_ConsentSwitch` recipe
  (`mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart:396-427`),
  which `ux/uiux-spec.md` §2 explicitly directed ("reuse that visual recipe
  rather than a native Material `Switch`"). Matching the mock's 2px instead
  would break the in-app convention. Correct call as made.
- **DEF-2 — tile-to-text gap is `CupidSpacing.md` (16) vs the mock's 13px, and
  row padding is `CupidSpacing.xs` (4) vs the mock's `14px 0`.** Both are
  spec-directed (§2). The `xs` choice is notably well-reasoned: it is the exact
  value `_PenaltyRadioGroup`'s `RadioListTile.contentPadding` already uses
  (line 835), which is the row-height parity §2 asked for instead of the mock's
  literal number.
- **DEF-3 — mock's subtitle carries `margin-top:2px`; the implementation's
  `Column` has no explicit gap.** Sub-visual, not enumerated in any AC.

## Residual Risks

- **RR-1 (product-level, for Product Owner triage — not a defect here).** States
  C/D (`_PendingPartnerBody`, `_ActiveSummaryBody`) render condensed summaries
  built from `anti_ghost_accept_semantic_label(minutes, penalty)` and
  `anti_ghost_active_summary(minutes, penalty)`, which carry two values only.
  The approving partner therefore accepts a config without ever seeing the
  proposed `publicCountdown` value. This does not violate AC4 (approval still
  gates the change) and `ux/uiux-spec.md` §3 State C ruled it out deliberately,
  flagging that closing it needs new l10n keys/parameters outside PO's In Scope
  list. Recommend Scrum Master log it as a candidate rework item rather than
  leaving it only in the UX spec's prose.
- **RR-2 — no rendered visual evidence.** Fidelity is verified by token
  assertions and source-to-mock comparison, not screenshots. `ux/uiux-spec.md`
  §2 explicitly deferred "no visible seam at the divider" to visual QA at
  implementation time; `RadioListTile` adds its own `ListTile` min-height
  metrics on top of the shared `xs` padding, so the new row and the radio rows
  are padding-identical but not necessarily pixel-identical in height. Low
  impact, consistent with every prior REQ-002 story on this screen.

## Out-of-Scope Edit Review

`mobile/test/features/anti_ghosting/data/ghost_config_repository_test.dart` sits
outside phase P2's declared Write Scope; the deviation is disclosed in
`coding-plan/phase-P2-mobile-public-countdown-row.md` §7. Verified directly: the
change is the expected map literal gaining `'publicCountdown': true` plus a test
rename. The assertion remains exact-map-equality on the POST body — it was not
loosened to a subset matcher, and no production-asserted behavior changed.
Accepted, no action.

## Conclusion

All nine acceptance criteria pass, including AC5's negative requirement and
AC6's RWB-20260816-019 fold-in. Backend and mobile evidence reproduced
independently. Story is approved for `DONE`.
