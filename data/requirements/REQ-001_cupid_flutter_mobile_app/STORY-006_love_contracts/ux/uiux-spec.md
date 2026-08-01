# UX Spec: STORY-006 Epic-1 — Love Contracts / Nghi Thức Cam Kết

Scope: REQ-001 / STORY-006_love_contracts
Source of truth: `cupid-mobile-design/Cupid Screens.dc.html` (screen id
`contract` — the Love Contract screen, part of the `NO_CHROME`/`NO_TABS`
epic-1 group per system UX memory §4).
Tokens/components reused verbatim from STORY-001
(`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/ux/uiux-spec.md`)
— no new tokens introduced.

**Read this spec's §9 before implementation.** The backend `love-contracts`
module (frozen, A1) does not currently implement the partner half of the
dual-signature ritual the design source and this story's ACs describe. This
spec designs the full intended UX (matches design source + ACs) and flags
the gap prominently rather than silently shipping a broken partner flow.

## 1. Screen Inventory

| Screen id | Purpose | Chrome |
|---|---|---|
| `contract` (existing design source) | Create/propose clauses, hold-to-sign ritual, view current contract + sign status | none (`NO_CHROME`/`NO_TABS`) |
| `contract` — **revisit variant (new, this spec)** | Same screen, reached post-onboarding from `Me`/profile, for viewing an already-signed contract later (AC3) | standard chrome (has header + tab bar, since it's reached from inside the main app, not onboarding) |

No new screen id is introduced — the revisit path renders the same `contract`
UI, only entered from a different place and with standard chrome instead of
`NO_CHROME`/`NO_TABS` (see §3).

Out of scope for this spec: the `vow` (Fingerprint Vow) screen. Its backend
target is `POST /users/vow` / `User.vowTaken`, a field on the user's own
pairing/profile record, not the `love-contracts` module this story owns.
Despite sitting next to `contract` in the design source's epic-1 screen
list, it is a separate backend concern — see §9 for placement flag.

## 2. Flow Map

The design source's raw `onClick` handlers are not a reliable path here (see
§9's prototype-artifact note). The authoritative order is the design
source's own `BACK_TO` map plus system UX memory §4's epic-1 screen list:

```
Onboarding (first-time, post-pairing):
  paired (pairing just completed, STORY-005)
    -> tap "Sign the Love Contract" -> contract (NO_CHROME/NO_TABS variant)
         - propose clauses, hold-to-sign (§4)
         - both signed -> continue to home (not "Pair up" — pairing already
           happened; the design source's literal button copy on this
           screen is a prototype artifact, see §9)
    -> vow (out of this story's scope, see §1)
    -> home

Revisit (any time post-onboarding, AC3):
  Me/profile screen -> "Love Contract" menu item (new entry point, §3)
    -> contract (standard-chrome variant)
         - if a contract exists: view clauses + sign status (read/append
           only if not yet fully signed; §5)
         - if none exists yet: empty state (§6) with the same
           propose-a-contract entry point as onboarding
```

## 3. New Entry Point — `Me`/Profile Revisit (AC3)

The design source only shows `contract` as a one-time onboarding stop
(`paired` -> `contract` -> `vow`). Nothing in the source re-enters it later,
but AC3 requires viewing existing love contracts at any time, not just
once. This spec adds one new entry point:

- A "Love Contract" row/menu item on the `Me` (profile) screen, in the same
  list-item style as other epic-6 profile rows (e.g. "Privacy / My data",
  "Notifications" — `--surf` card row, chevron affordance, per the existing
  `Me` screen pattern).
- Icon: reuse the `draw` icon already used for the contract nav-bar entry
  in the design source's screen picker (`{ id: 'contract', icon: 'draw', ... }`
  at the source's own `INDEX`).
- Tapping it navigates to the same `contract` screen content, but with
  standard chrome (header with back arrow/chevron per platform, main app
  tab bar visible) since the user is now inside the main app, not the
  chromeless onboarding flow. Screen title: "Love Contract" (kept as an
  English brand/proper-noun term per system UX memory §5's i18n
  convention for feature names).
- This is the only new screen real-estate this spec adds; no new visual
  design, only a new navigation entry point into the existing `contract`
  layout.

## 4. Contract Creation / Proposal (AC1)

Reuse the design source's existing `contract` screen body as-is:

- Header card: "Bản cam kết số 001" / contract sequence label (Roboto Mono,
  uppercase, `--pink`), "Love Contract" title (Nunito 900, 30px), subtext
  "Between {{ myName }} & {{ partnerName }} · valid until both revoke".
- Clause list (`clauseList`, `hint-placeholder-count="4"`): each clause is a
  toggleable row (checkbox-style, `c.on`/`c.off` states, `--grad-hot` filled
  check icon vs. outlined circle) with a mono clause id (`§{{ c.no }}`).
  These are **preset/suggested clauses** the couple can toggle on/off, not
  free-form from a blank page — matches the source's toggle-row pattern.
- "+ Add our own clause" affordance (pink text row, `+` icon) lets the
  couple append a custom clause string. New state, since the source only
  shows the tap target without an authored input pattern: tapping it opens
  a single-line text input (existing sheet/dialog chrome, `--r-sheet`
  radius) with a short helper caption ("Điều khoản của riêng hai bạn" /
  "Your own clause") and Save/Cancel. Enforce the backend's own
  `clauses: string[]`, `ArrayMinSize(1)`, `ArrayMaxSize(20)` constraints
  (`CreateContractDto`) client-side: disable "Add" past 20 total clauses,
  and require at least 1 toggled/added clause before the sign action
  becomes available.
- Whichever set of clauses is currently toggled-on/added is what gets sent
  as the `clauses: string[]` payload on save (`POST /love-contracts`,
  upserted per-requester as the backend's `create()` behavior — see §9 for
  what "upserted" means for the revisit case).

## 5. Signing Ritual (AC2)

Reuse the design source's existing hold-to-sign interaction exactly:

- Caption above the sign control: "Giữ ngón tay để ký — cam kết thì phải
  nặng tay một chút" / "Press and hold to sign — commitment should take
  effort" (system UX memory §1 "dual-confirmation" vocabulary — this is
  the partner-facing ritual class, distinct from STORY-003's solo
  destructive-confirm dialogs; do not substitute a plain confirm dialog
  here).
- **Unsigned state** (`myUnsigned`): full-width `--grad-hot` pill, hold
  gesture fills a circular progress ring (`holdPct`) and an inverse overlay
  (`holdInvPct`) over ~1.5s (per system UX memory §1's Fingerprint Vow
  precedent for hold-duration — apply the same ~1.5s dwell here for
  consistency across the app's hold-to-confirm vocabulary), releasing early
  cancels the hold with no partial-sign side effect.
- **Signed-by-me state** (`mySigned`): green-tinted card, "{{ myName }}
  đã ký" / "signed", plus `partnerSignStatus` line showing the partner's
  current status (e.g. "Đang chờ {{ partnerName }} ký" / "Waiting for
  {{ partnerName }} to sign").
- **Both-signed state** (`bothSigned`): green CTA button; per §2, its
  destination in the onboarding path is "continue to home", not "Pair up"
  (the source's literal `goInvite`/"Pair up" label is a reused artifact —
  see §9). In the revisit path (§3), no forward CTA is needed here since
  the user arrived via `Me`, not onboarding; show only the both-signed
  confirmation state with a "Done"/back affordance instead.
- Footer lock note stays as-is: "Bản hợp đồng lưu ở Level 2 — mã hoá
  đầu-cuối" / "Stored at Level 2 — end-to-end encrypted" (matches system UX
  memory §8's Level-2 classification for this data type).

## 6. Empty / Loading / Error States (new, not in design source)

The design source's `contract` screen only shows the mid-flow states above
(clauses + signing). Add the following, needed for both entry points:

- **Loading**: on entering `contract` (either entry point), show the
  existing card skeleton/placeholder treatment already established for
  other epic screens (reuse STORY-001's loading pattern, not a new
  spinner) while `GET /love-contracts/my-pending` resolves.
- **Empty (no contract yet)**: when the pending-contract fetch returns
  none, show the clause-toggle list pre-populated with all presets
  toggled off and the "Hold to sign" control disabled/hidden until at
  least one clause is toggled/added — i.e. the empty state is the same
  screen in its "nothing chosen yet" configuration, not a separate
  illustration screen (consistent with this feature being a lightweight
  single-object flow, not a list-heavy one).
- **Network/API error**: inline error banner at the top of the card (reuse
  STORY-003 §6's mapped-error convention — no raw `CupidApiFailure` type
  strings), with a "Thử lại" / "Retry" action. Do not block the whole
  screen behind a full-screen error state; the card chrome stays visible.
- **Partner-sign-call error (see §9 blocker)**: if the current backend
  behavior ships unchanged, a partner tapping "Hold to sign" will receive
  a 404 (`No pending contract found to sign`) because the backend never
  attributes the contract to them. Map this specific case to a
  non-technical message distinct from a generic network error — e.g.
  "Chưa thể ký lúc này, thử lại sau" / "Can't sign right now, try again
  later" — rather than surfacing the raw 404. This is a stopgap copy
  recommendation only; §9 is the real fix needed.

## 7. Gating for Unpaired Users (AC4)

The backend does not enforce a pairing check on the `love-contracts`
endpoints itself (no guard beyond Firebase auth). Client-side gate
required:

- Before showing the "Love Contract" entry point (both the onboarding
  `paired` -> `contract` tap target and the new `Me`-screen menu item in
  §3), check the current user's `partnerId` (from `GET /users/me`, already
  fetched app-wide for the paired/unpaired chrome state). If `partnerId`
  is absent, do not surface the entry point at all — this is a
  hide-not-disable pattern (an unpaired user has no partner to contract
  with, so the feature is not just locked, it's not applicable yet).
- This mirrors how the rest of the paired-only app shell should already be
  gating post-pairing features; no new gating mechanism is introduced,
  just applied to this feature's two entry points.

## 8. Accessibility Notes

- Hold-to-sign control (§5) must expose an accessible alternative to the
  raw hold gesture for screen-reader/switch-control users — e.g. a
  long-press-equivalent accessibility action or a confirm dialog fallback
  reachable via the platform's accessibility activation gesture, per
  standard practice for custom gesture controls (do not ship a
  gesture-only interaction with no accessible equivalent).
- Clause toggle rows (§4) must expose their on/off state as a semantic
  toggle (not color-only), consistent with STORY-003 §7's
  not-color-alone rule.
- The custom "Add our own clause" text input sheet (§4) must trap focus
  while open and return focus to the "+ Add" row on cancel, per the same
  modal a11y pattern established in STORY-003 §7.
- All interactive elements meet the existing `--tap` minimum (44pt iOS /
  48dp Material) per STORY-001 tokens — no new exemption.

## 9. Open Items For Downstream Roles

1. **Tech Lead — BLOCKING for AC2/AC3 as literally worded: backend does
   not implement partner-side signing or shared visibility.** Read
   `backend/src/modules/love-contracts/`:
   - `LoveContract.partnerId` (entity column) is never set anywhere in
     `LoveContractsService.create()` — there is no `partnerId` field on
     `CreateContractDto` at all, and no code path assigns the paired
     partner's user id to a contract.
   - `LoveContractsService.sign()` only matches
     `{ requesterId: userId, status: CREATED }`. If the *partner* (not the
     original requester) calls `PATCH /love-contracts/sign`, the query
     never matches their user id, so it throws `NotFoundException('No
     pending contract found to sign')` — the partner can never sign,
     regardless of UI. The `ContractStatus.SIGNED_PARTNER` enum value
     exists but no service code ever produces it.
   - `getMyContract()` queries `{ requesterId: userId } OR { partnerId:
     userId }`, but since `partnerId` is never populated, the partner
     branch never matches — the partner cannot fetch/view the requester's
     contract via this endpoint either.
   - There is also no list endpoint — `GET /love-contracts/my-pending`
     returns a single latest row (`order: { createdAt: 'DESC' }`), not an
     array. AC3's "list ... of active love contracts" does not match the
     API shape (there is effectively one current contract, not a list).
   - **This spec is written to the intended dual-signature ritual** (per
     design source + ACs) **assuming this gap gets resolved**, since
     designing UX only for the broken behavior would ship a feature the
     partner can never actually use. Given A1 (backend frozen, no
     client-driven endpoint changes), Tech Lead/PO must explicitly decide
     between: (a) escalate a narrowly-scoped backend fix request (attach
     `partnerId` on create via the pairing relationship, add a
     partner-aware branch to `sign()`) as a deliberate A1 exception, or
     (b) descope AC2/AC3 to "creator-only creates and signs; partner has
     no distinct action" for v1 and adjust the story's ACs accordingly.
     This spec does not resolve that trade-off — it is a product/backend
     decision, not a UX one. §6's "Partner-sign-call error" state is a
     stopgap only if option (b) or an unresolved gap ships as-is.
2. **Tech Lead — partner display name resolution.** The `contract` screen
   needs the partner's `displayName` (e.g. "Between Minh & Linh"). `GET
   /users/me` only returns the current user's own record, including a raw
   `partnerId` (uuid), not the partner's `displayName`/`photoUrl`. There is
   no `GET /users/:id` endpoint exposed. Confirm whether STORY-005
   (pairing) already resolves and caches the partner's profile
   client-side (e.g. from the `validateCode`/`paired` step, which does
   return `inviter.displayName`) for reuse here, or whether a new
   resolution path is needed — this spec assumes the partner's name is
   already available in app state by the time a paired user reaches this
   screen, sourced from STORY-005, not re-fetched here.
3. **Informational, not blocking — design source forward-nav artifacts.**
   Two `onClick` targets in the raw prototype are inconsistent with the
   `BACK_TO` map and system UX memory §4's confirmed screen order and are
   very likely prototype/demo copy-paste artifacts, not intended product
   flow: (a) the `profile` screen's "Continue → Love Contract" button
   (line ~117 of the design source) — real forward navigation from
   `profile` should go to `invite`, per `BACK_TO`'s `invite: 'profile'`
   mapping; (b) the `contract` screen's both-signed CTA reads "Cả hai đã
   ký → Ghép đôi" / "Both signed → Pair up" (`goInvite`) — but per the
   confirmed order (`paired` already precedes `contract`), pairing has
   already happened by the time a couple reaches `contract`, so this
   button's real destination should be "continue to home", not back into
   pairing. §2/§5 above already specify the corrected destinations;
   flagging here so Mobile Developer does not literally port the raw
   button labels/handlers.
4. **Product Owner — confirm epic-3 wording rule does not apply here.**
   Not applicable; noting only that this feature's copy has no
   "báo thức"/alarm-adjacent terms, so system UX memory §6's compliance
   flag does not apply to this story. (No action needed — included so
   this spec explicitly clears that check rather than silently skipping
   it.)

## Completion

UX_COMPLETE: YES

All four ACs have a corresponding UX specification: AC1 (§4, clause
propose/toggle/add flow), AC2 (§5, hold-to-sign ritual + §9 item 1's
backend-gap flag on the partner half), AC3 (§3 new revisit entry point +
§9 item 1's flag on the list/shared-visibility gap), AC4 (§7, client-side
pairing gate). One item (§9-1) is a blocking escalation for Tech
Lead/Product Owner regarding actual backend capability, not a gap in this
spec's coverage of the ACs as designed.
