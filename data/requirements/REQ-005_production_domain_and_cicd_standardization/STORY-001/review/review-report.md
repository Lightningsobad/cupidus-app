# STORY-001 Review Report — Point api.cupidus.app at the production backend API

Outcome: DEFERRED_ONLY

Review type: `compact-story-review` (RE-REVIEW of the F1/F2/F3 patch round)
Story: STORY-001 (REQ-005), Complexity `standard`, Implementation Lane `shared`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-005_production_domain_and_cicd_standardization-STORY-001`
Full-story diff baseline: `e34385af8c9579b3ee33fdf4f3c6bb8b47665097..HEAD`
Patch diff re-reviewed this round: `9cc6b5d..765541c` (`765541c` = 2 files, documentation only)

## Re-Review Scope

The prior round of this same review returned `Outcome: PATCH_REQUIRED` on three
documentation-only findings (F1, F2, F3). AC1-AC5 verdicts, the accepted AC3 host-Caddy
architecture deviation, and deferred findings D1-D3 were already reviewed and were
explicitly out of scope for this patch round; they are carried forward unchanged below
and were not re-litigated.

`git show --stat 765541c` confirms the patch touched exactly two files —
`STORY-001/coding-plan/test-results.md` and `REQ-005/deployment/configuration-guide.md` —
with no code, script, Caddyfile, or VPS change, matching what the prior review prescribed.
(`story_master.md` also appears in the `9cc6b5d..765541c` range, from the separate Scrum
Master commit `343327a` that recorded the PATCH_REQUIRED outcome; that is control-plane
state, not part of the DevOps patch.) The patch introduces no credential, key, or
certificate material.

## Independent Verification Performed

Re-verified live at re-review time rather than taken from evidence (2026-08-21):

```
curl -sS -D - -o /dev/null https://api.cupidus.app/
  HTTP/2 200
  via: 1.1 Caddy
  x-powered-by: Express
  server: cloudflare
  cf-ray: a2e7f3e99bbd04b9-HKG
dig +short api.cupidus.app A    -> 104.21.62.250, 172.67.141.59 (Cloudflare anycast)
curl -s -o /dev/null -w '%{http_code}' https://api-cupid.tikup.me/  -> 308 (legacy, unchanged)
curl -s -o /dev/null -w '%{http_code}' https://vocabik.com          -> 200 (co-tenant, unchanged)
```

The `via: 1.1 Caddy` + `x-powered-by: Express` pair on a `200` again proves the full
Cloudflare edge -> origin Caddy -> backend Express chain. The first attempt of this check
timed out at 25s with 0 bytes received; two immediate retries both returned `200` in
~1.4s, so that single timeout is treated as a transient client-side network event, not an
endpoint fault. It is recorded here as observed rather than omitted.

## Blocking Finding Resolution

### F1 — RESOLVED

`coding-plan/test-results.md:487` now carries the exact heading
`## Story Runtime Startup Smoke`, with a literal `Result: PASS` on line 489 — the two
tokens the independent DONE gate reads. The section is scoped to this story's impacted
surface (the host Caddy edge in front of `backend-api`) and states that scoping
explicitly, consistent with the runtime-smoke scoping rule.

Every citation in the new section traces to pre-existing evidence in the same file — I
checked each one rather than accepting the summary:

- `caddy validate --config /etc/caddy/Caddyfile` exit 0 — test-results.md:136.
- `systemctl reload caddy` with `ExecReload ... status=0` and
  `Active: active (running) since Mon 2026-06-08` — test-results.md:140-143; the second
  reload with the same `Main PID 570281` and unchanged `Active:` line — test-results.md:284-285.
  The `Main PID 570281` value is quoted verbatim from the section-11b capture, and the same
  pid appears independently in the `ss -ltnp` captures.
- Co-tenant regression curls, before and after — test-results.md:126-128 (baseline) and
  151-152 (post-reload), identical statuses.
- `ss -ltnp` sole-listener check — test-results.md:62-66 and 153-156.
- `master-plan.md:43` `startup smoke NOT_APPLICABLE` for `backend-api` — the cited line
  number is exact.
- Live edge `200` with provenance headers — re-verified live above.

No fabricated evidence: the section restates verification that was already performed and
recorded, which is precisely what F1 asked for.

### F2 — RESOLVED

- `test-results.md:459` now reads `DEVOPS_COMPLETE: YES`, with the SSL-permission item
  correctly reclassified as deferred D1 rather than an open blocker.
- `configuration-guide.md` §4 (lines 103-110), §5 status (139-148), and §7 (183-190) now
  describe the live `HTTP/2 200` state and correctly characterize the earlier `502` as
  transient, caused only by STORY-002's not-yet-deployed backend — while preserving the
  still-valid point that the `502` (not `521`/`526`) proved the TLS layer worked.
- The REQ-006/REQ-007 hold in §7 is explicitly lifted. This was F2's concrete operational
  risk — two downstream requirements read this guide to decide whether the host is usable —
  and it is now resolved.

### F3 — RESOLVED

`configuration-guide.md` §5 step 4 (lines 130-137) marks
`set-zone-ssl-full-strict.sh` struck through and **"Superseded, do not run"**, states why
it no longer matches §4's Flexible target, notes it is not executable against either value
because of the token permission gap, and cross-references D1 and §7. The §5 status line
now reads `step 4 SUPERSEDED/BLOCKED`. §4 and §5 no longer point an operator at opposite
settings for a security-relevant control.

## Acceptance Criteria Verdicts (carried forward, unchanged)

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 — scripted DNS record creation, conflict-checked | PASS | `create-api-dns-record.sh` enumerates first and exits non-zero without mutating on conflict; executed live, then `set-api-dns-proxied.sh` flipped to proxied. `dig` confirms anycast. No dashboard step. test-results §5, §11b.1/.3 |
| AC2 — hostname serves the backend over HTTPS | PASS | Independently re-verified this round: `HTTP/2 200` with a valid publicly trusted edge cert and origin-Caddy/Express provenance headers |
| AC3 — legacy vhost inspected, not blindly overwritten | PASS (with recorded deviation, accepted in the prior round under core rule 14) | `backend/nginx/default.conf` restored byte-for-byte to pre-story state (test-results §0, empty verification diff); disposition recorded in configuration-guide §6; legacy host still returns its own `308` |
| AC4 — no SSH key rotation | PASS | `ssh -o BatchMode=yes root@84.247.140.178` succeeded on the existing authorized key (test-results §1) |
| AC5 — secrets handling | PASS | Diff scanned across the full story range including this patch: no token, private key, or certificate material committed; scripts read only from env |

## Deferred Findings (all non-blocking)

- **D1 — `CLOUDFLARE_TOKEN_MISSING_SSL_PERMISSION` (accepted).** The token lacks the "SSL
  and Certificates" group, so the exact zone SSL-mode value cannot be read or written for
  any target. The Session 4 journal capture shows a completed TLS 1.3 handshake with correct
  SNI arriving at the origin from a Cloudflare edge IP, and the live `200` with origin-Caddy
  provenance confirms the path works today. The gap costs an exact recorded mode name, not a
  security property. Unchanged by this patch, and now correctly labelled deferred in
  `test-results.md` §12 and `configuration-guide.md` §5/§7.
- **D2 — `set-zone-ssl-full-strict.sh` retained while the chosen target is Flexible.** The
  script itself is unchanged, but F3's fix now documents it as superseded and not-to-be-run,
  which removes the operator hazard. Rename or replace when D1 resolves.
- **D3 — `www.vocabik.com` ACME failure on the shared host.** Pre-existing co-tenant
  NXDOMAIN since host setup in 2026-06. Out of scope, documented, not worsened.
- **D4 — `test-results.md` header status line is stale relative to its own §12 (new,
  minor).** Lines 6-8 still read `Status: **PARTIAL ... Zone SSL mode (Full strict) is
  BLOCKED on a missing token permission.**`, which predates both the user's Flexible
  retarget and the now-`YES` completion marker at line 459. Likewise §11 (line 427) still
  labels the SSL-permission item "current blocker" while §12 calls it deferred. Deliberately
  not raised to blocking: this is an intra-document narrative header, it errs conservative
  rather than overstating completeness, it is not read by the DONE gate, and it is not the
  artifact downstream requirements consume — which is what made F2 blocking. Fold into the
  D1 cleanup pass.
- **D5 — `configuration-guide.md` §7 is still titled "Open blocker" (new, cosmetic).** Its
  body now correctly describes item 1 as resolved and item 2 as narrowed/non-blocking, and
  the REQ-006/REQ-007 hold is lifted, so the heading is the only stale element. Same cleanup
  pass as D4.

## Traceability

- Requirements: `STORY-001/requirements/requirements.md` AC1-AC5, all PASS.
- Architecture: `STORY-001/architecture/solution.md` §1, §1A — implementation matches the R2
  host-Caddy design; R1 container-nginx prep fully reverted and verified with an empty diff.
- Runtime startup smoke (rule 12g): DECLARED and PASS — `test-results.md` §"Story Runtime
  Startup Smoke", scoped to the impacted edge surface.
- UX: WAIVED, no UI surface. Rules 12e1/12e2 not applicable.
- Configuration guide (rule 12a): now accurate on live state and internally consistent on
  SSL mode; residual staleness is heading-level only (D4/D5).
- Shared-infrastructure safety (rule 12h): PASS. Caddy site block proxies to
  `127.0.0.1:3010` (loopback-only), `3010` confirmed free before use, `3000` deliberately
  avoided because a live co-tenant holds it, co-tenant regression gate passed twice, and the
  co-tenant is still serving `200` at re-review time.
- Secret hygiene: PASS.

## State Recommendation

- Check `Implementation (Development)`
- Check `Review (Reviewer)` — `Outcome: DEFERRED_ONLY`
- Story eligible for `DONE` and for merge into
  `codex/REQ-005_production_domain_and_cicd_standardization-integration`
- Carry D1-D5 forward as non-blocking follow-ups; D1 is the parent item that unblocks D2,
  D4, and D5 cleanup.
