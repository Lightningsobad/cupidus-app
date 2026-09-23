# STORY-007 — Test Results

## P1 — Sổ kích hoạt lời cảm ơn (activation ledger)

- Date: 2026-09-23
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-007_thank_you_and_next_plan`
- BaseHead: `d36e7a4afe0831351fef11db26e5545306861b2a`
- Result: **PASS**

### Ràng buộc module (module binding)

- Module: `mobile/lib/features/activity_cards` (sub-feature `thank_you/`)
- Database: `mobile/lib/core/database/cupid_database.dart`
- Bảng drift: `mobile/lib/core/database/tables/thank_you_activations_table.dart`
  (đặt ở `core/database/tables/`, không đặt dưới thư mục feature — ADR-010)
- `schemaVersion`: **9 → 10**. Giá trị sống được kiểm lại trước khi bump và vẫn
  là 9, nên không có `DRIFT_SCHEMA_COLLISION`.
- Bước migration cộng thêm: `if (from < 10) { await m.createTable(thankYouActivations); }`

### Lệnh đã chạy và kết quả thật

1. Unit + migration của sub-feature và toàn bộ tầng database:

   ```
   flutter test test/core/database test/features/activity_cards/thank_you --reporter failures-only
   +127: All tests passed!
   ```

2. Các file test hiện có assert `schemaVersion` (sau khi sửa 9 → 10) và các
   fixture migration được sửa:

   ```
   flutter test test/core/database/calendar_event_state_migration_test.dart test/core/database/relationship_labels_migration_test.dart --reporter failures-only
   +12: All tests passed!
   ```

   ```
   flutter test test/features/chapter_closure/stage1_wipe_service_test.dart --reporter failures-only
   +16: All tests passed!
   ```

3. Hồi quy toàn bộ bộ test app (`## 4` AC: "bộ test của app xanh trở lại"):

   ```
   flutter test --reporter failures-only
   +2984 ~23 -18: Some tests failed.
   ```

   Đối chiếu tại BaseHead trong worktree detached riêng
   (`git worktree add --detach /tmp/req016-s007-base d36e7a4`,
   `flutter pub get && flutter gen-l10n`):

   ```
   flutter test --reporter failures-only
   +2942 ~23 -37: Some tests failed.
   ```

   **37 → 18.** Toàn bộ 18 test còn đỏ đều nằm trong danh sách đỏ của BaseHead
   (tập con thực sự); không có test đỏ mới. 19 test đỏ tồn đọng đã được sửa
   trong phase này (xem `### Sửa lỗi tồn đọng` bên dưới).

4. Build/type-check trên đúng các đường dẫn đã chạm:

   ```
   flutter analyze --no-pub lib/core/database lib/features/activity_cards/thank_you lib/features/chapter_closure/data test/core/database test/features/activity_cards/thank_you test/features/activity_cards/activity_type_test.dart test/features/chapter_closure test/features/your_view_portrait/portrait_answer_repository_test.dart test/features/compatibility_lookup/relationship_label_repository_test.dart
   13 issues found. (ran in 3.2s)
   ```

   **0 error, 0 warning, 13 info** — tất cả 13 info đều là
   `prefer_initializing_formals` trên các dòng constructor tồn đọng của
   `chapter_closure/data/{chapter_closure_service,stage1_wipe_registry,stage1_wipe_service}.dart`,
   không phải dòng do phase này viết. Gate của phase là "không thêm error mới",
   không phải exit code 0.

   Chỉ riêng mã mới của phase:

   ```
   flutter analyze --no-pub lib/features/activity_cards/thank_you lib/core/database test/features/activity_cards/thank_you test/core/database
   No issues found! (ran in 1.0s)
   ```

### Assertion theo risk surface (`## 1B`)

- `DRIFT_SCHEMA_COLLISION` — `thank_you_activation_migration_test.dart`:
  fixture v9 (seed thẻ, `DROP TABLE thank_you_activations`,
  `PRAGMA user_version = 9`) rồi mở lại, assert `readUserVersion == 10`,
  `fresh.schemaVersion == 10`, hàng cũ còn nguyên.
- `LOCAL_DATE_RULE_UNVERIFIED` — nhóm "biên ngày lịch địa phương (AC-1 vs
  AC-2)": arm lúc 23:59 rồi hỏi lúc 00:01 hôm sau → `isEligible == true`; arm
  và hỏi trong cùng ngày → `false`; đồng hồ lùi lại → `false`. So sánh theo
  ngày dân sự `YYYY-MM-DD` giờ địa phương, không theo khoảng 24h.
- `ACTIVATION_RULES_UNTESTABLE` — nhóm "năm chuyển trạng thái của một lượt trọn
  đời (BR-2)": `arm` chỉ tạo khi chưa có hàng; `cancel` chỉ đi từ ARMED;
  `consume` chỉ đi từ ARMED; CONSUMED và CANCELLED là hấp thụ.
- Idempotency (`solution.md` §4) — nhóm "consume idempotent": gọi `consume` lần
  hai trên thẻ đã CONSUMED không đổi `consumedAt`; `consume` trên thẻ CANCELLED
  là no-op.
- `SILENCE_PENALTY_LEAK` (AC-25 / BR-3) — nhóm "cột bị cấm vĩnh viễn": tập cột
  đúng bằng `{card_id, status, armed_on, consumed_at}`, không có cột đếm,
  streak, hạn chót, hay đo hành vi người kia.
- AC-14 — nhóm "nối vào tín hiệu đổi trạng thái thẻ của STORY-001":
  `onCardStatusChanged` arm khi thẻ vào `done`, cancel khi rời `done`.

### Sửa lỗi tồn đọng (pre-existing, không phải lỗi do phase này gây ra)

Bộ test đã đỏ sẵn tại BaseHead với 37 failure. 19 trong số đó thuộc hai họ lỗi,
cả hai đều là hệ quả còn sót của lần đánh số lại v7 → v9 ở STORY-013:

1. **Assertion phiên bản cũ.** `chapter_closure_migration_test.dart` vẫn assert
   `7`, `calendar_event_state_migration_test.dart` assert `8`,
   `relationship_labels_migration_test.dart` assert `8`,
   `portrait_answer_repository_test.dart` assert `7` — tất cả đã sai từ trước
   khi phase này bump. Đã sửa về `10` và đổi tên group/test không còn đúng
   (`v6 -> v8` → `v6 -> current`, `v8 on a fresh install` → `a fresh install`).

2. **`CREATE INDEX` không có `IF NOT EXISTS`.** `Migrator.createTable` phát
   `CREATE TABLE IF NOT EXISTS` nên một fixture "v6" dựng từ lược đồ hiện tại
   vẫn chạy lại được bước tạo bảng; `Migrator.createIndex` thì phát
   `CREATE INDEX` trần và ném
   `SqliteException(1): index chapter_closure_items_kind_item already exists`.
   Các fixture cũ chỉ `DROP` đúng bảng của riêng chúng rồi lùi `user_version`,
   để lại `chapter_closure_items` cùng index v9. Đã sửa **ở fixture**, không
   đụng vào migration đang chạy trên máy người dùng: fixture nay drop thêm
   `chapter_closure_items` rồi `chapter_closures` (con trước cha).

   **Cần báo cho Tech Lead / Scrum Master:** đây là bẫy hệ thống, không phải sự
   cố một lần. Mỗi story sau này thêm một index trong bước migration sẽ làm đỏ
   lại đúng những fixture này. Cách sửa gốc là để bước migration tạo index qua
   câu lệnh có `IF NOT EXISTS`, hoặc để các fixture dựng từ một ảnh chụp lược đồ
   thật thay vì từ lược đồ hiện tại.

Ngoài ra `activity_type_test.dart:180` assert `schemaVersion == 9` (xanh tại
BaseHead, đỏ sau khi bump) — đã sửa về `10` cùng với đoạn chú thích lịch sử
phiên bản.

### Sai lệch so với handoff, cần Scrum Master ghi nhận

1. **`mobile/test/core/database/message_dao_test.dart` không tồn tại.** Handoff
   nêu ba file (`expense_dao_test.dart`, `message_dao_test.dart`,
   `timeline_dao_test.dart`). File thực tế assert `schemaVersion` cũ là:
   `migration_v5_test.dart`, `context_notebook_migration_test.dart`,
   `timeline_dao_test.dart`, `expense_dao_test.dart`, `journal_dao_test.dart`,
   `activity_card_dao_test.dart`, `activity_card_migration_test.dart`,
   `chapter_closure_migration_test.dart`,
   `calendar_event_state_migration_test.dart`,
   `relationship_labels_migration_test.dart`,
   `portrait_answer_repository_test.dart`,
   `relationship_label_repository_test.dart`, `activity_type_test.dart`.

2. **Ghi ngoài WriteScope khai báo.** Ba nhóm, đều bắt buộc để bảng mới không
   làm hỏng hợp đồng đang có:
   - `mobile/lib/core/database/cupid_database.g.dart` — codegen chạy lại
     (`build_runner`), bắt buộc sau khi thêm bảng.
   - `mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart` —
     đăng ký `thank_you_activations` vào danh sách xoá khi "rời giai đoạn 1".
     Test tripwire `stage1_wipe_registry_parity_test.dart` yêu cầu rõ: bảng
     REQ-016 mới phải được đăng ký hoặc loại trừ có chủ ý. Vị từ chủ sở hữu đi
     qua thẻ cha (`card_id IN (SELECT id FROM activity_cards WHERE owner_key = ?)`),
     đặt trước `activity_cards` trong thứ tự xoá (con trước cha).
   - Các file test tồn đọng nêu ở mục trên.

3. **`stage1_wipe_registry_parity_test.dart` vẫn đỏ, và đỏ từ BaseHead.** Ba
   bảng REQ-016 khác chưa hề được đăng ký trong `Stage1WipeRegistry`:
   `calendar_event_state`, `portrait_answers`, `relationship_labels`. Nghĩa là
   dữ liệu của ba tính năng đó **sống sót** sau khi người dùng rời giai đoạn 1.
   Phase này không tự quyết định ngữ nghĩa xoá cho bảng của story khác, nên chỉ
   đăng ký bảng của mình và báo lại. Cần một quyết định PO / Tech Lead.

## P2 — Khung khối + điểm gắn

- Date: 2026-09-23
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-007_thank_you_and_next_plan`
- BaseHead: `4a241d2f0de7e6cbee251a8f17f3d1d6e7165a9f`
- Result: **PASS**

### Lệnh và kết quả

```
$ flutter test test/features/activity_cards test/features/before_you_go \
    --reporter failures-only
+358 ~6: 6 skipped tests.
+358 ~6: All other tests passed!
```

```
$ flutter test test/features/activity_cards/thank_you/thank_you_block_test.dart \
    --dart-define=CAPTURE_VISUALS=true --reporter expanded
00:01 +16: All tests passed!
```

```
$ flutter analyze lib test
265 issues found. (ran in 2.4s)      # exit 1
$ grep -c "error •"  →  0
```

`flutter analyze` không bao giờ thoát 0 trong repo này: nền có hàng trăm
`info`/`warning` có từ trước BaseHead. Cổng là **không có lỗi mới**, và kết quả
là **0 `error`** trên toàn `lib` + `test`, **0 issue nào nằm trong file mà phase
này chạm vào**. Lần chạy đầu có đúng một `prefer_initializing_formals` ở
`thank_you_block_cubit.dart:34`; đã sửa bằng initializing formal, 266 → 265.

### Phạm vi test mới

`mobile/test/features/activity_cards/thank_you/thank_you_block_test.dart` —
15 test + 1 test capture (skip trừ khi có dart-define), chạy trên
`CupidDatabase` in-memory thật, không mock sổ lượt:

- **cubit (AC-1, AC-3, AC-7)** — thẻ đủ điều kiện thì khối hiện và lượt bị tiêu
  thụ ngay tại lần trình bày đầu; thẻ chưa đủ điều kiện thì lượt còn nguyên; thẻ
  ngoài luồng "ghi lại" không chạm vào sổ lượt; `resolve` lần hai sau khi đóng
  không gọi khối trở lại.
- **màn chi tiết thẻ** — mở lần đầu sang ngày mới thì khối tự hiện, không cần
  thao tác; mở hai lần liên tiếp thì lần sau không còn khối (AC-3); bấm close
  rồi mở lại cũng không còn; thẻ vào *Đã đi rồi* **hôm nay** thì không có khối
  (AC-2); thẻ chưa từng vào *Đã đi rồi* thì không có khối; khối không thêm hành
  động chính cấp thẻ thứ hai (AC-6, BR-1).
- **khung khối** — khe rỗng không để lại ô giữ chỗ nào trong cây widget
  (AC-15/BR-9); ba khe đã cắm hiện đúng thứ tự P3 → P4 → P5; cắm một khe không
  kéo theo hai khe kia.
- **không phạt im lặng (AC-25, AC-28)** — sau khi đóng, sổ lượt còn đúng một
  hàng `CONSUMED` và không gì khác; màn chi tiết không hiện dấu
  chưa-hoàn-thành nào.

### Hồi quy phải sửa — test cũ thiếu composition root

Gắn khối vào `ActivityCardDetailScreen` làm 3 file test có sẵn đỏ với
`Bad state: GetIt: Object/factory with type CupidDatabase is not registered`.
Nguyên nhân: màn chi tiết giờ chạm tới sổ lượt qua composition root — đúng cách
nó vẫn lấy `ActivityCardRepository` — nhưng các test đó chưa bao giờ chạy
`configureDependencies()`.

Sửa theo hai hướng, **không đổi bố cục sản phẩm**:

1. Dependency thành lazy: `ThankYouBlockCubit` nhận
   `ThankYouActivationService Function()` và chỉ gọi nó sau khi đã biết thẻ ở
   *Đã đi rồi*. Thẻ ở mọi trạng thái khác không còn dựng service, nên phần lớn
   test cũ hết đỏ mà không phải đụng vào.
2. Ba file còn mount thẻ *Đã đi rồi* được thêm `setUp`/`tearDown` đăng ký một
   `CupidDatabase(NativeDatabase.memory())` rỗng vào `getIt`. Sổ lượt rỗng ⇒
   không thẻ nào `armed` ⇒ khối không vẽ ⇒ bố cục mà các test đó khẳng định giữ
   nguyên: `test/features/activity_cards/activity_card_detail_screen_test.dart`,
   `test/features/activity_cards/card_lifecycle_ui_test.dart`,
   `test/features/before_you_go/before_you_go_block_test.dart`.

Bẫy khung 800x600 mà phase §6 cảnh báo **không** xảy ra: khối không hiện trong
các test đó, nên không `tap()` nào bị trượt. `git status` trong worktree sạch —
không PNG visual-fidelity của story khác bị ghi đè.

### Visual fidelity

`VISUAL_FIDELITY: PASS`, `Design-Screen: sb-212-cam-on-chot-viec-ke-tiep`
(surface `cupid-ch-ng-1`, ios, 415x900). Chi tiết, bốn mục
`DESIGN_SPEC_CONFLICT` và danh sách phần chưa dựng vì thuộc P3/P4/P5 nằm trong
`visual-fidelity/visual-fidelity-report.md`.

### Việc P1 còn sót — báo lại, không sửa ở đây

Không chỗ nào trong `mobile/lib` gọi
`ThankYouActivationCardStatusListener.onCardStatusChanged`, và
`mobile/lib/core/di/service_locator.dart` không đăng ký gì cho sổ lượt. Phase P1
§3 liệt kê phần đấu nối đó là việc của P1, và P1 đang `DONE`. Hệ quả: trong bản
build thật **không thẻ nào được `arm`**, nên khối không bao giờ nổi lên — các
test ở trên chạy được là vì chúng tự `arm` qua service. Cả hai file đều ngoài
write scope của P2.

## P1 — lượt hoàn tất đấu nối (2026-09-23)

Mục này chỉ đóng đúng phần P2 báo sót ở trên; không sửa lại `## P1` hay `## P2`.

### Xác nhận lại gap

- `ThankYouActivationCardStatusListener` có mặt từ P1 nhưng
  `onCardStatusChanged` không có lời gọi nào trong `mobile/lib` — chỉ ba test
  trong `thank_you_activation_service_test.dart` gọi tay.
- `service_locator.dart` không đăng ký `ThankYouActivationDao` /
  `ThankYouActivationRepository` / `ThankYouActivationService`; widget dựng
  service tại chỗ trong `thank_you_block.dart` (`_registeredService()`), nên chỉ
  có nhánh **đọc** của sổ lượt được đấu nối, nhánh **ghi** thì không.
- Phase P1 §3 dòng "Nối `arm` / `cancel` vào tín hiệu đổi trạng thái thẻ của
  STORY-001 mà **không** sửa lược đồ bảng thẻ" — đúng là việc của P1.

### Cách đóng

Tín hiệu đổi trạng thái duy nhất của STORY-001 là lời gọi
`ActivityCardRepository.updateStatus` (không có stream trạng thái nào).
`activity_card_detail_cubit.dart` — nơi gọi nó — nằm ngoài write scope, và phần
chú thích của chính listener cấm đặt lời gọi vào trong card repository (sẽ làm
STORY-001 phụ thuộc ngược vào STORY-007).

Nên đấu nối ở composition root bằng một lớp bọc:

- `thank_you/domain/thank_you_activation_card_status_repository.dart` —
  `ThankYouActivationAwareCardRepository implements ActivityCardRepository`,
  uỷ quyền 8 phương thức còn lại nguyên vẹn, riêng `updateStatus` gọi listener
  **sau khi** ghi thành công (`rows > 0`, nên thẻ của chủ khác không arm).
- `service_locator.dart` — đăng ký `ThankYouActivationRepository`,
  `ThankYouActivationService`, `ThankYouActivationCardStatusListener`, và trả
  `ActivityCardRepository` bằng lớp bọc quanh `ActivityCardRepositoryImpl`.
  File STORY-001 và lược đồ bảng thẻ không đổi một dòng.

### Bằng chứng chạy thật

`flutter test test/features/activity_cards/thank_you/thank_you_activation_card_status_repository_test.dart --reporter expanded`

```
00:00 +0: thẻ sang *Đã đi rồi* qua chính card store của app thì có hàng ARMED — không cần nối tay (AC-1, AC-14)
00:00 +1: rời *Đã đi rồi* qua card store thì lượt đang chờ bị huỷ lặng lẽ (AC-5)
00:00 +2: thẻ của chủ khác không ghi được trạng thái nên cũng không arm (AC-22)
00:00 +3: các thao tác còn lại của card store đi thẳng qua lớp bọc
00:00 +4: All tests passed!
```

Hồi quy — `flutter test test/features/activity_cards --reporter failures-only`

```
+277 ~4: 4 skipped tests.
+277 ~4: All other tests passed!
```

`flutter analyze --no-fatal-infos --no-fatal-warnings lib/core/di/service_locator.dart lib/features/activity_cards/thank_you/domain test/features/activity_cards/thank_you/thank_you_activation_card_status_repository_test.dart`

```
2 issues found. (ran in 1.5s)
```

Cả 2 là `info • prefer_initializing_formals` trên hai tham số private có tên của
lớp bọc — Dart không cho `required this._inner`, nên đây là cùng loại info mà
`ActivityCardRepositoryImpl` đang mang. **0 error, 0 warning**; baseline repo
vốn khác 0 nên gate là "không thêm error mới".

`git status --porcelain` trong worktree: đúng 3 file (service_locator sửa, lớp
bọc mới, test mới) — không PNG visual-fidelity của story khác bị ghi đè.

## P5 — Phần 3 "chốt việc kế tiếp" (2026-09-23)

### Nguồn gợi ý đã chọn, và vì sao

AC-19 cho hai nguồn: "kho mồi của STORY-005 **hoặc** dịp lịch âm gần nhất".
P5 lấy **gói dịp** (`assets/data/req016/calendar_events.v1.json`), không lấy
kho câu mồi, vì `conversation_starters_entry_point.dart` ghi rõ một ranh giới
đã chốt: không có API headless nào cho phép đọc một câu mồi ngoài màn (6).
Một câu mồi cũng là câu để nhắn, không phải một kế hoạch có ngày — mà ngày là
thứ AC-21 bắt thẻ phải mang sẵn.

Ngày của dịp lấy từ chính hàm trên thiết bị của STORY-005
(`nearestUpcomingDate` trong `calendar_event_service.dart`), không tính lại
lịch âm ở đây (AC-21, STORY-005 AC-18).

### Ràng buộc module

- `NextPlanSuggestionService.suggest` là `static` và **đồng bộ**, thuần theo
  (gói, today, slots). Đó là bằng chứng cấu trúc cho AC-35: không có bước
  `await` nào để treo spinner vào khi gói lớn.
- Ghi thẻ đi qua đúng một cửa: `ActivityCardRepository.createCard`. Không có
  lời gọi DAO/bảng nào trong `thank_you/`.
- Hoàn tác đi ngược qua `deleteCard` của cùng hợp đồng, nên cascade của thẻ
  ra theo, không để lại hàng mồ côi.
- `NextPlanState` cố tình không có cờ `loading` và không có cờ "gói rỗng":
  danh sách rỗng vẽ ra đúng con số không, nên không nơi nào cắm được skeleton.

### Lệnh đã chạy và kết quả thật

`flutter test test/features/activity_cards/thank_you/next_plan_test.dart`

```
00:00 +12: phần 3 trong khối — tạo thẻ qua đúng một cửa (AC-20, AC-21) nhiều dịp thì các chip cùng cỡ, không chip nào được nhấn mạnh
00:00 +13: All tests passed!
```

Cả thư mục sub-feature —
`flutter test test/features/activity_cards/thank_you`

```
00:01 +54 ~1: All tests passed!
```

Hồi quy — `flutter test test/features/activity_cards --reporter failures-only`

```
+290 ~4: 4 skipped tests.
+290 ~4: All other tests passed!
```

`flutter analyze lib test`

```
268 issues found. (ran in 1.7s)
```

Phân rã: **0 error**, 35 warning, 233 info — không có dòng nào thuộc file P5
trừ đúng một `info • prefer_initializing_formals` trên
`next_plan_suggestion_service.dart:56`, cùng loại info mà lớp bọc của P1 và
`ActivityCardRepositoryImpl` đang mang (Dart không cho `required this._x`).
Baseline repo vốn khác 0, nên gate là "không thêm error mới" — và 0 error.

### Assertion theo yêu cầu của `## 6. Test Scope`

| Yêu cầu | Test |
| --- | --- |
| Tất định: hai lần gọi cùng đầu vào → cùng tập, cùng thứ tự | `cùng gói và cùng ngày thì trả về đúng một tập, đúng một thứ tự` + `hai dịp trùng ngày vẫn có thứ tự cố định` |
| N = 1 → 1 chip, không ô giữ chỗ, không lỗi (AC-35) | `gói chỉ còn một dịp thì trả về đúng một` + `gói không còn dịp nào thì khe phần 3 vắng hẳn khỏi cây widget` |
| N rất lớn → không thêm bước tải, chọn không đổi (AC-35) | `gói rất lớn không đổi kết quả và không thêm bước chờ nào` (500 dịp) |
| Bấm chip → thẻ ở *Mới nghĩ ra*, nguồn sinh đúng, có sẵn ngày | `chạm một chip tạo ngay thẻ *Mới nghĩ ra* trong kho chung` |
| Ngày điền sẵn sửa được | `ngày điền sẵn của thẻ vẫn sửa được như mọi thẻ khác (AC-21)` |
| Hoàn tác trong 5 giây → thẻ biến mất, không hàng mồ côi | `chạm chip xong có snackbar hoàn tác, và hoàn tác xoá sạch thẻ` |
| Đóng khối không chọn gì → số thẻ không đổi | `đóng khối mà không chọn chip nào thì không tạo gì (AC-22)` |
| Thẻ mới tìm thấy ở **kho chung của màn (1)** | Mọi assertion trên đọc qua `repository.cardsByStatus(status: idea)` — kho chung, không phải danh sách riêng của khối |

### Sai lệch so với handoff, cần Scrum Master ghi nhận

1. **Sửa một file ngoài WriteScope:**
   `mobile/lib/features/activity_cards/domain/activity_card.dart`, đúng một
   dòng thêm vào cuối enum:
   `nextPlanAfterDate('next_plan_after_date')`.
   Bắt buộc, không có đường vòng: `architecture/contract-summary.md` mục 2 ghim
   đúng chuỗi này làm nguồn sinh của thẻ tạo từ phần 3, `NewActivityCard.origin`
   có kiểu `ActivityCardOrigin` nên không có lối thoát bằng chuỗi, và enum tự
   ghi là append-only ("later stories add new values here").
   Không cần nâng `schemaVersion`: cột `origin` là `text()` thuần, không có
   CHECK constraint, nên không có migration nào đi kèm.
2. **Sửa `thank_you_block_test.dart` (P2, trong WriteScope):** `pumpDetail`
   giờ truyền `NextPlanOptions` với gói rỗng, vì phần 3 đã được cắm thật nên
   mặc định cũ sẽ đi tìm `getIt<ActivityCardRepository>()`. Test khung P2 giữ
   nguyên ý nghĩa: gói rỗng ⇒ cả ba khe vẫn rỗng.

### Đỏ có sẵn ngoài phạm vi — không do P5 gây ra

`flutter test test/features/conversation_starters --reporter failures-only` đỏ
3 test, cả 3 đều là kiểu "khoá cứng danh sách enum" đã lỗi thời trên nhánh
tích hợp:

- `calendar_event_service_test.dart:390` `giá trị mới nằm cuối, không chen vào
  giữa` — khoá `ActivityCardOrigin.values` đúng 5 phần tử. Tại `BaseHead`
  (`d684c7e5`) enum **đã có 6** (`compatibility_lookup` từ story khác), nên
  test này đã đỏ trước P5; P5 làm danh sách dài thành 7. Giá trị mới nằm đúng
  cuối, tức là bất biến mà test định bảo vệ vẫn giữ — chỉ con số ghim là cũ.
- `starter_content_gate_test.dart:471` và `:498` — khoá `InvariantRule` ở 6 quy
  tắc trong khi nhánh đã có `assertive_claim`. Không dính gì tới P5.

Cả ba file đều ngoài WriteScope của phase này nên P5 không sửa. Đề nghị Scrum
Master xếp chúng vào một việc dọn hợp đồng enum riêng.

Kết quả thật của lệnh, chạy lại nguyên văn để làm bằng chứng cho cổng build:

```
PATH="$HOME/flutter/bin:$PATH" FLUTTER_ROOT="$HOME/flutter" \
  flutter test test/features/conversation_starters --reporter failures-only
+100 ~1 -3: Some tests failed.
EXIT=1
```

Bằng chứng BaseHead cho lỗi (1):

```
git show d684c7e5:mobile/lib/features/activity_cards/domain/activity_card.dart
  manual('manual'), pastedLink('pasted_link'), occasionSuggestion('occasion_suggestion'),
  giftSuggestion('gift_suggestion'), conversationStarter('conversation_starter'),
  compatibilityLookup('compatibility_lookup');
```

6 phần tử tại BaseHead so với 5 phần tử test ghim ⇒ đã đỏ trước P5.
`git status --porcelain -- mobile/test/features/conversation_starters
mobile/lib/features/conversation_starters` rỗng ⇒ P5 không chạm file nào ở đó.

`BLOCKER: PREEXISTING_TEST_FAILURE` — phase dừng ở đây theo cổng build
evidence; cần Scrum Master mở bug rồi re-dispatch.

### Visual fidelity

`flutter test test/features/activity_cards/thank_you/thank_you_block_test.dart
--dart-define=CAPTURE_VISUALS=true --plain-name="visual fidelity capture"` →
`00:00 +1: All tests passed!`

Ảnh chụp được pin vào 2026-09-21 và đọc **gói dịp thật đang ship**, nên ba chip
trong ảnh đúng là chữ và ngày app sẽ hiện: `Tết Trung Thu · còn 4 ngày`,
`Halloween · còn 40 ngày`, `Ngày Nhà giáo Việt Nam · còn 60 ngày`. Đã soi ảnh
bằng mắt: đủ dấu tiếng Việt, không ô tofu, ba icon dẫn đầu là
`walk`/`handmade`/`visit` thật chứ không phải ô vuông thay thế.
`visual-fidelity-report.md` đã cập nhật: VISUAL_FIDELITY vẫn `PASS`, thêm mục
so khớp phần 3 và ba delta đã chấp nhận (ba hàng thay vì hai theo AC-35; dấu
`+` đặc thay vì `⊕` viền; mọi hàng đều có dòng ngày).

`git status --porcelain` trong worktree sau khi chạy: 5 file sửa + 4 file mới,
tất cả thuộc phase này — **không** PNG visual-fidelity của story khác bị ghi
đè.
