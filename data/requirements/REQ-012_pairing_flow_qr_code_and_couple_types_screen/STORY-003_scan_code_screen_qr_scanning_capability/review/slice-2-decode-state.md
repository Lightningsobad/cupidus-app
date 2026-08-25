# Review Slice 2 — Decode + State Logic (P2)

Reviewer: Iris-QC-6
Story: STORY-003_scan_code_screen_qr_scanning_capability
Requirement: REQ-012_pairing_flow_qr_code_and_couple_types_screen
Mode: scoped-slice (2 of 3)
RunId: RUN-REQ-012-STORY-003-reviewer-slice2
BaseHead: d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b
Worktree: /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-003_scan_code_screen_qr_scanning_capability

Slice Result: PASS
(no final story Outcome asserted here — Final Synthesis owns that)

## Scope Confirmed

`git -C <Worktree> diff --name-only <BaseHead> -- mobile/` returns 16 files; the
4 in this slice, all new, `+534` lines total:

| File | Δ |
|---|---|
| `mobile/lib/features/pairing/presentation/pairing_code_parser.dart` | +31 |
| `mobile/lib/features/pairing/presentation/scan_code_cubit.dart` | +158 |
| `mobile/test/features/pairing/presentation/pairing_code_parser_test.dart` | +61 |
| `mobile/test/features/pairing/presentation/scan_code_cubit_test.dart` | +284 |

Cubit state class names resolved from source before querying evidence:
`ScanCodeOpening`, `ScanCodeScanning`, `ScanCodeRecognized`, `ScanCodeInvalid`,
`ScanCodePermissionDenied`, `ScanCodePermissionPermanentlyDenied`,
`ScanCodeUnavailable` (`scan_code_cubit.dart:16-55`).

Not reviewed here, by handoff: runtime startup smoke, the `_InvalidCard` radius
deviation, UI/screen rendering, the other 12 diff files, story closure.

## AC2 — Decode resolves to the same pairing code and the same pairing seam

Verdict: **PASS** (logic half; the shared-instance *wiring* is Slice 3's file)

- Parse contract matches the architecture contract literally: trim → tail after
  the last `/` or `:` → strip non-alphanumerics → uppercase → accept only exactly
  6 alphanumerics (`pairing_code_parser.dart:18-31` vs `architecture/solution.md:151-157`).
- Length is 6, not 8, as explicitly decided in `architecture/solution.md:49-51`
  and guard-railed at `:202` ("Do not raise `_codeLength` to 8"). The story text's
  "6/8-character" phrasing was resolved there, so `pairingCodeLength = 6`
  (`pairing_code_parser.dart:2`) is conformant, not a regression.
- `_pasteCode`'s truncate-to-first-6 rule is deliberately **not** reused, so a URL
  payload cannot degrade to `HTTPS:` and reach the backend
  (`pairing_code_parser.dart:14-17`; asserted by `pairing_code_parser_test.dart:51-56`).
- The cubit owns no pairing call of its own: it takes a `JoincodeCubit` and calls
  `submit(code)` on that instance (`scan_code_cubit.dart:65-70`, `:120-121`).
  `JoincodeCubit.submit` is the same `acceptInvitation` seam manual entry uses
  (`joincode_cubit.dart:45-53`, unmodified by this story). Identical outcome is
  therefore structural, matching `architecture/solution.md:145-150`.
- Test evidence: `detection a valid payload submits exactly the normalized code`
  drives raw `https://cupid.app/join/abc123` and asserts the stub received exactly
  `['ABC123']` (`scan_code_cubit_test.dart:122-132`). The stub records the string
  handed to `acceptInvitation` (`:25-33`), i.e. the assertion sits at the manual-entry
  seam rather than assuming parity.
- Idempotency (`architecture/solution.md:170-173`): `_armed` is cleared before the
  parse (`scan_code_cubit.dart:108-110`), so a 30fps detection stream submits once —
  `detection repeated detections during an in-flight submit send one` fires four
  detections and asserts one submit (`scan_code_cubit_test.dart:134-146`).
- Boundary: `_armed` starts `false` and only `start()` with `granted` arms it
  (`scan_code_cubit.dart:82`, `:96`); `a detection without granted permission never
  submits` covers it (`scan_code_cubit_test.dart:91-100`).

Slice boundary note (not a finding): that the overlay receives *the same*
`JoincodeCubit` instance the join-code screen holds is a `BlocProvider.value`
wiring assertion in `scan_code_route.dart` / `scan_code_screen.dart` — Slice 3's
files. This slice verifies only that the cubit cannot pair by any other path.

## AC4 (logic half) — accept / expired / malformed state transitions

Verdict: **PASS**

| Required behavior | Source | Evidence |
|---|---|---|
| Malformed payload → State 4, zero network calls | `scan_code_cubit.dart:112-118` (returns before `submit`) | `detection a malformed payload is rejected with zero network calls` asserts `accept.codes` empty (`scan_code_cubit_test.dart:115-120`) |
| Accepted payload → State 3 held across the round trip | `scan_code_cubit.dart:120-121`, `:137-141` (Idle/InProgress fall through) | `routing ... in-flight submit holds State 3, no close` asserts `JoincodeInProgress` + `ScanCodeRecognized` + 0 close signals (`scan_code_cubit_test.dart:192-203`) |
| Backend invalid/**expired** → State 4, overlay stays open | `scan_code_cubit.dart:142-145` (only `InvalidOrExpiredCodeFailure` is rendered by the overlay) | `routing ... invalid or expired backend rejection -> State 4, no close` (`scan_code_cubit_test.dart:205-213`) |
| State 4 stays disarmed (framed bad code cannot re-fire) | `scan_code_cubit.dart:36-40`, `:109` | `detection detections stay disarmed while the invalid card shows` (`scan_code_cubit_test.dart:148-154`) |
| Retry re-arms and returns to scanning | `scan_code_cubit.dart:126-130` | `detection retry re-arms detection and returns to scanning` (`:156-167`); `retry outside the invalid state does nothing` (`:169-172`); backend-origin State 4 retried in `State 4 from the backend can be retried` (`:215-226`) |
| Every other failure → close, no invented error card | `scan_code_cubit.dart:146-148` | four parameterized tests over `AlreadyPairedFailure`, `SelfInviteFailure`, `InviterAlreadyPairedFailure`, `UnmappedPairingFailure` (`scan_code_cubit_test.dart:237-268`), matching `architecture/solution.md:163-166` |
| Success → close signal | `scan_code_cubit.dart:147-148` | `routing ... success closes the overlay` (`scan_code_cubit_test.dart:228-234`) |

Malformed-input coverage in the parser suite is real, not token: wrong length
(5 and 7, bare and URL-tailed), empty, whitespace-only, punctuation-only, a
truncated URL, a Wi-Fi QR and a vCard payload
(`pairing_code_parser_test.dart:28-49`). No fabricated success path exists — the
only route to `ScanCodeRecognized` is a successful parse.

## Verification Evidence

- Targeted suite **re-run by this reviewer**, not taken on trust:
  `flutter test test/features/pairing/presentation/pairing_code_parser_test.dart test/features/pairing/presentation/scan_code_cubit_test.dart`
  → `00:00 +47: All tests passed!`. Matches `coding-plan/test-results.md:112`
  ("47/47 passed (26 parser cases, 21 cubit cases)") exactly, and the case split
  reconciles against the source (12 accepted + 12 rejected + 2 = 26; 6 + 6 + 4 + 4 + 1 = 21).
- Regression: `flutter test test/features/pairing/` → `+189: All tests passed!`
  (`test-results.md:130-141`). The recorded `invite_cubit_test.dart` flake is in a
  file this slice neither touches nor imports; correctly disclosed rather than hidden.
- Static analysis: `flutter analyze lib/features/pairing test/features/pairing` →
  8 info-level issues (`test-results.md:152-165`). The two new ones are
  `scan_code_cubit.dart:68` / `:69` — `prefer_initializing_formals` on
  `_permissionGate` / `_joincodeCubit`. Confirmed unfixable as suggested: Dart
  forbids a named parameter starting with `_`, and the same false positive already
  sits at `joincode_cubit.dart:40`. Accepted, no new warning class introduced.
- Build gate: `flutter build apk --debug` → built (`test-results.md:384-392`).
  Whole-project `flutter analyze` is documented as unusable (vendored
  `build/ios/SourcePackages` checkouts) with the scoped invocation named as the
  gate (`test-results.md:379-382`); accepted for this slice, whose 4 files are all
  inside the analyzed scope.

## Observations (non-blocking, no rework requested by this slice)

1. **Colon/slash-tail parsing can still admit a non-pairing QR.** A Wi-Fi QR of
   the form `WIFI:S:HomeNet;T:WPA2;P:ABC123;` yields tail `ABC123;` → `ABC123`,
   which parses and reaches the backend. The suite's Wi-Fi case
   (`pairing_code_parser_test.dart:40`) ends at `T:WPA2;` and so does not exercise
   this. Consequence is bounded and honest: the backend rejects it and AC4's State 4
   renders, exactly as for a mistyped code — no fabricated success, no unsafe use of
   the payload (`architecture/solution.md:174-176`). The normalization rule is the
   one the architecture prescribed, so this is a spec-level tradeoff, not an
   implementation defect.
2. **Doc comment slightly overstates the guarantee.** `pairing_code_parser.dart:14-17`
   says the chosen rule avoids turning "a malformed scan into a real backend call".
   That holds for URL payloads (the case it cites) but not universally, per
   observation 1. Wording nit only.
3. **Cross-slice dependency for Slice 3.** `closeRequests` is a broadcast controller
   with no replay (`scan_code_cubit.dart:74-75`, `:86`): a close signal emitted
   before the screen subscribes would be dropped. Unreachable from this slice's code
   alone (a close requires an armed detection, which requires `start()` to have
   completed), but subscription timing lives in `scan_code_screen.dart` — Slice 3's file.

## Handoff Input Discrepancy

The handoff's `Checkpoint` /  run-file `checkpoint_path`
(`data/requirements/REQ-012_.../STORY-003_.../scrum-master-checkpoint.md`) does
not exist in either the worktree or the control checkout. The live checkpoint is
the requirement-level
`/Users/alantravala/workspace/snapsofts/cupid-apps/data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/scrum-master-checkpoint.md`,
which was read instead (line 14 / line 29 carry STORY-003 state and the 3-slice
dispatch). Recorded as **UNVERIFIED input path**, not a story finding.

REVIEW_SLICE_COMPLETE: YES
