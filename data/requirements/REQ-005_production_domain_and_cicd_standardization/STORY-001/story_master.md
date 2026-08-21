# Story Master: STORY-001 Point api.cupidus.app at the production backend API
Status: IN_PROGRESS
Complexity: standard
Implementation Lane: shared
Story-Class: standard

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — UX-Spec: WAIVED -- no operator-facing UI surface, infrastructure/DNS routing change only (scrum-master, per story_brief.md "Existing system entry / discoverability seed: not applicable")
- [x] Architecture (Tech Lead)
- [x] Implementation (Development) — AC1 (scripted DNS-only record creation) PASS, AC3 (legacy api-cupid.tikup.me untouched) PASS, AC4 (no SSH key rotation) PASS. AC2 (HTTPS edge) now fully PASS end-to-end: STORY-002's backend went live on `127.0.0.1:3010` via the real `deploy-backend.yml` run (https://github.com/hoak57uet/cupidus/actions/runs/32457256470, 2026-08-21), and `curl -s -o /dev/null -w '%{http_code}' https://api.cupidus.app/` now returns **200** (confirmed by Scrum Master directly) — a real backend response over HTTPS through the Cloudflare edge, superseding the earlier 502-pending-cross-story-dependency state. Known follow-up (non-blocking, informational): `CLOUDFLARE_API_TOKEN` lacks the "SSL and Certificates" permission group, so the exact API-confirmed zone SSL-mode name/value cannot be read or changed (user chose Flexible over Full (strict); a same-endpoint attempt at either value returns Cloudflare error 9109 regardless) — non-mutating traffic evidence already proved the zone's live mode satisfies AC2's security intent (`devops/vps-caddy-edge-evidence.md` Session 4). Evidence: `coding-plan/test-results.md` (11b/11c/11/12), `deployment/configuration-guide.md` (3/4/5/7).
- [ ] Review (Reviewer) — not yet run. AC1-AC4 are now all demonstrated end-to-end (no remaining cross-story dependency). Remaining before DONE: (1) the informational SSL-mode-permission follow-up is either accepted as a permanent known-limitation or resolved by granting the token permission (non-blocking either way), (2) story-scoped Reviewer approves.
