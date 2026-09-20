# Phase P5 – Ô pane "Đã đóng": tra lại, mở lại, xoá hẳn

## 1. Objective

Cho người dùng một đường vào kho đã đóng mà chính họ khởi xướng, nằm trên **cùng**
dải lọc của màn (1) chứ không phải một danh sách thứ hai, và hai hành động trong
đó: mở lại ngăn (AC-17) và xoá hẳn phần đã đóng (AC-15). Ô pane chỉ xuất hiện khi
đã có ít nhất một closure — trước đó app không được để lộ là nó tồn tại (AC-16).

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-closed-archive-pane.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3, P4
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/activity_cards/presentation/activity_card_list_cubit.dart`
  - `mobile/lib/features/activity_cards/presentation/widgets/activity_status_filter.dart`
  - `mobile/lib/features/chapter_closure/presentation/widgets/closed_archive_actions.dart`
  - `mobile/test/features/activity_cards/activity_status_filter_closed_pane_test.dart`
  - `mobile/test/features/chapter_closure/closed_archive_actions_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `runCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - none
- Shared Interfaces Consumed:
  - `ChapterClosureGate.hasAnyClosure()` / `.closedIdsOf()` (P1)
  - `ChapterClosureService.reopen()` (P2)
  - `Stage1WipeService.purgeClosed()` (P3)
- Risk Surfaces:
  - Rò rỉ vật liệu đã đóng ra luồng thường ngày
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §3 (một dải lọc,
    một danh sách, không route mới)
  - consumer contract: `../architecture/contract-summary.md` §3, §6
- Primary Inputs Summary:
  - requirements: AC-11, AC-14, AC-15, AC-16, AC-17, AC-30
  - architecture: `../architecture/solution.md` §1 Key Discovery 2, §3
    `UI Delivery Anchor`
  - OQ constraints: none
  - upstream phase outputs: P3 `purgeClosed()`, P4 lối vào đóng ngăn
  - UX constraints, if truly required: `../ux/uiux-spec.md` §3
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: một ô lọc thêm + hai hành động trong đó
  - Source/Test File Count: 5
  - Split Required: NO
  - Split Rationale: hai hành động chỉ tồn tại bên trong ô pane này; tách ra sẽ
    tạo một phase không có bề mặt để đặt nút

## 2. Required Reads

- `../requirements/requirements.md` (AC-11, AC-14..AC-17, AC-30)
- `../ux/uiux-spec.md` §3
- `../architecture/solution.md` §1, §3
- `mobile/lib/features/activity_cards/presentation/widgets/activity_status_filter.dart`
- `mobile/lib/features/activity_cards/presentation/activity_card_list_cubit.dart`
- P3, P4 outputs

## 3. Tasks

- Thêm ô "Đã đóng" vào **cuối** `ActivityStatusFilter`. Lưu ý thực tế trên code:
  dải này **đã có năm ô** (`ActivityCardPane { all, idea, scheduled, done,
  memory }`), nên ô mới là ô **thứ sáu** — `../ux/uiux-spec.md` §3 mô tả nó là
  "đoạn thứ 5" theo một ảnh chụp code cũ hơn. Ý đồ UX không đổi: cùng một dải,
  cùng một danh sách, không route mới.
- Ô "Đã đóng" chỉ dựng khi `hasAnyClosure()` là `true`; ở trạng thái chưa có
  closure, dải giữ nguyên đúng năm ô như hiện nay (AC-16).
- Dạy `ActivityCardListCubit` một pane mới đọc **đảo ngược** cổng: lấy đúng tập id
  trong sổ ghi thay vì loại trừ nó. Không thêm giá trị thứ năm nào vào
  `ActivityCardStatus` — "Đã đóng" là bộ lọc, không phải trạng thái vòng đời
  (BR-4). Lọc vẫn nằm trong SQL để `hasMore` đúng.
- Dựng `closed_archive_actions.dart` với hai hành động, mỗi hành động một hộp
  thoại xác nhận theo bảng luật `../ux/uiux-spec.md` §2:
  - mở lại ngăn → `ChapterClosureService.reopen()`; sau đó **không** lời chúc
    mừng, khích lệ, hay bình luận nào (AC-17);
  - xoá hẳn phần đã đóng → `Stage1WipeService.purgeClosed()`, một lần xác nhận,
    nêu tính không hoàn tác dưới dạng dữ kiện (AC-15).
- Không thêm bất kỳ nhắc nhở, huy hiệu đếm, hay gợi ý nào dẫn vào ô này (AC-16).

## 4. Acceptance Criteria

- Khi chưa có closure, `ActivityStatusFilter` dựng đúng năm ô và không có dấu
  hiệu nào cho thấy kho đã đóng tồn tại (AC-16).
- Sau closure đầu tiên, ô thứ sáu xuất hiện và mở ra **đầy đủ** vật liệu đã đóng —
  không mục nào bị xoá ngầm (AC-14).
- Vật liệu đã đóng xuất hiện **chỉ** trong ô này và không rò sang năm ô kia
  (AC-11).
- `reopen()` đưa vật liệu về đúng ô cũ của nó, và ô "Đã đóng" biến mất khi không
  còn closure nào.
- `purgeClosed()` sau một lần xác nhận xoá thật vật liệu đã đóng; vật liệu không
  đóng còn nguyên từng id (AC-15).
- Ô "Đã đóng" không phải ngõ cụt: rỗng hay đầy đều còn đường quay về màn (1)
  (AC-30).

## 5. Planned Outputs

- Code directories or files: `closed_archive_actions.dart`, sửa
  `activity_status_filter.dart` và `activity_card_list_cubit.dart`
- Contracts or schemas: none
- Requirement configuration guide updates: none
- Notes or evidence: `coding-plan/test-results.md`, PNG visual fidelity

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (Flutter, `mobile/`)
- Required levels:
  - unit: cubit — pane "Đã đóng" trả đúng tập đảo ngược, kể cả khi phân trang
  - integration: widget test dải lọc ở hai trạng thái (chưa có closure / đã có),
    và hai hành động trong ô
  - mobile build/type-check/static-analysis: có
  - visual inspection: có
- Required checks:
  - test khẳng định số ô: đúng 5 trước closure, đúng 6 sau closure
  - `flutter analyze lib test` không sinh error mới
- Mobile discoverability / navigation integration: ô thứ sáu phải chạm được từ
  màn (1) trong widget test và không dẫn sang route mới
- Minimum gates by risk surface:
  - Rò rỉ vật liệu đã đóng → assertion "vật liệu đã đóng không có mặt ở năm ô
    kia" phải chạy và xanh
- Required regression or contract coverage: test hiện có của
  `ActivityStatusFilter` (dải năm ô) và `ActivityCardListCubit` phải còn xanh ở
  trạng thái chưa có closure. Nếu ô thứ sáu làm đổi chiều cao hàng, kiểm lại các
  test `tap()` sẵn có: thêm một phần tử vào màn từng làm `tap()` của test khác
  trượt ra ngoài khung mặc định 800x600.
- Evidence format: `coding-plan/test-results.md` cộng hai PNG (design, implemented)
- Per-story visual fidelity: REQUIRED
  - Design screen id + how it is rendered: khung kho đã đóng (SB-64/SB-65) trên
    canvas `cupid-ch-ng-1`. Liệt kê khung bằng
    `.ai-team-bundle/runtime/tools/render-design-canvas.js` để lấy id chính xác,
    rồi `capture-mobile-screen.sh --mode=design --screen=<id>`. Nếu canvas không
    có khung cho bề mặt này, ghi `NOT_APPLICABLE — <lý do>` kèm danh sách khung
    làm bằng chứng.
  - How the implemented screen is captured:
    `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh` trên thiết bị, với
    dữ liệu đã seed một closure. Trạng thái này chỉ tới được sau khi đóng ngăn
    thật, nên nếu không seed được trên thiết bị thì dùng fallback đã có tiền lệ
    trong REQ-016: chụp `RepaintBoundary` trong widget test của chính phase này.
  - NOTE: đây là cổng của chính story, xét ở review của story. Không bao giờ được
    thoả bằng, hay hoãn sang, đợt audit cấp requirement. Không có thiết bị hay
    runtime nào tới được thì phase chặn ở `MOBILE_RUNTIME_UNAVAILABLE` /
    `VISUAL_RUNTIME_UNAVAILABLE` — blocker, không phải deferral.
  - Cả hai PNG phải được nhìn bằng mắt trước khi kết luận (kiểm ô tofu ở nhãn
    tiếng Việt của ô thứ sáu).
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/activity_cards/ test/features/chapter_closure/`
  - Build/type-check/lint command when required: `flutter build apk --debug`
  - Required assertion evidence: danh sách nhãn ô thực tế ở cả hai trạng thái, và
    id vật liệu có mặt/vắng mặt ở từng ô

## 7. Status

- Status: COMPLETE
- Last updated: 2026-09-17
- Evidence: `coding-plan/test-results.md` mục "Phase P5" — `+292 ~4: All other
  tests passed!` trên `test/features/activity_cards/` +
  `test/features/chapter_closure/`, `flutter analyze` 0 error/0 warning,
  `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk`, và hai PNG
  `visual-fidelity/design-reference-kho-da-dong-ios.png` /
  `visual-fidelity/implemented-kho-da-dong-ios.png` đã nhìn tận mắt.
