
# UI/UX Specification - Frontend App Foundation & Home Landing Page (REQ-006 / STORY-001)

## 1. Metadata

- Related Story: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/story_master.md`
- Source Requirement Paths: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/req_master.md`, `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/requirements/requirements.md`
- Target Directory: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/ux/`
- Mode: Greenfield (new web surface; System UX Memory only covers the unrelated mobile app, REQ-001)
- Status: Draft
- System UX Memory Path: `data/ux/system/ui_ux_system_memory.md`
- System UX Memory Action: Read Only (this run) — see §7 Handoff Notes for why an update is deferred, not skipped

## 2. Context Summary

- User goal: a prospective couple lands on `cupidus.app` (direct URL, first visit) and understands what Cupid is, sees the app is real/polished, and can either download the app or keep browsing the marketing site.
- Primary user mode: First-time.
- Business outcome: primary marketing entry point driving app downloads; establishes the shared shell every later REQ-006 page story (STORY-002..008) reuses unmodified.
- Existing specs reviewed: none — this is the first REQ-006 story; no prior UX spec exists for this feature area.
- Existing UI patterns found: none for web. `data/ux/system/ui_ux_system_memory.md` exists but documents `Cupid Mobile (REQ-001)` only (Flutter, iOS/Android, 5-tab bottom nav, `cupid-mobile-design/` source) — a different product surface. Brand tokens (pink/lilac/mint/butter/peach palette, Nunito/Roboto type family, nebula/twinkle background motif) are shared brand identity and are reused; the mobile page-anatomy/navigation rules (bottom tabs, platform-adaptive iOS/Material chrome) do not apply to web and are not reused.
- Existing components reused or extended: N/A (new surface).
- Current UX debt or consistency risks: none yet — greenfield for web.
- Current organization or hierarchy issues in the affected area: N/A.
- Stable shared patterns vs local debt: N/A (first web story).
- Open Question Impact source: `STORY-001/requirements/requirements.md` `## Open Question Impact`.
- Open assumptions: none — the design source (`cupid-app-design-system/Cupid Web.dc.html`) is a complete, working interactive prototype for the header/nav/footer shell and the Home page; every element below is sourced directly from it (exact line numbers cited throughout), not inferred.

## 3. Open Question Impact

- **OQ-REQ006-1** (frontend framework/stack — UNRESOLVED, Tech Lead-owned):
  - Status: UNRESOLVED, blocks implementation only.
  - UX Scope Blocked: nothing in this spec. All decisions below are markup structure, CSS tokens, interaction states, and responsive rules — expressed independent of any specific framework (React/Next.js/Vite/static). Tech Lead should be able to map this spec onto whichever stack is chosen without redesign.
  - UX Scope Still Designed: full scope of this story (shared shell + Home page).
  - UX Decision: proceed with full UX design; do not wait on the framework decision.
- **OQ-REQ006-2** (backend API dependency — RESOLVED at requirement level: static/informational site, no `api.cupidus.app` calls):
  - Status: RESOLVED.
  - UX Scope Blocked: none.
  - UX Scope Still Designed: everything — confirmed by the design source's own FAQ copy (line 818): *"Chưa có bản web... trang web này chỉ để giới thiệu và nhận lời mời ghép đôi"* / *"Not yet [a web app]. This site is for introductions and pairing invites."* The design source is explicitly aware it is a marketing site, not the product.
  - UX Decision: no loading/error states for API calls are designed; all interactive elements below are client-side only (theme toggle, language toggle, in-page nav) or static links (download badges, mailto in later stories).

## 4. Requirement-To-Design Traceability

- **AC-1 (Framework foundation)**: UX Response: N/A (Tech Lead scope). Affected: none.
- **AC-2 (Shared chrome — header)**: UX Response: §6.1 Header/Nav, sourced verbatim from `Cupid Web.dc.html:46-77`. Affected Screen/Component: global `<header>` shell, present on every route.
- **AC-3 (Shared chrome — footer)**: UX Response: §6.1 Footer, sourced from `Cupid Web.dc.html:655-676` + link data `:831-848`. Affected: global `<footer>`.
- **AC-4 (Theme + language persistence)**: UX Response: §6.4 Theme & Language States, sourced from `Cupid Web.dc.html:683-731`. Affected: header theme toggle, header VI/EN toggle, `document.body.dataset.theme/lang`, `localStorage["cupid-web-theme"]`.
- **AC-5 (Nav routing, no dead links)**: UX Response: §6.1 Header/Nav + §6.3 Route Map. Affected: header desktop nav (7 items), mobile `<select>` nav (7 items), footer link columns (adds the 8th route, Legal).
- **UI-Fidelity-AC-6 (Home page visual fidelity)**: UX Response: §6.2 Home Page (Hero, Features, Pet-cast teaser, How it works — all four sections that make up the design source's `isHome` state, `Cupid Web.dc.html:79-211`) + §6.8 Visual Acceptance Criteria. Affected: Home route.
- **AC-7 (Copy fidelity)**: UX Response: every VI/EN string quoted in this spec is copy-pasted verbatim from the design source's `data-vi`/`data-en` spans and the `renderVals()` data arrays (`:715-848`) — do not paraphrase at implementation time.
- **AC-8 (Production deploy)**: UX Response: N/A (DevOps/Tech Lead scope). Affected: none.

## 5. Critical User Tasks And Success Criteria

- **Understand what Cupid is and decide to download it (or keep exploring)**:
  - User Mode: First-time.
  - Entry Point: direct URL to `cupidus.app` (no referring product surface — this is a brand-new marketing site).
  - Success Signal: user taps an App Store/Google Play badge, or the header "Get the app" CTA, or navigates deeper into the site (Pets/Zodiac/Blog/etc.) instead of bouncing.
  - Primary Risk: a first-time visitor with zero prior context needs the hero headline + subcopy to establish the product concept ("a shared pet that grows with how you care for each other") within the first viewport — if that's unclear, the download CTAs have no motivating context.

- First-use guidance or discoverability needs: none beyond the hero copy itself — this is a static marketing page, no onboarding flow.
- Completion or post-completion state: N/A (external app-store deep links; no in-site completion state to design).
- Retry, edit, undo, or next-action behavior: N/A (no forms, no destructive actions in this story's scope).
- What would make the task feel unfinished or unsafe to the user: broken/dead nav links to the other 7 pages (explicitly covered by AC-5); a theme/language toggle that doesn't persist across navigation (explicitly covered by AC-4).

### 5.1 System Entry And Discoverability

- Existing surface, workflow, or state where the actor starts: none — `cupidus.app` is the entry point itself (brand-new public site, no existing product surface links here per story context).
- Required entry point, navigation item, CTA, or in-flow discovery path: direct URL only; this is expected and correct for a marketing landing page.
- Direct URL only acceptable per PO scope: YES (story context explicitly frames this as "direct URL entry (brand-new public marketing site; no existing product surface links here)").
- If direct URL only is acceptable, UX treatment: the Home page itself must be self-explanatory with no assumed context — hero headline, subcopy, and features grid carry the full burden of explaining the product (see §6.2).
- Entry point states: default only. No empty/loading/disabled/permission-limited states apply (static content, no auth, no data fetch).
- Surfaces intentionally not updated: N/A (greenfield).

## 6. UX Design

### 6.1 Global Shell (every route)

Sourced verbatim from `Cupid Web.dc.html:46-77` (header) and `:655-676` + `:831-848` (footer). This shell renders identically on Home and on all 7 other REQ-006 page stories.

**Header** (`Cupid Web.dc.html:46-77`)
- Reuse / Extend / New: New (first web shell).
- Layout: `position: sticky; top: 0; z-index: 50`, `backdrop-filter: blur(18px)`, background `var(--header)`, `border-bottom: 1px solid var(--c09)`. Inner row: `max-width: 1200px; margin: 0 auto; padding: 14px 32px; display: flex; align-items: center; gap: 28px`.
- Logo (leftmost, `margin-right: auto` so it pins left while nav/actions cluster right): 34×34px tile, `border-radius: 12px`, background `linear-gradient(140deg, {accent}, #B78CF5)` (accent defaults `#FF7FB6`), centered `favorite` icon (Material Symbols Rounded, white, 20px) + wordmark "Cupid" (Nunito 900, 21px, `letter-spacing: -.02em`). Clicking the logo navigates Home.
- Desktop primary nav (`[data-nav]`, visible ≥1025px, hidden ≤1024px): 7 pill buttons, `gap: 4px`, Nunito 700 13.5px. Items in order: Home/Trang chủ, Pets/Pet, Zodiac/Hoàng đạo, Invite/Ghép đôi (routes to the `share` page), Blog/Blog, About/Về chúng mình, Support/Hỗ trợ. Active item: `background: rgba(255,127,182,.16)`, `color: var(--acc-pink)`; inactive: transparent bg, `color: var(--c68)`; hover (any): `background: var(--c09); color: var(--ink)`.
- Mobile nav (`[data-navm]`, visible ≤1024px, hidden ≥1025px): single `<select>` replacing the pill row, same 7 items as options, styled as a pill (`border-radius: 999px`, `background: var(--c08)`, `border: 1px solid var(--c16)`), selecting an option navigates.
- Breakpoint is exactly **1024px** (`@media (max-width:1024px)` hides `[data-nav]`/shows `[data-navm]`; `@media (min-width:1025px)` is the inverse) — implement as a hard swap at 1024/1025px, not a gradual reflow.
- Theme toggle: 38×38px circular icon button, `background: var(--c07)`, `border: 1px solid var(--c1)`. Icon is `light_mode` when currently dark (offering to switch to light) / `dark_mode` when currently light. `title` attribute carries the localized action label ("Chuyển sang Hồng mơ mộng" / "Switch to Dreamy Pink" when dark→light; "Chuyển sang nền tối" / "Switch to dark" when light→dark) — note the light theme is branded "Dreamy Pink" in copy, not just "light".
- Language toggle: segmented pill (`display:flex; background:var(--c07); border-radius:999px; padding:3px; border:1px solid var(--c1)`) with two buttons "VI" / "EN" (Roboto Mono 500 11px). Active language: `background:#FF7FB6` solid, `color: var(--ink)`. Inactive: transparent, `color: var(--c6)`.
- "Get the app" CTA (rightmost): pill button, `background: linear-gradient(140deg, {accent}, #F0609E)`, white text, Nunito 800 13.5px, `padding: 11px 20px`, `box-shadow: 0 8px 24px rgba(255,107,168,.34)`, hover `filter: brightness(1.07)`. Copy: "Tải app" / "Get the app". In the design source this scrolls to Home (`goDownload` = `nav("home")`); since Home is where the App Store/Google Play badges live, that is the correct target on every page.
- Key Behavior / State Notes: header persists identically across all pages this story wires (Home built; Pets/Zodiac/Invite/Blog/About/Support/Legal routes exist but render nothing yet per story's out-of-scope note).
- Accessibility Notes: theme and language toggle buttons must expose their current state and action via accessible name (the design source uses `title=` for the theme button — carry that or an equivalent `aria-label` through; do not rely on icon glyph alone). Mobile `<select>` must have an accessible label (e.g. visually-hidden `<label>` or `aria-label`, since the design source relies on visual pill styling alone — a11y gap to close at implementation, not present in raw source). Active nav item should be exposed via `aria-current="page"` in addition to the visual pink pill (visual-only state indication is not sufficient).

**Footer** (`Cupid Web.dc.html:655-676`, link data `:831-848`)
- Reuse / Extend / New: New.
- Layout: `border-top: 1px solid var(--c09); background: var(--footer)`. Grid row: `max-width:1200px; margin:0 auto; padding:48px 32px 34px; grid-template-columns: repeat(auto-fit, minmax(min(210px,100%),1fr)); gap:32px`.
- Column 1 — brand block: 30×30px logo tile (same gradient as header) + "Cupid" wordmark (Nunito 900 19px), then tagline "Nuôi tình yêu như nuôi một bé pet. Làm tại Việt Nam." / "Grow your love like a little pet. Made in Vietnam." (13px, `color: var(--c5)`, `max-width: 280px`).
- Column 2 — "Sản phẩm"/"Product": Home, Pets, Zodiac, Invite (→ `share` route), Blog.
- Column 3 — "Công ty"/"Company": About, Press kit (→ **same** `about` route, not a separate page — press kit is a section within About, per STORY-006 scope), Support.
- Column 4 — "Pháp lý"/"Legal": Privacy and Terms — **both** links route to the single `legal` page (`Cupid Web.dc.html:845-846`; the design source does not split Privacy and Terms into separate pages, matching STORY-008 "Privacy & Terms Page" being one combined story).
- Column headers: Roboto Mono 10px, `letter-spacing:.14em`, uppercase, `color: var(--c42)`. Links: Roboto 13.5px, `color: var(--c62)`, hover `color: var(--acc-pink)`.
- Copyright line below the grid, full-width: "© 2026 Cupid Labs", Roboto Mono 11px, `color: var(--c36)`.
- Key Behavior / State Notes: the footer's "Legal" column is the **only** place the `legal` route is reachable — it is not in the header's 7-item primary/mobile nav (see §6.3 Route Map). This is intentional per the design source, not an omission to "fix."

### 6.2 Home Page (`isHome` state, `Cupid Web.dc.html:79-211`)

The design source's Home state renders four sections in this order. All four are part of the single home-page render and must ship together for AC-6 fidelity to hold — the story requirements text names "hero" and "features grid" explicitly, but the source's actual `isHome` block also contains the pet-cast teaser and "How it works" sections immediately after features, as one continuous page. See §7 Handoff Notes for the exact AC-6 wording gap this closes.

**1. Hero** (`:80-140`)
- Layout: two-column grid, `max-width:1200px; padding:76px 32px 30px; grid-template-columns: repeat(auto-fit, minmax(min(420px,100%),1fr)); gap:48px; align-items:center` — collapses to a single stacked column when the viewport can't fit two ≥420px columns (fluid `auto-fit`/`minmax`, not a fixed breakpoint).
- Left column, top to bottom:
  - Eyebrow badge: pill, `background: var(--tint-mint)`, `border: 1px solid var(--tint-mint-line)`, `padding: 7px 14px`; `auto_awesome` icon (15px, mint) + label "Dành cho hai người" / "Built for two" (Roboto Mono 11px, uppercase, `letter-spacing:.12em`, mint).
  - H1: Nunito 900, **66px**, `line-height:1.04`, `letter-spacing:-.03em`. VI: "Nuôi tình yêu như nuôi một **bé pet**." EN: "Grow your love like a little **pet**." — the last word/phrase ("bé pet" / "pet") is a gradient-text span: `background:linear-gradient(120deg,#FF7FB6,#B78CF5); -webkit-background-clip:text; -webkit-text-fill-color:transparent`.
  - Subcopy: max-width 520px, 17px, `line-height:1.65`, `color:var(--c66)`. VI: "Cupid là không gian riêng của hai người: một bé pet chung lớn lên theo cách hai bạn quan tâm nhau, nhật ký tâm trạng, thử thách mỗi ngày và những tấm thẻ kỷ niệm đáng để chia sẻ." EN: "Cupid is a private space for two: a shared pet that grows with how you care for each other, mood journals, daily quests, and keepsake cards worth sharing."
  - Download badges row (`gap:12px`, wraps): App Store badge and Google Play badge, each a dark pill (`background:#0D0918; border:1px solid rgba(247,238,251,.22); border-radius:14px; height:58px; padding:0 22px 0 18px`) with the platform SVG glyph + two-line label ("Download on the" / "App Store", "Get it on" / "Google Play" — these two lines are not localized in the source, ship as-is in both VI and EN per copy fidelity). Hover: `border-color:rgba(255,127,182,.55); background:#130D22`.
  - Platform note: "iOS 15+ · Android 10+ · miễn phí tải" / "iOS 15+ · Android 10+ · free to download" — Roboto Mono 10.5px, `color:var(--c42)`.
  - Stat counters row (3 items, `gap:34px`): each is a big number (Nunito 900 26px) over a small uppercase Roboto Mono 10.5px label (`color:var(--c46)`): **6** "bé pet"/"pets", **12** "cung hoàng đạo"/"zodiac signs", **0₫** "để bắt đầu"/"to start". These are the "usage stats" named in the story's Context Summary — confirm at implementation this is exactly what ships (static marketing numbers, not live/dynamic counters — no API per OQ-REQ006-2).
- Right column: decorative phone-mockup illustration (`min-height:560px`, centered) — a device frame (300×600px, `border-radius:44px`, 9px bezel border) containing a mini "app preview" card: day counter ("Ngày thứ 214"/"Day 214"), a battery-style "92%" chip, the "Bo" pet sprite (`dc-import name="Bo Sprite"`), pet name + status line ("đang chờ hai bạn tưới cây"/"waiting for you both"), a "Today's quest" card, and a "Care for Bo" pill CTA — all non-interactive, purely illustrative of the real app. Floats gently (`animation: floaty 7s ease-in-out infinite`).
- Background (page-global, behind everything, `aria-hidden`): fixed nebula radial-gradient wash + ~10 twinkling star dots (`@keyframes twinkle`) + two large blurred floating color blobs (`@keyframes floaty`). Present on every page, not hero-specific — implement once at the shell/layout level.

**2. Features grid** (`:142-152`, data `:734-739`)
- Layout: `max-width:1200px; padding:56px 32px`; grid `repeat(auto-fit, minmax(260px,1fr)); gap:18px`.
- 4 cards, each: `background:var(--surf); border:1px solid var(--c09); border-radius:26px; padding:26px`; hover lifts (`translateY(-4px)`) and brightens border. Card anatomy: 46×46px icon tile (tinted bg per feature, `border-radius:16px`) → title (Nunito 800 17.5px) → description (13.5px, `color:var(--c6)`).
- Content (verbatim, do not paraphrase):
  1. `pets` icon, pink — "Pet chung"/"A shared pet" — "Bé pet lớn lên bằng những việc nhỏ: check-in, lời nhắn, thử thách hoàn thành cùng nhau."/"Your pet grows on small things: check-ins, notes, and quests you finish together."
  2. `mood` icon, lilac — "Tâm trạng thật"/"Honest moods" — "Một chạm để nói hôm nay bạn thế nào. Đối phương thấy ngay, không cần hỏi \"sao thế?\"."/"One tap to say how today feels. They see it instantly — no need to ask what's wrong."
  3. `auto_awesome` icon, butter — "Hoàng đạo mỗi ngày"/"Daily zodiac" — "Chỉ số tương hợp và một gợi ý nhỏ cho hai bạn, đọc trong mười giây."/"A compatibility read and one small nudge for the two of you, in ten seconds."
  4. `lock` icon, mint — "Chỉ hai người"/"Just the two" — "Không feed, không người lạ. Việc quan trọng cần cả hai bấm đồng ý."/"No feed, no strangers. Anything that matters needs both of you to agree."

**3. Pet-cast teaser** (`:154-194`, data `:741-748`)
- Section header row (`justify-content:space-between`, wraps): eyebrow "Dàn pet"/"The cast" (Roboto Mono 11px, lilac) + H2 "Sáu bé, sáu tính cách"/"Six pets, six personalities" (Nunito 900 38px) on the left; "Xem tất cả"/"Meet them all" pill button on the right, routes to the Pets page (out of scope this story, but the link must exist and not 404 per AC-5).
- Grid: `repeat(auto-fit, minmax(170px,1fr)); gap:16px`. 6 cards (Bo/pink, Bun/lilac, Kem/mint, Mochi/butter, Sua/peach, Xoài/pink), each a tinted rounded card with the pet sprite (`dc-import`), name (Nunito 900 19px), and a one-word trait label (Roboto Mono 10px uppercase — "Trung thành"/"Loyal", "Nhút nhát"/"Shy", "Bình tĩnh"/"Calm", "Nghịch ngợm"/"Playful", "Nhõng nhẽo"/"Clingy", "Lì lợm"/"Stubborn"). Hover lifts card (`translateY(-6px)`).
- Note: this teaser only needs the 6 pet sprites + names/traits shown here — the full Pets page (species detail, evolution stages, etc.) is STORY-002 scope and out of scope here.

**4. "How it works"** (`:196-210`, data `:750-754`)
- One large gradient-bordered card (`background:linear-gradient(140deg,rgba(183,140,245,.2),rgba(255,127,182,.14)); border-radius:36px; padding:56px`), grid `repeat(auto-fit,minmax(230px,1fr)); gap:34px`.
- Header spans full width: eyebrow "Cách hoạt động"/"How it works" (butter) + H2 "Ba bước là có một mái nhà chung"/"Three steps to a shared home".
- 3 numbered steps (large `01`/`02`/`03` numeral in `var(--numeral)`, Nunito 900 44px, above a step title + description):
  1. "Ghép đôi bằng mã"/"Pair with a code" — "Một người tạo mã sáu ký tự, người kia nhập. Không cần tìm kiếm, không cần bạn bè chung."/"One creates a six-character code, the other enters it. No search, no mutual friends."
  2. "Chọn một bé pet"/"Choose a pet" — "Cả hai bấm chọn cùng lúc. Bé pet là của hai người, không của riêng ai."/"You both confirm together. The pet belongs to both of you, never to one."
  3. "Sống cùng nó"/"Live with it" — "Check-in tâm trạng, làm thử thách, xem bé lớn lên. Mỗi mốc sinh ra một tấm thẻ kỷ niệm."/"Check in, finish quests, watch it grow. Every milestone mints a keepsake card."

### 6.3 Route Map (AC-5)

| Route key | VI label | EN label | In desktop/mobile primary nav? | In footer? | Content this story |
|---|---|---|---|---|---|
| `home` | Trang chủ | Home | Yes | Yes (Product col) | Full page (§6.2) |
| `pets` | Pet | Pets | Yes | Yes (Product col) | Route exists, no body (STORY-002) |
| `zodiac` | Hoàng đạo | Zodiac | Yes | Yes (Product col) | Route exists, no body (STORY-003) |
| `share` | Ghép đôi | Invite | Yes | Yes (Product col) | Route exists, no body (STORY-004) |
| `blog` | Blog | Blog | Yes | Yes (Product col) | Route exists, no body (STORY-005) |
| `about` | Về chúng mình | About | Yes | Yes (Company col) | Route exists, no body (STORY-006); footer "Press kit" link is the same route |
| `support` | Hỗ trợ | Support | Yes | Yes (Company col) | Route exists, no body (STORY-007) |
| `legal` | (Privacy/Terms) | (Privacy/Terms) | **No** | Yes (Legal col, 2 links → same route) | Route exists, no body (STORY-008) |

Do not add an 8th header nav item for `legal` to "complete" the set — the design source deliberately reaches it only through the footer, and adding it to the header would be a fidelity deviation from `Cupid Web.dc.html`, not a fix. AC-5's "nav items for all 8 pages" is satisfied by the combined header+footer nav surface, matching the source exactly.

### 6.4 Theme & Language States (AC-4, `Cupid Web.dc.html:683-731`)

- Theme: `document.body.dataset.theme` = `"dark"` (default) or `"light"`, driving every `--c*`/`--acc-*`/`--bg`/`--nebula` CSS custom property (full token table at `Cupid Web.dc.html:16-17`). Persisted to `localStorage["cupid-web-theme"]`; read back on load, falling back to `"dark"` if unset or storage is unavailable (source wraps the read in try/catch).
- Language: `document.body.dataset.lang` = `"vi"` (default) or `"en"`, toggling every paired `[data-vi]`/`[data-en]` span's visibility (`display:none` → `display:revert`). The design source does not persist language to `localStorage` (only theme is persisted) — implement language as session/in-memory state unless Tech Lead decides otherwise; do not silently add persistence beyond what the source does, since that would be a scope addition, not fidelity.
- All 4 combinations (dark×vi, dark×en, light×vi, light×en) must render correctly — every token above has both a dark and light value, and every string above has both VI and EN text; there is no partial/placeholder combination in the source.
- Key Behavior / State Notes: theme and language are shell-level state (owned by the page/app root), not per-page — both toggles live in the header and must affect the entire shell + whichever page is currently mounted.

### 6.5 Component Changes

- **Header** (New): sticky global shell component. See §6.1. Accessibility notes in §6.1.
- **Footer** (New): global shell component. See §6.1.
- **Theme toggle button** (New): icon button, 2-state (dark/light), see §6.4. Accessibility: expose current/target state via `title`/`aria-label`, not icon-only.
- **Language toggle** (New): 2-option segmented control, see §6.4. Accessibility: implement as a proper toggle/radio-group pattern (`role="group"` with two toggle buttons or a native radio pair) — the source is plain styled buttons with no ARIA; add the semantics at implementation.
- **Mobile nav select** (New): native `<select>`, see §6.1. Needs an accessible label (gap noted in §6.1).
- **Hero stat counter** (New, reusable across future marketing sections if needed): number-over-label pair, see §6.2.1.
- **Feature card** (New): icon-tile + title + description, see §6.2.2. Reusable pattern — future stories with similar "benefit card" needs should reuse this, not invent a new card shape.
- **Pet-cast card** (New, this story only defines the teaser variant): sprite + name + trait label, see §6.2.3. STORY-002 (Pets page) should confirm whether it extends this same card or needs a richer variant — flag to that story's Tech Lead/UX pass rather than assuming.
- **Step card** (New): numeral + title + description, see §6.2.4.

### 6.6 Responsive And Accessibility Notes

- Responsive behavior for affected screens: hard nav-pattern swap at **1024/1025px** (desktop pill nav ↔ mobile select, §6.1). All grids (hero 2-col, features 4-col, pet-cast 6-col, steps 3-col) use CSS `auto-fit`/`minmax` fluid reflow rather than named breakpoints — implement with real fluid grids, not fixed breakpoint overrides, to match the source's continuous reflow behavior exactly.
- Content or action reprioritization on smaller surfaces: hero right-column phone mockup stacks below the left-column text/CTAs once the two-column grid can no longer fit both ≥420px columns (natural `auto-fit` behavior) — download badges and stat counters must remain above the fold priority-wise; do not let the decorative phone mockup push them down on narrow viewports (verify at implementation; source is a fluid grid so order is column-1-then-column-2 by default, which already achieves this).
- Keyboard and focus expectations: header logo, all 7 nav items, theme toggle, VI/EN toggle, "Get the app" CTA, all hero download badges, "Meet them all" CTA, and all footer links must be reachable via Tab in visual order and activatable via Enter/Space; add visible focus rings (not present in the raw prototype's inline styles — a11y gap to close at implementation, this is a hard requirement, not optional polish).
- Screen reader / semantics notes: use real `<header>`/`<nav>`/`<main>`/`<footer>` landmarks (source is DOM-agnostic template markup); mark the background nebula/star decoration `aria-hidden="true"` (source already does this at the outer div); pet sprite images need meaningful `alt` text (pet name), not empty/decorative alt, since the pet identity is part of the content.
- Error / status communication expectations: N/A — no forms, no async operations in this story's scope.

### 6.7 Visual Direction Notes

- Typography, density, or spacing posture: Nunito (900/800 weights) for display/headline/CTA text, Roboto for body copy, Roboto Mono (uppercase, tracked-out) for eyebrow labels/captions/mono-numeral accents — this three-typeface split is a deliberate system rule, keep it consistent across every future REQ-006 page story, not just Home.
- Surface and container treatment: soft `--surf` translucent panels with 26-36px border radii, thin `1px` low-opacity borders (`--c09`/`--c1`/`--c16` scale), never hard drop shadows on content cards (only the hero phone mockup and header/footer use elevation-style shadow/blur).
- Color or status-semantics treatment: no status/semantic colors appear in this story's scope (no forms, no error states) — the palette here is purely brand-expressive (pink/lilac/mint/butter/peach as feature/pet/section accents, not meaning-bearing).
- Anti-patterns explicitly avoided: do not introduce a bottom tab bar or platform-adaptive (iOS/Material) chrome from the mobile System UX Memory — web uses one shared header/footer shell across all breakpoints, not platform-specific navigation.

### 6.8 Visual Acceptance Criteria / Design Anchor

- Visual reference(s): **not yet rendered as image files — see the "Design Reference Rendering" note in §7 Handoff Notes for why, and the exact commands needed to produce them.** In their absence, this section's measurable rules below are the interim visual anchor; they are pulled directly from `cupid-app-design-system/Cupid Web.dc.html`, which remains the authoritative source (exact line ranges cited per element throughout §6.1–§6.2).
- Layout & spacing (key paddings, gaps, sizes): header row `padding:14px 32px`; hero section `padding:76px 32px 30px`, grid `gap:48px`; features section `padding:56px 32px`, card grid `gap:18px`, card `padding:26px`; pet-cast section `padding:40px 32px 80px`, card grid `gap:16px`; how-it-works section `padding:0 32px 90px`, card `padding:56px`, step grid `gap:34px`; footer `padding:48px 32px 34px`, column grid `gap:32px`. All content columns constrained to `max-width:1200px; margin:0 auto`.
- Color & status semantics (hex / token names): full dark+light token table at `Cupid Web.dc.html:16-17` (brand accents `--acc-pink #FF7FB6`/`--acc-lilac #B78CF5`/`--acc-mint #79E2CD`/`--acc-butter #FFC97E`/`--acc-peach #FFAB93`; backgrounds `--bg` dark `#171129` / light `#FFF1F7`; the full `--c05`…`--c86` opacity-scale tokens for borders/text). Implement as CSS custom properties keyed by `[data-theme]`, exactly matching the source's two blocks.
- Typography (sizes, weights, line-height): H1 Nunito 900 66px/1.04; H2 Nunito 900 38px; card title Nunito 800 17.5px; body/subcopy Roboto 17px/1.65 (hero) and 13.5px (cards); eyebrow/caption Roboto Mono 10-11px uppercase tracked `.12em`-`.14em`; stat number Nunito 900 26px.
- Component states to verify (default / hover / active / disabled / loading / error / empty): nav item default/active/hover (§6.1); theme toggle two icon states; language toggle two active states; download-badge and CTA hover treatments (§6.1, §6.2.1); feature/pet-cast card hover lift. No disabled/loading/error/empty states apply — static content only.
- Responsive checkpoints to verify: 1024px→1025px hard nav swap (§6.1); hero/features/pet-cast/steps grids reflow continuously via `auto-fit`/`minmax`, verify at common widths (375, 768, 1024, 1440) that no column ever drops below its `minmax` floor (420px hero halves, 260px feature cards, 170px pet cards, 230px step cells).

### 6.9 Usability Readiness Gate

- Can the target user complete the critical task without outside explanation? Yes — hero headline + subcopy + features grid explain the product without prior context, per §5.1's direct-URL-only entry treatment.
- Is the first action clear for the expected user mode? Yes — App Store/Google Play badges and the header "Get the app" CTA are the clearest, most repeated calls to action on the page.
- Is success, failure, and partial progress visible in user language? N/A for this story (external deep links, no in-site transaction to track).
- Are recovery, retry, edit, undo, or next-action paths explicit where needed? N/A — no destructive or multi-step actions in scope.
- Remaining usability risks: mobile nav `<select>` and theme/language toggles have accessibility gaps in the raw design source (no ARIA labels, no visible focus states) that implementation must close — flagged explicitly in §6.1, §6.5, §6.6, not left implicit.

## 7. Handoff Notes

- Important implementation constraints: build all four Home sections (Hero, Features, Pet-cast teaser, How it works) as one page — see the AC-6 wording note below. Header/footer shell must be structurally identical across Home and the 7 stub routes.
- OQ-driven blocked UX sections, if any: none (see §3).
- Shared pattern changes requiring System UX Memory update: yes, deferred — see "System UX Memory" note below.
- Design-coherence checks downstream should preserve: the three-typeface split (§6.7), the fluid `auto-fit` grid pattern (no fixed breakpoints beyond the 1024px nav swap), the footer's header-nav-minus-Legal-plus-Legal route pattern (§6.3).
- Usability checks downstream should preserve: hero must stay legible/self-explanatory with zero prior context (§5.1); all 8 routes reachable with no dead links (§6.3).
- Questions or blockers:

  1. **AC-6 wording gap (not a blocker, informational)**: the story's Acceptance Criteria text names only "hero section" and "features grid section" for the fidelity-audited scope, but the design source's actual `isHome` render (`Cupid Web.dc.html:79-211`) is one continuous page with two more sections (pet-cast teaser, "How it works") immediately after features. Per the requirement's hard "visually identical (100%)" mandate, this spec designs and expects implementation of all four sections as the true Home page. Recommend Product Owner amend AC-6's wording to name all four sections explicitly in a future pass, but this should not block Tech Lead/implementation from proceeding with the fuller, source-accurate scope now.

  2. **Design Reference Rendering — BLOCKED, needs a Bash-capable agent**: Per skill Core Rule 6A Step 0, I re-ran the required detection check by reading `data/devops/system/design-fidelity-config.json` directly (I could not execute the `detect_design_source.py` script itself — see reason below) and found `design_source` is already `locked: true` with `type: "claude-design"`, `location: "cupid-app-design-system"`, but `entry: "Cupid App.dc.html"` — that entry is the **mobile** app canvas from the earlier REQ-001 detection run, not `Cupid Web.dc.html`, the actual source for this story. `req_master.md` does not carry a `Design-Source: UPDATE — <reason>` line, so per the skill I cannot request the detector reconfigure the locked entry myself; that decision needs to go back through Scrum Master/Product Owner (or Tech Lead) to add that line if a config update is warranted — the two `.dc.html` files are legitimately different canvases (mobile app vs. this web marketing site) sharing one bundle directory, not a stale/incorrect detection.

     Separately, and independent of the above: **I do not have a Bash tool available in this run** — my available tools this session are Read, Write, Edit, SendMessage, Grep, Glob only. I could not run `python3 .claude/hooks/lib/detect_design_source.py`, `node .ai-team-bundle/runtime/tools/render-design-canvas.js --list-screens`, or the per-screen render command, all of which require shell/Python/Node execution. As a result, **no `design-reference-*.png` file exists yet** for this story, even though this is a UI-lane story with a FORCE rendering requirement. I have compensated by citing exact source line numbers and literal measurable values (colors, sizes, spacing, copy) throughout §6, rather than prose description, but a rendered reference image is still outstanding.

     **Recommended next step**: once the `Design-Source: UPDATE` question above is resolved (or confirmed the existing `location`/`type` is fine to reuse with a different `--entry` override at render time — worth checking whether `render-design-canvas.js` accepts a per-call `--entry` distinct from the locked config default), a Bash-capable agent should run:
     ```
     node .ai-team-bundle/runtime/tools/render-design-canvas.js \
       --location=cupid-app-design-system --entry="Cupid Web.dc.html" --list-screens
     node .ai-team-bundle/runtime/tools/render-design-canvas.js \
       --location=cupid-app-design-system --entry="Cupid Web.dc.html" \
       --out=data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/visual-fidelity \
       --screen=home --platform=all
     ```
     from the story worktree, to produce the `design-reference-home-*.png` files the reviewer/DONE gate needs.

## Optional Expansion

Not needed — this is a compact single-page + shared-shell spec; no multi-step flow, no new reusable component beyond what's covered in §6.5.
