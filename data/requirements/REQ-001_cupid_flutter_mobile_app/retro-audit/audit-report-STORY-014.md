---
audit_type: retro-audit
story: STORY-014_dream_jar
audited_at: 2026-08-12
audited_by: Reviewer (retro-audit)
base_head: f7d06fd4737cc7edbe6f6e33c205bf77fdf26f67
---

# Retro-Audit Report: STORY-014 Epic-4 — Dream Jar / Hũ Ước Mơ Chung

This is an independent re-verification against current `main` (BaseHead
`f7d06fd`). Conclusions are re-derived from direct source/test inspection,
git plumbing, and the OQ registry — prior `review/review-report.md`
conclusions were treated as claims to verify, not facts.

## AC-by-AC Traceability

| AC | Text (as written in `story_master.md`) | Verdict | Evidence |
|----|------------------------------------------|---------|----------|
| AC1 | "A paired user can add a dream/wish entry to the shared jar." | MET (against the re-mapped feature — see wish-list-vs-savings-jar row below) | Direct source read: `create_dream_jar_sheet.dart` (jar creation: name, target amount, optional deadline — no note field, no currency selector, matches declared v1 scope) and `dream_jar_hero_card.dart` (3 fixed VND quick-add presets `[100000, 200000, 500000]`, disabled while `isAddingContribution`, no 4th tile). Both files read in full at current `main` HEAD, not inferred from prose. |
| AC2 | "Both partners can view the jar's contents." | MET | Direct source read: `dream_jar_detail_screen.dart` at current `main` renders `DreamJarHeroCard` plus a `CupidPrimaryButton` that pushes `ContributionHistoryScreen(jarId, repository, currentUserId: null)` — the navigation edge that was the prior review's sole blocking (`PATCH_REQUIRED`) finding is present and wired on `main` today, not just documented as fixed (see "Prior PATCH_REQUIRED" section below). `git ls-files` confirms `dream_jar_list_screen.dart`, `contribution_history_screen.dart`, and `partner_split_card.dart` all exist. |
| AC3 | "Unpaired users cannot access this feature." | MET | Direct source read: `dream_jar_detail_screen.dart`'s `BlocBuilder` has an explicit `DreamJarDetailUnpaired() => const DreamJarUnpairedNotice()` branch, sourced from the backend's `404 "User not found or not paired"` mapped to `DreamJarUnpairedFailure` (per `architecture/solution.md` §4). Reachable only from the Home entry point per P5, so an unpaired user's only path in hits this state. |
| **AC1-AC3 wording vs. reality** | Story text describes a **free-text wish/dream list**; the shipped feature is a **shared monetary savings jar** (name, VND target amount, VND contributions, progress bar) | **Real mismatch, confirmed — and never routed through an authoritative approval channel** | See "Open Question Relevance" and "OQ Discipline Findings" below. This is not a wording nuance: "dream/wish entry" and "add ₫200,000 to a savings goal" are different product concepts. The AC1-AC3 *reinterpretation* (mapping "add a dream/wish entry" onto "add a VND contribution") was authored solely in `architecture/solution.md` (Tech Lead's own artifact) and `coding-plan/master-plan.md` §2 (Tech Lead's own artifact) — both are explicitly non-authoritative per the audit's Open Question / Scope Authority rule. |

## Prior PATCH_REQUIRED Finding — Re-Verified On Current `main`

The story's review history shows an original final-synthesis review with
`Outcome: PATCH_REQUIRED` (1 High finding: `ContributionHistoryScreen`
orphaned, no navigation edge in `mobile/lib`), later closed by a re-review
(`Outcome: DEFERRED_ONLY`) after patch commit `99bbd8e`.

Independently confirmed, not trusted from prose:
- `git merge-base --is-ancestor 99bbd8e main` → **is an ancestor of `main`**
  (the patch commit is actually merged, not just referenced).
- Direct read of `mobile/lib/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart`
  at current `main` HEAD shows the `CupidPrimaryButton` → `Navigator.push(...
  ContributionHistoryScreen(...))` wiring described in the patch is present
  and structurally intact today.
- `currentUserId: null` is passed to `ContributionHistoryScreen`, exactly as
  the patch note describes, and the receiving screen's documented
  `currentUserId == null` handling (generic "Partner" label, not a crash) is
  consistent with `test-results.md` §10's account.

**Conclusion: the prior PATCH_REQUIRED finding's fix is real and effective on
`main`, not merely documented as closed.**

## Design Fidelity (MANDATORY — reused, not recaptured)

Source: `data/requirements/REQ-001_cupid_flutter_mobile_app/integration-review/mobile-visual-audit.md`
(first-pass audit, 10 of 37 design screens captured: `alarm`, `antighost`,
`gallery`, `home`, `invite`, `joincode`, `paired`, `pet`, `privacy`, `vibe`).

**`dream_jar` is not among the 10 captured screens.**

| Screen | Design Fidelity Verdict | Basis |
|--------|--------------------------|-------|
| Dream Jar (jar list / jar detail / create sheet / contribution history) | **UNVERIFIED** | Not captured in the only visual-fidelity audit that exists for REQ-001. A missing render is not a PASS per the explicit audit instruction. No other visual-fidelity artifact exists for this story (`story_master.md` records no `visual-fidelity/` output). |

Per the mandatory rule, this UNVERIFIED row **blocks GREEN/AMBER classification
for this story exactly like a failed AC**, independent of how strong the
functional AC evidence above is.

Note for context only (does not change the verdict): `data/devops/system/design-fidelity-config.json`
shows the locked `claude-design` source was fingerprinted 2026-08-11, i.e.
after STORY-014 implementation (2026-07-30/31) and after the requirement was
marked DONE/deployed (2026-08-01). Per `mobile-visual-audit.md`'s own
guidance, any future Dream Jar capture must be checked against the design as
it stood at implementation time, not current drift, before treating a delta
as a story regression.

## Open Question Relevance

| OQ / Flag | Where Raised | Authoritative? | Status |
|-----------|--------------|-----------------|--------|
| R3 (libsodium FFI / local encryption) | `architecture/solution.md` §3 Open Question Constraints, citing `req_master.md` risk table | Architecture doc is not itself authoritative for scope, but this is a **technical** resolution (no client-side encryption needed) within Tech Lead's own remit, not a scope/AC reinterpretation — legitimate for Tech Lead to close. | Resolved for this story; not an OQ-discipline problem. |
| UX §0.1 "wish list vs. savings jar" AC reinterpretation | `architecture/solution.md` §3, `coding-plan/master-plan.md` §2, `story_master.md` "Open Items For Downstream Roles" | **NOT authoritative.** This is a scope/AC-meaning reinterpretation, which per the audit's Scope Authority rule requires a central OQ registry row, a `req_master.md` `## Open Question Triage` / `## Approved Scope Change` section, or an explicit user decision. None of those exist for this item. | **Unresolved / improperly routed** — see OQ Discipline Findings. |
| 4th custom-amount tile, `note` field, edit/archive/delete, multi-currency, "show archived" toggle | `architecture/solution.md` §3 Out Of Scope, `coding-plan/master-plan.md` §6 | Deferral-of-functionality decisions, made by Tech Lead citing "awaiting Product Owner confirmation" — these are scope *cuts*, also requiring the same authoritative approval and also not found in any OQ registry or `req_master.md` triage section. | **Unresolved / improperly routed**, though lower severity — see below. |

## OQ Discipline Findings

1. **The wish-list-vs-savings-jar AC reinterpretation was never triaged
   through an authoritative source.** I read `data/intake/bootstrap/conflicts_open_questions.md`
   in full (158 lines) and `req_master.md` in full (166 lines): neither
   contains any entry, `## Open Question Triage` section, or
   `## Approved Scope Change` section referencing STORY-014, Dream Jar, the
   wish-list/savings-jar mismatch, or the epic-4/epic-5 tag question. The
   only "approval" for reinterpreting AC1-AC3 onto a monetary feature lives
   in Tech Lead's own `architecture/solution.md` and `coding-plan/master-plan.md`
   — both downstream artifacts the audit rule explicitly excludes as approval
   sources. Tech Lead did flag it "to Product Owner" inside `story_master.md`'s
   "Open Items For Downstream Roles," but flagging is not the same as
   approval, and no Product Owner action is recorded anywhere.
2. **The flagged correction was never made, even after the requirement went
   DONE and was deployed.** `req_master.md`'s STORY-014 row (line 163) still
   reads "Epic-4: Dream Jar / hũ ước mơ chung" — the epic-4/epic-5 tag
   question `story_master.md` asked Product Owner to reconcile is still open.
   `story_master.md`'s User Story and AC text (lines 16-31) are still the
   original "wish/dream entry" wording, uncorrected. REQ-001 is now `Status:
   DONE`, deployed to Development (2026-08-01), and requirement integration
   review is `Outcome: CLEAN` — meaning this uncorrected AC/reality mismatch
   passed through every downstream gate (story DONE, requirement DONE,
   deployment) without ever being resolved by an authoritative decision.
3. **The v1 deferrals (4th tile, note field, edit/archive/delete,
   multi-currency, archived toggle) are real scope cuts made the same way** —
   Tech Lead's own architecture doc, citing "awaiting Product Owner," with no
   OQ-registry or `req_master.md` trace. Functionally these are honestly
   documented and consistently enforced (`test-results.md` §7 verifies none
   of them leaked into the build), so there is no hidden functionality gap —
   but the *process* by which they were authorized is the same discipline
   gap as finding 1, just lower-stakes because AC1-AC3 do not literally
   require them.
4. **Not a new finding, but worth surfacing for whoever owns the follow-up:**
   `architecture/solution.md` §5 and `master-plan.md` §6 both flag that the
   Privacy/"My data" screen still incorrectly claims Dream Jar is Level 2
   (end-to-end encrypted) when it is actually Level 3 (server-side only,
   ADR-014a). This audit did not re-verify the Privacy screen directly (out
   of STORY-014's own write scope and not requested by this handoff), but
   flags that this correction — like the AC wording — was never confirmed as
   done by an authoritative source in the artifacts read for this audit.

## Deferred Findings (carried from the re-review, re-checked for currency)

The three Low findings the last review report deferred are still present on
`main` and still non-blocking against AC1-AC3:
- `DreamJarDetailLoaded.copyWith` doesn't preserve `contributionFailure` by
  default (no live bug — every call site passes it explicitly).
- Repository failure-mapping tests only directly exercise `fetchJars`/`fetchJar`.
- List-screen → create-sheet CTA has no direct navigation-assertion test.

None of these affect the audit's Substantive Verdict; they remain accurately
described as non-blocking maintenance notes.

## Story-level Substantive Verdict: NEEDS_WORK

Rationale: AC1-AC3 are functionally implemented and independently verified
against current `main` with direct source inspection, and the prior
PATCH_REQUIRED finding's fix is confirmed real and merged — the mobile
implementation itself is solid. But two governance gaps keep this from
CLEAN: (1) the AC1-AC3 reinterpretation from "wish list" to "monetary
savings jar" — a real, material scope/meaning change — was authorized only
by Tech Lead's own downstream artifacts, never by an authoritative OQ
registry entry, `req_master.md` triage section, or explicit user decision,
and the flagged Product Owner correction was never made even after the
requirement reached DONE/deployed; (2) Design Fidelity for every Dream Jar
screen is UNVERIFIED — never captured in the one visual-fidelity audit that
exists for this requirement. Neither gap is a proven functional defect, but
both are exactly the kind of unresolved-approval and unverified-evidence
gaps this audit exists to catch.

## Classification Impact: RED-PATCH

The Design Fidelity UNVERIFIED status blocks GREEN/AMBER by the audit's own
mandatory rule, independent of the strong functional AC evidence. Combined
with the unresolved OQ-discipline gap on the AC reinterpretation, RED-PATCH
is the correct classification pending: (a) Product Owner or an authoritative
OQ-registry/`req_master.md` decision on the wish-list-vs-savings-jar wording
and the epic-4/epic-5 tag, and (b) a Dream Jar capture added to the mobile
visual-fidelity audit (checked against the design as it stood at
2026-07-30/31, per `mobile-visual-audit.md`'s own drift-vs-regression
guidance).

REVIEW_COMPLETE: YES
