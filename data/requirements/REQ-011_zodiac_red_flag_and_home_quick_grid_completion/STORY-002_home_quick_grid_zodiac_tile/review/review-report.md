# Story Review Report: STORY-002 Home Quick Grid — Zodiac Red Flag Tile

Outcome: PATCH_REQUIRED

- Requirement: REQ-011_zodiac_red_flag_and_home_quick_grid_completion
- Story: STORY-002_home_quick_grid_zodiac_tile
- Review mode: compact-story-review (round 2, supersedes round 1 in full)
- Story class: standard | `Implementation Lane: shared` (diff is 100% mobile)
- Reviewer: Iris-QC | Date: 2026-08-25
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-011_zodiac_red_flag_and_home_quick_grid_completion-STORY-002_home_quick_grid_zodiac_tile`
- BaseHead (diff baseline): `98420aaca21ed1734768bae2ad7bfb98769b111f`
- Worktree HEAD at review: `b0fe966af6f289eb1cba76119e16d5ffcabdb179` (tree clean)

## Scope Gate

- Review type: compact-story-review, full story diff at BaseHead (not a delta review).
- Source/test files in scope (3, within the 8-file compact budget):
  `mobile/lib/features/home/presentation/home_screen.dart`,
  `mobile/lib/design_system/icons/cupid_icons.dart`,
  `mobile/test/features/home/home_quick_grid_test.dart`.
- Evidence files in scope: `visual-fidelity/visual-fidelity-report.md`,
  both `visual-fidelity/*.png`, `coding-plan/test-results.md`,
  `coding-plan/phase-P1-home-quick-grid-zodiac-tile.md` §1B, `story_master.md`,
  round-1 `review/review-report.md`.
- Config in scope: `data/devops/system/design-fidelity-config.json`,
  `data/devops/system/runtime-command-registry.json` (`mobile-app`).
- Touched risk surfaces: mobile interaction, mobile navigation/discoverability,
  app lifecycle.
- Query keys: `subtitleColor`, `colorPeach`, `_QuickGridTile`, `_QuickGridRow`,
  `Entry Point Reachability`, `Story Runtime Startup Smoke`, `Design-Surface`, D1, F1.
- Round 1's `review/scope-gate.md` is left in place but is not this round's gate
  (rule 5a: compact reviews carry the gate inline).

## 1. Round-1 F1 — CLOSED

F1 required story-level design-fidelity render+compare evidence for AC1. It is now
present and, on my own inspection, real:

| 12e3 check | Result |
| --- | --- |
| Both images exist and open as real images | YES — `design-reference-home-android.png` 406x900, `implemented-home-emulator-5554.png` 405x900 |
| Implemented shot shows THIS story's screen, no splash/error/wrong screen | YES — I opened it: full Home dashboard on the `Nhà` tab, hero, `247 ngày bên nhau`, card column, quick-grid row all painted |
| Reference depicts the same screen of the design | YES — I opened it: the mobile Home node, same card column, same quick-grid row |
| `Design-Screen: <id>` recorded and is the screen I looked at | YES — `Design-Screen: home` |
| Correct design SOURCE (two are configured) | YES — rendered `--surface=mobile --entry="Cupid App.dc.html"` = source id `cupid-app`; the `cupid-web` canvas was not used. Confirmed by looking at the reference, not by the token |
| Report carries a concrete comparison, not a bare token | YES — 18-row element table, dp-normalized per §3's 0.939 vs 0.985 px/dp correction |
| Images do not contradict the `PASS` | Correct — see §2 |

## 2. Round-1 D1 (peach subtitle) — genuinely fixed, correctly scoped

Verified three independent ways, not from the report's assertion:

1. **In the image.** In `implemented-home-emulator-5554.png` the Zodiac subtitle
   `Xem chỉ số xung đột hôm …` renders warm salmon while the Synced Alarm subtitle
   `Nhắc trên cả hai máy` beside it renders grey-lavender. The design reference shows
   the same split (`Xung đột 7/10 hôm nay` peach, `06:30 · còn 1 người` grey).
2. **In the code at HEAD**, not just in the commit: `home_screen.dart:945` declares
   `this.subtitleColor` optional; `:1023` resolves `subtitleColor ?? colors.colorTextMuted`;
   `:922` is the ONLY call site passing `subtitleColor: colors.colorPeach`. The Synced
   Alarm call site (`:897-908`) passes none, so it still resolves `colorTextMuted`.
   Scoping is exactly right — no leak onto the sibling tile.
3. **The capture was really re-taken**, not re-asserted: `b0fe966` shows
   `implemented-home-emulator-5554.png | Bin 179790 -> 180467 bytes`. The design side was
   correctly not re-rendered (fix touched only `mobile/lib/**`).

## 3. AC re-check against the current diff

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — both tiles in the design's 2-column layout, no visible deviation | PASS | Structure re-confirmed at HEAD (`_QuickGridRow`: `IntrinsicHeight` > `Row` > 2x `Expanded` + 12px `SizedBox`). The comparison half, unproven in round 1, is now closed by §1/§2 |
| AC2 — tile navigates to STORY-001's screen | PASS | `home_screen.dart:923-925` `pushNamed(ZodiacRedFlagScreen.routeName)` — the imported constant, not a literal. Unchanged since round 1 |
| AC3 — no new top-level entry point | PASS | No `app_shell.dart`, tab-bar or route-registration file in the full `--stat`. Tile sits inside the already-reachable Home card list; the device capture shows it live on the `Nhà` tab |

Accessibility, codepoint discipline (`0xe65f` sparkle, cmap-derived), the Option A
Synced Alarm carve-out (key/copy/glyph/destination all preserved), and scope
containment (Dream Jar, Anti-Ghosting, tab bar, STORY-001's surface all untouched)
were verified in round 1 and are unchanged in the current diff. They are not re-litigated.

## 4. Blocking findings

These are gates round 1 did not check. They are mandatory, and `validate-done-gate.sh`
enforces B1 independently, so passing the story now would only fail later.

### B1 — Registry-backed runtime startup smoke is missing (rule 12g)

`coding-plan/test-results.md` has no `## Story Runtime Startup Smoke` section (its
headings are §1-§7; none is the smoke), and `story_master.md` records no
`Runtime-Smoke: WAIVED — <reason>`. `phase-P1-...md:31` instead claims
`Startup Smoke: NOT_APPLICABLE`, which 12g explicitly does not accept as a pass.

That claim is also factually wrong: `data/devops/system/runtime-command-registry.json`
defines a concrete smoke for `mobile-app` against the **shipped** launcher —
`adb -s "$MOBILE_DEVICE_SERIAL" shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
plus a `dumpsys ... ResumedActivity` readiness poll.

The visual-fidelity capture does **not** substitute. It launched
`main_preview.dart` via `cupidpreview://screen/home` — the preview harness, not the
shipped entrypoint. This repository already ruled on exactly this: RWB-20260816-027
records STORY-059's round-1 `PATCH_REQUIRED` (BLK-1) for "a missing registry-backed
runtime-smoke gate on the shipped entrypoint — every prior capture used the
`main_preview.dart` preview harness".

**Patch (Mobile Dev, or DevOps).** Run the registry command on a booted emulator against
a `flutter build apk --debug` of `lib/main.dart`, confirm the app reaches Home with no
crash or error screen, and record `## Story Runtime Startup Smoke` in
`coding-plan/test-results.md` with the exact command, device serial, and result. Correct
`phase-P1-...md:31` off `NOT_APPLICABLE` at the same time. Environment is available
(emulator-5554 was in use this session), so this is `PATCH_REQUIRED`, not `BLOCKED`.

### B2 — `## Entry Point Reachability` evidence section is missing (rule 12e1)

12e1 is mandatory and non-waivable for UI-facing stories, and `story_master.md:65`
records `UI-facing story: YES`. `coding-plan/test-results.md` carries no
`## Entry Point Reachability` section and no `Reachable: YES` line anywhere in the story.

The *implementation* is fine — I verified reachability independently and it is stronger
than usual: the tile is visible on the Home tab in the device capture itself, so this is
not a direct-URL-only capability. The gap is the evidence section only.

**Patch (Mobile Dev).** Add `## Entry Point Reachability` to `coding-plan/test-results.md`
with `Reachable: YES` and the concrete path (app shell `Nhà`/Home tab → Home dashboard card
column → `home_zodiac_entry_tile`). Doc-only; no source change.

### B3 — `shared` lane with two design sources and no `Design-Surface` (rule 12e2)

`data/devops/system/design-fidelity-config.json` configures **two** sources —
`cupid-app` (`surface: mobile`) and `cupid-web` (`surface: web`). Under 12e2 the
`Implementation Lane` decides the surface only for `mobile`/`ios`/`android` or
`frontend`/`web`; a `shared` lane must carry `Design-Surface: <id>`.
`story_master.md:6` says `shared` and records no `Design-Surface`.

The right surface *was* used — I confirmed `cupid-app` from the render command and by
looking at the reference image — so this is a metadata gap, not a wrong comparison. It
still needs closing because nothing in the story records the binding.

**Patch (Product Owner or Scrum Master).** Either set
`Implementation Lane: mobile` (which matches the diff — every changed source file is under
`mobile/`) or add `Design-Surface: cupid-app` to `story_master.md`. Either one closes it.

## 5. Deferred findings

- **DEF-1 — the D1 fix has no regression guard.** `home_quick_grid_test.dart` contains no
  reference to `subtitleColor`, `colorPeach`, or `colorTextMuted` (grep: no matches), and
  the addendum confirms test counts were unchanged by the fix (6 passed / 1 skipped, both
  rounds). A future edit to `_QuickGridTile` could silently revert the peach subtitle, and
  only another manual device capture would catch it. A widget test asserting the two tiles'
  resolved subtitle colours is cheap; worth folding into the B1/B2 patch round, but the
  behaviour is proven correct now so this is not blocking.
- **DEF-2 — stale line in `coding-plan/test-results.md` §7.** Its closing sentence says
  "No device/runtime re-capture was performed in this round", which `b0fe966` contradicts
  (the PNG was re-captured). Written at `e05d6db`, never updated. Same class as
  RWB-20260816-026's D-S1 doc correction. Fix while patching B1/B2.
- **DEF-3 — `ux/ux-spec.md` §3 item 5 still omits the subtitle colour**, which is what let
  D1 through in the first place (the spec pins size/`maxLines`/overflow only, while §1 of
  the same spec notes the design's "11.5px colored subtitle"). Designer amendment, outside
  this story's write scope. Already raised by the implementer in
  `visual-fidelity-report.md` §5.

## 6. Requirement-level observation (not a defect here)

The design's Home grid holds four tiles (Synced Alarm, Zodiac Red Flag, Dream Jar,
Anti-Ghosting); this story grids only the first two, with Dream Jar and Anti-Ghosting left
as full-width cards. Explicitly excluded by `story_master.md` Out of Scope and
`ux/ux-spec.md` §6, and AC1's subject is the two named tiles — so AC1 passes as written.
It is the most conspicuous difference between the two images and is correctly disclosed in
`visual-fidelity-report.md` §6.1. Carry to requirement integration review / backlog.

## 7. Traceability

- Requirements: `story_master.md` AC1-AC3, Out of Scope (Option A carve-out, `03ccf13`).
- UX: `ux/ux-spec.md` §3 tile internals, §3.1 Synced Alarm preservation, §3.2 static
  teaser copy, §4 comparison conditions, §6 exclusions.
- Architecture: `architecture/solution.md` (`_QuickGridRow`/`_QuickGridTile` boundary).
- Evidence: `coding-plan/test-results.md` §1-§7; `visual-fidelity/visual-fidelity-report.md`
  round 2 (`VISUAL_FIDELITY: PASS`) plus both PNGs, opened and compared by this review.
- Critical gates: design fidelity (12e2/12e3) **PASS**; targeted mobile tests and static
  analysis **PASS** (re-run in round 1, unchanged by the 1-file fix); entry-point
  reachability (12e1) **MISSING EVIDENCE — B2**; runtime startup smoke (12g)
  **MISSING — B1**; sibling call-site sweep (12d) **PASS** (Synced Alarm verified unchanged
  in code and in the capture).
- Configuration guide: not applicable — no setup, env, dependency, or external-integration
  impact in this diff.

## 8. Verdict

Verdict: PATCH_REQUIRED (the single literal verdict line is at the top of this report).

Round 1's F1 is closed and round 1's D1 is genuinely fixed, correctly scoped, and visible
in a re-taken capture — I verified all three by reading the images and the code at HEAD
rather than by trusting the `PASS` token. AC1, AC2, and AC3 all pass on the current diff,
and the implementation needs no source change.

What blocks closure is evidence, not code: the story never recorded the mandatory
registry-backed runtime startup smoke on the shipped entrypoint (B1), the mandatory
entry-point reachability section (B2), or the design-surface binding its `shared` lane
requires (B3). B1 and B2 are enforced independently at the DONE gate, so they cannot be
carried forward as deferred.

Recommended state: story `IN_PROGRESS`; leave `Review (Reviewer)` unchecked and uncheck
`Implementation (Development)`. Route B1/B2/DEF-1/DEF-2 to Mobile Developer and B3 to
Product Owner or Scrum Master, then re-review. Not merge-eligible until B1-B3 close.
