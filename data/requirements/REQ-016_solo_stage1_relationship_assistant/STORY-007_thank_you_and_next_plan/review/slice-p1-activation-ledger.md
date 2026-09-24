# STORY-007 — Review slice P1 (activation ledger)

Outcome: PARTIAL_SLICE_ONLY

Slice 1/5 của một Tier 3 scoped-slice review. **Không có phát hiện chặn (blocking
finding) trong phạm vi slice này.** Giá trị `PARTIAL_SLICE_ONLY` ở trên là giá
trị enum hợp lệ duy nhất diễn đạt "một slice đã xong, chưa phải phán quyết cả
story" — xem `## 6. Xung đột template` về việc handoff đề nghị `Outcome: PASS`.

- Reviewer: Iris-QC
- Ngày: 2026-09-24
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-007_thank_you_and_next_plan`
- Worktree HEAD lúc review: `7be9a23c`
- Diff baseline (BaseHead của handoff): `bfe231aa`
- Phạm vi: chỉ P1 — persistence, bump `schemaVersion` 9→10, và phần chạm
  `stage1_wipe_registry`. P2-P5 **không** được xem xét ở đây.

## 1. Các kiểm tra bắt buộc

### 1.1 Bump `schemaVersion` đúng một lần 9 → 10 — ĐẠT

- `mobile/lib/core/database/cupid_database.dart`: `int get schemaVersion => 9;`
  → `=> 10;`, đúng một dòng đổi, không có bump chồng trong diff.
- Bước migration là cộng thêm và sibling (không phải `else if`):
  `if (from < 10) { await m.createTable(thankYouActivations); }`, đặt sau
  `if (from < 9)`. Không có `drop`/`recreate`, đúng luật "từ v3 trở đi cấm
  destructive-recreate" ghi ngay trong file.
- **Không có `DRIFT_SCHEMA_COLLISION`.** Đã kiểm chứng chống
  [[parallel-schema-version-collision]] bằng cách đọc nhánh integration
  (`integration-REQ-016.../mobile/lib/core/database/cupid_database.dart:86`):
  integration cũng ở `10`, và bước `if (from < 10)` của integration tạo đúng
  `thankYouActivations` — cùng một bảng, không phải v10 của story khác. Các bậc
  v7/v8/v9 trên integration lần lượt là `calendar_event_state`+`portrait_answers`,
  `relationship_labels`, `chapter_closures`+`chapter_closure_items` — không
  trùng số với story này.
- `thank_you_activation_migration_test.dart` dựng fixture v9 (drop bảng, lùi
  `user_version = 9`) rồi mở lại và assert `readUserVersion == 10` — chạy xanh.

### 1.2 Single-fire semantics, không có bề mặt trừng phạt — ĐẠT

Máy trạng thái `armed → consumed | cancelled`, hai trạng thái hấp thụ, không có
đường quay lại `armed`:

- `thank_you_activation_dao.dart:insertArmed` dùng `InsertMode.insertOrIgnore`
  trên PK `cardId`, nên "chỉ arm khi chưa có hàng" do SQLite quyết định, không
  phải read-then-write có thể xen kẽ (AC-4).
- `settleArmed` narrow `WHERE card_id = ? AND status = 'armed'`, nên `consumed`
  và `cancelled` hấp thụ ở tầng SQL chứ không dựa vào kỷ luật caller; `consume`
  gọi lại không ghi đè `consumedAt` (idempotency, `solution.md` §4).
- `thank_you_activation_service.dart:isEligible` so **ngày dân sự**
  `YYYY-MM-DD` giờ địa phương qua `civilDateOf`, `compareTo(...) > 0` — đúng
  AC-1 (từ ngày lịch kế tiếp) và AC-2 (không hiện trong cùng ngày). Đồng hồ được
  inject (`DateTime Function() now`), nên biên ngày kiểm thử được.
- `SILENCE_PENALTY_LEAK` (AC-25/AC-26, R-1b): tập cột của
  `thank_you_activations_table.dart` đúng bằng
  `{card_id, status, armed_on, consumed_at}` — không cột đếm, streak, huy hiệu,
  `missed`, `expires_at` hay bất kỳ chỉ báo hành vi người kia nào. Interface
  `ThankYouActivationRepository` **cố ý không có** `delete` và không có bulk
  reader (không có đường nào để đếm lượt). Không có bề mặt phần trăm/tiến độ.
- `thank_you_activation_card_status_listener.dart`: vào `ActivityCardStatus.done`
  → `arm`; rời `done` theo bất kỳ hướng nào → `cancel` (AC-5, huỷ lặng lẽ, không
  thông báo gì cho người dùng).

Hệ quả có chủ ý, đã được ghi rõ trong tài liệu domain: một thẻ bị `cancelled`
rồi quay lại `done` sẽ **không** hồi lượt. Đây đúng là AC-4 ("mỗi thẻ có đúng
một lượt trong toàn bộ vòng đời"), không phải lỗi.

### 1.3 Layering DAO / repository / service — ĐẠT (kèm một ghi chú về nguồn dẫn)

- Tầng: `ThankYouActivationDao` (data, chạm drift) → `ThankYouActivationRepositoryImpl`
  (data, ánh xạ row ↔ domain) → `ThankYouActivationRepository` (domain,
  abstract interface) → `ThankYouActivationService` (domain, toàn bộ luật
  AC-1..AC-5). Không có rò rỉ kiểu drift lên domain: service chỉ thấy
  `ThankYouActivation` / `ThankYouActivationStatus`.
- Hướng phụ thuộc ADR-010 được giữ: bảng nằm ở `core/database/tables/` và chỉ
  import drift + `activity_cards_table.dart`; `core/` **không** import `features/`.
  Enum wire value được single-source ở `ThankYouActivationStatuses` trong `core/`
  và domain enum ánh xạ sang nó.
- Ranh giới STORY-007 → STORY-001 một chiều: `ThankYouActivationAwareCardRepository`
  là decorator gắn ở composition root thay vì gọi listener từ trong
  `ActivityCardRepositoryImpl`. Đã kiểm chứng đây là đường duy nhất:
  `git grep "ActivityCardRepositoryImpl("` trong `mobile/lib` chỉ trả về đúng
  khai báo constructor và đúng một chỗ khởi tạo, ở
  `core/di/service_locator.dart:381`, nằm bên trong decorator. Lược đồ
  `activity_cards` không bị sửa — khớp `solution.md` §4 "Boundaries And Ownership".
- Ghi chú: handoff yêu cầu đối chiếu layering với `architecture/contract-summary.md`.
  File đó (6.3K, các mục §1-§6) thực tế mô tả hợp đồng **danh mục preset
  `thank_you_after_date`** dùng cho P3, không mô tả layering P1. Nguồn đúng cho
  kiểm tra này là `architecture/solution.md` §4, và bản thân code cũng trích dẫn
  §4 chứ không trích `contract-summary.md`. Đã review theo §4.

### 1.4 Bằng chứng test — ĐẠT, kèm một đỏ có sẵn đã xác nhận

`coding-plan/test-results.md` mục `## P1 — Sổ kích hoạt lời cảm ơn (activation
ledger)` ghi `Result: PASS`, `schemaVersion 9 → 10`, `+127: All tests passed!`
cho `test/core/database` + `test/features/activity_cards/thank_you`, và
`0 error / 0 warning / 13 info` cho `flutter analyze` trên đúng các đường dẫn đã
chạm. Mọi risk surface ở `## 1B` đều có assertion trực tiếp được liệt kê.

Reviewer chạy lại độc lập, scoped đúng slice này, trong worktree của story:

```
flutter test test/core/database/ test/features/activity_cards/thank_you/ test/features/chapter_closure/ --reporter failures-only
+286 ~3 -1: Some tests failed.
```

Đúng **một** test đỏ, và nó là cái đã được handoff nêu trước.

### 1.5 `stage1_wipe_registry_parity_test.dart` — đỏ **CÓ SẴN**, không phải do diff này

Test `mọi bảng REQ-016 trong lược đồ đều có mặt trong registry` fail với
`Which: does not contain 'calendar_event_state'`. So sánh hai tập trong output:
registry thiếu **`calendar_event_state`, `portrait_answers`, `relationship_labels`**
— cả ba đều là bảng của story khác (STORY-009, STORY-010). `thank_you_activations`
**có mặt** trong tập Actual, tức diff này đã đăng ký đúng bảng của chính nó.

Bằng chứng nó đã đỏ từ trước BaseHead: diff của
`mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart` là `+9 -0`,
thêm đúng một `Stage1WipeTable` cho `thankYouActivations` (đặt trước
`activity_cards` — con trước cha, đúng thứ tự xoá). Vậy registry tại `bfe231aa`
bằng registry hiện tại trừ đi một mục, trong khi lược đồ tại `bfe231aa` đã ở v9
và đã chứa cả ba bảng thiếu kia. Test **không thể** xanh tại BaseHead.

Xác nhận theo yêu cầu handoff: **PRE-EXISTING, cross-story, không phải newly
broken.** Cần quyết định PO/Tech-Lead xuyên story (đăng ký ba bảng kia, hoặc
loại trừ có chủ ý trong `nonReq016Tables()`), không phải việc của STORY-007.

Thay đổi duy nhất của diff này lên file test đó là `hasLength(10)` →
`hasLength(14)`, phản ánh đúng số bảng REQ-016 trong lược đồ hiện tại. Dòng đó
nằm sau assertion đang fail nên chưa bao giờ chạy tới.

### 1.6 Ripple `schemaVersion` trong `test/core/database/` — phần lớn thuần số, hai file vượt mức

Handoff yêu cầu flag mọi thứ vượt quá "cập nhật số phiên bản literal".

Thuần literal (7 file): `activity_card_dao_test.dart`, `activity_card_migration_test.dart`,
`context_notebook_migration_test.dart`, `expense_dao_test.dart`,
`journal_dao_test.dart`, `migration_v5_test.dart`, `timeline_dao_test.dart` —
chỉ đổi `9` → `10`.

Vượt mức, **đã kiểm và chấp nhận được** (3 file):

1. `calendar_event_state_migration_test.dart` (+18 −12) và
   `relationship_labels_migration_test.dart` (+15 −8): ngoài số phiên bản còn
   thêm `DROP TABLE chapter_closure_items` + `DROP TABLE chapter_closures` vào
   fixture v6, và đổi tên group (`v6 -> v8` → `v6 -> current`). Lý do được nêu
   trong chính comment của file và trong `test-results.md`
   `### Sửa lỗi tồn đọng`: `Migrator.createTable` phát `CREATE TABLE IF NOT
   EXISTS` nên bước tạo bảng replay được, nhưng `Migrator.createIndex` phát
   `CREATE INDEX` trần và ném `index ... already exists` trên fixture dựng từ
   lược đồ hiện tại. Sửa nằm **ở fixture**, không chạm migration đang chạy trên
   máy người dùng — đúng chỗ.
2. `chapter_closure_migration_test.dart` (+10 −9): đổi comment `Schema v7` →
   `v9` và đổi tên group. Là đính chính tài liệu cho lần đánh số lại v7→v9 của
   STORY-013, không đổi hành vi test.

Không phát hiện assertion nào bị nới lỏng hay xoá để test xanh.

### 1.7 `ActivityCardOrigin` — append-only, ĐẠT

`activity_card.dart`: `compatibilityLookup('compatibility_lookup');` →
`compatibilityLookup('compatibility_lookup'), nextPlanAfterDate('next_plan_after_date');`.
Thêm ở **cuối**, không đổi tên, không sắp xếp lại, không đổi `wireValue` của
member đã ship — khớp luật append-only ở `solution.md` §4 "Compatibility". (Bản
thân việc *dùng* enum này thuộc P5, ngoài slice.)

## 2. Phát hiện không chặn (advisory, cho pass final-synthesis cân nhắc)

- **A1 — `fromWireValue` không có `orElse`.**
  `thank_you_activation.dart`: `values.firstWhere((s) => s.wireValue == value)`
  ném `StateError` nếu gặp giá trị lạ (ví dụ hàng do một bản sau ghi rồi hạ cấp).
  Với luật append-only thì hiện tại không xảy ra, nhưng đây là crash chứ không
  phải degrade. Khuyến nghị (không chặn): trả `null`/fallback thay vì ném.
- **A2 — thứ tự ghi trong decorator.**
  `ThankYouActivationAwareCardRepository.updateStatus` `await` listener **sau**
  khi ghi thẻ thành công. Nếu ghi sổ kích hoạt ném lỗi, caller nhận exception
  từ `updateStatus` dù trạng thái thẻ đã đổi thật. Không chặn (hai write đều là
  SQLite cục bộ), nhưng đáng ghi nhận là một điểm không-nguyên-tử.
- **A3 — AC của phase P1 "Bộ test của app xanh trở lại" chưa đúng nghĩa đen.**
  `phase-P1-activation-ledger.md` §4 đặt AC là bộ test app xanh trở lại;
  `test-results.md` ghi `+2984 ~23 -18` và chứng minh 18 đỏ còn lại là **tập
  con thật** của 37 đỏ tại BaseHead (37 → 18, không có đỏ mới). Về thực chất
  gate "không thêm đỏ mới" đã đạt, nhưng câu chữ AC thì chưa. Liên quan
  `BUG-20260924-001` (đỏ repo-wide có sẵn ở `test/design_system/`). Đề nghị
  Scrum Master/Tech Lead sửa câu chữ AC thành "không thêm test đỏ mới so với
  BaseHead" thay vì để nó mãi không thoả.
- **A4 — `BUG-20260923-001`.** Bug này mô tả độ trễ assertion `schemaVersion`
  trong `test/core/database/`. Trong lần chạy của reviewer, **không** còn
  failure nào thuộc họ đó trong slice này: diff đã cập nhật hết các assertion
  `schemaVersion` và cả 10 file `test/core/database/` chạy xanh. Trích dẫn để
  ghi nhận, không chẩn đoán lại, không mở bug mới.
- **A5 — trích dẫn `R-15c` trong handoff không tồn tại.** `req_master.md` chỉ
  có `R-15`, `R-15a`, `R-15b`. Luật chống bộ đếm/tiến độ áp cho story này là
  `R-15b` (cùng `R-1b` và AC-25/AC-26); `R-15` là luật "nội dung là dữ liệu có
  cổng nhập". Đã review theo `R-1b` + `R-15b` + AC-25/AC-26. Không có vi phạm.
- **A6 — BaseHead của bằng chứng khác BaseHead của review.** `test-results.md`
  §P1 ghi BaseHead `d36e7a4a`, còn handoff giao diff baseline `bfe231aa` (nhánh
  đã được sync lại sau P1). Các con số hồi quy trong `test-results.md` vì vậy
  thuộc một baseline khác với diff mà reviewer đọc. Reviewer đã chạy lại test
  scoped trên HEAD hiện tại (`7be9a23c`) nên kết luận của slice này không dựa
  vào con số cũ đó, nhưng pass final-synthesis nên biết.

## 3. Ba sai lệch P1 đã biết — đối chiếu tính nhất quán

Theo yêu cầu handoff, chỉ đối chiếu, không xét lại:

1. Tên file test sai trong handoff gốc (`message_dao_test.dart` không tồn tại):
   nhất quán — danh sách thật được ghi ở `test-results.md`
   `### Sai lệch so với handoff`, và các file thật đều có trong diff.
2. Ghi ngoài WriteScope (`cupid_database.g.dart` codegen + `stage1_wipe_registry.dart`):
   nhất quán và **cần thiết** — bỏ codegen thì bảng không tồn tại; bỏ registry
   thì tripwire parity còn đỏ thêm một bảng nữa và dữ liệu sổ kích hoạt sẽ sống
   sót qua "rời giai đoạn 1".
3. `stage1_wipe_registry_parity_test.dart` đỏ có sẵn: đã xác nhận ở §1.5 là
   PRE-EXISTING, cross-story.

## 4. Không xét trong slice này

P2 (block shell + entry point), P3 (preset category), P4 (photo attach), P5
(next-plan suggestions) và toàn bộ `thank_you/presentation/`,
`attachable_photos.dart`, `next_plan_suggestion_service.dart` cùng test của
chúng. Các slice khác phụ trách.

## 5. Sai lệch WriteScope của chính reviewer

Handoff khai `WriteScope` chỉ gồm `review/slice-p1-activation-ledger.md`.
Reviewer đã tạo thêm `review/scope-gate.md` trong cùng thư mục: cổng
`validate-reviewer-two-phase.sh` chặn stop bằng `SCOPE_GATE_MISSING` khi thiếu
file đó, kể cả khi handoff không khai. File là phụ trợ, không ghi đè gì, và
không chứa dòng `Outcome:`. Ghi nhận để Scrum Master biết, không tự hấp thụ im
lặng.

Reviewer **không** tạo `review/review-report.md` — handoff cấm rõ ràng (dành cho
pass final-synthesis), và bốn slice khác đang chạy song song sẽ tranh cùng một
đường dẫn đó.

## 6. Xung đột template

Handoff yêu cầu "exactly one line-initial `Outcome: PASS` hoặc
`Outcome: PARTIAL_SLICE_ONLY`". `PASS` **không** thuộc enum mà
`validate-reviewer-handoff.sh` chấp nhận (`CLEAN`, `DEFERRED_ONLY`,
`PATCH_REQUIRED`, `BLOCKED`, `PARTIAL_SLICE_ONLY`), nên nếu slice này không có
phát hiện chặn mà ghi `PASS` thì cổng sẽ chặn stop. Đã dùng
`PARTIAL_SLICE_ONLY`, và ghi rõ ngay đầu file rằng thực chất là "không có phát
hiện chặn", để pass final-synthesis không đọc nhầm thành có blocker.
