# Requirement Master: REQ-004 Notifications DND Banner Copy Reconciliation
Status: DONE

## Source Request
Not user-typed prose. Raised as finding **E-2** in REQ-002's Round 2
requirement-integration-review (Iris-QC,
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/integration-review/review-report.md`,
"Decisions Required — Not Mine To Make"), then routed to the user directly by
Scrum Master via `AskUserQuestion` on 2026-08-16. User selected: **"Route to
PO/UX for a copy ruling."**

## Business Context
The locked design's `notifs` screen banner includes a "Do Not Disturb"
sentence. STORY-021's approved ADR-002 copy guard test
(`reminder_copy_guard_test.dart:18-22`) explicitly bans that literal string,
with an inline code comment instructing implementers not to delete the test
to unblock a copy change. This is a genuine conflict between the locked
design source and an approved architecture decision record — Iris-QC
assessed it as a business/product ruling, not a call the reviewer or Scrum
Master should make unilaterally.

The user has decided this should be resolved by Product Owner / UI-UX
Designer, not by silently keeping the ADR guard as-is.

**Second token folded in (2026-08-18, user decision):** STORY-047
(`REQ-002_screen_flow_and_design_fidelity_audit/STORY-047_pairing_chain_deviation_triage`,
retro-hardening RWB-20260816-024, AC2) hit the same
`reminder_copy_guard_test.dart:18-22` guard for a second, independent locked
design-source token: the `permissions` screen's notification-permission row
body copy is specified as `Synced Alarm và Emoji Storm cần cái này...`
(`Cupid Screens.dc.html:2452`), and `synced alarm` is separately banned by
the same guard. The app currently ships the ADR-002-canonical
`Nhắc nhở đồng bộ`/`Synced Reminder` phrasing instead
(`permissions_screen.dart:80-81`, unchanged). Mobile implementation reverted
the attempted AC2 copy change and left `main` green; verified by Scrum
Master against disk. This requirement now owns both tokens against the same
ADR-002 guard so PO/UX makes one ruling, not two.

## Scope
- Product Owner / UI-UX Designer review both the design intent behind the
  DND banner sentence and the rationale behind ADR-002's ban on that literal
  string, then rule on one of:
  - Alternate banner copy that preserves the design's DND-awareness intent
    without violating ADR-002 (update the screen only, guard test stays as
    the enforcement backstop), or
  - A scoped, deliberate amendment to ADR-002/the guard test if the ruling
    concludes the original ban no longer reflects current product intent
    (this must be an explicit, documented ADR change, not a silent test
    deletion).
- Update `notifs` screen copy and/or the guard test together, consistent with
  whichever ruling is made.
- Apply the same ruling logic to the `permissions` screen's `Synced Alarm`
  token (STORY-047 AC2, folded in 2026-08-18): either alternate copy that
  preserves design intent without violating ADR-002, or the same documented
  ADR-002 amendment if it applies to both tokens. Update
  `permissions_screen.dart:80-81` and
  `mobile/test/features/onboarding/permissions_screen_test.dart` (already
  carries two assertions pinning the current ADR-002-canonical copy in both
  locales, added by STORY-047's mobile-dev as a marker for whoever executes
  this ruling) together with whichever ruling is made.

## Out of Scope
- REQ-003 (app shell five-tab navigation) — separate, unrelated requirement
  from the same review round.
- Any other Round 2 deferred/blocking findings tracked in REQ-002's own
  `req_master.md` Deferred Follow-Up Items or bug registry.
- STORY-047's AC1/AC3/AC4/AC5 (profile CTA copy, joincode segmented entry,
  paste, creator cross-link) — unrelated to this guard, delivered and closed
  under STORY-047 itself.

## Open Questions
- Which of the two resolution paths above (alternate copy vs. ADR amendment)
  — for Product Owner/UI-UX Designer to decide during story breakdown, citing
  ADR-002's original rationale before proposing a change. The ruling must
  explicitly state whether it applies uniformly to both tokens (`Do Not
  Disturb` and `Synced Alarm`) or differently to each.
  **RESOLVED (2026-08-20, Product Owner), see Ruling below: Resolution Path
  (a) — alternate copy, ADR-002 unchanged — applied uniformly to both
  tokens.**

## Ruling (2026-08-20, Product Owner)

**Decision: Resolution Path (a) for both tokens. ADR-002 is not amended.**
The design source's phrasing on both screens makes a capability claim the app
architecturally cannot honour, not merely a stylistic mismatch, so the ban
stands and the design copy is replaced:

- The `notifs` banner's original sentence, "Chỉ Synced Alarm được phép phá Do
  Not Disturb" (`ui_ux_system_memory.md` §7 finding, `Cupid Screens.dc.html`),
  literally claims the reminder can override the OS Do Not Disturb mode. That
  requires a Critical Alerts-class entitlement. STORY-009's architecture
  solution explicitly excludes this as a non-goal (`architecture/solution.md`
  D1: "no Critical Alerts entitlement, ... no Do-Not-Disturb override"), and
  it is independently unreachable in v1 because ASSUMPTION-2/R9 means the
  backend never dispatches FCM to a backgrounded device at all — there is no
  delivery path to override DND on, so the claim would be false regardless of
  entitlement.
- The `permissions` row's "Synced Alarm" label (`Cupid Screens.dc.html:2452`)
  implies native OS alarm-clock behaviour — firing while the app is
  backgrounded or killed. The same R9 foreground-only limitation makes this
  false too: nothing fires unless the app is in the foreground.

Both claims are false regardless of which language renders them, so ADR-002's
ban is a correctness constraint, not a wording preference, and amending it
would mean shipping a promise the product cannot keep. Iris-QC's Round 2
review independently flagged that the guard test only pattern-matches the
literal English phrase (plus `báo thức`), so a Vietnamese translation of "Do
Not Disturb" would slip past the guard mechanically without honouring ADR-002's
intent — this ruling settles the intent question the mechanical gate cannot:
no DND-override or native-alarm claim ships in **any** language, and the
guard is hardened in STORY-062 to match that intent instead of only today's
English wording.

Both tokens already ship the alternate-copy resolution in current `main`, via
prior ad-hoc implementer decisions this ruling now formally ratifies as the
deliberate product decision (not implementer discretion), closing both open
findings:

- `notifs` banner: STORY-031 already dropped the DND clause outright rather
  than translating or softening it, shipping the numeric-cap-only sentence
  `notifs_cap_banner` = "Tối đa 15 thông báo/ngày." / "Max 15 pushes/day."
  (`notification_settings_screen.dart:15-18`, `l10n/arb/app_vi.arb:617`,
  `l10n/arb/app_en.arb:136`), pinned by
  `notification_settings_screen_test.dart:51`. This ruling ratifies that
  choice; it is not new copy.
- `permissions` row: STORY-047's mobile-dev reverted an attempted "Synced
  Alarm" copy change and left the ADR-002-canonical `Nhắc nhở đồng bộ` /
  `Synced Reminder` phrasing in place (`permissions_screen.dart:80-81`:
  "Nhắc nhở đồng bộ và Emoji Storm cần cái này. Tối đa 15 cái/ngày." /
  "Synced Reminder and Emoji Storm need this. Max 15 a day."), pinned by the
  regression guard STORY-047 added at
  `permissions_screen_test.dart:51-55,134-138`. This ruling ratifies that
  choice; it is not new copy.

No design-intent element is lost: both alternates keep the design's actual
informational payload (a numeric notification cap on the `notifs` banner; the
feature name plus the same numeric cap on the `permissions` row) and drop only
the false capability claim.

**Central registry cross-reference:** this ruling also resolves the unlabeled
bootstrap-era entry "D1/Critical-Alerts copy conflict"
(`data/intake/bootstrap/conflicts_open_questions.md:73-85`), which flagged the
same design-source sentence before ADR-002/the guard test existed and
recommended exactly this default direction ("scope this copy out of v1").

## User Stories

| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-062 | Notification Copy ADR-002 Compliance Ruling | trivial | DONE | `data/requirements/REQ-004_notifications_dnd_banner_copy_reconciliation/STORY-062_notification_copy_adr002_compliance_ruling/story_master.md` |

`INTEGRATION_VERIFICATION_REQUIRED: NO` — single story, no cross-story
runtime interaction.
`Integration-Verify: WAIVED — single-story requirement, zero cross-story
runtime interaction; requirement integration review confirmed the merged diff
is byte-identical to the approved story tip (D-1/D-2 in
integration-review/review-report.md), so no separate boot/runtime smoke is
required beyond the reviewer's merge-integrity and build/test verification.`
