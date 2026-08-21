# Story Master: STORY-002 Standardize VPS backend deploys onto GitHub Actions CI/CD
Status: DONE
Complexity: complex
Implementation Lane: shared
Story-Class: standard
Visual-Fidelity-Evidence: NOT_APPLICABLE - CI/CD infrastructure change only (GitHub Actions workflow, deploy script, VPS Docker Compose overlay); no operator-facing UI surface exists to screenshot, per story_brief.md "Existing system entry / discoverability seed: not applicable" and the UX-Spec waiver below.

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — UX-Spec: WAIVED -- no operator-facing UI surface, CI/CD infrastructure change only (scrum-master, per story_brief.md "Existing system entry / discoverability seed: not applicable")
- [x] Architecture (Tech Lead)
- [x] Implementation (Development) — F1-F4 patched (commit e143527), landed on codex/REQ-005...-integration (bf6427b) and onto `main` (f87a084, pushed to origin). Git boundary MERGE_COMPLETE: true (merge_sha bf6427b).
- [x] Review (Reviewer) — Requirement-integration-review Outcome: DEFERRED_ONLY (`integration-review/review-report.md`), scope STORY-002, diff `f0f043f..bf6427b`. Merge disposition: "approved to merge... nothing that remains open is a merge blocker." Reviewer's explicit pre-DONE checklist: (1) reconcile this file — done; (2) observe first real `deploy-backend.yml` run — done (see below). DONE gate satisfied per `DEFERRED_ONLY` outcome.

## Task 8 evidence (first real deploy-backend.yml run)

- Trigger: manual `workflow_dispatch` on `main` at `f87a084` (push-triggered run never fired — GitHub registered zero runs for this new repo despite the landing push touching `backend/**` and the workflow files; root cause not fully diagnosed, flagged as a residual CI oddity, not a code defect). Dispatched only after explicit user authorization (AskUserQuestion, 2026-08-21).
- Run: https://github.com/hoak57uet/cupidus/actions/runs/32457256470 — **conclusion: success**.
  - `build-and-push`: green in 1m18s, pushed `ghcr.io/hoak57uet/cupidus-backend:f87a084623f38ddd701fdbb1d2586719a95e8cd8`.
  - `deploy-and-verify`: green in 53s. Log confirms `cupid-backend`/`cupid-redis` recreated and started, `health gate passed`, post-cutover row-count check ran cleanly (`SELECT count(*) FROM users` → 79, no error) — live confirmation that F1 (forced-command prefix, including the previously-unfixed health-gate curl), F2 (GHCR login), F3 (`-f docker-compose.prod.yml` pinning), and F4 (in-container `$POSTGRES_USER` expansion) all work against the real VPS/wrapper, not just the dry-run in the review report.
- End-to-end verification: `curl -s -o /dev/null -w '%{http_code}' https://api.cupidus.app/` → **200** (real backend response through the Cloudflare edge). This also resolves STORY-001's AC2, which was blocked on this same backend being live on `127.0.0.1:3010`.

## Deferred, non-blocking (per reviewer's DEFERRED_ONLY disposition, not DONE blockers)

- F5 (AC7 simulation bind-mount corruption risk) — must be fixed before Task 9 (AC7 negative rollback proof) is ever dispatched; unreachable from the `push`/normal `workflow_dispatch` path used for Task 8.
- F6 (legacy `backend/.github/workflows/deploy.yml` inert-path documentation) — low severity, no double-deploy risk.
- F7 (evidence-doc cross-file inconsistencies) — documentation only.
- N1 (redundant `ssh_exec_stdin` helper), N2 (no `docker logout` after GHCR pull), N3 (duplicate `cutover-evidence.md` pointer file) — low-severity hygiene follow-ups.
- Task 9 (AC7 rollback proof) and Task 10 (AC6 re-verification beyond the row-count check already observed in Task 8) remain open as follow-up work, not required for this story's DONE per the reviewer's explicit gate.
