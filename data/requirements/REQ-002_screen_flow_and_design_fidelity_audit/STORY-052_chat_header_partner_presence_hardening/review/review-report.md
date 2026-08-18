# STORY-052 Review Report — Chat Header Partner Pairing + Presence Chip

Reviewer: Iris-QC · Mode: `final-synthesis` (Tier 3 scoped-slice) · Date: 2026-08-18
Story: `REQ-002_screen_flow_and_design_fidelity_audit/STORY-052_chat_header_partner_presence_hardening`
Rework item: RWB-20260816-017 (`data/retro-audit/rework-backlog.md`)
BaseHead: `c7fd6ecdd13dc08a0abc72b07ab3b3305786829e`
Implementation diff baseline used by both slices: `25b92d8..212e50c`
F1/F2 closure evidence commit: `d2db1c9`

## 1. Why This Was a Sliced Review

14 touched files exceeded the Tier 2 12-file cap, so the gate ran as two
independent slices with disjoint AC coverage, then this synthesis pass. This
report is written by a fresh reviewer instance; it does not re-review the
source or test diffs, it synthesizes the two slice verdicts plus the evidence
committed after slice 2 was written.

| Slice | ACs | Report | Slice verdict |
| --- | --- | --- | --- |
| 1 — backend contract | AC1 | `review/slice-backend-contract.md` | PASS, 0 blocking, 2 deferred LOW (D-B1, D-B2) |
| 2 — mobile identity/header/presence | AC2–AC7 | `review/slice-mobile-identity-header.md` | Code PASS, 0 code defects; 2 blocking evidence gaps (F1, F2); disclosed F3/D-1 and N1–N4 |

Both slices recorded `REVIEW_SLICE_COMPLETE: YES`. Together they cover AC1–AC7
with no AC unreviewed and no overlap.

## 2. Story-Level Verdict Summary

Every acceptance criterion passes on the delivered code. Neither slice found a
correctness, regression, security, or maintainability defect in the
implementation. The two blocking findings raised by slice 2 were both missing
required evidence sections, not broken behavior, and both are now closed by
evidence committed afterward (§3).

One real, visible, disclosed design-fidelity delta remains open (D-1, the `↔`
glyph), and its remedy is provably outside this story's authorized write scope.
That is what drives the story-level verdict to `DEFERRED_ONLY` rather than
`CLEAN` (§4).

## 3. Blocking Findings From Slice 2 — Both Closed

### F1 — `## Entry Point Reachability` absent — CLOSED

`coding-plan/test-results.md:405-426` now carries the section with
`Reachable: YES`, the concrete path (`AppShell` bottom-nav tab `Trò chuyện` at
`mobile/lib/core/navigation/app_shell.dart:126-127` → `ChatScreen` mounted at
`app_shell.dart:137-146` behind `chat_entry_gate`), and a per-line verification
against the file at commit `212e50c` including the `isUnlocked` conditional and
the `chatIndex = isUnlocked ? 1 : -1` index shift.

This matches what slice 2 had already verified independently in code, and Scrum
Master re-verified the recorded line numbers against the actual `app_shell.dart`
source. The recorded fact was already true; only the required section was
missing. Rule 12e1 is satisfied.

### F2 — no `## Story Runtime Startup Smoke` evidence — CLOSED

`coding-plan/test-results.md:428-540` records remedy path (a) — the stronger of
the two options slice 2 offered — not a waiver. `story_master.md` therefore
correctly carries no `Runtime-Smoke: WAIVED` line, and none is needed.

The section closes the exact failure mode slice 2 named. Slice 2's objection was
that the only launch evidence came from a `-t lib/main_preview.dart` build,
which bypasses production bootstrap, DI, Firebase init, and the router — the
precise gap rule 12g exists for. The new section rebuilds without `-t` (plain
`flutter build apk --debug`, which targets `lib/main.dart`), and it explicitly
uninstalls the preview APK first because both share the `com.snapsofts.cupid`
application id — closing the "leftover preview install" hole before it could be
raised. Launch is asserted with the readiness probe documented in
`data/devops/system/runtime-command-registry.json` → `runtimes.mobile-app.readiness`
rather than an invented one, `LaunchState: COLD` rules out a resume of the warm
preview process, logcat is clean
(`NO_FATAL_OR_FLUTTER_EXCEPTION_FOUND`), the reached screen is described
concretely enough to be falsifiable (the `welcome` screen's wordmark, tagline,
and both CTAs — not a splash frame, blank canvas, or red error screen),
interactivity past the first frame is confirmed by routing to the login screen,
and shutdown follows the registry `shutdownCommand` with the device left clean.

Scrum Master independently re-verified this section against the actual registry
readiness-probe definition and confirmed it matches verbatim. I sanity-checked
the section for internal consistency as instructed and found none of the
thinness slice 2's F2 wording would have predicted: the claims are specific,
mutually corroborating (pid, `ResumedActivity`, `LaunchState`, logcat, rendered
copy), and the one limitation is self-disclosed rather than concealed.

The "chat screen not walked end-to-end" scope note is accepted per Scrum
Master's prior ruling and is not re-litigated here. I record only that the note
is honest and correctly reasoned: the chat tab is gated behind a real
Firebase-authenticated session plus active partner pairing, which this lane
must not fabricate, and rule 12g's gate is production bootstrap reaching a real
first screen — which it did, cleanly. Chat rendering itself is covered by the
19 tests in `chat_design_fidelity_test.dart` plus the rendered visual-fidelity
pair. Rule 12g is satisfied.

## 4. Disposition of D-1 / F3 — the `↔` Emoji Tile

This was the one judgment call left open for synthesis, and it decides the
story-level verdict.

**Finding.** On Android the header pairing title's U+2194 `↔` renders through
the emoji font as a filled teal/blue rounded tile, where the design reference
renders a thin monochrome arrow. Both slice reviewers opened both PNGs
independently and each confirmed the delta is real, clearly visible, and not
subtle. It sits inside AC2's own surface.

**The tension I have to resolve.** Rule 12e2 states that any visible
discrepancy, however small, is `FAIL` with the delta recorded. Yet
`visual-fidelity/visual-fidelity-report.md` line 3 records
`VISUAL_FIDELITY: PASS` while documenting this same deviation as OPEN in §4 of
that same file. Those two statements cannot both be the last word.

**Disposition: defer, do not absorb and do not patch.** Reasoning:

- `CLEAN` is wrong. There is a real, open, visible fidelity delta against the
  locked design source. Marking the story clean would silently absorb it, and
  this story exists precisely because an earlier story (STORY-040) disclosed a
  delta that was then not carried — I will not reproduce that failure mode.
- `PATCH_REQUIRED` is wrong, because no patch is available to this story that
  does not breach its own governing spec. `ux/uiux-spec.md` §1.2 states "Text
  content only; do not touch this existing style block", fencing the header
  title style off from this story. Both remaining remedies — declaring a
  text-presentation font on the title style, or replacing the separator glyph —
  breach either that fence or the locked design source's literal string.
  Demanding a patch here would be ordering the lane to violate its own spec.
- `BLOCKED` is wrong. Nothing prevents this story from being complete on its
  own terms; the blocker is scope authority, not missing information or a
  broken dependency.
- The one remedy that *was* inside scope was attempted honestly and disproved:
  U+FE0E (VARIATION SELECTOR-15) was built, installed, re-captured, shown to be
  a no-op because Flutter's Android font fallback still resolves the emoji font,
  then **fully reverted** — production constant removed, both test literals
  restored, chat suite re-run green, and the delivered evidence capture taken
  from the reverted build. A dartdoc on `ChatStrings.headerPairingTitle` records
  the dead end so the next reader does not repeat it. Lint, full suite, and
  build were all re-run against the exact delivered source after the revert.

That is a defect that is disclosed, root-caused, empirically bounded, and owned
elsewhere — the textbook shape of a deferred item. Hence `DEFERRED_ONLY`.

**AC2 itself still passes.** AC2's testable text requires the header to show
`<self> ↔ <partner>` with both halves sourced from real backend data and not
the caller's name duplicated. The string composition and the data sourcing both
pass (slice 2, and `_NamedPartnerStore` makes a wrong-getter wiring unable to
pass). What deviates is the *glyph presentation*, which the rule 12e2 fidelity
gate catches, not AC2's literal requirement. The delta is carried below as a
fidelity finding, not as an AC failure.

**Required before DONE — the deferral needs a durable carrier.** I checked, and
as of this review the `↔` follow-up exists only as prose inside
`visual-fidelity-report.md` §4 ("Routed to UI/UX Designer and Tech Lead").
`data/retro-audit/rework-backlog.md` ends at RWB-20260816-025 with no item
covering U+2194, and `story_master.md` registers no follow-up. A `DEFERRED_ONLY`
verdict is only honest if the deferral is actually carried somewhere that will
be read after this story closes. This is exactly how RWB-20260816-017 — this
story's own parent item — came into existence: a delta disclosed in a story
report and not registered, resurfacing stories later.

`rework-backlog.md` and story registration are Scrum Master-owned; neither this
reviewer nor the delivery lanes can write them, so I record this as a required
action on Scrum Master rather than as a blocking finding against the lanes:
**register a rework-backlog item (or follow-up story) for D-1, owned by UI/UX
Designer + Tech Lead, before marking STORY-052 DONE.**

## 5. Deferred Findings Carried Forward

| ID | Severity | Source | Item |
| --- | --- | --- | --- |
| D-1 | MEDIUM | slice 2 F3 / `visual-fidelity-report.md` §4 | `↔` renders as a colour emoji tile on Android. Root cause: U+2194 emoji-presentation default. VS15 fix attempted, disproved, fully reverted. Remedy requires the title style block fenced off by `ux/uiux-spec.md` §1.2. Owner: UI/UX Designer + Tech Lead. Needs backlog registration (§4). |
| D-S1 | LOW | this synthesis | `visual-fidelity-report.md` §7 line 317 still records `Runtime startup smoke \| — \| NOT_APPLICABLE per data/devops/system/runtime-command-registry.json (mobile-app)`. The registry says no such thing — slice 2 established it has no `startupSmoke`/`NOT_APPLICABLE` key, and its `mobile-app` entry documents a real launch path. The claim is now also superseded by the real smoke in `test-results.md`. Remedy: one-line correction pointing at `coding-plan/test-results.md` `## Story Runtime Startup Smoke`. Owner: `mobile-dev`. |
| D-B2 | LOW | slice 1 | An empty-string partner `displayName` returns as-is rather than `null` (`??` collapses only null/undefined). Contract-faithful per `contract-summary.md` §3, which also forbids backend normalization. Consumer-side note only. Minor: partner lookup loads the whole row where `select: ['displayName']` would do. |
| N2 | LOW | slice 2 | `Design-Screen: <id>` recorded only inside the render command, not as a `story_master.md` field. Traceability nit; slice 2 opened the reference and confirmed it is unambiguously the chat screen. |

Not carried, resolved during synthesis:

- **D-B1 — resolved, no action.** Slice 1 asked synthesis to confirm the mobile
  lane does not depend on regenerated OpenAPI typed models, since `GET /users/me`
  exposes no response schema. Slice 2 confirms it does not:
  `chat_partner_store.dart:46-53` reads the raw JSON map
  (`body['displayName']` → `selfDisplayName`, `body['partnerDisplayName']` →
  `partnerDisplayName`), with missing-key and null cases both tested, which is
  the consumption model `contract-summary.md` §3 implies ("a missing key must be
  treated as `null`"). In Scope item 3's "regenerate the API client" phrasing is
  satisfied by contract-faithful raw-map consumption. Documentation note only.
- **N1, N3, N4 — correctly dispositioned by slice 2, no action.** N1: the
  reference PNG's `M` vs. the implementation's `L` is a demo-toggle artifact;
  the partner-scoped implementation is spec-correct per `ux/uiux-spec.md`
  §"Finding". N3: `ExcludeSemantics` covering the status text is wider than
  §4's literal wording but is what makes AC4's "one coherent label" true, proved
  by `chip.childrenCount == 0`. N4: AC2's real-data path is covered link by link
  (backend → key mapping → composition) rather than as one live run; the device
  capture necessarily uses the preview fixture because it is a preview build,
  which does not weaken AC2 since the production path is the one under test.

## 6. Traceability

| AC | Verdict | Owning slice |
| --- | --- | --- |
| AC1 — `GET /users/me` carries `partnerDisplayName` from the partner's real row, self shape unchanged | PASS | 1 |
| AC2 — header shows `<self> ↔ <partner>` from real backend data | PASS (glyph presentation deferred as D-1) | 2 |
| AC3 — presence chip top-right: partner initial, online dot, `đang online` | PASS | 2 |
| AC4 — chip announces one coherent label; title semantics drops the `↔` glyph | PASS | 2 |
| AC5 — the other 16 `CupidHeader` consumers render unchanged | PASS (Material tree-identity via `same(actions)`) | 2 |
| AC6 — existing params unchanged, new params optional with safe default | PASS (both platform branches wired) | 2 |
| AC7 — reached through the existing navigation path, no new entry point | PASS (code + evidence section, F1 closed) | 2 |

Story-level gates: mobile design fidelity (rule 12e3) — PASS with the disclosed
D-1 delta; entry point reachability (rule 12e1) — PASS; runtime startup smoke
(rule 12g) — PASS on the production entrypoint; backend build/type-check and
targeted unit coverage — PASS; ADR-004 no-fork guard — PASS.

RWB-20260816-017 is closed by this story with real backend data, which was the
explicit purpose of the R2 disposition in `story_master.md` §BLK-052-1.

## 7. Required Actions Before Scrum Master Marks This Story DONE

1. Register D-1 in `data/retro-audit/rework-backlog.md` (or open a follow-up
   story), owned by UI/UX Designer + Tech Lead, so the deferral has a durable
   carrier beyond story-artifact prose. See §4.
2. D-S1 is a one-line documentation correction and does not gate DONE; fold it
   into the D-1 follow-up or file it with the mobile lane.

No code change is required by this review.

Outcome: DEFERRED_ONLY

REVIEW_COMPLETE: YES
