# Phase P4 – Lối vào J11: mục overflow "đóng ngăn gọn gàng" và hộp thoại xác nhận

## 1. Objective

Gắn hành động đóng ngăn vào màn (1) đúng một chỗ: một mục trong overflow
`more_vert` của app bar tab "Nhà", dẫn tới **một** hộp thoại xác nhận viết theo
bảng luật đo được của UX. Đây là bề mặt mà AC-2..AC-5 phán xét — nội dung chữ và
số bước là yêu cầu, không phải chi tiết trình bày.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-close-chapter-entry-ui.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/chapter_closure/presentation/widgets/close_chapter_dialog.dart`
  - `mobile/lib/features/activity_cards/presentation/screens/` — app bar
    overflow của `ActivityCardHubView`
  - `mobile/test/features/chapter_closure/close_chapter_dialog_test.dart`
  - `mobile/test/features/activity_cards/activity_card_hub_close_entry_test.dart`
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
  - `ChapterClosureService.close()` (P2)
- Risk Surfaces:
  - None
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §2 bảng luật hộp
    thoại; `mobile/lib/features/activity_cards/presentation/widgets/delete_card_dialog.dart`
    là kiểu dựng lại
  - consumer contract: `../architecture/contract-summary.md` §6
- Primary Inputs Summary:
  - requirements: AC-1, AC-2, AC-3, AC-4, AC-16, AC-30
  - architecture: `../architecture/solution.md` §3 `UI Delivery Anchor`
  - OQ constraints: none
  - upstream phase outputs: P2 — `ChapterClosureService`
  - UX constraints, if truly required: `../ux/uiux-spec.md` §2 (bắt buộc: chữ của
    hộp thoại là yêu cầu đo được)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: một lối vào + một hộp thoại xác nhận
  - Source/Test File Count: 4
  - Split Required: NO
  - Split Rationale: một bề mặt UI duy nhất

## 2. Required Reads

- `../requirements/requirements.md` (AC-1..AC-5, AC-16, AC-30)
- `../ux/uiux-spec.md` §2
- `../architecture/solution.md` §3 `UI Delivery Anchor`
- `mobile/lib/features/activity_cards/presentation/widgets/delete_card_dialog.dart`
- P2 outputs

## 3. Tasks

- Thêm **một** mục vào overflow `more_vert` của app bar tab "Nhà". Không thêm
  nút nổi, không thêm banner, không thêm gợi ý ở bất kỳ đâu trong luồng thường
  ngày (AC-16: lối vào chỉ một chiều, do người dùng khởi xướng).
- Dựng `close_chapter_dialog.dart` theo kiểu `delete_card_dialog.dart`: nêu phạm
  vi bị đóng và nêu rằng dữ liệu **không** bị xoá, dưới dạng dữ kiện. Không lời
  can ngăn, không hỏi lý do, không ô nhập ghi chú, không nhãn cảm xúc
  (AC-4, AC-5, BR-9).
- Xác nhận đúng **một** lần rồi gọi `ChapterClosureService.close()` (AC-1, AC-2).
- Phản hồi sau khi đóng: trạng thái bình thường, không hiệu ứng kịch tính, không
  lời trêu, không gợi ý nhắn lại (AC-3, R-1c).
- Sau khi đóng, màn (1) vẫn dùng được ngay và vẫn còn ít nhất một đường đi tiếp
  (AC-30).

## 4. Acceptance Criteria

- Toàn bộ luồng từ mục overflow tới khi sổ ghi có closure là **một** thao tác xác
  nhận (AC-2).
- Chữ của hộp thoại thoả từng dòng của bảng luật `../ux/uiux-spec.md` §2; test
  khẳng định trên chuỗi thực tế hiển thị, không trên khoá l10n.
- Không chuỗi nào trong bề mặt này chứa đánh giá về người kia, lý do chia tay,
  hay gợi ý liên lạc lại (AC-4).
- Huỷ hộp thoại không ghi gì vào sổ ghi.
- Không có bất kỳ điểm vào thứ hai nào tới luồng đóng ngăn (AC-16).

## 5. Planned Outputs

- Code directories or files: `close_chapter_dialog.dart`, sửa app bar của
  `ActivityCardHubView`
- Contracts or schemas: none
- Requirement configuration guide updates: none
- Notes or evidence: `coding-plan/test-results.md`, PNG visual fidelity

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (Flutter, `mobile/`)
- Required levels:
  - unit: none
  - integration: widget test luồng overflow → hộp thoại → `close()` được gọi
    đúng một lần
  - mobile build/type-check/static-analysis: có
  - visual inspection: có
- Required checks:
  - test chuỗi cấm: quét mọi `Text` của hộp thoại và mục overflow, fail nếu khớp
    danh sách cấm ở `../ux/uiux-spec.md` §2
  - `flutter analyze lib test` không sinh error mới
- Mobile discoverability / navigation integration: mục overflow phải tới được từ
  màn (1) trong widget test, không chỉ tồn tại trong cây widget
- Minimum gates by risk surface: none (phase không chạm risk surface nào ở
  `../architecture/solution.md` §4)
- Required regression or contract coverage: test hiện có của app bar và của
  `ActivityCardHubView` phải còn xanh
- Evidence format: `coding-plan/test-results.md` cộng hai PNG (design, implemented)
- Per-story visual fidelity: REQUIRED
  - Design screen id + how it is rendered: khung SB-64 (J11) trên canvas
    `cupid-ch-ng-1` (`Design-Surface` của REQ-016, `req_master.md:13`). Lấy id
    chính xác bằng cách liệt kê khung của canvas trước khi dựng
    (`.ai-team-bundle/runtime/tools/render-design-canvas.js`), rồi render bằng
    `capture-mobile-screen.sh --mode=design --screen=<id>`. Nếu canvas không có
    khung cho bề mặt này, ghi `NOT_APPLICABLE — <lý do>` kèm danh sách khung đã
    liệt kê làm bằng chứng; không tự chọn khung của story khác.
  - How the implemented screen is captured:
    `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh` trên thiết bị. Hộp
    thoại nằm sau một thao tác overflow nên nếu không tới được trên thiết bị, dùng
    fallback đã có tiền lệ trong REQ-016: chụp `RepaintBoundary` ngay trong widget
    test của chính phase này.
  - NOTE: đây là cổng của chính story, xét ở review của story. Không bao giờ được
    thoả bằng, hay hoãn sang, đợt audit cấp requirement. Nếu không có thiết bị
    hay runtime nào tới được thì phase chặn ở `MOBILE_RUNTIME_UNAVAILABLE` /
    `VISUAL_RUNTIME_UNAVAILABLE` — đây là blocker, không phải deferral.
  - Cả hai PNG phải được nhìn bằng mắt trước khi kết luận: một lần chụp xanh vẫn
    có thể đầy ô tofu nếu font đang dùng không phủ dấu tiếng Việt.
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/chapter_closure/ test/features/activity_cards/`
  - Build/type-check/lint command when required: `flutter build apk --debug`
  - Required assertion evidence: chuỗi thực tế của tiêu đề, thân, và hai nút của
    hộp thoại

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
