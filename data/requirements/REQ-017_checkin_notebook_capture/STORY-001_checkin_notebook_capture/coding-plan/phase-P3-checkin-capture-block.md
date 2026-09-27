# Phase P3 – Khối hỏi phụ trên màn check-in 23h và đường lưu tách đôi

## 1. Objective

Màn check-in 23h có một khối hỏi phụ tuỳ chọn ghi được **tối đa một** mục sổ tay, với
trạng thái thiếu-loại và trạng thái lỗi cục bộ, mà không bao giờ chặn đường lưu ảnh và
câu nhật ký.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-checkin-capture-block.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart`
  - `mobile/lib/features/phase_status/presentation/widgets/checkin_capture_block.dart` (mới)
  - `mobile/lib/features/context_notebook/presentation/widgets/context_inline_add_row.dart`
  - `mobile/test/features/phase_status/**` (suite check-in hiện có + một suite mới cho khối phụ)
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - tham số copy đã phân giải + seam ghi của `EveningCheckInSheet`
- Shared Interfaces Consumed:
  - đường ghi từ check-in của `ContextNotebookRepository` (P1)
  - gói `req017.checkin_capture.v1` và repository của nó (P2)
  - `eveningCheckInOriginRef(cardId)` (`evening_check_in_sheet.dart:35`)
- Risk Surfaces:
  - RS-2 Check-in save flow separation (BR-10)
  - RS-3 Per-check-in idempotency (AC-8/BR-12)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §1 KD-1, KD-4, §4
  - consumer contract: khối phụ chỉ ghi qua `ContextNotebookRepository`; không đọc thẻ
    lần thứ hai
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-1, AC-2, AC-3, AC-6, AC-7, AC-8,
    AC-12, AC-16, AC-17, BR-2, BR-3, BR-4, BR-8, BR-10, BR-12
  - architecture: `../architecture/solution.md` §1 KD-1, KD-4, §3 `UI Delivery Anchor`, §4
  - UX constraints: `../ux/uiux-spec.md` Phần A (mục 1-4), Phần B
  - upstream phase outputs: P1 đường ghi idempotent, P2 copy đã phân giải
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cluster — khối hỏi phụ và hành vi lưu của nó
  - Source/Test File Count: 3 source + 2 tệp test
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` (các AC/BR liệt kê trên)
- `../architecture/solution.md` §1 KD-1, KD-4, §3, §4
- `../ux/uiux-spec.md` Phần A, Phần B

## 3. Tasks

- Dựng `CheckinCaptureBlock`: divider mảnh phía trên, tiêu đề câu hỏi `body 17pt` cùng
  nhãn `Tuỳ chọn` (`caption 13pt`, `--ghost`), một ô nhập **một dòng**, và segmented
  hai lựa chọn ngay dưới. Đặt sau block nhật ký, trước CTA và dòng trấn an.
- Cho phép segmented khởi tạo **không lựa chọn nào được tô**: nới chỗ khởi tạo state ở
  `context_inline_add_row.dart:86-88` để `null` được giữ là `null` khi host yêu cầu.
  Không đổi hành vi mặc định của hàng "+ tự thêm".
- Truyền copy đã phân giải (P2) vào `EveningCheckInSheet` như một tham số; `null` nghĩa
  là không có nội dung nên khối phụ ẩn hẳn. Thêm một seam ghi tuỳ chọn cho test, và
  **không** dùng seam đó làm điều kiện hiện/ẩn khối (bài học STORY-012 §7).
- Sửa `_save()` theo KD-1: thử ghi sổ tay **trước** khi gọi `route(...)`, luôn gọi
  `route(...)` bất kể kết quả, và biến `navigator.pop()` thành có điều kiện — pop khi
  khối phụ đã ngã ngũ (ô trống/chỉ khoảng trắng, hoặc đã ghi xong), giữ màn khi đang
  chờ chọn loại hoặc vừa ghi lỗi.
- Thiếu loại: hiện dòng nhắc `caption 13pt` màu `--red` ngay dưới segmented, chỉ xuất
  hiện đúng lúc CTA bị chạm; chọn một loại ngay tại chỗ thì ghi luôn, không cần chạm
  CTA lần hai; xoá hết chữ thì dòng nhắc biến mất.
- Lỗi ghi: hiện câu lỗi + liên kết "Thử lại" trong chính khối, giữ nguyên ý đã gõ và
  loại đã chọn; "Thử lại" chỉ chạy lại phần sổ tay với cùng `originCheckInRef`.
- Giữ CTA ở trạng thái đang xử lý và vô hiệu hoá chạm tiếp trong lúc xử lý (AC-8).
- Không sửa `_openFromPayload` để đọc thẻ thêm lần nào; dùng `cardId`/`cardTitle` đã có.
- Không điền sẵn ô nhập từ bất kỳ nguồn nào, không nháp chia sẻ với ô nhật ký (AC-6).

## 4. Acceptance Criteria

- Khối hiện sau ảnh + nhật ký, trước CTA; hai chip mô tả của STORY-012 giữ nguyên vị
  trí và nghĩa (AC-1, AC-7).
- Ô trống hoặc chỉ khoảng trắng → không mục nào được tạo, không toast, không banner,
  màn đóng như trước (AC-2, AC-17).
- Có chữ nhưng chưa chọn loại → không mục nào được tạo, không lựa chọn nào bị tô tự
  động, journal route vẫn được gọi đúng một lần, dòng nhắc hiện ra (AC-16, BR-4, BR-10).
- Chọn loại sau khi thấy dòng nhắc → mục được tạo ngay, không cần chạm CTA lần hai.
- Phần sổ tay lỗi → câu lỗi + "Thử lại" trong khối, ý và loại còn nguyên, journal route
  vẫn được gọi đúng một lần (AC-12).
- Chạm CTA hai lần liên tiếp → đúng một mục (AC-8).
- Không trường ngày, không trường chi tiết, không lựa chọn thứ ba, không trường đánh
  giá trong khối (AC-3, AC-17).

## 5. Planned Outputs

- Code directories or files: như `Write Scope`
- Contracts or schemas: tham số copy + seam ghi của `EveningCheckInSheet`
- Notes or evidence: `coding-plan/test-results.md`, ảnh chụp visual fidelity

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter `mobile`, màn check-in 23h
- Required levels:
  - unit: máy trạng thái của khối (trống / thiếu loại / đã ghi / lỗi)
  - integration: widget test `EveningCheckInSheet` với repository giả
  - mobile build/type-check/static-analysis: `flutter analyze lib test` cho tệp đã sửa
    (so delta, baseline repo khác 0)
  - visual inspection: khối phụ dựng đúng thứ tự so với block nhật ký và CTA
- Required checks: journal route được gọi đúng một lần trong **cả bốn** nhánh trạng thái
- Mobile discoverability / navigation integration: không điểm vào mới; khối nằm trong
  màn check-in sẵn có, vốn chỉ tới được từ nhắc 23h
- Minimum gates by risk surface: RS-2, RS-3 theo `../architecture/solution.md` §4
- Required regression or contract coverage: suite `evening_check_in_sheet_test.dart`
  hiện có (kể cả test AC-18 `journalAvailable: false`) phải xanh không đổi assertion.
  Khối mới làm màn dài thêm: nếu `tap()` của test cũ trượt trong khung mặc định
  800x600, tăng `surfaceSize` hoặc scroll tới CTA — **không** sửa kỳ vọng của
  STORY-012 để lách.
- Evidence format: lệnh test + kết quả trong `coding-plan/test-results.md`
- Per-story visual fidelity (REQUIRED):
  - Design screen id + how it is rendered: `23h-vua-ve-j8`, dựng bằng
    `capture-mobile-screen.sh --mode=design`
  - How the implemented screen is captured: màn check-in chỉ tới được từ nhắc 23h nên
    không điều hướng tới được trong app đang chạy; chụp bằng `RepaintBoundary` trong
    chính widget test của phase này. Tên tệp `implemented-*.png` phải mở đầu bằng
    chính canvas id `23h-vua-ve-j8`, nếu không cổng fidelity không ghép được cặp.
    Kiểm tra bằng `.claude/hooks/lib/visual_fidelity.py --dir <dir> --stage <stage>`.
  - NOTE: đây là cổng riêng của story, kiểm ở review của story này; không hoãn sang
    audit cấp requirement. Không chụp được thì phase block với
    `MOBILE_RUNTIME_UNAVAILABLE` / `VISUAL_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests/regression/contract checks: chỉ các suite `phase_status`; không chạy
    toàn bộ `flutter test`
  - Required assertion evidence: đếm lời gọi journal route và đếm hàng sổ tay cho từng
    nhánh trạng thái
  - Trước khi ghi marker hoàn thành, `git status` phải sạch với ảnh PNG của story khác;
    nếu lần chạy test làm bẩn chúng, phục hồi trước.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-28
