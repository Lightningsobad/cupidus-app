# Test Results – STORY-009 Chân dung "theo cách BẠN nhìn"

## Phase P1 – Ba gói nội dung chân dung và cổng nhập chạy được

- Status: COMPLETE
- Lane: Mobile
- Last updated: 2026-09-11
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-009_your_view_portrait`
- Flutter resolution: `FLUTTER_SDK_PATH` default `$HOME/flutter` (không có
  `flutter` trần trên PATH máy này); `flutter gen-l10n` chạy trước mọi lệnh khác
  trong worktree mới.

### Commands run

| # | Command (cwd `mobile/`) | Result |
|---|---|---|
| 1 | `flutter gen-l10n` | OK (dùng `l10n.yaml`) |
| 2 | `flutter test test/features/your_view_portrait/portrait_content_gate_test.dart` | `+48: All tests passed!` |
| 3 | `flutter test ... --plain-name "the packs on disk report no violation"` sau khi **cố ý làm hỏng** một clause thật trong `portrait_sections.v1.json` | `+0 -1: Some tests failed.` `EXIT=1` — cổng bắt được `assertive_claim` và `illegal_opening_frame` (bằng chứng đỏ có chủ đích) |
| 4 | `flutter test test/features/your_view_portrait/ test/features/context_notebook/ test/features/before_you_go/ test/features/gift_ideas/ test/features/invite_composer/` | `+446 ~7: All other tests passed!` `EXIT=0` (7 skip có sẵn từ trước) |
| 5 | `flutter analyze <7 đường dẫn đã chạm>` | `1 issue found` — đúng một `info • prefer_initializing_formals` **đã có sẵn** ở `lib/core/content/content_package.dart:208`, file P1 không sửa. 0 error, 0 cảnh báo mới. Nền của repo khác 0 nên tiêu chí là "không lỗi mới", không phải exit code. |

Lệnh đỏ ở dòng 3 được chạy trên asset thật rồi hoàn nguyên; nội dung trên đĩa
hiện tại là bản sạch đã qua dòng 2 và dòng 4.

### Deliberate red run – exact gate output

```
'req016.portrait_sections/portrait.section.own_days.v1 [assertive_claim]: text uses the denylisted term "người ấy là"',
'req016.portrait_sections/portrait.section.own_days.v1 [illegal_opening_frame]: clause "Người ấy là kiểu giữ {ngay_rieng} cho riêng mình." does not open with one of the legal frames'
```

Một chuỗi hỏng trong **gói asset thật** làm đỏ bản dựng, không chỉ làm đỏ một
fixture — đúng yêu cầu AC-36/AC-37/BR-17.

### AC coverage – Phase P1

| AC / BR | Cách phủ | Bằng chứng |
|---|---|---|
| AC-31 (a) cổng nhập chạy được | `validatePortraitPacks(...)` + test quét đĩa | lệnh 2, 3 |
| AC-31 (b) truy vết duyệt theo id bền | `editorial_review` trên mọi item của cả ba gói; `PortraitEditorialReview` parse theo id | lệnh 2 |
| AC-33 gói có lược đồ + id bền | ba `schema_id` riêng, `ContentPackage.parse` chốt `expectedSchemaId`; test tham chiếu chéo `ask_id`/`question_id` | lệnh 2 |
| AC-34 N là thuộc tính dữ liệu | nhóm test "pack size is data" chạy gate trên gói 1 mục và gói 7 mục, cùng kết quả | lệnh 2 |
| AC-35 app không tự khẳng định | luật mới `assertiveClaim` + `illegalOpeningFrame` trên MỌI clause | lệnh 2, 3 |
| AC-36 cổng ĐẦU RA làm hỏng bản dựng | 7 luật `InvariantRule` chạy trên prompt/chips/heading/clause/ask | lệnh 2, 3 |
| AC-37 cổng ĐẦU VÀO của bộ câu hỏi | `NotebookBoundaryRule` chạy trên câu hỏi có `target` là `notebook.*`; test chứng minh phạm vi (câu `portrait.guess` không bị chặn) | lệnh 2 |
| AC-22 tiền đề (ranh giới sổ tay) | không câu `notebook.*` nào hỏi tần suất/hành vi/phán xét — cưỡng chế ở cổng, không phải quy ước | lệnh 2 |
| AC-13 / BR-4 khuôn câu mở đầu | `portraitLegalOpeningFrames` là hằng Dart; test khẳng định gói KHÔNG khai lại danh sách khung | lệnh 2 |
| AC-19 / R-1g mỗi phần kết bằng câu để hỏi | `sectionWithoutAsk` + `unknownAskId`; parse từ chối `ask_ids` rỗng | lệnh 2 |
| BR-15 / R-15a nội dung là dữ liệu | test quét `lib/**` `.dart`/`.arb` tìm mọi chuỗi đã soạn; 0 offender | lệnh 2 |
| BR-16 / R-15b không mã nào suy ra N | không hằng số đếm trong `portrait_content*.dart`; gate không đọc `length` để quyết định gì | lệnh 2, 5 |
| BR-17 / R-15c luật chỉ sống trong Dart | test "only invariant_terms.dart declares the assertive-claim terms" quét toàn `lib` | lệnh 2 |
| AC-29/AC-30 tất định + offline | P1 không có lời gọi mạng, không nguồn ngẫu nhiên; asset đọc qua `ContentPackageLoader` | lệnh 2, 5 |

### Ripple absorbed inside P1

Thêm `InvariantRule.assertiveClaim` vào `core/content/invariant_terms.dart` làm
đỏ hai test anh em ngay lập tức (`before_you_go` và `context_notebook` đều
khẳng định `InvariantRule.values ⊆ <Family>GateRule`), và làm
`_ruleFor(wireValue).firstWhere` của bốn gate cũ ném `StateError` nếu luật mới
kích hoạt. P1 hấp thụ trọn ripple: `ContextGateRule`, `BeforeYouGoGateRule`,
`GiftGateRule`, `PresetGateRule` đều nhận thêm `assertiveClaim('assertive_claim')`.
Denylist mới được đối chiếu trước với toàn bộ asset/lib/test đang có — không
cụm nào trùng, nên không gói đã ship nào chuyển sang vi phạm (lệnh 4 xác nhận).

`pubspec.yaml` KHÔNG đổi: `assets/data/req016/` đã được khai báo từ trước.

### Later-phase schedulability

P2..P5 **không** phase nào schedule song song được lúc này. Kế hoạch của Tech
Lead nối tiếp theo dữ liệu: P2 cần hình dạng gói của P1, P3 cần P1+P2, P4 cần
P2+P3, P5 cần P4. Phase actionable kế tiếp đúng một cái: **P2**
(`phase-P2-answer-store-and-notebook-door.md`), cùng lane Mobile.

## Phase P2 – Lưu câu trả lời và cửa ghi hẹp vào sổ tay

- Status: COMPLETE
- Lane: Mobile
- Last updated: 2026-09-16
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-009_your_view_portrait`
- Session-Recovery: phiên trước đã bị mất; phần cài đặt P2 dở dang của nó được
  Scrum Master niêm phong thành commit `47c52888` (BaseHead của phiên này).
  Phiên này kiểm kê lại commit đó đối chiếu từng mục của phase file, rồi chạy
  toàn bộ cổng kiểm thử — không có hạng mục cài đặt nào còn thiếu.

### Inventory đối chiếu commit 47c52888

| Yêu cầu phase | Trạng thái trong `47c52888` |
|---|---|
| Bảng `portrait_answers` đúng §5, không cột đo lường | Có — `core/database/tables/portrait_answers_table.dart`, đúng 7 cột, khoá chính `(owner_key, question_id)` |
| Đăng ký `@DriftDatabase` + `schemaVersion` 6 → 7 + `onUpgrade` chỉ tạo bảng mới | Có — `cupid_database.dart`, `if (from < 7) await m.createTable(portraitAnswers)` |
| Sửa mọi assertion `schemaVersion` đang đỏ | Có — 8 file test hiện có; phiên này sửa thêm một **tên test** còn ghi "schema version 6" ở `test/core/database/activity_card_dao_test.dart:61` (assertion đã đúng 7, chỉ nhãn bị lệch) |
| `PortraitAnswerDao` + `PortraitAnswerRepository` (`upsertAnswer`, `markSkipped`, `answersFor`), con trỏ suy ra không lưu | Có — `resolveResumeQuestionId` là hàm thuần, không cột nào mang nghĩa tiến độ |
| `recordAnsweredQuestion(...)` một câu mỗi lần, `kind` chỉ `interest`/`event`, `source = ask_on_the_spot` | Có — `context_notebook_entry_point.dart`; `NotebookKind` chỉ có hai giá trị nên `skill` bị chặn ở mức kiểu |
| Lưu `notebook_entry_id` cho P4 đọc lại | Có — và `answerValue` bị từ chối khi target là `notebook.*`, nên không có bản sao thứ hai |

### Commands run

| # | Command (cwd `mobile/`) | Result |
|---|---|---|
| 1 | `flutter gen-l10n` | OK (dùng `l10n.yaml`) |
| 2 | `dart run build_runner build` | `Built with build_runner/aot in 30s; wrote 1305 outputs.` — `git status` sạch sau đó, tức `cupid_database.g.dart` trong commit đã là bản sinh hiện hành |
| 3 | `flutter test test/features/your_view_portrait/portrait_answer_repository_test.dart` | `+28: All tests passed!` |
| 4 | `flutter test test/core/database` | `+82: All tests passed!` — mọi test chạm `CupidDatabase`, gồm `migration_v5_test`, `cupid_database_migration_v3_test`, `context_notebook_migration_test` |
| 5 | `flutter test test/features/context_notebook` | `+90 ~4: All other tests passed!` `EXIT=0` (4 skip có sẵn từ trước) |
| 6 | `flutter test test/features/activity_cards test/core/database/activity_card_dao_test.dart` | `+229 ~2: All other tests passed!` `EXIT=0` — chạy lại sau khi sửa tên test |
| 7 | `flutter analyze lib test` | `225 issues found` / `EXIT=1`: **0 error**, 35 warning, còn lại là `info`. Nền repo khác 0 nên tiêu chí là "không lỗi mới"; ba `info` mới đều là `prefer_initializing_formals` ở `portrait_answer_repository.dart:73..75`, cùng khuôn với `ContextNotebookRepository` đã ship |

Tập hợp file test khẳng định `schemaVersion` được liệt kê đầy đủ bằng `find` +
`grep -l`: 9 file, toàn bộ nằm trong lệnh 3, 4, 6 ở trên. Không còn assertion
`schemaVersion` nào ngoài phạm vi đã chạy.

### Acceptance criteria → test cụ thể

| AC của phase | Test |
|---|---|
| Trả lời rồi mở lại đúng câu đang dở (AC-25, AC-6) | `resume cursor is derived, never stored` — 6 test, gồm "a skipped question comes back around once everything has been seen" |
| Câu `notebook.*` đọc lại được qua `ContextNotebookReader` (AC-5) | `an answered interest question is readable back through ContextNotebookReader (AC-22)` |
| `portrait.guess` không tạo mục sổ tay (AC-23) | `a guess answer keeps its value here and writes nothing to the notebook (AC-23)` + `a guess answer pointing at a notebook entry is rejected (AC-23)` + `a portrait.guess target never reaches this door` |
| `recordAnsweredQuestion` từ chối `NotebookKind.skill` | `the door writes one answer per call: there is no kind outside interest and event to write through it` — `NotebookKind` chỉ có `interest`/`event`, nên `skill` không tồn tại ở mức kiểu |
| Migration v6 → v7 giữ nguyên dữ liệu cũ | `v6 -> v7 migration` — 3 test, gồm `every pre-existing client-owned row survives the upgrade intact` |
| Không cột cấm ở §5 | `carries exactly the contracted columns and no measuring column (R-1b / AC-12 / AC-28)` + `no data-layer source names a progress, count, or score concept` |

### Ripple bàn giao cho Scrum Master

`schemaVersion` được bump 6 → 7 trên base của story này. Ba story khác đang bay
cũng có việc schema riêng, nên con số 7 gần như chắc chắn đụng nhau ở lượt merge
tích hợp. Phase này cố tình **không** né bằng cách nhảy số: quy tắc của phase là
"đọc giá trị thật rồi cộng một". Người merge cần đánh số lại tuần tự và gộp các
bước `onUpgrade`; mọi assertion `schemaVersion` nằm đúng 9 file đã liệt kê ở
trên.

### Phase actionable kế tiếp

**P3** (`phase-P3-deterministic-composer.md`), cùng lane Mobile. P3 cần P1 (hình
dạng gói) và P2 (đường đọc câu trả lời), cả hai giờ đều COMPLETE. P4 vẫn chờ P3.

## Phase P3 – Bộ dựng chân dung tất định

- Status: COMPLETE
- Lane: Mobile
- Last updated: 2026-09-16
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-009_your_view_portrait`
- File đã tạo: `mobile/lib/features/your_view_portrait/domain/portrait_composer.dart`,
  `mobile/test/features/your_view_portrait/portrait_composer_test.dart`
  (đúng Write Scope của phase, không file nào khác bị chạm)

### Commands run

| # | Command (cwd `mobile/`) | Result |
|---|---|---|
| 1 | `flutter test test/features/your_view_portrait/portrait_composer_test.dart` | `+28: All tests passed!` |
| 2 | `flutter test test/features/your_view_portrait` | `+104: All tests passed!` `EXIT=0` — gồm toàn bộ test P1 (`portrait_content_gate_test.dart`) và P2 (`portrait_answer_repository_test.dart`), không hồi quy |
| 3 | `flutter analyze lib test` | `225 issues found` / `EXIT=1`: **0 error**, đúng bằng con số trước P3 ⇒ hai file mới không thêm một phát hiện nào |

Không chạy `dart run build_runner build`: P3 không đụng file Drift nào.

### Hai lần đỏ có thật trong lúc làm, và điều chúng phơi ra

1. **Luật bất biến chạy trên chuỗi ĐÃ DỰNG bắt một lỗ hổng mà cổng gói không
   thấy được.** Chip đã ship của `portrait.q.event.own_day.v1` kết thúc bằng từ
   chỉ người kia; mệnh đề đã duyệt của `portrait.section.own_days.v1` nối ngay
   sau bằng " là ngày …". Ghép lại ra đúng một cụm nằm trong denylist
   `assertive_claim`, dù **không** bên nào chứa cụm đó. Vì câu hỏi cho phép free
   text (`allow_free_text: true`), sửa nội dung không bịt được lỗ này — người
   dùng gõ tay vẫn tạo lại được. Cách bịt duy nhất đúng là **đo lại ở lúc dựng**:
   mệnh đề nào sau khi thay biến mà vi phạm luật thì bị bỏ **nguyên mệnh đề**.
   Engine vẫn không sinh chuỗi mới, và phần mỏng đi là kết quả hợp lệ
   (AC-19/BR-9). Đây chính là điều mục 4 phase file yêu cầu ("chạy các luật
   `InvariantRule` lên chuỗi **đã dựng**, không chỉ lên gói nguồn").
2. **Cổng BR-15 của P1 quét chữ nội dung trong `lib/`.** Comment giải thích của
   composer trích nguyên văn một chip để nêu ví dụ, và bị chính cổng đó bắt
   (`portrait_content_gate_test.dart` → "no portrait wording is written into any
   Dart or l10n file"). Comment đã viết lại theo mô tả thay vì trích dẫn. Ghi lại
   ở đây vì phase sau dễ vấp lại: **không** dán chữ của gói vào bất kỳ file
   `lib/` nào, kể cả trong comment.

### Quyết định đã lấy khi phase file và hợp đồng nói khác nhau

Phase file mục 3 và mục 4 viết: "Phần không còn mệnh đề nào sống sót thì **không
hiển thị**" và "Bỏ qua toàn bộ câu hỏi ⇒ **không phần nào hiển thị**".
`architecture/contract-summary.md` mục 4 viết ngược lại: "Phần còn 0 clause sống
**vẫn hiện**, **chỉ** với dòng câu-để-hỏi (AC-19/BR-9) — không khối rỗng".

Đã chọn theo **hợp đồng**, vì ba lý do kiểm chứng được:

- `1B. Phase Metadata → Source Of Truth` của chính phase file chỉ định
  `contract-summary.md` mục 4 là nguồn có thẩm quyền cho đúng chủ đề này.
- AC-19 (`requirements.md:178`) và UX mục 3.5 (`uiux-spec.md:55`) đều cho phép
  **cả hai** cách ("hiện thẳng câu-để-hỏi tương ứng, **hoặc** không hiện phần
  đó"), nên không cách nào vi phạm AC.
- Chỉ có cách của hợp đồng tránh được màn ngõ cụt: bỏ qua toàn bộ câu hỏi mà ẩn
  hết mọi phần thì màn kết quả trắng, đúng thứ mục 6 hợp đồng cấm ("Cấm … màn
  ngõ cụt").

Mối lo thật sự của phase file là "tiêu đề rỗng" — cách của hợp đồng không tạo ra
tiêu đề rỗng, vì phần luôn còn dòng câu-để-hỏi. Nếu Reviewer muốn lật lại, đó là
một dòng lọc trong `composePortrait` cộng hai test, không phải thiết kế lại.

### Ghi chú bàn giao cho chủ nội dung (không chặn P3)

Với chip mặc định đầu tiên của `portrait.q.event.own_day.v1`, mệnh đề thứ nhất
của `portrait.section.own_days.v1` **không bao giờ hiển thị** — nó luôn rơi vào
luật ở mục 1 phía trên. Phần đó vẫn còn hai mệnh đề khác nên chân dung không
rỗng (có test khẳng định mọi phần còn ít nhất một mệnh đề khi trả lời đầy đủ),
nhưng đây là việc biên tập nên xử lý ở gói: đổi cách đặt câu của mệnh đề để nó
không nối " là " ngay sau một biến chỉ người kia.

### API bàn giao cho P4

```dart
List<ComposedSection> composePortrait({
  required ContentPackage<PortraitSection> sections,
  required ContentPackage<PortraitAsk> asks,
  required Map<String, PortraitSettledAnswer> answers,  // key: question_id
  required Map<String, String> notebookValues,          // key: notebook_entries.id
  required int askCursor,
});
```

- `ComposedSection`: `sectionId` · `heading` · `clauses` · `paragraph`
  (`clauses.join(' ')`) · `askId` · `askText`. Chỉ đọc, không trường nào đếm
  được thành tiến độ.
- `PortraitSettledAnswer` là bản sao domain của ba trường đã lưu
  (`skipped`, `answerValue`, `notebookEntryId`). Composer nằm ở `domain/`, mà
  **không file `domain/` nào trong repo này import `data/`** (đã kiểm bằng grep
  toàn `lib/features/*/domain/`), nên P4 tự ánh xạ `PortraitAnswer` →
  `PortraitSettledAnswer` bằng ba dòng, thay vì kéo `data/` vào `domain/`.
- `askCursor` do P4 giữ trong Cubit đúng một vòng đời màn và **không** được lưu
  xuống DB (mục 5 hợp đồng). Quay vòng là `askIds[cursor % askIds.length]` trên
  `ask_ids` của **chính phần đó**, đúng với mọi N kể cả N = 1.

### Acceptance criteria → test cụ thể

| AC của phase | Test |
|---|---|
| Cùng đầu vào ⇒ hai kết quả bằng nhau từng ký tự (AC-29) | `the same inputs compose the same strings, character for character` + `the shipped packs compose the same portrait twice in a row` |
| Không mạng, không đồng hồ, không ngẫu nhiên (AC-30) | `the composer source reaches no clock, no network, and no randomness` (quét chính file nguồn: `dart:io`, `dart:math`, `package:http`, `Random`, `DateTime.now()`, `rootBundle`, `await`) |
| Thiếu biến ⇒ bỏ nguyên mệnh đề, phần vẫn đọc trôi | `an unbound variable drops its clause whole, leaving the others untouched` + `no dropped clause leaves a visible placeholder or a half sentence` |
| Bỏ qua toàn bộ ⇒ không trách móc | `skipping every question leaves ask lines, never a dead-end screen (§6)` + `nothing composed reads as a reproach, a count, or a prompt to answer more` |
| Mỗi phần kết bằng đúng một câu-để-hỏi, kết thúc bằng `?` (AC-3 story) | `every section ends with exactly one line to ask, and it is a question (AC-3 story)` |
| Không đầu ra nào chứa điểm số/khẳng định về người kia (AC-4 story) | `every composed string passes the same invariant rules as the packs` + hai test của nhóm `the invariant rules are measured on composed text` |
| Quay vòng đúng với N = 1, 2, n (R-15b) | `a store of one ask returns that ask at every cursor`, `a store of two asks alternates and wraps at the end`, `a store of n asks wraps on its own length, with no assumed size` |

Thêm ngoài AC, vì đều là đường người dùng thật đi vào được: giá trị người dùng
chứa `{...}` không bị thay tiếp (thay một lượt duy nhất); mục sổ tay bị xoá làm
chân dung mỏng đi thay vì để lại bản sao cũ (AC-22); `ask_id` không có trong kho
thì ném lỗi rõ thay vì hiện dòng hỏi rỗng.

### Phase actionable kế tiếp

**P4** (`phase-P4-portrait-screen.md`), cùng lane Mobile. P4 cần P2 (kho câu trả
lời) và P3 (bộ dựng), cả hai giờ đều COMPLETE. P5 vẫn chờ P4.

---

## Phase P4 – Màn chân dung

Ngày chạy: 2026-09-17. Worktree:
`story-REQ-016_solo_stage1_relationship_assistant-STORY-009_your_view_portrait`,
nhánh `codex/REQ-016_solo_stage1_relationship_assistant-STORY-009_your_view_portrait`,
BaseHead `c61256c2`.

### Commands run

| Lệnh | Kết quả |
|---|---|
| `flutter gen-l10n` | xanh; sinh 7 getter `portrait_*` trong `lib/l10n/generated/app_l10n.dart` |
| `flutter test test/features/your_view_portrait/your_view_portrait_screen_test.dart` | 13 xanh, 2 bỏ qua (hai test chụp ảnh, tắt mặc định) |
| cùng lệnh trên `--dart-define=CAPTURE_VISUALS=true` | 15 xanh, 0 bỏ qua; hai ảnh đã ghi |
| `flutter test test/features/your_view_portrait test/features/context_notebook` | **207 xanh**, 6 bỏ qua (toàn bộ test chụp ảnh của STORY-004 và của phase này) |
| `flutter analyze lib test` | 228 issue, **0 lỗi**; nền đã biết là 225 issue / 0 lỗi |
| `flutter build apk --debug` (registry `mobile-app.buildCommand`) | xanh — `app-local-debug.apk` |

Ba issue mới của analyze đều là `info • prefer_initializing_formals` ở hàm dựng
cubit. Lint này không sửa được cho tham số có tên: bản vá nó gợi ý là
`this._contentLoader`, mà tham số có tên bắt đầu bằng `_` là lỗi cú pháp Dart.
`portrait_answer_repository.dart` của P2 đã mang đúng ba info cùng loại và chúng
nằm sẵn trong nền 225. Tiêu chí của phase là "không lỗi mới": 0 lỗi, giữ nguyên.

### Hai lần đỏ có thật, và điều chúng phơi ra

**1. Toàn bộ 13 test đỏ ở lần chạy đầu: màn kẹt vĩnh viễn ở khung loading.**
Nhãn xuất xứ tìm thấy, prompt câu hỏi thì không — tức là cây widget dựng được,
nhưng cubit không bao giờ rời `PortraitStage.loading`. Dò bằng một test tạm cho
thấy cubit chạy đúng khi đứng một mình. Thủ phạm là chỗ tưởng vô hại nhất trong
file test: một `ContentPackageLoader` dùng chung giữa `setUpAll` và widget.
`CachingAssetBundle` giữ lại chính cái `Future` nó tạo lần đầu, và một `Future`
sinh ra ngoài vùng fake-async của `testWidgets` thì **không bao giờ hoàn tất bên
trong** vùng đó — `pumpAndSettle` trả về ngay vì chẳng có frame nào được lên
lịch, nên không có timeout để tố cáo. Sửa: mỗi lần mount một bundle mới; lần đọc
gói ở `setUpAll` (chỉ để lấy id/chip cho assertion) dùng bundle riêng của nó.
Đây là bẫy dùng lại được cho mọi test màn hình khác nạp gói nội dung.

**2. `portrait-section-portrait.section.your_guess.v1` không tìm thấy.**
`ListView` chỉ dựng phần đang thấy, nên phần thứ ba nằm dưới màn 800x600 vắng
mặt khỏi cây element — `findsNothing` ở đây là sự thật về kết xuất, không phải
về bố cục. Sửa ở phía test: `scrollUntilVisible` từng khối trước khi khẳng định,
và các phép quét chữ của AC-12/AC-24 chạy qua một helper cuộn hết danh sách rồi
gom chữ lại. Một test chỉ đọc phần thấy được sẽ xanh giả với mọi thứ nằm dưới
nếp gấp.

### Visual fidelity

`design_source`: **đã phát hiện** — `cupid-app-design-system/Cupid Chặng 1.dc.html`,
node `(8) Chân dung theo cách BẠN nhìn` (badge `B6 · khoá vị trí`), khung
393×852, dark, `data-plat="ios"`. Không ghi `DESIGN_SOURCE_NOT_DETECTED`.

Ảnh (RepaintBoundary, khung 415×900, nền `CupidAppBackground`, MaterialIcons của
framework đã nạp, platform Material vì băng iOS là `BackdropFilter` không sample
được khi render ngoài màn):

- `../visual-fidelity/implemented-8-chan-dung-theo-cach-ban-nhin-cau-hoi-md.png`
- `../visual-fidelity/implemented-8-chan-dung-theo-cach-ban-nhin-ket-qua-md.png`

Đã **mở ra nhìn**: dấu tiếng Việt hiện đủ và đúng ("Chân dung tưởng tượng",
"Bỏ qua", "Câu để hỏi"), không ô tofu; hai icon `info_outline` và `help_outline`
ra glyph thật; ảnh kết quả cho thấy nhãn xuất xứ vẫn dính đỉnh sau khi cuộn.

Ba chỗ canvas vẽ mà bản hiện thực **cố ý không** theo, đều do AC cấm — theo luật
"design anchor chỉ giải quyết tranh chấp spec-với-canvas, hạng mục do AC chi phối
thì AC thắng":

| Canvas vẽ | Không hiện thực vì |
|---|---|
| Thanh tiến độ 37.5% dưới dòng `CÂU 3 / 8` | AC-26/AC-28 và `uiux-spec` mục 4 cấm thanh phần trăm hoàn thành |
| Dòng phụ "8 câu, ..." | số câu cứng trong chuỗi khung là đúng thứ R-15b/BR-16 cấm |
| Tiêu đề lớn dạng câu hỏi trong khung | chữ mang nghĩa hỏi không được nằm trong l10n; mọi câu chữ nội dung đi từ gói |

Chỉ báo `Câu 1/8` **có** hiện thực: phase mục 3 (dòng 92-94) cho phép đích danh
"câu k/n" chỉ trong phiên hiện tại, `uiux-spec` mục 2.2 cũng vậy. Nó không lưu
xuống DB, không xuất hiện ngoài thẻ câu hỏi đang mở, và biến mất hoàn toàn ở
trang kết quả — có test khẳng định điều đó.

### Quyết định đã lấy khi các nguồn nói khác nhau

- **Widget màn không thể là library-private.** Phase đòi `_YourViewPortraitScreen`
  "không export", nhưng privacy của Dart theo file, mà P5 phải dựng được nó từ
  `your_view_portrait_entry_point.dart` — một file khác. Đã chọn: lớp công khai
  `YourViewPortraitScreen`, **không** `routeName`, **không** có trong `routes:`
  của `cupid_app.dart`, và không có chỉ thị `export` nào chạm tới nó. Khoá ở mức
  biên dịch (`openYourViewPortrait(..., from: PortraitEntrySource)`) và test của
  nó thuộc P5, đúng như AC cuối mục 4 của chính phase đã ghi ("kiểm bằng test ở
  P5").
- **Con trỏ câu-để-hỏi đứng yên ở 0.** P3 để người gọi giữ con trỏ quay vòng.
  Nếu tăng nó mỗi lần mở màn thì hai lần xem cùng bộ trả lời sẽ khác nhau, tức
  vỡ AC-29. Cơ chế quay vòng của P3 vẫn nguyên và vẫn đúng với mọi N; P4 chỉ
  không dùng nó để tạo khác biệt.
- **Không có link "xem lại câu đã bỏ qua" ở cuối trang kết quả.**
  `solution.md` có nhắc một link trung tính; `uiux-spec` mục 3.6 — Source Of
  Truth của phase này — nói cuối trang kết quả **chỉ** có đường quay lại luồng
  nguồn. Đã theo uiux-spec: câu đã bỏ qua tự quay lại ở lần mở sau qua con trỏ
  suy ra, đó đúng là điều AC-27 đòi.
- **Nhãn xuất xứ đặt ngoài vùng cuộn**, ngay dưới `CupidHeader`, dựng ở cả trạng
  thái hỏi lẫn trạng thái kết quả. Cách này làm "cuộn tới cuối mà nhãn vẫn còn"
  đúng về mặt cấu trúc chứ không chỉ đúng ở một lần chạy, và không cần
  `SliverPersistentHeader`.

### Acceptance criteria → test cụ thể

| AC của phase | Test |
|---|---|
| Mở màn khi chưa trả lời gì: câu đầu, có Bỏ qua, có nhãn xuất xứ (AC-1 story, AC-6) | `opens on the first question with the provenance line and a skip as reachable as the next action (AC-6, AC-25)` — có cả assertion hai nút cùng `dy`, tức bỏ qua không tốn tầm với hơn đi tiếp |
| Trả lời hết: mỗi phần kết bằng một câu để hỏi, không điểm số (AC-3, AC-4 story) | `renders one block per section, each closed by its own ask line (AC-20)` + `carries no measure, no progress and no completion badge (AC-12, AC-26, AC-28)` |
| Cuộn kết quả xuống cuối, nhãn xuất xứ vẫn thấy (AC-6..AC-8) | `keeps the provenance line on screen after scrolling to the bottom (AC-7)` |
| Trả lời dở rồi mở lại: vào đúng câu đang dở, không thúc ép, không badge (AC-6 story, AC-25, AC-26) | `reopening lands on the exact unfinished question, with nothing nagging about the rest (AC-27)` |
| `notebook.interest` tạo mục sổ tay, `portrait.guess` thì không (AC-5 story, AC-23) | `a notebook question lands in the notebook and a guess does not (AC-22, AC-23)` — chạy qua `recordAnsweredQuestion(...)` thật trên DB trong bộ nhớ, rồi đọc lại bằng `contextNotebookReader()` |
| Widget màn không export, không trong `routes:` | thuộc P5 theo chính phase; P4 đã để sẵn điều kiện: không `routeName`, không `export`, không sửa `cupid_app.dart` |

Thêm ngoài AC, vì đều là đường người dùng đi được: một câu cho tự viết thì nhận
chữ gõ thay cho chip; ghi vào sổ tay không hỏi xác nhận (`findsNothing` cho
`Dialog`/`AlertDialog`); bỏ qua sạch cả 8 câu vẫn ra trang kết quả rút gọn còn
các dòng câu-để-hỏi (AC-19); hai lần dựng trên cùng bộ trả lời cho cùng chuỗi
chữ (AC-29); không icon chia sẻ/sao chép/tải về nào ở cuối trang (AC-24).

### Ghi chú bàn giao cho Scrum Master

Ảnh bằng chứng nằm ở `STORY-009_your_view_portrait/visual-fidelity/`, đúng chỗ
phase file bắt buộc, nhưng `WriteScope` của handoff chỉ cấp `mobile` cộng ba file
`coding-plan/*.md`. Hai ảnh do tiến trình test ghi lúc chạy, không qua công cụ
Write. Nêu ở đây để Scrum Master biết mà đưa vào commit.

### Phase actionable kế tiếp

**P5** (`phase-P5-locked-entry-point.md`), cùng lane Mobile, phụ thuộc P4 —
giờ đã COMPLETE. P5 dựng `openYourViewPortrait(..., from: PortraitEntrySource)`,
khoá vị trí ở mức biên dịch và viết test khẳng định màn không export, không
`routeName`, không có trong `routes:`.
