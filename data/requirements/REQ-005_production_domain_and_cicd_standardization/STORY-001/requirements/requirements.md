# STORY-001 Requirements: Point api.cupidus.app at the production backend API

Source: `story_brief.md`; `req_master.md` Business Scope outcome 1; Technical
Constraints (DNS/Cloudflare CLI, SSH-key-reuse guardrail).

## Complexity / Lane Confirmation

- Complexity: standard — confirmed per `story_brief.md`. Reaching
  `api.cupidus.app` over TLS requires a new architecture decision (TLS
  termination approach: Cloudflare-proxied edge certificate vs. an origin
  certificate on the VPS reverse proxy) not previously in place for this
  backend; there is no new UX surface.
- Implementation Lane: shared — correcting `story_master.md`'s
  pre-breakdown `unassigned` placeholder. Standard/complex stories use
  `shared` per the lane-consistency rule so Tech Lead produces a
  coding-plan, even though only DevOps is expected to execute the resulting
  plan end to end (no backend/frontend/mobile code changes expected).

## Scope

In scope — the two Scope Seed bullets from `story_brief.md`:

- Creating/pointing the `api.cupidus.app` DNS record at the production VPS
  (`root@84.247.140.178`) through the Cloudflare CLI/API (scripted and
  repeatable), not the manual Cloudflare dashboard. Before creating the
  record, confirm no conflicting DNS record already exists on the
  `cupidus.app` zone.
- The VPS-side routing/TLS change needed for `api.cupidus.app` to reach the
  running backend API: inspecting and extending/replacing the existing
  `backend/nginx/default.conf` vhost (currently `server_name
  api-cupid.tikup.me`, plain HTTP on port 80 only, `proxy_pass
  http://backend:3000`) rather than blindly overwriting it.

Out of scope:

- Any change to how the backend gets deployed onto the VPS — that is
  STORY-002's read-only-investigation-then-CI/CD scope.
- REQ-006 (web) and REQ-007 (mobile) consuming this domain.
- Rotating or generating SSH keys unless the existing authorized keys are
  confirmed broken.
- Deciding the TLS termination approach (Cloudflare-proxied edge cert vs.
  VPS-origin cert) — that decision belongs to Tech Lead's architecture
  output for this story, not to this requirements artifact.
- Deciding whether the legacy `api-cupid.tikup.me` vhost/domain is kept,
  merged, or removed — only that it must not be blindly overwritten;
  the specific disposition is a Tech Lead/DevOps implementation call.

## Acceptance Criteria

- **AC1 (DNS record created via Cloudflare CLI/API):** the
  `api.cupidus.app` DNS record is created/pointed at the production VPS
  through a scripted Cloudflare CLI/API call (not the manual dashboard), so
  the step is repeatable and auditable. Before creation, the existing
  `cupidus.app` zone is checked and confirmed to have no conflicting record
  for this name.
- **AC2 (production hostname serves the backend over HTTPS):**
  `https://api.cupidus.app` resolves and serves live responses from the
  backend API over HTTPS — matching `req_master.md`'s Recommended Story
  Sequence outcome for STORY-001.
- **AC3 (legacy vhost inspected, not blindly overwritten):** the existing
  `backend/nginx/default.conf` vhost (`server_name api-cupid.tikup.me`) is
  inspected before any change; the change adds `api.cupidus.app` routing by
  deliberately extending or replacing this vhost, with the disposition of
  the legacy `api-cupid.tikup.me` name recorded in the implementation
  output rather than silently dropped.
- **AC4 (no SSH key rotation without confirmed breakage):** no SSH key is
  generated or rotated for VPS access as part of this story unless the
  existing authorized key(s) are confirmed broken, in which case that
  confirmation and the rationale for rotation are recorded in the
  implementation output.
- **AC5 (secrets handling, if a credential is needed):** if the DNS
  scripting step needs a credential (e.g., a Cloudflare API token) that
  isn't already available to the operator's local Cloudflare CLI session,
  a placeholder GitHub Actions secret is created via `gh secret set
  <NAME> --body <placeholder>` and the exact required secret name is
  reported back to the user to populate/rotate the real value — no real
  credential value is invented or reused without explicit user
  confirmation.

## Open Question Impact

- **OQ Registry Reviewed:** `req_master.md` Open Questions section;
  `requirements/requirements.md` (requirement-level) Open Question Triage
  table; central registry "Decisions Still Needed From The User" and
  "Resolved Foundation Decisions" sections.

### Scope Items BLOCKED in this story

- None.

### Scope Items NOT BLOCKED in this story

- **Nginx VPS-target ambiguity** (central registry, UNRESOLVED): concerns
  the legacy `api-cupid.tikup.me` domain, not `api.cupidus.app`. REQ-005's
  Business Scope is itself a direct user instruction naming
  `root@84.247.140.178` as the target VPS, which satisfies this OQ's
  VPS-target confirmation for this requirement's scope. This story only
  carries forward the guardrail to inspect (not blindly overwrite) the
  existing vhost — see AC3.
- **`api-cupid.tikup.me` VPS target identity** (central registry, RESOLVED
  2026-07-29): confirms the VPS itself is a legitimate deploy target,
  consistent with `root@84.247.140.178`. No remaining impact on this
  story.
- **Exact current deploy mechanism unknown** (`req_master.md`,
  UNRESOLVED): scoped to STORY-002's read-only investigation phase, not a
  precondition for STORY-001's DNS/routing/TLS scope.
- **Dedicated deploy SSH key vs. reuse** (`req_master.md`, UNRESOLVED):
  DevOps security judgment call for STORY-002's CI/CD pipeline; not
  applicable to STORY-001, which explicitly must not rotate/generate SSH
  keys unless the existing ones are confirmed broken (AC4).
