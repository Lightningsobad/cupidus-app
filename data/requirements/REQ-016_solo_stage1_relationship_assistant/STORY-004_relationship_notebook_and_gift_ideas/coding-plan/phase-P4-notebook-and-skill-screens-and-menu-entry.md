# Phase P4 – Màn (2) Sổ tay, màn (3) Hồ sơ kỹ năng, và hai lối vào menu

## 1. Objective

Hai màn KHO xem/sửa/xoá tồn tại và tới được từ tab "Tôi", không màn nào có luồng
điền-trước và không màn nào có đường xuất/chia sẻ.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-notebook-and-skill-screens-and-menu-entry.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P3
- Parallelizable: YES (với P6)
- Write Scope:
  - `mobile/lib/features/context_notebook/presentation/screens/notebook_screen.dart`
  - `mobile/lib/features/context_notebook/presentation/screens/skill_profile_screen.dart`
  - `mobile/lib/features/context_notebook/presentation/widgets/context_inline_add_row.dart`
  - `mobile/lib/features/account/presentation/screens/me_screen.dart`
  - `mobile/lib/l10n/arb/app_vi.arb`, `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/test/features/context_notebook/notebook_screen_test.dart`
  - `mobile/test/features/context_notebook/skill_profile_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - hai hàng menu trong khối "Kho riêng của tôi" (lối vào nhóm KHO)
- Shared Interfaces Consumed:
  - `openNotebookScreen` / `openSkillProfileScreen` / `AskOnTheSpotSlot` (P3),
    `ContextNotebookRepository` (P1)
- Risk Surfaces:
  - Hồ sơ kỹ năng trượt về hình dạng CV
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` Phần B và Phần C
  - consumer contract: `../architecture/contract-summary.md` §3, §6
- Primary Inputs Summary:
  - requirements: AC-5, AC-6, AC-7, AC-8, AC-9, AC-11, AC-12, AC-25, AC-29
  - architecture: `../architecture/contract-summary.md` §3, §6
  - OQ constraints: none mới
  - upstream phase outputs: P1, P3
  - UX constraints: `../ux/uiux-spec.md` Phần B, Phần C, Phần E
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: hai màn KHO cùng hình dạng + lối vào chung của chúng
  - Source/Test File Count: 8
  - Split Required: NO
  - Split Rationale: hai màn là **cùng một pattern** áp lên hai loại mục (SKILL
    rule: một pattern trên N biến thể là một phase); lối vào của cả hai nằm trong
    cùng một khối của `me_screen.dart`, nên tách sẽ buộc hai phase cùng sửa file đó.

## 2. Required Reads

- `../ux/uiux-spec.md` Phần 0, Phần B, Phần C, Phần E
- `../architecture/contract-summary.md` §3, §6
- `../requirements/requirements.md` (AC-5..AC-12, AC-25, AC-29)

## 3. Tasks

- Màn (2) "Sổ tay người yêu": hai group header cố định "Sở thích" và "Sự kiện",
  hàng đơn giản + menu "..." **chỉ chứa Sửa/Xoá**, nút "+ tự thêm" cuối mỗi nhóm
  mở hàng nhập inline với segmented 2 lựa chọn ngay trong hàng đó. Không phụ đề
  kiểu "hãy điền để app hiểu người ấy hơn". Ô ghi chú tự do chỉ tồn tại **bên
  trong** một mục, không thành nhóm thứ ba.
- Màn (3) "Những gì bạn giỏi": danh sách chỉ-tên-kỹ-năng. Không sao, không điểm,
  không thanh mức độ, không huy hiệu cấp độ — kể cả khi design system có sẵn một
  pattern "kỹ năng game hoá", pattern đó bị cấm ở màn này. Khi rỗng, dựng
  `AskOnTheSpotSlot` với đích `skill` để dải chip mồi hiện trước mọi ô nhập.
- Trạng thái rỗng của cả hai màn: trung tính, danh sách trống + nút "+ tự thêm"
  luôn hiện, không câu mời gọi, không banner hối thúc.
- Thêm hai `_MenuRow` vào khối "Kho riêng của tôi" của `me_screen.dart`, cùng
  khối chứa hàng "Nhật ký riêng", gọi qua mặt tiền P3.
- Chuỗi giao diện (header, nhãn nút, nhãn nhóm) đi qua l10n; chuỗi **nội dung**
  (chip mồi, câu hỏi) vẫn đến từ gói asset của P2, không l10n hoá.

## 4. Acceptance Criteria

- Mở hai màn lần đầu: chỉ có danh sách (có thể rỗng) + "+ tự thêm"; không màn
  onboarding, không luồng điền-trước ở bất kỳ đâu (AC-5, AC-8).
- Trên màn Sổ tay chỉ tồn tại hai loại trường: sở thích và sự kiện. Không ô
  "nhận xét về người ấy", không nhãn tính cách do app gán (AC-6).
- Không icon/menu/hành động chia sẻ, copy toàn bộ, xuất file, hay Share Sheet ở
  bất kỳ đâu trên hai màn, kể cả trong menu "..." (AC-7).
- Sửa/xoá có hiệu lực ngay, không dialog kịch tính hoá (AC-9).
- Màn (3) khi rỗng hiện ≥4 chip mồi kỹ năng mềm trước mọi ô nhập, và các chip đó
  bình đẳng thị giác với chip khác — không nhóm phụ, không mờ hơn (AC-11).
- Không widget nào hiển thị mức độ/sao/điểm/hạng kỹ năng (AC-12).
- Không streak, huy hiệu, bảng xếp hạng, hay paywall trên hai màn (AC-29).
- Hai hàng menu mới tới được từ tab "Tôi" trong ứng dụng đang chạy.

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`
- Contracts or schemas: không đổi hợp đồng
- Notes or evidence: `test-results.md`, ảnh chụp visual-fidelity

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, widget + điều hướng
- Required levels:
  - unit: rút gọn — logic nhóm/sắp xếp danh sách
  - integration: widget test hai màn (rỗng, có dữ liệu, sửa, xoá)
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
  - visual inspection: có (xem dòng visual-fidelity dưới)
- Required checks: test khẳng định **vắng mặt** — không widget chia sẻ/xuất,
  không widget mức độ kỹ năng, không widget streak/huy hiệu
- Mobile discoverability / navigation integration: widget test khẳng định hai
  `_MenuRow` mới có mặt trong khối "Kho riêng của tôi" và mỗi hàng đẩy đúng màn
  của nó
- Minimum gates by risk surface: test bốn chip mồi + test vắng-mặt-mức-độ; thiếu
  → `CV_SHAPE_REGRESSION`
- Required regression or contract coverage: test hiện có của `me_screen` và của
  hàng "Nhật ký riêng" giữ nguyên xanh
- Evidence format: lệnh + kết quả trong `test-results.md`; ảnh chụp trong
  `visual-fidelity/`
- Per-story visual fidelity: REQUIRED
  - Design screen id + how it is rendered: hai màn KHO trên design canvas Cupid
    Chặng 1 — màn "Sổ tay người yêu" và màn "Những gì bạn giỏi"/hồ sơ kỹ năng.
    Người cài đặt tự phân giải và ghi lại `Design-Screen: <id>` **sau khi
    render** theo `contracts/design-fidelity-spec.md` "Design source detection
    and locking"; đừng đoán id từ tài liệu này.
  - How the implemented screen is captured: `capture-mobile-screen.sh` cho bản
    dựng; nếu một trong hai màn không tới được bằng điều hướng trong lần chụp,
    chụp bằng `RepaintBoundary` trong chính widget test của story thay vì hoãn.
  - NOTE: đây là gate riêng của story, kiểm ở review của story này; không bao giờ
    được thoả mãn bởi, hay hoãn sang, audit cấp requirement. Nếu không tới được
    thiết bị/runtime nào, phase chặn với `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/features/context_notebook test/features/account`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: log test vắng-mặt và ảnh chụp cặp design/bản dựng

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-10
