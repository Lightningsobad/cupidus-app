# STORY-061 — Visual Fidelity Report (`jarlist`)

VISUAL_FIDELITY: PASS

AC1-AC8 all verified PASS against the literal `jarlist` design reference. Four
deltas are recorded below and none blocks an AC. Reviewer Round 2 (B5,
2026-08-20) adjudicated all four — D1, D2, D3 and D4 — as pre-approved, and the
verdict token is `PASS` accordingly; rule 12e2/12e3 admits only `PASS` or `FAIL`,
so the earlier `PASS_WITH_DELTAS` was not a valid token.

The deltas remain recorded in full under `## Recorded deltas` below, verbatim and
unrenumbered, including D4's open question about the active card's fill. A `PASS`
verdict records that no delta blocks an AC — it does not retract any delta or
close the follow-ups D2 and D4 raise.

## Design source resolution (AC9)

| Field | Value |
| --- | --- |
| Design-Screen | `jarlist` |
| Resolution command | `node .ai-team-bundle/runtime/tools/render-design-canvas.js --list-screens --location=cupid-app-design-system --entry="Cupid App.dc.html"` |
| Design entry | `Cupid App.dc.html` |
| Design location | `cupid-app-design-system/` |
| Toggles available | `dark`, `light`, `vi`, `en` |
| Platforms available | `ios`, `android` |
| Device | `emulator-5560` (Android) |
| Render toggles used | `android` + `dark` + `vi` |

`--list-screens` returns 37 screens; `jarlist` is one of them. Two entries in
the design bundle had to be discriminated: `Cupid Screens.dc.html` returns an
empty `screens` array and only the `ios` platform, so it is not the app-screen
entry. `Cupid App.dc.html` is.

The pinned entry is recorded in `data/devops/system/design-fidelity-config.json`,
which is `"locked": true` and sets `design_source.entry` to `"Cupid App.dc.html"`,
`design_source.location` to `cupid-app-design-system`, and
`design_source.project_dir` to `cupid-app-design-system/project`. The
by-elimination resolution performed above independently arrived at that same
pinned entry, so the two agree.

**Correction (B6, Reviewer Round 2):** an earlier revision of this report stated
that no `design-fidelity-config.json` existed in this repository. That was wrong
— the file above exists and is authoritative. The entry did not need to be
resolved by elimination, and this report should have cited the config in the
first place.

One real discrepancy remains, and it is the reason the config was missed rather
than an excuse for it: the render was invoked with
`--location=cupid-app-design-system`, the bundle root, whereas the config pins
`project_dir` to `cupid-app-design-system/project`. The `*.dc.html` files have
moved out of `project/` up to the bundle root, so the config's `project_dir` no
longer resolves to where the files actually sit while the bundle root does. That
is exactly D5, the design-source-directory-drift item already deferred to Scrum
Master as repo hygiene. The entry resolved to the same file either way, so the
drift did not change which screen was rendered — but it should be closed so the
config's `project_dir` and `content_fingerprint` describe the real tree again.

### `hide_selectors`

The config sets one hide selector,
`[data-plat] [style*="z-index: 95"]`, whose recorded purpose
(`hide_selectors_note`) is to suppress the canvas's own screen-index FAB
(`toggleIndex`/`pickScreen`), which the canvas paints inside the device frame as
prototype navigation rather than app UI.

Applied: **YES**, confirmed by inspecting the artifact. No screen-index FAB
appears anywhere in `design-reference-jarlist-ready-emulator-5560.png` — not in
any corner and not inside the device frame; the bottom-right area contains only
the tab bar and the home indicator. The suppression therefore took effect for
this render, and there is no leftover prototype-navigation control that could
have skewed the AC-by-AC comparison at that corner.

Stated precisely, since this rework pass re-rendered nothing: this is an
attestation about the committed reference image, verified by looking at it, not
a re-execution of the render. `render-design-canvas.js` warns when the selector
matches nothing, and no such warning appears in this story's recorded evidence
trail.

**Confirmed by content, not by id match** (AC9 explicitly requires this): the
rendered `jarlist` reference depicts a Dream Jar collection — three jar cards
with progress bars, the `+ Tạo hũ mới` create-jar CTA, a `Hũ đã hoàn thành`
completed row, and a bottom tab bar with `Ví chung` active. It is the Dream Jar
list screen, not merely a screen whose id happens to read `jarlist`.

## Evidence pair

| Role | Path | Size |
| --- | --- | --- |
| Implemented | `implemented-jarlist-ready-emulator-5560.png` | 405x900 |
| Design reference | `design-reference-jarlist-ready-emulator-5560.png` | 406x900 |

Both under this `visual-fidelity/` directory. Captured on the already-running
`emulator-5560`; no device was created, booted, wiped, or repaired.

## States compared

One state: `ready` (loaded, populated, `vi` locale, dark theme) — the only state
AC1-AC8 make claims about. Concretely the compared state contains three active
jars (`Du lịch Đà Lạt` 78%, `Nhẫn đôi` 30%, `Dọn về ở chung` 3%), the first
marked as currently-viewed, and two completed jars (`Tai nghe cho Linh`,
`Sinh nhật Minh`) feeding the AC5 row.

Not compared, and deliberately out of scope for AC1-AC8: `loading`, `error`,
`empty`, single-jar-bypass, `light` theme, and `en` locale. No AC references
them and the design reference renders none of them.

## Per-AC verdict

| AC | Element | Verdict | Basis |
| --- | --- | --- | --- |
| AC1 | Summary pill | PASS | Both images render a full-width pill with a leading circular savings badge and the sentence `Tổng cả nhà đang để dành 7.150.000₫ trong 3 cái hũ`. Amount and count match the reference exactly, and the total correctly counts active jars only (the two completed fixtures are excluded). Delta D3 applies. |
| AC2 | Jar illustration + per-jar leading glyph | PASS | Both required elements are present on every card: a leading illustration thumbnail and a glyph immediately before the jar name. Deltas D1 and D2 apply to their rendering. |
| AC3 | Deadline row | PASS | All three cards render their deadline right-aligned — `30/09/2026`, `14/02/2027`, `01/06/2027` — matching the reference values and placement. |
| AC4 | `Đang xem` badge | PASS | The first card carries a ~2dp `colorAccentPink` border ring and, on its own row below the amount/percent line, a pill chip with `CupidIcons.checkCircle` + `Đang xem` in pink with a tinted fill. Matches `ux/uiux-spec.md:181-192`, including the "no top-right badge" requirement. Delta D4 applies to the card fill. |
| AC5 | Completed-jars row | PASS | Both images render `Hũ đã hoàn thành` with a leading history glyph, the subtitle `2 cái · Tai nghe cho Linh, Sinh nhật Minh`, and a trailing chevron. Jar names match the design source's own sample names. This closes the P1 gap where AC5 had widget-test coverage only and no on-device evidence. |
| AC6 | Title copy | PASS | Header reads exactly `Các hũ ước mơ` in both. The old `Hũ Ước Mơ` is gone. |
| AC7 | CTA copy | PASS | Both render a full-width gradient pill reading `+ Tạo hũ mới` with the plus drawn as a leading glyph. The English noun `Dream Jar` no longer appears in the `vi` build. |
| AC8 | Shell tab-bar shape | PASS | Both tab bars read `Nhà · Trò chuyện · Pet · Ví chung · Tôi` — five tabs, `Ví chung` active and pink-highlighted at index 3. No Gallery tab and no account FAB in either. The old 3-tab-plus-FAB shape is gone. |

AC9 is satisfied by this report plus the evidence pair above. AC10 is
documentation-only and its disposition is recorded in
`coding-plan/test-results.md` `### AC10 disposition`, not here.

## Recorded deltas

These are real differences between the two images. None is silently passed over;
this story exists because that pattern produced RWB-20260816-029.

### D1 — Jar thumbnail is a circular avatar, not a jar silhouette (AC2)

The reference draws a tall rounded-rectangle jar illustration per card (lid,
collar, glass body) in a per-jar colour — teal, purple, pink. The implementation
draws a 48x48 tinted circle containing `CupidIcons.savings`.

Status: **approved before implementation**, not discovered after. `ux/uiux-spec.md:119-127`
put the choice to Tech Lead as option (a) a new static jar-silhouette painter
versus option (b) an existing generic glyph in a tinted circular avatar, and
described (b) in advance as a "coarser match" to be flagged "as an explicit
fidelity trade-off, not silently" passed. `architecture/solution.md:228-233`
selected (b), on the ground that `DreamJarIllustration` is a `StatefulWidget`
holding two `AnimationController`s per instance
(`dream_jar_illustration.dart:38-45`), so one per card in a scrolling list costs
N live animation controllers for a decorative thumbnail, and new painter work is
out of budget for a hardening pass.

Closing this delta requires option (a) — a new static painter — which is a
scoped follow-up, not a defect in this story.

### D2 — The same `savings` glyph renders twice per card, and identically across all cards (AC2)

Per card, `CupidIcons.savings` appears both inside the avatar and again as the
leading glyph in the title row. Across cards, all three title-row glyphs are the
same. The reference instead uses a content-specific glyph per jar — a plane for
`Du lịch Đà Lạt`, rings for `Nhẫn đôi`, a house for `Dọn về ở chung`.

Status: **anticipated and constrained by design**, but the specific outcome is
worth flagging. Two spec facts combine here:

- `ux/uiux-spec.md:137-150` records that the reference's per-jar glyphs are
  placeholders tied to the mockup's three sample jar names. `DreamJar` has no
  category, type, or icon field (`ux/uiux-spec.md:329-332`), so per-jar glyphs
  cannot be data-driven, and the spec explicitly forbids faking them by
  name-text sniffing or keyword matching. One consistent generic glyph is the
  spec's own recommendation and is called "an acceptable, honest simplification"
  that satisfies AC2's element-presence requirement.
- `architecture/solution.md:223-227` then forbids adding any new `IconData`
  codepoint and assigns `CupidIcons.savings` to the `Ví chung` tab, the
  summary-pill badge, *and* the per-jar leading glyph.

So the repetition is a direct consequence of two deliberate guardrails, not an
oversight. However, `ux/uiux-spec.md:145-147` named this exact risk in advance —
"if visually too repetitive next to the avatar's own jar shape", use
`CupidIcons.favorite` instead — and the rendered result does read as repetitive,
since D1 made the avatar carry the same glyph rather than a jar shape. The
alternative is an existing cmap-confirmed icon, so adopting it would not breach
the no-new-codepoint guardrail.

Flagged for a decision. No code change required for AC2 to pass, and none made
in this pass.

### D3 — Summary pill amount is not bolded and wraps to two lines (AC1)

The reference renders `7.150.000₫` in a heavier weight inside an otherwise
single-line sentence. The implementation renders the whole sentence at one
weight, and it wraps to two lines.

Status: **within approved tolerance on both counts.**
`ux/uiux-spec.md:63-65` states that if the `Text.rich` split on the localized
amount substring is judged too fragile for this hardening story, "a single-weight
`Text` (no split) is an acceptable fallback — AC1 requires the format/content to
match, not the inline bold treatment". `ux/uiux-spec.md:71-72` sets the wrap
budget at "without wrapping past 2 lines"; the implementation uses exactly two,
so it is at the limit but not over it.

Content and format match the reference exactly, which is what AC1 asks for.

### D4 — Active card has the border ring but no fill differentiation (AC4)

The reference's active card carries both a pink border ring and a visible
pink/magenta gradient fill across the card body. The implementation renders the
2dp pink border ring only; its fill is the same `colorSurface` as the two
inactive cards.

Status: **partial gap against the UX spec** — the one delta here that is not
fully pre-approved. `ux/uiux-spec.md:181-185` asks for the border ring as "the
primary signal" *plus* "a very subtle differentiation in fill versus the other
cards", while explicitly constraining the fix: "do not invent a second background
token for this". The primary signal is implemented and AC4's own wording asks for
"an 'Đang xem' badge with the design's pink border/tint treatment", which the
border and the tinted badge chip both deliver — so AC4 passes. The secondary
fill differentiation is absent.

The reference's fill is also considerably stronger than the "very subtle"
treatment the spec sanctions, so matching the reference literally would overshoot
the spec. Flagged for a decision on which of the two to converge toward. Not
fixed in this pass because it is AC-affecting code and this rework pass is
evidence-only.

## Out of scope, not a delta

The amount/percent line differs in both format and layout — the reference reads
`3.900.000₫ / 5.000.000₫` with the percent and date on their own row below the
progress bar, while the implementation reads `3.900.000₫ trên 5.000.000₫ · 78%`
with the percent inline and the bar above.

This is report row 8 and is explicitly excluded from this story. The requirement
scope leaves it out with no PO decision extending it, and
`architecture/solution.md:236-237` instructs directly: "Do not touch `_JarCard`'s
existing amount/percent `Text`". Recorded here so a future reader does not mistake
its absence from the delta list for an oversight.

The reference render also carries a device bezel and a back chevron the
implementation lacks. The bezel is a capture-framing artifact of the design
renderer. The absent back chevron is correct post-P2 behaviour and is dispositioned
under AC10 in `coding-plan/test-results.md`.
