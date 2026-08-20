# Review Report: STORY-061 Dream Jar List (`jarlist`) Design Fidelity Hardening

Outcome: DEFERRED_ONLY

- Review type: `full-story-review` (Round 3 — final)
- Scope gate: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-061_dream_jar_list_design_fidelity_hardening/review/scope-gate.md`
- Reviewer: Iris-QC
- Date: 2026-08-20
- Worktree: `/Users/alantravala/workspace/snapsofts/cupid-apps` (branch `main`)
- BaseHead: `970784cad0f33dde24e561d2036e2896995ec593`
- Blocking findings: 0
- Deferred findings: 5 (D1-D5, unchanged since Round 1)

## Round history

| Round | Outcome | Blocking findings | Disposition |
|---|---|---|---|
| Round 1 | `PATCH_REQUIRED` | B1 (no visual-fidelity report / no `Design-Screen`), B2 (no `## Entry Point Reachability`), B3 (no `## Story Runtime Startup Smoke`), B4 (AC10 disposition inaccurate; B4a record, B4b duplicate-entry decision) | All four closed in Round 2 |
| Round 2 | `PATCH_REQUIRED` | B5 (`VISUAL_FIDELITY: PASS_WITH_DELTAS` not a contract token), B6 (report falsely claimed no `design-fidelity-config.json` exists) | Both closed in Round 3 |
| Round 3 | `DEFERRED_ONLY` | none | Story is approvable |

No implementation code changed across any round.
`git diff --stat <BaseHead> -- mobile/` is byte-identical in all three rounds
(12 files, 1106 insertions / 280 deletions), so every Round 1 code verdict stands
unmodified and no source file was re-read after Round 1.

## Round 3 verification (two lines, as scoped)

### B5 — CLOSED

`visual-fidelity/visual-fidelity-report.md:3` now reads `VISUAL_FIDELITY: PASS`,
which is one of the two values rule 12e2/12e3 defines. The adjudication note at
`:5-14` cites the Round 2 ruling correctly and, importantly, does not overclaim:
it states explicitly that a `PASS` verdict records that no delta blocks an AC and
"does not retract any delta or close the follow-ups D2 and D4 raise". That is the
right reading and it protects the deltas from being read as resolved later.

`## Recorded deltas` was not re-read this round — it was verified verbatim in
Round 2 and the report's own `:11-12` attests it is unchanged and unrenumbered.

Token propagation is consistent: `story_master.md:142-143` now also reads
`VISUAL_FIDELITY: PASS`. Verified directly rather than taken on report — the two
artifacts agree, so no automated gate can read contradictory values.

### B6 — CLOSED

`visual-fidelity/visual-fidelity-report.md:34-56` now cites
`data/devops/system/design-fidelity-config.json` directly, quotes its pinned
`design_source.entry` (`Cupid App.dc.html`), `location`
(`cupid-app-design-system`), and `project_dir` (`cupid-app-design-system/project`),
and notes that the by-elimination resolution independently landed on the same
pinned entry. The false no-config claim is retracted explicitly at `:41-45`
rather than quietly deleted, which is the better outcome for a future reader.

The `--location` drift is now described accurately at `:47-56`: the `*.dc.html`
files have moved out of `project/` up to the bundle root, so the config's
`project_dir` no longer resolves while the bundle root does. It is tied to D5 as
the tracking item and is no longer restated as an absent config. The report also
records that the drift did not change which screen was rendered — correct, and
the reason the AC9 evidence remains valid.

The useful `Cupid Screens.dc.html` discrimination narrative was kept.

### `hide_selectors` — confirmed

The new `### hide_selectors` subsection at `:58-71` records `Applied: YES` by
inspecting the committed reference capture: no screen-index FAB appears anywhere
in `design-reference-jarlist-ready-emulator-5560.png`, so the config's
`[data-plat] [style*="z-index: 95"]` suppression took effect and no
prototype-navigation control could have skewed the corner-level comparison. This
matches my own Round 2 observation of that image independently.

`:73-75` states precisely that this is an attestation about the committed image,
verified by looking at it, not a re-execution of the render. That distinction is
accurate and is exactly how the mobile lane is supposed to work under rule 12e3
(implementer captures, reviewer verifies; no re-capture in a rework pass).

## AC-by-AC verdict (final)

| AC | Verdict | Basis |
|---|---|---|
| AC1 | PASS | Summary pill renders the full-width pill with leading circular savings badge; amount `7.150.000₫` and count `3 cái hũ` match the reference, and the total correctly counts active jars only. Delta D3 sits inside the tolerance `ux/uiux-spec.md:63-65` grants and at (not over) the 2-line wrap budget at `:71-72`. |
| AC2 | PASS | Both required elements present on every card — leading illustration thumbnail plus a glyph immediately before the jar name. Deltas D1/D2 govern their rendering and are pre-approved by `architecture/solution.md:187-192` selecting UX option (b). |
| AC3 | PASS | `_jarDeadlineFormat = DateFormat('dd/MM/yyyy')`; `30/09/2026`, `14/02/2027`, `01/06/2027` match the reference in value and right-aligned placement. |
| AC4 | PASS | 2dp `colorAccentPink` border ring plus a tinted `Đang xem` chip with `CupidIcons.checkCircle` on its own row, matching `ux/uiux-spec.md:181-192` including the no-top-right-badge rule. Delta D4 is the absent secondary fill differentiation — deferred, not AC-blocking. |
| AC5 | PASS | `_CompletedJarsRow` renders `Hũ đã hoàn thành`, the `2 cái · Tai nghe cho Linh, Sinh nhật Minh` subtitle, and a trailing chevron; on-device evidence now exists, closing the P1 widget-test-only gap. |
| AC6 | PASS | Header title is exactly `Các hũ ước mơ`; the old `Hũ Ước Mơ` is gone from `app_vi.arb` and from the capture. |
| AC7 | PASS | Full-width gradient CTA reads `+ Tạo hũ mới` with the plus as `leadingIcon: CupidIcons.add`; the English noun `Dream Jar` no longer appears in the `vi` build. |
| AC8 | PASS | `app_shell.dart` drives one ordered `List<_ShellDestination>`; both tab bars read `Nhà · Trò chuyện · Pet · Ví chung · Tôi` with `Ví chung` active at index 3. Gallery tab, `_galleryTabIcon`, `_openAccountHub`, and the account `FloatingActionButton` are removed. Preview shell mirrors the same shape, which is what lets AC9 evidence it. |
| AC9 | PASS | Was FAIL in Rounds 1 and 2. `visual-fidelity/visual-fidelity-report.md` records `Design-Screen: jarlist`, the resolution command, the config-pinned entry, the evidence pair, the single compared state, a per-AC table, four honestly recorded deltas, and the row-8 out-of-scope note. The by-content confirmation AC9 demands is performed properly — the rendered reference is verified to depict a Dream Jar collection (jar cards with progress bars, the create CTA, the completed row, `Ví chung` active), not merely a screen whose id reads `jarlist`. |
| AC10 | PASS | Was FAIL in Round 1. `story_master.md:109-120` and `coding-plan/test-results.md:287-302` record both post-P2 framings: the `Ví chung` shell-tab body, where nothing can be popped and the absent chevron is correct, and the surviving `MaterialPageRoute` push from `HomeScreen`'s `DreamJarEntryCard`, where DEF-3's original condition is intact. The still-open duplicate-entry question is tracked under `architecture/solution.md` `### Decision B4b` rather than presupposed. AC10 is documentation-only and its documentation is now accurate. |

## Critical gates

| Gate | Rule | Verdict | Evidence |
|---|---|---|---|
| Mobile build | 12e0 | PASS | `flutter build apk --debug`, both phases |
| Static analysis | 12e0 | PASS | zero issues in touched files |
| Targeted + full regression | 12e0 | PASS | 1335 passed / 2 skipped / 0 failed |
| Entry-point reachability | 12e1 | PASS | `coding-plan/test-results.md:459-491`, `Reachable: YES`, three paths — independently verified in code in Round 1 |
| Rendered design fidelity | 12e2 / 12e3 | PASS | `visual-fidelity/visual-fidelity-report.md`, `VISUAL_FIDELITY: PASS`, `Design-Screen: jarlist` resolved against the locked config, evidence pair verified by opening the images (not re-captured) |
| Runtime startup smoke | 12g | PASS | `coding-plan/test-results.md:407-457` — production entrypoint launched on `emulator-5560`: `Status: ok`, `LaunchState: COLD`, `TotalTime: 2077`ms, `ResumedActivity` confirmed, logcat clean |

## RED-PATCH closure

This story exists because `jarlist`'s fidelity deviations were passed over
silently (RWB-20260816-029, from STORY-059's DEF-2/DEF-3). The pattern is not
reproduced here: all four residual deltas are named, quantified, attributed to a
pre-implementation approval, and left open where they are genuinely open. AC9's
by-content verification and the retained delta list are what make this a real
RED-PATCH closure rather than a restatement of capability criteria.

Two PO-authorized scope decisions were verified as implemented, not assumed:
Decision 1 (Gallery entry-point relocation) genuinely preserves reachability —
`home_screen.dart:210-217` pushes `const GalleryScreen()`, so removing the Gallery
tab does not orphan the shipped epic-4 feature; Decision 2 (AC10 wording
correction) matches the code.

The `app_en.arb` change flagged in the handoff is **not a defect**: `en` is a real
locale that stays fully built, gated for exposure only by
`CupidFeatureFlags.enableEnLocale` (`bool.fromEnvironment`, `defaultValue: false`),
so real English values there are correct.

## Deferred findings (D1-D5)

None blocks approval. Carried forward exactly as Round 1 disposed them.

| ID | Summary | Owner | Disposition |
|---|---|---|---|
| D1 | Jar thumbnail is a tinted circular avatar with `CupidIcons.savings`, not the reference's per-jar jar silhouette (AC2) | follow-up story | `architecture/solution.md:187-192` selected UX option (b) before implementation, on the ground that `DreamJarIllustration` holds two `AnimationController`s per instance and one per card in a scrolling list is not affordable for a decorative thumbnail. Closing it needs a new static painter — out of budget for a hardening pass. |
| D2 | The `savings` glyph renders twice per card and identically across all cards (AC2) | follow-up decision | A direct consequence of two deliberate guardrails: `DreamJar` has no category/type/icon field so per-jar glyphs cannot be data-driven (and name-sniffing is explicitly forbidden), and no new `IconData` codepoint may be added. `ux/uiux-spec.md:145-147` pre-named `CupidIcons.favorite` as the fallback if the result read as repetitive; it does. An existing cmap-confirmed icon, so adopting it would not breach the guardrail. |
| D3 | Summary pill amount unbolded and wraps to two lines (AC1) | none | Within approved tolerance on both counts (`ux/uiux-spec.md:63-65`, `:71-72`). Content and format match the reference, which is what AC1 asks for. |
| D4 | Active card has the border ring but no fill differentiation (AC4) | follow-up decision | Partial gap versus `ux/uiux-spec.md:181-185`, which asks for the ring as primary signal *plus* "a very subtle differentiation in fill" while forbidding a second background token. The reference's own fill overshoots what the spec sanctions, so the follow-up must decide which to converge toward. AC4 passes on the ring plus the tinted chip. |
| D5 | Design-source directory drift — `*.dc.html` files sit at the bundle root, not the config's pinned `project_dir` | **Scrum Master** | Repo hygiene, outside this story. Should be closed so `project_dir` and `content_fingerprint` in `data/devops/system/design-fidelity-config.json` describe the real tree again. Did not affect this story's render, which resolved the correct entry either way. |

## Advisory (non-blocking, no action requested)

`coding-plan/test-results.md:445-446` still literally reads `MOBILE_COMPLETE: NO`
and `BLOCKER: BACKEND_RUNTIME_UNAVAILABLE`. The lines are prefixed "superseded"
and annotated by the Scrum Master note at `:448-457`, and Scrum Master has
already adjudicated this deliberately. Recorded only because it is the same class
of parse hazard B5 was: a machine-read marker line whose literal value contradicts
the story's actual state. Worth a cleanup pass at requirement-integration time,
not now.

## Workflow recommendation

- `Outcome: DEFERRED_ONLY` — the story may be marked `DONE` by Scrum Master.
- Scrum Master ticks `- [x] Review (Reviewer)` in `story_master.md` and sets
  `Status: DONE` (Reviewer rule 7 forbids me editing that file).
- Run `.claude/hooks/git-story-boundary.sh complete --req
  REQ-002_screen_flow_and_design_fidelity_audit --story
  STORY-061_dream_jar_list_design_fidelity_hardening` after the state updates
  land, so `commit_sha` / `merge_sha` / `MERGE_COMPLETE` are present for the DONE
  gate.
- Close RWB-20260816-029 in `data/retro-audit/rework-backlog.md` against this
  report.
- D1, D2, and D4 are candidate follow-up items; D5 is Scrum Master-owned repo
  hygiene. None gates this story.
