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
