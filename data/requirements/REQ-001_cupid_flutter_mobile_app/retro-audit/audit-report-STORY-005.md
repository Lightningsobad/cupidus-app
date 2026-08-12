# Retro Audit Report: STORY-005 Pairing / 1:1 Connection

Story: STORY-005 (Epic-1: Pairing / 1:1 Connection — invitations), Implementation Lane: mobile, Status: DONE
Run Key: 2026-08-12:REQ-001:STORY-005:retro-audit

## Scope Of This Audit

Independent re-verification of current code (not the prior story review's own claims) against
`story_master.md`'s four ACs, Design Fidelity per `req_master.md`'s design intent, and OQ
discipline. Source files read (10, within the 12-file budget): `mobile/lib/core/navigation/app_shell.dart`,
`mobile/lib/core/navigation/pair_gate_shell.dart`, `mobile/lib/app/cupid_app.dart`,
`mobile/lib/features/pairing/data/pairing_repository.dart`,
`mobile/lib/features/pairing/data/pairing_failure.dart`,
`mobile/lib/features/pairing/presentation/pair_gate_cubit.dart`,
`mobile/lib/features/pairing/presentation/screens/invite_screen.dart`,
`mobile/lib/features/pairing/presentation/screens/waiting_screen.dart`,
`mobile/lib/features/pairing/presentation/screens/joincode_screen.dart`,
`backend/src/modules/invitations/invitations.controller.ts`.

Note on drift from the prior review report: the prior `review/review-report.md` (2026-07-30)
describes the pairing gate/stack living inside `app_shell.dart`'s `_PairingStack`. That is no
longer accurate — the code has since been refactored (by a later story, `pair_gate_shell.dart`'s
own doc comment cites STORY-007/STORY-009/STORY-013/STORY-016 changes) so the gate now lives in a
new `core/navigation/pair_gate_shell.dart` (`PairGateShell` / `_PairingStack` / `_AppShellView`),
which hands off to `app_shell.dart`'s `AppShell` only once paired. This is a legitimate downstream
refactor, not a regression: the navigation chain traced below is fully intact in the current file,
just relocated. Flagging so a future auditor does not waste a cycle rediscovering this.

## Substantive Findings - STORY-005

Run Key: 2026-08-12:REQ-001:STORY-005:retro-audit
Story: STORY-005

### AC-by-AC Traceability

| AC | Status | Evidence |
| --- | --- | --- |
| AC1 — generate/send an invitation | PASS | `pairing_repository.dart:31-38` `generateInvitation()` calls `POST /invitations/generate` (backend confirmed live at `invitations.controller.ts:17-34`, auth-guarded). `invite_screen.dart` `_InviteView._share`/`_copy` both call `_copyAndAdvance` (`invite_screen.dart:84-109`), which copies to clipboard, announces, and pushes `WaitingScreen`. Reachable from `pair_gate_shell.dart`'s `_PairingStack._openInvite` (`pair_gate_shell.dart:176-182`), itself reached from the unpaired root. |
| AC2 — invited partner accepts, both sides reflect an active pair | PASS | Invitee path: `joincode_screen.dart` `_JoincodeView` submits via `JoincodeCubit.submit` → `pairing_repository.dart:52-61` `acceptInvitation` (`POST /invitations/accept`, backend confirmed at `invitations.controller.ts:63-73`) → on `JoincodeSuccess`, `_handlePairedOnce` fires `onPaired`, wired in `pair_gate_shell.dart:184-193` to `_onPaired` → `pushAndRemoveUntil(PairedScreen)`. Inviter path: `invite_screen.dart:111-120` `_onWaitingPaired` (wired as `WaitingScreen.onPaired`) also `pushAndRemoveUntil(PairedScreen)` once `WaitingCubit`/poller detects `partnerId != null` (`waiting_screen.dart:61-88`). Both arrival paths converge on the same `PairedScreen`, matching UX §4. |
| AC3 — couple-only enforcement, third invite against an already-paired user rejected in the UI | PASS | `pairing_repository.dart:63-84` `_mapAcceptFailure` classifies all three 409 messages into distinct sealed types (`AlreadyPairedFailure`, `SelfInviteFailure`, `InviterAlreadyPairedFailure` in `pairing_failure.dart:13-44`), matching UX §5's table verbatim, including the specific "This person is already paired with a partner" case that is AC3's literal couple-only scenario. `joincode_screen.dart:89-91,121-132` renders the mapped failure as an inline `errorText` tied to the code field (never a raw backend string), re-enables the button, no modal. |
| AC4 — paired vs. unpaired state visually distinguishable, gates paired-only features | PASS | `pair_gate_cubit.dart` emits `PairGateChecking`/`PairGateUnpaired`/`PairGatePaired` from a single `GET /users/me` read, with a failed check defaulting to `PairGateUnpaired` (never granting access on ambiguity, `pair_gate_cubit.dart:52-61`). `pair_gate_shell.dart:120-138` `_AppShellView` switches on that state: unpaired routes to `_PairingStack` (`NO_TABS`), paired routes to `AppShell` (the tab shell), checking shows a bare spinner — no paired-only surface is reachable pre-pairing. |

### Design Fidelity

`data/devops/system/design-fidelity-config.json` names a locked `design_source`
(`cupid-app-design-system`) and `ui_surface: true`; this story's lane is `mobile`, so Design
Fidelity is in scope per the retro-audit rules, independent of what the prior story-level review
concluded under rule 12g2 (that rule governs story-review gating, not this requirement-authority
retro-audit).

| Screen | Design Reference | Implemented Capture | Result | Deviation |
| --- | --- | --- | --- | --- |
| `invite` | `mobile-visual-audit.md` table, 168 KB reference | 29 KB implemented | UNVERIFIED | Ratio-only (5.7x) — not a full rendered visual comparison per the reused evidence; not reviewed in detail in `mobile-visual-audit.md`'s "Reviewed in detail" section. |
| `joincode` | `mobile-visual-audit.md` table, 154 KB reference | 30 KB implemented | UNVERIFIED | Ratio-only (5.0x) — same limitation as `invite`. |
| `paired` | `mobile-visual-audit.md` table, 220 KB reference | 22 KB implemented | UNVERIFIED | Ratio-only (9.8x, the largest gap in the whole captured set) — same limitation. |
| `waiting` | none | none | UNVERIFIED | Not present anywhere in `mobile-visual-audit.md` (neither the "Reviewed in detail" nor the "Captured, not yet reviewed" table) — no rendered evidence exists for this screen at all. |

No screen in this story has a `MATCH` result. Per the retro-audit's own rule, "a missing render is
not a `PASS`," and PNG-size ratio is explicitly called out as "a weak proxy," not a rendered
comparison — so all four screens are `UNVERIFIED`, not `MATCH` or `FAIL`. This alone forecloses
`GREEN` and `AMBER` for this story (AMBER requires every Design Fidelity row to be `MATCH` or the
section to state fidelity is out of scope, which it is not here).

Separately, `ux/uiux-spec.md` §1 documents that the design source bundles a couple-type picker and
a "Continue → Fingerprint Vow" CTA into the `invite` screen's markup, and the story deliberately
excluded both (no AC covers them, no supporting `invitations` endpoint exists) — flagged to PO in
UX §7 rather than silently dropped. This is a legitimate AC-coverage gap per the retro-audit's own
guidance ("if the requirement demanded a design and the ACs are silent about it, that is itself a
finding, record it as an AC-coverage gap and recommend PO-owned AC correction, not a scope cut") —
not a fidelity defect, since no AC or `req_master.md` line item names couple-type personalization
for this story.

### Open Question Relevance

| OQ | Relevant? | Blocked Scope | Approval/Triage Source | Classification Impact |
| --- | --- | --- | --- | --- |
| OQ4 (offline storage) | No | — | Resolved (ADR-007), not pairing-domain | none |
| OQ5 (light theme / EN locale) | No | — | Deferred to PO at `design_system` breakdown, not pairing-specific | none |
| R8 (Socket.IO auth gap) | No | — | D1 in `master-plan.md` explicitly rejected the realtime-coordinator/socket path for pairing in favor of polling `GET /users/me`, so this story never touches the affected gateway | none |
| D3 unpair/leave absence (story-local, not a central OQ) | Yes | Un-pair/breakup flow | Flagged forward per `story_master.md`'s own "Open Items" instruction and `master-plan.md` §6 — correctly not built and not silently assumed | none (compliant open-item handling, no scope was silently cut) |
| D2 couple-type picker exclusion (story-local, not a central OQ) | Yes | Couple-type picker + "Continue → Fingerprint Vow" CTA on `invite` | `ux/uiux-spec.md` §7 + `master-plan.md` §1 D2 flag this to PO; no central OQ or PO-owned `## Approved Scope Change` was found confirming this exclusion | RED-PATCH-eligible AC-coverage gap (see Design Fidelity note above) — recommend PO-owned AC correction, not a blocker to this story's functional ACs |

### OQ Discipline Findings

- D3 (unpair/leave) and D2 (couple-type picker) were both flagged forward to PO/Tech Lead rather
  than silently built or silently dropped — this is the correct discipline per the retro-audit's
  own rules, even though neither has a formal central-registry OQ id. No existing central OQ
  covers either; recommend Product Owner triage to convert both into tracked OQs or an explicit
  `## Approved Scope Change` if the exclusions are intended to stand permanently.
- No unresolved central Open Question (OQ4, OQ5, R8, D1/Critical-Alerts, Nginx VPS, backend/.git
  history, Firebase service-account key, mobile bundle id) is relevant to this story's pairing
  domain or blocks its ACs.

### Structural Finding — Missing Architecture Artifact

Confirmed independently: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-005_pairing/`
contains exactly three subdirectories — `coding-plan/`, `review/`, `ux/` — and no `architecture/`
directory exists at all (not merely empty; it is entirely absent). No legacy-named architecture
artifact was found elsewhere under the story directory either. The four technical decisions that
would normally live in a dedicated architecture/ADR artifact (D1 poll mechanism, D2 picker
exclusion, D3 unpair absence, D4 hand-constructed body parsing) are instead folded directly into
`coding-plan/master-plan.md` §1, so the *content* of those decisions is present and traceable, but
the *artifact family* itself (`data/requirements/<REQ>/<STORY>/architecture/`) was never produced
for this story. This is a genuine process/artifact-completeness gap, not a content gap — the
decisions are documented and were independently confirmed correct against the current backend
controller (`invitations.controller.ts`, still only `generate`/`accept`/`validate`/two debug GETs,
confirming D3 still holds).

### Implementation Defects Or Unverified Behavior

- None found in the functional navigation/AC-4 code paths (see AC-by-AC table above — all four
  ACs independently verified PASS against current code, not carried over from the prior review's
  claims).
- The only unverified surface is Design Fidelity (see table above): three screens have ratio-only
  evidence and one screen (`waiting`) has no rendered evidence captured at all.

Story-level Substantive Verdict: NEEDS_WORK
Classification Impact: RED-PATCH
REVIEW_COMPLETE: YES
