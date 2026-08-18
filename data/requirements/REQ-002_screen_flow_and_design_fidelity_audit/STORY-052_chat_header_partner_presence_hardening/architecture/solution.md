# STORY-052 Architecture Solution — Chat Header Partner Pairing + Presence Chip

Status: ACTIVE (BLK-052-1 resolved 2026-08-18 — Product Owner chose R2)

## 0. Metadata

- Complexity: standard
- Date: 2026-08-18
- Run mode: `compact-story-plan`

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: additive change to a 17-call-site shared design-system
  component; sourcing two identity strings for the header title and chip.
- Architectural invariants / non-goals: `CupidHeader`'s `title`/`onBack`/
  `backLabel`/`actions` contract is frozen; no presence backend/realtime
  feature; no raw color literal in `lib/features` (ADR-004,
  `test/design_system/no_fork_guard_test.dart`).
- Proposed technical direction: one new optional `Widget? trailing` slot on
  `CupidHeader` defaulting to `null`; the chip itself is a chat-feature widget;
  one new additive gradient token file.
- Why this fits: mirrors the existing additive-token precedent
  (`couple_presence_palette.dart`) and the existing pill recipe
  (`_PrivacyChip`, `chat_screen.dart:284-331`).

### Key Discovery

**The data-source premise in both `story_master.md` § Product Owner Triage and
`ux/uiux-spec.md` § Finding is inverted.** The partner display name — not the
self display name — is the half with no source in the app.

Evidence chain:

- `backend/src/modules/users/users.controller.ts:14-19` — `GET /users/me`
  returns `findByFirebaseUid(req.user.uid)`, i.e. the **caller's own** `User`
  row.
- `backend/src/modules/users/entities/user.entity.ts:15,33` — `displayName` is
  that caller's own name; `partnerId` is a bare UUID with no name expansion.
- `mobile/lib/features/love_contracts/data/love_contract_gate_repository.dart:29-35`
  reads that same `/users/me` `displayName` key and correctly names it
  `myDisplayName`.
- `mobile/lib/features/chat/data/chat_partner_store.dart:31-39` populates
  `_displayName` from the identical key, but its dartdoc (line 23) labels it
  "The paired partner's display name". **The label is wrong; the value is the
  self name.**
- `mobile/lib/core/di/service_locator.dart:70-75,311-314` independently
  documents that "the partner's `displayName` is not resolvable from the frozen
  backend" and registers `PartnerDisplayName` as `() => null`.
- No `partnerName` / `partnerDisplayName` field exists anywhere in
  `backend/src`. The only endpoint that ever returns another user's name is
  `backend/src/modules/invitations/invitations.service.ts:79-85`
  (`inviter.displayName`, at invite-validation time); no mobile code reads or
  persists it (`mobile/lib/features/pairing/**` has zero `displayName` hits).

Consequences:

1. AC1 `<self> ↔ <partner>`: the **self** half is already synchronous
   (`ChatPartnerStore.displayName`); the **partner** half cannot be rendered
   from real data at all.
2. AC2 / `uiux-spec.md` §1.4 and §4: the chip's avatar initial and its combined
   accessibility label are both derived from the partner display name, so they
   inherit the same gap.
3. Pre-existing latent defect (disclosure only, out of scope here): today's
   chat header title (`chat_screen.dart:166-169`), `GhostBubble`
   (`ghost_bubble.dart:118-128`) and `ChatComposer`
   (`chat_composer.dart:157-179`) all render the signed-in user's **own** name
   where the partner's name is intended. RWB-20260816-017's premise that "the
   implemented capture renders `Linh` alone" is explained by the preview
   fixture `_PreviewChatPartnerStore(displayName: …)`
   (`main_preview.dart:732-749`), not by real partner sourcing.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` — the expanded
  `GET /users/me` payload, produced by the backend lane (P0) and consumed by
  the mobile lane (P1).

## 3. Scope And Assumptions

- In Scope (technical): `backend/src/modules/users/` (one field expansion on
  the existing `GET /users/me`), `mobile/lib/features/chat/data/`
  (`ChatPartnerStore` self/partner split), `mobile/lib/design_system/adaptive/`
  (additive optional slot), one new `design_system/tokens/` gradient file, one
  new chat-feature chip widget, `chat_screen.dart` header composition.
- Out Of Scope (technical): new endpoints or modules, realtime/presence
  computation, partner search, the other 16 `CupidHeader` consumers.
- Assumptions affecting design: `preferredSize` stays `kToolbarHeight` (chip is
  34dp tall: 24dp avatar + 5dp/5dp padding); the three existing `/users/me`
  readers keep reading the raw JSON map via `Dio`.

### BLK-052-1 Disposition

Resolved 2026-08-18 — Product Owner chose **R2**: expand `GET /users/me` with
`partnerDisplayName` and split `ChatPartnerStore.displayName` into
`selfDisplayName` + `partnerDisplayName`. Story lane becomes `shared`
(backend-dev then mobile-dev). R1 and R3 rejected by PO.

### Generated API Client — Regeneration Is Not Required

`mobile/openapi/cupid_api/lib/src/api/epic1_users_api.dart:33` declares
`usersControllerGetProfile` as `Future<Response<void>>`: `UsersController`
(`users.controller.ts:14-19`) carries `@ApiOperation` but no `@ApiResponse`
type, so the vendored spec has no response schema for this path. Adding a field
to the returned object therefore changes nothing the generator can see, and
`mobile/tool/generate_api_client.sh` would emit a byte-identical package. All
three client-side readers of this endpoint — `ChatPartnerStore`,
`LoveContractGateRepository`, `CouplePairingStore` — already bypass the
generated client and parse the raw `Dio` JSON map.

Introducing an `@ApiResponse` DTO to make the field appear in the generated
client is a deliberate **non-goal** for this story: `generate_api_client.sh`
does a whole-directory replace (ADR-010b) across a package referenced by 19
files, which is disproportionate to a one-field expansion and outside PO's
"field expansion only" constraint. The contract is instead pinned in
`contract-summary.md` and in the backend phase's own tests.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/design_system/` (component + token) and
  `mobile/lib/features/chat/presentation/` (chip widget + composition).
- New boundary: `CupidHeader` gains `final Widget? trailing;` defaulting to
  `null`. When `null`, neither the widget nor the `10dp` gap
  (`uiux-spec.md` §1.3) is built, so the 16 other consumers keep the exact
  child list they have today — AC3/AC4 hold by construction, not by inspection.
  The slot must be wired in **both** `_IosHeader` (after `Expanded`, before
  `...actions`) and `_MaterialHeader` (prepended to `AppBar.actions`), because
  `CupidHeader.build` branches on platform (`cupid_header.dart:50-67`).
- Deliberately **not** a typed `avatarInitial`/`presenceLabel` parameter pair:
  `CupidHeader` is a platform-branching design-system primitive and must not
  acquire chat/presence domain vocabulary. Keeping the slot a plain `Widget?`
  also lets the chip live in `lib/features/chat/`, where it can read
  `ChatStrings` the way `_PrivacyChip` already does.
- New additive token file:
  `mobile/lib/design_system/tokens/partner_chip_palette.dart`, holding only the
  `#00C9A7 → #7B2FBE` 135deg `LinearGradient`. It reuses the `Alignment(
  ∓0.7071067811865476, ∓0.7071067811865476)` derivation already established at
  `couple_presence_palette.dart:20-27`. Not folded into `CupidColorTokens`
  (per UX) and not inlined in `lib/features` (ADR-004).

- Identity ownership (R2): the backend becomes the single source of truth for
  the partner's display name. `UsersService` resolves it from the paired
  partner's `User` row via the existing `partnerId` FK and exposes **only**
  `displayName` — never the partner's `email`, `firebaseUid`, or full row.
  `ChatPartnerStore` then holds two clearly named getters instead of one
  mislabelled getter, which is what removes the Key Discovery item 3 defect.

### Affected Modules

- Backend: `src/modules/users`.
- Mobile: `features/chat/data`, `features/chat/presentation`,
  `design_system/adaptive`, `design_system/tokens`, `core/di`.

### Contracts And Integrations

- Compatibility posture: strictly additive on both sides. No existing
  `/users/me` key changes name, type, or meaning; no existing `CupidHeader`
  parameter changes type, order, or default; `preferredSize` is unchanged.
- Empty-state contract: `trailing: null` renders nothing and reserves no space.
- Unpaired / dangling-partner contract: `partnerDisplayName` is `null` when
  `partnerId` is null, when the partner row no longer exists, or when the
  partner's own `displayName` is null. The lookup must be non-throwing —
  `UsersService.findOne` raises `NotFoundException`, so `getProfile` must not
  route the partner lookup through it, or an unpaired user's whole profile
  request would start failing.
- Mobile empty-state contract: an older client that has not yet been updated
  simply ignores the new key; a newer client against an older backend reads
  `null` and renders the same degraded header it renders today. Neither
  ordering produces an error, which is why the deploy order is not a gate.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Shared-component backward compatibility (16 other consumers) | `story_master.md` § Product Owner Triage | Optional `Widget?` defaulting to `null`; no gap built when unset | `flutter analyze` clean + `test/design_system/adaptive_widgets_test.dart` passes unchanged + a new case asserting the unset header's child list is identical to today | Report `MOBILE_VERIFY_REQUIRED`; do not self-certify AC3 by reading code |
| ADR-004 raw-color-literal guard | `test/design_system/no_fork_guard_test.dart` | New gradient declared in `design_system/tokens/`, never in `lib/features` | `no_fork_guard_test.dart` passes | Same |
| Partner identity sourcing | `contract-summary.md`; Key Discovery evidence chain above | Backend resolves the partner's `displayName` from the existing `partnerId` FK and exposes only that one field; non-throwing lookup keeps unpaired profiles working | Backend unit tests covering paired / unpaired / dangling-partnerId / null-partner-displayName, asserting the self-identity keys are byte-unchanged | Report `BACKEND_VERIFY_REQUIRED`; mobile lane must not start until the backend gate is green |
| Self-vs-partner name plumbing (latent defect, Key Discovery item 3) | `chat_partner_store.dart` after the split | Rename to `selfDisplayName` and add `partnerDisplayName`, so every call site is forced by the compiler to restate its intent | `flutter analyze` clean (the rename makes stale reads a compile error, not a silent wrong name) + a store unit test asserting the two getters map to the two distinct payload keys | Report `MOBILE_VERIFY_REQUIRED`; do not re-add a bare `displayName` getter to keep old call sites compiling |
| Design fidelity of the `chat` screen | locked `design_source` (`Cupid Screens.dc.html` lines 49-64, 2118-2128) | Values transcribed verbatim in `uiux-spec.md` §1 | Story owes its own rendered `visual-fidelity/` evidence pair at the DONE gate (same precedent as STORY-048/049/050/051); `ui_surface` is not false | Report the missing capture rather than reusing STORY-040's pair |

### Backend Lane

- Responsibilities: add `partnerDisplayName` to the existing `GET /users/me`
  response, resolved from the paired partner's `User` row.
- Authoritative inputs: `contract-summary.md`; this file §4.
- Guardrails: no new endpoint, module, entity, or migration; do not change or
  reorder any existing response key; do not expose any partner field other than
  `displayName`; do not route the partner lookup through
  `UsersService.findOne` (it throws `NotFoundException`); do not add an
  `@ApiResponse` DTO (see §3 "Generated API Client").

### Mobile Lane

- Responsibilities: `ChatPartnerStore` self/partner split and its call sites,
  `CupidHeader` slot, token file, chip widget, `chat_screen` composition,
  regression coverage for the unset path.
- Authoritative inputs: `ux/uiux-spec.md` §1-§4; `contract-summary.md`;
  this file §4.
- Guardrails: do not modify `title`/`onBack`/`backLabel`/`actions`; do not wire
  `trailing` into any of the 16 other consumers; do not add a `button` semantic
  to the chip; do not copy `home_screen.dart:458`'s `colorBackground` dot ring —
  the chip's dot rings in `colors.colorSurface` (`uiux-spec.md` §1.4).

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| New optional `Widget? trailing` slot | Story In-Scope #1; design system owns the trailing-gap rule and the no-reserved-space invariant for all future consumers | ACCEPTED | |
| Reuse the existing `actions` list with a leading `SizedBox(width: 10)` | Needs zero design-system change, so AC3/AC4 become vacuous | REJECTED | Bakes header layout spacing into a feature screen and overloads `actions`, whose Material path inherits `AppBar` icon-affordance theming. Surfaced for PO awareness because it would also drop In-Scope #1. |
