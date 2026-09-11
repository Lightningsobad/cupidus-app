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

## Phase P2 – Chọn preset tất định và dựng câu mad-libs

- Owner: Mobile Developer
- Status: COMPLETE
- Last updated: 2026-09-11

### Commands

Chạy trong worktree story, `cwd = mobile/`, Flutter 3.44.1 / Dart 3.12.1.

| Command | Result |
|---|---|
| `flutter test test/features/date_script/` | PASS — `00:06 +88: All tests passed!` (52 test P1 + 36 test P2) |
| `flutter analyze lib/features/date_script test/features/date_script` | PASS — `Analyzing 2 items... No issues found! (ran in 3.9s)` |

Không chạy repo-wide `flutter analyze` (baseline repo khác 0). Startup smoke
`NOT_APPLICABLE` theo phase file: phase này thuần Dart, không widget, không DB,
không đổi đường khởi động app.

### Files

- `mobile/lib/features/date_script/domain/date_script_selector.dart`
- `mobile/lib/features/date_script/domain/date_script_renderer.dart`
- `mobile/test/features/date_script/date_script_selector_test.dart` (18 test)
- `mobile/test/features/date_script/date_script_renderer_test.dart` (18 test)

Không file nào của P1 bị sửa; gói nội dung và cổng nhập giữ nguyên.

### AC coverage

| AC / Rule | Evidence |
|---|---|
| AC-8 (cùng đầu vào → cùng kịch bản) | selector_test `returns the same preset on 100 consecutive calls`; renderer_test `bindVariables is deterministic across repeated calls`, `the same card and notebook render identically twice` |
| AC-34 / BR-17 / R-15b (chọn preset toàn phần, mọi N) | selector_test `is total over every ActivityType and over null` (chạy trên gói ship thật), `falls back to generic for a type no preset declares`, `falls back to generic when the card has no type at all`, `serves a pack of exactly one preset` |
| AC-10 / AC-37 (không ô trống, không placeholder lộ) | renderer_test `drops exactly the sentences that need the one missing variable` (ma trận 7/7 biến), `leaves no brace behind for any card/notebook combination` (9 loại thẻ × đầy/trống × 4 sổ tay) |
| AC-23 / BR-9 (sổ tay trống vẫn dùng được cả ba phần) | renderer_test `every part still reads with an empty notebook and a bare card`, `keeps the unconditional sentence when nothing is bound` |
| AC-35 / R-15b (quay vòng, không ngõ cụt, không đếm số) | selector_test nhóm `cycleIndex`: length 1, 2, N=347, con trỏ âm, `has no exhausted state` |
| BR-12 / R-1b / R-1f (chỉ sở thích + sự kiện, không đo hành vi) | renderer_test `picks the lowest notebook id regardless of the order passed in` — không xếp hạng liên quan, không ưu tiên mới nhất; `an entry of the other kind never fills a variable` |
| §3/§5 (nguồn tất định tự định nghĩa) | selector_test `matches the published FNV-1a 32-bit vectors`, `is not String.hashCode`, `depends on byte order, not just on the set of bytes` |
| §3 (engine chỉ nối, không sửa ngữ pháp) | renderer_test `joins surviving sentences with exactly one space`, `preserves the authored order of the surviving sentences` |
| AC-1, AC-5, AC-6, AC-22, AC-24 | NOT IN P2 — thuộc P3/P4 (đường vào, khoá vị trí, hỏi-tại-chỗ, ba cửa ra). Phase file liệt kê chúng làm input ngữ cảnh |

### Negative controls / anti-vacuity

| Rủi ro | Bằng chứng test bắt được |
|---|---|
| Đổi sang `String.hashCode` về sau | ba vector FNV-1a viết thẳng (`0x811c9dc5`, `0xe40c292c`, `0xbf9cf968`) + `is not String.hashCode` |
| Hash chỉ XOR/cộng byte | `depends on byte order` (`abc` ≠ `cba`) |
| Selector trả hằng số (vẫn "tất định") | `spreads different card ids across the candidates` + `each card keeps its own preset when others are added` |
| Ma trận drop thả nhầm câu khác | mỗi vòng lặp assert **cả hai** chiều: câu thiếu biến biến mất *và* sáu câu còn lại nguyên vẹn, cộng câu neo `requires: []` |
| Sổ tay chọn theo thứ tự truyền vào | cùng danh sách gọi hai lần, lần hai `.reversed`, cùng kết quả |
| Gói không có preset chung lọt qua im lặng | `rejects a package with no generic preset loudly` |

### Notes / deviations

1. **`renderScript` bổ sung ngoài §3.** §3 chỉ liệt kê `bindVariables` và
   `renderPart`, nhưng §1B khai `renderScript(...)` là bề mặt P3 tiêu thụ. Đã
   thêm dưới dạng `Map<DateScriptPart, String>`: nối các câu sống sót của từng
   phần bằng đúng một dấu cách, đúng luật "engine chỉ nối" của §3. `renderPart`
   vẫn trả `List<String>` đúng chữ ký §3 nên P3 chọn mức nào cũng được.
2. **`selectPreset` ném khi gói không có preset chung.** §3 phase nói hàm "không
   bao giờ ném" — điều đó đúng *với gói hợp lệ*, mà P1 gate đã bảo đảm. Với gói
   do CMS ngoài repo dựng thẳng trong bộ nhớ (không đi qua gate), im lặng là
   lựa chọn tệ hơn `RangeError`, nên hàm ném `ContentPackageFormatException`
   nêu đích danh gói. Cùng tinh thần "hỏng loud" của §4.
3. **Trích dẫn AC sai trong phase file P2.** §4 gán "Sổ tay trống → kịch bản vẫn
   có nội dung dùng được ở cả ba phần" cho **AC-6**. AC-6 thật sự nói về việc
   không thêm hành động chính cấp thẻ thứ hai (SC-4). Luật đúng là **AC-23** (sổ
   tay trống vẫn ra bản mặc định dùng được) cộng **AC-34** (mọi thẻ vẫn đủ ba
   phần). Đây là **cùng một lỗi trích dẫn AC-6** đã ghi ở P1 mục 3 — hai phase
   file độc lập cùng dẫn sai một AC. Code và test bám AC-23/AC-34.
4. **`ContextEntrySource` phải import trực tiếp trong test.**
   `context_notebook_entry_point.dart` export `NotebookEntry`/`NotebookKind`
   nhưng **không** export `ContextEntrySource`, trong khi `NotebookEntry.source`
   là trường bắt buộc — nên không thể dựng fixture chỉ qua entry point. Test
   import thêm `domain/context_notebook_models.dart show ContextEntrySource`,
   kèm chú thích. Code `lib/` vẫn chỉ đi qua entry point đúng §5. Nếu STORY-009/
   010 cũng cần dựng fixture sổ tay, cân nhắc bổ sung export ở entry point (nằm
   ngoài write scope P2).
5. **Bốn từ buổi trong ngày lặp lại.** `_timeOfDayWord` (sáng/trưa/chiều/tối) là
   bản sao của helper private cùng tên trong `invite_composer`. §5 cấm feature
   này chạm nội tại của feature kia, nên bốn từ sống ở cả hai nơi thay vì sau
   một import chung. Đây là rendering giá trị của enum đóng, không phải câu chữ
   kịch bản, nên không vi phạm R-15a.
6. **Không có `DateTime.now()` trong feature.** Mọi thứ phụ thuộc ngày đi qua
   `ActivityCard.scheduledOn`/`timeOfDaySlot`; `formatLongViDate` và
   `formatDurationMinutes` dùng lại của `activity_cards` nên ngày và thời lượng
   đọc giống hệt trên thẻ và trong kịch bản.
