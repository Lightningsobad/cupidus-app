# Story Requirements: STORY-003 Zodiac Compatibility Preview Page

Parent requirement: REQ-006 Web frontend implementation from design system &
production deploy

## Actor & Goal

A visitor curious about the app's astrology/compatibility feature navigates to
the "Zodiac" page from the shared site nav and sees a static preview of the
zodiac-compatibility feature: a sample daily compatibility read, the full
12-sign directory, the 4-element grouping, and a weekly top-pairs leaderboard
— all in service of building interest and trust before download.

## Business Value

Previews a differentiated in-app feature (zodiac compatibility) that is not
explained anywhere else on the marketing site, giving a visitor a concrete
reason to download before they commit.

## Scope

### In Scope

- Zodiac page reachable via the "Zodiac" item in the shared header nav
  (desktop nav + mobile nav select) established by STORY-001, and by direct
  URL/route for the `zodiac` page state.
- Page hero: eyebrow label ("Astrology"/"Chiêm tinh"), H1 headline, and
  supporting paragraph, per design source lines 288–290.
- Sample daily compatibility card (design source lines 292–320):
  - Two zodiac sign icons + labels (Cancer, Taurus in the design sample).
  - Circular percentage ring showing the day's overall compatibility score
    (92% in the design sample).
  - Three labeled metric bars with percentages: Communication (88%),
    Understanding (94%), Energy (71%), each with its own accent color per
    the design source.
  - "Today's nudge" text block with a short sample tip.
- "All twelve signs" grid (design source lines 322–331): all 12 zodiac signs,
  each with icon, localized name (VI/EN), and date range, reproduced exactly
  from the design-source `zodiac` data array (verbatim VI/EN names and
  date-range strings, e.g. Aries "21.3 – 19.4" / Bạch Dương).
- "Four elements" grouping (design source lines 332–350): four element cards
  (Fire, Earth, Air, Water), each listing its 3 member signs with icons,
  exactly as grouped in the design source (Fire: Aries/Leo/Sagittarius;
  Earth: Taurus/Virgo/Capricorn; Air: Gemini/Libra/Aquarius; Water:
  Cancer/Scorpio/Pisces).
- "Six most in-sync pairs this week" leaderboard (design source lines
  351–383): 6 ranked rows, each with a sign-pair label, a horizontal
  percentage bar, and a percentage value, reproduced with the exact sample
  values from the design source (96%, 93%, 90%, 88%, 85%, 82%).
- All page text/content rendered in both VI and EN per the existing
  language-toggle mechanism established in STORY-001 (reuse, do not
  reimplement).
- Per-page `<title>` tag for the Zodiac page (carried-forward deferred
  finding DEF-2 from STORY-001 review — every new page needs its own
  descriptive `<title>`, not the shared/generic title from the app shell).

### Out of Scope

- Any live or user-computed zodiac compatibility calculation, user sign
  selection/input, or personalization — the design source contains no
  `fetch`/API reference on this page; every figure is static sample content
  (per resolved OQ-REQ006-2).
- Backend/API integration of any kind for this page.
- Changes to the shared header/nav/footer/theme-toggle/language-toggle chrome
  itself — STORY-001 already built and owns that chrome; this story only adds
  page body content behind the existing "Zodiac" nav item.
- New design elements not present in the `isZodiac` section of
  `cupid-app-design-system/Cupid Web.dc.html`.

## Acceptance Criteria

- AC-1: Given a visitor on any page of the deployed site, when they click the
  "Zodiac" item in the header nav (desktop) or select "Zodiac" from the
  mobile nav, then the Zodiac page renders at its route with the shared
  header/nav/footer chrome intact.
- AC-2: Given a visitor on the Zodiac page, when the page loads, then they see
  the hero eyebrow/headline/subtext, matching the design source content and
  layout at line 288–290 of `Cupid Web.dc.html`.
- AC-3: Given a visitor on the Zodiac page, when they view the daily
  compatibility card, then they see two sign icons/labels, a circular
  percentage ring, three labeled metric bars with percentages, and the
  "today's nudge" text — all matching the design source sample values and
  layout at lines 292–320.
- AC-4: Given a visitor on the Zodiac page, when they view the "All twelve
  signs" section, then all 12 zodiac signs are present, each showing its
  icon, VI/EN name, and date range exactly matching the design-source
  `zodiac` data array (12 entries, no fewer, no duplicates).
- AC-5: Given a visitor on the Zodiac page, when they view the "Four
  elements" section, then exactly 4 element cards are shown (Fire, Earth,
  Air, Water), each listing its 3 correct member signs with icons, matching
  the design-source grouping at lines 332–350.
- AC-6: Given a visitor on the Zodiac page, when they view the "Six most
  in-sync pairs this week" section, then exactly 6 ranked rows are shown,
  each with the correct sign-pair label, percentage bar width, and
  percentage value matching the design source at lines 351–383.
- AC-7: Given a visitor with the site language toggle set to VI or EN, when
  they view the Zodiac page, then all text content on the page (hero,
  compatibility card, signs grid, elements, leaderboard) renders in the
  selected language, reusing the existing STORY-001 language-toggle
  mechanism.
- AC-8: Given a visitor with the site theme toggle set to dark or light, when
  they view the Zodiac page, then all Zodiac-page content renders correctly
  themed, reusing the existing STORY-001 theme-toggle mechanism.
- AC-9: Given the deployed Zodiac page, when its HTML `<head>` is inspected,
  then it has its own descriptive `<title>` tag distinct from the shared app
  shell default (carried-forward DEF-2 from STORY-001 review).
- AC-10: The rendered Zodiac page is visually identical to the `isZodiac`
  section of `cupid-app-design-system/Cupid Web.dc.html` per this
  requirement's strict visual-fidelity acceptance bar (see req_master.md
  Business Scope) — verified at the requirement-level
  `frontend-dev` `Mode: requirement-visual-audit` gate before REQ-006 as a
  whole is marked DONE.

## Business Rules / Guardrails

- BR-1: All figures, labels, and copy on this page are static
  presentational/sample content sourced verbatim from the design source, not
  live-computed values — there is no backend dependency for this page
  (inherits resolved OQ-REQ006-2).
- BR-2: VI and EN copy must both be reproduced verbatim from the design
  source's `data-vi`/`data-en` spans; do not paraphrase or retranslate.

## Non-Functional Notes

- No new architecture beyond what STORY-001 established (framework, routing,
  chrome, theme/language toggle) — this story is additive page content only.
- No live/failure edge case: content is static and always fully populated, so
  there is no loading, empty, or error state to design for on this page.

## Open Question Impact

Requirement-level OQ triage re-checked for this story:

- OQ-REQ006-1 (frontend framework/stack) — RESOLVED by STORY-001 (shared
  foundation, DONE). This story reuses that foundation and does not
  re-litigate the framework choice.
- OQ-REQ006-2 (API dependency) — RESOLVED (Product Owner, 2026-08-21):
  static/marketing site, no live API dependency. Directly applicable to this
  story: the Zodiac page is 100% static sample content.

### Scope Items BLOCKED in this story

- None. Both requirement-level OQs are resolved and this story's dependency
  (STORY-001) is DONE/MERGE_COMPLETE.

### Scope Items NOT BLOCKED in this story

- All in-scope items above (hero, daily compatibility card, 12-sign grid,
  4-element grouping, 6-pair leaderboard, VI/EN content, per-page `<title>`)
  are unblocked and ready for UX/architecture/implementation handoff.

## Coverage Map

| Requirement Item | Source |
|---|---|
| Zodiac page nav entry + route | `Cupid Web.dc.html` line 716, 720, 835 |
| Hero copy | `Cupid Web.dc.html` lines 288–290 |
| Daily compatibility card | `Cupid Web.dc.html` lines 292–320 |
| All-12-signs grid + data | `Cupid Web.dc.html` lines 322–331, 763–775 (zodiac array) |
| Four elements grouping | `Cupid Web.dc.html` lines 332–350 |
| Six-pair leaderboard | `Cupid Web.dc.html` lines 351–383 |
| Per-page `<title>` (DEF-2) | STORY-001 review carried-forward finding |

## Dependencies

- STORY-001 (Frontend App Foundation & Home Landing Page) — DONE,
  MERGE_COMPLETE. Provides framework, shared chrome, nav routing, and
  theme/language toggle reused by this story.
