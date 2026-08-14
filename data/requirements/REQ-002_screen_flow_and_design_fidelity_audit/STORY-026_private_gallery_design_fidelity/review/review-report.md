# STORY-026 Review Report — Design Fidelity: Private Gallery

Outcome: DEFERRED_ONLY

Current outcome is round 3 (2026-08-14) — see "Round 3" at the end of this
report. The header block and findings immediately below are preserved round-2
history, whose outcome was `PATCH_REQUIRED` on F1; round 3 closes F1.

Review type: compact-story-review (round 2, first full post-rescope review)
Story: STORY-026 (REQ-002), Complexity `trivial`, Implementation Lane `mobile`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-026`
Diff baseline: `12c427f..c0bfbcf` (4 commits)
Date: 2026-08-14

## Scope Gate

| Field | Value |
| --- | --- |
| Source files in scope | `mobile/lib/features/gallery/presentation/widgets/gallery_grid_view.dart`, `mobile/lib/features/gallery/presentation/widgets/gallery_tile.dart` |
| Test files in scope | `mobile/test/features/gallery/gallery_design_fidelity_test.dart`, `mobile/test/features/gallery/gallery_capture_entry.dart` |
| Governing artifacts | `story_master.md` (incl. §"Product Owner Ruling" 2026-08-14) |
| Evidence in scope | `visual-fidelity/visual-fidelity-report.md`, `visual-fidelity/implemented-gallery-emulator-5560.png` |
| Design source (ranged read) | `cupid-app-design-system/project/Cupid Screens.dc.html` L720-754 |
| Entry-point verification | `mobile/lib/core/navigation/app_shell.dart` L184-198 |
| Query keys | `galleryOpen`, `galleryLocked`, `add_photo_alternate`, `box-shadow:var(--shadow)`, `GalleryScreen`, `gallery_locked_view.dart` |
| Touched risk surfaces | mobile interaction (UI layout/typography/token usage); no schema, contract, runtime, permission, or auth surface touched |

## Acceptance Criteria

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — `galleryOpen` layout/spacing/token/typography match | PARTIAL | Value-by-value match confirmed against the design source; the mandated rendered side-by-side is missing (F1) |
| AC2 — deviations corrected in the app, not merely documented | PASS | All 10 deviations present in the diff and pinned by 6 new widget tests |
| AC3 — no Level-1 lock affordance; pairing gate unchanged | PASS | Independently verified, see below |
| AC4 — no new entry point | PASS | `GalleryScreen` still mounted as an existing `CupidTabBar` destination; `app_shell.dart` not in the diff |

### Round-1 premise conflict is genuinely resolved

Round-1 findings B1/B2 blocked on AC1/AC3 targeting the design source's
`galleryLocked` state — a Level-1 device-encrypted gallery REQ-001 never
approved. The Product Owner Ruling (`story_master.md` L94-122, commit
`6956e84`) rescopes AC1 to `galleryOpen` and flips AC3 to require the lock
affordance's *absence*. I verified the implementation against the amended
targets, not the original ones. Round-1 deferred D-1 (token-scale vs raw-px) is
closed by the ruling's explicit definition of "match" as
nearest-existing-token resolution.

### AC1 — independently verified against the design source

I read the `galleryOpen` block directly (`Cupid Screens.dc.html` L736-751). The
evidence report's citations are accurate line-for-line: `padding:8px 16px 40px`
(L737), `grid-template-columns:1fr 1fr;gap:11px` (L743),
`aspect-ratio:3/4;border-radius:var(--r-sm);box-shadow:var(--shadow)` with the
`left:9px;bottom:9px;padding:3px 8px;border-radius:999px;backdrop-filter:blur(6px);
'Roboto Mono';font-size:9px` caption chip (L744-746), and
`border:1.5px dashed var(--line)` + `add_photo_alternate` 26px `var(--pink)` +
11.5px `var(--tx2)` label (L747). Each maps to the delivered code as the report
claims. D3 (shadow `DecoratedBox` moved outside the corner `ClipRRect`) is a
real rendering fix, not a token swap — tiles previously shipped with no
elevation at all.

### AC3 — verified two ways, independently

- `git diff --name-only 12c427f..HEAD` touches exactly four files; neither
  `gallery_locked_view.dart` nor `presentation/screens/` is among them. Its last
  commit is `0b71a84` (REQ-001 STORY-013). The pairing gate is untouched, not
  deleted, and the Level-1 lock feature was not built.
- The rendered capture shows no lock gate, no auto-lock banner and no
  screenshot notice.

### Verification re-run independently in this review

| Command | Result |
| --- | --- |
| `flutter test test/features/gallery test/design_system` | 78/78, "All tests passed!" — matches the report's claim exactly |
| `flutter analyze lib/features/gallery test/features/gallery` | 1 issue: pre-existing `use_null_aware_elements` **info** at `gallery_api.dart:88`, a file outside this story's diff. No error/warning in changed files |

## Blocking Findings

### F1 — No rendered `galleryOpen` design reference; the mandated side-by-side comparison did not happen

`visual-fidelity/` contains only `implemented-gallery-emulator-5560.png`. There
is no `design-reference-gallery-<device>.png`, and the reviewer gate requires
both images so the comparison can be re-checked by the last reader before DONE.

The implementer's reasoning for omitting it is correct as far as it goes, and I
confirmed it: the only rendered gallery baseline in the repo,
`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/design-reference-gallery-android.png`,
depicts the `galleryLocked` branch (lock glyph, "Chỉ mình bạn mở được", AES-256
/ Secure Enclave copy, fingerprint CTA) — I opened it. The canvas marks that
branch `hint-placeholder-val="{{ true }}"`, so it is the canvas default.
Copying that PNG into the story would have manufactured a wrong-state
reference, which is worse than omitting it. Not copying it was the right call.

But the gap is still open, and it is not cosmetic on a story whose entire
deliverable is visual fidelity to one specific design state. A value-by-value
CSS comparison catches wrong tokens; it does not catch composite/emergent
differences, and two are already visible when the capture is set against the
design source:

- the caption chip reads `14 thg 2, 2026` in the app versus `14/02 · Đà Lạt` in
  the design (L744) — a different string shape driving a visibly wider pill.
  The report does not mention this at all.
- the tile carries a top-right uploader badge (`B`/`Đ`) that has no counterpart
  anywhere in the design source. The report lists it under D10 as an inset
  adjustment without flagging that the element itself is an app addition.

Both are very likely legitimate REQ-001-approved app extensions (`GalleryItem`
carries no location field; the uploader badge is a `uiux-spec` element), and the
report already discloses the comparable responsive-column extension in §3. They
need the same disclosure so the `VISUAL_FIDELITY: PASS` is honest about what
differs from the canvas.

Action items (owner: mobile-dev):

1. Render the canvas screen `gallery` in its `galleryOpen` state to
   `visual-fidelity/design-reference-gallery-<device>.png` (the sc-if state must
   be forced; the canvas defaults to `galleryLocked`), then re-issue §8 as an
   actual two-image comparison with a per-state verdict.
2. If `render-design-canvas.js` cannot force a non-default `sc-if` state, do not
   resolve this silently and do not substitute prose: record the exact tool
   limitation and route it to Scrum Master for an explicit exemption decision.
3. Add the caption-format delta and the uploader badge to the disclosed
   app-extension list, alongside the existing responsive-column disclosure.

No source change is expected from F1 unless the render exposes a deviation the
value comparison missed.

## Deferred Findings

- **D-2** — `_addPhotoAlternateIcon` (`0xe43e`) is declared file-locally in
  `gallery_grid_view.dart` because `cupid_icons.dart` is outside this story's
  WriteScope. Correct call here; promoting it into `CupidIcons` belongs to
  whichever story owns the design-system icon set. The same codepoint is
  already resolved by `gallery_empty_view.dart`, so it is verified, not guessed.
- **D-3** — `gallery_capture_entry.dart` renders `GalleryGridView` in a bare
  `Scaffold`, so the capture omits the real `AppShell` chrome (tab bar, FAB).
  The audited surface is fully covered and the harness correctly mirrors the
  app's `GlobalMaterialLocalizations` setup, but a future capture through the
  real shell would make the evidence stronger.

## Traceability

- Requirements: `story_master.md` AC1-AC4 as amended by §"Product Owner Ruling"
  (2026-08-14, commit `6956e84`).
- Design: `cupid-app-design-system/project/Cupid Screens.dc.html` L736-751
  (`galleryOpen`); `design-fidelity-config.json` records `ui_surface: true` with
  a locked `claude-design` source, so no fidelity exemption applies.
- Architecture/UX (scope boundary): REQ-001 `STORY-013_gallery`
  `architecture/solution.md` D-1/R3 and `ux/uiux-spec.md` §2 — cited by the PO
  ruling as the basis for excluding the Level-1 lock model. Not re-read here;
  the ruling is the governing artifact for this story.
- Tests: 6 new widget tests in `gallery_design_fidelity_test.dart`; 78/78 pass
  on re-run.
- Critical gates: mobile static analysis PASS; targeted widget/regression tests
  PASS; entry-point reachability PASS (verified in `app_shell.dart`, not on
  trust); rendered design-fidelity comparison **NOT MET** (F1).
- Runtime startup smoke: not required — story `Complexity: trivial`.
- Configuration guide: not applicable — no setup/configuration surface touched.

## State Recommendation

- Story status: `IN_PROGRESS` — return to mobile-dev for F1.
- Leave `Review (Reviewer)` unchecked; uncheck `Implementation (Development)`.
- Scope is narrow: F1 is evidence completion, not a code rework. A re-review
  should be a `completion/resume` pass over §8 of the visual-fidelity report and
  the new reference image only.

---

# Round 3 — 2026-08-14 (narrow closure re-review)

Outcome: DEFERRED_ONLY

Review type: compact-story-review, closure-only re-review of F1
Diff baseline: `58b7353..55a98cc`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-026`

## Scope Gate

| Field | Value |
| --- | --- |
| Diff contents | 2 files, +195/-12 — `visual-fidelity/visual-fidelity-report.md` (+167/-12), `story_master.md` (+40/-0) |
| Source files in scope | none — no `lib` or `test` file changed in round 3 |
| Governing artifact | `story_master.md` §"Scrum Master Disposition — 2026-08-14 (round-2 review F1)" |
| Design source (ranged reads) | `Cupid Screens.dc.html` L730-735, L740-751, L2274-2279; `Cupid App.dc.html` L292-296, L408-412 |
| UX source (ranged reads) | REQ-001 `STORY-013_gallery/ux/uiux-spec.md` §4.2 L104-129, §4.5 L163-181, §6 L194-212 |
| App source (spot-check) | `gallery_tile.dart`, `gallery_grid_columns.dart`, `gallery_item.dart` L1-40 |
| Not re-litigated | Whether the exemption should have been granted — that ruling is the Scrum Master's and is made |

## Exemption conditions — both genuinely met

The Scrum Master ruling grants the live two-image render exemption on two
conditions. Both hold:

**(a) AC1 value-match independently verified against the design source.** Round 2
did this first-hand (§"AC1 — independently verified against the design source"),
reading `Cupid Screens.dc.html` L736-751 directly rather than trusting the
evidence report; its AC1 verdict was `PARTIAL` solely because the rendered
side-by-side was absent, not because any value failed. I re-read the same block
(L740-751) this round and re-confirm the in-scope citations: `1fr 1fr;gap:11px`
(L743), the `aspect-ratio:3/4` / `var(--r-sm)` / `box-shadow:var(--shadow)` tile
and its `left:9px;bottom:9px;padding:3px 8px;999px;blur(6px);'Roboto Mono';9px`
caption chip (L744-746), and the `1.5px dashed var(--line)` + 26px
`add_photo_alternate` + 11.5px `var(--tx2)` add tile (L747). The exemption
covers the rendering tool only; it does not waive this, and this is not waived.

**(b) All deltas disclosed with citations in §3A.** Verified each of E1-E3
against both the cited authority and the shipped code, not against the report's
own prose:

| # | Claim | Verification |
| --- | --- | --- |
| E1 | canvas fixed 2-up (L743) vs `galleryColumnCount()` 2→3 at ~430dp, per uiux-spec §6 | Canvas L743 is `grid-template-columns:1fr 1fr`. `gallery_grid_columns.dart` L6 is `widthDp >= 430 ? 3 : 2`. uiux-spec §6 L196-202 states 2 columns at ~360-430dp and `>=430dp` may render 3. Exact match |
| E2 | canvas `14/02 · Đà Lạt` vs app localized date-only; no location field exists; spec says location is optional | Canvas L744 placeholder and caption text are both `14/02 · Đà Lạt`. `gallery_tile.dart` L71-73 is `DateFormat.yMMMd(locale).format(item.createdAt)`. `gallery_item.dart` L17-22 carries `id`/`userId`/`filename`/`createdAt`/`thumbnailUrl`/`mimeType` and no location. uiux-spec §4.2 L108-109 reads "caption chip showing date + optional location". Accurate |
| E3 | 24px uploader badge, tile top-right, no canvas counterpart | Canvas tiles L744-746 contain exactly an `<image-slot>` plus one caption `<div>` — no badge. `gallery_tile.dart` L162-166/L194-204 is a 24x24 circle at `Positioned(top, right)`. uiux-spec §4.2 L112-118 specifies the 24px badge and states in its own words that it is "new relative to the source screen" and "required by AC2's 'both partners' framing". Accurate |

The E1 citation correction (round 2's "§4.6" → "§6") is itself correct: the
uiux-spec's §4 ends at §4.5 (`gallery-locked`, L163-181); there is no §4.6, and
the 2-vs-3 column rule lives in §6 Responsive Behavior.

**Blocker recorded honestly, not deleted.** `Design-Reference-Render: BLOCKED
(DESIGN_CANVAS_STATE_FORCE_UNSUPPORTED)` is in the report's frontmatter block
(L13), the §8 evidence table now carries a `Design reference | not produced —
see 8.1` row, and a scope caveat directly under the frontmatter states in plain
terms that `VISUAL_FIDELITY: PASS` is **not** the two-image comparison the gate
normally requires. The gap is more visible after round 3, not less.

**§8.1's technical claims are sound.** Every design-source citation supporting
the blocker is exact: `Cupid App.dc.html` L294 (`unlockedA: false, unlockedB:
false` — canvas default is locked), L410 (`unlock = (side) => this.setState(...)`
— the only writer), `Cupid Screens.dc.html` L2276-2277 (the `galleryLocked` /
`galleryOpen` branch computation) and L733 (`onClick="{{ doUnlock }}"` on the
fingerprint CTA — the only caller). `galleryOpen` is app state written only by
an in-frame click, which is the substance of the limitation.

## Blocking Findings

None. F1 is closed.

## Deferred Findings

- **D-4 (new)** — §8.1 prints its inventory command under "Run in the story
  worktree", but `render-design-canvas.js` cannot run there: `.ai-team-bundle/`
  is gitignored (`.gitignore:5`), so the tool exists only in the control
  checkout and the command as written exits `MODULE_NOT_FOUND`. I confirmed this
  by running it. This cuts the same way as the finding — the renderer is *less*
  reachable from a story worktree than §8.1 claims, so it does not weaken the
  blocker — but the reproduction line should say control checkout, and the
  quoted `toggles` output was evidently captured from a different cwd than
  stated. Evidence-narrative accuracy, not an AC gap.
- **D-5 (new)** — `gallery_grid_view.dart` L19 still cites "`ux/uiux-spec.md`
  §4.2, §4.6" in its class docstring; §4.6 does not exist, and §3A corrected the
  same citation to §6 this round. Pre-existing STORY-013 comment, outside the
  round-3 diff and outside this story's source scope. Fix opportunistically in
  whichever story next touches that file.
- **D-2, D-3** — carried forward unchanged from round 2 (file-local
  `_addPhotoAlternateIcon`; capture harness renders `GalleryGridView` outside the
  real `AppShell` chrome). Neither is affected by round 3.
- The follow-up recorded in the Scrum Master disposition — giving
  `render-design-canvas.js` a way to force arbitrary `sc-if`/unlock states — is
  tracked outside this story as a bundle-tooling note and is correctly not
  reopened here.

## Residual Risk

Composite/emergent differences a value-by-value comparison cannot catch remain
unverified for the `galleryOpen` state — most concretely the E2 caption-pill
width question §3A itself raises. This is the accepted, documented cost of the
granted exemption, and it is now stated in the artifact rather than implied.

## Traceability

- Requirements: `story_master.md` AC1-AC4 as amended by §"Product Owner Ruling"
  (2026-08-14) and dispositioned by §"Scrum Master Disposition" (2026-08-14).
- Verification: round 3 changed no source or test file, so round 2's
  `flutter test test/features/gallery test/design_system` (78/78) and
  `flutter analyze` results stand; §9 correctly says so rather than restating
  them as a fresh run. Not re-run this round — nothing to re-run against.
- Critical gates: all round-2 gates unchanged and passing; the rendered
  design-fidelity two-image comparison is **exempted by explicit Scrum Master
  ruling**, with the blocker recorded in-artifact.

## State Recommendation

- Story status: eligible for `DONE` — `Outcome: DEFERRED_ONLY`, no blocking
  finding.
- Check `Review (Reviewer)`; the story branch is merge-eligible into
  `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`.
- D-4 and D-5 are non-blocking and need no rework pass on this story.
