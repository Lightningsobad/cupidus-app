# STORY-062 Requirements: Notification Copy ADR-002 Compliance Ruling

Source: `req_master.md` Ruling (2026-08-20, Product Owner), Scope bullets 1-3.
Closes: REQ-002 integration-review finding **E-2**;
`data/retro-audit/rework-backlog.md` **RWB-20260816-024** AC2.

## Complexity / Lane Confirmation

- Complexity: trivial — confirmed. The only code change is adding one token
  to an existing static guard test (`reminder_copy_guard_test.dart`); no
  production copy on either screen changes.
- Implementation Lane: mobile — confirmed, single-lane, test file only.
- UX Design and Architecture are SKIPPED:trivial per `story_master.md` — this
  story ratifies an already-made ruling and hardens an existing guard; it
  does not introduce a new UX decision or a new architecture decision.

## Scope

In scope — exactly the three Scope Seed bullets from `story_brief.md`:

- Add the Vietnamese Do-Not-Disturb phrase "không làm phiền" to the
  forbidden-token list in
  `mobile/test/features/reminders/reminder_copy_guard_test.dart`, alongside
  the existing English "Do Not Disturb" ban, so the guard fails a Vietnamese
  translation of the banned claim the same way it already fails the English
  wording.
- Confirm `notification_settings_screen_test.dart` and
  `permissions_screen_test.dart` still pass unmodified — no production copy
  in `notification_settings_screen.dart` or `permissions_screen.dart`
  changes as part of this story.
- Record the ratified ruling's citation trail in this artifact (below) for
  Reviewer traceability.

Out of scope:

- Changing the `notifs` banner (`notification_settings_screen.dart`) or
  `permissions` row (`permissions_screen.dart`) copy text — both already
  ship the ADR-002-canonical alternate copy this ruling ratifies.
- Any forbidden-token addition beyond the one Vietnamese DND phrase this
  ruling's intent requires (e.g., no new "Synced Alarm"/native-alarm-clock
  token — that claim's English form is already covered by the existing
  guard, and no separate Vietnamese "Synced Alarm" wording is in play).
- Reopening ADR-002, D1, or R9.

## Acceptance Criteria

- **AC1 (guard hardened — Vietnamese DND phrase):**
  `reminder_copy_guard_test.dart`'s forbidden-token list includes
  "không làm phiền" in addition to the existing "Do Not Disturb" ban, and
  the test suite fails if that literal Vietnamese phrase appears in the
  scanned source. This closes the mechanical gap Iris-QC flagged (REQ-002
  Round 2 review, finding E-2): the guard previously pattern-matched only
  the English phrase (plus "báo thức"), so a Vietnamese translation of "Do
  Not Disturb" would have slipped past it mechanically.
- **AC2 (no production copy regression — `notifs` banner):**
  `notification_settings_screen_test.dart` passes unmodified. The `notifs`
  banner keeps shipping `notifs_cap_banner` = "Tối đa 15 thông báo/ngày." /
  "Max 15 pushes/day." (`notification_settings_screen.dart:15-18`,
  `l10n/arb/app_vi.arb:617`, `l10n/arb/app_en.arb:136`) — the numeric-cap-only
  sentence STORY-031 already shipped, with no DND clause in either language.
- **AC3 (no production copy regression — `permissions` row):**
  `permissions_screen_test.dart` passes unmodified. The `permissions` row
  keeps shipping the ADR-002-canonical `Nhắc nhở đồng bộ` / `Synced Reminder`
  phrasing (`permissions_screen.dart:80-81`: "Nhắc nhở đồng bộ và Emoji Storm
  cần cái này. Tối đa 15 cái/ngày." / "Synced Reminder and Emoji Storm need
  this. Max 15 a day.") — the phrasing STORY-047's mobile-dev already
  reverted to and pinned, with no "Synced Alarm" label in either language.
- **AC4 (ruling citation trail recorded for Reviewer traceability):** this
  story's artifacts state, without requiring Reviewer to re-derive it from
  `req_master.md`:
  - **Decision:** Resolution Path (a) — alternate copy, ADR-002 unchanged —
    applied uniformly to both tokens (`req_master.md` Ruling, 2026-08-20).
  - **Why:** both the `notifs` banner's original DND-override sentence and
    the `permissions` row's "Synced Alarm" native-alarm-clock label are
    capability claims the app architecturally cannot honour — no Critical
    Alerts entitlement (STORY-009 `architecture/solution.md` D1) and no FCM
    dispatch to a backgrounded device at all (ASSUMPTION-2/R9,
    foreground-only delivery) — so ADR-002's ban is a correctness
    constraint, not a wording preference, and stands unamended.
  - **What closes:** this ruling formally ratifies the alternate copy both
    screens already ship in `main` (via STORY-031's `notifs`-banner numeric
    cap sentence, and STORY-047's mobile-dev revert of the `permissions`-row
    "Synced Alarm" attempt) as the deliberate product decision, closing
    REQ-002 integration-review finding **E-2** and
    `rework-backlog.md` **RWB-20260816-024** AC2 — not by changing either
    screen's copy, but by the AC1 guard hardening plus this documented
    ruling.
  - **Central registry cross-reference:** this ruling also resolves the
    unlabeled bootstrap-era entry "D1/Critical-Alerts copy conflict"
    (`data/intake/bootstrap/conflicts_open_questions.md:73-85`).

## Open Question Impact

- **OQ Registry Reviewed:** `req_master.md` Open Questions section (single
  OQ, already RESOLVED 2026-08-20 by this same Product Owner ruling); central
  registry `data/intake/bootstrap/conflicts_open_questions.md:73-85`.
- **Impact on STORY-062:** None outstanding. The requirement's sole Open
  Question — which resolution path applies, and whether uniformly to both
  tokens — is resolved by the Ruling this story implements (Resolution Path
  (a), uniform). No other registry OQ concerns notification copy or this
  guard.
