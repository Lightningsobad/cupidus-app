# Review Report: STORY-009 Chân dung "theo cách BẠN nhìn"

- Review type: `compact-story-review`
- Story: `STORY-009_your_view_portrait` (REQ-016), Complexity `standard`, Lane `mobile-only`
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-009_your_view_portrait`
- Diff baseline: `b58afbe0` → worktree HEAD `d860557e`
  - lượt 1 (2026-09-17): `b58afbe0` → `dc190a49` (54 file, +7542/-47) → `PATCH_REQUIRED`
  - lượt 2, vòng vá (2026-09-17): `dc190a49` → `d860557e` (13 file, +415/-10,
    **không file nào dưới `mobile/lib` hoặc `mobile/test`**)
- Reviewed: 2026-09-17 (lượt 2)

Outcome: DEFERRED_ONLY

## Scope Gate

- Review report path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-009_your_view_portrait/review/review-report.md`
- Governing artifacts đã đọc: `story_master.md`; `coding-plan/test-results.md` (P2 §Commands, P4 toàn phần, P5 toàn phần); `data/devops/system/design-fidelity-config.json`; `.agent-contract/design-fidelity-spec.md` (query-first).
- Source/test files trong phạm vi (đọc mã thật, không chỉ đọc kế hoạch):
  - `mobile/lib/features/your_view_portrait/your_view_portrait_entry_point.dart`
  - `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart` (diff)
  - `data/.../visual-fidelity/implemented-8-*-cau-hoi-md.png` (mở ra nhìn)
  - `data/.../visual-fidelity/implemented-8-*-ket-qua-md.png` (mở ra nhìn)
- Query keys: `openYourViewPortrait`, `PortraitEntrySource`, `routeName`, `schemaVersion`,
  `Entry Point Reachability`, `Story Runtime Startup Smoke`, `VISUAL_FIDELITY`, `design_source`.
- Không mở: `architecture/solution.md`, `ux/uiux-spec.md`, `requirements/requirements.md` —
  không có câu hỏi hợp đồng hay biên lane nào phát sinh; ba phát hiện chặn đều là
  cổng bằng chứng, không phải tranh chấp phạm vi.
- Lượt 2 có `scope-gate.md` riêng: `review/scope-gate.md` (mục Source/Test Files
  In Scope của lượt 2 chỉ thêm `activity_card_hub_view.dart` dòng 226–285; mọi
  bề mặt rủi ro lượt 1 đã PASS và diff vòng vá không chạm nên không soát lại).

## Touched Risk Surfaces → Critical Gates

| Risk surface | Bằng chứng | Cổng |
|---|---|---|
| Persistence/schema/migration (`portrait_answers`, drift `schemaVersion` 6→7) | P2 lệnh 2/4/6: `build_runner` sạch, `test/core/database` +82 xanh gồm `migration_v5_test`, 9 file assertion `schemaVersion` đều chạy | PASS |
| Local storage/offline (DAO + repository, con trỏ suy ra) | P2 lệnh 3: `portrait_answer_repository_test.dart` +28 xanh | PASS |
| Typed/generated contract (`cupid_database.g.dart`, gói nội dung có schema + id bền, R-15a) | P1 cổng nhập chạy được; P2 `git status` sạch sau `build_runner` | PASS |
| Mobile interaction (màn chân dung, 8 câu, trang kết quả) | P4: 13 xanh + 2 test ảnh; 207 xanh khi chạy cùng `context_notebook` | PASS |
| Mobile navigation/discoverability (khoá vị trí SC-6/R-13) | P5: `portrait_location_lock_test.dart` 4 xanh, có bằng chứng bắt vi phạm thật bằng file dò `_probe_violation.dart`; `your_view_portrait_entry_point_test.dart` 2 xanh; 225 xanh gộp `gift_ideas` | PASS (mã); mục bằng chứng đã có sau vòng vá — F-2 ĐÓNG |
| Mobile build / static analysis | `flutter build apk --debug` xanh; `flutter analyze lib test` 228 issue / **0 lỗi** (nền 225/0) | PASS |
| UI design fidelity (12e2/12e3/12g2) | `visual-fidelity-report.md` `VISUAL_FIDELITY: PASS` + `design-reference-8-*-ios.png` + 2 `implemented-*.png` + 3 ảnh runtime | PASS — F-1 ĐÓNG |
| App lifecycle / runtime startup smoke (12g) | `## Story Runtime Startup Smoke` PASS trên `emulator-5554`, logcat 0 fatal / 0 `E/flutter`, DB thật `user_version=7` | PASS — F-3 ĐÓNG |

Configuration/setup: story không chạm env, script hạ tầng, registry entry hay
Docker/Compose — `configuration-guide.md` không thuộc phạm vi story này.

## Blocking Findings — đã đóng ở vòng vá `d860557e`

Không còn phát hiện chặn nào. Ba mục dưới đây giữ nguyên nội dung lượt 1 làm hồ
sơ, mỗi mục có một khối **Vá — đã xác minh** ghi cách tôi tự kiểm chứng ở lượt 2
(mở ảnh ra nhìn, đọc dải văn bản thật, đối chiếu dòng mã — không tin vào tiêu đề
mục).

**F-1 — Thiếu hoàn toàn bằng chứng design fidelity dạng ảnh so sánh.** (owner: `mobile-dev`)
`data/devops/system/design-fidelity-config.json` có `design_source` đã khoá
(`locked: true`, `cupid-app-design-system`, `ui_surface: true`), và chính
`test-results.md` P4 §Visual fidelity ghi đã phát hiện node `(8) Chân dung theo
cách BẠN nhìn` trong `Cupid Chặng 1.dc.html`. Nhánh SKIPPED "không có design
source" **không** áp dụng. Nhưng `visual-fidelity/` chỉ có hai ảnh implemented:
- thiếu `design-reference-8-chan-dung-theo-cach-ban-nhin-<device>.png`
- thiếu `visual-fidelity/visual-fidelity-report.md` với dòng `VISUAL_FIDELITY: PASS|FAIL`
- `Design-Screen: <id>` chỉ nằm trong văn xuôi P4, không có trong artifact cổng đọc

Đoạn văn "Ba chỗ canvas vẽ mà bản hiện thực cố ý không theo" trong
`test-results.md` là một so sánh **bằng lời**; luật 12e2 đòi ảnh kết xuất, không
đòi văn xuôi. Ba khoản lệch đó đều được biện minh đúng luật design-anchor
(hạng mục do AC chi phối thì AC thắng: AC-26/AC-28 cấm thanh phần trăm, R-15b/BR-16
cấm số câu cứng trong chuỗi khung) — nên nhiều khả năng kết quả cuối là
`VISUAL_FIDELITY: PASS` kèm delta đã phân loại, chứ không phải lỗi hiện thực. Đây
là khoảng trống **artifact**, phải vá bằng cách render reference và viết báo cáo,
không phải sửa UI.

**Vá — đã xác minh (F-1 ĐÓNG).** `visual-fidelity/design-reference-8-chan-dung-theo-cach-ban-nhin-ios.png`
(233.6 KB) đã có và tôi **mở ra nhìn**: đúng một frame canvas 415x900 có device
chrome iOS, và nó chứa đủ sáu điểm mà `visual-fidelity-report.md` khai là
`DESIGN_SPEC_CONFLICT` — vạch gradient tiến độ dưới `CÂU 3 / 8`; khối mở đầu
"Bạn đang hình dung Cún thế nào?" cộng câu "8 câu, bạn trả lời thay Cún…"; tên
riêng "Cún" ở mọi chuỗi; "bỏ qua được" nằm ở góc phải header thẻ; ba lựa chọn cố
định không có ô tự viết; CTA "Câu tiếp nha". Nó cũng chứa đúng chip trấn an "Chỉ
hỏi **sở thích và sự kiện**. App không bao giờ hỏi Cún trả lời tin nhắn nhanh hay
chậm." mà báo cáo khai là `DESIGN_DELTA_OPEN`. Tức bản mô tả trong báo cáo là
trung thực với ảnh, không phải văn xuôi dựng lại từ trí nhớ — đây chính là thứ
lượt 1 không thể kiểm được.

`visual-fidelity-report.md` mở đầu bằng đúng hai token máy đọc được:
`VISUAL_FIDELITY: PASS` và `Design-Screen: 8-chan-dung-theo-cach-ban-nhin`, kèm
lệnh render chạy lại được nguyên văn. Cổng
`.agent-contract/design-fidelity-spec.md` §"Force gate" (dòng 702–714) đòi báo
cáo + ít nhất một `implemented-*.png` + một `design-reference-*.png` khi có
`design_source`: cả ba đều có, đều là PNG thật, kích thước phi-tầm-thường.

Về verdict `PASS` khi vẫn liệt kê 6 lệch: spec dòng 671–674 nói "any visible
discrepancy is FAIL". Tôi chấp nhận `PASS` ở đây vì cả sáu khoản đều là loại
**AC-governed** — luật design-anchor của REQ-016 cho canvas thắng `uiux-spec`
nhưng không cho thắng một AC, nên đây là lệch cố ý có viện dẫn AC id, đúng dạng
"documented intentional divergence". Tôi đã đọc lại AC thật chứ không tin trích
dẫn: AC-26/AC-28 (cấm đo lường/tiến độ/huy hiệu), AC-25 (bỏ qua phải dễ với
ngang hành động đi tiếp), AC-34/AC-29/BR-15 (số câu và nhãn là dữ liệu của gói),
AC-35 (app không tự khẳng định về người ấy) — và ba ảnh runtime cho thấy bản
hiện thực làm đúng từng khoản. Khoản thứ bảy (chip trấn an) **không** AC-governed
và vì thế không được tự xử ở đây; nó đi xuống D-4.

Hai ảnh implemented tôi đã mở ra nhìn và chúng là ảnh thật, đúng màn của story
này: khung câu hỏi có `Câu 1/8`, nhãn xuất xứ "Dựa trên những gì bạn đã nhập.
App không biết người ấy…" dính đỉnh ở cả hai trạng thái; trang kết quả có ba khối
mỗi khối đóng bằng một dòng "Câu để hỏi"; không điểm số, không xếp hạng, không
phần trăm. Dấu tiếng Việt đủ và đúng, không ô tofu, icon ra glyph thật, không
khung lỗi/đỏ/loading. Tức phần capture là thật — chỉ thiếu vế so sánh.

**F-2 — `coding-plan/test-results.md` không có mục `## Entry Point Reachability`.** (owner: `mobile-dev`)
Luật 12e1 đòi mục này với `Reachable: YES` và đường đi cụ thể cho mọi story
UI-facing (`story_master.md` §System Integration ghi `UI-facing story: YES`).
Tôi đã tự kiểm chứng phía mã và nó **đạt**: `gift_ideas_screen.dart` `_GuessRow.onTap`
gọi `openYourViewPortrait(context, from: PortraitEntrySource.giftIdeas)`, thay
cho SnackBar "sắp có" đã gỡ; khoá `gift_ideas_guess_coming_soon` đã xoá khỏi cả
hai `.arb`. Cửa vào là một hàng bấm được có thật trong luồng (5), không phải
direct-URL. Đây là khoảng trống ghi chép, không phải khoảng trống hiện thực,
nhưng 12e1 xếp "missing evidence section" là `PATCH_REQUIRED` không khoan nhượng.

**Vá — đã xác minh (F-2 ĐÓNG).** `coding-plan/test-results.md` dòng 492–515 có
mục `## Entry Point Reachability` với `Reachable: YES` và bảng 5 bước, mỗi bước
có **hai cột bằng chứng**: vị trí mã tại HEAD và một ảnh runtime. Tôi kiểm phần
lượt 1 chưa soát — bước 1–2, tức đường từ `main()` tới màn (5) — bằng cách đọc
`mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart`:
`_openQuickEntryCell` ở dòng 232 gọi `openGiftIdeasScreen(context)` ở dòng 247
cho nhánh `QuickEntryCell.giftIdeas`, và `_EmptyPane` ở dòng 270–276 truyền
`onQuickEntryCellSelected` của `MinuteOneEmptyState` vào đúng hàm đó. Nên khẳng
định "strip ô nhanh có ở cả hai trạng thái hub, gồm Minute-1" là đúng, và số
dòng trong bảng khớp file thật.

Ba ảnh runtime cũng khớp từng bước: `runtime-smoke-main-first-screen` là màn (1)
`Muốn làm` đã vẽ xong với ba ô nhanh `Gợi ý quà` / `Mồi chuyện` / `Vỏ hoàng đạo`;
`runtime-smoke-gift-ideas-guess-row` là màn (5) cuộn tới đáy, thấy rõ hàng "Bí
quá thì thử đoán xem người ấy thích kiểu quà nào" có đĩa glyph `?` và chevron
`›`; `runtime-smoke-portrait-first-question` là màn chân dung ở `Câu 1/8`. Tức
chuỗi đi được xác nhận ở runtime, không chỉ suy từ mã.

**F-3 — Thiếu `## Story Runtime Startup Smoke`.** (owner: `mobile-dev`)
Luật 12g bắt buộc cổng vận hành này cho mọi story `standard` lane `mobile`, trừ
khi `story_master.md` ghi `Runtime-Smoke: WAIVED — <lý do>`; story master không
có dòng đó. `flutter build apk --debug` xanh chứng minh **dựng được**, không
chứng minh **chạy được**: cần bằng chứng app khởi động trên thiết bị đã cấp và
tới được màn đầu tiên, không crash, không khung lỗi. Story này bump
`schemaVersion` 6→7 với `onUpgrade` tạo bảng mới, nên khởi động thật là thứ duy
nhất chứng minh đường nâng cấp không làm chết app lúc mở.

**Vá — đã xác minh (F-3 ĐÓNG).** `coding-plan/test-results.md` dòng 517–611 có
mục `## Story Runtime Startup Smoke`, `Status: PASS`, chạy trên `main()` đã ship
(không phải `main_preview.dart`), thiết bị `emulator-5554`, lệnh ghi lại đầy đủ
để chạy lại. Các tín hiệu đều là loại đo được, không phải lời khẳng định:
`am start -W` cho `Status: ok` / `LaunchState: COLD` / `TotalTime: 3087`; readiness
lấy từ `dumpsys activity activities` chứ không phải "chờ vài giây rồi coi như
xong"; `adb logcat -d -s AndroidRuntime:E flutter:E` rỗng. Ảnh màn đầu tôi mở ra
nhìn: đúng màn (1) đã vẽ xong, có tiêu đề, hai thẻ hành động, ba ô nhanh và
thanh điều hướng 4 mục — **không phải khung splash**, và tác giả còn tự ghi rằng
ảnh chụp ở giây thứ 8 vẫn là splash nên đã chờ chụp lại. Dấu tiếng Việt đủ ở mọi
nhãn của cả ba ảnh, không ô tofu, icon ra glyph thật.

Phần schema chạy thật là mức bằng chứng cao hơn tôi đòi ở lượt 1: DB trên thiết
bị được kéo về đọc bằng `sqlite3`, `PRAGMA user_version` = `7`, `portrait_answers`
có trong `sqlite_master`, và trả lời câu 1 trên máy ghi đúng 1 dòng. Tác giả tự
ghi **giới hạn** thay vì nói quá: thiết bị chưa từng có DB nên đường chạy thật là
`onCreate` thẳng lên v7, không phải `onUpgrade` 6→7; nhánh `onUpgrade` vẫn chỉ có
bằng chứng ở mức test. Tôi chấp nhận điều đó cho cổng 12g — cổng này đòi app khởi
động được và tới màn đầu không crash, và điều đó đã được chứng minh. Bằng chứng
`onUpgrade` trên thiết bị đòi một bản dựng trước story, chỉ dựng được từ nhánh
tích hợp; chuyển thành D-5 cho cổng requirement integration review.

## Deferred Findings

- **D-1** — 3 issue `info • prefer_initializing_formals` mới (228 vs nền 225, 0 lỗi).
  Lint này không vá được cho tham số có tên (`this._x` là lỗi cú pháp Dart) và
  `ContextNotebookRepository` đã ship cùng khuôn. Không chặn.
- **D-2** — `PortraitAnswerRepository` không đăng ký vào `service_locator.dart`;
  cửa vào tự dựng nó. Chấp nhận được khi chỉ có một người dùng; nếu STORY-008 thêm
  cửa thứ hai thì nên gom lại lúc đó.
- **D-3** — Hai ảnh `visual-fidelity/*.png` do tiến trình test ghi, nằm ngoài
  `WriteScope` của phase P4. Đã vào commit `dc190a49`, worktree sạch. Ghi lại để
  lần sau `WriteScope` cấp sẵn thư mục `visual-fidelity/`. Đã được chấp nhận ở
  vòng trước; không nâng lại thành chặn.
- **D-4 (mới, cần Product Owner)** — `DESIGN_DELTA_OPEN`: chip trấn an ở chân
  thẻ câu hỏi ("Chỉ hỏi sở thích và sự kiện. App không bao giờ hỏi … trả lời tin
  nhắn nhanh hay chậm") có trên canvas, không có trong bản hiện thực. Đây là
  khoản duy nhất **không** do AC chi phối, nên luật design-anchor để canvas
  thắng; nhưng lược đồ `portrait_questions.v1` không có trường nào chứa dòng
  trấn an ở cấp bộ câu hỏi, và BR-15/R-15a cấm chuỗi soạn sẵn nằm trong
  `.dart`/`.arb`. Vì thế ship nó là thay đổi gói nội dung **cộng** lược đồ, tức
  thay đổi phạm vi, không phải sửa widget. Không chặn story: mobile-dev đã nêu
  lên đúng chỗ thay vì tự phán quyết. Định tuyến: Product Owner quyết mở rộng
  lược đồ gói hay bỏ chip.
- **D-5 (mới, cho requirement integration review)** — `onUpgrade` 6→7 chưa có
  bằng chứng trên thiết bị; lần smoke chạy qua `onCreate` vì máy chưa từng có
  DB. Ở mức story không dựng được bằng chứng này. Cổng tích hợp nên cài một bản
  dựng trước STORY-009 để tạo DB v6 rồi cài đè và mở lại app.
- **D-6 (mới, cho requirement integration review — cross-story)** — STORY-009 và
  STORY-010 **đều** độc lập bump Drift `schemaVersion` 6→7 với các bảng mới khác
  nhau. Hai nhánh gộp vào nhánh tích hợp sẽ cho hai định nghĩa v7 xung đột, và
  máy nào đã ở v7 sẽ không chạy nhánh migration của story còn lại — triệu chứng
  điển hình là màn hình trắng, không exception. Không phải lỗi cục bộ của
  STORY-009 và không chặn review này; phải xử ở lúc gộp (một story lên v7, story
  kia lên v8, kèm test migration bắc cầu).
- **D-7 (mới, cho Scrum Master/Product Owner)** — `story_master.md` không có dòng
  `Design-Screen: 8-chan-dung-theo-cach-ban-nhin`. Không chặn:
  `.agent-contract/design-fidelity-spec.md` dòng 757–761 cho phép implementer tự
  phân giải id khi thiếu dòng đó, miễn là liệt kê id thật, render rồi xác nhận
  bằng mắt — mobile-dev đã làm đúng quy trình đó và ghi id vào đầu
  `visual-fidelity-report.md`. Chỉ cần chép dòng đó sang `story_master.md`
  (ngoài `WriteScope` của cả mobile-dev lẫn reviewer).

## Traceability

- AC-1/AC-3/AC-4 (story): xác nhận trực tiếp trên hai ảnh implemented (nhãn xuất
  xứ ở đầu và dính khi cuộn; mỗi phần đóng bằng câu để hỏi; không điểm/xếp hạng/%).
- AC-2 (SC-6/R-13): `portrait_location_lock_test.dart` quét tĩnh `lib/`, phân giải
  URI nhập thật thay vì so khớp chuỗi — đã chứng minh bắt được vi phạm cố ý.
  `your_view_portrait_entry_point.dart` không có `routeName`, không `export`,
  không `rootNavigator`.
- AC-5: `recordAnsweredQuestion(...)` chạy thật trên DB trong bộ nhớ, đọc lại bằng
  `contextNotebookReader()`; `portrait.guess` bị chặn ở mức kiểu.
- AC-6: `resolveResumeQuestionId` là hàm thuần, không cột nào mang nghĩa tiến độ.
- OQ discipline: OQ-3 đã ĐÓNG 2026-09-06 bằng D-15 → R-15; story requirements có
  `## Open Question Impact` với triage rõ. Không có phạm vi bị chặn nào bị hiện
  thực, không có AC không-bị-chặn nào bị bỏ. Không phát hiện vi phạm.

## Patch Round Traceability

| Phát hiện lượt 1 | Artifact vá | Tôi xác minh bằng | Trạng thái |
| --- | --- | --- | --- |
| F-1 design fidelity | `visual-fidelity/design-reference-8-chan-dung-theo-cach-ban-nhin-ios.png`, `visual-fidelity/visual-fidelity-report.md` | mở ảnh reference ra nhìn, đối chiếu từng khoản `DESIGN_SPEC_CONFLICT` với ảnh; đọc lại AC-25/26/28/29/34/35, BR-15/16 | ĐÓNG |
| F-2 entry point reachability | `coding-plan/test-results.md` dòng 492–515 + 3 ảnh runtime | đọc `activity_card_hub_view.dart:232/247/270-276`, đối chiếu số dòng và nhánh Minute-1; mở cả ba ảnh runtime | ĐÓNG |
| F-3 runtime startup smoke | `coding-plan/test-results.md` dòng 517–611 + `runtime-smoke-main-first-screen-emulator-5554.png` | đọc tín hiệu `am start -W`/`dumpsys`/`logcat`/`sqlite3`, mở ảnh màn đầu xác nhận không phải splash | ĐÓNG |
| Phụ: không chạm mã sản phẩm | diff `dc190a49..d860557e` | `git diff --stat`: 13 file, 0 file dưới `mobile/lib` hay `mobile/test` → mọi kết quả test §P1–§P5 còn hiệu lực | XÁC NHẬN |
| Phụ: trạng thái phase | `master-plan.md` + 5 file phase | `COMPLETE` → `DONE` ở cả bảng master-plan lẫn từng file phase, đúng enum cổng test chấp nhận | XÁC NHẬN |

## Recommendation

- Story status: đủ điều kiện cho Scrum Master đưa sang `DONE` theo cổng review
  (`DEFERRED_ONLY`), sau khi chạy các bước Git boundary/merge thường lệ.
- Tick được `Implementation (Development)` và `Review (Reviewer)`.
- Không có finding nào đòi sửa mã sản phẩm, ở cả hai lượt.
- Trước khi gộp, cần xử lý riêng **D-6** (đụng độ `schemaVersion` v7 với
  STORY-010) ở cổng requirement integration review — đây là rủi ro gộp thật, chỉ
  là không thuộc phạm vi story này. **D-4** cần một phán quyết của Product Owner;
  **D-7** là một dòng Scrum Master chép sang `story_master.md`.
