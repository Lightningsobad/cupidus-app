# Story Master: STORY-026 Design Fidelity — Private Gallery

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: "Private Gallery" (design-registry label), canvas id `gallery`, Epic 4
(Shared relationship growth) — REQ-001 shipped this as the shared/backend
gallery model, not a Level-1 device-only model. See Product Owner Ruling
below.
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`) — only the `galleryOpen` state block is a valid
comparison target for this story; see Out of Scope.

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a paired user viewing our shared gallery, I want the screen to match the
design source's open/shared-grid state exactly, so the shared-photo
experience feels visually polished and trustworthy.

## In Scope
1. Re-audit the current Private Gallery screen against
   `cupid-app-design-system`'s `galleryOpen` state block for the enabled
   dark theme + `vi` locale configuration: grid/list layout, spacing,
   color/design-token usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source's `galleryOpen` state exactly — this is
   a fix, not an audit report.
3. Confirm no Level-1 lock/re-auth affordance is rendered on this screen,
   consistent with the shared/backend gallery model REQ-001 actually
   approved and shipped; the existing pairing gate
   (`gallery_locked_view.dart`, unpaired-access state) is unchanged by this
   story.

## Out of Scope
- Any new feature, new screen state, or new interaction not already present
  in the `galleryOpen` design source state.
- The design source's `galleryLocked` state (lock/re-auth gate, AES-256 /
  Secure Enclave copy, "auto-locks in 60s" countdown banner,
  screenshot-detection notice) is out of scope entirely and must not be
  built. REQ-001 Open Item #1 was formally resolved as "Shared model only"
  (`REQ-001_cupid_flutter_mobile_app/STORY-013_gallery/architecture/solution.md`
  lines 22, 44, 60, 62 — D-1/R3: no client-side encryption, biometric
  unlock, auto-lock, or screenshot detection), and
  `STORY-013_gallery/ux/uiux-spec.md` §2 (lines 51-55) explicitly excludes
  that lock ceremony from reuse. Rendering it would assert security
  properties (device-only encryption, biometric unlock, auto-lock,
  screenshot detection) the app does not have. A real Level-1 protected
  gallery, if the business wants one, is a distinct future feature requiring
  its own requirement with a genuine encryption/auth architecture — not a
  design-fidelity fix inside this story.
- Any change to the underlying re-auth/PIN-gate or pairing-gate logic
  itself — this story covers only the visual treatment of the
  `galleryOpen` state, not authentication or access-control implementation.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the Private Gallery screen rendered in the enabled dark theme +
   `vi` locale, when compared against `cupid-app-design-system`'s
   `galleryOpen` state block (the only state REQ-001 approved and shipped
   for this screen — the `galleryLocked` state is not a valid comparison
   target, see Out of Scope), then layout, spacing, color/token usage, and
   typography match with no visible deviation, where a match means each
   design-source value resolves to its nearest existing design-system token
   per the no-fork-guard convention (`no_fork_guard_test.dart`) rather than
   a literal forked pixel value.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the shared/backend gallery model REQ-001 approved (Open Item #1:
   "Shared model only"), when the screen is rendered, then no Level-1
   device-only lock/re-auth/auto-lock/screenshot-detection affordance is
   present or added by this story, and the existing pairing gate remains
   the sole access-control affordance on this screen, unchanged.
4. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## Product Owner Ruling (2026-08-14)

Round-1 review (`review/review-report.md`, Outcome: BLOCKED, findings B1/B2)
found AC1/AC3 as originally written required an exact match to the design
source's `galleryLocked` state — a Level-1 device-only encrypted/re-auth
gallery. That state was never approved to be built: REQ-001's
`STORY-013_gallery/architecture/solution.md` explicitly closed Open Item #1
as "Shared model only" and blocked client-side encryption, biometric unlock,
auto-lock, and screenshot detection (D-1/R3); `STORY-013_gallery/ux/uiux-spec.md`
§2 explicitly excludes the lock/unlock gate, auto-lock banner, and
screenshot notice from reuse, and mandates a visually distinct pairing-gate
icon (`link_off`, not `lock`) specifically so users don't confuse "not
paired yet" with "authenticate to unlock." The shipped screen is the
approved shared gallery ("Gallery chung").

Ruling: Option 1 from the review's Action Items. AC1 is rescoped to the
`galleryOpen` state only, AC3 is amended to require the *absence* of the
Level-1 lock affordance (consistent with the approved shared model) rather
than its presence, and the `galleryLocked` state is recorded as out of
scope with rationale above. This also resolves the review's deferred D-1
(token-scale vs. raw-px): AC1's "match" is now explicitly defined as
nearest-design-token matching, so the already-delivered spacing snaps are
compliant by definition, not a pending question.

This does not authorize building a real Level-1 protected gallery under
this story or this requirement. If the business wants that feature, it
needs its own requirement with a real encryption/auth architecture; this
story's scope stops at correcting the shared-gallery screen's visual
fidelity.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Private Gallery screen,
  already reachable in the shipped app.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
OQ5 (light theme / `en` locale) only affects out-of-scope light/`en`
user-facing visual QA per this story's Out of Scope section; it does not
block any in-scope acceptance criterion.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-4) are unblocked.

## Scrum Master Disposition — 2026-08-14 (round-2 review F1)

Round-2 review (`review/review-report.md`, Outcome: PATCH_REQUIRED, F1) held
one blocking finding: `visual-fidelity/visual-fidelity-report.md` needed a
real two-image comparison for the `galleryOpen` canvas state plus disclosure
of the caption-format and uploader-badge deltas as app extensions. AC2/AC3/AC4
already PASS and AC1 value-match was already verified against the design
source; F1 was an evidence-completeness gap, not an unresolved AC.

The round-3 evidence commit added §3A "Disclosed App Extensions" (E1 column
count, E2 caption date format, E3 uploader badge — each cited against the
uiux-spec/design source) and recorded `BLOCKER:
DESIGN_CANVAS_STATE_FORCE_UNSUPPORTED` in §8.1: `render-design-canvas.js`
can only drive the canvas's `[data-screen-btn]`/`[data-tog]` controls
(screen selection, dark/light, vi/en); `galleryOpen` is reachable only via
the in-frame `doUnlock` CTA, which the tool has no affordance to trigger, so
no live two-image render of that exact state is currently producible.

Ruling: GRANTED — explicit exemption for the live-rendered
design-reference-vs-implementation screenshot pair for the `galleryOpen`
state, conditioned on the already-satisfied requirements: (a) AC1's
value-level match is independently verified against the design source
(confirmed by round-2 review), and (b) all deltas from the design source are
disclosed with citations (§3A, confirmed present). This exemption covers only
the *rendering-tool* limitation; it does not waive AC1's substantive match
requirement, which remains reviewer-checked against the design source values
directly. `visual-fidelity-report.md` must keep `Design-Reference-Render:
BLOCKED` (not silently deleted or reported as a completed render) so the gap
stays visible in the artifact.

Follow-up (non-blocking, tracked outside this story): `render-design-canvas.js`
should gain a way to force arbitrary `sc-if`/unlock app states (not just the
existing screen/theme/locale toggles) so future stories needing a locked or
gated canvas state don't hit the same limitation. File this as a tooling note
for DevOps/Tech Lead rather than reopening STORY-026 scope.

This story is review-ready again: round-3 (evidence-only, no source/test
changed) closes F1. Next: Reviewer, scoped to the diff since the round-2
`review_base_head` (`c0bfbcf`) through the round-3 closure commit.
