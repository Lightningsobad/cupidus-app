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
