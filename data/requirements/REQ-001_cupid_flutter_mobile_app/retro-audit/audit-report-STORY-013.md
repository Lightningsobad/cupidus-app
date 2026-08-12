# Retro Audit: STORY-013 Gallery Ảnh Chung (Shared Gallery)

BaseHead audited: `f7d06fd4737cc7edbe6f6e33c205bf77fdf26f67` (main)
Auditor: Reviewer (retro-audit), independent re-derivation — prior
review-report.md conclusions treated as claims to verify, not fact.

## AC-By-AC Traceability Table

| AC | Statement | Prior Review Verdict | Independent Re-Verification | Verdict |
|----|-----------|----------------------|------------------------------|---------|
| AC1 | A paired user can upload a photo to the shared gallery | PASS | Read `mobile/lib/features/gallery/presentation/screens/gallery_screen.dart` directly: both `onAddPhoto` call sites (`GalleryEmptyView` line 118, `GalleryGridView` line 137) call `_openUploadFlow(context)`, which constructs a real `GalleryUploadCubit` from `getIt<GalleryRepository>()` and calls `GalleryUploadSheet.show(context, cubit: uploadCubit)`, with `onUploaded` routed to `GalleryCubit.insertOptimistic`. This matches the P6-addendum fix (commit `324b1f3`, "BLOCKER-3 RESOLVED") and confirms the flow is reachable end-to-end from the mounted UI, not just unit-tested in isolation. `GalleryApi.uploadFile`/`createItem` confirm the two-step `POST /uploads` -> `POST /gallery` sequence matches the frozen (A1) backend contract. | **PASS** (confirmed) |
| AC2 | Both partners can view the shared gallery contents | DEFERRED (BLOCKER-1, backend) | Read `backend/src/modules/gallery/gallery.service.ts` directly on current `main`: `findAll(userId, ...)` calls `this.galleryRepository.find({ where: { userId }, ... })` — confirmed user-scoped, not couple-scoped; no `coupleId` field or join exists on `GalleryItem`. This backend gap is still present, unfixed, on `main` today. Read `mobile/lib/features/gallery/data/gallery_api.dart`: the only read path is a single `GET /gallery?limit=&offset=` call — no partner-scoped second fetch, no client merge, no id-substitution workaround. `gallery_cubit.dart`/`gallery_tile` badge logic derives attribution purely from `item.userId == currentUserId`, so the client is correctly built to render couple-scoped data with zero further mobile changes once the backend is fixed. A1 (backend contract freeze) forbids fixing this in-story. This is a genuine, disclosed, out-of-mobile-scope limitation, not a masked or silently-dropped AC — matches Core Rule 7 (pre-existing/out-of-scope defer, not block). | **DEFERRED** (confirmed, correctly disclosed — not a hidden failure) |
| AC3 | Unpaired users cannot access this feature | PASS | Read `mobile/lib/features/gallery/presentation/gallery_cubit.dart` directly: `_loadFirstPage()` calls `_repository.currentUser()` and emits `GalleryLocked()` immediately when `me.partnerId == null`, before any gallery fetch — no gallery data path is reachable in that branch. Read `mobile/lib/core/navigation/app_shell.dart` directly: `GalleryScreen` is mounted as a real, always-present bottom-tab destination (`_galleryTabIcon`, `CupidTabBarItem`), not a URL-only/hidden route — so the gate is reachable from real navigation, not just a widget test harness. Read `gallery_locked_view.dart` directly: uses a locally-defined `link_off` glyph (not `lock`/`fingerprint`), matching UX §4.5's "access-state, not encryption-state" requirement, with CTA labelled "Go to the pairing screen" for screen readers. | **PASS** (confirmed) |

Supplementary confirmation: `flutter analyze`/`flutter test` could not be
independently re-run in this audit environment (`flutter`/`dart` binaries are
not on `PATH` here). AC verdicts above are derived from direct source
inspection, not re-trusted from `test-results.md`'s narrative claims. The one
prior blocker with runtime-test dependence — BLOCKER-2 (design-system
no-fork-guard literals) — was independently re-checked by grepping the three
flagged files (`gallery_viewer_screen.dart`, `gallery_tile.dart`,
`gallery_upload_item.dart`) for `Colors.`, `Color(0x`, `Platform.is`,
`defaultTargetPlatform`: zero matches on current `main`, confirming the P6
fix (`CupidColorTokens.dark()` members) holds.

## Design Fidelity Section

Per the handoff, `data/requirements/REQ-001_cupid_flutter_mobile_app/integration-review/mobile-visual-audit.md`
is reused verbatim as the evidence source (no recapture performed).

- That audit captured 10 of 37 screens. Only two — `alarm` and `home` — were
  **fully reviewed** (both **FAIL**). `gallery` is **not** one of those two.
- `gallery` is in the "Captured, not yet reviewed" table: design render
  144 KB vs. implemented render 24 KB, ratio **6.0x**. The audit's own
  methodology note states a PNG-size ratio is "a weak proxy" used only to
  flag screens that likely warrant detailed review, and explicitly instructs
  the next reviewer to "review the eight outstanding pairs" (§ Recommended
  next steps, item 3) rather than treating the ratio as a verdict.
- Per the handoff's rule: **a missing or ratio-only render is UNVERIFIED,
  not PASS.**

**Gallery screen design-fidelity result: UNVERIFIED** (ratio-only,
weak-evidence bucket — not one of the two fully-reviewed FAIL screens, and
not independently pixel/structure-compared against
`cupid-app-design-system/` in this audit per the "do not recapture
screenshots" instruction).

The 6.0x size ratio for `gallery` is directionally consistent with the
pattern seen on the two fully-reviewed screens (`alarm` 1.0x — close match;
`home` 2.7x — not built to design) and with the other under-built ratio-only
screens (`antighost` 6.0x, `invite` 5.7x, `joincode` 5.0x, `pet` 6.9x,
`paired` 9.8x). A 6.0x gap is large enough to be a plausible real
under-build (e.g., a bare/harness-only render, missing chrome content, or an
empty-state render standing in for the populated grid) rather than noise,
but this audit cannot convert that suspicion into a verdict without an
actual side-by-side capture, which is out of scope here per the handoff.

**Per the handoff's rule, this UNVERIFIED row blocks GREEN/AMBER exactly
like a failed AC** — see Classification Impact below.

## Open Question Relevance Table

| OQ / Open Item | Story's Handling | Central Authority Trace |
|---|---|---|
| A1 (backend contract freeze) | Respected — no backend/OpenAPI edit; `Epic4PrivateGalleryApi` deliberately not used; confirmed by direct read of `gallery_api.dart` and current `gallery.service.ts`/`gallery.controller.ts` | `req_master.md` "Ngoài phạm vi" ("Thay đổi contract backend (A1)") — traceable to req_master.md |
| Open Item #1 — gallery model conflict ("shared" vs. design source's "Private Gallery") | Ruled (a): shared/backend model stands, Private Gallery is a separate out-of-scope future backlog item | **Not traceable** to the central OQ registry or req_master.md — see OQ Discipline Findings below |
| Open Item #3 — delete/report affordance | Ruled out of scope for STORY-013 (AC1-3 never included delete/report; this is a "never in scope" ruling, not a scope cut) | Story-level Product Owner artifact only (`requirements/requirements.md`); not a scope reduction since AC1-3 never claimed this, so central-registry traceability is lower-stakes here |
| R3 (libsodium FFI / local encryption) | Closed NO by Tech Lead ADR (`architecture/solution.md` D-1), evidenced directly against `uploads.controller.ts` (plaintext disk storage) and `app.module.ts` (unauthenticated static serving) | Traceable to `req_master.md`'s risk table (R3 row) — a risk-closure decision within Tech Lead's normal authority, not a scope-cut requiring central OQ sign-off |
| R4 (Android low-end perf) | Budget set by Tech Lead (`architecture/solution.md` D-2); measured statically in P5/test-results.md, not on a real device | Traceable to `req_master.md`'s risk table (R4 row) |

## OQ Discipline Findings

**Finding: Open Item #1 (gallery model conflict) was self-resolved by
Product Owner in a story-level artifact only, and never surfaced to the
central OQ registry or req_master.md.**

- The conflict is real and correctly identified: the design source's only
  epic-4 gallery screen is named "Private Gallery" and modeled as
  device-only/encrypted/single-partner (per `data/ux/system/ui_ux_system_memory.md`
  §8-§9), directly contradicting STORY-013's shared/backend/both-partners
  scope. `ux/uiux-spec.md` §8 explicitly flags this as needing "Tech Lead +
  Product Owner confirmation before coding-plan" and warns: "Do not
  silently pick a direction during implementation (same escalation
  precedent as system UX memory §7's DND/Critical-Alerts conflict)."
- The resolution ("Ruling: (a)... Private Gallery is a separate,
  out-of-scope backlog item") is recorded **only** in
  `STORY-013_gallery/requirements/requirements.md` (a story-level Product
  Owner artifact), and echoed in `ux/uiux-spec.md` and
  `architecture/solution.md`'s OQ tables — all three are downstream
  artifacts, not authoritative approval sources per the audit's scope-authority
  rule.
- I checked both authoritative locations directly:
  - `data/intake/bootstrap/conflicts_open_questions.md` (central OQ
    registry): no mention of "Private Gallery," "gallery model," or
    STORY-013's Open Item #1 anywhere in the file.
  - `req_master.md`: has no `## Open Question Triage` or `## Approved Scope
    Change` section at all; its only two Open Questions are OQ4 (offline
    storage, resolved via ADR-007) and OQ5 (light theme/EN locale, still
    open) — neither covers the gallery model conflict.
- **Inconsistency with sibling precedent**: the ux-spec explicitly cites
  "system UX memory §7's DND/Critical-Alerts conflict" as the escalation
  precedent to follow. That structurally identical conflict (D1/Critical-Alerts
  copy conflict) **was** escalated and **is** recorded in
  `conflicts_open_questions.md` under "Decisions Still Needed From The
  User." Open Item #1 was not given the same treatment despite its own spec
  citing that exact precedent.
- **Assessment**: this is a process/traceability gap, not evidence of a bad
  technical outcome. The ruling itself is well-reasoned (req_master.md's
  backlog row has always been named "Gallery ảnh chung" / shared gallery;
  no separate "Private Gallery" backlog row exists anywhere; the shared
  model is consistent with STORY-013's dependency chain on
  STORY-001/002/003 and its backend module list). No implementation actually
  builds toward the Private Gallery model — confirmed independently in
  `mobile/lib/features/gallery/`: no encryption, biometric, auto-lock, or
  screenshot-detection code exists. But per this audit's explicit rule, a
  scope-defining ruling recorded only in downstream/story-level artifacts is
  an unapproved-scope-cut pattern regardless of how sound the reasoning is,
  and it should have been escalated to the central registry the same way
  the sibling DND/Critical-Alerts conflict was.

No other OQ Discipline issue found. A1 is respected end-to-end and
independently confirmed against current backend source. R3/R4 closures are
within Tech Lead's normal ADR authority (risk-table items, not scope
conflicts) and are evidenced directly against backend source, not merely
asserted.

## Summary

- AC1: PASS (confirmed, direct source read — upload flow fully wired).
- AC2: DEFERRED (confirmed genuine, disclosed, backend-only blocker; not a
  masked or hidden failure; A1 forbids an in-story fix).
- AC3: PASS (confirmed, direct source read — pairing gate + real tab entry
  point + correct locked-state iconography).
- BLOCKER-2 (fork-guard literals): confirmed RESOLVED on `main`.
- BLOCKER-3 (upload flow unreachable): confirmed RESOLVED on `main`.
- Design Fidelity: **UNVERIFIED** — `gallery` was only ratio-captured (6.0x
  gap), not one of the two fully-reviewed screens in the reused mobile
  visual audit. Per the handoff's rule, this blocks GREEN/AMBER.
- OQ Discipline: one real finding — Open Item #1's scope ruling lacks
  central-registry/req_master.md traceability, despite the story's own UX
  spec citing the correct escalation precedent for exactly this situation.

Story-level Substantive Verdict: NEEDS_WORK
Classification Impact: RED-PATCH
REVIEW_COMPLETE: YES
