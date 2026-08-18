# STORY-052: Chat Header Partner Pairing + Presence Chip

Status: DONE
Retro-Type: RED-PATCH
Fixes: STORY-018_chat_typing_ghost_design_fidelity
Complexity: standard
Story-Class: standard
Implementation Lane: shared (ui-ux-designer avatar/presence slot spec, then
tech-lead component contract, then backend-dev `GET /users/me`
`partnerDisplayName` field expansion, then mobile-dev consumption +
`ChatPartnerStore` split — expanded from mobile-only per BLK-052-1
disposition R2, see Product Owner Triage)

## Artifacts

- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md` written: pixel-exact
  presence-chip spec transcribed from `Cupid Screens.dc.html`'s
  `showPartnerChip` block, new-token flag for the `#00C9A7→#7B2FBE` avatar
  gradient, and the finding that the chip is partner-scoped (already
  synchronous via `ChatPartnerStore`), not self-scoped.
- [x] Architecture (Tech Lead) — `architecture/solution.md` (BLK-052-1
  resolved per PO's R2 disposition) + `architecture/contract-summary.md` +
  `coding-plan/` bundle (master-plan.md, coding-agent-guide.md, phase-P0
  backend, phase-P1 mobile identity plumbing, phase-P2 mobile header slot +
  chip), verified complete against the coding-plan completion gate by
  Scrum Master.
- [x] Implementation (Development) — P0 backend (`22e4a0d`), P1 mobile
  identity split (`ecf1303`), P2 mobile header slot + presence chip +
  visual-fidelity evidence (`6b71078`). All disk-verified and independently
  re-run by Scrum Master, not trusted from specialist reports alone.
- [x] Review (Reviewer) — `review/review-report.md` final synthesis,
  `Outcome: DEFERRED_ONLY`, `REVIEW_COMPLETE: YES`. Both slices PASS (AC1-AC7
  all MET); slice 2's 2 blocking evidence-only findings (missing Entry Point
  Reachability + Story Runtime Startup Smoke sections) closed same-story by
  a real production runtime smoke. D-1 (`↔` emoji-tile render) split to
  `RWB-20260816-026` per the reviewer's required pre-DONE action.

## Background (Rework Item)

Source: `data/retro-audit/rework-backlog.md` — RWB-20260816-017, split out of
`STORY-040_chat_typing_ghost_design_fidelity_hardening`'s reviewer finding
R-1 while re-verifying that story's own evidence pair.

The design reference for the `chat` screen renders `Minh ↔ Linh` plus a
`đang online` presence chip at top-right of the header; the implemented
capture renders `Linh` alone with no presence chip. Root cause is
pre-existing and documented in code at `chat_screen.dart:164-169`:
`CupidHeader` exposes a title string only, with no avatar/presence slot, and
was reused as-is rather than reopening a frozen shared component. Not a
STORY-040 regression and not blocking there: the delta pre-dates that
hardening pass, and correcting it means touching `design_system/adaptive/`,
outside a chat-screen story's natural WriteScope either way. The defect
flagged by the reviewer was disclosure only — STORY-040's out-of-scope
enumeration had omitted this delta.

Exact remediation suggested by the surfacing reviewer: UI/UX Designer +
design-system owner to give `CupidHeader` an optional avatar/presence slot
(or an equivalent adaptive variant), then update `chat_screen.dart`'s header
composition to pass the partner pairing (`Minh ↔ Linh`) and online-presence
state, scoped as its own story rather than folded into a future chat
hardening pass.

`CupidHeader` is a shared `design_system/adaptive/` component. Product
Owner and Tech Lead must confirm whether any other screen currently
consuming `CupidHeader` needs the new slot to stay optional/backward
compatible (default: no visible change when the new slot is unset), so this
story does not regress any other `CupidHeader` consumer.

## Product Owner Triage

- `CupidHeader` (`mobile/lib/design_system/adaptive/cupid_header.dart`) is
  consumed by 17 `lib/` call sites today — `chat_screen.dart` plus 16 other
  screens/widgets (`love_contract_screen.dart`, `timeline_screen.dart`,
  `vibe_screen.dart`, `reminder_schedule_screen.dart`,
  `love_contract_entry_tile.dart`, `expense_history_screen.dart`,
  `dream_jar_list_screen.dart`, `dream_jar_detail_screen.dart`,
  `contribution_history_screen.dart`, `ghost_settings_screen.dart`,
  `anti_ghost_screen.dart`, `profile_edit_screen.dart`, `privacy_screen.dart`,
  `notification_settings_screen.dart`, `me_screen.dart`, `gallery_screen.dart`),
  plus test coverage in `adaptive_widgets_test.dart` and
  `gallery_capture_entry.dart`. Confirmed: the new avatar/presence slot must
  be optional with a safe default so every one of these 16 other consumers
  keeps rendering exactly as today when it does not pass the new param(s).
- Presence signal check (app-wide): the only "presence" hit outside this
  story's own artifacts is `design_system/tokens/couple_presence_palette.dart`,
  which is a static color-gradient token pair for the Home dashboard's
  avatar fills — not an online/offline computation. No presence/last-seen
  realtime event exists in `core/realtime/realtime_event.dart` or elsewhere.
  Disposition (per the handoff's guidance): `đang online` ships as a fixed
  v1 stub label matching the locked design source's always-visible chip, not
  wired to any real online/offline signal. This story does not add a
  presence backend/realtime feature.
- Partner-pairing text check: the partner half (`Linh`) is already wired via
  `ChatPartnerStore.displayName` (synchronous, session-scoped). The self half
  (`Minh`) is **not** currently plumbed into `ChatScreen` — the only existing
  source is `AccountRepository.fetchProfile()`, an async network call with no
  existing session-scoped/synchronous cache the chat screen can read the way
  it reads the partner name. Reusing existing profile data (not inventing a
  new backend endpoint) is required, but *which* existing cache/store to read
  it from, and what to render before it resolves, is an architectural
  decision, not a UI-only one.
- Tech Lead: **REQUIRED**, not `SKIPPED:trivial`. Two reasons: (1) this adds a
  new optional parameter surface to a 17-call-site shared component contract,
  not a single-token swap like STORY-051, so the backward-compatibility
  guarantee and default-value shape need an explicit contract decision; (2)
  sourcing the self display name touches session/data-store architecture
  (which existing cache to reuse, load-before-ready behavior), which is Tech
  Lead scope.

### BLK-052-1 Disposition (2026-08-18)

Tech Lead's `architecture/solution.md` `### Key Discovery` found the data-
source premise above is **inverted**: `ChatPartnerStore.displayName` reads
`GET /users/me`, i.e. the signed-in user's own name, mislabeled as "the
paired partner's display name" — verified directly against
`backend/src/modules/users/users.controller.ts:14-19`
(`findByFirebaseUid(req.user.uid)`, the caller's own row) and
`mobile/lib/core/di/service_locator.dart:70-75,311-314`, which already
documents partner-name as unresolvable and registers it as `() => null`. So
it is the **partner** half of the pairing string (not the self half) that has
no real data source today, and `ux/uiux-spec.md` §"Finding" confirms the
presence chip's avatar-initial and its combined accessibility label need that
same missing partner identity — BLK-052-1 blocks AC1's partner half and all
of AC2's chip identity content, not just the title.

Decision: **R2** — expand this story to the `shared` lane. Add
`partnerDisplayName` to the **existing** `GET /users/me` response (a field
expansion on an existing endpoint, not a new endpoint — holds my original
"reuse existing profile data, no new backend endpoint" constraint), regenerate
the mobile API client, and split `ChatPartnerStore.displayName` into
`selfDisplayName` + `partnerDisplayName`.

Reasoning:
- **R1 rejected.** Self-name-only would leave AC1 not matching the locked
  design source (RWB-20260816-017 stays open) *and* still can't produce a
  coherent AC2 presence chip — `ux/uiux-spec.md` confirms the chip's avatar
  initial and label need the partner's identity specifically, so R1 doesn't
  even fully unblock AC2. R1 closes this story without closing the rework
  item it exists to fix.
- **R3 rejected.** Splitting into a prerequisite backend+mobile story plus a
  dependent fidelity story adds a second full delivery/review cycle for what
  Tech Lead scoped as a narrow, well-understood field expansion (the `User`
  entity already carries `partnerId`; the service only needs to look up that
  row and serialize its `displayName`) — disproportionate process overhead
  for a LOW-severity, already-twice-deferred rework item.
- **R2 is the only option that closes RWB-20260816-017 with real data**, and
  it removes the pre-existing latent defect Key Discovery item 3 found (today's
  chat header, `GhostBubble`, and `ChatComposer` all render the self name
  where the partner's name is visually intended) as a side effect of
  correcting the data source this story already has to touch.
- On `GhostBubble`/`ChatComposer`: their own display-fidelity is **not** added
  to this story's Acceptance Criteria (Tech Lead's technical out-of-scope
  stands) — no new visual re-audit of those two widgets is required here.
  However, once `ChatPartnerStore` is split, `chat_screen.dart`'s existing
  `partnerDisplayName:` arguments into `GhostBubble`/`ChatComposer`
  (`chat_screen.dart:249,270`) should be pointed at the new correct
  `partnerDisplayName` getter rather than continuing to pass the old
  (self-name) value — leaving them wired to a value now provably wrong, in
  the same file this story already edits, would be a worse state than today.
  This is a small correctness fix that falls out of the split, not a new
  testable AC. Flagging for Scrum Master: consider filing a separate LOW
  disclosure/rework item if a full design-fidelity re-audit of `GhostBubble`/
  `ChatComposer` is wanted later — not requesting one myself here.

## In Scope
1. Add an optional avatar/presence slot to `CupidHeader`
   (`design_system/adaptive/`) as new optional constructor parameter(s), so
   all 16 other existing consumers compile and render unchanged when they do
   not pass the new param(s).
2. Backend: add a `partnerDisplayName` field to the existing `GET /users/me`
   response, sourced from the paired partner's real `User.displayName` (field
   expansion on an existing endpoint — see BLK-052-1 Disposition; not a new
   endpoint).
3. Mobile: regenerate the API client for the expanded `/users/me` response,
   and split `ChatPartnerStore.displayName` into `selfDisplayName` +
   `partnerDisplayName`, both real backend-sourced values.
4. Update `chat_screen.dart`'s header composition to render the partner
   pairing text in the design source's `Minh ↔ Linh` format, using the new
   `ChatPartnerStore.selfDisplayName` + `partnerDisplayName`.
5. Render a presence chip in the chat header's top-right per
   `ux/uiux-spec.md` §1: partner avatar-initial, online-status dot, and the
   fixed v1 stub label `đang online` — the identity content (avatar initial,
   accessibility label) is sourced from the real partner display name; only
   the online/offline status itself is a fixed stub, not backed by any real
   presence computation.
6. Verify all 16 other existing `CupidHeader` consumers render with no
   visible change after the slot addition (regression check).

## Out of Scope
- Any real-time/backend presence feature (actual online/offline detection,
  last-seen timestamps, presence realtime events) — no such capability
  exists in the app today and this story does not add one; only the identity
  data (partner display name) is real, the online/offline state stays a
  fixed stub.
- Any change to `CupidHeader`'s existing `title`, `onBack`, `backLabel`, or
  `actions` contract, or to its back-affordance/title styling — only
  additive, optional avatar/presence slot(s).
- Wiring the new avatar/presence slot into any screen other than `chat` —
  this story updates `chat_screen.dart` only; the other 16 consumers keep
  using the title-only path unchanged.
- A new `/users/*` endpoint — this story extends the existing `GET /users/me`
  response shape only.
- Re-auditing `GhostBubble`'s or `ChatComposer`'s own design fidelity — see
  BLK-052-1 Disposition: their `partnerDisplayName:` argument should be
  repointed at the corrected store field as a byproduct of the
  `ChatPartnerStore` split, but a full visual re-verification of those two
  widgets is not required by this story.
- STORY-051's token change, light-theme/OQ5 scope, and chat bubble colors —
  already DONE, separate story.
- Typing Ghost consent/toggle behavior — untouched, already covered by
  STORY-018/STORY-040.

## Acceptance Criteria
1. Given a paired user calls `GET /users/me`, then the response includes a
   `partnerDisplayName` field populated from the partner's real
   `User.displayName`, and the existing self-identity field shape is
   otherwise unchanged.
2. Given the chat screen rendered in the enabled dark theme + `vi` locale,
   when compared against the locked design source, then the header shows the
   partner pairing text in `<self display name> ↔ <partner display name>`
   format, both sourced from real backend data — not a preview-fixture
   stand-in and not the caller's own name duplicated on both sides.
3. Given the same chat screen render, then a presence chip is visible at the
   header's top-right showing the partner's avatar initial, an online-status
   dot, and the fixed v1 stub label `đang online`, matching
   `ux/uiux-spec.md` §1; the avatar initial is derived from the real partner
   display name, not the caller's own name.
4. Given the presence chip's `Semantics` node, when read by assistive
   technology, then it announces one coherent label (e.g. `"<partner display
   name> đang online"`) per `ux/uiux-spec.md` §4, and the pairing title's
   `Semantics` label uses a natural phrase in place of the `↔` glyph.
5. Given any of the 16 other existing `CupidHeader` consumer
   screens/widgets, when rendered without passing the new avatar/presence
   slot, then each renders exactly as it did before this story — no visible
   regression.
6. Given the shared `CupidHeader` component contract, when the new
   avatar/presence slot is added, then the existing `title`, `onBack`,
   `backLabel`, and `actions` parameters are unchanged and the new
   parameter(s) are optional with a safe (no-visible-change) default.
7. Given the chat screen is reached through its existing normal navigation
   path, when a user arrives, then no new entry point is required — this
   story does not change how the screen is reached.
