# REQ-004 Requirement Integration Review — Notifications DND Banner Copy Reconciliation

Reviewer: Iris-QC
Mode: `requirement-integration-review`
Date: 2026-08-21
Requirement: REQ-004_notifications_dnd_banner_copy_reconciliation
Scope gate: `data/requirements/REQ-004_notifications_dnd_banner_copy_reconciliation/integration-review/scope-gate.md`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-004_notifications_dnd_banner_copy_reconciliation`
Branch: `codex/REQ-004_notifications_dnd_banner_copy_reconciliation-integration`
BaseHead: `2632b0d9cd30ea850bd7e71a35f0df90ef11e96e` · Integration HEAD: `4157816`

Outcome: DEFERRED_ONLY

## Merged stories and merge refs

| Story | Story review outcome | Story tip | Merge commit |
| --- | --- | --- | --- |
| STORY-062 notification_copy_adr002_compliance_ruling | `DEFERRED_ONLY` (0 blocking, 1 deferred D-1 LOW) — `STORY-062.../review/review-report.md` | `03382f3` | `4157816` |

Single-story requirement; `req_master.md` records
`INTEGRATION_VERIFICATION_REQUIRED: NO` — no cross-story runtime interaction to
verify.

## Merge integrity — no drift vs the approved story diff

- `git log --format='%h parents=%p' -n 1 HEAD` → `4157816 parents=2632b0d 03382f3`:
  the merge's only two parents are the requirement base and the reviewed story
  tip. No third branch, no rebase, no amended content entered here.
- `git diff --stat 03382f3 HEAD` → **empty**. The merge result is byte-identical
  to the story tip the story review approved; the merge itself contributed zero
  content.
- `git merge-base HEAD main` → `2632b0d9`, matching the declared `BaseHead`, so
  the integrated diff below is exactly this requirement's work and nothing else.
- `git diff --name-only 2632b0d9 HEAD` → 5 paths: 4 REQ-004 artifacts plus the
  single test file `mobile/test/features/reminders/reminder_copy_guard_test.dart`
  (+6/-1). Zero paths under `mobile/lib`, `android/`, `ios/`, or any
  backend/web tree.

The reviewed content therefore equals the approved content. Stop-rule condition
(merge-introduced drift) does not fire.

## Integration Build & Runtime

Run by the Reviewer on the merged integration branch (not copied from story
evidence), `flutter 3.44.1 / Dart 3.12.1`, in
`<Worktree>/mobile` after `flutter pub get` + `flutter gen-l10n`:

- Build: **PASS** — `flutter analyze lib test/features/reminders/reminder_copy_guard_test.dart`
  → `80 issues found`, all severity `info` (`prefer_initializing_formals`,
  `use_null_aware_elements`, one `deprecated_member_use`). **0 errors, 0
  warnings.** Every one sits in a `lib/` file that this requirement does not
  touch, so all 80 are byte-identical to `main` at `2632b0d9` — pre-existing and
  out of scope per rule 7. The changed test file itself is clean.
- Tests: **PASS 12/12** — `flutter test test/features/reminders/reminder_copy_guard_test.dart
  test/features/account/presentation/screens/notification_settings_screen_test.dart
  test/features/onboarding/permissions_screen_test.dart` → `00:01 +12: All tests
  passed!`, including the two cross-screen ratification guards the ruling depends
  on: "shows only the numeric cap copy, no DND-bypass clause (DEC-6)" and
  "renders the design source copy for the vi locale" / "en locale renders the
  design source English copy".
- Runtime / Smoke: **NOT_APPLICABLE, evidenced not asserted.** 12g3 exists to
  prove a merged branch still boots. Here the merged tree contains no runtime
  bytes of its own: the `git diff --name-only` above shows zero files under any
  compiled/shipped path, so the app binary produced from this branch is identical
  to the one already running on `main` at `2632b0d9`. There is no new runtime
  state to boot into. `req_master.md` independently records
  `INTEGRATION_VERIFICATION_REQUIRED: NO`. Booting an emulator would re-measure
  `main`, not this requirement. See D-2 for the token-hygiene follow-up this
  leaves for Scrum Master.

## Requirement-level acceptance

The requirement's deliverable is a PO ruling plus whatever code change that
ruling entails. Verified on the integration branch:

| Requirement scope item | Verdict | Evidence on this branch |
| --- | --- | --- |
| Ruling made and documented (path (a) vs ADR-002 amendment), citing ADR-002 rationale | PASS | `req_master.md` "Ruling (2026-08-20, Product Owner)": Resolution Path (a), ADR-002 **not** amended, uniform across both tokens, grounded in STORY-009 `solution.md` D1 (no Critical Alerts / no DND override) and ASSUMPTION-2/R9 foreground-only. The sole Open Question is marked RESOLVED against it. |
| Ruling states whether it applies uniformly to both tokens | PASS | Explicit: "applied uniformly to both tokens" (`req_master.md:77-79`, `:83`). |
| `notifs` banner token (`Do Not Disturb`) closed | PASS | Ratifies the shipped `notifs_cap_banner` numeric-cap-only copy; pinned green here by the DEC-6 widget test. No copy change was needed, and none was made. |
| `permissions` row token (`Synced Alarm`, folded-in STORY-047 AC2) closed | PASS | Ratifies the ADR-002-canonical `Nhắc nhở đồng bộ`/`Synced Reminder` copy; pinned green here by both locale tests. `permissions_screen.dart` untouched. |
| Guard updated consistently with the ruling, not silently deleted | PASS | The guard was **hardened**, not weakened: `'không làm phiền'` added to `_forbiddenTokens`, consumed by the same `lowered.contains(token)` loop as the three pre-existing tokens. This is the correct direction for a ruling that upholds the ban, and it closes the Vietnamese-translation bypass that REQ-002 finding E-2 raised. |
| Out-of-scope boundaries respected (REQ-003, REQ-002 other findings, STORY-047 AC1/3/4/5) | PASS | The 5-path diff touches nothing outside REQ-004 artifacts and the one guard test. |

Cross-story contracts, migrations, generated clients, shared schemas,
configuration guide (12a): **none touched** — no such surface appears in the
integrated diff, so no consistency check applies.

## Blocking findings

None.

## Deferred findings

**D-1 (LOW) — carried forward unchanged from the STORY-062 story review.** The
copy guard walks `Directory('lib')` filtering `.dart`, so the canonical ARB copy
sources (`mobile/lib/l10n/arb/app_vi.arb`, `app_en.arb`) are never scanned; the
generated Dart that does contain those strings is gitignored. A banned phrase
could sit in an ARB file on a fresh checkout and pass. Pre-existing and identical
for the three tokens that predate this requirement; not re-litigated here. It
does gain a little weight at requirement level, because REQ-004's ruling now
leans on this guard as the durable enforcement mechanism for a decision that is
explicitly language-independent ("no DND-override or native-alarm claim ships in
**any** language"). Suggested follow-up (unchanged): extend the filter to `.arb`,
as its own RWB item or a REQ-004 follow-on story.

**D-2 (LOW, Scrum-Master-owned artifact hygiene) — `req_master.md` bookkeeping
is behind the delivered state.** Two items, neither affecting the code:
1. The `## User Stories` table still shows STORY-062 `Status: PENDING`, while
   `story_master.md` records `Status: DONE`.
2. Rule 12g3's documented waiver token is the literal
   `Integration-Verify: WAIVED — <reason>`; this requirement instead carries
   `INTEGRATION_VERIFICATION_REQUIRED: NO`. The substance is satisfied (see
   Integration Build & Runtime above) but if `validate-done-gate.sh` matches the
   literal token, closure will trip on wording rather than on evidence.
Both live in files Reviewer must not edit (rule 7/17); flagged for Scrum Master
to settle during closure.

## Traceability

- Requirement: `req_master.md` — Ruling, Scope, Out of Scope, Open Questions (RESOLVED), `INTEGRATION_VERIFICATION_REQUIRED: NO`.
- Story review: `STORY-062.../review/review-report.md` (`DEFERRED_ONLY`, AC1-AC4 all PASS) — accepted as-is, not re-reviewed.
- Implementation evidence: `STORY-062.../verification/mobile-verification.md` §1-§3, `MOBILE_COMPLETE`.
- Merge refs: base `2632b0d9`, story tip `03382f3`, merge `4157816` (drift check above).
- Code: `mobile/test/features/reminders/reminder_copy_guard_test.dart`.
- Visual fidelity (12e2/12g2): correctly scoped out — `story_master.md` declares
  `Visual-Fidelity-Evidence: NOT_APPLICABLE` with reason, and the integrated diff
  independently confirms zero production UI changed, so there is no rendered
  state to capture at story or requirement level. No requirement-level
  `mobile-visual-audit.md` is produced or required for a requirement that ships
  no screen change.

## State recommendation

- Requirement status: `DONE` (Scrum Master owns the transition and the D-2
  artifact updates).
- Story STORY-062 remains `DONE` on its already-approved story review.
- Track D-1 as a follow-up item if the ARB coverage gap should be tracked; it is
  not a condition of closing REQ-004.
