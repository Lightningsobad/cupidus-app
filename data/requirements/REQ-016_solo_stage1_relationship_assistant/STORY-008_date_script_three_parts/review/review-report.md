# Review Report — STORY-008 Kịch bản buổi hẹn 3 phần

- Review type: `compact-story-review`
- Story: `STORY-008_date_script_three_parts` (REQ-016), Complexity `standard`, Lane `mobile`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-008_date_script_three_parts`
- Diff baseline: `b58afbe073eff4e1ebb9151735221532a9cf5a82` → `6818d2a2` (P1→P4 COMPLETE)
- Reviewed: 2026-09-17

Outcome: BLOCKED

## Scope Gate

- Report path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-008_date_script_three_parts/review/review-report.md`
- Source/test files in scope (7): `mobile/lib/features/date_script/date_script_entry_point.dart`,
  `mobile/lib/features/date_script/domain/date_script_content_gate.dart`,
  `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart`,
  `mobile/lib/features/activity_cards/presentation/widgets/quick_capture_sheet.dart`,
  `mobile/lib/features/activity_cards/domain/activity_card.dart`,
  `mobile/test/features/date_script/visual-fidelity/implemented-screen-9-kich-ban-buoi-hen-truoc.png`,
  `mobile/test/features/date_script/visual-fidelity/implemented-screen-9-ba-cua-ra.png`
- Evidence files in scope: `coding-plan/test-results.md` (ranged reads: P3 §184-282, P4 §283-393),
  `story_master.md`, `data/devops/system/design-fidelity-config.json`
- Query keys: `Reachable`, `VISUAL_FIDELITY`, `Design-Screen`, `Runtime`/`smoke`, `R-1g`,
  `ActivityCardOrigin`, `openDateScriptScreen`
- Touched risk surfaces: mobile interaction · mobile navigation/discoverability ·
  local storage (enum wire value trên cột chuỗi) · typed contract (`ActivityCardOrigin`)
- Phase 2 verdict: proceed, then stop at the visual-fidelity critical gate.

## Outcome Rationale

Phần code đã cài đặt đọc rất tốt và bám sát AC: điểm vào khoá vị trí là thật,
cổng nội dung R-1g là thật, ba cửa ra là thật, và các test có negative control
chống-rỗng đúng nghĩa. Nhưng story là UI-bearing trên lane `mobile` với
`design_source` đã CHỐT và `ui_surface: true`, mà **toàn bộ gói bằng chứng
design-fidelity theo hợp đồng không tồn tại**, và nguyên nhân gốc — visual
runtime chưa cài — nằm ngoài quyền của lane này. Theo quy tắc reviewer 12c,
một critical gate bị chặn bởi môi trường/phụ thuộc là `BLOCKED`, không phải
`DEFERRED_ONLY`.

## Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Verdict |
|---|---|---|
| Mobile interaction (màn 9, 3 phần) | Widget test có mục tiêu | PASS — `date_script_screen_test.dart` (9 test), `flutter test test/features/date_script/` → `+124 ~2` |
| Mobile navigation/discoverability | Điểm vào có thật + mục `## Entry Point Reachability` | **FAIL** — code đạt, mục bằng chứng KHÔNG tồn tại (F-2) |
| UI-bearing design fidelity | `<story>/visual-fidelity/` + `design-reference-*` + `visual-fidelity-report.md` + `VISUAL_FIDELITY: PASS` | **BLOCKED** — không có gì trong số đó (F-1) |
| Mobile runtime startup smoke (12g) | `## Story Runtime Startup Smoke` hoặc `Runtime-Smoke: WAIVED` | **FAIL** — không có mục nào; `story_master.md` không ghi waiver (F-3) |
| Typed contract / local storage | Round-trip enum + hồi quy | PASS — `activity_card_test.dart` viết tay 4 wire value cũ; `flutter test test/features/date_script/ test/features/activity_cards/` → `+344 ~4` |
| Static analysis | `flutter analyze` phạm vi story | PASS — 0 error, 0 warning (10-11 `info • prefer_initializing_formals`, phần lớn có sẵn) |

## Blocking Findings

**F-1 (BLOCKER, môi trường) — Không có bằng chứng design-fidelity nào cho một
story UI-bearing có design source đã chốt.**
`data/devops/system/design-fidelity-config.json` khai báo `ui_surface: true` và
một `design_source` `claude-design` đã `locked` (`Cupid App.dc.html`, surface
`mobile`), nên gate 12e2/12e3 áp dụng nguyên vẹn. Thực tế:
- Thư mục `data/requirements/.../STORY-008_date_script_three_parts/visual-fidelity/`
  **không tồn tại**. Bốn ảnh chụp nằm ở `mobile/test/features/date_script/visual-fidelity/`.
- **Không có** `design-reference-<screen>-<device>.png` nào.
- **Không có** `visual-fidelity-report.md`, nên không có dòng `VISUAL_FIDELITY:`
  và không có `Design-Screen:` được ghi ở nơi hợp đồng đọc (id `s1:datescript`
  chỉ nằm trong deviation 9 của `test-results.md`).

Nguyên nhân gốc do lane khai báo và tôi đã kiểm chứng độc lập:
`.ai-team-bundle/runtime/tools/render-design-canvas.js` có tồn tại trong
control checkout nhưng **không có `node_modules`** dưới `.ai-team-bundle/runtime`
— đúng với `VISUAL_RUNTIME_MISSING` (exit 3) mà P4 ghi lại. Provisioning runtime
không thuộc Mobile Developer, nên đây là blocker môi trường chứ không phải lỗi
hiện thực. So sánh: STORY-001..004 cùng requirement đều có
`<story>/visual-fidelity/design-reference-*.png` + `visual-fidelity-report.md`,
xác nhận đây là mức bằng chứng chuẩn của REQ-016 chứ không phải yêu cầu mới.

Tôi đã tự mở hai ảnh chụp thật (rule 12e3: đọc ảnh, không tin token): cả hai là
màn (9) thật của bản dựng — tiêu đề "Kịch bản buổi hẹn", pill 3 phần
Trước/Trong/Sau, đoạn văn mad-libs có dữ liệu thật, và ở ảnh `ba-cua-ra` có đủ
ba pill viền "Xuất lời mời" / "Tạo thẻ mới" / "Ghi vào nhật ký" dính đáy. Dấu
tiếng Việt đủ nét, không ô tofu, không màn lỗi, không spinner. Ảnh chụp là
**hợp lệ**; cái thiếu là phía đối chiếu.

**F-2 (PATCH) — Thiếu mục `## Entry Point Reachability` trong `test-results.md`.**
Rule 12e1 bắt buộc mục này với `Reachable: YES` + đường đi cụ thể; grep toàn file
không có chuỗi `Reachab` nào. Tôi đã **tự xác minh trong code** và điểm vào là
thật: `prepare_actions_sheet.dart` thêm hàng thứ hai `prepare_action_date_script`
chỉ khi `card.status == ActivityCardStatus.scheduled`, gọi
`openDateScriptScreen(context, card)` từ `date_script_entry_point.dart` (route ẩn
danh, `card` là positional bắt buộc). Không phải direct-URL-only. Đây là khoảng
trống **bằng chứng**, không phải khoảng trống hiện thực — nhưng mục này
non-waivable nên vẫn phải bổ sung.

**F-3 (PATCH) — Thiếu gate runtime startup smoke của story (12g).**
Lane `mobile`, story `standard` → smoke "app khởi động tới màn đầu tiên không
crash" là bắt buộc trừ khi `story_master.md` ghi `Runtime-Smoke: WAIVED — <lý do>`;
`story_master.md` không có dòng đó. `test-results.md` ghi `Startup smoke
NOT_APPLICABLE` ở cả P1..P4 với lý do "không đăng ký route, không đổi đường khởi
động, không đụng schema" — đó là lập luận cho một **WAIVED do Scrum Master/PO
chốt**, không phải một pass. Tiền lệ trong cùng requirement tồn tại:
`STORY-003_private_journal/visual-fidelity/runtime-smoke-main-first-screen-emulator-5554.png`.

## Deferred Findings

- **D-1 — Pill "Ghi vào nhật ký" sát mép phải ở khung 415dp.** Trong ảnh
  `implemented-screen-9-ba-cua-ra.png`, viền phải của pill thứ ba nằm đúng mép
  khung. Test chỉ assert `rect.bottom <= view.height`, không assert biên ngang.
  Không chặn được vì không có `design-reference` để đối chiếu — cần kiểm lại
  ngay khi F-1 mở khoá, và cân nhắc thêm assert `rect.right <= view.width`.
- **D-2 — AC-35 (con trỏ xoay preset) không hiện thực** (P3 deviation 1). AC ghi
  việc xoay là *có điều kiện* và `ux/uiux-spec.md` không định nghĩa affordance
  xoay nào trên màn (9); `cycleIndex` của P2 vẫn còn và có test. Chấp nhận hoãn.
- **D-3 — Snackbar "Đã tạo thẻ mới" thiếu hành động "Xem"** mà UX §3 mô tả
  (P4 deviation 6). Lý do nêu ra hợp lý (`contract-summary.md` §5 cấm màn (9) mở
  đường đi mới), nhưng đây là lệch so với UX spec — để chủ sở hữu màn (1) chốt.
- **D-4 — Nhóm chụp ảnh của STORY-002 không nấp sau cờ dart-define**, nên chạy
  hồi quy `test/features/invite_composer/` ghi đè PNG của story khác (P4
  deviation 10, đã `git checkout --` trả lại). Việc cần làm thuộc STORY-002.
- **D-5 — `mobile/ios/.../Package.resolved` đổi 2 dòng** do `flutter test` sinh
  ra, không phải sửa tay; đã nằm trong commit `6818d2a2`.

## Traceability

- Requirements: AC-2/SC-6 (khoá vị trí) — `date_script_location_lock_test.dart`
  part 1-3 quét toàn `lib/`, phủ mọi `ActivityCardStatus`; AC-3/SC-2 và AC-4 —
  `date_script_exits_test.dart`; AC-5/AC-23/AC-24/AC-25 — `date_script_screen_test.dart`;
  AC-6/J7 — assert vắng mặt timer/countdown/`bottomNavigationBar` + quét `Timer(`;
  AC-7/R-1g — `date_script_content_gate.dart:161` chặn câu `aboutPartner` không
  kết thúc bằng `?` (`partnerSentenceNotQuestion`).
- OQ: OQ-3 đã ĐÓNG 2026-09-06 bằng D-15/R-15. Kỷ luật OQ **đạt** — R-15a được
  giữ đúng (`ActivityCardOrigin.dateScript` nối thêm, 4 wire value cũ được test
  viết tay chứng minh vẫn decode), R-15b (N là thuộc tính dữ liệu) do selector
  P2 giữ, R-15c ở cổng nhập P1. Không có scope bị chặn nào bị làm, không có AC
  chưa-bị-chặn nào bị bỏ vì over-apply OQ.
- Architecture: `contract-summary.md` §1 (một contact surface duy nhất) đạt —
  `date_script_entry_point.dart` chỉ export `DateScriptScreen` +
  `dateScriptEntryPointId`. §5 có một lệch đã ghi nhận (P4 deviation 2: import
  thẳng `invite_composer_sheet.dart` vì `invite_composer` không có entry-point
  file, và chính phase file P4 chỉ đích danh `showInviteComposerSheet`) — chấp
  nhận được, không chặn.
- Configuration guide: không áp dụng — story không đổi env, không đổi setup,
  không đổi schema DB.

## Required Actions

1. `[owner: devops]` Cài lại visual runtime (`./install.sh` / cài phụ thuộc
   renderer) để `render-design-canvas.js` không còn thoát mã 3
   `VISUAL_RUNTIME_MISSING`. Đây là hành động mở khoá F-1.
2. `[owner: mobile-dev]` Sau khi (1) xong: render
   `design-reference-<screen>-ios.png` cho `Design-Screen: s1:datescript`, chuyển
   4 ảnh `implemented-*` sang
   `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-008_date_script_three_parts/visual-fidelity/`,
   và viết `visual-fidelity-report.md` có `VISUAL_FIDELITY: PASS|FAIL`,
   `Design-Screen: s1:datescript`, verdict theo từng device/state kèm delta cụ thể.
   Kiểm luôn D-1 ở bước này.
3. `[owner: scrum-master]` Mở rộng WriteScope của handoff mobile-dev để bao gồm
   thư mục `visual-fidelity/` của story — đây chính là lý do lane đã ghi ảnh vào
   `mobile/test/` (P3 deviation 2, P4 deviation 8).
4. `[owner: mobile-dev]` Thêm mục `## Entry Point Reachability` vào
   `coding-plan/test-results.md` với `Reachable: YES` và đường đi:
   màn (1) → chi tiết thẻ *Đã hẹn ngày* → "Chuẩn bị" → hàng "Kịch bản buổi hẹn".
5. `[owner: mobile-dev hoặc devops]` Chạy story runtime startup smoke trên
   device/emulator và ghi `## Story Runtime Startup Smoke`; HOẶC
   `[owner: scrum-master]` ghi `Runtime-Smoke: WAIVED — <lý do>` vào
   `story_master.md` nếu quyết định đây là miễn trừ có chủ đích.

## State Recommendation

- `Implementation (Development)`: giữ **chưa tick**.
- `Review (Reviewer)`: giữ **chưa tick**.
- Story status: **BLOCKED** cho tới khi hành động (1) được thực hiện; sau đó
  route lại Mobile Developer cho (2), (4), (5) rồi re-review.
- Scrum Master sở hữu mọi cập nhật trạng thái; báo cáo này không sửa file nào khác.
