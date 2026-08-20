# Phase P1 – `jarlist` screen composition fidelity (AC1-AC7)

## 1. Objective

Rebuild the Dream Jar list ready state so it matches the `jarlist` design
reference: summary pill, restructured jar cards with illustration/glyph/deadline/
"Đang xem" badge, a completed-jars row, and the corrected title and CTA copy.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-jarlist-screen-fidelity.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/dream_jar/presentation/dream_jar_list_cubit.dart`
  - `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart`
  - `mobile/lib/l10n/arb/app_vi.arb`
  - `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/test/features/dream_jar/` (list cubit + list screen tests)
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Risk Surfaces:
  - Summary-pill / completed-row data split
  - Design-reference conformance (AC9)
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §3, §4
  - per-AC measurements, tokens, and copy: `../ux/uiux-spec.md` §2-§6, §8
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC1-AC7
  - architecture: `../architecture/solution.md` §3 assumptions, §4 contracts and
    Mobile lane guardrails
  - UX constraints: `../ux/uiux-spec.md` §2 (pill), §3-§5 (card), §6 (completed
    row), §8 (copy)
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one screen's ready-state composition plus the single cubit
    partition it reads from
  - Source/Test File Count: 4 source + 2 test
  - Split Required: NO
  - Split Rationale: AC1-AC7 are one behavior cluster and all non-ARB edits land
    in `dream_jar_list_screen.dart`; splitting would split one file across
    phases.

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md` §2-§6 and §8

## 3. Tasks

1. **Cubit partition (shared basis for AC1 and AC5).** In
   `DreamJarListCubit._fetch()`, partition the fetched jars into active
   (`DreamJarStatus.active`) and completed (`DreamJarStatus.completed`), still
   dropping `archived`. Carry both on `DreamJarListReady` (add a `completed`
   list; keep `jars` as the active list). Emit `DreamJarListEmpty` only when
   both are empty.
2. **Fix the single-jar bypass.** `dream_jar_list_screen.dart:59` currently
   bypasses to `DreamJarDetailScreen` on `state.jars.length == 1`. Narrow it to
   fire only when there is exactly one active jar AND no completed jars, so a
   one-active-jar-plus-completed collection still renders the summary pill and
   the completed row.
3. **AC1 summary pill.** Render a full-width pill between `CupidHeader` and the
   card list: leading tinted circular badge with `CupidIcons.savings`, plus one
   atomic localized sentence with `amount` and `count` placeholders. `amount` is
   `DreamJarAmountFormat.vnd` of the sum of `currentAmount` over active jars;
   `count` is the active jar count. Follow `../ux/uiux-spec.md` §2 for tokens
   and sizing.
4. **AC2/AC3/AC4 card restructure.** In `_JarCard`: add the leading tinted
   circular jar avatar containing `CupidIcons.savings` (not
   `DreamJarIllustration` — see the architecture guardrail), the small inline
   leading glyph beside `jar.name`, and a deadline row rendering `jar.deadline`
   in `dd/MM/yyyy`. Tint rotation is `jar.id.hashCode.abs() % 3` over
   `colorMint` / `colorAccentLilac` / `colorAccentPinkDark` per
   `../ux/uiux-spec.md` §4. Add an `isCurrent` flag driven by `index == 0` in
   `_JarListBody.itemBuilder`; when set, render the "Đang xem" badge and the
   pink border/tint treatment on that card.
5. **AC5 completed-jars row.** Render a "Hũ đã hoàn thành" row after the CTA,
   only when the completed list is non-empty. Presence, copy, and layout only —
   do not build a completed-jars destination screen.
6. **AC6/AC7 copy.** In both ARB files set `dream_jar_list_title` to
   `"Các hũ ước mơ"` and `dream_jar_new_jar_cta` to `"Tạo hũ mới"` (no literal
   `"+"` in the string). Add the leading plus glyph at both `CupidPrimaryButton`
   call sites (`_EmptyJarsView` and `_JarListBody`). Regenerate the l10n
   bindings.
7. **Remove the now-unreachable status badges.** With `jars` narrowed to active
   only, `_JarCard`'s `DreamJarStatus.completed` / `.archived` `_StatusBadge`
   branches can no longer fire. Delete them rather than leaving misleading dead
   code; keep `_StatusBadge` itself if the AC4 badge reuses it.

## 4. Acceptance Criteria

- The ready state renders, in order: header, summary pill, active jar cards,
  "+ Tạo hũ mới" CTA, completed-jars row (when completed jars exist).
- Each active card shows a jar avatar, a leading glyph beside the name, and a
  deadline row; the first card additionally shows "Đang xem" with the pink
  treatment.
- Title reads exactly "Các hũ ước mơ"; the CTA reads exactly "+ Tạo hũ mới".
- One active jar plus one or more completed jars renders the full list, not the
  detail-screen bypass.
- `_JarCard`'s existing amount/percent line and `dream_jar_of` are byte-identical
  to before this phase (report row 8 is out of scope).

## 5. Planned Outputs

- Code: the four source files in Write Scope, plus regenerated
  `mobile/lib/l10n/generated/`
- Notes or evidence: `coding-plan/test-results.md` entry for P1, and an interim
  `implemented-jarlist-ready-*` capture covering AC1-AC7

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `jarlist` screen and its list cubit
- Required levels:
  - unit: `DreamJarListCubit` partition — all-active, mixed active+completed,
    one-active-plus-completed (bypass must NOT fire), single-active-only
    (bypass fires), all-completed, all-archived
  - integration: widget tests on the ready state asserting summary-pill text
    (amount and count), per-card deadline text, "Đang xem" on the first card
    only, completed-row presence/absence, and both copy strings
  - mobile build/type-check/static-analysis: `flutter analyze` and
    `flutter test` for the touched suites
  - visual inspection: interim `implemented-jarlist-ready-*` capture
- Required checks: no new `IconData` codepoint introduced; no edit to
  `_JarCard`'s amount/percent line; `dream_jar_of` unchanged
- Mobile discoverability / navigation integration: unchanged in this phase —
  `HomeScreen`'s `DreamJarEntryCard` remains the entry point until P2
- Required regression or contract coverage: existing Dream Jar list tests must
  pass against the narrowed `DreamJarListReady.jars` meaning; update them to the
  new shape rather than relaxing assertions
- Evidence format: test command output plus the capture path, recorded in
  `coding-plan/test-results.md`
- Requirement mobile visual audit: interim only; the AC9 pair is owned by P2

## 7. Status

- Status: DONE
- Last updated: 2026-08-20
- Evidence: `coding-plan/test-results.md` (Phase P1 section) and
  `visual-fidelity/implemented-jarlist-ready-emulator-5560.png`
- Open item for the review gate: `app_en.arb` carries English values instead of
  the plan's Vietnamese copy, because `en` is a real flag-gated locale — see the
  deviation note in `coding-plan/test-results.md`
