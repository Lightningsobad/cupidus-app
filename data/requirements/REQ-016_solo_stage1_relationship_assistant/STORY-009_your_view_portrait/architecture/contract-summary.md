# Cross-Lane Contract — REQ-016 STORY-009 Chân dung "theo cách BẠN nhìn"

Authoritative source: `mobile/` (STORY-009).
Consumers: `mobile/` STORY-008 (thêm **giá trị** cửa vào thứ hai), STORY-010
(tái dùng nguyên khối nhãn xuất xứ và khối "Câu để hỏi"). Hợp đồng này tự chứa:
consumer không cần mở `solution.md` hay đọc source để cài đặt theo nó.

## 1. Envelope

Ba envelope, không có envelope thứ tư. Không HTTP, không backend, không API nội
dung, không mô hình AI ở bất kỳ đường đi nào (AC-30/BR-8).

**(A) Gói nội dung — Flutter asset JSON.** Tái dùng nguyên vẹn
`ContentPackage`/`ContentPackageLoader` (`mobile/lib/core/content/content_package.dart`).
Ba gói, **ba `schema_id` riêng** vì hình dạng item khác hẳn nhau — họ gói mới,
không phải danh mục mới của `req016.presets.v1`. Thư mục `assets/data/req016/`
đã khai báo trong `pubspec.yaml`: thêm gói **không** sửa `pubspec.yaml`.
`schema_id` sai → `ContentPackageFormatException` lúc load; vi phạm luật bất
biến → **hỏng bản dựng** ở cổng nhập (§5).

**(B) Câu trả lời — bảng Drift cục bộ `portrait_answers`.** Local-only, không
đồng bộ, không bản sao trên server.

**(C) Hai API Dart trong tiến trình** (§3). Sai khớp tên trường là **lỗi biên
dịch Dart**, không mất dữ liệu âm thầm.

## 2. Identifiers — copy exactly

| Mục đích | Định danh | Ràng buộc |
|---|---|---|
| Gói bộ câu hỏi | `req016.portrait_questions.v1` | `assets/data/req016/portrait_questions.v1.json` |
| Gói đoạn chân dung + luật ánh xạ | `req016.portrait_sections.v1` | `assets/data/req016/portrait_sections.v1.json` |
| Kho câu-để-hỏi | `req016.portrait_asks.v1` | `assets/data/req016/portrait_asks.v1.json` |
| Đích của một câu trả lời | `notebook.interest` · `notebook.event` · `portrait.guess` | `questions[].target`; enum đóng `PortraitAnswerTarget`, giá trị lạ là lỗi load |
| Cửa vào màn (8) | `gift_ideas` | `PortraitEntrySource`; STORY-008 thêm `date_script` là thêm **giá trị**, không thêm cơ chế |
| Trạng thái một câu | `answered` · `skipped` | cột `portrait_answers.state` |
| Khuôn câu mở đầu hợp lệ | `Theo cách bạn kể` · `Bạn đang thấy` · `Bạn kể rằng` · `Theo cách bạn nhìn` | hằng Dart trong `portrait_content_gate.dart`, **không bao giờ** trong asset (AC-13/BR-4) |

Quy tắc cho phía tiêu thụ:

- `items[].id` của cả ba gói là **id bền**: append-only, không đổi tên, không tái
  dùng, không xoá một id đã ship (`portrait_answers` và sổ tay trỏ ngược vào nó).
- Chỉ số trong `items` **không bao giờ** là định danh; thứ tự hiển thị là thứ tự
  khai báo.
- `portrait.guess` **không** là một giá trị của `AskTarget` (STORY-004) và không
  bao giờ được thêm vào đó — hai enum, hai đích, cố ý tách.

## 3. API Dart — hai cửa duy nhất

```dart
// mobile/lib/features/your_view_portrait/your_view_portrait_entry_point.dart
enum PortraitEntrySource { giftIdeas }
Future<void> openYourViewPortrait(BuildContext context,
    {required PortraitEntrySource from});

// mobile/lib/features/context_notebook/context_notebook_entry_point.dart
// Bản sửa đổi §6 hợp đồng STORY-004: cửa ghi thứ hai, hẹp, và duy nhất.
Future<String> recordAnsweredQuestion({
  required String entryPointId,   // 'your_view_portrait'
  required String questionId,     // id bền của gói câu hỏi
  required NotebookKind kind,     // CHỈ interest | event
  required String value,
  String? detail,
  String? eventOn,
});                               // trả về notebook_entries.id vừa tạo
```

- Widget màn (8) là **private trong thư viện feature**, không export, không
  `routeName`, không có mặt trong `routes:` của `cupid_app.dart`: không tồn tại
  cách dựng nó ngoài `openYourViewPortrait` (AC-2/AC-3, cưỡng chế ở biên dịch).
- `openYourViewPortrait` push lên **chính Navigator của luồng nguồn**; cấm
  `pushReplacement`, cấm `rootNavigator: true`, cấm `popUntil` — đó là cách luồng
  (5) mất tiến độ khi đóng màn (AC-4).
- `recordAnsweredQuestion` ghi `source = 'ask_on_the_spot'`, `question_id` bắt
  buộc non-empty. **Không** có biến thể bulk/import/điền-trước, **không** sửa,
  **không** xoá, **không** đọc-tất-cả: những cửa đó là thứ §6 của STORY-004 cấm,
  và bản sửa đổi này không mở chúng.

## 4. Gói nội dung — trường của mỗi item

`portrait_questions`: `id` · `prompt` (câu hỏi, **là nội dung**, không l10n) ·
`target` (§2) · `chips[]` (≥ 1) · `allow_free_text` (bool) · `editorial_review`.

`portrait_sections`: `id` · `heading` · `bindings` (`{tên_biến: question_id}`) ·
`clauses[]` (`text` chứa `{tên_biến}`, `requires[]` là tên biến) · `ask_ids[]`
(≥ 1, mỗi id phải có trong kho câu-để-hỏi) · `editorial_review`.

`portrait_asks`: `id` · `text` (kết thúc bằng `?`) · `editorial_review`.

- Clause thiếu bất kỳ biến trong `requires` bị **bỏ nguyên câu** (ngữ nghĩa
  STORY-002). Phần còn 0 clause sống vẫn hiện, **chỉ** với dòng câu-để-hỏi
  (AC-19/BR-9) — không khối rỗng, không "chưa đủ dữ liệu".
- Bên soạn nội dung sở hữu câu chữ và dấu câu; engine chỉ nối các clause còn
  sống bằng một dấu cách, không viết hoa, không thêm/bớt dấu chấm.
- Khoá lạ bị bỏ qua; khoá bắt buộc thiếu hoặc sai kiểu là lỗi load, không phải
  giá trị mặc định.
- Giá trị của một biến trỏ tới `target: notebook.*` đọc từ **sổ tay**, không từ
  bản sao trong `portrait_answers`: người dùng sửa/xoá mục sổ tay thì chân dung
  mỏng đi, không lệch nhau (AC-22).

## 5. `portrait_answers` — cột và thứ tự triển khai

PK gộp (`owner_key`, `question_id`) · `owner_key` TEXT NOT NULL (backend
`User.id`) · `question_id` TEXT NOT NULL · `state` TEXT NOT NULL (§2) ·
`option_id` TEXT NULL (chip đã chọn) · `answer_value` TEXT NULL (**chỉ** khi
`target == portrait.guess`) · `notebook_entry_id` TEXT NULL (**chỉ** khi
`target == notebook.*`) · `updated_at` DATETIME NOT NULL.

**Cột bị cấm vĩnh viễn** (R-1b/AC-12/AC-28, cưỡng chế ở test): mọi cột đếm, điểm,
%, mức độ, streak, `completed_at`, `answered_count`, và mọi cột đo hành vi người
kia. Không lưu con trỏ xoay vòng kho câu-để-hỏi xuống DB — nó sống trong Cubit,
đúng một vòng đời màn.

Hai thứ tự có thật:

1. **Cổng nhập nội dung chạy trước khi bản dựng ra đời.**
   `mobile/test/features/your_view_portrait/portrait_content_gate_test.dart` quét
   ba gói từ đĩa và chạy `validatePortraitPacks`; gói vi phạm → test đỏ → **bản
   dựng hỏng** (AC-36/AC-37/BR-17). Không có nhánh nào để vi phạm lọt tới người
   đọc.
2. **Migration cộng thêm.** `portrait_answers` là DDL mới nên `schemaVersion` +1;
   `CREATE TABLE` thôi, huỷ-tạo-lại bị cấm tuyệt đối. Đọc giá trị thật trên nhánh
   tích hợp lúc cài đặt rồi cộng một — **không** chép con số từ tài liệu này.

## 6. Phía tiêu thụ KHÔNG được làm

- Không đăng ký màn (8) vào `routes:`, không đặt `routeName`, không nhận deep
  link — cửa vào là một **giá trị** mới của `PortraitEntrySource` (AC-3).
- Không đặt câu chữ hỏi/đoạn chân dung/câu-để-hỏi vào widget, l10n, hay hằng
  Dart. Ngược lại: **luật** bất biến (khuôn câu mở đầu, denylist) chỉ sống trong
  Dart, không bao giờ trong asset — nếu không, CMS ngoài repo tự nới luật của
  chính nó (R-15c).
- Không hiện nhãn xuất xứ ở dạng tooltip, banner tắt-được, hay chú thích chân
  màn; mọi bề mặt nhắc lại nội dung chân dung mang nhãn đi cùng (AC-6..AC-8).
- Không giả định số mục của một gói; hết-kho là quay vòng modulo `length`. Cấm
  "đã hết câu hỏi", màn ngõ cụt, chỉ báo tiến độ, phần trăm, đếm số (AC-35).
- Không thêm chức năng xuất/chia sẻ/sao chép chân dung dưới bất kỳ tên nào
  (AC-24), và không đọc `portrait_answers` để đếm hay xếp hạng.
