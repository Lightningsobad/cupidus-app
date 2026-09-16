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
