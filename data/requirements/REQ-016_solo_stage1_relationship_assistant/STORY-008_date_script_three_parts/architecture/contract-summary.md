# Cross-Lane Contract — REQ-016 STORY-008 Kịch bản buổi hẹn 3 phần

Authoritative source: `mobile/lib/features/date_script/` (STORY-008).
Consumers: STORY-009 (chân dung) và STORY-010 (bảng tra) **thêm** liên kết
khoá-vị-trí đi ra từ màn (9); một CMS ngoài repo sẽ thay nguồn gói nội dung.
Hợp đồng này tự chứa: consumer không cần mở `solution.md` hay đọc source.

## 1. Envelope

Hai envelope, không có envelope thứ ba. Không HTTP, không backend, không API nội
dung, không mô hình AI (R-7/AC-12). **Không có bảng Drift nào**: story này không
ghi gì xuống DB, `CupidDatabase.schemaVersion` **giữ nguyên**.

**(A) Gói nội dung — Flutter asset JSON.** Tái dùng nguyên vẹn
`ContentPackage.parse<T>` (`mobile/lib/core/content/content_package.dart`). Đây
là một **họ gói mới**, không phải danh mục mới của họ `req016.presets.v1`
(STORY-002 §6 cấm điều đó). Asset key `assets/data/req016/date_script.v1.json`;
thư mục đã khai báo trong `pubspec.yaml` — thêm gói **không** sửa pubspec.

```json
{
  "id": "date_script", "version": "1", "schemaId": "req016.date_script.v1",
  "items": [
    { "id": "script.ca_phe.v1", "activityTypes": ["dining"],
      "parts": [
        { "part": "before", "sentences": [
          {"text": "Chọn sẵn một chỗ ngồi cạnh cửa sổ.", "requires": [], "aboutPartner": false},
          {"text": "{place} tầm {time} thường vắng hơn.", "requires": ["place","time"], "aboutPartner": false}]},
        { "part": "during", "sentences": [
          {"text": "Nếu bí, kể chuyện của mình trước.", "requires": [], "aboutPartner": false},
          {"text": "Nghe nói bạn ấy thích {interest} — thật ra là thích chỗ nào của nó?", "requires": ["interest"], "aboutPartner": true}]},
        { "part": "after", "sentences": [
          {"text": "Về tới nơi thì nhắn một câu ngắn.", "requires": [], "aboutPartner": false}]}
      ],
      "editorial_review": {"layer1": "<reviewer>", "layer2": "<reviewer>", "approved_at": "YYYY-MM-DD"} }
  ]
}
```

Khớp là **khớp chuỗi**. `schemaId` sai → `ContentPackageFormatException` ngay lúc
load. Vi phạm luật bất biến → **hỏng bản dựng** ở cổng nhập (§5). Không có trạng
thái "im lặng bỏ qua" cho cả hai loại lỗi.

**(B) Điểm nhận điều hướng — một lời gọi Dart trong cùng process**, export ở
đúng một file `mobile/lib/features/date_script/date_script_entry_point.dart`:

```dart
Future<void> openDateScriptScreen(BuildContext context, ActivityCard card);
const String dateScriptEntryPointId = 'date_script';
```

**Cố ý không có tên route.** Không `MaterialPageRoute(settings: ...)`, không mục
trong bảng route. `card` là tham số vị trí bắt buộc, nên "mở màn (9) mà không có
thẻ nguồn" là **lỗi biên dịch**, không phải màn rỗng lúc chạy (AC-4/BR-1).

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---|---|---|
| Schema id gói kịch bản | `req016.date_script.v1` | `expectedSchemaId` lúc parse |
| Asset key | `assets/data/req016/date_script.v1.json` | hằng `dateScriptAssetKey` |
| Ba phần (tập ĐÓNG, đúng 3) | `before` · `during` · `after` | `parts[].part` |
| Biến mad-libs từ thẻ | `activity` · `date` · `time` · `place` · `duration` | trường `activity_cards`, §3 |
| Biến mad-libs từ sổ tay | `interest` · `event` | `notebook_entries.kind`, §3 |
| Cửa vào hỏi-tại-chỗ | `date_script` | `AskOnTheSpotSlot.entryPointId` |
| Trường sổ tay cần hỏi | `notebook.interest`, rồi `notebook.event` | `AskOnTheSpotSlot.neededFieldIds` |
| Nguồn sinh thẻ mới | `ActivityCardOrigin.dateScript` = `date_script` | đã dành sẵn ở `STORY-001/.../contract-summary.md` §2 |

Rules for the consumer side:

- `items[].id` là **id bền**: append-only, không đổi tên, không tái dùng, không
  xoá một id đã ship (`editorial_review` truy vết theo nó, AC-31). Chỉ số trong
  `items` **không bao giờ** là định danh.
- Bảy biến mad-libs là tập **ĐÓNG**. Suýt trúng hay gặp và đều **sai**:
  `activityType`, `place_name`, `durationMinutes`, `interests` (số nhiều),
  `partner_interest`. Biến lạ → gate từ chối gói.
- `aboutPartner` là `bool` của **từng câu**, không phải của cả phần. Đừng dùng
  `targets`/`recipient` — hai từ đó thuộc họ gói lời mời và `recipient` bị cấm
  ở đó vì lý do khác (R-1d).
- Nhãn "Trước/Trong/Sau" và nhãn ba cửa ra là **nhãn chức năng của widget**,
  không phải nội dung: chúng không có trong gói và không lấy từ gói.

## 3. `items[]` fields

| Order | Key | Rendered/exposed as | Value contract |
|---|---|---|---|
| 1 | `id` | không hiển thị | ASCII, duy nhất trong gói, bền vĩnh viễn |
| 2 | `activityTypes` | không hiển thị | danh sách wire value của `ActivityType`; **rỗng = preset tổng quát**. Gói phải có ≥1 preset tổng quát |
| 3 | `parts[]` | ba đoạn của segmented control | đúng 3 phần tử, đúng một lần mỗi giá trị `before`/`during`/`after` |
| 4 | `parts[].sentences[]` | thân đoạn văn | ≥1 phần tử, giữ nguyên thứ tự khai báo; ≥1 câu phải có `requires: []` |
| 5 | `sentences[].text` | một câu hoàn chỉnh | chỉ chứa placeholder `{tên_biến}` thuộc bộ 7 biến §2 |
| 6 | `sentences[].requires` | — | câu bị **bỏ nguyên** nếu thiếu bất kỳ biến nào trong đây; mọi `{var}` trong `text` phải có mặt ở đây |
| 7 | `sentences[].aboutPartner` | — | `true` ⇒ `text` phải kết thúc bằng `?` (R-1g/AC-26) |
| 8 | `editorial_review` | không hiển thị | `layer1`, `layer2`, `approved_at` đều bắt buộc (SB-123/BR-13) |

- Bên **soạn nội dung** sở hữu câu chữ và dấu câu. Bên **engine** chỉ nối các câu
  còn sống bằng một dấu cách: không viết hoa, không thêm/bớt dấu chấm, không sửa
  ngữ pháp — đúng quy ước renderer STORY-002 §3.
- Khoá lạ ở bất kỳ cấp nào bị bỏ qua; khoá bắt buộc thiếu hoặc sai kiểu là lỗi
  load, không phải giá trị mặc định.
- **Chọn preset** là hàm toàn phần tất định của `(pack, card)`: lọc theo
  `activityTypes` chứa `card.activityType`; rỗng thì rơi về tập preset tổng
  quát; chọn phần tử bằng một **hash ổn định tự định nghĩa** trên `card.id`
  modulo số ứng viên. `card.activityType == null` đi thẳng nhánh tổng quát.
  **Không** dùng `String.hashCode`, `Random`, đồng hồ, hay thứ tự chèn.
- **Chọn giá trị sổ tay** cũng phải tất định: sắp `NotebookEntry` theo `id` tăng
  dần rồi lấy phần tử đầu đúng `kind`. Không xếp hạng độ liên quan, không ưu
  tiên theo thời gian — cả hai đều là đại lượng hành vi (R-1b).

## 4. Deploy / rollout order

Một binary, không có thứ tự triển khai đa phía. Hai thứ tự có thật:

1. **Cổng nhập chạy trước khi bản dựng ra đời.** Test quét
   `assets/data/req016/date_script.*.json` từ đĩa và chạy `validateDateScriptPack`.
   Gói vi phạm → test đỏ → **bản dựng hỏng** (AC-36/BR-18). Sai thứ tự là hỏng
   **loud**, không có nhánh nào để vi phạm lọt tới người đọc.
2. **STORY-003/002/001 phải merge trước.** Gọi entry point của chúng khi file
   chưa tồn tại là lỗi biên dịch (ồn ào, đúng ý), không phải mất âm thầm.

Không có bước migration: story này không sinh DDL.

## 5. What the consumer must NOT do

- Không tạo tên route, deep link, hay mục tab/menu trỏ tới màn (9), và không
  thêm nút share/copy-link **trên** màn (9) — mọi affordance kiểu đó là cửa
  ngách tương đương deep link, vi phạm SC-6 dù route vẫn khoá đúng (AC-3/AC-4).
- Không đưa câu chữ kịch bản vào widget, l10n, hay hằng Dart. Ngược lại: **luật**
  bất biến chỉ sống trong Dart (`core/content/invariant_terms.dart` +
  `date_script_content_gate.dart`), không bao giờ trong asset — nếu không, CMS
  ngoài repo tự nới luật của chính nó (R-15c).
- Không sao chép danh sách từ cấm sang feature này. Tầng từ vựng gọi
  `invariantHitsIn`; gate của story chỉ thêm luật **cấu trúc**.
- Không giả định số preset. `ContentPackage.length` là dữ liệu; hết-tập là quay
  vòng modulo `length`. Cấm "đã hết kịch bản", màn ngõ cụt, chỉ báo tiến độ, và
  mọi hiển thị đếm số (AC-34/AC-35/R-15b).
- Không lưu lịch sử kịch bản đã đọc, không con trỏ xoay vòng xuống DB, không
  danh sách "kịch bản của tôi" (AC-22/BR-6).
- Không đọc/ghi bất cứ gì của `journal`, `invite_composer`, `context_notebook`
  ngoài entry-point file của chúng, kể cả khi phân tích tĩnh cho phép.
- Không thêm timer, bộ đếm ngược, thông báo, hay bất kỳ phụ thuộc scheduler nào
  vào feature này; `scheduledOn` chỉ là giá trị mad-libs, **không bao giờ** là
  điều kiện kích hoạt (AC-13/AC-15/BR-3).
- Không thêm hành động chính thứ hai lên thẻ: cửa vào là một hàng trong sheet
  "Chuẩn bị", ở dưới "Xuất lời mời" (AC-6/SC-4).
