# Test Results – STORY-008 Kịch bản buổi hẹn 3 phần

## Phase P1 – Họ gói `req016.date_script.v1` và cổng nhập nội dung

- Owner: Mobile Developer
- Status: COMPLETE
- Last updated: 2026-09-11

### Commands

Chạy trong worktree story, `cwd = mobile/`, Flutter 3.44.1 / Dart 3.12.1.

| Command | Result |
|---|---|
| `flutter pub get` | PASS |
| `flutter gen-l10n` | PASS |
| `flutter test test/features/date_script/` | PASS — `00:00 +52: All tests passed!` |
| `flutter analyze lib/features/date_script test/features/date_script` | PASS — `Analyzing 2 items... No issues found! (ran in 1.6s)` |

Không chạy repo-wide `flutter analyze`: baseline của repo khác 0 nên nó không
dùng làm bằng chứng cổng được. Startup smoke `NOT_APPLICABLE` theo phase file —
phase này không đổi đường khởi động app, không có widget, không đụng DB.

### Files

- `mobile/assets/data/req016/date_script.v1.json` (10 preset seed)
- `mobile/lib/features/date_script/domain/date_script_content.dart`
- `mobile/lib/features/date_script/domain/date_script_content_gate.dart`
- `mobile/test/features/date_script/date_script_content_test.dart` (23 test)
- `mobile/test/features/date_script/date_script_content_gate_test.dart` (29 test)

`pubspec.yaml` không đổi: `assets/data/req016/` đã khai báo sẵn.

### AC coverage

| AC / Rule | Evidence |
|---|---|
| AC-7 (đúng ba phần, đúng thứ tự) | content_test `every preset carries the three parts in order`; parser ném ở `an unknown part name` / `a missing part` / `the three parts out of order`; gate_test `a preset missing a part`, `the three parts in the wrong order` |
| AC-10 / AC-37 (không ô trống, không placeholder lộ) | content_test `every part has an unconditional sentence`, `every placeholder is one of the seven variables and is declared`; gate_test `a part whose every sentence is conditional`, `a placeholder that is not declared in "requires"` |
| AC-26 / R-1g (câu về người kia kết bằng `?`) | content_test `every sentence about the other person ends in a question`; gate_test `a sentence about the other person that does not ask` + control ngược `... that does ask is clean` |
| AC-31 / SB-123 / BR-13 (kiểm duyệt hai lớp truy vết theo id bền) | gate_test `a missing editorial_review`, `an editorial_review without approved_at`; content_test `every preset id is unique and printable ASCII` |
| AC-33 / BR-16 / R-15a (nội dung là dữ liệu có lược đồ) | content_test `parses under its own schema id`, `a pack under another schema id`; gate_test `no shipped script wording lives in a Dart file under the feature` |
| AC-34 / BR-17 / R-15b (chọn preset toàn phần, ≥1 preset chung) | content_test `the pack ships at least one generic preset` + `... at least one activity-typed preset too`; gate_test `a pack with no generic preset` |
| AC-36 / BR-18 / R-15c (cổng nhập làm hỏng bản dựng) | gate_test `the shipped pack ... reports no violation at all` chạy trên file thật từ đĩa; 16 negative control bên dưới |
| AC-13 / AC-14 / BR-3 (ranh giới J7) | gate_test `the "during" part never tells the reader to touch the app` + control ngược `the J7 scan actually catches an app instruction` |
| AC-5, AC-6, AC-24 (đường vào, hành động cấp thẻ, hỏi-tại-chỗ) | NOT IN P1 — thuộc P3; phase file liệt kê chúng làm input ngữ cảnh |

### Negative controls (cổng nhập thực sự bắt được)

Mọi luật cấu trúc và mọi luật từ vựng đều có một control ngược khẳng định gate
trả về đúng rule cho đúng preset/câu. Control cơ sở `the clean fixture reports
nothing` chứng minh các test còn lại cô lập đúng một luật, nên không test nào
vacuously pass.

| Rule | Negative control |
|---|---|
| `parts_shape` | thiếu phần · sai thứ tự |
| `generic_preset_missing` | gói chỉ có preset theo loại (`presetId == null`, cấp gói) |
| `unconditional_sentence_missing` | phần `during` chỉ có câu điều kiện (detail nêu đúng tên phần) |
| `undeclared_placeholder` | `{place}` với `requires: []` (detail nêu đúng câu) |
| `partner_sentence_not_question` | câu `aboutPartner: true` kết bằng dấu chấm |
| `duplicate_preset_id` | hai preset cùng id |
| `non_ascii_preset_id` | id `kịch_bản.v1` |
| `editorial_review_incomplete` | thiếu cả khối · thiếu `approved_at` |
| tầng từ vựng (6 rule `InvariantRule`) | một control cho mỗi rule, cộng test `"địa điểm" is not a score` chứng minh khớp nguyên từ vẫn còn |
| tầng ranh giới sổ tay (3 rule `NotebookBoundaryRule`) | một control cho mỗi rule |
| R-15c (không denylist thứ hai) | `the feature declares no second denylist` + control ngược `the denylist scan actually catches a copied term` |

### Notes / deviations

1. **Khoá wire của `schema_id`.** `contract-summary.md` §1 in ví dụ JSON là
   `"schemaId"`, nhưng `ContentPackage.parse` đọc `schema_id` (snake) và mọi gói
   `req016.*` đang ship đều dùng `schema_id`. Gói mới dùng `schema_id`; ví dụ
   trong §1 là lỗi chính tả của artifact, không phải hợp đồng khác.
2. **Phân vai parser ↔ gate cho `{biến}`.** Parser từ chối *tên biến lạ*
   (`ContentPackageFormatException`); gate sở hữu luật *"đã dùng nhưng chưa khai
   báo trong `requires`"*. Tách như vậy để luật gate không vacuous — nếu parser
   bắt luôn cả hai thì negative control của luật 4 không bao giờ tới được gate.
   Tương tự, luật `parts_shape` của gate là cho gói do CMS dựng thẳng trong bộ
   nhớ, không đi qua parser của repo này.
3. **Trích dẫn AC sai trong phase file.** Phase P1 §3 và §4 gán "mỗi phần phải có
   ít nhất một câu `requires: []`" cho **AC-6**. AC-6 thật sự nói về việc không
   thêm hành động chính cấp thẻ thứ hai (SC-4). Luật đúng là **AC-10** (không ô
   trống / không placeholder lộ) và **AC-37** (bảo đảm AC-10 cho mọi preset ở
   mọi N). Code và test bám AC-10/AC-37; không đổi hành vi, chỉ đổi trích dẫn.
4. **Tầng từ vựng gọi cả `notebookBoundaryHitsIn`.** Theo phase §3, gate uỷ quyền
   cho cả hai hàm, nên câu kịch bản cũng bị chặn nếu hỏi sang tần suất/hành vi/
   đánh giá con người (R-1b/R-1f/BR-12).
5. **Seed 10 preset** (3 chung + 7 theo loại hoạt động) đúng tinh thần BR-17:
   N là dữ liệu bản đầu. Không AC/test nào của P1 dựa vào con số 10; test chỉ
   assert "≥1 preset chung" và "≥1 preset theo loại".
6. **Danh sách cụm J7** nằm trong test, không nằm trong gate — đúng chỉ định
   phase §6, và vì nó là heuristic duyệt văn xuôi, không phải luật lược đồ.
