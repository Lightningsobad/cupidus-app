# STORY-005_conversation_starters-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-09-11

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC-17/AC-18 (tất định, ngoại tuyến), AC-26..AC-30
  (nội dung là dữ liệu, N là thuộc tính dữ liệu), AC-29 (luật bất biến cưỡng
  chế ở cổng nhập chạy được), AC-11/AC-12 (ghi vào đúng kho thẻ STORY-001),
  AC-6..AC-9 (tái dùng nguyên cơ chế hỏi-tại-chỗ STORY-004).
- Architectural invariants / non-goals: không HTTP, không AI, không API nội
  dung trên mọi đường đi của story (R-7); không kho ngữ cảnh thứ hai; không
  danh sách thẻ thứ hai; không con trỏ xoay vòng xuống DB.
- Proposed technical direction: một feature module mobile-only
  `mobile/lib/features/conversation_starters/`, dựng trên đúng ba cơ chế đã
  giao — họ gói `ContentPackage` (STORY-001), `AskOnTheSpotSlot` +
  `ContextNotebookReader` (STORY-004), `ActivityCardRepository.createCard`
  (STORY-001). Hai gói nội dung mới, một bảng Drift trạng-thái nhỏ, một cổng
  nhập nội dung riêng của họ gói này.
- Why this fits: ba story trước đã dựng đủ hạ tầng; story này không mở boundary
  mới, chỉ thêm một feature tiêu thụ. **Không có lane backend** — xem Key
  Discovery 1.

### Key Discovery

1. **Không có lane backend, và không thể có.** Cả ba bề mặt story này chạm vào
   đều là in-process Dart + Drift cục bộ (STORY-001 §1, STORY-004 §1). AC-15/
   AC-16 cấm mọi lời gọi mạng trên đường đi này. Handoff ghi "shared (backend +
   mobile)"; ranh giới đúng là **mobile-only**. Một endpoint backend ở đây sẽ
   trực tiếp vi phạm AC-16.

2. **Lịch âm đã được giải, không phải bằng thuật toán.** `occasions.v1.json`
   (STORY-001) ship sẵn `dates: ["2026-02-17", "2027-02-06"]` cho Tết và
   `calendar: "lunar"` **chỉ là provenance** —
   `lib/features/activity_cards/domain/occasion_suggestion_service.dart:27-30`
   nói rõ không file nào quy đổi âm↔dương. Gói sự kiện của story này dùng đúng
   quy ước đó: **ngày dân dụng do người soạn nội dung chốt sẵn**. Đây là cách
   đọc AC-18 mà kiến trúc chọn — xem §3 Assumptions.

3. **Thêm một giá trị vào `InvariantRule` sẽ làm đỏ bốn cổng nhập đang chạy.**
   `gift_content_gate.dart:254`, và ba cổng chị em, ánh xạ hit của
   `invariantHitsIn()` về enum riêng bằng `firstWhere(...)` **không có
   `orElse`**. Rule R-1g mới vì vậy **không** được thêm vào `InvariantRule` và
   **không** được yield từ `invariantHitsIn()`; nó đi theo đúng tiền lệ
   `NotebookBoundaryRule` / `notebookBoundaryHitsIn()` — enum riêng, hàm riêng,
   cùng một file. Bỏ qua điểm này là một `StateError` runtime ở bốn feature
   không liên quan.

4. **Điểm vào đã tồn tại và đang ở trạng thái "Sắp có".**
   `QuickEntryCell.conversationStarters` đã có trong
   `quick_entry_strip.dart:15`; `_openQuickEntryCell`
   (`activity_card_hub_view.dart:232-252`) hiện bắn snackbar "Sắp có" cho mọi
   ô khác `giftIdeas`. Wiring điểm vào là sửa đúng nhánh `if` đó, không phải
   dựng dải lối-vào mới.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md`

## 3. Scope And Assumptions

- In Scope: feature module `conversation_starters` (domain/data/presentation),
  hai gói asset JSON mới, cổng nhập nội dung của họ gói này, một bảng Drift
  trạng-thái sự-kiện, và ba điểm chạm append-only vào code đã giao.
- Out Of Scope: mọi thứ phía backend; quy đổi lịch âm trong code; renderer
  preset của STORY-002 (đánh giá và **bác** — xem §6).
- Assumptions affecting design:
  - **A-1 (AC-18).** "Tính tất định trên thiết bị" được thoả bằng ngày dân dụng
    chốt sẵn trong gói dữ liệu, không bằng thuật toán quy đổi âm↔dương chạy lúc
    runtime. Ràng buộc AC-18 bảo vệ là *tất định + không lấy từ dịch vụ ngoài*;
    dữ liệu chốt sẵn thoả chặt hơn thuật toán (không có rủi ro sai năm nhuận),
    và giữ **một** nguồn sự thật cho ngày dịp trong toàn REQ-016. Nếu Reviewer
    hoặc PO đọc AC-18 theo nghĩa đen "phải có phép tính", đây là điểm cần một
    Design Ruling — không phải việc nhét thêm một thư viện lịch âm.
  - **A-2 (AC-5).** Riêng-hoá là **thay thế placeholder tất định**, không phải
    so khớp mờ: mục `contextual` khai báo `context_slot` và mang token `{value}`
    trong câu; renderer thay bằng `NotebookEntry.value` đọc qua
    `ContextNotebookReader`. Không heuristic, không tokenizer tiếng Việt, không
    mô hình.
  - **A-3 (AC-20/BR-8).** Luật R-1g cưỡng chế **trên mọi mục** của gói mồi,
    không có cờ dữ liệu kiểu `about_partner` để tắt. Một cờ như thế là đúng cái
    lỗ R-15c cảnh báo: CMS ngoài repo tự đặt cờ để thoát luật.

### UI Delivery Anchor

- Design Scope Description: một destination full-screen đẩy chồng từ tab Nhà
  (ô thứ 2 của `QuickEntryStrip`), nội dung một cột: header có nút quay lại →
  khối 3 dòng câu mồi mỗi dòng kèm icon-button copy → text button "Xem câu
  khác" → `AskOnTheSpotSlot` (có thể không render) → divider mảnh → danh sách
  hàng sự kiện có badge ngày dẫn đầu, pill "Thêm vào kho" và icon-button đóng ở
  trailing. Không bottom sheet, không tab, không danh sách cuộn dài cho khối
  câu mồi.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/lib/features/conversation_starters/`.
- New or changed boundaries: không boundary mới. Ba điểm chạm append-only vào
  code đã giao — `ActivityCardOrigin` (+1 giá trị), `_openQuickEntryCell`
  (+1 nhánh), `CupidDatabase` (+1 bảng, `schemaVersion` 6→7). Một điểm chạm mở
  rộng `core/content/invariant_terms.dart` theo mẫu enum-riêng/hàm-riêng
  (Key Discovery 3).
- Shared patterns reused or introduced: `ContentPackage`/`ContentPackageLoader`
  và mẫu `<feature>_content_gate.dart` (bốn tiền lệ đang chạy);
  `AskOnTheSpotSlot`; `createCard`; Cubit giữ con trỏ xoay vòng trong đúng một
  vòng đời màn (STORY-004 §6).

### Affected Modules

- Mobile: `features/conversation_starters` (mới),
  `features/activity_cards` (append-only), `core/content`, `core/database`,
  `assets/data/req016`.

### Contracts And Integrations

- Error, retry, timeout, idempotency, and empty-state contract: gói nội dung
  hỏng là **lỗi to ở load time** (`ContentPackageFormatException`), không bao
  giờ suy biến thành gói rỗng — kế thừa nguyên từ `ContentPackage.parse`. Khối
  Bản A không có trạng thái rỗng (AC-1/BR-5); khối sự kiện rỗng là **trạng thái
  êm đã định**, không phải lỗi (AC-30). "Thêm vào kho" là thao tác idempotent
  theo `event_id`: hàng `calendar_event_state` với PK gộp
  (`owner_key`, `event_id`) chặn tạo thẻ trùng khi người dùng bấm hai lần.
- Compatibility or versioning posture: mọi định danh append-only; `schema_id`
  gắn cứng consumer vào một hình dạng gói; migration Drift chỉ được cộng thêm.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Cổng nhập nội dung R-15c (AC-29) | `starter_content_gate.dart` + `core/content/invariant_terms.dart` | Rule R-1g đi qua enum/hàm **riêng**, không đụng `InvariantRule`; gate quét asset thật từ đĩa | Unit test đọc `assets/data/req016/{starters,calendar_events}.v1.json` từ đĩa, khẳng định `violations.isEmpty`, cộng case âm cho từng rule | `CONTENT_GATE_UNVERIFIED` |
| Hành vi hết-vòng với mọi N (AC-27/AC-28) | `starter_selector.dart` | Cửa sổ modulo `package.length`; không hằng số N trong code; `perPage` là tham số bố cục | Unit test tham số hoá N ∈ {1, 2, 3, 4, 10, 137}: không "đã hết", không ngõ cụt, wrap đúng thứ tự | `ROTATION_UNVERIFIED` |
| Tất định (AC-17) | `starter_selector.dart` | Hàm thuần, `today` và reader **tiêm vào**; cấm `DateTime.now()` trong domain | Unit test chạy hai lần cùng đầu vào → danh sách id giống hệt | `DETERMINISM_UNVERIFIED` |
| Không mạng / không AI (AC-15/AC-16) | toàn module | Không import HTTP client, không base URL trên đường đi này | Test quét import của `features/conversation_starters/**` cấm `dart:io` HTTP, `http`, `dio` | `OFFLINE_UNVERIFIED` |
| Ghi thẻ đúng hợp đồng STORY-001 (AC-11/AC-12) | `STORY-001/architecture/contract-summary.md` | Chỉ qua `createCard`; `status` để mặc định `idea`, `scheduledOn` = ngày sự kiện | Widget/unit test: thẻ tạo ra có `status == idea`, `origin == conversationStarter`, `scheduledOn` khớp, và mục biến mất khỏi danh sách | `CARD_CONTRACT_UNVERIFIED` |
| Migration Drift 6→7 | `cupid_database.dart` | Chỉ `createTable`; cấm huỷ-tạo-lại | Test migration v6→v7 giữ nguyên hàng `activity_cards`/`notebook_entries` đã có | `MIGRATION_UNVERIFIED` |
| Visual fidelity màn (6) | `ux/uiux-spec.md` §2 | Một màn duy nhất, dựng bằng token design-system đã có | Per-story visual-fidelity capture của màn Mồi chuyện ở cả hai trạng thái (có sự kiện / rỗng) | `VISUAL_FIDELITY_UNVERIFIED` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: toàn bộ story — gói nội dung, cổng nhập, domain, Drift,
  presentation, wiring điểm vào.
- Authoritative inputs: `architecture/contract-summary.md`,
  `STORY-001/architecture/contract-summary.md` §2/§3,
  `STORY-004/architecture/contract-summary.md` §2/§3, `ux/uiux-spec.md`.
- Guardrails:
  - Không thêm giá trị vào `InvariantRule` và không yield rule mới từ
    `invariantHitsIn()` (Key Discovery 3).
  - Không sửa `ask_questions.v1.json`, không sửa `AskOnTheSpotSlot`,
    không dựng biến thể thẻ hỏi.
  - Không viết chuỗi câu mồi / tên sự kiện vào widget, Dart, hay l10n.
  - Không lưu con trỏ xoay vòng và không lưu "câu đã copy" xuống DB.
  - Không quy đổi âm↔dương trong code; không thêm dependency lịch âm.
  - Không thêm cột nào trong danh sách cấm của STORY-001 §4 / STORY-004 §4.

## 5. Non-Functional Impact

- `schemaVersion` 6→7 làm đỏ các khẳng định phiên bản đang có: 9 chỗ trong 8
  file test (`test/core/database/**`, `test/features/activity_cards/
  activity_type_test.dart`). Đây là chi phí đã biết của phase Drift, phải nằm
  trong đúng phase đó chứ không rải ra các phase khác.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Họ gói riêng `req016.starters.v1` + `req016.calendar_events.v1`, cổng nhập riêng | Tiền lệ STORY-004: hình dạng item khác hẳn thì là họ gói mới, không phải danh mục mới | ACCEPTED | Giữ `occasions.v1` nguyên vẹn cho lời nhắc Phút-1 của STORY-001 |
| Dùng lại renderer preset của STORY-002 cho câu mồi (câu hỏi kỹ thuật PO giao lại Tech Lead) | Cùng là "chuỗi nội dung render ra màn" | REJECTED | Preset STORY-002 là mad-libs có ô điền do người dùng chọn; câu mồi là dòng đọc-và-copy có placeholder **do sổ tay** điền. Dùng lại sẽ kéo theo máy điền-ô không ai gọi, và buộc hai story dùng chung một `schema_id` mà STORY-002 §6 đã cấm mở rộng |
