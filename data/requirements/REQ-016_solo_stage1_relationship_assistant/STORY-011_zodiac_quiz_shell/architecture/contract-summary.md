# Cross-Lane Contract — REQ-016 STORY-011 Vỏ hoàng đạo / trắc nghiệm

Authoritative source: `mobile/lib/features/zodiac_shell/` (STORY-011).
Consumers: một **CMS ngoài repo** sẽ thay nguồn hai gói nội dung dưới đây mà
không kéo theo sửa code (R-15a/BR-12); `features/activity_cards` nhận một giá
trị origin mới. Hợp đồng này tự chứa: consumer không cần mở `solution.md`.

## 1. Envelope

Hai gói asset JSON, không có envelope thứ ba. Không HTTP, không backend, không
API nội dung, không mô hình AI (AC-22/AC-23). **Không có bảng Drift nào**:
`CupidDatabase.schemaVersion` giữ nguyên.

Tái dùng nguyên vẹn `ContentPackage.parse<T>`
(`mobile/lib/core/content/content_package.dart`). Thư mục
`assets/data/req016/` đã khai báo trong `pubspec.yaml` — thêm gói **không**
sửa `pubspec.yaml`.

```json
{
  "id": "zodiac_quiz", "version": "1", "schemaId": "req016.zodiac_quiz.v1",
  "items": [
    { "id": "set.lat_hoang_dao.v1", "kind": "slice",
      "title": "Lát hoàng đạo", "blurb": "Một lát cắt nhẹ để bắt chuyện.",
      "questions_per_round": 1,
      "questions": [
        { "id": "q.dau_cua_ban.v1", "prompt": "Dấu của bạn là gì?",
          "subject": "self",
          "options": [ {"id": "o.bach_duong.v1", "label": "Bạch Dương",
                        "outcome_key": "bach_duong"} ] } ],
      "mapping": [ {"key": "bach_duong", "outcome_id": "out.bach_duong.v1"} ],
      "fallback_outcome_id": "out.chung.v1",
      "editorial_review": {"layer1": "<reviewer>", "layer2": "<reviewer>",
                           "approved_at": "YYYY-MM-DD"} }
  ]
}
```

```json
{
  "id": "zodiac_outcomes", "version": "1",
  "schemaId": "req016.zodiac_outcomes.v1",
  "items": [
    { "id": "out.bach_duong.v1",
      "insight": "Bạn hay quyết nhanh rồi mới cân nhắc.",
      "about_other": false, "ask_line": null,
      "suggestions": [
        {"id": "sg.di_bo.v1", "title": "Rủ đi bộ một vòng vào chiều mát",
         "note": "Mười lăm phút là đủ.", "notebook_tags": ["di_bo"]},
        {"id": "sg.quan_quen.v1", "title": "Quay lại quán hai người từng thích",
         "note": null, "notebook_tags": ["ca_phe"]},
        {"id": "sg.nau_an.v1", "title": "Nấu thử một món bạn ấy hay nhắc",
         "note": null, "notebook_tags": []} ],
      "editorial_review": {"layer1": "<reviewer>", "layer2": "<reviewer>",
                           "approved_at": "YYYY-MM-DD"} }
  ]
}
```

Khớp là **khớp chuỗi**. `schemaId` sai → `ContentPackageFormatException` ngay
lúc parse (lỗi runtime ồn, không mất im lặng). Vi phạm luật bất biến →
`ZodiacContentGateException` ném ở test nạp gói asset thật, **làm hỏng bản
dựng** (AC-33/AC-34).

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---------|------------|--------------------------|
| Gói bộ chơi | `req016.zodiac_quiz.v1` | `assets/data/req016/zodiac_quiz.v1.json` |
| Gói kết quả | `req016.zodiac_outcomes.v1` | `assets/data/req016/zodiac_outcomes.v1.json` |
| Nguồn sinh thẻ | `ActivityCardOrigin.zodiacShell` | `wireValue` = `zodiac_shell` |
| Con trỏ xoay vòng | khoá `SharedPreferences` `zodiac_shell.rotation_cursor.v1` | giá trị: JSON `{"<setId>": <int>}` |
| Ô cửa vào | `QuickEntryCell.zodiacShell` | `activity_quick_entry_slot_2` |

Rules cho consumer:

- `ActivityCardOrigin` là **append-only**: thêm `zodiacShell('zodiac_shell')`
  vào **cuối** enum. Đổi thứ tự hay sửa `wireValue` của giá trị cũ làm hỏng dữ
  liệu thẻ đã lưu mà **không** hỏng bản dựng.
- `id` của mọi item/question/option/suggestion là **khoá bền**; CMS không được
  tái dùng một id cho nội dung khác, và không được dựa vào chỉ số mảng.
- Đừng đặt `zodiac_shell` vào họ gói `req016.presets.v1` — đây là **họ gói
  mới**, không phải danh mục mới của họ preset (STORY-002 §6 cấm).

## 3. `req016.zodiac_quiz.v1` item fields

| Order | Key | Rendered/exposed as | Value contract |
|-------|-----|---------------------|----------------|
| 1 | `id` | không hiển thị | chuỗi không rỗng, bền |
| 2 | `kind` | chọn luồng | `"quiz"` hoặc `"slice"` |
| 3 | `title` | tiêu đề thẻ chọn | chuỗi không rỗng |
| 4 | `blurb` | 1-2 dòng mô tả thẻ chọn | chuỗi, có thể rỗng |
| 5 | `questions_per_round` | số câu mỗi vòng | int ≥ 1, ≤ `questions.length` |
| 6 | `questions[]` | màn hỏi | N ≥ 1, N **là dữ liệu** |
| 6a | `questions[].subject` | quyết định nhãn phỏng đoán | `"self"` hoặc `"guess_about_other"` |
| 6b | `questions[].options[].outcome_key` | khoá ánh xạ | chuỗi không rỗng |
| 7 | `mapping[]` | luật ánh xạ | mỗi phần tử `{key, outcome_id}`; `key` = các `outcome_key` đã chọn nối bằng `+` theo thứ tự câu hỏi |
| 8 | `fallback_outcome_id` | kết quả khi không khớp `mapping` | phải tồn tại trong gói outcomes |
| 9 | `editorial_review` | không hiển thị | 3 trường bắt buộc (SB-123/AC-29) |

- Khoá lạ → bỏ qua im lặng (cho CMS tiến hoá); khoá bắt buộc thiếu →
  `ContentPackageFormatException`.
- `subject: "guess_about_other"` buộc UI dán nhãn **phỏng đoán của người dùng**
  (AC-12). `subject` hỏi về **tần suất/hành vi** người kia bị gate từ chối
  (AC-34, R-1b tầng đầu vào).

## 4. `req016.zodiac_outcomes.v1` item fields

| Order | Key | Rendered/exposed as | Value contract |
|-------|-----|---------------------|----------------|
| 1 | `id` | không hiển thị | chuỗi bền; là đích của `mapping[].outcome_id` |
| 2 | `insight` | đoạn nhận định trên cùng | chuỗi không rỗng, không `%`, không giọng phán quyết |
| 3 | `about_other` | bật khối "câu để hỏi" | bool |
| 4 | `ask_line` | khối "câu để hỏi" | bắt buộc không rỗng **và kết bằng `?`/`？`** khi `about_other == true`; `null` khi `false` (AC-15) |
| 5 | `suggestions[]` | 3 thẻ gợi ý | **độ dài ≥ 3**; app luôn render **đúng 3** |
| 5a | `suggestions[].title` | tiêu đề thẻ + tiêu đề thẻ hoạt động khi thêm vào kho | chuỗi không rỗng, là **một việc làm được ngoài đời** (AC-9) |
| 5b | `suggestions[].note` | dòng phụ | chuỗi hoặc `null` |
| 5c | `suggestions[].notebook_tags[]` | không hiển thị | danh sách tag khớp sổ tay; rỗng là hợp lệ |
| 6 | `editorial_review` | không hiển thị | như §3 |

- **Chọn 3 trong pool**: app lấy các suggestion có `notebook_tags` giao với sổ
  tay trước (giữ nguyên thứ tự gói), rồi bù cho đủ 3 theo thứ tự gói. Sổ tay
  rỗng hoặc đọc lỗi → 3 phần tử đầu (AC-24/AC-25).
- Con số **3** là hợp đồng bố cục (BR-2), **không** phải N của gói (BR-13). Pool
  dài hơn 3 là hợp lệ và không làm lộ số đếm nào ra UI.

## 5. Deploy / rollout order

Không có thứ tự triển khai: cả hai gói nằm trong cùng một bản dựng app với mã
đọc chúng. Nếu CMS phát hành gói mới mà quên một `outcome_id` được `mapping` trỏ
tới, gate từ chối **tại bản dựng** (ồn), không phải lúc người dùng đọc (im lặng)
— đó là lý do luật tham chiếu chéo nằm ở gate chứ không ở runtime.

## 6. What the consumer must NOT do

- Không thêm trường vào `ActivityCard`, không định nghĩa trạng thái thẻ mới
  (BR-7).
- Không thêm `daily`, `valid_from`, `unlocks_at`, `streak`, `play_count`, hay
  bất kỳ khoá theo-thời-gian nào vào hai gói — AC-18/19/20 cấm, và gate từ chối.
- Không thêm khoá điểm số, phần trăm, xếp hạng, hay DẢI ăn khớp (AC-13/AC-14).
- Không dùng `assets/data/req016/compat_*.json` hay `portrait_*.json` làm nguồn
  cho màn này (BR-5/BR-6).
