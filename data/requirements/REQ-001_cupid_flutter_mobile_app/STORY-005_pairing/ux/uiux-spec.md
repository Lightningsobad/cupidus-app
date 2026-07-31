# UX Spec: STORY-005 Pairing (Epic-1: 1:1 connection — invitations)

Scope: REQ-001 / STORY-005_pairing
Source of truth: `cupid-mobile-design/Cupid Screens.dc.html` (screen ids
`invite`, `joincode`, `waiting`, `paired` — confirmed below).
Backend contract: `backend/src/modules/invitations/` (frozen, A1) —
`invitationsService.generateCode`, `validateCode`, `acceptInvitation`.
Tokens/components reused verbatim from STORY-001
(`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/ux/uiux-spec.md`)
and the session/error-mapping conventions established in STORY-003
(`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-003_auth/ux/uiux-spec.md`)
— no new tokens introduced.

## 1. Screen Inventory (existing design source, reused as-is)

| Screen id | Purpose | Header/back | Tab bar |
|---|---|---|---|
| `invite` | Inviter's screen — shows the generated pairing code, share/copy actions | **Has header**, back target `profile` | hidden (`NO_TABS`) |
| `joincode` | Invitee's screen — manual code entry (paste/QR/type) | **Has header**, back target `invite` | hidden (`NO_TABS`) |
| `waiting` | Inviter-only — pulsing "waiting for partner" hold state after code is generated | **No header** (`NO_CHROME`) | hidden |
| `paired` | Celebration screen shown to both users once the pair is established | **No header** (`NO_CHROME`) | hidden |

Correction to system UX memory §4: that section states the *entire*
onboarding/pairing group is chromeless. The design source's own `NO_CHROME`
map (`{ welcome, vow, home, splash, waiting, paired }`) is narrower than its
`NO_TABS` map (which does include `invite`/`joincode`) — `invite` and
`joincode` carry a header with a back chevron, only the tab bar is hidden.
`waiting` and `paired` are the only two pairing-flow screens with no header
at all. This is a precision correction for this story's screens, not a new
shared convention, so system UX memory is left unedited per this story's
WriteScope.

The design source also bundles a "what kind of couple are we?" type picker
and a "Continue → Fingerprint Vow" CTA into the same `invite` screen markup.
Neither is covered by this story's ACs (couple-type personalization and the
Love Contract/Fingerprint Vow flow are downstream/separate concerns, and the
`invitations` module has no supporting endpoint for couple-type). For this
story, treat `invite` as scoped to **only** the code-display + share/copy
card. Flagged to PO/Tech Lead in §7 rather than silently dropped or silently
built.

## 2. Flow Map

```
Unpaired user, entry point (e.g. Me/profile "Pair with your partner" action)
  -> invite  (tap "generate/get code" entry point)
       - calls POST /invitations/generate (idempotent: returns existing
         active code if one exists, per backend AC1)
       - renders code + Share invite / Copy actions
       -> after share or copy is invoked -> waiting

  -> joincode (reached via invite's "I am the one with the code" toggle,
     OR as the direct entry point for a user who already has a code)
       - manual code entry (type / paste / scan QR — all populate the same
         code value, no separate contract path)
       - tap "Pair up" -> POST /invitations/accept { code }
       - success -> paired (AC2, immediate — invitee has no waiting step)
       - failure -> inline rejection state, stays on joincode (§5, AC3)

waiting (inviter only, after generate)
  -> partner accepts elsewhere -> paired (AC2)
  -> mechanism to detect this transition is an open item, see §7

paired (both users converge here)
  -> downstream Love Contract/Fingerprint Vow flow (out of this story's scope)
```

Asymmetry is intentional and matches the backend: `acceptInvitation` is a
single synchronous call, so the invitee goes straight from `joincode` to
`paired` on success. Only the inviter needs an interim `waiting` state,
because nothing in the `invitations` module pushes the inviter a
notification when their code is used.

## 3. Invite-Send Flow (AC1)

- `invite` screen: card shows the code (mono, large, gradient-clip text per
  existing design), a "Share invite" pill (native share sheet) and a
  secondary copy-to-clipboard icon button.
- Backend truth: `generateCode` returns an **existing** active code if the
  user already has one (does not check its expiry before returning it — see
  §7 flag). UI should treat "tap generate again" as safe/idempotent: it must
  not visually flash as if a brand-new code were minted when the code text
  is unchanged.
- **Copy correction needed:** the design source's static copy reads "Hết hạn
  sau 15 phút" / "Expires in 15 minutes", but the actual backend TTL
  (`expiresAt`) is **24 hours** from creation. Since the backend contract is
  frozen and authoritative, replace the static string with a live
  countdown/expiry readout computed from the returned `expiresAt` (e.g.
  "Expires in 23h 40m"), not the hardcoded 15-minute string.
- **Code-format correction needed:** the design source's example code
  ("CPD-8F2K") and its "8-character code" copy do not match what the backend
  actually generates: `randomBytes(3).toString('hex').toUpperCase()` — a
  **6-character uppercase hex string** (digits 0-9 and letters A-F only, no
  dash, e.g. `3F9A2B`). The mockup's example contains a non-hex letter ("P")
  and a dash the backend never produces. Render the code exactly as
  returned by the API (6 hex chars, no dash) and update copy to "6-character
  code" rather than matching the mockup's placeholder text literally.
- After Share or Copy is invoked, advance to `waiting`. (No explicit
  onClick target for this transition exists in the click-dummy prototype;
  this is the logical production behavior given `waiting`'s existence and
  purpose.)

## 4. Invite-Accept Flow (AC2)

- `joincode` screen: 6-character code entry (paste / manual type / QR scan
  affordances — all three are just input methods feeding the same code
  value, not separate API paths).
- On "Pair up" tap: `POST /invitations/accept` with the code.
- Success (`{ success: true }`): navigate directly to `paired` — no
  intermediate loading screen beyond the standard button-disable +
  inline-spinner pattern established in STORY-003 §6 (disable button, swap
  label for inline spinner, no layout shift, prevent double-submit).
- `paired` screen is shared: both the inviter (arriving from `waiting`) and
  the invitee (arriving from `joincode`) land on the same celebration
  screen and CTA ("Sign the Love Contract →", downstream/out of scope).

## 5. Error / Rejection States (AC3 — couple-only enforcement)

`acceptInvitation` raises four distinct backend conditions. Per the STORY-003
§6 convention (map each raw failure to one short user-facing line, inline
below the primary CTA — not a full-screen error, not a modal), all four
render as an inline `--red` error message beneath the "Pair up" button on
`joincode`, re-enabling the button and leaving the user on the same screen:

| Backend condition | HTTP | User-facing line (vi / en) |
|---|---|---|
| Code not found or inactive | 404 | "Mã không đúng hoặc đã hết hạn" / "Invalid or expired code" |
| Code found but past `expiresAt` | 400 | same line as above — do not distinguish "expired" from "invalid" to the user, mirrors STORY-003's non-revealing error pattern |
| **Accepting user already has a partner** | 409 | "Bạn đã được ghép đôi rồi" / "You're already paired" — defensive only; see gating note below |
| **Code belongs to the user's own account** | 409 | "Đây là mã của chính bạn" / "This is your own code" |
| **Inviter already has a partner (AC3's couple-only case)** | 409 | "Người này đã ghép đôi với người khác rồi" / "This person is already paired with someone else" |

The third row (AC3's literal "third invitation attempt against an
already-paired user") is the `ConflictException('This person is already
paired with a partner')` thrown when the invitation's original inviter has
since paired with someone else via a different route, and a third party
still holds/enters that stale code. It renders with the same inline-error
treatment as the other three — no special modal or blocking dialog, just the
existing STORY-003 inline-error pattern reused.

Note: `validate` (`POST /invitations/validate`) does **not** perform any of
these couple-only checks — it only confirms the code exists/unexpired and
returns the inviter's name/photo. If Mobile/Tech Lead choose to call
`validate` first for an optimistic "you're about to pair with {name}"
preview before the user commits to "Pair up", that preview must not be
treated as confirmation the pair will succeed — the couple-only/self-invite
checks only fire on `accept`. This is optional polish, not required by the
ACs; the joincode flow works correctly using `accept` alone.

## 6. Paired vs. Unpaired State — Gating (AC4)

The design source's own chrome rules make this simpler than a per-screen
gate: the entire pairing flow (`invite`/`joincode`/`waiting`/`paired`) is
`NO_TABS`, and the main app (post-pairing) is the only place the 5-tab
bottom nav (`home, chat, pet, money, me`) appears. Gating should happen at
the **navigation-shell level**, not per-feature-screen:

- Unpaired: app root routes into the pairing-flow stack (no tab bar
  reachable at all). There is no "locked tab" visual state to design because
  paired-only screens are architecturally unreachable pre-pairing, not shown
  in a disabled state.
- Paired: app root routes into the main tab shell. Every feature building
  on later stories (chat, timeline, etc.) assumes this gate already passed.
- Ongoing visual signal of paired state (once inside the main shell): the
  partner-presence chip already present in the design source's post-pairing
  screens (avatar initial + online-status dot + name, e.g. `partnerName`/
  `partnerStatus`/`showPartnerChip`) — this is the existing "couple-first"
  ambient signal (system UX memory §1); reuse it, do not design a new
  paired-state indicator.
- The defensive "you're already paired" inline error (§5, row 3) only
  matters if a paired user's stale device state somehow re-lands them on
  `joincode` (e.g. a deep link opened after already pairing on another
  device) — the shell-level gate should make this rare, but the inline copy
  exists as a fallback rather than a crash/blank state.

## 7. Open Items For Downstream Roles

- **Tech Lead — inviter-side transition mechanism (flag, not resolved
  here):** nothing in the `invitations` module notifies or lets the inviter
  poll for "has my code been accepted." `waiting` needs *some* signal to
  transition to `paired` — likely a poll against a users/profile endpoint
  checking `partnerId`, or a websocket/push event — but that is outside the
  `invitations` module and this story's read scope. Recommend Tech Lead's
  ADR pick one mechanism explicitly rather than mobile-dev silently
  implementing ad hoc polling. Until resolved, `waiting` should keep a
  manual "Share again" / manual refresh affordance as a working fallback
  (the design source's own "Simulate join" button hints at this same gap in
  the prototype itself).
- **Product Owner — couple-type picker scope (flag):** the `invite` screen
  in the design source bundles a couple-type selector and a "Continue →
  Fingerprint Vow" CTA that are not covered by this story's ACs and have no
  supporting `invitations` endpoint. Recommend PO confirm these belong to a
  separate story before Tech Lead/Mobile Dev build them as part of
  `invite`.
- **Backend/Tech Lead — unpair/leave flow (per story_master's own open
  item):** confirmed absent from the current `invitations` module (only
  `generate`/`validate`/`accept`/debug endpoints exist). Flagging forward
  per story_master's instruction rather than assuming a UI for it.
- **Tech Lead — generated API client has no typed request/response
  bodies:** `Epic1InvitationsApi`'s generated methods (`accept`, `validate`)
  return `Future<Response<void>>` with no `code` parameter in the method
  signature at all, despite the controller requiring `code` in the request
  body. This doesn't block writing this UX spec (the states/copy above are
  derived directly from `invitations.service.ts`), but it does mean
  Mobile/Backend will need to either regenerate against a corrected OpenAPI
  spec or hand-construct the request body — a contract-completeness gap,
  not a UX gap.

## 8. Responsive / Platform × Theme Notes

No new fork points or tokens. Existing STORY-001 rules apply unchanged:
- "Pair up" / "Share invite" primary CTAs follow the existing adaptive
  Primary CTA pattern (full-width pill iOS / filled button + ripple
  Material), same as STORY-003 §8.
- All icons used here (`ios_share`, `content_copy`, `content_paste`,
  `qr_code_scanner`, `link`, `hourglass_top`, `favorite`) are already part
  of the Material Symbols Rounded functional-icon system (system UX memory
  §2) — no new icons introduced.
- `waiting`'s pulse-ring/bob animation and `paired`'s pop-in/bob heart
  animation reuse the existing `pulseRing`/`bob`/`popIn` keyframe vocabulary
  (system UX memory §2 Animation vocabulary) — no new animation primitives
  needed.

## 9. Accessibility Notes

- All tap targets (Share, Copy, Paste, Scan QR, Pair up) meet the existing
  `--tap` minimum (44pt iOS / 48dp Material) — no new exemption.
- The pairing code must be exposed to assistive tech as a single accessible
  string (e.g. one semantic label reading the full code), not as
  visually-fragmented per-character elements — this applies both to the
  `invite` screen's code display and the `joincode` screen's digit-entry
  boxes, which should be backed by a single accessible text field rather
  than six independently-focusable visual boxes.
- Copy-to-clipboard on `invite` is a visual-only affordance in the mockup;
  add a live-region/snackbar announcement (e.g. "Copied" / "Đã sao chép") so
  screen-reader users get confirmation, consistent with STORY-003's
  precedent of not leaving state changes silent for assistive tech.
- `waiting`'s looping pulse/hourglass animation is decorative and should be
  hidden from assistive tech (e.g. `excludeSemantics`/`aria-hidden`
  equivalent); the "Waiting for {partner}…" text is the real accessible
  status. If/when Tech Lead's polling mechanism (§7) resolves and the screen
  auto-navigates to `paired` without user action, that navigation should be
  announced as a live-region update, mirroring STORY-003 §7's rule for the
  session-expired forced-navigation case.
- Inline rejection/error copy on `joincode` (§5) must be associated with the
  code input/accept action via accessible description, not color alone —
  same rule as STORY-003 §7 for inline field errors.

## Completion

UX_COMPLETE: YES

All four ACs have a corresponding UX specification: AC1 (§3, invite-send
flow incl. two design/backend mismatches corrected), AC2 (§4, accept flow,
asymmetric invitee/inviter paths), AC3 (§5, all four backend rejection
conditions mapped to one inline-error UI pattern, including the specific
couple-only case), AC4 (§6, shell-level gating reusing existing
NO_TABS/tab-bar architecture, no new locked-state UI needed). No blocker to
starting implementation of the non-flagged parts of this spec; three items
flagged in §7 (inviter transition mechanism, couple-type-picker scope,
unpair/leave absence, generated-client typing gap) require Tech
Lead/Backend/PO decisions before those specific edges can be built, but do
not block the invite/accept/reject/gate flows specified above.
