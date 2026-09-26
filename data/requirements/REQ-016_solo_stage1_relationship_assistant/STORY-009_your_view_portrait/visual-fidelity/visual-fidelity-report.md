VISUAL_FIDELITY: PASS
Design-Screen: 8-chan-dung-theo-cach-ban-nhin

# STORY-009 — Chân dung "theo cách BẠN nhìn", visual fidelity

- Story: REQ-016 / STORY-009, phase P4 (màn chân dung) + P5 (cửa vào)
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Date: 2026-09-17 (vá F-1 của `review/review-report.md`)

## Screens under audit

| Design screen id | Platform | Design reference | Implemented |
| --- | --- | --- | --- |
| `8-chan-dung-theo-cach-ban-nhin` (trạng thái hỏi) | ios | `design-reference-8-chan-dung-theo-cach-ban-nhin-ios.png` (415x900) | `implemented-8-chan-dung-theo-cach-ban-nhin-cau-hoi-md.png` (415x900) và `runtime-smoke-portrait-first-question-emulator-5554.png` (1080x2400, app thật trên thiết bị) |
| `8-chan-dung-theo-cach-ban-nhin` (trạng thái kết quả) | ios | cùng reference — canvas không vẽ riêng trang kết quả | `implemented-8-chan-dung-theo-cach-ban-nhin-ket-qua-md.png` (415x900) |

Design source resolution: `data/devops/system/design-fidelity-config.json` khoá
`design_source` ở `cupid-app` (`locked: true`, `ui_surface: true`), nhưng bề mặt
mang story này là `cupid-ch-ng-1` (entry `Cupid Chặng 1.dc.html`,
`platforms: ["ios"]`, `screens_from: "frames"`). Vì project khai 4 design source
dùng chung một thư mục bundle, công cụ đòi `--surface` đích danh. Danh sách frame
được liệt kê bằng `--list-screens`, và `8-chan-dung-theo-cach-ban-nhin` là frame
duy nhất vẽ bề mặt của story này.

Lệnh render (chạy lại được nguyên văn, từ gốc worktree):

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --surface=cupid-ch-ng-1 \
  --screen=8-chan-dung-theo-cach-ban-nhin \
  --out=data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-009_your_view_portrait/visual-fidelity
```

`story_master.md` không có dòng `Design-Screen:` và nằm ngoài WriteScope của
handoff này, nên id được ghi ở đầu file này và Scrum Master chép sang.

### Vì sao báo cáo này đến sau phần hiện thực

Ở vòng chạy P4, `render-design-canvas.js` hỏng toàn repo vì thiếu
`node_modules` (`VISUAL_RUNTIME_MISSING`), nên chỉ có hai ảnh implemented được
sinh ra và bước so sánh bị bỏ trống — đó chính là F-1 của reviewer. DevOps đã sửa
công cụ; lần chạy ngày 2026-09-17 ở trên cho `DESIGN_CANVAS: OK ... 415x900`, và
phần còn thiếu được vá ở đây mà **không sửa một dòng mã sản phẩm nào**.

## Các ảnh implemented được tạo ra thế nào

Hai ảnh `implemented-*-md.png` là `RepaintBoundary.toImage` chụp trong chính
widget test của story, ở viewport tham chiếu iOS, pump `YourViewPortraitScreen`
thật (không phải harness thay thế) với `buildCupidTheme` thật, gói nội dung đọc
từ đĩa, và các font của pubspec cộng `MaterialIcons-Regular.otf` nạp qua
`FontLoader`. Nhóm test bị skip trừ khi bật dart-define, nên bộ test thường vẫn
hermetic.

Ảnh `runtime-smoke-*.png` là **screencap của app thật** trên `emulator-5554`,
lấy trong cùng lượt chạy với mục `## Story Runtime Startup Smoke` của
`coding-plan/test-results.md`. Chúng là bằng chứng mạnh hơn ảnh widget test: cùng
một bố cục, nhưng ở mật độ điểm ảnh và bộ font của thiết bị.

### Sai khác do harness, không phải lỗi sản phẩm

- Hai ảnh widget test chụp qua `CupidPlatform.material`, không phải `.ios`.
  `CupidHeader` bản iOS đặt một `BackdropFilter` đè lên chính tiêu đề của nó;
  chụp offscreen thì filter không có gì phía sau để lấy mẫu và làm bay mất
  header. Toàn bộ phần đang audit là platform-neutral.
- Không có thanh trạng thái iOS, không có home indicator: design reference có
  device chrome, một lần render widget trực tiếp thì không.
- Design reference là 415x900 (khung iOS của canvas); ảnh runtime là 1080x2400
  (khung Android của emulator). So sánh là so cấu trúc và token, không phải so
  từng điểm ảnh giữa hai khung khác kích thước.

Cả năm ảnh đều đã được **mở ra nhìn tận mắt**. Dấu tiếng Việt đủ và đúng ở mọi
nhãn, không ô tofu, icon ra glyph thật, không khung lỗi/đỏ/loading.

## Khớp với design

- Nền gradient tím-đen của `CupidAppBackground`, có lớp hạt sáng nhỏ
- Nhãn xuất xứ là một dải bo góc, viền ấm, icon `info` tròn bên trái, đặt ngay
  dưới header và **ngoài vùng cuộn** — đúng vai trò "dính đỉnh" mà canvas vẽ
- Thẻ câu hỏi: bề mặt `colorSurfaceAlt`, bo `radiusCard`, nhãn "Câu k/n" ở
  `caption` màu muted, câu hỏi ở heading semibold
- Mỗi lựa chọn là một hàng bo `radiusButton`, viền `colorLine`, đổi sang viền
  hồng khi chọn — đúng cách canvas vẽ lựa chọn đang chọn
- Ô tự viết là hàng cuối cùng của danh sách, cùng hình dạng, chữ placeholder muted
- CTA chính là pill gradient hồng-tím ở chân màn, có glow
- "Bỏ qua" là hành động chữ nằm ngang hàng với CTA (canvas đặt nó trong header
  thẻ; xem mục 4 bên dưới)
- Trang kết quả: mỗi phần là một thẻ riêng, đóng bằng một khối "Câu để hỏi" có
  icon `?` — không điểm số, không xếp hạng, không phần trăm

## Authority note

Chỗ nào canvas và artifact ràng buộc của story nói khác nhau thì AC trong
`requirements/requirements.md` thắng — đó là thứ story bị gate, còn frame canvas
có trước chúng. Các mục dưới đây là trường hợp đó, ghi là
`DESIGN_SPEC_CONFLICT`: chúng **không** phải khoảng trống hiện thực và không được
"sửa" về phía canvas nếu không có phán quyết của người dùng.

## DESIGN_SPEC_CONFLICT — canvas trái với yêu cầu ràng buộc

1. **Thanh tiến độ dưới nhãn "CÂU 3 / 8".** Canvas vẽ một vạch gradient chạy
   ngang, tức một chỉ báo phần trăm hoàn thành. AC-26/AC-28 cấm mọi đo lường,
   tiến độ và huy hiệu hoàn thành. Bản hiện thực giữ nhãn "Câu k/n" (được phép
   đích danh, chỉ trong phiên hiện tại, theo phase P4 mục 3 và `uiux-spec` 2.2)
   và bỏ hẳn vạch. Có test khẳng định điều này:
   `carries no measure, no progress and no completion badge (AC-12, AC-26, AC-28)`.
2. **Khối mở đầu "Bạn đang hình dung Cún thế nào?" + "8 câu, bạn trả lời thay
   Cún…".** Câu phụ này **đóng cứng số câu** vào chuỗi khung. BR-16/R-15b nói
   không mã nào được suy ra hay khai N, và AC-34 đặt N là thuộc tính dữ liệu của
   gói. Ship câu này nghĩa là mỗi lần gói đổi số mục thì màn nói sai. Không ship.
3. **Tên riêng "Cún" trong mọi chuỗi của canvas.** Chặng 1 là chế độ một mình:
   app chưa có tên người kia, và AC-35 cấm app tự khẳng định về người ấy. Bản
   hiện thực dùng "người ấy" ở mọi chỗ canvas dùng "Cún".
4. **"bỏ qua được" nằm trong header thẻ câu hỏi.** AC-25 đòi bỏ qua *dễ với tới
   ngang* hành động đi tiếp. Đặt nó thành chữ mờ ở góc thẻ làm nó khó với hơn
   CTA. Bản hiện thực đưa "Bỏ qua" xuống cùng hàng với "Tiếp", và test
   `opens on the first question with the provenance line and a skip as reachable
   as the next action (AC-6, AC-25)` khẳng định hai nút có cùng `dy`.
5. **Ba lựa chọn cố định, không có ô tự viết.** AC-29/BR-15 đặt mọi nhãn vào gói
   nội dung đã ship và AC-34 đặt số lựa chọn là dữ liệu; câu 1 của gói thật có 5
   lựa chọn cộng ô tự viết. Số lựa chọn trên ảnh là dữ liệu, không phải hằng số
   thiết kế.
6. **Nhãn CTA "Câu tiếp nha".** Bản hiện thực dùng "Tiếp". Chuỗi nút thuộc `.arb`
   của lane này, còn `uiux-spec` 3.x là Source Of Truth cho chuỗi khung; canvas
   là bản nháp giọng điệu, không phải bản khoá chuỗi.

## DESIGN_DELTA_OPEN — cần phán quyết sản phẩm, không tự quyết ở đây

- **Chip trấn an ở chân thẻ câu hỏi**: canvas vẽ "Chỉ hỏi sở thích và sự kiện.
  App không bao giờ hỏi Cún trả lời tin nhắn nhanh hay chậm." Bản hiện thực
  không có nó. Đây là chỗ canvas **không** trái AC nào — nội dung này còn hợp ý
  AC-22 (ranh giới sổ tay) — nên theo luật design-anchor thì canvas lẽ ra thắng.
  Lý do chưa ship: BR-15/R-15a cấm mọi chuỗi đã soạn nằm trong `.dart`/`.arb`,
  mà lược đồ `portrait_questions.v1` hiện **không có trường nào** chứa dòng trấn
  an ở cấp bộ câu hỏi. Thêm nó là một thay đổi gói nội dung cộng lược đồ, phải
  qua Product Owner, không phải một sửa widget. Ghi ra đây để Scrum Master/
  Reviewer định tuyến, thay vì lặng lẽ cho qua.

Mục này không hạ `VISUAL_FIDELITY` xuống `FAIL`: toàn bộ cấu trúc, token, bố cục
và mọi thành phần tương tác của màn đều khớp canvas, và khoản còn lại là một dòng
nội dung thuần cần quyết định phạm vi.
