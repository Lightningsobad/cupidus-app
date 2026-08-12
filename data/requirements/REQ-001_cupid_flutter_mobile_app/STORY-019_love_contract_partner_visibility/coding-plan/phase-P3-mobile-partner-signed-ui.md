# P3 — Mobile: partner-already-signed state, copy, and entry-point reachability

Owner: mobile-dev | Lane: mobile | Depends On: P2 | Runtime id: `mobile-app`
Status: DONE
UX: `../ux/uiux-spec.md` §2 (per-viewer table) and §3 (the one new state)

## 1. Goal

Render the correct copy and CTA for each viewer across every reachable state,
and prove the partner can actually reach and use the sign action. AC2 and AC3
(mobile UI half), AC4 regression guard.

## 2. Write Scope

- `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`
- `mobile/lib/features/love_contracts/presentation/widgets/love_contract_entry_tile.dart`
  (only if the partner-viewer reachability check in §3 proves a change is needed)
- `mobile/lib/l10n/arb/app_en.arb`, `mobile/lib/l10n/arb/app_vi.arb`
- `mobile/lib/l10n/generated/**` (regenerated output, not hand-edited)
- `mobile/test/features/love_contracts/presentation/love_contract_screen_test.dart`

## 3. Implementation

**New l10n keys** (naming follows the existing `loveContract*` convention;
add to both ARB files with `@`-metadata and placeholders, then regenerate):

| Key | EN | VI |
|---|---|---|
| `loveContractPartnerAlreadySignedNamed(otherPartyName)` | "{otherPartyName} already signed — your turn" | "{otherPartyName} đã ký, đến lượt bạn" |
| `loveContractPartnerAlreadySignedNeutral` | "Your partner already signed — your turn" | "Đối phương đã ký, đến lượt bạn" |
| `loveContractBothSignedNamed(otherPartyName)` | "You and {otherPartyName} both signed" | "Bạn và {otherPartyName} đều đã ký" |
| `loveContractBothSignedNeutral` | "You both signed" | "Cả hai đã ký" |

The both-signed pair is Assumption A-1 in `../architecture/solution.md`: the UX
spec calls that visual "unchanged from STORY-006", but STORY-006 never
implemented it and its signed card hardcodes a "waiting for partner" status
line, which is wrong once both parties have signed.

**`_SignPromptSection`** takes an optional `acknowledgmentLine`. For
`partnerAlreadySigned`, pass the Named/Neutral partner-already-signed string and
render it above the existing sign caption in the same caption/`--pink` style as
other status lines. The `HoldToSignButton` itself is unchanged — same enabled
state, same ~1.5s dwell, no color or urgency change (`ux/uiux-spec.md` §3).

**`_SignedConfirmationCard`** keeps the `loveContractSignedByMe` heading for
both signed states, and picks its status line by state: `signedByMe` keeps
`loveContractAwaitingPartner*`, `bothSigned` uses the new
`loveContractBothSigned*`. Delete the "`awaitingPartner` is defensive-only /
ADR-006c" doc comment — that rationale is now false.

**Clause affordances (ADR-019e).** Gate the add-clause button and
`ClauseToggleRow` interactivity on `state.canEditClauses`. For the partner the
clause list is read-only: rows still render (they must see what they are
signing), but they are not tappable and the add-clause row is absent.

**Entry-point reachability (skill rule 13a).** This phase owns proving the
capability is reachable for the partner, not just the creator: the entry tile
and `LoveContractGateRoute` show for any paired user, so a paired partner
already gets the row and the screen. Verify by test rather than assume, and
confirm `partnerDisplayName` resolves to the *other* party for both viewers
(Assumption A-2). Do not relax the AC4 hide-not-disable gate in either file.

## 4. Do Not

- No new screen, no new design-system component, no token change.
- Do not add a partner clause-editing or renegotiation path.
- Do not hand-edit `mobile/lib/l10n/generated/**`; regenerate it.
- Do not modify the AC4 gate tests to make anything pass.

## 5. Test Scope

`love_contract_screen_test.dart`:
- Partner viewer + `partnerAlreadySigned` → acknowledgment line present and the
  hold-to-sign button is enabled (the AC2 partner CTA).
- Requester viewer + `signedByMe` → signed card with the awaiting-partner line
  and **no** sign button (unchanged behavior).
- Either viewer + `bothSigned` → signed card with the both-signed line.
- Partner viewer → add-clause button absent and clause rows not tappable.
- Named vs Neutral fallback for both new copy pairs.
- Existing entry-tile and gate tests
  (`love_contract_entry_tile_test.dart`) still pass unmodified — the AC4
  regression guard.

Gate: `cd mobile && flutter test test/features/love_contracts` fully green and
`flutter analyze` clean. Record evidence in `coding-plan/test-results.md`
before `MOBILE_COMPLETE: YES`. No Playwright, no runtime startup smoke.
