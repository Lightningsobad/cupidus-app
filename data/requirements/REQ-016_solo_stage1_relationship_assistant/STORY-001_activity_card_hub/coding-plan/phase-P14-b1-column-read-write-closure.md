# P14 — F-2 + F-3: khép vòng đọc–ghi cho 5 cột B-1

- Lane: Mobile
- Story: REQ-016 / STORY-001
- Nguồn: review round-9 (`review/review-report.md`, `PATCH_REQUIRED`) — **F-2**
  (3 cột chỉ-ghi, không có đường đọc trên màn) và **F-3** (`time_of_day_slot`
  chỉ-đọc, không có đường ghi)
- Đặc tả: `coding-plan/master-plan.md` §13
- BaseHead: `59d8564`
- Date: 2026-09-10
- AC chạm tới: AC-6, AC-8 — **giữ nguyên hợp đồng**, chỉ mở nốt đường còn thiếu
  cho 5 field B-1 đã chốt ở `req_master.md` `## Design Ruling Log` (B-1)

## 1. Khuyết tật P14 vá

B-1 cấp 5 cột (`duration_minutes`, `time_of_day_slot`, `note_keywords`,
`link_source_label`, `link_saved_at`). P11 dựng cột, P12 dựng formatter, P13
dựng lưới meta. Sau P13 bảng đường đi còn thủng đúng như review mô tả:

| Cột | Đường đọc trước P14 | Đường ghi trước P14 | Sau P14 |
|---|---|---|---|
| `duration_minutes` | có (ô THỜI LƯỢNG) | có (P8/P12) | không đổi |
| `time_of_day_slot` | có (ô KHUNG GIỜ, **chỉ đọc**) | **không** → F-3 | có cả hai |
| `note_keywords` | **không** → F-2 | **không** → F-2 | có cả hai |
| `link_source_label` | **không** → F-2 | **không** → F-2 | có cả hai |
| `link_saved_at` | **không** → F-2 | **không** → F-2 | có cả hai |

Đây là lý do §13.1 cấm chia đôi tập 7 file: mọi cách cắt đều để lại một nửa
chỉ-đọc hoặc chỉ-ghi trên cùng tập cột — đúng khuyết tật đang vá.

## 2. F-3 — KHUNG GIỜ thành ô bấm được

`time_of_day_slot_picker.dart` (mới) theo khuôn `status_change_picker.dart`:
sheet **một tầng**, đúng 5 lựa chọn, không menu lồng menu.

- `enum TimeOfDaySlotChoice { morning, noon, afternoon, evening, unset }`
- `timeOfDaySlotForChoice` toàn phần trên 5 lựa chọn, `unset → null`
- nhãn Sáng / Trưa / Chiều / Tối / Chưa rõ
- mỗi dòng `Key('time_of_day_slot_option_<choice>')`, `Semantics(button: true,
  selected: …)`, `ConstrainedBox(minHeight: platform.tapTarget)`, dấu
  `CupidIcons.check` màu `colorAccentPink` trên dòng đang chọn

Ô KHUNG GIỜ trong `_metaBlock` được bọc `Semantics(button: true)` +
`GestureDetector(key: Key('card_detail_time_slot_cell'))`. Sheet bị vuốt bỏ trả
`null` → **không ghi gì** (khác hẳn chọn *Chưa rõ*, vốn ghi `null` để xoá cột).

## 3. F-2 — ba cột có mặt trên màn

- **Dải chip từ khoá** trong `_noteBlock`: `Wrap` key
  `card_detail_note_keywords`, chip thứ `i` key `card_detail_note_keyword_$i`,
  ô nhập key `card_detail_note_keyword_field` hint `Thêm từ khoá`. Thẻ có
  `noteKeywords == null` **không** dựng dải rỗng.
- **Dòng xuất xứ link** ngay trên `_sourceLinkRow`: `Row` key
  `card_detail_link_provenance`, ô nhãn `card_detail_link_source_label_field`
  hint `Link này từ đâu?`, và `Text` key `card_detail_link_saved_at` đọc
  `lưu <ngày>`. Thiếu cả hai giá trị → không dựng dòng; và
  `card_detail_source_link_field` vẫn tìm thấy được ở cả hai trường hợp.
- Ghi theo **commit-on-blur / commit-on-submit**, không ghi mỗi phím.

Formatter thuần trong `vi_field_format.dart`: `kNoteKeywordSeparator = ','`,
`parseNoteKeywords`, `formatNoteKeywords` (rỗng → `null`, **không bao giờ** trả
`''`), `formatShortViDate` (epoch → `28/8`, không đệm 0, không năm; `null` →
`''`).

## 4. Một chỗ lệch §13.4, đã chốt và không giấu

§13.4 giao việc suy `linkSavedAt` cho `_commitSourceLink` **trên màn**
(`activity_card_detail_screen.dart:221-228`). Đã đặt trong **cubit**
(`editSourceLink`) thay vì đó, và `_commitSourceLink` giữ nguyên không sửa.

Lý do: `ActivityCardEdit` là ghi **toàn ảnh** — field `null` là *xoá cột*, nên
`sourceLink` và `linkSavedAt` bắt buộc phải đi trong **cùng một** lần
`_persist`, đúng chữ của §13.4 ("một lần ghi duy nhất"). `_persist` là hàm
private của cubit; màn không gọi được. Đặt trên màn thì hoặc phải nới `_persist`
thành public (mở đường cho caller khác ghi nửa vời), hoặc phải gọi hai editor
liên tiếp — đúng cái rule 6 §13.6 cấm. Chọn giữ **bất biến** thay vì giữ **chỗ
đặt**. Luật suy vẫn nguyên văn §13.4: link mới → đóng dấu `DateTime.now()`; link
không đổi → giữ dấu cũ; xoá link → cả hai về `null`.

## 5. Bảy rule §13.6

| # | Rule | Test | Kết quả |
|---|---|---|---|
| 1 | `editTimeOfDaySlot` đặt/xoá được, đọc lại từ repository | `time_of_day_slot_picker_test.dart:77`, `:94`, `:111` | PASS |
| 2 | Chạm KHUNG GIỜ → picker 5 lựa chọn; chọn → ô đổi nhãn; *Chưa rõ* → về `chưa rõ` | `activity_card_detail_screen_test.dart:1023`, `:1043` | PASS |
| 3 | Có `noteKeywords` → đúng số chip đúng thứ tự; `null` → không dựng dải rỗng | `…screen_test.dart:1072`, `:1125` | PASS |
| 4 | `cà phê , , sách ` → lưu `cà phê,sách`; xoá hết → `null`, không `''` | `…screen_test.dart:1116` + `vi_field_format_test.dart:169`, `:179` | PASS |
| 5 | Dòng xuất xứ hiện 2 giá trị đúng dạng ngày Việt; thiếu cả hai → không dựng; `card_detail_source_link_field` vẫn tìm thấy | `…screen_test.dart:1154`, `:1181` + `vi_field_format_test.dart:200` | PASS |
| 6 | Link mới → `linkSavedAt` sau **đúng một** lần ghi; xoá → cả hai `null`; sửa `note` sau đó **không** đổi `linkSavedAt` | `…screen_test.dart:1154` (chống thoái lui cho `_withEdits`) | PASS |
| 7 | Thứ tự khối A-4 không đổi | `…screen_test.dart:993` (`title → meta → note → chip → link → CTA`) | PASS |

## 6. File đã đụng

Đúng 7 file mã/test của §13.7, không thêm không bớt:

| # | File | Thay đổi |
|---|---|---|
| 1 | `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart` | 4 editor mới; `_persist`/`_withEdits` nhận thêm 8 tham số (4 giá trị + 4 cờ `clear`); khối carry-forward thay đoạn ternary cũ ở ~dòng 405 |
| 2 | `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` | dải chip + ô thêm từ khoá; dòng xuất xứ; ô KHUNG GIỜ thành vùng chạm. **Dòng 1004 không đụng** (§13.8/F-5) |
| 3 | `mobile/lib/features/activity_cards/presentation/widgets/time_of_day_slot_picker.dart` | **Mới** |
| 4 | `mobile/lib/features/activity_cards/presentation/formatters/vi_field_format.dart` | `parseNoteKeywords` / `formatNoteKeywords` / `formatShortViDate` |
| 5 | `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart` | rule 2-7, cộng fixture `_captureCard` và `_cardWithSavedLink` |
| 6 | `mobile/test/features/activity_cards/vi_field_format_test.dart` | rule 4 phần thuần hàm + ngày ngắn (6 test mới) |
| 7 | `mobile/test/features/activity_cards/time_of_day_slot_picker_test.dart` | **Mới** — rule 1 (4 test) |

Cộng ba artifact: file này, mục evidence trong `coding-plan/test-results.md`
(gồm cả kết luận F-5 §13.5 và bằng chứng R-2), và
`visual-fidelity/visual-fidelity-report.md` §12 + 3 PNG chụp lại.

## 7. Lệnh và kết quả

- `flutter analyze lib test --no-fatal-infos --no-fatal-warnings` → **exit 0**,
  `191 issues found`, `grep -c " error • "` = **0**. Đúng bằng mốc P11/P12/P13,
  delta **0**. (Không có cờ đó, `flutter analyze` trả **exit 1** cho 191 lint
  info/warning tồn đọng sẵn của repo dù 0 error — số issue y hệt, chỉ khác mã
  thoát.)
- `flutter test test/features/activity_cards --reporter failures-only` →
  **exit 0**, `+192 ~2: All other tests passed!` (P13: 175 / 2 / 0). **+17**
  đúng bằng số test P14 thêm: 7 màn + 4 picker + 6 formatter.
- Chụp lại bằng chứng:
  `flutter test .../activity_card_detail_screen_test.dart
  --dart-define=CAPTURE_VISUALS=true --reporter failures-only` → **exit 0**,
  `+33: All tests passed!`, ba PNG được ghi lại. Chạy lại lần hai cho ra đúng
  cùng hash sha256 (ghi ở `visual-fidelity-report.md` §12), nên khung chụp là
  tái lập được chứ không phụ thuộc một lần chạy.
- **Runtime startup smoke (R-2): ĐẠT**, chạy ở cấp story theo §6 chứ không phải
  ở P14 (§13.9). Chuỗi thật v2→v3→v4 trên máy thật, đủ 4 điều kiện rule-12g.
  Bằng chứng đầy đủ ở `coding-plan/test-results.md` §
  `Story Runtime Startup Smoke` → *Lần chạy thứ 4*, kèm log và ảnh ở
  `coding-plan/evidence/rule-12g-r2-run4/`.

## 8. F-5 — không có việc phải làm, đã kiểm ở mã nguồn

Review round-9 đòi sửa `activity_card_detail_screen.dart:1004`. Tech Lead đã
kiểm và bác ở §13.5: dòng đó là **icon CTA chính** trong `_primaryAction`, chọn
giữa `menuBook` và `schedule` — §12.5 chưa bao giờ giao `event`/`history` cho
CTA, nên đổi nó là regression chứ không phải vá. §13.8 cấm đụng vào, và P14
không đụng.

**Lưu ý số dòng cho vòng review cuối:** phần chèn của P14 đẩy mã đó xuống
**dòng 1208**; dòng 1004 bây giờ là nhánh `null =>` của nhãn chip trong/ngoài
(`trong hay ngoài?`). Cả hai cách đánh số đều không phải một token
`event`/`history` bị bỏ rơi, và không dòng nào bị sửa. Bảng bằng chứng 4 dòng
chép nguyên ở `coding-plan/test-results.md` § F-5.

## 9. Còn treo, không phải việc của lane này

1. **`VISUAL_FIDELITY` vẫn `FAIL`** — nhưng **không phải trên D-8**. P14 đóng
   D-15, D-17, D-22 và mở D-29. Token đỏ trên D-28, D-20, D-21, D-23, D-26,
   D-29; chi tiết và trích dẫn ở `visual-fidelity-report.md` §12.3 (đây là nội
   dung F-4 yêu cầu sửa).
2. **D-20 — lý do treo đã cũ.** §9.3 của report viết D-20 kẹt vì
   "`cupid_icons.dart` has no `event` token"; P13 đã thêm
   `CupidIcons.event` (`cupid_icons.dart:349`) nên nửa lý do đó không còn đúng.
   Nửa còn lại vẫn đúng: đổi glyph CTA ở
   `activity_card_detail_screen.dart:1208` nằm ngoài phạm vi ghi của P14 và
   §13.8 cấm mở rộng. **P14 không mở lại D-20**; xếp phase hay không là quyết
   định của Scrum Master.
3. **D-29 (mới)** — hàng ngày trên A8 in thẳng chuỗi ISO `2026-10-01`
   (`activity_card_detail_screen.dart:805-807`) trong khi canvas viết ngày dạng
   Việt. Rẻ và thuần hiển thị, nhưng ngoài phạm vi P14.
4. **Icon chia sẻ (F-6)** — Scrum Master đã đóng là ngoài phạm vi STORY-001
   (`req_master.md` `## Design Ruling Log`, R9-F-6). Không đụng.
