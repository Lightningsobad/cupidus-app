# Review Scope Gate: REQ-017_checkin_notebook_capture — Ghi vào sổ tay từ màn check-in 23h

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `requirement-integration-review`
- Review report path: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-017_checkin_notebook_capture/data/requirements/REQ-017_checkin_notebook_capture/integration-review/review-report.md`
- Scope gate path: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-017_checkin_notebook_capture/data/requirements/REQ-017_checkin_notebook_capture/integration-review/scope-gate.md`

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget or why it must stop: requirement có đúng MỘT story
  (`STORY-001_checkin_notebook_capture`) đã qua story review với verdict `DEFERRED_ONLY` và đã merge.
  `git -C <Worktree> diff dd46d89d254b49b983d331b3ace3db38e211fe2a HEAD` rỗng, nên cây merge trùng
  khít cây story branch: không có bề mặt cross-story nào để đối chiếu lại. Phạm vi thu về ba câu hỏi
  cấp requirement — merge có nhập trọn vẹn không, artifact cấp requirement (build/runtime, visual
  audit, configuration guide) có đủ không, và luồng end-to-end check-in → sổ tay có còn nguyên sau
  merge không. Không mở lại AC nào đã PASS ở story review (rule 16a).
- Current story or bug status: `req_master.md` `Status: IN_PROGRESS`; bảng `## User Stories` ghi
  STORY-001 `Status: TODO` (lệch với `story_master.md` `Status: IN_PROGRESS` và với story review đã
  đóng — ghi nhận là finding artifact, không phải defect code; Scrum Master sở hữu cập nhật, rule 17).

## Governing Inputs

- Primary artifacts: `data/requirements/REQ-017_checkin_notebook_capture/req_master.md`;
  `.../STORY-001_checkin_notebook_capture/story_master.md`
- Existing review findings: `.../STORY-001_checkin_notebook_capture/review/review-report.md`
  (verdict `DEFERRED_ONLY`, mục `## Traceability`, `## Risk surfaces và critical gates`,
  `## Xử lý toàn bộ carry-forward`, `## Completion/Resume Closure`, `## Khuyến nghị trạng thái`)
- Test evidence: `.../STORY-001_checkin_notebook_capture/coding-plan/test-results.md` — chỉ ba mục
  `## Entry Point Reachability` (:788-856), `## Story Runtime Startup Smoke` (:858-914),
  `AC-5 — Deviation đã khai báo` (:916-931)
- Extra artifacts required beyond the default minimum: tiền lệ gate cấp requirement của REQ-016 —
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/integration-review/review-report.md`
  (chỉ các dòng khớp `Integration Build & Runtime`) và sự tồn tại của
  `REQ-016.../integration-review/mobile-visual-audit.md`, để xác lập hình dạng bằng chứng mà rule
  12g2/12g3 đòi ở lần đóng requirement trước, thay vì tự diễn giải luật.

## Source/Test Files In Scope

- `mobile/lib/core/database/cupid_database.dart` (chỉ `schemaVersion` + bước migration mới)
- `mobile/lib/core/database/tables/context_notebook_tables.dart` (chỉ cột mới)
- `mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart` (chỉ đối chiếu identity với
  `main` @ `70ddb8b8` — file này là giao điểm với BUG-20260927-001)
- `mobile/lib/features/context_notebook/domain/context_content_gate.dart` (chỉ đường quét pack)
- `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart` (chỉ :369-380, điểm mount)
- `mobile/lib/features/context_notebook/context_notebook_entry_point.dart` (chỉ :85-90)
- `mobile/pubspec.yaml` (chỉ hunk assets/dependency)
- Không mở `mobile/test/**`: bằng chứng test cấp story đã được story review chốt PASS; phạm vi này
  chỉ cần biết suite nào là cửa cho bề mặt rủi ro, không cần đọc lại assertion.

## Evidence Files In Scope

- `data/requirements/REQ-017_checkin_notebook_capture/req_master.md` (`## Configuration Documentation`,
  `## Deployment Status`, `## User Stories`; đã xác nhận KHÔNG có dòng `Integration-Verify:`)
- `.../STORY-001_checkin_notebook_capture/review/review-report.md`
- `.../STORY-001_checkin_notebook_capture/coding-plan/test-results.md` (ba mục nêu trên)
- `.../STORY-001_checkin_notebook_capture/visual-fidelity/visual-fidelity-report.md` (chỉ dòng verdict)
- Git: merge commit `a15bde4fb6a5d4e8de67410a1f0fd4b2b00612b7`; BaseHead
  `0198e32ddd3f8bad6a4d5274fd7b5ebeae9158b1`; story tip `dd46d89d`; `main` tip `70ddb8b8`
- KHÔNG có trong cây: `integration-review/build-runtime-evidence.md`,
  `integration-review/mobile-visual-audit.md`

## Risk Surfaces And Critical Gates

- Touched risk surfaces: persistence/schema/migration (drift `schemaVersion` 10 → 11);
  typed/generated contract (`cupid_database.g.dart`); local storage/offline content (pack
  `mobile/assets/data/req017/checkin_capture.v1.json` + cổng nội dung); mobile interaction; mobile
  navigation/discoverability; app lifecycle (khởi động sau nâng schema trên máy đã có dữ liệu);
  runtime/configuration (`pubspec.yaml`)
- Source-of-truth artifacts or contracts: `req_master.md` (BR/R kế thừa REQ-016: R-1f, SC-3, R-7,
  R-15, BR-12); `story_master.md` AC-1..AC-17; story `review/review-report.md`
- Critical gates to verify:
  1. merge nhập trọn vẹn: cây merge ⊇ `main` tip, không mất nội dung, không divergence trên file mà
     cả hai nhánh cùng chạm (rule 16a)
  2. `## Integration Build & Runtime` với CẢ `- Build: PASS — …` và `- Runtime/Smoke: PASS — …` trong
     cùng một file dưới `integration-review/` (rule 12g3)
  3. `integration-review/mobile-visual-audit.md` cấp requirement (rule 12g2)
  4. configuration guide: cần hay không, theo phạm vi đã đổi (rule 12a)
  5. luồng end-to-end cấp requirement còn nguyên sau merge: check-in modal → mục sổ tay → nhãn xuất xứ
  6. schema/migration cộng thêm và tuần tự, không xung đột `schemaVersion` với nhánh khác
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` (requirement không có lane frontend/web;
  `Implementation Lane: shared` nhưng thực tế mobile-only, không có bề mặt web nào thay đổi)
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `REQUIRED when requirement had mobile participation` —
  REQUIRED ở đây, và KHÔNG tồn tại trong cây
- Missing gate evidence or blocker: hai gate cấp requirement thiếu — `## Integration Build & Runtime`
  (rule 12g3) và `mobile-visual-audit.md` (rule 12g2). Cả hai là bằng chứng phải sinh ra bởi lane
  thực thi (devops/mobile-dev) trên nhánh đã merge, không phải thứ Reviewer được tự viết: gate 2 cần
  một lần build thật + một lần khởi chạy thật, gate 3 cần chụp trên thiết bị/emulator mà rule 12e3
  nói rõ không thuộc Reviewer. Do đó Phase 2 vẫn chạy để chốt các gate còn lại, nhưng outcome cuối
  là `PATCH_REQUIRED`, không phải `BLOCKED` (rule 12c: lane vẫn cấp được bằng chứng).

## Query Keys

- `schemaVersion`, `from < 11`, `beforeOpen`, `onUpgrade` trong `cupid_database.dart`
- `originKind`, `originLabel`, `originCardId`, `question_id` trong `context_notebook_tables.dart`
- `assets/data/req017/` trong `pubspec.yaml`
- `validateContextPacks`, `checkin_capture` trong `context_content_gate.dart`
- `CheckinCaptureBlock` trong `evening_check_in_sheet.dart` (:369-380)
- `openNotebookScreen` trong `context_notebook_entry_point.dart` (:85-90)
- `Reachable: YES`, `## Story Runtime Startup Smoke`, `AC-5 — Deviation đã khai báo` trong
  `test-results.md`
- `VISUAL_FIDELITY:` trong `visual-fidelity/visual-fidelity-report.md`
- `Integration-Verify`, `Configuration Documentation` trong `req_master.md`
- `Integration Build & Runtime` trong `REQ-016.../integration-review/review-report.md`
- Git: `diff dd46d89d..HEAD` (phải rỗng), `diff 70ddb8b8..HEAD --name-status`,
  `merge-base --is-ancestor 70ddb8b8 HEAD`

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: N/A — Phase 2 được chấp thuận
- If `NO`, exact blocker or re-scope instruction: N/A

## Reviewer Notes On Non-Rerun Decisions

- KHÔNG chạy lại `flutter build` / `flutter test` trong worktree integration. Rule 18 nói chỉ chạy
  lại khi bằng chứng thiếu, cũ, hay mâu thuẫn. Bằng chứng build/test cấp story còn đúng cho cây này
  (diff với story tip rỗng), nên một lần chạy lại của Reviewer không mua thêm sự thật nào — và nó
  KHÔNG thay được gate 12g3, vì gate đó đòi bằng chứng build + khởi chạy trên nhánh merge do lane
  thực thi sinh ra, đúng như REQ-016 đã làm bằng `build-runtime-evidence.md`. Reviewer tự viết hai
  dòng `Build: PASS` / `Runtime/Smoke: PASS` dựa trên lập luận "cây trùng khít" sẽ là tự sản xuất
  bằng chứng cho gate mình đang canh; báo cáo này không làm thế.
