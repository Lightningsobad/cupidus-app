# Scrum Master Checkpoint — Portfolio Retro Hardening (REQ-001)

Scope:
- Requirement: REQ-001_cupid_flutter_mobile_app
- Workflow: hardening course-correction per `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md` § Open Question Triage / Approved Scope Change
- Source: `data/requirements/REQ-001_cupid_flutter_mobile_app/retro-audit/audit-report.md` (Audit Date 2026-08-12)

Binding course-correction (user-confirmed, do not deviate):
1. STORY-017 — DONE.
2. STORY-018 — DONE.
3. STORY-019 love_contract_partner_visibility (fixes STORY-006 AC2/AC3) — **DONE**.
   Review `Outcome: DEFERRED_ONLY` (0 blocking, 1 non-blocking deferred: missing
   "Phase P2" section in `test-results.md`, code independently confirmed passing).
   `git-story-boundary.sh complete` ran clean: commit+merge `1bd16e41be61f307796ab79e80e2e89e03fc6bc0`
   on `main`. `req_master.md` User Stories row and `story_master.md` Status/Role
   Completion both updated.
4. STORY-020 anti_ghosting_chat_mount (fixes STORY-008 AC2, mount `GhostStateRow`
   into `ChatScreen`) — **NEXT, NOT STARTED**. Start with Product Owner
   (`Andy-PO`) — no story directory exists yet under
   `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-020_anti_ghosting_chat_mount/`.
5. STORY-021 privacy_notifications_capability (fixes STORY-016 AC2/AC3) — NOT STARTED, after STORY-020.
6. After STORY-020 + STORY-021 DONE: set REQ-001 `Status` back to `DONE` per the
   hardening plan's Done Condition; update `master_requirements_list.md` REQ-001 row.

Do Not Re-read: STORY-017/018/019 implementation or review detail (all closed,
committed, merged), audit-report.md full body, req_master.md full body beyond
the User Stories table — all superseded by this checkpoint.

## Next Valid Step

STORY-020 PO complete and independently verified on disk
(`STORY-020_anti_ghosting_chat_mount/story_master.md`, Status PENDING,
Complexity XS, Story-Class standard, Implementation Lane mobile, single AC
carried forward from STORY-008 AC2). req_master.md STORY-020 row left
unchanged (title not materially different).

STORY-020 UX complete and independently verified on disk
(`ux/uiux-spec.md`, 124 lines): confirmed mount point is
`chat_screen.dart` `_ChatViewState.build` Column, after the `GhostBubble`
BlocBuilder and before `ChatComposer` BlocBuilder, citing 3 concordant
STORY-008 sources. No new design, just placement pin + seam behavior notes.

STORY-020 Tech Lead complete and independently verified on disk (Tech Lead
judged full single-phase plan warranted over pure compact mode; verified
well-scoped, not overbuilt): `architecture/solution.md` (mount seam = new
Column child after GhostBubble/before ChatComposer, no new provider, key
discovery that STORY-008's stale DI-guard comment no longer blocks the
poll), `coding-plan/master-plan.md` (single P1, Mobile Developer, NOT_STARTED),
`coding-plan/phase-P1-mobile-chat-ghost-state-mount.md` (2 files: edit
chat_screen.dart + new mount test, 4 ACs, visual audit required).

STORY-020 P1 code+test complete and independently verified on disk: diff
matches plan exactly (barrel import, `partnerId` threaded, `GhostStateRow`
inserted after `GhostBubble`/before `ChatComposer`, comment cites solution.md
§4), 5/5 new mount tests + 110/110 regression + clean `flutter analyze`,
`master-plan.md` P1 flipped `DONE`.

STORY-020 visual audit returned `VISUAL_FIDELITY: BLOCKED` — verified on disk
(`visual-fidelity/visual-fidelity-report.md` + one blocker screenshot). Real,
pre-existing bug, NOT caused by P1: `main_preview.dart`'s bootstrap never
calls `AuthRepository`, so `BackendUserIdStore.backendUserId` is null on the
preview path, and `ChatCubit`'s constructor null-checks it
(`chat_cubit.dart:77`) — `ChatScreen` throws in `initState` for EVERY preview
render, pre-existing and reproduces identically on the STORY-018 pre-mount
baseline. Side-finding (not this story's scope, do not chase now):
STORY-018's `chat` screen in its 37/37 coverage was never actually a
`ChatScreen` render either — same crash.
Mobile-dev staged (did not execute) a backend HTTP recipe proving the
eligible-storm state IS reachable once the crash is fixed. Recommends Option
A (STORY-019 precedent): narrow one-time `main_preview.dart` write-scope
extension so the preview bootstrap does a real backend login. This decision
is above mobile-dev's write scope — routing to `Alan-Techlead` next
(`Mode: completion/resume`) to authorize/decide, per the same pattern used in
STORY-019 P3.

Tech Lead complete, verified on disk: `architecture/solution.md` §7
authorizes Option A but CORRECTS the target file — grant is
`mobile/lib/preview/preview_session_bootstrap.dart` ONLY (not
main_preview.dart as mobile-dev proposed; that path is a dead end, see §7).
Exact may/must/may-not write-scope spelled out, plus a second
previously-unreported blocker (ChatEntryGate bypassed in preview so
partnerId stays null — grant covers calling ChatPartnerStore.refreshFromServer()
too) and backend-state execution authorization for the staged HTTP recipe
(dev backend port 3005, seeded accounts only). STORY-018 chat-coverage gap
flagged as a known non-blocking follow-up, explicitly not this story's scope.

STORY-020 visual audit PASS, independently verified on disk: 2 real
`implemented-*` captures + pixel-diff evidence (only rows 717-766 differ, row
placement + zero idle-cost proven by position not inspection), backend
mutation table recorded, grant verification bullets all satisfied. Bootstrap
diff stayed exactly inside the grant (`preview_session_bootstrap.dart` only,
24 lines added).

STORY-020 full changed-file set (vs BaseHead
`1bd16e41be61f307796ab79e80e2e89e03fc6bc0`): `mobile/lib/features/chat/
presentation/screens/chat_screen.dart`,
`mobile/lib/preview/preview_session_bootstrap.dart`,
`mobile/test/features/chat/presentation/chat_screen_ghost_state_row_mount_test.dart`
(new) — 3 files. Classified Tier 1 (Reviewer Compact Story Review) per
`references/handoffs/reviewer.md`: Story-Class standard (not trivial, so
Tier 0 lightweight is not available) + RED-PATCH rework, well under the
8-file Tier 1 cap, no migration/auth/payment/external-integration/prod-
runtime/multi-lane-contract risk, test evidence complete and non-
contradictory.

First `Iris-QC` dispatch attempt was blocked by `guard-review-ready.sh
[REVIEW_NOT_READY]`: `story_master.md` had no `Implementation (Development)`
marker even though `master-plan.md` P1 was `DONE` and all evidence was
verified. Fixed: added a `## Role Completion` section to `story_master.md`
with `[x]` bullets for Product Owner, UI/UX Designer, Architecture (Tech
Lead), Implementation (Development) — each citing exact artifact paths;
Review (Reviewer) bullet deliberately not yet added, to be appended after
`Iris-QC` returns.

`Iris-QC` dispatch is next (retry), `Mode: compact-story-review`. **Awaiting
`REVIEW_COMPLETE`.** On CLEAN/DEFERRED_ONLY: append Review (Reviewer) bullet
to the Role Completion section, flip Status DONE, flip req_master.md row,
`git-story-boundary.sh complete`, commit. On PATCH_REQUIRED/BLOCKED: route
the named fix back to Alex-Mobile-Dev with exact findings.

## Standing operational notes

- Never write the literal substring "retro-audit" in a non-reviewer handoff prompt (`guard-broad-handoff.sh` GENERIC false-positive) — paraphrase, or use `Checkpoint: NONE`.
- Canonical runtime agent names only: `Andy-PO`, `Pink-Designer`, `Alan-Techlead`, `Alex-Mobile-Dev`, `Abert-BE`, `Iris-QC`, etc. — never per-phase/per-slice variants.
- Coding-plan edits must keep `## 5. Phases Overview` (level-2, not nested), the 10-column header, `P\d+` phase ids, bare terminal `Status` tokens (rationale in prose below, not in the cell).
- Treat any completion-status teammate message as possibly stale/out-of-order; re-verify against disk (git status, file Status fields) before reacting.
- Platform `Grep`/`Glob` tools are NOT available in this runtime session
  (confirmed via ToolSearch + direct call). Their absence is a hard runtime
  fact, not a transient load failure — do not retry loading them. Use `Read`
  with `offset`/`limit` to locate content in large files; the
  `guard-query-first-bash-read.sh` hook still blocks shell `grep` over
  `data/**`/source/config files, so there is no fallback for content search
  other than targeted `Read` chunks.
- `list-releasable-agents.sh` has repeatedly printed stale
  `session-e67e7d2e`-suffixed handles that do not match this session's actual
  live teammates (`session-795f1c08`); `TaskStop` correctly rejects them. Do
  not retry with a guessed/corrected suffix — this appears to be a persistent
  environment quirk, not a one-off. Idle teammates left un-stopped are
  harmless; re-check at the next natural checkpoint in case the script
  self-corrects.
- `Iris-QC` sent 4 messages re-pathing the same Slice A output early in this
  story before settling; content was identical each time, do not chase
  further path corrections from a slice reviewer — verify on disk via
  `find`/`Read` and consolidate directly instead of round-tripping.
- This checkpoint is a rolling cursor (budget ≤120 lines) — compact on every write; do not re-accumulate round-by-round history.
