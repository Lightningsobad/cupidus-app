# Contract Summary: Pairing QR Payload

Producer: STORY-002 (create-code / Couple Types screen, `InviteQrFrame`).
Consumer: STORY-003 (join-code screen scanning) and any future scanner.

## 1. Payload

The QR encodes the **bare pairing code string**, byte-for-byte identical to the
value rendered as text on the same card.

- Source field: `PairingInvitation.code`
  (`mobile/lib/features/pairing/data/pairing_invitation.dart`).
- Payload = that string. No prefix, no scheme, no URL, no JSON, no padding, no
  case transformation, no whitespace.
- Example shape only (the value is server-issued and its length is not fixed by
  this contract): a short alphanumeric token such as `8F2K7Q`.

## 2. What The Payload Is Not

- It is **not** `https://cupid.app/pair?code=<code>`. That URL form exists only
  in the share-sheet text built by `_share` in `invite_screen.dart` and is a
  separate distribution channel. A scanner must not assume the URL form is what
  it will read from this QR.
- It is **not** a second, QR-only code. AC2 of STORY-002 requires one value with
  two representations.

## 3. Encoding Parameters

| Parameter | Value | Why fixed |
|---|---|---|
| Error correction level | `H` | The 40x40 center heart badge plus its 5px ring occludes the QR's center modules (UX spec §1). |
| QR version | encoder-selected | Do not pin. The code length is server-issued and may change. |
| Character set | encoder-selected from the payload | Do not force alphanumeric-only mode. |

## 4. Consumer Obligation (STORY-003)

A scanner reading this QR receives a value it can pass straight into the
existing join-code path (`JoincodeCubit` / `PairingRepository.acceptInvitation`)
with no parsing step. If STORY-003 also wants to accept the share URL form, that
is additive on the consumer side and does not change this producer contract.

## 5. Validity

The QR carries no expiry of its own. It expires exactly when the text code
expires, because it is the same value; expiry remains governed by
`PairingInvitation.expiresAt` and the existing countdown.
