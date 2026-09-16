# Phase P3 – Xếp câu mồi tất định + đổi sự kiện thành thẻ

## 1. Objective

Tầng domain thuần: xếp câu mồi tất định có riêng-hoá từ sổ tay và quay vòng
đúng với mọi N, lọc sự kiện theo ngày và theo trạng thái đã xử lý, và đổi một
sự kiện thành thẻ qua đúng cửa ghi của STORY-001.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-selection-and-card-handoff.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/conversation_starters/domain/starter_selector.dart`
  - `mobile/lib/features/conversation_starters/domain/calendar_event_service.dart`
  - `mobile/lib/features/activity_cards/domain/activity_card.dart`
  - `mobile/test/features/conversation_starters/starter_selector_test.dart`
  - `mobile/test/features/conversation_starters/calendar_event_service_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ActivityCardOrigin.conversationStarter`
    (`../architecture/contract-summary.md` §2)
  - `StarterSelector`, `CalendarEventService` cho P4
- Shared Interfaces Consumed:
  - `ActivityCardRepository.createCard` / `NewActivityCard`
    (`STORY-001/architecture/contract-summary.md` §1, §3)
  - `ContextNotebookReader` (`STORY-004/architecture/contract-summary.md` §3)
  - P1 model + gói nội dung; P2 `CalendarEventStateRepository`
- Risk Surfaces:
  - Hành vi hết-vòng với mọi N (AC-27/AC-28)
  - Tất định (AC-17)
  - Ghi thẻ đúng hợp đồng STORY-001 (AC-11/AC-12)
  - Không mạng / không AI (AC-15/AC-16)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md`
    §3, §4
  - consumer contract: P4
- Primary Inputs Summary:
  - requirements: AC-4, AC-5, AC-11, AC-12, AC-13, AC-17, AC-27, AC-28
  - architecture: `../architecture/solution.md` §3 A-1/A-2, §4 Lane Handoff
  - upstream phase outputs: P1 `starter_content.dart`, P2
    `CalendarEventStateRepository`
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: chọn nội dung và ghi thẻ — một cụm hành vi domain thuần
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (Nhóm A, Nhóm B, Nhóm C, Nhóm D)
- `../architecture/contract-summary.md` §2, §3, §4
- `STORY-001/architecture/contract-summary.md` §1, §2, §3 — chỉ cửa ghi
  `createCard` và bảng trường thẻ
- `STORY-004/architecture/contract-summary.md` §3 — chỉ `ContextNotebookReader`

## 3. Tasks

- Thêm `conversationStarter('conversation_starter')` vào `ActivityCardOrigin`.
  Append-only: không đổi tên, không đổi thứ tự giá trị đang có.
- Viết `StarterSelector` là **hàm thuần**: nhận `ContentPackage<StarterItem>`,
  danh sách `NotebookEntry`, `today` dạng ngày dân dụng, `page`, và `perPage`;
  trả danh sách câu đã render.
  - Mục `contextual` chỉ đủ tư cách khi sổ tay có mục hợp `context_slot`; khi
    đủ, thay `{value}` bằng `NotebookEntry.value`.
  - Mục đủ tư cách `contextual` xếp trước mục `generic` (AC-5).
  - Thứ tự trong mỗi nhóm là khoá tất định sinh từ `'$today|$itemId'`, hoà thì
    so theo `id`.
  - Cửa sổ là `perPage` phần tử bắt đầu ở `(page * perPage) % length`, cuộn
    vòng. Không hằng số N trong code; `perPage` là tham số bố cục truyền vào.
- Viết `CalendarEventService` với:
  - `visibleEvents({required String ownerKey, required String today})` — bỏ mục
    có mọi `dates[]` nhỏ hơn `today`, bỏ mục có trong `handledEventIds`, mỗi
    mục còn lại mang ngày sắp tới gần nhất của chính nó.
  - `addToStore(event)` — gọi `createCard(NewActivityCard(title: event.name,
    origin: ActivityCardOrigin.conversationStarter, scheduledOn: <ngày sắp tới
    gần nhất>, activityType: event.activityType))` rồi ghi `converted`.
  - `dismiss(event)` — chỉ ghi `dismissed`, không hỏi lý do, không tạo gì.
- `today` được **tiêm vào**; cấm `DateTime.now()` trong code domain của phase
  này, giống `occasion_suggestion_service.dart`.

## 4. Acceptance Criteria

- Hai lần gọi `StarterSelector` với cùng đầu vào trả danh sách id giống hệt.
- Với N ∈ {1, 2, 3, 4, 10, 137} và `perPage = 3`: gọi liên tiếp `page` tăng dần
  duyệt hết kho rồi quay lại đúng bộ đầu tiên, theo cùng thứ tự; không có
  trạng thái "đã hết", không có chỉ báo tiến độ hay số mục còn lại trong API.
- Với N < `perPage`, selector trả đúng N mục, không ném lỗi và không chèn mục
  giữ chỗ.
- Sổ tay rỗng vẫn trả đủ câu dùng được từ các mục `generic` (AC-6/BR-5).
- Không câu nào trả ra còn sót token `{value}`.
- Thẻ tạo ra có `status == idea`, `origin == conversationStarter`,
  `scheduledOn` bằng ngày sự kiện. `NewActivityCard` không nhận `status`, nên
  một `scheduled_on` khác null **không** làm thẻ thành `scheduled`.
- Bấm `addToStore` hai lần cho cùng `event_id` chỉ tạo một thẻ.
- Sự kiện đã qua ngày không xuất hiện trong `visibleEvents` và không có API nào
  nhắc lại nó (AC-13, R-1c/R-1d).

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`.
- Contracts or schemas: `ActivityCardOrigin.conversationStarter`.
- Notes or evidence: `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng domain, không UI
- Required levels:
  - unit: selector (tất định, quay vòng tham số hoá theo N, riêng-hoá, sổ tay
    rỗng); service (lọc ngày, lọc trạng thái đã xử lý, tạo thẻ, idempotency)
  - mobile build/type-check/static-analysis: `flutter analyze lib test` — gate
    là zero analyzer **error**; exit code không phải gate
- Required checks: `ActivityCardOrigin.fromWireValue` vẫn đọc được cả bốn giá
  trị cũ sau khi thêm giá trị mới
- Minimum gates by risk surface: quay vòng và tất định phải được chứng minh
  bằng test tham số hoá theo N, không bằng một N cố định
- Required regression or contract coverage:
  `mobile/test/features/activity_cards/` (hợp đồng thẻ và enum nguồn sinh)
- Evidence format: lệnh `flutter test <đường dẫn>` và tóm tắt pass/fail trong
  `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase này không dựng màn nào
- Verification strategy:
  - Targeted tests/regression/contract checks: như trên
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: danh sách id trả về ở hai lần chạy bằng nhau;
    bảng N → chuỗi trang duyệt hết rồi wrap

## 7. Status

- Status: COMPLETE
- Last updated: 2026-09-16
