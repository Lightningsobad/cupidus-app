# REQ-016 Requirement Integration Review

This file holds three reviews. The **Round 44 F-I4 closure re-check** below is
the current one and carries the single live `Outcome:` line. The **Round 43
scoped re-review** and the **Round 39 review** are preserved verbatim underneath
it as history; their verdicts are restated inline so only one literal verdict
line exists in this file.

---

# Round 44 — F-I4 closure re-check

Review type: requirement-integration-review (narrow closure re-check)
Requirement: REQ-016_solo_stage1_relationship_assistant
Scope gate: `data/requirements/REQ-016_solo_stage1_relationship_assistant/integration-review/scope-gate.md`
Branch: `codex/REQ-016_solo_stage1_relationship_assistant-integration`
HEAD reviewed: `35723ed206b6a9670e92c0f49f988321deeb5979`
Diff baseline: `893c364954d5e8ed67697fbdb0934c502283c33f`
Reviewed: 2026-09-27
RunId: `RUN-REQ-016_solo_stage1_relationship_assistant-NONE-reviewer-fi4close`

Outcome: DEFERRED_ONLY

## Round 44 — what was in scope

Only the span `893c3649..35723ed2` (1 commit, 1 file, +29/−3): the seam A row and
its "Result on content" narrative in `mobile-visual-audit.md`. This round
adjudicates exactly one question — **is F-I4 closed?** The 14 rows Round 43
recorded PASS or accepted-exclusion (seams B/C/D, F-I2 items 5/6, F-I3 item 7,
the F-M1 architecture and implementation, the accepted 3rd-import deviation,
BUG-20260927-001) are untouched by this diff and stand by reference; they were
not re-scanned.

## Round 44 — verdict rationale

F-I4 is genuinely closed. The seam A `PASS` is backed by four post-fix captures
that I opened, magnified and compared myself rather than reading off the
narrative — the same discipline that produced F-I4 in Round 43. The screenshots
show what the narrative claims, the harness that produced them drives the real
shipped widget tree rather than a mock of the block, and the captures are
provably newer than the F-M1 fix. No new blocking finding. The only residual
items are two evidence-durability notes and the pre-existing deferred set, none
of which block requirement closure.

## Round 44 — verification results

| # | Item | Verdict | Evidence |
|---|---|---|---|
| 1 | WriteScope discipline | **PASS** | `git diff 893c3649..35723ed2 --name-only` returns exactly one path, `integration-review/mobile-visual-audit.md` (+29/−3). No source file touched, no PNG committed into the repo, worktree `git status` clean. |
| 2 | Seam A table row + narrative read in context | **PASS** | `mobile-visual-audit.md:47` now reads `PASS (re-captured at 893c3649 …)`; `:61-100` carries the full re-written narrative. Read in place, not from the handoff's diff summary. |
| 3 | `seamA3` — `Sổ tay` content | **PASS** | Opened and cropped ×3. Muted caption header `Sổ tay` over one surface card with **exactly two** rows: `Sổ tay người yêu` (lilac `menuBook` badge) and `Những gì bạn giỏi` (butter `checklist` badge), each with a trailing chevron, one hairline divider between them. Matches the narrative term for term. |
| 4 | `seamA4` — `Nhật ký` content | **PASS** | Opened and cropped ×3. Caption `Nhật ký`, one card, **one** row `Nhật ký riêng` (mint `lock` badge) + chevron, **no** divider — exactly as claimed. |
| 5 | Parity with `seamC1`'s `_PrivateStorageBlock` | **PASS** | Side-by-side crops of both at the same scale: badge size, corner radius, per-row tint (mint `lock` / lilac `menuBook` / butter `checklist`), row height, type scale, chevron and divider treatment are indistinguishable. The claim of visual identity is accurate, not approximate. |
| 6 | No overflow, clipping or truncation | **PASS** | At 412×915 both blocks sit well inside the card; no ellipsis, no clipped glyph, no RenderFlex artefact. |
| 7 | Vietnamese diacritics | **PASS** | At ×3 magnification every mark is present and correctly placed — `Sổ tay người yêu`, `Những gì bạn giỏi`, `Nhật ký riêng`, `Muốn làm`, `Ý tưởng`. No tofu box anywhere, including the icon glyphs. |
| 8 | AC-21 / SC-1' not regressed | **PASS** | No activity-card content on any non-`Muốn làm` tab in `seamA2`/`seamA3`/`seamA4`; the harness asserts `find.text('Đi biển')` → `findsNothing` per tab (`solo_shell_seam_capture_test.dart:173`). `seamA1` shows `Muốn làm` rendering its own surface unchanged. |
| 9 | `Ý tưởng` placeholder is spec, not a defect | **PASS** | `seamA2` renders `Ý tưởng — sắp có`, the neutral placeholder `ux/uiux-spec.md` §6 prescribes for an unshipped entry point, deliberately retained by `fm1-solo-tabs-solution.md` §2/§6 and tracked as non-blocking OQ-1. Correctly excluded from the failure set. |
| 10 | Captures are genuinely post-fix, not stale | **PASS** | mtimes: `seamA1`–`seamA4` all `2026-09-27T01:23:31–32`, harness `01:20:36`. Commit times: F-M1 fix `3b51172f` `00:50:48`, Round 43 review `893c3649` `01:09:10`, audit update `35723ed2` `01:24:32`. The captures postdate both the fix and the finding, and predate the doc update. Ordering is coherent. |
| 11 | Harness drives the real widget tree, not a mock | **PASS** | `solo_shell_seam_capture_test.dart:126-133` pumps the real `PairGateShell` with a real `PairGateCubit` and `PartnerLink(partnerId: null)` (the REQ-016 solo premise); `:160-165` taps the real `solo_stage_one_tab_bar` by label; `:144-156,169-171` assert the shipped keys `solo_tab_destinations_soTay/nhatKy` and `solo_destination_row_notebook/skill_profile/journal` — the same symbols the Round 43 gate already confirmed as production. Nothing about the block is hand-built. |
| 12 | Capture fidelity to what ships | **PASS** | `:68-79` wraps the tree in `CupidAppBackground` exactly as `cupid_app.dart:87,95` does, and `:42` loads the framework `MaterialIcons` font so `Icons.*` cannot render as false tofu. The known harness traps from Round 43 are handled, not re-introduced. |
| 13 | D-I1 still accurately deferred | **PASS (narrower than described)** | Integration is 340 ahead / 11 behind `main`. `git diff HEAD...main --stat` shows those 11 touch **only** `data/` bookkeeping — `bug_master.md`, `master_bugs_list.md`, `scrum-master-checkpoint.md`. Zero source files diverge, so land-integration carries no code-merge risk. Not materially worse; stays deferred. |

## Round 44 — residual non-blocking notes

- **R44-N1 — audit evidence is machine-local.** The four PNGs live only in
  `/tmp/req016-visual-audit/` and the harness is an out-of-tree scratch file
  (`solo_shell_seam_capture_test.dart:1-2`). Once `/tmp` is cleared the seam A
  `PASS` cannot be reproduced from the repository by another agent or on another
  machine. This is the accepted outcome of the item-9 `/tmp`-only WriteScope
  decision, so it is recorded rather than re-litigated — but the audit's verdict
  is, from here on, a trusted assertion rather than a checkable one.
- **R44-N2 — capture density.** Captures are `pixelRatio: 1` at 412×915
  (`:57`, `:106-107`), not a real 3× device density. That is sufficient for the
  layout, content and diacritic questions F-I4 actually asked, and is consistent
  with every other seam in this audit; it is not evidence about text rendering at
  shipping density. Non-blocking.
- Pre-existing deferred findings D-I1–D-I4 and the accepted pre-existing
  exclusion BUG-20260927-001 carry forward unchanged from Round 43. Their
  presence is why this round is `DEFERRED_ONLY` rather than `CLEAN`; none of them
  blocks requirement closure.

## Round 44 — requirement state recommendation

- F-I4 is **closed**. No blocking finding remains from the integration review.
- `Outcome: DEFERRED_ONLY` satisfies the requirement-integration gate, so
  REQ-016 may be marked `DONE` and `Review (Reviewer)` may be checked.
- Remaining work is the queued land-integration step (D-I1), which this round
  confirms is a `data/`-only catch-up merge with no source divergence.
- No further reviewer round is needed for this requirement.

---

# Round 43 scoped re-review (history — superseded by Round 44 above)

Round 43 verdict: **PATCH_REQUIRED**. Its single blocking finding F-I4 is
verified closed in Round 44 above; its action item 8 landed as `35723ed2` and
item 9 was resolved as the `/tmp`-only decision. Retained below for the record.

Review type: requirement-integration-review (scoped re-review)
Requirement: REQ-016_solo_stage1_relationship_assistant
Scope gate: superseded by the Round 44 scope gate at the same path
Branch: `codex/REQ-016_solo_stage1_relationship_assistant-integration`
HEAD reviewed: `3b51172f2494241b01f96c2378d89fceb9ef9bf9`
Diff baseline: `753d2a863b630ec3629cb1cba898bac1f0e075f8`
Reviewed: 2026-09-27
RunId: `RUN-REQ-016_solo_stage1_relationship_assistant-NONE-reviewer-fm1review`

## Round 43 — what was in scope

Only the span `753d2a86..3b51172f` (4 commits: `0a8f4214`, `c1c538ea`,
`9aadd52f`, `3b51172f`) — 2 source/test files and 4 artifacts. The 9 cross-story
contracts this report already recorded PASS in Round 39 were **not** re-verified;
they stand by reference. F-I1 closed before this baseline and is out of span.

## Round 43 — verdict rationale

Everything that was routed for this round landed, and the code is right. F-I2
items 5 and 6 and F-I3 item 7 are substantively closed; the F-M1 architecture
decision is sound and its implementation is correct, tested, and green. The
patch is required for **evidence only, not for a code change**: the requirement's
blocking cross-screen gate (`mobile-visual-audit.md`) still records seam A as
`FAIL on content`, and the remediation that clears it was never looked at. See
F-I4.

## Round 43 — verification results

| # | Item | Verdict | Evidence |
|---|---|---|---|
| 1 | F-I2 action item 5 — integration build + runtime | **PASS** | `build-runtime-evidence.md` carries `- Build: PASS — …` and `- Runtime/Smoke: PASS — …` in one file under `## Integration Build & Runtime`, satisfying reviewer rule 12g3. Real `assembleLocalDebug` (85.2s, 3 split-ABI APKs) and a real `am start -W` on `emulator-5554` polled to `ResumedActivity`, zero `FATAL EXCEPTION`, clean `force-stop`. `Runtime: NOT_APPLICABLE` was correctly not used. |
| 2 | D-I2 — migration-ladder test evidence | **PASS (closes D-I2)** | `flutter test test/core/database/` = 104/104 at `753d2a86`. `BUG-20260923-001`'s 11 reds do not reproduce; the gap D-I2 recorded is closed by a real green run, not by re-classification. |
| 3 | F-I2 action item 6 — requirement-level mobile visual audit | **PASS as an artifact** | `mobile-visual-audit.md` exists and is substantive: seams 0/A/B/C/D, each with a named capture and a reasoned verdict, plus two run-down false positives (the `Bảng tra ăn khớp` empty body = AC-28 `SizedBox.shrink()`; the `Icons.info_outline` empty square = an unloaded framework font). Not taken on trust — I opened `seamA3-solo-tab-soTay.png` and `seamC1-me-hub-private-storage.png`: seamA3 shows the real `Sổ tay — sắp có` dead end with a persistent tab bar and clean diacritics, seamC1 shows the three `_PrivateStorageBlock` rows with the exact labels the fix reuses. The verdicts match the pixels. |
| 4 | F-M1 was the audit's only new blocking finding | **CONFIRMED** | The audit's other outputs are NOTE-0 (device cold launch hits `_NetworkErrorView`, no local backend — environmental), NOTE-1 (AC-28 blank load window, PO glance), NOTE-2 (a `POST_NOTIFICATIONS` denial at FCM init silently disables the REQ-016 nudge). None is blocking; all three carry forward as deferred. |
| 5 | F-I3 action item 7 — configuration guide | **PASS** | The new `## Local Notifications (evening check-in nudge)` section covers all four items the action item named — init (`:65-67`, lazy, iOS request flags `false` on purpose), iOS permission request (`:95-124`, alert-only), timezone (`:139-165`, `tz.UTC` only, with the reason no `initializeTimeZones()` is needed), and `inexactAllowWhileIdle` with the deliberate absence of `SCHEDULE_EXACT_ALARM`. The stale claim at the old `:120-125` is corrected to name `features/phase_status/` as a second `POST_NOTIFICATIONS` consumer added by this requirement. Reviewer rule 12a satisfied. |
| 6 | F-M1 architecture decision vs AC-17 | **PASS** | `fm1-solo-tabs-solution.md` §1 quotes the two shipped entry-point contracts (`journal_entry_point.dart:96-98`, `context_notebook_entry_point.dart:59-61`) that forbid these screens being a tab or sub-tab, and §2 keeps them route-pushed from a menu block that sits *outside* both screens — the `_PrivateStorageBlock` shape AC-17 already permits. No switcher between the two listed surfaces. The decision also corrects the handoff's own premise (no `Hồ sơ kỹ năng` tab exists) rather than implementing a wrong mapping. |
| 7 | F-M1 architecture decision vs D-3 | **PASS** | The four D-3-locked labels are untouched: `SoloStageOneTab` and `_label` (`home_screen.dart:351-363`) are not in the diff. D-3 required the four-tab bar *and its routes*; this restores the routes without reopening D-3. |
| 8 | Implementation — `Sổ tay`/`Nhật ký` push, never mount | **PASS** | `_tabBody` (`home_screen.dart:368-419`) returns `_SoloDestinationBlock`, whose rows call `openNotebookScreen`/`openSkillProfileScreen`/`openJournalScreen`. No screen is mounted as a tab body. Proven at runtime by the new seam-B test: with the real opener and a registered `ContextNotebookRepository`, the observer records a second pushed route and `solo_stage_one_tab_bar` is `findsNothing` on it. |
| 9 | Implementation — `Muốn làm`, `Ý tưởng`, paired path unchanged | **PASS** | `muonLam` still returns `widget.muonLamBuilder(context)`; `yTuong` still returns `_SoloTabPlaceholder` (the widget is kept, not deleted); `coupleBuilder: _buildCoupleHome` is untouched. The paired-session test passes unchanged. |
| 10 | Implementation — AC-21/SC-1' preserved verbatim for all 4 tabs | **PASS** | `find.text('Đi biển')` → `findsNothing` is asserted for `yTuong`, `soTay` and `nhatKy`, and `findsOneWidget` for `muonLam`. The rewrite unrolled the old loop into four explicit blocks and kept the assertion in every one — coverage is equal to before, not reduced. The destination block is also structurally incapable of listing cards (header + rows only, no counts, no preview, no CTA). |
| 11 | Accepted deviation — 3 new imports, not 2 | **ACCEPTED, independently confirmed** | The three are `context_notebook_entry_point.dart`, `journal_entry_point.dart`, and `lib/l10n/generated/app_l10n.dart`. I checked the third against the constraint's stated purpose rather than the count: the import-boundary rule bans journal/notebook **internals** (`presentation/screens/...`, repository, dao, cubit). A generated app-wide l10n resource is none of those, and it is what lets the block reuse the existing `me_menu_*` keys the architecture doc itself mandated instead of inventing new ones. Not a boundary violation. |
| 12 | Targeted test reruns | **PASS (one accepted exclusion)** | `flutter test test/features/activity_cards/activity_card_hub_view_test.dart --no-pub --reporter compact` → **28/28 `All tests passed!`**, including all three new F-M1 tests. `flutter test test/features/context_notebook/` → one red only, `context_content_gate_test.dart:159` (BR-16). I also ran `test/features/home/ test/features/pairing/presentation/pair_gate_cubit_test.dart` → **58 pass, 1 skipped, 0 failures** (see deferred D-I8 for why). |
| 13 | BR-16 red is pre-existing | **CONFIRMED — not a new finding** | Filed as `BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak`. Verified independently rather than taken from the handoff: `git log -S"Cà phê sáng" -- …/zodiac_shell_resolver.dart` attributes the string to `27700367` (STORY-011 P2), and `git merge-base --is-ancestor 27700367 753d2a86` is true — it predates this review's own baseline. Accepted non-blocking exclusion under reviewer rule 7. |
| 14 | Worktree hygiene | **PASS** | `git status --porcelain` after all test runs shows only this review's own `scope-gate.md`. No other story's `visual-fidelity/` PNGs were rewritten by the mobile test runs. |

## Round 43 — blocking finding

### F-I4 — BLOCKING (evidence, not code): the cross-screen gate still records seam A as FAIL, and the fix was never looked at

`mobile-visual-audit.md` is the requirement-level gate reviewer rule 12g2 keeps
separately blocking before closure. Its seam A line reads, at HEAD:

> `| A | Solo stage-1 shell, all four tabs | widget-test PNG | PASS on shell/consistency; **FAIL on content — see F-M1** |`

That FAIL is the recorded state of the blocking gate. F-M1 has now been fixed in
code, but nothing in the repository re-runs seam A or updates that verdict, so
whether the gate is cleared is currently a code-reading inference rather than an
observation. The governing architecture document asked for exactly this capture
and it was not produced: `fm1-solo-tabs-solution.md` §5.4 specifies capturing
`Sổ tay` and `Nhật ký` with `RepaintBoundary` in the widget test, explicitly "để
đóng lại seam A". No post-fix PNG exists anywhere — `/tmp/req016-visual-audit/`
still holds only the 18 pre-fix captures, and `3b51172f` adds no image.

Why the passing widget tests do not substitute: they assert that keys resolve and
labels are found, which is presence, not appearance. `_SoloDestinationBlock` is a
**new composition** that has never been rendered anywhere — a `SafeArea` +
`Column(mainAxisSize: min)` placed inside the shell's `IndexedStack` beside a
full-height `ActivityCardHubView`. Its placement and sizing in that stack are the
one property no assertion in this diff covers, and seam A is the surface that was
already found broken once.

Scoped honestly: the residual risk is narrow, because the glyph risk is already
retired — `seamC1` shows the same three Vietnamese labels in the same fonts
rendering cleanly, and the row geometry is transcribed from the
`_PrivateStorageBlock` that capture depicts. This is a small, cheap gap, not a
suspicion of breakage. It is blocking only because it is the primary proof of the
changed behaviour on a gate that currently says FAIL, which reviewer rule 12c
does not allow to be recorded as deferred.

Action items:

8. **[mobile-dev]** Capture the `Sổ tay` and `Nhật ký` tab bodies at HEAD
   `3b51172f` with the existing harness
   (`/tmp/req016-visual-audit/solo_shell_seam_capture_test.dart`, already written
   and already run once), **look at them**, and update `mobile-visual-audit.md`
   seam A from `FAIL on content` to its post-fix verdict. Per
   `fm1-solo-tabs-solution.md` §5.4 these are seam-closure images, **not**
   fidelity-gate artifacts: there is no design canvas id for these blocks, so do
   not name them `implemented-*.png` and do not attempt fidelity pairing.
9. **[scrum-master, WriteScope decision]** Decide whether the audit's evidence
   should persist in the repository. All 18 seam PNGs live in
   `/tmp/req016-visual-audit/`, which is machine-local and purgeable; the audit
   flagged this itself and asked for a WriteScope extension it did not have. The
   requirement would close with its blocking visual gate backed by evidence that
   no future reader can open.

## Round 43 — deferred findings and residual risks

- **D-I5 — OQ-1, the `Ý tưởng` tab, is for PO and does not block.** Verified as
  described: no shipped screen maps to `Ý tưởng`, and the idea-generating screens
  (`Gợi ý quà`, `Mồi chuyện`, `trắc nghiệm`) are already solo-reachable through
  the `Muốn làm` quick-entry strip (audit seam B PASS). Keeping `sắp có` there is
  what UX §1/§6 specify for a surface whose owning story has not shipped, so it
  is correct-as-specified rather than a residual piece of F-M1. PO should either
  assign the tab's content to a stage-1 story or record an explicit deferral.
- **D-I6 — BR-16 / `BUG-20260927-001`** stays open and non-blocking; see row 13.
- **D-I7 — audit NOTE-1 and NOTE-2 carry forward.** NOTE-1: `Bảng tra ăn khớp`
  shows a fully blank body while its packs load (AC-28 forbids a spinner) — worth
  a PO glance on a cold read. NOTE-2: if the user denied `POST_NOTIFICATIONS` at
  FCM init, the REQ-016 evening check-in silently writes `markReminded` and stays
  off with no explanation surface.
- **D-I8 — the solo shell's host contract quietly widened; verified safe today.**
  `_tabBody` calls `AppL10n.of(context)` unconditionally, for the `Muốn làm` tab
  too. The architecture doc §3 justified this as "Localizations already used by
  `_label`", but `_label` (`home_screen.dart:352`) uses only
  `Localizations.localeOf`, which any bare `MaterialApp` satisfies, whereas
  `AppL10n.of` needs the app's own delegates registered. So any future test host
  that pumps an unpaired `HomeScreen` without `AppL10n.localizationsDelegates`
  will now throw where it previously rendered. I checked all nine test files that
  construct `HomeScreen` by running the affected suites: `test/features/home/`
  plus `pair_gate_cubit_test.dart` are 58 pass / 1 skipped / 0 failures, so
  nothing is broken now. Recorded so the next host to be added knows the
  requirement exists.
- **D-I9 — the destination-row geometry is duplicated, by choice.** The six
  `_destination*` constants in `home_screen.dart:88-94` are transcribed from
  `me_screen.dart`'s `_PrivateStorageBlock` rather than shared, so the two menu
  surfaces can now drift apart visually. The code says so in a comment and the
  duplication is two call sites, which is the cheaper trade today; noted as the
  thing to revisit if a third menu surface appears.
- **D-I1 (from Round 39) is unchanged and still applies.** The integration branch
  is behind `main`, and the registry table in this branch's `req_master.md` is
  still stale. New corroboration: `BUG-20260927-001` exists in the control
  checkout's `data/bugs/` but not in this worktree's, which is the same drift.
  Sync `main` into the integration branch before the final merge.
- **D-I3 and D-I4 (from Round 39)** are untouched by this span and stay as
  recorded.

## Round 43 — touched risk surfaces and critical gates

| Risk surface | Critical gate | Status |
|---|---|---|
| mobile navigation / discoverability | the four solo tabs reach their shipped screens | **PASS** — 28/28, incl. real-opener seam-B push test |
| mobile interaction | each destination row calls its own opener exactly once | **PASS** — dedicated test asserts the ordered call list |
| requirement closure — build + runtime | `## Integration Build & Runtime` (rule 12g3) | **PASS** — both lines present in one file |
| requirement closure — cross-screen visual | `mobile-visual-audit.md` (rule 12g2) | **FAIL — F-I4**: artifact present and substantive, but seam A still records `FAIL on content` with no post-fix capture |
| persistence / migration ladder | green `test/core/database/` at integration HEAD | **PASS** — 104/104, closes D-I2 |
| setup / configuration documentation | guide matches delivered scope (rule 12a) | **PASS** — F-I3 closed |
| regression — paired path | paired session keeps the couple dashboard | **PASS** — unchanged code, test green |
| import boundary | no journal/notebook internal imported into `home_screen.dart` | **PASS** — all three new imports are public surfaces or generated l10n |

## Round 43 — traceability

- Decision D-3 (`req_master.md:155`) — four-tab bar **and its routes** for the
  solo stage-1 surface: restored, labels untouched.
- AC-17 — the two entry-point contracts quoted in
  `fm1-solo-tabs-solution.md` §1: honoured; nothing mounted as a tab body, no
  switcher between the notebook and skill surfaces.
- AC-21 / SC-1' — single card store on `Muốn làm`: asserted verbatim for all four
  tabs.
- AC-22 positioning intent (D-3 Outcome column) — the destination block is light
  (header + rows), carries no counts, preview, large card or floating CTA.
- Seed scope (`req_master.md:131`) — `Sổ tay người yêu` + `Hồ sơ kỹ năng` are one
  seed, which is why they are two rows of one tab rather than two tabs.
- Prior review (`55ade421`): F-I1 closed pre-baseline; F-I2 items 5/6 and F-I3
  item 7 closed here; the 9 cross-story contracts stand PASS by reference.

## Round 43 — requirement state recommendation

- Requirement status: **`IN_PROGRESS`** — do not mark `DONE` yet.
- Leave `Review (Reviewer)` unchecked.
- Route **action item 8** to mobile-dev. It is a capture-and-update pass with no
  code change; the harness already exists and has been run once before.
- Route **action item 9** to Scrum Master as a WriteScope decision.
- Everything else routed into this round is closed. After item 8 lands, the
  remaining path to closure is a short re-check of seam A only, not another full
  integration review.

---

# Round 39 review (history — superseded by Round 43 above)

Round 39 verdict: **PATCH_REQUIRED**. Its action items 1-4 (F-I1) closed before
this review's baseline; items 5-6 (F-I2) and item 7 (F-I3) are verified closed in
Round 43 above. Retained below for the record.

Review type: requirement-integration-review
Requirement: REQ-016_solo_stage1_relationship_assistant
Scope gate: superseded by the Round 43 scope gate at the same path
Branch: `codex/REQ-016_solo_stage1_relationship_assistant-integration`
HEAD reviewed: `e9519243047baa59a2703496b37912a8b71a5848`
Diff baseline: `eb4898c61427bf78572915ee80459e48ed6b30e3`
Reviewed: 2026-09-26

## Verdict rationale

The 13 story branches integrate cleanly at the level each story was reviewed at:
the Drift ladder, the generated client, DI, the navigation shell and the native
widget host are all mutually consistent (see Cross-story contracts below). The
patch is required for one cross-story data defect that no single story review
could own, plus two requirement-level closure gates that have no evidence yet.

The blocking defect is the one item every story review deferred as
"pre-existing / another story's table": at requirement level there is no other
story to defer it to, and STORY-013 AC-26 names the affected data by name.

## Merged story inventory

| Story | Latest merge commit | Story verdict recorded |
|---|---|---|
| STORY-001 | `4c18bd31` | DEFERRED_ONLY |
| STORY-002 | `844487bc` | DEFERRED_ONLY |
| STORY-003 | `69b36905` | DEFERRED_ONLY |
| STORY-004 | `fa30737f` | DEFERRED_ONLY |
| STORY-005 | `518d2453` | CLEAN |
| STORY-006 | `b58afbe0` | DEFERRED_ONLY |
| STORY-007 | `73cbdbfe` | DEFERRED_ONLY |
| STORY-008 | `e636b303` | DEFERRED_ONLY |
| STORY-009 | `84a3c4b4` | DEFERRED_ONLY |
| STORY-010 | `32f6a085` | DEFERRED_ONLY |
| STORY-011 | `e346e147` | DEFERRED_ONLY |
| STORY-012 | `e9519243` | DEFERRED_ONLY |
| STORY-013 | `ca811a29` | DEFERRED_ONLY |

All 13 carry a passing story-level verdict. No story verdict is reopened here.

## Cross-story contracts verified PASS

| Contract | Evidence | Result |
|---|---|---|
| Drift schema ladder | `mobile/lib/core/database/cupid_database.dart:86,112-167` — `schemaVersion = 10`, one additive step per story version, sibling (not chained) `if`s for the v3/v4/v5 column groups, STORY-013's v7→v9 renumber documented at lines 104-106 | PASS — 19 tables, every table reachable from exactly one `from < N` branch; no two stories claim one version |
| Generated client parity | `cupid_database.g.dart:8665-8687` `allSchemaEntities` lists the same 19 tables + 2 indexes as the `@DriftDatabase` annotation at `cupid_database.dart:48-79` | PASS — codegen is current with the merged table set |
| Foreign-key integrity | `cupid_database.dart:172-174` `beforeOpen` sets `PRAGMA foreign_keys = ON` | PASS |
| DI registration | `service_locator.dart` — 78 registrations, all distinct types; every REQ-016 repository/service/cubit registered once | PASS — no duplicate or conflicting registration across the 13 stories |
| Navigation shell | `pair_gate_shell.dart:84-97,133-147` — one `SessionTerminationListener` + one `ReminderOverlayHost` wrap the gated tree; unpaired branch resolves to solo `HomeScreen` with `_soloPairingStatus` pinned (lines 127-138) | PASS — single mount point, no double-mount from parallel stories |
| Android widget host | `AndroidManifest.xml` receiver `com.snapsofts.cupid.CupidPhaseWidgetProvider` + `@xml/cupid_phase_widget_info`; backup attributes added alongside | PASS |
| Vector drawable validity | `res/drawable/dot_today_bolt.xml` — valid XML, no `--` inside the comment body, single closed path, no hard-coded tint | PASS — the earlier build-breaking form is gone from this branch |
| Notification permission surface | `local_notification_scheduler.dart:19-20` uses `AndroidScheduleMode.inexactAllowWhileIdle`, so no `SCHEDULE_EXACT_ALARM`; manifest diff adds no new `<uses-permission>` | PASS — deliberate inexact scheduling, no undeclared permission |
| Content pack assets | 23 `*.v1.json` under `mobile/assets/data/req016/`, declared as a directory in `pubspec.yaml:104-105` | PASS — directory form covers every story's pack, no per-file omission possible |

## Blocking findings

### F-I1 — BLOCKING: leaving stage 1 does not delete the portrait or the compatibility results (STORY-013 AC-26)

`Stage1WipeRegistry.tables` (`mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart:67-137`) registers **11** tables. The schema holds **14** REQ-016 tables (19 total − 5 server-authoritative caches). Unregistered:

- `portrait_answers` — STORY-009, owner column `ownerKey` (`tables/portrait_answers_table.dart:18`)
- `relationship_labels` — STORY-010, owner column `ownerKey` (`tables/relationship_labels_table.dart:29`)
- `calendar_event_state` — owner column `ownerKey` (`tables/calendar_event_state_table.dart:14`)

Why this is an AC violation, not a style gap:

1. `Stage1WipeService.wipeAll()` iterates **only** `_registry.tables` (`stage1_wipe_service.dart:51-56`). There is no second deletion path for these three tables anywhere in the service.
2. STORY-013 **AC-26** (`STORY-013_graceful_exit_and_return/requirements/requirements.md:248-251`) enumerates what must be deleted and names `chân dung` and `kết quả ăn khớp` explicitly. Those are exactly `portrait_answers` (STORY-009 "Chân dung theo cách BẠN nhìn") and `relationship_labels` (STORY-010 "Bảng tra ăn khớp").
3. **AC-27** (lines 253-255) forbids any residue on the device after the wipe. All three tables are described as device-authoritative in the migration notes (`cupid_database.dart:101-104`) — there is no server copy and no other cleanup path, so the rows simply survive.
4. The registry's own doc comment (lines 47-53) claims completeness and points at the parity test as the tripwire.

Static confirmation that the tripwire is red (no test run needed — the counts are arithmetic): `stage1_wipe_registry_parity_test.dart:52-65` compares `registeredTables()` against `expected` and separately asserts `expect(expected, hasLength(14))`. Registered is 11.

Per reviewer rule 14, exact AC text controls: for `portrait_answers` and `relationship_labels` this is an AC-26 `FAIL`, **not** an open design question. The earlier "needs a cross-story PO/Tech-Lead decision" framing (`STORY-007/review/review-report.md:129-137`, `scrum-master-checkpoint.md:99-105`) was correct at story level and is now resolved by AC-26's own wording for two of the three tables. Only `calendar_event_state` remains genuinely undecided, because AC-26's `trạng thái bộ đếm` does not unambiguously refer to it.

This is NEW evidence relative to the handoff's "confirmed non-blocking" note: the non-blocking finding was scoped per story, and no story review checked the registry against AC-26's enumerated list.

Action items:

1. **[mobile-dev]** Register `portrait_answers` and `relationship_labels` in `Stage1WipeRegistry.tables` using the existing `_ownedBy(...ownerKey)` helper. Both are parentless, so ordering is unconstrained. Mechanical change, ~6 lines.
2. **[product-owner OR tech-lead]** Decide `calendar_event_state`: register it, or add it to `nonReq016Tables()` in the parity test with the one-line reason the test's own comment (lines 35-39) requires. Do not leave it unregistered and unexcluded.
3. **[mobile-dev]** Re-run `flutter test test/features/chapter_closure/stage1_wipe_registry_parity_test.dart` and record the result; after (1)+(2) the `hasLength(14)` assertion and the set comparison must agree.
4. **[mobile-dev]** Re-label the residue evidence in `STORY-013/coding-plan/test-results.md` to cover the newly registered tables, so AC-26/AC-27 coverage names all 14.

### F-I2 — BLOCKING: requirement-level closure gates have no evidence

`data/requirements/REQ-016_solo_stage1_relationship_assistant/integration-review/` held no files before this review, and `req_master.md` records no `Integration-Verify: WAIVED` line.

- Reviewer rule 12g3: the merged branch needs `## Integration Build & Runtime` with both `- Build: PASS — <command + result>` and `- Runtime/Smoke: PASS — <command + result>` in one file. Absent.
- Reviewer rule 12g2: the requirement-level `integration-review/mobile-visual-audit.md` cross-screen check remains separately blocking before closure. Absent.

This is expected at this point in the sequence — the handoff states a separate integration-verification pass follows, and this review is read-only by instruction. It is recorded as blocking because the DONE gate enforces both independently and the requirement cannot close until they exist.

Action items:

5. **[devops or mobile-dev, integration-verification pass]** Produce `## Integration Build & Runtime` in the integration-review directory with a real build command + result and a real app-launch smoke result on the merged branch. `Runtime: NOT_APPLICABLE` is not a pass.
6. **[mobile-dev]** Produce `integration-review/mobile-visual-audit.md` for cross-screen navigation/shell/consistency. Per-story `visual-fidelity/` evidence does not substitute.

### F-I3 — BLOCKING (low severity): configuration guide is incomplete and one statement is now inaccurate

`deployment/configuration-guide.md` documents STORY-012's widget host configuration thoroughly, but the requirement added three dependencies (`pubspec.yaml` diff base..HEAD): `home_widget`, `flutter_local_notifications`, `timezone`. Only `home_widget` is covered.

- No section covers the local-notification setup this requirement introduced: `local_notification_scheduler.dart` initialization (`:65-67`), the iOS permission request path (`:111`), or the `timezone` database usage (`:150-153`, scheduling in `tz.UTC`).
- Lines 120-125 state the three `<uses-permission>` entries predate the requirement and that `POST_NOTIFICATIONS` is "the Android 13+ runtime permission the reminder surface uses, not the widget." The permission does predate REQ-016, but this requirement added a second consumer of it in `features/phase_status/` — the same feature the guide is about. A reader following this guide would conclude no notification setup belongs to REQ-016.

Per reviewer rule 12a, stale or missing setup guidance for delivered scope is `PATCH_REQUIRED`.

Action item:

7. **[devops]** Add a local-notification section (init, iOS permission request, timezone init, the deliberate `inexactAllowWhileIdle` choice and why no `SCHEDULE_EXACT_ALARM` is declared) and correct lines 120-125 to name `features/phase_status/` as a `POST_NOTIFICATIONS` consumer added by this requirement.

## Deferred findings and residual risks

- **D-I1 — integration branch is behind `main` by 20+ commits, and its `req_master.md` registry is stale.** `git merge-base --is-ancestor main HEAD` is false; `main` carries `4882303b`, `b9827099`, `323f4666`, `0d824386`, `4108ac86`, `d7137e1e` and others that never synced in (last sync was `5fba81eb`, before the STORY-011/STORY-012 merges). Consequently this branch's `req_master.md:251-263` still shows STORY-005/007/008/010/011/012/013 as `TODO` while merge-boundary state says all 13 are `MERGE_COMPLETE: true`. The registry table is a mirror, so this is not a code defect — but Scrum Master should sync `main` into the integration branch **before** the final merge so the registry-sync commits already on `main` are not re-conflicted or reverted. Not fixed here: `req_master.md` is outside this review's write scope.
- **D-I2 — the v3→v10 migration ladder has no green migration-test evidence at integration level.** `BUG-20260923-001` tracks 11 reds in `test/core/database/`. The ladder reads correct on inspection (see Cross-story contracts), but the persistence gate's primary proof is owed. The integration-verification pass should confirm these 11 reds are version-number lag only, not a real migration break, before closure.
- **D-I3 — STORY-007 AC-3 wording question** (`ThankYouBlockCubit.resolve()` consumes at `initState` rather than at scroll-into-view) stays open for PO as recorded; not re-litigated, no new evidence found.
- **D-I4 — STORY-013 F2**: the three J13 return destinations all land on `PairGateShell` (`return_screen.dart:67-78`) rather than the three distinct destinations in `ux/uiux-spec.md` §6. Confirmed unchanged on the merged branch; stays deferred per the story review's AC-22 reasoning.
- **Open bugs confirmed still non-blocking for closure**: `BUG-20260907-001`, `BUG-20260908-001`, `BUG-20260923-001` (see D-I2), `BUG-20260923-002`, `BUG-20260924-001`. None of them touches the F-I1 defect, and none was made worse by the integration merges.
- `stage1_wipe_registry_parity_test.dart` is no longer classified as a benign pre-existing red at this level — it is the tripwire for F-I1 and must go green as part of that patch.

## Touched risk surfaces and critical gates

| Risk surface | Critical gate | Status |
|---|---|---|
| persistence/schema/migration | additive monotonic ladder to v10, generated client parity | PASS on inspection; migration-test proof owed (D-I2) |
| data migration/backfill (deletion) | stage-1 wipe deletes everything stage 1 owns (AC-26/AC-27) | **FAIL — F-I1** |
| typed/generated contract | `.g.dart` matches merged table set | PASS |
| runtime/configuration | DI completeness, no conflicting registration | PASS |
| mobile navigation/discoverability | single shell mount, solo entry point | PASS |
| package-dependencies | merged `pubspec.yaml` resolvable, no undeclared platform requirement | PASS |
| operational command / platform build | Android widget receiver + resources, iOS extension contract documented | PASS |
| requirement closure — build + runtime | `## Integration Build & Runtime` | **MISSING — F-I2** |
| requirement closure — cross-screen visual | `mobile-visual-audit.md` | **MISSING — F-I2** |
| setup/configuration documentation | configuration guide matches delivered scope | **STALE — F-I3** |

## Traceability

- Merged stories and merge refs: table above; ground truth is `git-story-boundary.sh status` per the handoff, not `req_master.md` (see D-I1)
- Story review reports: all 13 read for their verdict line; STORY-007 (`:125-149`, `:205-223`) and STORY-013 (`:105-199`) read in detail for the cross-story wipe-registry history
- Requirement artifacts: `req_master.md` (`## User Stories`, `Integration-Verify` query), `scrum-master-checkpoint.md` (`:94-126` open items), `STORY-013/requirements/requirements.md:248-277` (AC-26..AC-32)
- Cross-story source inspected: `cupid_database.dart`, `cupid_database.g.dart` (ranged), `service_locator.dart` (registration query), `pair_gate_shell.dart`, `stage1_wipe_registry.dart`, `stage1_wipe_service.dart` (query), `local_notification_scheduler.dart` (query), 3 table definitions (query), `pubspec.yaml`, `AndroidManifest.xml` diff, `dot_today_bolt.xml`
- Test evidence: `stage1_wipe_registry_parity_test.dart` read in full and evaluated statically; no test was executed by this review (read-only by handoff instruction)
- Configuration: `deployment/configuration-guide.md` read in full (169 lines)

## Requirement state recommendation

- Requirement status: `IN_PROGRESS` — do NOT mark `DONE`
- Route action items 1-4 (F-I1) to the mobile lane, with item 2 needing a PO/Tech-Lead decision first
- Route action items 5-6 (F-I2) to the integration-verification pass already planned
- Route action item 7 (F-I3) to DevOps
- Sync `main` into the integration branch before the final merge (D-I1)
- Re-review scope after the patch: `stage1_wipe_registry.dart`, the parity test result, the configuration guide section, and the two new integration-review evidence files. The nine PASS rows above do not need re-verification unless the patch touches the schema or DI.
