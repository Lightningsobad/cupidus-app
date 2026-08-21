
# UI/UX Specification - Zodiac Compatibility Preview Page (REQ-006 / STORY-003)

## 1. Metadata

- Related Story: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-003/story_master.md`
- Source Requirement Paths: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/req_master.md`, `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-003/requirements/requirements.md`
- Target Directory: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-003/ux/`
- Mode: Additive page content on an existing shell (STORY-001 shared header/footer/theme/language toggle — reused, not redesigned).
- Status: Draft
- System UX Memory Path: `data/ux/system/ui_ux_system_memory.md`
- System UX Memory Action: Read Only (this run) — memory currently documents only the unrelated mobile app (REQ-001); no web-shell entry exists yet there (still pending from STORY-001, see that story's Handoff Notes item "System UX Memory update: deferred"). This spec reuses STORY-001's own `ux/uiux-spec.md` directly as the shell reference instead.

## 2. Context Summary

- User goal: a visitor already browsing `cupidus.app` clicks "Zodiac" in the nav and sees a static, fully-populated preview of the in-app zodiac-compatibility feature — a sample daily read, all 12 signs, the 4 elements, and a weekly leaderboard — to build trust/interest before downloading.
- Primary user mode: Returning-within-session (arrives via the shared header/mobile-select nav built in STORY-001, not a first-time cold entry).
- Business outcome: previews a differentiated in-app feature not explained elsewhere on the site, giving a concrete download reason.
- Existing specs reviewed: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/ux/uiux-spec.md` (shared shell + typographic/spacing system this page must match exactly).
- Existing UI patterns found (reused unmodified): global header/footer/theme-toggle/language-toggle shell (STORY-001 §6.1, §6.4); page container `max-width:1200px; margin:0 auto`; three-typeface split (Nunito 900/800 display, Roboto body, Roboto Mono uppercase-tracked eyebrow/caption/numeral); `--surf`/`--c*` border-and-panel system; no hard drop shadows on content cards.
- Existing components reused or extended: page container + section rhythm pattern (new sub-pattern introduced here, see §6.7, for later page stories to reuse); percentage ring, metric bar, element card, and leaderboard row are new components local to this page (not present in STORY-001).
- Current UX debt or consistency risks: none — this story only adds body content behind an already-wired, currently-empty route (`isZodiac` per STORY-001 §6.3 Route Map).
- Current organization or hierarchy issues in the affected area: N/A.
- Stable shared patterns vs local debt: the outer page padding pattern `padding:70px 32px 90px` (design source line 286) differs slightly from Home's hero `padding:76px 32px 30px` — this is a legitimate different-page-type variance in the source, not local debt; carry it forward exactly, do not normalize it to Home's values.
- Open Question Impact source: `STORY-003/requirements/requirements.md` `## Open Question Impact`.
- Open assumptions: none — every element below is sourced directly from `cupid-app-design-system/Cupid Web.dc.html` lines 285–384 (the complete `isZodiac` block) plus the `zodiac` data array at lines 763–776, with exact line numbers cited throughout.

## 3. Open Question Impact

- **OQ-REQ006-1** (frontend framework/stack) — RESOLVED by STORY-001 (DONE, MERGE_COMPLETE). UX Scope Blocked: none. This spec is expressed as markup structure/CSS tokens/interaction states independent of the chosen stack, matching STORY-001's convention.
- **OQ-REQ006-2** (backend API dependency) — RESOLVED: static/marketing site, no live API. UX Scope Blocked: none. UX Decision: no loading/error/empty states are designed for this page — every figure (92%, 88%/94%/71%, the 12-sign dates, the 6 leaderboard percentages) is static sample content per BR-1; there is nothing to fetch and nothing that can fail.

### Scope Items BLOCKED in this story

None.

## 4. Requirement-To-Design Traceability

- **AC-1 (Nav entry + route, chrome intact)**: UX Response: §6.1 (chrome is reused verbatim from STORY-001, no local changes). Affected: global header/footer, `isZodiac` route body only.
- **AC-2 (Hero)**: UX Response: §6.2.1, sourced from `Cupid Web.dc.html:288-290`.
- **AC-3 (Daily compatibility card)**: UX Response: §6.2.2, sourced from `:292-320`.
- **AC-4 (All twelve signs grid)**: UX Response: §6.2.3, sourced from `:322-331` + `zodiac` array `:763-776`.
- **AC-5 (Four elements grouping)**: UX Response: §6.2.4, sourced from `:332-350`.
- **AC-6 (Six-pair leaderboard)**: UX Response: §6.2.5, sourced from `:351-383`.
- **AC-7 (VI/EN language toggle)**: UX Response: every string quoted below is copy-pasted verbatim from the design source's `data-vi`/`data-en` spans; reuses STORY-001 §6.4 language mechanism unmodified — no new toggle logic in scope.
- **AC-8 (Theme toggle)**: UX Response: reuses STORY-001 §6.4 theme mechanism unmodified; all colors below are expressed as the same `--c*`/`--acc-*` tokens already defined for both themes, so no new theme work is needed, only correct token usage.
- **AC-9 (Per-page `<title>`)**: UX Response: §6.3 (new — the design source has no `<title>` element anywhere, confirmed at STORY-001 review DEF-2; this is a first-time UX decision for the whole requirement, not a reuse).
- **AC-10 (Visual fidelity)**: UX Response: §6.7 Visual Acceptance Criteria + all literal values cited throughout §6.2. Affected: Zodiac route, verified at the requirement-level `frontend-dev` `Mode: requirement-visual-audit` gate.

## 5. Critical User Tasks And Success Criteria

- **Build trust in the zodiac feature and continue toward download**:
  - User Mode: Returning-within-session (already on the site, exploring nav items).
  - Entry Point: header "Zodiac" pill (desktop) or mobile nav `<select>` "Zodiac" option (both wired by STORY-001).
  - Success Signal: user scrolls through the full page (sample card → 12 signs → elements → leaderboard) and either returns to Home via the header CTA/logo, or continues to another nav item — i.e., the page reads as a complete, credible feature preview rather than a stub.
  - Primary Risk: because every number on this page is static sample content (BR-1) and there is no in-page disclaimer text in the design source itself, a visitor could misread "92%" etc. as live/personalized. This is the source's own presentation choice (no disclaimer copy exists at `:285-384`) — do not add one; it would be a fidelity deviation. Flagged here as a known, accepted trade-off, not something for this spec to "fix."
- First-use guidance or discoverability needs: none — page is self-contained, reached only via nav (no in-flow onboarding).
- Completion or post-completion state: N/A — no action to complete; page is read-only preview content.
- Retry, edit, undo, or next-action behavior: N/A — no forms, no interactive data on this page.
- What would make the task feel unfinished or unsafe to the user: an incomplete sign list (must be exactly 12, no fewer/no duplicates per AC-4) or a leaderboard with the wrong row count (must be exactly 6 per AC-6) — both explicitly measurable, not subjective.

### 5.1 System Entry And Discoverability

- Existing surface, workflow, or state where the actor starts: any page of the deployed site (header/footer nav is global per STORY-001).
- Required entry point, navigation item, CTA, or in-flow discovery path: header "Zodiac" pill / mobile `<select>` "Zodiac" option (STORY-001 §6.1, item 3 of 7, `Cupid Web.dc.html:716`) — already wired, this story only fills the route body.
- Direct URL only acceptable per PO scope: not applicable — this page's primary path is in-nav discovery, not direct-URL-first (unlike STORY-001's Home).
- Entry point states: default only. No empty/loading/disabled/permission-limited states (static content, no auth, no fetch — per OQ-REQ006-2).
- Surfaces intentionally not updated: header/footer/theme/language-toggle chrome (STORY-001-owned, out of scope here per story's own Out of Scope list).

## 6. UX Design

### 6.1 Shell Reuse (no local changes)

- Reuse / Extend / New: **Reuse, unmodified.** Header, footer, theme toggle, language toggle, sticky/blur behavior, and the 1024/1025px nav breakpoint are all STORY-001 §6.1/§6.4 as built — this story's `isZodiac` state only supplies the `<main>` body between them.
- The nebula/star background wash and floating blobs (STORY-001 §6.2 Hero, "Background (page-global)") are shell-level and persist behind this page's content unchanged — do not re-implement per-page.

### 6.2 Zodiac Page (`isZodiac` state, `Cupid Web.dc.html:285-384`)

Page container: `max-width:1200px; margin:0 auto; padding:70px 32px 90px` (`:286`). Five sections render top to bottom, all part of one continuous page render (matching STORY-001's precedent of treating one design-source `isX` block as one page) — implementer must ship all five together for AC-10 fidelity.

**1. Hero** (`:287-290`)
- Left-aligned text block, `max-width:640px`.
- Eyebrow: Roboto Mono 11px, uppercase, `letter-spacing:.14em`, `color:var(--acc-butter)`. VI "Chiêm tinh" / EN "Astrology".
- H1: Nunito 900, 52px, `letter-spacing:-.03em`, `margin:10px 0 0`, `color:var(--ink)`. VI "Hôm nay trời có ủng hộ hai bạn không?" / EN "Are the stars on your side today?" — plain text, no gradient span here (unlike Home's H1 — do not add one, that would be a fidelity deviation).
- Subcopy: 16px, `line-height:1.65`, `color:var(--c64)`, `margin:16px 0 0`. VI "Chỉ số tương hợp mỗi ngày, gợi ý nhỏ cho từng cặp cung — nhẹ nhàng, vui, và không bao giờ nói ai đúng ai sai." / EN "A daily compatibility read and a small nudge for your pairing — playful, gentle, and never about who is right."

**2. Daily compatibility card** (`:292-320`)
- Card: `margin-top:38px`, `background:linear-gradient(150deg,rgba(255,201,126,.18),rgba(183,140,245,.16))`, `border:1px solid var(--c13)`, `border-radius:34px`, `padding:38px`. Two-column grid: `grid-template-columns:repeat(auto-fit,minmax(min(300px,100%),1fr)); gap:36px; align-items:center` (fluid reflow, same `auto-fit`/`minmax` convention as STORY-001's grids — stacks to one column below ~636px combined min-width, not a fixed breakpoint).
- **Left cell** — sign pair + ring (`:293-302`), `display:flex; align-items:center; justify-content:center; gap:22px`:
  - Sign 1 (left): Zodiac Icon `sign="cancer"` 86×86px, centered; below it, name Nunito 800 15px `color:var(--ink)`, `margin-top:10px`. VI "Cự Giải" / EN "Cancer".
  - Center: percentage ring, `flex-direction:column; align-items:center; gap:6px`. Outer ring 104×104px circle, `background:conic-gradient(#FFC97E 0% 92%, var(--c1) 92% 100%)` (92% fill in butter, remainder in the low-opacity border token), centered inner disc 82×82px `background:var(--screen)` containing "92%" (Nunito 900 24px, `color:var(--ink)`). Below the ring: caption Roboto Mono 9.5px, uppercase, tracked `.12em`, `color:var(--c5)`. VI "hôm nay" / EN "today".
  - Sign 2 (right): Zodiac Icon `sign="taurus"` 86×86px, same label treatment. VI "Kim Ngưu" / EN "Taurus".
  - The ring's fill percentage (92%) must be implemented as a real conic-gradient stop tied to the value shown in the inner disc, not a static pre-baked image — so the pattern is reusable if this card's sample value ever changes (still static per BR-1, but the ring math should not be hardcoded separately from the displayed number).
- **Right cell** — three metric bars + nudge (`:303-319`), `display:flex; flex-direction:column; gap:16px`:
  - Each metric row: label row `display:flex; justify-content:space-between; font-size:12.5px; color:var(--c7); margin-bottom:6px` (label left, percentage right in Roboto Mono, own accent color), then a track `height:7px; border-radius:999px; background:var(--c09); overflow:hidden` containing a filled bar `border-radius:999px` at the stated width.
    1. VI "Giao tiếp" / EN "Communication" — **88%**, percentage text `color:var(--acc-pink)`, bar fill `#FF7FB6`.
    2. VI "Thấu hiểu" / EN "Understanding" — **94%**, percentage text `color:var(--acc-lilac)`, bar fill `#B78CF5`.
    3. VI "Năng lượng" / EN "Energy" — **71%**, percentage text `color:var(--acc-mint)`, bar fill `#79E2CD`.
  - "Today's nudge" block (`:316-319`): `background:var(--inner); border:1px solid var(--c11); border-radius:20px; padding:18px`. Label: Roboto Mono 9.5px uppercase tracked `.12em`, `color:var(--acc-butter)`. VI "Lời khuyên hôm nay" / EN "Today's nudge". Body: 13.5px, `line-height:1.6`, `color:var(--c78)`, `margin-top:8px`. VI "Kim Ngưu hôm nay hơi chậm nhịp — đừng giục. Cự Giải cứ nấu gì đó, im lặng cùng nhau cũng là nói chuyện." / EN "Taurus is running slow today — don't rush them. Cancer, cook something; sitting quietly together still counts as talking."

**3. "All twelve signs" grid** (`:322-331`, data `:763-776`)
- H2: `margin:48px 0 0`, Nunito 900 28px, `letter-spacing:-.02em`, `color:var(--ink)`. VI "Mười hai cung" / EN "All twelve signs".
- Grid: `margin-top:38px`, `repeat(auto-fit,minmax(150px,1fr)); gap:14px`.
- Exactly 12 cards, one per `zodiac` array entry, each: `background:var(--surf); border:1px solid var(--c1); border-radius:22px; padding:20px 16px; text-align:center`; hover `border-color:rgba(255,201,126,.4)`. Card anatomy top to bottom: icon 54×54px centered → name (Nunito 800 15px, `color:var(--ink)`, `margin-top:10px`) → date range (Roboto Mono 9.5px, `color:var(--c45)`, `margin-top:4px`).
- Exact 12-entry data set, reproduce verbatim in this order (`key` / VI / EN / date range):
  1. `aries` — Bạch Dương / Aries — 21.3 – 19.4
  2. `taurus` — Kim Ngưu / Taurus — 20.4 – 20.5
  3. `gemini` — Song Tử / Gemini — 21.5 – 20.6
  4. `cancer` — Cự Giải / Cancer — 21.6 – 22.7
  5. `leo` — Sư Tử / Leo — 23.7 – 22.8
  6. `virgo` — Xử Nữ / Virgo — 23.8 – 22.9
  7. `libra` — Thiên Bình / Libra — 23.9 – 22.10
  8. `scorpio` — Bọ Cạp / Scorpio — 23.10 – 21.11
  9. `sagittarius` — Nhân Mã / Sagittarius — 22.11 – 21.12
  10. `capricorn` — Ma Kết / Capricorn — 22.12 – 19.1
  11. `aquarius` — Bảo Bình / Aquarius — 20.1 – 18.2
  12. `pisces` — Song Ngư / Pisces — 19.2 – 20.3
- Date-range strings use an en-dash-like " – " separator exactly as sourced (space, en-dash, space) — do not normalize to a hyphen.

**4. "Four elements" grouping** (`:332-350`)
- H2: `margin:52px 0 18px`, same H2 style as above. VI "Bốn nguyên tố" / EN "Four elements".
- Grid: `repeat(auto-fit,minmax(min(230px,100%),1fr)); gap:16px`.
- Exactly 4 cards, each `background:var(--surf); border:1px solid var(--c1); border-radius:24px; padding:22px`; label row Roboto Mono 9.5px uppercase tracked `.12em`; icon row `display:flex; gap:12px; margin-top:14px`, three 46×46px sign icons per card, no labels under these icons (unlike the 12-sign grid — icons only here):
  1. VI "Hỏa" / EN "Fire" — `color:var(--acc-peach)` — aries, leo, sagittarius.
  2. VI "Thổ" / EN "Earth" — `color:var(--acc-butter)` — taurus, virgo, capricorn.
  3. VI "Khí" / EN "Air" — `color:var(--acc-lilac)` — gemini, libra, aquarius.
  4. VI "Thủy" / EN "Water" — `color:var(--acc-mint)` — cancer, scorpio, pisces.

**5. "Six most in-sync pairs this week" leaderboard** (`:351-383`)
- Card: `margin-top:52px; background:var(--surf); border:1px solid var(--c1); border-radius:30px; padding:32px`.
- Card title (Nunito 900 24px, `color:var(--ink)`, no separate eyebrow above it — the H2-style pattern used elsewhere is not repeated here, keep as a single title line). VI "Sáu cặp ăn ý nhất tuần này" / EN "Six most in-sync pairs this week".
- Exactly 6 rows, each `display:flex; align-items:center; gap:14px; padding:14px 0; border-top:1px solid var(--c08)` (hairline rule above every row, including the first, directly under the title):
  - Pair label (`flex:1`, Nunito 700 14.5px, `color:var(--ink)`).
  - Bar track: fixed `width:120px; height:6px; border-radius:999px; background:var(--c09); overflow:hidden`, filled bar `background:linear-gradient(90deg,#FF7FB6,#B78CF5)` at the row's percentage width.
  - Percentage value: Roboto Mono 12px, `color:var(--acc-pink)`, `width:38px; text-align:right`.
  - Row data, in rank order (pair / bar+value):
    1. VI "Cự Giải × Kim Ngưu" / EN "Cancer × Taurus" — 96%
    2. VI "Song Ngư × Bọ Cạp" / EN "Pisces × Scorpio" — 93%
    3. VI "Sư Tử × Nhân Mã" / EN "Leo × Sagittarius" — 90%
    4. VI "Thiên Bình × Song Tử" / EN "Libra × Gemini" — 88%
    5. VI "Ma Kết × Xử Nữ" / EN "Capricorn × Virgo" — 85%
    6. VI "Bạch Dương × Bảo Bình" / EN "Aries × Aquarius" — 82%
  - The pair-label separator is the multiplication sign "×" (U+00D7), not a lowercase "x" — preserve exactly.

### 6.3 Per-Page `<title>` (AC-9, new UX decision — no source precedent)

- The design source has no `<title>` element on any route (confirmed, STORY-001 review DEF-2). This is the first UX decision on the pattern for the whole requirement; STORY-002 and STORY-004..008 should each define their own page's title the same way, following this pattern, rather than each inventing a different convention.
- Pattern: `<Nav item's own label> — Cupid`, using the same VI/EN label pair already defined for the nav item (STORY-001 §6.1 nav items), switched by the active language exactly like all other page text (§6.4 mechanism, reused).
  - VI: `Hoàng đạo — Cupid`
  - EN: `Zodiac — Cupid`
- Rationale: reuses copy already verbatim-sourced from the design (`Cupid Web.dc.html:716`, the `zodiac` nav item's `vi`/`en` values) rather than inventing new marketing copy not present in the design source, keeping AC-9 compliant without a copy-fidelity risk. "— Cupid" suffix matches the brand wordmark used in the header logo (STORY-001 §6.1).
- Must update on language toggle the same way all other `data-vi`/`data-en` content does (no separate title-specific toggle logic).

### 6.4 Component Changes

- **Percentage ring** (New, this page only): conic-gradient circular progress indicator with a centered value label. See §6.2.2. Not used elsewhere in STORY-001's scope — flag to later stories (e.g. STORY-002 if it needs a similar "score" visualization) rather than assuming reuse without checking this page's specific values.
- **Metric bar** (New): label+percentage header row over a filled track. See §6.2.2. Visually similar to the leaderboard bar (§6.2.5) but with a label header row above it — treat as a distinct variant, not the same component, since the leaderboard bar has no label row and a different track width (120px fixed vs. metric bar's fluid full-width).
- **Sign card** (New, this page only): icon + name + date range, used for the 12-sign grid. See §6.2.3.
- **Element card** (New, this page only): label + 3 unlabeled icons, used for the 4-elements grouping. See §6.2.4. Do not confuse with Sign card — element cards show icons with no name/date labels underneath.
- **Leaderboard row** (New): pair label + fixed-width bar + percentage. See §6.2.5.
- **Nudge callout** (New, this page only): inset panel with eyebrow + body text. See §6.2.2 "Today's nudge".

### 6.5 Responsive And Accessibility Notes

- Responsive behavior: all five sections use fluid `auto-fit`/`minmax` grids exactly as sourced — daily-card 2-column (`minmax(min(300px,100%),1fr)`), 12-sign grid (`minmax(150px,1fr)`), 4-element grid (`minmax(min(230px,100%),1fr)`). No named breakpoints beyond the shell's existing 1024/1025px nav swap (STORY-001 §6.1, reused unmodified) — implement as real fluid grids, matching STORY-001's established convention (§6.6), not fixed breakpoint overrides.
- Content reprioritization on smaller surfaces: the daily-compatibility card's two grid cells (sign-pair+ring, then metric bars+nudge) stack vertically once combined width drops below the two ~300px columns — natural `auto-fit` behavior, left cell first, matching source DOM order; no reordering needed.
- Leaderboard rows: the fixed 120px bar track and 38px percentage-value column do not shrink on narrow viewports (source uses fixed pixel widths here, unlike the fluid grids elsewhere) — only the pair-label column (`flex:1`) compresses; verify at implementation that long VI pair labels (e.g. "Thiên Bình × Song Tử") do not wrap awkwardly against the fixed-width bar/value columns at ~375px viewport width — if wrapping occurs it must wrap the label text only, never truncate the percentage or shrink the bar.
- Keyboard and focus expectations: this page has no interactive controls of its own (no forms, no buttons, no links within the five sections — all figures are static text/graphics) — the only focusable elements on this route remain the shared header/footer items already covered by STORY-001 §6.6. Do not add tabbable wrapper elements around static cards.
- Screen reader / semantics notes:
  - Use a real `<main>` landmark for the page body (shell already provides `<header>`/`<footer>` per STORY-001 §6.6).
  - Zodiac sign icons are decorative alongside an always-present visible text label (name in the 12-sign grid; name in the daily-card sign pair) — mark icons `aria-hidden="true"`/empty `alt=""`, do not duplicate the name into alt text.
  - Element-card icons (§6.2.4) have **no adjacent visible text label** (icons only, per source) — these need meaningful `alt` text naming the sign (e.g. "Aries", using the EN or active-language name), since there is no visible text fallback for a screen-reader user on those three icons per card. This is an a11y gap the raw source doesn't address, matching STORY-001's convention of closing such gaps at implementation (§6.1 accessibility notes precedent).
  - The percentage ring's value (92%) is exposed as visible text in the inner disc already — do not rely on the conic-gradient fill alone; ensure the text node is real DOM text, not an image, so it's screen-reader accessible without extra ARIA.
  - Metric bars and leaderboard bars already pair every bar with adjacent visible percentage text (§6.2.2, §6.2.5) — no color/length-only meaning, so no extra ARIA needed beyond correct semantic markup (e.g. these are presentational bars, not native `<progress>`/`<meter>` elements per the source's plain-div structure; a `role="img"` with an `aria-label` stating the percentage is acceptable if implemented as non-text divs, but the adjacent visible text already satisfies the core requirement).
- Error / status communication expectations: N/A — no forms, no async operations (OQ-REQ006-2).

### 6.6 Visual Direction Notes

- Typography, density, spacing posture: same three-typeface split as STORY-001 (§6.7) — Nunito 900/800 for headline/title text (H1, H2, card titles, ring value, pair labels), Roboto Mono uppercase-tracked for eyebrow/caption/percentage-mono accents, plain Roboto-scale body text for subcopy/nudge body. No new typographic pattern introduced.
- Surface and container treatment: `--surf` translucent panels with 22-34px border radii and thin low-opacity borders, consistent with STORY-001's "never hard drop shadows on content cards" rule (§6.7) — the daily-compatibility card's soft gradient background (`rgba(255,201,126,.18)`/`rgba(183,140,245,.16)`) is a border/background treatment, not a shadow, and stays within that rule.
- Color usage: this page is the first to use the accent palette as **data-encoding** color (metric-bar/leaderboard-bar gradient fills, ring fill) rather than purely brand-expressive decoration (STORY-001 §6.7 noted no semantic color use existed yet) — every such use is paired with adjacent percentage text (§6.5), so color remains reinforcing, not the sole signal.
- Anti-patterns explicitly avoided: no native `<progress>`/`<meter>` browser-default styling (source is fully custom-styled divs); no numeric input or live recalculation control anywhere on this page (would contradict BR-1/OQ-REQ006-2 — this is a preview, not a calculator).

### 6.7 Visual Acceptance Criteria / Design Anchor

- Visual reference(s): not yet rendered as image files, same outstanding condition already logged in STORY-001 §7 Handoff Notes item 2 (design-reference rendering requires a Bash-capable agent this role does not have). The measurable rules below, pulled directly from `Cupid Web.dc.html:285-384`, are the interim visual anchor. `req_master.md` now shows `Design-Source: UPDATED 2026-08-21T10:18:35Z (applied)`, which resolves STORY-001's earlier item 3 blocker (`Cupid Web.dc.html` is the locked entry) — a Bash-capable agent should still be the one to run the actual `render-design-canvas.js --screen=zodiac` render before the requirement-level visual audit gate (AC-10).
- Layout & spacing (key paddings, gaps, sizes): page container `padding:70px 32px 90px`; daily-card `padding:38px`, grid `gap:36px`; 12-sign grid `margin-top:38px`, `gap:14px`, card `padding:20px 16px`; 4-element grid `gap:16px`, card `padding:22px`; leaderboard card `padding:32px`, row `padding:14px 0`, bar track fixed `120px×6px`. All sections share the page's single `max-width:1200px` container (no per-section width override).
- Color & status semantics: ring fill `#FFC97E` (butter) at 92%, remainder `var(--c1)`; metric-bar fills `#FF7FB6`/`#B78CF5`/`#79E2CD` (pink/lilac/mint) matching their percentage-text colors `var(--acc-pink)`/`var(--acc-lilac)`/`var(--acc-mint)`; leaderboard bar fill `linear-gradient(90deg,#FF7FB6,#B78CF5)` for all 6 rows (uniform gradient, not per-row color); element-card labels `var(--acc-peach)`/`var(--acc-butter)`/`var(--acc-lilac)`/`var(--acc-mint)` for Fire/Earth/Air/Water respectively. All tokens are the same dark/light pair already defined in STORY-001 §6.8's token table — no new tokens introduced.
- Typography (sizes, weights, line-heights): H1 Nunito 900 52px (smaller than Home's 66px — page-type variance, keep exact); H2 Nunito 900 28px (smaller than Home's 38px — same note); card/leaderboard title Nunito 900 24px; sign/pair-label names Nunito 700-800 14.5-15px; ring value Nunito 900 24px; body/subcopy Roboto 16px/1.65 (hero), 13.5px (nudge body); eyebrow/caption/date/percentage Roboto Mono 9.5-12px uppercase tracked `.12em` where uppercase.
- Component states to verify (default / hover / active / disabled / loading / error / empty): 12-sign card hover only (`border-color` shift, `:325`) — no active/selected state exists for any card on this page (nothing is clickable). No disabled/loading/error/empty states apply (static content only, per OQ-REQ006-2 and this story's own Non-Functional Notes "no live/failure edge case").
- Responsive checkpoints to verify: daily-card 2-column collapse point (combined `minmax(min(300px,100%),1fr)` columns); 12-sign grid and 4-element grid continuous reflow at common widths (375, 768, 1024, 1440) with no column dropping below its `minmax` floor (150px signs, 230px elements); leaderboard row label-wrap behavior at ≤375px per §6.5.

### 6.8 Usability Readiness Gate

- Can the target user complete the critical task without outside explanation? Yes — the page is read-only preview content; scrolling through it is self-explanatory with the header/nudge/leaderboard copy providing context.
- Is the first action clear for the expected user mode? N/A in the traditional CTA sense — this page has no primary action of its own; the "next action" is continuing site navigation via the always-present shared header (STORY-001-owned).
- Is success, failure, and partial progress visible in user language? N/A — no transaction, no multi-step process.
- Are recovery, retry, edit, undo, or next-action paths explicit where needed? N/A — no destructive or multi-step actions in scope.
- Remaining usability risks: the element-card icon `alt`-text gap (§6.5) is the only accessibility item this spec adds beyond what the raw source provides — flagged explicitly, not left implicit.

## 7. Handoff Notes

- Important implementation constraints: build all five sections (Hero, Daily card, 12-sign grid, 4-elements, 6-pair leaderboard) as one page in the `isZodiac` route body, reusing the STORY-001 shell without modification. The percentage-ring conic-gradient must be tied to the same value shown as text (§6.2.2), not two independently-hardcoded numbers.
- OQ-driven blocked UX sections, if any: none (see §3).
- Shared pattern changes requiring System UX Memory update: yes, deferred — same deferred status as STORY-001 (no web-shell entry in `data/ux/system/ui_ux_system_memory.md` yet). This story additionally introduces the `<title>` pattern in §6.3, which later page stories (STORY-002, STORY-004..008) should follow rather than reinvent; worth capturing in that same deferred memory update.
- Design-coherence checks downstream should preserve: the three-typeface split and page-container/`--surf` panel conventions (§6.6); the H1/H2 size variance between page types (52px/28px here vs. 66px/38px on Home) is intentional per-page-type design, not an inconsistency to fix.
- Usability checks downstream should preserve: exactly 12 sign cards / exactly 4 element cards / exactly 6 leaderboard rows (AC-4/5/6, directly measurable); the per-page `<title>` pattern (§6.3) for consistency with future page stories.
- Questions or blockers:
  1. **Design reference rendering — same outstanding condition as STORY-001** (not a new blocker introduced by this story): no `design-reference-zodiac-*.png` exists yet; this role has no Bash tool to generate it. A Bash-capable agent should run `render-design-canvas.js --location=cupid-app-design-system --entry="Cupid Web.dc.html" --screen=zodiac --platform=all` before the requirement-level visual-audit gate (AC-10). `req_master.md`'s `Design-Source: UPDATED ... (applied)` line suggests the earlier lock-mismatch blocker (STORY-001 §7 item 3) may already be resolved — worth confirming at render time rather than assuming re-blocked.
  2. **Per-page `<title>` pattern (§6.3) is a new UX decision, not sourced from the design** — flagging explicitly since it sets precedent for 5 more page stories; if Product Owner or the user has a different preferred title convention (e.g. including a tagline, or a different separator), that should override §6.3 before STORY-002/004-008 UX passes copy it.

## Optional Expansion

Not needed — single-page spec, no multi-step flow beyond what §6.2 already covers; no new reusable shell component (only page-local components per §6.4).
