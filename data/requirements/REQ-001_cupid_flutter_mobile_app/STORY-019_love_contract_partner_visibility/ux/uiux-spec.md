# UX Spec: STORY-019 — Love Contract Partner Visibility (RED-PATCH hardening)

Scope: REQ-001 / STORY-019_love_contract_partner_visibility
Fixes: STORY-006 AC2/AC3 build defect (see `story_master.md` Background,
findings 1-3). This spec answers the second "Open Item For Downstream
Roles" in `story_master.md`: how `ContractSignStatus` (or its mobile model)
becomes viewer-aware.

Base spec: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-006_love_contracts/ux/uiux-spec.md`
(hereafter "the STORY-006 spec"). This document does not replace it — it
adds the missing per-viewer state table for §5 (Signing Ritual) and leaves
everything else (screen inventory, entry points, clause flow, empty/error
states, accessibility, tokens) unchanged. No new screen, no new visual
components: this is a state-copy/CTA-visibility correction on top of the
STORY-006 spec's existing `_SignedConfirmationCard` / `_SignPromptSection`
components (`mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`).

## 1. Why the STORY-006 spec is not sufficient as-is

The STORY-006 spec's §5 already writes its state names in viewer-relative
terms (`myUnsigned`, `mySigned`, `bothSigned`) and was designed assuming a
correct dual-signature backend. It does not, however, enumerate the
combination of {raw contract status} x {which of the two partners is
looking at the screen}, because at STORY-006 time the partner-signing path
did not exist at all (ADR-006c, creator-only). That per-viewer combination
table is exactly what is missing, and what caused the build defect in
`story_master.md` finding 3: the mobile mapping from raw backend `status`
string to `ContractSignStatus` currently ignores who is viewing.

Verified against `mobile/lib/features/love_contracts/data/love_contract.dart`
and `backend/src/modules/love-contracts/entities/love-contract.entity.ts`:
the backend `ContractStatus` enum has exactly three values —
`created`, `signed_requester`, `signed_partner` — plus two independent
nullable timestamps, `signedAtRequester` and `signedAtPartner`. There is no
`status` value that represents "both partners have signed." See §4 for why
this matters and what it means for downstream roles.

## 2. Per-Viewer State Table (replaces the single `ContractSignStatus`
   mapping in scope for this story)

Two viewers: **Requester** (created the contract) and **Partner** (the
paired other person). For each raw status the two viewers must see
different copy/CTA when it is their own action pending vs. already taken.
Signing order is symmetric — nothing in AC2/AC3 requires the requester to
sign before the partner may, so this table treats "partner signs first" as
a valid, designed-for path, not an edge case.

| Raw `status` | `signedAtRequester` | `signedAtPartner` | Requester sees | Requester CTA | Partner sees | Partner CTA |
|---|---|---|---|---|---|---|
| `created` | null | null | **Unsigned** — sign prompt (STORY-006 §5 `myUnsigned`) | Hold-to-sign: enabled | **Unsigned** — sign prompt (same visual, viewer-symmetric) | Hold-to-sign: enabled |
| `signed_requester` | set | null | **Signed-by-me** (STORY-006 §5 `mySigned`) — "{{myName}} đã ký" / "signed", status line "Đang chờ {{partnerName}} ký" | none (already signed, no re-sign) | **Partner-already-signed** (new, §3) — "{{requesterName}} đã ký, đến lượt bạn" / "already signed — your turn" | Hold-to-sign: enabled |
| `signed_partner` | null | set | **Partner-already-signed** (new, §3) — "{{partnerName}} đã ký, đến lượt bạn" / "already signed — your turn" | Hold-to-sign: enabled | **Signed-by-me** (STORY-006 §5 `mySigned`) — "{{myName}} đã ký" / "signed", status line "Đang chờ {{requesterName}} ký" | none (already signed, no re-sign) |
| both signed (§4 — not a distinct `status` value today) | set | set | **Both-signed** (STORY-006 §5 `bothSigned`, unchanged) | none / forward CTA per entry point | **Both-signed** (STORY-006 §5 `bothSigned`, unchanged) | none / forward CTA per entry point |

Notes:
- "Signed-by-me" and "Both-signed" are unchanged from the STORY-006 spec —
  they were already written in correct viewer-relative language. The gap
  was entirely the missing **Partner-already-signed** state and the fact
  that the mobile mapping collapses it into "Signed-by-me" for whichever
  viewer is looking, regardless of who actually signed.
- "Both-signed" CTA visibility (none in revisit path vs. "continue to
  home"/"Done" in onboarding path) follows the entry-point rule already
  defined in STORY-006 spec §5's `bothSigned` bullet — unchanged, applies
  identically to both viewers.

## 3. New State — "Partner-already-signed" (my turn)

Not present in the STORY-006 spec because the partner-signs-first path did
not exist before this story. Composition, reusing existing components only:

- Same layout as STORY-006 spec §5's unsigned state (`_SignPromptSection`:
  caption + `HoldToSignButton`, both unchanged, hold gesture unchanged,
  ~1.5s dwell unchanged) — the CTA itself is not new.
- Add one acknowledgment line above the sign caption, in the same
  `--pink`/caption text style as other status lines on this screen:
  - Named: "{{otherPartyName}} đã ký, đến lượt bạn" / "{{otherPartyName}}
    already signed — your turn"
  - Neutral (name not yet resolved, mirrors STORY-006 spec §9 item 2's
    existing Named/Neutral fallback pattern): "Đối phương đã ký, đến lượt
    bạn" / "Your partner already signed — your turn"
- No color/urgency change to the hold-to-sign button itself — it is the
  viewer's own pending action, same visual weight as the plain unsigned
  state, just with the added context line explaining why it's their turn.
- Suggested l10n keys, following the existing naming convention in
  `love_contract_screen.dart` (`loveContractSignedByMe`,
  `loveContractAwaitingPartnerNamed/Neutral`):
  - `loveContractPartnerAlreadySignedNamed(String otherPartyName)`
  - `loveContractPartnerAlreadySignedNeutral`

## 4. Open Item For Downstream Roles — data-model gap for "both signed"

**Tech Lead — blocking for the "both signed" row of §2's table as a data
question, not a UX one.** `ContractStatus` (`backend/src/modules/love-contracts/entities/love-contract.entity.ts`)
has only three values: `created`, `signed_requester`, `signed_partner`.
There is no value representing "both partners have signed." Once this
story lets the second partner sign after the first already has, the
service must decide what `status` becomes — options include (a) add a
fourth enum value (e.g. `signed_both`/`completed`), or (b) leave `status`
as whichever party signed second and have the mobile client derive
"both signed" purely from `signedAtRequester != null && signedAtPartner !=
null` rather than from `status` alone. This spec's §2 table designs the
**observable UX** for the both-signed case (identical to STORY-006 spec's
existing `bothSigned` visual, both viewers) and does not require the enum
change — the mobile mapping can derive "both signed" from the two
timestamps regardless of what `status` literally contains — but Tech Lead
must decide which signal (`status` string vs. both timestamps) the client
reads, since the current mobile model (`love_contract.dart`) only ever
looks at `status`, not the timestamps, to pick a `ContractSignStatus`. This
is the same open item already flagged as item 2 of `story_master.md`'s
"Open Items For Downstream Roles" — this section is the concrete detail
behind it, not a new scope item.

## Completion

UX_COMPLETE: YES

This spec answers AC2/AC3's viewer-awareness requirement: §2's table gives
the exact copy/CTA state for both partners across every reachable raw
status, §3 defines the one net-new visual composition needed (built
entirely from existing STORY-006 components, no new screen or design
system addition), and §4 hands Tech Lead the one remaining data-model
question (status enum vs. dual-timestamp derivation) needed to implement
the "both signed" row correctly. No UX decision remains open.
