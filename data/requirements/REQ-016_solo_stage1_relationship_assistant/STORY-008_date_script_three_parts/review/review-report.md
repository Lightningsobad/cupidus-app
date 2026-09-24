# Review Report — STORY-008 Kịch bản buổi hẹn 3 phần

- Review type: `compact-story-review`
- Story: `STORY-008_date_script_three_parts` (REQ-016), Complexity `standard`, Lane `mobile`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-008_date_script_three_parts`
- Diff baseline: `b58afbe073eff4e1ebb9151735221532a9cf5a82` → `6818d2a2` (P1→P4 COMPLETE)
- Reviewed: 2026-09-17

Outcome lượt 1 (2026-09-17, đã được thay thế bởi lượt 2 ở cuối file): BLOCKED

Kết luận có hiệu lực của story nằm ở dòng `Outcome:` duy nhất trong mục
`## Rework Re-Review 2026-09-24`. Thân báo cáo lượt 1 bên dưới giữ nguyên làm
dấu vết kiểm toán.

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

---

# Rework Re-Review 2026-09-24

- Review type: `compact-story-review` (re-review khắc phục, không review lại P1-P4)
- Diff baseline: `58ff2e56` (commit của lượt 1) → `dcacbc56`, 2 commit khắc phục
- Không tái kiểm: Traceability, kỷ luật OQ, D-2..D-5 — giữ nguyên kết luận lượt 1
- Worktree sạch (`git status --short` trống) tại thời điểm kiểm

Outcome: DEFERRED_ONLY

Ba finding chặn của lượt 1 (F-1, F-2, F-3) **đều đóng**, và D-1 cũng đóng. Lượt 2
để lại đúng **một** việc phải sửa: 4 ảnh `implemented-*` đặt tên sai quy ước nên
gói bằng chứng design-fidelity không ghép cặp được bằng máy (F-4). Đây là sửa cơ
học, đổi tên file, không đụng mã và không chụp lại ảnh.

Dòng `Outcome:` ngay trên là kết luận **có hiệu lực** của story. Lịch sử của nó:
lượt 3 (2026-09-24) xác minh **F-4 ĐÓNG** — xem `## Xác nhận F-4 (lượt 3,
2026-09-24)` — nhưng cùng lượt đó cổng `verify-story-visual-fidelity-gate.sh`
phát hiện **F-5**, một lỗi định dạng khác cùng họ với F-4 (nội dung đúng, máy
không đọc được) trong `story_master.md`, nên lượt 3 giữ `PATCH_REQUIRED`. Lượt 4
(2026-09-24) đã xác minh **F-5 ĐÓNG** sau khi Scrum Master sửa đúng đề xuất của
lượt 3, và vì thế nâng outcome lên `DEFERRED_ONLY` theo đúng điều kiện lượt 3 đã
ghi sẵn. Xem `## Xác nhận F-5 (lượt 4, 2026-09-24)`. Không còn finding chặn nào
mở. D-2..D-7 và N-1/N-2 vẫn treo, không chặn.

## Phạm vi thay đổi kể từ lượt 1

`git diff 58ff2e56 --name-status` trả đúng 8 mục, **không có mã sản phẩm nào**:
1 file thêm (`visual-fidelity/design-reference-9-kich-ban-buoi-hen-ios.png`),
4 file `R100` (4 ảnh `implemented-*` chuyển nguyên vẹn từ
`mobile/test/features/date_script/visual-fidelity/` sang thư mục
`visual-fidelity/` của story, thêm hậu tố `-ios`), 1 file thêm
(`visual-fidelity/visual-fidelity-report.md`), và 2 file sửa:
`coding-plan/test-results.md` (+159 dòng) cùng `story_master.md` (+6 dòng).

`story_master.md` là file duy nhất nằm ngoài danh sách dự kiến của handoff.
Nội dung thêm vào chỉ là header `Design-Screen: 9-kich-ban-buoi-hen` kèm ghi
chú bí danh — chính xác và đúng thứ cần để đóng F-1 — nhưng đây là artifact
trạng thái do Scrum Master sở hữu, nên xem N-1 bên dưới.

## F-1 — ĐÓNG

`visual-fidelity/visual-fidelity-report.md` tồn tại với `VISUAL_FIDELITY: PASS`
ở dòng 1 và `Design-Screen: 9-kich-ban-buoi-hen` ở dòng 2, khớp header vừa được
ghi vào `story_master.md`.

Việc phân giải id màn là **đúng**, và nó sửa một sai sót của chính lượt 1: lượt
1 đòi `design-reference` cho `s1:datescript`, nhưng id đó nằm trên canvas
`cupid-app` trong khi `req_master.md:13` neo `Design-Surface: cupid-ch-ng-1`.
Trên bề mặt đã neo, khung tương ứng là `9-kich-ban-buoi-hen`. Required Action 2
của lượt 1 (ghi `Design-Screen: s1:datescript`) do đó **sai** và bản khắc phục
đúng hơn yêu cầu; ghi nhận để tránh lặp lại ở STORY-009/010.

Bản tham chiếu là ảnh thật, không phải placeholder: PNG 415x900 RGBA, 174.7 KB,
đã tự mở xem. Nó dựng đúng những gì báo cáo mô tả (tiêu đề `Chuẩn bị buổi hẹn`,
khối `TRƯỚC · 3 VIỆC` 3 mục đánh số, 2 thẻ điều hướng màn (8)/(10), khu
`LÀM GÌ TIẾP` 3 ô đặc `Soạn lời rủ`/`Thêm điều mới`/`Ghi nhật ký`), nên 5 mục
`DESIGN_SPEC_CONFLICT` và 1 mục `DESIGN_ANCHOR_OPEN` trong báo cáo là mô tả
trung thực chứ không phải suy đoán. Verdict theo từng trạng thái có delta cụ
thể (lề 16dp vs 21dp, caption `menu_book` bắt buộc theo BR-3/AC-14), đạt yêu
cầu "verdict kèm delta" của F-1. Phán quyết AC-thắng-canvas cho nhãn ba cửa ra
khớp tiền lệ REQ-016 và không tự ý đổi mã theo canvas — đúng.

**D-1 — ĐÓNG, đã tự đo lại, không tái lập.** Quét pixel độc lập trên
`implemented-screen-9-ba-cua-ra-ios.png` (so nền theo cột, dải y 836..883):
nội dung hàng ba cửa ra trải x = 16..398 trong khung rộng 415 → lề trái 16px,
lề phải 16px, đối xứng; mọi cột x ≥ 399 trống hoàn toàn. Có đúng 3 pill, khoảng
hở tại x 135-143 và 263-271. Không có phần tử nào chạm hay bị cắt ở mép khung.
Cảm giác "sát mép" ở lượt 1 là do nhìn ảnh ở tỉ lệ nhỏ. Lệch thật duy nhất là
lề ngang 16dp (`CupidSpacing.md`) so với 21dp của canvas — hằng số token dùng
chung toàn app, không phải quyết định của màn (9); không sửa trong story này.

## F-2 — ĐÓNG, đã đối chiếu mã chứ không chỉ đọc lời kể

`coding-plan/test-results.md` có mục `## Entry Point Reachability` với
`Reachable: YES` và đường đi 5 bước. Hai mắt xích quan trọng nhất được kiểm
trực tiếp trên mã, khớp từng chi tiết:

- `prepare_actions_sheet.dart:135-145` — hàng `Key('prepare_action_date_script')`,
  nhãn `'Kịch bản buổi hẹn'`, icon `CupidIcons.menuBook`, nằm trong nhánh
  `if (card.status == ActivityCardStatus.scheduled)` và được `add` **sau** hàng
  "Xuất lời mời". Hàng **vắng mặt** thay vì bị làm mờ khi thẻ chưa hẹn ngày —
  đúng AC-2/SC-6, đúng như mục bằng chứng mô tả.
- `date_script_entry_point.dart:26` —
  `Future<void> openDateScriptScreen(BuildContext context, ActivityCard card)`,
  `card` là tham số vị trí bắt buộc, route dựng bằng `MaterialPageRoute` không
  `settings.name`. Khẳng định "không có ngữ cảnh thẻ thì không compile được"
  của mục bằng chứng là đúng về mặt cấu trúc, không phải chuyển hướng lúc chạy
  (AC-4/BR-1a).

## F-3 — ĐÓNG

`coding-plan/test-results.md` có mục `## Story Runtime Startup Smoke`, và phần
`Cập nhật 2026-09-24 (devops — lần chạy thật, thay thế BLOCKED ở trên)` ghi đủ
các trường bắt buộc: `Runtime Id: mobile-app`; `Registry:
data/devops/system/runtime-command-registry.json → runtimes.mobile-app`;
`Command` trích nguyên văn `readiness.command` (`am start -W -n
com.snapsofts.cupid/…MainActivity` + poll `dumpsys activity activities`);
`Ready Check` mô tả lần thử #1 thất bại vì hộp thoại `POST_NOTIFICATIONS`
chiếm resumed activity, xử lý bằng `pm grant` (thiết lập trạng thái thiết bị,
không sửa hành vi app) rồi lặp lại đúng lệnh → PASS; `Result: PASS`;
`Shutdown: PASS` (`am force-stop` + `pidof` exit 1, sau đó `adb emu kill`).
Hai trở ngại hạ tầng của lượt 1 (đĩa 1.1 GiB, shell emulator treo) được nêu là
đã hết kèm số đo. Việc ghi lại cả lần readiness thất bại thay vì chỉ lần đạt
làm bằng chứng này đáng tin hơn, không kém đi.

## F-4 — MỞ, phải sửa (owner: mobile-dev)

Bốn ảnh `implemented-*` đặt tên không ghép cặp được với bản tham chiếu, nên
`verify-story-visual-fidelity-gate.sh` chặn một review PASS trên story
UI-bearing với nguyên văn:

```
no screen has BOTH renders, so nothing was actually compared:
running-app renders exist for ['screen'] and design renders for ['9']
```

Gate lấy id màn là **token đứng trước dấu `-` đầu tiên sau tiền tố**:

| File hiện tại | Token gate đọc ra |
|---|---|
| `design-reference-9-kich-ban-buoi-hen-ios.png` | `9` |
| `implemented-screen-9-kich-ban-buoi-hen-truoc-ios.png` | `screen` |
| `implemented-screen-9-kich-ban-buoi-hen-trong-ios.png` | `screen` |
| `implemented-screen-9-kich-ban-buoi-hen-so-tay-trong-ios.png` | `screen` |
| `implemented-screen-9-ba-cua-ra-ios.png` | `screen` |

Chữ `screen-` thừa là di sản của tên file ở vị trí cũ trong `mobile/test/`; lúc
chuyển sang `visual-fidelity/` lượt khắc phục thêm hậu tố `-ios` nhưng giữ
nguyên nó, trong khi phía `design-reference` bắt buộc dùng dạng chuẩn
`design-reference-<id>-<platform>.png` (báo cáo visual-fidelity đã giải thích
đúng lý do không được dùng `--label`). Hai phía vì thế lệch nhau.

**Việc cần làm:** `git mv` 4 file bỏ chữ `screen-`, thành
`implemented-9-kich-ban-buoi-hen-truoc-ios.png`,
`implemented-9-kich-ban-buoi-hen-trong-ios.png`,
`implemented-9-kich-ban-buoi-hen-so-tay-trong-ios.png`,
`implemented-9-ba-cua-ra-ios.png`; rồi cập nhật cột "Bản cài đặt" trong bảng
`## Các màn được đối chiếu` của `visual-fidelity/visual-fidelity-report.md` và
mục `## Cách bốn ảnh cài đặt được tạo ra` cho khớp tên mới. Cân nhắc sửa luôn
`_visualEvidenceDir` ở D-6 trong cùng lượt để lần chụp sau sinh ra thẳng tên
đúng.

**Không chụp lại ảnh, không đụng mã sản phẩm.** Nội dung 4 ảnh đã được review
này mở xem tận mắt và xác nhận hợp lệ; chỉ tên file sai. Sau khi đổi tên, phần
kiểm F-1/D-1 ở trên giữ nguyên hiệu lực — đây là lý do outcome là
`PATCH_REQUIRED` chứ không phải `BLOCKED`: không có trở ngại môi trường hay phụ
thuộc nào, và không cần chạy lại thiết bị.

## Phát hiện mới (đều hoãn, không chặn)

- **D-6 — Harness chụp ảnh vẫn trỏ về thư mục cũ đã bị dọn.**
  `date_script_screen_test.dart:38` giữ
  `const String _visualEvidenceDir = 'test/features/date_script/visual-fidelity'`,
  trong khi 4 ảnh chính thức đã chuyển sang `visual-fidelity/` của story. Lần
  chạy `--dart-define=CAPTURE_VISUALS` tới sẽ `createSync(recursive: true)` tạo
  lại thư mục cũ và ghi ảnh ở đó, tách rời bản đã commit — hai nơi phân kỳ âm
  thầm. Không chặn: nhánh chụp nấp sau cờ dart-define nên gate test mặc định
  không chạm tới, và 4 ảnh đã chuyển là `R100` (nguyên vẹn từng byte). Nên sửa
  hằng số này khi STORY-009/010 đụng vào màn (9).
- **D-7 — Ảnh runtime smoke chỉ nằm ở `/tmp`.**
  `runtime-smoke-main-first-screen-emulator-5554.png` được ghi vào
  `/tmp/story008-smoke/` và không commit (lý do nêu: ngoài WriteScope lượt
  devops). Tiền lệ STORY-003 commit ảnh này vào `visual-fidelity/`. Các trường
  bắt buộc của mục smoke đều đã có dạng văn bản nên gate đóng được, nhưng bằng
  chứng ảnh sẽ biến mất khi `/tmp` bị dọn và không kiểm toán lại được. Scrum
  Master quyết định có yêu cầu commit lại hay không.
- **N-1 — Dòng `Status: BLOCKED` cũ vẫn đứng đầu mục Story Runtime Startup
  Smoke**, phía trên phần cập nhật 2026-09-24 thay thế nó. Người đọc lướt hoặc
  một gate quét chuỗi có thể đọc nhầm mục này là còn chặn. Đề xuất Scrum Master
  hoặc devops đổi nhãn dòng đó thành `Status: SUPERSEDED 2026-09-24` (giữ
  nguyên phần thân làm dấu vết). Nằm ngoài WriteScope của review này.
- **N-2 — `story_master.md` bị lane khắc phục sửa (+6 dòng header
  `Design-Screen:`).** Nội dung đúng và cần thiết, nhưng đây là artifact trạng
  thái do Scrum Master sở hữu; xác nhận lại rằng việc ghi này được cho phép.

D-2, D-3, D-4, D-5 của lượt 1 giữ nguyên, vẫn hoãn, không mục nào bị bản khắc
phục này chạm tới.

## Cổng tới hạn — trạng thái sau khắc phục

| Cổng tới hạn | Lượt 1 | Lượt 2 |
|---|---|---|
| Design fidelity — nội dung đối chiếu | FAIL (F-1) | **PASS** (bản tham chiếu thật, verdict có delta, D-1 đo lại) |
| Design fidelity — gói bằng chứng ghép cặp được | FAIL (F-1) | FAIL (F-4) ở lượt 2 → **PASS** ở lượt 3 (F-4 đóng, gate tự chạy lại exit 0) |
| Design fidelity — id màn hợp lệ trong `story_master.md` | không kiểm | **FAIL (F-5)** ở lượt 3 — giá trị `Design-Screen:` trải 6 dòng, gate đọc ra id không tồn tại |
| Điểm vào có thật + `## Entry Point Reachability` | FAIL (F-2) | **PASS** |
| Story runtime startup smoke | FAIL (F-3) | **PASS** |
| Widget test có mục tiêu / cổng nội dung R-1g / ba cửa ra | PASS | không tái kiểm, giữ PASS |

## State Recommendation

Mục này được thay thế ở lượt 3 — xem `## State Recommendation (lượt 3)` ở cuối
file. Giữ nguyên phần dưới làm dấu vết kiểm toán của lượt 2.

- `Implementation (Development)`: giữ **chưa tick** cho tới khi F-4 xong.
- `Review (Reviewer)`: giữ **chưa tick**.
- Story **chưa** đủ điều kiện `DONE` và chưa merge vào
  `codex/REQ-016_solo_stage1_relationship_assistant-integration`.
- Route lại Mobile Developer cho **một việc duy nhất**: F-4 (đổi tên 4 file +
  cập nhật bảng trong `visual-fidelity-report.md`, tuỳ chọn kèm D-6). Không cần
  chạy lại thiết bị, không cần chụp lại, không đụng mã sản phẩm.
- Sau F-4, re-review chỉ cần xác nhận tên file và cổng
  `verify-story-visual-fidelity-gate.sh` — mọi kết luận còn lại của lượt 2 giữ
  nguyên hiệu lực.
- D-1..D-7 và N-1/N-2 để lại cho Scrum Master phân loại.
- Báo cáo này không sửa file nào khác ngoài chính nó và `review/scope-gate.md`
  (xem ghi chú cuối).

## Ghi chú về `scope-gate.md`

Handoff của lượt này ghi "Do not create `scope-gate.md`", nhưng
`validate-reviewer-two-phase.sh` chặn stop với `SCOPE_GATE_MISSING` và yêu cầu
đúng file đó. File đã được tạo để gỡ thế kẹt; nó chỉ liệt kê phạm vi đã đọc
trong lượt 2, không thêm phán quyết nào. Scrum Master nên chỉnh mẫu handoff
compact-review cho khớp guard, vì mâu thuẫn này sẽ lặp lại ở mọi re-review sau.

---

## Xác nhận F-4 (lượt 3, 2026-09-24)

Phạm vi lượt này **chỉ** là xác nhận F-4 đã đóng. Không mở lại F-1/F-2/F-3/D-1,
không review lại P1-P4, không đọc lại master-plan/solution/requirements/uiux-spec.

- Diff baseline: `1b18a7fc` → `ff567fdc` (1 commit khắc phục duy nhất)
- Worktree sạch (`git status --porcelain` trống) tại thời điểm kiểm

**1. Phạm vi diff đúng như khai báo.**
`git diff 1b18a7fc..ff567fdc --stat` trả đúng **5 file**: 4 `R100` (đổi tên
nguyên vẹn từng byte) + 1 `M` trên `visual-fidelity/visual-fidelity-report.md`.
Không có mã sản phẩm, mã test, hay file cấu hình nào bị đụng; không có file nào
ngoài `visual-fidelity/`.

**2. Cổng thị giác tự chạy lại, PASS thật.**
Review này tự gọi bộ kiểm chứ không tin lời kể trong report. `.claude/hooks/`
không được projected vào worktree nên script được gọi bằng đường dẫn tuyệt đối ở
control checkout, `--project` trỏ vào worktree:

```
python3 <control>/.claude/hooks/lib/visual_fidelity.py \
  --dir <worktree>/data/requirements/REQ-016.../STORY-008... --project <worktree> \
  --stage review --stack mobile --lane mobile   → không output, exit 0
  --stage done   --stack mobile --lane mobile   → không output, exit 0
```

**3. Đối chứng xác nhận cổng không rỗng.** Trên bản sao `/tmp` chỉ khác ở việc
giữ tên cũ `implemented-screen-9-*`, cùng script trả exit 1 với đúng lỗi đã chặn
ở lượt 2: `no screen has BOTH renders ... running-app renders exist for
['screen'] and design renders for ['9']`. Tức là PASS ở bước 2 là do việc bỏ
token `screen-`, không phải do gate bỏ qua story.

**4. Bảng tên file trong report khớp đĩa.** 4 tên trong cột "Bản cài đặt" của
`## Các màn được đối chiếu` và tên trong mục verdict `## Cách bốn ảnh cài đặt
được tạo ra` khớp đúng 4 file thật đang được Git theo dõi:
`implemented-9-kich-ban-buoi-hen-truoc-ios.png`,
`implemented-9-kich-ban-buoi-hen-trong-ios.png`,
`implemented-9-kich-ban-buoi-hen-so-tay-trong-ios.png`,
`implemented-9-ba-cua-ra-ios.png`, cùng
`design-reference-9-kich-ban-buoi-hen-ios.png`. Cả hai phía giờ cùng cho id màn
`9`.

**F-4 — ĐÓNG.** Mọi kết luận khác của lượt 2 giữ nguyên hiệu lực. Một finding
chặn MỚI, không liên quan tới tên file, xuất hiện ở chính lượt này khi cổng
story chạy: xem `## F-5 — MỞ (lượt 3)`.

D-6 (harness `_visualEvidenceDir` vẫn trỏ thư mục cũ) **không** được sửa trong
lượt khắc phục này — vẫn treo, vẫn không chặn, vì nhánh chụp nấp sau cờ
`--dart-define=CAPTURE_VISUALS` nên gate test mặc định không chạm tới.

## F-5 — ĐÓNG ở lượt 4 (nội dung dưới đây là bản ghi khi mở ở lượt 3)

`verify-story-visual-fidelity-gate.sh` chặn stop của review này với id màn không
hợp lệ. Giá trị nó đọc ra:

```
Design-Screen: 9-kich-ban-buoi-hen (ios, resolved 2026-09-17 — see
```

Nguồn là `story_master.md:11-16`: giá trị `Design-Screen:` trải **6 dòng**, phần
còn lại của dòng 11 sau id là chú thích văn xuôi (`(ios, resolved 2026-09-17 —
see`) rồi tràn tiếp sang dòng 12-16. Gate lấy nguyên phần còn lại của dòng làm id
nên nhận được một chuỗi không nằm trong danh sách id hợp lệ của design source
`cupid-ch-ng-1`. Id đúng — `9-kich-ban-buoi-hen` — nằm trong danh sách đó và là
token đầu tiên của chính dòng 11, nên **nội dung đúng, chỉ định dạng sai**.

Đây cùng một dạng lỗi với F-4: bằng chứng hợp lệ, con người đọc hiểu, máy không
ghép được. Đó là lý do outcome giữ `PATCH_REQUIRED`.

**Việc cần làm (một dòng).** Trong `story_master.md`, để dòng `Design-Screen:`
chỉ mang **id trần, không gì khác**:

```
Design-Screen: 9-kich-ban-buoi-hen
```

rồi chuyển toàn bộ chú thích hiện tại (platform `ios`, ngày phân giải, alias
`s1:datescript`, việc neo `Design-Surface: cupid-ch-ng-1`, 5 mục
DESIGN_SPEC_CONFLICT, 1 mục DESIGN_ANCHOR_OPEN) xuống các dòng riêng bên dưới
hoặc để nguyên chúng ở `visual-fidelity/visual-fidelity-report.md`, nơi đã có
sẵn bản đầy đủ. Không mất thông tin nào.

**Ai sửa:** `story_master.md` là artifact trạng thái do Scrum Master sở hữu và
nằm ngoài WriteScope của review này (chỉ có `review/review-report.md`), nên
review này **không** tự sửa. Đây cũng chính là rủi ro N-2 của lượt 2 hiện hình:
lane khắc phục đã ghi 6 dòng header này vào một file nó không sở hữu, và định
dạng đó giờ chặn cổng. Scrum Master sửa trực tiếp nhanh hơn route lại
Mobile Developer.

**Không cần** chạy lại thiết bị, chụp lại ảnh, hay đụng mã sản phẩm. Sau khi
dòng đó thành id trần, mọi kết luận của lượt 3 giữ nguyên hiệu lực và outcome
nâng thẳng lên `DEFERRED_ONLY`.

## State Recommendation (lượt 3 — đã được thay thế bởi lượt 4 ở cuối file)

- `Implementation (Development)`: giữ **chưa tick** cho tới khi F-5 xong.
- `Review (Reviewer)`: giữ **chưa tick**.
- Chất lượng bản cài đặt và gói bằng chứng thị giác đã **đạt** — F-4 đóng, cổng
  `visual_fidelity.py` tự chạy lại PASS ở cả `--stage review` và `--stage done`.
  Việc còn lại duy nhất là F-5, một dòng metadata trong `story_master.md`.
- Sau F-5, story đủ điều kiện tick cả hai mục, đủ điều kiện merge vào
  `codex/REQ-016_solo_stage1_relationship_assistant-integration`, và đủ điều kiện
  `DONE` theo `DEFERRED_ONLY`.
- Hoãn, không chặn, để Scrum Master phân loại: **D-2, D-3, D-4, D-5** (lượt 1),
  **D-6, D-7** (lượt 2), **N-1, N-2** (lượt 2). Danh sách này không đổi so với
  lượt 2.
- Review này không sửa file nào khác ngoài chính nó và `review/scope-gate.md`.
- Không tự commit: Scrum Master sở hữu commit và mọi cập nhật trạng thái.

## Xác nhận F-5 (lượt 4, 2026-09-24)

Phạm vi lượt 4 là **duy nhất** việc xác nhận F-5. Không tái kiểm F-1..F-4, D-1,
và không đọc lại `coding-plan/master-plan.md`, `architecture/solution.md`,
`requirements/requirements.md`, `ux/uiux-spec.md`. Baseline: `ff567fdc..HEAD`
(HEAD = `6c41ac26`).

**1. `Design-Screen:` giờ là id trần — ĐÚNG.** Đọc `story_master.md` dòng 9-18:
dòng 11 hiện là `Design-Screen: 9-kich-ban-buoi-hen`, không còn văn xuôi trên
cùng dòng. Chú thích cũ nằm nguyên vẹn ở dòng riêng `Design-Screen-Note:` ngay
bên dưới; `git diff` cho thấy đúng 3 dòng thêm / 2 dòng xóa, không mất nội dung
nào (chỉ `(` đầu chú thích và `)` cuối được thay bằng dấu câu thường).

**2. Diff kể từ BaseHead không chạm mã — ĐÚNG.**
`git diff ff567fdc..HEAD --name-status` trả đúng 3 file, tất cả là artifact:
`story_master.md` (M, fix F-5), `review/review-report.md` (M, lượt 3),
`review/scope-gate.md` (M, lượt 3). Không có file nào dưới `mobile/lib/` hay
`mobile/test/`. `git status --short` trống — worktree sạch tại thời điểm kiểm.

**3. Cổng thị giác PASS thật — ĐÚNG.** Lượt 4 tự chạy lại, không tin lời kể:
`python3 .claude/hooks/lib/visual_fidelity.py --dir <story> --project <worktree>
--stage done --stack mobile --lane mobile` → **exit 0, không in gì**. Không còn
báo id không hợp lệ. Đây chính là lệnh đã chặn stop ở lượt 3.

**Kết luận.** Điều kiện mà lượt 3 tự đặt ra ("sau khi dòng đó thành id trần, mọi
kết luận của lượt 3 giữ nguyên hiệu lực và outcome nâng thẳng lên
`DEFERRED_ONLY`") đã được thỏa đầy đủ. **F-5 ĐÓNG.** Không còn finding chặn nào
mở trên story này.

## State Recommendation (lượt 4 — có hiệu lực)

- `Implementation (Development)`: **đủ điều kiện tick**.
- `Review (Reviewer)`: **đủ điều kiện tick**.
- Story **sẵn sàng để Scrum Master merge** vào
  `codex/REQ-016_solo_stage1_relationship_assistant-integration`, và đủ điều kiện
  `DONE` theo `Outcome: DEFERRED_ONLY`.
- Danh sách hoãn **không đổi**, giữ nguyên để Scrum Master phân loại: **D-2, D-3,
  D-4, D-5** (lượt 1), **D-6, D-7** (lượt 2), **N-1, N-2** (lượt 2).
- Lượt 4 chỉ sửa `review/review-report.md` và `review/scope-gate.md`; không sửa
  `story_master.md` (chỉ đọc để xác nhận) và không tự commit.
