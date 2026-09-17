# Visual Fidelity Report: STORY-012 Trạng thái theo pha, widget, bộ đếm

VISUAL_FIDELITY: FAIL

Lane: mobile · Ngày: 2026-09-17 · Tác giả: Alex-Mobile-Dev
Đóng gap `G-1` trong `review/review-report.md` (rule 12e2/12e3).

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

Tên file design-reference ghép **nhãn của ảnh implemented + id canvas gốc**, ví
dụ `design-reference-hub-waiting-ngan-da-hen-ngay-dang-doi-ios.png`: giữ được
cả cặp so sánh lẫn truy vết về đúng frame đã render.

| implemented | design-reference | id canvas |
|---|---|---|
| `implemented-hub-waiting.png` | `design-reference-hub-waiting-ngan-da-hen-ngay-dang-doi-ios.png` | `ngan-da-hen-ngay-dang-doi` |
| `implemented-hub-upcoming.png` | `design-reference-hub-upcoming-ngan-da-hen-ngay-dang-doi-ios.png` | `ngan-da-hen-ngay-dang-doi` |
| `implemented-hub-date_day.png` | `design-reference-hub-date_day-man-goc-muon-lam-ios.png` | `man-goc-muon-lam` |
| `implemented-hub-quiet.png` | `design-reference-hub-quiet-man-goc-muon-lam-ios.png` | `man-goc-muon-lam` |
| `implemented-evening-check-in-sheet.png` | `design-reference-evening-check-in-sheet-23h-vua-ve-j8-ios.png` | `23h-vua-ve-j8` |
| `implemented-quiet-surfaces.png` | `design-reference-quiet-surfaces-j12-nhan-ra-cot-moc-ios.png` | `j12-nhan-ra-cot-moc` |
| *(không có)* | `design-reference-widget-phases-sb-84-widget-bon-pha-ios.png` | `sb-84-widget-bon-pha` |

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
- **D-7 (delta cài đặt).** Không có lưới ô ảnh: thiết kế cho thấy trước ba
  chỗ cất ảnh; bản dựng chỉ có một nút chữ "Đính ảnh".
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
  (`design-reference-widget-phases-sb-84-widget-bon-pha-ios.png`): đó là một
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

| Id | Loại | Ảnh | Ai sửa |
|---|---|---|---|
| D-1 | delta cài đặt | hub-waiting | mobile-dev |
| D-2 | delta cài đặt | hub-waiting | mobile-dev |
| D-3 | delta cài đặt (định dạng ngày ISO) | hub-upcoming, hub-date_day | mobile-dev |
| D-4 | delta cài đặt | hub-upcoming | mobile-dev |
| D-5 | delta cài đặt | hub-date_day | mobile-dev |
| D-6 | lệch spec-prose vs canvas | evening-check-in-sheet | Scrum Master quyết trước |
| D-7 | delta cài đặt | evening-check-in-sheet | mobile-dev |
| D-8 | delta cài đặt | evening-check-in-sheet | mobile-dev |
| D-9 | delta cài đặt | evening-check-in-sheet | mobile-dev |
| D-10 | ứng viên `DESIGN_SPEC_CONFLICT` (AC-37/BR-15 + hợp đồng 5 khoá) | widget | Scrum Master / user quyết |
| D-11 | delta cài đặt | widget | mobile-dev |
| D-12 | delta cài đặt | widget | mobile-dev |

Không delta nào ở trên được sửa trong lượt này: WriteScope của handoff chỉ gồm
`visual-fidelity/` và `coding-plan/test-results.md`, và handoff cấm sửa logic
sản xuất của bất kỳ phase nào.

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
