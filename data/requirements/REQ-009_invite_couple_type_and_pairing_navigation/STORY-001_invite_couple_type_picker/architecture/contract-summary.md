# Cross-Lane Contract — REQ-009 Invite Couple-Type Selection

Authoritative source: `mobile/lib/features/pairing/presentation` (STORY-001).
Consumers: `mobile/lib/features/pairing/presentation` STORY-002 (attaches the
post-code navigation destination to the Continue CTA this story creates).

## 1. Envelope

Unchanged transport. The value travels on the existing
`PATCH /users/me` body as `UpdateProfileDto.coupleType`, sent through
`AccountRepository.updateProfile(coupleType: UpdateProfileDtoCoupleTypeEnum)`.
Matching is textual against a closed backend enum validated by
`@IsEnum(CoupleType)`; a mismatch is a runtime `400`, not a build error, so the
literals below must be copied exactly.

Minimal body: `{"coupleType":"LONG_DISTANCE"}` — every other profile field is
omitted (`UpdateProfileDto` uses `includeIfNull: false`), so this PATCH never
clobbers `displayName`, `birthday`, or `relationshipStartDate`.

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---------|------------|--------------------------|
| Long-distance card | `LONG_DISTANCE` | `UpdateProfileDto.coupleType` |
| Same-city card | `SAME_CITY` | `UpdateProfileDto.coupleType` |
| Just-started-dating card | `DATING` | `UpdateProfileDto.coupleType` |
| Long-term card | `LIVING_TOGETHER` | `UpdateProfileDto.coupleType` |

Rules for the consumer side:

- The enum is closed. `LONG_TERM` is NOT a valid value — the long-term card
  deliberately maps to `LIVING_TOGETHER` (`solution.md` section 6). Sending
  `LONG_TERM` fails validation at runtime with no compile-time warning.
- Never construct these literals inline. They exist only as `wireValue` on the
  local `CoupleType` enum in
  `mobile/lib/features/pairing/presentation/couple_type.dart`.
- Unknown or absent inbound `CupidProfile.coupleType` parses to `null`
  (no card pre-selected). Do not throw on it.

## 3. Continue CTA seam (what STORY-002 builds against)

| Order | Key | Rendered/exposed as | Value contract |
|-------|-----|---------------------|----------------|
| 1 | `InviteReady.selectedCoupleType` | drives which card is selected | `CoupleType?`; `null` means the Continue CTA is disabled |
| 2 | `InviteReady.isSaving` | Continue CTA disabled while true | `bool`; true only during the in-flight PATCH |
| 3 | `InviteCubit.selectCoupleType(CoupleType)` | card tap handler | replaces the selection; never additive |
| 4 | `InviteCubit.submitCoupleType()` | Continue CTA `onPressed` | `Future<bool>` — `true` when the PATCH succeeded, `false` on failure (selection kept, CTA re-enabled) |

- STORY-001 wires Continue to `submitCoupleType()` and stops there: on `true`
  it performs no navigation. STORY-002 adds the navigation to
  `pairing_choice_screen.dart` on the `true` branch only, and must not
  navigate on `false`.
- STORY-001 owns the failure UX (`SnackBar` + CTA re-enabled). STORY-002 must
  not add a second failure surface for the same call.

## 5. Deploy / rollout order

No ordering constraint: the backend enum, DTO, and column already exist and are
unchanged by REQ-009. Mobile can ship alone.

## 6. What the consumer must NOT do

- Do not change `submitCoupleType()`'s return contract to a state emission —
  STORY-002 needs the boolean to decide whether to navigate.
- Do not re-persist the couple-type on the navigation path; STORY-001's
  Continue handler is the only writer.
- Do not make `InviteCubit`'s optional constructor parameters required —
  `mobile/lib/main_preview.dart:859-866` constructs it with
  `generateInvitation` alone.
