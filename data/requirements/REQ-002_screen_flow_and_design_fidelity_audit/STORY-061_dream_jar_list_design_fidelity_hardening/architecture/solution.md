# STORY-061 Dream Jar List (`jarlist`) Design Fidelity Hardening – solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-20

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: RED-PATCH design-fidelity hardening of one screen
  (`jarlist`) plus the shared bottom-tab shell it is captured inside. Every AC
  is verified against a literal design render (AC9), so "the element renders in
  the capture" is the real acceptance signal, not "the capability exists".
- Architectural invariants / non-goals:
  - No new backend field, endpoint, or DTO. Every value AC1-AC5 needs is
    already on `DreamJar` (`currentAmount`, `targetAmount`, `deadline`,
    `status`, `id`).
  - No UI capability may lose its only discoverable entry point (see
    `### Key Discovery`, item 3).
  - Report row 8 (progress amount/percent format) stays untouched — excluded by
    `requirements/requirements.md`'s reconciliation note.
  - Non-goal: a dedicated completed-jars list screen. AC5 is a row, not a
    destination.
- Proposed technical direction: two sequential Mobile phases. P1 rebuilds the
  `jarlist` screen content (cubit active/completed split, summary pill, card
  restructure, copy) — AC1-AC7. P2 converts the shared shell and its preview
  mirror from 3-tabs-plus-FAB to the design's 5 tabs — AC8. AC9 evidence is
  captured by the phase that owns the surface; AC10 is documentation recorded
  in §3 of this file.
- Why this fits the current system: `CupidTabBar` already accepts an arbitrary
  `items` list, `PetScreen` and `MeScreen` already exist as mountable bodies,
  and `CupidIcons.savings` / `.pets` / `.person` are already cmap-confirmed. AC8
  is a wiring change, not new feature scaffolding.

### Key Discovery

Three facts found in the code contradict what the upstream artifacts assume.
All three change the plan.

1. **AC8 is invisible in the AC9 evidence pair unless the preview mirror also
   changes.** `implemented-jarlist-*` captures do not run `AppShell`. They run
   `main_preview.dart`'s `_buildJarlist` inside `PreviewAppShellChrome`
   (`main_preview.dart:180-186` registry entry has `wrapInShell: true`;
   `main_preview.dart:1520-1529` wraps it). `PreviewAppShellChrome`
   (`mobile/lib/preview/preview_app_shell_chrome.dart`) hardcodes its own
   3-item tab list and its own account FAB, and its `activeTab` switch
   (`main_preview.dart:1523-1528`) has no `jarlist` arm, so `jarlist` renders
   today with `currentIndex: -1` — no tab highlighted at all. Editing only
   `app_shell.dart` would satisfy AC8 in production and still produce an
   AC9 capture that fails AC8. `preview_app_shell_chrome.dart` and the
   `activeTab` switch are therefore load-bearing write scope for AC8, not
   optional polish.

2. **AC10's stated fact is false against current code.** `jarlist` is *not* a
   shell tab root today. It is pushed with `MaterialPageRoute` from
   `HomeScreen`'s `DreamJarEntryCard` (`home_screen.dart:179-188`) and appears
   nowhere in `AppShell`. The capture shows no back chevron for a different
   reason than AC10 gives: `CupidHeader` is built with no `onBack` at all
   (`dream_jar_list_screen.dart:68-71`), and the preview harness mounts the
   screen as its own root so there is nothing to pop regardless. AC8 is what
   makes AC10's sentence true — once `jarlist` becomes the "Ví chung" tab body,
   the tab-root path genuinely has nothing to pop. The corrected disposition is
   recorded in §3 and must be used verbatim instead of AC10's original wording.

3. **The design's 5 tabs have no Gallery slot, and the shell tab is Gallery's
   only production entry point.** `GalleryScreen` is referenced from exactly two
   places: `app_shell.dart:19/130/189` and `main_preview.dart`. Replacing the
   3-tab set with Nhà / Trò chuyện / Pet / Ví chung / Tôi deletes the only way a
   user reaches the shipped epic-4 gallery. A design-fidelity story must not
   orphan a feature, so P2 additionally wires a Gallery entry card into the
   existing `HomeScreen` entry-card stack (see §6 option table and the Mobile
   lane guardrail).

4. **The single-jar bypass silently eats AC1 and AC5.**
   `dream_jar_list_screen.dart:59` returns `DreamJarDetailScreen` whenever
   `state.jars.length == 1`. After AC5 splits active from completed, a couple
   with one active jar and any completed jars would hit the bypass and never see
   the summary pill or the completed row. The bypass condition must be rewritten
   to fire only on a genuinely single-jar collection.

## 3. Scope And Assumptions

- In Scope: `jarlist` screen composition and its list cubit's state shape; the
  shared `AppShell` destination set and its preview-harness mirror; the
  `dream_jar_list_title` / `dream_jar_new_jar_cta` ARB values plus new ARB keys
  for the summary pill, deadline row, "Đang xem" badge, and completed row.
- Out Of Scope: backend, `DreamJarDetailScreen`, `_JarCard`'s existing
  amount/percent line (report row 8), a completed-jars destination screen, and
  removing `HomeScreen`'s `DreamJarEntryCard` push once the Ví chung tab exists
  (a second entry point is not a defect; deleting it is Product Owner scope).
- Assumptions affecting design:
  - AC1's totals are the sum of `currentAmount` over **active** jars with the
    **active** jar count. Verified against the design string
    ("7.150.000₫ trong 3 cái hũ") and `main_preview.dart`'s fixture
    (3.900.000 + 2.400.000 + 850.000 = 7.150.000, 3 jars). This is an exact
    match, not an inference.
  - AC4's "Đang xem" is positional (first jar in list order) as UX spec'd.
    Confirmed implementable as a pure read: `_JarListBody` already has `index`
    in `itemBuilder`, so `index == 0` drives the badge and the pink border with
    no new state, no new cubit field, and no persistence. Recorded as an
    accepted fidelity-only simplification — no "currently viewed jar" concept
    exists in this codebase and none is introduced.

### AC10 disposition (documentation-only, no code change)

The absence of a back chevron on `jarlist`'s `CupidHeader` is accepted and
intended, for these verified reasons:

- `dream_jar_list_screen.dart:68-71` constructs `CupidHeader` with a title and
  an empty `actions` list and passes no `onBack`, so no back affordance is
  requested by this screen in any mounting.
- After P2, `jarlist` is the body of the "Ví chung" shell tab — a shell tab
  root, with nothing to pop. This matches RWB-20260816-024's Chrome Rules
  precedent for shell-tab-root screens.
- The AC9 capture is produced by `main_preview.dart`'s preview harness, which
  mounts the screen as its own root inside `PreviewAppShellChrome`. A static
  capture has no pushed route behind it, so no chevron can appear there either.
- `HomeScreen`'s `DreamJarEntryCard` still pushes the screen as a second entry
  point. That pushed instance also shows no chevron, but system back (Android)
  and edge-swipe (iOS `MaterialPageRoute`) remain functional. This is
  pre-existing and unchanged by this story.

No implementation change follows from AC10.

### Decision B4b — duplicate `jarlist` entry point (2026-08-20)

Reviewer finding B4 (`review/review-report.md`): post-P2 `jarlist` has two live
framings — the `Ví chung` tab body (nothing to pop, correctly no chevron) and
`HomeScreen`'s `DreamJarEntryCard` push (`home_screen.dart:180-189`), which is
poppable but still renders no back affordance because `CupidHeader` receives no
`onBack` in either framing. Framing (2) therefore still exhibits DEF-3's
original condition.

**Decision: (c) no change, tracked as a separate item.** Rationale:

- The condition is pre-existing, is not introduced or worsened by this story,
  and is not on the itemized DEF-2 list. `story_master.md` forbids folding in a
  non-itemized deviation without a PO-owned scope decision, and this story has
  already consumed one such extension (the Gallery entry card).
- Option (a) — deleting `DreamJarEntryCard` — is a product/UX call, not a
  technical one. Deciding whether Home should still surface Dream Jar now that
  `Ví chung` exists requires the `home` design reference, which is outside this
  story's `jarlist` scope.
- Option (b) is technically viable but badly timed. B1/B2/B3 are all
  documentation/evidence items that touch no Dart source; folding a code change
  into that pass forces a fresh full regression and probable evidence
  re-capture, immediately after a P2 completion gate that already needed a fresh
  specialist spawn to clear. Poor risk/benefit at this point in the story.

**Guidance for whoever picks this up later.** Prefer passing the back callback
explicitly from each call site (`AppShell` constructs `DreamJarListScreen` with
no back; `HomeScreen`'s push supplies one) over an ambient
`Navigator.of(context).canPop()` test inside the screen. Ambient `canPop()` is
in fact *correct today* — the mount chain is `cupid_app.dart:60`'s
`home: SplashScreen`, then `pushReplacement` into `PairGateShell`
(`splash_screen.dart:125-130`, ADR-5 invariant 2), then `AppShell` built inline,
so stack depth stays 1 and `canPop()` is `false` under the tab. But it couples
shell-tab-root chrome to ambient navigator depth: if any future change up that
chain swaps a `pushReplacement` for a `push`, a back chevron silently appears on
a tab root, reintroducing exactly the DEF-3 confusion this story spent a
disposition explaining. `CupidHeader` already models this correctly — `onBack`
is a nullable `VoidCallback` whose null case means "no back affordance"
(`cupid_header.dart:29`, `:53`) — so the explicit form needs no design-system
change.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile-app` (`mobile/`), Mobile lane only.
- New or changed boundaries: `DreamJarListReady` gains a second jar list
  (completed). `AppShell` becomes a 5-destination shell and stops owning an
  account FAB. `PreviewAppShellChrome` must stay a faithful mirror of
  `AppShell`'s destination set — that mirroring obligation is the new
  cross-file invariant this story introduces.
- Shared patterns reused: `CupidTabBar`'s existing arbitrary-`items` API,
  `context.viEn(...)` inline tab labels, `getIt<T>()` body construction, and the
  build-only-the-selected-destination rule already in `app_shell.dart:184-190`.

### Affected Modules

- Mobile: `features/dream_jar/presentation`, `core/navigation`, `preview`,
  `features/home/presentation`, `l10n/arb`.

### Contracts And Integrations

- `DreamJarListReady` shape change: `jars` narrows from "all non-archived" to
  "active only", and a `completed` list is added. Consequence to handle in P1:
  `_JarCard`'s `DreamJarStatus.completed` / `.archived` `_StatusBadge` branches
  (`dream_jar_list_screen.dart:277-286`) become unreachable for the active list
  and must not be left as misleading dead code.
- Single-jar bypass contract: the bypass at `dream_jar_list_screen.dart:59`
  fires only when the collection is genuinely one jar — one active jar and no
  completed jars. Any other combination renders the full list so AC1 and AC5
  are visible.
- Empty/error/unpaired states (`DreamJarListEmpty`, `DreamJarListFailed`,
  `DreamJarListUnpaired`) are unchanged; the summary pill and completed row do
  not render in them.
- Chat's `isUnlocked` gating stays. With Chat hidden the shell shows 4 tabs, not
  5. That is existing product behavior and is not a design deviation this story
  resolves — the AC9 capture is taken in the unlocked/5-tab state.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Shell destination regression | `mobile/lib/core/navigation/app_shell.dart` | Replace the `chatIndex`/`safeIndex` special-casing with one ordered destination list holding item + body builder, so index math cannot drift as slots appear/disappear | Widget test asserting the destination set and selected body for both `isUnlocked` states, including Home/Chat/Gallery-replacement bodies | Report `MOBILE_VERIFY_REQUIRED`; do not mark AC8 met on the capture alone |
| Gallery entry-point orphaning | `app_shell.dart` (only production reference to `GalleryScreen`) | Wire a Gallery entry card into `HomeScreen`'s existing entry-card stack in the same phase that removes the Gallery tab | Widget test asserting `GalleryScreen` is reachable from `HomeScreen` after the tab set changes | Stop and escalate to Scrum Master; shipping AC8 without this orphans epic-4 |
| Preview/production shell divergence | `mobile/lib/preview/preview_app_shell_chrome.dart` vs `app_shell.dart` | Change both in one phase; add a `jarlist` arm to the `activeTab` switch | Widget test on `PreviewAppShellChrome`'s 5-item set plus the `viChung` active index | AC8 cannot be evidenced by AC9; report `MOBILE_VERIFY_REQUIRED` |
| Summary-pill / completed-row data split | `dream_jar_list_cubit.dart` | One `_fetch()` partition into active / completed / dropped-archived, with the single-jar bypass rewritten against it | Cubit unit tests for: all-active, mixed active+completed, one-active-plus-completed (bypass must NOT fire), single-active-only (bypass fires), all-completed | Report `MOBILE_VERIFY_REQUIRED` |
| Design-reference conformance (AC9) | `jarlist` design render via `render-design-canvas.js --list-screens` | Fresh `implemented-jarlist-*` / `design-reference-jarlist-*` pair covering the ready state, confirmed by content (jar collection, "+ Tạo hũ mới", "Ví chung" tab) not by id match | Mobile visual audit in P2 covering AC1-AC8 against the pair | Story cannot be reviewed; report the exact render/capture failure |

### Lane Handoff

#### Mobile Lane

- Responsibilities: both phases. No backend, frontend, or DevOps work exists in
  this story.
- Authoritative inputs: `../requirements/requirements.md` (AC1-AC10),
  `../ux/uiux-spec.md` (per-AC measurements, copy, tokens), this file.
- Guardrails:
  - Do not add a new `IconData` codepoint. Use `CupidIcons.savings` (Ví chung
    tab, summary-pill badge, per-jar leading glyph), `CupidIcons.pets` (Pet
    tab), `CupidIcons.person` (Tôi tab), and the existing
    `Icons.home_rounded` / `Icons.chat_bubble_outline`. All are already
    cmap-confirmed in `cupid_icons.dart`.
  - Do not use `DreamJarIllustration` as the AC2 card thumbnail. It is a
    `StatefulWidget` holding two `AnimationController`s per instance
    (`dream_jar_illustration.dart:38-45`); one per card in a scrolling list is
    a real cost for a decorative thumbnail. Use UX option (b): a tinted
    circular avatar containing `CupidIcons.savings`. Do not build a new painter
    file in this hardening story.
  - Do not remove the Gallery destination without landing its `HomeScreen`
    entry card in the same phase.
  - Do not touch `_JarCard`'s existing amount/percent `Text`
    (`dream_jar_list_screen.dart:319-325`) or `dream_jar_of` — report row 8 is
    out of scope.
  - Do not change `CupidHeader`, `cupid_tab_bar.dart`, or any backend file.
  - Keep the AC1 summary sentence as one atomic ARB message with `amount` and
    `count` placeholders; do not split it into pre/post-amount fragments.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Move Gallery to a `HomeScreen` entry card, ship the design's exact 5 tabs | AC8 demands the 5-tab shape; Gallery has no other entry point | ACCEPTED | Smallest change that satisfies AC8 without orphaning epic-4. Adds `home_screen.dart` to P2's write scope. Product Owner may override toward a different Gallery home, but not toward deleting its only entry. |
| Keep Gallery as a 6th tab | Zero-risk for epic-4 | REJECTED | Fails AC8 outright — the design bar has exactly 5 destinations, and a 6th slot is precisely the deviation this story exists to remove. |
