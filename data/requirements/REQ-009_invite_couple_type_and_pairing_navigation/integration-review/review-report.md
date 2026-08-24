# Requirement Integration Review — REQ-009 Invite couple-type picker & pairing navigation restore

Outcome: PATCH_REQUIRED

Reviewer: Iris-QC · `requirement-integration-review` · 2026-08-24
Requirement: REQ-009_invite_couple_type_and_pairing_navigation
Branch: `codex/REQ-009_invite_couple_type_and_pairing_navigation-integration` @ `a66d6c8`
Scope gate: `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/integration-review/scope-gate.md`

The merged code is healthy. Every AC that REQ-009 owns holds in the combined
tree, the one cross-story regression is genuinely closed, and the navigation
graph matches the user-locked decisions exactly. What is missing is
requirement-level, not story-level: the merged branch has never been proven to
**build and boot**, and the cross-screen mobile visual audit has not been
produced. Both are named blocking gates for requirement closure, and neither is
waived. Nothing here routes back to STORY-001, STORY-002, or STORY-003.

## Merged stories

| Story | Story review | Merge ref | Integration verdict |
| --- | --- | --- | --- |
| STORY-001 Invite couple-type picker | `DEFERRED_ONLY` | `7c9118f` | AC1-AC7 hold in the merged tree |
| STORY-002 Pairing-choice navigation restore | `DEFERRED_ONLY` | `d2cdebb` | AC1-AC7 hold in the merged tree |
| STORY-003 Integration regression fix | n/a by design (no AC/UX/coding-plan) | `77d575e` via `main` `0963cfc`, synced by `19efb6d`/`a66d6c8` | Regression closed, no production change |

## Cross-story verification (independently checked, not taken on report trust)

| Check | Result |
| --- | --- |
| The cross-story contract — STORY-001's new `AccountRepository` GetIt dependency at `InviteScreen._defaultInviteCubit` (`invite_screen.dart`, composition root) | PASS. Production registration confirmed at `mobile/lib/core/di/service_locator.dart:122-124` (`registerLazySingleton<AccountRepository>`). The production eager resolve is correct; the gap was fixture-only, as STORY-003 diagnosed |
| STORY-003 fix scope | PASS. `git diff 19efb6d -- mobile/test/features/expenses/pairing_gate_test.dart` is `+17 −0`, one file, test-only. `_NeverReadyAccountRepository` mirrors the same file's existing `_NeverReadyPairingRepository` precedent. `invite_screen.dart` was in write scope and correctly left untouched |
| Sibling call-site sweep (rule 12d) for the same GetIt gap | PASS. The post-sync full suite is the sweep: 1386 pass / 2 pre-existing skips / 0 failures at the current integration HEAD, so no other fixture mounts `InviteScreen` with a partial locator |
| Navigation graph vs `req_master.md` locked decision #2 | PASS. `mobile/lib/core/navigation/onboarding_chain.dart:38-45` encodes `invite → waiting`, `joinCode → paired` (ADR-4 asymmetry, commented in place), `pairingChoice` deliberately branching with no successor, and no `→ vow` edge from either pairing node |
| STORY-002's merge-ordering precondition (B1 ratification `498bb85` must reach the integration branch before review) | PASS — now satisfied. The amendment text is present on this branch at `req_master.md:48-49`. The cycle-2 contradiction (tests asserting `joinCode → paired` against requirement text still saying Waiting-for-partner) does not exist in the merged tree |
| Combined-tree test evidence currency (rule 18) | PASS. `integration-review/final-full-suite-verification.md` records the run at HEAD `a66d6c8` with a clean worktree — the exact commit under review. Not re-run |

## Risk surfaces and critical gates

| Surface | Gate | Result |
| --- | --- | --- |
| Shared composition root (GetIt) | cross-story resolve + sibling sweep | PASS |
| Mobile navigation / discoverability | chain edges + `BACK_TO`, entry point verified at both story reviews (`pair_gate_shell.dart:139`) | PASS |
| Mobile interaction, design-source asset | per-story AC suites + per-story `VISUAL_FIDELITY: PASS` (12e2/12e3) | PASS |
| Test fixture contract | STORY-003 fix + full suite | PASS |
| **Merged-branch build** | **12g3 `- Build: PASS — …`** | **MISSING — B1** |
| **Merged-branch runtime startup smoke** | **12g3 `- Runtime/Smoke: PASS — …`** | **MISSING — B1** |
| **Cross-screen mobile visual integration** | **12g2 `integration-review/mobile-visual-audit.md`** | **MISSING — B2** |
| Configuration guide | 12a | NOT REQUIRED — `req_master.md:9-12` records `Status: NOT_REQUIRED`, and no setup/config surface is touched by the merged diff |

## Blocking findings

### B1 — the integration branch has never been proven to build or boot (rule 12g3)

`data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/integration-review/`
holds no `## Integration Build & Runtime` section on any file. Both required
lines are absent: there is no `- Build: PASS — <command + result>` and no
`- Runtime/Smoke: PASS — <startup smoke command + result>`. `req_master.md`
carries no `Integration-Verify: WAIVED — <reason>`, so the gate is live.

`final-full-suite-verification.md` is good evidence and it is current, but it is
the wrong evidence for this gate: `flutter test --no-pub` is neither a build nor
a startup smoke. A green unit/widget suite cannot observe app startup at all.

This is not a formality here. STORY-002's own review carried **D4** forward
specifically as an input to this gate: the story-level runtime smoke launched
`lib/main_preview.dart`, not the release entrypoint. That was the right call for
that story's one-constant delta, but it means **nothing in REQ-009 has yet
booted the real `main()`** — which is precisely the failure class of
`BUG-20260823-001` (a `main()` initialisation defect that unit tests cannot
see). STORY-001 additionally moved the composition root to eagerly resolve
`AccountRepository` from GetIt at `InviteScreen` build time, so the merged tree
has a new hard startup-path dependency that only a real launch exercises.

Action (owner: devops / mobile-dev, routed by scrum-master as the
integration-verification pass — **not** story rework):

1. In the integration worktree, run a real build of the release entrypoint
   (`lib/main.dart`, not `main_preview.dart`) and record the exact command and
   result.
2. Install and launch on the provided device/emulator; confirm the app reaches
   its first screen with no crash/error frame (`topResumedActivity` resolved,
   `logcat` clean of `FATAL EXCEPTION` / `AndroidRuntime`), and navigate as far
   as `InviteScreen` so the new `AccountRepository` resolve is actually executed
   on the startup path.
3. Write both lines into a `## Integration Build & Runtime` section inside
   `integration-review/`, each with the verdict as the first word after the
   colon:
   `- Build: PASS — <command + result>` and
   `- Runtime/Smoke: PASS — <startup smoke command + result>`.
   `Runtime: NOT_APPLICABLE` is not a pass. If it genuinely cannot run, record
   `Integration-Verify: WAIVED — <reason>` in `req_master.md` instead of
   asserting a smoke that did not happen.

### B2 — requirement-level cross-screen mobile visual audit is missing (rule 12g2)

`integration-review/mobile-visual-audit.md` does not exist. REQ-009 has mobile
participation with two UI-bearing stories, `design-fidelity-config.json`
records `ui_surface: true` with a locked `design_source` (`cupid-app`, surface
`mobile`), and both stories carry passing per-story `visual-fidelity/` evidence.

The per-story captures do not substitute for this in either direction, and 12g2
says so explicitly: each story photographed its own screen in isolation, so
nothing has yet checked the two screens *against each other* — the
`pairingChoice → invite` transition, shell/chrome consistency across the
restored edge, and the couple-type block's fit under the restored navigation.
That cross-screen surface is exactly what this requirement changed and exactly
what a per-story capture cannot see.

Action (owner: mobile-dev, `mobile-visual-audit` mode, routed by scrum-master):
produce `integration-review/mobile-visual-audit.md` covering the restored
`pairingchoice → invite → waiting` and `pairingchoice → joincode → paired`
screen sequence on the integration branch build.

## Deferred findings

- **D1 — `req_master.md`'s story registry is stale (owner: scrum-master).**
  The `## User Stories` table at `:87-90` still lists STORY-001 and STORY-002 as
  `Status: PENDING` although both are `MERGE_COMPLETE`, and **STORY-003 has no
  row at all** despite being a merged, committed change to the requirement. The
  registry is the traceability surface for the requirement; STORY-003's absence
  means the only record of that change outside Git is its own `story_master.md`.
  Reviewer does not edit workflow state — fold this into the closure update.
- **D2 — the post-sync verification evidence is not on the branch it verifies.**
  `final-full-suite-verification.md` is committed as `ba6c81a`, on `main` only;
  `git branch --contains ba6c81a` → `main`. The integration branch (`a66d6c8`)
  predates it, so the file is absent from the tree it certifies. The evidence
  itself is valid and current (it names HEAD `a66d6c8`); this is placement only,
  and it resolves when the integration branch lands on `main`.
- **D3 — carried forward from the story gates, unchanged and still non-blocking.**
  STORY-002 D2 (EN primary-CTA wording drift; `en` is not user-enabled per OQ5)
  and D3 (two stale rows in STORY-002 `coding-plan/test-results.md:13` and
  `:297-306` that later sections of the same file explicitly supersede).
  STORY-001 DF-4 (card 4 "Gắn bó lâu dài" mapped to the existing
  `LIVING_TOGETHER` wire value — accepted semantic drift, recorded as a REQ-009
  follow-up in `architecture/solution.md` §6).
- **D4 — reviewer skill rule 5a still contradicts `validate-reviewer-two-phase.sh`,
  third occurrence in this requirement (owner: scrum-master).** Unchanged from
  STORY-001 DF-6 and STORY-002's scope-gate note. Recorded here because this
  review's `scope-gate.md` also had to be written outside the handoff's declared
  `WriteScope` (which names `review-report.md` only) to satisfy the guard.

## Traceability

- Requirement: `req_master.md` locked decisions #1 (couple-type picker after the
  code, leading to the CTA) and #2 (post-code navigation, with the 2026-08-24
  asymmetric-invitee amendment) — both verified against
  `onboarding_chain.dart:32-46` and the two story AC tables.
- Story reviews: STORY-001 `review/review-report.md` (`DEFERRED_ONLY`, AC1-AC7
  PASS, runtime smoke PASS, `VISUAL_FIDELITY: PASS` pixel-verified); STORY-002
  `review/review-report.md` (`DEFERRED_ONLY`, AC1-AC7 PASS, B4/B5 closed, D4
  raised as an input to this gate).
- Merge refs: `7c9118f`, `d2cdebb`, `19efb6d`, `a66d6c8`; STORY-003 `77d575e`
  via `main` `0963cfc`.
- Integration evidence: `integration-review/mobile-fix-notes.md` (STORY-003
  diagnosis + fix trail), `integration-review/final-full-suite-verification.md`
  (1386 pass / 2 pre-existing skips / 0 failures at `a66d6c8`).
- Integration diff reviewed: `git diff 0963cfc3 --name-status` → 37 files. The
  handoff's `BaseHead: 19efb6d9` was not used as the review baseline; it covers
  only STORY-003's 4-file slice and would have hidden STORY-001 and STORY-002
  entirely. Recorded in the scope gate.

## Workflow recommendation

- Requirement status: `IN_PROGRESS`. Do **not** mark REQ-009 `DONE`.
- Do not reopen STORY-001, STORY-002, or STORY-003 — no finding routes to a
  story lane, and no production code change is requested.
- Route the requirement-level integration-verification pass for B1 (build +
  real-entrypoint runtime smoke) and the mobile visual audit for B2.
- Re-run this gate once `## Integration Build & Runtime` and
  `mobile-visual-audit.md` exist; the code half of this review needs no repeat.
- Fold D1 into the closure state update.
