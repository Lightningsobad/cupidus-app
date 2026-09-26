# Visual Fidelity Report: STORY-012 Trạng thái theo pha, widget, bộ đếm

VISUAL_FIDELITY: PASS

Lane: mobile · Ngày: 2026-09-26 · Tác giả: Alex-Mobile-Dev
Đóng gap `G-1` trong `review/review-report.md` (rule 12e2/12e3).

Cập nhật lượt patch #4 (2026-09-26): sáu phát hiện chặn B-1..B-6 của lượt review
S8 đã đóng hết, ô 1 và ô 7 chụp lại và soi bằng mắt, nên verdict tổng chuyển
`FAIL` → `PASS`. Chi tiết ở mục "Lượt patch #4 — B-1..B-6" cuối file. Không còn
khoản nào mở ở bảy ô.

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

Tên `implemented-*` dưới đây là tên **sau** lượt đổi tên B-7 (lượt patch #5):
id canvas đứng ngay sau tiền tố, nhãn bản dựng lùi về hậu tố trạng thái, theo
bảng §8b của `architecture/solution.md`. Không ảnh `design-reference-*` nào bị
đổi tên hay nhân bản.

Các mục "Lượt patch #1"…"#4" bên dưới giữ nguyên tên file **tại thời điểm lượt
đó chạy** (`implemented-hub-*`, `-evening-*`, `-quiet-*`, `-widget-*`): đó là
biên bản đã ghi, không phải đường dẫn còn sống. Tra tên hiện tại qua bảng ngay
trên hoặc bảng §8b.

| implemented | design-reference | id canvas |
|---|---|---|
| `implemented-ngan-da-hen-ngay-dang-doi-waiting.png` | `design-reference-ngan-da-hen-ngay-dang-doi-ios.png` | `ngan-da-hen-ngay-dang-doi` |
| `implemented-ngan-da-hen-ngay-dang-doi-upcoming.png` | `design-reference-ngan-da-hen-ngay-dang-doi-ios.png` | `ngan-da-hen-ngay-dang-doi` |
| `implemented-man-goc-muon-lam-date-day.png` | `design-reference-man-goc-muon-lam-ios.png` | `man-goc-muon-lam` |
| `implemented-man-goc-muon-lam-quiet.png` | `design-reference-man-goc-muon-lam-ios.png` | `man-goc-muon-lam` |
| `implemented-23h-vua-ve-j8-check-in-sheet.png` | `design-reference-23h-vua-ve-j8-ios.png` | `23h-vua-ve-j8` |
| `implemented-j12-nhan-ra-cot-moc-quiet-surfaces.png` | `design-reference-j12-nhan-ra-cot-moc-ios.png` | `j12-nhan-ra-cot-moc` |
| `implemented-sb-84-widget-bon-pha-date-day.png` (+ `-waiting`, `-upcoming`, `-quiet`) | `design-reference-sb-84-widget-bon-pha-ios.png` | `sb-84-widget-bon-pha` |

### B-7 đã gỡ: một tên màn duy nhất cho cả hai cổng

`visual_fidelity.py` ghép ảnh theo **token đầu tiên sau tiền tố**: nó đòi
`implemented-<screen>-*.png` và `design-reference-<screen>-*.png` trùng
`<screen>`. Bộ tên cũ (`implemented-hub-*`, `-evening-*`, `-quiet-*`,
`-widget-*`) không trùng token nào với `design-reference-*`, nên cổng exit 1.

Đổi tên phía **design** vẫn là không làm được: tên đó do
`render-design-canvas.js` sinh theo id canvas, và lượt trước đã thử chèn nhãn
vào giữa — `validate-dev-design-render.sh` lập tức không tra được screen trên
surface `cupid-ch-ng-1` nên phải xoá và render lại (xem đoạn ngay trên bảng).

Tech Lead đã chốt hướng ngược lại ở `architecture/solution.md` §8: **id canvas
là id màn chuẩn duy nhất**, nhãn bản dựng chỉ được đứng ở hậu tố. Lượt này thi
hành đúng bảng §8b — `git mv` 10 file `implemented-*`, giữ nguyên toàn bộ
`design-reference-*`, không sửa cổng. Quan hệ nhiều-một (một frame canvas phục
vụ hai trạng thái implemented) không cần cổng diễn đạt: cổng đòi **ít nhất
một** màn có đủ hai bên, và §8a dẫn năm tiền lệ story DONE cùng requirement đã
ghép nhiều-một qua đúng cổng này.

#### Bằng chứng đối chứng (không phải một lần xanh)

`verify-story-visual-fidelity-gate.sh` **không** được dùng: gọi tay nó trả
exit 0 im lặng bất kể bằng chứng đúng hay sai. Chạy trực tiếp bộ kiểm:

```bash
python3 .claude/hooks/lib/visual_fidelity.py \
  --dir <story dir> --project <worktree root> \
  --stage review --stack mobile --lane mobile
```

| Lượt | Bộ tên trong `visual-fidelity/` | Kết quả |
|---|---|---|
| A — tên mới (thư mục thật của story) | 10 file theo bảng §8b | **exit 0, không in gì → PASS** |
| B — đối chứng tên cũ (`cp -R` sang `/tmp/vf-oldname-control/`, phục hồi 10 tên cũ, ảnh y hệt) | `implemented-hub-*`, `-evening-*`, `-quiet-*`, `-widget-*` | **exit 1** |

Thông điệp lỗi nguyên văn của lượt B, trùng từng chữ với lần Iris-QC chạy ở S9:

> no screen has BOTH renders, so nothing was actually compared: running-app
> renders exist for `['evening', 'hub', 'quiet', 'widget']` and design renders
> for `['23h', 'j12', 'man', 'ngan']`.

Hai lượt chỉ khác nhau ở tên file — nội dung ảnh, story dir, cờ và bộ kiểm đều
giống hệt — nên chính việc đổi tên là thứ làm cổng chuyển đỏ sang xanh.

`ngan-da-hen-ngay-dang-doi` dùng cho **hai** trạng thái vì chính frame đó vẽ cả
thẻ "đang đợi" lẫn thẻ "chốt rồi · còn 4 ngày" trong một khung.
`man-goc-muon-lam` dùng cho `date_day` (thẻ "HÔM NAY, 19:20" ở đầu danh sách)
và làm mốc bố cục cho `quiet` — canvas **không ship frame riêng cho pha khoảng
lặng**, nên trạng thái đó chấm theo BR-2 chứ không theo pixel.

## Verdict theo màn và theo trạng thái AC

> Bảng này là ảnh chụp trạng thái **lượt đầu (2026-09-17)** và được giữ nguyên
> làm mốc lịch sử. Verdict đang có hiệu lực nằm ở mục "Lượt patch #4 —
> B-1..B-6" cuối file: bảy ô đều `PASS`.

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

## Lượt P12 (2026-09-25) — ảnh widget thật trên Android, ô 7

### Cách chụp: ảnh hệ điều hành thật, không vẽ lại bằng Dart

Bốn file `implemented-widget-*.png` lượt này là ảnh chụp màn hình chính thật của
launcher Android, chụp từ `RemoteViews` do `CupidPhaseWidgetProvider.kt` dựng —
không phải một cây widget Flutter vẽ lại cho giống:

1. `flutter build apk --debug --flavor local --split-per-abi` (phải có
   `--flavor` vì module khai báo hai flavor `local`/`prod`; lệnh trần trong
   registry runtime không chạy được — xem mục "Lệch phát hiện ngoài phạm vi").
2. `adb install -r app-arm64-v8a-local-debug.apk` lên `sdk_gphone64_arm64`,
   Android 16, 1080×2400, density 420.
3. Nạp payload vào đúng file prefs mà `home_widget` 0.9.4 đọc —
   `HomeWidgetPreferences`, lấy từ hằng `HomeWidgetPlugin.PREFERENCES` trong
   mã plugin chứ không đoán tên — qua `run-as`, đủ sáu khoá của
   `../architecture/contract-summary.md` §2.
4. Đặt widget lên màn hình chính **một lần** bằng thao tác UI thật: giữ vùng
   trống → Widgets → `cupid_mobile` (3 × 1) → kéo thả.
5. Mỗi pha sau đó: nạp lại payload rồi `adb install -r` chính APK đó, để hệ
   thống tự phát `APPWIDGET_UPDATE` tới provider. Không dùng `am broadcast`
   thủ công được: đó là protected broadcast, shell nhận
   `SecurityException: not allowed to send broadcast ... from unknown caller`,
   và ảnh máy ảo là build `ro.build.type=user` nên `adb root` bị từ chối
   (`adbd cannot run as root in production builds`).
6. `adb exec-out screencap -p`, cắt về vùng widget bằng `sips` nhưng chừa lại
   nền tường hai phía để thấy widget đang nằm trên launcher thật.

Mặt bằng so sánh: ảnh bản dựng là **Android**, canvas mốc là **iOS**. Vì vậy
chỉ chấm hình dạng chỉ báo, màu theo vai trò token, tỉ lệ và thứ tự thông tin.
Không chấm vỏ hệ điều hành, phông hệ thống, hay bo góc — Android 12+ tự cắt bo
góc widget ở phía launcher, layout không khai báo.

### Ô 7 — đối chiếu từng thuộc tính

`implemented-widget-date-day.png` ↔ thẻ "PHA 4 · HÔM NAY, TRƯỚC GIỜ ĐI" của
`design-reference-sb-84-widget-bon-pha-ios.png` (thẻ pha đúng-ngày-hẹn trên
canvas).

| Thuộc tính | Canvas (thẻ pha hôm nay) | Ảnh bản dựng | Kết |
|---|---|---|---|
| Hình chỉ báo pha | tia chớp, không phải chấm | tia chớp, rasterise từ `@drawable/dot_today_bolt` | **KHỚP** — D-13 đóng bằng ảnh |
| Màu chỉ báo | tia chớp sáng gần trắng trên nền hồng | `#FF7FB6` (vai trò `--dot-today`) | LỆCH ĐÃ BIẾT — D-13, chủ sở hữu UI/UX + Tech Lead |
| Nền thẻ | gradient hồng → tím **riêng** cho pha hôm nay | `#241B42` phẳng, y hệt ba pha kia | LỆCH MỚI — R-6 |
| Nhãn-mí | chữ hoa, giãn chữ, cùng màu với chỉ báo | chữ hoa, `letterSpacing 0.08`, cùng màu chỉ báo | KHỚP |
| Dòng chính | đậm, sáng, trên một–hai dòng | đậm `#F7EEFB`, `maxLines=2` | KHỚP |
| Dòng phụ | mờ hơn, hiện đủ một dòng | `#B4A6CE`, `maxLines=1`, bị cắt "…" ở ô 3 × 1 | LỆCH MỚI — R-7 |
| Con số cỡ lớn | canvas vẽ "4" cỡ lớn ở thẻ pha sắp hẹn | không có ở bất kỳ pha nào | R-3 vẫn mở, nay có ảnh chứng minh |
| Biểu tượng ứng dụng trong thẻ | **không có** | ô vuông trắng đục `@mipmap/ic_launcher` 24dp bên trái | LỆCH MỚI — R-8 |
| Bo góc, viền | bo lớn | bo lớn do launcher cắt | KHỚP |

### Ba pha còn lại — kiểm chứng nhánh chỉ báo (D-10 + D-13)

Ba ảnh kia không có thẻ tương ứng riêng trên canvas `sb-84` để chấm pixel; mục
đích của chúng là chứng minh nhánh chọn hình + màu chỉ báo chạy đúng trên thiết
bị thật, và là bằng chứng hai-pha cho bề mặt rủi ro `WIDGET-STALE`.

| Ảnh | phase_id | Chỉ báo quan sát được | Vai trò token mong đợi | Kết |
|---|---|---|---|---|
| `implemented-widget-waiting.png` | `waiting` | chấm tròn, tím nhạt | `DOT_WAITING` `#B4A6CE` | KHỚP |
| `implemented-widget-upcoming.png` | `upcoming` | chấm tròn, xanh ngọc | `DOT_UPCOMING` `#79E2CD` | KHỚP |
| `implemented-widget-quiet.png` | `quiet` | chấm tròn, tím đậm | `DOT_QUIET` `#8E5FD6` | KHỚP |
| `implemented-widget-date-day.png` | `date_day` | **tia chớp**, hồng | `DOT_TODAY` `#FF7FB6` + glyph D-13 | KHỚP về hình |

Ba pha không-phải-`date_day` giữ chấm tròn: đó là nửa còn lại của D-13, và nó
chỉ chứng minh được bằng ảnh thật như thế này.

Chữ: mọi dấu tiếng Việt và ký tự phân cách `·` (U+00B7) hiện đúng trên cả bốn
ảnh, không ô tofu nào. Nội dung hiện ra khớp từng chữ với gói
`assets/data/req016/phase_content.v1.json` — tức là chuỗi đi từ gói nội dung
qua payload tới `RemoteViews`, không có chuỗi nào sinh ở tầng native
(AC-37/BR-15, khớp với 38 case xanh của `native_copy_scan_test.dart`).

### Deep link (điểm vào, rule 13a)

Chạm một lần vào widget khi đang hiển thị pha `quiet`:
`dumpsys activity activities` trả `ResumedActivity: com.snapsofts.cupid/
com.snapsofts.cupid_mobile.MainActivity`. Intent của widget tới được app.
Chặng điều hướng trong app tới đúng thẻ `card_id` **chưa** kiểm chứng được ở
lượt này vì API local không chạy — app dừng ở màn "Không thể kết nối máy chủ".
Không mở rộng phạm vi để dựng backend; ghi nhận là giới hạn của lượt chụp.

### Tồn dư mới phát hiện ở P12 (P12 không sửa mã sản phẩm)

Ba khoản dưới đây là **phát hiện**, không phải việc bỏ dở: §4 của
`phase-P12-widget-native-capture.md` cấm sửa mã sản phẩm trong phase này, nên
chúng được ghi ra cho Scrum Master định tuyến.

| Id | Tồn dư | Bằng chứng | Chủ sở hữu đề xuất |
|---|---|---|---|
| R-6 | Nền widget phẳng `#241B42` cho cả bốn pha; canvas cho pha hôm nay một gradient hồng → tím riêng | `cupid_phase_widget.xml:17` (`android:background` là màu đơn); so với thẻ pha 4 của canvas | Tech Lead — cần drawable gradient theo pha, ngoài WriteScope P12 |
| R-7 | Dòng phụ bị cắt "…" ở ô mặc định 3 × 1 trên ba trong bốn pha | `cupid_phase_widget.xml:85` (`maxLines=1`) + bốn ảnh | UI/UX — chọn giữa nới `maxLines`, ô 4 × 1 mặc định, hay rút ngắn chuỗi trong gói nội dung |
| R-8 | `@mipmap/ic_launcher` dựng thành một ô vuông **trắng đục** trên nền tối; canvas không vẽ biểu tượng ứng dụng nào trong thẻ | `cupid_phase_widget.xml:22-27` + bốn ảnh | UI/UX + Tech Lead — bỏ hẳn, hay thay bằng bản đơn sắc nền trong |

### Lệch phát hiện ngoài phạm vi (không sửa ở P12)

`data/devops/system/runtime-command-registry.json` ghi `mobile-app.buildCommand`
là `flutter build apk --debug` (không flavor). Lệnh đó **không chạy được** trên
module này: `mobile/android/app/build.gradle.kts` khai báo
`flavorDimensions += "backend"` với hai flavor `local`/`prod`, nên Gradle đòi
`--flavor`. Chủ sở hữu: DevOps.

### Verdict sau lượt này

| # | Ảnh implemented | Trước | Sau |
|---|---|---|---|
| 1 | `implemented-hub-waiting.png` | FAIL — R-1 | không đụng tới ở P12 |
| 2..6 | các ảnh hub/sheet/quiet | PASS | không đụng tới ở P12 |
| 7 | `implemented-widget-date-day.png` (+ `-waiting`, `-upcoming`, `-quiet`) | NOT_COMPARED | **FAIL — đã đối chiếu**: hình chỉ báo D-13 và bốn vai trò màu D-10 KHỚP; còn R-3, R-6, R-7, R-8 và lệch màu D-13 |

R-5 (thiếu ảnh bản dựng của widget) **đóng**: ô 7 không còn là `NOT_COMPARED`,
và câu hỏi "chụp thật hay ghi `NOT_APPLICABLE`" ở mục P9 đã có câu trả lời —
chụp thật được, bằng chính đường build + thiết bị mà lượt này đi.

`VISUAL_FIDELITY` giữ `FAIL`. Lý do **không** đổi: R-1 (hai chip hành động ở
`hub-waiting`, chờ chuỗi hiển thị mới từ Product Owner) vẫn mở, và ô 7 vừa mở
thêm R-6/R-7/R-8. Cổng `visual_fidelity.py --stage review --stack mobile` vì
thế vẫn exit 1 với thông điệp "does not record 'VISUAL_FIDELITY: PASS'" — đó là
trạng thái đúng của story lúc này, không phải lỗi bằng chứng.

## Lượt patch #4 — B-1..B-6 (2026-09-26)

Lượt này nhận nguyên sáu phát hiện chặn của `review/review-report.md` (S8,
`Outcome: PATCH_REQUIRED`, AC-9) và đóng cả sáu trong một lượt mobile. Chuỗi
hiển thị mà R-1 chờ đã có quyết định Product Owner, nên khoản duy nhất treo
xuyên ba lượt trước cũng đóng được ở đây.

### Đã đóng trong lượt này

| Id review | Tồn dư cũ | Cách đóng | Bằng chứng |
|---|---|---|---|
| B-1 | R-1 — `hub-waiting` thiếu nhãn hành động thứ hai | `PhaseContentItem` nhận trường tuỳ chọn `action_label`, vào thẳng `displayStrings` nên cổng bất biến AC-39 đo nó như mọi chuỗi hiển thị khác; gói nội dung khai `"Chọn trước một chỗ"` cho `phase.waiting.prepare.v1`. Không có nhãn mặc định ở bất kỳ tầng nào: vắng trường là vắng hành động | `implemented-hub-waiting.png` |
| B-3 | R-7 — dòng phụ bị cắt "…" ở ô mặc định | Ba việc cùng lúc: bốn chuỗi `secondary` mới theo AC-37, ô mặc định nới `minWidth` 180dp → 250dp, và ngân sách ≤28 grapheme ép ngay lúc nạp gói cho `secondary` (bề mặt `widget`/`both`) lẫn `action_label` | bốn ảnh `implemented-widget-*.png`: không ảnh nào còn dấu "…" |
| B-4 | R-8 — ô vuông `@mipmap/ic_launcher` trắng đục | Gỡ hẳn `ImageView` khỏi layout | bốn ảnh widget |
| B-2 | R-6 — nền phẳng cho cả bốn pha | Hai drawable: gradient ngang `#FF7FB6` → `#B78CF5` cho `date_day`, nền phẳng `#241B42` cho ba pha kia, đẩy **mỗi lượt cập nhật** bằng `setBackgroundResource` | `implemented-widget-date-day.png` so với `-waiting` |
| B-6 | D-13 phần 2 — tia chớp màu hồng chìm trên nền gradient | Vai trò `--dot-today` chuyển `colorAccentPink` → `colorOnAccent` `#F7EEFB`; cả hai palette native khai một thành viên `onAccent`/`ON_ACCENT` riêng thay vì mượn `text` | `implemented-widget-date-day.png` |
| B-5 | R-3 — không có chữ số cỡ lớn trên Android | Cụm chữ số đầu tiên của `primary` nhận `RelativeSizeSpan(34f / 14f)` + `ForegroundColorSpan`, đẩy qua `setTextViewText` trong **một** `TextView` duy nhất | `implemented-widget-upcoming.png` ("4"), `implemented-widget-quiet.png` ("12") |

B-2 và B-6 đi chung một lượt đúng như review yêu cầu: tia chớp sáng chỉ có
nghĩa khi nền gradient đã có, và nền gradient chỉ đọc được khi tia chớp đã
sáng.

### Một quyết định nền phải nói rõ: vì sao đẩy nền ở **cả hai** nhánh

`backgroundFor()` trả về drawable cho cả ba pha phẳng, không chỉ cho
`date_day`. Đây không phải dư thừa: `AppWidgetHostView.updateAppWidget` gọi
`RemoteViews.reapply` lên chính view đã inflate khi layout id không đổi, nên
nếu để ba pha kia rơi về mặc định của XML thì gradient của `date_day` sẽ **đọng
lại** trên pha kế tiếp. `implemented-widget-waiting.png` chụp ngay sau
`implemented-widget-date-day.png` là bằng chứng hai-pha cho việc đó: nền đã trở
về `#241B42` phẳng.

### Một lệch phát sinh do chính B-2, đã đóng trong lượt

Khi `date_day` có nền gradient, dòng phụ `#B4A6CE` cố định trong layout tụt
tương phản tới mức gần như không đọc được (thấy rõ ở lượt chụp thử đầu tiên).
iOS đã có luật riêng cho đúng chỗ này từ trước — `secondaryColor` ở
`CupidPhaseWidget.swift:265` đổi sang `text` với `opacity 0.85` khi
`isDateDay`. Android nay đẩy cùng luật đó bằng `setTextColor` với
`TEXT_ON_GRADIENT` `#D9F7EEFB` (alpha 85% gộp sẵn vào giá trị, vì `RemoteViews`
không có lệnh opacity riêng). Đây là parity với mốc iOS, không phải token mới.

### Cách chụp ô 7 ở lượt này

Đúng đường P12 đã mở, không phát sinh cách mới: nạp sáu khoá §2 vào
`HomeWidgetPreferences.xml` qua `run-as`, rồi `adb install -r` chính APK để hệ
thống tự phát `APPWIDGET_UPDATE`. `am broadcast` thủ công vẫn bị từ chối
(`SecurityException: not allowed to send broadcast ... from unknown caller`) và
`adb root` vẫn bị từ chối (`adbd cannot run as root in production builds`) —
ảnh thiết bị là build production. `adb logcat -d` sau mỗi lượt cập nhật: không
một exception nào của `com.snapsofts.cupid`.

Payload nạp tay khớp từng chữ với thứ gói nội dung thật sẽ công bố: với mỗi
pha, `_widgetLineFor` lấy mục `allowsWidget` **đầu tiên** bỏ qua mục còn `{n}`
khi không có số, tức `phase.waiting.prepare.v1`, `phase.upcoming.countdown.v1`,
`phase.date_day.today.v1`, `phase.quiet.gathering.v1`.

### Ô 7 — đối chiếu lại từng thuộc tính đã lệch

`implemented-widget-date-day.png` ↔ thẻ pha đúng-ngày-hẹn của
`design-reference-sb-84-widget-bon-pha-ios.png`.

| Thuộc tính | Kết ở P12 | Kết lượt này |
|---|---|---|
| Hình chỉ báo pha | KHỚP | KHỚP — tia chớp giữ nguyên |
| Màu chỉ báo | LỆCH — D-13 | **KHỚP** — tia chớp sáng gần trắng `#F7EEFB` trên nền hồng |
| Nền thẻ | LỆCH — R-6 | **KHỚP** — gradient hồng → tím riêng cho pha này |
| Dòng phụ | LỆCH — R-7 (cắt "…") | **KHỚP** — hiện đủ một dòng, và đọc được trên gradient |
| Con số cỡ lớn | LỆCH — R-3 | **KHỚP** — xem `-upcoming` và `-quiet`; pha `date_day` không có chữ số nào trong `primary` nên đúng là không có |
| Biểu tượng ứng dụng trong thẻ | LỆCH — R-8 | **KHỚP** — không còn biểu tượng nào |
| Nhãn-mí, dòng chính, bo góc | KHỚP | KHỚP |

Chữ: soi bằng mắt cả bốn ảnh — mọi dấu tiếng Việt và ký tự `·` (U+00B7) hiện
đúng, không ô tofu nào.

### Verdict sau lượt này

| # | Ảnh implemented | Trước | Sau |
|---|---|---|---|
| 1 | `implemented-hub-waiting.png` | FAIL — R-1 | **PASS** — hành động thứ hai đã hiện, đúng bậc hành động phụ của `ux/requirement-ux-survey.md` §4 |
| 2..6 | các ảnh hub/sheet/quiet | PASS | PASS — ô 2 và ô 3 chụp lại vì chuỗi `secondary` của gói đổi; bố cục không đổi |
| 7 | `implemented-widget-date-day.png` (+ `-waiting`, `-upcoming`, `-quiet`) | FAIL — R-3, R-6, R-7, R-8, D-13 | **PASS** — cả năm khoản đóng |

`VISUAL_FIDELITY` chuyển `PASS`. Không còn tồn dư mở nào thuộc bảy ô của story
này. Hai khoản đã ghi ở các lượt trước vẫn nằm ngoài bề mặt story và giữ chủ
sở hữu cũ: `mobile-app.buildCommand` thiếu `--flavor local` trong registry
runtime (DevOps), và chặng điều hướng sâu sau khi chạm widget chưa kiểm chứng
được vì API local không chạy trong lượt chụp.

### Lệnh đã chạy ở P12

```
flutter build apk --debug --flavor local --split-per-abi
adb shell cmd package uninstall -k com.snapsofts.cupid
adb install -r .../flutter-apk/app-arm64-v8a-local-debug.apk
adb shell "run-as com.snapsofts.cupid sh -c 'echo <b64> | base64 -d > /data/data/com.snapsofts.cupid/shared_prefs/HomeWidgetPreferences.xml'"
adb shell input swipe 540 950 540 950 1200      # giữ vùng trống trên màn chính
adb shell input motionevent DOWN/MOVE/UP ...    # kéo widget từ bộ chọn ra màn chính
adb exec-out screencap -p > <ảnh gốc 1080x2400>
sips -c 396 814 --cropOffset 362 12 <ảnh gốc> --out implemented-widget-<pha>.png
adb shell dumpsys activity activities            # xác nhận MainActivity sau khi chạm widget
flutter test test/features/phase_status/native_copy_scan_test.dart   # 38/38 xanh
python3 .claude/hooks/lib/visual_fidelity.py --dir <thư mục này> --stage review --stack mobile
```

## Lượt patch #5 — B-1a (hình khối chip) và B-7 (đổi tên 10 ảnh implemented)

Vào sau `full-story-review` S9 của Iris-QC (`Outcome: PATCH_REQUIRED`, hai
khoản chặn). Lượt này đóng cả hai.

### B-1a — chip hành động phụ đã là chip, không còn text trần

Dữ liệu đã đúng từ lượt #4 (`action_label` đi qua `displayStrings`, cổng bất
biến AC-39 đo được), chỉ **hình khối** là sai: `_PhaseStatusAction` vẽ nhãn
thành chữ hồng trần. `ux/uiux-spec.md` §1 vá B-1 đòi chip bo tròn theo canvas.

Quy cách lấy nguyên từ canvas, không suy đoán — `Cupid Chặng 1.dc.html:236`,
chip `Chọn quán dự phòng` của màn `ngan-da-hen-ngay-dang-doi`:

| Thuộc tính canvas | Giá trị CSS | Token đã dùng trong Dart |
|---|---|---|
| nền | `background:var(--surf)` | `colors.colorSurface` (`--surf` = `#241B42` dark / `#FFFFFF` light, khớp từng byte với bảng biến CSS dòng 24-25) |
| viền | `1px solid var(--line)` | `Border.all(color: colors.colorLine)` |
| bo góc | `border-radius:999px` | `platform.radiusButton` (= `999`) |
| đệm | `9px 14px` | `horizontal: CupidSpacing.md` (16), `vertical: CupidSpacing.sm` (8) — ô lưới 8pt gần nhất |
| chữ | `font-size:12.5px; font-weight:700` | `type.caption` (13) + `FontWeight.w700` |
| màu chữ | mặc định `var(--tx)` | `colors.colorText` |

Hai điều chỉnh kèm theo, đều có lý do nêu tại chỗ trong mã:

- Bỏ thụt lề `left: md`. Thụt lề đó thuộc cách đọc "text button" của
  `ux/requirement-ux-survey.md` §4 mà vá B-1 đã thay; canvas đặt chip sát mép
  trái khối chuẩn-bị.
- Màu chữ chuyển `colorAccentPink` → `colorText`. Canvas dùng `--tx`, và hồng
  ở cỡ caption vi phạm ADR-004b (hồng light `#E8558F` trên trắng ~3.4:1, dưới
  ngưỡng AA 4.5:1 cho chữ nhỏ). Hồng vẫn giữ nguyên ở CTA `Hẹn ngày`.

Chip vẫn là bậc hành động phụ, không phải CTA thứ hai (D-2): nền `--surf` đặt
trên nền khối `--surf2`, không phải nền hồng đặc của CTA chính.

Ô 1 đã chụp lại **sau** khi sửa mã, dưới tên mới. Soi bằng mắt ảnh mới: chip
"Chọn trước một chỗ" hiện thành viên thuốc bo tròn có nền và viền nằm trong
khối "Chuẩn bị dần cho buổi tới"; mọi dấu tiếng Việt hiện đúng, không tofu.

Kiểm thử: `flutter test test/features/phase_status` — **263 xanh, 6 skip, 0
đỏ**. Riêng `phase_status_line_test.dart` 17 xanh / 4 skip, gồm cả khẳng định
`getSize(phaseStatusLineActionKey).height >= 44` (chip vẫn là vùng chạm đủ) và
cổng "không chuỗi tiếng Việt nào trong `phase_status_line.dart`".

### B-7 — 10 ảnh `implemented-*` đã đổi tên

Thi hành bảng §8b của `architecture/solution.md` bằng `git mv`; bảng "Đặt cặp
ảnh" ở đầu file đã cập nhật. Không đụng `design-reference-*`, không sửa cổng,
không đổi một dòng mã sản phẩm nào vì khoản này.

Bằng chứng đối chứng (tên mới xanh / tên cũ đỏ) ghi ở mục "Bằng chứng đối
chứng" ngay dưới bảng đặt cặp.

### Tồn dư mở sau lượt này

Tên file chụp **do mã test sinh ra**, không do người đặt:
`mobile/test/features/phase_status/phase_status_line_test.dart:627` nối chuỗi
`'implemented-hub-${phase.wireValue}.png'`, và harness chụp widget ở P12 ghi
`implemented-widget-<pha>.png`. Lượt này chụp dưới tên cũ rồi `git mv`, vì
`mobile/test/**` nằm ngoài WriteScope được giao. Hệ quả: lần sau ai chạy
`--dart-define=CAPTURE_VISUALS=true` sẽ sinh lại **tên cũ** bên cạnh tên mới và
cổng đỏ trở lại. `architecture/solution.md` §8d kết luận "không mở WriteScope
`mobile/` cho khoản B-7" dựa trên tiền đề không còn đúng — tiền đề đó chỉ xét
mã sản phẩm, không xét mã test. Cần một lượt nhỏ sửa hằng tên trong hai harness
chụp; đây là việc định tuyến cho Scrum Master, không phải quyết định của lane
mobile.

### Lệnh đã chạy ở lượt #5

```
flutter test test/features/phase_status --reporter failures-only
flutter test test/features/phase_status/phase_status_line_test.dart \
  --dart-define=CAPTURE_VISUALS=true \
  --plain-name "captures screen (1) in the waiting phase" --reporter expanded
git mv implemented-<tên cũ>.png implemented-<tên mới>.png     # 10 lần, theo §8b
python3 .claude/hooks/lib/visual_fidelity.py --dir <thư mục này> \
  --project <gốc worktree> --stage review --stack mobile --lane mobile   # exit 0
cp -R <thư mục story> /tmp/vf-oldname-control/ && <phục hồi 10 tên cũ>
python3 .claude/hooks/lib/visual_fidelity.py --dir /tmp/vf-oldname-control/... \
  --project <gốc worktree> --stage review --stack mobile --lane mobile   # exit 1
```
