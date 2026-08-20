# STORY-062 Review Report — Notification Copy ADR-002 Compliance Ruling

Reviewer: Iris-QC
Mode: `compact-story-review`
Date: 2026-08-20
Requirement: REQ-004_notifications_dnd_banner_copy_reconciliation
Story: STORY-062_notification_copy_adr002_compliance_ruling
Complexity: trivial · Implementation Lane: mobile (single-lane, rule 15 OK)
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-004_notifications_dnd_banner_copy_reconciliation-STORY-062_notification_copy_adr002_compliance_ruling`
Branch: `codex/REQ-004_notifications_dnd_banner_copy_reconciliation-STORY-062_notification_copy_adr002_compliance_ruling`
BaseHead: `9742fe8c14fc4059c3c5c827e1d2b6ff09fbdd56` · Reviewed commit: `562d53f`

Outcome: DEFERRED_ONLY

## Scope Gate

- Review type: `compact-story-review` (ADR-002-enforcing guard change; Tier 0
  self-approval correctly excluded).
- Report path: this file.
- Source/test files in scope (1): `mobile/test/features/reminders/reminder_copy_guard_test.dart`.
- Story artifacts changed in scope (2): `story_master.md` (Implementation
  checkbox), `verification/mobile-verification.md`.
- Evidence in scope: `verification/mobile-verification.md`,
  `requirements/requirements.md` AC1-AC4, `story_master.md`.
- Query keys: `_forbiddenTokens`, `lowered.contains`, `không làm phiền`,
  `do not disturb`, `notification_settings_screen.dart`, `permissions_screen.dart`.
- Retro gate (rule 1a): `data/retro-audit/rework-backlog.md` index checked —
  every RWB item is `RESOLVED`/`DONE`, no `PENDING`/`IN_PROGRESS`. Handoff is
  not blocked by pending retro rework.
- Phase 2 proceeds.

## Acceptance Criteria

| AC | Verdict | Independent verification |
| --- | --- | --- |
| AC1 guard hardened with `'không làm phiền'` | PASS | `reminder_copy_guard_test.dart:25` adds the token to `_forbiddenTokens`; it is consumed by the same `for (final token in _forbiddenTokens) { if (lowered.contains(token)) ... }` loop (lines 60-66) that already fails on `'do not disturb'`/`'synced alarm'` — one shared check, not a separate or weaker path. Test description at lines 37-39 names the new token. |
| AC2 `notifs` banner copy unchanged | PASS | `git diff <BaseHead>..HEAD --stat` touches exactly 3 files; `notification_settings_screen.dart` and `app_vi.arb`/`app_en.arb` are not among them. Zero production copy diff. |
| AC3 `permissions` row copy unchanged | PASS | Same diff evidence; `permissions_screen.dart` untouched. |
| AC4 ruling citation trail recorded | PASS | `requirements/requirements.md:68-90` records Decision (Resolution Path (a), uniform), Why (D1 Critical Alerts + ASSUMPTION-2/R9 foreground-only), What closes (REQ-002 E-2, RWB-20260816-024 AC2), and the bootstrap registry cross-reference — no re-derivation from `req_master.md` needed. Not a mobile-lane deliverable. |

## Independent checks beyond the supplied evidence

- Ran `git grep -in -e "làm phiền" -e "do not disturb" -e "báo thức" -- mobile/lib`
  in the worktree: 2 hits, both `///` doc-comment lines
  (`notification_settings_screen.dart:16`,
  `reminder_strings.dart:10`), both skipped by the guard's
  `line.trimLeft().startsWith('//')` filter at line 53. Confirms the suite is
  green on substance, not by accident, and confirms AC2's claim that the shipped
  `notifs` banner carries no DND clause — the only occurrence there is an
  explanatory comment.
- WriteScope: exactly one test file changed under `mobile/`; the other two
  changed files are this story's own artifacts (implementer checkbox + the
  verification file). No production source, no `pubspec.yaml`, no ARB touched.

## Risk surfaces and critical gates

| Surface | Gate | Result |
| --- | --- | --- |
| Runtime/configuration (compliance guard test) | Targeted guard test run | PASS — `flutter test .../reminder_copy_guard_test.dart` 2/2 (evidence §1) |
| Mobile copy regression | Sibling widget tests unmodified | PASS — 12/12 across `notification_settings_screen_test.dart`, `permissions_screen_test.dart`, guard (evidence §2) |
| Static analysis | `flutter analyze` on the changed file | PASS — no issues (evidence §3) |
| Design fidelity (12e2/12e3) | Not applicable | The story delivers zero production UI change; there is no implemented screen state to render or compare. A design source is configured (`data/devops/system/design-fidelity-config.json`, `ui_surface: true`), but this story is not UI-bearing. |
| Entry point reachability (12e1) | Not applicable | No user-facing capability added. |
| Runtime startup smoke (12g) | Not required | 12g scopes to non-trivial stories; `story_master.md` records `Complexity: trivial` and the diff is test-only with no runtime surface. |
| Configuration guide (12a) | Not required | No setup/configuration, env, or external-integration impact. |

Tests were not rerun (rule 18): the evidence is one commit old, complete with
commands and output, and nothing in it was stale or contradictory.

## Deferred findings

**D-1 (LOW) — the guard does not scan the ARB copy source; ARB coverage is
incidental and build-state dependent.**
`reminder_copy_guard_test.dart:44-47` walks `Directory('lib')` and filters
`file.path.endsWith('.dart')`. The canonical localized copy lives in
`mobile/lib/l10n/arb/app_vi.arb` and `app_en.arb` (both tracked, both cited by
AC2), which are not `.dart` and are therefore never scanned. The generated
Dart that does contain those strings (`mobile/lib/l10n/generated/`) is
gitignored (`mobile/.gitignore:41`) and only exists after `flutter gen-l10n` —
mobile-dev had to generate it before the widget tests would compile. So on a
fresh checkout the guard can pass while a banned Vietnamese phrase sits in
`app_vi.arb`.

Not blocking: the gap is pre-existing and identical for the three tokens that
predate this story (`báo thức`, `synced alarm`, `do not disturb`); this story
did not make it worse, and closing it is outside the declared scope
("Out of scope: any forbidden-token addition beyond the one Vietnamese DND
phrase"). Recorded because AC3 characterises this guard as "the durable
compliance gate every future surface must keep green", and that durability
claim is weaker than it reads. Suggested follow-up: extend the file filter to
`.arb` (a one-line change) as its own RWB item or a REQ-004 follow-on story.

## Blocking findings

None.

## Traceability

- Requirements: `requirements/requirements.md` AC1-AC4, Scope, Open Question
  Impact (sole OQ RESOLVED 2026-08-20 by the PO ruling this story implements —
  OQ discipline per rule 12 satisfied, no unresolved OQ affects this scope).
- UX / Architecture: `SKIPPED:trivial` per `story_master.md`; correct — the
  story ratifies an existing decision (ADR-002) and adds no new UX or
  architecture decision.
- Evidence: `verification/mobile-verification.md` §1-§3 + AC table,
  `MOBILE_COMPLETE`.
- Code: `mobile/test/features/reminders/reminder_copy_guard_test.dart:18-26`,
  `:35-39`, `:60-66`.

## State recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE`.
- Carry D-1 forward as a follow-up item if Scrum Master wants the ARB coverage
  gap tracked; it is not a condition of closing STORY-062.
