# Visual Fidelity Report: STORY-050 Contract Clause-Counter Row Disposition

VISUAL_FIDELITY: PASS
Design-Screen: contract

## Scope Of This Report

This is a **single-row confirmation**, not a full-screen fidelity comparison.

Product Owner (`story_master.md`, `## Product Owner Triage (2026-08-18)`,
Disposition 2) and Reviewer (`review/review-report.md`, Outcome:
DEFERRED_ONLY) have already approved this story's substantive disposition:
both findings are **keep-and-exclude** with no code, UX, or architecture
change. That disposition is not reopened, re-litigated, or re-derived here.

What this report adds is the one thing the DONE evidence gate
(`guard-story-done-evidence.sh`, recorded in `story_master.md`
`## DONE Evidence Gate (2026-08-18)`) still required: this story's **own**
`contract`-screen evidence pair, plus a confirmation that the clause-counter
row **CC-1** actually renders the way Disposition 2 describes it. No AC1-style
whole-screen comparison is performed or implied.

## Evidence Pair

| Side | File | Size | Provenance |
|------|------|------|-----------|
| Implementation | `implemented-contract-requesterunsigned-emulator-5560.png` | 405x900 | Reused byte-for-byte from STORY-049. `shasum -a 256` = `afc5dd76cfff33b20e5c9a4e6c28e0f3ed6c193e7c52ade6cf2d539eaf959a8a` on both copies. |
| Design reference | `design-reference-contract-myunsigned-android.png` | 406x900 | Reused byte-for-byte from STORY-049 (which itself reused STORY-039's, and independently re-confirmed the hash against a fresh `render-design-canvas.js` run). `shasum -a 256` = `2acd1045727564cf7ff167fd36e13f3a418c65509be7debc35060ba6498514b3` on all copies. |

Capture conditions are STORY-049's, unchanged: dark theme, `vi` locale, Android
412x915dp design frame vs `emulator-5560` at 1080x2400 @420dpi, `font_scale`
1.0, both sides downscaled to 900 px tall. The capture pipeline is documented in
STORY-049's own report under "How The Implementation Capture Was Produced";
this story did not re-run it, for the reason below.

### Why reuse, not recapture

The handoff allows reuse if the `contract` screen's rendered output is
confirmed unchanged since STORY-049's capture. It is, verified two ways rather
than assumed:

1. `git diff --stat d58da5f..HEAD -- mobile/lib/ cupid-app-design-system/`
   returns **empty**. `d58da5f` is STORY-049's own story commit — the commit
   that carries that capture — and `HEAD` is `3b8ea09`, this story's declared
   `BaseHead`. Every commit between them is documentation-only.
2. `git status --porcelain -- mobile/ cupid-app-design-system/` returns
   **empty**: no uncommitted working-tree change on either side of the
   comparison.

Neither the implementation source nor the design source has moved since the
capture, so a recapture would reproduce the same bytes. Recapturing would also
require rebuilding the preview APK with STORY-049's `requesterUnsigned`
`--dart-define`, which is a compile-time `String.fromEnvironment` — cost with
no evidentiary gain.

## CC-1 Confirmation — clause-counter row (`{n}/20 điều khoản`)

Disposition 2 describes CC-1 as: present in the implementation, absent from the
design source, "kept and re-homed inside the clause-list block (`type.caption` /
`colorTextMuted`)", backing a real 20-clause cap. Each of those four claims is
confirmed below against the stored renders and the shipped source.

### Present in the implementation render — CONFIRMED

`implemented-contract-requesterunsigned-emulator-5560.png` paints
`2/20 điều khoản` as a right-aligned muted caption line, sitting between the
dashed hairline that closes the header block and the first clause row
(`Always tell the truth`). `2` is the fixture's selected-clause count, not a
literal.

### Absent from the design source — CONFIRMED

`design-reference-contract-myunsigned-android.png` paints no counter of any
kind. Its first clause row (`Không giận quá 24 giờ`) begins immediately below
the same header hairline. This absence is the whole of the deviation CC-1
records; it is a design-source omission of an app-only affordance, not a
misrender on either side.

### Positioned inside the clause-list block — CONFIRMED

The row is the **first child of the clause-list block's own `Column`**, not a
sibling floating between blocks. In
`mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`
the block is the `Padding(EdgeInsets.fromLTRB(CupidSpacing.sm, CupidSpacing.sm,
CupidSpacing.sm, CupidSpacing.xs))` at lines 376-382, bounded by `_DashedRule`
at line 375 above and `_DashedRule` at line 449 below. Its `Column` (line 383)
contains, in order:

1. the counter `Align` (lines 386-394) — CC-1,
2. the empty-state hint when `selectedCount == 0` (lines 395-406),
3. the `ClauseToggleRow` list (lines 407-426),
4. the add-clause row (lines 427-445) — STORY-049's D-8, confirmed there as
   the block's last child.

CC-1 and D-8 are therefore the first and last children of the same block, which
is exactly the containment STORY-015's A-1 claimed when it re-homed the row.
The render agrees: the counter is inside the card, above the first clause row,
below the header rule.

### `type.caption` / `colorTextMuted` styling — CONFIRMED

`love_contract_screen.dart:390-392` styles the row
`type.caption.copyWith(color: colors.colorTextMuted)` — both are real
`design_system/` tokens, no hardcoded value, matching the disposition text
verbatim. This is the same token pair the header subtitle (lines 368-370) and
the sign caption (lines 483-485) use, and the render shows the counter at that
same muted weight and size.

Because the row draws from genuine tokens, it is also **not** an instance of
the F-1/F-2/F-3 token-vs-source policy in Disposition 1 — there is no
design-source counterpart to snap against. CC-1 is a structural app-only
element, which is why Disposition 2 deliberately gave it its own id outside the
F-series.

### Backs a real 20-clause cap — CONFIRMED

`mobile/lib/l10n/arb/app_vi.arb` defines
`loveContractClauseCounter` = `{count}/20 điều khoản`, and its `@`-metadata
records the reason: "Selected-clause count against the backend's 20-clause cap
(create-contract.dto.ts ArrayMaxSize)." The `20` traces to a server-enforced
limit, corroborating Disposition 2's finding that the row is functional product
information rather than decoration — the basis for keeping it rather than
removing it for pixel parity.

## Result

CC-1 renders exactly as `## Product Owner Triage (2026-08-18)` Disposition 2
describes it. No delta between the approved disposition and the shipped render.
The row remains **excluded** from STORY-015/STORY-039 AC1 fidelity comparisons
and is deliberately not "fixed".

No source file was modified by this story. `mobile/lib/features/love_contracts/`
is untouched; STORY-049's and STORY-039's `visual-fidelity/` directories were
read but not written.

## Verification State

Run in this session against the working tree at `BaseHead` `3b8ea09`, from
`/Users/alantravala/workspace/snapsofts/cupid-apps/mobile`:

- `flutter analyze --no-pub lib test` → `80 issues found`, all `info`, all
  pre-existing; zero errors, zero warnings. Identical to STORY-049's recorded
  run. Exit code is 1, which is `flutter analyze`'s normal result whenever any
  issue exists including `info`-level ones — not a failure signal here, since
  the issue set is unchanged from the baseline.
- `flutter test --no-pub` (full suite) → `+1285 ~2: All tests passed!`, exit 0.
  1285 passed, 2 skipped, 0 failures. Identical to STORY-049's recorded run.
- Flutter 3.44.1 stable / Dart 3.12.1.

Both results match STORY-049's post-rework numbers exactly, which is the
expected outcome for a story that changes no source: the verification is
evidence that this story introduced no regression, not a new build result.

VISUAL_FIDELITY: PASS
