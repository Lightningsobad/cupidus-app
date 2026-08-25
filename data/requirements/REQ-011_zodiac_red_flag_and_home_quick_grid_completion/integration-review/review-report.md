# Requirement Integration Review — REQ-011

Requirement: REQ-011_zodiac_red_flag_and_home_quick_grid_completion
Review type: `requirement-integration-review` (pass 1)
Reviewer: Iris-QC
Date: 2026-08-25
Scope gate: `data/requirements/REQ-011_zodiac_red_flag_and_home_quick_grid_completion/integration-review/scope-gate.md`

Outcome: PATCH_REQUIRED

Blocking findings: 2
Deferred findings: 4

## Rationale

The two merged stories integrate correctly. The single genuine cross-story
surface — Home quick-grid tile to the Zodiac Red Flag screen — is wired through
a shared symbol on both sides and mounts a real registered route, and the
requirement-level cross-screen visual audit found no blocking breakage. The
backend addition is self-contained with no migration, no generated client, and
no new configuration surface, so both recorded Open Question resolutions hold
against what was actually built.

What is missing is requirement-level closure evidence, not correctness. The
merged integration branch carries no `## Integration Build & Runtime` artifact
(rule 12g3) and `req_master.md` records no `Integration-Verify: WAIVED`, so the
mandatory proof that the merged tree builds and boots does not exist in the
required location. Separately the requirement's own story registry is stale.
Both are cheap to clear and neither requires reopening implementation, but the
DONE gate enforces the first independently, so this cannot close as
`DEFERRED_ONLY`.

## Merged scope

| Story | Complexity / Lane | Merge | Own review outcome | Story master |
|---|---|---|---|---|
| STORY-001 zodiac red flag screen | complex / shared | `51d5236` | DEFERRED_ONLY (pass 3), 0 blocking | `Status: DONE` |
| STORY-002 home quick grid zodiac tile | standard / mobile | `da4f60c` | DEFERRED_ONLY (round 3), 0 blocking, 1 deferred | `Status: DONE` |

Baseline `1aba7508` → HEAD `9847cc1`. HEAD is one docs-only commit above the
`da4f60c` named in the handoff; it adds `mobile-visual-audit.md` and changes no
runtime bytes.

`51d5236` is an ancestor of `da4f60c^2` — STORY-002 was developed on top of the
already-merged STORY-001, so the two stories never diverged and there is no
merge-order reconciliation risk to verify.

## Cross-story integration verification

The one cross-story surface, verified at both call sites in code rather than
from narrative:

| Link | Location | Result |
|---|---|---|
| Route constant | `mobile/lib/features/zodiac/presentation/zodiac_red_flag_screen.dart:27` — `static const String routeName = '/zodiac/red-flag'` | PASS |
| Registration | `mobile/lib/app/cupid_app.dart` — `routes:` map binds `ZodiacRedFlagScreen.routeName` to `const ZodiacRedFlagScreen()` | PASS |
| Consumer | `mobile/lib/features/home/presentation/home_screen.dart:923-925` — `Navigator.of(context).pushNamed(ZodiacRedFlagScreen.routeName)` on tile `home_zodiac_entry_tile` | PASS |

Both sides reference the same exported symbol rather than a duplicated string
literal, so the route name cannot drift between the producing and consuming
story. The registration comment correctly notes the map must never carry a `'/'`
key while `home:` is set, which is the real `MaterialApp` assertion risk in this
shape. Coverage exists at `mobile/test/features/zodiac/presentation/zodiac_route_test.dart`
and `mobile/test/features/home/home_quick_grid_test.dart:309-312`.

## Requirement-level checks

| Check | Result | Evidence |
|---|---|---|
| Cross-screen mobile visual audit | PASS, no blocking breakage | `integration-review/mobile-visual-audit.md` (`MOBILE_VISUAL_AUDIT_COMPLETE: YES`) |
| OQ1 — MVP content source | RESOLVED and honored | `conflict-index.content.ts` ships `CONFLICT_INDEX` as a static `ReadonlyMap`; no admin content system, no content table, no migration |
| OQ2 — new profile input for zodiac sign | RESOLVED and honored | `zodiac.service.ts:45,50` reads `self.zodiacSign` / `partner.zodiacSign` off the existing `User` entity; missing signs return `incomplete_profile`, no new profile input |
| Configuration `NOT_REQUIRED` | Still holds | `zodiac.module.ts` provides `ZODIAC_CLOCK` as an internal DI value; no `process.env`, no `ConfigService`, no new env/port/migration surface |
| Backend self-containment | Holds | `app.module.ts` diff is a 2-line `ZodiacModule` import + registration; no shared runtime/registry or generated-client change |
| Story test evidence coherence | No contradiction or staleness found | Both `coding-plan/test-results.md` carry passing build, analyze, targeted tests, `## Story Runtime Startup Smoke`, `Entry Point Reachability: YES`, `VISUAL_FIDELITY: PASS` |
| `req_master.md` User Stories rows both DONE | FAIL | See B-2 |
| Merged-branch build + runtime evidence (rule 12g3) | FAIL | See B-1 |

## Blocking findings

### B-1 — No `## Integration Build & Runtime` evidence for the merged branch

Rule 12g3 requires `data/requirements/<REQ>/integration-review/` to carry a
`## Integration Build & Runtime` section holding both `- Build: PASS — <command + result>`
and `- Runtime/Smoke: PASS — <startup smoke command + result>` in the same file.

`integration-review/` contains exactly one file, `mobile-visual-audit.md`, and it
holds no `Build:`, `Runtime/Smoke:`, or `Integration Build` line. `req_master.md`
records no `Integration-Verify: WAIVED — <reason>`. So neither the evidence nor
the documented waiver exists.

Residual technical risk is LOW, and the report should say so plainly: because
STORY-002 was branched on top of merged STORY-001, STORY-002's own
`## Story Runtime Startup Smoke` (`coding-plan/test-results.md:384-413`) already
built and cold-launched a mobile tree that contained both stories
(`flutter build apk --debug` PASS, install + `am start -W` PASS), and the backend
tree at integration HEAD is byte-identical to the one STORY-001 smoked
(`test-results.md:149-185`). The gap is that this proof lives in per-story
artifacts and was never established against the merged branch in the required
location. The DONE gate enforces this artifact independently, so it must exist
regardless of how strong the per-story evidence is.

Owner: Scrum Master to route the integration-verification pass.
Action: run build + startup smoke on integration HEAD `9847cc1` and record both
verdict lines in one file under `integration-review/`, or record
`Integration-Verify: WAIVED — <reason>` in `req_master.md` if the per-story
coverage above is accepted as sufficient. This is transcription plus one
confirmatory run, not new development.

### B-2 — `req_master.md` story registry is stale for STORY-002

`data/requirements/REQ-011_.../req_master.md:89` still reads `PENDING` for
STORY-002 while `STORY-002_home_quick_grid_zodiac_tile/story_master.md:3` reads
`Status: DONE` (flipped in `5b29058`, before the `da4f60c` merge). Line 88 was
correctly updated to `DONE` for STORY-001, so this is a missed update on one row,
not a disputed status.

Owner: Scrum Master (Reviewer must not edit `req_master.md`).
Action: set the STORY-002 row to `DONE`. No implementation lane needs to reopen;
Scrum Master can clear this directly as part of closure.

## Deferred findings

| ID | Finding | Owner | Why non-blocking |
|---|---|---|---|
| DEF-1 | Carried from STORY-002 review DEF-3 — `STORY-002/ux/ux-spec.md` §3 item 5 still omits the tile subtitle colour that the implementation ships | UI/UX Designer | Spec-documentation gap; the implemented colour was reviewed and passed visual fidelity |
| DEF-2 | Visual audit F-5 — light theme fails AA on four of this requirement's surfaces | UI/UX Designer | Sits entirely behind `enableLightTheme=false`; belongs with REQ-010's D1/F-6 token decision, not this requirement's completion path |
| DEF-3 | Visual audit F-2 — the tile→screen navigation is not observable in the sanctioned preview harness | Mobile Dev / tooling | Evidence-tooling gap, low residual risk; closed by the passing AC2 navigation test (`home_quick_grid_test.dart:309-312`) and by the route registration independently verified above |
| DEF-4 | `req_master.md:80-81` describes OQ1's resolution as "static curated content table shipped with backend **seed data**", but the implementation ships compiled TypeScript constants, not DB seed data | Product Owner | Wording only. The actual disposition — static curated content, not an admin-authored system — is honored, so this is not a scope deviation |

## Traceability

- Merged story ids and merge refs: STORY-001 / `51d5236`, STORY-002 / `da4f60c`
- Story review reports: both `Outcome: DEFERRED_ONLY`, 0 blocking findings each
- Integration evidence: `integration-review/mobile-visual-audit.md` (PASS)
- Cross-story contract: `ZodiacRedFlagScreen.routeName`, verified at definition,
  registration, and consumption
- Migrations / generated clients / shared runtime registry: none introduced
- Configuration guide: not required; `req_master.md` `Status: NOT_REQUIRED`
  re-confirmed against `zodiac.module.ts`
- Missing: merged-branch build + runtime evidence (B-1)

## Integration Build & Runtime

- Build: PASS — `flutter pub get && flutter build apk --debug` (run in `mobile/` at integration branch HEAD `90b670c` — one docs/registry-only commit above the reviewed `9847cc1`, no runtime bytes changed); Gradle task `assembleLocalDebug` succeeded, `Built build/app/outputs/flutter-apk/app-local-debug.apk`.
- Runtime/Smoke: PASS — reused already-online `emulator-5554` (`adb devices` confirmed `device` state), installed the built debug APK via `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk` (Success), then ran the registry `readiness.command` `adb -s "$MOBILE_DEVICE_SERIAL" shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity >/dev/null && for _ in $(seq 1 30); do adb -s "$MOBILE_DEVICE_SERIAL" shell dumpsys activity activities | grep -q "ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity" && exit 0; sleep 2; done; exit 1` — exited 0 with `ResumedActivity` matched on the first poll; then ran `readiness.shutdownCommand` `adb -s "$MOBILE_DEVICE_SERIAL" shell am force-stop com.snapsofts.cupid` (exit 0).

## State recommendation

- Requirement status: `IN_PROGRESS` — do not mark `DONE`
- Leave the requirement integration review gate unchecked
- Clear B-1 (integration-verification pass or documented waiver) and B-2
  (registry row), then re-gate this review
- Carry DEF-1 through DEF-4 forward as recorded follow-ups; none of them gate
  closure

REVIEW_COMPLETE: YES
