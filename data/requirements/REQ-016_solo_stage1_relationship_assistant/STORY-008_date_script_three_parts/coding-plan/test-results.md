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

## Phase P3 – Đường vào khoá vị trí và màn hình (9)

- Owner: Mobile Developer
- Status: COMPLETE
- Last updated: 2026-09-17

### Commands

Chạy trong worktree story, `cwd = mobile/`, Flutter 3.44.1 / Dart 3.12.1.

| Command | Result |
|---|---|
| `flutter test test/features/date_script/` | PASS — `+110 ~1: All other tests passed!` (88 test P1+P2, 22 test P3; 1 skip là nhóm chụp ảnh khi không bật dart-define) |
| `flutter test test/features/date_script/ test/features/invite_composer/` | PASS — `+231 ~1: All other tests passed!` (hồi quy bắt buộc vì P3 sửa `prepare_actions_sheet.dart`) |
| `flutter test test/features/date_script/date_script_screen_test.dart --dart-define=CAPTURE_VISUALS=true --plain-name="visual fidelity capture"` | PASS — `+1: All tests passed!`, sinh 3 PNG |
| `flutter analyze lib/features/date_script lib/features/invite_composer test/features/date_script test/features/invite_composer` | `11 issues found` — 0 error, 0 warning, toàn bộ là `info • prefer_initializing_formals` (3 ở cubit mới, 8 có sẵn trong `invite_composer`). Hai file test P3 sạch |

Không chạy repo-wide `flutter analyze` (baseline repo khác 0). Startup smoke
`NOT_APPLICABLE`: màn hình (9) không đăng ký route, không đổi đường khởi động
app, không đụng schema DB.

### Files

- `mobile/lib/features/date_script/date_script_entry_point.dart` (mới)
- `mobile/lib/features/date_script/presentation/screens/date_script_screen.dart` (mới)
- `mobile/lib/features/date_script/presentation/cubit/date_script_cubit.dart` (mới)
- `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart` (sửa: thêm hàng thứ hai + seam `DateScriptOpener`)
- `mobile/test/features/date_script/date_script_screen_test.dart` (mới, 9 test)
- `mobile/test/features/date_script/date_script_location_lock_test.dart` (mới, 14 test)
- `mobile/test/features/invite_composer/prepare_actions_sheet_test.dart` (sửa, 2 test AC-27 — xem deviation 3)
- `mobile/test/features/date_script/visual-fidelity/implemented-screen-9-kich-ban-buoi-hen-{truoc,trong,so-tay-trong}.png`

Không file nào của P1/P2 bị sửa; gói nội dung, selector và renderer giữ nguyên.

### AC coverage

| AC / Rule | Evidence |
|---|---|
| AC-2 / SC-6 (chỉ một cửa vào, từ hành động cấp thẻ) | location_lock_test `a scheduled card offers the script row, second in the sheet`; `openDateScriptScreen is declared once and called from one file only` |
| AC-4 / BR-1a (không ngữ cảnh thì không có màn hình) | `card` là tham số vị trí bắt buộc ở `openDateScriptScreen` → mở thiếu thẻ là lỗi biên dịch; location_lock_test `the entry point pushes an anonymous route and exports nothing else` |
| AC-2 / SC-6 (khoá vị trí: không route, không deep link, không tab/menu) | location_lock_test part 3: `no file that names the date script registers a route for it`, `no route-shaped string literal names the date script`; quét toàn `lib/` |
| AC-2 / SC-6 (thẻ chưa hẹn ngày không có cửa) | location_lock_test part 2 sinh một test cho *mỗi* `ActivityCardStatus` khác `scheduled` + `the status scan covered every value there is` |
| AC-7 (ba phần, đổi phần là đổi trạng thái thuần) | screen_test `the screen opens on "Trước" with a rendered paragraph`, `switching parts keeps the same script and never re-reads the pack (AC-7)` (assert `bundle.loads == 1` và `notebook.reads == 1`) |
| AC-13…AC-16 / BR-3 (ranh giới J7) | screen_test `no part offers a timer, a countdown, or a "start" control` (bơm 30 phút mỗi phần, `bottomNavigationBar == null`); location_lock_test `nothing under the feature can move on its own clock` |
| BR-3 (nhắc "đọc trước khi đi", chỉ ở phần *Trong*) | screen_test `only "Trong" carries the J7 guard caption (BR-3)`; caption nằm trong Dart, không nằm trong gói nội dung |
| AC-5 / AC-23 (sổ tay trống vẫn ra kịch bản dùng được) | screen_test `an empty notebook still renders a usable script (AC-5)` |
| AC-5 / AC-25 (đúng một câu hỏi trên một route) | screen_test `an empty notebook shows exactly one question (AC-5/AC-25)` — dùng `AskOnTheSpotSlot` thật + `CupidDatabase(NativeDatabase.memory())` |
| AC-24 (trả lời xong dựng lại tại chỗ, không rời màn hình) | screen_test `answering re-renders in place, without leaving the screen or re-reading the pack (AC-24)` — `notebook.reads` 1→2, `bundle.loads` vẫn 1 |
| §2 (danh tính ask của màn hình 9) | screen_test `the slot is handed this screen's identity and its two notebook targets` — `'date_script'`, `['notebook.interest','notebook.event']` |
| SC-6 (không chia sẻ, không copy link) | location_lock_test `screen (9) offers no share or copy-link affordance (SC-6)` |
| Visual fidelity | 3 PNG ở `mobile/test/features/date_script/visual-fidelity/`, đã soi mắt thường: dấu tiếng Việt đủ nét, không ô tofu, icon `menu_book` hiển thị đúng |
| AC-22 (ba cửa ra cuối màn hình) | NOT IN P3 — thuộc P4. `bottomNavigationBar` cố ý để trống |

### Negative controls / anti-vacuity

| Rủi ro | Bằng chứng test bắt được |
|---|---|
| "Không đọc lại gói" thành câu assert rỗng | `_CountingDiskBundle` kế thừa `AssetBundle` chứ **không** `CachingAssetBundle`, nên nếu màn hình đọc lại thật thì `loads` tăng thật |
| Quét J7 không khớp gì nên luôn xanh | `the J7 scan actually catches a timer` chạy `_j7Hits` trên đoạn `Timer.periodic` và đòi đúng `['dart:async','Timer']`, cộng control ngược trên nguồn sạch |
| Quét route không đọc file nào | `the scan finds files to scan` assert danh sách file quét khác rỗng |
| Thêm `ActivityCardStatus` mới mà quên khoá cửa | `the status scan covered every value there is` so danh sách trạng thái đã quét với `ActivityCardStatus.values` |
| Đếm `GestureDetector` để chứng minh "không có nút" | bỏ hẳn; thay bằng assert vắng mặt `ElevatedButton`/`TextButton`/`FloatingActionButton` và `bottomNavigationBar == null` |
| Assert chuỗi `export` nhiều dòng vỡ khi `dart format` | assert `contains('show DateScriptScreen, dateScriptEntryPointId;')` cộng đúng một dòng khớp `^export ` |

### Notes / deviations

1. **Không hiện thực con trỏ quay vòng preset của AC-35.** Phase file §2 muốn
   cubit giữ con trỏ xoay preset trong bộ nhớ, nhưng `_candidatesFor` là hàm
   private trong `date_script_selector.dart` (file của P2, ngoài WriteScope P3),
   nên không lấy được tập ứng viên để xoay mà không sửa file P2. AC-35 để việc
   xoay là *có điều kiện* và `ux/uiux-spec.md` không định nghĩa nút xoay nào
   trên màn hình (9), nên P3 bỏ qua. `cycleIndex` của P2 vẫn còn nguyên và có
   test; khi nào UX bổ sung affordance thì mở `_candidatesFor` là đủ.
2. **Ảnh visual fidelity nằm trong `mobile/test/`, không nằm trong
   `data/requirements/.../visual-fidelity/`.** Thư mục artifact đó ngoài
   WriteScope của handoff (`mobile` + ba file coding-plan). Ảnh được chụp bằng
   `RepaintBoundary.toImage` ngay trong widget test của story và ghi cạnh test.
3. **Hai test AC-27 sẵn có của STORY-006 phải đổi thẻ đầu vào.**
   `prepare_actions_sheet_test.dart` dùng chung một `_card()` với
   `status: scheduled`. Từ P3, thẻ *Đã hẹn ngày* luôn có hàng kịch bản, nên
   "gói lời mời rỗng ⇒ sheet không mở" không còn đúng với thẻ đó. Hai test
   `does not open at all when the pack holds no preset (AC-27)` và
   `does not open when the pack asset is missing (AC-27)` giờ truyền
   `status: ActivityCardStatus.idea` — thẻ mà hàng lời mời là hàng duy nhất có
   thể có. Ý nghĩa AC-27 giữ nguyên: không có hành động nào dùng được thì
   không mở sheet, không mở sheet rỗng, không hiện màn hình lỗi.
4. **`bottomNavigationBar` cố ý để trống.** Thanh ba cửa ra là của P4; đặt
   placeholder ở đây là thêm một affordance thứ tư để rồi phải gỡ.
5. **Không thêm key l10n.** `mobile/lib/l10n/` ngoài write scope, nên màn hình
   dùng helper song ngữ cục bộ `_scriptText(context, vi, en)` — đúng cách
   `prepare_actions_sheet.dart` và `invite_composer_sheet.dart` đang làm.
6. **3 info `prefer_initializing_formals` ở `date_script_cubit.dart`.** Các
   tham số này gán vào field private (`_card`/`_loader`/`_notebook`) nên
   initializing formal sẽ lộ tên private ra API khởi tạo. Cùng kiểu với 8 info
   đã có sẵn trong `invite_composer`; không phải lỗi mới.
7. **`mobile/ios/.../Package.resolved` đổi 2 dòng.** Do chạy `flutter test`
   sinh ra, không phải sửa tay. Để nguyên trong worktree cho Scrum Master quyết
   định khi commit.

## Phase P4 – Ba cửa ra và nguồn sinh thẻ

- Owner: Mobile Developer
- Status: COMPLETE
- Last updated: 2026-09-17

### Commands

Chạy trong worktree story, `cwd = mobile/`, Flutter 3.44.1 / Dart 3.12.1.

| Command | Result |
|---|---|
| `flutter test test/features/date_script/date_script_exits_test.dart` | PASS — `+14 ~1: All other tests passed!` (1 skip là nhóm chụp ảnh khi không bật dart-define) |
| `flutter test test/features/date_script/` | PASS — `+124 ~2: All other tests passed!` |
| `flutter test test/features/activity_cards/` | PASS — `+220 ~2: All other tests passed!` (hồi quy bắt buộc vì P4 sửa `activity_card.dart` và `quick_capture_sheet.dart`) |
| `flutter test test/features/date_script/ test/features/activity_cards/` | PASS — `+344 ~4: All other tests passed!` (lần chạy chốt) |
| `flutter test test/features/invite_composer/ test/features/journal/` | PASS — `+188 ~4: All other tests passed!` (hai luồng mà ba cửa ra gọi tới) |
| `flutter test test/features/date_script/date_script_exits_test.dart --dart-define=CAPTURE_VISUALS=true --plain-name="visual fidelity capture"` | PASS — `+1: All tests passed!`, sinh 1 PNG |
| `flutter analyze lib/features/date_script lib/features/activity_cards test/features/date_script test/features/activity_cards` | `10 issues found` — 0 error, 0 warning, toàn bộ là `info • prefer_initializing_formals` có sẵn từ trước (7 trong `activity_cards`, 3 trong cubit của P2). Không file nào của P4 sinh issue mới |

Không chạy repo-wide `flutter analyze` (baseline repo khác 0). Startup smoke
`NOT_APPLICABLE`: P4 không đăng ký route, không đổi đường khởi động app, không
đụng schema DB — `ActivityCardOrigin` là enum nối thêm, cột lưu vẫn là chuỗi.

### Files

- `mobile/lib/features/date_script/presentation/widgets/date_script_exit_bar.dart` (mới)
- `mobile/lib/features/date_script/presentation/screens/date_script_screen.dart` (sửa: lắp thanh vào `bottomNavigationBar`, thêm 3 seam cửa ra)
- `mobile/lib/features/activity_cards/domain/activity_card.dart` (sửa: nối `dateScript('date_script')`)
- `mobile/lib/features/activity_cards/presentation/widgets/quick_capture_sheet.dart` (sửa: thêm `ActivityCardOrigin? origin` tuỳ chọn — xem deviation 1)
- `mobile/test/features/date_script/date_script_exits_test.dart` (mới, 15 test)
- `mobile/test/features/activity_cards/activity_card_test.dart` (mới, 6 test)
- `mobile/test/features/activity_cards/quick_capture_sheet_test.dart` (sửa: +1 test gốc thẻ)
- `mobile/test/features/date_script/date_script_screen_test.dart` (sửa: 1 assert của P3 — xem deviation 3)
- `mobile/test/features/date_script/visual-fidelity/implemented-screen-9-ba-cua-ra.png`

### AC coverage

| AC / Rule | Evidence |
|---|---|
| AC-3 / SC-2 (ba cửa ra đọc được, bấm được) | exits_test `all three are rendered, readable and announced as buttons (AC-3/SC-2)` — đủ ba nhãn, mỗi nút cao ≥ 44 và nằm trong khung; `they stack instead of squeezing on a narrow frame` ở khung 360dp |
| AC-6 / SC-4 (không có hành động chính thứ hai của thẻ) | exits_test `none of the three is a filled primary action (AC-6/SC-4)` — không `CupidPrimaryButton` nào trong thanh; ba nút là pill viền |
| SC-2 (xuất lời mời dùng lại STORY-002) | exits_test `"Xuất lời mời" hands the source card to STORY-002's composer`; production đi thẳng `showInviteComposerSheet(context, card, inviteCategoryId)` |
| AC-4 (ghi nhật ký mang ngữ cảnh thẻ) | exits_test `"Ghi vào nhật ký" seeds STORY-003's composer with the card (AC-4)`; production đi `openJournalComposer(seed: JournalComposerSeed(originRef: 'date_script:<id>'))` |
| Nguồn sinh thẻ `date_script` | activity_card_test `screen (9) has its own origin, appended after the existing ones`; quick_capture_sheet_test `a caller-supplied origin is stamped on the card` assert `draft.origin.wireValue == 'date_script'` đúng trên đường sản xuất |
| R-15a (nối thêm, không đổi giá trị cũ) | activity_card_test `the values STORY-001..STORY-004 stored still decode` (viết tay từng chuỗi), `every value round-trips through its wire value`, `no two origins share a wire value`, `an unknown wire value is an error, not a silent default` |
| BR-6 (cửa ra hoàn tất thì màn (9) tự đóng) | exits_test `the invite exit closes the script behind it`, `a created card closes the script and confirms in place`, `a saved journal entry closes the script` — sau mỗi cái, `date-script-body` biến mất và màn nguồn `Chuẩn bị` hiện lại |
| `ux/uiux-spec.md` §3 (huỷ giữa chừng thì ở lại, không mất đoạn đang đọc) | exits_test `a cancelled exit leaves the reader on the part they were reading` — chuyển sang *Trong*, huỷ lần lượt cả ba cửa, đoạn văn và caption J7 không đổi, không `AlertDialog` nào |
| SC-6 (không chia sẻ, không copy link trên màn (9)) | exits_test `screen (9) carries no share, copy-link or clipboard path` — quét toàn bộ `lib/features/date_script/**.dart` |
| AC-13…AC-16 / BR-3 (không cửa ra nào đặt lịch) | exits_test `no exit schedules anything` (`transientCallbackCount == 0`, thẻ mới không mang ngày); quét `Timer(` trong cùng test; screen_test `no part offers a timer, a countdown, or a "start" control` vẫn xanh |
| Visual fidelity | `implemented-screen-9-ba-cua-ra.png`, đã soi mắt thường: ba nhãn "Xuất lời mời" / "Tạo thẻ mới" / "Ghi vào nhật ký" đủ dấu, không ô tofu, thanh dính đáy, pill viền hồng không tô nền |

### Negative controls / anti-vacuity

| Rủi ro | Bằng chứng test bắt được |
|---|---|
| Quét share/clipboard không khớp gì nên luôn xanh | `the scan would actually catch one` chạy đúng vị từ đó trên chuỗi *có* `Clipboard` và đòi `isTrue` |
| Một cú chạm chạy nhầm nhiều cửa ra | `one tap runs one exit and no other` đếm cả ba seam, đòi 1/0/0 |
| Test gốc thẻ xanh vì mọi thẻ đều là `date_script` | control ngược có sẵn trong cùng file: `saves on submit with no confirm button (AC-6)` vẫn đòi `ActivityCardOrigin.manual` khi không truyền `origin` |
| Round-trip enum sinh từ chính enum nên đổi tên vẫn xanh | `the values STORY-001..STORY-004 stored still decode` viết thẳng 4 chuỗi wire cũ |
| Thanh dính đáy chiếm hết màn mà test vẫn xanh | `all three are rendered…` assert chiều cao thanh < 200 và thân kịch bản cao hơn thanh — chính lỗi đã xảy ra khi dựng (xem deviation 4) |
| `tap` thanh dính đáy trượt ra ngoài khung 800x600 mặc định | mọi test dùng khung 415x1400, và assert `rect.bottom <= view.height` cho từng nút |

### Notes / deviations

1. **Sửa `quick_capture_sheet.dart` (ngoài Phase Write Scope của P4, trong
   WriteScope `mobile` của handoff).** Yêu cầu là "dùng form tạo thẻ có sẵn của
   STORY-001 với `origin: ActivityCardOrigin.dateScript`", nhưng form đó hardcode
   `manual`/`pasted_link`. Thêm tham số `ActivityCardOrigin? origin` tuỳ chọn
   (null giữ nguyên hành vi cũ) là cách duy nhất đóng dấu nguồn mà không dựng
   form thứ hai và không ghi thẳng vào repository từ màn (9).
2. **Import trực tiếp `invite_composer_sheet.dart` + `preset_catalogue.dart`.**
   `contract-summary.md` §5 cấm đọc/ghi `invite_composer` ngoài entry-point file
   của nó, nhưng `invite_composer` *không có* entry-point file; chính phase file
   P4 chỉ đích danh `showInviteComposerSheet` là giao diện phải dùng. `journal`
   thì đi đúng `journal_entry_point.dart`.
3. **Sửa một assert của P3.** `date_script_screen_test.dart` khẳng định
   `bottomNavigationBar == null` kèm chú thích "thanh cửa ra là của P4". P4 lắp
   thanh vào đúng chỗ đó, nên assert đổi thành "có đúng một `DateScriptExitBar`",
   giữ nguyên ba assert vắng mặt `ElevatedButton`/`TextButton`/`FAB`.
4. **Nút cửa ra dùng `Align(heightFactor: 1)` chứ không `Center`.** Là
   `bottomNavigationBar`, thanh được đo với chiều cao cả màn; `Center` không có
   height factor nở hết 1368px và để kịch bản đúng 0px. Lỗi này thật sự đã xảy
   ra khi dựng và bị test bắt; giờ có assert chốt lại.
5. **Ngưỡng xếp dọc đặt ở 380dp, không phải 340dp.** Ở 360dp — bề ngang phổ
   biến nhất của máy Android — ba nhãn tiếng Việt chỉ vừa một hàng bằng cách
   xuống dòng từng nhãn, đúng kiểu chật mà `ux/uiux-spec.md` §2.5 muốn tránh.
6. **Snackbar "Đã tạo thẻ mới…" không có nút "Xem".** UX §3 mô tả snackbar kèm
   hành động "Xem" dẫn sang màn (1), nhưng màn (9) tự đóng ngay sau đó và
   `contract-summary.md` §5 cấm màn (9) mở đường đi mới. Snackbar hiện trên
   `ScaffoldMessenger` gốc nên sống sót qua lúc màn đóng; phần "Xem" để ngỏ cho
   chủ sở hữu màn (1) quyết định.
7. **Không thêm key l10n.** Ba nhãn là nhãn chức năng widget
   (`contract-summary.md` §2), dùng helper song ngữ cục bộ `_exitText` giống
   phần còn lại của màn (9).
8. **Ảnh visual fidelity nằm trong `mobile/test/`** — cùng lý do như deviation 2
   của P3 (thư mục artifact ngoài WriteScope).
9. **Bản thiết kế gốc không render lại được.** `design_source` đã chốt
   (`claude-design` / `cupid-app-design-system` / `Cupid App.dc.html`,
   `screens_from: dom`), id màn (9) là `s1:datescript`; nhưng
   `render-design-canvas.js` thoát mã 3 với `VISUAL_RUNTIME_MISSING` vì runtime
   trực quan chưa được cài. Provisioning runtime nằm ngoài quyền của lane này,
   nên đối chiếu dựa trên `ux/uiux-spec.md` §2.5/§3 và ảnh chụp thật của bản
   dựng.
    **Đính chính 2026-09-17 (mobile-verification):** deviation này sai hai chỗ.
    (a) Runtime trực quan chạy được trong worktree này, đã render thật — xem
    `devops-visual-runtime-fix.md` và `../visual-fidelity/visual-fidelity-report.md`.
    (b) Bề mặt thiết kế của requirement là `cupid-ch-ng-1`
    (`req_master.md:13 Design-Surface:`), không phải `cupid-app`; id màn (9)
    trên canvas đã neo là **`9-kich-ban-buoi-hen`**, còn `s1:datescript` chỉ tồn
    tại trên canvas `cupid-app` và bị `guard-design-render-surface.sh` chặn.
10. **Chạy hồi quy `test/features/invite_composer/` ghi đè một ảnh của
    STORY-002.** `implemented-11-chuan-bi-chon-hanh-dong-ios.png` bị chụp lại
    dù không bật `--dart-define=CAPTURE_VISUALS` (74253 → 72804 byte). File đó
    ngoài WriteScope của story này nên đã `git checkout --` trả về đúng bản đã
    commit. Đáng lưu ý cho chủ sở hữu STORY-002: nhóm chụp ảnh ở đó không bị
    chặn sau cờ dart-define như của STORY-008.

## Entry Point Reachability

**Reachable: YES.** Cửa vào duy nhất, nằm trong luồng "chuẩn bị" của một thẻ
*Đã hẹn ngày*, đúng AC-1/AC-2 và khoá vị trí AC-3/AC-4/AC-5.

Đường đi, từng bước một, đều là mã đã ship (không phải route ẩn, không phải
màn preview):

1. **Màn (1)** — kho hoạt động. Người dùng mở một thẻ ở trạng thái
   *Đã hẹn ngày* (`ActivityCardStatus.scheduled`).
2. **`ActivityCardDetailScreen`** — chi tiết thẻ đó. Hành động chính **duy
   nhất** cấp thẻ cho trạng thái `scheduled` là "Chuẩn bị cho tươm tất"
   (`activity_card_detail_screen.dart:1377-1382`). Đúng một hành động chính,
   theo SC-4 / STORY-001 AC-11 / AC-6 — màn (9) không thêm cái thứ hai.
3. Bấm hành động đó gọi `widget.prepareActions(context, cubit.state.card)`
   (`activity_card_detail_screen.dart:1441`), mặc định là
   `showPrepareActionsSheet` (`…:71`) → bottom sheet **"Chuẩn bị"**.
4. **Hàng thứ hai của sheet** — `prepare_actions_sheet.dart`,
   `_resolveActions()` dòng 135-145: hàng `Key('prepare_action_date_script')`,
   nhãn "Kịch bản buổi hẹn" / "Date script", icon `CupidIcons.menuBook`. Hàng
   này **chỉ được thêm vào danh sách khi `card.status ==
   ActivityCardStatus.scheduled`** — vắng mặt hẳn chứ không phải bị làm mờ, vì
   một hàng xám vẫn là một affordance chỉ về màn (9) (AC-2/SC-6). Nó đứng sau
   "Xuất lời mời", đúng thứ tự khu vực Chuẩn bị mà `STORY-006/ux/uiux-spec.md`
   §1 đã khoá.
5. `run:` của hàng gọi `openDateScript(context, card)`, mặc định là
   **`openDateScriptScreen(context, card)`** trong
   `mobile/lib/features/date_script/date_script_entry_point.dart` — route ẩn
   danh, `card` là tham số vị trí **bắt buộc**, nên không có cách nào mở màn
   (9) mà không mang theo ngữ cảnh thẻ nguồn. Đây cũng là lý do
   `Direct URL only acceptable: NO` của AC-4 đạt được về mặt cấu trúc chứ
   không chỉ bằng quy ước.

Đường đi này được kiểm bằng test chứ không chỉ bằng mắt: xem `### AC coverage`
của P3 (`date_script_location_lock_test.dart` quét toàn `lib/` cho mọi
`ActivityCardStatus`, và test dựng `prepare_actions_sheet` thật để bấm hàng).

## Story Runtime Startup Smoke

**Status: BLOCKED — đây KHÔNG phải một lần chạy đạt.** Không có ảnh
`runtime-smoke-main-first-screen-*.png` cho story này, và không được diễn giải
mục này là gate 12g đã đóng. Gate chỉ đóng khi có một lần chạy thật, hoặc khi
Scrum Master ghi `Runtime-Smoke: WAIVED — <lý do>` vào `story_master.md`.

Đã thử đúng hình dạng bằng chứng của tiền lệ
(`STORY-006/coding-plan/test-results.md` §Story Runtime Startup Smoke,
`STORY-003/visual-fidelity/runtime-smoke-main-first-screen-emulator-5554.png`)
và dừng lại ở hai trở ngại hạ tầng, cả hai đều ngoài quyền của lane mobile.

**1. Shell của `emulator-5554` không phản hồi.**

```
adb devices -l        → emulator-5554  device product:sdk_gphone64_arm64 device:emu64a
adb -s emulator-5554 get-state → device            (exit 0, ~1s)
adb -s emulator-5554 shell df -h /data             → treo, không xuất ra gì
adb -s emulator-5554 shell getprop sys.boot_completed → treo, không xuất ra gì
adb -s emulator-5554 exec-out echo ok              → treo, không xuất ra gì
```

Ba lệnh shell riêng biệt treo quá 5 phút, không trả một byte nào, trong khi
`get-state` vẫn trả `device` tức thì. Thiết bị có mặt ở tầng adb nhưng không
phục vụ được `shell`, nên không thể `am start`, không thể đọc
`dumpsys activity activities`, không thể `logcat`, không thể `screencap`.

**2. Đĩa máy chủ không đủ để dựng APK debug.**

```
df -h /   → 460Gi tổng, 1.1Gi trống (95% đầy)   [đo lúc 2026-09-17, sau khi chạy test]
```

Tiền lệ STORY-006 ghi rõ ngưỡng thật: `flutter build apk --debug --flavor local`
**fail exit 255** với `java.io.IOException: No space left on device` khi còn
250 MiB, và chỉ PASS sau khi đĩa được giải phóng về ~10 GiB. Với 1.1 GiB trống,
`flutter build apk --debug --flavor local -t lib/main.dart --split-per-abi`
gần như chắc chắn fail giữa chừng và còn có nguy cơ làm đầy nốt đĩa của các
worktree song song khác đang chạy trên cùng máy này. Không chạy.

**Cái đã chạy được và đã đạt**, làm bằng chứng bù một phần:

```
cd mobile && flutter test test/features/date_script/ test/features/activity_cards/ test/features/invite_composer/
→ 00:31 +465 ~4: All tests passed!   (exit 0)
```

Bao gồm 9 test hành vi dựng `DateScriptScreen` thật, các test dựng
`prepare_actions_sheet` và `ActivityCardDetailScreen` thật cho đường vào, và
bốn ảnh `RepaintBoundary` ở
`../visual-fidelity/implemented-screen-9-*-ios.png`. Đó là bằng chứng màn (9)
dựng và tương tác đúng, **không** phải bằng chứng app khởi động được trên
thiết bị — hai việc khác nhau, và mục này chỉ thiếu việc thứ hai.

**Việc cần làm để đóng mục này** (owner: devops hoặc user, không phải mobile):
giải phóng đĩa máy chủ về ≥10 GiB và khôi phục/khởi động lại `emulator-5554`;
sau đó lặp lại đúng chuỗi lệnh của STORY-006 §Story Runtime Startup Smoke.
Hoặc Scrum Master ghi `Runtime-Smoke: WAIVED — <lý do>` vào `story_master.md`.
