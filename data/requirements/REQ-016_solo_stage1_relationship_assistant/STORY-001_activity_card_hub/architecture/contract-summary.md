# Cross-Lane Contract — REQ-016 Kho thẻ hoạt động (activity card hub)

Authoritative source: `mobile/` package `cupid_mobile` (STORY-001).
Consumers: STORY-002, 004, 005, 006, 007, 008, 011, 012, 013 — mọi story đẩy thẻ
vào kho chung hoặc đọc trạng thái thẻ.

## 1. Envelope

Không có wire protocol: hợp đồng này là **API Dart trong tiến trình + bảng Drift
cục bộ**, không có endpoint, không có payload mạng, không có backend counterpart
(xem `solution.md` §1 Key Discovery).

Cửa ghi duy nhất cho story sau:

```dart
// mobile/lib/features/activity_cards/domain/activity_card_repository.dart
Future<ActivityCard> createCard(NewActivityCard draft);
```

`NewActivityCard` chỉ bắt buộc `title` và `origin`; mọi trường khác tuỳ chọn.
Sai khớp tên trường/định danh là **lỗi biên dịch Dart**, không phải mất dữ liệu
âm thầm — đây là lý do hợp đồng dùng kiểu Dart chứ không dùng `Map<String,
dynamic>`.

Bảng lưu: `activity_cards` + `activity_card_photos` trong `CupidDatabase`
(`mobile/lib/core/database/`, ADR-010 — một Drift owner duy nhất).

## 2. Identifiers — copy exactly

| Mục đích | Định danh (lưu trong DB) | Nhãn hiển thị lấy từ |
|---|---|---|
| Trạng thái thẻ | `idea`, `scheduled`, `done`, `memory` | l10n key `cardStatus_<id>` |
| Nguồn sinh (AC-9) | `manual`, `pasted_link`, `occasion_suggestion` | **không hiển thị** |
| Nguồn sinh story sau (append-only) | `gift_suggestion` (004), `conversation_starter` (005), `zodiac` (011), `date_script` (008) | **không hiển thị** |
| Cờ trả lời (R-1b) | `not_answered`, `answered` | l10n key `replyState_<id>` |
| Trong nhà / ngoài trời | `indoor`, `outdoor` | l10n |
| Gói nội dung dịp (AC-3) | `occasions` | asset `mobile/assets/data/req016/occasions.v1.json` |

Ánh xạ trạng thái ↔ nhãn tiếng Việt: `idea` = *Mới nghĩ ra* · `scheduled` = *Đã
hẹn ngày* · `done` = *Đã đi rồi* · `memory` = *Đã thành kỷ niệm*.

Quy tắc cho phía tiêu thụ:

- Định danh là ASCII, ổn định, **append-only**. Không đổi tên, không đổi thứ tự,
  không dùng chuỗi tiếng Việt làm khoá lưu (R-15a).
- Story sau thêm `origin` mới thì thêm **giá trị**, không thêm bảng thẻ mới và
  không thêm cột (SC-1').
- Không tạo enum trạng thái thứ hai ở feature khác; đọc `ActivityCardStatus`.

## 3. `activity_cards` fields

| Khoá | Kiểu | Hợp đồng giá trị |
|---|---|---|
| `id` | TEXT PK | UUID v4 sinh ở client, bền vĩnh viễn. Không dùng rowid/autoincrement (R-15a) |
| `owner_key` | TEXT NOT NULL | backend `User.id` của phiên tạo thẻ; mọi truy vấn lọc theo cột này |
| `title` | TEXT NOT NULL | trường bắt buộc **duy nhất** (AC-6) |
| `status` | TEXT NOT NULL | một trong 4 định danh §2, mặc định `idea` |
| `origin` | TEXT NOT NULL | định danh §2; nội bộ, cấm hiển thị như chỉ số (AC-9) |
| `activity_type` | TEXT NULL | định danh trong gói dữ liệu loại hoạt động |
| `scheduled_on` | TEXT NULL | ngày dân dụng `YYYY-MM-DD` theo lịch thiết bị, **không** phải instant/UTC |
| `price_vnd` | INTEGER NULL | chỉ hiển thị trên thẻ rút gọn khi `> 0` |
| `distance_km` | REAL NULL | |
| `needs_booking` | BOOLEAN NULL | ba trạng thái: null = chưa biết |
| `indoor_outdoor` | TEXT NULL | `indoor` \| `outdoor` |
| `note` | TEXT NULL | |
| `source_link` | TEXT NULL | URL thô do người dùng dán, giữ nguyên (AC-7) |
| `invited` | BOOLEAN NOT NULL | ý niệm "đã rủ", mặc định `false` |
| `reply_state` | TEXT NOT NULL | `not_answered` \| `answered`, mặc định `not_answered` (R-1b) |
| `created_at` / `updated_at` | DATETIME NOT NULL | thời điểm **người dùng** thao tác trên dữ liệu của chính họ |

`activity_card_photos`: `id` TEXT PK · `card_id` TEXT FK → `activity_cards.id`
ON DELETE CASCADE · `local_path` TEXT (file trong thư mục app sở hữu) ·
`sort_index` INTEGER.

- Chuẩn hoá và mặc định thuộc về repository, không thuộc UI.
- Trường thiếu = `null` hợp lệ, không phải lỗi. Không có trường "bắt buộc mềm".

## 4. Danh sách cột bị CẤM (R-1b, cưỡng chế ở test)

`partner_seen_at`, `opened_count`, `open_times`, `reply_latency`,
`response_rate`, `last_seen`, `viewed_at`, `partner_activity_*`, và mọi cột đo
hành vi người kia. `reply_state` chỉ đổi khi người dùng bấm; không tiến trình
nền, không suy luận, không timestamp đi kèm cờ này.

## 5. Deploy / rollout order

Không có thứ tự triển khai giữa hai bên: toàn bộ nằm trong một bản dựng app.
Ràng buộc thay thế là **thứ tự schema**: `CupidDatabase.schemaVersion` lên `3`
trong story này. Story sau thêm cột phải bump tiếp và viết migration cộng thêm;
`activity_cards` **không được** dùng migration huỷ-tạo-lại (khác các bảng cache
theo ADR-007/ADR-015.6) vì đây là dữ liệu gốc, mất là mất vĩnh viễn.

## 6. Phía tiêu thụ KHÔNG được làm

- Không tạo bảng/danh sách thẻ thứ hai cho quà, mồi chuyện, hoàng đạo (SC-1').
- Không thêm hành động chính thứ hai và không đổi 4 nhãn SC-4 (`uiux-spec.md` §2).
- Không đăng ký DAO thẻ làm `SessionScopedStore` (xem `solution.md` §4).
- Không thêm bất kỳ cột/trường nào ở §4, kể cả "chỉ để log".
- Không viết chuỗi nội dung preset thẳng vào widget/Dart; nội dung đi qua gói dữ
  liệu có `id` + `version` (R-15a).
- Không thêm lời gọi mạng hay mô hình AI vào đường đi tạo thẻ (R-7, BR-8).
