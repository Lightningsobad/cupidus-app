# Review Report — REQ-010 / STORY-001 Anti-Ghost Alert Banner Design Fidelity

Outcome: PATCH_REQUIRED

Reviewer: Iris-QC
Mode: compact-story-review
Flow: parallel-story
Date: 2026-08-25
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-010_home_dashboard_deferred_scope_completion-STORY-001`
Branch: `codex/REQ-010_home_dashboard_deferred_scope_completion-STORY-001`
BaseHead: `8fdabddb6f5f59b6f5b3fa1f8860992095c7a338`
Worktree HEAD at review: `af0061db27e30188e75b8e1a0f520dd49d2970f4`

Implementation code is CLEAN and every claimed gate was independently
reproduced by the Reviewer. The single blocking finding is a missing DONE-gate
evidence section in `story_master.md`, not a code defect.

## Diff scope confirmed

`git -C <Worktree> diff 8fdabdd --stat` matches the implementer's declared file
list exactly — no undeclared code changes:

| File | Change |
| --- | --- |
| `mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart` | +54 -52 |
| `mobile/lib/design_system/icons/cupid_icons.dart` | +10 -0 |
| `mobile/test/features/anti_ghosting/presentation/anti_ghost_entry_card_test.dart` | +65 -0 |
| `.../coding-plan/test-results.md` | +102 (evidence) |
| `.../visual-fidelity/visual-fidelity-report.md` | +122 (evidence) |
| `.../visual-fidelity/*.png` | 2 captures (evidence) |
| `.../story_master.md` | +2 -1 (`Design-Screen: home`, Implementation checkbox) |

Working tree clean. No stray edits outside the story's write scope.

## Acceptance criteria

- **AC1 — banner matches the design source (layout/spacing/colour/typography/copy):**
  MET. All ten UX-spec deviations are dispositioned: D1-D9 corrected in code,
  D10 (`wiggle` motion) correctly NOT added per the spec's own out-of-scope
  ruling. Verified line-by-line in the diff and confirmed visually against
  `visual-fidelity/design-reference-home-android.png`.
- **AC2 — deviations corrected in the app, not merely documented, and
  re-verified:** MET. Changes are real app-code changes, pinned by a new widget
  test and re-verified by an on-device capture.
- **AC3 — tap behaviour unchanged, no new entry point:** MET. `onTap` still
  builds `MaterialPageRoute(builder: (_) => const AntiGhostScreen())`; the
  design source's `goChat` binding was deliberately not adopted per
  `ux/uiux-spec.md` §3. `AntiGhostCubit` / `_copyFor` lifecycle logic is
  untouched (the `_CardCopy` → `_subtitleFor` refactor drops only the
  now-unused `isPending` flag; every lifecycle branch returns the same string as
  before). Regression-covered by two pre-existing tests, both passing.

## Independent verification performed

The Reviewer re-ran every claimed gate rather than accepting the report.

| Gate | Claimed | Reviewer re-run | Verdict |
| --- | --- | --- | --- |
| Static analysis (`flutter analyze lib/features/anti_ghosting lib/design_system/icons test/features/anti_ghosting`) | 7 pre-existing infos, zero new | `7 issues found` — all `prefer_initializing_formals`, all in `ghost_config_repository.dart` / `anti_ghost_cubit.dart` / `ghost_storm_cubit.dart`, none in a changed file | CONFIRMED |
| Targeted tests | `+9 All tests passed` | `00:01 +9: All tests passed!` | CONFIRMED |
| Regression sweep (`anti_ghosting`, `home`, chat ghost-row mount, `design_system`) | `+168 All tests passed` | `00:29 +168: All tests passed!` | CONFIRMED |
| Visual fidelity | PASS | Both PNGs opened and inspected — see below | CONFIRMED |

### Icon codepoint gate (`ux/uiux-spec.md` §2) — independently re-verified

The spec's one hard constraint was "do not invent a codepoint". The Reviewer
re-ran the cmap check against
`mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` with `fontTools`:

```
sentiment_dissatisfied gid 6351 codepoints ['0xe811']
sentiment_neutral      gid 6355 codepoints ['0xe812']
sentiment_very_dissatisfied gid 6357 codepoints ['0xe814']
0xe811 -> sentiment_dissatisfied
```

This matches the doc comment on `CupidIcons.sentimentDissatisfied` exactly,
including the gid and the two neighbouring glyphs it warns against. Fix-path
step 2 was correctly taken; no codepoint was invented. `CupidIcons.chevronRight`
used for D9 is pre-existing (already consumed by `VibeEntryCard`).

### Capture integrity — the splash-frame trap was avoided

`implemented-home-emulator-5554.png` was opened and is a genuine, fully
populated Home dashboard (day counter, anti-ghost banner, Vibe/alarm/pet/wallet
cards, bottom nav) — not a Flutter splash frame. The rendered banner shows the
amber wash, amber hairline border, amber tile with the concerned-face glyph,
amber bold "Anti-Ghosting" title, muted `vi` subtitle "Đang chờ đối phương xác
nhận", and the trailing chevron, with no secondary timer badge. The report's
disclosure that a first 16399-byte splash capture was rejected and re-taken with
a uniquely-named script is credible and matches the accepted artifact.

### D11 (typography) — scope addition, justified and verified

D11 was not in the UX spec's §1 table; the implementer changed the title from
`type.cardTitle` (22px/w600) to `type.body` + `w800` (17px) and the subtitle
from `type.body` (17px) to `type.caption` (13px). The Reviewer verified both the
token values in `mobile/lib/design_system/tokens/cupid_typography_tokens.dart`
and the claimed precedent: `mobile/lib/features/vibes/presentation/widgets/vibe_entry_card.dart:59-77`
uses precisely `body.copyWith(fontWeight: FontWeight.w800)` + `caption` +
`SizedBox(width: CupidSpacing.sm)` + `chevronRight` in `colorTextMuted`.

The change is therefore an alignment with an established sibling-card
convention on the same screen, it is materially closer to the design's
14.5px/800 + 12px, and AC1 explicitly puts typography in scope. Accepted, not a
finding.

## Findings

### F1 — BLOCKING (non-code): `story_master.md` is missing the DONE-gate evidence sections

`story_master.md` declares `System Integration And Discoverability` with
`UI-facing story: YES`, but carries neither a `## Story Runtime Startup Smoke`
section with a `Result:` line nor an `## Entry Point Reachability` section with
a `Reachable:` line. Both are enforced by the story DONE gate for UI-facing
stories — the same omission was raised as blocking finding `F2` on
`data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/story_master.md`
and required a dedicated patch cycle plus two follow-up commits to clear.

Left as-is, Scrum Master's DONE transition will reject this story despite a
fully clean implementation.

The underlying facts are already proven — only the documented sections are
absent, so this is a documentation patch, not new verification work:

- Runtime startup smoke: the app was launched on Android emulator
  `emulator-5554` via `flutter run -t lib/main_preview.dart` and the Home
  dashboard rendered (`MOBILE_CAPTURE: OK ... 405x900 171096`).
- Entry point reachability: `AntiGhostEntryCard` is already mounted on
  `HomeScreen`, is visible in the accepted capture, and the passing test
  `tapping the card from HomeScreen pushes AntiGhostScreen` proves the tap
  reaches `AntiGhostScreen`.

Owner: mobile-dev (or Scrum Master, which owns `story_master.md` state).
Fix: add the two sections with the evidence above. No code change required.

Implementation checkbox recommendation: `KEEP_CHECKED` — every code gate
passes and was independently reproduced; this is an artifact-completeness gap,
not a rework of the implementation.

### F2 — NON-BLOCKING (metadata): Story-Class disagreement

`story_master.md` records `Complexity: trivial` / `Story-Class: trivial`, while
the review handoff declares `Story-Class: standard`. Harmless for this story's
outcome, but worth reconciling so the scheduler and the story artifact agree.

## Residual risks (accepted, all pre-dispositioned — none blocking)

1. **Copy divergence.** Design renders `{{ghostAlertTitle}}`/`{{ghostAlertBody}}`
   ("Seen 5 phút rồi đấy" / "Trả lời đi không là bị bắn Storm nha"); the app
   keeps the shipped `l10n.anti_ghost_*` lifecycle strings. Ruled out of scope
   by `ux/uiux-spec.md` §1 and permitted by the story's own "or equivalent"
   wording.
2. **Leading tile size.** 48px (`cupidPlatform.tapTarget`) vs the design's 42px.
   Keeping the platform token is correct — 42px would fall below the Material
   minimum tap target.
3. **`wiggle` motion (D10).** Absent by design; dispositioned to STORY-017 `F1`
   ("motion is not a static-fidelity concern").
4. **Typography approximation.** Title 17px vs design 14.5px, subtitle 13px vs
   design 12px. Consistent with the repo's documented token-rounding convention
   and with the sibling `VibeEntryCard`; the `caption` token's own doc comment
   warns against re-pointing the token for a single 12px consumer.
5. **Uniform amber chrome across all lifecycle states.** Intentional per
   `ux/uiux-spec.md` §3 — the design draws one persistent amber banner and
   lifecycle is now carried entirely by title/subtitle copy, so no accessibility
   regression from colour-only signalling.

## Verdict

Outcome: PATCH_REQUIRED

One blocking finding (F1), documentation-only, in `story_master.md`. The
implementation, tests, static analysis, icon-codepoint sourcing, and visual
fidelity are all CLEAN and independently reproduced. Once F1's two sections are
added, this story is ready for a fast re-review and merge with no code change.
