# Slice Review: STORY-019 — Slice P3-mobile-ui-visual-fidelity

Scope: mobile UI + visual fidelity only (P1 backend and P2 mobile data/state
are separate slices with their own reports).
BaseHead: `7f2e8ccc8fb8361d9c105fdd0d2f6469d31c20c4`

Files reviewed (`git diff <BaseHead> -- <path>`):
- `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`
- `mobile/lib/l10n/arb/app_en.arb`
- `mobile/lib/l10n/arb/app_vi.arb`
- `mobile/test/features/love_contracts/presentation/love_contract_screen_test.dart`
- `mobile/lib/main_preview.dart`

## Findings

### AC2/AC3 viewer-aware UI — matches `ux/uiux-spec.md` §2/§3 table

- `partnerAlreadySigned` now renders `_SignPromptSection(enabled: state.canSign,
  acknowledgmentLine: ...)` instead of falling into the old
  `signedByMe`/`awaitingPartner` shared branch. The Named/Neutral
  acknowledgment strings match the UX spec §3 text verbatim in both EN and VI.
  The hold-to-sign button stays enabled for this state, correctly giving the
  partner the CTA required by AC2.
- `signedByMe` keeps the existing awaiting-partner status line (no sign
  button); `bothSigned` is a new switch arm using the new
  `loveContractBothSignedNamed/Neutral` status line via `_SignedConfirmationCard`.
  Both match Assumption A-1 in `architecture/solution.md` (client derives
  "both signed" as its own visual state, no new backend status value needed).
- `_SignedConfirmationCard` was refactored to take a precomputed `statusLine`
  instead of deriving it internally — matches
  `coding-plan/phase-P3-mobile-partner-signed-ui.md` §3 exactly, and removes
  the now-false "`awaitingPartner` is defensive-only / ADR-006c" doc comment
  as directed.
- Doc comment at the top of the file was correctly updated from the old
  ADR-006c/no-`GET /users/:id` rationale to `architecture/solution.md`
  Assumption A-2 (viewer-relative `partnerDisplayName`, no new plumbing
  needed).

### ADR-019e clause read-only gating (partner never edits clauses)

- `ClauseToggleRow` is wrapped in `IgnorePointer(ignoring:
  !state.canEditClauses)` — rows still render (partner must see what they're
  signing) but taps are inert.
- The add-clause `Align`/`TextButton.icon` block is now conditional on
  `if (state.canEditClauses)` — hidden entirely for the partner, consistent
  with the existing AC4 hide-not-disable pattern rather than a disabled
  affordance.
- Test `'partner viewer hides the add-clause button and clause taps are inert'`
  verifies both: button absent via `findsNothing`, and a tap on a preset
  clause row leaves the clause count at `0/20 clauses` (registers no visible
  regression from an inert tap — see note below).

### l10n (`app_en.arb` / `app_vi.arb`)

- Four new keys (`loveContractPartnerAlreadySignedNamed/Neutral`,
  `loveContractBothSignedNamed/Neutral`) added to both files with placeholder
  `otherPartyName`, correctly reflecting that these strings are shown
  symmetrically to either viewer (verified against `ADR-019d`/A-2:
  `partnerDisplayName` is already viewer-relative).
- `app_vi.arb` metadata (`@key` description + `placeholders`) follows the
  established convention exactly (cross-checked against the pre-existing
  `loveContractAwaitingPartnerNamed` block). `app_en.arb` has **no** per-key
  `@`-metadata anywhere in the file (only `"@@locale": "en"` — confirmed by
  diffing the full pre-change file), so the new EN keys correctly omit
  metadata too. The coding plan's phrasing ("add to both ARB files with
  `@`-metadata and placeholders") is a documentation imprecision, not a code
  defect — actual codebase convention is metadata-in-VI-only, and this diff
  follows it consistently with every pre-existing key.
- EN/VI copy for the two new-state pairs matches `ux/uiux-spec.md` §3
  verbatim. The `bothSigned` pair has no spec-mandated exact text (spec only
  says "visual unchanged from STORY-006"); the chosen copy ("You and
  {otherPartyName} both signed" / "Bạn và {otherPartyName} đều đã ký") is
  consistent in tone with the rest of the screen and not a defect.

### `main_preview.dart` write-scope extension

- Confirmed narrow and preview-only: `_contractSignStatusFixture` reads
  `String.fromEnvironment('PREVIEW_CONTRACT_SIGN_STATUS')`, defaults to the
  live `getIt<LoveContractRepository>()` when unset, and only swaps in
  `_PreviewLoveContractRepository` (a fixture-backed subclass whose
  `saveClauses`/`sign` throw `UnimplementedError`, since a static capture
  never calls them) for the two new states. No new screen, component, or
  token was added, matching the Do-Not list and the team-lead authorization
  recorded in `visual-fidelity/visual-fidelity-report.md` and
  `coding-plan/test-results.md`.

### Test coverage vs. phase Test Scope (`phase-P3-mobile-partner-signed-ui.md` §5)

All six required cases are present in the diff and match by name/assertion:
partner+`partnerAlreadySigned` (Neutral, enabled button), partner+
`partnerAlreadySigned` (Named), requester+`signedByMe` (unchanged, no sign
button), `bothSigned` Neutral, `bothSigned` Named (partner viewer), and the
add-clause-hidden/inert-tap case. `flutter test test/features/love_contracts`
reports 69/69 passing and `flutter analyze` (scoped to the P3-touched files)
is clean, per `coding-plan/test-results.md`.

### Visual fidelity

- `VISUAL_FIDELITY: PASS` in `visual-fidelity/visual-fidelity-report.md`.
  Both new-state screenshots exist on disk:
  `implemented-contract-partnerAlreadySigned-emulator-5554.png` and
  `implemented-contract-bothSigned-emulator-5554.png`, alongside
  `design-reference-contract-android.png`.
- The report's narrative is internally consistent and matches the code: the
  design canvas has one composed `contract` state with no per-sign-status
  mockup, so the two new states were verified by (a) a structural fidelity
  check reasoning about the additive-only diff reusing existing tokens, and
  (b) an implementation smoke check using the authorized `main_preview.dart`
  fixture trigger, with both captures reported free of overflow/clipping.
  This is a reasonable, clearly-justified substitute for a pixel mockup diff
  given no mockup exists for these two data-derived states.

### Stray blocker line in `coding-plan/test-results.md`

Per the handoff's request to call this out either way: the line
`Blocker: MOBILE_VISUAL_AUDIT_SCREEN_UNREACHABLE` directly after the Visual
fidelity section's `PASS` narrative is **stale leftover text**, not a live
blocker. Evidence:
- The paragraph immediately above it describes the blocker as already
  resolved ("Captured per team-lead direction after the initial
  `SCREEN_UNREACHABLE` block"), i.e. past tense.
- `visual-fidelity-report.md`'s own narrative independently confirms the same
  resolution path (team-lead authorized the `main_preview.dart` extension,
  both screenshots were then captured and inspected, "No defect found in
  either capture").
- The two screenshot files it claims are unreachable are confirmed present on
  disk (see Files list above).

This is a documentation-hygiene defect in `test-results.md` (a trailing
line not cleaned up after the blocker was resolved), not a code or test
defect, and does not indicate any unresolved issue in the P3 mobile UI or
visual fidelity work. Recommend Scrum Master/mobile-dev delete that trailing
line in a follow-up edit to `coding-plan/test-results.md`, but it does not
block this slice.

## Slice Verdict

No defects found in the P3 mobile UI + visual fidelity slice. Code matches
`ux/uiux-spec.md` §2/§3, `architecture/solution.md` ADR-019e/Assumption A-1/A-2,
and the phase's Do-Not list and Test Scope. The one issue found (stale
`Blocker:` line in `test-results.md`) is a non-blocking documentation
inconsistency, called out above per the handoff's instruction, not a slice
defect.

REVIEW_SLICE_COMPLETE: YES
