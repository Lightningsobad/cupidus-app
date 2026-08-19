# STORY-059 UX Spec: CupidHeader Action-Slot FAB Sizing Hardening

Scope: `CupidAddAction` inside `CupidHeader.actions` on the Material
silhouette, single confirmed call site
`mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart:68-82`.

## Correction to prior pass

My first pass wrongly claimed `cupid-mobile-design/` does not exist anywhere
in the repo. It exists under a different path:
`cupid-app-design-system/project/Cupid Screens.dc.html` (2483 lines). I have
now opened it and read the relevant blocks directly. That false access-gap
framing is withdrawn. The finding below is a revision driven by what the
literal file actually shows, not the secondary-evidence chain my first pass
relied on.

## What the literal design source actually shows

Two blocks are directly relevant, both read in full from
`cupid-app-design-system/project/Cupid Screens.dc.html`:

1. **The shared header block** (`showHeader`, lines 49-64) — used by every
   screen that has chrome, including `jarlist`. It renders exactly three
   things: an optional back chevron (`canBack`), the title text, and an
   optional trailing partner-presence chip (`showPartnerChip`). There is no
   icon-action slot of any kind in this template — no "add", no trailing
   icon button, nothing besides the partner chip.
2. **The `isJarList` canvas block** (lines 889-930) — the Jar List screen's
   own body. Its "create a new jar" affordance is a full-width, 54px-tall
   pill CTA at line 923, sitting in the scrollable content *after* the jar
   cards: `background:var(--grad-hot)`, `add` glyph + `"Tạo hũ mới"`/`"New
   jar"` label, pill radius, glow shadow (`box-shadow:var(--glow)`). This is
   the same full-width primary-CTA pattern already implemented app-wide as
   `CupidPrimaryButton` (STORY-055 D-2 added exactly this leading-icon
   capability to that shared widget). There is no icon-only FAB anywhere in
   this block, and nothing rendered inside the header region.

So: the design source has **no header-hosted "add" action for the Jar List
screen at all**, in either literal form. The 60x60 Material FAB spec cited in
`cupid_add_action.dart:9-16` (`Cupid Screens.dc.html` line 881, the `isMD`
add-action block) is real, but the source markup at that line renders as a
floating overlay, not inside `showHeader` — consistent with its two other
real call sites (`expense_history_screen.dart`, `Scaffold.floatingActionButton`;
`gallery_empty_view.dart`, a shrink-wrapping `Column`).

## Cross-check against the current implementation — the fix already exists

`dream_jar_list_screen.dart` already implements the literal `isJarList`
bottom CTA correctly, independent of the header:

- `DreamJarListReady` → `_JarListBody` (lines 208-253): a pinned
  `CupidPrimaryButton` with label `dream_jar_new_jar_cta`, calling
  `_openCreateSheet`, as the list's last item (lines 228-234) — matches
  line 923 of the design source.
- `DreamJarListEmpty` → `_EmptyJarsView` (lines 161-206): a centered
  `CupidPrimaryButton`, same label, same `_openCreateSheet` call
  (lines 197-200) — matches `ux/uiux-spec.md` §1.5's own extrapolated
  empty-state spec ("single prominent 'Tạo Dream Jar mới' CTA"), written
  before a literal `jarlist` canvas block was available.

Both states that show the header's `CupidAddAction`
(`DreamJarListEmpty() || DreamJarListReady()`, `dream_jar_list_screen.dart:71`)
**already have a complete, correctly styled, already-wired duplicate of the
same action** in the body. The header icon is not a smaller/alternate
rendering of the design's CTA — it is a second, fully redundant entry point
to the identical `_openCreateSheet` call, present in neither literal design
block.

## Decision (revised)

**Primary, design-conformant fix: remove `CupidAddAction` from
`CupidHeader.actions` at this call site** (`dream_jar_list_screen.dart:70-81`,
both switch arms), leaving `actions: const <Widget>[]`. This is not "define a
smaller variant" or "raise the toolbar band" — it is recognizing the header
slot itself has no basis in the design source and deleting the duplicate,
which:

- Makes the header render exactly what `showHeader` specifies (back + title
  only, no trailing icon) — full literal design conformance, not an
  approximation.
- Leaves the screen's actual create-jar affordance exactly where and how the
  design shows it — the existing, unmodified, already-correct
  `CupidPrimaryButton` CTA in both states.
- Eliminates the clamping bug at its root: no >56pt element ever enters
  `CupidHeader.actions` here again, so there is nothing left to clamp or
  resize.
- Requires no new size, no new component variant, and touches neither
  `cupid_add_action.dart` nor any behavior of `CupidAddAction` anywhere else
  (AC3's protection of its intrinsic 60x60 contract holds trivially).

**Scope-boundary flag for Scrum Master/Tech Lead:** this fix edits
`mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart`,
a screen file. `story_master.md`'s "Implementation Lane" and the rework
item's routing describe this story's write scope as `cupid_header.dart`
(and/or `cupid_add_action.dart`), design-system lane only — it does not name
the screen file. I am not authorized to expand write scope myself; this is a
scope decision for Scrum Master. I raise it because it is the fix the
literal design reference actually supports, and the handoff explicitly
invited "another design-conformant option if the design reference supports
it." If the screen file is kept out of this story's scope for procedural
reasons, see the fallback below.

**AC1's current wording will need a Product Owner pass regardless of
routing.** AC1 as written presupposes `CupidAddAction` continues to render
"inside `CupidHeader.actions`" post-fix and just needs a corrected size. That
premise no longer holds under this decision — the correct outcome is that it
stops rendering there. Flagging for Scrum Master to route to Product Owner
rather than silently reinterpreting the AC myself.

## Secondary, complementary fix — still needed regardless of the above

AC2 requires the pinned widget test in
`mobile/test/design_system/adaptive_widgets_test.dart:619-644` to keep
asserting an explicit, correct `Size` for the general composition of
`CupidHeader(actions: [CupidAddAction(...)])` — that test builds `CupidHeader`
and `CupidAddAction` directly, independent of the real screen. Even after the
screen-level removal above, `CupidHeader`'s Material toolbar band should
still be hardened so this composition does not silently mis-render (60x56)
for this or any future consumer. This is genuine design-system defensive
correctness, not scope creep — it is squarely inside the design-system lane
already authorized for this story:

1. **Target toolbar height: 60**, not the framework default `kToolbarHeight`
   (56) — exactly matching `CupidAddAction`'s own already-correct Material
   FAB height (`_materialFabSize = 60`, `cupid_add_action.dart:14`, itself
   sourced from `Cupid Screens.dc.html` line 881). No other number is
   supported by any source evidence.
2. **Conditional, not global.** Only a `CupidHeader` whose `actions` contains
   an element needing more than 56pt gets the taller band. Every other
   `CupidHeader` — including `profile_edit_screen.dart`'s `TextButton`-only
   header (the only other real `CupidHeader.actions` consumer app-wide,
   confirmed by full-repo grep) and every header with empty/no `actions` —
   keeps the standard 56pt band. Do not change `kToolbarHeight` itself.
3. **`CupidAddAction` needs zero code changes.** Its Material branch already
   renders the fully correct 60x60/`r20`/`gradientHot`/`glowShadow`/27px-glyph
   treatment; once the incoming constraint is >= 60, it renders unclamped at
   its existing native size.
4. **`CupidHeader.preferredSize`** (`cupid_header.dart:62-63`, currently a
   fixed `Size.fromHeight(kToolbarHeight)` for both platforms) must track the
   same conditional value for Material, or the `Scaffold` body will
   clip/overlap under a taller `AppBar`. iOS is unaffected (renders
   `CupidAddAction` as a plain `IconButton`, not the FAB).
5. **Mechanism left to Tech Lead** — detecting "this header's actions need
   the taller band" (marker inspection vs. explicit opt-in parameter) is the
   component-contract decision that follows this UX pass.

## AC2 — regression pin flip

`mobile/test/design_system/adaptive_widgets_test.dart:619-644` — flip the
test named `'Material FAB is clamped to 60x56 inside CupidHeader.actions'`:

- Rename to reflect corrected behavior, e.g. `'Material FAB renders at full
  60x60 inside CupidHeader.actions (toolbar band raised to fit)'`.
- Replace `expect(size, const Size(60, 56)); expect(size.height,
  kToolbarHeight);` with `expect(size, const Size(60, 60));` — an explicit
  `Size`, per AC2's own wording.
- This test's own fixture directly composes `CupidHeader(actions:
  [CupidAddAction(...)])` — it is unaffected by whether the real screen still
  uses that composition, and must still pass via the secondary fix above.

## AC3 — confirmed unaffected cases (must stay exactly as-is)

- `mobile/lib/features/gallery/presentation/widgets/gallery_empty_view.dart:78`
  — not inside a `CupidHeader`; untouched.
- `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart:159`
  — wired to `Scaffold.floatingActionButton`, not `CupidHeader.actions`;
  untouched. Both stay unaffected automatically — neither this story's
  screen-level removal nor the `CupidHeader` hardening touches
  `cupid_add_action.dart`.

## AC4 — no unrelated CupidHeader regression

Confirmed by full-repo grep: `profile_edit_screen.dart`'s `TextButton` is the
only other `CupidHeader.actions` consumer in the app, and it is unaffected
because the raised band (secondary fix) is conditional, and the primary fix
touches only the Dream Jar list screen's own file.

## Status

UX_COMPLETE: YES — decision revised against the literal design source;
scope-boundary question for the primary fix is flagged for Scrum Master, not
resolved unilaterally here.
