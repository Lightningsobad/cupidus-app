# Cross-Lane Contract — REQ-016 STORY-013 Cổng đóng ngăn và sổ đăng ký xoá sạch

Authoritative source: `mobile/lib/features/chapter_closure/` (STORY-013).
Consumers: `mobile/` STORY-005/007/008/009/010/011/012 — mọi story còn lại của
REQ-016 tạo dữ liệu người dùng đều phải đăng ký vào hai cơ chế dưới đây.

## 1. Envelope

Không có transport, không có wire format: đây là hợp đồng **trong tiến trình**
giữa các module mobile, đi qua hai bảng Drift trong `CupidDatabase` và hai
symbol Dart. Sai sót không gây lỗi build — nó gây **rò rỉ im lặng**: vật liệu
đã đóng vẫn hiện (vi phạm AC-11), hoặc dữ liệu sót lại sau xoá sạch (vi phạm
AC-27). Vì vậy cả hai cơ chế đều có test đối chiếu bắt buộc ở §6.

Sổ ghi (`schemaVersion` 7, cộng thêm, không sửa bảng cũ):

```
chapter_closures(id TEXT PK, owner_key TEXT, closed_at DATETIME)
chapter_closure_items(
  closure_id TEXT -> chapter_closures.id ON DELETE CASCADE,
  item_kind  TEXT,
  item_id    TEXT,
  PRIMARY KEY (closure_id, item_kind, item_id))
INDEX chapter_closure_items_kind_item ON (item_kind, item_id)
```

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---|---|---|
| Loại thành viên: thẻ hoạt động | `activity_card` | `chapter_closure_items.item_kind` |
| Loại thành viên: mục sổ tay người yêu | `notebook_entry` | `chapter_closure_items.item_kind` |
| Loại thành viên: trạng thái câu hỏi đã hỏi | `ask_prompt` | `chapter_closure_items.item_kind`, `item_id` = `question_id` |
| Ngưỡng vắng | `kReturnAbsenceThreshold = Duration(days: 30)` | hằng số Dart, một giá trị duy nhất |
| Mốc mở app gần nhất | `req016.last_opened_at` | khoá `SharedPreferences`, epoch ms |

Rules for the consumer side:

- `item_kind` là **append-only**. Thêm loại mới khi story của bạn tạo vật liệu
  gắn người; không bao giờ đổi tên hay tái dùng một giá trị cũ cho ý nghĩa khác.
- `item_id` phải là khoá chính bền của bảng bạn sở hữu. Không dùng rowid.
- Không tạo khoá `SharedPreferences` thứ hai nào đo khoảng vắng, đếm lần mở
  app, hay lưu lịch sử các lần vắng — R-1 cấm (f), BR-7.

## 3. Cổng đọc — `ChapterClosureGate`

| Order | Key | Rendered/exposed as | Value contract |
|---|---|---|---|
| 1 | `closedIdsOf(kind)` | `Future<Set<String>>` | Tập id đang đóng của một `item_kind`; rỗng là trạng thái bình thường |
| 2 | `hasAnyClosure()` | `Future<bool>` | Điều khiển progressive disclosure của ô pane "Đã đóng" |
| 3 | anti-join SQL | `NOT EXISTS (SELECT 1 FROM chapter_closure_items WHERE item_kind = ? AND item_id = <bảng>.<pk>)` | Dạng chuẩn cho mọi truy vấn phân trang |

- Consumer nào đọc dữ liệu gắn người **phải** loại trừ id đã đóng, và phải làm
  việc đó **trong SQL** nếu truy vấn có `LIMIT`/`OFFSET` — lọc trong Dart sau
  khi đọc làm sai kích thước trang và cờ `hasMore`.
- Consumer đọc sổ tay qua `ContextNotebookReader.entries()` **không cần làm
  gì**: cổng đã nằm trong repository, và kết quả rỗng đúng bằng hành vi "sổ tay
  còn trống" mà AC-12 yêu cầu.
- `skills()` (hồ sơ kỹ năng) **không bao giờ** bị lọc — AC-8.
- Nhật ký riêng (STORY-003) **không bao giờ** là thành viên closure — BR-6.

## 4. Sổ đăng ký xoá sạch — `Stage1WipeRegistry`

| Order | Key | Rendered/exposed as | Value contract |
|---|---|---|---|
| 1 | `tables` | `List<TableInfo>` | Mọi bảng Drift do REQ-016 sở hữu, xoá trong **một** transaction |
| 2 | `mediaRoots` | `List<Future<void> Function()>` | Mọi thư mục file do REQ-016 sở hữu, ví dụ `JournalMediaStore.deleteRoot` |
| 3 | `preferenceKeys` | `List<String>` | Mọi khoá `SharedPreferences` do REQ-016 sở hữu |

- Story tạo bảng/thư mục/khoá mới **phải** thêm nó vào đúng danh sách trên
  trong cùng story. Bỏ sót không làm hỏng build; nó để lại dư lượng và fail
  AC-27 ở review.
- Bảng nào có `ON DELETE CASCADE` về `activity_cards` (ví dụ `invite_messages`,
  `activity_card_photos`) vẫn nên được liệt kê: cascade là bảo hiểm, sổ đăng ký
  là nguồn sự thật mà test đối chiếu.
- Story nào lần đầu ghi **file** ảnh cho thẻ hoạt động phải tạo media store
  riêng cho nó và đăng ký `mediaRoots` — hiện `activity_card_photos` chỉ có
  hàng DB, chưa có store sở hữu đường dẫn nào.

## 5. Deploy / rollout order

Một tiến trình, một lần cài đặt: không có thứ tự triển khai giữa các bên. Thứ
tự **trong story** là bắt buộc: bảng + migration phải tồn tại trước khi bất kỳ
truy vấn anti-join nào tham chiếu tới chúng, nếu không sqlite ném lỗi runtime
"no such table" trên đường đọc nóng nhất của app (hub thẻ).

## 6. What the consumer must NOT do

- Không thêm cột `closed_at`/`archived`/`hidden` vào bảng của mình — trạng thái
  đóng chỉ sống trong sổ ghi (BR-3).
- Không thêm cột chứa lý do đóng, nhãn cảm xúc, hay bất kỳ nhận định nào về
  người kia vào hai bảng này (AC-5/BR-9).
- Không tính lại vị từ "gắn người" lúc đọc — tập đóng là ảnh chụp tại thời điểm
  đóng; tính lại sẽ hút thẻ sống sót vào kho đã đóng và phá AC-9.
- Không thêm giá trị thứ năm vào `ActivityCardStatus`; "Đã đóng" là bộ lọc chứ
  không phải trạng thái vòng đời (BR-4).
- Không để bất kỳ hàm public nào trả về số ngày vắng, `Duration`, hay mốc mở
  app trước đó — chỉ `bool` được rời khỏi `ReturnGateResolver` (AC-19/AC-20).
- Không gọi `clearOnSignOut()` từ luồng xoá sạch: người dùng vẫn đăng nhập
  (AC-29), và các kho REQ-016 cố ý không phải `SessionScopedStore`.
