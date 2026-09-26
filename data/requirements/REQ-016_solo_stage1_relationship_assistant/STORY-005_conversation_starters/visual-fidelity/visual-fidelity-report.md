VISUAL_FIDELITY: PASS
DESIGN_ANCHOR_ADJUDICATION_REQUIRED: NO (đã phân xử — xem §7)
Design-Screen: 6-moi-chuyen-a-a (đã xác nhận bằng ảnh dựng, xem §2 và §4b)

# STORY-005 — "Mồi chuyện", visual fidelity (P4 màn hình + lối vào, cập nhật sau rework P5-P7)

- Story: REQ-016 / STORY-005, phases P4 → P7
  (`coding-plan/phase-P4-screen-and-entry-point.md` §6, mục
  "Per-story visual fidelity: REQUIRED"; giữ hiệu lực cho cả ba phase rework)
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Date: 2026-09-24 (bản gốc 2026-09-17, so sánh ảnh 2026-09-20, rework P5-P7 tới
  2026-09-23)

> **Phán quyết neo-thiết-kế đã đóng.** Người dùng chọn **đường 1 ("Neo thiết
> kế")** trong ba đường §7 đề xuất ngày 2026-09-20. Sáu chỗ mở khi đó (mục 2, 3,
> 4, 5, 6b, 7) đã được bóc thành ba phase rework và **đã ship**: P5 (`ae908e93`)
> phân cấp hero/phụ, P6 (`9ab00f48`) nhãn + affordance + ngày inline, P7
> (`fa9c0ad5`) dòng lý do của sự kiện. `ux/uiux-spec.md` §2/§5 đã được vá cho
> khớp canvas ở `06dc96a4`. Vì vậy cờ đầu tệp chuyển
> `DESIGN_ANCHOR_ADJUDICATION_REQUIRED: YES → NO`, §6 và §7 được viết lại theo
> đúng thứ đang chạy, và §1/§4b neo lại trên ảnh chụp của P7. Không có tranh
> chấp canvas-vs-spec nào còn treo ở màn này.

## 1. Ảnh đã chụp

| Design screen id | Design source | Design reference | Implemented |
| --- | --- | --- | --- |
| `6-moi-chuyen-a-a` | `cupid-ch-ng-1` (`Cupid Chặng 1.dc.html`, `screens_from: "frames"`, `platforms: ["ios"]`) | `design-reference-6-moi-chuyen-a-a-ios.png` (415x900) — dựng được ngày 2026-09-20, xem §3 | `implemented-6-moi-chuyen-a-a-material.png` (415x900) — **ảnh hiện tại là bản chụp của P7** (`fa9c0ad5`, 2026-09-23), tức là bản dựng **sau** cả ba phase rework |

Ảnh implemented được chụp lại ở **cả ba** phase rework, mỗi lần đè lên cùng một
tên tệp; tệp đang nằm trên đĩa là lần chụp cuối (P7). Vòng vá tài liệu này
**không** chụp lại và không cần chụp lại: bản P7 đã mang đủ sáu mục đã phân xử.

| Lần chụp | Commit | Thứ mà ảnh lần đó chứng minh |
| --- | --- | --- |
| P5 | `ae908e93` | thẻ hero `CÂU HÔM NAY` + caption `CÙNG CHỦ ĐỀ` + hai câu phụ |
| P6 | `9ab00f48` | nút đặc `Chép để nhắn`, đĩa `refresh`, dòng trấn an, nhãn khối sự kiện, ngày inline |
| P7 (đang trên đĩa) | `fa9c0ad5` | tất cả các mục trên **cộng** dòng lý do, và lần đầu thấy được khối sự kiện trong khung 415x900 |

## 2. Cách phân giải `Design-Screen:` khi không có trình dựng

`story_master.md` và `ux/uiux-spec.md` của STORY-005 **không** mang dòng
`Design-Screen:` nào (đã grep cả thư mục story). Bước A của quy trình
(`--list-screens`) không chạy được, nên id dưới đây được **suy ra từ chính tệp
canvas**, không phải bịa và cũng không phải do trình dựng liệt kê:

- Khung của màn này trong `cupid-app-design-system/Cupid Chặng 1.dc.html`
  (dòng 790) mang nhãn `(6) Mồi chuyện A / A+`. Đây là khung **duy nhất** trong
  33 khung của canvas dựng bề mặt của story này.
- Quy tắc tạo slug được đối chiếu ngược từ **sáu** cặp nhãn→id đã được các
  story khác trong cùng REQ-016 xác nhận:
  `Phút 1 — kho trống` → `phut-1-kho-trong`;
  `Màn gốc — Muốn làm` → `man-goc-muon-lam`;
  `SB-211 "Trước giờ đi"` → `sb-211-truoc-gio-di`;
  `(3) Hồ sơ kỹ năng "phiên bản tôi"` → `3-ho-so-ky-nang-phien-ban-toi`;
  `(5) Gợi ý quà — thang công sức` → `5-goi-y-qua-thang-cong-suc`;
  `(11) Xuất lời mời — chọn khung` → `11-xuat-loi-moi-chon-khung`.
  Quy tắc: bỏ dấu tiếng Việt về chữ cái gốc, bỏ dấu ngoặc/dấu nháy/gạch ngang
  em, gộp khoảng trắng thành `-`.
- Áp cùng quy tắc: `(6) Mồi chuyện A / A+` → `6-moi-chuyen-a-a`.

Suy luận này **chưa được bước C (dựng ra nhìn) xác nhận**. Scrum Master nên chép
dòng `Design-Screen:` sang `story_master.md` sau khi trình dựng được cài lại và
id được liệt kê xác nhận; `story_master.md` nằm ngoài write scope của phase này.

## 3. Lịch sử: vì sao vòng đầu (2026-09-17) không có ảnh design reference

> **Đã giải quyết 2026-09-20.** Scrum Master cài lại phụ thuộc còn thiếu của
> trình dựng và dựng ra
> `design-reference-6-moi-chuyen-a-a-ios.png` (415x900, surface
> `cupid-ch-ng-1`, biến thể ios), commit `04a2d610`. So sánh ảnh trực tiếp nằm
> ở §4b; §5 (đối chiếu theo nội dung với `ux/uiux-spec.md`) vẫn giữ nguyên
> hiệu lực như cơ sở thứ hai, không bị thay thế. Phần dưới giữ lại để ghi
> nhận vì sao vòng đầu chỉ có cơ sở đối chiếu theo nội dung.


```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --surface=cupid-ch-ng-1 --list-screens
→ exit 3
VISUAL_RUNTIME_MISSING: ... is not provisioned. This is an install defect —
run: .ai-team-bundle/runtime/ensure-runtime.sh --capability=visual-inspection
```

Đây là **install defect của runtime**, không phải lỗi của story, và việc cài
lại năng lực `visual-inspection` nằm ngoài lane Mobile. Hệ quả: không dựng được
`design-reference-6-moi-chuyen-a-a-ios.png`, nên **không có so sánh pixel**.

Thay vào đó, khung thiết kế được đọc trực tiếp từ DOM của canvas (dòng 795–826)
và so sánh **theo nội dung**: nhãn, thứ tự khối, hành động. Kết quả so sánh nằm
ở §5–§6. Đây cũng đúng thứ mà phase P4 §6 yêu cầu làm chuẩn đối chiếu:
"ảnh chụp màn kèm đối chiếu với `../ux/uiux-spec.md`".

## 4. Ảnh implemented được tạo thế nào

Không phải ảnh chụp thiết bị. Dùng fallback mà phase P4 §6 cho phép
(`Fallback được phép: bọc RepaintBoundary và chụp ngay trong widget test của
chính phase này`): `RepaintBoundary.toImage` bên trong
`mobile/test/features/conversation_starters/conversation_starters_screen_test.dart`,
test `captures 6-moi-chuyen-a-a`, dựng **chính** `ConversationStartersScreen`
thật (không phải harness thay thế) với `buildCupidTheme` thật,
`CupidAppBackground`, và bốn họ font trong `pubspec.yaml` (Nunito, Roboto,
Roboto Mono, Material Symbols Rounded) cộng `MaterialIcons-Regular.otf` của
framework nạp qua `FontLoader`. Test bị `skip` trừ khi có dart-define, nên bộ
test thường vẫn kín.

Dựng lại:

```
FLUTTER_ROOT="$HOME/flutter" flutter test \
  test/features/conversation_starters/conversation_starters_screen_test.dart \
  --dart-define=CAPTURE_VISUALS=true
```

### Chi tiết harness — không phải lỗi sản phẩm

- Chụp qua `CupidPlatform.material` chứ không phải `.ios`, dù design source
  `cupid-ch-ng-1` khai `platforms: ["ios"]`. `CupidHeader` bản iOS đặt một
  `BackdropFilter` lên chính tiêu đề của nó; chụp ngoài màn hình thì filter
  không có gì phía sau để lấy mẫu và làm bay mất tiêu đề. Mọi thứ đang audit ở
  đây đều trung tính với nền tảng. Tên tệp ghi `-material` đúng như đã chụp,
  không ghi `-ios` để khỏi khai sai.
- Không có nút quay lại trong ảnh: `CupidHeader` chỉ gắn `onBack` khi
  `Navigator.of(context).canPop()`
  (`conversation_starters_screen.dart:109–111`). Ảnh chụp dựng màn ở gốc cây
  nên `canPop()` là `false`; đường production đẩy màn bằng `MaterialPageRoute`
  từ ô lối-vào-nhanh nên nút quay lại có thật — có test điều hướng riêng phủ.
- Không có thanh trạng thái iOS, không có home indicator: ảnh design có device
  chrome, một lần dựng widget trực tiếp thì không.
- Nội dung câu mồi trong ảnh là gói fixture (`Fixture starter 1..12`) chứ không
  phải gói ship kèm — bố cục là thứ đang audit, còn nội dung gói đã có test
  riêng ở P1/P2.
- **Từ P7 trở đi**, `_captureAtReferenceViewport` nhận thêm tham số tuỳ chọn
  `beforeCapture`, và lần chụp này chạm `ask-skip` trước khi chụp. Lý do nằm ở
  §4b: ô hỏi sổ tay (`ContextAskCard`) chiếm nửa dưới khung `415x900` và đẩy
  khối sự kiện xuống dưới fold, nên P6 không đối chiếu được mục 5 và 6b bằng
  mắt. Khung reference, nền, font và nền tảng Material giữ y nguyên — chỉ trạng
  thái của ô hỏi đổi, và đó là trạng thái người dùng thật cũng đạt được bằng một
  chạm "Bỏ qua".

**Ảnh đã được mở ra nhìn bằng mắt** (bản P7 đang trên đĩa). Mọi chữ tiếng Việt
lên đúng dấu — `Mồi chuyện`, `CÂU HÔM NAY`, `Chép để nhắn`, `Câu này nhắn liền,
không cần lưu. Quay lại là có câu khác.`, `CÙNG CHỦ ĐỀ`, `CÓ LỊCH SẴN · RỦ ĐI
ĐƯỢC`, `Sinh nhật bạn ấy — thứ Ba 20/10`, `Đúng dòng "thích đọc sách cũ" trong
sổ tay`, `Kỷ niệm quen nhau — thứ Hai 02/11`, `Thêm vào Muốn làm` — **không có ô
tofu nào**. Glyph `content_copy`, `refresh`, `calendar` và `close` rasterise
đúng hình, không phải ô vuông. Cặp dấu nháy kép thẳng trong dòng lý do lên
nguyên vẹn.

## 4b. So sánh ảnh trực tiếp (2026-09-20, neo lại trên ảnh P7 ngày 2026-09-24)

Phần đầu mục này ghi vòng so sánh 2026-09-20 — lúc đó ảnh implemented còn là bản
**trước** rework. Phần "Sau rework" ở cuối mục là vòng so sánh hiện hành, chạy
trên đúng tệp đang nằm trên đĩa (bản chụp P7).

Hai tệp đã được **mở ra nhìn bằng mắt** cạnh nhau:
`design-reference-6-moi-chuyen-a-a-ios.png` ↔
`implemented-6-moi-chuyen-a-a-material.png`.

**Cùng một màn logic — đã xác nhận.** Ảnh design mang đúng tiêu đề `Mồi chuyện`,
đúng nền gradient tím-đỏ tối của hệ thiết kế, đúng tông nhấn hồng, và đúng bộ
khối của story này (câu mồi + khối sự kiện có lịch). Không có khung nào khác
trong canvas dựng bề mặt này. Suy luận slug ở §2 do đó được ảnh dựng xác nhận,
không còn là suy luận chưa kiểm chứng.

**Khác biệt họ thiết bị — không ảnh hưởng kết luận.** Ảnh design là biến thể
`ios` và có device chrome (thanh trạng thái `9:41`, sóng/wifi/pin, home
indicator, chevron quay lại ở header). Ảnh implemented chụp qua
`CupidPlatform.material`, không device chrome, không nút quay lại (`canPop()`
là `false` khi dựng ở gốc cây) — cả ba điểm đã giải thích ở §4 và đều là tính
chất của harness chụp, không phải của sản phẩm. Không mục nào trong §5–§7 phụ
thuộc vào họ thiết bị: màu nền, thang chữ, bo góc, và tông nhấn hồng trùng nhau
giữa hai ảnh.

**Nội dung câu mồi khác nhau là do fixture**, không phải delta bố cục: ảnh
implemented dựng gói `Fixture starter 1..12`, ảnh design dùng câu mẫu biên tập.

**Kết quả:** so sánh ảnh trực tiếp **không** phát hiện thêm lỗi cài đặt nào
ngoài các mục đã liệt kê — không lệch lưới, không tràn chữ, không tofu, không
sai thang màu. Nó **xác nhận bằng mắt** cả 8 delta mà vòng 2026-09-17 mới chỉ
suy ra được từ DOM. Nhưng nó cũng cho thấy **cơ sở phân xử của 5 trong 8 mục
đó là lời văn spec chứ không phải AC** — sáu chỗ đó đi vào §7 và đã được người
dùng phân xử theo đường 1, xem dưới.

### 4b-2. Sau rework — so sánh trên ảnh P7 (2026-09-24)

Cùng hai tệp, **mở lại bằng mắt** sau khi P5/P6/P7 đã ship, lần này ảnh
implemented là bản chụp của P7 (`fa9c0ad5`). Ba mục dưới đây chép nguyên ý các
mục "Kiểm tra thị giác" đã viết trong `coding-plan/test-results.md` của từng
phase, cộng một lần đối chiếu hợp nhất của chính vòng này.

| Phase | Đã nhìn thấy gì trên ảnh | Nguồn |
| --- | --- | --- |
| P5 `ae908e93` | Thẻ hero mang caption `CÂU HÔM NAY` (mint, IN HOA, giãn chữ) trên câu hero cỡ `cardTitle` **đậm hơn hẳn** hai câu phụ; dưới đó caption `CÙNG CHỦ ĐỀ` muted rồi hai hộp bo góc nền `colorSurfaceAlt` — đúng tương quan canvas. Glyph `content_copy` rasterise đúng, không tofu. | `test-results.md` P5 §"Kiểm tra thị giác" |
| P6 `9ab00f48` | Glyph `refresh` mới thêm rasterise thành vòng tròn có mũi tên trong đĩa viền `colorLine` — **không ô tofu**, đây là rủi ro lớn nhất của phase và đã loại trừ bằng mắt chứ không bằng một lần chạy xanh. Nút đặc `Chép để nhắn` là dải gradient hồng-tím full-width kèm icon copy, đĩa refresh sát phải cùng hàng, dòng trấn an muted ngay dưới. | `test-results.md` P6 §"Kiểm tra thị giác" |
| P7 `fa9c0ad5` | Dòng lý do hiện đúng dưới dòng tên, cỡ `caption`, màu `colorTextMuted`: `Đúng dòng "thích đọc sách cũ" trong sổ tay` dưới `Sinh nhật bạn ấy — thứ Ba 20/10`. Chỗ dễ ra tofu nhất của phase (có cả ngoặc kép lẫn dấu tiếng Việt): **không ô tofu nào**. `Kỷ niệm quen nhau — thứ Hai 02/11` không có dòng lý do, đúng như gói fixture khai. Badge `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC` và icon lịch/`×` nguyên vẹn. | `test-results.md` P7 §"Kiểm tra thị giác" |

**Giới hạn fold của P6 đã được P7 gỡ.** P6 ghi lại rằng ô hỏi sổ tay chiếm nửa
dưới khung `415x900` và đẩy khối sự kiện xuống dưới fold, nên mục 5 và 6b lúc đó
**không đối chiếu được bằng mắt** và phải dựa vào bốn test widget. P6 đã thử nạp
thêm entry `NotebookKind.event` vào fixture chụp để ô hỏi rút lui — không tác
dụng; P7 thử lại, vẫn không. Cách hiệu quả là **chạm `ask-skip` trước khi chụp**
(§4, tham số `beforeCapture`): ô hỏi rút lui và khối sự kiện lên đúng vị trí
canvas vẽ. Từ P7, ảnh đối chiếu được trực tiếp với ảnh design **gồm cả mục 5 và
6b**, và mục này không còn khoảng trống bằng chứng nào phải trả cho test widget.

**Đối chiếu hợp nhất của vòng 2026-09-24.** Mở hai ảnh cạnh nhau lần nữa và soi
đúng sáu mục đã phân xử: caption hero mint IN HOA, câu hero đậm, nút đặc gradient
`Chép để nhắn` + đĩa `refresh` cùng hàng, dòng trấn an nguyên văn canvas, caption
`CÙNG CHỦ ĐỀ` + hai hộp phụ, tiêu đề khối `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC` kèm glyph
lịch, ngày gộp trong dòng tên (`— thứ Ba 20/10`, `— thứ Hai 02/11`, **không** còn
badge `dd/mm` leading), dòng lý do muted, pill `+ Thêm vào Muốn làm`. **Sáu trên
sáu khớp canvas.** Hai khác biệt còn lại **không** thuộc sáu mục đã phân xử và
được ghi thành D-1, D-2 ở §7b để vòng sau không mở lại như một lỗ fidelity.

## 5. Khớp với `ux/uiux-spec.md` §2 (nguồn ràng buộc)

> **Bảng dưới là ảnh chụp của vòng 2026-09-17**, đối chiếu với lời văn
> `uiux-spec.md` §2 **trước khi** nó được vá. Phán quyết neo-thiết-kế đã đổi
> chính nguồn ràng buộc: `uiux-spec.md` §2/§5 được vá theo canvas ở `06dc96a4`
> (quyền của Tech Lead/Scrum Master, không phải của lane Mobile), và bản dựng
> được sửa theo canvas ở P5/P6/P7. Bốn hàng dưới đây vì vậy **đã bị thay thế**
> và phải đọc ở §7, không đọc ở đây: "đúng 3 câu, mỗi câu một dòng độc lập"
> (nay là một hero + hai câu phụ), "text button nhãn Xem câu khác" (nay là nút
> đặc `Chép để nhắn` + đĩa `refresh`), "tiêu đề phụ Sự kiện có lịch" + pill
> "Thêm vào kho" (nay là `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC` + `Thêm vào Muốn làm`), và
> "badge ngày dd/mm leading" (nay ngày gộp trong dòng tên). Các hàng còn lại —
> header, vùng chạm ≥44, không danh sách "đã copy/đã lưu", ô hỏi tại chỗ + "Bỏ
> qua", divider mảnh, icon-button `close` ≥44, không spinner/skeleton/banner
> mạng/nhãn "AI gợi ý" — **vẫn đúng nguyên trên bản dựng P7**, đã soi lại bằng
> mắt ở §4b-2.

Đối chiếu từng mục, từ trên xuống:

| uiux-spec §2 | Trong ảnh | Kết luận |
| --- | --- | --- |
| 1. Header: nút quay lại + tiêu đề "Mồi chuyện" | tiêu đề `Mồi chuyện` ở `CupidHeader`; nút quay lại có điều kiện `canPop` | khớp |
| 2. Đúng 3 câu, mỗi câu một dòng độc lập, text trái + icon `content_copy` biến thể line bên phải, vùng chạm ≥44 | 3 dòng `Fixture starter 2/3/1`, icon copy phải, `kStarterCopyTapTarget = 44` | khớp |
| 2. Dưới 3 câu: text button không nền đặc, nhãn "Xem câu khác" | `Xem câu khác` chữ hồng, không nền | khớp |
| 2. Không có danh sách "đã copy"/"đã lưu"/"yêu thích" | không có | khớp |
| 3. Ô hỏi tại chỗ ngay dưới khối Bản A, có nút "Bỏ qua" cùng khối | khối `Người ấy hợp gu ăn uống kiểu nào?` + 6 lựa chọn + `Bỏ qua` | khớp |
| 4. Divider mảnh (`--r-sm`), không phải đường kẻ nặng | `Divider(height: 0, color: colors.colorLine)` trong `Padding(vertical: sm)` | khớp |
| 5. Tiêu đề phụ "Sự kiện có lịch" | có | khớp |
| 5. Hàng sự kiện: badge ngày dd/mm leading | `20/10`, `02/11` | khớp |
| 5. Giữa: tên sự kiện `body 17pt` | `Sinh nhật bạn ấy`, `Kỷ niệm quen nhau` | khớp |
| 5. Trailing: pill nhỏ nền `--pink`, nhãn "Thêm vào kho", cao 44, không full-width | có | khớp |
| 5. Cạnh đó: icon-button `close` biến thể line ≥44 | có | khớp |
| 3 (trạng thái rỗng) | không nằm trong ảnh này; có test riêng cho dòng "Chưa có sự kiện nào sắp tới" | khớp qua test |
| 4. Không spinner/skeleton/banner mạng/nhãn "AI gợi ý" | không có phần tử nào loại đó | khớp |

Không có delta nào cần sửa so với `uiux-spec.md`.

## 6. DESIGN_SPEC_CONFLICT — khung canvas mâu thuẫn với artifact ràng buộc

Khung `(6) Mồi chuyện A / A+` có trước các AC của story. Các điểm dưới đây
**không** phải lỗi cài đặt.

> **Đính chính 2026-09-20 — cơ sở phân xử.** Bản 2026-09-17 của mục này viết
> "ở đâu canvas và spec lệch nhau thì AC thắng" rồi xử **cả 8 mục** theo
> `ux/uiux-spec.md`. Điều đó không đúng với phán quyết đã chốt ở cấp
> requirement: `req_master.md` (mục A-1..A-4, B-1, D-1/D-2/D-3) ghi người dùng
> chọn **"anchor on design"** — canvas neo **trên lời văn của `uiux-spec.md`**,
> và **chỉ** AC mới đè được canvas. Nên phải tách đôi:
>
> - **(a) Có AC chống lưng** → canvas thua, cài đặt giữ nguyên: mục 1, 6 (nửa
>   nút bỏ qua), 8. Đã kiểm nguyên văn AC, xem dưới.
> - **(b) Chỉ có lời văn spec chống lưng** → theo phán quyết neo-thiết-kế thì
>   **canvas thắng**, và việc sửa là phạm vi implementation mới. Báo cáo này
>   **không tự phân xử** các mục đó; chúng được gom vào §7 để Scrum Master và
>   người dùng quyết: mục 2, 3, 4, 5, 6 (nửa badge ngày), 7.
>
> Không mục nào trong (b) được "sửa về phía canvas" trước khi có phán quyết.

> **Cập nhật 2026-09-24 — phán quyết đã có, sáu mục (b) đã ship.** Mỗi mục dưới
> đây mang thêm một dòng `**Đang cài (2026-09-24):**` mô tả đúng thứ đang chạy
> trên bản dựng P7. Câu "Cài đặt:" ngay trên nó là trạng thái **lịch sử** của
> vòng 2026-09-17, giữ lại để đọc được mạch phân xử, **không** phải mô tả bản
> hiện tại. Ba mục (a) — 1, 6 (nửa nút bỏ qua), 8 — không đổi.

1. **Ba tab đầu màn.** Canvas vẽ `Câu để nhắn` / `Tuần này có gì` / `Đoán thử`.
   Ghi chú của chính canvas (dòng 1449) nói tab thứ ba là trò "đoán" và
   `Bản B feed tin thật đã cắt sang REQ-014`. `uiux-spec.md` §1 mô tả màn (6)
   là một destination phẳng theo bố cục §2, không tab. Cài đặt: không tab.
   → **(a) có AC chống lưng.** Nguyên văn **AC-19**: "không tồn tại feed tin
   thật, tin nóng theo ngày... bản B nằm ngoài phạm vi và **không có phiên bản
   rút gọn ở đây**" — tab `Tuần này có gì` chính là bề mặt đó. Tab `Đoán thử`
   không có AC nào của story này phủ. Kết luận giữ nguyên, nhưng căn cứ là
   AC-19 chứ không phải `uiux-spec.md` §1.
2. **Một câu "hero" + cặp phụ.** Canvas chia `CÂU HÔM NAY` (một câu lớn, có
   nhãn `Chép để nhắn` và icon `refresh`) rồi `CÙNG CHỦ ĐỀ` (hai câu nhỏ hơn).
   `uiux-spec.md` §2.2 đòi "đúng **3 câu** mỗi lượt" và "mỗi câu là một **dòng
   độc lập**". Cài đặt: ba dòng ngang hàng.
   → **(b) KHÔNG có AC chống lưng — và có AC nói ngược lại.** Nguyên văn
   **AC-28**: "số câu hiển thị mỗi lượt là **tham số bố cục**"; **AC-27**/R-15b
   chỉ cấm suy AC ra từ N. Đã grep `requirements.md`: **không** AC nào chứa
   "3 câu"/"ba câu". Vậy "đúng 3 câu, mỗi câu một dòng" thuần là lời văn
   `uiux-spec.md` §2.2, đúng loại tranh chấp mà phán quyết neo-thiết-kế xử cho
   canvas. Đây là mục nặng nhất trong §7.
   → **Đang cài (2026-09-24):** đã dựng theo canvas ở **P5 `ae908e93`** — một
   thẻ hero mang caption `CÂU HÔM NAY` cộng caption `CÙNG CHỦ ĐỀ` với tối đa hai
   câu phụ. N = 1 không caption và không hộp rỗng; N = 2 đúng một câu phụ
   (AC-28 giữ nguyên, N vẫn là tham số bố cục).
3. **Nhãn chữ cạnh nút copy và nút `refresh`.** Canvas dùng `Chép để nhắn` +
   icon `refresh`. `uiux-spec.md` §2.2 đòi nút icon copy trần và **một text
   button nhãn "Xem câu khác"**. Cài đặt theo spec. (Phase P4 §3 có chỗ gọi nút
   này là "Gợi ý khác"; `uiux-spec.md` và `requirements.md` thắng, xem
   `coding-plan/test-results.md` mục Phase P4.)
   → **(b) KHÔNG có AC chống lưng.** **AC-2** chỉ đòi "copy được câu đó để đi
   nhắn"; **AC-4** chỉ đòi có đường ra bộ câu tiếp theo. Cả hai đều được thoả
   bởi bố cục canvas (`Chép để nhắn` + `refresh`) y như bởi bố cục đang cài.
   Nhãn và hình thức nút là lời văn spec.
   → **Đang cài (2026-09-24):** đã đổi theo canvas ở **P6 `9ab00f48`** — nút đặc
   gradient `Chép để nhắn` kèm icon copy, cộng nút tròn icon `refresh`
   (`0xe5d5`, tra bằng `fontTools getBestCmap()` thẳng trên font đang bundle).
   Text button `Xem câu khác` **biến mất khỏi thân màn** và chuyển thành nhãn
   `Semantics`; hai neo key `starter_line_copy_<id>` và `starter_next_round`
   giữ nguyên nên regression P4/P5 không mất điểm bám.
4. **Dòng trấn an "Câu này nhắn liền, không cần lưu. Quay lại là có câu khác."**
   Canvas có, spec không yêu cầu, và AC-27 cấm mọi thứ gợi ý "đã hết/còn lại".
   Không ship.
   → **(b) trích dẫn AC sai, đã đính chính.** Nguyên văn **AC-27** cấm thông
   báo "đã hết", màn ngõ cụt, và "chỉ báo tiến độ hay số mục còn lại". Dòng
   canvas không nói điều nào trong ba điều đó — "Quay lại là có câu khác" còn
   *hợp* với AC-4 (không ngõ cụt) và "không cần lưu" hợp với **AC-3** (không
   có kho "đã lưu"/"yêu thích"). Vậy AC-27 **không** chặn dòng này; giữ hay bỏ
   là quyết định lời văn, đưa vào §7.
   → **Đang cài (2026-09-24):** đã thêm theo canvas ở **P6 `9ab00f48`** — dòng
   trấn an muted nằm ngay dưới hàng CTA của thẻ hero, nguyên văn canvas. Có test
   khẳng định thứ tự dọc (`getBottomLeft` của CTA so với `getTopLeft` của dòng).
5. **Nhãn khối sự kiện.** Canvas: `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC` + nút
   `Thêm vào Muốn làm`. Spec §2.5: tiêu đề phụ `Sự kiện có lịch` + nút
   `Thêm vào kho`. Cài đặt theo spec.
   → **(b) KHÔNG có AC chống lưng.** Đã grep `requirements.md`: không AC nào
   chứa chuỗi `Thêm vào kho` hay quy định tiêu đề khối sự kiện. Thuần lời văn.
   → **Đang cài (2026-09-24):** đã đổi theo canvas ở **P6 `9ab00f48`** — tiêu đề
   khối là `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC` (kèm glyph lịch) và pill là
   `Thêm vào Muốn làm`. Hai nhãn cũ `Sự kiện có lịch` / `Thêm vào kho của tôi`
   **không còn tồn tại** trên màn, có test khẳng định chúng biến mất. Hành vi
   không đổi: pill vẫn tạo thẻ `conversationStarter` rồi bỏ dòng đi. Mục này đã
   được **nhìn thấy trực tiếp trên ảnh từ P7** (xem §4b-2), không còn phải dựa
   vào test widget như ở P6.
6. **Badge ngày dd/mm và nút bỏ qua.** Canvas viết ngày lẫn trong tên sự kiện
   (`Hội sách cũ phố Đinh Lễ — thứ Bảy này`) và **không** có nút bỏ qua. Spec
   §2.5 đòi badge `dd/mm` leading, và AC-14 đòi nút bỏ qua xoá ngay không hộp
   thoại. Cài đặt theo spec/AC.
   → **tách đôi.** Nút bỏ qua: **(a)**, nguyên văn **AC-14** — "có đường bỏ qua
   sạch, một chạm, không hỏi lý do" — canvas thiếu nó, AC thắng, giữ nguyên.
   Badge `dd/mm` leading: **(b)**, chỉ `uiux-spec.md` §2.5 đòi, không AC nào
   quy định chỗ đặt ngày; canvas viết ngày lẫn trong tên sự kiện.
   → **Đang cài (2026-09-24), nửa badge:** đã đổi theo canvas ở
   **P6 `9ab00f48`** — **không còn** badge `dd/mm` leading; key
   `starter_event_date_<id>` đã biến mất và ngày nằm trong chính dòng tên:
   `Sinh nhật bạn ấy — thứ Ba 20/10`, `Kỷ niệm quen nhau — thứ Hai 02/11`. Dùng
   dạng **tuyệt đối** (`thứ Ba 20/10`) chứ không tương đối (`thứ Bảy này` như
   canvas viết): `eventDateLabel` là hàm thuần của chuỗi `YYYY-MM-DD` mà gói
   ship, không đọc đồng hồ, nên nhãn không thể lệch khỏi ngày thẻ đang mang.
   → **Nửa nút bỏ qua không đổi:** `×` vẫn còn, AC-14 vẫn thắng canvas.
7. **Dòng lý do dưới tên sự kiện** (`Đúng dòng "thích đọc sách cũ" trong sổ
   tay`). Canvas có; spec §2.5 không mô tả trường này và schema gói sự kiện
   không mang nó. Không ship — đây là thay đổi content package, không phải
   thay đổi widget của P4.
   → **(b) KHÔNG có AC chống lưng.** Không AC nào đòi hay cấm dòng lý do. Lập
   luận "không ship vì schema gói không mang trường này" là lập luận **chi
   phí**, không phải lập luận AC — và STORY-001 B-1 là tiền lệ cho thấy người
   dùng có thể chọn "mở rộng phạm vi" đúng loại chi phí đó.
   → **Đang cài (2026-09-24):** **đã ship** theo canvas ở **P7 `fa9c0ad5`** —
   người dùng đúng là đã chọn mở rộng phạm vi, y như tiền lệ STORY-001 B-1. Gói
   sự kiện nhận thêm **hai khoá tuỳ chọn** `reason_template` /
   `reason_context_slot` (giữ nguyên `schema_id`, **không** đụng Drift, không
   đụng `schemaVersion`). `resolveEventReason` là hàm thuần khoá trên
   `stableContentKey('$today|$eventId')` — cùng phép FNV-1a `StarterSelector`
   dùng, nên AC-17 vẫn chỉ có một quy tắc. Trên ảnh:
   `Đúng dòng "thích đọc sách cũ" trong sổ tay` dưới `Sinh nhật bạn ấy — thứ Ba
   20/10`; sổ tay rỗng, giá trị rỗng, hoặc sự kiện không khai template thì
   **không** dựng dòng và **không** dựng ngoặc trống. Cổng nội dung nhận ba luật
   mới, trong đó `event_reason_asks_question` bắt đúng chiều ngược: dòng lý do là
   chuỗi hiển thị **duy nhất** không được kết thúc bằng dấu hỏi.
8. **Không có ô hỏi tại chỗ trong canvas.** Spec §2.3 + AC-6 đòi có. Cài đặt
   có, dùng nguyên `AskOnTheSpotSlot` của STORY-004.
   → **(a) có AC chống lưng.** Nguyên văn **AC-6**: "hỏi tại chỗ **đúng một
   câu** theo cơ chế của STORY-004"; **AC-7** quy định đường bỏ qua của ô này.
   AC thắng canvas, giữ nguyên.

## 7. Phán quyết neo-thiết-kế — ĐÃ ĐÓNG, sáu mục đã ship

Mục này mở ra ngày 2026-09-20 sau khi có ảnh design reference, với sáu chỗ
(5 mục + nửa mục 6) **không có AC chống lưng** và ba đường đi đề xuất cho Scrum
Master. **Người dùng chọn đường 1 — "Neo thiết kế"** — nhất quán với A-1..A-4
trong `req_master.md` ("anchor on design" cho REQ-016). Tech Lead bóc thành ba
phase rework, cả ba đã ship, và `ux/uiux-spec.md` §2/§5 đã được vá cho khớp
canvas ở `06dc96a4`. Không còn mục nào chờ phán quyết, nên cờ đầu tệp là
`DESIGN_ANCHOR_ADJUDICATION_REQUIRED: NO`.

| # | Canvas vẽ | Đã cài (bản dựng P7) | Phase / commit | Trạng thái |
| --- | --- | --- | --- | --- |
| 2 | `CÂU HÔM NAY` một câu hero + `CÙNG CHỦ ĐỀ` hai câu phụ | thẻ hero + caption `CÙNG CHỦ ĐỀ` + tối đa hai câu phụ; N = 1 không caption, không hộp rỗng | P5 `ae908e93` | **RESOLVED** |
| 3 | nút đặc `Chép để nhắn` + icon `refresh` tròn | nút đặc gradient `Chép để nhắn` + đĩa `refresh` (`0xe5d5`); `Xem câu khác` chuyển vào `Semantics` | P6 `9ab00f48` | **RESOLVED** |
| 4 | dòng "Câu này nhắn liền, không cần lưu. Quay lại là có câu khác." | đúng dòng đó, muted, ngay dưới hàng CTA của hero | P6 `9ab00f48` | **RESOLVED** |
| 5 | `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC` + `Thêm vào Muốn làm` | đúng hai nhãn đó; nhãn cũ biến mất khỏi màn | P6 `9ab00f48` | **RESOLVED** |
| 6b | ngày viết lẫn trong tên sự kiện | ngày gộp vào dòng tên (`— thứ Ba 20/10`); hết badge `dd/mm` leading, hết key `starter_event_date_<id>` | P6 `9ab00f48` | **RESOLVED** |
| 7 | dòng lý do dưới tên sự kiện ("Đúng dòng ... trong sổ tay") | dòng lý do caption muted dưới dòng tên, dựng từ hai khoá **tuỳ chọn** mới của gói sự kiện | P7 `fa9c0ad5` | **RESOLVED** |

Ba mục **(a)** của §6 — 1 (không tab, AC-19), 6 nửa nút bỏ qua (AC-14), 8 (ô hỏi
tại chỗ, AC-6/AC-7) — giữ nguyên: ở đó AC đè canvas, và rework **không** đụng
vào chúng.

Cả sáu mục đã được **nhìn thấy trực tiếp trên ảnh** ở §4b-2, không mục nào chỉ
có bằng chứng gián tiếp qua test widget.

## 7b. Hai delta canvas còn lại — có theo dõi, không phải khuyết tật

Hai điểm dưới đây khác canvas nhưng **không** nằm trong sáu mục đã phân xử và
**không** được mở lại như một lỗ fidelity ở vòng sau. Ghi ở đây theo đúng
Reviewer `review-report.md` §6 (D-1, D-2), cùng số hiệu để tra chéo được.

- **D-1 — vỏ của khối sự kiện.** Canvas vẽ khối sự kiện thành một thẻ **viền
  đứt** với nút `+ Thêm vào Muốn làm` **full-width** bên dưới. Bản dựng dùng một
  divider mảnh rồi một hàng có pill ở cuối dòng cộng nút `×`. Đây **không** phải
  một trong sáu mục được phân xử (mục 5 chỉ nói về *nhãn*), và bản thân nút `×`
  do AC-14 chống lưng, nên hình dạng hàng một phần là do AC quy định chứ không
  phải do bỏ sót canvas. Có sẵn từ P4, rework không làm nó tệ hơn.
- **D-2 — chrome của canvas không có trong bản dựng.** Chevron quay lại, thanh
  trạng thái iOS (`9:41`, sóng/wifi/pin, home indicator) và dải tab
  `Câu để nhắn / Tuần này có gì / Đoán thử` đều chỉ có ở ảnh design. Chevron và
  device chrome đã giải thích ở §4/§4b là **tính chất của harness chụp**, không
  phải của sản phẩm. Dải tab đã xử ở §6 mục 1: `Tuần này có gì` bị **AC-19** loại
  ("bản B nằm ngoài phạm vi và không có phiên bản rút gọn ở đây"), còn `Đoán thử`
  là SB-144/145/146, ghi rõ **ngoài phạm vi** trong `story_master.md`.

Cả hai **chỉ ghi nhận, không hành động** trong story này.

## 8. Vì sao verdict là PASS

`VISUAL_FIDELITY: PASS` ở đây đo **tính đúng của cài đặt**, và so sánh ảnh trực
tiếp — cả vòng 2026-09-20 lẫn vòng trên ảnh P7 ở §4b-2 — không tìm ra lỗi cài
đặt nào: màn dựng đúng, không lệch lưới, không tràn chữ, không tofu, đúng thang
màu, và khớp **toàn bộ** ràng buộc có hiệu lực (`ux/uiux-spec.md` §2/§5 sau khi
vá ở `06dc96a4`, cộng AC-6/AC-7/AC-14/AC-19 ở §6).

Bản 2026-09-17 giữ PASS **kèm** cờ `DESIGN_ANCHOR_ADJUDICATION_REQUIRED: YES`,
vì thứ còn mở khi đó là **câu hỏi phán quyết** giữa canvas và lời văn spec, chứ
không phải khuyết tật của bản dựng. Câu cuối của bản đó tự đặt điều kiện: *"Nếu
người dùng chọn đường 1 ở §7, mục này phải được mở lại cùng phase rework."*

Điều kiện đó đã xảy ra và **đã được thực hiện**: đường 1 được chọn, P5/P6/P7 ship
cả sáu mục, ảnh được chụp lại ở từng phase, và vòng 2026-09-24 này mở lại chính
báo cáo để neo §1/§4b trên ảnh P7, sửa §6 theo thứ đang chạy, viết lại §7 thành
bảng đã phân xử, và ghi D-1/D-2 vào §7b. Verdict không đổi — **PASS** — nhưng
bây giờ nó đứng trên bản dựng hiện tại chứ không phải bản trước rework, và cờ
phân xử chuyển về `NO`.

Vòng vá này **không đụng một dòng mã nào**, không chụp lại ảnh, không dùng thiết
bị: chỉ sửa chính tệp báo cáo này.
