# STORY-011 Slice Review — Slice A: pet-data-di

- Reviewer: Iris-QC (reviewer)
- Scope: `mobile/lib/features/pet/data/pet_models.dart`,
  `mobile/lib/features/pet/data/pet_mood.dart`,
  `mobile/lib/features/pet/data/pet_repository.dart`,
  `mobile/lib/core/di/service_locator.dart`,
  `mobile/lib/design_system/design_system.dart`,
  `mobile/test/features/pet/data/pet_models_test.dart`,
  `mobile/test/features/pet/data/pet_mood_test.dart`,
  `mobile/test/features/pet/data/pet_repository_test.dart`,
  `mobile/test/features/pet/presentation/fake_pet_repository.dart`,
  `mobile/ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved`
- Diff baseline: `0a467d03babf1ed4102c3fab09c61b2dec941a0b`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-001_cupid_flutter_mobile_app-STORY-011`

## 1. `PetModels`/`PetMood` JSON decode correctness vs. the `Response<void>` shape

**PASS.**

- `pet_models.dart` `Pet.fromJson` decodes exactly the fields the architecture
  D1/§4 contract table declares (`id, coupleId, species, name, happiness,
  level, totalInteractions, lastInteraction`), with `lastInteraction` handled
  as nullable ISO-8601 (`DateTime.parse`) per P1 task list.
- `PetStatus.fromJson` decodes `{ pet, mood, decayedHappiness, milestone,
  nextMilestone }` matching the §4 example payload verbatim; `milestone` is
  kept as a raw nullable string but documented display-forbidden, with
  `levelProgress`/`interactionsTowardNextMilestone` only forwarding numbers
  (no backend math reimplemented), matching the P1 AC.
- `PetSpecies.fromJson`/`wireValue` round-trip the three backend enum
  strings; unknown species throws `FormatException` (fail-fast, no silent
  wrong-species fallback — appropriate since species is a P0 identity field,
  unlike mood).
- `PetMood.fromWire` maps all five backend moods and falls back to `content`
  for null/unknown; `BunSpriteState.fromMood` maps all five moods to the five
  sprite states with no `sleep` state declared or reachable — matches
  architecture non-goal ("no invented mechanics: no `sleep` state") and P1 AC.
- `PetPairing.fromJson` treats `partnerId` non-null-and-non-empty as paired,
  matching D2.
- `pet_models_test.dart` (7 tests) and `pet_mood_test.dart` (4 tests) assert
  the full payload, the null-field payload, the unrecognised-mood fallback,
  species round-trip, all 5 mood→sprite mappings, and the absence of a
  `sleep` state by name — evidence in
  `coding-plan/phase-P1-pet-contracts.md` §7 (11/11 passed) and
  `coding-plan/test-results.md` §3 (rolled into the 214/214 full-suite pass).
- No model file imports `flutter_bloc`, `dio`, or `cupid_api` — confirmed by
  reading `pet_models.dart` (imports only `pet_mood.dart`) and
  `pet_mood.dart` (no imports).

## 2. `PetRepository` owns parsing and does not call undocumented endpoints

**PASS.**

- `pet_repository.dart` calls exactly four endpoints via `_api.dio` directly:
  `GET /users/me` (`readPairing`), `GET /pets/status` (`readStatus`),
  `PATCH /pets/interact` (`interact`), `POST /pets/adopt` (`adopt`) — matching
  architecture §4 "Contracts And Integrations" table and D1-D4 exactly. No
  call to `Epic4LovePetApi` and no `GET /pets` call (architecture: "`GET
  /pets` is not consumed").
  matches D1's escape-hatch precedent from `auth_repository.dart`.
- All JSON parsing happens in `pet_models.dart`/`pet_mood.dart`, invoked from
  the repository (`PetPairing.fromJson`, `PetStatus.fromJson`); the
  repository itself does no manual field extraction beyond passing
  `response.data` through.
- `readStatus()` returns `null` for a `null`/empty body without throwing
  (D-guardrail: empty body is HTTP 200, not 404) — verified by
  `pet_repository_test.dart` "an empty body maps to null".
- `interact()` and `adopt()` both discard their mutation response and
  refetch `GET /pets/status` via the shared `_requireStatus()` helper (D4),
  matching "the interact/adopt response is the raw pet row without `mood`".
  Verified by both "...then refetches GET /pets/status" tests asserting
  request order and count (2 requests, correct verbs/paths).
- Failure mapping: `_unwrap` rethrows `DioException.error` when it is a
  `CupidApiFailure`, else `UnexpectedFailure()` — no `DioException` or
  `DioExceptionType` inspected directly, matching the STORY-002/003 error
  contract. Verified by the 400 (interact cooldown), 409 (adopt conflict),
  and 400 (adopt not-yet) tests all asserting `HttpStatusFailure`.
- No automatic retry logic present in `interact()`/`adopt()` (architecture:
  "No automatic retry ... both mutate server state and are non-idempotent").
- One inline comment at `pet_repository.dart:6-11` documents the D1 rationale
  (`Epic4LovePetApi`/`Response<void>`) as the phase task explicitly required.

## 3. DI registration wiring

**PASS.**

- `service_locator.dart` adds one import and one additive
  `getIt.registerLazySingleton<PetRepository>(() => PetRepository(api:
  getIt<CupidApi>()))` block at the end of `setupServiceLocator()`, matching
  "additive-only edit" and "keep the edit to one additive block... to
  minimise merge conflicts."
- Verified the call `PetRepository(api: ...)` correctly resolves against the
  constructor `PetRepository({required this._api})`: Dart permits a
  field-initializing named parameter (`this._api`) to be invoked from another
  library using the field's un-prefixed label (confirmed empirically with a
  minimal two-library repro compiled via `dart analyze`/`dart run` — no
  private-identifier violation). This is the same pattern already used
  unchanged by pre-existing `AuthRepository({required this._gateway,
  required this._api, ...})` and its test call sites
  (`auth_repository_test.dart`), so it is consistent with established
  codebase precedent, not a new risk.
- No existing registration in `setupServiceLocator()` was reordered, removed,
  or altered; `test/core` regression evidence in
  `coding-plan/phase-P2-pet-data-layer.md` §7 (58/58 passed, including the
  `RealtimeCoordinator` DI-registration test) confirms the additive edit did
  not break existing consumers.
- `design_system.dart` adds two barrel exports
  (`tokens/bun_sprite_palette.dart`, `tokens/pet_hero_gradient.dart`), both
  files exist in the tree and the additions are alphabetically ordered
  consistent with the existing list. This is the only way for later-phase
  presentation code to obtain these tokens without importing token files
  directly ("one barrel import, no direct token/theme file imports").
  **Out-of-scope note:** whether `pet_hero_gradient.dart` itself complies with
  the D-guardrail ("declare the hero gradient as a private const inside the
  pet hero widget; do not add a global token") cannot be assessed here — that
  file and the widget that should own the gradient are not in this slice's
  file list. Flag for whichever slice review covers P4/P5
  (`bun_sprite.dart`/`pet_hero_card.dart`) to confirm the gradient is not
  duplicated as a redundant global token.
- **Unrelated-file note:**
  `mobile/ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved` (176
  new lines, net-new file) is in this slice's assigned diff but has no
  relationship to pet data/DI. It is a generated Xcode SwiftPM lockfile
  (Firebase pod/package resolution), not hand-authored code, and does not
  affect any of the four review points. No content issue found (only package
  name/version/checksum entries), but its presence in a "pet-data-di" slice
  is unexplained — recommend Scrum Master confirm which phase/commit is
  responsible for it and that it is not an accidental local-tooling
  artifact.

## 4. No dead/unused code introduced

**PASS.**

- Every public symbol added in this slice (`Pet`, `PetStatus`, `PetPairing`,
  `PetSpecies`, `PetMood`, `BunSpriteState`, `PetRepository` and its four
  methods) is exercised directly by the slice's own unit tests, per the
  evidence above.
- `FakePetRepository implements PetRepository` (test double, in
  `test/features/pet/presentation/fake_pet_repository.dart`) implements all
  four interface methods with call counters and error/override hooks; it is
  test infrastructure for later presentation-layer phases, not dead code
  within this slice.
- No unused imports observed in the reviewed files (`pet_models.dart` imports
  only `pet_mood.dart`; `pet_repository.dart` imports `cupid_api.dart`,
  `dio.dart`, `pet_models.dart`, all used).
- `coding-plan/test-results.md` §2 records `flutter analyze`: 0 issues in any
  file this story touched (10992 pre-existing/out-of-scope issues elsewhere),
  and `coding-plan/phase-P2-pet-data-layer.md` §7 records a scoped
  `flutter analyze` on exactly the three P2 slice files: "No issues found!".

## Summary

| Point | Result |
|---|---|
| 1. Models/Mood JSON decode correctness | PASS |
| 2. Repository owns parsing, no undocumented endpoints | PASS |
| 3. DI registration wiring | PASS |
| 4. No dead/unused code | PASS |

**Outcome: CLEAN** for slice-a (pet-data-di).

Non-blocking notes for Scrum Master (not slice-a failures):
1. Confirm `pet_hero_gradient.dart` (design-system token, exported but not
   reviewed here) doesn't duplicate a gradient the architecture says should
   be a private const in the pet hero widget — route to the P4/P5 slice
   review.
2. Confirm why `mobile/ios/.../Package.resolved` is part of this story's diff
   at all.

REVIEW_SLICE_COMPLETE: YES
