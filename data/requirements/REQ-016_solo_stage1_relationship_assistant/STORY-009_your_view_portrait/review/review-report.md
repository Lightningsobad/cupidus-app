# Review Report: STORY-009 Chân dung "theo cách BẠN nhìn"

- Review type: `compact-story-review`
- Story: `STORY-009_your_view_portrait` (REQ-016), Complexity `standard`, Lane `mobile-only`
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-009_your_view_portrait`
- Diff baseline: `b58afbe0` → worktree HEAD `dc190a49` (54 file, +7542/-47)
- Reviewed: 2026-09-17

Outcome: PATCH_REQUIRED

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

## Touched Risk Surfaces → Critical Gates

| Risk surface | Bằng chứng | Cổng |
|---|---|---|
| Persistence/schema/migration (`portrait_answers`, drift `schemaVersion` 6→7) | P2 lệnh 2/4/6: `build_runner` sạch, `test/core/database` +82 xanh gồm `migration_v5_test`, 9 file assertion `schemaVersion` đều chạy | PASS |
| Local storage/offline (DAO + repository, con trỏ suy ra) | P2 lệnh 3: `portrait_answer_repository_test.dart` +28 xanh | PASS |
| Typed/generated contract (`cupid_database.g.dart`, gói nội dung có schema + id bền, R-15a) | P1 cổng nhập chạy được; P2 `git status` sạch sau `build_runner` | PASS |
| Mobile interaction (màn chân dung, 8 câu, trang kết quả) | P4: 13 xanh + 2 test ảnh; 207 xanh khi chạy cùng `context_notebook` | PASS |
| Mobile navigation/discoverability (khoá vị trí SC-6/R-13) | P5: `portrait_location_lock_test.dart` 4 xanh, có bằng chứng bắt vi phạm thật bằng file dò `_probe_violation.dart`; `your_view_portrait_entry_point_test.dart` 2 xanh; 225 xanh gộp `gift_ideas` | PASS (mã), FAIL (mục bằng chứng — F-2) |
| Mobile build / static analysis | `flutter build apk --debug` xanh; `flutter analyze lib test` 228 issue / **0 lỗi** (nền 225/0) | PASS |
| UI design fidelity (12e2/12e3/12g2) | chỉ có hai `implemented-*.png` | **FAIL — F-1** |
| App lifecycle / runtime startup smoke (12g) | không có | **FAIL — F-3** |

Configuration/setup: story không chạm env, script hạ tầng, registry entry hay
Docker/Compose — `configuration-guide.md` không thuộc phạm vi story này.

## Blocking Findings

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

**F-3 — Thiếu `## Story Runtime Startup Smoke`.** (owner: `mobile-dev`)
Luật 12g bắt buộc cổng vận hành này cho mọi story `standard` lane `mobile`, trừ
khi `story_master.md` ghi `Runtime-Smoke: WAIVED — <lý do>`; story master không
có dòng đó. `flutter build apk --debug` xanh chứng minh **dựng được**, không
chứng minh **chạy được**: cần bằng chứng app khởi động trên thiết bị đã cấp và
tới được màn đầu tiên, không crash, không khung lỗi. Story này bump
`schemaVersion` 6→7 với `onUpgrade` tạo bảng mới, nên khởi động thật là thứ duy
nhất chứng minh đường nâng cấp không làm chết app lúc mở.

## Deferred Findings

- **D-1** — 3 issue `info • prefer_initializing_formals` mới (228 vs nền 225, 0 lỗi).
  Lint này không vá được cho tham số có tên (`this._x` là lỗi cú pháp Dart) và
  `ContextNotebookRepository` đã ship cùng khuôn. Không chặn.
- **D-2** — `PortraitAnswerRepository` không đăng ký vào `service_locator.dart`;
  cửa vào tự dựng nó. Chấp nhận được khi chỉ có một người dùng; nếu STORY-008 thêm
  cửa thứ hai thì nên gom lại lúc đó.
- **D-3** — Hai ảnh `visual-fidelity/*.png` do tiến trình test ghi, nằm ngoài
  `WriteScope` của phase P4. Đã vào commit `dc190a49`, worktree sạch. Ghi lại để
  lần sau `WriteScope` cấp sẵn thư mục `visual-fidelity/`.

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

## Recommendation

- Story status: `IN_PROGRESS` — trả về lane Mobile với F-1, F-2, F-3.
- Bỏ tick `Implementation (Development)`; để trống `Review (Reviewer)`.
- Không có finding nào đòi sửa mã sản phẩm. Ba khoản đều là bằng chứng cổng: render
  design reference + viết `visual-fidelity-report.md`, thêm mục
  `## Entry Point Reachability`, chạy và ghi `## Story Runtime Startup Smoke`.
