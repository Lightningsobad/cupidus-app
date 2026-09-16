VISUAL_FIDELITY: PASS
Design-Screen: 6-moi-chuyen-a-a (derived, not enumerated — see §2)

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
| `6-moi-chuyen-a-a` | `cupid-ch-ng-1` (`Cupid Chặng 1.dc.html`, `screens_from: "frames"`, `platforms: ["ios"]`) | **không dựng được** — xem §3 | `implemented-6-moi-chuyen-a-a-material.png` (415x900) |

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

## 3. Vì sao không có ảnh design reference

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

Khung `(6) Mồi chuyện A / A+` có trước các AC của story. Ở đâu canvas và
`ux/uiux-spec.md` + `requirements/requirements.md` lệch nhau thì AC thắng — đó
là thứ story bị gate. Các điểm dưới đây **không** phải lỗi cài đặt và không
được "sửa về phía canvas" nếu chưa có phán quyết của người dùng.

1. **Ba tab đầu màn.** Canvas vẽ `Câu để nhắn` / `Tuần này có gì` / `Đoán thử`.
   Ghi chú của chính canvas (dòng 1449) nói tab thứ ba là trò "đoán" và
   `Bản B feed tin thật đã cắt sang REQ-014`. `uiux-spec.md` §1 mô tả màn (6)
   là một destination phẳng theo bố cục §2, không tab. Cài đặt: không tab.
2. **Một câu "hero" + cặp phụ.** Canvas chia `CÂU HÔM NAY` (một câu lớn, có
   nhãn `Chép để nhắn` và icon `refresh`) rồi `CÙNG CHỦ ĐỀ` (hai câu nhỏ hơn).
   `uiux-spec.md` §2.2 đòi "đúng **3 câu** mỗi lượt" và "mỗi câu là một **dòng
   độc lập**". Cài đặt: ba dòng ngang hàng.
3. **Nhãn chữ cạnh nút copy và nút `refresh`.** Canvas dùng `Chép để nhắn` +
   icon `refresh`. `uiux-spec.md` §2.2 đòi nút icon copy trần và **một text
   button nhãn "Xem câu khác"**. Cài đặt theo spec. (Phase P4 §3 có chỗ gọi nút
   này là "Gợi ý khác"; `uiux-spec.md` và `requirements.md` thắng, xem
   `coding-plan/test-results.md` mục Phase P4.)
4. **Dòng trấn an "Câu này nhắn liền, không cần lưu. Quay lại là có câu khác."**
   Canvas có, spec không yêu cầu, và AC-27 cấm mọi thứ gợi ý "đã hết/còn lại".
   Không ship.
5. **Nhãn khối sự kiện.** Canvas: `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC` + nút
   `Thêm vào Muốn làm`. Spec §2.5: tiêu đề phụ `Sự kiện có lịch` + nút
   `Thêm vào kho`. Cài đặt theo spec.
6. **Badge ngày dd/mm và nút bỏ qua.** Canvas viết ngày lẫn trong tên sự kiện
   (`Hội sách cũ phố Đinh Lễ — thứ Bảy này`) và **không** có nút bỏ qua. Spec
   §2.5 đòi badge `dd/mm` leading, và AC-14 đòi nút bỏ qua xoá ngay không hộp
   thoại. Cài đặt theo spec/AC.
7. **Dòng lý do dưới tên sự kiện** (`Đúng dòng "thích đọc sách cũ" trong sổ
   tay`). Canvas có; spec §2.5 không mô tả trường này và schema gói sự kiện
   không mang nó. Không ship — đây là thay đổi content package, không phải
   thay đổi widget của P4.
8. **Không có ô hỏi tại chỗ trong canvas.** Spec §2.3 + AC-6 đòi có. Cài đặt
   có, dùng nguyên `AskOnTheSpotSlot` của STORY-004.
