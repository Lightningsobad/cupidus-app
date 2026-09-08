# Test Results — REQ-016 / STORY-001

## Phase P1 — Kho thẻ cục bộ (schema + DAO + migration)

- Lane: Mobile
- Date: 2026-09-07
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Package: `mobile/` (`cupid_mobile`)

### Codegen

```
$ dart run build_runner build
  8s drift_dev on 2104 inputs: 526 skipped, 1030 output, 548 no-op; spent 5s analyzing, 1s resolving
  0s source_gen:combining_builder on 1052 inputs: 526 skipped, 5 output, 521 no-op
  Built with build_runner/aot in 22s; wrote 1035 outputs.
```

### Targeted unit + integration tests

```
$ flutter test test/core/database/
00:02 +40: All tests passed!
exit=0
```

Named gates from `phase-P1-local-card-store.md` §6, enumerated with
`--reporter expanded` (same run, 40/40 pass):

| Gate (§6 / §4) | Test name | Result |
|---|---|---|
| Cột đúng bằng allowlist §3 | `activity_cards schema (contract-summary.md §3 allowlist) exposes exactly the agreed column set and nothing more` | pass |
| Không cột đo hành vi người kia (R-1b, §4) | `... carries no column that measures the partner behind their back (R-1b, contract-summary.md §4)` | pass |
| Cột bảng ảnh | `... activity_card_photos exposes exactly its agreed columns` | pass |
| Không có `@DriftDatabase` thứ hai (ADR-010) | `... lib declares exactly one @DriftDatabase (ADR-010)` | pass |
| schemaVersion = 3 | `opens at schema version 3 with both activity card tables` | pass |
| DAO CRUD | `ActivityCardDao CRUD upsertCard inserts, then a second write on the same id updates in place` | pass |
| Trường thiếu = null hợp lệ | `ActivityCardDao CRUD optional fields default to null rather than being rejected` | pass |
| Đổi ngăn trạng thái | `ActivityCardDao CRUD updateCard moves a card between status panes` | pass |
| Phân trang | `ActivityCardDao CRUD cardsByStatus pages newest-updated first` | pass |
| Watch theo ngăn | `ActivityCardDao CRUD watchCardsByStatus emits the pane again after a write` | pass |
| Đếm số thẻ mỗi ngăn | `ActivityCardDao.countsByStatus counts each pane for one owner without loading the rows` | pass |
| Cách ly `owner_key` (đọc) | `owner_key isolation a different owner_key sees none of the cards` | pass |
| Cách ly `owner_key` (xoá) | `owner_key isolation deleting under the wrong owner_key writes nothing` | pass |
| Xoá thẻ xoá kèm ảnh (ON DELETE CASCADE) | `photo cascade deleting a card deletes its photo rows` | pass |
| DAO không đăng ký hook đăng xuất | `sign-out survival (AC-22) ActivityCardDao does not implement SessionScopedStore` | pass |
| Thẻ sống sót qua `clearOnSignOut()` | `sign-out survival (AC-22) running every registered clearOnSignOut leaves the cards intact` | pass |
| Migration v2→v3 giữ dữ liệu cache | `a v2 database with cache data upgrades to v3 keeping that data` | pass |
| Migration tạo bảng + chỉ mục ngăn | `the upgrade creates the activity card tables and the pane index` | pass |
| Thẻ bền qua reopen | `cards written after the upgrade survive a reopen` | pass |

Ghi chú về fixture migration: DB v2 được dựng bằng cách mở schema hiện tại trên
file rồi gỡ đúng phần thêm ở v3 và đặt `PRAGMA user_version = 2`, nên hình dạng
v1/v2 luôn khớp định nghĩa bảng thật thay vì DDL chép tay.

### Static analysis

```
$ flutter analyze lib/core/database test/core/database
Analyzing database, database...
No issues found!
exit=0
```

```
$ flutter analyze lib test
188 issues found. (ran in 2.5s)
exit=1
```

- `error` count: **0**
- `warning` count: 35 — toàn bộ nằm ngoài write scope của P1
  (`features/chat`, `features/gallery`, `test/features/**`, ...), có sẵn từ
  BaseHead `a2aaf1c`.
- Không có issue nào trỏ vào `activity_cards_table.dart`,
  `activity_card_dao.dart`, `cupid_database.dart`, hay hai file test mới
  (đã kiểm bằng lọc tên file trên output đầy đủ: 0 dòng khớp).
- `flutter analyze` thoát khác 0 với bất kỳ mức nào kể cả `info`, nên kết luận
  đọc theo severity count chứ không theo exit code.

### Thay đổi ngoài write scope đã khai báo

`schemaVersion` bump 2 → 3 làm hai assertion ghim cứng phiên bản trong test có
sẵn sai:

- `mobile/test/core/database/expense_dao_test.dart` — `expect(schemaVersion, 2)`
- `mobile/test/core/database/timeline_dao_test.dart` — `expect(schemaVersion, 2)`
  (tên test còn ghi "version 1", đã lệch từ trước)

Cả hai được sửa thành `expect(database.schemaVersion, 3)` và đổi tên thành
"opens at the current schema version with both tables present" để lần bump sau
không phải sửa lại tên. Đây là hệ quả bắt buộc của P1 chứ không phải thay đổi
hành vi; không có assertion nào khác trong hai file bị đụng tới.

### Không chạy ở phase này

- Runtime startup smoke: NOT_APPLICABLE theo §1B (P1 không dựng màn hình).
- Per-story visual fidelity: NOT_APPLICABLE theo §6.

## Phase P3 — Gói dữ liệu dịp và loader nội dung

- Lane: Mobile
- Date: 2026-09-07
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Package: `mobile/` (`cupid_mobile`)
- BaseHead: `fd371b2`

### Targeted unit tests

```
$ flutter test test/core/content/ test/features/activity_cards/
00:00 +48: All tests passed!
exit=0
```

Named gates từ `phase-P3-occasion-content-package.md` §4/§6, liệt kê bằng
`--reporter expanded` trên cùng lần chạy (48/48 pass; 33 test mới của P3, phần
còn lại là test P1/P2 chạy lại nguyên vẹn):

| Gate (§4 / §6) | Test name | Result |
|---|---|---|
| Loader hợp lệ: `id`/`version`/`schemaId`/`items` | `gói hợp lệ parse exposes id, version, schemaId and the parsed items` | pass |
| Không giả định gói không rỗng | `gói hợp lệ an empty items list parses instead of being assumed non-empty (R-15b)` | pass |
| N là dữ liệu, N=1 (R-15b) | `N là thuộc tính dữ liệu (R-15b) a package of 1 items parses and reports N from the data` | pass |
| N là dữ liệu, N=50 (R-15b) | `N là thuộc tính dữ liệu (R-15b) a package of 50 items parses and reports N from the data` | pass |
| `id` mục là chuỗi bền, không phải chỉ số mảng (R-15a) | `id mục là chuỗi bền... an item keeps its id when the package is reordered, and the id is not the array index` | pass |
| Trùng `id` bị từ chối | `id mục là chuỗi bền... a duplicate item id is rejected rather than silently shadowed` | pass |
| JSON hỏng → lỗi rõ ràng, không nuốt | `lỗi schema... malformed JSON throws instead of yielding an empty package` | pass |
| Gốc không phải object bị từ chối | `lỗi schema... a non-object root is rejected` | pass |
| Sai `schema_id` bị từ chối | `lỗi schema... a mismatched schema_id is rejected` | pass |
| Thiếu `version` bị từ chối | `lỗi schema... a missing package version is rejected` | pass |
| `items` không phải list bị từ chối | `lỗi schema... items that is not a list is rejected` | pass |
| Mục thiếu `id` bị từ chối | `lỗi schema... an item without a stable id is rejected` | pass |
| Trường tuỳ chọn sai kiểu bị từ chối | `lỗi schema... a present-but-wrong-typed optional field is rejected` | pass |
| Loader đọc asset bundle | `ContentPackageLoader loads and parses a package from the asset bundle` | pass |
| Lỗi schema nêu đúng asset key | `ContentPackageLoader a schema failure names the asset key it came from` | pass |
| Dịp gần nhất + 1–2 gợi ý, N=1 | `hành vi đúng ở mọi N (R-15b) N=1 picks the nearest upcoming occasion and offers 1–2 suggestions` | pass |
| Dịp gần nhất + 1–2 gợi ý, N=50 | `hành vi đúng ở mọi N (R-15b) N=50 picks the nearest upcoming occasion and offers 1–2 suggestions` | pass |
| Tất định, N=1 | `hành vi đúng ở mọi N (R-15b) N=1 is deterministic: same device date and package give the same prompt` | pass |
| Tất định, N=50 | `hành vi đúng ở mọi N (R-15b) N=50 is deterministic: same device date and package give the same prompt` | pass |
| Không dịp nào phía trước, N=1 | `hành vi đúng ở mọi N (R-15b) N=1 with no date on or after the device date yields no prompt rather than throwing` | pass |
| Không dịp nào phía trước, N=50 | `hành vi đúng ở mọi N (R-15b) N=50 with no date on or after the device date yields no prompt rather than throwing` | pass |
| Gói rỗng không nổ | `hành vi đúng ở mọi N (R-15b) an empty package yields no prompt` | pass |
| Dịp rơi đúng ngày thiết bị vẫn tính là phía trước | `hành vi đúng ở mọi N (R-15b) an occasion falling on the device date itself still counts as upcoming` | pass |
| Trần 2 gợi ý theo AC-3, không theo kích thước gói | `hành vi đúng ở mọi N (R-15b) an occasion with more suggestions than AC-3 offers is capped at two` | pass |
| Gói ship sẵn nạp được từ asset đã đăng ký, `id` bền cho dịp và gợi ý | `gói ship sẵn ... loads from the registered asset with a stable id per occasion and per suggestion (R-15a)` | pass |
| Gói ship sẵn cho 1–2 gợi ý ở một ngày cố định | `gói ship sẵn ... the nearest upcoming occasion for a fixed device date is 1–2 suggestions` | pass |
| Prompt mang sẵn tên hiển thị + nguồn lịch cho màn hình (§4, thấy trên design reference) | `gói ship sẵn ... the prompt carries the display name and calendar provenance the screen renders, so neither is derived in Dart` | pass |
| Dịp thiếu tên hiển thị bị từ chối lúc load | `gói ship sẵn ... an occasion without a display name is rejected at load` | pass |
| Không chuỗi nội dung dịp nào trong file Dart (§4) | `gói ship sẵn ... no occasion content string is written into any Dart file (R-15a)` | pass |
| Chọn gợi ý tạo ngay thẻ `idea`, không hỏi thêm trường (AC-3) | `chọn gợi ý tạo thẻ ngay (AC-3) accepting a suggestion creates one idea card with origin occasion_suggestion and asks for no further field` | pass |
| Không lời gọi mạng trên đường gợi ý (R-7, BR-8, AC-5) | `không lời gọi mạng... load + suggest + create runs to completion under an HttpClient that throws if it is ever opened` | pass |
| Đối chứng cho gate trên | `không lời gọi mạng... the control: opening an HttpClient inside the same zone does throw` | pass |

Ghi chú về gate R-7/BR-8: luồng chạy trong `HttpOverrides.runZoned` với
`createHttpClient` **ném `StateError`**, nên bất kỳ lời gọi mạng nào cũng làm
test đỏ. Test đối chứng ngay sau đó chứng minh override thật sự có hiệu lực
trong cùng zone, để một "pass" không thể đến từ override bị bỏ qua.

Ghi chú về gate "không chuỗi nội dung trong Dart": test đọc mọi `name` dịp **và**
mọi `title` gợi ý trong `occasions.v1.json` rồi quét **toàn bộ** `lib/**/*.dart`
(không chỉ hai file P3) và fail nếu bất kỳ file nào chứa một chuỗi đó. Gate này
đã bắt lỗi thật trong chính lần chạy áp chót: một doc comment trong
`occasion_suggestion_service.dart` trích nguyên một tên dịp làm ví dụ, test đỏ,
comment đã sửa. Nó quét text file nên comment cũng bị tính — đúng ý R-15a, vì
tên dịp trong comment vẫn là nội dung nằm trong repo code.

Ghi chú về gate N=1/N=50: gói tổng hợp sinh ngày chạy một dịp mỗi ngày từ
`2030-01-01`, nên "dịp gần nhất" có đúng một đáp án ở mọi N; `id` mục là
`occ_<7i+3>` chứ không phải chỉ số mảng, nên test không thể vô tình đúng nhờ
thứ tự.

### Static analysis

```
$ flutter analyze lib/core/content lib/features/activity_cards test/core/content test/features/activity_cards
Analyzing 4 items...
5 issues found. (ran in 1.7s)
exit=1
```

```
$ flutter analyze lib test
193 issues found. (ran in 3.5s)
exit=1
```

- `error` count: **0**
- `warning` count: **35** — y hệt baseline P1, không warning nào mới.
- `info` count: 158. Đúng **2** info trỏ vào file P3, cả hai là
  `prefer_initializing_formals`:
  - `lib/core/content/content_package.dart:208:55`
  - `lib/features/activity_cards/domain/occasion_suggestion_service.dart:107:7`

  Cả hai không sửa được theo gợi ý của lint: field là private (`_bundle`,
  `_repository`) sau một named parameter công khai, mà Dart cấm named parameter
  bắt đầu bằng `_`. Đây cũng đúng khuôn `activity_card_repository_impl.dart`
  của P2 (3 info cùng loại).
- Tổng 188 (baseline P1) + 3 (P2) + 2 (P3) = 193, khớp.
- `flutter analyze` thoát khác 0 với bất kỳ mức nào kể cả `info`, nên kết luận
  đọc theo severity count chứ không theo exit code.

### Design reference đã dựng và đã xem

P3 không dựng màn hình, nhưng nó quyết định **hình dạng dữ liệu** mà màn hình
P5 sẽ đọc, nên design phải được xem trước khi chốt schema.

```
$ node render-design-canvas.js --surface=cupid-ch-ng-1 --screen=phut-1-kho-trong --out=<visual-fidelity>
$ node render-design-canvas.js --surface=cupid-ch-ng-1 --screen=man-goc-muon-lam --out=<visual-fidelity>
```

- `visual-fidelity/design-reference-phut-1-kho-trong-ios.png` (415x900)
- `visual-fidelity/design-reference-man-goc-muon-lam-ios.png` (415x900)

Điều nhìn thấy đã đổi contract của P3: cả hai màn hình đều render **tên hiển
thị của dịp** và **nguồn lịch** của nó ("Theo lịch âm"). Model `Occasion` bản
đầu chỉ có `id`/`calendar`/`dates`/`suggestions`, không có tên — nên P5 sẽ buộc
phải hard-code tên dịp tiếng Việt trong Dart, vi phạm đúng §4 của chính phase
này. Đã sửa trước khi đóng phase:

- `Occasion` thêm field `name` bắt buộc, parse từ gói, có test từ chối dịp
  thiếu `name`.
- Cả 10 dịp trong `occasions.v1.json` được bổ sung `name`.
- `OccasionPrompt` mang cả object `Occasion` (thay vì chỉ `occasionId`), để màn
  hình đọc `name`/`calendar` thẳng từ gói thay vì suy lại trong Dart;
  `occasionId` giữ nguyên dưới dạng getter nên call site không đổi.
- Gate "không chuỗi nội dung trong Dart" mở rộng để quét cả `name`.

### Thay đổi ngoài write scope đã khai báo

Sáu file trong §1B là toàn bộ thay đổi **code/test/asset** của P3. Ngoài ra P3
ghi thêm hai file ảnh vào `STORY-001_activity_card_hub/visual-fidelity/` cho
design reference ở trên — thư mục này nằm ngoài `coding-plan` được cấp trong
handoff WriteScope, nêu ở đây để Scrum Master thấy khi commit.

### Không chạy ở phase này

- Runtime startup smoke: NOT_APPLICABLE theo §1B (P3 không dựng màn hình).
- Per-story visual fidelity: NOT_APPLICABLE theo §6. Ảnh ở trên là **design
  reference** (render từ nguồn design), không phải screenshot app, và không
  phải bằng chứng đối chiếu fidelity — phần đó thuộc phase dựng màn hình.

## Phase P4 — Kho thẻ: danh sách, filter, điểm vào

- Lane: Mobile
- Date: 2026-09-07
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Package: `mobile/` (`cupid_mobile`)
- Flutter 3.44.1 / Dart 3.12.1

### Targeted widget + unit tests

```
$ flutter test test/features/activity_cards/ test/features/home/
00:02 +101 ~1: All tests passed!
exit=0
```

`~1` là một test `skip` có sẵn từ trước P4, không phải test của phase này.

Named gates từ `phase-P4-hub-list-and-entry-point.md` §4 và §6, liệt kê bằng
`--reporter expanded` trên file test của phase (21/21 pass):

| Gate (§4 / §6) | Test name | Result |
|---|---|---|
| Điểm vào AC-22 | `AC-22 entry point an unpaired session renders the hub in the "Nhà" tab` | pass |
| Không đụng nhánh đã-ghép-đôi (§3) | `AC-22 entry point a paired session keeps the couple dashboard untouched` | pass |
| Trạng thái ghép đôi chưa rõ | `AC-22 entry point an unresolved pairing status keeps the couple dashboard` | pass |
| Đúng 4 ngăn, nhãn đầy đủ (AC-10) | `ActivityCardHubView AC-10: renders exactly four panes with their full labels` | pass |
| Mỗi ngăn chỉ liệt kê đúng trạng thái (AC-10) | `ActivityCardHubView AC-10: selecting a pane lists that status only` | pass |
| Đúng 1 nút hành động chính, nhãn khớp SC-4 (AC-11) — `idea` | `ActivityCardHubView AC-11/SC-4: a idea card carries exactly one primary action, labelled "Hẹn ngày"` | pass |
| AC-11 / SC-4 — `scheduled` | `... a scheduled card carries exactly one primary action, labelled "Chuẩn bị"` | pass |
| AC-11 / SC-4 — `done` | `... a done card carries exactly one primary action, labelled "Ghi lại"` | pass |
| AC-11 / SC-4 — `memory` | `... a memory card carries exactly one primary action, labelled "Xem lại"` | pass |
| Đường xoá kể cả ngăn kỷ niệm (AC-13) | `ActivityCardListCubit AC-13: delete removes the card from a memory pane too` | pass |
| Không streak/huy hiệu/chỉ số người kia (AC-18, AC-20) | `ActivityCardHubView AC-18/AC-20: no streak, day-chain, badge or partner-behaviour metric is rendered` | pass |
| Chip "đã rủ" đúng 2 giá trị, không nhãn thời gian (§3) | `ActivityCardHubView the "đã rủ" chip shows two values, toggles on tap and carries no time label` | pass |
| Chip vắng khi chưa từng rủ (§3) | `ActivityCardHubView the chip is absent when the card was never invited` | pass |
| Giá chỉ hiện khi `> 0` (§3) | `ActivityCardHubView the price renders only when it is greater than zero` | pass |
| Ngăn rỗng có lối đi tiếp, không dead end (UX §4b, SC-5) | `ActivityCardHubView UX §4b: an empty pane in a non-empty store offers one neutral line and a link back to "Mới nghĩ ra"` | pass |
| Kho rỗng nhường chỗ cho Phút-1 của P5 | `ActivityCardHubView an empty store leaves the Minute-1 slot to P5 instead of repeating the two invitations` | pass |
| Khung lối-vào-nhanh đúng 3 ô (UX §6) | `ActivityCardHubView UX §6: the quick-entry strip frame has exactly three cells` | pass |
| Cubit chỉ nạp ngăn đang chọn + số đếm (§3) | `ActivityCardListCubit loads only the selected pane and its per-pane counts` | pass |
| Đổi ngăn thay danh sách (§3) | `ActivityCardListCubit switching pane replaces the list with that status only` | pass |
| Phân trang, không nạp cả kho (§3) | `ActivityCardListCubit pages the pane instead of reading the whole store` | pass |
| Toggle trả lời đúng 2 giá trị (§3) | `ActivityCardListCubit the reply toggle flips between exactly two values` | pass |

Hai lỗi test đã sửa trong phase này, cả hai là lỗi của chính test chứ không
phải nới lỏng assertion:

- `AC-11/SC-4 ... "Xem lại"`: filter cuộn ngang theo đúng §3, nên ở viewport
  test 800px ô thứ tư nằm ngoài mép phải và `tester.tap` sinh
  `Offset(885.1, 96.0)` ngoài root render tree. Sửa bằng `tester.ensureVisible`
  trước khi chạm — đúng hành vi người dùng thật.
- `an empty store leaves the Minute-1 slot to P5`: chỗ trống Phút-1 là
  `SizedBox` cao 0 trong `SliverToBoxAdapter`, mà
  `_ViewportElement.debugVisitOnstageChildren` bỏ qua sliver có
  `geometry.visible == false`, nên finder mặc định không thấy nó. Sửa bằng
  `skipOffstage: false`; widget giữ nguyên cao 0 vì "không vẽ gì" mới là hành
  vi đúng của sản phẩm ở đây.

### Static analysis

```
$ flutter analyze lib/features/activity_cards lib/features/home lib/main_preview.dart test/features/activity_cards test/features/home
16 issues found. (ran in 2.6s)
exit=1
```

- `error` count: **0**
- `warning` count: 5 — tất cả có sẵn từ BaseHead `1d88f98`
  (`home_screen.dart` `_daysRowGap`/`_daysUnitBaselineLift`/`_daysUnitFontSize`
  `unused_element`; `main_preview.dart` `unused_import`; `home_screen_test.dart`
  `unused_import` + `_NoOpGalleryRepository`). Đã xác nhận `home_screen.dart`
  chỉ được **thêm** ở P4: `git diff <BaseHead>` cho 62 insertions, 0 deletions,
  và ba hằng số đó đã có trong `git show <BaseHead>:...`.
- 2 `info` `prefer_initializing_formals` ở `activity_card_list_cubit.dart:86`
  và `:87` là **cố ý**: Dart không cho khai báo initializing formal có tên
  riêng tư, và file P2 `activity_card_repository_impl.dart` đã mang sẵn ba
  info y hệt. Sửa chúng sẽ phải đổi field thành public.
- `flutter analyze` thoát khác 0 với bất kỳ mức nào kể cả `info`, nên kết luận
  đọc theo severity count chứ không theo exit code.

### Per-story visual fidelity

REQUIRED theo §6, và đã chạy — runtime tới được (`emulator-5554`, Android 16 /
API 36), nên `MOBILE_RUNTIME_UNAVAILABLE` không áp dụng.

```
$ node render-design-canvas.js --surface=cupid-ch-ng-1 --screen=man-goc-muon-lam --out=<visual-fidelity>
$ flutter run -d emulator-5554 -t lib/main_preview.dart \
    --dart-define=PREVIEW=man-goc-muon-lam \
    --dart-define=PREVIEW_SOLO_HUB_FIXTURE=true
$ capture-mobile-screen.sh --device=emulator-5554 --max-edge=900 --out=<visual-fidelity>
MOBILE_CAPTURE: OK .../implemented-man-goc-muon-lam-emulator-5554.png 405x900 84865
```

- Design screen id đã khoá: `man-goc-muon-lam` (surface `cupid-ch-ng-1`).
- Báo cáo đầy đủ: `../visual-fidelity/visual-fidelity-report.md`.
- **`VISUAL_FIDELITY: FAIL`** — không phải vì hiện thực sai, mà vì design canvas
  và artifact có thẩm quyền mâu thuẫn nhau ở ba điểm, và
  `design-fidelity-spec.md` nói rõ mọi sai lệch nhìn thấy được đều là FAIL,
  không có waiver bằng lời văn. Ba điểm đó cần quyết định sản phẩm:
  - Design có ô filter thứ năm "Tất cả · 14"; UX §3 và AC-10 bắt buộc **đúng
    bốn** ô.
  - Design có thẻ hero mang CTA "Trước giờ đi" **kèm** nút tràn "…"; SC-4 và
    AC-11 cấm hành động chính thứ hai trên cùng một thẻ.
  - Design thay thanh tab app bằng thanh 4 mục riêng của Chặng 1; AC-22 và
    UX §1 cấm tab/route mới cho kho thẻ.
- Một sai lệch trong vùng đã sửa ngay trong phase: số đếm ngăn đổi từ `8` sang
  `· 8` cho khớp `Mới nghĩ ra · 8` của design. Đã chụp lại và chạy lại toàn bộ
  suite sau khi sửa (vẫn `+101 ~1`).
- Một sai lệch trong vùng **chưa** sửa được: UX §2 muốn icon loại hoạt động ở
  dòng 2 của thẻ, nhưng `ActivityCard.activityType` của P2 là `String?` tự do
  không có enum, nên không tồn tại bảng ánh xạ loại→icon đo được. Đóng nó cần
  đổi domain, nằm ngoài write scope của P4.

Ảnh chụp lần đầu dùng `--width=540` bị loại: trên máy 420dpi nó cho viewport
logic ~205dp làm màn hình phóng to bất thường và tiêu đề xuống dòng. Ảnh giữ
lại chụp ở 411dp logic gốc của máy, khớp tỉ lệ của design reference.

### Sai lệch so với plan, đã cân nhắc

- **l10n**: `mobile/lib/l10n/**` nằm ngoài write scope, nên hub dùng helper
  song ngữ file-local `activityHubText(context, vi, en)` — đúng cách các màn
  Home/Timeline hiện có đang làm, thay vì thêm khoá ARB.
- **Toggle "đã rủ" không bền**: `replyState` sống trong state của cubit chứ
  không ghi xuống kho, vì contract repository của P2 không có hàm ghi
  `reply_state`. Test chỉ khẳng định chip đổi giữa đúng hai giá trị, không
  khẳng định nó sống qua restart.
- **Hành động chính tạm thời**: bốn nút chính mở luồng thuộc story sau. Cho tới
  lúc đó chúng trả lời bằng thông điệp trung tính "Sắp có" đúng như UX §6 quy
  định cho điểm vào chưa lấp, nên không ngăn nào thành dead end (SC-5).
- **Filter luôn hiện**: UX §4a nói ẩn filter khi kho rỗng, nhưng §4a **không**
  nằm trong Source Of Truth của P4 (§2 chỉ cấp §1, §2, §3, §4b). Ghi lại cho P5.

### Thay đổi ngoài write scope đã khai báo

Sáu file trong §1B là toàn bộ thay đổi **code sản phẩm** của P4. Ngoài ra:

| File | Vì sao bắt buộc |
|---|---|
| `mobile/lib/main_preview.dart` | Không có entry `man-goc-muon-lam` thì không render được màn để chạy gate visual fidelity mà §6 bắt buộc. Thêm entry + `_PreviewActivityCardRepository` fixture (`--dart-define=PREVIEW_SOLO_HUB_FIXTURE=true`), không đụng entry nào có sẵn. |
| `mobile/test/features/home/presentation/home_header_notifications_test.dart` | 5 test vỡ sau khi điểm vào AC-22 lên: nhánh `unpaired` giờ dựng hub và cần `ActivityCardRepository` trong GetIt. Comment sẵn có trong chính file chứng minh `unpaired` chỉ là fixture tình cờ, nên đổi sang `PairingStatus.unknown` — vẫn ra header cặp đôi, không đổi assertion. |
| `mobile/test/features/home/presentation/timeline_entry_point_test.dart` | 2 test vỡ cùng lý do. Thêm `_EmptyActivityCardRepository` (stub rỗng, không ghi) và tham số tuỳ chọn cho harness, tiêm vào đúng case `unpaired`. Assertion về timeline entry point giữ nguyên. |
| `data/requirements/.../STORY-001_activity_card_hub/visual-fidelity/` | Ảnh chụp hiện thực + `visual-fidelity-report.md`. Thư mục này nằm ngoài `coding-plan` được cấp trong handoff WriteScope, nêu ở đây để Scrum Master thấy khi commit. |

### Không chạy ở phase này

- Runtime startup smoke ở dạng khởi động app thật với DI đầy đủ: không chạy.
  Màn hình được xác minh qua preview harness với fixture, đúng cách
  `design-fidelity-spec.md` quy định (state cố định bằng dữ liệu giả, không
  lái runtime thật).

  > **ĐÃ BỊ THAY THẾ (vòng patch B-1/B-2, 2026-09-08).** Lập luận trên sai ở
  > chỗ nó coi preview harness là đủ thay cho startup smoke. Phán quyết R-2
  > (`master-plan.md` §6) ra sau đó: startup smoke là **REQUIRED**, và phải là
  > `main.dart` với DI thật — không `main_preview.dart`, không
  > `PREVIEW_SOLO_HUB_FIXTURE`. Fixture không đi qua migration v2→v3, không đi
  > qua cổng chưa-ghép-đôi, nên nó không thể chứng minh thứ mà rule 12g hỏi.
  > Kết quả thật ghi ở § Phase P8 bên dưới.
- `flutter test` toàn bộ repo: không chạy. §6 chỉ định phạm vi
  `test/features/activity_cards/ test/features/home/`.

## Phase P4 — Vòng 2 (rework sau phán quyết "bám design" cho D-1/D-2/D-3)

- Lane: Mobile
- Date: 2026-09-07
- BaseHead: `54173ad5954afe015843e68d08fdd7ed079281cc`
- Nguồn thay đổi: user chốt "bám design" cho cả ba delta; PO vá AC-10, AC-11,
  AC-22 trong `requirements/requirements.md`, UX §1/§3 trong `ux/uiux-spec.md`,
  và `## Design Ruling Log` D-1/D-2/D-3 trong `req_master.md`. Vòng này dựng
  lại theo văn bản AC **mới**, không mở lại tranh luận.

### Đã dựng lại theo AC mới

| AC | Thay đổi | File |
|---|---|---|
| AC-10 / D-1 | `ActivityCardPane` (5 giá trị) thay `ActivityCardStatus` làm khoá ngăn. `all` đứng đầu và là mặc định, là **view** chứ không phải trạng thái thứ năm — vòng đời vẫn 4 giá trị, `ActivityCardStatus` không đổi. `countForPane` trả `storeCount` cho `all`. | `activity_card_list_cubit.dart`, `activity_status_filter.dart` |
| AC-11 / D-2 | Footer thẻ = đúng 1 CTA gradient + đúng 1 nút tràn `…` tròn, nền `colorSurfaceAlt`, hẹp hơn CTA, không `--grad`. Menu chỉ chứa Chuyển trạng thái / Sửa / Xoá — không bao giờ là CTA thứ hai. | `activity_card_tile.dart`, `activity_card_hub_view.dart` |
| AC-22 / D-3 | Nhánh chưa-ghép-đôi của `HomeScreen` dựng `_SoloStageOneShell`: `CupidTabBar` 4 mục `Muốn làm · Ý tưởng · Sổ tay · Nhật ký`, `Muốn làm` mặc định và trỏ tới `ActivityCardHubView`, ba mục còn lại là `_SoloTabPlaceholder` theo UX §6. Nhánh đã-ghép-đôi giữ nguyên shell cũ. | `home_screen.dart` |

`all` được phục vụ bằng cách gộp 4 truy vấn có giới hạn theo từng trạng thái
rồi sắp theo `updatedAt` giảm dần, offset mỗi trạng thái suy ra từ số thẻ đã
nạp. Không thêm hàm nào vào `ActivityCardRepository` (file đó ngoài write
scope) và vẫn không đọc cả kho.

### Static analysis

```
$ flutter analyze lib test
195 issues found. (ran in 7.0s)
```

- `error` count: **0**. 195 issue còn lại là warning/info có sẵn ở các file
  không liên quan (phạm vi analyze rộng hơn vòng 1 nên số lớn hơn).

### Test

```
$ flutter test test/design_system test/features/activity_cards test/features/home
00:16 +194 ~1 -2
```

- `test/features/activity_cards`: **58/58 pass**.
- `test/features/home`: **47 pass, 1 skip** (skip có sẵn từ trước P4).
- `test/design_system/no_fork_guard_test.dart`: pass sau khi sửa 2 vi phạm do
  vòng này gây ra (xem dưới).
- 2 test đỏ còn lại **đều đã đỏ ở BaseHead** và nằm ngoài write scope:
  - `shared_backdrop_occlusion_guard_test.dart` AC2 — vi phạm duy nhất còn lại
    là `lib/features/reminders/presentation/screens/reminder_schedule_screen.dart:79`,
    file này vòng nào của STORY-001 cũng không đụng tới.
  - `shared_backdrop_occlusion_test.dart` "chat shows the shared sky wash" —
    `pumpAndSettle timed out` trên màn chat, không liên quan tới STORY-001.

### Hai regression vòng này tự gây ra và đã tự sửa

- `no_fork_guard_test` AC-4: `Colors.transparent` trong `_StatusCell` và
  `context.cupidColors.colorBackground` trong `_SoloStageOneShell` đều khớp
  chuỗi cấm `Colors.` (guard so khớp chuỗi thô, nên `cupidColors.` cũng dính).
  Sửa: `color: isSelected ? colors.colorAccentPink : null`, và hoist
  `final CupidColorTokens colors = context.cupidColors;` trước khi dùng.
- `shared_backdrop_occlusion_guard_test` AC2: `_SoloStageOneShell` và
  `ActivityCardHubView` đều đặt `Scaffold(backgroundColor: colors.colorBackground)`,
  che lớp `--sky` dùng chung. Bỏ cả hai fill theo đúng `architecture/solution.md`
  AD-3 (fill của hub là nợ có sẵn từ BaseHead, tiện tay trả luôn vì file trong
  write scope).

### Per-story visual fidelity — vòng 2

```
$ flutter run -d emulator-5554 -t lib/main_preview.dart \
    --dart-define=PREVIEW=man-goc-muon-lam \
    --dart-define=PREVIEW_SOLO_HUB_FIXTURE=true
$ adb -s emulator-5554 exec-out screencap -p
$ sips -z 900 405
MOBILE_CAPTURE: OK .../implemented-man-goc-muon-lam-round2.png 405x900
```

- **`VISUAL_FIDELITY: FAIL`**, nhưng vì lý do **mới** — D-1/D-2/D-3 đã đóng và
  khớp reference. Báo cáo đầy đủ: `../visual-fidelity/visual-fidelity-report.md`.
- Còn lại: D-4 và D-5 mang sang nguyên trạng từ vòng 1; D-6 (mới) là lệch glyph
  của thanh tab; D-7 (mới) là lỗi của chính harness chụp ảnh.
- D-6: design vẽ checklist / bóng đèn / sách mở / trang kẻ có bút chì.
  `CupidIcons` không có codepoint nào trong bốn cái đó, và
  `lib/design_system/icons/cupid_icons.dart` ngoài write scope, nên vòng này
  dùng bốn token gần nhất (`checkCircle`, `autoAwesome`, `draw`, `schedule`).
  UX §1 chỉ ràng buộc kiểu (`icon line` + nhãn bên dưới), không nêu tên glyph.
  Cần **mở rộng write scope**, không cần quyết định sản phẩm.
- D-7: `main_preview.dart:222` vẫn đăng ký `man-goc-muon-lam` với
  `wrapInShell: true` và `:2158` vẫn map nó về `PreviewAppShellTab.home` — cả
  hai có từ trước D-3, khi hub thật sự nằm trong tab "Nhà". Hậu quả: ảnh chụp
  có **hai** thanh dưới chồng nhau (thanh Chặng-1 mới, và thanh app shell 5 tab
  cũ bên dưới). Bản build sản phẩm chỉ có một thanh. File ngoài write scope.

### Thay đổi ngoài write scope

Không có. `git diff --name-only <BaseHead>` cho đúng 6 file, trùng khít
WriteScope của run này (5 file `lib/` + 1 file test), cộng hai artifact trong
`coding-plan/` và `visual-fidelity/` đã được cấp.

### Đỏ có sẵn cần Scrum Master định tuyến

| Test | Nguyên nhân | File cần sửa (ngoài write scope) |
|---|---|---|
| `test/core/navigation/app_shell_test.dart` — 3 test | Helper đăng ký DI của file này (`~:187–200`) đăng ký 5 singleton nhưng thiếu `ActivityCardRepository`, nên nhánh chưa-ghép-đôi của `HomeScreen` ném `Bad state: ... not registered inside GetIt`. Đã xác nhận **đỏ sẵn ở BaseHead**: `git show <BaseHead>` cho thấy `home_screen.dart` và `activity_card_hub_view.dart` lúc đó đã dựng hub y hệt qua `getIt<ActivityCardRepository>()`. Cùng loại lỗi mà vòng 1 đã sửa cho hai file test khác. | `mobile/test/core/navigation/app_shell_test.dart` |
| `shared_backdrop_occlusion_guard_test.dart` AC2 | `Scaffold(backgroundColor: palette.colorBackground)` che lớp `--sky`. | `mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart:79` |
| `shared_backdrop_occlusion_test.dart` chat | `pumpAndSettle timed out`. | màn chat, chưa khoanh vùng |
| D-6 glyph thanh tab | Thiếu 4 codepoint. | `mobile/lib/design_system/icons/cupid_icons.dart` |
| D-7 hai thanh chồng nhau | `wrapInShell` sai sau D-3. | `mobile/lib/main_preview.dart:222` và `:2158` |

## P4 — vòng 3 (mở rộng write scope hẹp: đóng D-6 và D-7)

- Lane: Mobile
- Date: 2026-09-08
- BaseHead: `98e865d777c03e9f3bf8d93178d35a0bb45973e6`
- Nguồn thay đổi: user cấp write scope hẹp cho đúng 2 file `lib/` mà vòng 2 đã
  chỉ đích danh. Không đụng cubit/filter/tile/test của vòng trước.

### D-6 — 4 token icon mới

Design **gọi tên glyph trực tiếp**, nên đây không phải phán đoán: `Cupid Chặng
1 Screens.dc.html` dòng 91/92/94/95 ghi `checklist`, `lightbulb`, `menu_book`,
`edit_note`. Cả 4 đều tra được trong cmap của font đang bundle:

```
$ python3 -c "fontTools.ttLib.TTFont(assets/fonts/MaterialSymbolsRounded-Variable.ttf).getBestCmap()"
checklist  0xe6b1        (0xe6b3 = checklist_rtl, glyph khác — không thay thế)
lightbulb  0xe0f0/0xe90f (hai codepoint trỏ cùng một glyph)
menu_book  0xea19        (khác book 0xe865 và auto_stories 0xe666)
edit_note  0xe745        (khác edit 0xe3c9 và note_alt 0xf040)
```

Đọc cmap bằng `fontTools` đúng theo quy tắc ghi ở đầu `cupid_icons.dart`:
codepoint phải tra từ font đang bundle, không nhớ từ PUA của font icon khác.
`_SoloStageOneShellState._icons` chuyển từ `checkCircle`/`autoAwesome`/`draw`/
`schedule` sang `checklist`/`lightbulb`/`menuBook`/`editNote`.

### D-7 — lỗi harness, không phải lỗi sản phẩm

`man-goc-muon-lam` bỏ `wrapInShell: true` và bỏ nhánh `PreviewAppShellTab.home`
đã cũ trong `_PreviewScreen.build`. Chỉ sửa đúng entry này; mọi entry
`wrapInShell` khác giữ nguyên nên không màn nào khác đổi khung chụp.

### Static analysis

```
$ flutter analyze lib/design_system/icons/cupid_icons.dart lib/features/home/presentation/home_screen.dart lib/main_preview.dart
5 issues found. (ran in 3.0s)
```

- `error` count: **0**, và **0 issue mới** từ vòng này. Đúng 5 issue đó là nợ có
  sẵn, đã ghi ở vòng trước (dòng ~313): `home_screen.dart` `_daysRowGap` /
  `_daysUnitBaselineLift` / `_daysUnitFontSize` `unused_element`,
  `main_preview.dart` `unused_import` + `unnecessary_import`. Tất cả nằm ngoài
  diff vòng này. `flutter analyze` thoát khác 0 với bất kỳ mức nào kể cả `info`,
  nên exit code không phải tín hiệu đỏ ở đây.

### Test

```
$ flutter test test/features/activity_cards/activity_card_hub_view_test.dart
00:01 +25: All tests passed!
```

- Đây là file test duy nhất chạm tới `SoloStageOneTab` (đã grep `test/` và
  `lib/`). Không test nào khẳng định token icon cụ thể, nên đổi glyph không phá
  hợp đồng test nào; 25/25 xanh, gồm cả AC-22/D-3 và AC-22/AC-21.

### Per-story visual fidelity — vòng 3

```
$ flutter run -d emulator-5554 -t lib/main_preview.dart \
    --dart-define=PREVIEW=man-goc-muon-lam \
    --dart-define=PREVIEW_SOLO_HUB_FIXTURE=true
$ adb -s emulator-5554 exec-out screencap -p
$ sips -z 900 405
MOBILE_CAPTURE: OK .../implemented-man-goc-muon-lam-round3.png 405x900
```

- **D-6 đóng**: thanh tab vẽ đúng checklist / bóng đèn / sách mở / trang kẻ có
  bút chì, khớp reference từng glyph.
- **D-7 đóng**: đúng **một** thanh dưới. Thanh shell 5 tab cũ đã biến mất, dải
  dọc dưới danh sách thẻ giờ so được với reference, và phần vừa trống ra để lộ
  thẻ thứ 4 mà vòng 2 bị cắt.
- **`VISUAL_FIDELITY: FAIL`** — vẫn FAIL, nhưng **chỉ còn** D-4 và D-5, hai
  delta mang nguyên trạng từ vòng 1. Vòng này không đụng tile hay domain nên
  không thể đóng chúng.
- Không tự ý ghi PASS: `.agent-contract/design-fidelity-spec.md` chỉ cho hai giá
  trị PASS/FAIL, PASS đòi không còn sai lệch nhìn thấy được, và **không có
  waiver bằng lời văn** ở mức story. D-4/D-5 còn nhìn thấy được thì token phải
  là FAIL. Đây là chỗ Scrum Master phải định tuyến, không phải chỗ vòng lặp thêm
  của mobile lane giải quyết được.

### Thay đổi ngoài write scope

Không có. Diff vòng này đúng 2 file `lib/` đã cấp, cộng 2 artifact
(`coding-plan/test-results.md`, `visual-fidelity/`) và ảnh chụp vòng 3.

## P7 — `ActivityType` enum + icon trên thẻ, và D-4

Phase: `coding-plan/phase-P7-activity-type-enum-and-card-icon.md`.
Hai việc trong cùng một lane: hiện thực P7 và đóng delta thiết kế D-4.

### Analyze

```
$ flutter analyze --no-fatal-infos --no-fatal-warnings \
    lib/features/activity_cards lib/core/database lib/design_system/icons \
    lib/main_preview.dart test/features/activity_cards
8 issues found. (ran in 1.9s)   # exit 0
```

- `error` count: **0**, `warning` mới: **0**. 8 issue còn lại là nợ có sẵn:
  6 `prefer_initializing_formals` trong `activity_cards/`, cùng
  `main_preview.dart` `unused_import` (dòng 119) + `unnecessary_import`
  (dòng 126) đã ghi ở các vòng trước. Không cái nào nằm trong diff vòng này.
- Vì sao thu hẹp đường dẫn thay vì chạy `flutter analyze lib test`: bản đầy đủ
  in ra hàng vạn ký tự `info` (`withOpacity` deprecated, v.v.) và **bị cắt mất
  phần đuôi**, che đúng 2 dòng `error` thật. Guard chặn `grep` trên output nên
  cách lọc duy nhất là thu hẹp danh sách đường dẫn.

### Test

```
$ flutter test test/features/activity_cards/
00:02 +77: All tests passed!
```

- File mới `test/features/activity_cards/activity_type_test.dart` phủ đúng §6:
  - `ActivityType vocabulary` — enum đúng 8 thành viên khớp từ vựng gói nội
    dung, mỗi thành viên round-trip qua tên ASCII chuẩn, và chuỗi lạ
    (`chiều`, `''`, `Outing`, `tối nay được`, `null`) đọc ra `null` chứ không ném.
  - `Drift storage` — 8/8 thành viên sống sót write/read; một hàng mang giá trị
    tự do thời trước từ vựng (`UPDATE ... SET activity_type = 'chiều'`) vẫn đọc
    được, giữ nguyên các trường khác và trả `activityType == null`;
    `schemaVersion == 3` không đổi, cột vẫn `TEXT NULL`.
  - `Card tile line 2 (D-5)` — 8 khẳng định glyph theo từng thành viên,
    `null` → `CupidIcons.label`, không có dòng 2 thì không vẽ icon, và chuỗi meta
    là `'2026-09-07 · 1.8 km · 70.000đ'` — không còn wire value nào lọt ra text.
  - `Card tile delete affordance (D-4)` — không còn `activity_card_delete_x`,
    không còn `CupidIcons.remove`, và đường xoá vẫn tới được qua `…` → `Xoá`.
- Không có migration và không đụng `schemaVersion`: diff của
  `cupid_database.g.dart` là 35 thêm / 35 bớt, toàn bộ nằm trong cột
  `activityType` (`GeneratedColumnWithTypeConverter`, `$converteractivityType`,
  kiểu hàng và companion). Không DDL, không bước migration mới.
- `activity_card_repository_impl.dart` **không cần sửa**: `Value(draft.activityType)`
  và `row.activityType` chỉ đổi kiểu, trong suốt với repository.

### Per-story visual fidelity — vòng 4

```
$ flutter build apk --debug -t lib/main_preview.dart \
    --dart-define=PREVIEW=man-goc-muon-lam \
    --dart-define=PREVIEW_SOLO_HUB_FIXTURE=true
$ .ai-team-bundle/runtime/tools/capture-mobile-screen.sh --lease-exec -- ...
MOBILE_CAPTURE: OK .../implemented-man-goc-muon-lam-round4-emulator-5554.png 405x900 128325
```

- **D-4 đóng**: không thẻ nào còn dấu gạch xoá. Footer mỗi thẻ đúng một CTA
  gradient + một `…` tròn, khớp canvas. Đường xoá đi qua `…` → `Xoá`.
- **D-5 đóng**: chữ loại hoạt động biến mất khỏi dòng 2, thay bằng glyph đã ánh
  xạ (dĩa-dao `restaurant` cho `dining`, vé `local_activity` cho `outing`). Dòng
  2 thẻ cà phê đọc `1.8 km · 70.000đ` thay vì `chiều · 1.8 km · 70.000đ` như
  vòng 3. Nguyên nhân vòng 1 nêu ("`activityType` là `String?` tự do, không có
  enum nên không đo được ánh xạ type→icon") không còn đúng. Canvas còn vẽ glyph
  trong avatar tròn bên trái tiêu đề, nhưng vị trí đó **không mở lại**: P7 §3 và
  `ux/uiux-spec.md` §2 đều chỉ định dạng inline ở dòng 2, và lane hiện thực
  đúng spec được duyệt thay vì tự xếp hạng hai thẩm quyền.
- **Delta mới D-8** (chặn, Product Owner phân xử): canvas mang bốn từ bối cảnh
  mà không trường nào trong `architecture/contract-summary.md` §3 chứa được —
  `ngoài trời đang mưa` (nguồn dòng 125), `chiều` (141), `tối nay được` (152),
  `Theo lịch âm` (160) trong `Cupid Chặng 1 Screens.dc.html`. Cảnh báo đo lường
  ở P7 §6 kích hoạt đúng như đã viết; lane dừng ở mức báo cáo, **không thêm
  cột, không nhét chữ vào enum**. Ghi thành mục delta riêng trong
  `visual-fidelity-report.md` §3, không phải ghi chú mềm.
- **`VISUAL_FIDELITY: FAIL`** vì D-8 còn nhìn thấy được. Theo định tuyến của
  Scrum Master, D-8 không giữ `MOBILE_COMPLETE` của vòng này: không còn gì để
  hiện thực, chỉ còn phân xử sản phẩm.

### Ghi chú glyph

`card_giftcard` mà P7 §3 gọi tên **không có trong cmap** của
`MaterialSymbolsRounded-Variable.ttf` đang bundle. Hai glyph quà duy nhất có
mặt là `redeem` 0xe8b1 và `featured_seasonal_and_gifts` 0xef91. Lane thay bằng
`redeem` và ghi lý do ngay trên token, thay vì bịa codepoint. Cần Tech Lead xác
nhận, nhưng không chặn.

### Thay đổi ngoài write scope

Không có. Toàn bộ 12 file sửa + 2 file mới đều nằm trong `write_scope` của
`data/runtime/parallel-runs/RUN-...-STORY-001-mobile-dev.json`. Ba file mà bản
tóm tắt handoff trong ngữ cảnh agent bị thiếu — `activity_card_hub_view.dart`,
`activity_card_hub_view_test.dart`, `occasion_suggestion_service_test.dart` —
có mặt đầy đủ trong run file (write_scope[10..12]), là nguồn mà guard áp dụng.
Sửa ở đó là tối thiểu và bắt buộc: gỡ `onDelete:` ở caller duy nhất, đổi kiểu
helper `_card()`, và đảo khẳng định D-4 cũ (`findsOneWidget` → `findsNothing`)
vốn đang khoá chính phán quyết D-4.

## Phase P5 — Phút 1 (kho trống) + quick capture + dải 3 ô

- Lane: Mobile
- Date: 2026-09-08
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Package: `mobile/` (`cupid_mobile`)

### File tạo mới

| File | Vai trò |
| --- | --- |
| `mobile/lib/features/activity_cards/presentation/widgets/quick_entry_strip.dart` | Dải quick-entry cố định 3 ô, không đổi hình theo dữ liệu |
| `mobile/lib/features/activity_cards/presentation/widgets/quick_capture_sheet.dart` | Sheet một trường + `QuickCaptureAddAction` (nút "+") |
| `mobile/lib/features/activity_cards/presentation/widgets/minute_one_empty_state.dart` | Trạng thái rỗng tuyệt đối với đúng hai lời mời |
| `mobile/test/features/activity_cards/quick_capture_sheet_test.dart` | 6 test |
| `mobile/test/features/activity_cards/minute_one_empty_state_test.dart` | 8 test (gồm 1 test chụp ảnh, `skip` khi không bật cờ) |

### Analyze

```
$ flutter analyze lib/features/activity_cards/presentation/widgets/quick_entry_strip.dart \
    lib/features/activity_cards/presentation/widgets/quick_capture_sheet.dart \
    lib/features/activity_cards/presentation/widgets/minute_one_empty_state.dart \
    test/features/activity_cards/quick_capture_sheet_test.dart \
    test/features/activity_cards/minute_one_empty_state_test.dart
Analyzing 5 items...
No issues found! (ran in 2.6s)
exit=0
```

```
$ flutter analyze lib test
exit=1
```

`exit=1` ở lệnh toàn package là **nợ có sẵn, không phải của pha này**: không có
`error` nào, chỉ `info`/`warning` đã tồn tại từ trước ở `core/`, `dream_jar/`,
`emojis/` (`prefer_initializing_formals`, `deprecated_member_use` với
`withOpacity`, `unused_import`). Không có mục nào trỏ vào 5 file của P5 — đã
kiểm chứng bằng lệnh phạm vi hẹp phía trên, trả về `No issues found!`.

### Test

```
$ flutter test test/features/activity_cards/
00:02 +90 ~1: All tests passed!
exit=0
```

`~1` là test chụp ảnh, bị `skip` khi `CAPTURE_VISUALS` chưa bật — đúng thiết kế.

```
$ flutter test test/features/activity_cards/minute_one_empty_state_test.dart \
    --dart-define=CAPTURE_VISUALS=true
00:00 +8: All tests passed!
exit=0
```

### Cổng §6 của `phase-P5-...md`

| Gate §6 | Test | Kết quả |
| --- | --- | --- |
| Unit: nhánh rỗng tuyệt đối | `storeCount == 0` khi kho trống | PASS |
| Unit: nhánh một ô đã có thẻ | thẻ `memory` + `selectPane(idea)` → `cards` rỗng nhưng `storeCount == 1` | PASS |
| Widget: không có trường onboarding nào ngoài một trường URL | `EditableText` findsOneWidget, `Form`/`TextFormField` findsNothing | PASS |
| Widget: chạm lời mời tạo thẻ, không có màn bắt buộc xen giữa | cả hai lời mời → `createCard` mà không hiện `EditableText` nào ở nhánh gợi ý | PASS |
| Widget: dải 3 ô không đổi hình | bề rộng 3 ô giống hệt nhau ở cả hai trạng thái, đúng 3 nhãn, không `Badge` | PASS |

Ánh xạ AC: AC-1 (một trường, không form), AC-2 (dải 3 ô luôn hiện), AC-3 (gợi ý
theo dịp tạo thẻ một chạm), AC-6 (lưu ngay khi submit, không nút xác nhận; "+"
ẩn trong Phút 1), AC-7 (link trần không tiêu đề vẫn thành thẻ, `origin` =
`pastedLink`).

### Quyết định phải ghi lại

- **Không thêm khoá ARB.** Handoff liệt kê `mobile/lib/l10n/app_vi.arb`, nhưng
  đường dẫn thật là `mobile/lib/l10n/arb/app_vi.arb` — không nằm trong write
  scope. Lane theo tiền lệ P4: dùng helper song ngữ cục bộ
  `activityHubText(context, vi, en)` trong `activity_status_filter.dart`, không
  đụng ARB. Nếu Product Owner muốn chuỗi vào ARB thì đó là một pha riêng cho cả
  cụm chuỗi của hub, không phải sửa lẻ ở đây.
- **Thay glyph.** `cupid_icons.dart` bị cấm trong pha này, nên ba token cần cho
  dải 3 ô và lời mời được lấy từ cmap đã có: `redeem`, `mood`, `autoAwesome`,
  `schedule`, `link`, `add`. `mood` được chọn cho "gợi mở trò chuyện" để tránh
  trùng `lightbulb` vốn là glyph tab "Ý tưởng". Lý do ghi ngay trên chỗ dùng.
- **Ô chưa có nội dung không phải ngõ cụt (SC-5).** Ô nào chưa có luồng thật thì
  trả về SnackBar trung tính `Sắp có`, cùng một câu với các chỗ chưa dựng khác,
  chứ không im lặng và cũng không bịa nội dung.

### Khoảng hở còn lại (không phải lỗi của pha này)

Ba widget P5 hiện đứng độc lập, chưa được gắn vào màn hub: `_EmptyPane` trong
`activity_card_hub_view.dart` vẫn trả về `SizedBox(key:
Key('activity_card_hub_minute1_slot'))`, và P4 vẫn dùng `_QuickEntryStrip`
riêng của nó. Cả hai file đều nằm ngoài write scope của pha này (P7 giữ
`activity_card_hub_view.dart`). Việc gắn `MinuteOneEmptyState` vào slot đó,
thay `_QuickEntryStrip` cũ bằng `QuickEntryStrip`, và đưa
`QuickCaptureAddAction` vào khung hub cần một handoff sau có
`activity_card_hub_view.dart` trong write scope.

### Thay đổi ngoài write scope

Không có. 5 file mới đều nằm trong `write_scope` của run P5; không file nguồn
sẵn có nào bị sửa.

## Phase P6 — Màn chi tiết thẻ, vòng đời trạng thái và xoá thẻ

- Lane: Mobile
- Date: 2026-09-08
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Package: `mobile/` (`cupid_mobile`)

### File tạo mới

| File | Vai trò |
| --- | --- |
| `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart` | Máy trạng thái của màn chi tiết: đổi trạng thái hai chiều, câu hỏi AC-15, xoá thẻ, sửa trường tại chỗ |
| `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` | Một màn, hai chế độ (ghi lại / xem lại), đúng một CTA theo bảng SC-4 |
| `mobile/lib/features/activity_cards/presentation/widgets/status_change_picker.dart` | Sheet đổi trạng thái (đủ 4, không lọc chiều) + hộp thoại AC-15 + `ActivityDialogChoiceButton` dùng chung |
| `mobile/lib/features/activity_cards/presentation/widgets/delete_card_dialog.dart` | Hộp thoại xoá thẳng một bước (AC-16) |
| `mobile/test/features/activity_cards/card_lifecycle_ui_test.dart` | 16 test |
| `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart` | 7 test (gồm 1 test chụp ảnh, `skip` khi không bật cờ) |

### Analyze

```
$ flutter analyze lib/features/activity_cards test/features/activity_cards
Analyzing 2 items...
7 issues found. (ran in 3.1s)
exit=1
```

Cả 7 đều là `info • prefer_initializing_formals`, và 6 trong số đó đã có sẵn
trước pha này (`activity_card_repository_impl.dart` x3,
`occasion_suggestion_service.dart`, `activity_card_list_cubit.dart` x2). Mục thứ
7 là `activity_card_detail_cubit.dart:71`, tức constructor mới của pha này —
**không sửa được và là cảnh báo sai**: initializing formal đòi tham số tên
`this._repository`, mà Dart cấm tham số tên bắt đầu bằng `_`. Đây đúng là lý do
`activity_card_list_cubit.dart` bên cạnh cũng mang y hệt info này. Không có
`error`, không có `warning` nào trong 4 file nguồn và 2 file test của P6.

```
$ flutter analyze lib test
196 issues found. (ran in 3.2s)
exit=1
```

`exit=1` toàn package là nợ có sẵn: 0 `error`, 35 `warning`, 161 `info`, đều nằm
ở `core/`, `dream_jar/`, `emojis/`, `timeline/`. Đã kiểm chứng từng file của P6
trong danh sách 196 mục: chỉ đúng 1 dòng trỏ vào
`activity_card_detail_cubit.dart` (chính là info nói trên); không mục nào trỏ
vào `activity_card_detail_screen.dart`, `status_change_picker.dart`,
`delete_card_dialog.dart` hay `card_lifecycle_ui_test.dart`.

### Test

```
$ flutter test test/features/activity_cards/ --reporter=failures-only
+112 ~2: 2 skipped tests.
+112 ~2: All other tests passed!
exit=0
```

`~2` là hai test chụp ảnh (P5 và P6), bị `skip` khi `CAPTURE_VISUALS` chưa bật.

```
$ flutter test test/features/activity_cards/activity_card_detail_screen_test.dart \
    --dart-define=CAPTURE_VISUALS=true
00:01 +7: All tests passed!
exit=0
```

### Cổng §6 của `phase-P6-...md`

| Gate §6 | Test | Kết quả |
| --- | --- | --- |
| Unit: cubit chi tiết | `card_lifecycle_ui_test.dart` nhóm "card fields" + "write failures" | PASS |
| Widget: một chạm vừa đặt ngày vừa đổi trạng thái (AC-12) | `scheduleDate` ghi `updateStatus(scheduled)` một lần, thẻ rơi đúng ngăn | PASS |
| Widget: vòng đời chạy được cả hai chiều (AC-14) | vòng lặp qua đủ 12 cặp trạng thái có thứ tự, không cặp nào bị chặn | PASS |
| Widget: lùi trạng thái không mất dữ liệu ngầm (AC-15) | 5 nhánh: hỏi / giữ / xoá ngày / bỏ qua hộp thoại / không có ngày thì không hỏi | PASS |
| Widget: xoá là một hộp thoại thẳng (AC-16) | không `EditableText`, hai nút cùng `fontSize`/`fontWeight`, chỉ nhãn xoá mang `colorRed`, không có câu níu kéo | PASS |
| Widget: không có chỉ số hành vi / lời phán xét (AC-18, AC-19) | quét toàn bộ `Text.data` ở cả 4 trạng thái với 15 từ khoá cấm | PASS |
| Visual fidelity: bắt buộc, ngay trong story này | `visual-fidelity/visual-fidelity-report.md` §8, 2 cặp thiết kế + 3 frame | PASS (14 delta, không delta nào là blocker) |

Ánh xạ AC: AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19.

### Quyết định phải ghi lại

- **Ranh giới lưu trữ: sửa trường là tại chỗ, không ghi xuống store.** Hợp đồng
  repository của P2 chỉ có `updateStatus`, `clearScheduledDate`, `deleteCard`,
  `createCard` — không có `setScheduledDate` và không có hàm ghi trường tổng
  quát; các file repository lại nằm ngoài write scope của pha này. Nên cubit giữ
  bản làm việc trong bộ nhớ cho mọi sửa trường (kể cả ngày đã chọn ở AC-12), và
  chỉ ba lệnh trên mới chạm store. Tiền lệ là `ActivityCardListState.
  replyOverrides` vốn đã mô tả đúng khe hở này cho cột `reply_state`. AC-12 vẫn
  đo được vì thẻ rơi đúng ngăn nhờ `status` đã được ghi thật. **Đây là việc phải
  làm tiếp, không phải blocker**: cần một pha có repository trong write scope để
  bổ sung đường ghi trường, nếu không thì ngày hẹn và các sửa trường không sống
  qua lần mở lại màn.
- **`updated_at` là của repository.** Helper `_edit` trong cubit cố tình giữ
  nguyên `updatedAt` thay vì tự đặt `DateTime.now()`, để không tạo ra hai nguồn
  sự thật cho cột đó.
- **Nhánh phá huỷ không bao giờ là mặc định.** Hai nút của hộp thoại AC-15 và
  AC-16 đều là `GestureDetector` vẽ giống hệt nhau, không nút nào là
  `ElevatedButton`/`FilledButton` và không nút nào `autofocus`, nên không phím
  Enter hay hành vi trợ năng mặc định nào kích được nhánh xoá. Đóng hộp thoại
  trả `null` và được hiểu là "để yên thẻ".
- **Thay glyph.** `cupid_icons.dart` ngoài write scope, nên `event` → `schedule`,
  `history` → `menuBook`, `image` → `photoCamera`, thùng rác → `remove`. Cùng
  quy tắc D-13, ghi lại thành D-20.
- **Ô chuẩn bị chưa có luồng thật** trả SnackBar trung tính "Phần chuẩn bị nằm ở
  bước sau." vì STORY-002 mới là chủ của bước đó — theo đúng SC-5 như P5.
- **Test chụp ảnh phải tự kiểm chứng frame.** Lần chụp đầu ghi ra ba PNG mà cả
  ba đều là trạng thái *Mới nghĩ ra*: pump lại cùng một loại widget khiến
  element tree được tái dùng, `BlocProvider.create` không chạy lại. Đã sửa bằng
  cách khoá màn theo trạng thái, và vòng lặp chụp giờ đọc ngược nhãn pill rồi
  mới ghi file — một frame dán nhãn sai còn tệ hơn không có bằng chứng.

### Khoảng hở còn lại (không phải lỗi của pha này)

- Màn chi tiết chưa có route: `activity_card_hub_view.dart` (chủ sở hữu chỗ gắn)
  nằm ngoài write scope, y như ba widget P5. Cần một pha tích hợp sau có file đó
  trong write scope để mở màn từ thẻ.
- Đường ghi trường xuống store (xem quyết định đầu tiên ở trên).
- `VISUAL_FIDELITY: FAIL` ở đầu `visual-fidelity-report.md` vẫn giữ nguyên vì
  D-8 còn mở và thuộc quyền Product Owner; vòng 6 của P6 không mở lại D-8.

### Thay đổi ngoài write scope

Không có. 4 file nguồn và 2 file test đều nằm trong `write_scope` của run P6;
không file nguồn sẵn có nào bị sửa.

## Phase P8 + vòng vá B-1/B-4/B-5 — đường ghi trường và nối điểm đến

Vòng này gộp sáu mục của handoff patch (B-1, B-2/P8, B-3, B-4, B-5, B-6) vào
**một** lần merge theo ràng buộc B-3 của `master-plan.md` §5.

### File đã sửa

| File | Mục | Nội dung |
|------|-----|----------|
| `domain/activity_card.dart` | B-2 | Thêm `ActivityCardEdit` (11 trường) + `ActivityCardEdit.from(card)` |
| `domain/activity_card_repository.dart` | B-2 | Thêm `updateCardDetails`; `updateStatus`/`clearScheduledDate` đổi sang `Future<int>` |
| `data/activity_card_repository_impl.dart` | B-2 | Hiện thực ghi ảnh chụp toàn phần; trả row count |
| `presentation/activity_card_detail_cubit.dart` | B-2 | Mọi mutator đi qua `_persist`: ghi-rồi-emit |
| `presentation/screens/activity_card_detail_screen.dart` | B-2 | 5 `FocusNode` + commit khi submit/mất focus |
| `presentation/screens/activity_card_hub_view.dart` | B-1, B-5 | Nối điều hướng thật; xoá placeholder `_QuickEntryStrip` |
| `presentation/widgets/quick_entry_strip.dart` | S5-F-4 | `LayoutBuilder` + fallback cuộn ngang khi hẹp |
| `test/features/activity_cards/card_lifecycle_ui_test.dart` | B-3 | Sửa 2 test chứng nhận lỗi; thêm 4 test nhánh ghi thất bại |
| `test/features/activity_cards/activity_card_repository_test.dart` | B-2 | Thêm nhóm `updateCardDetails` (3 test) |
| `test/core/navigation/app_shell_test.dart` | B-4 | Đăng ký `ActivityCardRepository` vào GetIt; sửa assertion theo AC-22 |

`core/database/daos/activity_card_dao.dart` **không** đổi: `updateCard` của P1 đã
đúng §7.9 sẵn (`WHERE owner_key = ? AND id = ?`, trả row count). Đã đọc rồi mới
kết luận, không phải bỏ qua.

### Test

```
flutter test test/features/activity_cards/activity_card_repository_test.dart \
             test/features/activity_cards/card_lifecycle_ui_test.dart \
             test/core/navigation/app_shell_test.dart --reporter compact
00:04 +39: All tests passed!
```

39/39 xanh — repository 9, card lifecycle 19, app shell 11.

### B-3 — hai test từng chứng nhận mất dữ liệu

- *"picking a date saves it"*: trước đây assert `repository.calls` là rỗng, tức
  là chứng nhận rằng ngày **không** được lưu. Nay assert đúng chuỗi ghi
  `['updateCardDetails:card-1', 'updateStatus:card-1:scheduled']` và
  `lastEdit.scheduledOn == '2026-10-01'`.
- Cú lùi trạng thái âm thầm: nay assert `['updateStatus:card-1:idea']` và
  `clearScheduledDate` chỉ chạy ở nhánh người dùng chọn "xoá".
- Test "mỗi trường SB-76 sửa được, xoá được, lưu được": trước đây assert
  `repository.calls` rỗng kèm chú thích "field edits are screen-local until a
  field writer exists". Nay đếm 9 rồi 14 lần ghi và so từng trường của
  `lastEdit`, gồm cả các giá trị `null` khi xoá trường.
- 4 test mới cho nhánh store từ chối ghi: trạng thái không đi trước store khi
  ghi ngày bị từ chối, khi lùi trạng thái bị từ chối, khi ghi trường bị từ chối.

`_RecordingRepository` nay nhận `rowsWritten` để test được phân biệt "ghi thành
công" với "thẻ không phải của owner này" — thứ mà trước `Future<int>` không có
cách nào diễn đạt (S2-F2-3).

### B-4 — 3 test đỏ của `app_shell_test.dart`

Nguyên nhân thứ nhất là DI: nhánh solo của `HomeScreen` giải `ActivityCardRepository`
qua GetIt mà harness không đăng ký (`Bad state: GetIt: Object/factory with type
ActivityCardRepository is not registered`). Sửa bằng một `CupidDatabase`
in-memory + `ActivityCardRepositoryImpl` trong `_harness()`.

Nguyên nhân thứ hai **không** phải lỗi: test còn tìm `home_screen_ready_signal`
ở phiên chưa ghép đôi, nhưng P4 thay hẳn thân Home chưa-ghép-đôi bằng
`_SoloStageOneShell` (AC-22, D-3) nên khoá đó vắng mặt theo thiết kế. Assertion
viết lại thành: có `solo_stage_one_shell`, không có `home_screen_ready_signal`.
Đồng thời phải giới hạn phép đếm 4 `InkWell` vào đúng `CupidTabBar` của shell —
bề mặt solo thêm một `CupidTabBar` thứ hai cũng 4 mục, nên
`findsNWidgets(4)` cũ sẽ thấy 8.

### B-1 / B-5 — hub mount widget thật

Cùng một nguyên nhân gốc: hub tự khai báo một `_QuickEntryStrip` riêng tư (chỉ
`DecoratedBox` rỗng, không icon, không nhãn — chính là "3 ô xám" của B-5) và
định tuyến mọi hành động qua `_showComingSoon`. Đã xoá cả hai. Nay:

- Kho trống → `MinuteOneEmptyState` thật, `onCardCreated` gọi `cubit.load()`.
- Chạm thẻ → `Navigator.push` sang `ActivityCardDetailScreen`, và `load()` lại
  khi quay về nên thay đổi ở màn chi tiết hiện ngay trên hub.
- `QuickEntryStrip` thật, cùng `QuickCaptureAddAction` và header filter, đều bị
  chặn trong trạng thái Phút-1 (`storeCount == 0`) để không đè bề mặt kho trống.

### Ghi chú ngoài phạm vi

- **S4-F-3 (nháy frame)**: không sửa ở vòng này. Nguyên nhân nằm ở
  `home_screen.dart:206` (`_SoloHomeGate` dựng khung trước khi
  `PairingStatus` về), là file ngoài WriteScope và là nguyên nhân gốc khác với
  B-1. Cần một vòng có file đó trong write scope.
- **S5-F-4 (dải 3 ô không cuộn)**: đã sửa cùng B-5 vì trùng nguyên nhân gốc —
  `kQuickEntryMinCellWidth = 104`, hẹp hơn thì bọc `SingleChildScrollView`
  ngang (`Key('activity_quick_entry_strip_scroll')`).

### Mở rộng WriteScope — đã được cấp, cây đã biên dịch

Hai lần mở rộng đã được ghi vào run state (`scope_extension_1` 08:26Z cho B-6,
`scope_extension_2` 08:31Z cho 5 implementer giả còn lại). Sau khi sửa, cây
biên dịch sạch và các cổng đã chạy thật:

| Lệnh | Kết quả |
|------|---------|
| `flutter analyze lib test` | `196 issues found`, **0 error** (`grep -c "error •"` = 0) |
| `flutter test test/features/activity_cards test/features/home test/core/navigation` | `+230 ~3: All other tests passed!` (3 skip là capture visual-fidelity chờ `kCaptureVisuals`) |
| `flutter test` toàn bộ | `+1880 ~4 -21: Some tests failed.` |
| `flutter test test/core/navigation/app_shell_test.dart` | 11/11 xanh (tại BaseHead là `+8 -3`) |

21 đỏ của lần chạy toàn bộ là đỏ có sẵn, không phải regression. Đã chứng minh
bằng đo đối chứng: dựng một worktree detached tại BaseHead `4940e26`, chạy đúng
các file test đó, rồi so danh sách tên test đỏ đã sắp xếp — hai tập trùng khít
(`IDENTICAL_FAILURE_SETS`, 21 vs 21). Tác động ròng của vòng vá: **−3 đỏ, 0 đỏ
mới**.

Bối cảnh của lần mở rộng thứ hai, giữ lại vì nó giải thích vì sao vòng vá không
thể nhỏ hơn: `ActivityCardRepository` có 8 implementer; WriteScope ban đầu chứa 2.
`abstract interface class` của Dart không kế thừa thân hàm và không dung thứ
sai kiểu trả về, nên B-2 làm vỡ 6 file còn lại theo đúng định nghĩa. Đo bằng
`flutter analyze` trên đúng 6 đường dẫn đó: 20 issue, trong đó 18 error (3 mỗi
file: thiếu `updateCardDetails`, override `updateStatus` sai kiểu, override
`clearScheduledDate` sai kiểu) cộng 2 issue không phải error có sẵn trong
`main_preview.dart` (`unused_import` :119, `unnecessary_import` :126).

| File ngoài WriteScope | Dòng lỗi |
|-----------------------|----------|
| `lib/main_preview.dart` | 1048, 1150, 1154 |
| `test/features/activity_cards/activity_card_detail_screen_test.dart` | 37, 39, 42 |
| `test/features/activity_cards/activity_card_hub_view_test.dart` | 32, 92, 96 |
| `test/features/activity_cards/minute_one_empty_state_test.dart` | 38, 99, 103 |
| `test/features/activity_cards/quick_capture_sheet_test.dart` | 11, 62, 66 |
| `test/features/home/presentation/timeline_entry_point_test.dart` | 47, 77, 81 |

Bốn file chỉ cần sửa máy móc phần implementer giả. Hai file cần sửa cả
assertion vì B-1 làm chúng sai theo định nghĩa:
`activity_card_hub_view_test.dart:677-703` assert placeholder P4
(`activity_card_hub_minute1_slot` có mặt, Minute-1 thật vắng mặt), và `:705-724`
assert đúng một `activity_quick_entry_strip` — vẫn đúng, nhưng chỉ vì hub nay
chặn dải ở `storeCount > 0`, nên assertion cần nói ra điều đó có chủ ý.

Đây không phải phình phạm vi: §7.9 ước lượng P8 ~7 file mà không tính sáu
implementer giả của chính hợp đồng nó đổi. Vì B-3 buộc P8 và bản vá P4/P6 vào
một vòng merge, không tập con nào nhỏ hơn cho ra một cây biên dịch được.

### B-6 — đã đóng

Affordance rủ lần hai theo dịp là `_InviteCard` riêng tư, khoá
`activity_minute1_invite_occasion`, ở `minute_one_empty_state.dart`. Sau khi
`minute_one_empty_state.dart` vào WriteScope, nó được đặt sau `if (prompt !=
null)`: `loadPrompt` không trả về prompt nào chính là điều kiện sản xuất sau
2027-12-24, nên lời mời bị **giữ lại** thay vì mời rồi từ chối. Nhánh SnackBar
"Sắp có" (`activity_minute1_occasion_coming_soon`) không còn lý do tồn tại và đã
bị xoá; `_revealSuggestions` rút lại còn một `setState`.

Test mới trong `minute_one_empty_state_test.dart` chốt hành vi: khi gói dịp hết
hạn thì `activity_minute1_invite_occasion` vắng mặt, còn lời mời dán link,
tiêu đề Minute-1 và dải 3 ô vẫn nguyên.

### Startup smoke R-2 — đã chạy, và nó bắt được một lỗi tuyến đường

Chạy thật trên `emulator-5554`, `main.dart` thật, không dùng `main_preview.dart`
và không dùng `PREVIEW_SOLO_HUB_FIXTURE`.

Cách dựng schema v2 để migration có cái để chạy: bản `main` (schemaVersion 2)
không mở database ở bất kỳ màn hình nào mà phiên chưa ghép đôi tới được, nên
không thể sinh `cupid.sqlite` bằng cách bấm trong app v2. Thay vào đó file v2
được sinh **bằng chính code v2** (`CupidDatabase(NativeDatabase(file))` trong
worktree detached tại `main`, in ra `SEEDED_USER_VERSION=2`, 0 bảng
`%activity%`), rồi `adb push` vào `app_flutter/cupid.sqlite` trước khi cài bản
STORY-001 đè lên.

Kết quả đo được:

| Điều kiện R-2 | Kết quả |
|---------------|---------|
| Không exception trong log khởi động | **ĐẠT** — `adb logcat -d` 1893 dòng, không `E/flutter`, không `FATAL EXCEPTION`, không `SqliteException` |
| Phiên chưa ghép đôi vào thẳng hub solo | **KHÔNG ĐẠT** — vào `PairingChoiceScreen` ("Ghép đôi kiểu nào?"); nút back thoát hẳn app, không có hub solo nào phía sau |
| Migration v2→v3 trên máy đã cài schema v2 | **KHÔNG CHẠY** — `cupid.sqlite` vẫn đúng 36864 byte như file v2 đã push; app không hề mở database |
| Mở một thẻ sang màn chi tiết P6 | **KHÔNG VỚI TỚI** — hệ quả của hai dòng trên |

Nguyên nhân gốc: `lib/core/navigation/pair_gate_shell.dart:142` —
`PairGateUnpaired() => PairingChoiceScreen(...)`. Cổng ghép đôi cấp ứng dụng
chặn phiên chưa ghép đôi **trước** `HomeScreen`, nên `_SoloHomeGate` ở
`home_screen.dart:201` (nơi STORY-001 gắn `ActivityCardHubView`) không bao giờ
được dựng trong sản xuất. Hub solo hiện chỉ với tới được qua preview harness và
widget test.

`pair_gate_shell.dart` không nằm trong WriteScope của vòng vá này, và việc quyết
định cổng ghép đôi cấp ứng dụng có được bỏ qua cho Stage-1 solo hay không là
quyết định kiến trúc/sản phẩm vượt quá những gì `master-plan.md` §7 đã đặc tả.
Ghi lại như blocker thay vì tự đoán.

Bằng chứng ảnh: `/tmp/req016-v3-unpaired.png` (màn hình phiên chưa ghép đôi thật
sự nhận được). Chưa có ảnh hub vì hub không với tới được.

### Startup smoke R-2 chạy lại sau P9 — tuyến đường đã thông, migration vẫn không chạy

Chạy lại tại HEAD `93ff105e3136c540450fc69f2b3d24d9963ce3e9` trên
`emulator-5554`, `main.dart` thật (`com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`),
không `main_preview.dart`, không `PREVIEW_SOLO_HUB_FIXTURE`.

Dựng lại đúng tình huống "người dùng cũ nâng cấp": file `cupid.sqlite` schema v2
sinh bằng chính code v2 (`SEEDED_USER_VERSION=2`, 36864 byte, 5 bảng, không có
`activity_cards`) rồi `adb push` vào `app_flutter/` trước khi khởi động bản
STORY-001. Đo trước khi mở app: `PRE_USER_VERSION=2`,
`PRE_TABLES=messages,timeline_entries,timeline_sync_state,expenses,expense_sync_metadata`.

Phiên đăng nhập: tài khoản thật `r2smoke+001@cupid.local` đăng ký qua
`POST /auth/register` + `POST /auth/verify-otp` trên API local `:21020`
(OTP lấy từ mailpit `:8025`), user thật `ea03bad7-35c4-411c-a8af-d3a046b9b30a`
với `partnerId: null` (đúng là phiên chưa ghép đôi). Access token được ghi vào
`shared_prefs/FlutterSharedPreferences.xml` theo đúng 3 khoá của
`JwtTokenProvider` — tức là đúng trạng thái bền vững mà một lần mở lại app bình
thường sẽ khôi phục.

| Điều kiện R-2 | Kết quả |
|---------------|---------|
| Không exception trong log khởi động | **ĐẠT** — 386 dòng logcat theo pid, không exception phía Dart lúc khởi động; chỉ có lỗi môi trường của emulator (`FirebaseInstallations SERVICE_NOT_AVAILABLE`, `flutter_facebook_auth` không đăng ký được) |
| Phiên chưa ghép đôi vào thẳng hub solo | **ĐẠT** — vào thẳng hub solo với thanh 4 tab `Muốn làm / Ý tưởng / Sổ tay / Nhật ký`, không phải `PairingChoiceScreen`, không phải dashboard cặp đôi. P9 sửa `pair_gate_shell.dart` sang `PairGateUnpaired() => HomeScreen(resolvePairingStatus: _soloPairingStatus)` đã có tác dụng thật |
| Migration v2→v3 trên máy đã cài schema v2 | **KHÔNG CHẠY** — sau toàn bộ phiên: `FINAL_USER_VERSION=2`, vẫn 5 bảng cũ, `cupid.sqlite` vẫn 36864 byte và mtime không đổi. App chưa từng mở database |
| Mở một thẻ sang màn chi tiết P6 | **KHÔNG VỚI TỚI** — hub kẹt vĩnh viễn ở Minute-1, không tạo được thẻ nào để mở |

Nguyên nhân gốc (quan sát được, không suy đoán) — `adb logcat` bắt đúng lúc bấm
"+" trên gợi ý dịp:

```
E flutter : Unhandled Exception: Bad state: ActivityCardRepository used before a backend user id resolved.
E flutter : #0  ActivityCardRepositoryImpl._requireOwnerKey (activity_card_repository_impl.dart:164:7)
E flutter : #1  ActivityCardRepositoryImpl.createCard (activity_card_repository_impl.dart:31:22)
E flutter : #2  _MinuteOneEmptyStateState._acceptSuggestion (minute_one_empty_state.dart:167:31)
```

`BackendUserIdStore` (`core/realtime/backend_user_id_store.dart`) chỉ giữ
`_backendUserId` trong bộ nhớ, không persist. Nó chỉ được nạp lúc đăng nhập
(`AuthRepository.signInWithEmail` / `verifyOtp` / `_syncBackendProfile`) và ở
`chat_partner_store.dart:57`. Không có đường nào nạp lại nó khi khởi động nguội.
Vì `ActivityCardRepositoryImpl._requireOwnerKey()` ném `StateError` khi khoá
rỗng, mọi lời gọi repository đều hỏng với người dùng quay lại app:

- `ActivityCardListCubit.load()` hỏng → `storeCount == 0` → hub luôn hiện
  Minute-1 dù store có dữ liệu hay không.
- `createCard` hỏng → không tạo được thẻ, và lỗi nổi lên thành unhandled
  exception chứ không thành thông báo cho người dùng.
- Vì DAO không bao giờ được gọi, Drift không bao giờ mở `cupid.sqlite`, nên
  migration v2→v3 (`cupid_database.dart:46` `schemaVersion => 3`, nhánh
  `if (from < 3)` ở dòng 60) không bao giờ chạy. Đây là lý do điều kiện
  migration không đo được, chứ không phải migration sai.

`backend_user_id_store.dart` và tuyến khởi động lại phiên nằm ngoài WriteScope
của vòng xác minh này, và việc chọn cách nạp lại khoá chủ (đọc `/users/me` lúc
khởi động, persist `backendUserId`, hay dùng `cupid_user_id` đã có sẵn trong
SharedPreferences) là quyết định kiến trúc. Ghi lại như blocker thay vì tự vá.

Bằng chứng ảnh:

- `/tmp/req016-r2-a.png` — hub solo ngay sau khởi động, thanh 4 tab (điều kiện 2 ĐẠT)
- `/tmp/req016-r2-b.png` — sheet "Dán link vào đây" mở được từ hub
- `/tmp/req016-r2-c.png` — gợi ý dịp "Rằm tháng Tám" hiện ra
- `/tmp/req016-r2-d.png` — sau khi bấm "+": không có thẻ nào được thêm (đúng lúc exception ở trên)

## P10 — nạp lại khoá chủ `owner_key` khi khởi động nguội (mobile-dev)

Triển khai đúng phương án (3) đã chốt ở `master-plan.md` §9.3-§9.4: nạp lười
`BackendUserIdStore._backendUserId` từ `cupid_user_id` đã có sẵn trong
SharedPreferences qua `JwtTokenProvider.getSavedUserId`, dây nối ở
`service_locator.dart` dòng 174 (nay có thêm `readPersistedUserId:`).

File đã sửa (đúng danh sách §9.8, không vượt WriteScope):

1. `mobile/lib/core/realtime/backend_user_id_store.dart` — thêm tham số
   constructor tuỳ chọn `readPersistedUserId` (mặc định `null`, giữ nguyên
   hành vi `BackendUserIdStore()` trần cho mọi call site preview/test hiện
   có) và sửa `resolve()` để đọc lại persisted id khi RAM rỗng, cache lại kết
   quả, và ưu tiên giá trị RAM khi đã có.
2. `mobile/lib/core/di/service_locator.dart` — dòng 174 dây `BackendUserIdStore`
   qua `readPersistedUserId: getIt<JwtTokenProvider>().getSavedUserId`.
3. `mobile/test/core/realtime/backend_user_id_store_test.dart` — thêm group
   `BackendUserIdStore cold-start rehydration (P10)` với 5 test theo đúng
   §9.6 rule 1-3: cache-once-per-two-calls, RAM thắng persisted, reader trả
   null/rỗng thì không cache, và bất biến teardown bằng đồ thật
   (`SharedPreferences.setMockInitialValues` + `JwtTokenProvider` +
   `CupidSession(tokenProvider: ..., firebaseAuth: null)` +
   `registerScopedStore`).
4. `mobile/test/features/activity_cards/activity_card_repository_test.dart` —
   thêm test khởi động nguội (§9.6 rule 4): `ActivityCardRepositoryImpl` với
   `ownerKeyStore` chưa từng đăng nhập trong phiên này nhưng có reader trả id
   persist; khẳng định `createCard` + `cardsByStatus` chạy được và
   `_requireOwnerKey()` không ném.

Không đổi khẳng định nào đang có trong hai file test trên (§9.6 rule 5).
Không chạm `home_screen.dart`, `pair_gate_shell.dart`, schema/migration,
`cupid_session.dart`, `jwt_token_provider.dart` (chỉ đọc `getSavedUserId`),
`couple_pairing_store.dart:99`, không thêm khoá SharedPreferences mới, không
chạm `main_preview.dart`/`preview_reminder_fixture.dart` (đúng §9.7).

**`flutter analyze lib/core/realtime/backend_user_id_store.dart
lib/core/di/service_locator.dart
test/core/realtime/backend_user_id_store_test.dart
test/features/activity_cards/activity_card_repository_test.dart`**: 0 error,
1 info (`prefer_initializing_formals` tại `backend_user_id_store.dart:11:9` —
giữ nguyên tên field private `_readPersistedUserId` đúng chữ ký §9.4, không
phải error nên không chặn §9.9).

**`flutter test test/core/realtime/backend_user_id_store_test.dart
test/features/activity_cards/activity_card_repository_test.dart`**: 22/22
test xanh (12 trong `backend_user_id_store_test.dart`, 10 trong
`activity_card_repository_test.dart`, gồm cả các test mới của P10).

Chưa chạy lại startup smoke R-2 (§9.9) — đó là bước Scrum-Master-owned tiếp
theo sau vòng patch này, không phải việc của mobile-dev trong lượt này.

### Startup smoke rule-12g — lần chạy thứ 3 (vòng R-2 sau P10) — ĐẠT cả 4 điều kiện

Chạy tại HEAD `ea59bae` trên `emulator-5554`, `main.dart` thật
(`com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`), không
`main_preview.dart`, không `PREVIEW_SOLO_HUB_FIXTURE`, không harness test.

Tái sử dụng đúng máy trạng thái từ vòng R-2 trước (không cài lại từ đầu để giữ
nguyên "người dùng cũ nâng cấp"): `app_flutter/cupid.sqlite` vẫn ở schema v2
(36864 byte, `PRAGMA user_version=2`, 5 bảng
`messages,timeline_entries,timeline_sync_state,expenses,expense_sync_metadata`,
không có `activity_cards`), và `shared_prefs/FlutterSharedPreferences.xml` vẫn
giữ phiên thật `r2smoke+001@cupid.local` /
`ea03bad7-35c4-411c-a8af-d3a046b9b30a` (`partnerId: null`, xác nhận lại bằng
`GET /users/me` trực tiếp trước khi mở app) — chỉ cài đè APK build mới ở HEAD
`ea59bae` lên trên (`adb install -r`, `app_flutter/` và `shared_prefs/` không
bị xoá).

Ghi chú thủ tục (không phải phát hiện về code): build đầu tiên bằng
`flutter build apk --debug` trần (không qua `scripts/run-mobile.sh`) đã thiếu
`--dart-define=CUPID_API_BASE_URL=...`, khiến app rơi về mặc định
`http://localhost:3000` (loopback của chính máy ảo, cổng không hề mở) và hiện
"Không thể kết nối máy chủ" mọi lượt thử — `DioException [connection timeout]`
với `uri: http://localhost:3000/users/me` trong logcat. Đây là lỗi ở quy trình
build của vòng xác minh này, không phải lỗi trong patch P10. Build lại đúng
theo ví dụ trong chính `scripts/run-mobile.sh` dòng 38, chỉnh cổng đúng theo
API local thật của repo này (`curl http://localhost:21020/` trả 200,
`curl http://localhost:3000/` không kết nối được):
`flutter build apk --debug --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:21020`.
Sau khi cài lại APK build đúng này, log xác nhận `uri:
http://10.0.2.2:21020/users/me` trả `statusCode: 200`.

Kết quả đo được:

| Điều kiện rule-12g | Kết quả |
|---------------------|---------|
| App khởi động, DB migrate v2→v3 trên schema đã cài | **ĐẠT** — kéo `cupid.sqlite` về host sau phiên: 57344 byte (từ 36864), `PRAGMA user_version=3`, bảng mới `activity_cards`, `activity_card_photos` xuất hiện cùng 5 bảng cũ |
| Migration thực sự được quan sát chạy (không chỉ suy luận từ việc không crash) | **ĐẠT** — so sánh trực tiếp state trước/sau: trước khi mở app `36864 byte / user_version=2 / không có activity_cards`; sau phiên (đã tạo 1 thẻ) `57344 byte / user_version=3 / có activity_cards` |
| Phiên chưa ghép đôi vào thẳng hub solo | **ĐẠT** — vào thẳng hub solo với thanh 4 tab `Muốn làm / Ý tưởng / Sổ tay / Nhật ký`, không phải `PairingChoiceScreen` (ảnh `/tmp/req016-p10-r12g3-screen2.png`) |
| Mở một thẻ sang màn chi tiết P6 | **ĐẠT** — bấm "Để mình mách cho, theo dịp gần nhất" → gợi ý "Rằm tháng Tám" hiện ra → bấm "+" ở gợi ý "Đi phố lồng đèn rồi ngồi vỉa hè ăn bánh nướng" → thẻ được tạo thành công, hiện trong "Tất cả · 1" (ảnh `/tmp/req016-p10-r12g3-screen4.png`), không có unhandled exception (khác hẳn vòng R-2 trước P10, nơi đúng thao tác này ném `Bad state: ActivityCardRepository used before a backend user id resolved.`) → bấm vào thẻ → màn chi tiết P6 mở đầy đủ: tiêu đề, "Sổ tay có ghi", "Giá"/"Khoảng cách" (chưa rõ), tags, "Chuyển trạng thái", "Xoá thẻ", nút "Hẹn ngày" (ảnh `/tmp/req016-p10-r12g3-screen5.png`) |

`adb logcat -d --pid=<pid>` chụp nhiều lần trong suốt phiên (tệp
`/tmp/req016-p10-r12g3-logcat2.txt` qua `.../logcat5.txt`, 176-341 dòng mỗi
lần): không `E flutter`, không `FATAL EXCEPTION`, không `StateError`, không
`SqliteException` nào liên quan tới patch; nhiễu môi trường còn lại
(`FirebaseInstallations SERVICE_NOT_AVAILABLE`, `flutter_facebook_auth` không
đăng ký được) giống hệt các vòng trước, đã ghi nhận là nhiễu môi trường không
liên quan.

Kết luận: P10 (`ea59bae`) sửa đúng lỗi rehydrate `BackendUserIdStore` mà vòng
R-2 trước đó phát hiện. Cả 4 điều kiện rule-12g ĐẠT ở lần chạy thứ 3 này.

Bằng chứng ảnh: `/tmp/req016-p10-r12g3-screen2.png` (hub solo ngay sau khởi
động), `/tmp/req016-p10-r12g3-screen3.png` (gợi ý dịp "Rằm tháng Tám"),
`/tmp/req016-p10-r12g3-screen4.png` (thẻ đã tạo thành công, "Tất cả · 1"),
`/tmp/req016-p10-r12g3-screen5.png` (màn chi tiết P6 mở đầy đủ).
