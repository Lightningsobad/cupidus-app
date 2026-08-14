# Review Report — STORY-026 Design Fidelity: Private Gallery

Outcome: BLOCKED

Review type: `compact-story-review` (round 1)
Story: STORY-026 / REQ-002_screen_flow_and_design_fidelity_audit
Complexity: `trivial` · Implementation Lane: `mobile`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-026`
Diff baseline: `12c427f` → `06fef3e`
Blocking findings: 2 · Deferred findings: 3

---

## Scope Gate

| Field | Value |
| --- | --- |
| Review report path | `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-026_private_gallery_design_fidelity/review/review-report.md` |
| Source files in scope | `mobile/lib/features/gallery/presentation/widgets/gallery_grid_view.dart`, `mobile/lib/features/gallery/presentation/widgets/gallery_tile.dart` |
| Test files in scope | `mobile/test/features/gallery/gallery_design_fidelity_test.dart`, `mobile/test/features/gallery/gallery_capture_entry.dart` |
| Evidence files in scope | `visual-fidelity/visual-fidelity-report.md`, `visual-fidelity/implemented-gallery-emulator-5560.png`, `REQ-001/STORY-018_design_fidelity_capture/visual-fidelity/design-reference-gallery-android.png` |
| Governing artifacts queried | `story_master.md`; `REQ-001/STORY-013_gallery/architecture/solution.md` (§1, §2, Open Question Constraints); `REQ-001/STORY-013_gallery/ux/uiux-spec.md` (§preamble, §2) |
| Entry-point verification | `mobile/lib/core/navigation/app_shell.dart` |
| Touched risk surfaces | mobile interaction, mobile navigation/discoverability, design-token/contract surface |
| Phase 2 | Proceeded; review completed and stopped at a governing-scope contradiction |

---

## Rationale

The implementation work in this story is sound and largely complete: ten real
design deviations were found and corrected in code against named design-source
lines, the fixes are token-based with no forks, and the rendered capture
confirms them. Static analysis and the targeted widget tests pass on re-run.

The story cannot close because two of its acceptance criteria rest on a premise
that approved upstream artifacts explicitly forbid. That is a contradiction in
the governing inputs, not a defect the mobile lane can patch, so this is a
`BLOCKED` gate awaiting a Product Owner ruling rather than rework.

Mobile-dev reached the same conclusion and self-reported
`VISUAL_FIDELITY: FAIL` with the conflict documented in §5.1 of the visual
fidelity report. That call is correct and is confirmed independently below.

---

## Blocking Findings

### B1 — AC1 and AC3 contradict the approved REQ-001 gallery scope

STORY-026 defines the screen as the "Private Gallery" at Level-1 data
sensitivity, and requires the lock/re-auth affordance be "present and styled
exactly per the design source" (AC3), with an exact match to the design
source's corresponding screen (AC1). The approved REQ-001 artifacts rule that
exact scope out. Verified verbatim:

| Artifact | Line | Text |
| --- | --- | --- |
| `REQ-001/STORY-013_gallery/architecture/solution.md` | 22 | "No client-side encryption, biometric unlock, auto-lock, or screenshot detection." |
| same | 44 | "Level-1 device-only encryption / biometric / auto-lock / screenshot-detection UI is BLOCKED" |
| same | 60 | Open Item #1 — "Resolved (Product Owner) … Shared model only" |
| same | 62 | R3 — "**Closed by this solution — NO**" |
| `REQ-001/STORY-013_gallery/ux/uiux-spec.md` | 11-18 | the canvas screen "is modeled as Level-1, device-only, single-partner encrypted storage — a different feature shape than this story's confirmed scope" |
| same | 51-55 | the lock/fingerprint-unlock gate, the auto-lock countdown banner, and the screenshot-detection notice are "**Explicitly not reused**" |

The shipped screen is a *shared* gallery — the implemented capture is titled
"Gallery chung" — which is the feature REQ-001 actually approved. Rendering the
design source's lock ceremony would display AES-256 / Secure Enclave /
auto-lock / screenshot-detection claims for capabilities the product does not
have. Mobile-dev was right to refuse; the story's own Out of Scope line also
bars touching re-auth logic.

This is not confined to AC3. AC1's "match exactly with no visible deviation"
against "`cupid-app-design-system`'s corresponding screen" is unsatisfiable for
the same reason: the corresponding canvas screen is a private/locked gallery,
and the app screen is a shared gallery by approved design.

Needs a Product Owner ruling — see Action Items.

### B2 — No valid design reference exists for the audited screen state

Rule 12e3 requires the reference image to depict the same screen state as the
implemented capture. It does not.

I opened both images. The implemented capture
(`visual-fidelity/implemented-gallery-emulator-5560.png`) is a real, clean
render of the open grid in the built app — no error frame, no spinner, no wrong
screen. The only design reference that exists for `Design-Screen: gallery` is
`REQ-001/STORY-018_design_fidelity_capture/visual-fidelity/design-reference-gallery-android.png`
(a byte-identical copy also sits under
`REQ-001/integration-review/mobile-screenshots/`), and it renders the
`galleryLocked` branch: lock glyph, "Chỉ mình bạn mở được", AES-256/Secure
Enclave copy, and the fingerprint unlock CTA.

The two images are different `<sc-if>` branches of the same canvas screen, so
no meaningful pixel comparison for the delivered state is possible. Mobile-dev
disclosed this accurately in §5.2 and compared value-by-value against the
`galleryOpen` source block (L736-751) instead — a reasonable fallback, but not
the rendered comparison the gate requires.

Secondary to the same root: the story's own `visual-fidelity/` directory holds
only `implemented-gallery-emulator-5560.png`. Rule 12e3 expects
`design-reference-<screen>-<device>.png` alongside it.

B2 cannot be resolved by re-rendering. A reference for the open-grid state can
only be produced once B1 settles which state is authoritative for this app.

---

## Gates Verified

| Gate | Result | Evidence |
| --- | --- | --- |
| Rendered capture is real and shows this story's screen | PASS | Opened `implemented-gallery-emulator-5560.png` — rounded 16 corners, elevation shadow outside the clip, bottom-left mono caption pill, top-right uploader badges, dashed add tile with pink `add_photo_alternate` glyph over "Thêm ảnh". Matches report §2/§3 claims |
| `Design-Screen` recorded and resolved | PASS | `Design-Screen: gallery`, registry entry L1885, predicate L2251 |
| Rendered design-fidelity comparison | FAIL → B2 | reference depicts the locked branch, not the audited open grid |
| Entry point reachability | PASS | Verified directly in `mobile/lib/core/navigation/app_shell.dart:19,36-38` — Gallery is an always-present `CupidTabBar` destination mounting `GalleryScreen`. Discoverable via bottom nav, not URL-only. AC4 holds |
| Static analysis | PASS | Re-ran `flutter analyze lib/features/gallery test/features/gallery` → 1 pre-existing `info` (`use_null_aware_elements`, `gallery_api.dart:88`, untouched file). Nothing in changed files |
| Targeted widget tests | PASS | Re-ran `flutter test test/features/gallery/gallery_design_fidelity_test.dart` → 5/5 passed |
| Design-token fork guard | PASS | No design-system file touched; all fixes consume existing `CupidSpacing` / `CupidColorTokens` / `CupidPlatformTokens` / `CupidTypographyTokens` |
| Runtime startup smoke (12g) | NOT REQUIRED | `story_master.md` records `Complexity: trivial` |
| Configuration-guide impact (12a) | NOT REQUIRED | pure presentation-layer change; no env, permission, or setup surface touched |

### Code review of the delivered fixes

D1-D10 were each checked against the diff and are real, correctly scoped, and
traceable to cited design-source lines. Two are worth naming:

- **D3** is a genuine rendering bug, not a token swap. The shadow
  `DecoratedBox` was nested *inside* the corner `ClipRRect`, so every gallery
  tile shipped with its elevation clipped away entirely. The fix moves the
  shadow outside the clip (`gallery_tile.dart`, hunk `@@ -94,16 +94,22 @@`).
- **D2** corrected `colors.glowShadow` (the pink CTA glow, `--glow`) to
  `platform.elevationShadow` (`--shadow`) — the wrong token had been applied.

No correctness, security, lifecycle, or regression risk found in the changed
code.

---

## Deferred Findings

- **D-1 — spacing snapped to the token scale, not matched exactly.** Grid
  bottom padding 40→32 (−8), gutters 11→8 (−3), add-tile label 11.5→13 (+1.5).
  These are deliberate, documented snaps chosen over literal forks to satisfy
  `no_fork_guard_test.dart`. They are defensible, but AC1 as written demands
  no visible deviation, so the token-scale-vs-raw-px tension should be settled
  by the same ruling that resolves B1 rather than patched blind.
- **D-2 — `_addPhotoAlternateIcon` (`0xe43e`) declared file-locally** in
  `gallery_grid_view.dart` instead of `CupidIcons`, because this story's
  `WriteScope` excludes `design_system/icons/cupid_icons.dart`. Same pattern
  already exists at `app_shell.dart:31`. Clean follow-up for whichever story
  owns the design-system icon set.
- **D-3 — evidence report says "6 widget tests"** for
  `gallery_design_fidelity_test.dart`; the file contains 5. Cosmetic. The
  `strokeWidth 2 → 1.5` change (D7) is the one fix with no pinning test.

---

## Action Items

**Owner: Product Owner (required first — B1)**
Rule on the AC1/AC3 premise. One of:
1. Amend STORY-026 to target the *shared* gallery as approved by REQ-001,
   dropping AC3 and rescoping AC1 to the `galleryOpen` canvas block; or
2. Drop AC3 and mark the lock ceremony out of scope pending a separate
   requirement that builds real Level-1 protection; or
3. Open that Level-1 protection requirement first and park STORY-026 behind it.

Option 1 or 2 makes the already-delivered code closeable. Option 3 does not.

**Owner: Mobile Developer (only after the ruling — B2)**
- Produce or designate a design reference for the state the ruling makes
  authoritative, and place both images under the story's own
  `visual-fidelity/` as `implemented-gallery-emulator-5560.png` and
  `design-reference-gallery-<device>.png`.
- Re-run the comparison and update `visual-fidelity-report.md` to a verdict
  based on that rendered pair.
- Add a `## Entry Point Reachability` section with `Reachable: YES` and the
  `app_shell.dart` tab path to the story's evidence. The entry point itself is
  correct and verified above; only the written record is absent (the story is
  `trivial`, so it carries no `coding-plan/test-results.md`).

**Owner: Scrum Master (housekeeping)**
The handoff declared `Story-Class: standard`; `story_master.md` records
`Complexity: trivial` / `Story-Class: trivial`. The mismatch changes whether the
12g runtime-startup-smoke gate applies. Reconcile before the next round.

---

## Traceability

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — exact match to design source, dark + `vi` | BLOCKED | corresponding canvas screen is a private/locked gallery; app screen is the approved shared gallery (B1). Token-snap deltas also open (D-1) |
| AC2 — deviations corrected in the app, not documented | PASS | D1-D10 verified in the diff; rendered capture confirms |
| AC3 — Level-1 lock affordance present and styled | BLOCKED | forbidden by `solution.md:22,44,60,62` and `uiux-spec.md:51-55` (B1) |
| AC4 — no new entry point required | PASS | `app_shell.dart:19,36-38`, existing tab destination unchanged |

Open Question: OQ5 (light theme / `en` locale) correctly treated as out of
scope; only dark + `vi` was audited and captured, per the story's Out of Scope
section. No OQ triage defect found.

---

## State Recommendation

- Leave `Implementation (Development)` unchecked.
- Leave `Review (Reviewer)` unchecked.
- Story status: `BLOCKED`, pending the Product Owner ruling in B1.
- Do not route back to Mobile Developer until that ruling lands — the
  implementation lane has no remaining action it can take unilaterally.
