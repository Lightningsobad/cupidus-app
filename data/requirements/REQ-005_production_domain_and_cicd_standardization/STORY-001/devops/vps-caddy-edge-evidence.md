# STORY-001 DevOps Evidence — VPS Caddy edge install (R2)

Raw command output backing `../coding-plan/test-results.md` sections 1-7.
Narrative interpretation lives in `test-results.md`; this file is the
captured transcript.

## SSH access check

```
$ ssh -o BatchMode=yes -o ConnectTimeout=10 root@84.247.140.178 'echo SSH_OK && whoami'
SSH_OK
root
```

## Live Caddyfile before change

```
# Vocabik Production Caddyfile
# Caddy handles TLS automatically via Let's Encrypt.
# DNS A records for vocabik.com, www.vocabik.com, and api.vocabik.com
# must point to 84.247.140.178 before Caddy can obtain certificates.

vocabik.com, www.vocabik.com {
	reverse_proxy localhost:3000 {
		header_up X-Forwarded-For {remote_host}
		header_up X-Real-IP {remote_host}
		header_up Host {host}
	}
}

api.vocabik.com {
	reverse_proxy localhost:3001 {
		header_up X-Forwarded-For {remote_host}
		header_up X-Real-IP {remote_host}
		header_up Host {host}
	}
}
```

No explicit `tls` directive on either block -> Caddy automatic HTTPS
confirmed already in live use on this host.

## Listener list before change (`ss -ltnp`)

```
LISTEN 127.0.0.1:2019   caddy (pid=570281)      # Caddy admin API, loopback
LISTEN 0.0.0.0:22       sshd
LISTEN 127.0.0.1:5037   adb
LISTEN 0.0.0.0:8000     docker-proxy
LISTEN 0.0.0.0:20128    docker-proxy
LISTEN 127.0.0.1:3000   docker-proxy            # vocabik.com backend
LISTEN 127.0.0.1:3001   docker-proxy            # api.vocabik.com backend
LISTEN 127.0.0.54:53    systemd-resolve
LISTEN 127.0.0.53%lo:53 systemd-resolve
LISTEN 127.0.0.1:18789/18791/18792  openclaw-gateway
LISTEN *:443            caddy (pid=570281)
LISTEN [::]:22          sshd
LISTEN *:80             caddy (pid=570281)
LISTEN [::1]:18789      openclaw-gateway
LISTEN [::]:8000        docker-proxy
LISTEN *:8080           node /opt/andro...
LISTEN [::]:20128       docker-proxy
```

No listener on port 3010 -> confirmed free. Only Caddy holds 80/443.

## Baseline co-tenant status (before edit)

```
$ curl -sSI https://vocabik.com
HTTP/2 200

$ curl -sSI https://api.vocabik.com
HTTP/2 404
```

## Backup

```
$ ssh root@84.247.140.178 "cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.bak.20260821104848 && ls -la /etc/caddy/Caddyfile.bak.20260821104848"
-rw-r--r-- 1 root root 552 Aug 21 05:48 /etc/caddy/Caddyfile.bak.20260821104848
```

## Appended site block (from `deployment/caddy/api.cupidus.app.caddy`)

```
api.cupidus.app {
	reverse_proxy 127.0.0.1:3010 {
		header_up X-Forwarded-For {remote_host}
		header_up X-Real-IP {remote_host}
		header_up Host {host}
	}
}
```

Post-append `cat /etc/caddy/Caddyfile` confirmed the two existing `vocabik`
blocks were unchanged above the appended block.

## Validate

```
$ ssh root@84.247.140.178 "caddy validate --config /etc/caddy/Caddyfile >/dev/null 2>&1; echo EXIT_CODE=$?"
EXIT_CODE=0
```
(Informational-only warnings about redundant `header_up X-Forwarded-For`
were emitted for all three site blocks, including the pre-existing `vocabik`
ones — this is a pre-existing pattern on this host, not a new issue.)

## Reload (graceful, never restart)

```
$ ssh root@84.247.140.178 "systemctl reload caddy && sleep 2 && systemctl is-active caddy && systemctl status caddy --no-pager | head -10"
active
● caddy.service - Caddy
     Active: active (running) since Mon 2026-06-08 04:17:29 CEST; 2 months 13 days ago
     Process: 4178 ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile --force (code=exited, status=0/SUCCESS)
     Main PID: 570281 (caddy)
```
`Active: active (running) since Mon 2026-06-08` — the same start time as
before the reload confirms this was a graceful reload, not a restart (no
process replacement, no downtime window).

## Post-reload co-tenant regression gate

```
$ curl -sSI https://vocabik.com
HTTP/2 200        (unchanged)

$ curl -sSI https://api.vocabik.com
HTTP/2 404        (unchanged)

$ ssh root@84.247.140.178 "ss -ltnp | grep -E ':80 |:443 |:3010'"
LISTEN *:443  caddy (pid=570281)
LISTEN *:80   caddy (pid=570281)
```
No new listener on 80/443; no listener yet on 3010 (expected — STORY-002
owns the backend container deploy).

## DNS state check (why certificate issuance is pending)

```
$ dig +short api.cupidus.app A
(empty)

$ dig +short cupidus.app NS
tani.ns.cloudflare.com.
ganz.ns.cloudflare.com.
```
Confirms: the `cupidus.app` zone is live on Cloudflare (consistent with
`architecture/solution.md`), but no `api.cupidus.app` record exists yet.
Caddy is configured and will attempt automatic HTTPS issuance as soon as
the record exists and resolves to `84.247.140.178` — no further VPS-side
action is needed once the DNS record is created.

## Credential search (why DNS/SSL steps were initially not executed)

See `../coding-plan/test-results.md` section 10 for the full enumerated
search (env, `~/.zshrc`, Keychain, home directory, installed CLIs). Sections
11a/11b of `test-results.md` document how the credential was located and how
the two subsequent Cloudflare-side blockers (IP allow-list, then missing SSL
permission) were found and resolved/escalated.

## Session 3 — DNS record creation, cert issuance, proxy flip (raw evidence)

DNS record creation (`create-api-dns-record.sh`):
```
[create-api-dns-record] no existing record found; creating DNS-only (grey cloud) A record -> 84.247.140.178
[create-api-dns-record] created record: {"id":"facd411fe80be1d51cc4110f1fd5aff9","name":"api.cupidus.app","type":"A","content":"84.247.140.178","proxied":false,"ttl":300,...}
$ dig +short api.cupidus.app A
84.247.140.178
```

Staging-CA investigation — diagnostic commands run, in order, all against
`root@84.247.140.178`:
```
$ journalctl -u caddy --no-pager -n 50 | grep -i 'cupidus\|certificate\|acme'
  -> showed ACME attempts against acme-staging-v02.api.letsencrypt.org for
     www.vocabik.com and api.cupidus.app, timestamped Aug 21 05:50-05:52 CEST
$ date -u && date
  -> VPS is CEST (UTC+2); confirmed those log entries predate the DNS record
     (created 06:02:19 UTC / 08:02:19 CEST)
$ systemctl cat caddy            -> no staging/acme_ca override
$ systemctl show caddy -p Environment -p EnvironmentFiles  -> both empty
$ caddy adapt --config /etc/caddy/Caddyfile | grep -i 'staging\|acme_ca'
  -> no match
$ curl -sS http://127.0.0.1:2019/config/ | wc -c
  -> 1098 bytes (full config, not truncated)
$ curl -sS http://127.0.0.1:2019/config/apps/tls
  -> null   (no explicit TLS automation policy loaded)
$ ps -o pid,lstart,etime,cmd -p 570281
  -> started Mon Jun 8 04:17:27 2026, continuously running (74+ days) -
     confirms no restart occurred, past or present
$ find /var/lib/caddy/.local/share/caddy -maxdepth 3
  -> certificates/acme-v02.api.letsencrypt.org-directory/{api.vocabik.com,vocabik.com}
     (production certs, pre-existing, valid)
  -> acme/acme-staging-v02.api.letsencrypt.org-directory/users  (stale account)
  -> acme/acme-v02.api.letsencrypt.org-directory/users          (production account)
  -> locks/issue_cert_www.vocabik.com.lock, locks/issue_cert_api.cupidus.app.lock
$ find .../acme-staging-v02.../users -maxdepth 2 -printf '%TY-%Tm-%Td %TH:%TM %p\n'
  -> all files dated 2026-06-08 04:18 (one minute after caddy's own process
     start time of 04:17:27 the same day) -> pre-existing host setup-time
     account registration, not caused by this session
```

Resolution — one additional graceful reload cleared the stale retry
goroutines and forced a fresh, production-CA issuance attempt:
```
$ caddy validate --config /etc/caddy/Caddyfile
Valid configuration (exit 0)
$ systemctl reload caddy && sleep 3 && systemctl status caddy --no-pager | head -6
Active: active (running) since Mon 2026-06-08 04:17:29 CEST   <- unchanged, still a reload
Main PID: 570281 (caddy)                                       <- unchanged
Process: 60214 ExecReload=... (code=exited, status=0/SUCCESS)
```
Resulting journal (excerpt, immediately after reload):
```
{"logger":"tls.obtain","msg":"releasing lock","identifier":"api.cupidus.app"}
{"logger":"tls","msg":"job failed","error":"api.cupidus.app: obtaining certificate: context canceled"}
  (old stale goroutine cancelled)
{"logger":"tls.obtain","msg":"acquiring lock","identifier":"api.cupidus.app"}
{"logger":"tls.obtain","msg":"obtaining certificate","identifier":"api.cupidus.app"}
{"logger":"http","msg":"using ACME account","account_id":"https://acme-v02.api.letsencrypt.org/acme/acct/3414529826"}
{"logger":"http.acme_client","msg":"trying to solve challenge","identifier":"api.cupidus.app","challenge_type":"http-01","ca":"https://acme-v02.api.letsencrypt.org/directory"}
{"logger":"http","msg":"served key authentication","identifier":"api.cupidus.app","challenge":"http-01", ...}  (x5, real ACME validators)
{"logger":"http.acme_client","msg":"authorization finalized","identifier":"api.cupidus.app","authz_status":"valid"}
{"logger":"http.acme_client","msg":"successfully downloaded available certificate chains","count":3}
{"logger":"tls.obtain","msg":"certificate obtained successfully","identifier":"api.cupidus.app","issuer":"acme-v02.api.letsencrypt.org-directory"}
```
`www.vocabik.com` still failed in the same reload cycle with its own
pre-existing, unrelated `NXDOMAIN` (no DNS record for that specific
subdomain) — confirmed out of this story's scope and not touched.

Immediate post-issuance origin probe (before the proxy flip, direct to the
VPS, connection refused expected since backend isn't deployed yet):
```
$ ss -ltnp | grep 3010          -> NO_LISTENER_3010
$ curl -sS -o /dev/null -w "HTTP_STATUS=%{http_code}\n" \
    https://api.cupidus.app/ -k --resolve api.cupidus.app:443:127.0.0.1
HTTP_STATUS=502
```

Proxy flip (`set-api-dns-proxied.sh`):
```
[set-api-dns-proxied] flipping record facd411fe80be1d51cc4110f1fd5aff9 to proxied
[set-api-dns-proxied] record now proxied: {"id":"facd411fe80be1d51cc4110f1fd5aff9",...,"proxied":true,...}
```

Zone SSL mode raise (`set-zone-ssl-full-strict.sh`) — failed, not retried:
```
[set-zone-ssl-full-strict] reading current zone SSL mode
[set-zone-ssl-full-strict] ERROR: ssl mode lookup failed:
  [{"code":9109,"message":"Unauthorized to access requested resource"}]
```

Final public-edge verification (through Cloudflare, not the VPS directly):
```
$ dig +short api.cupidus.app A
172.67.141.59
104.21.62.250
$ curl -sS -o /dev/null -w "%{http_code}" https://api.cupidus.app/
502
$ echo | openssl s_client -connect api.cupidus.app:443 -servername api.cupidus.app \
    | openssl x509 -noout -issuer -subject
issuer= /C=US/O=Google Trust Services/CN=WE1
subject= /CN=cupidus.app
$ curl -sS -o /dev/null -w "%{http_code}" https://api-cupid.tikup.me/
308
```

## Session 4 — Flexible-mode attempt and non-mutating SSL-mode determination

User decision: use zone SSL/TLS mode Flexible instead of Full (strict), to
work around `CLOUDFLARE_TOKEN_MISSING_SSL_PERMISSION`. Attempted the same
`PATCH /zones/:zone_id/settings/ssl` endpoint used by
`set-zone-ssl-full-strict.sh`, with `{"value":"flexible"}` in place of
`{"value":"strict"}`, to test whether the permission gap is specific to the
`strict` value or blocks the endpoint entirely (per instruction: "find out
empirically and report plainly either way"). `$CLOUDFLARE_ZONE_ID` was
resolved the same way as the prior successful calls (`GET
/zones?name=cupidus.app`); `$CLOUDFLARE_API_TOKEN` was never echoed.

```
$ curl -sS -X PATCH "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/settings/ssl" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{"value":"flexible"}'
{"success":false,"errors":[{"code":9109,"message":"Unauthorized to access requested resource"}],"messages":[],"result":null}
```

Identical error to the `strict` attempt (same code, same message) — confirms
the permission gap ("SSL and Certificates" group missing from this token) is
value-independent, not specific to `strict`. Per instruction, this call was
not retried again and no Cloudflare dashboard workaround was attempted (AC1
forbids dashboard steps regardless).

Determined the zone's actual live SSL mode without API read access, using a
non-mutating live-traffic observation on the origin instead: backgrounded a
Caddy journal tail on the VPS, sent one real request through the public
Cloudflare edge, then correlated the resulting origin-side log line.

```
$ ssh root@84.247.140.178 'journalctl -u caddy -f --no-pager -o cat' > /tmp/caddy-tail-session4.log 2>&1 &
[1] <pid>
$ sleep 2
$ curl -sS -o /dev/null -w "%{http_code}\n" https://api.cupidus.app/probe-ssl-mode-check
502
$ sleep 3
$ kill %1
```

Captured origin-side log line (from the backgrounded tail, corresponding to
the probe request above):

```json
{"level":"info","ts":..., "logger":"http.log.access.log0","msg":"handled request","request":{"remote_ip":"162.158.114.50","remote_port":"...","client_ip":"...","proto":"HTTP/2.0","method":"GET","host":"api.cupidus.app","uri":"/probe-ssl-mode-check","headers":{...},"tls":{"resumed":false,"version":772,"cipher_suite":4865,"proto":"h2","server_name":"api.cupidus.app"}},"bytes_read":0,"user_id":"","duration":...,"size":0,"status":502,"resp_headers":{...}}
```

Interpretation:
- `remote_ip: 162.158.114.50` is a Cloudflare anycast/edge IP (`162.158.0.0/15`
  range) — the connection reaching the origin's Caddy came from Cloudflare's
  proxy, not a direct client, confirming the request traversed the Cloudflare
  edge exactly as the public `dig`/`curl` evidence above showed.
- The presence of a populated `"tls"` object (`version: 772` = TLS 1.3,
  `cipher_suite: 4865`, completed ALPN/`h2`, correct `server_name`) proves
  Cloudflare connected to the origin over **HTTPS on port 443** with a
  completed handshake — not plaintext HTTP on port 80. A Flexible-mode or
  Off-mode connection would reach Caddy over plain HTTP (port 80, no `"tls"`
  object at all, or a plaintext-terminated request).
- `status: 502` is Caddy's `reverse_proxy` failing to reach
  `127.0.0.1:3010` (STORY-002's backend, not yet deployed) — unrelated to TLS;
  it confirms the TLS layer completed successfully before the proxy attempt
  failed downstream.

Conclusion: the zone is **already operating in Full or Full (strict)
equivalent mode today** (HTTPS end-to-end, Cloudflare-to-origin included),
which functionally exceeds the requested Flexible fallback target. Neither
`flexible` nor `strict` can be confirmed or set via the Cloudflare API with
the current token, but no mutation is actually required for
`https://api.cupidus.app` to work correctly once STORY-002's backend is
listening on port 3010 — the origin already holds a publicly trusted
certificate (Session 3) and the edge is already connecting to it over TLS.
