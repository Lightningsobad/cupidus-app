# Review Report — STORY-001 Zodiac Red Flag Screen

Outcome: PATCH_REQUIRED

- Review type: `full-story-review` (Reviewer, Iris-QC)
- Scope gate: `review/scope-gate.md`
- Story: STORY-001_zodiac_red_flag_screen (complex, Implementation Lane `shared`)
- Diff baseline: `1aba7508` → `cc8ef7bc` (47 files; 32 under `backend/` + `mobile/`)
- Date: 2026-08-25

## Rationale

All five acceptance criteria are implemented correctly and the code is well
traced to `architecture/contract-summary.md`. **No implementation defect was
found.** The story is returned for rework on two *mandatory evidence gates* that
were never run and are not waived by any governing artifact. One of them (F-1)
is the only proof that the newly registered backend module actually boots; it is
currently unproven by anything in the repository.

## Acceptance criteria

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 real-sign-pair content, both custom icons, daily tip | PASS | `zodiac.service.ts:45-53,60-69,80-83` reads each partner's `zodiacSign` off the `User` entity and looks up the static table — no fixture path exists. `zodiac_conflict_index_card.dart:200-202` renders one `CupidZodiacIcon` per wire partner with no `color` override. `zodiac.service.spec.ts:48-64` asserts 2 partners (`partners[0].role === 'self'`) and 3 distinct tip ids. |
| AC2 per-day determinism | PASS | `daily-tip.selector.ts:24-46` is a pure FNV-1a over `${coupleKey}#${contentDate}` — no clock, no RNG, so the same day always resolves the same 3 tips and a new day reseeds. `zodiac.service.ts:62` sorts `[self.id, partnerId]`, so both partners derive an identical key. `contentDate` comes from the injected `ZODIAC_CLOCK` (`zodiac.module.ts:16`), and `zodiac.service.spec.ts:103-109` pins it. Mobile renders the server value (`zodiac_red_flag_screen.dart:476-480`); the widget test additionally asserts today's `dd/MM` is *absent*, so a `DateTime.now()` regression fails on any non-fixture day. |
| AC3 degraded payload honesty | PASS | Backend: `zodiac.service.ts:40-57` returns the `incomplete_profile` literal for any of the three reasons — that object carries no `conflictIndex`/`partners`/`dailyTips` key at all, and `zodiac.service.spec.ts:66-77` asserts `not.toHaveProperty` on each. Mobile: `zodiac_repository.dart:45-53` branches on `data['status'] != 'ready'`, so an unrecognised status fails honest. `zodiac_red_flag_screen.dart:121-132` is a sealed switch that mounts `_ZodiacIncompleteProfileState` *instead of* the content tree, and that widget (`:321-367`) builds only `_CenteredCard` — Card 1/2/3 are structurally unreachable in this state, not merely hidden. |
| AC4 design fidelity, dark + `vi` | PASS | I read both PNGs myself. `design-reference-zodiac-android.png` genuinely depicts the Zodiac Red Flag screen (matching `Design-Screen: zodiac`), and `implemented-zodiac-emulator-5554.png` shows the built screen fully painted — not a splash, spinner, error frame or a different screen. Score `7`, the ~70% bar fill, the eyebrow, both element-inked discs, the three tinted tip rows and the disclaimer all correspond. Deltas 1/2/4 in the report are legitimate and correctly reasoned. Source guards are real assertions, not placeholders: `zodiac_route_test.dart:117-129` runs `RegExp(r'[♈-♓]')` and `:131-140` runs the raw-hex regex over every `.dart` file returned by `_zodiacSources()` (`:49-54`), each asserting `isFalse`. |
| AC5 direct in-app route | PASS | `zodiac_red_flag_screen.dart:27` publishes `routeName = '/zodiac/red-flag'`; `cupid_app.dart:65-68` registers it in the `routes:` map without adding a `'/'` key. `zodiac_route_test.dart:58-99` pushes it from the authenticated shell and asserts the screen mounts, plus that `home:` is not shadowed. `:103-113` asserts `'zodiac'` is gone from `_notImplementedCanvasIds` and the `PreviewScreenEntry` exists. `story_master.md:105-107` records `Direct URL only acceptable: YES` with STORY-002 owning discoverability. |

## Contract fidelity (`architecture/contract-summary.md`)

Verified exactly, key by key: textual `status` matching with fail-honest on
unknown (§1); `UnexpectedFailure` on every missing required key with **no**
substituted default (§3, `_requiredString`/`_requiredInt`/`_asObject`,
`zodiac_repository.dart:106-132`); `default:`-branch parsing for the append-only
`tint`/`icon` vocabularies rather than a throwing exhaustive switch
(`zodiac_red_flag.dart:116-117,137-140`, §2); `displayName` falling back to
`sign.viLabel` and never a placeholder (`:84`, §3 row 6); `fillFraction` derived
from `score/scoreMax` with no hardcoded `10` or `70%` (`:62-63`, §3 row 3);
lowercase `zodiacSign` fed straight to `CupidZodiacSign.tryParse` with no
re-derivation from `birthday` (§2). `ZodiacRepository` is the only file under
`mobile/lib` that knows the payload keys.

## Open questions

OQ1 (RESOLVED — static curated table) and OQ2 (RESOLVED — no new profile input)
are both implemented as recorded: the content lives in static TS tables with no
authoring pipeline, and the service reads the pre-existing `User.zodiacSign`
column. No blocked scope was implemented and no unblocked AC was omitted.

## Blocking findings

### F-1 — No story-level runtime startup smoke; the new backend module is never booted

Reviewer rule 12g makes registry-backed runtime startup smoke a mandatory
story-level gate for a non-trivial `shared` story. There is **no
`## Story Runtime Startup Smoke` section** in `coding-plan/test-results.md`.
Instead `coding-plan/master-plan.md:40-41` records startup smoke
`NOT_APPLICABLE` for both `backend-api` and `mobile-app`, deferring runtime
evidence to requirement-level integration verification. That deferral is not a
valid waiver: the only sanctioned form is `Runtime-Smoke: WAIVED — <reason>` in
`story_master.md`, and neither `story_master.md` nor `req_master.md` contains it.

This is not a paperwork gap. `ZodiacModule` is new and was added to the root
graph at `backend/src/app.module.ts:58`, yet **no test ever instantiates it** —
`zodiac.service.spec.ts:37-43` compiles a bare `providers` array, so
`ZodiacController`, the `ZODIAC_CLOCK` custom provider and the `UsersModule`
import are covered only by `nest build`, which type-checks but does not resolve
the DI graph. A Nest wiring fault of this shape compiles clean and fails at boot.
(`UsersModule` does export `UsersService` — `users.module.ts:11` — so the graph
looks correct on inspection; correct-on-inspection is precisely what 12g refuses
to accept in place of a boot.)

On the mobile side the only device launch in evidence is the **preview**
entrypoint: `visual-fidelity-report.md:26-30` builds
`-t lib/main_preview.dart` and launches `cupidpreview://screen/zodiac`. That
path bypasses `main.dart`, Firebase init, auth and the shell — while this story
modified `cupid_app.dart`, which *is* on the real launch path. The runtime
registry already states this distinction explicitly
(`runtime-command-registry.json:236-240`: the in-app first-screen widget test is
"supporting evidence only … NOT the readiness probe").

Both smokes are already fully specified in the registry, so this is cheap to
close:
- backend: `npm run start:dev` (or `start:prod`) with readiness
  `GET http://127.0.0.1:${DEVSTACK_PORT_API}/api-docs-json` expecting `200`
  (`runtime-command-registry.json:85,96-102`), then shutdown.
- mobile: the `readiness.command` at `runtime-command-registry.json:224` —
  `adb -s $MOBILE_DEVICE_SERIAL shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
  plus the `ResumedActivity` poll — against a `flutter build apk --debug`
  (default entrypoint, not `main_preview.dart`), with the recorded
  `shutdownCommand`.

Record the result as a `## Story Runtime Startup Smoke` section in
`coding-plan/test-results.md`. If the backend genuinely cannot boot locally
(`backend/service-account.json` is a manually supplied secret per
`runtime-command-registry.json:118`), that is a `BLOCKED` sub-case to report
rather than a silent `NOT_APPLICABLE` — do not re-record the deferral.

Owner: `devops` (backend boot) + `mobile-dev` (real-entrypoint app launch).

### F-2 — Missing `## Entry Point Reachability` evidence section

Reviewer rule 12e1 requires `coding-plan/test-results.md` to carry an
`## Entry Point Reachability` section with `Reachable: YES` and the concrete
path. It has none; AC5 reachability appears only as a prose bullet under the P3
results (`test-results.md:112-113`).

The underlying implementation is correct and I verified it independently in code
(see AC5 above), so this is an evidence-record gap only — but 12e1 names a
missing evidence section as `PATCH_REQUIRED`. Add the section recording
`Reachable: YES` and the path
`Navigator.pushNamed(ZodiacRedFlagScreen.routeName)` → `'/zodiac/red-flag'`
registered in `cupid_app.dart:65-68`, plus the note that the discoverable Home
quick-grid entry point is STORY-002's deliverable per `story_master.md:105-107`.

Owner: `mobile-dev`.

## Deferred findings

- **D-1 — degraded copy prescribes a remedy that is wrong for one reason code.**
  `zodiac_red_flag_screen.dart:356-357` tells the user "Cả hai người cần điền
  ngày sinh trong hồ sơ". That is correct for `self_zodiac`/`partner_zodiac`,
  but the same neutral card is also shown for `partner_link` (not paired), where
  filling in a birthday changes nothing. The implementation is contract-correct —
  §4 mandates one neutral card for every non-`ready` status and forbids branching
  on `missing` — so this is a copy follow-up, not a defect. Likely unreachable in
  practice because the app gates on pairing upstream.
- **D-2 — one visible difference not named in the fidelity report's delta list.**
  In `implemented-zodiac-emulator-5554.png` the lower ~20% of the screen exposes
  the teal stop of the shared `CupidAppBackground` gradient, where the reference
  draws the tab bar over that region. It is a direct consequence of recorded
  delta 1 (no tab bar above `AppShell`) acting on pre-existing app-wide chrome
  this story did not touch, so it is not a regression — but section 4 should have
  named it rather than leaving the reader to notice it.
- **D-3 — `Design-Surface` not recorded.** `design-fidelity-config.json` declares
  two design sources (`cupid-app`/mobile and `cupid-web`/web) and the lane is
  `shared`, which per rule 12e2 calls for an explicit `Design-Surface: <id>` in
  `story_master.md`. It is absent. Not blocking here because the surface is
  unambiguous in substance — `Platform: android`, a 412dp canvas viewport, and a
  Flutter-only deliverable — and I confirmed by reading the reference image that
  it is the correct mobile zodiac screen. Worth recording explicitly on future
  `shared`-lane UI stories.
- **D-4 — design entry-file naming mismatch (unverifiable here).**
  `visual-fidelity-report.md` and the widget source comments cite
  `Cupid Screens.dc.html`, while `design-fidelity-config.json` `design_source.entry`
  is `Cupid App.dc.html`. Both files sit in the same locked bundle under one
  `content_fingerprint`, and the reference image is demonstrably the right screen,
  so nothing is invalidated. I could **not** determine whether citing
  `Cupid Screens.dc.html` is longstanding convention across earlier requirements:
  `Grep`/`Glob` are unavailable in this session, `ToolSearch` is disabled, and
  `guard-query-first-bash-read.sh` blocks shell `grep` over artifacts
  (`SHELL_GREP_SOURCE`), so no repo-wide pattern check was possible. Flagging for
  someone with search tooling to reconcile the config `entry` value.
- **D-5 — timezone-fragile backend assertion.** `zodiac.service.spec.ts:10`
  pins `new Date('2026-08-25T10:00:00Z')` while `toContentDate`
  (`zodiac.service.ts:17-22`) formats with local getters, so the
  `expect(...).toBe('2026-08-25')` assertion at `:57,108` would fail on a CI host
  more than 10 hours behind UTC. Passes on this machine (UTC+7).
- **D-6 — payload arity is contracted but not enforced.** §3 rows 5/7 specify
  exactly 2 partners and exactly 3 tips; `_parseList`
  (`zodiac_repository.dart:99-104`) accepts any length. Not a crash risk —
  `_PartnerPair` (`zodiac_conflict_index_card.dart:156-174`) and
  `ZodiacDailyTipsCard` (`zodiac_daily_tips_card.dart:22-32`) both iterate rather
  than index, and a short list renders short by design. Backend is the sole
  producer and its own spec pins the arity.

## Configuration guide

Not required. `master-plan.md:8` records `NOT_APPLICABLE` and this review
confirms it: no new env var, secret, port or third-party integration — the
endpoint reuses the existing `JwtAuthGuard` and the existing `zodiacSign`
profile column. `req_master.md:11` `Status: NOT_REQUIRED` is accurate.

## Recommended workflow state

- Uncheck `Implementation (Development)`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Route F-1 to `devops` + `mobile-dev` and F-2 to `mobile-dev` as one rework
  phase. No source change is required for either finding unless the smoke itself
  surfaces a fault — both are verification runs plus evidence sections in
  `coding-plan/test-results.md`.
- Do not merge the story branch to
  `codex/REQ-011_zodiac_red_flag_and_home_quick_grid_completion-integration`
  until the re-review records `CLEAN` or `DEFERRED_ONLY`.
