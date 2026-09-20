# Phase P7 – Trường lý do của gói sự kiện (ruling mục 7)

## 1. Objective

Dòng lý do dưới tên sự kiện trên canvas — `Đúng dòng "thích đọc sách cũ" trong
sổ tay` — trở thành một **trường thật trong schema gói sự kiện
`req016.calendar_events.v1`**, có cổng nhập chống lưng, được điền tất định từ
sổ tay STORY-004, và render dưới dòng tên trên màn (6).

## 1A. Ownership

- Phase ID: P7
- Canonical Phase File: `phase-P7-event-reason-field.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P6
- Parallelizable: NO
- Write Scope:
  - `mobile/assets/data/req016/calendar_events.v1.json`
  - `mobile/lib/features/conversation_starters/domain/starter_content.dart`
  - `mobile/lib/features/conversation_starters/domain/starter_content_gate.dart`
  - `mobile/lib/features/conversation_starters/domain/calendar_event_service.dart`
  - `mobile/lib/features/conversation_starters/presentation/cubit/conversation_starters_cubit.dart`
  - `mobile/lib/features/conversation_starters/presentation/screens/conversation_starters_screen.dart`
  - `mobile/test/features/conversation_starters/starter_content_gate_test.dart`
  - `mobile/test/features/conversation_starters/calendar_event_service_test.dart`
  - `mobile/test/features/conversation_starters/conversation_starters_screen_test.dart`
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
  - `req016.calendar_events.v1` mở rộng: `reason_template`,
    `reason_context_slot` (hợp đồng đầy đủ ở §4 của chính file này)
  - `VisibleCalendarEvent.reason`
- Shared Interfaces Consumed:
  - `StarterContextSlot`, `starterValueToken` (P1) — **tái dùng, không nhân bản**
  - `NotebookEntry` / `ContextNotebookReader` (STORY-004)
  - `stableContentKey` (P3)
- Risk Surfaces:
  - Cổng nhập nội dung R-15c (AC-29)
  - Tất định (AC-17)
  - Visual fidelity màn (6)
- Source Of Truth:
  - authoritative artifact or convention: Design Ruling Log `req_master.md`
    hàng `2026-09-20 | STORY-005`, mục 7; canvas
    `../visual-fidelity/design-reference-6-moi-chuyen-a-a-ios.png`
  - consumer contract: chỉ màn (6). Không story nào khác đọc hai trường mới.
- Primary Inputs Summary:
  - requirements: AC-15, AC-16, AC-17, AC-20, AC-29, BR-15, R-1b, R-1f
  - architecture: `../architecture/contract-summary.md` §4 (đọc để khớp khuôn,
    **không sửa** — vòng này không chạm `architecture/`)
  - upstream phase outputs: P6 (dòng tên sự kiện đã ở dạng cuối)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một trường nội dung mới, từ schema tới pixel
  - Source/Test File Count: 6 file thực chất + 3 file test là hệ quả cơ học của
    chính trường này
  - Split Required: NO
  - Split Rationale: cùng một lane, cùng một owner, và mọi consumer của hợp
    đồng nằm trong chính phase này. Tách hợp đồng ra phase riêng sẽ tạo một
    dispatch không có consumer nào và để lại một trường chết giữa hai vòng
    đời specialist.

## 1C. Phạm Vi Schema — Đọc Trước Khi Gõ Dòng Đầu Tiên

**Đây là schema GÓI NỘI DUNG, không phải schema Drift.**

Ruling viết "thêm trường lý do vào schema gói sự kiện — cỡ như B-1". `cỡ như
B-1` là **so sánh kích cỡ và quyền sở hữu** (Tech Lead bóc phase, mobile-dev
thi hành, PO không thi hành), **không** có nghĩa lặp lại đúng hình thức kỹ
thuật của B-1.

Bản giao việc vòng này diễn giải mục 7 thành "cột Drift mới + migration +
nâng `schemaVersion`". Đã rà mã trên nhánh này và **diễn giải đó sai phạm vi**:

- Sự kiện lịch **không** nằm trong Drift. Chúng là mục của gói asset
  `mobile/assets/data/req016/calendar_events.v1.json`, parse bằng
  `calendarEventFromJson` (`starter_content.dart`).
- Bảng Drift duy nhất mà story này thêm (`calendar_event_state`, P2) chỉ lưu
  `converted`/`dismissed` theo `event_id`; nó không lưu một byte nào của nội
  dung sự kiện.
- Dòng lý do là **nội dung hiển thị suy ra từ sổ tay tại thời điểm render**,
  không có gì để lưu bền.

Vì vậy phase này **CẤM**: thêm cột Drift, thêm bảng, viết migration, nâng
`schemaVersion`. Nâng `schemaVersion` ở đây còn là một rủi ro thật, không chỉ
thừa: các nhánh story song song của REQ-016 từng đụng nhau vì cùng nâng một số
phiên bản Drift, và nhánh về sau im lặng không chạy migration.

Nếu Reviewer hoặc Scrum Master vẫn đọc mục 7 theo nghĩa "phải có migration",
đó là một phán quyết phạm vi mới cần ghi vào Design Ruling Log — mobile-dev
**dừng và báo blocker**, không tự mở Drift.

## 2. Required Reads

- Design Ruling Log hàng `2026-09-20 | STORY-005` trong `../../req_master.md`,
  mục 7 — và hàng `2026-09-09 | STORY-001 | B-1` để thấy "cỡ như" nghĩa là gì
- `../visual-fidelity/design-reference-6-moi-chuyen-a-a-ios.png` (khối sự kiện)
- `mobile/lib/features/conversation_starters/domain/starter_content.dart`
  (`CalendarEvent`, `StarterContextSlot`, `calendarEventFromJson`)
- `mobile/lib/features/conversation_starters/domain/starter_selector.dart`
  (`_contextValue` — quy tắc chọn giá trị sổ tay đã tất định, phải tái dùng)
- `mobile/lib/features/conversation_starters/domain/calendar_event_service.dart`

## 3. Tasks

### Schema và cổng nhập

- `calendar_events.v1.json`: mỗi mục sự kiện được thêm hai khoá **tuỳ chọn**,
  không khoá nào khác:
  - `reason_template` TEXT — ví dụ `Đúng dòng "{value}" trong sổ tay`
  - `reason_context_slot` TEXT — enum đóng `interest` | `event`, chính là
    `StarterContextSlot` đang có
- Giữ nguyên `schema_id` `req016.calendar_events.v1`. Hai khoá tuỳ chọn không
  phá gói cũ, gói ship kèm trong bản dựng nên không có bề mặt tương thích nào
  ở ngoài; đặt `v2` sẽ bắt sửa `calendarEventsSchemaId` và mọi test đọc nó mà
  không mua thêm điều gì.
- `CalendarEvent` nhận thêm `reasonTemplate` và `reasonContextSlot`;
  `calendarEventFromJson` đọc chúng bằng `optionalContentString` đã có, và
  **từ chối** (parse error) khi `reason_context_slot` không thuộc enum.
- `starter_content_gate.dart` — thêm rule, mỗi rule một giá trị enum mới của
  họ rule sự kiện, đúng khuôn `firstWhere` trên wire value đang dùng:
  - có `reason_template` ⇔ có `reason_context_slot` (thiếu một bên là vi phạm)
  - `reason_template` chứa **đúng một** `starterValueToken`
  - `reason_template` **không** kết thúc bằng `?` — nó là một câu kể về điều
    người dùng đã tự ghi, không phải câu để nhắn; R-1g chỉ chi phối
    `StarterItem.text`
  - `reason_template` đi qua `invariantHitsIn()` như mọi chuỗi hiển thị khác
  - **không** thêm giá trị nào vào `InvariantRule`
- Nội dung seed: điền `reason_template`/`reason_context_slot` cho các mục sự
  kiện có lý do tự nhiên; mục không có thì bỏ trống cả hai khoá.

### Điền giá trị và render

- Thêm hàm **thuần** `String? resolveEventReason({required CalendarEvent event,
  required List<NotebookEntry> notebook, required String today})` trong
  `calendar_event_service.dart`:
  - không có `reasonTemplate` ⇒ `null`
  - lọc `notebook` theo `reasonContextSlot.wireValue`, bỏ giá trị rỗng, sort
    theo `entry.id`, chọn
    `matches[stableContentKey('$today|${event.id}') % matches.length]` — **đúng
    cùng phép chọn** `StarterSelector._contextValue` đang dùng, để lý do không
    nhảy giữa hai lần dựng cùng ngày (AC-17)
  - không có mục sổ tay nào khớp ⇒ `null`. **Không bao giờ** trả chuỗi còn
    nguyên token, không chuỗi giữ chỗ, không "chưa có ghi chú"
- `VisibleCalendarEvent` nhận thêm `final String? reason`; `visibleEvents`
  nhận thêm tham số `notebook` và gọi `resolveEventReason`.
- Cubit: `load()` phải đọc sổ tay **trước** khi gọi `visibleEvents` (hiện đang
  gọi sau) rồi truyền vào.
- Cubit `refreshContext()`: sau khi sổ tay đổi, map **trên chính
  `state.events`** để tính lại `reason`, không gọi lại `visibleEvents`. Gọi lại
  sẽ làm sống dậy những hàng vừa bị "Thêm vào Muốn làm"/"Bỏ qua" (AC-12/AC-14).
- Màn: dưới dòng tên sự kiện, nếu `event.reason != null` thì vẽ một `Text`
  `type.caption` màu `colorTextMuted`, key `starter_event_reason_<id>`. Không
  có lý do thì **không** vẽ gì — không dòng rỗng, không khoảng trắng giữ chỗ.
  Hàng sự kiện đổi từ `Row` phẳng sang tên + lý do xếp dọc ở cột giữa.

### Ranh giới không được vượt

- Không cột Drift, không bảng, không migration, không nâng `schemaVersion`
  (xem §1C).
- Không suy luận lý do bằng heuristic khớp từ khoá: lý do chỉ đến từ
  `reason_template` do gói khai, giá trị chỉ đến từ sổ tay. Không mạng, không
  AI (AC-15/AC-16).
- Không ghi lý do xuống đâu cả, kể cả vào thẻ được tạo khi bấm "Thêm vào Muốn
  làm" — hợp đồng thẻ của STORY-001 không đổi ở phase này.
- Không thêm trường đo phản ứng người kia hay đếm lượt hiện lý do (R-1b, R-1f).

## 4. Acceptance Criteria — Hợp Đồng Trường Lý Do

Đây là nơi hợp đồng của trường này sống; `architecture/solution.md` **không**
nhắc lại nó ở vòng này.

- `req016.calendar_events.v1`, mỗi mục sự kiện, sau phase này gồm đúng:
  `id`, `name`, `calendar`, `dates[]`, `activity_type?`, `reason_template?`,
  `reason_context_slot?`. Không khoá nào khác được thêm.
- `reason_context_slot` chỉ nhận `interest` hoặc `event`; giá trị lạ là parse
  error, không phải mặc định im lặng.
- `validateStarterPacks` trả rỗng cho gói ship kèm sau khi thêm nội dung lý do.
- Mỗi rule lý do mới có ít nhất một case âm chứng minh nó bắt được vi phạm:
  thiếu slot, thiếu template, không token, hai token, template kết thúc `?`.
- Sổ tay rỗng: màn vẫn dựng, mọi hàng sự kiện vẫn hiện, **không hàng nào** có
  dòng lý do, không chuỗi nào lộ `{value}`.
- Cùng (ngày, sổ tay, sự kiện) cho ra cùng một dòng lý do qua hai lần dựng.
- Sổ tay có nhiều mục cùng loại: dòng lý do chọn đúng mục mà công thức
  `stableContentKey` chỉ ra, không phải mục đầu danh sách một cách tình cờ.
- Trả lời ô hỏi tại chỗ xong: lý do được tính lại, và **không** hàng sự kiện
  nào đã "Thêm vào Muốn làm"/"Bỏ qua" quay trở lại dải.
- `schemaVersion` của Drift **không đổi**; không file nào trong
  `mobile/lib/core/database/` bị chạm.
- Không lời gọi mạng nào phát sinh khi mở màn.

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`.
- Contracts or schemas: `req016.calendar_events.v1` (mở rộng, giữ id),
  `VisibleCalendarEvent.reason`.
- Notes or evidence: `coding-plan/test-results.md`,
  `visual-fidelity/implemented-6-moi-chuyen-a-a-material.png` chụp lại.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile — tầng nội dung/domain cộng một dòng UI
- Required levels:
  - unit: cổng nhập với gói thật đọc từ đĩa, cộng case âm cho từng rule lý do
    mới; parser từ chối `reason_context_slot` lạ
  - unit: `resolveEventReason` — không template, có template nhưng sổ tay
    rỗng, một mục khớp, nhiều mục khớp (tất định), mục khớp có giá trị rỗng
  - widget: dòng lý do hiện/không hiện đúng hai nhánh; không hàng nào lộ
    `{value}`; hàng đã thêm/bỏ qua không quay lại sau `refreshContext`
  - mobile build/type-check/static-analysis: `flutter analyze lib test` — gate
    là zero analyzer **error** và không warning mới ở file đã chạm; exit code
    **không** phải gate
- Required checks: chạy lại bốn cổng nhập đang ship
  (`gift_content_gate`, `preset_content_gate`, `context_content_gate`,
  `before_you_go_content_gate`) để chứng minh họ rule mới không làm chúng đỏ
- Minimum gates by risk surface: tất định (AC-17) phải được test bằng sổ tay
  **nhiều mục**, không chỉ một mục — một mục thì phép chọn nào cũng đúng
- Required regression or contract coverage: toàn bộ
  `mobile/test/features/conversation_starters/`, cộng
  `mobile/test/core/database/` để chứng minh `schemaVersion` không bị chạm
- Evidence format: lệnh `flutter test <đường dẫn>` và tóm tắt pass/fail trong
  `coding-plan/test-results.md`
- Per-story visual fidelity: **REQUIRED** — phase này thêm một dòng hiển thị
  thật vào khối sự kiện.
  - Chụp lại `visual-fidelity/implemented-6-moi-chuyen-a-a-material.png` ở
    trạng thái **có** dòng lý do (sổ tay được seed), đối chiếu canvas.
  - Fallback được phép: `RepaintBoundary` trong widget test của phase này, với
    `CupidAppBackground`, một lớp nền đục và font MaterialIcons của framework.
  - **Bắt buộc nhìn bằng mắt ảnh đã chụp**: dòng lý do có dấu ngoặc kép và dấu
    tiếng Việt, đúng chỗ dễ ra tofu.
  - Chạy `git status` trước khi báo hoàn thành; không commit PNG của story khác.
- Verification strategy:
  - Targeted tests/regression/contract checks: như trên
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: `violations.isEmpty` cho gói ship kèm; bảng
    `sổ tay → dòng lý do` cho ít nhất ba cấu hình sổ tay; `git diff --stat`
    chứng minh `mobile/lib/core/database/` không có thay đổi nào

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-20
