# Story Master: STORY-001 Point api.cupidus.app at the production backend API
Status: IN_PROGRESS
Complexity: standard
Implementation Lane: shared
Story-Class: standard

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — UX-Spec: WAIVED -- no operator-facing UI surface, infrastructure/DNS routing change only (scrum-master, per story_brief.md "Existing system entry / discoverability seed: not applicable")
- [x] Architecture (Tech Lead)
- [x] Implementation (Development) — AC1 (scripted DNS-only record creation) PASS, AC3 (legacy api-cupid.tikup.me untouched) PASS, AC4 (no SSH key rotation) PASS. AC2 (HTTPS edge): Caddy holds a live production Let's Encrypt cert; DNS proxied to Cloudflare; non-mutating traffic evidence (origin journal + edge probe, see `devops/vps-caddy-edge-evidence.md` Session 4) proves Cloudflare completes a real TLS 1.3 handshake to the origin today. `https://api.cupidus.app` still returns 502 pending STORY-002's backend going live on `127.0.0.1:3010` (cross-story dependency, not this story's blocker). Known follow-up (non-blocking, informational): `CLOUDFLARE_API_TOKEN` lacks the "SSL and Certificates" permission group, so the exact API-confirmed zone SSL-mode name/value cannot be read or changed (user chose Flexible over Full (strict); a same-endpoint attempt at either value returns Cloudflare error 9109 regardless). Evidence: `coding-plan/test-results.md` (11b/11c/11/12), `deployment/configuration-guide.md` (3/4/5/7).
- [ ] Review (Reviewer) — not yet run. Do not mark DONE until: (1) STORY-002's backend is live on 127.0.0.1:3010 and `https://api.cupidus.app` returns a real backend response (not 502) so AC2 is fully demonstrated end-to-end, (2) the informational SSL-mode-permission follow-up is either accepted as a permanent known-limitation or resolved by granting the token permission, (3) story-scoped Reviewer approves.
