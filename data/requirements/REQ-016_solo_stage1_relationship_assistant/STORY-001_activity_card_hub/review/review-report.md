# Review Report — STORY-001 (REQ-016) Danh sách việc-cần-làm / Activity Card Hub

Outcome: PATCH_REQUIRED

- Review type: `final-synthesis` (S8 of the 8-pass plan in `review/scope-gate.md` § *Prescribed Slice Plan*)
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Diff baseline (`BaseHead`): `9207f7296a64cd37ca60e432939469ca96860762`
- Reviewed at: 2026-09-08
- Story: `Complexity: complex`, `Story-Class: shared-foundation`, `Implementation Lane: shared (mobile)`
- Acceptance source of truth: `requirements/requirements.md` (AC-1..AC-23)

This report supersedes the earlier `BLOCKED` / `REVIEW_SCOPE_TOO_BROAD` pass. The
slice plan ran to completion: S1–S7 are DONE and their reports are the evidence
base for this verdict. This pass read only the seven slice reports; it re-derived
no gate and re-read no source.

## Slice Verdict Roll-Up

| Pass | Subject | Slice verdict | Blocking finding raised |
|---|---|---|---|
| S1 | P1 local card store (schema, DAO, v2→v3 migration) | PASS_WITH_FINDINGS | none |
| S2 | P2 domain repository + P7 `ActivityType` | PASS_WITH_FINDINGS (2 gate FAILs, classification withheld to S6/S8) | none directly |
| S3 | P3 occasion content package | PASS_WITH_FINDINGS | none |
| S4 | P4 hub list, status buckets, entry point | **FAIL** | S4-F-1 (FLAG-2), S4-F-2 |
| S5 | P5 minute-one empty state + quick capture | PASS with findings | none (F-1 attributed to S4) |
| S6 | P6 detail, lifecycle, delete | **FAIL** | S6-F-1 (FLAG-1, AC-15) |
| S7 | Visual fidelity + runtime/entry-point evidence | **FAIL** | S7-F-1, S7-F-4 |

Four of seven slices found the implementation of their own files correct and
well tested. The story's defects are concentrated in **integration** (nothing
mounts or routes to P5/P6) and in one **contract hole** (no post-creation field
write path). Both flagged items from the scope gate resolved as real violations.

## Cross-Slice Consistency Check

Performed as S8's own work, not inherited. Four apparent conflicts across the
slices were checked and all four resolve:

1. **AC-15: S2 says PASS, S6 says FAIL.** Not a contradiction. S2 verified column
   *purity* — `updateStatus` writes only `status`, proven by a 16-pair matrix
   test. S6 verified the AC's actual `Given/When/Then` through the app: the date
   is never persisted in the first place, so purity is vacuous and the
   no-silent-loss guard cannot fire. **S6's verdict governs**; S2's holds only for
   the column-purity half.
2. **Photos: S2 G3 FAIL vs S6 AC-8 PASS.** Both stand at their own layer. BR-13
   permits this story's UI to leave the photo field unused (S6), while the domain
   model and repository expose no photo member at all (S2-F2-1), which is the
   shared-foundation gap STORY-007 will hit. Routed as deferred, bundled into
   B-2's patch phase per S2's own recommendation.
3. **AC-10 *Tất cả* pane: S1-F-3 open.** Closed by S4 — `ActivityCardPane.all`
   merges four bounded per-status queries and the gate passed. The residual is
   ordering only (S4-F-5, deferred).
4. **FLAG-2 is reported by four slices.** S4-F-1, S5-F-1, S6-F-5 and S7-F-1 are
   one defect observed from four surfaces, each confirmed independently in code.
   **Counted once, as B-1.** S5, S6 and S7 all correctly declined to double-count
   it.

The scope gate's `## Query Keys` AC labels were found wrong by **six consecutive
slices** (S1–S6), each of which verified against `requirements.md` instead and
found the phase files and code comments correct. The gate's AC list is a review
artifact defect, not an implementation defect; no finding is raised against code
for it. Item M-1 below.

## Blocking Findings

Every item here must be closed before this story can be re-reviewed.

### B-1 — FLAG-2 confirmed: the hub mounts neither P5 nor P6 — rule 12e1

**Owner: mobile-dev.** Source: S4-F-1, reconfirmed independently by S5-F-1,
S6-F-5, S7-F-1.

`activity_card_hub_view.dart` imports no P5 widget and no P6 screen and contains
no `Navigator` call. `_EmptyPane` returns an empty `SizedBox` instead of
`MinuteOneEmptyState`; the hub mounts a private, childless `_QuickEntryStrip`
instead of P5's real one; `onPrimaryAction` and the overflow's *Chuyển trạng
thái* / *Sửa* all fall through to `_showComingSoon`. Only delete reaches the
repository.

Consequence: **AC-1, AC-2, AC-3, AC-4, AC-6, AC-7, AC-12, AC-14** and every
detail-screen AC (AC-8, AC-15, AC-16, AC-17) are exercisable only by widget tests
that mount the widget directly. No user arriving from the main menu can reach
them. `test-results.md` files this as a deliberate deferral; that justification
covers only the four genuinely later-story flows (STORY-002 invitation export
etc.), not this story's own criteria.

The patch is integration, not new feature work — P5 and P6 both exist and are
separately tested. Scope: mount `MinuteOneEmptyState` in the `storeCount == 0`
branch, mount the real quick-entry/capture affordance, route
`onPrimaryAction`/overflow to `ActivityCardDetailScreen`.

### B-2 — FLAG-1 confirmed: no post-creation field write path — AC-15 violated

**Owner: mobile-dev (write path) + tech-lead (repository contract).** Source:
S6-F-1, ground truth from S2 §3.

`ActivityCardRepository` exposes exactly four writes: `createCard` (insert-only),
`updateStatus`, `clearScheduledDate`, `deleteCard`. There is no
`setScheduledDate`, no general field writer. Every detail-screen editor routes to
`ActivityCardDetailCubit._edit`, which only `emit`s an in-memory card and issues
zero repository calls — for all eleven editable values including the AC-12
scheduled date.

The store therefore reaches `status = 'scheduled'` with `scheduled_on = NULL`. On
AC-15's ordinary path (schedule today, roll back next week) the date and note are
already gone at dispose, `_needsScheduledDateQuestion` returns false, and the
rollback writes straight through **without keeping the data and without asking**.
Both limbs of AC-15's `then` fail. AC-15 forbids an outcome, not a mechanism.

Two tests certify the defect as intended behaviour, so a green suite is not
evidence here: `card_lifecycle_ui_test.dart:266–278` green-lights the silent
rollback, and `:127–138` is named *"picking a date saves it"* while asserting the
date is not saved. **Both tests must be repaired to assert persistence**, not
just the production path fixed.

The phase record self-classifies this as *"việc phải làm tiếp, không phải
blocker"*. A phase does not grade its own declared risk surface
(`phase-P6-…md:39–41` lists AC-15 as an owned risk), and this review does not
adopt that classification. `master-plan.md` §3A binds AC-15 to P2+P6 jointly and
both shipped inside this story and this diff baseline, so the phase write-scope
boundary is not exculpatory.

Minimum fix: a set-direction writer (`setScheduledDate`, or fold the date into
`updateStatus`) plus the two test repairs. Bundle into the same phase, per S2 §5
and S6 F-2: **S2-F2-1** (photos absent from the contract), **S2-F2-3** (silent
ownership-mismatch writes), **S4-F-4 / S6-F-2** (`invited` / `replyState`
memory-only) and **S6-F-6** (title field desync).

### B-3 — SEQUENCING CONSTRAINT: B-1 and B-2 must land together

Source: S6-F-5. B-1 currently **masks** B-2 — while the detail screen is
unreachable, nobody can observe the date loss. Wiring the route without also
fixing the write path converts a latent defect into a live, user-visible one. Any
patch plan that ships B-1 alone is rejected at the next gate.

### B-4 — three red tests caused by this story, misfiled as inherited debt — rule 12f

**Owner: mobile-dev.** Source: S4-F-2.

`mobile/test/core/navigation/app_shell_test.dart` — 3 tests failing with
`Bad state: … not registered inside GetIt`, because the new solo `unpaired`
branch of `HomeScreen` resolves `getIt<ActivityCardRepository>()`. Filed under
*"Đỏ có sẵn"* on the strength of round 3's own `BaseHead 98e865d`, which already
contained P4 rounds 1–2. Against the story baseline `9207f72` the claim is false:
`test/core/navigation/` was never touched by this story and `home_screen.dart` is
`+162 / −0`, i.e. the whole solo branch and its new dependency are introduced
here. One-line fix, the same repair round 1 already applied to two other test
files. The other two red tests named in that table are correctly routed as
unrelated.

### B-5 — `VISUAL_FIDELITY: FAIL` stands; an in-region delta is unrecorded

**Owner: mobile-dev** (code half closes with B-1; report half is
artifact-only — see M-2). Source: S7-F-1, S7-F-5.

The hub's quick-entry strip renders as three empty grey boxes in r1, r2, r3 and
r4 alike — an in-region visible deviation on the one screen captured from the
built app. `visual-fidelity-report.md` §5 reports it as *"the strip renders its
three cells"*, which is true and materially misleading. Same root cause as B-1.

The head token must stay `FAIL` on this ground alone. Separately, the premise
that D-8 was closed does not hold: **D-8 does not exist in `req_master.md`** —
the Design Ruling Log ends at D-4, and its closing prose still records D-5 as
open while `visual-fidelity-report.md` §3c declares D-5 closed. No reviewer or
Scrum Master should record D-8 as adjudicated.

### B-6 — the occasion package expires 2027-12-24; the second invitation dead-ends after it

**Owner: product-owner (content-horizon decision) + mobile-dev (conditional
render).** Source: S3-F-2, escalated to HIGH by S5-F-2.

`occasions.v1.json` carries two dated instances per occasion; the last date in
the whole package is `2027-12-24`, with no recurrence rule and no refresh path.
From 2027-12-25 `nearestOccasion` returns `null` permanently. The failure is
graceful (neutral SnackBar, nothing crashes, no occasion invented in Dart), but
the invitation card is rendered **unconditionally**, so AC-1 degrades to one
working invitation plus one dead affordance and AC-3 becomes permanently
unsatisfiable. The copy shown is `Sắp có` — the identical string used for
genuinely unbuilt cells, so a data-exhausted feature tells the user it was never
built. This branch has zero test coverage: the one branch the app enters
permanently after 2027-12-24 is the only untested branch in that file.

This is listed as blocking on S5's explicit condition, which S8 verified is
unmet: the deferral holds *only if* a content-refresh owner and a refresh date
before 2027-12-25 are recorded somewhere durable, and no such record exists in
the phase file, `requirements.md`, `req_master.md` or `test-results.md`.
**Cheapest closure is the durable record, not code.** If product-owner records
the owner and date, B-6 downgrades to deferred without a new review pass.

## Decisions Required (rulings, not code findings)

These cannot be closed by mobile-dev and are not counted as blocking findings,
but the patch plan cannot be sized without them.

### R-1 — is a correctly-labelled but inert CTA acceptable under AC-11?

**Owner: product-owner.** Source: S6-F-3. The *Đã hẹn ngày* primary action shows
a SnackBar, *"Phần chuẩn bị nằm ở bước sau."*, justified in code as *"STORY-002
owns preparation."* `requirements.md` `## Out of Scope` L55–56 draws the line
elsewhere: *"Ở story này hành động chính của Đã hẹn ngày là 'chuẩn bị'"* — only
*xuất lời mời* is STORY-002's. AC-11's label table is satisfied and AC-13 still
passes, but one of the four SC-4 primary actions currently does nothing. If PO
rules that *chuẩn bị* needs a real destination in this story, that is additional
scope on top of B-1.

### R-2 — rule 12g runtime startup smoke: required or `NOT_APPLICABLE`?

**Owner: scrum-master + tech-lead.** Source: S7-F-3. **UNVERIFIED — no real-DI
startup evidence exists anywhere in this story.** `test-results.md:391` states
plainly that a real-app-with-full-DI startup was not run; all seven phase files
and `master-plan.md:49` declare `Startup Smoke: NOT_APPLICABLE`, while
`scope-gate.md` lists 12g as a critical gate. What exists instead is the preview
harness (`main_preview.dart`, `PREVIEW_SOLO_HUB_FIXTURE=true`) backed by a
repository whose write methods throw — sufficient to prove the app compiles,
installs and launches on device, insufficient for 12g's actual gate. The
artifact contradiction is unresolved and no slice could resolve it. Note that
B-1's patch changes exactly the wiring 12g would exercise, so this ruling is
best made now and satisfied during the patch round.

## Deferred Findings

Accepted with a named owner. None blocks this story on its own.

| id | Sev | Item | Owner | Note |
|---|---|---|---|---|
| S2-F2-1 | HIGH | Photos absent from `ActivityCard` and the repository; no read/add/remove. STORY-007 has no contract path. | tech-lead | Highest-severity deferred item. **Bundle into B-2's phase.** |
| S1-F-1 | MED | `owner_key` isolation claim broader than the code: `upsertCard`/`upsertPhoto`/`photosForCard` take no `ownerKey`. | mobile-dev | Fix or narrow the three doc comments; low practical exposure (UUID v4 ids). |
| S2-F2-2 | MED | Status writes do not bump `updated_at`, but panes order by it — a just-moved card can rank below older ones. | tech-lead | Pairs with S4-F-5. |
| S2-F2-3 | MED | `updateStatus`/`clearScheduledDate` discard the row count, so an ownership-mismatched write resolves successfully having written nothing. | mobile-dev | **Bundle into B-2's phase.** |
| S2-F2-4 | MED | DI publishes `ActivityCardDao` beside the repository, bypassing the "single write door" rule. | mobile-dev | Hardening; no in-story consumer does this. |
| S4-F-3 | MED | Unpaired session renders the couple dashboard for one frame before the solo surface; its side-effect work starts for a user who never sees it. | mobile-dev | Visible contradiction of AC-22's "màn mặc định". **Fold into B-1** — same file. |
| S6-F-2 / S4-F-4 | MED | `invited` and `replyState` are memory-only, lost on dispose. | mobile-dev | Real user-facing loss but **no AC requires persistence** (AC-17/AC-18 are constraint-shaped and both hold). **Bundle into B-2's phase.** |
| S6-F-4 + S5-F-5 | MED | Write failures are invisible: `state.failed` has no reader, and the capture sheet wedges with no error path. | mobile-dev | Treat as one item; only unhandled failure surface on both paths. |
| S3-F-3 | LOW/MED | `ContentPackage<T>` is a declared shared interface that `contract-summary.md` never records; a STORY-002 author would invent a second one. | tech-lead | Shared-foundation documentation gap. |
| S3-F-4 | LOW | Package validation looser than its own stated policy: dates not format-checked, unknown `activity_type` degrades silently. | tech-lead | R-15's ingest gate is explicitly out of STORY-001 scope; defer to STORY-002. |
| S4-F-5 | LOW | *Tất cả* paging can order cards wrongly across page boundaries (four independently-offset queries). | tech-lead | No AC constrains this ordering; no card lost or duplicated. |
| S4-F-6 | LOW | Preview fixture hard-codes `countsByStatus` to 14 against 4 rows, visible in the `man-goc-muon-lam` capture. | mobile-dev | Fixture bug, not a product defect; S7 correctly excluded it from fidelity findings. |
| S5-F-4 | LOW | Quick-entry strip does not scroll on narrow screens (`uiux-spec.md` §6). | mobile-dev | **Fold into B-1** — the strip is replaced anyway. |
| S2-F2-5 | LOW | Blank title with no usable link host persists as `title = ''`; untested. | mobile-dev | |
| S2-F2-8 | LOW | Repository-level owner-scoping and `countsByStatus`/paging/`watchCardsByStatus` untested; DAO-level isolation is covered by P1. | mobile-dev | Scope observation; not a missed prescribed gate. |
| S6-F-6 | LOW | Title field can desynchronise from the cubit when emptied. | mobile-dev | **Fold into B-2** — becomes a save-the-wrong-thing hazard once a writer exists. |
| S7-F-2 | — | 3 of 4 screens have no built-app capture; the in-test `RepaintBoundary` fallback was used because those screens exist on no route. | — | Fallback accepted as the correct method for an unreachable screen. The unreachability is B-1. |
| S7-F-6 | — | The occasion capture renders widget-test stub strings, so D-12's "read from the package" claim is shown by mechanism, not by shipped content. | mobile-dev | Evidence-quality note. |
| S1-F-4, S1-F-5, S3-F-5, S4-F-7, S4-F-8 | INFO | Migration fixture derived from current schema · `clearOnSignOut` list hand-written · `tet_trung_thu` id/label divergence · three disclosed out-of-write-scope files (proportionate) · AC-13 rationale comment overstates what is wired. | mobile-dev | S4-F-8's comment should be corrected when B-1 lands, at which point it becomes true. |

## Report-Metadata Fixes (no code change)

Tracked separately per the S8 handoff. None of these is an implementation defect
and none blocks on its own, but M-1 and M-2 will corrupt the next review pass if
left in place.

- **M-1 — `review/scope-gate.md` § Query Keys AC labels are wrong for S1–S6.**
  Owner: scrum-master (gate is a review artifact, outside any dev write scope).
  Six consecutive slices verified against `requirements.md` and found the gate's
  ids drifted from `story_master.md` numbering. Re-key before any re-review, or
  the next pass re-derives the same six corrections.
- **M-2 — `visual-fidelity-report.md` delta typing and citations.** Owner:
  mobile-dev. Per S7 §4: `D-14` → `PATCH_REQUIRED` (AC-16 carries no such clause,
  and **AC-11 expressly permits** the overflow the implementation dropped);
  `D-24` → `PATCH_REQUIRED` (AC-8 does list *ảnh/ký ức* and the
  `activity_card_photos` table does exist, so it is not a contract gap);
  `D-18` re-cite AC-13 → AC-11; `D-23` and `D-26` split into label
  (`DESIGN_SPEC_CONFLICT`) + placement (`PATCH_REQUIRED`); `D-16`, `D-21`
  unlabelled → `PATCH_REQUIRED` (deferrable); `D-9`'s `DESIGN_SPEC_CONFLICT`
  label unsupported. `D-15`, `D-17`, `D-19`, `D-20`, `D-22`, `D-25`, `D-27` are
  sound as recorded. Also record the S7-F-1 delta in §5.
- **M-3 — `req_master.md` Design Ruling Log.** Owner: product-owner via
  scrum-master. D-8 does not exist; D-5 is recorded open in the log and closed in
  the fidelity report; D-14..D-27 have no ruling-log entries. Note the live id
  collision: `D-15` in `req_master.md` is the closed OQ-3 content/CMS decision, a
  different namespace from `D-15` the visual delta.
- **M-4 — required evidence sections absent.** Owner: mobile-dev. Neither
  `## Entry Point Reachability` nor `## Story Runtime Startup Smoke` exists in
  any story artifact (S7-F-4); both strings occur only inside `scope-gate.md`'s
  own Query Keys.
- **M-5 — P2 has no evidence section in `test-results.md`,** and
  `phase-P2-card-domain-repository.md` still reads `Status: NOT_STARTED` while
  `master-plan.md` marks P2 `DONE` (S2-F2-6, S2-F2-7). Owner: mobile-dev. The P2
  tests demonstrably exist and pass in later runs; this is an evidence-trail gap,
  not a red suite.
- **M-6 — AC citation drift in code comments, test names and evidence tables.**
  Owner: mobile-dev. S1-F-2 (three comments cite AC-22 for sign-out survival;
  the rule comes from `solution.md` §1/§4 + BR-12), S5-F-3 (two test names and
  one `test-results.md` mapping), S4-F-10 (stale *"Nhà"* tab wording in
  `main_preview.dart` and `phase-P4-…md`, all predating D-1/D-3).

## Unverified Items Carried Forward

- **Rule 12g runtime startup smoke** — no real-entrypoint, full-DI launch
  evidence exists anywhere in this story. See R-2.
- **AC-4's 60-second numeric clause** — structurally well inside budget (two
  interactions, autofocus, no confirm step), but unmeasured and not obtainable
  from a widget test. Low risk; recorded, not charged against the story.
- **Rule 12e3 built-app capture** — satisfied for `man-goc-muon-lam` only; the
  other three screens show that the widget renders correctly, not that a user can
  reach it. Resolves with B-1.

## What Held

Recorded so the patch round does not re-open settled ground. Verified against
code plus named tests in their own slices: the additive v2→v3 migration
(ADR-015.6) with FK cascade and pane index proven behaviourally; R-1b — no
read-receipt, seen, open-count or partner-behaviour field anywhere in schema,
DAO, repository or the four P6 files, enforced by a set-**equality** column test
that fails the build on any addition; SC-1'/AC-21 single card store, asserted by
a `lib/`-wide `@DriftDatabase` scan; sign-out survival of client-owned originals;
shared-contract identifier stability for the 11 downstream stories, pinned by
literal-string assertions; R-7/BR-8 no runtime AI and no external content API,
enforced by an exploding-`HttpClient` zone **with a control test** proving the
override took effect; AC-3 determinism at N=0/1/50 with total ordering; AC-10's
five panes with *Tất cả* as a view rather than a fifth status; AC-11's exactly-one
CTA with the four labels fixed and the other three asserted absent; AC-13 no dead
end (narrowly, via the delete path); AC-14 all twelve ordered transitions; AC-16
undramatic delete; AC-18/AC-19 copy gates. Two gates are recorded as having
caught real violations before their phase closed, which is why this review treats
them as gates that bite rather than gates that decorate.

## State Recommendation

- **Story status: `PATCH_REQUIRED`.**
- Do NOT check `Review (Reviewer)` in `story_master.md`. Do NOT mark the story
  `DONE`; this Outcome is neither `CLEAN` nor `DEFERRED_ONLY`.
- The story branch is **not merge-eligible** into
  `codex/REQ-016_solo_stage1_relationship_assistant-integration`.
- Next action owner: **Scrum Master** — route one patch round to **mobile-dev**
  covering B-1, B-2 (together, per B-3), B-4 and B-5's code half, with the
  bundled deferred items named in each B-item. Obtain R-1 from product-owner and
  R-2 from tech-lead before sizing that round; obtain B-6's durable
  content-horizon record from product-owner or include its conditional render in
  the patch.
- Re-review after the patch should be a **scoped slice**, not a full story
  review: the patch touches `activity_card_hub_view.dart`, the repository
  contract pair, the P6 cubit, `app_shell_test.dart`'s DI helper and two
  lifecycle tests. S1, S3 and the P7 half of S2 need no re-review — nothing in
  the patch plan touches their files.

REVIEW_COMPLETE: YES
