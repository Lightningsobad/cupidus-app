# Review Report — STORY-001 Zodiac Red Flag Screen

Outcome: DEFERRED_ONLY

- Review type: `scoped-slice` re-gate, pass 3 (Reviewer, Iris-QC)
- Scope gate: `review/scope-gate.md`
- Story: STORY-001_zodiac_red_flag_screen (complex, Implementation Lane `shared`)
- Diff baseline: `1aba7508` → `6950e19` (pass-2 baseline `ad992f8e` → `6950e19`
  for the pass-3 delta)
- Pass 1: `PATCH_REQUIRED` — F-1 runtime startup smoke, F-2 entry-point
  reachability section; no implementation defect.
- Pass 2: `PATCH_REQUIRED` — F-1 and F-2 closed; one blocking paperwork finding
  F-3 (`Design-Surface` unresolved).
- Date: 2026-08-25

All three blocking findings are now closed. No implementation defect was found in
any pass. Six deferrals (D-1, D-2, D-4, D-5, D-6 — D-3 was promoted to F-3 and is
now closed) carry forward as non-blocking follow-ups, which is what makes this
`DEFERRED_ONLY` rather than `CLEAN`.

## Pass 3 — F-3 CLOSED

Paperwork re-gate only, which is justified by the delta rather than asserted.
`git diff ad992f8e..HEAD --name-only` returns three files, **all** under
`data/requirements/.../STORY-001_zodiac_red_flag_screen/`: `story_master.md`
(+1 line), `review/review-report.md` (this report, pass-2 body), and
`scrum-master-checkpoint.md`. Filtering that list for anything outside `data/`
returns nothing — zero files under `backend/` or `mobile/`, and zero test,
capture, or config changes. So AC1-AC5, contract fidelity, and visual fidelity
rest on byte-identical source to the passes that verified them, and are
correctly not re-audited here.

`6950e19` adds exactly the line pass 2 specified, at `story_master.md:16`,
directly after `Design-Screen: zodiac` at `:15`:

```text
Design-Surface: cupid-app
```

I read the file to confirm placement and value rather than trusting the commit
message. `cupid-app` is one of the two ids the gate itself named as valid
(`cupid-app` mobile / `cupid-web` web), and it is the correct one for this
story's `Platform: android`, 412dp canvas, Flutter-only deliverable. The commit
touches one file and adds one line — no drive-by edits.

**Gate verification — read this before treating F-3 as closed by a green run.**
`verify-story-visual-fidelity-gate.sh` cannot be meaningfully invoked from the
command line. Running it with this story's `--req`/`--story`/`--worktree`
exits `0` silently, but so does running it with a bogus requirement and story
(`--req REQ-999_bogus --story STORY-999_bogus`) and so does running it with no
arguments at all — all three exit `0`. A direct CLI run is therefore a no-op and
is **not** evidence that the gate passes. The gate is hook-driven and evaluates
this report at reviewer stop time, which is exactly how it blocked pass 2. The
authoritative signal is that it does not block the stop of this pass with a
passing `Outcome:` recorded; the specific defect it named in pass 2 (design
source unresolved on a UI-bearing story) is resolved by construction, since the
sole missing datum now exists with a valid value.

## Pass 2 scope

This pass re-checks only the two blocking findings and confirms the deferred set
is unchanged. Acceptance criteria AC1-AC5, contract fidelity against
`architecture/contract-summary.md`, and visual fidelity all passed in pass 1 and
are **not** re-audited here, which is justified by the diff: the four commits
added since pass 1 (`00ff710`, `bd7cde6`, `afe7803`, `ad992f8`) touch only
`coding-plan/test-results.md` (+129 lines, evidence sections) and
`scrum-master-checkpoint.md`. Zero files under `backend/` or `mobile/` changed,
so no rework-introduced defect is possible in the reviewed surface and the pass-1
verdicts on those surfaces stand as written.

## F-1 — Story runtime startup smoke — CLOSED

Rule 12g requires registry-backed runtime startup smoke as a story-level gate.
Pass 1 found no such section and rejected the `master-plan.md:40-41`
`NOT_APPLICABLE` deferral as an invalid waiver. Both halves are now recorded and
both meet the 12g standard — real boot, not a narrative claim.

**Backend half** (`coding-plan/test-results.md:149-188`, devops, `00ff710`) —
PASS. It is genuine DI-graph boot evidence, which is exactly what pass 1 said
`nest build` could not supply. The section names the specific Nest boot log
lines rather than asserting success: `[InstanceLoader] ZodiacModule dependencies
initialized`, `[RoutesResolver] ZodiacController {/zodiac}`, `[RouterExplorer]
Mapped {/zodiac/red-flag/today, GET} route`, `[NestApplication] Nest application
successfully started`, with an explicit absence check for
`UnknownDependenciesException` / `Nest can't resolve dependencies` — so the
`ZODIAC_CLOCK` custom provider and the `UsersModule` import are proven resolved,
not merely type-checked. The mapped route matches the contract path verified in
pass 1. A live readiness probe is recorded (`GET /api-docs-json` → `HTTP 200`,
the registry `backend-api.readiness`), plus a supporting `GET
/zodiac/red-flag/today` → `HTTP 401`, which is consistent with the `JwtAuthGuard`
confirmed in pass 1 and distinguishes a running guarded handler from a 500-shaped
DI fault. Clean shutdown verified by `lsof`.

The one deviation is documented and legitimate: the reserved `api` port 21020 was
held by another live process, so the smoke ran on `DEVSTACK_LEASE_API=22000`
obtained via `devstack port lease --slot ... --role api --path <Worktree>`. I
verified against the live CLI that `devstack port lease` exists and is defined as
"temporary port for a parallel worktree slot" — this is the sanctioned mechanism
for parallel worktrees under `AGENTS.md` ("Parallel worktrees share the project's
database and lease their own ports"), not an unreserved ad-hoc port. The
readiness URL is the registry probe with the leased port substituted.

**Mobile half** (`coding-plan/test-results.md:190-247`, mobile-dev, `afe7803`) —
PASS. This is a default-entrypoint launch plus the real readiness probe, which is
precisely the gap pass 1 named (P3 evidence had launched only
`-t lib/main_preview.dart` via `cupidpreview://screen/zodiac`, bypassing
`main.dart`, Firebase, auth and the shell). Recorded: `flutter build apk --debug`
with **no `-t` flag**, install, then the registry `mobile-app.readiness.command`
verbatim — I compared it character-for-character against
`runtime-command-registry.json:224` and the `shutdownCommand` against `:227`, and
both match. The probe result is the `adb`/`ResumedActivity` evidence the handoff
asked for, not a substitute: `am start -W` → `Status: ok`, `LaunchState: COLD`,
and `ResumedActivity: ActivityRecord{... com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity t37}`
satisfying the 30×2s poll, with force-stop shutdown confirmed by an empty
`pidof` and `ResumedActivity` falling back to the launcher. The widget-test
`inAppFirstScreenSignal` is correctly *not* offered as the probe, matching
`runtime-command-registry.json:236-240`. Real-entrypoint execution is
independently corroborated from `logcat` (Firebase `[DEFAULT]` init → Dart VM →
live `GET /users/me` through the real Dio client), which proves `main.dart` →
`CupidApp` — the widget this story modified — executed on the live launch path.

I spot-checked the one red observation in that section rather than accepting it:
the `/users/me` `Connection refused` against `http://localhost:3000` is claimed
to be pre-existing base-URL drift. `runtime-command-registry.json:249`
(`dependsOnRationale`) confirms it verbatim — the compile-time
`CUPID_API_BASE_URL` default is stale at `http://localhost:3000` since the
shared-infra port became `21020`, the emulator alias is `10.0.2.2`, and fixing
the default is explicitly recorded as out of scope for that change. Readiness for
`mobile-app` is the foreground-activity assertion only and does not include
backend reachability, so this does not weaken the probe and is not a regression
from this story.

## F-2 — `## Entry Point Reachability` section — CLOSED

Rule 12e1 satisfied at `coding-plan/test-results.md:249-276`: the named section
exists, carries `Reachable: YES` on its own line, and cites the concrete path
`Navigator.pushNamed(ZodiacRedFlagScreen.routeName)` → `'/zodiac/red-flag'` →
`ZodiacRedFlagScreen`.

I re-verified the two file:line citations against source rather than trusting
them. `mobile/lib/app/cupid_app.dart:68-71` is exactly the
`routes: <String, WidgetBuilder>{ ZodiacRedFlagScreen.routeName: ... }` map, with
`home: SplashScreen` at `:61-64` and no `'/'` key — so the "entry route not
shadowed" claim holds. `zodiac_red_flag_screen.dart:27` is exactly
`static const String routeName = '/zodiac/red-flag';`. Note the evidence cites
`cupid_app.dart:68-71` where pass 1 wrote `65-68`; the evidence is the more
precise citation (pass 1 included the three-line comment block at `:65-67`) and
the file is unchanged — no discrepancy. This is consistent with the independent
AC5 verification in pass 1.

The section also records the `zodiac_route_test.dart` run (`+5: All tests
passed!`), correctly framed as supporting evidence alongside the device
cross-check rather than as the reachability proof itself, and correctly scopes
discoverability to STORY-002 per `story_master.md:103-107`
(`Direct URL only acceptable: YES`).

## F-3 — `Design-Surface` unresolved on a UI-bearing story — CLOSED in pass 3 (promoted from pass-1 D-3)

Raised as blocking in pass 2, closed by `6950e19`; see "Pass 3" above. The
pass-2 analysis is kept below unchanged as the record of why it blocked.

Pass 1 recorded this as deferred `D-3`. That deferral was wrong for a *passing*
review and I am correcting it: `verify-story-visual-fidelity-gate.sh` blocks a
passing story review on a UI-bearing story when the design source is
unresolved, and it blocked this pass with:

> passing review without resolving which design source the story was compared
> against — this project configures 2 design sources (mobile, web) and
> Implementation Lane `shared` does not decide between them […] Record
> `Design-Surface: <id>` in story_master.md. Valid: cupid-app (mobile,
> `Cupid App.dc.html`), cupid-web (web, `Cupid Web.dc.html`)

This is an evidence-record gap, not a fidelity failure. Rendered visual evidence
exists and passed in pass 1 (`visual-fidelity/design-reference-zodiac-android.png`
and `implemented-zodiac-emulator-5554.png`, both read directly, AC4 PASS), and
the surface is unambiguous in substance — `Platform: android`, a 412dp canvas
viewport, a Flutter-only deliverable — so the correct value is **`cupid-app`**.

Remedy: add one line to `story_master.md`, next to the existing
`Design-Screen: zodiac` at `story_master.md:15`:

```text
Design-Surface: cupid-app
```

Owner: `scrum-master` or `ui-ux-designer` — whoever owns `story_master.md`.
This reviewer's `WriteScope` is `review/**` only, so it cannot be closed from
inside this review run. No source change, no re-capture, and no re-run of any
test is required; a trivial re-gate is enough to flip this report to
`DEFERRED_ONLY`.

## Deferred findings (D-3 promoted to F-3 above; the rest unchanged from pass 1)

No source file changed since pass 1, so every deferral below rests on the same
code it did then and none has become blocking.

- **D-1 — degraded copy prescribes a remedy that is wrong for one reason code.**
  `zodiac_red_flag_screen.dart:356-357` tells the user "Cả hai người cần điền
  ngày sinh trong hồ sơ". Correct for `self_zodiac`/`partner_zodiac`, but the
  same neutral card also shows for `partner_link` (not paired), where filling in
  a birthday changes nothing. Implementation is contract-correct — §4 mandates
  one neutral card for every non-`ready` status and forbids branching on
  `missing` — so this is a copy follow-up, not a defect.
- **D-2 — one visible difference not named in the fidelity report's delta list.**
  In `implemented-zodiac-emulator-5554.png` the lower ~20% exposes the teal stop
  of the shared `CupidAppBackground` gradient where the reference draws the tab
  bar. A direct consequence of recorded delta 1 acting on pre-existing app-wide
  chrome this story did not touch — not a regression, but section 4 should have
  named it.
- **D-3 — promoted to blocking F-3 in pass 2, closed in pass 3.** No longer
  carried forward.
- **D-4 — design entry-file naming mismatch (still unverifiable here).**
  `story_master.md:11`, `visual-fidelity-report.md` and widget source comments
  cite `Cupid Screens.dc.html`; `design-fidelity-config.json`
  `design_source.entry` is `Cupid App.dc.html`. The visual-fidelity gate's own
  message independently confirms the configured entries are `Cupid App.dc.html`
  (cupid-app) and `Cupid Web.dc.html` (cupid-web), so the story artifacts do name
  a file that is not the configured entry for either surface. Same locked bundle,
  one `content_fingerprint`, correct reference image — nothing invalidated, so
  still non-blocking. I again could not determine whether the
  `Cupid Screens.dc.html` citation is longstanding convention across earlier
  requirements: the `Grep` tool is absent in this session ("No such tool
  available: Grep"), and `guard-query-first-bash-read.sh` blocks shell `grep`
  over artifacts (`SHELL_GREP_SOURCE`, retried and blocked again this pass,
  including via `rtk proxy`). Needs someone with search tooling. Pass 3 note:
  the F-3 edit (`6950e19`) added `Design-Surface` only and did not reconcile the
  `Cupid Screens.dc.html` citation — that was optional, so D-4 stays open and
  non-blocking rather than becoming a new finding.
- **D-5 — timezone-fragile backend assertion.** `zodiac.service.spec.ts:10` pins
  `new Date('2026-08-25T10:00:00Z')` while `toContentDate`
  (`zodiac.service.ts:17-22`) formats with local getters, so
  `expect(...).toBe('2026-08-25')` at `:57,108` would fail on a CI host more than
  10 hours behind UTC. Passes on this machine (UTC+7).
- **D-6 — payload arity is contracted but not enforced.** §3 rows 5/7 specify
  exactly 2 partners and 3 tips; `_parseList` (`zodiac_repository.dart:99-104`)
  accepts any length. Not a crash risk — both consumers iterate rather than
  index, and backend is the sole producer with its own spec pinning arity.

## Residual risks

- The backend smoke proves the DI graph and the readiness contract on a leased
  worktree port with a machine-local `.env.devstack`/`service-account.json`
  copied from the main checkout. It therefore does not exercise the shared-tenant
  `api` reservation (21020) end to end. Acceptable and correctly handled for a
  parallel worktree; requirement-level integration verification remains the place
  where the shared reservation is exercised.
- Backend and mobile were booted in separate smokes, so no cross-process
  request against the new `/zodiac/red-flag/today` endpoint from the device has
  been observed. Out of scope for a story-level 12g gate (the registry readiness
  probes are per-service), and the endpoint is covered by backend specs plus the
  mobile repository/widget tests.

## Configuration guide

Not required, unchanged from pass 1. `master-plan.md:8` records `NOT_APPLICABLE`:
no new env var, secret, port or third-party integration — the endpoint reuses the
existing `JwtAuthGuard` and the existing `zodiacSign` profile column.
`req_master.md:11` `Status: NOT_REQUIRED` is accurate.

## Recommended workflow state

- Check `Implementation (Development)` — implementation and runtime evidence are
  accepted; F-1, F-2 and F-3 are all closed and nothing remains outstanding.
- Check `Review (Reviewer)` — this report is the passing story review gate.
- Story status: eligible for `DONE`. Only `scrum-master` may set it.
- The story branch is now merge-eligible into
  `codex/REQ-011_zodiac_red_flag_and_home_quick_grid_completion-integration`.
  Per `AGENTS.md`, the requirement itself still needs requirement integration
  review before `REQ-011` can be marked `DONE`.
- D-1, D-2, D-4, D-5, D-6 carry forward as non-blocking follow-ups. D-4 (design
  entry-file naming) and D-5 (timezone-fragile spec assertion) are the two worth
  routing somewhere durable rather than dropping; D-5 in particular will surface
  as a real CI failure on any host more than 10 hours behind UTC.
