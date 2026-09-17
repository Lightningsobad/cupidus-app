VISUAL_FIDELITY: PASS
Design-Screen: 10-bang-tra-an-khop

# STORY-010 — Bảng tra ăn khớp, màn (10), visual fidelity

- Story: REQ-016 / STORY-010, phase P4
  (`coding-plan/phase-P4-entry-point-screen-and-label-capture.md` §7)
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Date: 2026-09-17

## Screens under audit

| Design screen id | Platform | Design reference | Implemented |
| --- | --- | --- | --- |
| `10-bang-tra-an-khop` | ios | `design-reference-10-bang-tra-an-khop-ios.png` (415x900) | `implemented-10-bang-tra-an-khop-md.png` (415x1900, full height) |
| `10-bang-tra-an-khop` (chưa có nhãn) | — | không có frame tương ứng | `implemented-10-bang-tra-an-khop-md-chua-co-nhan.png` (415x1900) |

Hậu tố `-md` là platform dựng thật của ảnh: bản dựng chụp ở Material, trong khi
frame tham chiếu của canvas chỉ có bản `ios`. Tên theo quy ước
`implemented-<screen>-<platform>[-<biến thể>].png` mà `verify-story-visual-fidelity-gate.sh`
nhận diện, và mà STORY-001/002/003/004/006 đã dùng.

Design source resolution: `data/devops/system/design-fidelity-config.json` khai
4 nguồn; surface mang màn này là `cupid-ch-ng-1` (entry `Cupid Chặng 1.dc.html`,
`screens_from: "frames"`, `platforms: ["ios"]`). Danh sách frame lấy bằng
`node .ai-team-bundle/runtime/tools/render-design-canvas.js --list-screens
--surface=cupid-ch-ng-1`, và `10-bang-tra-an-khop` là frame duy nhất vẽ màn
này. Lưu ý: `ux/uiux-spec.md` mở đầu bằng `DESIGN_SOURCE_NOT_DETECTED` —
tại thời điểm viết spec chưa dò ra nguồn thiết kế, nhưng nay frame có thật,
nên audit này so với frame chứ không chỉ so với luật đo được trong spec.

`story_master.md` không có dòng `Design-Screen:` và nằm ngoài write scope của
phase này; id được ghi tại đây để Scrum Master chép sang.

## Ảnh "implemented" được tạo thế nào — và vì sao không phải ảnh chụp thiết bị

Màn (10) khoá vị trí (AC-2/AC-3): không route gõ tay được, không mục menu/tab,
chỉ mở từ một dòng chữ cuối màn (5). Nó cũng chỉ hiện kết quả khi đã có nhãn
của cả hai bên trong một hệ, nên đưa nó lên màn thiết bị đòi hỏi seed dữ liệu
và một đường điều hướng mà phase này không sở hữu.

Vì vậy dùng đúng fallback đã thiết lập của repo cho một surface không tới được
(giống STORY-003 P3, STORY-006 P2, STORY-021): chụp `RepaintBoundary.toImage`
ngay trong widget test của story, dựng `CompatibilityLookupScreen` thật — không
phải harness thay thế — với `buildCupidTheme` thật, `CupidAppBackground`, gói
nội dung đọc thẳng từ đĩa, và 4 họ font trong pubspec cộng `MaterialIcons-
Regular.otf` của framework nạp qua `FontLoader`.

- Harness: `mobile/test/features/compatibility_lookup/compatibility_lookup_screen_test.dart`
  (`_loadDesignFonts`, `_captureScreen`, group `bằng chứng visual-fidelity`)
- Lệnh: `flutter test test/features/compatibility_lookup/compatibility_lookup_screen_test.dart --dart-define=CAPTURE_VISUALS=true`
- Không bật cờ thì 2 test chụp ảnh `skip`, nên suite thường ngày vẫn kín và
  không ghi file.
- Chụp ở platform Material chứ không phải iOS: `CupidHeader` bản iOS là một
  `BackdropFilter`, mà ảnh chụp offscreen không có nền phía sau để lấy mẫu,
  nên tiêu đề sẽ bị xoá trắng trong mọi bản chụp iOS.
- Viewport 415x1900 (không phải 415x900 như reference) để cả màn nằm trong một
  khung không bị cắt. Hệ quả: không so pixel-diff trực tiếp với reference được;
  audit dưới đây là so từng luật/khối.

Đã soi mắt cả hai ảnh: chữ tiếng Việt đủ dấu, không ô tofu, icon hiện đúng.

## Đối chiếu từng luật đo được (`ux/uiux-spec.md` §3)

| Luật | AC | Kết quả |
| --- | --- | --- |
| DẢI là **một chip nhãn văn bản tĩnh**, cấm thanh/vòng/gradient/sao | AC-16/AC-17 | PASS — pill "Khác nhịp, bù nhau", nền đặc một màu, không có thành phần nào trả lời được "đầy bao nhiêu phần" |
| Thứ tự cố định: DẢI → Chỗ dễ hợp → Chỗ dễ va → 1 hoạt động nên thử → 1 câu để hỏi | AC-19 | PASS — đúng thứ tự trong ảnh |
| "Chỗ dễ va" ngay sau "Chỗ dễ hợp", cùng container/cỡ chữ/độ đậm/bề rộng, khác **chỉ** ở icon | R-7 | PASS — hai khối đối xứng thị giác, cùng `--r-sm` full-width, khác icon đầu tiêu đề |
| "Chỗ dễ va" không bị gập accordion, không thu xuống caption, không tô nhạt | R-7 | PASS |
| Hành động phụ "Thêm vào kho của tôi" là outline chip, không tô đặc `--grad` | §3.4 | PASS |
| "1 câu để hỏi" khác tông, nền tách lớp, icon `help_outline` | AC-19 | PASS |
| Dòng xuất xứ "Dựa trên nhãn bạn đã nhập: …" ở đầu kết quả, kiểu STORY-009 §3 | — | PASS |
| Nhãn "đoán": icon nhỏ + chữ "bạn đang đoán", không đậm như trường đã xác nhận | AC-8 | PASS |
| Không hiện sẵn giá trị gợi ý/mặc định cho ô của người kia | AC-6 | PASS — xem `…-chua-co-nhan.png`: không chip nào được chọn sẵn |
| Sửa/xoá nhãn tại chỗ nhập | AC-9 | PASS — "Bỏ nhãn này" chỉ hiện trên thẻ đã có nhãn |
| "Bỏ qua, quay lại" trung tính, không trách móc | AC-10 | PASS |
| Không skeleton/spinner/"đang tra cứu…" | AC-28/AC-29 | PASS — trạng thái loading trả khung rỗng, không hiệu ứng suy nghĩ |
| Không %, sao, streak, đếm lần, "đã xem" | AC-30/AC-33 | PASS |
| Không ngôn ngữ tiên tri/vận mệnh ở khối DẢI | AC-32 | PASS |

## Chênh lệch so với design reference — và lý do

1. **Khối DẢI**: canvas vẽ "HAI ĐỨA HỢP TỚI ĐÂU" là một **thanh gradient có 3
   mốc** (cần cố gắng / vừa / rất hợp) với nhãn "khá hợp" ở đầu bên phải. Bản
   dựng **không** theo canvas ở điểm này: đó chính xác là hình khối mà
   AC-16/AC-17 và `ux/uiux-spec.md` §3.1 cấm tuyệt đối ("nếu component có thể
   trả lời câu 'cái này đầy bao nhiêu phần?', nó SAI"). Khi canvas và AC mâu
   thuẫn, AC thắng — đây là mục do AC chi phối, không phải tranh chấp
   spec-vs-canvas thuần tuý. **Cần UI/UX xử lý frame**: frame hiện tại đang mô
   tả một UI vi phạm AC của chính story.
2. **Dòng tự bạch của canvas** "Cố tình không hiện phần trăm. Một con số dễ làm
   người ta tin chắc quá sớm." đi kèm thanh đó nên cũng không dựng — nó giải
   thích một thành phần không tồn tại.
3. **Dòng chân bảng** "Bảng tra soạn sẵn, cố định. Không có gì học từ bạn, nên
   nó không biết nịnh bạn." — canvas có, spec không nhắc. Đã **thêm** theo
   canvas (`compat_static_table_note`), vì nó nói bằng lời đúng điều AC-28/
   AC-31 nói bằng code.
4. **Tiêu đề màn**: canvas dùng tên cặp ("Sư Tử × Cự Giải"); bản dựng dùng tiêu
   đề tĩnh "Bảng tra ăn khớp" cộng dòng xuất xứ. Lý do: AC-11 cho phép hai hệ
   nhãn cùng ra kết quả trong một màn, nên "tên cặp" không xác định được; dòng
   xuất xứ của spec §3.1 mang đúng thông tin đó cho từng hệ.
5. **Kiểu tiêu đề khối**: canvas dùng caption in hoa ("CHỖ DỄ HỢP"); bản dựng
   dùng tiêu đề phụ `600` sentence case theo spec §3.2/§3.3. Chênh lệch kiểu
   chữ thuần tuý, cả hai khối "hợp"/"va" vẫn đối xứng tuyệt đối với nhau.
6. **Hành động "1 hoạt động nên thử"**: canvas là nút `(+)` tròn icon-only; bản
   dựng là outline chip có chữ theo spec §3.4 ("text button/outline chip, body
   17pt/400"). Chip có chữ cũng dễ chạm và dễ đọc hơn icon-only.
7. **Thẻ nhập nhãn**: canvas chỉ vẽ trạng thái đã đủ nhãn nên không có chúng;
   bản dựng đặt chúng **dưới** kết quả theo spec §2 (hỏi-tại-chỗ khi thiếu
   nhãn) và AC-9 (sửa/xoá tại chỗ).
8. **Nút quay lại**: không thấy chevron trong ảnh vì màn được pump như `home`
   của harness nên `Navigator.canPop` là false. Trên luồng thật (push từ màn
   (5)) `CupidHeader` hiện nút quay lại; đường quay lại có test riêng
   (`compat_skip_back`, AC-4/AC-10).

## Deferred

- Frame `10-bang-tra-an-khop` trên canvas cần UI/UX sửa khối DẢI cho khớp
  AC-16/AC-17 (mục 1 ở trên). Không sửa được từ lane Mobile: canvas nằm ngoài
  write scope của phase này.
- So pixel-diff ở đúng 415x900 với reference: cần một màn cuộn được chia khung,
  chưa có công cụ trong repo cho surface không tới được.
