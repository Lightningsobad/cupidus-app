# Cross-Lane Contract — REQ-016 STORY-006 "Trước giờ đi"

Authoritative source: `mobile/lib/features/before_you_go/` (STORY-006).
Consumers: STORY-012 (vẽ pha "trước giờ đi" lên widget OS — đọc §4/§5 ở đây,
không đọc widget của STORY-006); một CMS ngoài repo sẽ thay nguồn gói nội dung
§1-§3 mà **không** kèm sửa code (R-15a / BR-15).

## 1. Envelope

Gói nội dung ship kèm app dưới dạng một asset JSON, nạp qua
`ContentPackage.parse<T>` có sẵn ở `mobile/lib/core/content/content_package.dart`.

- Asset key: `assets/data/req016/before_you_go.v1.json`
  (hằng `beforeYouGoAssetKey`). Thư mục `assets/data/req016/` đã khai báo trong
  `mobile/pubspec.yaml` — thêm file **không** cần sửa pubspec.
- Khớp là **khớp chữ**: `schemaId`, `field`, `op`, `action`, `icon` đều so sánh
  chuỗi chính xác.
- Sai lược đồ → `ContentPackageFormatException` ném **lúc load**, ồn ào, có nêu
  tên asset. Không bao giờ degrade thành gói rỗng hay bỏ qua dòng hỏng.

```json
{
  "id": "before_you_go",
  "version": "1",
  "schemaId": "req016.before_you_go.v1",
  "items": [
    { "id": "cash", "order": 10, "labelVi": "Mang đủ tiền mặt",
      "icon": "payments",
      "when": [{ "field": "priceVnd", "op": "gt", "value": 0 }] },
    { "id": "rain", "order": 30,
      "labelVi": "Mang áo mưa/ô, có phương án B trong nhà", "icon": "umbrella",
      "when": [{ "field": "indoorOutdoor", "op": "eq", "value": "outdoor" },
               { "field": "rainySeason", "op": "isTrue" }] },
    { "id": "share_location", "order": 50, "labelVi": "Chia sẻ vị trí",
      "icon": "share_location", "action": "share_location",
      "when": [{ "field": "always", "op": "isTrue" }] }
  ],
  "regions": [
    { "id": "bac", "aliases": ["ha noi", "hai phong"], "rainyMonths": [5,6,7,8,9,10] }
  ]
}
```

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---|---|---|
| Fact (tập ĐÓNG) | `always`, `priceVnd`, `distanceKm`, `needsBooking`, `indoorOutdoor`, `rainySeason` | `items[].when[].field` |
| Toán tử (tập ĐÓNG) | `isTrue`, `isPresent`, `eq`, `gt`, `gte` | `items[].when[].op` |
| Hành động (tập ĐÓNG) | `share_location` | `items[].action`, tuỳ chọn |
| Miền | `bac`, `trung`, `nam` | `regions[].id` |
| Khoá đóng khối | `before_you_go.dismissed_on.<cardId>` | `SharedPreferences` |

Rules cho phía tiêu thụ:

- `items[].id` là ASCII, bền vĩnh viễn, **append-only**. Không đổi tên, không
  dùng chỉ số mảng làm định danh, không dùng `labelVi` làm khoá.
- Fact/op/action **ngoài** danh sách trên là lỗi cổng nhập, không phải giá trị
  mở rộng: cổng từ chối dòng và làm hỏng bản dựng (AC-31). Ví dụ suýt trúng hay
  gặp: `priceVND`, `price_vnd`, `greaterThan`, `shareLocation` — cả bốn đều sai.
- Không tái dùng tiền tố khoá `before_you_go.` cho bất kỳ mục đích nào khác.

## 3. `items[]` fields

| Order | Key | Rendered/exposed as | Value contract |
|---|---|---|---|
| 1 | `id` | không hiển thị | ASCII `[a-z0-9_]+`, duy nhất trong gói |
| 2 | `order` | thứ tự dòng | int; sắp tăng dần, ổn định khi trùng |
| 3 | `labelVi` | nhãn dòng | chuỗi rỗng là lỗi; ≤ 60 ký tự; **nhãn chức năng**, mệnh lệnh việc người dùng tự làm (BR-14) |
| 4 | `icon` | icon leading | phải thuộc allowlist icon ship kèm |
| 5 | `action` | nút trailing | vắng mặt, hoặc `share_location`. Vắng mặt = dòng **không** tương tác |
| 6 | `when` | không hiển thị | mảng **không rỗng** mệnh đề `{field, op, value?}` |

- Đánh giá: dòng hiện khi **mọi** mệnh đề đúng. Mệnh đề trên fact `null` luôn
  **sai** — không mặc định, không đoán, không dòng xám (BR-4).
- `rainySeason` là fact **suy ra**, không phải trường thẻ: `true` khi miền suy
  được từ `ActivityCard.location` (khớp token đã chuẩn hoá với `regions[].aliases`)
  **và** tháng của ngày hẹn nằm trong `regions[].rainyMonths`; `null` khi không
  suy được miền.
- Khoá lạ trong một item = lỗi lược đồ (ném lúc load), không phải bỏ qua.
- Số dòng N là **thuộc tính dữ liệu**: mọi N kể cả 0 đều hợp lệ, bố cục không
  đổi theo N, không có bước tải mới (AC-30/BR-16).

## 4. `BeforeYouGoPhase` — trạng thái pha cho STORY-012

| Order | Key | Rendered/exposed as | Value contract |
|---|---|---|---|
| 1 | `cardId` | không hiển thị | `ActivityCard.id` (UUID v4) |
| 2 | `dateIso` | không hiển thị | ngày dân dụng thiết bị `YYYY-MM-DD`, cùng quy ước `scheduled_on` |
| 3 | `isActive` | pha đang chạy | `status == scheduled` **và** `scheduledOn == dateIso` |
| 4 | `isDismissed` | pha đã đóng trong ngày | khoá `before_you_go.dismissed_on.<cardId>` bằng đúng `dateIso` |

- Value object thuần ở `domain/`, không phụ thuộc widget và không phụ thuộc
  `BuildContext`. STORY-012 đọc nó; STORY-006 **không** vẽ bề mặt widget OS (BR-11).
- `isActive == false` khi thẻ không đủ hai vế. `isActive && isDismissed` là hợp
  lệ và có nghĩa "hôm nay đã xong" — không phải trạng thái lỗi.

## 5. Deploy / rollout order

Một binary, không có thứ tự triển khai giữa hai bên. Thứ tự duy nhất còn ý nghĩa
là **gói dữ liệu trước, phía đọc sau**: nếu asset thiếu hoặc `schemaId` sai,
`ContentPackage.parse` ném lúc load — **ồn ào, có log tên asset**, không phải mất
lặng lẽ. Nếu một `items[].id` bị đổi tên thay vì append, không có bản dựng nào
hỏng: dòng cũ biến mất im lặng khỏi khối. Đó là lý do §2 cấm đổi tên.

## 6. What the consumer must NOT do

- Không thêm cột `activity_cards`, không sửa `CupidDatabase`, không bump
  `schemaVersion` để lưu trạng thái đóng khối.
- Không định nghĩa lại `ActivityCardStatus` hay enum miền ở feature khác.
- Không đọc/ghi khoá `before_you_go.dismissed_on.*` từ ngoài module này; STORY-012
  đọc qua `BeforeYouGoPhase`.
- Không mở rộng `action` để mang logic (URL, template, tên hàm). Nội dung là dữ
  liệu; hành vi ở lại trong code.
- Không lưu vị trí đã chia sẻ, người nhận, hay lịch sử chia sẻ ở bất kỳ đâu
  (AC-19/AC-20).
