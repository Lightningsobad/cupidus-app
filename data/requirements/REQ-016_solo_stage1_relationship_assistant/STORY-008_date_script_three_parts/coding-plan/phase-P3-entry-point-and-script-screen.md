# Phase P3 – Điểm vào khoá vị trí và khung màn kịch bản (9)

## 1. Objective

Màn (9) tồn tại, vào được **đúng một đường** — hàng mới trong bottom sheet "Chuẩn
bị" của một thẻ *Đã hẹn ngày* — và không đường nào khác. Khung màn có header,
điều khiển ba phần, vùng nội dung với caption bảo vệ "Trong", và ô hỏi tại chỗ.
Ba cửa ra để sang P4.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-entry-point-and-script-screen.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/date_script/date_script_entry_point.dart`
  - `mobile/lib/features/date_script/presentation/cubit/date_script_cubit.dart`
  - `mobile/lib/features/date_script/presentation/screens/date_script_screen.dart`
  - `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart`
  - `mobile/test/features/date_script/date_script_screen_test.dart`
  - `mobile/test/features/date_script/date_script_location_lock_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `Future<void> openDateScriptScreen(BuildContext context, ActivityCard card)`
  - `const String dateScriptEntryPointId = 'date_script';`
  - (`../architecture/contract-summary.md` §1 — STORY-009/010 sẽ tiêu thụ)
- Shared Interfaces Consumed:
  - P1 + P2 (`domain/` đầy đủ)
  - `mobile/lib/features/context_notebook/context_notebook_entry_point.dart`
    (`AskOnTheSpotSlot`, `AskTarget`, `NotebookEntry`, `NotebookKind`)
  - `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart`
    (`_resolveActions` — điểm mở rộng STORY-002 đã chừa sẵn cho story này)
- Risk Surfaces:
  - Khoá vị trí màn (9) — `LOCATION_LOCK_UNVERIFIED`
  - Ranh giới J7 — `J7_BOUNDARY_UNVERIFIED`
  - Visual fidelity màn (9) — `VISUAL_FIDELITY_BLOCKED`
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` (bố cục màn 9) +
    `../architecture/contract-summary.md` §1
  - consumer contract: P4, STORY-009, STORY-010
- Primary Inputs Summary:
  - requirements: AC-1, AC-2, AC-5, AC-13..AC-16, AC-24, AC-35; BR-1, BR-1a,
    BR-3, SC-6, R-13
  - architecture: `../architecture/solution.md` §1 Key Discovery (a) và (c),
    §3 UI Delivery Anchor, §4; `../architecture/contract-summary.md` §1, §5
  - upstream phase outputs: P1, P2
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: đường vào khoá vị trí + khung màn + ô hỏi tại chỗ
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` (các AC/BR liệt kê ở trên)
- `../ux/uiux-spec.md` — bố cục màn (9) và vị trí "Khu vực Chuẩn bị"
- `../architecture/solution.md` §1 Key Discovery (a): "Khu vực Chuẩn bị" là
  **hai** bề mặt; mục #2 của UX spec giải ra thành một **hàng trong bottom
  sheet**, không phải khối inline
- `../architecture/contract-summary.md` §1 và §5
- `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart`
  — đọc cả doc comment của `_PrepareAction`: nó nói thẳng STORY-008 **thêm mục**
  vào `_resolveActions`, không reshape sheet
- `mobile/lib/features/gift_ideas/gift_ideas_entry_point.dart` — khuôn entry
  point 29 dòng cần bám theo
- `mobile/lib/features/context_notebook/presentation/screens/skill_profile_screen.dart`
  — tiền lệ dùng `AskOnTheSpotSlot`

## 3. Tasks

- `date_script_entry_point.dart` (bề mặt tiếp xúc **duy nhất** của feature):
  - `openDateScriptScreen(BuildContext context, ActivityCard card)` đẩy một
    `MaterialPageRoute` **vô danh**. Không `settings.name`, không route đăng ký,
    không deep link. `card` là tham số vị trí bắt buộc để việc mở màn mà không
    có thẻ nguồn là lỗi biên dịch (BR-1a).
  - `const String dateScriptEntryPointId = 'date_script';`
  - Không export gì khác ngoài những thứ STORY-009/010 thật sự cần.
- `prepare_actions_sheet.dart` — thêm **đúng một** `_PrepareAction` vào
  `_resolveActions`:
  - Chỉ hiện khi `card.status` là *Đã hẹn ngày* (`scheduled`). Thẻ khác trạng
    thái → hàng không tồn tại, không disabled, không tooltip.
  - `Key('prepare_action_date_script')`, nhãn song ngữ qua helper file-local
    `_prepareText` đang có (không thêm khoá l10n mới ở phase này).
  - `run` gọi `openDateScriptScreen` trên context màn chi tiết sau khi sheet
    đóng, đúng như hàng "Xuất lời mời" đang làm.
  - Không reshape sheet, không đổi thứ tự hàng có sẵn, không thêm hành động
    chính cấp thẻ thứ hai.
- `date_script_cubit.dart`:
  - Nạp gói, chọn preset qua P2, ràng buộc biến từ thẻ + sổ tay, giữ phần đang
    xem (`DateScriptPart`) và con trỏ xoay vòng preset **trong bộ nhớ**.
  - Không đọc/ghi DB, không `SharedPreferences`, không lưu lịch sử kịch bản
    (AC-22). Con trỏ chết khi màn đóng — đó là chủ đích.
  - `reload()` để `AskOnTheSpotSlot` gọi lại sau khi người dùng trả lời.
- `date_script_screen.dart`:
  - Header + điều khiển ba đoạn (`Trước` · `Trong` · `Sau`) + vùng nội dung +
    ô `AskOnTheSpotSlot(entryPointId: dateScriptEntryPointId, neededFieldIds:
    [interest, event], onContextChanged: cubit.reload)` theo §2 (thứ tự
    `notebook.interest` rồi `notebook.event`).
  - Caption bảo vệ khi đang xem phần **Trong**: nói rõ đây là nội dung đọc
    trước khi đi, không phải việc phải làm trong lúc hẹn. Caption này là nhãn
    **widget**, nằm trong Dart, không nằm trong gói — để không CMS nào xoá được
    (BR-3).
  - Không thanh tiến độ, không "đã hết", không tìm kiếm, không share/copy-link.
  - Nhãn ba đoạn và nhãn nút là nhãn chức năng của widget, không phải nội dung
    gói.
  - Chừa chỗ cho thanh cửa ra dính đáy màn; P4 lắp nội dung vào.
- Hai file test theo `## 6`.

## 4. Acceptance Criteria

- Từ một thẻ *Đã hẹn ngày*, bấm "Chuẩn bị" → sheet có hàng kịch bản → màn (9)
  mở ra với nội dung khớp loại hoạt động của thẻ (AC-1).
- Thẻ **không** ở trạng thái *Đã hẹn ngày* → hàng kịch bản không có mặt trong
  sheet (AC-2 / SC-6).
- Không route có tên nào dẫn tới màn (9); không mục menu chính, không tab bar
  (AC-2 / BR-1a).
- Đổi giữa ba đoạn giữ nguyên preset đang chọn; không nạp lại, không đổi nội
  dung (AC-7).
- Sổ tay trống → màn vẫn hiện kịch bản dùng được và `AskOnTheSpotSlot` hỏi đúng
  **một** câu (AC-5).
- Trả lời câu hỏi → `reload` chạy → nội dung bớt chung chung, không rời màn.
- Không `Timer`, không thông báo, không countdown, không nút "bắt đầu buổi hẹn"
  ở bất kỳ đâu trên đường đi này (AC-13..AC-16 / BR-3).
- Test `invite_composer` hiện có vẫn xanh sau khi thêm hàng.

## 5. Planned Outputs

- Code: `mobile/lib/features/date_script/` (entry point + cubit + screen),
  một hàng thêm vào `prepare_actions_sheet.dart`
- Contracts: `../architecture/contract-summary.md` §1 được hiện thực hoá
- Notes: bằng chứng test + ảnh chụp ghi vào `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, widget test
- Required levels:
  - widget: `date_script_screen_test.dart`, `date_script_location_lock_test.dart`
  - mobile build/type-check/static-analysis:
    `flutter analyze lib/features/date_script lib/features/invite_composer
    test/features/date_script test/features/invite_composer`
- Required checks:
  - Khoá vị trí, ba phần: (1) sheet của thẻ `scheduled` **có** hàng kịch bản;
    (2) sheet của thẻ mọi trạng thái khác **không** có hàng đó, quét qua toàn bộ
    giá trị trạng thái chứ không chỉ một; (3) quét source
    `lib/**` không có literal tên route nào trỏ màn (9), và
    `openDateScriptScreen` chỉ được gọi từ `prepare_actions_sheet.dart`.
  - Ranh giới J7: quét source `lib/features/date_script/**` không import
    `dart:async` `Timer`, không import gói thông báo, không có `Duration` dùng
    cho đếm ngược. Test phải có negative control chứng minh phép quét bắt được.
  - Đổi đoạn không gọi lại selector (đếm số lần nạp gói).
  - Sổ tay trống → `AskOnTheSpotSlot` hiện đúng một câu hỏi, và nội dung vẫn
    render.
  - Frame test đủ cao: dựng khung lớn hơn mặc định 800x600 trước khi `tap`, nếu
    không thanh cửa ra dính đáy sẽ đẩy mục tiêu ra ngoài màn.
- Minimum gates by risk surface:
  - Khoá vị trí → ba phần ở trên đều xanh
  - Ranh giới J7 → phép quét source xanh kèm negative control
- Required regression or contract coverage: chạy lại **cả**
  `flutter test test/features/invite_composer/` vì `prepare_actions_sheet.dart`
  bị sửa.
- Evidence format: lệnh + tóm tắt pass/fail ghi vào `coding-plan/test-results.md`
- Per-story visual fidelity (REQUIRED — phase này dựng UI):
  - Design screen id + cách render: phân giải và khoá `design_source` theo
    `contracts/design-fidelity-spec.md` "Design source detection and locking".
    Nếu sau khi phân giải vẫn không có design source, ghi
    `DESIGN_SOURCE_NOT_DETECTED` kèm bằng chứng đã thử, đừng bỏ trống.
  - Cách chụp màn đã hiện thực: màn (9) **cố ý không có tên route**, nên
    `capture-mobile-screen.sh` không deep-link tới được — đó là yêu cầu BR-1a,
    không phải hạn chế công cụ. Chụp bằng `RepaintBoundary` ngay trong
    `date_script_screen_test.dart`, ba trạng thái: đoạn **Trước**, đoạn **Trong**
    (phải thấy caption bảo vệ), và trạng thái sổ tay trống có ô hỏi tại chỗ.
  - Harness phải bọc `CupidAppBackground` và nạp MaterialIcons của framework,
    nếu không icon ra ô tofu và ảnh chụp vô giá trị. Mắt phải nhìn ảnh: một lần
    chụp "xanh" vẫn có thể đầy ô tofu ở chữ tiếng Việt có dấu.
  - NOTE: đây là cổng riêng của story, kiểm ở review của chính nó. Không được
    hoãn sang audit cấp requirement. Nếu không chụp được, phase chặn với
    `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests: `flutter test test/features/date_script/ test/features/invite_composer/`
  - Build/type-check: lệnh `flutter analyze` phạm vi hẹp ở trên
  - Required assertion evidence: test khoá vị trí quét **mọi** trạng thái thẻ,
    không chỉ một trạng thái đối chứng.

## 7. Status

- Status: COMPLETE
- Last updated: 2026-09-17
- Evidence: `coding-plan/test-results.md` mục "Phase P3 – Đường vào khoá vị
  trí và màn hình (9)" (lệnh, file, AC coverage, negative control, 7 deviation).
  Con trỏ quay vòng preset của AC-35 không hiện thực — lý do ở deviation 1.
