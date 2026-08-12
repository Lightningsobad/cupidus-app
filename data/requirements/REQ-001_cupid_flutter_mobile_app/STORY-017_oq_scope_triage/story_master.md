# Story Master: STORY-017 Hardening - OQ/Scope Triage (Retro-Audit RED-PATCH)

Status: DONE
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-001
Retro-Type: RED-PATCH
Fixes: STORY-005, STORY-006, STORY-013, STORY-014, STORY-016 (unapproved
scope-cut traceability) + REQ-001 (requirement-wide AC-coverage gap — no
acceptance criterion in any of the 16 original stories asserts conformance
to the locked design source)
Source: `data/requirements/REQ-001_cupid_flutter_mobile_app/retro-audit/audit-report.md`
(Audit Date 2026-08-12, Overall Verdict RED-PATCH — CONFIRMED, user-confirmed
2026-08-12)

## Depends On
- NONE for this story's own execution. However, the code-fix hardening
  stories deferred pending this story's disposition (STORY-006 partner
  visibility, STORY-008 GhostStateRow mount, STORY-016 privacy/notifications)
  and STORY-018's Design Fidelity scoping both need this story's `DONE`
  output before they can be finalized.

## User Story
As the Product Owner, I need to formally triage the six confirmed unapproved
scope cuts / traceability gaps identified in the REQ-001 retro-audit, and
record each disposition as a dated, sourced `## Open Question Triage` /
`## Approved Scope Change` entry in `req_master.md`, so downstream hardening
work has an authoritative basis instead of the story-level self-approval the
audit found in every one of these six items.

## In Scope
Exactly the six items confirmed unapproved in
`retro-audit/audit-report.md`'s "Overall Substantive Verdict" and "Audit
Classification" sections — no other scope:

1. **STORY-005 D2** — the design source's couple-type picker + "Continue →
   Fingerprint Vow" CTA, deliberately excluded from the `invite` screen
   (flagged in UX §7 / master-plan §1, never centrally triaged).
2. **STORY-006 OQ-006A** — the dual-signature contract ritual reduced to a
   creator-only capability; note the audit found the actual gap is worse
   than documented (AC2 FAIL: partner cannot even *view* the contract, not
   merely "cannot sign it").
3. **STORY-013 Open Item #1** — the shared/backend gallery model vs. the
   design source's "Private Gallery" (device-encrypted, single-partner)
   concept; the story's own UX spec cites the sibling DND/Critical-Alerts
   conflict (which *was* escalated) as the precedent this one should have
   followed and didn't.
4. **STORY-014 wish-list-vs-savings-jar reinterpretation** — AC1-AC3's text
   "dream/wish entry" reinterpreted and shipped as a monetary VND
   savings-jar contribution feature; also resolve the still-open
   epic-4/epic-5 tag question `story_master.md` asked Product Owner to
   reconcile.
5. **STORY-016 AC2/AC3 rescope** — "view and change privacy/notification
   settings exposed by backend contract" (as literally written) shipped as
   privacy view-only (no editable control beyond STORY-008's ghost-mode
   field) and notifications device-local-only (no backend contract at all).
6. **REQ-001 AC-coverage gap** — none of the 16 original stories' 60
   acceptance criteria assert conformance to the locked design source
   (`cupid-app-design-system`), even though `req_master.md`'s own Problem/
   Value section names that design source as the founding intent.

## Out of Scope
- Any code implementation. This story is Product-Owner-owned decision
  recording only.
- The three deferred code-fix hardening stories (STORY-006 partner
  visibility, STORY-008 GhostStateRow mount, STORY-016 privacy/notification
  capability) — explicitly not created yet, pending this story's disposition
  plus STORY-018's Design Fidelity capture results.
- Recapturing or re-auditing any screen — that is STORY-018's scope.
- Any file other than `req_master.md` and, where a disposition requires it,
  the affected story's own `story_master.md` AC section.

## Acceptance Criteria
1. `req_master.md` has a `## Open Question Triage` / `## Approved Scope
   Change` section with one dated, sourced entry for each of the six items
   listed under In Scope. Per the retro-review workflow's RED-PATCH rules,
   each entry must be framed as OQ-aware PO triage / approved AC correction
   — not a plain AC-text edit — and must state: the affected OQ(s), whether
   the ruling is a scope cut or a contract/wording correction, a
   no-further-scope-cut assertion where applicable, and explicit
   source/date.
2. Each entry states the changed AC (verbatim before/after, or "AC text
   unchanged, cut ruled out of scope" if the ruling keeps the AC as written
   and defers the gap to a future code-fix story), the reason, the
   source/date of the ruling, and the exact blocked/unblocked scope.
3. Where the ruling amends an AC's meaning or scope, the affected story's own
   `story_master.md` canonical AC text is updated to match — so a future
   audit does not find the same drift again. Where the ruling requires the
   AC to be built as originally written, the AC text is left unchanged and
   the `req_master.md` entry explicitly flags this as unblocking a future
   code-fix hardening story.
4. The REQ-001 AC-coverage gap entry states whether design-conformance
   acceptance criteria will be added (and to which stories/screens) or
   whether the design-conformance intent is being formally narrowed for
   named screens — with the same changed-AC/reason/source/date discipline as
   the other five entries. This entry must not close the gap by simply
   deleting or reducing the design-source commitment in the Problem/Value
   section; per the retro-review classification guardrails, the requirement
   master outranks story artifacts, so any narrowing must be an explicit,
   justified decision, not an implicit one.
5. No new product scope is invented and no code is changed by this story.

## Downstream Note
This story's `## Open Question Triage` / `## Approved Scope Change`
dispositions are the authoritative input for the three deferred code-fix
hardening stories (STORY-006, STORY-008, STORY-016) and for scoping any
STORY-013/STORY-014/STORY-005 follow-up work. Do not create those stories
until this story is `DONE` with Reviewer approval.

## Role Completion
- [x] Product Owner — OQ/Scope Triage complete. `req_master.md` `## Open
  Question Triage / Approved Scope Change` (6 dated, sourced entries) and
  `## Design Conformance Acceptance Criterion` added; STORY-014
  `story_master.md` User Story + AC1 corrected to match shipped behavior;
  STORY-005/006/013/016 confirmed to need no AC edit. `PO_COMPLETE`,
  2026-08-12.
- [x] Implementation (Development) — N/A for this story by design: per
  "Out of Scope" above, this story is Product-Owner-owned decision recording
  only, with no code/architecture/verification phase. The Product Owner
  phase above is the sole delivery phase and is complete.
