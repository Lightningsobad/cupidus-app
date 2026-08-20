# Requirement Breakdown: REQ-004 Notifications DND Banner Copy Reconciliation

## Source Artifacts

- Requirement master:
  `data/requirements/REQ-004_notifications_dnd_banner_copy_reconciliation/req_master.md`
- Additional input files:
  - `mobile/test/features/reminders/reminder_copy_guard_test.dart` (ADR-002 guard)
  - `mobile/lib/features/reminders/presentation/reminder_strings.dart` (ADR-002 canonical copy source)
  - `mobile/lib/features/account/presentation/screens/notification_settings_screen.dart` (`notifs` banner)
  - `mobile/lib/features/onboarding/presentation/screens/permissions_screen.dart` (`permissions` row)
  - `data/ux/system/ui_ux_system_memory.md` §7 (original DND finding)
  - `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-009_nhac_nho_dong_bo/architecture/solution.md` (ADR-002 origin, D1)
  - `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/integration-review/review-report.md` (E-2 finding)
  - `data/retro-audit/rework-backlog.md` RWB-20260816-024 (STORY-047 AC2 fold-in)
- Existing related requirement artifacts:
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/req_master.md`

## Context Summary

- Request summary: Two locked-design copy tokens ("Do Not Disturb" DND-override
  claim on the `notifs` banner; "Synced Alarm" label on the `permissions`
  notification row) both trip the same approved ADR-002 copy guard test. User
  routed this to Product Owner/UI-UX for one ruling covering both.
- Primary actors: end user reading notification-related copy during onboarding
  (`permissions`) and in account settings (`notifs`).
- Problem to solve: the locked design source claims capabilities (DND
  override, native alarm-clock behaviour) the shipped architecture explicitly
  excludes and cannot deliver (no Critical Alerts entitlement; foreground-only
  delivery, R9). Two independent implementer workarounds already exist in
  `main` without a formal product ruling backing them, and the enforcement
  guard has a mechanical gap (English-only pattern match) that does not match
  the ruling's actual intent.
- Business outcome: user-facing copy never promises something the product
  cannot do, in any language, and the two open E-2/AC2 findings close with an
  explicit, durable ruling instead of silent implementer discretion.
- Success signal: `req_master.md` Open Question resolved; guard test blocks
  the Vietnamese DND phrase the same way it already blocks the English one;
  existing regression-pinning tests for both screens stay green unmodified.
- Notes on current project context: both screens already ship the ruled
  outcome in code (STORY-031, STORY-047 revert). This requirement is
  ratification plus guard hardening, not a copy change.

## Scope Decision

### In Scope

- Ratify Resolution Path (a) (alternate copy, ADR-002 unchanged) for both the
  `notifs` banner and `permissions` row tokens, applied uniformly — see
  `req_master.md` Ruling.
- Harden `reminder_copy_guard_test.dart` to also block the Vietnamese
  Do-Not-Disturb phrase ("không làm phiền"), closing the mechanical gap
  Iris-QC flagged (REQ-002 Round 2 review, E-2) where the guard only matched
  the English phrase.
- Verify existing regression-pinning tests
  (`notification_settings_screen_test.dart`,
  `permissions_screen_test.dart`) remain green and unmodified, confirming no
  copy regression accompanies the guard change.

### Out of Scope

- Any change to the `notifs` banner or `permissions` row copy text itself —
  both already ship the ruled-correct alternate copy.
- REQ-003 (app shell five-tab navigation) — separate, unrelated requirement.
- Any other Round 2 deferred/blocking finding tracked in REQ-002's own
  `req_master.md`.
- Constructing new Critical Alerts / DND-override capability — explicitly
  excluded by ADR-002/D1 and not reopened by this ruling.

### Business Rules And Guardrails

- No user-facing string under `mobile/lib` may claim DND-override,
  Critical-Alerts, or native-alarm-clock behaviour, in Vietnamese or English —
  the product genuinely cannot deliver either (R9: no backend FCM dispatch to
  backgrounded devices).
- `ReminderStrings` remains the single canonical source for the
  Synced-Reminder feature's own copy (STORY-009 AC2/AC3); this requirement
  does not relocate `notifs_cap_banner` or the `permissions` row copy into it,
  since neither string is exclusive to the reminder feature.

## Open Question Triage

| OQ ID | Status | Scope Items BLOCKED | Scope Items NOT BLOCKED | Decision |
|-------|--------|---------------------|------------------------|----------|
| Central registry: "D1/Critical-Alerts copy conflict" (`data/intake/bootstrap/conflicts_open_questions.md:73-85`, unlabeled bullet, no formal OQ ID assigned) | RESOLVED (2026-08-20) | — | All scope | Same direction the registry entry already recommended ("scope this copy out of v1"); formally ratified by this requirement's Ruling |
| REQ-002 finding E-2 (`integration-review/review-report.md`) | RESOLVED (2026-08-20) | — | All scope | Ratified via Resolution Path (a); see `req_master.md` Ruling |
| RWB-20260816-024 residual AC2 (STORY-047, `rework-backlog.md`) | RESOLVED (2026-08-20) | — | All scope | Same ruling covers both tokens uniformly |

### OQs reviewed but not applicable to this requirement

- ASSUMPTION-1 (STORY-009, "mỗi sáng"/recurrence wording) → not applicable,
  unrelated copy token.

## Seed To Story Mapping

No `## Story Seeds` table was carried on `req_master.md`; this requirement
was routed directly from a Reviewer finding, not discovery.

### Distinct user outcomes in this requirement

1. Notification-related copy across both surfaces never overstates the
   product's capability, in any language, and that guarantee is enforced by
   an automated guard rather than by convention. Both tokens serve this same
   single outcome — that is why the user required one ruling, not two.

## Coverage Map

| Requirement / Need | Planned Story ID(s) | Notes |
|--------------------|---------------------|-------|
| `notifs` banner DND claim (E-2) | STORY-062 | Ratify already-shipped alternate copy |
| `permissions` row "Synced Alarm" label (RWB-20260816-024 AC2) | STORY-062 | Ratify already-shipped alternate copy |
| Guard mechanical gap (Vietnamese DND phrase) | STORY-062 | New guard token |

## Recommended Story Sequence

| Story ID | Title | Complexity | Depends On | Why This Order | Observable After This Story |
|----------|-------|------------|------------|----------------|-----------------------------|
| STORY-062 | Notification Copy ADR-002 Compliance Ruling | trivial | None | Only story in this requirement | Both E-2/AC2 findings are formally closed; a future Vietnamese-DND string addition now fails the build the same way an English one already does |

## Story Index

| Story ID | Title | Brief File | Primary Scope | Key AC/OQ Anchors |
|----------|-------|------------|---------------|-------------------|
| STORY-062 | Notification Copy ADR-002 Compliance Ruling | `data/requirements/REQ-004_notifications_dnd_banner_copy_reconciliation/STORY-062_notification_copy_adr002_compliance_ruling/story_brief.md` | Guard test hardening + ruling ratification | E-2, RWB-20260816-024 AC2 |

INTEGRATION_VERIFICATION_REQUIRED: NO
