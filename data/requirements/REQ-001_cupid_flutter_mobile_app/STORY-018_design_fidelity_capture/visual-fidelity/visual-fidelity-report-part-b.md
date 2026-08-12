# Visual Fidelity Report — Part B (18 of 37)

Phase: P11. Scope: the 18 ids `ghostset, timeline, jar, jarlist, jarnew,
expense, me, notifs, otp, permissions, vow, zodiac, themes, themedetail,
sharepick, shareedit, shareapprove, shareok`. Pairs judged: `design-reference-
<id>-android.png` vs `implemented-<id>-emulator-5554.png` under this
directory. Android only (DEC-2), 412px-wide capture. Same live paired-couple
session as Part A (Minh & Linh, P7 seed data, live local backend confirmed
at `127.0.0.1:3005` / `127.0.0.1:3006`).

Five ids were recaptured in this pass: `me`, `timeline`, `jar`, `jarlist`
(recaptured twice), and `expense` — see Recapture note below. The other 13
were judged from the existing P9 captures, including all 10 approved-
scope-cut placeholders.

## Product Owner ruling on 10 ids: approved scope cut, not defect

Per `requirements/requirements.md` (OQ-1 ruling, `Status:
PRODUCT_OWNER_COMPLETE`), the ten ids `otp`, `permissions`, `vow`, `zodiac`,
`themes`, `themedetail`, `sharepick`, `shareedit`, `shareapprove`,
`shareok` are ruled **approved scope cuts**: no shipped story's User Story,
In/Out of Scope, or Acceptance Criteria text ever promised these screens.
This does not change the capture or verdict mechanics — each still shows a
real placeholder `implemented-*.png` and is recorded as `DEVIATION — screen
not implemented` exactly as the plan's default already requires — it only
changes the *label* from an implicit defect to an explicit approved scope
cut, so these ten do not feed the three deferred code-fix hardening stories
(STORY-006/STORY-008/STORY-016 are unchanged by this ruling).

## Recapture note

`me` and `timeline` were named directly by the handoff (Scrum Master
independently flagged `me` for a text-overflow concern). Both were
recaptured (`--route=cupidpreview://screen/<id> --width=412 --max-edge=900
--settle-ms=1500`) — both still show the same class of failure as before
recapture (see rows below), confirming these are not stale/cached captures.

`jar` and `expense` were recaptured in the same batch pass and also
reproduced their prior state unchanged.

`jarlist` was recaptured twice. The first attempt, run back-to-back with
`jar` in the same loop (`--settle-ms=1500`), produced a PNG byte-identical
to `jar`'s (`md5 -q` both `5559fcaf849a19991ca15912dd67d252`) — initially
suspected as a route-switch race condition, since both captures fired
within the same short loop. To rule that out, a second recapture was run
after first navigating to an intermediate screen (`cupidpreview://screen/
home`, 1s settle) and then firing `jarlist` alone with `--settle-ms=2000`.
This produced a different file hash (`36882c1923078304315a35061bb6aa40`),
proving the bytes did change — but visual inspection of the new capture
shows the **same content** as `jar`: the identical pink card reading
"Previ/ew/Seed:/Trip/to/Pari[s]" with the same overlapping profile FAB and
the same broken bottom chrome. This rules out a simple timing race and
points instead to an app-level wiring defect — see the `jarlist` row.

## Headline finding: two systemic issues from Part A reproduce further in this batch

1. **Oversized text scale** reproduces on every real-content screen in this
   batch (`ghostset`, `timeline`, `jarnew`, `expense`, `me`, `notifs`) —
   headline/label text renders at roughly 3-4x the design's apparent size,
   wrapping single words or even single characters across multiple
   full-width lines and pushing the rest of each design's layout off the
   900px capture. This is the same defect flagged in Part A on `splash`,
   `welcome`, `login`, `register`, `forgot`, and `contract` — now confirmed
   present in 6 more screens across this batch, strengthening the case that
   this is one systemic text-scale/theme regression, not 12+ unrelated
   bugs.
2. **Broken bottom-chrome variant** (plain 2-label "Trang chủ / Trò chuyện"
   nav with an overlapping pink profile-icon FAB, instead of the correct
   5-tab pink-pill `CupidTabBar`) also reproduces on every AppShell-tab or
   tab-bar-shown-in-design screen in this batch (`ghostset`, `timeline`,
   `jar`, `jarlist`, `expense`, `me`, `notifs`) — consistent with the same
   pattern flagged on `home`/`gallery`/`chat` in Part A.

A third, new finding in this batch — distinct from both of the above — is
the `jar`/`jarlist` content-collision defect (see that row and the
Recapture note above).

## Verdicts

### `ghostset` — DEVIATION

App-bar title is truncated ("Typing Gh…"). Body renders the correct design
copy start ("Đối phương thấy c[ả] phần [bạn] đã xoá") but at the oversized
text scale, consuming the frame and cutting off before the descriptive
subtext ("Từng ký tự bay sang trong dưới 200ms…"), the Typing Ghost toggle
row with per-partner consent state ("Minh đã đồng ý" / "Linh đã đồng ý"),
the "Nhìn như thế nào" live preview box, or the Ephemeral-100% footer note.

Seeded state: n/a (static feature-settings copy; toggle state not
Firebase-seeded). Chrome: broken 2-tab + overlapping-FAB variant present
(design reference shows the 5-tab bar with Trò chuyện highlighted) —
DEVIATION on chrome too, same broken variant as `home`/`gallery`/`chat`.

### `timeline` — DEVIATION (recaptured, see note above)

Recapture confirms real seeded content is reaching this screen: a pink
timeline dot/line and a heart-icon entry dated "Aug 12," with body text
"Seeded memory for des[ign] fide[lity] previ[ew] captur[e]" — this is
literally the P7 seed script's own placeholder memory text, confirming the
seed pipeline still works. However the oversized-text-scale bug truncates
the capture before the design's "Còn 53 ngày" progress card (with its 82%
ring), the "Mốc 200 ngày" milestone entry, the "Dream Jar đạt 75%" entry, or
any further timeline entries the design shows below the first one.

Seeded state: one seeded memory entry confirmed rendering (per above).
Chrome: broken 2-tab + overlapping-FAB variant (design reference shows the
5-tab bar with Pet highlighted) — same broken variant as elsewhere.

### `jar` — DEVIATION (recaptured, see note above)

Recapture reproduces the same result as before: instead of the design's
Dream Jar detail card (bottle illustration, "3.900.000đ / 5.000.000đ · 78%"
progress, quick-add buttons +100k/+200k/+500k, "Ai thương cái hũ hơn"
leaderboard), the implemented capture shows a generic pink card with text
wrapped one-to-two-words-per-line reading "Previ/ew/Seed:/Trip/to/Pari[s]"
— this does not match any of the design's actual jar-detail copy, so this
is not merely an unstyled/truncated render of the right content, it is
different content altogether (see the `jarlist` row for the related
wiring-collision finding).

Seeded state: P7 reports one dream jar seeded with contributions ("Trip to
Paris" is plausibly the seed's jar name, consistent with the fragment
visible), but the screen does not render the seeded jar's real detail UI.
Chrome: broken 2-tab + overlapping-FAB variant (design shows the 5-tab bar
with Ví chung highlighted).

### `jarlist` — DEVIATION (recaptured twice, see note above — distinct wiring defect)

This is the most notable new finding in this batch. After two recapture
attempts (the second specifically designed to rule out a route-switch race
condition — see Recapture note above), `jarlist`'s implemented capture
remains **visually identical** to `jar`'s: the same "Previ/ew/Seed:/Trip/
to/Pari[s]" pink card, the same overlapping profile FAB, the same broken
chrome. The design references for the two ids are completely different
screens (`jar` = single jar detail card; `jarlist` = "Các hũ ước mơ", a
list of 3 jar summary cards plus a "Tạo hũ mới" CTA and a completed-jars
row) — there is no design-level reason these two should ever render the
same content. This is best read as a **preview-registry/route wiring
defect**: the `jarlist` deep-link route appears to resolve to the same
builder/widget as `jar` rather than a distinct `DreamJarListScreen`. This
is a different defect class from the load-error and oversized-text
patterns seen elsewhere — flagging explicitly for Tech Lead triage as a
routing/registry bug, not a design-fidelity styling gap.

Seeded state: P7 reports one dream jar seeded; a list view should show at
minimum that one jar. Not observable here since the wrong screen renders.
Chrome: broken 2-tab + overlapping-FAB variant (design shows the 5-tab bar
with Ví chung highlighted).

### `jarnew` — DEVIATION

This is the most-complete real render in this batch: title "Dream Jar mới"
(matching the design's "Hũ mới" intent) and three real form fields are
visible — "Tên", "Số tiền mục [tiêu]", and "Hạn chót (không [bắt buộc])"
with its "Chưa đặt hạn chót" placeholder value. The oversized-text bug is
present but milder here (the title wraps across 2 lines instead of
consuming the whole frame), so more of the actual form structure is
visible than on other Part B screens. Missing vs. design: the "Hai đứa để
dành cho gì?" context subtitle, the icon-picker grid (plane/game/home/
car/gem/plant), the amount stepper quick-buttons (-1tr/+1tr/+5tr), the
weekly-reminder toggle row, and the two-person-consent footer note — all
pushed below the visible frame.

Seeded state: n/a (this is a creation form, not seed-populated). Chrome:
correctly absent — design also shows no tab bar on this modal-style
creation screen, so this is the one screen in the batch where chrome is
**not** a DEVIATION.

### `expense` — DEVIATION (recaptured, see note above)

Recapture confirms real seeded content: "750.000đ" total and "2 khoản chi"
line render correctly-worded, plus the start of a bar-chart's weekday axis
labels ("T2 T3 … T5 T6 T7 CN") is visible. But the oversized-text bug
(digits in "750.000đ" rendered enormous) truncates the capture before the
category-filter chips (Tất cả/Ăn uống/Date/Du lịch), the itemized expense
list the design shows (5 named entries — "Lẩu ở Nguyễn Huệ", "Trà sữa hoà
giải", etc. — matching the P7-seeded "a couple of expenses"), or the "+"
add-expense FAB in its correct bottom-right position; instead the
broken-chrome variant's pink profile FAB overlaps the partial chart.

Seeded state: total and expense count confirmed seeded/rendering per
above; itemized entries not visible in the truncated capture. Chrome:
broken 2-tab + overlapping-FAB variant (design shows the 5-tab bar with
Ví chung highlighted).

### `me` — DEVIATION (recaptured, see note above — Scrum Master's flagged concern confirmed)

Recapture confirms the concern raised independently by Scrum Master: this
is a more severe failure than plain oversized text. The app-bar title
"Tôi" renders at a normal, correctly-proportioned size, but the body is
dominated by a single-character-per-line fragment reading "p / r / e"
(evidently the start of "preview"/a placeholder string, wrapping one
character to a full-width line each) occupying the space where the
design's avatar-photo card with name/zodiac/DOB ("Linh · Song Ngư ·
03/03/2001") should be. None of the design's settings rows (Dữ liệu của
tôi, Thông báo, Kho Theme, Ảnh chia sẻ, Typing Ghost toggle, Love Contract,
Ngôn ngữ, Digital Divorce card) are visible. The one-character-per-line
wrapping (rather than one-word-per-line, seen elsewhere) suggests an
unusually narrow available width for this specific text node, distinct in
degree from the other oversized-text screens.

Seeded state: n/a (profile display, not further seed-dependent beyond the
signed-in account). Chrome: broken 2-tab + overlapping-FAB variant (design
shows the 5-tab bar with Tôi highlighted).

### `notifs` — DEVIATION

App-bar title truncated ("Thôn…"). Body renders real design copy
("Tối đa 15 thông báo/ngày." matches verbatim) with the lightning-bolt icon
and the start of the "CRIT[ICAL]" section label visible, but the
oversized-text bug truncates the capture before any of the six named
toggle rows the design shows (Synced Alarm, Emoji Storm, Vibe Check, Bún
cần bạn, Bae đang gõ, Dream Jar milestone, Love Timeline) or their on/off
switches render.

Seeded state: n/a (static notification-preferences copy; toggle states not
seed-dependent). Chrome: broken 2-tab + overlapping-FAB variant (design
shows the 5-tab bar with Tôi highlighted).

### `otp` — DEVIATION — approved scope cut (per `requirements/requirements.md` OQ-1 ruling)

Renders the plan's standard placeholder: id label "otp" and "NOT_IMPLEMENTED"
on a dark background with a bottom progress-bar sliver — no real screen
exists to compare. Per the Product Owner ruling, this is an approved scope
cut (STORY-003's UX spec and Tech Lead ADR-011e place OTP downstream of
this story), not a defect feeding a hardening story.

### `permissions` — DEVIATION — approved scope cut (per `requirements/requirements.md` OQ-1 ruling)

Same placeholder pattern ("permissions" / "NOT_IMPLEMENTED"). Approved
scope cut — STORY-003's UX spec places this screen out of scope beyond
being a navigation target.

### `vow` — DEVIATION — approved scope cut (per `requirements/requirements.md` OQ-1 ruling)

Same placeholder pattern ("VOW" / "NOT_IMPLEMENTED"). Approved scope cut —
STORY-006's UX spec explicitly excludes this screen (its backend target is
a separate `User.vowTaken` concern, not the love-contracts module
STORY-006 owns).

### `zodiac` — DEVIATION — approved scope cut (per `requirements/requirements.md` OQ-1 ruling)

Same placeholder pattern ("zodiac" / "NOT_IMPLEMENTED"). Approved scope
cut — no shipped story ever named this standalone screen; STORY-016 ships
only a read-only zodiac chip on the profile screen, not this screen.

### `themes` — DEVIATION — approved scope cut (per `requirements/requirements.md` OQ-1 ruling)

Same placeholder pattern ("themes" / "NOT_IMPLEMENTED"). Approved scope
cut — no backend theme-store module exists; outside the six v1 epics.

### `themedetail` — DEVIATION — approved scope cut (per `requirements/requirements.md` OQ-1 ruling)

Same placeholder pattern ("themedet / ail" / "NOT_IMPLEMENTED"). Approved
scope cut, same reasoning as `themes`.

### `sharepick` — DEVIATION — approved scope cut (per `requirements/requirements.md` OQ-1 ruling)

Same placeholder pattern ("sharepick" / "NOT_IMPLEMENTED"). Approved scope
cut — no backend share-to-partner-approval module exists; outside the six
v1 epics.

### `shareedit` — DEVIATION — approved scope cut (per `requirements/requirements.md` OQ-1 ruling)

Same placeholder pattern ("shareedit" / "NOT_IMPLEMENTED"). Approved scope
cut, same reasoning as `sharepick`.

### `shareapprove` — DEVIATION — approved scope cut (per `requirements/requirements.md` OQ-1 ruling)

Same placeholder pattern ("shareappr / ove" / "NOT_IMPLEMENTED"). Approved
scope cut, same reasoning as `sharepick`.

### `shareok` — DEVIATION — approved scope cut (per `requirements/requirements.md` OQ-1 ruling)

Same placeholder pattern ("shareok" / "NOT_IMPLEMENTED"). Approved scope
cut, same reasoning as `sharepick`.

## Summary table

| id | Verdict | Note |
|---|---|---|
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

18/18 rows recorded. 0/18 MATCH (10 of the 18 are approved scope cuts per
Product Owner ruling, not defects). All verdicts carry concrete
per-element detail per the judging protocol (no ratio-only rows).
