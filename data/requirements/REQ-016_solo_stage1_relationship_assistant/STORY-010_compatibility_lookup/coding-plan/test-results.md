# Test Results – STORY-010 Bảng tra ăn khớp

## Phase Status

| Phase | Owner | Status | Build Gate | Test Gate |
|-------|-------|--------|------------|-----------|
| P1 | Mobile Developer | COMPLETE | PASS | PASS (35/35) |
| P2 | Mobile Developer | COMPLETE | PASS | PASS (19/19 + 102 hồi quy) |
| P3 | Mobile Developer | COMPLETE | PASS | PASS (4/4 + 1 chụp ảnh + 4 ARB parity) |
| P4 | Mobile Developer | COMPLETE | PASS | PASS (12/12 mới + 377 hồi quy) |
| P5 | Mobile Developer | NOT_STARTED | — | — |
| P6 | Mobile Developer | NOT_STARTED | — | — |

## P1 – Lược đồ gói nội dung và cổng nhập

### Commands Run

Chạy với `cwd` là `<worktree>/mobile`, `PATH` có prefix
`${FLUTTER_SDK_PATH:-$HOME/flutter}/bin`. Không nối ống.

| Command | Source | Result |
|---|---|---|
| `flutter --version` | — | Flutter 3.44.1 · Dart 3.12.1 |
| `flutter gen-l10n` | coding-agent-guide §3 | OK (dùng `l10n.yaml`) |
| `flutter test test/features/compatibility_lookup/compat_content_gate_test.dart` | runtime registry `mobile-app.testCommand` | **All tests passed!** — 35 passed, 0 failed |
| `flutter build apk --debug` | runtime registry `mobile-app.buildCommand` | **PASS** — `build/app/outputs/flutter-apk/app-local-debug.apk` (task `assembleLocalDebug`, 69.8s) |

`flutter analyze` không chạy làm bằng chứng cổng: baseline repo là 222 cảnh báo
có sẵn nên lệnh này không thể trả về 0 (coding-agent-guide §3).

Runtime startup smoke: NOT_APPLICABLE (phase file §9).

### Files Delivered

| File | Kind |
|---|---|
| `mobile/lib/features/compatibility_lookup/domain/compat_content.dart` | model + parser + `lookupCell` |
| `mobile/lib/features/compatibility_lookup/domain/compat_content_gate.dart` | cổng nhập |
| `mobile/assets/data/req016/compat_bands.v1.json` | 3 nhãn DẢI |
| `mobile/assets/data/req016/compat_zodiac.v1.json` | trục 2 (`aries`, `taurus`) + 4 ô |
| `mobile/assets/data/req016/compat_mbti.v1.json` | trục 2 (`intj`, `enfp`) + 4 ô |
| `mobile/test/features/compatibility_lookup/compat_content_gate_test.dart` | 35 test |

`pubspec.yaml` không bị sửa (thư mục asset đã khai báo từ STORY-004).

### AC Coverage

| AC | Cưỡng chế bằng | Test |
|---|---|---|
| AC-12 (bộ bốn đầy đủ) | 4 trường bắt buộc + luật rỗng-sau-trim | `every shipped cell carries the full quartet and asks at the end`; `a whitespace-only friction point`; `a whitespace-only activity` |
| AC-13 / AC-37(b) (luôn có điểm cọ xát) | `friction` bắt buộc → thiếu là **lỗi parse** | `a cell without a friction point is a parse error, not a variant` |
| AC-36 (trục suy từ dữ liệu, không hằng số) | độ phủ tính `n * n` với `n` = số item `kind: axis_value`; quét literal `12/16/144/256` trong `lib/features/compatibility_lookup` | `no Dart file in the feature hardcodes an axis size`; `widening the axis needs no code change`; `the literal scan itself can tell a count from an asset key` |
| AC-37(a) (hành vi / tần suất người kia) | `InvariantRule.recipientBehaviour` + **chỉ** `NotebookBoundaryRule.frequencyProbe` | `a recipient-behaviour indicator (AC-37a)`; `a how-often claim about the other person is a violation`; `the judgement-probe terms are the legitimate subject here` |
| AC-37(c) (số / %, điểm, hạng) | `percentDisplay` + `scoreOrRatio` **+ cấu trúc**: quét đệ quy mọi JSON value, gặp `num` là vi phạm | `a numeric field on a cell`; `a number nested inside a list`; `an ordering field on a band…`; `a percentage figure`; `a score or ranking` |
| AC-37(d) (streak / chuỗi ngày) | `InvariantRule.streakDisplay` | `a streak (AC-37d)` |
| AC-37(e) (kết bằng câu để hỏi) | `question` bắt buộc + phải kết bằng `?` sau `trim()` | `a closing line that states a verdict instead of asking`; `a cell missing the closing question is a parse error` |
| AC-38 (phủ 100%, không ô trống/dự phòng) | mọi cặp có thứ tự phải có đúng một ô; thừa/thiếu/trùng đều là `coverage_gap` | `each shipped pack covers every ordered pair of its own axis`; `a missing ordered pair…`; `a cell pointing at an axis value the pack never declares`; `two cells claiming the same ordered pair…` |
| BR-2 (ô **có hướng**) | `lookupCell` khớp `(self, partner)` theo thứ tự; id ô phải bằng `<self>__<partner>` | `a pair is ordered: the two directions are different cells (BR-2)`; `a cell id that does not match its own ordered pair` |
| BR-4 (hai trục độc lập) | hai schema id riêng; gói sai schema bị từ chối lúc nạp | `a pack under another schema id is rejected at load` |
| R-15a/R-15b (nội dung thay được, không chuỗi cứng) | quét toàn bộ `lib/**.dart` + `lib/**.arb` tìm chữ của ô | `no cell wording is written into a Dart or l10n file` |
| R-15c (một bản denylist duy nhất) | gate `import` `core/content/invariant_terms.dart`; không có danh sách từ thứ hai trong feature | `the shared invariant rules fire on compat packs too` (7 test) |

### Cổng chứng minh được, không chỉ chạy được

24 trong 35 test là **ca âm tính** dựng gói trong bộ nhớ: mỗi luật có ít nhất
một ca chứng minh nó **thật sự bắt** vi phạm, cộng một test baseline
(`the fixture baseline is clean`) để mọi ca đỏ bên dưới chỉ đỏ vì đúng một
nguyên nhân.

### Trạng thái trục (bàn giao cho P5/P6)

Mỗi gói tra cứu hiện ship **2 giá trị trục / 4 ô**, hợp lệ y như gói đầy đủ vì
cổng suy `n` từ dữ liệu. Giá trị trục dùng id thật (`aries`/`taurus`,
`intj`/`enfp`) nên P5/P6 chỉ **thêm** item, không phải viết lại. Bộ seed chưa
qua kiểm duyệt lớp 2 (AC-35/D-15) — P5/P6 ghi vết duyệt.

## P2 – Bảng nhãn tự khai `relationship_labels`

Phase này chạy lại sau khi phiên trước mất liên lạc. Scrum Master đã niêm phong
phần dở dang thành commit `406c0bc6`; mục 1 dưới đây là biên bản đối chiếu
commit đó với yêu cầu của file phase, không phải mô tả công việc mới.

### Inventory commit `406c0bc6` so với `phase-P2-relationship-labels-store.md`

| Yêu cầu phase | Hiện trạng ở `406c0bc6` | Việc còn lại phiên này |
|---|---|---|
| §4 bảng `relationship_labels` | Có, 8 cột đúng §5, PK `id`, UNIQUE `(owner_key, subject, system)` | Không |
| §4 DAO | Có, 4 truy vấn đều bắt buộc `ownerKey`, không có aggregate | Không |
| §4 repository | Có, upsert trên khoá tự nhiên + đọc theo `owner_key` | Không |
| §4 `cupid_database.dart` | `schemaVersion` 6 → 7, `onUpgrade` chỉ `createTable` | Không |
| §4 `service_locator.dart` | Có, 2 `registerLazySingleton` (DAO + repository) | Không |
| §4 test repository | Có, 19 test | Không |
| §6.2 sửa test đỏ do bump | 7 file đã sửa | **Sót 1 file** — xem dưới |
| §7 chạy test / §8 build gate | Không có bằng chứng nào trong artifact | Chạy lại toàn bộ |

Kết luận: phần mã nguồn của P2 đã hoàn chỉnh trong `406c0bc6`; cái thiếu là một
khẳng định `schemaVersion` bị sót và toàn bộ bằng chứng cổng.

### Sửa trong phiên này

`mobile/test/features/activity_cards/activity_type_test.dart:178` vẫn khẳng
định `expect(database.schemaVersion, 6)`. Đây đúng là dư chấn bump mà §6.2 dự
báo, ở file thứ tám mà phiên trước không quét tới. Sửa **con số khẳng định**
thành `7` và nối thêm `6 -> 7 cho relationship_labels` vào chú thích lịch sử
phiên bản ngay trên nó; hành vi của test không đổi. Đây là sửa hợp lệ theo §7
("sửa con số khẳng định, không sửa hành vi"), không phải `SCHEMA_BUMP_BLOCKED`:
không có story nào khác cùng nhắm v7.

Đã quét cạn để chắc không còn file thứ chín: 9 file test nhắc `schemaVersion`,
5 file nhắc `userVersion`/`allTables`; tất cả đều nằm trong các lệnh dưới đây.

### Commands Run

Chạy với `cwd` là `<worktree>/mobile`, `PATH` có prefix
`${FLUTTER_SDK_PATH:-$HOME/flutter}/bin`. Không nối ống, không cắt đuôi.

| Command | Source | Result |
|---|---|---|
| `flutter test test/features/compatibility_lookup/relationship_label_repository_test.dart` | runtime registry `mobile-app.testCommand` | **All tests passed!** — 19 passed, 0 failed |
| `flutter test test/core/database` | §7 (mọi test đỏ do bump) | **All tests passed!** — 82 passed, 0 failed |
| `flutter test test/features/activity_cards/activity_type_test.dart` | §7 (file sót, sau khi sửa) | **All tests passed!** — 19+0; trước khi sửa: 1 failed |
| `flutter test test/widget_test.dart` | hồi quy cho 2 đăng ký mới ở `service_locator.dart` | **All tests passed!** — 1 passed |
| `dart run build_runner build --delete-conflicting-outputs` | §8 | OK, 1307 outputs; `git status` sạch sau đó → `.g.dart` đã commit là bản sinh hiện hành |
| `flutter build apk --debug` | runtime registry `mobile-app.buildCommand` | **PASS** — `build/app/outputs/flutter-apk/app-local-debug.apk` (task `assembleLocalDebug`, 48.6s) |

`flutter analyze` không chạy làm bằng chứng cổng, cùng lý do như P1: baseline
repo 222 cảnh báo có sẵn nên lệnh không thể trả về 0.

### Đối chiếu §10 Completion Criteria

| Tiêu chí | Bằng chứng |
|---|---|
| Bảng, DAO, repository, migration tồn tại và biên dịch | build gate PASS |
| Test repository và test cột-bị-cấm xanh | 19/19, gồm nhóm `ranh giới lưu trữ (AC-30 / AC-31 / AC-33)` 6 test |
| Mọi test bị bump làm đỏ đã xanh | 82 + 19, không còn file nào khẳng định v6 |
| Build gate xanh | `app-local-debug.apk` |

### Kiểm chứng AC mà P2 trích dẫn

Các id AC trong mã nguồn P2 đã đối chiếu trực tiếp với `requirements.md` và
**đúng cả sáu** — khác với dư chấn lệch id ở P1 (mục 1 phần Findings):

| Id trích trong mã P2 | Dòng `requirements.md` | Khớp nội dung |
|---|---|---|
| AC-8 (`certainty` giữ `guess` là phỏng đoán của người dùng) | 159 | Đúng |
| AC-9 (sửa/xoá nhãn → upsert, không chồng lịch sử) | 164 | Đúng |
| AC-29 (ngoại tuyến → lưu trên thiết bị) | 258 | Đúng |
| AC-30 (không cột đo hành vi người kia) | 264 | Đúng |
| AC-31 (không ghi kết quả tra vào sổ tay) | 268 | Đúng |
| AC-33 (không cột đếm lần tra) | 277 | Đúng |

### Ba phát hiện P1 chuyển tiếp — trạng thái với P2

Wave này chỉ có làn Mobile, không có làn Tech Lead để phân xử, nên ghi lại như
mục **đã ghi nhận / hoãn**. Không mục nào phá hợp đồng của chính P2:

1. **Lệch id AC trong file phase P1** — không ảnh hưởng P2. Bảng ngay trên cho
   thấy cả sáu id P2 trích đều đúng. Vẫn chờ Scrum Master quyết có sửa file
   phase P1 hay không.
2. **AC-32 (ngôn ngữ tiên tri / vận mệnh) chưa có chủ ở tầng dữ liệu** — đúng,
   và P2 **không phải** chỗ nhận. `relationship_labels` không lưu văn xuôi nào;
   `value` là một `axis_value.id`. AC-32 là ràng buộc nội dung, thuộc cổng nhập
   (P1) hoặc nội dung (P5/P6). Vẫn hoãn.
3. **`lookupCell` ship với `ContentPackage<CompatItem>`** — không chạm P2. P2
   không gọi `lookupCell`; nó chỉ ghi id giá trị trục. Ràng buộc duy nhất là
   `value` phải là `axis_value.id` của gói tương ứng, và điều đó đúng với cả hai
   chữ ký. Vẫn hoãn cho P3/P4.

### Một điểm mới, ghi ra để Reviewer không phải tự suy

`AC-31` (dòng 270) viết: *"Sổ tay chỉ chứa **sở thích và sự kiện**, cộng nhãn
tự khai của người dùng"*. Đọc thoáng dễ tưởng AC này **bắt** nhãn phải nằm
trong sổ tay, mâu thuẫn với quyết định §2 của file phase (nhãn ở bảng riêng).
Không mâu thuẫn: `chỉ chứa` là **trần** của những gì sổ tay được phép chứa, một
lệnh cấm, không phải lệnh bắt lưu ở đó. Lưu nhãn ở nơi khác không vi phạm trần
đó. Lập luận đầy đủ ở `../architecture/solution.md` §1 Key Discovery 5, và test
`notebook_entries.kind stays the closed interest|event enum STORY-004 owns` là
hàng rào cho đúng ranh giới này.

## P3 – Khối trình bày kết quả

Bốn widget thuần, không biết database/cubit/điều hướng. Nhánh đẩy thẻ vẫn ở P4;
P3 chỉ phát tín hiệu.

### Commands Run

| Lệnh | Kết quả |
| --- | --- |
| `flutter gen-l10n` | PASS (6 khoá `compat_*` sinh ra `lib/l10n/generated/app_l10n.dart:1652-1682`) |
| `flutter test test/features/compatibility_lookup/compat_result_widgets_test.dart -r expanded` | PASS 4/4, 1 skip (ảnh, tắt mặc định) |
| `flutter test ... --dart-define=CAPTURE_VISUALS=true --plain-name "captures the result block"` | PASS 1/1, ghi PNG 415x1100 |
| `flutter test test/l10n/arb_parity_test.dart -r expanded` | PASS 4/4 |
| `flutter build apk --debug` | PASS, `build/app/outputs/flutter-apk/app-local-debug.apk`, exit 0 |

### Files Delivered

| Tệp | Vai trò |
| --- | --- |
| `mobile/lib/features/compatibility_lookup/presentation/widgets/compat_band_chip.dart` | Chip DẢI, chỉ nhận `CompatBand` |
| `mobile/lib/features/compatibility_lookup/presentation/widgets/compat_facet_block.dart` | `CompatFacetKind` + **một** widget cho cả hai mặt |
| `mobile/lib/features/compatibility_lookup/presentation/widgets/compat_activity_block.dart` | Hoạt động + `VoidCallback? onAddToMyStore` |
| `mobile/lib/features/compatibility_lookup/presentation/widgets/compat_question_block.dart` | Câu hỏi mở, không phải ô nhập |
| `mobile/lib/l10n/arb/app_vi.arb`, `app_en.arb` | 6 khoá `compat_*` |
| `mobile/test/features/compatibility_lookup/compat_result_widgets_test.dart` | 4 test + bộ chụp `RepaintBoundary` |

Đường dẫn ARB thực tế là `mobile/lib/l10n/arb/app_*.arb` (theo `mobile/l10n.yaml`
`arb-dir: lib/l10n/arb`), không phải `mobile/lib/l10n/app_*.arb` như §3/§4 file
phase ghi. Cùng một cặp tệp, chỉ lệch đường dẫn trong văn bản phase.

### Đối chiếu §10 Completion Criteria

| Tiêu chí | Bằng chứng |
| --- | --- |
| Bốn widget thuần, không phụ thuộc cubit/database/điều hướng | Import của cả bốn tệp chỉ gồm `flutter/material.dart`, `design_system/`, `l10n/generated/`, `domain/compat_content.dart` |
| Test đối xứng `fit`/`friction` xanh | `fit and friction blocks are geometrically identical` |
| Test "không có thang đo" xanh | `result block carries no scale, meter or score` |
| Ảnh `RepaintBoundary` đã chụp **và** đã mở ra kiểm bằng mắt | Xem mục "Kiểm ảnh bằng mắt" bên dưới |
| Build gate xanh | `flutter build apk --debug` exit 0 |

### Test đối xứng khoá cái gì

So sánh từng cặp giữa hai lần dựng `CompatFacetBlock`: bề rộng đã bố trí,
`padding`, `BoxDecoration.color`/`borderRadius`/`border`, `gradient` của cả hai
phải `null`, `fontSize`/`fontWeight`/`color` của tiêu đề, y hệt cho đoạn văn,
cỡ icon, và danh sách mọi `SizedBox` bên trong khối. Kèm hai khẳng định chống
rỗng — tiêu đề khác nhau và icon khác nhau — để phép so không xanh vì cả hai
cùng biến mất. Thêm một khẳng định thứ tự: `friction` nằm dưới `fit` và trên
khối hoạt động, tức không bị đẩy xuống cuối màn (`uiux-spec.md` §3.3).

Một test riêng khẳng định không có `ExpansionTile`/`ExpansionPanelList` và
`cell.friction` hiện nguyên văn — khối "va" không được gập vào accordion.

### Test "không có thang đo"

`LinearProgressIndicator`, `CircularProgressIndicator`, `Slider`, `TextField`,
`TextFormField` đều `findsNothing`; mọi `Text.data` trong cây bị quét bằng
`RegExp(r'%|/10|\bđiểm\b|\bthang\b')` và phải không khớp; `BoxDecoration.gradient`
của chip DẢI phải `null`.

### Kiểm ảnh bằng mắt

`build/visual-fidelity/STORY-010/compat-result-block-material.png`, 415x1100,
`pixelRatio: 1`, nền `CupidAppBackground`, nạp Nunito/Roboto/Roboto Mono/Material
Symbols Rounded từ đĩa cộng `MaterialIcons` của framework. Đã mở ảnh, và đã phóng
to vùng icon 4x để phân biệt glyph thật với ô tofu:

- Dấu tiếng Việt hiện đủ và đúng: *Dễ đi cùng nhau*, *Chỗ dễ hợp*, *Chỗ dễ va*,
  *1 hoạt động nên thử*, *Thêm vào kho của tôi*, *1 câu để hỏi*, *Lần gần nhất
  mình quyết vội, bạn thấy thế nào?* — không ô vuông ở bất kỳ chữ nào.
- Ba glyph (`favorite`, `cyclone`, `local_activity`, `add`, `help`) render ra
  hình thật. Đã đối chiếu cmap `MaterialSymbolsRounded-Variable.ttf` bằng
  `fontTools`: cả năm codepoint đều có mặt, nên khung vuông của `local_activity`
  là hình cái vé chứ không phải notdef.
- Hai khối `fit`/`friction` nhìn bằng mắt là cùng một khung: cùng nền, cùng bo
  góc, cùng bề rộng, cùng cỡ chữ. Che tiêu đề thì không đoán được khối nào là
  "điểm mạnh".
- Chip DẢI là pill tĩnh, không thanh/vòng/gradient. Nút "Thêm vào kho của tôi"
  là chip viền, không tô đặc `--grad`.

### Sửa trong phiên này

Lần chạy đầu đỏ cả bốn test vì `RenderFlex overflowed by 48 pixels` ở hàng
trong chip hành động: nhãn *Thêm vào kho của tôi* ở `body 17pt` cộng icon và
padding vượt 319pt khả dụng tại khung tham chiếu 415pt. Sửa ở phía sản phẩm —
bọc `Text` trong `Flexible` để nhãn xuống dòng — chứ không nới khung test và
không hạ cỡ chữ xuống dưới thang "hành động phụ". Khung test vẫn đặt 415x1100
(thay cho 800x600 mặc định) để nút nằm trong tầm `tap()`, đúng hướng dẫn §7.

### Thay icon cho mặt "va"

`uiux-spec.md` §3.3 nêu `favorite`/`bolt` làm **ví dụ**. `CupidIcons` không có
`bolt`, và tệp đó nằm ngoài Write Scope của P3, còn doc của nó cấm bịa codepoint
từ trí nhớ. Dùng `CupidIcons.cyclone` (0xebd5, đã xác nhận trong cmap) cho mặt
"va". Nếu UI/UX muốn đúng `bolt`, đó là một dòng thêm vào `cupid_icons.dart` ở
phase sau, không phải lỗi hợp đồng của P3.

### Khoảng trống phạm vi ghi: thư mục `visual-fidelity/` của story

Quy ước bằng chứng thị giác của skill `mobile-dev` đặt PNG và
`visual-fidelity-report.md` trong
`data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-010_compatibility_lookup/visual-fidelity/`.
Đường dẫn đó **không** nằm trong WriteScope của handoff P3 (`mobile` + ba tệp
coding-plan), nên ảnh phiên này ghi vào `mobile/build/visual-fidelity/STORY-010/`
— thư mục đã bị `.gitignore`, tức bằng chứng không theo commit.

P3 chỉ giao widget, chưa có màn hình, nên gói bằng chứng cấp story hợp lý thuộc
về P4. Đề nghị Scrum Master thêm
`data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-010_compatibility_lookup/visual-fidelity`
vào WriteScope của handoff P4. Không tự ghi ra ngoài WriteScope trong phiên này.

### Hình dạng tham số, ghi ra để P4 không phải đoán

- `CompatBandChip({required CompatBand band})` — không tham số thứ hai. Mọi
  band dùng chung một kiểu chip; bảng màu theo `band.id` bị bỏ có chủ đích, vì
  từ vựng DẢI ship trong gói nội dung chứ không ở Dart, nên một bảng ở đây
  hoặc thiếu hoặc phải rơi về một thứ tự — mà thứ tự chính là thang đo AC-32 cấm.
- `CompatFacetBlock({required CompatFacetKind kind, required String text})` —
  nhận `String`, không nhận `CompatCell`, để màn dựng đúng một widget hai lần.
- `CompatActivityBlock({required CompatCell cell, VoidCallback? onAddToMyStore})`
  và `CompatQuestionBlock({required CompatCell cell})` — nhận cả ô theo §2 file
  phase.
- Key ổn định cho test P4: `compat_band_chip`, `compat_facet_block_fit`,
  `compat_facet_block_friction`, `compat_activity_block`,
  `compat_activity_add_to_store`, `compat_question_block`.

## P4 – Cửa vào, màn (10) và nhập nhãn tại chỗ

### Commands Run

| Command | Source | Result |
|---|---|---|
| `flutter gen-l10n` | coding-agent-guide §3 | OK (dùng `l10n.yaml`) |
| `flutter test test/features/compatibility_lookup/compatibility_lookup_position_lock_test.dart` | runtime registry `mobile-app.testCommand` | **All tests passed!** — 7 passed |
| `flutter test test/features/compatibility_lookup/compatibility_lookup_screen_test.dart --dart-define=CAPTURE_VISUALS=true` | như trên + §7 | **All tests passed!** — 7 passed (5 hành vi + 2 chụp ảnh) |
| `flutter test test/l10n test/features/compatibility_lookup` | hồi quy | **All other tests passed!** — 74 passed, 3 skipped |
| `flutter test test/features/gift_ideas test/features/activity_cards` | hồi quy | **All other tests passed!** — 315 passed, 3 skipped |
| `flutter build apk --debug` | runtime registry `mobile-app.buildCommand` | **PASS** — `build/app/outputs/flutter-apk/app-local-debug.apk` (task `assembleLocalDebug`, 9.5s) |

`flutter analyze` không dùng làm cổng (baseline 222 cảnh báo có sẵn).
Runtime startup smoke: NOT_APPLICABLE (phase file §9).

### Files Delivered

| File | Kind |
|---|---|
| `mobile/lib/features/compatibility_lookup/presentation/screens/compatibility_lookup_screen.dart` | màn (10) |
| `mobile/lib/features/compatibility_lookup/presentation/cubit/compatibility_lookup_cubit.dart` | state |
| `mobile/lib/features/compatibility_lookup/presentation/widgets/label_capture_card.dart` | thẻ nhập nhãn |
| `mobile/lib/core/util/uuid_v4.dart` | tách từ repository P2 |
| `mobile/lib/core/di/service_locator.dart` | đăng ký cubit + `ContentPackageLoader` |
| `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart` | nối cửa vào |
| `mobile/lib/features/activity_cards/domain/activity_card.dart` | thêm origin `compatibility_lookup` |
| `mobile/lib/l10n/arb/app_vi.arb`, `app_en.arb` | 15 khoá mới, gỡ 1 khoá cũ |
| `mobile/test/features/compatibility_lookup/compatibility_lookup_screen_test.dart` | 5 test hành vi + harness chụp |
| `mobile/test/features/compatibility_lookup/compatibility_lookup_position_lock_test.dart` | 7 test khoá vị trí |
| `…/STORY-010_compatibility_lookup/visual-fidelity/` | 2 PNG + 1 reference + report |

### Khoá vị trí được kiểm bằng cách đọc cả cây `lib/`

AC-2/AC-3 là tính chất của toàn cây, không của một widget, nên
`compatibility_lookup_position_lock_test.dart` đọc file: chỉ entry point dựng
`CompatibilityLookupScreen`, `gift_ideas_screen.dart` là call site duy nhất,
`cupid_app.dart` không chứa tên nào của feature, feature không khai `routeName`
/`settings:`, không file nào trong `lib/` `pushNamed` vào `compatibility`, và
feature không import `context_notebook` (BR-10).

Hai bẫy đã gỡ: (a) các lệnh cấm khớp cả trong **doc comment** giải thích sự
vắng mặt của chúng, nên test lược bỏ comment trước khi so chuỗi; (b) `lib/`
import nhau bằng đường **tương đối**, nên test **phân giải** URI import thành
đường dẫn thật — so chuỗi `features/context_notebook/` sẽ luôn xanh một cách
rỗng. Có một test tự kiểm bộ phân giải và một biến đếm chống rỗng.

### Bằng chứng thị giác

`visual-fidelity/visual-fidelity-report.md` — `VISUAL_FIDELITY: PASS`,
`Design-Screen: 10-bang-tra-an-khop` (frame có thật trên surface
`cupid-ch-ng-1`, dù `uiux-spec.md` mở đầu bằng `DESIGN_SOURCE_NOT_DETECTED`).
Hai ảnh implemented chụp bằng `RepaintBoundary` trong chính widget test của
story, gate bằng `--dart-define=CAPTURE_VISUALS=true` nên suite thường ngày
vẫn kín. Đã soi mắt: không tofu.

### Sửa trong phiên này

- `compat_content_gate_test.dart` ("không file Dart nào hardcode kích thước
  trục") đỏ sẵn vì `relationship_label_repository.dart` chứa `16`/`256`/`16` —
  của helper UUID nội tuyến từ P2, không phải kích thước trục. Tách helper ra
  `mobile/lib/core/util/uuid_v4.dart` thay vì nới cổng.
- Thêm dòng chân màn `compat_static_table_note` theo design canvas ("Bảng tra
  soạn sẵn, cố định…") — canvas có, spec không nhắc, và nội dung nói đúng điều
  AC-28/AC-31 đã ép bằng code.

## P5 – Bộ seed 144 ô hoàng đạo

### Commands Run

| Command | Source | Result |
|---|---|---|
| `flutter test test/features/compatibility_lookup/compat_zodiac_seed_test.dart` | runtime registry `mobile-app.testCommand` | **All tests passed!** — 8 passed |
| `flutter test test/features/compatibility_lookup/compat_content_gate_test.dart -r failures-only` | cổng nội dung P1 | **All tests passed!** — 35 passed |
| `flutter test test/features/compatibility_lookup/compatibility_lookup_screen_test.dart -r failures-only` | hồi quy màn (10) | **All other tests passed!** — 5 passed, 2 skipped |
| `flutter test test/features/compatibility_lookup -r failures-only` | hồi quy feature | **All other tests passed!** — 78 passed, 3 skipped |
| `flutter test test/app test/tooling test/l10n test/core/content test/features/gift_ideas` | hồi quy rộng | **All other tests passed!** — 135 passed, 1 skipped |
| `flutter build apk --debug` | runtime registry `mobile-app.buildCommand` | **PASS** — `build/app/outputs/flutter-apk/app-local-debug.apk` (task `assembleLocalDebug`, 8.8s) |

`flutter analyze` không dùng làm cổng (baseline 222 cảnh báo có sẵn).
Runtime startup smoke: NOT_APPLICABLE (phase file §9).

### Files Delivered

| File | Kind |
|---|---|
| `mobile/assets/data/req016/compat_zodiac.v1.json` | trục 12 dấu + đủ 144 ô |
| `mobile/test/features/compatibility_lookup/compat_zodiac_seed_test.dart` | 8 test ghim bộ seed |
| `mobile/test/features/compatibility_lookup/compat_content_gate_test.dart` | 1 sửa: khẳng định "cặp lạ" chuyển sang `ophiuchus` |
| `mobile/test/features/compatibility_lookup/compatibility_lookup_screen_test.dart` | 1 sửa harness: `_DiskBundle.loadString` |

Bốn ô gốc của P1 (`aries__aries`, `aries__taurus`, `taurus__aries`,
`taurus__taurus`) giữ nguyên từng byte. Không DẢI nào được thêm: cả 144 ô dùng
`easy_sync`, `needs_tuning`, `complementary` đã khai sẵn trong
`compat_bands.v1.json`. Không file nào dưới `mobile/lib/` bị chạm.

### Bộ seed được ghim bằng test, không bằng con số trong `lib/`

`compat_zodiac_seed_test.dart` giữ `12` và `144` trong `test/` (AC-36 cấm chúng
dưới `lib/`) và khẳng định: trục đúng 12 id theo thứ tự cố định; mỗi cặp có
**đúng một** ô và id khớp `compatCellId`; mọi `band_id` được gói DẢI khai; bộ
tứ `fit`/`friction`/`activity`/`question` không rỗng, khác nhau trong cùng ô,
và `question` kết thúc bằng `?`; hai chiều của cùng một cặp khác nhau ở **cả
bốn** trường (BR-2); `fit`/`friction`/`question` duy nhất trên toàn lưới —
tức không thể chép một câu ra 144 ô; và `validateCompatPacks(...)` trả về rỗng.

Cổng nội dung xanh ngay lần chạy đầu: không ô nào chạm `%`/`phần trăm`,
`điểm số`/`xếp hạng`, `tần suất`/`thường xuyên`/`đều đặn`, từ vựng tâng bốc,
hay bất kỳ chữ số nào — đúng cảnh báo đã ghi ở Finding 5.

### Kiểm duyệt lớp 2 (AC-35/D-15): đã chuẩn bị, chưa được cấp

Bộ seed này **chưa** được phê duyệt để vào bản dựng người dùng thật. P5 chỉ ghi
vết rằng nội dung đã sẵn sàng cho user kiểm duyệt; nó không tự phê duyệt, đúng
§6 của `master-plan.md`.

## P6 – Bộ seed 256 ô MBTI

### Commands Run

| Command | Source | Result |
|---|---|---|
| `flutter test test/features/compatibility_lookup/compat_mbti_seed_test.dart` | runtime registry `mobile-app.testCommand` | **All tests passed!** — 8 passed |
| `flutter test test/features/compatibility_lookup/compat_content_gate_test.dart test/features/compatibility_lookup/compat_mbti_seed_test.dart -r failures-only` | cổng nội dung P1 + bộ ghim P6 | **All tests passed!** — 43 passed |
| `flutter test test/features/compatibility_lookup` | hồi quy feature | **All tests passed!** — 86 passed, 3 skipped |
| `flutter test test/features test/core --reporter=failures-only` | hồi quy rộng | 602 passed, 9 skipped, **3 đỏ** — cả ba nằm ở `test/features/love_contracts`, xem Finding 11 |
| `flutter test test/features/love_contracts --reporter=failures-only` (chạy khi asset MBTI bị `git stash`) | chứng minh ba test đỏ có sẵn | **`+80 -3`** — đúng ba test đó, với asset P6 vắng mặt |
| `flutter build apk --debug` | runtime registry `mobile-app.buildCommand` | **PASS** — `build/app/outputs/flutter-apk/app-local-debug.apk` (task `assembleLocalDebug`, 8.7s) |

`flutter analyze` không dùng làm cổng (baseline 222 cảnh báo có sẵn).
Runtime startup smoke: NOT_APPLICABLE (phase file §9).

### Files Delivered

| File | Kind |
|---|---|
| `mobile/assets/data/req016/compat_mbti.v1.json` | trục 16 loại + đủ 256 ô (147.975 byte) |
| `mobile/test/features/compatibility_lookup/compat_mbti_seed_test.dart` | 8 test ghim bộ seed |

Hai giá trị trục của P1 (`intj`, `enfp`) giữ nguyên vị trí đầu danh sách, nên
thứ tự trục là `intj, enfp, intp, entj, entp, infj, infp, enfj, istj, isfj,
estj, esfj, istp, isfp, estp, esfp`. **Không DẢI nào được thêm**: cả 256 ô dùng
`easy_sync`, `needs_tuning`, `complementary` đã khai sẵn — nên
`compat_bands.v1.json`, điểm va chạm duy nhất được cảnh báo giữa P5 và P6,
**không bị chạm**. Không file nào dưới `mobile/lib/` bị chạm.

### Lệch có chủ đích so với §6 bước 5 của file phase

File phase yêu cầu chạy cổng P1 **sau mỗi lô 16 ô**. Không làm được như vậy:
trục được mở lên 16 giá trị ngay từ đầu, mà luật phủ kín AC-38 so
`cells.length` với `axisIds.length²`, nên **mọi trạng thái trung gian đều đỏ**
theo đúng thiết kế của cổng. Cộng với rủi ro một lần chạy tổ hợp đỏ khoá cổng
chứng cứ build của cả phiên, đã soạn trọn 256 ô rồi chạy cổng một lần ở cuối.
Cổng xanh ngay lần đầu, không vi phạm nào, nên không có lượt sửa muộn.

Không ô nào chạm `%`/`phần trăm`, `điểm số`/`xếp hạng`,
`tần suất`/`thường xuyên`/`đều đặn`, từ vựng tâng bốc, từ vựng tiên tri, hay
bất kỳ chữ số nào — mọi con số viết bằng chữ. Từ đứng một mình `đều` và
`thường` không bị cổng bắt.

### Ngưỡng 50 KB / `compute()`: rủi ro có thật, nhưng đã được P5 xử lý

Asset MBTI là 147.975 byte, gần gấp ba ngưỡng 50 KB mô tả ở Finding 8. Không
cần thay đổi sản phẩm và cũng không cần sửa harness mới:
`compatibility_lookup_screen_test.dart` đã có bản ghi đè `_DiskBundle.loadString`
do P5 thêm, và toàn bộ 86 test của feature xanh với asset đầy đủ.
`compat_mbti_seed_test.dart` đọc thẳng bằng `File(...).readAsStringSync()` nên
không đi qua đường `compute()`.

### Bộ seed được ghim bằng test, không bằng con số trong `lib/`

`compat_mbti_seed_test.dart` giữ `16` và `256` trong `test/` (AC-36 cấm chúng
dưới `lib/`) và khẳng định: trục đúng 16 id theo thứ tự cố định; mọi nhãn không
rỗng và duy nhất; mỗi cặp có **đúng một** ô, id khớp `compatCellId`; mọi
`band_id` được gói DẢI khai; bộ tứ `fit`/`friction`/`activity`/`question` không
rỗng, khác nhau trong cùng ô, và `question` kết thúc bằng `?`; hai chiều của
cùng một cặp khác nhau ở **cả bốn** trường (BR-2); `fit`/`friction`/`question`
duy nhất trên toàn lưới 256 ô; và `validateCompatPacks(...)` trả về rỗng.

`question` được soạn theo quy ước **hỏi người kia**, thống nhất với dữ liệu P1
và 144 ô của P5 (Finding 9 vẫn mở, nhưng P6 không tạo giọng thứ hai).

### Kiểm duyệt lớp 2 (AC-35/D-15): đã chuẩn bị, chưa được cấp

Bộ seed này **chưa** được phê duyệt để vào bản dựng người dùng thật. P6 chỉ ghi
vết rằng nội dung đã sẵn sàng cho user kiểm duyệt; nó không tự phê duyệt, đúng
§6 của `master-plan.md`.

## Findings For Scrum Master / Tech Lead

### 1. AC id trong file phase P1 lệch với `requirements.md` (đã sửa khi dùng)

Kiểm chứng trực tiếp bằng `requirements.md` và `architecture/solution.md`
section 1 Key Discovery 2/4. Code và test dùng id **đúng**:

| Chỗ trích trong `phase-P1-…md` §6.3 | AC file phase ghi | AC thật |
|---|---|---|
| luật **Phủ kín** `n²` | AC-36 | **AC-38** (AC-36 chỉ nói `n` suy từ dữ liệu; cả hai đều được trích trong code) |
| luật **Không số** | AC-32 | **AC-37(c)** |

`AC-32` thật là *"không có ngôn ngữ tiên tri, vận mệnh, số phận"* (R-10);
`AC-34` thật là cổng cứng *"người kia chưa từng tham gia"*, không phải luật
phân giải id giữa các gói. Ánh xạ `AC-37 (a)/(c)/(d)` và `AC-37e` trong file
phase là **đúng**, đã dùng nguyên.

### 2. AC-32 (ngôn ngữ tiên tri / vận mệnh) chưa có chủ ở tầng dữ liệu

Bảy nhóm luật của P1 **không** chứa luật nào chặn từ vựng tiên tri
(`vận mệnh`, `số phận`, `định mệnh`, `tử vi`, `bói`…), và
`core/content/invariant_terms.dart` cũng không có nhóm đó. P1 không tự thêm:
thêm một danh sách từ cục bộ là đúng kiểu vi phạm R-15c mà story này tồn tại
để chặn, và mở rộng phạm vi phase. **Đề nghị quyết định**: hoặc bổ sung một
`InvariantRule` mới vào `invariant_terms.dart` (một bản duy nhất, dùng chung),
hoặc gán AC-32 cho một phase sau. Hiện tại AC-32 chỉ được bảo đảm bằng biên
tập, không bằng cổng.

### 3. Chữ ký `lookupCell` khác file phase — hình dạng hợp đồng thắng

File phase §5 ghi
`lookupCell(ContentPackage<CompatCell> pack, …)`. Không dựng được: theo
`contract-summary.md` §3 một gói tra cứu chứa **cả** item `kind: axis_value`
**và** `kind: cell` trong cùng `items`, nên tham số kiểu không thể là
`CompatCell`. Chữ ký đã ship (nguồn sự thật cho P3/P4):

```dart
CompatCell? lookupCell(
  ContentPackage<CompatItem> pack, {
  required String selfId,
  required String partnerId,
});
```

`CompatItem` là `sealed`, hai nhánh `CompatAxisValue` và `CompatCell`.
Parser cho cả gói là `compatItemFromJson`, `expectedSchemaId` là
`compatZodiacSchemaId` / `compatMbtiSchemaId`.

### 4. Mỗi item giữ lại `rawJson` — đây là điều kiện để luật cấm số chạy được

Luật AC-37(c) quét **đệ quy mọi JSON value**, mà một model đã typed thì xoá
sạch đúng những con số nó cần tìm (`weight`, `order`, `score` không nằm trong
trường nào cả). Vì vậy `CompatBand`, `CompatAxisValue`, `CompatCell` đều mang
`Map<String, Object?> rawJson` bất biến, và parser **không** từ chối khoá lạ —
khoá lạ mang số được báo là vi phạm **kèm id ô** (AC-37 đòi *"kèm id ô vi
phạm"*), thay vì ném lỗi parse không có id. P3/P4 không cần đọc `rawJson`.

### 5. `frequencyProbe` áp cho cả bốn trường, không riêng `question` — rủi ro cho P5/P6

AC-37(a) lấy ví dụ *"hay trả lời chậm"*, *"ít nhắn tin"* — đó là văn **mô tả**
trong `fit`/`friction`, không phải câu hỏi. Nên cổng quét `frequencyProbe` trên
cả bốn trường. Hệ quả cần biết trước: `thường xuyên` và `đều đặn` nằm trong
danh sách đó và là từ tiếng Việt rất thông dụng. Người soạn 400 ô ở P5/P6 sẽ
gặp chúng và phải viết lại câu. Đây là hành vi **đúng theo AC**, không phải
lỗi — ghi ra đây để P5/P6 không mất thời gian tưởng là cổng hỏng. Không nới
luật, không chép denylist.

### 6. Frame thiết kế `10-bang-tra-an-khop` đang vẽ một UI vi phạm AC của story

Frame trên canvas `cupid-ch-ng-1` vẽ khối DẢI là **thanh gradient có 3 mốc**
(cần cố gắng / vừa / rất hợp). `uiux-spec.md` §3.1 và AC-16/AC-17 cấm tuyệt
đối đúng hình khối đó. Bản dựng theo AC (chip nhãn tĩnh) và ghi chênh lệch
trong `visual-fidelity-report.md` §"Chênh lệch". Cần UI/UX sửa frame; canvas
nằm ngoài WriteScope của lane Mobile nên phiên này không đụng vào.

### 7. Gỡ khoá `gift_ideas_guess_coming_soon` — rủi ro đối soát với STORY-009

Hàng "đoán" ở màn (5) trước đây hiện snackbar "sắp có"; P4 nối nó vào màn (10)
nên khoá ARB đó bị gỡ khỏi `app_vi.arb`/`app_en.arb` và test tương ứng trong
`gift_ideas_screen_test.dart` được thay bằng test mở màn (10). Nếu STORY-009
đang chạy song song còn tham chiếu khoá này trên nhánh của nó, merge sẽ đỏ ở
`AppL10n` chứ không im lặng — sửa bằng cách bỏ tham chiếu bên đó, không khôi
phục khoá.

### 8. Asset vượt 50 KB làm đứng widget test — đã sửa ở harness, không ở sản phẩm

Khi trục hoàng đạo mở từ 2 lên 12, `compat_zodiac.v1.json` vượt 50 KB và 5 test
trong `compatibility_lookup_screen_test.dart` đỏ với hai triệu chứng khác nhau
(`Found 0 widgets with key [<'compat_empty_state'>]` và `Bad state: No element`
từ `tapChip`). Cùng một nguyên nhân: trên 50 KB, `CachingAssetBundle.loadString`
giao việc giải mã cho `compute()`, và isolate không bao giờ kết thúc trong vùng
fake-async của widget test, nên màn kẹt ở `state.loading`. Sửa bằng cách ghi đè
`loadString` trong `_DiskBundle` của test để giải mã tại chỗ. Hành vi sản phẩm
không đổi và vẫn đúng — giải mã trong isolate trên máy thật là mong muốn.

Hệ quả cho P6: khi trục MBTI mở lên 16 (256 ô), mọi widget test nạp asset thật
đều cần cùng cách ghi đè này. Ngoài ra, màn (10) hiện **không** có trạng thái
lỗi: `compatibility_lookup_cubit.dart` §`load()` không bắt exception, còn màn
trả `SizedBox.shrink()` khi `loading`, nên một lần nạp hỏng trên máy thật sẽ
hiện màn trắng không thông báo. Đề nghị giao trạng thái lỗi cho một phase sau —
nằm ngoài WriteScope nội dung của P5.

### 9. `question` gửi cho ai: file phase lệch với dữ liệu đã ship

`phase-P5-zodiac-seed-content.md` mô tả `question` là câu hỏi "gửi cho chính
người dùng", nhưng cả bốn ô P1 đã ship lẫn nhãn khối trong UX (*1 câu để hỏi*)
đều coi đó là câu người đọc hỏi người kia. Đã soạn 144 ô theo **quy ước dữ liệu
đã ship** để không tạo hai giọng trong cùng một gói. Nếu chủ đích sản phẩm là
câu tự vấn, đó là một lượt biên tập lại cả bốn ô P1 lẫn 144 ô mới cộng đổi nhãn
khối, nên cần quyết định trước khi P6 soạn 256 ô MBTI.

### 10. Ba test đỏ có sẵn, nằm ngoài thay đổi của P5

`flutter test test/core test/design_system test/openapi` đỏ ở
`test/design_system/no_fork_guard_test.dart` (8 điểm chạm mẫu cấm: `Colors.`
trong `skill_profile_screen.dart:167`, `context_inline_add_row.dart:242`,
`compatibility_lookup_screen.dart:56`, `activity_card_detail_screen.dart:590`,
`quick_capture_sheet.dart:50`, `frame_chip_strip.dart:105`,
`gift_ideas_screen.dart:158`, cùng `Platform.is` trong
`service_locator.dart:694`) và `shared_backdrop_occlusion_test.dart`
(`pumpAndSettle timed out`). Diff của P5 (`git diff --name-only 6d59a6d0…` cộng
`git status --short`) chỉ gồm một file asset JSON và ba file `test/` — **không
file `lib/` nào** — nên cả ba đều có sẵn trước phiên này và thuộc story khác.
P5 không sửa để tránh chạm `lib/` ngoài phạm vi nội dung.

### 11. Ba test đỏ có sẵn ở `love_contracts`, nằm ngoài thay đổi của P6

`flutter test test/features test/core` đỏ ở ba chỗ, cả ba thuộc story hợp đồng
tình yêu:

- `love_contract_bloc_test.dart:149` — `load` trả 2 điều khoản, test chờ 1.
- `love_contract_particle_dots_test.dart:148` — độ mờ chấm nền là
  `0.2549019607843137`, test chờ `1.0` ± `0.02`.
- `love_contract_screen_test.dart:183` — khẳng định semantics dùng nhãn tiếng
  Anh `Always tell the truth`, còn node thật mang nhãn `Luôn nói thật với nhau`.

Đã kiểm chứng bằng thực nghiệm đảo ngược được: `git stash` riêng
`mobile/assets/data/req016/compat_mbti.v1.json`, chạy lại
`flutter test test/features/love_contracts --reporter=failures-only` → vẫn
`+80 -3` đúng ba test đó, rồi `git stash pop`. Diff của P6 chỉ gồm một file
asset JSON và một file `test/` mới, không file `lib/` nào, nên không có đường
nào để dữ liệu MBTI ảnh hưởng hình học hay semantics của màn hợp đồng. P6 không
sửa vì nằm ngoài phạm vi.

MOBILE_IMPLEMENTATION_COMPLETE
