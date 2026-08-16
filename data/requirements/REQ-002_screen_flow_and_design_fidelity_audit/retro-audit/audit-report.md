# Retro Audit Report: REQ-002 Screen flow correction & design fidelity audit

Audit Date: 2026-08-16
Audited By: scrum-master (structural only — see Scope Note)
Trigger: Direct user request: "For every DONE story, decide whether the
RUNNING app was actually compared against the design canvas — not whether
the code reads like the design. Judge from rendered evidence only."
Mode: single-req (narrowed — see Scope Note)

## Scope Note (read before the findings below)

The user asked for exactly one mechanical, per-story check, not the full
retro-review Single-REQ Audit case:

> A Design Fidelity row may read MATCH only when visual-fidelity/ holds
> implemented-\<screen\>-\*.png AND design-reference-\<screen\>-\*.png for the
> SAME screen. Either side missing is UNVERIFIED, and UNVERIFIED is
> RED-PATCH — name the exact capture or canvas export that has to be
> produced.

This is a **Structural Audit** item under `shared-audit-gates.md`'s
design-evidence-pair rule (same-screen file-pair existence on disk), not a
judgment call requiring AC-by-AC code review. Per the user's explicit
instruction ("This audit reports; it does not edit story Status... stop"),
**no `Reviewer: retro-audit` delegation to Iris-QC was run in this pass** —
this report does not attempt a Substantive Reviewer Audit (AC-by-AC
traceability, OQ discipline, code-quality judgment). If a full 32-story
Substantive Reviewer Audit is also wanted, that is a separate, larger
follow-up this report does not cover. Disclosing this so the scoping choice
is visible, not silent.

`data/devops/system/design-fidelity-config.json` confirms REQ-002 is in
scope for the design-evidence-pair rule: `design_source.locked: true`
(Claude Design handoff bundle, `cupid-app-design-system/project`, entry
`Cupid App.dc.html`, screens rendered via `render-design-canvas.js
--screen=<id>`) and `"ui_surface": true`.

Per `req_master.md`, REQ-002 has 33 stories, STORY-001..STORY-033. 32 are
`DONE`; STORY-023 is `DEFERRED` (never shipped) and is excluded from "every
DONE story" — its lone `design-reference-zodiac-android.png` with no
`implemented-*` counterpart is noted for completeness but not scored.

All 32 DONE stories have a `visual-fidelity/` directory. Evidence checked by
listing every file in each directory and matching `implemented-<screen>-*`
against `design-reference-<screen>-*` by the literal `<screen>` token in the
filename (device/platform suffix ignored, as the user's rule specifies
same-screen, not same-device).

## Design Fidelity Evidence Audit (Structural)

| Story | Screen(s) | design-reference-* | implemented-* | Verdict |
|---|---|---|---|---|
| STORY-001 app_launch_entry_routing | launch-login, launch-welcome, splash | present, all 3 | present, all 3 | **MATCH** |
| STORY-002 onboarding_pairing_navigation | pairing_choice | only invite/joincode/profile (different screens) | only pairingchoice | **UNVERIFIED** |
| STORY-003 splash_design_fidelity | splash | present | present | **MATCH** |
| STORY-004 welcome_design_fidelity | welcome | **missing** | **missing** | **UNVERIFIED** |
| STORY-005 login_design_fidelity | login | present | present | **MATCH** |
| STORY-006 register_design_fidelity | register | **missing** | **missing** | **UNVERIFIED** |
| STORY-007 otp_design_fidelity | otp | present | present | **MATCH** |
| STORY-008 forgot_password_design_fidelity | forgot | present | present | **MATCH** |
| STORY-009 permissions_design_fidelity | permissions | present | present | **MATCH** |
| STORY-010 onboarding_profile_design_fidelity | profile | present | present | **MATCH** |
| STORY-011 invite_code_design_fidelity | invite | **missing** | **missing** | **UNVERIFIED** |
| STORY-012 join_code_design_fidelity | joincode | present | present | **MATCH** |
| STORY-013 waiting_pairing_design_fidelity | waiting | present | present | **MATCH** |
| STORY-014 paired_success_design_fidelity | paired | **missing** | **missing** | **UNVERIFIED** |
| STORY-015 love_contract_design_fidelity | contract | **missing** | **missing** | **UNVERIFIED** |
| STORY-016 fingerprint_vow_design_fidelity | vow | present | present | **MATCH** |
| STORY-017 home_dashboard_design_fidelity | home (android+ios) | present, both | present, both | **MATCH** |
| STORY-018 chat_typing_ghost_design_fidelity | chat | **missing** | **missing** | **UNVERIFIED** |
| STORY-019 typing_ghost_settings_design_fidelity | ghostset | present | present (+2 state variants, +1 smoke, all extra) | **MATCH** |
| STORY-020 vibe_check_design_fidelity | vibe | present | present | **MATCH** |
| STORY-021 synced_reminder_design_fidelity | alarm-ringing, alarm-schedule | present, both | present, both | **MATCH** |
| STORY-022 anti_ghosting_settings_design_fidelity | antighost | **missing** | **missing** | **UNVERIFIED** |
| STORY-023 zodiac_red_flag_design_fidelity | zodiac | present | missing | excluded — Status `DEFERRED`, not DONE |
| STORY-024 love_pet_design_fidelity | pet | present | present | **MATCH** |
| STORY-025 love_timeline_design_fidelity | timeline | **missing** | **missing** | **UNVERIFIED** |
| STORY-026 private_gallery_design_fidelity | gallery (galleryOpen state) | **missing** | present | **UNVERIFIED** |
| STORY-027 dream_jar_design_fidelity | jar | present | present | **MATCH** |
| STORY-028 shared_expenses_design_fidelity | expense | **missing** | **missing** | **UNVERIFIED** |
| STORY-029 me_profile_design_fidelity | me | present | present | **MATCH** |
| STORY-030 privacy_my_data_design_fidelity | privacy | present | present (+1 extra) | **MATCH** |
| STORY-031 notifications_design_fidelity | notifs | present | present | **MATCH** |
| STORY-032 design_system_app_shell_follow_up | forgot, vibe, waiting | present, all 3 | present, all 3 | **MATCH** |
| STORY-033 app_shell_design_system_deltas | alarm, notifs, welcome | present, all 3 | present, all 3 | **MATCH** |

Totals: **21 MATCH**, **11 UNVERIFIED**, 1 excluded (STORY-023, not DONE).

## Evidence Gate

Per `shared-verdict-and-plan.md`, an `UNVERIFIED`/`DEVIATION` Design Fidelity
row blocks `GREEN` and `AMBER` classification exactly as a failed AC does.
11 of 32 DONE stories carry an `UNVERIFIED` row above. `GREEN`/`AMBER` are
therefore unavailable; this pushes the requirement to `RED-PATCH` (not
`RED-REDO` — every gap is an evidence-production gap, not an architecture
mismatch; see per-story remediation below).

### Why "code reads like the design" was not accepted as proof

All 11 UNVERIFIED stories' `visual-fidelity-report.md` documents state, in
substance, the same method: the design source's declared CSS/HTML properties
were read and compared textually against the Flutter widget tree / design
tokens in code, with zero rendered screenshots on either side. Examples:

- STORY-004 (welcome): "The design source is the HTML/CSS prototype bundle,
  not a static image, so each declared CSS property... was read literally
  and compared against the rendered Flutter widget tree" — no capture
  either side.
- STORY-014 (paired): rewrote what its own report calls a "placeholder"
  screen (15 deviations found, 14 corrected) with zero visual confirmation
  of the result.
- STORY-015 (contract): "Token Mapping Policy Used" section confirms a
  code/token-based comparison only.
- STORY-025 (timeline) reviewer's own words, round 2 (`review/review-report.md`,
  "Residual risks"): "Unchanged from round 1: no on-device, emulator or
  rendered-PNG capture backs this review. The evidence is source-to-source
  plus widget tests, **consistent with the rest of the REQ-002 wave**." This
  is reviewer-acknowledged confirmation the gap is systemic, not isolated.

None of these are rejected because the underlying code fix is wrong — every
one of the 11 stories' reviews closed `DEFERRED_ONLY` (never `CLEAN`, never
blocked specifically on this gap) and several reviewers state the AC-level
code changes are real and correct. They are rejected under this audit's rule
because the comparison was never made against the *running* app next to the
*rendered* canvas — which is exactly the distinction the user asked this
audit to draw.

Two of the 11 are a different kind of gap — not negligence, but a
design-source/tooling limitation the story's own report already
self-diagnosed:

- **STORY-002** (`pairing_choice`): the report's own Step C investigation
  enumerated all screens available via `render-design-canvas.js
  --list-screens` (37 ids) and confirmed none corresponds to the
  `pairing_choice` state — `invite`/`joincode`/`profile` were each
  considered and rejected with reasoning. The story instead verified against
  AC4's chrome rule and `chain_chrome_guard_test.dart` (18/18 passing). Its
  own investigation additionally surfaced **F-B**: the design canvas encodes
  a *shorter* pairing chain that appears to omit a `pairing_choice`-equivalent
  node entirely — this is a new finding, not currently listed in
  `req_master.md`'s Deferred Follow-Up Items (IF-1..IF-8), and bears
  directly on how STORY-002's gap should be closed (see rework backlog).
- **STORY-026** (`gallery`, `galleryOpen` state): its report header is
  explicit — `Design-Reference-Render: BLOCKED
  (DESIGN_CANVAS_STATE_FORCE_UNSUPPORTED)` — `render-design-canvas.js` has
  no way to force the gallery-open UI state, and the report proposes an
  exact tooling fix (a `--click=<selector>` flag), noting the only
  alternative is "an explicit Scrum Master exemption," which does not exist
  anywhere in `req_master.md`.

The remaining 9 (STORY-004, 006, 011, 014, 015, 018, 022, 025, 028) have no
documented tooling or design-source obstacle — the canvas screen and the
running app both exist and are reachable; the paired capture was simply
never produced.

## Cross-reference: this is a known, already-flagged pattern

`req_master.md` § Deferred Follow-Up Items already carries **IF-7**:
"STORY-004 shipped with no rendered visual-fidelity evidence (PROCESS)...
the direct reason the welcome-screen defects (`BUG-20260816-001`) reached
integration undetected. Argues for enforcing the per-story capture rule
going forward." This audit confirms IF-7's root cause is not isolated to
STORY-004 — it recurs in 10 further stories. IF-8 (a stale claim in
STORY-030's report) is unrelated to this gap (STORY-030 is MATCH — its own
pair exists) and is left as-is.

## Open Question Relevance

Central registry: `data/intake/bootstrap/conflicts_open_questions.md`. Checked
every row by `Blocking` target and by question text, not only OQs cited in
REQ-002's own story artifacts.

| OQ | Status | Relevant To | Blocked Scope | Unblocked Scope | Triage / Approval Source | Classification Impact |
|----|--------|-------------|---------------|-----------------|--------------------------|-----------------------|
| D1 / Critical-Alerts copy conflict (unlabeled OQ, "Decisions Still Needed From The User") | UNRESOLVED | STORY-031_notifications_design_fidelity, by question text (Notifications screen DND-override copy vs ADR-002) | none for REQ-002 itself | — | Already triaged out of REQ-002 into `REQ-003_...`/`REQ-004_notifications_dnd_banner_copy_reconciliation` (req_master.md E-2, user decision 2026-08-16) | none — REQ-002 does not need this OQ resolved to close; tracked in REQ-004 |
| OQ5 — Light theme & EN locale in v1? | UNRESOLVED (deferred to Product Owner at `design_system` story breakdown per its own working assumption) | REQ-002 by question text (all `design-reference-*` captures are dark+vi only) | none — every REQ-002 capture in this audit is dark+vi, consistent with OQ5's working assumption | — | Working assumption in the OQ registry itself; no story-level override found | none — REQ-002's dark+vi-only evidence is consistent with the standing assumption, not a gap it introduces |

No other central-registry row (OQ4 offline storage — resolved, unrelated;
R8 Socket.IO auth gap; VPS/backend-git-folding items; Firebase
service-account rotation; mobile bundle id placeholder) is relevant to
REQ-002 by `Blocking` target or question text.

## Reviewer Delegation Log

| Story | Reviewer Called? | Handoff Type | Result |
|-------|------------------|--------------|--------|
| All 32 DONE stories | NO | — | Out of scope for this pass — see Scope Note. Original story reviews (Iris-QC) already closed all 11 gap stories `DEFERRED_ONLY`; this audit does not re-run or second-guess those AC verdicts, only the design-fidelity evidence-pairing rule. |

## Audit Classification

**Overall Verdict: RED-PATCH**

Justification: 11 of 32 DONE stories have a Design Fidelity row that is
`UNVERIFIED` under the user's binary same-screen-pair rule (2 of the 11 are
tooling/design-source-limited; 9 are a plain missing capture). Per the
Evidence Gate, any `UNVERIFIED` row blocks `GREEN`/`AMBER`. Nothing found
rises to `RED-REDO` — every gap is closable by producing the missing
capture/canvas export (or, for STORY-002/STORY-026, by a PO/UX/tooling
decision plus the resulting capture), not by re-architecting delivered code.

## Recommended Path

Per the user's explicit instruction, this report does not execute the
`RED-PATCH` verdict plan (no hardening stories created, no `Status` field on
any story or on REQ-002 changed). Remediation items are recorded in
`data/retro-audit/rework-backlog.md` (RWB-20260816-001 through
RWB-20260816-011, one per UNVERIFIED story) for the user to action via
`continue retro`.
