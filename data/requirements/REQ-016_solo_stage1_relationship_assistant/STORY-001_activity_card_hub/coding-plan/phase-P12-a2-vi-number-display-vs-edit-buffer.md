# P12 — A-2: chuỗi hiển thị đã định dạng vs. bộ đệm sửa thô

- Lane: Mobile
- Story: REQ-016 / STORY-001
- Phán quyết: **A-2** (`req_master.md` → `## Design Ruling Log`, 2026-09-09),
  thi hành qua **AC-8**, khối "Định dạng hiển thị vs. bộ đệm sửa"
- Đặc tả: `coding-plan/master-plan.md` §11
- BaseHead: `86e66dd`
- Date: 2026-09-09
- AC-6 không đổi: luồng tạo nhanh vẫn đúng một trường bắt buộc

## 1. Bốn bất biến §11.1 và nơi chúng được giữ

| # | Bất biến | Nơi thi hành |
|---|---|---|
| 1 | Ô không focus → chuỗi đã định dạng | `initState` nạp `format*(...)`; nhánh `else` của listener trong `_bindNumericField` |
| 2 | Ô được focus → văn bản thô | nhánh `if (node.hasFocus)` của `_bindNumericField` |
| 3 | Bộ đệm đang gõ luôn thô | không có `TextInputFormatter` nhóm nghìn nào được thêm; `FilteringTextInputFormatter.digitsOnly` sẵn có chỉ lọc ký tự, không chèn dấu |
| 4 | Tầng dữ liệu không nhận chuỗi đã định dạng | `_commitPrice` / `_commitDistance` / `_commitDuration` parse rồi mới gọi cubit; cubit chỉ nhận `int?` / `double?` |

Bất biến 3 là chỗ dễ trượt nhất, nên nó có test riêng gõ dồn từng ký tự tới
`1234567` và khẳng định controller không mọc dấu `.` ở bất kỳ bước nào.

## 2. Quy ước Việt đã cài (§11.2)

| Trường | Cột | Chuỗi hiển thị | Bộ đệm thô |
|---|---|---|---|
| Giá | `price_vnd` INTEGER | `180.000đ` | `180000` |
| Khoảng cách | `distance_km` REAL | `1,8 km` | `1.8` |
| Thời lượng | `duration_minutes` INTEGER | `45 phút` · `2 tiếng` · `1 tiếng 30 phút` | `90` |

- Không dùng `intl`/`NumberFormat`. `vi_field_format.dart` không import gì
  ngoài lõi Dart, nên chuỗi không đổi theo locale máy — đây là hằng số sản
  phẩm, đúng như §11.3 yêu cầu.
- Không sinh tiền tố `~` ở bất kỳ nhánh nào; có test khẳng định điều đó.
- Parser khoảng cách nhận **cả** `1,8` lẫn `1.8`, vì người dùng gõ tay có thể
  dùng dấu nào cũng được; bộ đệm thô vẫn ghi dấu chấm để `double.tryParse`
  đọc được.

**Một chỗ §11.2 để ngỏ, đã chốt trong lúc cài.** Ô "Chuỗi hiển thị" của thời
lượng liệt kê ba ví dụ `2 tiếng · 90 phút · 1 tiếng 30 phút` mà không gán ví
dụ nào cho giá trị nào; đọc theo nghĩa "một đầu vào ra một chuỗi" thì `90`
vừa phải ra `90 phút` vừa phải ra `1 tiếng 30 phút`, tức là mâu thuẫn. Đã đọc
đó là **ba hình dạng**, và chọn luật xác định duy nhất sinh ra đúng ba hình
dạng ấy:

- `< 60` → `N phút` (45 → `45 phút`)
- chia hết cho 60 → `N tiếng` (120 → `2 tiếng`)
- còn lại → `H tiếng M phút` (90 → `1 tiếng 30 phút`)

Nếu Tech Lead muốn `90` hiện `90 phút`, đó là đổi luật ở một chỗ duy nhất
(`formatDurationMinutes`) cộng ba dòng test.

## 3. Điểm tích hợp (§11.3)

`_commitPrice` / `_commitDistance` **vẫn là cửa ghi duy nhất**; P12 bọc quanh
chúng chứ không thay. Thay đổi bên trong chúng là đổi `int.tryParse(text)` →
`parsePriceVnd(text)` và `double.tryParse(text)` → `parseDistanceKm(text)`,
để một ô chưa bao giờ được focus — tức vẫn đang giữ chuỗi `180.000đ` — vẫn
commit ra số 180000 thay vì `null`. `_commitDuration` là cửa thứ ba, cùng
khuôn.

`_bindNumericField` thay `_commitOnBlur` **chỉ cho ba ô số**; ba ô chữ (tiêu
đề, ghi chú, link) vẫn dùng `_commitOnBlur` nguyên như cũ.

`setState` trong listener là vì hậu tố đơn vị: chuỗi đã định dạng tự mang đơn
vị (`180.000đ`), nên `suffixText` của `InputDecoration` chỉ được vẽ khi ô đang
ở trạng thái thô, không thì màn hình in đơn vị hai lần (`180.000đ đ`).

`_replaceText` gán thẳng vào `controller.value`. Gán bằng chương trình không
chạy `inputFormatters`, nên chuỗi `180.000đ` sống sót qua bộ lọc
`digitsOnly` của chính ô đó — đây là lý do bất biến 3 và ô giá không xung đột.

## 4. Hai thay đổi ngoài chữ §11.5 (đều bắt buộc, không phải mở rộng phạm vi)

### 4.1 Ô THỜI LƯỢNG phải tồn tại thì mới có gì để định dạng

§11.3 yêu cầu "gắn `FocusNode` listener cho **ba** ô", nhưng trước P12 màn chi
tiết chỉ có hai ô số. `duration_minutes` là cột P11 vừa thêm và chưa có
editor. Nên P12 thêm một `_statCard` thứ ba, khoá
`card_detail_duration_field`, nhãn `Thời lượng`, cùng khuôn với hai ô sẵn có.

Lưới stat giữ **một hàng ba cột**, không phải hai hàng. Bản cài đầu dùng hàng
thứ hai và làm đỏ một test không thuộc phạm vi P12:
`card_lifecycle_ui_test.dart` → "AC-16 · the dialog asks once" tap vào
`card_detail_delete_row`, và hàng stat thứ hai đẩy hàng xoá xuống `y=643`
trong khung 800×600 mặc định, ngoài tầm hit-test. Ba cột giữ nguyên chiều cao
lưới nên test đó xanh trở lại mà không phải sửa file test ngoài phạm vi.

`KHUNG GIỜ` (`time_of_day_slot`) **không** được thêm: nó không nằm trong ba
trường §11.2.

### 4.2 `_withEdits` đang bỏ rơi năm cột B-1 — lỗi mất dữ liệu tiềm ẩn

`ActivityCardDetailCubit._persist` gọi
`updateCardDetails(id, ActivityCardEdit.from(next))`, tức **ảnh chụp toàn
phần**: trường vắng mặt là lệnh xoá cột, không phải "giữ nguyên". Sau P11,
`_withEdits` dựng `ActivityCard` mới nhưng không mang theo năm cột B-1, nên
mọi lần sửa bất kỳ trường nào — gõ một ký tự vào ghi chú — sẽ âm thầm `NULL`
hoá `duration_minutes`, `time_of_day_slot`, `note_keywords`,
`link_source_label`, `link_saved_at`.

Lỗi này chưa nổ vì trước P12 không có đường nào ghi năm cột đó từ UI. Thêm
`editDurationMinutes` là đúng cái làm nó nổ, nên P12 phải vá cùng lúc:
`_withEdits` nay mang `durationMinutes` qua cặp `durationMinutes` /
`clearDurationMinutes` như các trường có editor, và bốn cột còn lại được chép
thẳng từ `state.card`. Có test widget khẳng định một lần sửa ghi chú vẫn giữ
đủ năm giá trị trong `ActivityCardEdit` đi tới repository.

## 5. File đã đổi

| # | File | Thay đổi |
|---|---|---|
| 1 | `mobile/lib/features/activity_cards/presentation/formatters/vi_field_format.dart` | **Mới**. 9 hàm thuần (`format*` / `raw*` / `parse*` × 3 trường) + 2 hằng phân cách. Không phụ thuộc widget, để P13 dùng lại cho hàng meta A8. |
| 2 | `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` | `_duration` controller + `_durationFocus`; `_bindNumericField`, `_replaceText`; `_commitPrice`/`_commitDistance` đổi sang parser Việt; `_commitDuration` mới; ô stat thứ ba; `suffixText` chỉ vẽ khi focus; bỏ `_trimDouble` cục bộ (hết chỗ dùng — `activity_card_tile.dart` có bản riêng, không đụng tới). |
| 3 | `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart` | `editDurationMinutes`; `_persist`/`_withEdits` nhận `durationMinutes`/`clearDurationMinutes`; `_withEdits` chép đủ năm cột B-1. |
| 4 | `mobile/test/features/activity_cards/vi_field_format_test.dart` | **Mới**. 26 test — rule 1 §11.4. |
| 5 | `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart` | Nhóm `A-2/AC-8` 6 test — rule 2, 3, 4 §11.4; thêm `durationMinutes` vào `_editableFields`; `_pumpEditableCard` + `_cardWithB1()`. |

## 6. Test bắt buộc §11.4 → nơi đáp ứng

| Rule | Nội dung | Test |
|---|---|---|
| 1 | formatter/parser thuần, ba trường, hai chiều, biên `null`/`0`/rất lớn/rác, vòng `parse(format(x)) == x` | `vi_field_format_test.dart`, 26 test, mỗi trường có nhóm riêng cộng một test round-trip lặp qua danh sách giá trị |
| 2 | mất focus hiện chuỗi đã định dạng; chạm vào ô thì thô | `an unfocused field shows the formatted Vietnamese string`, `focusing a field swaps it to the raw buffer, blurring it swaps it back` |
| 3 | gõ từng ký tự vào ô giá, controller không mọc dấu phân cách | `typing into the price field never grows a separator mid-typing` |
| 4 | đường ghi vẫn nhận số | `the write path receives numbers, never a formatted string` (`isA<int>()` / `isA<double>()`), cộng `clearing a field writes null rather than a zero` và `an unrelated edit carries the five B-1 columns through the full-snapshot write` |

## 7. Điều cấm §11.6 — trạng thái

- `quick_capture_sheet.dart` / AC-6: **không đụng**. Không có thay đổi nào
  ngoài màn chi tiết.
- 4 nhãn SC-4 và số hành động chính: **không đổi**. `primaryActionFor` và
  `_screenCtaText` nguyên vẹn.
- Kiểu cột: **không đổi**. `price_vnd` INTEGER, `distance_km` REAL,
  `duration_minutes` INTEGER. P12 không chạm schema, không có migration.

## 8. Cổng kiểm chứng (tự chạy trong phiên này)

- `flutter analyze lib test` → **191 issue, 0 error**. Đúng bằng mốc P11
  (191 / 0), delta **0**. Không dòng nào trỏ vào `vi_field_format.dart` hay
  `activity_card_detail_screen.dart`.
- `flutter test` toàn cây, một lần chạy duy nhất, không lọc output:
  **+1937 pass, ~4 skip, −14 fail**.
- 14 test đỏ trùng khớp từng dòng với bảng "14 test đỏ còn lại"
  (`BUG-20260907-001`): `design_system` 3 · `love_contracts` 3 · `auth` 4 ·
  `gallery` 1 · `in_app_notifications` 1 · `zodiac` 2. **0 đỏ mới.**
- `test/features/activity_cards` riêng: **164 pass, 2 skip, 0 fail**.
- Runtime startup smoke: **NOT_APPLICABLE** theo §10.8 (R-2).

## 9. Việc còn treo cho reviewer / Scrum Master

`visual-fidelity/implemented-*.png` nay đã lệch thêm một mức: lưới stat có ba
ô thay vì hai, và giá/khoảng cách hiển thị dạng đã định dạng. Test chụp
(`renders the visual-fidelity evidence frames`) vẫn `skip` mặc định và thư mục
ảnh nằm ngoài phạm vi 5 file của §11.5, nên P12 không chụp lại. Cần Scrum
Master cấp scope chụp lại trước khi cổng visual fidelity đọc bộ ảnh — cùng
khoản treo đã ghi ở mục `### A4-CTA-D18-D19` của `test-results.md`.
