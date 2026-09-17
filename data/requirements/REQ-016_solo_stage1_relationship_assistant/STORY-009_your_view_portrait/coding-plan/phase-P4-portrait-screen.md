# Phase P4 – Màn (8): bảng câu hỏi và chân dung có nhãn xuất xứ

## 1. Objective

Màn chân dung tồn tại với hai trạng thái trên cùng một route nội bộ: bảng câu hỏi
từng-câu-một có nút Bỏ qua, và trang kết quả cuộn được với nhãn xuất xứ ghim trên
đầu, mỗi khối phần kết bằng một hàng "Câu để hỏi" khác tông. Không chỗ nào thúc
ép hoàn thành.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-portrait-screen.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2, P3
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/your_view_portrait/presentation/cubit/your_view_portrait_cubit.dart`
  - `mobile/lib/features/your_view_portrait/presentation/screens/your_view_portrait_screen.dart`
  - `mobile/lib/features/your_view_portrait/presentation/widgets/portrait_question_step.dart`
  - `mobile/lib/features/your_view_portrait/presentation/widgets/portrait_section_block.dart`
  - `mobile/lib/l10n/app_*.arb` (chỉ chuỗi khung: tiêu đề, "Bỏ qua", "Tiếp",
    nhãn xuất xứ, nhãn "Câu để hỏi")
  - `mobile/test/features/your_view_portrait/your_view_portrait_screen_test.dart`
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
  - không có giao diện liên lane; widget màn là **library-private**, không export,
    không `routeName` (`../architecture/contract-summary.md` mục 3)
- Shared Interfaces Consumed:
  - `composePortrait(...)` (P3)
  - `PortraitAnswerRepository`, `recordAnsweredQuestion(...)` (P2)
  - gói nội dung qua `ContentPackageLoader` (P1)
- Risk Surfaces:
  - Nhãn xuất xứ trong bố cục (AC-6..AC-8)
  - Bỏ dở, không thúc ép (AC-25..AC-28)
  - Ranh giới sổ tay R-1f (AC-22/AC-23)
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` mục 2 và 3;
    `../architecture/contract-summary.md` mục 3 và 6
  - consumer contract: P5 là consumer duy nhất (mở màn qua điểm vào)
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-6..AC-8, AC-22, AC-23,
    AC-25..AC-28; AC-1, AC-3, AC-4, AC-6 của `story_master.md`
  - architecture: `../architecture/contract-summary.md` mục 3, 6;
    `../architecture/solution.md` mục 3 (UI Delivery Anchor) và mục 4
  - OQ constraints: R-15b — không widget nào được đọc độ dài gói để vẽ tiến độ
  - upstream phase outputs: composer của P3, repository và cửa sổ tay của P2
  - UX constraints, if truly required: `../ux/uiux-spec.md` mục 2 (từng câu một,
    chỉ báo vị trí chỉ trong một phiên, không badge liên phiên) và mục 3
  - review findings: none yet
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: một cụm — "một màn, hai trạng thái của cùng một luồng"
  - Source/Test File Count: 6 source/test (ARB là chuỗi khung của cùng lát)
  - Split Required: NO
  - Split Rationale: N/A

## 2. Required Reads

- `../requirements/requirements.md` (AC-6..AC-8, AC-22, AC-23, AC-25..AC-28)
- `../architecture/contract-summary.md` mục 3 và 6
- `../architecture/solution.md` mục 3 và 4
- `../ux/uiux-spec.md` mục 2 và 3
- đầu ra P2 và P3 như liệt kê ở trên

## 3. Tasks

- `YourViewPortraitCubit`: nạp ba gói một lần, đọc câu trả lời, suy ra câu đang
  dở, chuyển giữa trạng thái `questioning` và `portrait`. Con trỏ câu-để-hỏi giữ
  trong cubit, **không** ghi xuống DB.
- Màn: `class _YourViewPortraitScreen` (hoặc tương đương) **không export**,
  **không** hằng `routeName`, không xuất hiện trong `routes:` của
  `mobile/lib/app/cupid_app.dart`. Đây là cách AC-3 được bảo đảm ở mức biên dịch,
  không phải bằng quy ước điều hướng.
- Bảng câu hỏi: mỗi lần một câu; hàng chip từ `chips[]`; ô nhập tự do chỉ khi
  `allow_free_text`; nút "Bỏ qua" cùng hàng với "Tiếp". Chỉ báo vị trí dạng
  "câu k/n" được phép **chỉ trong phiên hiện tại**; không progress bar mang nghĩa
  phần trăm hoàn thành, không badge "chưa xong" ở bất kỳ đâu.
- Câu có `target` là `notebook.*`: khi trả lời, gọi `recordAnsweredQuestion(...)`
  với `entryPointId: 'your_view_portrait'` và `questionId` thật. Cờ "sẽ lưu vào
  sổ tay" là **ngầm** — không hộp thoại xác nhận riêng.
- Trang kết quả: nhãn xuất xứ "dựa trên những gì BẠN nhập" **ghim trên đầu**,
  luôn thấy khi cuộn (AC-1 story, AC-6..AC-8). Mỗi phần là một khối cách nhau
  `--r-sm`, kết bằng hàng "Câu để hỏi" khác tông kèm icon `help_outline`.
- Thoát màn ở bất kỳ câu nào rồi mở lại: vào đúng câu đang dở, không banner
  "hoàn tất chân dung của bạn" ở bất cứ đâu trong app.
- Mọi chuỗi nội dung đến từ gói; ARB chỉ chứa chuỗi khung. Không nhãn xuất xứ nào
  bị hạ cấp thành tooltip hay banner có thể đóng (mục 6 hợp đồng).

## 4. Acceptance Criteria

- Mở màn ở trạng thái chưa trả lời gì: hiện câu đầu tiên, có nút Bỏ qua, có nhãn
  xuất xứ ở đầu (AC-1 story).
- Trả lời hết: trang kết quả hiện, mỗi phần kết bằng một câu để hỏi, không điểm
  số/xếp hạng nào (AC-3, AC-4 story).
- Cuộn trang kết quả xuống cuối: nhãn xuất xứ vẫn thấy (AC-6..AC-8).
- Trả lời một phần rồi thoát và mở lại: vào đúng câu đang dở, không thông điệp
  thúc ép, không badge (AC-6 story, AC-25, AC-26).
- Trả lời một câu `notebook.interest`: mục sổ tay xuất hiện; trả lời một câu
  `portrait.guess`: không mục sổ tay nào (AC-5 story, AC-23).
- Widget màn không export và không có trong `routes:` — kiểm bằng test ở P5.

## 5. Planned Outputs

- Code directories or files:
  `mobile/lib/features/your_view_portrait/presentation/`, `mobile/lib/l10n/`
- Contracts or schemas: none (không giao diện liên lane)
- Requirement configuration guide updates: none
- Notes or evidence: kết quả widget test + ảnh chụp visual fidelity

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter widget test
- Required levels (omit N/A levels):
  - unit: chuyển trạng thái của cubit, suy ra câu đang dở
  - integration: widget test toàn màn với DB trong bộ nhớ và gói thật
  - mobile build/type-check/static-analysis: `flutter gen-l10n` trước, rồi
    `flutter analyze lib test` so với nền khác 0 đã biết (222 cảnh báo, 0 lỗi),
    tiêu chí là không lỗi mới
  - visual inspection: bắt buộc, xem mục visual fidelity bên dưới
- Required checks: `flutter gen-l10n` phải chạy trước mọi lệnh khác trong worktree
  mới, nếu không mã l10n sinh ra chưa tồn tại và mọi thứ đỏ giả
- Mobile discoverability / navigation integration: màn này **cố ý không** khám phá
  được; việc kiểm tính khám phá được thuộc P5 và kiểm điều ngược lại (không có
  đường vào nào ngoài điểm vào duy nhất)
- Minimum gates by risk surface:
  - Nhãn xuất xứ trong bố cục: widget test cuộn tới cuối rồi khẳng định nhãn vẫn
    `findsOneWidget`
  - Bỏ dở, không thúc ép: test mở lại vào đúng câu đang dở; test khẳng định không
    widget nào chứa chuỗi tiến độ liên phiên
  - Ranh giới sổ tay R-1f: test khẳng định `portrait.guess` không tạo mục sổ tay
- Required regression or contract coverage: `flutter test test/features/context_notebook/`
  và test của P1..P3 vẫn xanh
- Evidence format: lệnh đã chạy + dòng tóm tắt, dán vào `coding-plan/test-results.md`;
  ảnh chụp đặt dưới `../visual-fidelity/`
- Per-story visual fidelity (REQUIRED — phase này dựng UI):
  - Design screen id + cách render: phân giải và khoá `design_source` theo
    `contracts/design-fidelity-spec.md` mục "Design source detection and locking".
    `../ux/uiux-spec.md` ghi `DESIGN_SOURCE_NOT_DETECTED` là bình thường ở giai
    đoạn spec; nếu sau khi phân giải vẫn không có design source, ghi
    `DESIGN_SOURCE_NOT_DETECTED` kèm bằng chứng đã thử, đừng bỏ trống.
  - Cách chụp màn đã hiện thực: màn (8) **khoá vị trí** và chỉ có nội dung sau khi
    đã trả lời, nên `capture-mobile-screen.sh` trên thiết bị không tới được nó.
    Chụp bằng `RepaintBoundary` ngay trong
    `your_view_portrait_screen_test.dart`, hai trạng thái: một câu hỏi đang mở, và
    trang kết quả đã cuộn. Harness phải bọc `CupidAppBackground` và nạp
    MaterialIcons của framework, nếu không icon ra ô tofu và ảnh vô giá trị.
    Kiểm mắt thường ảnh đã chụp: một lần chạy xanh vẫn có thể ra chữ tofu.
  - NOTE: đây là cổng riêng của story, kiểm ở review của chính nó. Không được
    hoãn sang audit cấp requirement. Nếu không chụp được, phase chặn với
    `MOBILE_RUNTIME_UNAVAILABLE` — là blocker, không phải hoãn.
- Verification strategy:
  - Targeted tests/regression/contract checks: `your_view_portrait_screen_test.dart`
    + test của P1..P3 + `test/features/context_notebook/`
  - Build/type-check/lint command when required: `flutter gen-l10n` rồi
    `flutter analyze lib test`
  - Required assertion evidence: assertion nhãn xuất xứ sau khi cuộn, và assertion
    mở lại đúng câu đang dở

## 7. Status

- Status: DONE
- Last updated: 2026-09-17
