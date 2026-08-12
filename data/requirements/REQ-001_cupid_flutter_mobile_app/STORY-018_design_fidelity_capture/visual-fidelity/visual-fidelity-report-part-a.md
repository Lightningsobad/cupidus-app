# Visual Fidelity Report — Part A (19 of 37)

Phase: P10. Scope: the 19 ids `alarm, antighost, gallery, home, invite,
joincode, paired, pet, privacy, vibe, splash, welcome, login, register,
forgot, profile, contract, waiting, chat`. Pairs judged: `design-reference-
<id>-android.png` vs `implemented-<id>-emulator-5554.png` under this
directory. Android only (DEC-2), 412px-wide capture. Session: paired couple
Minh & Linh, signed in via Firebase, populated by the P7 seed script
(gallery items, messages, timeline events, one dream jar with
contributions, a couple of expenses, one alarm, one vibe entry) against the
live local backend.

Two of the 19 ids were recaptured in this pass: `profile` and `contract`
(see Recapture note below). The other 17 were judged from the existing P9
captures.

## Headline finding: most Part A screens do not reach a comparable state

12 of the 19 ids (`alarm`, `antighost`, `gallery`, `home`, `invite`,
`joincode`, `paired`, `pet`, `chat`, `splash`, `welcome`, `login`,
`register`, `forgot` — see rows below) render either a load-error banner,
an unstyled placeholder, or text at a drastically oversized scale that
pushes the design's actual layout off the 900px-tall capture. This is
**not** the same class of defect as the 8 ids (`profile`, `contract`,
`chat`, `timeline`, `expense`, `jar`, `jarlist`, `me`) the handoff already
attributed to the fixed backend-URL/DNS infra bug — those 8 were
independently re-verified by Scrum Master outside this pass, and of the
three that land in Part A, `profile` and `contract` are confirmed fixed by
recapture below, and `chat` was explicitly flagged by the handoff to judge
as-is (see its row).

Two separate, apparently systemic issues are visible across the *other* 29
un-recaptured ids (this Part A batch and, going by the pattern, likely part
of Part B too):

1. **Load-error / empty states** on `alarm`, `antighost`, `gallery`,
   `invite`, `joincode`, `pet` — each shows a "Không tải được…" / "Không có
   kết nối mạng" banner with a Retry button, despite the backend answering
   200 at both `127.0.0.1:3005` and `127.0.0.1:3006` at the time of this
   judging pass. `paired` shows a bare, un-styled one-line success message
   with none of the design's stat cards or CTA. These are captured
   evidence from P9, are **out of this handoff's recapture scope** (the
   handoff explicitly names only `profile`/`contract`/`chat`/`timeline`/
   `expense`/`jar`/`jarlist`/`me` as already-fixed, and forbids recapturing
   the other 29 ids), so they are recorded below as-is with the caveat
   that they may be a data/seed timing gap distinct from a design mismatch,
   per the plan's own instruction not to conflate the two. This needs a
   follow-up capture pass before these rows can be treated as final design
   verdicts.
2. **Oversized text scale** on `splash`, `welcome`, `login`, `register`,
   `forgot`, and (now confirmed via recapture) `contract` — the Cupid
   logotype and headline copy render at roughly 3-4x the design's apparent
   size, wrapping single words across multiple full-width lines and pushing
   every other element (buttons, input styling, social login, footer text)
   below the visible 900px capture. This reproduced identically on a fresh
   recapture of `contract`, so it is not a one-off race condition — it looks
   like a real text-scale/theme regression in the preview harness or its
   screens, independent of the backend-URL fix. Flagging for Tech Lead/
   Scrum Master triage; out of scope for this pass to fix.

Two odd bottom-chrome variants also recur on `home`, `gallery`, and `chat`:
a plain two-item nav ("Trang chủ" / "Trò chuyện") with a floating pink
profile-icon FAB overlapping the labels — visibly not the pink-pill
5-tab `CupidTabBar` seen correctly rendered on `alarm`/`privacy`/`vibe`.
Recorded per-row below as a chrome DEVIATION distinct from the AppShell
fix itself, which did work (see `alarm`).

## Recapture note

Two of the 8 already-flagged ids fall inside Part A: `profile` and
`contract`. Both existing P9 captures showed non-content states (`profile`:
a stuck loading spinner; `contract`: "Không có kết nối mạng"). Both were
recaptured in this pass (`--route=cupidpreview://screen/<id>
--width=412 --max-edge=900 --settle-ms=1500`, backend confirmed live at
`127.0.0.1:3005` and `127.0.0.1:3006`, `adb reverse tcp:3005 tcp:3005`
already established). Both now render real content instead of an error/
loading state; their rows below are judged from the new captures. `chat`
is the third already-flagged id in Part A, but the handoff explicitly
directed judging its existing gray-fill capture as-is rather than
recapturing it — done, see its row.

## Verdicts

### `alarm` — DEVIATION (old vs new: chrome fixed, content newly broken)

**Old finding (first audit, pre-fix):** FAIL — bright pink→green gradient
card where design has a dark translucent surface, day chips in a vertical
column instead of a horizontal row, partner-confirmation cards and the
"Xác nhận giờ này" CTA entirely absent, and no chrome (no capture in that
pass showed a tab bar).

**New finding:** The AppShell + backend-live fix **did** land for chrome —
this capture is the only one of the 19 that renders the full, correct
`CupidTabBar` (Nhà / Trò chuyện / Pet / Ví chung / Tôi, pink pill, Nhà
highlighted), matching the design's chrome exactly. But the screen content
itself no longer renders at all: it shows "Không tải được nhắc nhở đồng bộ"
(could not load the synced alarm) with a "Thử lại" retry button, so no
element of the design (time display, day chips, confirmation cards, CTA)
is present to compare. This is a regression from the *content* the first
audit was able to render, even though the *chrome* the first audit flagged
as missing is now fixed. State explicitly: chrome fix = confirmed working;
content fix = not done, worse than before.

Seeded state: P7 reports one alarm seeded; this capture indicates it is not
resolving on load. Chrome applied: **yes**, correctly (AppShell tab
destination-equivalent, design shows the tab bar).

### `home` — DEVIATION (old vs new: content finding unchanged, chrome now partial/wrong)

**Old finding (first audit):** FAIL — still the STORY-001 placeholder,
literal string "Cupid mobile scaffold is running." above six navigation
cards, none of the design's couple header / 247-day counter / Vibe Check /
pet card / Synced Alarm-Zodiac tiles.

**New finding:** Unchanged — this capture is the *same* STORY-001
placeholder text and cards, so the content finding stands exactly as
before; the design still has no implementation here. What changed is the
chrome: a bottom bar is now present, but it is **not** the correct
`CupidTabBar` — it's a plain two-label "Trang chủ" / "Trò chuyện" row with
a pink circular profile-icon FAB overlapping the label text, visually
broken (compare `alarm`'s correct chrome). So: content FAIL is unchanged;
chrome went from "absent" to "present but wrong/overlapping."

Seeded state: n/a (screen is unbuilt). Chrome applied: attempted, but
**incorrect** — wrong widget/style, FAB overlaps nav labels.

### `gallery` — DEVIATION

Implemented shows "Không tải được gallery" (gallery failed to load) with
the same broken two-label nav + overlapping profile FAB seen on `home`,
instead of the design's "Private Gallery" lock screen (fingerprint icon,
"Chỉ mình bạn mở được" headline, AES-256 explainer, "Mở bằng vân tay" CTA,
correct 5-tab chrome with Pet... actually Gallery isn't the highlighted tab
in the design ref — design ref shows Pet highlighted, likely a shared
asset; the design's own chrome is the correct 5-tab bar regardless).
Zero design elements present to compare beyond the app-bar title text.

Seeded state: gallery items reported seeded by P7; not reachable in this
capture. Chrome applied: attempted, same broken variant as `home`.

### `antighost` — DEVIATION

Implemented shows "Không tải được cấu hình. Vui lòng thử lại." (could not
load configuration) with a Retry button, vs. the design's fully populated
Anti-Ghosting settings screen (threshold selector, 3 toggles, emoji-pack
grid, footer note, full chrome). No chrome visible in the implemented
capture at all (screen ends before reaching a nav bar).

Seeded state: n/a — this is a settings/config load, not seed-dependent.
Chrome applied: not reached in this capture.

### `invite` — DEVIATION

Implemented shows "Không thể tạo mã mời. Vui lòng thử lại." (could not
generate invite code) vs. the design's fully rendered invite screen (live
"CPD-8F2K" code, expiry timer, share/copy buttons, 4 relationship-type
cards, CTA). No chrome in view.

Seeded state: n/a. Chrome applied: not reached.

### `joincode` — DEVIATION

Implemented renders a bare, unstyled version of the right screen — a plain
underlined text field labeled "Mã ghép đôi…" and an unstyled pink pill
button "Ghép đôi" — versus the design's icon header, "Nhập mã của người ấy"
title, subtitle, 5 individual boxed code-character inputs (one focused),
Paste/Scan-QR buttons, the styled "Ghép đôi" CTA, and the "Tôi mới là
người tạo mã" link. This is a real (not error-state) render, just missing
essentially all visual styling and half the input affordances.

Seeded state: n/a. Chrome applied: no (design also shows none here —
consistent).

### `paired` — DEVIATION

Implemented shows only a plain pink circle and the line "Đã ghép đôi!"
centered on an unstyled background. Design shows the same core message
("Ghép đôi thành công!") plus the M/L avatar pair with a heart, an
explanatory line, a 3-stat row (days / features / arguments), and the
"Ký Love Contract" CTA — none of which render.

Seeded state: couple pairing itself is seeded/real (P7). Chrome applied:
no (design also shows none — consistent).

### `pet` — DEVIATION

Implemented shows "Không có kết nối mạng" (no network connection) with a
truncated retry-button render, vs. the design's fully populated Love Pet
screen (large animated-style cat art, level/mood chip, name, 6-pet
selection grid, XP bar). No chrome present, though the design reference for
`pet` does show the 5-tab bar (Pet highlighted) — per DEC-4 limb (b) this
screen should be chrome-wrapped, and currently is not.

Seeded state: pet/XP state reported seeded by P7; not reachable here.
Chrome applied: no, but design requires it (limb b) — DEVIATION on chrome
too.

### `privacy` — DEVIATION

Implemented renders genuine, correctly-worded content — the header/body
text "Cupid chia dữ liệu thành 3 tầng. Càng riêng tư thì càng ít rời khỏi
máy bạn." matches the design's copy verbatim — but with none of the visual
styling: no rounded/tinted Level-1/2/3 cards, no icons, no chip tags
("Typing Ghost", "Private Gallery", etc.), and the capture is cut off
partway through the first level card's label ("LE…VE…") before reaching
Level 2, Level 3, the export button, or the chrome. This reads as a
real-content, near-unstyled/skeleton render rather than an error state.

Seeded state: n/a (static settings copy). Chrome: not reached in the
capture; design reference shows the 5-tab bar (Tôi highlighted), so per
DEC-4 limb (b) this screen should be chrome-wrapped — cannot confirm
either way from this capture.

### `vibe` — DEVIATION

Same pattern as `privacy`: implemented shows correct copy verbatim ("Một
tap là Bae biết, không cần gõ chữ nào 🎀" matches the design's subtitle
exactly) and the beginning of the 6-emoji mood grid (3 pill-shaped items
partially visible, truncated labels "V…", "T…", "Đ…"), but with none of
the design's emoji-icon styling, no "today's pick" summary card, no
"7 ngày qua" history strip, and cut off before any chrome. Real content,
mostly unstyled, capture height-truncated.

Seeded state: today's vibe reported seeded by P7 (design shows "Kiệt sức"
already picked); not visible in the truncated capture. Chrome: design
reference shows the 5-tab bar (Nhà highlighted, since Vibe Check is a Home
card, not its own tab) — actually the vibe screen's own design ref shows
tab chrome, so per limb (b) it should be wrapped; not visible in this
capture, cannot confirm.

### `splash` — DEVIATION

Correct gradient background and correct copy ("Cupid", "Đang mở khoá kỷ
niệm của hai bạn…", "Chạm để tiếp tục") are present, but the "Cupid"
logotype renders at roughly 3-4x the design's scale, wrapping across two
full-width lines ("Cupi" / "d") instead of sitting compact and centered.
This pushes layout down but the tap-to-continue text is still visible near
the bottom. Chrome: n/a (design has none here either).

### `welcome` — DEVIATION

Same oversized-text-scale issue: "Cupid" wraps as "Cu" / "pid" across two
huge lines, consuming most of the 900px capture, so the tagline ("Yêu
nghiêm túc. Chia tay đàng hoàng."), the descriptor line, and both CTA
buttons ("Tiếp tục với Google" / "Dùng email") that the design shows below
are pushed out of frame. Gradient and copy content that IS visible matches
the design. Chrome: n/a (consistent, none in design).

### `login` — DEVIATION

Same oversized-text-scale issue: the headline "Mừng bạn quay lại 🎀" alone
consumes most of the frame, and the email/password inputs that are visible
are plain underlined `TextField`s with labels only ("Email", "Mật khẩu") —
none of the design's rounded/tinted input cards, the "Quên mật khẩu?" link,
the gradient "Đăng nhập" CTA, fingerprint-login button, or Google/Facebook
buttons are visible in the capture (pushed below frame by the oversized
header). Chrome: n/a (consistent).

### `register` — DEVIATION

Same pattern: oversized "Tạo tài khoản" headline, then plain unstyled
`TextField`s ("Tên hiển thị", "Email", "Mật khẩu") with no rounded card
background — the design's password-strength bar, terms/privacy checkbox,
and gradient "Tạo tài khoản" CTA are all pushed out of the visible frame.
Chrome: n/a (consistent).

### `forgot` — DEVIATION

Same oversized-text-scale issue on the headline ("Quên mật khẩu là chuyện
thường") and body copy, both of which match the design's wording but at
far larger scale, pushing the email input, the "Gửi link đặt lại" CTA, and
the Private-Gallery reassurance note out of the visible frame. No icon
avatar visible either (design has a circular back-arrow-in-clock icon at
top). Chrome: n/a (consistent).

### `profile` — DEVIATION (recaptured, see note above)

Recapture now renders real content: a circular avatar-placeholder icon and
a rounded input card labeled "TÊN HIỂN THỊ" ("Linh" in design, empty in
this capture since the seeded profile's photo/name state differs from the
design mock). Missing versus design: the "Hồ sơ của bạn" app-bar title
(implemented shows a generic back-arrow + "Lưu" action bar instead), the
pink camera-badge overlay on the avatar, the "Ảnh sẽ được crop tròn"
caption, the date-of-birth/zodiac field, the language field, and the
"Tiếp tục → Love Contract" CTA — all cut off below the visible frame,
consistent with the oversized-label-text pattern seen elsewhere ("TÊN HIỂN
THỊ" alone fills most of the card width at a much larger relative size
than the design's small-caps label).

Seeded state: signed-in profile for account "Linh" per P7. Chrome: n/a
(design also shows none here — this is an onboarding/edit screen, not a
tab destination).

### `contract` — DEVIATION (recaptured, see note above)

Recapture now renders real content: "Bản cam kết số 001" (matches design's
kicker text) followed by the title "Love Contract" — but the oversized-text
bug reproduces here identically, wrapping "Love Contract" across three
full-width lines ("Love" / "Cont" / "ract") that alone consume the entire
900px capture. None of the design's 4 checklist items, the "+ Thêm điều
khoản của riêng tụi mình" link, the "Giữ để ký" CTA, or the Level-2
encryption footnote are visible. Confirms the text-scale issue is not
specific to the auth-flow screens; it reproduces on a fresh, backend-
connected capture.

Seeded state: n/a (static contract copy, paired-couple gated). Chrome: n/a
(consistent, none in design).

### `waiting` — DEVIATION

Implemented renders a real, on-model but generic state: "Đang chờ người
ấy…" with a plain pink circle and one outlined "Làm mới" button. Design
shows a personalized state — "Đang đợi Linh vào…" (names the actual paired
partner), an hourglass icon in a ringed badge, the live invite code card
("CPD-8F2K"), and two buttons ("Gửi lại" to resend, "Giả lập: Linh vào" to
simulate). The implemented version is a simplified/generic placeholder
rather than the personalized, code-bearing design. Text scale here looks
normal (not the oversized bug), which is itself a useful data point that
the scale bug is not universal to every screen.

Seeded state: n/a (pending-pairing UI state). Chrome: n/a (consistent).

### `chat` — DEVIATION (judged as-is per handoff instruction, not recaptured)

Per the handoff's explicit note, this existing capture was judged fresh
rather than recaptured. It shows a flat, unstyled **gray** full-screen fill
with no header, no message bubbles, no input bar, and no theming applied
at all — a stark contrast to the design's dark-gradient chat screen with
the "Minh ↔ Linh · đang online" header, message bubbles, the "Đã seen 5
phút…" nudge banner, emoji-storm action, and composer bar. Only a sliver of
bottom chrome is visible: the same broken two-label "Trang chủ / Trò
chuyện" nav with the overlapping pink profile FAB seen on `home`/`gallery`,
though "Trò chuyện" does appear highlighted/active here, unlike the plain
version on `home`/`gallery`. The flat gray fill strongly suggests an
unthemed/default `Scaffold` background is rendering instead of the actual
`ChatScreen` content — i.e., a build/theming defect on this specific route,
not a data-seeding gap (a data gap would show an empty *themed* chat view,
not a gray blank one).

Seeded state: messages reported seeded by P7 (design shows an active
conversation); not visible in this capture. Chrome: attempted, same broken
variant, but with the correct tab shown active.

## Summary table

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

19/19 rows recorded. 0/19 MATCH. All verdicts carry concrete per-element
detail per the judging protocol (no ratio-only rows).
