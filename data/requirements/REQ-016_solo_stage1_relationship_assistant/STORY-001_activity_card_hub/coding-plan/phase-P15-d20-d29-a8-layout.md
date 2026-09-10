# P15 — D-20, D-29 và bố cục A8

- Lane: Mobile
- Date: 2026-09-10
- BaseHead: `6e41a35`
- Kế hoạch nguồn: `master-plan.md` §14 (§14.3 → §14.9)
- Bằng chứng chạy: `test-results.md` → `### P15 — D-20 + D-29 + bố cục A8`
- Bằng chứng hình: `../visual-fidelity/visual-fidelity-report.md` §13 (vòng 11)

Vòng dọn nốt phần tập đỏ §12.3 mà mobile còn đóng được: một cặp icon CTA, một
hàm định dạng ngày, một phép hoán vị hai khối trên đúng một trạng thái. Không
cột mới, không migration, không đổi cubit — **P15 không có đường ghi mới**.

## 1. Ba thay đổi mã, đầy đủ

### 1.1 D-20 — cặp icon CTA (§14.3)

`presentation/screens/activity_card_detail_screen.dart`, trong `_primaryAction`:

```dart
outlined ? CupidIcons.menuBook : CupidIcons.schedule   // trước
outlined ? CupidIcons.history  : CupidIcons.event      // sau
```

`outlined` là `action == ActivityCardPrimaryAction.review`, tức nhánh kỷ niệm.
Nghĩa đọc được: kỷ niệm thì **đọc lại** (`history`), thẻ đang mở thì **hẹn lịch**
(`event`). `cupid_icons.dart` không đổi — cả hai token đã có sẵn từ P13.

Ba thứ **không** đổi theo: `activityPrimaryActionFor`, 4 nhãn SC-4, và icon/bố
cục của tile P4.

### 1.2 D-29 — `formatLongViDate` (§14.4)

`presentation/formatters/vi_field_format.dart`, thêm mới cạnh
`formatShortViDate`:

```dart
String formatLongViDate(String? isoDate)   // '2026-08-15' → 'Thứ Bảy 15/8'
```

- Bảng thứ 1..7 = *Thứ Hai · Thứ Ba · Thứ Tư · Thứ Năm · Thứ Sáu · Thứ Bảy ·
  Chủ Nhật*, hằng số sản phẩm, không phải output của `intl` — cùng lý do đã
  khoá cả file này khỏi `NumberFormat` (§11.2, A-2).
- Ngày và tháng **không đệm `0`**, **không năm**, khớp dạng ngắn.
- `DateTime.tryParse`; chuỗi không parse được trả về **nguyên văn**, không ném.
  Giá trị đến từ SQLite nên đây là biên hệ thống: một hàng meta trống làm mất dữ
  liệu của người dùng trên màn hình, một hàng chưa được làm đẹp thì không.
- `null` **không bao giờ** tới hàm này; nhánh "chưa hẹn ngày" thuộc về call site.

**Đây là hàm anh em của `formatShortViDate`, không phải chỗ dùng lại nó.**
`scheduled_on` là `String` ISO do màn hình ghi, `link_saved_at` là epoch millis
`int`. Một hàm phục vụ cả hai chỉ chạy được sau một phép ép kiểu nói dối về cột.

Call site — `_metaDateRow`, **chỉ nhánh non-null**:

```dart
scheduledOn == null
    ? activityHubText(context, 'chưa hẹn ngày', 'no date yet')   // không đổi
    : formatLongViDate(scheduledOn),                             // đổi
```

Import `../formatters/vi_field_format.dart` đã có sẵn ở dòng 17 của màn hình.

### 1.3 A8 — ảnh dẫn trước tiêu đề (§14.5)

Trong `Column` dựng thân thẻ, khối ảnh chuyển lên **trước** `_titleField`, và chỉ
bên trong nhánh `if (state.isReviewing)`:

```dart
if (state.isReviewing) ...<Widget>[
  _memoryPhotoPlaceholder(context),
  const SizedBox(height: CupidSpacing.md),
],
_titleField(context, state),
```

Ba trạng thái mở không có khối ảnh nên trình tự của chúng không bị nhánh này
chạm tới. **Lưới meta 2x2 không bị dời** — xem §3.

## 2. Tám rule §14.6

Bảng khẳng định ↔ test ↔ kết quả nằm trong `test-results.md`. Ba lựa chọn về
*cách đo* đáng ghi lại ở đây:

1. **Rule 1 đọc widget, không đọc nhãn.** Assert đi qua
   `find.descendant(of: find.byKey('card_detail_primary_action'), matching:
   find.byType(Icon))` rồi so `icon.icon`. Nếu assert trên chữ CTA, test sẽ đỏ
   mỗi lần D-18 nới lời thoại — mà D-18 nới **chữ**, không nới icon. Đo icon
   bằng token icon là cách duy nhất giữ rule 1 độc lập với SC-4.
2. **Rule 6/7 đo toạ độ `dy`, không đo thứ tự trong cây widget.** Thứ tự vẽ trên
   màn là thứ tự người dùng thấy; thứ tự trong `Column` chỉ là cách viết. Dùng
   `tester.getTopLeft(...).dy` nên test vẫn đúng nếu sau này khối được bọc thêm
   một lớp `Padding`/`Sliver`.
3. **Rule 8 không sửa gì.** §12.6-5 và §12.6-6 giữ nguyên từng dòng; giá trị của
   chúng ở vòng này là *đã không đỏ*, nên chạm vào là mất bằng chứng.

## 3. Sai lệch còn lại: lưới meta 2x2, chờ Scrum Master phán quyết

§14.5 giao việc **ghi lại**, không phải giải quyết. Chụp lại xong sai lệch vẫn
còn, nên mục này bắt buộc phải có.

- **Đo được**: canvas A8 đọc `… → ghi chú → 2 thẻ số → CTA`; bản dựng đặt lưới
  2x2 **trước** khối ghi chú.
- **Vì sao P15 không dời**: hai phán quyết đã đóng nằm trên vị trí đó.
  D-24/D-25 đã đóng hai "thẻ số" của canvas (`4 lần đi chung`,
  `15 chỗ để dành`) là **nội dung minh hoạ, không phải field** — neo bố cục vào
  chúng là dùng lại một non-field đã đóng làm mốc. Và A-4 định nghĩa "meta" gồm
  cả thời lượng · khung giờ · khoảng cách · giá, đặt **cả cụm** trước ghi chú;
  dời lưới xuống là sửa chính A-4.
- **Câu hỏi mở**: giữ A-4 như đang viết (chấp nhận sai lệch này cho token), hay
  thu hẹp định nghĩa "meta" của A-4 để cụm số được xuống sau ghi chú **chỉ trên
  A8**. Tech Lead và mobile-dev không được tự chọn (§14.5).
- Nửa còn lại của **D-26** ("một dòng meta duy nhất") là cùng khối này dưới số
  hiệu khác, và hai vế `2 tiếng 10` / `trời hanh` của nó chính là khoảng hở D-15
  đã trả lời bằng lưới 2x2.

Nửa nhãn của **D-23** (`★ KỶ NIỆM` vs `ĐÃ THÀNH KỶ NIỆM`) cũng là tồn dư, nhưng
không phải mục chờ phán quyết của §14.5: nó thuộc bộ từ vựng 4 trạng thái **D-1**
đã đóng, đổi ở đây là đổi liên màn. Nửa vị trí (pill sát mép phải, chỉ trên A8)
đã đóng và nhìn thấy trong khung.

## 4. Một mâu thuẫn đặc tả đã lật, ghi để không mở lại

`test-results.md` mục `### F-5` (viết ở P14) kết luận đổi icon CTA ở dòng 1208 là
một **regression**. **§14.3 lật kết luận đó và P15 làm theo §14.3.** Không phải
hai bên nói sai: F-5 khẳng định *§12.5 chưa từng giao* cặp `history`/`event` cho
CTA — đúng tại thời điểm P14 — còn §14.3 là quyết định **mới** giao cặp ấy cho
CTA, kèm lý do D-18 chỉ nới chữ chứ không nới icon. §14.3 thay thế §13.8 tại
**đúng dòng 1208** và không đụng phần còn lại của bảng F-5. Một ghi chú tương
ứng đã chèn ngay dưới mục F-5 trong `test-results.md`.

## 5. Hai bẫy bắt được, một trong đặc tả một trong Dart

1. **§14.6 rule 2 lấy ví dụ sai lịch**: `2026-08-16` → `Thứ Bảy 16/8`. Ngày đó là
   **Chủ Nhật**. Ví dụ ấy là mẫu *hình dạng chuỗi*, không phải mốc kiểm chứng,
   nên test dùng cặp đã tự tra lịch `2026-08-15` → `Thứ Bảy 15/8`, và giữ luôn
   `2026-08-16` → `Chủ Nhật 16/8` để cặp sai không quay lại. Hợp đồng §14.4
   không đổi một chữ.
2. **`DateTime.parse` chuẩn hoá thay vì từ chối**: bản nháp đầu assert
   `formatLongViDate('2026-13-45')` trả nguyên văn — chuỗi đó *parse được*, nên
   assert sẽ đỏ. Thay bằng `'sang tuần'` và `'01/10/2026'`, hai dạng
   `DateTime.tryParse` thật sự không đọc được. Bắt trước khi chạy, không phải sau
   khi đỏ.

## 6. Cổng đóng §14.9

| Điều kiện | Kết quả |
|---|---|
| `flutter analyze lib test` 0 error | **PASS** — 191 issue / **0 error**, delta 0 so với P11→P14 |
| `flutter test` xanh | **PASS** — `test/features/activity_cards` 199/2/0; toàn cây +1972 ~4 −14, trùng đúng 14 đỏ có sẵn tại BaseHead (+1965 ~4 −14), **0 đỏ mới** |
| 8 rule §14.6 xanh | **PASS** — 8/8 |
| 3 khung chụp lại | **PASS** — 2 khung A4 + 1 khung A8 chụp lại (`+38: All tests passed!`); khung hub mang sang nguyên vẹn, có ghi lý do trong §13 báo cáo hình |

**WriteScope §14.7**: đúng 4 file mã/test + 3 artifact, không hơn.
`git diff --stat 6e41a35 -- mobile` = 4 file, +189/−5.

Không tự commit — commit thuộc Scrum Master.
