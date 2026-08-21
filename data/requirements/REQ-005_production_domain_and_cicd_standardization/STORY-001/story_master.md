# Story Master: STORY-001 Point api.cupidus.app at the production backend API
Status: IN_PROGRESS
Complexity: standard
Implementation Lane: shared
Story-Class: standard

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — UX-Spec: WAIVED -- no operator-facing UI surface, infrastructure/DNS routing change only (scrum-master, per story_brief.md "Existing system entry / discoverability seed: not applicable")
- [x] Architecture (Tech Lead)
- [ ] Implementation (Development) — Reviewer `compact-story-review` (2026-08-21, `review/review-report.md`) returned `Outcome: PATCH_REQUIRED`: AC1-AC5 all independently re-verified PASS (including AC2's live `HTTP/2 200` with origin-Caddy/Express provenance headers, re-checked live by the reviewer), but three documentation-only findings must be fixed before re-review — F1 (missing `## Story Runtime Startup Smoke` declaration), F2 (stale `DEVOPS_COMPLETE: NO` marker and 502-era `configuration-guide.md` sections contradicting the now-live `200` state), F3 (contradictory SSL-mode instructions in `configuration-guide.md` §4 vs §5). No code/script/VPS change required per the reviewer; routed back to DevOps as RUN-...-STORY-001-devops-patch1.
- [ ] Review (Reviewer) — `Outcome: PATCH_REQUIRED` (2026-08-21, `review/review-report.md`). Re-review required after F1-F3 are fixed. AC1-AC5 verdicts and the AC3 host-Caddy architecture deviation are already reviewed and accepted; D1-D3 are deferred, non-blocking.
