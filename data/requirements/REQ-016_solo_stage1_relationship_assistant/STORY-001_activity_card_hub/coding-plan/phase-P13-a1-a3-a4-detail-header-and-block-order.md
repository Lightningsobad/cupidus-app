# P13 — A-1 + A-3 + A-4: ô tràn header, ngoại lệ căn lề A8, thứ tự khối

- Lane: Mobile
- Story: REQ-016 / STORY-001
- Phán quyết: **A-1**, **A-3**, **A-4** (`req_master.md` → `## Design Ruling
  Log`), cộng hai action item gộp vào dispatch: **D-20** (4 codepoint icon) và
  **R8-F-1** (màu dòng phụ)
- Đặc tả: `coding-plan/master-plan.md` §12
- BaseHead: `9107336`
- Date: 2026-09-10
- AC chạm tới: AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19 — **giữ nguyên
  hành vi**, chỉ đổi lối vào

## 1. A-1 — ba thứ rời thân màn, vào ô tràn

`_header` trước đây chỉ có nút back + `card_detail_status_pill`. Nay có thêm
`CardDetailOverflowMenu`, đúng ba mục:

| Mục | Mở thẳng cái gì | Key |
|---|---|---|
| Chuyển trạng thái | `showStatusChangePicker` (4 lựa chọn, AC-14) | `card_detail_overflow_changeStatus` |
| Xoá thẻ | `showDeleteCardDialog` (trung tính, AC-16) | `card_detail_overflow_delete` |
| Đánh dấu đã trả lời / chưa trả lời | sheet `card_detail_reply_sheet` | `card_detail_overflow_markReply` |

Sáu bất biến §12.2 và nơi chúng được giữ:

| # | Bất biến | Nơi thi hành |
|---|---|---|
| 1 | Mỗi mục mở đúng một hộp thoại/sheet, một tầng | `_runOverflowAction` là một `switch` ba nhánh, mỗi nhánh gọi thẳng một hàm `show*` |
| 2 | Cấm menu lồng menu | `card_detail_overflow_menu_test.dart` khẳng định không `PopupMenuButton` nào nằm trong bất kỳ item nào |
| 3 | `status_change_picker.dart` / `delete_card_dialog.dart` giữ nguyên | hai file **không** nằm trong diff của P13 |
| 4 | AC-14 hai chiều còn sống | test mở picker từ ô tràn, thấy đủ 4 trạng thái, lùi *Đã hẹn ngày* → *Mới nghĩ ra* vẫn bật hộp thoại AC-15 |
| 5 | Thẻ rút gọn P4 không đổi | `activity_card_tile.dart` không nằm trong diff; test tile chạy nguyên vẹn, không sửa một dòng |
| 6 | Ranh giới đạo đức R-1b/AC-18 nguyên vẹn | `_invitedBlock` được **đem nguyên** vào sheet, không sửa nội dung; test quét toàn bộ chữ trong sheet, cấm `lúc` / `phút` / `:` |

### 1.1 Một chỗ §12.2 phải đọc, đã chốt

§12.6 rule 4 gọi mục thứ ba là "cờ đã rủ", còn AC-17 nguyên văn chỉ nói *đã
trả lời / chưa trả lời*. Hai cờ này nằm chung một khối và
`card_detail_invited_chip` là **control `invited` duy nhất của cả app** — chip
trên tile P4 là chip *trả lời*, không phải chip *đã rủ*. Nếu mục thứ ba chỉ mở
cờ trả lời thì `invited` mất đường vào hoàn toàn.

Cách đã cài: mục thứ ba mở **một** sheet (`card_detail_reply_sheet`) render
`_invitedBlock` y nguyên. Giữ được cả bốn thứ cùng lúc — bất biến 1 (một tầng,
một sheet), hai Key cũ, hai cờ hai trạng thái, và ranh giới đạo đức. Sheet
dùng `BlocProvider.value` + `BlocBuilder` nên chip trong sheet sống theo cubit
của màn, bấm là đổi ngay, không phải đóng mở lại.

**Khoảng hở giữ nguyên, không tự quyết:** uiux-spec §5 mô tả header là "icon
chia sẻ + ô tràn ⋯". Repo không có hành vi chia sẻ nào cho thẻ. P13 dựng ô
tràn và **không** bịa hành vi chia sẻ, đúng §12.2. Đây là quyết định phạm vi
cho Scrum Master / PO.

## 2. A-3 — ngoại lệ căn lề, đóng ở đúng một chỗ

Một biến `memory` trong `_header`, hai `Spacer()` có điều kiện quanh pill:

```dart
if (memory) const Spacer(),
DecoratedBox(key: const Key('card_detail_status_pill'), ...),
if (!memory) const Spacer(),
```

Không tham số căn lề cho từng trạng thái, không suy rộng. Test đo bằng toạ độ:
ở `memory` khoảng cách `overflow.left - pill.right` đúng bằng `CupidSpacing.sm`;
ba trạng thái kia `pill.left - back.right` bằng `sm` và khoảng hở bên phải lớn
hơn `sm`.

## 3. A-4 — thứ tự khối và hàng meta

Thứ tự mới: **tiêu đề → (ảnh, chỉ A8) → meta → ghi chú → chip → link → CTA**.
`_statGrid` bị thay bằng `_metaBlock` (`card_detail_meta`):

- hàng ngày hẹn `card_detail_meta_date` — glyph `event` + `card.scheduledOn`,
  hoặc `chưa hẹn ngày`
- lưới 2x2: THỜI LƯỢNG / KHUNG GIỜ, rồi KHOẢNG CÁCH / GIÁ

Chuỗi thời lượng lấy từ formatter P12, không nối chuỗi tại chỗ. KHUNG GIỜ
(`card_detail_time_slot`) là ô **chỉ đọc** trong P13 — cột `time_of_day_slot`
đã có từ P11 nhưng chưa có phán quyết nào mở editor cho nó, và §12.8 cấm mở
rộng phạm vi. Ánh xạ morning/noon/afternoon/evening → Sáng/Trưa/Chiều/Tối,
`null` → `chưa rõ`.

`trong nhà / ngoài trời` **ở lại hàng chip**, không vào meta, dù §12.4 liệt kê
nó trong sáu giá trị meta: nó là control hai trạng thái người dùng bấm để đổi,
biến nó thành ô meta chỉ đọc là mất một đường sửa đang có. Năm trên sáu giá
trị meta nằm trong `_metaBlock`.

`_actionRow` bị xoá cùng lúc: sau A-1 nó không còn caller nào, để lại sẽ thành
`unused_element`.

**Chiều cao không phình.** Lưới meta thêm ~96px nhưng A-1 gỡ hai hàng hành
động 48px, khối invited và một khoảng `lg`, nên tổng chiều cao giảm. Đây là
đúng cái đã làm đỏ `card_lifecycle_ui_test.dart` ở P12 (khung mặc định
800x600), lần này kiểm lại và cả file vẫn xanh.

## 4. D-20 — bốn codepoint, tra từ cmap thật

Đọc trực tiếp `assets/fonts/MaterialSymbolsRounded-Variable.ttf` bằng
`fontTools` (4382 mục cmap). Bốn hằng mới trong `cupid_icons.dart`:

| Tên §12.5 | Hằng | Codepoint | Bằng chứng |
|---|---|---|---|
| event | `CupidIcons.event` | `0xe878` | gid 1281, 5 contour; `0xe24f` alias cùng gid |
| history | `CupidIcons.history` | `0xe889` | gid 548, 2 contour; `0xe28e`, `0xe8b3` alias cùng gid |
| image | `CupidIcons.image` | `0xe3f4` | gid 2172, 4 contour; `0xe251`, `0xe3c4` alias cùng gid; `broken_image`/`0xe3ad` là glyph khác, không thay |
| trash | `CupidIcons.delete` | `0xe872` | gid 1, 5 contour; `0xe92e` alias cùng gid; `delete_forever`/`0xe92b` là glyph khác, không thay |

**`trash` không phải tên glyph có thật trong font này.** Cả cmap chỉ có một tên
dính chữ trash là `restore_from_trash` (thùng rác có mũi tên — hình khác). Hình
thùng rác trơn font phát hành dưới tên Material là `delete`. Nên đây là đúng
glyph §12.5 mô tả, đọc từ cmap dưới cái tên font thật sự công bố — không phải
codepoint bịa, cũng không phải icon thay thế. Cùng tình huống với `redeem` đã
có sẵn trong file. Không codepoint nào phải đoán, nên không có điều kiện STOP
nào của dispatch bị kích hoạt.

**Nút ô tràn dùng ký tự, không dùng codepoint thứ năm.** Font không có
`more_horiz`. Ký tự là **U+2026 `…`**, không phải `⋯` (U+22EF) như §12.2 viết:
lần chụp đầu ra hộp tofu, tra lại thì U+22EF không có trong cmap của cả
`Nunito-Variable.ttf` lẫn `Roboto-Variable.ttf`, còn U+2026 có ở cả hai. Đây
cũng đúng ký tự ô tràn của tile P4 (`activity_card_tile.dart:321`), nên hai ô
tràn của story này giống hệt nhau.

## 5. R8-F-1 — màu dòng phụ

Dòng phụ D-19 dưới CTA đổi từ `colorTextMuted` sang `colorAccentLilac`. Vẫn
đúng một dòng, không nền `--grad`, không dạng pill — §12.8 không bị chạm.

## 6. File đã đụng

§12.7 dự kiến 6 file; thực tế **7**, thêm một file test bắt buộc:

| # | File | Thay đổi |
|---|---|---|
| 1 | `mobile/lib/features/activity_cards/presentation/widgets/card_detail_overflow_menu.dart` | **Mới** |
| 2 | `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` | header, ngoại lệ căn lề, thứ tự khối, `_metaBlock`, màu dòng phụ |
| 3 | `mobile/lib/design_system/icons/cupid_icons.dart` | 4 codepoint tra cmap |
| 4 | `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart` | rule 1-6 |
| 5 | `mobile/test/features/activity_cards/card_detail_overflow_menu_test.dart` | **Mới** |
| 6 | `visual-fidelity/visual-fidelity-report.md` + 3 PNG | round 9 |
| 7 | `mobile/test/features/activity_cards/card_lifecycle_ui_test.dart` | **ngoài §12.7** — ba test cũ bấm vào `card_detail_change_status_row` / `card_detail_delete_row` / chip invited trong thân màn; A-1 dời cả ba nên chúng phải đi qua ô tràn. Chỉ đổi *đường bấm*, không đổi một khẳng định nào. |

## 7. Lệnh và kết quả

- `flutter analyze lib test` → **191 issue, 0 error**. Đúng bằng mốc P11/P12
  (191 / 0), delta **0**. Bảy dòng thuộc `activity_cards` đều là
  `prefer_initializing_formals` có sẵn, không dòng nào trỏ vào file P13 đụng.
- `flutter test` toàn cây, một lần chạy, không lọc output:
  **+1948 pass, ~4 skip, −14 fail** (P12: +1937 / ~4 / −14). +11 test đúng
  bằng số test P13 thêm (6 rule §12.6 + 5 test menu). **0 đỏ mới**; 14 test đỏ
  trùng từng dòng với bảng `### S9-F-5` (`BUG-20260907-001`): `design_system` 3
  · `love_contracts` 3 · `auth` 4 · `gallery` 1 · `in_app_notifications` 1 ·
  `zodiac` 2.
- `flutter test test/features/activity_cards` → **175 pass, 2 skip, 0 fail**
  (P12: 164 / 2 / 0).
- Chụp lại bằng chứng:
  `flutter test .../activity_card_detail_screen_test.dart
  --dart-define=CAPTURE_VISUALS=true` → `+26: All tests passed!`, ba PNG được
  ghi lại. Một lần chụp này trả luôn khoản recapture P12 còn treo.
- Runtime startup smoke: **NOT_APPLICABLE** theo §10.8 (R-2).

## 8. Còn treo, không phải việc của lane này

1. **Icon chia sẻ** (§12.2) — uiux-spec §5 có, repo không có hành vi. Quyết
   định phạm vi cho Scrum Master / PO.
2. **VISUAL_FIDELITY vẫn FAIL** trên D-8, không đổi. P13 không mở cũng không
   đóng finding nào; chi tiết ở §11 của `visual-fidelity-report.md`.
3. **KHUNG GIỜ chưa có editor** — cột P11, hiện chỉ đọc. Cần một phán quyết
   nếu muốn sửa được.
