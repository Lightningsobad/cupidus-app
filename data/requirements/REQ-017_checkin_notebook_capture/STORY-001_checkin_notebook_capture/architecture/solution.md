# STORY-001_checkin_notebook_capture-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-09-28

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: khối hỏi phụ tuỳ chọn trên màn check-in 23h phải ghi được
  **một** mục vào kho sổ tay STORY-004 mà không bao giờ chặn đường lưu ảnh/nhật ký
  (BR-10), và mục đó phải là mục sổ tay bình thường có thêm **thuộc tính xuất xứ**
  (BR-11).
- Architectural invariants / non-goals: tất định, không AI, không API ngoài (R-7);
  câu nhật ký không bao giờ chảy sang sổ tay (BR-3); thẻ chỉ đọc (BR-6); không màn
  mới, không route mới, không điểm vào mới (BR-9); mọi câu chữ mới là dữ liệu có id
  bền qua cổng nhập (BR-5/R-15c).
- Proposed technical direction: ba mảnh cộng thêm, không mảnh nào đổi nghĩa dữ liệu
  cũ — (a) ba cột nullable trên `notebook_entries` + một đường ghi idempotent theo
  lần check-in trong `ContextNotebookRepository`; (b) một gói nội dung REQ-017 mới
  đi qua đúng cổng nhập của STORY-004; (c) một khối UI mới trong
  `evening_check_in_sheet.dart` và một dòng nhãn xuất xứ trong `_NotebookRow`.
- Why this fits: `ContextNotebookRepository.addEntry` đã là cửa ghi duy nhất vào
  `notebook_entries`, `ContextInlineAddRow` đã là component nhập-ý-kèm-loại, và
  `validateContextPacks` đã là cổng nhập nội dung. Story này cộng tham số vào ba
  chỗ đó thay vì mở cơ chế thứ hai.

### Key Discovery

- **KD-1 — `_save()` pop vô điều kiện làm UI lỗi/nhắc của khối phụ không tới được.**
  `evening_check_in_sheet.dart:377-392`: `_save()` `await route(...)` (mở
  `openJournalComposer`) rồi `navigator.pop()` không điều kiện. UX Phần A.4 và Phần
  B lại đòi người dùng **ở lại màn** để chọn loại đang thiếu ("không cần chạm CTA
  lần hai") và để bấm "Thử lại". Vậy `pop()` phải trở thành có điều kiện: pop khi
  khối phụ ở trạng thái đã ngã ngũ (trống, hoặc đã ghi xong), giữ màn khi khối đang
  chờ chọn loại hoặc vừa ghi lỗi. Nếu implement nguyên pop cũ, hai trạng thái AC-16
  và AC-12 là code không bao giờ chạy — cùng loại lỗi với gate bị đảo của STORY-012
  P10.
- **KD-2 — "đóng ngăn" không có biểu diễn nào trong dữ liệu.**
  `ActivityCardStatus` chỉ có `idea|scheduled|done|memory`
  (`mobile/lib/features/activity_cards/domain/activity_card.dart:8-12`), cả bốn đều
  đọc được. Trạng thái "không đọc được" thật sự duy nhất là `cardById()` trả `null`
  (thẻ bị xoá / khác owner) hoặc ném lỗi. Suy biến AC-9 phải bắt đúng hai điều kiện
  đó; **không** dò một trạng thái archived không tồn tại.
- **KD-3 — câu hỏi REQ-017 không vừa lược đồ `AskQuestion`.** `AskQuestion`
  (`context_content.dart:57-126`) bắt buộc đúng một `target` trong
  `notebook.interest|notebook.event|skill` và mang `chips`; câu hỏi REQ-017 cố ý
  **không** có target định trước (người dùng tự chọn loại — BR-4), còn nhãn xuất xứ
  và câu lỗi/thử lại không phải câu hỏi. Vì vậy câu chữ mới không thể là item của
  `req016.ask_questions.v1`; nó cần một gói em đi qua **cùng** cổng nhập.
- **KD-4 — segmented "chưa chọn" gần như đã có.** `ContextInlineAddRow` đã nhận
  `String? selectedOptionId` và `_InlineSegmented` đã vẽ `String? selectedId`; chỉ
  phần khởi tạo state (`context_inline_add_row.dart:86-88`) ép `null` về
  `options.first.id`. Trạng thái "không tô sẵn" của AC-3 là một cờ host + sửa đúng
  chỗ khởi tạo đó, không phải component mới.
- **KD-5 — không thêm giá trị vào `ContextEntrySource`.** Giữ enum hai giá trị
  `ask_on_the_spot|manual`; mục từ check-in vẫn là `ask_on_the_spot`, và dấu hiệu
  "đến từ check-in" là `originCheckInRef != null`. Nhờ vậy không `switch` nào của
  STORY-005/008/009/010 trên `ContextEntrySource` bị vỡ (BR-11).

## 3. Scope And Assumptions

- In Scope: `notebook_entries` (3 cột nullable + migration cộng thêm), đường ghi
  idempotent trong `ContextNotebookRepository`, gói nội dung `req017.checkin_capture.v1`
  + mở rộng `validateContextPacks`, khối hỏi phụ trong `evening_check_in_sheet.dart`,
  dòng nhãn xuất xứ trong `notebook_screen.dart`.
- Out Of Scope: mọi đường ghi thứ hai vào sổ tay, sửa mục trên màn check-in, cột/bảng
  cho nhiều mục một lần check-in, UI mới ở widget/thông báo, lọc-sắp xếp theo xuất xứ.
- Assumptions affecting design: A-5 (một ý + một loại) đã CONFIRMED 2026-09-27; OQ-1
  và OQ-2 đã RESOLVED cùng ngày (`../req_master.md` `## User Decisions`), nên không
  phạm vi nào của story bị chặn. `eveningCheckInOriginRef(cardId)` =
  `req016.evening_check_in.<cardId>` (`evening_check_in_sheet.dart:35-36`) là định
  danh lần check-in mà nhật ký đã dùng; story này dùng lại đúng khoá đó làm khoá
  idempotency thay vì phát minh khái niệm thứ hai.

### UI Delivery Anchor

- Design Scope Description: hai bề mặt sẵn có, không bề mặt mới. (1) Khối hỏi phụ
  là widget con mới **bên trong** `EveningCheckInSheet`, đặt sau block nhật ký và
  trước CTA/dòng trấn an, ngăn bằng divider mảnh. (2) Nhãn xuất xứ là một dòng
  `caption` mới bên trong `_NotebookRow` của `notebook_screen.dart`, ngay dưới dòng
  `entry.value`/`detail`, không phải chip/pill, không chạm được.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile` (app Flutter). Không lane backend, không thay đổi API.
- New or changed boundaries: `context_notebook` sở hữu cả lược đồ mục sổ tay, gói
  nội dung REQ-017, và logic suy biến nhãn xuất xứ. `phase_status` (màn check-in) là
  **phía gọi**: nó chỉ đưa ý + loại + `cardId` + `cardTitle` đã có sẵn trong tay
  xuống `context_notebook`, và không tự đọc thẻ thêm lần nào (BR-6).
- Shared patterns reused: `ContextNotebookRepository` là cửa ghi duy nhất;
  `validateContextPacks` là cổng nhập duy nhất; `ContextInlineAddRow` là component
  nhập-ý-kèm-loại duy nhất.

### Affected Modules

- Mobile: `core/database` (bảng + migration), `features/context_notebook`
  (domain/data/presentation), `features/phase_status/presentation`,
  `mobile/assets/data/req017`, `mobile/pubspec.yaml`.

### Contracts And Integrations

- Ba cột nullable cộng thêm vào `notebook_entries`: `origin_check_in_ref` (khoá
  idempotency của lần check-in), `origin_card_id` (đầu vào của phép dò tồn tại ở
  AC-9), `origin_card_title` (**ảnh chụp** tên thẻ lúc tạo, cho AC-5). Chỉ
  `ALTER TABLE ADD COLUMN`; `schemaVersion` +1 đọc từ giá trị thật trên nhánh tích
  hợp rồi cộng một — không chép số từ tài liệu.
- Idempotency: đường ghi từ check-in nhận `originCheckInRef` bắt buộc; nếu đã tồn
  tại hàng cùng `owner_key` + `origin_check_in_ref` thì **cập nhật** hàng đó thay vì
  chèn hàng mới (AC-8, BR-12). Hai lần check-in khác thẻ có hai ref khác nhau nên
  vẫn là hai mục hợp lệ.
- Tách lưu (BR-10): thất bại của phần sổ tay không bao giờ lan sang đường nhật ký.
  Ghi sổ tay chạy **trước** khi trao ảnh/câu nhật ký cho `openJournalComposer`; kết
  quả của nó chỉ điều khiển trạng thái cục bộ của khối phụ và điều kiện `pop()`
  (KD-1), không bao giờ chặn lời gọi journal.
- Suy biến nhãn (AC-9): tại lúc ghi, `cardTitle == null` → `origin_card_title` là
  `null`. Tại lúc đọc, nhãn dùng ảnh chụp **chỉ khi** `origin_card_id` còn dò được;
  `null`/lỗi đọc → "từ một buổi hẹn" (KD-2). Đổi tên thẻ về sau không đổi nhãn vì
  nhãn lấy từ ảnh chụp.
- Compatibility posture: mọi hàng cũ có ba cột `null` và hiển thị y như trước;
  `ContextEntrySource` không đổi (KD-5).

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| RS-1 Notebook local persistence write path | `core/database/tables/context_notebook_tables.dart` + `cupid_database.dart` | chỉ `ADD COLUMN`, `schemaVersion` +1 đọc từ nhánh tích hợp, cấm huỷ-tạo-lại | test migration/schema + test repository chèn & đọc ba cột mới | `MIGRATION_GATE_UNAVAILABLE` |
| RS-2 Check-in save flow separation (BR-10) | `features/phase_status/presentation/evening_check_in_sheet.dart` | ghi sổ tay chạy trước, lỗi chỉ đổi trạng thái khối phụ; `pop()` có điều kiện (KD-1) | widget test: journal route vẫn được gọi đúng một lần khi phần sổ tay lỗi hoặc thiếu loại | `WIDGET_TEST_GATE_UNAVAILABLE` |
| RS-3 Per-check-in idempotency (AC-8/BR-12) | `features/context_notebook/data/context_notebook_repository.dart` | khoá `owner_key` + `origin_check_in_ref`, ghi lặp là cập nhật | test: hai lần gọi cùng ref → đúng một hàng; hai ref khác → hai hàng | `UNIT_TEST_GATE_UNAVAILABLE` |
| RS-4 Content ingestion gate (AC-14/R-15c) | `features/context_notebook/domain/context_content_gate.dart` | gói REQ-017 đi qua `validateContextPacks`; luật vẫn chỉ sống trong Dart | test cổng nhập quét `assets/data/req017/` từ đĩa; gói vi phạm làm test đỏ | `CONTENT_GATE_UNAVAILABLE` |
| RS-5 Origin label degrade (AC-9/BR-6) | `features/context_notebook` (resolver nhãn xuất xứ) | dò tồn tại theo `origin_card_id`, chỉ đọc, lỗi đọc = suy biến | unit test resolver + widget test màn Sổ tay cho cả hai nhãn | `UNIT_TEST_GATE_UNAVAILABLE` |
| RS-6 Notebook consumer non-regression (BR-11, AC-10/AC-13) | `features/context_notebook/domain/context_notebook_models.dart` | không thêm giá trị enum, không đổi `entries()`; xuất xứ chỉ hiện trên hàng mục | widget test: bề mặt gợi ý quà và widget/thông báo không chứa nhãn xuất xứ | `WIDGET_TEST_GATE_UNAVAILABLE` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: toàn bộ P1-P4.
- Authoritative inputs: `../requirements/requirements.md`, file này, `../ux/uiux-spec.md`
  (chỉ Phần A-E khi phase trích dẫn).
- Guardrails: không mở đường ghi thứ hai vào `notebook_entries` ngoài
  `ContextNotebookRepository`; không đặt câu chữ mới vào ARB/l10n hay hằng Dart;
  không thêm giá trị vào `ContextEntrySource`; không thêm cột đo hành vi người kia;
  không sửa `_openFromPayload` để đọc thẻ lần thứ hai; không thêm route/điểm vào;
  không gắn đường dẫn ảnh check-in vào mục sổ tay.

## 5. Non-Functional Impact

- `schemaVersion` +1 làm đỏ mọi assertion đang chốt con số cũ; phase P1 phải sửa hết
  assertion đó trong cùng lần chạy, nếu không build gate của các phase sau bị khoá.
- Màn Sổ tay thêm một phép dò thẻ theo lô cho các `origin_card_id` phân biệt (một
  lượt cho cả màn), không phải một truy vấn mỗi hàng.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Ảnh chụp `origin_card_title` + dò tồn tại theo `origin_card_id` lúc đọc | AC-5 đòi nhãn giữ nguyên chữ như lúc tạo, AC-9 lại đòi suy biến khi thẻ bị xoá về sau | ACCEPTED | thoả cả hai theo đúng câu chữ: đổi tên thẻ không đổi nhãn, xoá thẻ thì suy biến |
| Giải tên thẻ lười (chỉ lưu `origin_card_id`, đọc tên lúc render) | ít cột hơn | REJECTED | đổi tên thẻ sẽ đổi chữ nhãn, trái UX Phần C "giữ nguyên chữ như lúc tạo" |
