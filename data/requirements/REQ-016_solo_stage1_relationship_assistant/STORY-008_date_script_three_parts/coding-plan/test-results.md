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
