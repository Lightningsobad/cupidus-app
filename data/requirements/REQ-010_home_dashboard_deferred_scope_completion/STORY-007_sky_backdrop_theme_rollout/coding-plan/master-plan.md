# Master Coding Plan – `--sky` Backdrop Occlusion Audit, Allowlist, And Guard

## 1. Planning Metadata

- Story ID: STORY-007_sky_backdrop_theme_rollout
- Complexity: complex (classified on blast radius; see `## 6. Notes`)
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  third-party integration, port, or runtime dependency changes.

## 2. Planning Goal

- Shared contract owner: none. This story produces no new cross-lane interface.
- Contract-first phase required: NO — there is no contract to publish.
- Parallel execution possible: NO — single lane (Mobile), single phase.
- Critical path: P1.
- Parallelism notes: none.

### 2A. Scope Reality (read this before anything else)

The story title says "rollout". It is not a rollout. Per the resolved OQ-2 in
`../story_master.md` `## Open Question Impact` and `../architecture/solution.md`
AD-1/AD-2:

- The `--sky` primitive already exists (`CupidAppBackground` +
  `CupidSkyPalette`) and is already mounted **once** above the `Navigator` at
  `mobile/lib/app/cupid_app.dart:59`. `scaffoldBackgroundColor` is already
  `Colors.transparent`. **AC1 is already satisfied by shipped code.**
- The whole-app occlusion audit is already done (`../architecture/solution.md`
  section 3). It found **exactly two** occluders, and OQ-1 ratified **both** as
  permanent exceptions: `splash_screen.dart` (design-source-backed) and
  `gallery_viewer_screen.dart` (product-judgment media legibility).

Therefore the deliverable of this story is **verification and a durable
anti-regression guard**, not new production UI code.

**Expected production change surface: `mobile/lib/**` = ZERO files.** That is a
planned, ratified outcome, not an oversight. If P1's own re-check of the
allowlist contradicts this, P1 must stop and escalate (see
`coding-agent-guide.md` §3 rule 6) rather than silently editing `mobile/lib/`.

### 2B. Hard Constraints (highest-risk failure mode first)

1. **Do not add a second wash.** The single most damaging way to "implement"
   this story is to apply `CupidAppBackground` or a `--sky` gradient per screen.
   That double-paints the wash and reintroduces `BUG-20260815-002`. AD-1/AD-2
   forbid it. The wash is composition-root chrome; per-screen wiring is neither
   possible nor wanted.
2. **Do not remove either allowlisted opaque fill.** Both are ratified. Removing
   the gallery viewer's fill would be a *design reversal*, out of scope here.
3. **Do not point the existing runtime probe helper at an allowlisted screen.**
   It asserts `everyElement(isNull)` over all `Scaffold.backgroundColor` in the
   tree and would fail by design on splash and the gallery viewer.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|----------------------|-------|----------------|----------------|-----------------|
| (none) | — | — | — | — |

No cross-lane contract exists. The only durable interface this story creates is
the in-test allowlist constant inside
`mobile/test/design_system/shared_backdrop_occlusion_guard_test.dart`, which has
exactly one consumer: that same test.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in `../architecture/solution.md` section 5) | Required Dependency |
|---------------------------------------------------------------------|---------------------|
| Someone "implements" the story literally and adds a second wash per screen | P1 (blocked by `## 2B` constraint 1 + AC5) |
| Guard test written too broadly and flags legitimate component fills | P1 (root-level-only detector; AC2) |
| Guard test written too narrowly and misses a computed opaque fill | P1 (accepted limit, documented in the guard header; mitigated by the AD-5 runtime probes) |
| Allowlist becomes a dumping ground | P1 (each entry carries an inline rationale; AC3) |
| New probe fails on `everyElement(isNull)` inside nested shells | P1 (AD-5 blocking constraint; AC4) |
| Scope disagreement: AC2 "every screen" vs. the two-screen allowlist | RESOLVED before planning — OQ-1 ratified, AC2 patched. No phase dependency. |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `mobile-app` (`testCommand: flutter test`,
    `buildCommand: flutter build apk --debug`; the Flutter SDK is not on PATH on
    this machine — resolve it via `FLUTTER_SDK_PATH`, default `$HOME/flutter`,
    per the registry's `sdk` block). No DI registration, env var, port, or
    startup path changes; no production code changes at all. The change is fully
    covered by the test and static-analysis gates.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-backdrop-occlusion-guard-and-probes.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- P1 writes 2 test files (1 new, 1 extended) plus `test-results.md` and the AD-6
  visual evidence. That is well inside one specialist lifecycle (roughly six
  source/test files); no split is needed and none is permitted.
- No standalone contract phase exists: there is no cross-lane contract.
- No trailing verification/testing phase exists: P1 *is* the verification work,
  and it owns its own test, analysis, and build gates. Splitting AD-4 from AD-5
  from AD-6 would fragment one behavior cluster ("prove the shared wash is not
  occluded") across three dispatches for no added signal — explicitly rejected
  per `../architecture/solution.md` section 8.

## 6. Notes

- The story is classified `complex` on blast-radius grounds (a shared theme
  layer consumed by every screen). The audit collapsed that blast radius to
  zero production edits, so the *implementation* is one small phase while the
  *review* still deserves a full gate. Reviewer should judge this story against
  the OQ-2 corrected framing recorded in `../story_master.md`, not against the
  literal In Scope items 1-2 wording.
- The Rollout Note asks Tech Lead to choose verification breadth. That decision
  is made in `../architecture/solution.md` AD-5: **representative sample, not a
  37-screen pass**, because the AD-4 static guard already gives whole-inventory
  coverage of the failure mode and runtime probes exist only to cover
  composition classes a source scan cannot reason about. P1 must not expand the
  probe set beyond the four named targets without escalating.
- No new package dependency is permitted. The guard is a hand-rolled
  paren-depth scanner in the test file itself; `analyzer` is not a declared
  dependency of `mobile/pubspec.yaml` and must not be added for this story.
