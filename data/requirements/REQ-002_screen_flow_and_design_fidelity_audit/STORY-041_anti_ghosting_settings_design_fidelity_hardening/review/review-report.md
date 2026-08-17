# STORY-041 Review Report — Anti-Ghosting Settings Design Fidelity Hardening

Outcome: DEFERRED_ONLY

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-041 (RWB-20260816-008 hardening of STORY-022)
- Review type: `compact-story-review`
- Reviewer: Iris-QC
- Date: 2026-08-17
- Worktree: `/Users/alantravala/workspace/snapsofts/cupid-apps`
- Branch: `main` · BaseHead: `e1e6f015669dbedd244ef1a4dda850cbf7a3c865`
- Complexity: `trivial` · Implementation Lane: `mobile` · Retro-Type: RED-PATCH

## Scope Gate

Phase: SCOPE_GATE — inline (compact review, no separate `scope-gate.md`).

Source files in scope (1): `mobile/lib/main_preview.dart`. Confirmed from
`git diff --name-only <BaseHead>` — the only `mobile/` path in the diff.
`anti_ghost_screen.dart` is **not** in the diff, as the handoff states.

Evidence in scope: `visual-fidelity/visual-fidelity-report.md` and its three
PNGs. Read-only corroboration: `anti_ghost_entry_card.dart:128-155` (AC7).

Query keys: `PREVIEW_ANTIGHOST`, `_PreviewGhostConfigRepository`,
`_TimeoutSegment`, `Tuỳ chỉnh`, `Đếm ngược công khai`, `RWB-20260816-018`.

Risk surfaces: mobile interaction, mobile navigation/discoverability. Not
touched: persistence, schema, backend, l10n, auth, config, entry point.

The three other diff entries (`req_master.md`, `rework-backlog.md`,
`scrum-master-checkpoint.md`) are Scrum Master-owned workflow state, excluded.

## Acceptance criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| 1 | PASS with deferral | Real rendered-to-rendered pair, correct screen both sides. All visible deltas fall into disclosed/tracked buckets except RV-1 below. |
| 2 | PASS | F-01..F-10 re-confirmed against the pixels; see below. |
| 3 | PASS | Verified myself in both captures — no truncation. See below. |
| 4 | PASS | D-05 confirmed still absent from the app render and untouched; `RWB-20260816-018` present in `rework-backlog.md`. No backend/persistence/l10n path in the diff. |
| 5 | PASS with deferral | O-1 judgment accepted (see below). One further undisclosed delta found by my own read of the images — RV-1 below, l10n-blocked, not fixable in this story. |
| 6 | PASS | `VISUAL_FIDELITY: PASS` on line 1. The `## Verdict Scope` section explicitly bounds what PASS claims and enumerates what remains open — correct framing for a hardening story, not an overclaim. |
| 7 | PASS | `anti_ghost_entry_card.dart:140-142` still pushes `AntiGhostScreen` via `MaterialPageRoute`, unchanged. Discoverability independently corroborated by the passing `tapping the card from HomeScreen pushes AntiGhostScreen` test in the run below. |

## Gates independently rerun

| Gate | Result |
| --- | --- |
| `flutter test test/features/anti_ghosting` | `+63: All tests passed!`, exit 0. Matches the claimed 63. |
| `flutter analyze lib/main_preview.dart` | `No issues found!`, exit 0. Matches the claim. |
| Diff containment | `+77 / -0`, additions only. The fixture is gated behind `String.fromEnvironment('PREVIEW_ANTIGHOST')` and fires only for exactly `state-a`/`state-b`, so omitting the define leaves live behaviour byte-identical. It lives in the dev-only preview entrypoint and is unreachable from the shipped app. |
| Design screen identity | `Design-Screen: antighost`. The reference PNG unambiguously depicts the Anti-Ghosting screen (title, threshold picker, penalty card) — it is this story's screen, not a plausible-looking neighbour. |

## AC2 — F-01..F-10 against the pixels

Checked by reading the images, not by trusting the table.

F-01 gutter alignment, F-02 hero card present, F-04 card surface fill/radius,
F-07 three distinct type levels, F-09 equal inter-card gaps — all confirmed
visually against the reference.

**F-03 (emphasis target) — CONFIRMED.** The app renders a genuine single pill
track with inset segments and the selected segment carrying the hot pink
gradient pill. The design draws the same construct. This is structurally a
segmented control, not the `ChoiceChip` row STORY-022 replaced.

**F-06 (emphasis target) — CONFIRMED.** Per row: 40x40 rounded icon tile, label
in the design's label style, hairline divider between rows, selection control at
the trailing edge. `Emoji Storm`'s tile carries the peach/amber tint against
neutral tiles for the others, matching the canvas. Tile geometry, glyph size,
divider placement and trailing alignment all read as the same design.

Minor accuracy note, not a finding: the report says the canvas has Emoji Storm
as "the only tinted tile". The canvas actually tints two — `Đếm ngược công khai`
(amber) as well. Since that row is absent from the app entirely (D-05), the
comparison still holds for every row that exists; the wording is imprecise, the
verdict is not.

F-05 (three distinct radii) and F-08 (badge hugs content at the start edge, does
not span the card — confirmed in State B) both hold. F-10 is confirmed only
indirectly, as the report itself admits; acceptable, since an ink regression
would surface as a mismatched row background and none is present.

## AC3 (R-2) — narrow-width truncation

Verified independently, and the claim is correct. At 360dp all four segments —
`5 phút`, `10 phút`, `15 phút`, `Tuỳ chỉnh` — render complete in the State A
capture, with full diacritics and no ellipsis or clipped glyph, including on the
app-only fourth segment that created the risk. Re-confirmed in the State B
capture, where the selection sits on `10 phút` instead. `R-2 resolves as
no-defect, no code fix required` is the right call, and it is now backed by the
capture the widget test's 800x600 viewport could never produce.

## AC5 — O-1 judgment, assessed independently

**O-1 (app-added `Hình phạt` section heading): accepted, not a defect.**
The reasoning holds. The app's radio-group divergence is already an accepted
STORY-022 decision, and a radio group needs an accessible name — corroborated
here by the passing `State A: penalty selector exposes single-select radio
semantics` test in the suite I ran. The design's card can omit a heading because
its rows are independent toggles each carrying a descriptive subtitle; those
subtitles are D-03, deferred and l10n-blocked, so in the app the heading is
currently the only thing naming the group.

One qualification the report does not raise: the accessible name could
technically be supplied by an invisible `Semantics(label:)` instead, preserving
the design's headingless card. I do not think that is preferable — a visible
group label serves sighted users too, and with D-03 deferred the app would
otherwise present three unexplained rows under no heading at all. No fix
warranted. Flagging the judgment openly, as the implementer asked, was the right
call rather than burying it.

## Deferred findings

**RV-1 (new, reviewer-found) — sound-penalty row label differs from the design and is not disclosed anywhere in the report.**
Named `RV-1` to avoid colliding with the story's existing `R-1` (light-theme
contrast, OQ5-blocked), which is a different, already-tracked item.
The design's third penalty row reads `Phát âm thanh`; the app's corresponding
row reads `Gây ồn`. Same glyph, same position, different words. The report's
`Pre-Tracked Deltas` table covers D-01/D-02/D-03/D-05/R-1/R-3, and D-03 covers
row *subtitles* — nothing covers the row *label*. This is a real visible textual
delta under an AC1 that asks for no visible deviation. Its disposition is
nevertheless defer, not patch: the string lives in `mobile/lib/l10n/arb/`, which
is outside this story's WriteScope and is the same blocker class as
D-01/D-02/D-03, so the story could not have fixed it without breaching AC4's
sibling constraint. Pre-existing, not made worse here. Recommend Scrum Master
track it alongside the other l10n-blocked deltas so a future l10n-scoped story
picks it up.

Note, not a finding: the app's third row `Không` (none) has no design
counterpart, but that is an inherent consequence of the already-accepted
radio-group divergence — a mutually-exclusive group needs an explicit none
option, a set of independent toggles does not.

Carried forward unchanged, no action: R-1 light-theme contrast (OQ5-blocked, not
exercised by a dark capture) and R-3 disabled-state gradient (confirmed in State
B exactly as dispositioned).

## Rationale

The story delivers what RWB-20260816-008 asked for. STORY-022 evidenced this
screen's fidelity purely by token-level widget assertions and said so plainly;
that gap is now closed with real captures, and the two AC-bearing controls
called out as emphasis targets (F-03, F-06) both hold up under actual pixels.

Two things raise confidence. The two-capture approach is justified rather than
padded — `AntiGhostCubit.load()` maps an unauthenticated fetch to
`AntiGhostLoadFailed`, so without an authored fixture *none* of F-03, F-06 or
F-08 would appear in any capture at all; State B is what makes F-08 and R-3
checkable. And the `## Verdict Scope` section bounds the PASS honestly up front
("STORY-022's fidelity claims are now visually evidenced", not "no design delta
remains") instead of letting a bare token imply more than was checked.

Production code was correctly left alone. For a fidelity-hardening story, no
change to `anti_ghost_screen.dart` is the right outcome when the render surfaces
no defect — AC3 was a real check that could have forced a fix and did not.

Outcome is `DEFERRED_ONLY` rather than `CLEAN` solely because of RV-1.

## State recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE`.
- Scrum Master to track RV-1 with the other l10n-blocked deltas before closure.
