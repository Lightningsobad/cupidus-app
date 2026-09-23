# Phase P2 – Khối lồng + điểm vào trong chi tiết thẻ

## 1. Objective

Dựng khối "Cảm ơn + chốt việc kế tiếp" như một khối con lồng dưới cùng vùng
ảnh/ghi chú của chi tiết thẻ *Đã đi rồi*, và **gắn nó vào bề mặt đã có** để nó
tự hiện đúng một lần. Đây là phase điểm-vào của story.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-block-shell-and-entry-point.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/activity_cards/thank_you/presentation/`
    (widget khối, cubit, state)
  - màn chi tiết thẻ của STORY-001: **chỉ** thêm điểm gắn khối
  - `mobile/test/features/activity_cards/thank_you/`
- Impacted Runtime Service/App:
  - Name: mobile
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - khung khối + khe cắm cho ba phần (P3, P4, P5 cắm section vào đây)
- Shared Interfaces Consumed:
  - service vòng đời lượt kích hoạt (P1)
  - mẫu container khối lồng của STORY-006
- Risk Surfaces:
  - Lượt kích hoạt một lần trọn đời
  - Không phạt im lặng
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` mục 1, 2, 6
  - consumer contract: P3/P4/P5 thêm section vào khe cắm của khối
- Primary Inputs Summary:
  - requirements: AC-1, AC-3, AC-6, AC-7, AC-25, AC-28, BR-1
  - architecture: `../architecture/solution.md` mục 3 `UI Delivery Anchor`, mục 4
  - upstream phase outputs: service vòng đời của P1
  - UX constraints: `../ux/uiux-spec.md` mục 1 (vị trí), mục 2 (header + icon
    đóng), mục 6 (đồng cư với STORY-006)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: khung khối + luật trình bày một lần + điểm gắn
  - Source/Test File Count: ~6 (widget khối, cubit, state, sửa màn chi tiết
    thẻ, widget test, visual fidelity test)
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (Nhóm A)
- `../architecture/solution.md`
- `../ux/uiux-spec.md` mục 1, 2, 6

## 3. Tasks

- Dựng widget khối dùng **đúng mẫu container** của STORY-006 (bo góc `--r-sm`,
  nền tách lớp, thụt trái `md`) — không phát minh mẫu thị giác mới.
- Header: tiêu đề "Cảm ơn + chốt việc kế tiếp" (`body 17pt/600`) + icon `close`
  biến thể line, vùng chạm ≥44pt, không hộp thoại xác nhận.
- Cubit: khi chi tiết thẻ mở, hỏi `isEligible` của P1; nếu đúng thì hiện khối
  **và gọi `consume` ngay tại lần trình bày đầu** (không đợi người dùng thao
  tác — AC-3 tính theo lần hiện, không theo lượt dùng).
- Gắn khối vào **dưới cùng** vùng ảnh/ghi chú của chi tiết thẻ, bên trong luồng
  "ghi lại"; giữ mức thị giác "hành động phụ", không thêm CTA cấp thẻ (AC-6,
  AC-7, BR-1).
- Ba khe cắm rỗng cho phần 1/2/3 để P3, P4, P5 cắm vào — P2 không dựng nội dung
  ba phần.

## 4. Acceptance Criteria

- Khối hiện đúng một lần; mở lại chi tiết thẻ sau đó thì không hiện (AC-3).
- Đóng bằng icon `close` tương đương đã tiêu thụ lượt — khối không quay lại, và
  **không có** đường nào từ UI gọi lại nó.
- Khối không hiện trong ngày thẻ chuyển *Đã đi rồi* (AC-2).
- Chi tiết thẻ vẫn chỉ có **một** hành động chính cấp thẻ (AC-6).
- Không huy hiệu thiếu, bộ đếm bỏ lỡ, hay dấu chưa-hoàn-thành nào xuất hiện sau
  khi đóng khối (AC-25, AC-28).

## 5. Planned Outputs

- Code directories: `.../thank_you/presentation/`, điểm gắn trong màn chi tiết
  thẻ
- Notes or evidence: ảnh chụp khối (trạng thái khung, chưa có nội dung ba phần)

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, màn chi tiết thẻ *Đã đi rồi*
- Required levels:
  - unit: cubit (eligible → hiện + consume; không eligible → không hiện)
  - integration: widget test trên màn chi tiết thẻ
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
  - visual inspection: có — xem mục visual fidelity bên dưới
- Required checks:
  - Mở chi tiết thẻ hai lần liên tiếp: lần đầu có khối, lần sau không.
  - Bấm icon `close` rồi mở lại: không có khối.
  - Thẻ chuyển *Đã đi rồi* hôm nay: không có khối.
- Mobile discoverability / navigation integration: khối phải xuất hiện **tự
  động** trong luồng "ghi lại" của chi tiết thẻ; test phải khẳng định nó được
  tìm thấy từ màn chi tiết thẻ, **không** qua một route trực tiếp riêng. Story
  không thêm destination, menu, hay tab mới.
- Minimum gates by risk surface: mỗi risk surface ở `## 1B` có ít nhất một
  assertion trực tiếp.
- Evidence format: lệnh + kết quả test thật ghi vào `coding-plan/test-results.md`
- Per-story visual fidelity: REQUIRED
  - Design screen id + how it is rendered: giải quyết id màn thiết kế **sau khi
    render**, theo `contracts/design-fidelity-spec.md` mục "Design source
    detection and locking". Canvas REQ-016 dùng id dạng slug — **không** truyền
    `--label`.
  - How the implemented screen is captured: `capture-mobile-screen.sh` trên màn
    chi tiết thẻ *Đã đi rồi* có khối đang hiện.
  - NOTE: đây là gate riêng của story này, kiểm ở review của chính nó; không
    được hoãn sang audit cấp requirement. Nếu không chạm được device/runtime,
    phase chặn với `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests: test của sub-feature + test hiện có của màn chi tiết thẻ.
  - Build/type-check: `flutter analyze lib test`; gate là **không thêm error
    mới** (baseline repo khác 0).
  - Required assertion evidence: trích dòng kết quả thật.
  - **Bẫy đã biết:** thêm hàng vào chi tiết thẻ có thể đẩy phần tử ra ngoài
    khung mặc định 800x600 của `testWidgets`, làm `tap()` của các test **khác**
    trượt. Chạy lại test hiện có của màn chi tiết thẻ, và chỉnh kích thước
    surface trong test thay vì đổi bố cục sản phẩm.
  - **Bẫy đã biết:** kiểm `git status` trước khi báo hoàn tất — chạy bộ test
    mobile có thể ghi đè PNG visual-fidelity của story khác.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-20
