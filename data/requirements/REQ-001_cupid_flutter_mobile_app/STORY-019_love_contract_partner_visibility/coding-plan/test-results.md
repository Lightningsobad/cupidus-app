# Test Results: STORY-019 — Love Contract Partner Visibility

## Phase P1 (backend-dev)

Command: `cd backend && npm test -- love-contracts && npm run build`

### Gap closeout (post Slice A review)

Slice A review (`review/slice-P1-backend-review-report.md`) flagged a
blocking test-scope gap: `phase-P1-backend-partner-signing.md` Test Scope
item 5 / `architecture/solution.md` Risk Surface row 2 require a unit test
proving a caller who is requester on one row AND partner on another
resolves to their own row, in both recency directions.

Tracing the then-deployed `findContractForUser` (single combined
`where: [{requesterId}, {partnerId}]` query ordered by `createdAt DESC`)
showed it did **not** satisfy ADR-019a's stated precedence guarantee: when
the caller's own row was older than a row where they are the backfilled
partner, the combined `ORDER BY createdAt DESC` picked the newer partnered
row instead of the caller's own row. Fixed by splitting the lookup into two
sequential, explicitly ordered queries — `where: { requesterId: userId }`
first, returning immediately if found; only then `where: { partnerId:
userId }` — before falling through to the unchanged User.partnerId
backfill fallback. Both new tests use a where-clause-matching stub so they
discriminate on resolver *behavior*: the "older own row" case fails against
the old combined-query implementation and passes against the new
split-query implementation.

### `npm test -- love-contracts`

```
PASS src/modules/love-contracts/love-contracts.service.spec.ts
  LoveContractsService
    create
      ✓ writes partnerId from the paired User.partnerId when creating a new contract
      ✓ leaves partnerId null when creating a new contract for an unpaired requester
      ✓ updates an existing pending contract owned by the requester
      ✓ throws ConflictException when the caller is the partner of an existing contract
      ✓ resets status to CREATED and nulls both timestamps when the requester edits a signed contract
    getMyContract
      ✓ resolves for the partner via the partnerId branch
      ✓ resolves via the step-2 fallback and backfills partnerId when it is null
      ✓ resolver precedence: a caller who owns a row resolves to it via the requester-first query, without the partner fallback
      ✓ resolver precedence: a caller who is requester on one row and partner on another resolves to their own row when it is the newer row
      ✓ resolver precedence: a caller who is requester on one row and partner on another resolves to their own row even when it is the older row
    sign
      ✓ sets signedAtRequester and SIGNED_REQUESTER when the requester signs
      ✓ sets signedAtPartner and SIGNED_PARTNER when the partner signs, preserving signedAtRequester
      ✓ is idempotent when the caller has already signed
      ✓ throws NotFoundException for an unpaired caller with no contract (AC4 regression guard)
    LoveContractResponseDto.from
      ✓ sets viewerRole to requester for the creator and partner for the other side

Test Suites: 1 passed, 1 total
Tests:       15 passed, 15 total
```

Result: PASS

### `npm run build`

```
> nest build
```

Result: PASS (clean, no TypeScript errors)

No e2e, no runtime startup smoke — out of scope for this phase per
`coding-plan/master-plan.md` Build / Verification Gate.

## Phase P3 (mobile-dev)

Command: `cd mobile && flutter test test/features/love_contracts`
(`FLUTTER_SDK_PATH=$HOME/flutter`)

```
00:01 +69: All tests passed!
```

New in this phase (`love_contract_screen_test.dart`):
- partner viewer + `partnerAlreadySigned` shows the Neutral acknowledgment
  line and an enabled hold-to-sign button (AC2 partner CTA)
- partner viewer + `partnerAlreadySigned` shows the Named acknowledgment line
  when the requester display name is known
- requester viewer + `signedByMe` shows the signed card with the
  awaiting-partner line and no sign button (unchanged behavior)
- `bothSigned` shows the signed card with the Neutral both-signed line
- `bothSigned` shows the Named both-signed line when the partner display name
  is known, for the partner viewer too
- partner viewer hides the add-clause button and clause taps are inert
  (ADR-019e, `clause_toggle_row.dart` out of write scope)

Result: PASS (69/69, includes all pre-existing P1/P2-adjacent and P3 cases)

### `flutter analyze` (scoped to P3-touched files)

Command: `cd mobile && flutter analyze
lib/features/love_contracts/presentation/screens/love_contract_screen.dart
lib/l10n/generated
test/features/love_contracts/presentation/love_contract_screen_test.dart`

```
Analyzing 3 items...
No issues found! (ran in 1.4s)
```

Result: PASS. The repo-wide `flutter analyze` noise under
`mobile/build/ios/SourcePackages/checkouts/flutterfire/...` (git-ignored,
`mobile/.gitignore:33`) is pre-existing and unrelated to any `love_contracts`
file — confirmed in P2, reconfirmed here by scoping analyze to only the files
this phase touched.

### Visual fidelity

See `visual-fidelity/visual-fidelity-report.md` (`VISUAL_FIDELITY: PASS`).
Design reference for the `contract` canvas screen captured
(`visual-fidelity/design-reference-contract-android.png`, 406x900) and
confirms the pink-caption token this phase reused for the new acknowledgment
line. The two new sign-status states have no distinct canvas mockup (only one
composed `contract` state exists); team-lead authorized a narrow, one-time
extension of `main_preview.dart`'s write scope to add a preview-only fixture
trigger (`--dart-define=PREVIEW_CONTRACT_SIGN_STATUS`), and both states were
then captured as implemented screenshots on `emulator-5554`
(`implemented-contract-partnerAlreadySigned-emulator-5554.png`,
`implemented-contract-bothSigned-emulator-5554.png`) and visually inspected —
no overflow, clipping, or broken layout in either.
