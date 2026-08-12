# Visual Fidelity Report — Full (37 of 37)

Assembled from `visual-fidelity-report-part-a.md` (P10, 19 ids) and
`visual-fidelity-report-part-b.md` (P11, 18 ids). Part A verdicts below are
pulled verbatim, unmodified, and unrejudged. Android only (DEC-2), 412px-wide
captures, live paired-couple session (Minh & Linh, P7 seed data) against the
live local backend.

## Combined summary table (37/37)

| id | Verdict | Note |
|---|---|---|
| alarm | DEVIATION | chrome now correct; content now errors (regression vs. first audit which at least rendered content) |
| home | DEVIATION | content finding unchanged (still STORY-001 placeholder); chrome now present but wrong widget |
| gallery | DEVIATION | load-error state; broken chrome variant |
| antighost | DEVIATION | load-error state; no chrome reached |
| invite | DEVIATION | load-error state; no chrome |
| joincode | DEVIATION | real but fully unstyled render, missing most affordances |
| paired | DEVIATION | bare text only, no cards/CTA |
| pet | DEVIATION | network-error state; chrome required by design but absent |
| privacy | DEVIATION | correct copy, unstyled/truncated, no cards |
| vibe | DEVIATION | correct copy, unstyled/truncated, no cards |
| splash | DEVIATION | oversized text scale wraps logotype |
| welcome | DEVIATION | oversized text scale pushes CTAs off-frame |
| login | DEVIATION | oversized text scale, unstyled fields, CTAs off-frame |
| register | DEVIATION | oversized text scale, unstyled fields, CTAs off-frame |
| forgot | DEVIATION | oversized text scale, CTA off-frame |
| profile | DEVIATION | recaptured; fixed from error to real render, still missing most fields/CTA |
| contract | DEVIATION | recaptured; fixed from error to real render, oversized-text bug reproduces |
| waiting | DEVIATION | generic/simplified state vs. personalized design state |
| chat | DEVIATION | flat unthemed gray fill, no content; broken chrome variant, tab correctly active |
| ghostset | DEVIATION | oversized text scale truncates content; broken chrome |
| timeline | DEVIATION | recaptured; real seeded memory entry renders, then oversized text truncates; broken chrome |
| jar | DEVIATION | recaptured; renders unrelated placeholder text, not jar-detail content; broken chrome |
| jarlist | DEVIATION | recaptured twice; content-identical to `jar` — app-level routing/wiring defect, not styling |
| jarnew | DEVIATION | most-complete real render; mild oversized text; correctly no chrome |
| expense | DEVIATION | recaptured; real seeded totals render, then oversized text truncates; broken chrome |
| me | DEVIATION | recaptured; severe 1-char-per-line text wrap, no settings rows render; broken chrome |
| notifs | DEVIATION | real copy renders, then oversized text truncates before toggle rows; broken chrome |
| otp | DEVIATION | approved scope cut (requirements.md OQ-1) — placeholder only |
| permissions | DEVIATION | approved scope cut (requirements.md OQ-1) — placeholder only |
| vow | DEVIATION | approved scope cut (requirements.md OQ-1) — placeholder only |
| zodiac | DEVIATION | approved scope cut (requirements.md OQ-1) — placeholder only |
| themes | DEVIATION | approved scope cut (requirements.md OQ-1) — placeholder only |
| themedetail | DEVIATION | approved scope cut (requirements.md OQ-1) — placeholder only |
| sharepick | DEVIATION | approved scope cut (requirements.md OQ-1) — placeholder only |
| shareedit | DEVIATION | approved scope cut (requirements.md OQ-1) — placeholder only |
| shareapprove | DEVIATION | approved scope cut (requirements.md OQ-1) — placeholder only |
| shareok | DEVIATION | approved scope cut (requirements.md OQ-1) — placeholder only |

37/37 rows recorded. 0/37 MATCH. 10/37 are approved scope cuts (Product
Owner ruling in `requirements/requirements.md`), not defects; the
remaining 27/37 are real fidelity/functional deviations. Cross-cutting
findings for Tech Lead/Scrum Master triage, each spanning many of the 27:

1. **Oversized text scale** — reproduces across at least 12 screens
   (`splash`, `welcome`, `login`, `register`, `forgot`, `contract`,
   `ghostset`, `timeline`, `jarnew`, `expense`, `me`, `notifs`) — headline/
   label text renders at roughly 3-4x design scale, wrapping words (or, on
   `me`, single characters) across full-width lines and pushing the rest of
   each screen's layout off the 900px capture. Read as one systemic text-
   scale/theme regression, not independent per-screen bugs.
2. **Broken bottom-chrome variant** — a plain 2-label "Trang chủ / Trò
   chuyện" nav with an overlapping pink profile-icon FAB renders instead of
   the correct 5-tab pink-pill `CupidTabBar`, on at least 10 screens
   (`home`, `gallery`, `chat`, `ghostset`, `timeline`, `jar`, `jarlist`,
   `expense`, `me`, `notifs`). `alarm` is the one confirmed case of the
   correct chrome rendering.
3. **Load-error/empty states beyond the officially-fixed 8** — `alarm`,
   `antighost`, `gallery`, `invite`, `joincode`, `pet` show "Không tải
   được…"/"Không có kết nối mạng" banners despite a live backend at
   judging time; flagged as possibly a data/seed-timing gap distinct from a
   design mismatch, needing a follow-up capture pass before being treated
   as final design verdicts.
4. **`jar`/`jarlist` content collision** — new in this batch. After two
   recapture attempts (one specifically to rule out a route-switch race),
   `jarlist`'s capture remains visually identical to `jar`'s, despite the
   two design references being completely different screens. Points to a
   preview-registry/route wiring defect distinct from the styling issues
   above — see the Part B `jarlist` row for detail.

For the full per-screen judgment detail (concrete UI-element deltas, seeded
state, chrome yes/no + why) behind every row above, see
`visual-fidelity-report-part-a.md` (ids 1-19) and
`visual-fidelity-report-part-b.md` (ids 20-37).
