# Cross-Lane Contract — REQ-016 STORY-002 Xuất lời mời

Authoritative source: `mobile/` (STORY-002).
Consumers: `mobile/` STORY-007 (thêm danh mục preset "lời cảm ơn sau hẹn"),
`mobile/` STORY-008 (cửa vào thứ hai từ kịch bản buổi hẹn), và requirement
chặng 1.5 (đọc lại payload đã lưu). Hợp đồng này tự chứa: consumer không cần
mở `solution.md` hay đọc source để cài đặt theo nó.

## 1. Envelope

Hai envelope, không có envelope thứ ba. Không có HTTP, không có backend, không
có API sinh nội dung ở bất kỳ chặng nào của hai envelope này (R-7).

**(A) Gói preset — Flutter asset JSON.** Tái dùng nguyên vẹn
`ContentPackage`/`ContentPackageLoader` (`mobile/lib/core/content/content_package.dart`,
do STORY-001 giao). Quy ước khoá asset, **không phải bảng tra trong code**:

    assets/data/req016/presets.<categoryId>.v1.json

Thêm một danh mục = thêm một file theo đúng quy ước này + khai báo thư mục đã
có sẵn trong `pubspec.yaml`. Không sửa engine (AC-21/AC-29). Ví dụ tối thiểu:

```json
{
  "id": "presets.invite",
  "version": "1.0.0",
  "schema_id": "req016.presets.v1",
  "locale": "vi",
  "items": [
    {
      "id": "invite.rap_phim.v1",
      "frame": "Rạp phim",
      "clauses": [
        {"text": "{date} tớ có suất phim mà chưa rủ được ai.", "requires": ["date"], "targets": "sender"},
        {"text": "Ở {place} nhé.", "requires": ["place"], "targets": "neutral"},
        {"text": "Bận thì nhắn \"để hôm khác\" là tớ hiểu ngay.", "requires": [], "targets": "neutral", "role": "decline_door"}
      ],
      "editorial_review": {"layer1": "<reviewer>", "layer2": "<reviewer>", "approved_at": "YYYY-MM-DD"}
    }
  ]
}
```

Khớp là **khớp chuỗi**. `schema_id` sai → `ContentPackageFormatException` ngay
lúc load; vi phạm luật bất biến → **hỏng bản dựng** ở cổng nhập (§5). Không có
trạng thái "im lặng bỏ qua" nào cho cả hai loại lỗi.

**(B) Payload lời mời đã xuất — bảng sqlite `invite_messages`** (drift schema
v5, migration cộng thêm). Local-only, không đồng bộ, không có bản sao trên
server.

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---------|------------|--------------------------|
| Schema id gói preset (mọi danh mục) | `req016.presets.v1` | `expectedSchemaId` của `ContentPackageLoader.load` |
| Danh mục đang hoạt động ở story này | `invite` | `assets/data/req016/presets.invite.v1.json` |
| Danh mục STORY-007 sẽ thêm | `thanks` | `assets/data/req016/presets.thanks.v1.json` |
| Biến mad-libs (đóng, đúng 5) | `activity` · `date` · `time` · `place` · `duration` | trường thẻ tương ứng, §3 |
| Vai clause bắt buộc | `decline_door` | `clauses[].role` |
| Giá trị hợp lệ của `targets` | `sender` · `neutral` | `clauses[].targets` |
| Bảng payload | `invite_messages` | `CupidDatabase.schemaVersion == 5` |

Rules for the consumer side:

- `items[].id` là **id bền** dùng chung với `invite_messages.preset_id` (BR-9,
  BR-14). Append-only: không đổi tên, không tái sử dụng, không xoá một id đã
  ship — payload cũ trỏ vào nó. Chỉ số trong `items` **không bao giờ** là định
  danh (`ContentPackage` đã cấm điều này).
- `schema_id` là hằng dùng chung cho **mọi** danh mục. STORY-007 **không** được
  đặt `req016.presets.thanks.v1` hay bất kỳ biến thể nào — một schema id riêng
  sẽ tạo nhánh cổng nhập thứ hai và vi phạm AC-29.
- `recipient` **không** là giá trị hợp lệ của `targets`; nó không có trong enum
  chứ không phải bị lọc sau (R-1d).

## 3. Gói preset — trường của mỗi item

| Order | Key | Rendered/exposed as | Value contract |
|-------|-----|---------------------|----------------|
| 1 | `id` | không hiển thị | chuỗi không rỗng, duy nhất trong gói, bền vĩnh viễn |
| 2 | `frame` | nhãn chip khung nhại | chuỗi không rỗng; đây là **nội dung**, không lấy từ l10n |
| 3 | `clauses[]` | thân lời mời | ≥ 1 phần tử, giữ nguyên thứ tự khai báo |
| 4 | `clauses[].text` | một câu hoàn chỉnh | chỉ chứa placeholder `{tên_biến}` thuộc bộ 5 biến §2 |
| 5 | `clauses[].requires` | — | danh sách tên biến; clause bị **bỏ nguyên câu** nếu thiếu bất kỳ biến nào trong đây (AC-6) |
| 6 | `clauses[].targets` | — | `sender` \| `neutral` |
| 7 | `clauses[].role` | — | chỉ có một giá trị hợp lệ: `decline_door`; đúng **một** clause mỗi preset mang nó, và clause đó phải có `requires: []` |
| 8 | `editorial_review` | không hiển thị | truy vết kiểm duyệt hai lớp (SB-123/BR-10) theo id bền |

- Bên **soạn nội dung** sở hữu câu chữ, dấu câu, và việc tách câu ngắn. Bên
  **engine** chỉ nối các clause còn sống bằng một dấu cách; nó không viết hoa,
  không thêm/bớt dấu chấm, không sửa ngữ pháp.
- `requires: []` nghĩa là clause luôn còn sống. Vì cửa từ chối bắt buộc
  `requires: []`, **không tồn tại** dữ liệu thẻ nào làm mất câu từ chối (AC-10).
- Khoá lạ ở bất kỳ cấp nào bị bỏ qua; khoá bắt buộc bị thiếu hoặc sai kiểu là
  lỗi load, không phải giá trị mặc định.

## 4. `invite_messages` — cột

| Order | Key | Rendered/exposed as | Value contract |
|-------|-----|---------------------|----------------|
| 1 | `id` | không hiển thị | uuid chuỗi |
| 2 | `card_id` | gắn vào thẻ nguồn | FK `activity_cards.id`, `ON DELETE CASCADE` (BR-2) |
| 3 | `category_id` | không hiển thị | `invite` ở story này |
| 4 | `preset_id` | không hiển thị | `items[].id` của gói, §2 |
| 5 | `pack_version` | không hiển thị | `version` của gói lúc xuất |
| 6 | `filled_values` | không hiển thị | JSON object `{tên_biến: giá_trị_chuỗi}`, chỉ chứa biến có dữ liệu |
| 7 | `user_edited_text` | văn bản đã xuất | `NULL` khi người dùng không sửa; xem quy tắc dưới |
| 8 | `created_at` | không hiển thị | epoch ms, thời điểm người dùng bấm chia sẻ |

- Render lại (AC-18): `user_edited_text ?? render(preset[preset_id], filled_values)`.
  `user_edited_text` là **bản ghi đè thủ công của người dùng (AC-7)**, không
  phải dạng lưu chính; payload vẫn là dữ liệu có cấu trúc (AC-17). Lưu chuỗi
  đã bẹp vào các cột 3-6 là vi phạm hợp đồng.
- Bảng này **không** có và sẽ không có: người nhận, kênh gửi, `sent_at`,
  `opened_at`, `seen_at`, kết quả Share Sheet, hay số lần xuất (R-1b, AC-19).

## 5. Deploy / rollout order

Không có thứ tự triển khai đa phía: một binary duy nhất mang cả engine, gói
nội dung, và schema. Thứ tự duy nhất có thật là **cổng nhập nội dung chạy trước
khi bản dựng ra đời**: `test/features/invite_composer/preset_content_gate_test.dart`
quét mọi file khớp `assets/data/req016/presets.*.json` từ đĩa và chạy
`validatePresetPack`. Gói vi phạm → test đỏ → **bản dựng hỏng**, không có
đường vòng (AC-28/BR-16). Sai thứ tự (ship nội dung chưa qua cổng) là hỏng
**loud**: không có nhánh nào để nó lọt tới người đọc.

Migration v4 → v5 chỉ **thêm** bảng `invite_messages`. `activity_cards` và
`journal_entries` là dữ liệu chỉ tồn tại trên máy người dùng; recreate bị cấm
(`STORY-001/architecture/solution.md` §1 Key Discovery).

## 6. What the consumer must NOT do

- Không đặt câu chữ lời mời/lời cảm ơn vào widget, l10n, hay hằng Dart. Câu chữ
  chỉ sống trong gói asset (R-15a). Ngược lại: **luật** bất biến chỉ sống trong
  `preset_content_gate.dart`, không bao giờ trong asset — nếu không, CMS ngoài
  repo tự nới luật của chính nó.
- Không thêm `schema_id`, nhánh cổng nhập, hay tham số engine riêng cho danh
  mục mới (AC-29).
- Không giả định số preset của một danh mục. `ContentPackage.length` là dữ liệu;
  hành vi hết-tập là **quay vòng modulo `length`**, đúng với N = 1 và N = vài
  trăm. Cấm thông báo "đã hết", màn ngõ cụt, và mọi chỉ báo tiến độ/đếm số
  (AC-26/AC-27/R-15b).
- Không đọc `invite_messages` để đếm, xếp hạng, so sánh, hay A/B test lời mời;
  repository cố ý **không** cung cấp API đếm theo thẻ (R-1e/AC-14).
- Không thêm hành động chính thứ hai lên thẻ. Cửa vào của STORY-008 là một mục
  trong danh sách lựa chọn "Chuẩn bị", không phải nút mới trên thẻ (AC-2/SC-4).
