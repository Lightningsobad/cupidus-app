
# UI/UX Specification - Pairing Invite Landing Page (REQ-006 / STORY-004)

## 1. Metadata

- Related Story: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-004/story_master.md`
- Source Requirement Paths: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/req_master.md`, `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-004/requirements/requirements.md`
- Target Directory: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-004/ux/`
- Mode: Extension (reuses STORY-001's shared shell unmodified; new content is one page)
- Status: Draft
- System UX Memory Path: `data/ux/system/ui_ux_system_memory.md`
- System UX Memory Action: Read Only (this run) — that file documents `Cupid Mobile (REQ-001)` only; the web shell record of truth for this requirement is `STORY-001/ux/uiux-spec.md` §6.1/§6.7, cited throughout below.

## 2. Context Summary

- User goal: a person who received a pairing/invite code from their partner lands on this page (most likely via a direct shared-link URL, secondarily via header nav) and understands the pairing-code flow well enough to download the app and pair up.
- Primary user mode: First-time, arriving with intent already primed (they were told "here's your invite").
- Business outcome: converts an invite recipient into an app download and explains the dual-confirmation pairing model that differentiates the product.
- Existing specs reviewed: `STORY-001/ux/uiux-spec.md` (shared header/footer shell, theme/language states, typography system, fluid-grid responsive pattern — all reused unmodified here).
- Existing UI patterns found: STORY-001's Header/Footer global shell (§6.1), three-typeface split (Nunito/Roboto/Roboto Mono, §6.7), `--surf`/soft-border card treatment (§6.7), phone-mockup device-frame pattern (STORY-001 §6.2 hero used a single decorative mockup; this story extends that pattern to a *pair* of mockups connected by a heart-icon connector — new composition, same device-frame visual language).
- Existing components reused or extended: Header, Footer, theme toggle, language toggle, page-global nebula/star background — all reused unmodified from STORY-001. Step-card pattern (icon + title + body) reuses the same anatomy as STORY-001's "How it works" step cards, but with distinct Invite-page-only copy (see §6.2.3 note — do not merge with Home's steps).
- Current UX debt or consistency risks: none new. Carries forward STORY-001's already-flagged a11y gaps (no ARIA on toggle controls, no visible focus rings in raw source) — those are STORY-001 shell scope, not re-specified here, but this page's own new interactive elements (code cells, CTA) must still meet the accessibility bar in §6.6.
- Current organization or hierarchy issues in the affected area: N/A (new page).
- Stable shared patterns vs local debt: shell, typography, and card/spacing system are stable (STORY-001-established); this story's own local pattern (paired phone mockups + connector) is new and single-use to this page, not yet a documented reusable component.
- Open Question Impact source: `STORY-004/requirements/requirements.md` `## Open Question Impact`.
- Open assumptions: none — `Cupid Web.dc.html`'s `isShare` block (lines 387-451) is a complete static prototype for every element this page needs; every value below is cited directly from it, not inferred. Card sample data (`cards` array, lines 794-798) and code-cell letters (`codeCells`, line 778) are sourced from the same file's `renderVals()` data block.

## 3. Open Question Impact

- **OQ-REQ006-1** (frontend framework/stack — RESOLVED at STORY-001, Astro static site):
  - Status: RESOLVED.
  - UX Scope Blocked: none. This spec builds inside the STORY-001 foundation without re-litigating framework choice.
- **OQ-REQ006-2** (backend API dependency — RESOLVED at requirement level: static/informational site, no `api.cupidus.app` calls):
  - Status: RESOLVED.
  - UX Scope Blocked: none.
  - UX Scope Still Designed: everything. Directly relevant here: the 6-cell code display and "Open Cupid" CTA are confirmed presentational-only (zero `fetch`/API calls anywhere in the design source) — no loading/error/success states are designed for either element (§5, §6.6).

## 4. Requirement-To-Design Traceability

- **AC-1 (Discoverability)**: UX Response: §5.1 System Entry And Discoverability — reachable via STORY-001's header "Invite" nav item (already wired to the `share` route, STORY-001 §6.3 Route Map) and via direct URL. Affected: header nav item `share` (already built), new page body.
- **AC-2 (Hero content)**: UX Response: §6.2.1 Hero. Affected: new `<section>` at the `share` route.
- **AC-3 (Code-cell display, non-functional)**: UX Response: §6.2.2 Code-Cell Display. Affected: 6-cell row inside the hero.
- **AC-4 (Open Cupid CTA, presentational only)**: UX Response: §6.2.3 CTA. Affected: hero CTA link.
- **AC-5 (Phone-mockup pairing sequence)**: UX Response: §6.2.4 Phone-Mockup Pairing Sequence. Affected: paired device-frame section.
- **AC-6 (Three-step explainer)**: UX Response: §6.2.5 Three-Step Explainer. Affected: 3-card grid below the mockups.
- **AC-7 (Keepsake-card section)**: UX Response: §6.2.6 Keepsake-Card Section. Affected: card panel at page bottom.
- **AC-8 (Per-page title tag)**: UX Response: §6.5 Component Changes, per-page `<title>` note. Affected: document `<head>` for the `share` route.
- **UI-Fidelity-AC-9 (Visual fidelity)**: UX Response: §6.2 (all subsections) + §6.8 Visual Acceptance Criteria / Design Anchor. Affected: entire Invite page render.
- **AC-10 (Copy fidelity)**: UX Response: every VI/EN string quoted in §6.2 is copy-pasted verbatim from `Cupid Web.dc.html:387-451` and the `codeCells`/`cards` data arrays (`:778`, `:794-798`) — do not paraphrase at implementation time.

## 5. Critical User Tasks And Success Criteria

- **Understand the pairing-code flow and decide to download/open the app**:
  - User Mode: First-time, arrives with a partner-shared invite already in mind.
  - Entry Point: direct URL from a shared invite link (primary), or header "Invite" nav (secondary).
  - Success Signal: user taps the "Open Cupid" CTA, or an App Store/Google Play badge elsewhere in the shell (header "Get the app" CTA, per STORY-001), or reads through the three-step explainer and keepsake section and continues browsing.
  - Primary Risk: a recipient who hasn't installed the app yet needs the page to make clear this is an *explanation* of the flow (illustrative code cells, illustrative "Open Cupid" CTA), not a working code-entry form — if the static code cells read as an interactive input the user will try to type into them and find nothing happens.
- First-use guidance or discoverability needs: the eyebrow/headline/subcopy must establish "this is what pairing looks like" before the user reaches the non-functional code cells, so the illustrative nature is contextually clear without an explicit disclaimer (none exists in the design source — do not add one, that would be a fidelity deviation).
- Completion or post-completion state: N/A — no in-site completion; the real pairing flow happens inside the native app, out of scope here (per AC-3/AC-4 and `OQ-REQ006-2` resolution).
- Retry, edit, undo, or next-action behavior: N/A (no forms, no functional inputs in this story's scope).
- What would make the task feel unfinished or unsafe to the user: a code-cell row or "Open Cupid" CTA that looks interactive but silently does nothing on click with no affordance change — implementation must not add hover/focus states that imply functionality beyond what §6.2.2/§6.2.3 specify (static display, static styled link only).

### 5.1 System Entry And Discoverability

- Existing surface, workflow, or state where the actor starts: the STORY-001 header "Invite" nav item (desktop pill nav and mobile `<select>`, both already route to `share`) and any external shared-link URL pointing at the `share` route.
- Required entry point, navigation item, CTA, or in-flow discovery path: both nav discovery and direct URL are acceptable entry paths (confirmed by Product Owner in `requirements.md` Context Summary) — implementation does not need to add any new discovery affordance beyond the existing shell nav.
- Direct URL only acceptable per PO scope: YES, and it is in fact the *primary* expected path (shared invite links point straight here) — nav discovery is secondary, not primary.
- If direct URL only is acceptable, UX treatment: the hero (eyebrow + headline + subcopy) must establish context with zero prior in-site navigation, exactly as STORY-001's Home hero does for first-time visitors (§6.2.1 below carries that same self-explanatory burden for a partner-invite audience specifically).
- Entry point states: default only. No empty/loading/disabled/permission-limited states apply (static content, no auth, no data fetch, per `OQ-REQ006-2`).
- Surfaces intentionally not updated: header/footer shell markup itself (STORY-001-owned, reused unmodified) — this story only adds the `share` route's page body and its `<title>`.

## 6. UX Design

### 6.1 Global Shell (reused, not re-specified)

This page mounts inside the STORY-001 global shell (sticky header, footer, theme/language state, nebula/star background) unmodified. See `STORY-001/ux/uiux-spec.md` §6.1 (Header/Footer), §6.4 (Theme & Language States), §6.7 (three-typeface split, `--surf` card treatment) for the authoritative shell spec — do not re-derive or duplicate those rules here. The header's "Invite" nav item already targets this page's `share` route (STORY-001 §6.1, §6.3); no shell change is needed for AC-1.

### 6.2 Invite Page (`isShare` state, `Cupid Web.dc.html:387-451`)

Page-level container: `max-width:1000px; margin:0 auto; padding:70px 32px 90px; text-align:center` — narrower than Home's `1200px` shell (this page is a single centered column, not a multi-column layout). Individual subsections below override `text-align` to `left` where the design source does (explainer cards, keepsake panel).

**1. Hero** (`:389-397`)

- Eyebrow: Roboto Mono 11px, `letter-spacing:.14em`, uppercase, `color:var(--acc-mint)`. VI "Lời mời" / EN "Invite".
- H1: Nunito 900, 54px, `letter-spacing:-.03em`, `margin:10px 0 0`, `color:var(--ink)`. VI "Có người vừa gọi bạn về nhà" / EN "Someone just called you home". (Note: smaller than Home's 66px H1 — this page's H1 size is a deliberate step down from the Home hero, keep at 54px, do not reuse Home's 66px value.)
- Subcopy: `max-width:560px; margin:16px auto 0`, 16px, `line-height:1.65`, `color:var(--c64)`. VI "Nhập mã ghép đôi để mở căn nhà chung. Một mã chỉ dùng cho một người — và chỉ dùng được một lần." / EN "Enter your pairing code to open your shared home. One code, one person, one time."

**2. Code-Cell Display, non-functional** (`:392-396`, AC-3)

- Row: `display:flex; justify-content:center; gap:10px; margin:34px 0 0; flex-wrap:wrap`.
- 6 cells, values verbatim from source data `["C","U","P","1","D","7"]` — render as static text content, not placeholder/input values.
- Cell: `width:56px; height:68px; border-radius:18px; background:rgba(36,27,66,.8); border:1px solid rgba(255,127,182,.32); display:grid; place-items:center`; letter: Nunito 900 26px, `color:var(--ink)`.
- Implementation must render these as non-interactive elements (e.g. `<div>`, not `<input>`) — no focus ring, no cursor:text, no keyboard tab-stop, since there is nothing to type into (AC-3 hard requirement: no input capture, no client-side validation, no backend call).

**3. "Open Cupid" CTA, presentational only** (`:397`, AC-4)

- `margin-top:26px`; pill link, `display:inline-block; background:linear-gradient(140deg,#FF7FB6,#F0609E); color:#fff; padding:15px 34px; border-radius:999px; box-shadow:0 10px 30px rgba(255,107,168,.34)`, Nunito 800 16px.
- VI "Mở app Cupid" / EN "Open Cupid".
- Implementation note (AC-4 hard requirement): render as a styled link/button with **no** functional `href` deep-link target and **no** click-triggered redemption/pairing simulation — a `href="#"` or a no-op affordance matching the design source's own `href="#"` is correct; do not wire this to any app-store/deep-link URL, since none exists in the design source and adding one would be a fidelity deviation, not an improvement.

**4. Phone-Mockup Pairing Sequence** (`:398-418`, AC-5)

- Row: `display:flex; align-items:center; justify-content:center; gap:26px; margin-top:60px; flex-wrap:wrap`.
- Both device frames share identical outer dimensions: `width:250px; height:500px; border-radius:38px; background:var(--surf2); border:8px solid var(--bezel); box-shadow:0 28px 70px var(--shadow); overflow:hidden; flex:0 0 auto`. Inner screen: `height:100%; padding:38px 18px 18px; background:radial-gradient(120% 60% at 50% 0%,rgba(183,140,245,.32),transparent 70%),var(--screen); display:flex; flex-direction:column`.
- **Left mockup — "Enter code" state**:
  - Label: Roboto Mono 9px, `letter-spacing:.12em`, uppercase, `color:var(--c5)`, centered. VI "Nhập mã" / EN "Enter code".
  - Heading: Nunito 900 20px, `color:var(--ink)`, centered, `margin-top:14px; line-height:1.25`. VI "Mã của người kia?" / EN "Their code?".
  - 6-cell code-input row (`display:flex; gap:7px; margin-top:22px`), each cell `flex:1; height:52px; border-radius:14px; background:var(--c06)`: first 3 cells are filled (`C`, `U`, `P`, `border:1px solid rgba(255,127,182,.4)`, Nunito 900 20px `color:var(--ink)`), last 3 cells are empty placeholders (`border:1px solid var(--c14)`, no glyph) — this "partially entered" visual state is intentional and must render exactly this way (3 filled + 3 empty), not all-filled or all-empty.
  - Bottom pill CTA (illustrative only, part of the mockup chrome, not a real page-level control): `margin-top:auto; background:linear-gradient(140deg,#FF7FB6,#F0609E); border-radius:999px; padding:14px; text-align:center`, Nunito 800 14px, `color:#fff`. VI "Ghép đôi" / EN "Pair up".
- **Connector** (between the two mockups): `display:flex; flex-direction:column; align-items:center; gap:8px` — two thin `56px × 1px` gradient divider lines (pink-tinted above, lilac-tinted below) framing a `52px × 52px` circular badge, `background:linear-gradient(140deg,#FF7FB6,#B78CF5)`, `box-shadow:0 10px 30px rgba(255,127,182,.4)`, `animation:floaty 5s ease-in-out infinite`, containing a white `favorite` icon at 28px.
- **Right mockup — "Paired" state**:
  - Label: Roboto Mono 9px, `letter-spacing:.12em`, uppercase, `color:var(--acc-mint)` (note: mint, not the left mockup's neutral `--c5` — this color shift signals "success" state), centered. VI "Đã ghép đôi" / EN "Paired".
  - Center: `flex:1; display:grid; place-items:center` containing the "Mochi Sprite" asset at 150×150px (`dc-import name="Mochi Sprite"`).
  - Pet name "Mochi" (literal, not localized): Nunito 900 19px, `color:var(--ink)`, centered.
  - Caption: 12px, `color:var(--c55)`, centered, `margin-top:4px`. VI "Ngày thứ nhất của hai bạn" / EN "Your day one".
  - Stat chip row: `margin-top:auto; display:flex; gap:8px`, two chips each `flex:1; background:var(--c06); border-radius:16px; padding:12px; text-align:center`: number (Nunito 900 16px, `color:var(--ink)`) over label (10px, `color:var(--c5)`) — "2"/"thành viên"/"members" and "1"/"bé pet"/"pet".
- Accessibility: the "Mochi" sprite is meaningful content (pet identity, mirrors STORY-001 §6.6's pet-sprite `alt` rule) — needs a real `alt` (e.g. "Mochi") not empty/decorative alt. Both mockups are illustrative, not interactive — no tab stops on the mockup chrome's own "Pair up" pill or code-input cells (they are inside a decorative device-frame illustration, distinct from the page-level CTA in §6.2.3 which *is* a real, tabbable link).

**5. Three-Step Explainer** (`:419-433`, AC-6)

- Grid: `display:grid; grid-template-columns:repeat(auto-fit,minmax(min(240px,100%),1fr)); gap:16px; margin-top:52px; text-align:left`.
- 3 cards, each `background:var(--surf); border:1px solid var(--c1); border-radius:24px; padding:24px`; icon (26px) → title (Nunito 800 17px, `margin:12px 0 7px`, `color:var(--ink)`) → body (13.5px, `line-height:1.6`, `color:var(--c6)`).
  1. `qr_code_2` icon, `color:var(--acc-pink)` — "Nhận mã" / "Get a code" — "Người kia tạo mã sáu ký tự trong app và gửi cho bạn." / "They create a six-character code in the app and send it over."
  2. `favorite` icon, `color:var(--acc-lilac)` — "Xác nhận cả hai" / "Both confirm" — "Hai người cùng bấm đồng ý — không ai bị ghép một mình." / "You both tap yes — nobody gets paired alone."
  3. `pets` icon, `color:var(--acc-mint)` — "Chọn bé pet" / "Pick a pet" — "Bé pet đầu tiên nở sau ba ngày cả hai đều check-in." / "Your first pet hatches after three days of you both checking in."
- Reuses the same card *anatomy* as STORY-001's "How it works" step cards (icon/numeral + title + body), but this is a **different, Invite-page-specific copy set** — do not substitute Home's "Ghép đôi bằng mã / Chọn một bé pet / Sống cùng nó" copy here, and do not merge the two into one shared card component with shared content; they are separately-sourced sections that happen to share visual anatomy.

**6. Keepsake-Card Section** (`:434-449`, AC-7)

- Panel: `margin-top:56px; background:var(--surf); border:1px solid var(--c1); border-radius:30px; padding:34px; text-align:left`.
- Heading: Nunito 800 20px, `color:var(--ink)`, `margin-bottom:6px`. VI "Thẻ kỷ niệm" / EN "Keepsake cards".
- Description: 14px, `line-height:1.6`, `color:var(--c62)`, `max-width:560px`. VI "Mỗi mốc quan trọng sinh ra một tấm thẻ vuông đẹp để đăng lên story — không lộ tin nhắn, chỉ lộ việc hai bạn đang ổn." / EN "Every milestone mints a square card made for stories — no private messages, just proof that you two are doing fine."
- Card grid: `display:grid; grid-template-columns:repeat(auto-fit,minmax(200px,1fr)); gap:16px; margin-top:22px`. 3 sample cards, each `aspect-ratio:1; border-radius:24px; border:1px solid var(--c12); padding:22px; display:flex; flex-direction:column; justify-content:space-between`, background per-card gradient (below).
  - Top: tag label, Roboto Mono 9.5px, `letter-spacing:.14em`, uppercase, color per-card.
  - Middle: big value, Nunito 900 30px, `line-height:1.05`, `color:var(--ink)`, `letter-spacing:-.02em`; sub-copy below it, 12.5px, `line-height:1.5`, `color:var(--c66)`, `margin-top:8px`.
  - Bottom: `display:flex; align-items:center; gap:7px` — `favorite` icon 15px `color:var(--acc-pink)` + "Cupid" wordmark, Nunito 800 12px, `color:var(--c55)` (literal brand mark on every card, not localized).
  - Card 1: tag "Milestone" (`color:var(--acc-pink)`), `bg:linear-gradient(150deg,rgba(255,127,182,.24),rgba(183,140,245,.16)),var(--screen)`, big "214", sub VI "ngày cùng nhau, Bo đã thành linh thú" / EN "days together — Bo became a spirit".
  - Card 2: tag "Streak" (`color:var(--acc-mint)`), `bg:linear-gradient(150deg,rgba(121,226,205,.2),rgba(23,17,41,.4)),var(--screen)`, big "30/30", sub VI "check-in tâm trạng, không bỏ ngày nào" / EN "mood check-ins, no day missed".
  - Card 3: tag "Zodiac" (`color:var(--acc-butter)`), `bg:linear-gradient(150deg,rgba(255,201,126,.2),rgba(183,140,245,.14)),var(--screen)`, big "92%", sub VI "tương hợp hôm nay — Cự Giải × Kim Ngưu" / EN "compatible today — Cancer × Taurus".
  - Card tag labels ("Milestone", "Streak", "Zodiac") are literal, not localized, per the design source's data — ship as-is in both VI and EN.

### 6.3 Route Confirmation

The `share` route already exists in STORY-001's Route Map (`STORY-001/ux/uiux-spec.md` §6.3) with header/mobile-nav and footer entries wired but no body. This story fills that body only — no new nav entries, no route-map changes. VI/EN nav label stays "Ghép đôi"/"Invite" as already specified.

### 6.4 Theme & Language States (reused)

No new theme/language behavior. This page must render correctly across all 4 combinations (dark×vi, dark×en, light×vi, light×en) using the shell-level state STORY-001 already established (`STORY-001/ux/uiux-spec.md` §6.4) — every `var(--*)` token referenced in §6.2 above resolves through that same token table (`Cupid Web.dc.html:16-17`).

### 6.5 Component Changes

- **Invite hero, code-cell display, CTA, phone-mockup pairing sequence, three-step explainer, keepsake-card panel** (all New, this story only): see §6.2.1–§6.2.6. None of these are reusable cross-page components in this story's scope — flag to a later story's UX pass if a future page needs a similar "static illustrative device mockup pair" or "sample-card grid" pattern rather than assuming reuse now.
- **Per-page `<title>`** (New, addresses carried-forward DEF-2): the `share` route must set a distinct, descriptive `<title>` (e.g. "Cupid — Ghép đôi" / "Cupid — Invite" style, localized to match the active language state) — the design source's raw markup does not define a `<title>` per page-state (it's a single-file prototype), so this is an implementation-level addition, not a source citation; keep it short, brand-prefixed, and distinct from Home's and every other page's title so DEF-2 is actually closed (a generic "Cupid" title reused unchanged everywhere would not satisfy AC-8).

### 6.6 Responsive And Accessibility Notes

- Responsive behavior for affected screens: this page has no explicit named breakpoints of its own — the code-cell row, hero, phone-mockup row, three-step grid, and keepsake-card grid all use fluid `flex-wrap`/`auto-fit`/`minmax` reflow (§6.2.2, §6.2.4, §6.2.5, §6.2.6), consistent with STORY-001's "no fixed breakpoints beyond the 1024px nav swap" rule (`STORY-001/ux/uiux-spec.md` §6.6). The two 250px-wide phone mockups plus their connector (`gap:26px`) will wrap to a stacked column on narrow viewports via `flex-wrap:wrap` — verify at implementation that the connector's floating heart badge does not orphan awkwardly between stacked mockups; center it above/below consistently.
- Content or action reprioritization on smaller surfaces: none required beyond natural fluid reflow — hero copy and the "Open Cupid" CTA remain first in DOM order and are not decorative, so they stay above-the-fold priority on all viewport widths.
- Keyboard and focus expectations: the "Open Cupid" CTA (§6.2.3) must be a real, tabbable, Enter/Space-activatable link with a visible focus ring (same hard requirement as STORY-001 §6.6 — not present in the raw source's inline styles, must be added at implementation). The 6 hero code cells (§6.2.2) and the phone-mockup's internal chrome (§6.2.4) must **not** receive tab stops — they are non-interactive/decorative, and adding focus states there would misrepresent them as functional controls, contradicting AC-3/AC-4.
- Screen reader / semantics notes: wrap this page's content in `<main>` (shell already provides `<header>`/`<footer>` landmarks per STORY-001 §6.6). The 6 hero code-cell letters and the "Mochi" pet sprite are meaningful content — code cells should be reachable as static text (e.g. a labelled group, not individually focusable inputs), and the sprite needs a real `alt="Mochi"` (see §6.2.4 note). Mark the page-global nebula/star background `aria-hidden="true"` (inherited from shell, not re-specified here).
- Error / status communication expectations: N/A — no forms, no async operations, no functional pairing logic in this story's scope (confirmed by `OQ-REQ006-2` resolution and AC-3/AC-4).

### 6.7 Visual Direction Notes

- Typography, density, or spacing posture: same three-typeface split as the rest of REQ-006 (Nunito for display/headline/CTA, Roboto for body, Roboto Mono uppercase-tracked for eyebrow/caption/mono-numeral accents) — no new typeface introduced. This page's H1 is intentionally smaller (54px) than Home's (66px); do not normalize the two.
- Surface and container treatment: same soft `--surf` translucent panel language as Home (24-30px radii, thin low-opacity borders) for the explainer cards and keepsake panel; the phone mockups reuse Home's hero device-frame elevation treatment (`--shadow`-based box-shadow, 8px `--bezel` border) — the only two elements on this page with drop-shadow elevation, consistent with STORY-001's "no hard shadows on content cards" rule.
- Color or status-semantics treatment: the right ("Paired") mockup's mint-colored label vs. the left ("Enter code") mockup's neutral-gray label is the one deliberate color-as-status signal on this page (success/complete vs. neutral/in-progress) — preserve that contrast exactly, do not make both labels the same color.
- Anti-patterns explicitly avoided: do not turn the illustrative code cells into a real input component "for better UX" — that would violate AC-3's explicit non-functional requirement; do not wire the "Open Cupid" CTA to any real store/deep-link URL not present in the design source (AC-4).

### 6.8 Visual Acceptance Criteria / Design Anchor

- Visual reference(s): design-source detection is now unblocked for this requirement — `data/devops/system/design-fidelity-config.json` shows `design_source.entry: "Cupid Web.dc.html"`, `locked: true` (re-detected and entry-confirmed 2026-08-21, superseding the earlier `Cupid App.dc.html` mobile lock STORY-001 flagged as blocked). A Bash-capable agent (Tech Lead or dev) can now run `render-design-canvas.js --location=cupid-app-design-system --entry="Cupid Web.dc.html" --screen=share --platform=all` to produce `design-reference-share-*.png` for the reviewer/DONE gate — this role has no Bash tool and could not run it directly. Until that render exists, the measurable rules below (pulled directly from `Cupid Web.dc.html:387-451`, exact line numbers cited throughout §6.2) are the interim visual anchor.
- Layout & spacing (key paddings, gaps, sizes): page container `padding:70px 32px 90px; max-width:1000px`; code-cell row `gap:10px; margin-top:34px`; CTA `margin-top:26px`; mockup row `gap:26px; margin-top:60px`; explainer grid `gap:16px; margin-top:52px`, card `padding:24px`; keepsake panel `padding:34px; margin-top:56px`, card grid `gap:16px; margin-top:22px`, card `padding:22px`.
- Color & status semantics (hex / token names): brand accents reused from the shared token table (`Cupid Web.dc.html:16-17`, cited in `STORY-001/ux/uiux-spec.md` §6.8) — `--acc-pink #FF7FB6`, `--acc-lilac #B78CF5`, `--acc-mint #79E2CD`, `--acc-butter #FFC97E`; plus this page's card-specific gradients listed verbatim in §6.2.6.
- Typography (sizes, weights, line-height): H1 Nunito 900 54px/1 (`letter-spacing:-.03em`); hero subcopy Roboto 16px/1.65; code-cell letter Nunito 900 26px; CTA label Nunito 800 16px; mockup heading Nunito 900 20px/1.25; step-card title Nunito 800 17px; step-card body 13.5px/1.6; keepsake heading Nunito 800 20px; keepsake card big-value Nunito 900 30px/1.05.
- Component states to verify (default / hover / active / disabled / loading / error / empty): CTA default + hover (add a hover treatment consistent with STORY-001's other gradient CTAs — brightness/filter lift, since the raw source has no explicit hover rule for this specific link but the shell's other CTAs establish the pattern) + visible focus ring (new, a11y requirement). Code cells and mockup chrome: default only, explicitly no interactive states (§6.6). No loading/error/empty states apply anywhere on this page.
- Responsive checkpoints to verify: verify at 375, 768, 1024, 1440px that the phone-mockup pair wraps cleanly via `flex-wrap` without cutting off the connector badge, and that the explainer/keepsake grids never drop a card below their `minmax` floor (240px explainer cards, 200px keepsake cards).

### 6.9 Usability Readiness Gate

- Can the target user complete the critical task without outside explanation? Yes — hero headline/subcopy plus the three-step explainer together explain both "what a pairing code is" and "how the flow works" without prior context.
- Is the first action clear for the expected user mode? Yes — the "Open Cupid" CTA is the single, prominent, gradient-styled call to action directly below the illustrative code cells, in the same visual position a real code-redemption action would occupy.
- Is success, failure, and partial progress visible in user language? N/A for this story — no real transaction happens on this page (illustrated only via the right "Paired" mockup, which is descriptive, not a live status).
- Are recovery, retry, edit, undo, or next-action paths explicit where needed? N/A — no destructive or multi-step actions in scope.
- Remaining usability risks: the biggest risk is a user attempting to type into the illustrative code cells or the mockup's internal "Enter code" chrome and getting no response — mitigated by rendering both as clearly non-interactive (no cursor:text, no focus affordance, per §6.6) rather than by any added copy/disclaimer (none exists in source, adding one would be a fidelity deviation).

## 7. Handoff Notes

- Important implementation constraints: this is a single new page inside the STORY-001 shell — do not modify header/footer/theme/language shell code as part of this story. Build all six subsections of §6.2 (hero, code cells, CTA, phone-mockup pair, three-step explainer, keepsake panel) as one continuous page matching the source's single `isShare` block.
- OQ-driven blocked UX sections, if any: none (see §3; both requirement-level OQs are resolved).
- Shared pattern changes requiring System UX Memory update: no new *shell-level* shared pattern introduced (paired-mockup and sample-card-grid compositions are page-local, not proposed as reusable components yet) — no update needed from this story.
- Design-coherence checks downstream should preserve: the three-typeface split and `--surf` card language (STORY-001 §6.7, reused here); the deliberate 54px-vs-66px H1 size distinction from Home (§6.7); the mint-vs-neutral label color as the only status signal on this page (§6.7).
- Usability checks downstream should preserve: code cells and mockup chrome must never gain interactive affordances (§6.6, §6.9) even as future stories add real functionality elsewhere in the app — this page's non-functional status is a hard, source-confirmed requirement (AC-3/AC-4), not a placeholder to "finish" later inside this requirement's scope.
- Questions or blockers:
  1. **Design reference rendering — no longer blocked on entry-lock, but still not producible by this role**: unlike STORY-001's note (written when `design_source.entry` still pointed at the mobile `Cupid App.dc.html`), the config is now correctly locked to `Cupid Web.dc.html` (`data/devops/system/design-fidelity-config.json`, confirmed above in §6.8). No `Design-Source: UPDATE` trigger or re-lock is needed for this story. The remaining gap is purely tool access: this role has no Bash tool, so it cannot run `render-design-canvas.js --screen=share`. Recommended next step: a Bash-capable agent (Tech Lead or dev, once assigned) runs that render command from the story worktree to produce `design-reference-share-*.png` before the UI-lane review gate (UI-Fidelity-AC-9) needs it.
  2. No other blockers. All acceptance criteria in `STORY-004/requirements/requirements.md` are addressed by §6.2–§6.6 above with source line citations.

UX_COMPLETE: YES
Output path: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-004/ux/uiux-spec.md`
