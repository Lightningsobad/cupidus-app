# Phase P2 – Khối trên chi tiết thẻ, đóng/mở lại, và chia sẻ vị trí

## 1. Objective

Khối "Trước giờ đi" hiện ra đúng lúc trên chi tiết thẻ mà không cần bất kỳ thao
tác bật nào, đóng được trong ngày và mở lại được, và dòng "Chia sẻ vị trí" mở OS
Share Sheet đúng một lần mà không để lại dấu vết nào.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-detail-screen-block-and-dismissal.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/before_you_go/data/before_you_go_dismissal_store.dart`
  - `mobile/lib/features/before_you_go/presentation/before_you_go_cubit.dart`
  - `mobile/lib/features/before_you_go/presentation/widgets/before_you_go_block.dart`
  - `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart`
  - `mobile/test/features/before_you_go/before_you_go_block_test.dart`
  - `mobile/test/features/before_you_go/before_you_go_dismissal_store_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Consumed:
  - `../architecture/contract-summary.md` §1-§4
  - P1: `resolveHints(...)`, `BeforeYouGoFacts`, `BeforeYouGoPhase`, `ChecklistHint`
- Risk Surfaces:
  - Điều kiện hai vế của khối (AC-1/AC-2/AC-3)
  - Chuỗi cứng trong widget (AC-29/BR-15)
  - Hồi quy layout chi tiết thẻ
  - Rò rỉ quyền riêng tư khi chia sẻ (AC-19/AC-20)
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §1 Key Discovery (điểm
    mount) và §4; `../ux/uiux-spec.md` mục 2-3 (bố cục khối, hàng gọn sau khi đóng)
  - consumer contract: STORY-012 đọc `BeforeYouGoPhase`, không đọc widget này
- Primary Inputs Summary:
  - requirements: AC-1..AC-6, AC-12..AC-21, AC-25..AC-27; BR-1, BR-2, BR-5,
    BR-7..BR-9, BR-12, BR-13
  - architecture: `../architecture/solution.md` §1 Key Discovery, §4
  - upstream phase outputs: P1 domain API
  - UX constraints: `../ux/uiux-spec.md` mục 2 (icon từng dòng, `body 17pt`,
    chiều cao dòng ≥ 40px, pill outline cuối khối) và mục 3 (hàng gọn "Trước giờ
    đi ✓" + text button "Mở lại", icon `check` màu trung tính, **không** `--mint`/
    `--green`)
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: render khối + vòng đời đóng/mở lại + một hành động share
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` (các AC/BR liệt kê ở trên)
- `../architecture/solution.md` §1 Key Discovery và §4
- `../ux/uiux-spec.md` mục 2 và mục 3
- `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart`
- `mobile/lib/features/account/data/notification_preferences_store.dart` (khuôn
  store `SharedPreferences`)

## 3. Tasks

- `before_you_go_dismissal_store.dart`: đọc/ghi/xoá khoá
  `before_you_go.dismissed_on.<cardId>` = `YYYY-MM-DD`. Không dùng Drift, không
  bump `schemaVersion`. Khoá tự hết hiệu lực khi sang ngày mới — không viết job
  dọn dẹp.
- `before_you_go_cubit.dart`: dựng `BeforeYouGoPhase` + `List<ChecklistHint>` từ
  `(card, today, gói, dismissedOnIso)`. `today` và seam share là tham số tiêm
  được; cấm `DateTime.now()` trực tiếp. Đóng khối = ghi khoá; "Mở lại" = xoá
  khoá. **Không** đổi trạng thái thẻ (BR-8), không gọi cubit của
  `activity_cards`.
- `before_you_go_block.dart`:
  - Không hiện gì khi `isActive == false`, khi `isDismissed == false` và danh
    sách rỗng thì **ẩn cả tiêu đề** (AC-14) — không khung, không viền, không ô
    giữ chỗ.
  - Mỗi dòng: icon leading + `labelVi` lấy từ `ChecklistHint`. Không checkbox,
    không trạng thái đã-làm. Chỉ dòng có `action == share_location` có text
    button trailing.
  - Pill outline "Xong hết rồi, đi thôi" cuối khối; bấm là đóng ngay, không
    dialog, không chúc mừng (AC-17).
  - Sau khi đóng: hàng gọn một dòng + text button "Mở lại" (AC-16).
  - Bỏ qua dòng chia sẻ không sinh icon cảnh báo hay nhắc lại (AC-21).
- Mount vào `activity_card_detail_screen.dart`: chèn ngay **sau**
  `_primaryAction(context, state, cubit)` trong `Column` của `SliverList`
  (`_ActivityCardDetailBodyState.build`). Không sửa `_primaryAction`, không sửa
  `prepare_actions_sheet.dart`, không thêm route.
- Chia sẻ vị trí: gọi `share_plus` **một lần** qua một seam tiêm được. Không
  permission vị trí, không `Geolocator`, không lưu vị trí/người nhận/lịch sử.

## 4. Acceptance Criteria

- Thẻ `scheduled` + `scheduledOn == hôm nay` → khối hiện sẵn khi mở chi tiết
  thẻ, không thao tác nào (AC-1).
- `scheduledOn` là hôm qua hoặc ngày mai → khối vắng mặt hoàn toàn (AC-2).
- Thẻ `idea`/`done`/`memory` trùng ngày hôm nay → khối vắng mặt (AC-3).
- Hành động chính cấp thẻ vẫn đúng một, nhãn không đổi (AC-4).
- Bấm "Xong hết rồi, đi thôi" → khối co thành hàng gọn; mở lại chi tiết thẻ
  trong cùng ngày vẫn là hàng gọn (AC-15); bấm "Mở lại" trả về khối đầy đủ (AC-16).
- Trạng thái thẻ không đổi sau khi đóng khối (AC-17/BR-8).
- Bấm "Chia sẻ" gọi seam share **đúng một lần**; không khoá `SharedPreferences`
  nào khác khoá đóng khối được ghi (AC-18/AC-19).
- Khối rỗng → không widget nào của khối trong cây, chi tiết thẻ vẫn cuộn và dùng
  bình thường (AC-14).
- Không widget nào chứa literal nhãn checklist (AC-29).

## 5. Planned Outputs

- Code: `mobile/lib/features/before_you_go/{data,presentation}/`, một điểm mount
  trong `activity_card_detail_screen.dart`
- Notes: bằng chứng test và ảnh chụp fidelity ghi vào `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter widget test (`flutter_test`), không thiết bị
- Required levels:
  - unit: `before_you_go_dismissal_store_test.dart` (dùng
    `SharedPreferences.setMockInitialValues`)
  - integration: `before_you_go_block_test.dart` — pump `ActivityCardDetailScreen`
    thật với repository giả, không chỉ pump widget khối rời
  - mobile build/type-check/static-analysis:
    `flutter analyze lib/features/before_you_go lib/features/activity_cards test/features/before_you_go`
  - visual inspection: xem tận mắt ảnh chụp, không chỉ đọc "capture OK"
- Required checks:
  - Ba nhánh điều kiện hiện/ẩn (AC-1/AC-2/AC-3), mỗi nhánh một `testWidgets`.
  - Vòng đóng → hàng gọn → "Mở lại" → khối đầy đủ, trong cùng một ngày giả lập.
  - Seam share đếm đúng 1 lần gọi; assert tập khoá `SharedPreferences` sau đó chỉ
    chứa khoá đóng khối.
  - Nhánh khối rỗng: `find.byType(BeforeYouGoBlock)` vắng mặt và màn hình vẫn
    cuộn được.
- Mobile discoverability / navigation integration: điểm vào của story này là
  **tự động, không destination mới**. Test phải chứng minh khối hiện qua đường
  người dùng thật — mở `ActivityCardDetailScreen` — chứ không phải bằng cách pump
  thẳng widget khối. Đây là phần thay cho "route + navigation item" của một story
  UI thông thường.
- Minimum gates by risk surface:
  - Hồi quy layout chi tiết thẻ → chạy lại **toàn bộ**
    `flutter test test/features/activity_cards/`. Khối làm `Column` cao thêm; một
    `tap()` sẵn có có thể trượt ra ngoài khung mặc định 800x600. Nếu có test đỏ vì
    lý do đó, sửa bằng `tester.view.physicalSize` lớn hơn hoặc
    `scrollUntilVisible`, **không** bằng cách bỏ assert.
  - Rò rỉ quyền riêng tư → assert không có khoá lạ và seam share gọi 1 lần.
- Required regression or contract coverage:
  `flutter test test/features/activity_cards/ test/features/before_you_go/`
- Evidence format: lệnh + pass/fail + đường dẫn ảnh chụp, ghi vào
  `coding-plan/test-results.md`
- Per-story visual fidelity (REQUIRED — phase này dựng UI):
  - Design screen id + cách render: phân giải và khoá `design_source` theo
    `contracts/design-fidelity-spec.md` "Design source detection and locking".
    `../ux/uiux-spec.md` đã ghi `DESIGN_SOURCE_NOT_DETECTED` là bình thường ở giai
    đoạn này; nếu sau khi phân giải vẫn không có design source, ghi
    `DESIGN_SOURCE_NOT_DETECTED` kèm bằng chứng đã thử, đừng bỏ trống.
  - Cách chụp màn đã hiện thực: khối chỉ tồn tại khi thẻ `scheduled` có
    `scheduledOn == hôm nay`, nên **không** điều hướng tới được bằng
    `capture-mobile-screen.sh` trên thiết bị. Chụp bằng `RepaintBoundary` ngay
    trong `before_you_go_block_test.dart`, hai trạng thái: khối đầy đủ và hàng
    gọn sau khi đóng. Harness phải bọc `CupidAppBackground` và nạp MaterialIcons
    của framework, nếu không icon ra ô tofu và ảnh chụp vô giá trị.
  - NOTE: đây là cổng riêng của story, kiểm ở review của chính nó. Không được
    hoãn sang audit cấp requirement. Nếu không chụp được, phase chặn với
    `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests: `flutter test test/features/before_you_go/ test/features/activity_cards/`
  - Build/type-check: `flutter analyze lib/features/before_you_go lib/features/activity_cards test/features/before_you_go`
  - Required assertion evidence: ba nhánh hiện/ẩn, vòng đóng/mở lại, đếm 1 lần
    gọi share, và hai ảnh chụp đã được xem tận mắt (không ô tofu).

## 7. Status

- Status: DONE
- Last updated: 2026-09-11
- Evidence: `coding-plan/test-results.md` mục `## Phase P2`;
  `visual-fidelity/visual-fidelity-report.md`
- Open item cho Scrum Master: 6 mục `DESIGN_SPEC_CONFLICT` trong báo cáo thị
  giác cần người dùng chọn bên nào là anchor.
