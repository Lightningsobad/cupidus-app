# Visual Fidelity Report: STORY-012 Trạng thái theo pha, widget, bộ đếm

VISUAL_FIDELITY: FAIL

Lane: mobile · Ngày: 2026-09-17 · Tác giả: Alex-Mobile-Dev
Đóng gap `G-1` trong `review/review-report.md` (rule 12e2/12e3).

Cập nhật lượt patch #2 (2026-09-19): WriteScope đã mở tới thẻ, vỏ hub, ARB và
hai file widget, nên **9/9 delta được giao trong lượt này đã đóng thật**
(D-1..D-5, D-6, D-8, D-9, D-12; D-11 đóng phía iOS). Sáu ảnh `implemented-*` đã
chụp lại và soi bằng mắt. Verdict tổng vẫn `FAIL` vì hai khoản còn lại — R-1
(hai chip hành động cần chuỗi từ gói nội dung) và bề mặt widget (D-10 + R-3) —
chi tiết ở mục "Lượt patch #2 — C-1". Mỗi khoản còn mở đều có tên chủ sở hữu,
không phải việc lane mobile bỏ dở.

Ghi chú lượt trước (2026-09-17, lần 2): chỉ D-7 và C-3 đóng được; 9 delta còn
lại nằm ngoài WriteScope lúc đó.

## Design-Surface / Design-Screen đã giải (rule 12e2)

Design-Surface: `cupid-ch-ng-1` (`Cupid Chặng 1.dc.html`, `surface: mobile`,
`platforms: ["ios"]`, `screens_from: frames`)

Design-Screen: `ngan-da-hen-ngay-dang-doi`, `man-goc-muon-lam`,
`23h-vua-ve-j8`, `j12-nhan-ra-cot-moc`, `sb-84-widget-bon-pha`

### Vì sao là `cupid-ch-ng-1`, không phải `cupid-app` hay `cupid-d-u-m-c`

`design-fidelity-config.json` khai **ba** canvas mobile, nên phải ghim surface
trước khi so sánh có nghĩa. Đã liệt kê id của cả ba bằng
`render-design-canvas.js --list-screens` (bước A), rồi lọc theo nghĩa (bước B)
và render để nhìn tận mắt (bước C):

- `cupid-ch-ng-1` đặt tên frame **thẳng theo id spec của story này**:
  `sb-84-widget-bon-pha` (SB-84, In Scope #2), `23h-vua-ve-j8` (SB-85/J8,
  In Scope #4), `j12-nhan-ra-cot-moc` (J12, In Scope #7),
  `ngan-da-hen-ngay-dang-doi` (pha đang đợi/sắp hẹn),
  `man-goc-muon-lam` (màn (1) ở pha đúng ngày hẹn). `story_master.md:10-11`
  liệt kê đúng chùm SB-83/84/85, SB-87, SB-99 và J4/J5/J10/J12.
- `cupid-app` có nhóm `s1:*` (`s1:widget`, `s1:today`, `s1:night`,
  `s1:milestone`) trông gần đúng theo chuỗi, nhưng đó là canvas app tổng,
  không phải bản chặng 1 mà REQ-016 dựng theo. Đã loại sau khi đối chiếu tên
  frame với id spec.
- `cupid-d-u-m-c` là canvas "Dấu Mốc" (`home`, `passport`, `stamp`, `widget`…),
  thuộc dòng tính năng khác. Loại.

Chưa có dòng `Design-Screen:` nào trong `ux/uiux-spec.md` hay `story_master.md`
trước lượt này (đã grep, 0 kết quả) — giải ở đây theo rule 12e2 bước A-D.
Ghi `Design-Surface`/`Design-Screen` vào `story_master.md` là việc của Scrum
Master: file đó ngoài WriteScope của handoff này.

## Khung ảnh và giới hạn đã biết

| | Khung | Nguồn |
|---|---|---|
| implemented-* | 412×915, dpr 1, nền `CupidColorTokens.dark()` | `RepaintBoundary` trong widget test (`CAPTURE_VISUALS=true`), P7/P8 |
| design-reference-* | 415×900, khung iOS | `render-design-canvas.js --surface=cupid-ch-ng-1 --platform=ios` |

`cupid-ch-ng-1` chỉ khai `platforms: ["ios"]`, nên **không có khung Android để
render**. Chênh 3px ngang / 15px dọc giữa hai bên là chênh khung thiết bị, đã
trừ ra khỏi mọi delta bên dưới; nó không phải delta cài đặt.

Giới hạn thứ hai, nói thẳng: các `implemented-*.png` là ảnh chụp
`ActivityCardHubView` **một mình**, không có vỏ `_SoloStageOneShell` (tiêu đề
"Muốn làm", ô tìm kiếm, thanh điều hướng đáy 4 mục). Vỏ đó thuộc STORY-001.
Mọi phần tử chỉ có ở bản thiết kế vì nó thuộc vỏ hoặc thuộc story khác được
liệt kê riêng ở mục "Ngoài bề mặt của story này", **không** tính là delta của
STORY-012.

## Đặt cặp ảnh

Tên file design-reference là tên do chính `render-design-canvas.js` sinh ra,
`design-reference-<id canvas>-ios.png`, không gắn thêm nhãn nào. Lượt trước có
chèn nhãn của ảnh implemented vào giữa tiền tố và id canvas; tên ghép đó làm
gate `validate-dev-design-render.sh` không tra được screen trên surface
`cupid-ch-ng-1` nên đã xoá và render lại đúng 5 frame gốc. Nội dung ảnh không
đổi (kích thước byte trùng khớp từng file), nên mọi so sánh đã ghi vẫn còn giá
trị.

| implemented | design-reference | id canvas |
|---|---|---|
| `implemented-hub-waiting.png` | `design-reference-ngan-da-hen-ngay-dang-doi-ios.png` | `ngan-da-hen-ngay-dang-doi` |
| `implemented-hub-upcoming.png` | `design-reference-ngan-da-hen-ngay-dang-doi-ios.png` | `ngan-da-hen-ngay-dang-doi` |
| `implemented-hub-date_day.png` | `design-reference-man-goc-muon-lam-ios.png` | `man-goc-muon-lam` |
| `implemented-hub-quiet.png` | `design-reference-man-goc-muon-lam-ios.png` | `man-goc-muon-lam` |
| `implemented-evening-check-in-sheet.png` | `design-reference-23h-vua-ve-j8-ios.png` | `23h-vua-ve-j8` |
| `implemented-quiet-surfaces.png` | `design-reference-j12-nhan-ra-cot-moc-ios.png` | `j12-nhan-ra-cot-moc` |
| *(không có)* | `design-reference-sb-84-widget-bon-pha-ios.png` | `sb-84-widget-bon-pha` |

`ngan-da-hen-ngay-dang-doi` dùng cho **hai** trạng thái vì chính frame đó vẽ cả
thẻ "đang đợi" lẫn thẻ "chốt rồi · còn 4 ngày" trong một khung.
`man-goc-muon-lam` dùng cho `date_day` (thẻ "HÔM NAY, 19:20" ở đầu danh sách)
và làm mốc bố cục cho `quiet` — canvas **không ship frame riêng cho pha khoảng
lặng**, nên trạng thái đó chấm theo BR-2 chứ không theo pixel.

## Verdict theo màn và theo trạng thái AC

| # | Ảnh implemented | Trạng thái AC được chấm | Verdict |
|---|---|---|---|
| 1 | `implemented-hub-waiting.png` | AC-1 (SB-83 hướng sang việc chuẩn bị), AC-6/AC-7 (không chữ số chờ) | FAIL |
| 2 | `implemented-hub-upcoming.png` | AC-3 (SB-86 đếm ngược tới ngày hẹn) | FAIL |
| 3 | `implemented-hub-date_day.png` | AC-2 pha 4 trên màn (1) (phản chiếu "Trước giờ đi") | FAIL |
| 4 | `implemented-hub-quiet.png` | BR-2 (pha không nội dung → không khung rỗng) | PASS |
| 5 | `implemented-evening-check-in-sheet.png` | AC-4 (SB-85 nhắc 23h → cất ảnh / viết một câu) | FAIL |
| 6 | `implemented-quiet-surfaces.png` | AC-5 (bộ đếm "của cải đang lớn"), AC-6 (không streak), In Scope #5/#6 | PASS |
| 7 | *(không có ảnh)* | AC-2 (widget bốn pha) | NOT_COMPARED |

Thiết bị: mọi verdict ở trên là **một** form factor — điện thoại dọc, 412×915
dpr 1 bên implemented, khung iOS 415×900 bên design. Story không có yêu cầu
tablet, xoay ngang hay mật độ khác, nên không chụp form factor thứ hai.

## Delta từng ảnh

### 1 · `hub-waiting` — FAIL

- **D-1 (delta cài đặt).** Thiết kế đặt khối hướng-chuẩn-bị **bên trong thẻ**:
  một mặt bo góc có nền riêng, tiêu đề "Đừng ngồi đoán, mình chuẩn bị tiếp
  nhé.", thân giải thích, rồi hai chip hành động. Bản dựng đặt nó thành
  **tiêu đề danh sách** trên toàn bộ danh sách thẻ ("Chuẩn bị dần cho buổi
  tới" + phụ đề), chữ trần trên nền scaffold, không mặt, không bo, không viền.
  Khác về vị trí và về xử lý bề mặt.
- **D-2 (delta cài đặt).** Thiết kế có nhãn-mí trạng thái trên thẻ
  ("ĐANG ĐỢI · rủ từ 14:02") kèm chấm màu theo pha. Bản dựng không có nhãn-mí
  nào; thẻ chỉ có tiêu đề + nút.
- **Không phải delta — chữ.** Câu cụ thể khác nhau ("Chuẩn bị dần cho buổi
  tới" vs "Đừng ngồi đoán, mình chuẩn bị tiếp nhé.") là **dữ liệu gói nội
  dung**, do AC-37/BR-15 và R-15a quản: chuỗi đến từ pack, không từ mã, và
  sửa nó là việc của Product Owner trên pack chứ không phải của lane này. Ghi
  lại chứ không chấm là lỗi dựng.
- **Khớp.** AC-6/AC-7: đã soi toàn ảnh, **không ký tự số nào** xuất hiện ở
  trạng thái đang đợi — đúng như thiết kế, vốn cũng không đếm ngày chờ.

### 2 · `hub-upcoming` — FAIL

- **D-3 (delta cài đặt).** Ngày hẹn hiện dạng ISO thô `2026-09-20` trên thẻ.
  Thiết kế vẽ "CN 14/9, 19:20" — thứ, ngày/tháng, giờ, theo locale vi. Đây là
  lỗi định dạng user-visible thật, không phải chênh khung.
- **D-4 (delta cài đặt).** Thiết kế cho con số đếm ngược cỡ display ("**4**"
  lớn, màu nhấn, đứng cạnh "ngày nữa" hai dòng). Bản dựng viết "còn 4 ngày"
  cùng cỡ chữ với phần còn lại của thẻ, không nhấn.
- **Khớp.** Cùng một con số (4) xuất hiện ở dòng trạng thái chính và trên thẻ,
  đúng ý AC-3; thiết kế cũng chỉ nêu số ngày nguyên, không giờ đồng hồ.

### 3 · `hub-date_day` — FAIL

- **D-3 lặp lại.** Thẻ "Ăn lẩu" hiện `2026-09-16` dạng ISO. Thiết kế:
  "HÔM NAY, 19:20".
- **D-5 (delta cài đặt).** Thiết kế nâng thẻ đúng-ngày-hẹn lên thành một mặt
  gradient nổi bật ở đầu danh sách, CTA "Trước giờ đi" chiếm gần hết chiều
  ngang. Bản dựng để thẻ giống hệt mọi thẻ khác, CTA "Chuẩn bị" là nút nhỏ
  bình thường — pha 4 không có ưu tiên thị giác nào so với pha khác.
- **Khớp.** Dòng chính đọc "Hôm nay là ngày đã hẹn" và thẻ đọc "Hôm nay", đúng
  ý thiết kế ("HÔM NAY") và không phải "còn 0 ngày".

### 4 · `hub-quiet` — PASS

Canvas không ship frame riêng cho pha khoảng lặng, nên trạng thái này chấm
theo BR-2 chứ không theo pixel: *pha không có nội dung hợp lệ thì không được
để lại khung rỗng*. Ảnh cho thấy đúng thế — không dòng trạng thái, không hộp
giữ chỗ, thẻ "Tự làm bánh" nằm ngay dưới hàng lọc, khoảng cách bằng đúng
khoảng cách giữa hàng lọc và thẻ đầu tiên ở `man-goc-muon-lam`. Không delta.

### 5 · `evening-check-in-sheet` — FAIL

- **D-6 (delta cài đặt, gốc là lệch spec-vs-canvas).** Thiết kế là **màn hình
  đầy đủ** (`23h-vua-ve-j8`): tiêu đề lớn hai dòng, đoạn dẫn, khối ngữ cảnh
  "TỐI NAY CỦA HAI NGƯỜI" nhắc lại tên buổi hẹn, lưới **ba ô ảnh**, ô nhập
  nhiều dòng, hai chip ("+ ghi vào sổ tay", "chỉ mình đọc"), CTA lớn "Cất đi,
  ngủ ngon nha", và dòng trấn an ở chân màn. Bản dựng là **bottom sheet thấp**
  với: tiêu đề một dòng, phụ đề, một nút chữ "Đính ảnh", một ô nhập một dòng,
  "Để sau" + "Lưu vào nhật ký".
  `ux/uiux-spec.md:78` viết rõ "gộp trong một **sheet nhỏ**" — nên đây là lệch
  **spec prose vs canvas**, không phải lệch AC. AC-16/AC-18 chỉ đòi hai bước
  đều tuỳ chọn và ô câu không bao giờ bị khoá; cả hai bản đều thoả. Theo
  precedent design-anchor của REQ-016, loại lệch này thuộc nhóm "rework về
  canvas + sửa spec cho khớp", nhưng **báo cáo này không tự phân xử** — ghi
  nguyên và để Scrum Master quyết.
- **D-7 — ĐÃ ĐÓNG (2026-09-17, lượt patch C-1/C-3).** Trước: chỉ một nút chữ
  "Đính ảnh". Nay: lưới **ba ô vuông** bo góc, viền `colorLine`, nền
  `colorSurfaceAlt`, mỗi ô rỗng vẽ `add_photo_alternate_outlined` — đúng số ô
  và đúng cách "cho thấy trước chỗ cất ảnh" của thiết kế; ô đã có ảnh vẽ chính
  tấm ảnh (`Image.file`, `BoxFit.cover`), hỏng đường dẫn thì rơi về glyph chứ
  không ném lỗi trong sheet. Chỗ sửa:
  `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart`
  (`_PhotoSlot`, `_photoSlotCount = 3`).
  Bằng chứng: `implemented-evening-check-in-sheet.png` đã chụp lại ở lượt này
  và **đã mở ra nhìn tận mắt** — ba ô hiện đủ, icon dựng đúng (không ô tofu),
  dấu tiếng Việt nguyên vẹn. Test canh: `evening_check_in_sheet_test.dart`
  "the photo step shows its three places before anything is picked" và
  "a picked photo fills a place and leaves the rest empty".
- **D-8 (delta cài đặt).** Không có khối ngữ cảnh nhắc lại buổi hẹn, nên người
  dùng không thấy sheet đang nói về thẻ nào.
- **D-9 (delta cài đặt).** Thiếu dòng trấn an chân màn ("Không viết cũng chẳng
  sao…"), vốn là thứ đỡ AC-4 ở vế "bỏ qua thì không nhắc lại".
- **Không phải delta — chữ.** "Về tới nhà chưa?" vs "Về tới nhà rồi chứ?": lại
  là chuỗi của `nudges.v1.json`, thuộc AC-37/BR-15.

### 6 · `quiet-surfaces` — PASS

`j12-nhan-ra-cot-moc` là **khoảnh khắc cột mốc toàn màn** (tiêu đề "5 lần đi
chung. 3 tháng rồi.", lưới ảnh, bảng "Chỗ đã đi / Chỗ còn để dành / Sổ tay",
CTA "Giữ lại bộ này" và "Xem lại 5 kỷ niệm"). `story_master.md:48-56` chốt
rằng trong REQ-016, **mặt user-visible duy nhất** của J12 là bộ đếm, và luồng
mời/gói-lại của J12 nằm ở Out of Scope (chặng 1.5). Vậy nên bản rút gọn thành
một dòng trong màn (1) là thu hẹp **có chủ ý và đúng phạm vi**, không phải
thiếu sót dựng hình.

Chấm phần story thật sự sở hữu:
- Bộ đếm đọc "Bạn đang giữ 5 kỷ niệm." — cùng con số 5 mà thiết kế nêu, dạng
  câu chứ không phải huy hiệu; **không** thanh phần trăm, **không** chuỗi
  ngày, **không** bảng xếp hạng (AC-6 / R-1(f)) — giống thiết kế, vốn tự nói
  "Đây không phải huy hiệu gì cả".
- Khối quà "Món bạn đang làm đã đi được một chặng." tương ứng khối "Món quà
  đang lớn dần" ở chân `ngan-da-hen-ngay-dang-doi`: cùng là một dòng khái quát
  về tiến triển, không tỉ lệ X/Y (AC-20/BR-7).
- Thứ tự dọc đúng `uiux §5/§6`: bộ đếm nằm **trên** dải quick-entry, dải
  quick-entry trên hàng lọc dính.
- Dấu tiếng Việt và icon Material Symbols dựng đúng, không ô tofu.

### 7 · `widget-phases` — NOT_COMPARED (thiếu ảnh bản dựng)

Không có `implemented-*` cho widget, nên **AC-2 chưa được so sánh bằng ảnh**.
Nói rõ vì sao và đã làm gì thay thế:

- Bề mặt này là widget màn hình chính của **hệ điều hành**, dựng bởi
  `RemoteViews` (Android) và WidgetKit (iOS). Nó không nằm trong cây widget
  Flutter, nên harness `RepaintBoundary` đang tạo 6 ảnh kia **không với tới
  được**. Đặt được widget lên launcher rồi chụp đòi thao tác launcher trên
  thiết bị — ngoài phạm vi per-story capture.
- Đã render và **nhìn tận mắt** bản thiết kế
  (`design-reference-sb-84-widget-bon-pha-ios.png`): đó là một
  tờ spec xếp chồng bốn biến thể pha, mỗi biến thể gồm chấm màu + nhãn-mí
  "PHA n · <TRẠNG THÁI>", dòng chính đậm, dòng phụ mờ; riêng PHA 3 có chữ số
  cỡ display ("**4**" cạnh "ngày nữa"); PHA 4 có nền gradient hồng.
- Đối chiếu ở mức mã với bản dựng:
  `mobile/android/app/src/main/res/layout/cupid_phase_widget.xml` là một hàng
  ngang: icon launcher 24dp + dòng chính (14sp bold,
  `?android:attr/textColorPrimary`) + dòng phụ (12sp,
  `?android:attr/textColorSecondary`) trên `?android:attr/colorBackground`.
  `mobile/ios/CupidPhaseWidget/CupidPhaseWidget.swift:108-113` là một `VStack`
  `Text(primaryLine).font(.headline)` + `Text(secondaryLine).font(.caption)`.
  Từ đó có ba khác biệt đọc được mà không cần ảnh:
  - **D-10.** Không có nhãn-mí pha và không có chấm màu theo pha ở cả hai nền
    tảng.
  - **D-11.** Không có xử lý chữ số cỡ display cho pha `upcoming`; con số nằm
    lẫn trong câu.
  - **D-12.** Dùng màu hệ thống (`?android:attr/...`, màu mặc định SwiftUI)
    thay vì bảng màu tối của thương hiệu và nền gradient của PHA 4.
- **D-10 có thể là `DESIGN_SPEC_CONFLICT`, cần quyết định — không tự phân
  xử ở đây.** Nhãn-mí là chuỗi hiển thị thứ ba. Hợp đồng payload trong
  `architecture/contract-summary.md` §2 (và
  `lib/features/phase_status/data/home_widget_bridge.dart:22-37`) chỉ có năm
  khoá, trong đó đúng **hai** khoá chữ: `primary_line`, `secondary_line`.
  AC-37/BR-15 lại cấm viết chuỗi hiển thị trong mã widget. Nên muốn có
  nhãn-mí phải thêm khoá vào hợp đồng và thêm trường vào gói nội dung — vượt
  ngoài "sửa cho khớp thiết kế" và vượt ngoài WriteScope của lượt này.

## Tổng kết delta

| Id | Loại | Ảnh | Trạng thái sau lượt patch #2 (2026-09-19) | File chứa chỗ sửa |
|---|---|---|---|---|
| D-1 | delta cài đặt | hub-waiting, hub-upcoming, hub-date_day | **ĐÓNG** ✔ (trừ hai chip hành động — xem tồn dư R-1) | `activity_card_hub_view.dart`, `phase_status_line.dart`, `activity_card_tile.dart` |
| D-2 | delta cài đặt | mọi ảnh hub | **ĐÓNG** ✔ (trừ nửa giờ đồng hồ — tồn dư R-2) | `activity_card_tile.dart` (`_StatusEyebrow`, `activityCardStatusLabel/Color`) |
| D-3 | delta cài đặt (định dạng ngày ISO) | hub-upcoming, hub-date_day | **ĐÓNG** ✔ (trừ nửa giờ đồng hồ — tồn dư R-2) | `activity_card_tile.dart` (`activityCardDateLabel`, `_subtitle`) |
| D-4 | delta cài đặt | hub-upcoming | **ĐÓNG** ✔ | `activity_card_tile.dart` (`_CountdownBlock`) |
| D-5 | delta cài đặt | hub-date_day | **ĐÓNG** ✔ | `activity_card_tile.dart` (nhánh `today0`) |
| D-6 | lệch spec-prose vs canvas | evening-check-in-sheet | **ĐÓNG** ✔ — Scrum Master quyết: canvas thắng, dựng bản toàn màn | `evening_check_in_sheet.dart` |
| D-7 | delta cài đặt | evening-check-in-sheet | **ĐÓNG** ✔ (lượt trước) | `evening_check_in_sheet.dart` |
| D-8 | delta cài đặt | evening-check-in-sheet | **ĐÓNG** ✔ | `evening_check_in_sheet.dart` + `app_vi.arb`/`app_en.arb` |
| D-9 | delta cài đặt | evening-check-in-sheet | **ĐÓNG** ✔ | `evening_check_in_sheet.dart` + `app_vi.arb`/`app_en.arb` |
| D-10 | ứng viên `DESIGN_SPEC_CONFLICT` (AC-37/BR-15 + hợp đồng 5 khoá) | widget | **ĐÓNG cài đặt** ✔ ở lượt #3 (2026-09-25, phase P9): hợp đồng lên 6 khoá với `eyebrow_line`, chấm màu tra theo `phase_id`; còn thiếu **ảnh** để so (R-5) và có quan sát D-13 | `phase_content.dart`, `home_widget_bridge.dart`, `phase_content.v1.json`, `cupid_phase_widget.xml`, `CupidPhaseWidgetProvider.kt`, `CupidPhaseWidget.swift` |
| D-11 | delta cài đặt | widget | **ĐÓNG một nửa** — iOS xong, Android không với tới (tồn dư R-3) | `CupidPhaseWidget.swift` (xong) · `CupidPhaseWidgetProvider.kt` (ngoài WriteScope) |
| D-12 | delta cài đặt | widget | **ĐÓNG** ✔ | `cupid_phase_widget.xml`, `CupidPhaseWidget.swift` |

## Lượt patch C-1/C-3 (2026-09-17)

WriteScope lượt này (đọc từ
`data/runtime/parallel-runs/RUN-...-STORY-012_phase_status_and_widget-mobile-dev.json`,
khoá `write_scope`): `mobile/lib/features/phase_status`,
`mobile/test/features/phase_status`, `mobile/ios/Runner/Info.plist`,
`.../visual-fidelity`, `.../coding-plan/test-results.md`,
`.../deployment/configuration-guide.md`.

### Đã đóng

- **D-7** — lưới ba ô ảnh trong sheet 23h. Xem mục `5 · evening-check-in-sheet`.
- **C-3** — scheme `cupidapp` đã đăng ký trong `mobile/ios/Runner/Info.plist`
  (`CFBundleURLTypes` → `CFBundleURLSchemes` → `cupidapp`). Xác minh:
  `plutil -lint ios/Runner/Info.plist` → `OK`;
  `/usr/libexec/PlistBuddy -c "Print :CFBundleURLTypes:0:CFBundleURLSchemes:0"`
  → `cupidapp`. Test canh mới trong `native_copy_scan_test.dart` đọc scheme ra
  từ `CupidPhaseWidgetProvider.kt` rồi đòi plist đăng ký đúng giá trị đó, nên
  một lần đổi tên scheme làm đỏ test thay vì làm chết cú chạm trên máy.
  Bước này cũng đã ghi vào
  `deployment/configuration-guide.md` §"Register the `cupidapp` URL scheme".
  Giới hạn cần nói thẳng: đăng ký này chỉ đủ để iOS **mở lại app**; phía Dart
  hiện **chưa** có chỗ nhận `cupidapp://card/<id>` (đã đo: 0 khớp
  `cupidapp|deepLink|scheme` trong
  `lib/features/phase_status/data/home_widget_bridge.dart`), nên chạm widget mở
  app về màn mặc định chứ chưa nhảy tới đúng thẻ. Định tuyến sâu là việc riêng,
  không nằm trong C-3.

### Không đóng được trong WriteScope này

Bảy delta (D-1, D-2, D-3, D-4, D-5, D-11, D-12) nằm ở file thuộc story khác:

- D-1..D-5 sống trong `mobile/lib/features/activity_cards/**` — thẻ và vỏ danh
  sách của STORY-001, không phải `features/phase_status`.
- D-11, D-12 sống trong layout RemoteViews Android và `CupidPhaseWidget.swift`
  — chỉ `mobile/ios/Runner/Info.plist` được mở trong WriteScope, không phải cả
  `mobile/ios/` hay `mobile/android/`.

Hai delta còn lại (D-8, D-9) nằm **trong** file sheet thuộc WriteScope nhưng
đòi chuỗi hiển thị mới ("TỐI NAY CỦA HAI NGƯỜI", dòng trấn an chân màn), và
mọi chuỗi chrome của sheet đến từ `mobile/lib/l10n/arb/app_vi.arb` +
`app_en.arb` (đã đo: `l10n.evening_check_in_*`). Thư mục `lib/l10n/` ngoài
WriteScope. Riêng D-8 còn cần tên buổi hẹn: `EveningCheckInSheet` hiện chỉ
nhận `cardId`, nên phải sửa cả call site trong `activity_card_hub_view.dart`
(cũng ngoài WriteScope).

### Một ghi chú dữ liệu về D-3, không chỉ là chuyện phạm vi

Thiết kế vẽ "CN 14/9, **19:20**" và "HÔM NAY, **19:20**". Phần thứ/ngày/tháng
format được từ dữ liệu hiện có, nhưng **giờ thì không**: `ActivityCard` chỉ có
`scheduledOn` dạng chuỗi ngày (`activity_card.dart:131`, giá trị kiểu
`'2026-09-20'`), không có trường giờ nào. Vậy D-3 tách làm hai:

1. phần sửa được ngay khi mở scope: bỏ chuỗi ISO thô, in `CN 14/9` / `HÔM NAY`
   theo locale `vi`;
2. phần cần quyết: hoặc chấp nhận lệch (không hiện giờ), hoặc mở rộng lược đồ
   thẻ để mang giờ hẹn — việc sau là thay đổi hợp đồng dữ liệu, không phải
   chỉnh hiển thị.

### Vì sao verdict vẫn FAIL

`VISUAL_FIDELITY` là verdict trên **màn**, không phải trên số delta đã đóng.
Sau lượt này `hub-waiting`, `hub-upcoming`, `hub-date_day` không đổi một pixel
nào (không file nào của chúng nằm trong WriteScope), nên ba màn đó vẫn FAIL y
như trước; `evening-check-in-sheet` gần thiết kế hơn nhưng vẫn thiếu D-8, D-9
và đang chờ quyết D-6. Lật verdict lúc này sẽ là một chữ ký sai.

## Lượt patch #2 — C-1 (2026-09-19)

WriteScope lượt này đã mở rộng đúng những file mà lượt trước phải ghi "ngoài
WriteScope": `activity_card_tile.dart`, `activity_card_hub_view.dart`,
`mobile/lib/l10n/arb`, layout RemoteViews Android, `CupidPhaseWidget.swift`.
Nhờ vậy 9/9 delta được giao trong lượt này đã sửa được thật.

Ảnh `implemented-*` đã chụp lại toàn bộ (6 ảnh) sau khi sửa, cùng harness cũ
(412×915, dpr 1, `CAPTURE_VISUALS=true`), và đã soi bằng mắt từng ảnh: không có
ô tofu, nền đục, dấu tiếng Việt đủ.

### Đã đóng trong lượt này

- **D-1** — khối hướng dẫn pha nay nằm **trong** thẻ nó nói về, trên mặt
  `colorSurfaceAlt` bo góc có viền (`PhaseStatusLine` tự vẽ mặt của nó;
  `ActivityCardTile.phaseBlock` là chỗ gắn). Không còn là tiêu đề chữ trần trên
  toàn danh sách. Thẻ được chọn là thẻ mà `PhaseResolution.cardId` trỏ tới.
- **D-2** — nhãn-mí trạng thái + chấm màu trên mọi thẻ
  (`_StatusEyebrow`): `MỚI NGHĨ RA` / `ĐÃ HẸN NGÀY` / `ĐANG ĐỢI TRẢ LỜI` /
  `CHỐT RỒI` / `ĐÚNG HÔM NAY` / `ĐÃ XONG` / `KỶ NIỆM`. Chấm màu là kênh **thứ
  hai** trên một nhãn chữ, không bao giờ là kênh duy nhất
  (`ux/uiux-spec.md` §5).
- **D-3** — ngày hẹn không còn in chuỗi ISO thô. `activityCardDateLabel` in
  `CN 20/9` / `T3 1/9` ở locale `vi` (`SUN 20/9` ở `en`), và `HÔM NAY` đúng
  ngày. Ngày đã chuyển hẳn lên nhãn-mí; dòng meta chỉ còn khoảng cách + giá.
- **D-4** — số ngày vẽ ở cỡ `display` (Nunito w900 34) màu hồng, đơn vị
  "ngày nữa" ở cỡ `body` bên cạnh (`_CountdownBlock`). Trình đọc màn hình vẫn
  nghe **một** câu "còn 4 ngày" nhờ `Semantics(excludeSemantics: true)`, không
  nghe một chữ số rồi một danh từ.
- **D-5** — thẻ đúng ngày hẹn được nâng một bậc: mặt `colorSurfaceAlt`, viền
  `colorAccentPink` 1.5px, `glowShadow`, và CTA gradient kéo hết chiều ngang.
- **D-6** — dựng bản **toàn màn** theo quyết định Scrum Master (canvas
  `23h-vua-ve-j8` thắng chữ "sheet nhỏ" ở `ux/uiux-spec.md:78`; AC-16/AC-18 thoả
  ở cả hai hình dạng). `EveningCheckInSheet.show` nay đẩy `MaterialPageRoute`
  `fullscreenDialog`, không còn `showModalBottomSheet`. Ô viết câu nở thành
  `minLines: 3 / maxLines: 5`.
- **D-8** — khối ngữ cảnh đầu màn: nhãn-mí "TỐI NAY CỦA HAI NGƯỜI" + **tên
  buổi hẹn** lấy từ `ActivityCardRepository.cardById` theo `cardId` của thông
  báo. Thẻ không đọc được thì bỏ tên, không chặn màn.
- **D-9** — dòng trấn an chân màn ("Không viết cũng chẳng sao. Mai app sẽ không
  nhắc lại chuyện này.") + hai chip mô tả điểm đến của câu đã lưu.
- **D-12** — widget dùng bảng màu thương hiệu thay vì màu theo theme máy:
  layout Android đổi `?android:attr/colorBackground` → `#241B42`, chữ
  `#F7EEFB`/`#B4A6CE`; iOS thêm `CupidWidgetPalette` và nền gradient
  hồng→tím riêng cho pha `date_day`. Có test canh (`native_copy_scan_test.dart`)
  cấm `?android:attr/` và `Color.clear` quay lại.

### D-11 — đóng nửa, và nửa còn lại nói thẳng

iOS xong: `CupidPhaseSplit.of` cắt chuỗi payload tại cụm chữ số đầu tiên và trả
ba mảnh, nên widget **đổi cỡ đúng con số nó được đưa** mà không bỏ, không đảo,
không viết lại một ký tự nào — tính chất "không có chuỗi hiển thị trong mã
widget" (AC-37/BR-15) giữ nguyên. `native_copy_scan_test.dart` không bị nới
lỏng: allowlist `Text(...)` siết lại thành đúng bốn biểu thức và có thêm một
assert đòi `CupidPhaseSplit.of(entry.primaryLine)` phải còn đó.

Android **không** làm được trong WriteScope này: cỡ chữ của một `RemoteViews`
chỉ đặt được từ `CupidPhaseWidgetProvider.kt` (một `SpannableString` +
`setTextViewText`), mà file đó không nằm trong WriteScope. Đây là tồn dư R-3.

### Tồn dư đã ghi (không phải từ chối sửa)

| Id | Tồn dư | Vì sao chưa đóng | Chủ sở hữu |
|---|---|---|---|
| R-1 | Hai chip hành động trong khối hướng dẫn pha (D-1) | Chip cần **chuỗi hiển thị mới**; AC-37/BR-15 bắt mọi chuỗi pha đến từ gói nội dung, không từ mã. Tự nghĩ chữ ở đây là vi phạm. | Product Owner trên `phase_content.v1.json` |
| R-2 | Nửa giờ đồng hồ của D-2/D-3 ("19:20", "rủ từ 14:02") | `ActivityCard` chỉ mang ngày dân sự, không có trường giờ. Handoff lượt này chốt rõ: **không** sửa model, **không** thêm trường giờ. | Tech Lead / PO nếu muốn mở hợp đồng dữ liệu |
| R-3 | Con số cỡ lớn trên widget Android (D-11) | Cần `CupidPhaseWidgetProvider.kt`, ngoài WriteScope | Scrum Master mở scope |
| R-4 | Nút "Để sau" nằm dưới CTA ở màn 23h | Canvas không vẽ nút thoát nào. Bỏ nó đi thì trên một **toàn màn** chỉ còn cử chỉ back của hệ thống, và AC-17 đòi "bỏ qua" là một cái kết một chạm. Giữ lại là chọn AC trên canvas — ghi ra để Reviewer soi. | Reviewer |
| D-10 | Nhãn pha + chấm màu trên widget | Handoff lượt này ghi rõ: ngoài phạm vi, giữ nguyên trạng thái blocker đã ghi nhận | Scrum Master / user |

### Verdict sau lượt này

| # | Ảnh implemented | Trước | Sau |
|---|---|---|---|
| 1 | `implemented-hub-waiting.png` | FAIL | FAIL — chỉ còn R-1 (hai chip) |
| 2 | `implemented-hub-upcoming.png` | FAIL | PASS (R-2 là lệch đã được chấp nhận) |
| 3 | `implemented-hub-date_day.png` | FAIL | PASS (R-2 như trên) |
| 4 | `implemented-hub-quiet.png` | PASS | PASS |
| 5 | `implemented-evening-check-in-sheet.png` | FAIL | PASS (còn R-4 để Reviewer soi) |
| 6 | `implemented-quiet-surfaces.png` | PASS | PASS |
| 7 | *(không có ảnh)* | NOT_COMPARED | NOT_COMPARED — D-10, R-3 |

`VISUAL_FIDELITY` giữ `FAIL`: `hub-waiting` vẫn lệch canvas ở hai chip hành
động (R-1), và bề mặt widget vẫn chưa có ảnh để so cùng hai khoản mở D-10/R-3.
Năm màn còn lại đã lật sang PASS. Lật verdict tổng lúc này sẽ là một chữ ký sai
— nhưng cả hai khoản còn lại đều có chủ sở hữu tên rõ ở bảng trên, không phải
việc lane mobile bỏ dở.

## Ngoài bề mặt của story này (không tính delta)

Có trong thiết kế, không có trong ảnh chụp, vì thuộc vỏ hoặc story khác:

- Tiêu đề màn "Muốn làm", dòng tóm tắt "14 điều đang chờ · dành dụm được 15
  chỗ", nút tìm kiếm, thanh điều hướng đáy 4 mục — vỏ `_SoloStageOneShell`,
  STORY-001; harness chụp `ActivityCardHubView` một mình.
- Khối "Trước giờ đi" đầy đủ trong `sb-211-truoc-gio-di` — STORY-006, được
  `story_master.md:62-63` xếp Out of Scope; STORY-012 chỉ **phản chiếu** pha
  đó.
- Ô "Cảm ơn + chốt việc kế tiếp" — STORY-007.
- Cửa ra nhật ký của sheet 23h — STORY-003.

## Golden test

Chưa đặt golden (`matchesGoldenFile`) cho bốn pha: rule 12 chỉ cho phép
`--update-goldens` **sau khi** so sánh thị giác PASS. Verdict lượt này là
FAIL, nên đóng băng ảnh hiện tại thành golden sẽ ghim đúng các delta vừa nêu.
Việc này để lại cho lượt rework sau khi D-1..D-12 được quyết và sửa.

## Lệnh đã chạy

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=cupid-ch-ng-1 --list-screens
node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=cupid-app --list-screens
node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=cupid-d-u-m-c --list-screens
node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=cupid-ch-ng-1 --screen=<id> --platform=ios --out=<story-dir>/visual-fidelity
```

Mỗi lệnh render trả `DESIGN_CANVAS: OK <path> 415x900`. Không gặp
`VISUAL_RUNTIME_MISSING`: `render-design-canvas.js` chạy được trong chính
worktree này.

## Lượt patch #3 — D-10 (2026-09-25, phase P9)

Design screen id giải lại trong lượt này, không đoán và không dùng `--label`:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=cupid-ch-ng-1 --list-screens
```

trả về, trong 29 id, đúng một màn widget: `sb-84-widget-bon-pha`. Ảnh thiết kế
`design-reference-sb-84-widget-bon-pha-ios.png` đã có sẵn từ lượt #1 nên không
render lại; đã **mở ra nhìn tận mắt** trước khi viết mục này.

### D-10 — đã dựng, đối chiếu từng điểm với canvas

| Điểm trên canvas `sb-84-widget-bon-pha` | Bản dựng sau P9 | Kết |
|---|---|---|
| Hàng nhãn-mí: chấm tròn nhỏ + chữ hoa cỡ nhỏ, giãn chữ, cùng màu với chấm | Android: hàng `cupid_phase_widget_eyebrow_row` (chấm 8dp + `TextView` 10sp bold, `letterSpacing` 0.08, màu đặt lúc chạy bằng đúng màu chấm). iOS: `HStack(spacing: 5)` với `Circle` 7pt + `Text(entry.eyebrowLine)` 10pt bold, `tracking` 0.8 | KHỚP |
| Nhãn-mí là một chuỗi "PHA n · <TRẠNG THÁI>" | chuỗi đi từ `phase_content.v1.json` → `eyebrow_line` → native; không một ký tự hiển thị nào nằm trong `.xml`/`.kt`/`.swift` (AC-37/BR-15, có test canh) | KHỚP |
| Chấm và nhãn-mí đổi theo pha đang active | native tra `phase_id` trong bảng bốn vai trò §3a; không có vai trò thứ năm, không màu mặc định hệ điều hành | KHỚP |
| Nhãn-mí nằm **trên** dòng chính, cách một khoảng nhỏ | Android `layout_marginBottom="4dp"`; iOS `VStack(spacing: 6)` | KHỚP |
| Hàng nhãn-mí biến mất khi không có nội dung | Android `View.GONE` khi `eyebrow_line` rỗng/thiếu; iOS vẽ chuỗi rỗng trong entry `blank` | KHỚP |
| Màu chấm từng pha: PHA 1 hồng, PHA 2 tím, PHA 3 bạc hà, PHA 4 một tia chớp sáng trên nền gradient | bảng §3a: `waiting` → `--dot-waiting` `#B4A6CE` (trung tính), `upcoming` → `--dot-upcoming` `#79E2CD`, `date_day` → `--dot-today` `#FF7FB6`, `quiet` → `--dot-quiet` `#8E5FD6` | LỆCH — D-13 |

### D-13 (mới, quan sát — không tự phân xử)

Hai chỗ canvas và hợp đồng `architecture/contract-summary.md` §3a nói khác nhau.
Lượt này dựng theo hợp đồng (handoff: "implement, do not renegotiate") và ghi
lệch ra đây thay vì tự sửa:

1. **"PHA n" trên canvas không phải bốn pha của hợp đồng.** Canvas đánh số theo
   trạng thái thẻ (chưa rủ gì / đang đợi trả lời / đã chốt ngày / hôm nay), và
   hai trong bốn nhãn của nó nói thẳng về người kia ("PHA 2 · ĐANG ĐỢI CÚN TRẢ
   LỜI"). AC-11/AC-12/BR-11 cấm widget nhắc người kia, nên chuỗi nhãn-mí lấy
   đúng bốn tên ở `ux/uiux-spec.md` §1 (`đang đợi`, `sắp hẹn`, `đúng ngày hẹn`,
   `khoảng lặng`) chứ không chép chữ trên canvas. Hệ quả: số thứ tự "PHA n"
   trùng hình thức nhưng không trùng ngữ nghĩa với canvas.
2. **Chấm `date_day` gần như không đọc được trên chính nền của nó.** §3a xếp
   `--dot-today` vào "nhóm hành động chính (`--pink`/`--grad`)" → `#FF7FB6`,
   còn D-12 (P8) cho `date_day` nền gradient hồng→tím. Chấm hồng trên nền hồng
   còn rất ít tương phản; canvas vẽ chỗ đó bằng một tia chớp sáng chứ không
   phải chấm cùng tông nền. Không tự đổi sang màu trắng hay một vai trò thứ
   năm: §3a khoá cả tên vai trò lẫn nhóm ngữ nghĩa. Chủ sở hữu: UI/UX +
   Tech Lead.

### Ảnh bản dựng của widget: vẫn NOT_COMPARED, và lý do chính xác

Lượt này **không** tạo được `implemented-widget-*.png`, nên ô 7 chưa đóng
được bằng ảnh. Lý do là một mâu thuẫn nằm ngay trong §6 của
`phase-P9-widget-phase-label-and-dot.md`, không phải việc bỏ dở:

- §6 "Platform / Surface" ghi **"không chạy build native"**, và "Runtime
  startup smoke: NO".
- Bề mặt cần chụp lại là widget màn hình chính của hệ điều hành:
  `RemoteViews` (Android) và WidgetKit (iOS). Nó không nằm trong cây widget
  Flutter, nên harness `RepaintBoundary` đang tạo sáu ảnh kia không với tới
  được. Muốn có ảnh thật thì phải build native, cài lên thiết bị, đặt widget
  lên launcher rồi chụp — đúng thứ §6 loại trừ.
- Cách duy nhất còn lại để có một file `implemented-*.png` là vẽ lại widget
  bằng Dart rồi chụp bản vẽ lại đó. Đó là **bịa bằng chứng**: ảnh sẽ chứng minh
  một cây widget Flutter không tồn tại trong sản phẩm, không chứng minh gì về
  `CupidPhaseWidgetProvider.kt` hay `CupidPhaseWidget.swift`. Không làm.
- Thay cho ảnh, lượt này đối chiếu canvas ↔ mã ở bảng trên, từng thuộc tính
  một, và mọi khẳng định đó đều có test canh trong
  `test/features/phase_status/native_copy_scan_test.dart` (34 case, xanh).

Cần một quyết định của Scrum Master / Tech Lead cho ô này: hoặc mở scope cho
một lượt chụp widget thật (build native + thiết bị), hoặc ghi nhận ô 7 là
`NOT_APPLICABLE` cho per-story capture vì bề mặt thuộc hệ điều hành.

### Verdict sau lượt này

| # | Ảnh implemented | Trước | Sau |
|---|---|---|---|
| 1 | `implemented-hub-waiting.png` | FAIL — R-1 | không đụng tới ở P9 |
| 2..6 | các ảnh hub/sheet/quiet | PASS | không đụng tới ở P9 |
| 7 | *(không có ảnh)* | NOT_COMPARED — D-10, R-3 | NOT_COMPARED — D-10 **đã dựng và đối chiếu ở mức mã**, còn thiếu đúng một ảnh; R-3 và D-13 vẫn mở |

`VISUAL_FIDELITY` giữ `FAIL`: `hub-waiting` vẫn lệch ở hai chip hành động
(R-1) và ô widget vẫn chưa có ảnh. D-10 không còn là khoản mở về **cài đặt**
— nó đã dựng xong ở cả hai nền tảng — nhưng lật verdict tổng lúc này vẫn là
một chữ ký sai.

### Tồn dư cập nhật sau P9

| Id | Tồn dư | Vì sao chưa đóng | Chủ sở hữu |
|---|---|---|---|
| R-3 | Con số cỡ lớn trên widget Android (D-11) | Cần `SpannableString` trong `CupidPhaseWidgetProvider.kt`; P9 chỉ mở file này cho nhãn-mí + chấm màu, không cho cỡ chữ dòng chính | Tech Lead / Scrum Master |
| R-5 | Ảnh bản dựng của widget (ô 7) | §6 của P9 vừa đòi chụp vừa cấm build native; xem mục trên | Scrum Master / Tech Lead |
| D-13 | Lệch ngữ nghĩa "PHA n" và tương phản chấm `date_day` | §3a khoá bảng tra bốn vai trò; sửa là đổi hợp đồng | UI/UX + Tech Lead |
