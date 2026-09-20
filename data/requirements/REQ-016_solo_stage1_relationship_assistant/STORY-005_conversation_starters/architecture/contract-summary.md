# Cross-Lane Contract — REQ-016 STORY-005 Mồi chuyện

Authoritative source: `mobile/` (STORY-005).
Consumers: `mobile/` STORY-007 (đọc lại kho mồi đã giao). Hợp đồng tự chứa:
consumer cài đặt theo file này, không cần mở `solution.md` hay đọc source.

## 1. Envelope

Hai envelope, không có envelope thứ ba. Không HTTP, không backend, không API
nội dung, không mô hình AI trên bất kỳ đường đi nào (R-7, AC-15/AC-16).

**(A) Gói nội dung — Flutter asset JSON.** Tái dùng nguyên
`ContentPackage`/`ContentPackageLoader`
(`mobile/lib/core/content/content_package.dart`). Hai gói, **hai `schema_id`
riêng**: hình dạng item khác hẳn nhau nên đây là một họ gói mới, không phải
danh mục mới của họ preset STORY-002. Thư mục `assets/data/req016/` đã khai
báo trong `pubspec.yaml`: thêm gói **không** sửa `pubspec.yaml`.

**(B) Trạng thái mục sự kiện — bảng Drift cục bộ.** Không wire protocol. Sai
khớp tên trường là **lỗi biên dịch Dart**, không mất dữ liệu âm thầm.

## 2. Identifiers — copy exactly

| Mục đích | Định danh | Ràng buộc |
|---|---|---|
| Gói câu mồi thường xanh | `req016.starters.v1` | `assets/data/req016/starters.v1.json` |
| Gói sự kiện có lịch | `req016.calendar_events.v1` | `assets/data/req016/calendar_events.v1.json` |
| Loại mục mồi | `generic` · `contextual` | trường `kind`; enum đóng |
| Ô ngữ cảnh của mục `contextual` | `interest` · `event` | trường `context_slot`; ánh xạ 1-1 sang `NotebookKind` của STORY-004 |
| Token thay thế trong câu `contextual` | `{value}` | đúng một lần, đúng chuỗi này |
| Nguồn sinh thẻ (bản A+) | `conversation_starter` | giá trị đã dành sẵn ở `STORY-001/architecture/contract-summary.md` §2; thêm vào `ActivityCardOrigin` như `conversationStarter('conversation_starter')` |
| Cửa vào gọi hỏi-tại-chỗ | `conversation_starters` | giá trị mới trong danh sách append-only ở `STORY-004/architecture/contract-summary.md` §2; **không** thêm cơ chế |
| Trường cần hỏi ở màn này | `notebook.interest` | `AskOnTheSpotSlot.neededFieldIds`, đã có sẵn trong `ask_questions.v1.json` |
| Trạng thái một mục sự kiện | `converted` · `dismissed` | cột `calendar_event_state.state`; enum đóng |
| Provenance lịch của một sự kiện | `solar` · `lunar` | trường `calendar`; **chỉ là provenance**, không có phép quy đổi nào trong code |

Quy tắc cho phía tiêu thụ:

- `items[].id` của cả hai gói là **id bền**: append-only, không đổi tên, không
  tái dùng, không xoá một id đã ship (`calendar_event_state` trỏ ngược vào nó).
- Chỉ số trong `items` **không bao giờ** là định danh.
- `conversation_starter` là giá trị thứ năm của `ActivityCardOrigin`. Thêm
  **giá trị**, không thêm bảng, không thêm cột (SC-1').

## 3. `req016.starters.v1` — item fields

| Khoá | Kiểu | Hợp đồng giá trị |
|---|---|---|
| `id` | string, bắt buộc | id bền, duy nhất trong gói |
| `kind` | string, bắt buộc | `generic` \| `contextual` |
| `text` | string, bắt buộc | Câu mồi hoàn chỉnh. **Phải kết thúc bằng `?`** (R-1g/AC-20) — không có cờ dữ liệu nào tắt được luật này |
| `context_slot` | string | Bắt buộc khi `kind == contextual`, **cấm** khi `kind == generic` |

- `kind == contextual` ⇒ `text` chứa đúng một `{value}`; `kind == generic` ⇒
  `text` **không** chứa `{value}`. Cả hai chiều đều là vi phạm cổng nhập.
- Thay thế `{value}` bằng `NotebookEntry.value` đọc qua
  `ContextNotebookReader`. Không so khớp mờ, không tokenizer, không mô hình.
- Sổ tay không có mục hợp `context_slot` ⇒ mục `contextual` đó **không được
  xếp ra**; nó không render với token còn nguyên và không render với chuỗi rỗng.

## 4. `req016.calendar_events.v1` — item fields

| Khoá | Kiểu | Hợp đồng giá trị |
|---|---|---|
| `id` | string, bắt buộc | id bền |
| `name` | string, bắt buộc | Nhãn hiển thị. Là **nội dung**, không bao giờ lấy từ l10n hay hằng Dart |
| `calendar` | string, bắt buộc | `solar` \| `lunar`, provenance only |
| `dates` | list\<string\>, bắt buộc, ≥1 | Ngày dân dụng `YYYY-MM-DD` **do người soạn nội dung chốt sẵn** cho từng lần xảy ra, đúng quy ước `occasions.v1.json` của STORY-001. Không file nào trong repo quy đổi âm↔dương |
| `activity_type` | string, tuỳ chọn | Một trong 8 giá trị `ActivityType` ở `STORY-001/architecture/contract-summary.md` §2 |

`calendar_event_state`: PK gộp (`owner_key`, `event_id`) · `state` TEXT NOT
NULL (`converted` \| `dismissed`) · `updated_at` DATETIME NOT NULL.
`owner_key` là backend `User.id`; mọi truy vấn lọc theo cột này.

- Một mục hiện ra ⟺ có ít nhất một `dates[]` **>= ngày hôm nay** và không có
  hàng `calendar_event_state` cho `event_id` đó (AC-12/AC-13/AC-14).
- Ngày hôm nay được **tiêm vào** domain; cấm `DateTime.now()` trong domain
  code, giống `occasion_suggestion_service.dart`.
- Thẻ sinh ra dùng `createCard(NewActivityCard(title: name, origin:
  conversationStarter, scheduledOn: <ngày sắp tới gần nhất>, activityType:
  ...))`. `status` **để mặc định** `idea`; `NewActivityCard` không nhận
  `status`, và một `scheduled_on` khác null **không** làm thẻ thành `scheduled`.
- Bấm "Thêm vào kho" hai lần là idempotent theo PK gộp: hàng `converted` đã tồn
  tại ⇒ không tạo thẻ thứ hai.

## 5. Deploy / rollout order

Một binary duy nhất — không có thứ tự triển khai đa phía. Hai thứ tự có thật:

1. **Cổng nhập nội dung chạy trước khi bản dựng ra đời.** Test quét hai file
   asset từ đĩa và chạy `validateStarterPacks`; gói vi phạm → test đỏ → **bản
   dựng hỏng** (AC-29/BR-17). Không có nhánh nào để vi phạm lọt tới người đọc.
2. **Migration cộng thêm.** `calendar_event_state` là DDL mới nên
   `CupidDatabase.schemaVersion` lên `7` (giá trị hiện tại trên nhánh tích hợp
   là `6` — đọc lại giá trị thật lúc cài đặt rồi cộng một). Chỉ `CREATE TABLE`;
   huỷ-tạo-lại bị cấm tuyệt đối.

## 6. What the consumer must NOT do

- **Không** thêm giá trị vào `InvariantRule` và **không** yield rule mới từ
  `invariantHitsIn()`. Bốn cổng nhập đang chạy ánh xạ hit bằng `firstWhere`
  không có `orElse`; một giá trị mới là `StateError` runtime ở bốn feature
  không liên quan. Rule R-1g đi theo tiền lệ `NotebookBoundaryRule` — enum
  riêng, hàm riêng, cùng file `core/content/invariant_terms.dart`.
- Không thêm cờ dữ liệu kiểu `about_partner` để một mục thoát luật R-1g.
- Không tạo danh sách "câu đã copy"/"yêu thích"/"để dành" dưới bất kỳ tên nào,
  và không lưu con trỏ xoay vòng xuống DB — nó sống trong Cubit, đúng một vòng
  đời màn (SC-1'/AC-3).
- Không giả định số mục của gói. Hết-tập là quay vòng modulo `length`; cấm "đã
  hết ý tưởng", màn ngõ cụt, và mọi chỉ báo tiến độ/phần trăm/đếm số
  (AC-27/AC-28).
- Không vẽ lại thẻ hỏi và không sửa `ask_questions.v1.json`; dựng
  `AskOnTheSpotSlot` với `entryPointId: 'conversation_starters'`.
- Không thêm lời gọi mạng, dependency lịch âm, hay mô hình AI vào bất kỳ đường
  đi nào của module này.
