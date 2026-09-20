VISUAL_FIDELITY: PASS
DESIGN_ANCHOR_ADJUDICATION_REQUIRED: YES (xem §7 — 5 mục, không phải lỗi cài đặt)
Design-Screen: 6-moi-chuyen-a-a (đã xác nhận bằng ảnh dựng, xem §2 và §4b)

# STORY-005 — "Mồi chuyện", visual fidelity (P4 màn hình + lối vào)

- Story: REQ-016 / STORY-005, phase P4
  (`coding-plan/phase-P4-screen-and-entry-point.md` §6, mục
  "Per-story visual fidelity: REQUIRED")
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Date: 2026-09-17

## 1. Ảnh đã chụp

| Design screen id | Design source | Design reference | Implemented |
| --- | --- | --- | --- |
| `6-moi-chuyen-a-a` | `cupid-ch-ng-1` (`Cupid Chặng 1.dc.html`, `screens_from: "frames"`, `platforms: ["ios"]`) | `design-reference-6-moi-chuyen-a-a-ios.png` (415x900) — dựng được ngày 2026-09-20, xem §3 | `implemented-6-moi-chuyen-a-a-material.png` (415x900) |

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

**Ảnh đã được mở ra nhìn bằng mắt.** Mọi chữ tiếng Việt lên đúng dấu
(`Mồi chuyện`, `Xem câu khác`, `Người ấy hợp gu ăn uống kiểu nào?`,
`Trà sữa ít đường`, `Bỏ qua`, `Sự kiện có lịch`, `Kỷ niệm quen nhau`,
`Thêm vào kho`), không có ô tofu. Glyph `content_copy` và `close` rasterise
đúng, không phải ô vuông.

## 4b. So sánh ảnh trực tiếp (2026-09-20)

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
đó là lời văn spec chứ không phải AC** — xem §7, phần này là thứ duy nhất còn
mở sau khi có ảnh.

## 5. Khớp với `ux/uiux-spec.md` §2 (nguồn ràng buộc)

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
3. **Nhãn chữ cạnh nút copy và nút `refresh`.** Canvas dùng `Chép để nhắn` +
   icon `refresh`. `uiux-spec.md` §2.2 đòi nút icon copy trần và **một text
   button nhãn "Xem câu khác"**. Cài đặt theo spec. (Phase P4 §3 có chỗ gọi nút
   này là "Gợi ý khác"; `uiux-spec.md` và `requirements.md` thắng, xem
   `coding-plan/test-results.md` mục Phase P4.)
   → **(b) KHÔNG có AC chống lưng.** **AC-2** chỉ đòi "copy được câu đó để đi
   nhắn"; **AC-4** chỉ đòi có đường ra bộ câu tiếp theo. Cả hai đều được thoả
   bởi bố cục canvas (`Chép để nhắn` + `refresh`) y như bởi bố cục đang cài.
   Nhãn và hình thức nút là lời văn spec.
4. **Dòng trấn an "Câu này nhắn liền, không cần lưu. Quay lại là có câu khác."**
   Canvas có, spec không yêu cầu, và AC-27 cấm mọi thứ gợi ý "đã hết/còn lại".
   Không ship.
   → **(b) trích dẫn AC sai, đã đính chính.** Nguyên văn **AC-27** cấm thông
   báo "đã hết", màn ngõ cụt, và "chỉ báo tiến độ hay số mục còn lại". Dòng
   canvas không nói điều nào trong ba điều đó — "Quay lại là có câu khác" còn
   *hợp* với AC-4 (không ngõ cụt) và "không cần lưu" hợp với **AC-3** (không
   có kho "đã lưu"/"yêu thích"). Vậy AC-27 **không** chặn dòng này; giữ hay bỏ
   là quyết định lời văn, đưa vào §7.
5. **Nhãn khối sự kiện.** Canvas: `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC` + nút
   `Thêm vào Muốn làm`. Spec §2.5: tiêu đề phụ `Sự kiện có lịch` + nút
   `Thêm vào kho`. Cài đặt theo spec.
   → **(b) KHÔNG có AC chống lưng.** Đã grep `requirements.md`: không AC nào
   chứa chuỗi `Thêm vào kho` hay quy định tiêu đề khối sự kiện. Thuần lời văn.
6. **Badge ngày dd/mm và nút bỏ qua.** Canvas viết ngày lẫn trong tên sự kiện
   (`Hội sách cũ phố Đinh Lễ — thứ Bảy này`) và **không** có nút bỏ qua. Spec
   §2.5 đòi badge `dd/mm` leading, và AC-14 đòi nút bỏ qua xoá ngay không hộp
   thoại. Cài đặt theo spec/AC.
   → **tách đôi.** Nút bỏ qua: **(a)**, nguyên văn **AC-14** — "có đường bỏ qua
   sạch, một chạm, không hỏi lý do" — canvas thiếu nó, AC thắng, giữ nguyên.
   Badge `dd/mm` leading: **(b)**, chỉ `uiux-spec.md` §2.5 đòi, không AC nào
   quy định chỗ đặt ngày; canvas viết ngày lẫn trong tên sự kiện.
7. **Dòng lý do dưới tên sự kiện** (`Đúng dòng "thích đọc sách cũ" trong sổ
   tay`). Canvas có; spec §2.5 không mô tả trường này và schema gói sự kiện
   không mang nó. Không ship — đây là thay đổi content package, không phải
   thay đổi widget của P4.
   → **(b) KHÔNG có AC chống lưng.** Không AC nào đòi hay cấm dòng lý do. Lập
   luận "không ship vì schema gói không mang trường này" là lập luận **chi
   phí**, không phải lập luận AC — và STORY-001 B-1 là tiền lệ cho thấy người
   dùng có thể chọn "mở rộng phạm vi" đúng loại chi phí đó.
8. **Không có ô hỏi tại chỗ trong canvas.** Spec §2.3 + AC-6 đòi có. Cài đặt
   có, dùng nguyên `AskOnTheSpotSlot` của STORY-004.
   → **(a) có AC chống lưng.** Nguyên văn **AC-6**: "hỏi tại chỗ **đúng một
   câu** theo cơ chế của STORY-004"; **AC-7** quy định đường bỏ qua của ô này.
   AC thắng canvas, giữ nguyên.

## 7. DESIGN_ANCHOR_ADJUDICATION_REQUIRED — 5 mục cần người dùng phán quyết

Mở ra sau khi có ảnh design reference, **không** phải lỗi cài đặt và **không**
phải việc mà lane Mobile được tự quyết. Căn cứ: `req_master.md` ghi người dùng
đã chọn **"anchor on design"** cho REQ-016 (A-1..A-4, D-1/D-2/D-3), nghĩa là
canvas neo trên lời văn `uiux-spec.md`; chỉ AC mới đè được canvas. Sáu chỗ dưới
đây (5 mục + nửa mục 6) **không có AC chống lưng**, nên bản 2026-09-17 xử cho
spec là tự phân xử sai thẩm quyền.

| # | Canvas vẽ | Đang cài | Nếu neo-thiết-kế thắng thì phải làm gì |
| --- | --- | --- | --- |
| 2 | `CÂU HÔM NAY` một câu hero + `CÙNG CHỦ ĐỀ` hai câu phụ | ba dòng ngang hàng | dựng lại phân cấp hero/phụ — **phạm vi implementation mới**, cần phase riêng |
| 3 | nút đặc `Chép để nhắn` + icon `refresh` tròn | icon copy trần + text button `Xem câu khác` | đổi affordance + nhãn; kéo theo test nhãn ở P1/P4 |
| 4 | dòng "Câu này nhắn liền, không cần lưu. Quay lại là có câu khác." | không có | thêm một dòng caption |
| 5 | `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC` + `Thêm vào Muốn làm` | `Sự kiện có lịch` + `Thêm vào kho` | đổi hai nhãn; kéo theo test nhãn |
| 6b | ngày viết lẫn trong tên sự kiện | badge `dd/mm` leading | bỏ badge, gộp ngày vào tên — **va với** yêu cầu badge ở `uiux-spec.md` §2.5 |
| 7 | dòng lý do dưới tên sự kiện ("Đúng dòng ... trong sổ tay") | không có | **thêm trường vào schema gói sự kiện** — phạm vi mới, cỡ như STORY-001 B-1 |

Ba đường đi cho Scrum Master, không tự chọn hộ:

1. **Neo thiết kế** (nhất quán với A-1..A-4): nhận 6 mục trên thành phạm vi
   rework, giao Tech Lead bóc phase, rồi vá `uiux-spec.md` §2 cho khớp canvas.
   Mục 2 và 7 là phạm vi implementation mới, không phải sửa câu chữ.
2. **Giữ nguyên** và ghi 6 mục thành **ngoại lệ đóng** của phán quyết
   neo-thiết-kế cho màn này, có lý do sản phẩm — khi đó phải vá `req_master.md`
   để vòng sau không mở lại, giống cách A-3 được đóng.
3. **Tách**: nhận mục nhãn rẻ (3, 4, 5) và đóng mục đắt (2, 6b, 7).

Trước khi rework bất kỳ mục nào, đọc lại nguyên văn AC — §6 vừa phải đính chính
một trích dẫn AC-27 sai của chính bản trước.

## 8. Vì sao verdict vẫn là PASS

`VISUAL_FIDELITY: PASS` ở đây đo **tính đúng của cài đặt**, và so sánh ảnh trực
tiếp không tìm ra lỗi cài đặt nào: màn dựng đúng, không lệch lưới, không tràn
chữ, không tofu, đúng thang màu, và khớp **toàn bộ** ràng buộc có hiệu lực
(`ux/uiux-spec.md` §2 ở §5, cộng AC-6/AC-7/AC-14/AC-19 ở §6). Thứ còn mở ở §7
là **câu hỏi phán quyết** giữa canvas và lời văn spec, không phải khuyết tật
của bản dựng — nên nó được gắn cờ
`DESIGN_ANCHOR_ADJUDICATION_REQUIRED: YES` ở đầu tệp thay vì bị nhét vào một
FAIL khiến story trông như có lỗi kỹ thuật. Nếu người dùng chọn đường 1 ở §7,
mục này phải được mở lại cùng phase rework.
