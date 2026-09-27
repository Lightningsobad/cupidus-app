# Phase P4 – Nhãn xuất xứ trên màn Sổ tay và ranh giới của nó

## 1. Objective

Mục ghi từ check-in hiện trong đúng nhóm sẵn có với một dòng nhãn xuất xứ biết suy
biến, sửa/xoá bằng đúng thao tác cũ, và nhãn đó không rò ra bất kỳ bề mặt nào khác.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-notebook-origin-label.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/context_notebook/domain/checkin_origin_resolver.dart` (mới)
  - `mobile/lib/features/context_notebook/presentation/screens/notebook_screen.dart`
  - `mobile/test/features/context_notebook/**` (suite màn Sổ tay + test resolver)
  - `mobile/test/features/gift_ideas/**` chỉ assertion không-rò-nhãn
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
  - resolver nhãn xuất xứ và phép dò thẻ theo lô (chỉ đọc)
- Shared Interfaces Consumed:
  - trường xuất xứ trên `NotebookEntry` (P1)
  - hai item nhãn xuất xứ của gói `req017.checkin_capture.v1` (P2)
  - `ActivityCardRepository.cardById`
    (`mobile/lib/features/activity_cards/domain/activity_card_repository.dart:26`)
- Risk Surfaces:
  - RS-5 Origin label degrade (AC-9/BR-6)
  - RS-6 Notebook consumer non-regression (BR-11, AC-10/AC-13)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §1 KD-2, §4
  - consumer contract: nhãn xuất xứ chỉ hiện trên hàng mục ở màn Sổ tay
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-4, AC-5, AC-9, AC-10, AC-11,
    AC-13, AC-15, BR-6, BR-7, BR-9, BR-11
  - architecture: `../architecture/solution.md` §1 KD-2, §3 `UI Delivery Anchor`, §4
  - UX constraints: `../ux/uiux-spec.md` Phần C, Phần E
  - upstream phase outputs: P1 trường xuất xứ, P2 hai item nhãn
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cluster — hiển thị và suy biến của nhãn xuất xứ
  - Source/Test File Count: 2 source + 3 tệp test
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` (các AC/BR liệt kê trên)
- `../architecture/solution.md` §1 KD-2, §3, §4
- `../ux/uiux-spec.md` Phần C, Phần E

## 3. Tasks

- Viết resolver nhận danh sách mục + một phép dò thẻ theo lô (chỉ đọc, nhận tập
  `origin_card_id` phân biệt và trả về tập id còn đọc được) rồi trả nhãn cho từng mục:
  ảnh chụp tên thẻ khi id còn dò được và ảnh chụp khác `null`; ngược lại là nhãn suy
  biến. Lỗi đọc của phép dò được coi như không đọc được, không bao giờ ném lên UI (KD-2).
- Gọi phép dò **một lượt cho cả màn**, không phải một truy vấn mỗi hàng.
- Thêm vào `_NotebookRow` một dòng nhãn `caption 13pt` màu `--ghost` ngay dưới dòng nội
  dung/`detail`: không chip, không viền, không nền riêng, không icon, không chạm được.
- Chỉ mục có `origin_check_in_ref != null` mới có dòng nhãn; mục tự thêm không đổi gì.
- Loại `event` vào đúng nhóm "Sự kiện" sẵn có; không tạo nhóm thứ ba (AC-4).
- Menu "..." giữ đúng hai lựa chọn Sửa/Xoá; không thêm "Xem xuất xứ"/"Xem buổi hẹn
  gốc", không thêm xuất/chia sẻ (AC-15, BR-9).
- Không đọc, không hiển thị đường dẫn ảnh check-in ở bất kỳ đâu trong hàng mục.

## 4. Acceptance Criteria

- Mục từ check-in nằm đúng nhóm theo loại, mang nhãn "từ buổi hẹn <tên thẻ>" (AC-4).
- Thẻ không còn dò được → nhãn suy biến "từ một buổi hẹn", mục vẫn hiện đầy đủ và vẫn
  sửa/xoá được (AC-9).
- Sửa nội dung hoặc đổi loại → thay đổi có hiệu lực ngay, chữ nhãn không đổi (AC-5).
- Xoá mục → mục biến mất bằng đúng luồng xoá cũ, không dialog thêm (AC-5).
- Mục tự thêm không có dòng nhãn nào (BR-11).
- Bề mặt gợi ý quà hiện tên mục nhưng **không** có nhãn xuất xứ hay tên thẻ (AC-10).
- Widget và thông báo của STORY-012 không chứa tên mục hay nhãn xuất xứ (AC-13, BR-7).
- Xoá mục nhật ký không đổi hiển thị của mục sổ tay và ngược lại (AC-11).

## 5. Planned Outputs

- Code directories or files: như `Write Scope`
- Contracts or schemas: resolver nhãn xuất xứ
- Notes or evidence: `coding-plan/test-results.md`, ảnh chụp visual fidelity

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter `mobile`, màn Sổ tay người yêu
- Required levels:
  - unit: resolver cho cả bốn trường hợp (có tên / ảnh chụp `null` / id không dò được /
    phép dò ném lỗi)
  - integration: widget test màn Sổ tay cho nhãn đầy đủ, nhãn suy biến, và mục tự thêm
    không nhãn
  - mobile build/type-check/static-analysis: `flutter analyze lib test` cho tệp đã sửa
    (so delta, baseline repo khác 0)
  - visual inspection: dòng nhãn là caption mờ, không phải chip/badge
- Required checks: menu "..." vẫn đúng hai lựa chọn; không chuỗi xuất/chia sẻ nào
- Minimum gates by risk surface: RS-5, RS-6 theo `../architecture/solution.md` §4
- Required regression or contract coverage: suite màn Sổ tay và suite gợi ý quà hiện có
  phải xanh; thêm assertion nhãn xuất xứ **vắng mặt** trên bề mặt gợi ý quà (AC-10) và
  trên bề mặt widget/thông báo (AC-13)
- Evidence format: lệnh test + kết quả trong `coding-plan/test-results.md`
- Per-story visual fidelity (REQUIRED):
  - Design screen id + how it is rendered: `2-so-tay-nguoi-yeu`, dựng bằng
    `capture-mobile-screen.sh --mode=design`
  - How the implemented screen is captured: màn Sổ tay tới được từ nhóm KHO / tab Sổ tay
    nên chụp bằng `capture-mobile-screen.sh` trên app đang chạy; nếu không có thiết bị,
    chụp `RepaintBoundary` trong widget test của phase này. Tên tệp `implemented-*.png`
    phải mở đầu bằng chính canvas id `2-so-tay-nguoi-yeu`. Kiểm tra bằng
    `.claude/hooks/lib/visual_fidelity.py --dir <dir> --stage <stage>`.
  - NOTE: đây là cổng riêng của story, kiểm ở review của story này; không hoãn sang
    audit cấp requirement. Không chụp được thì phase block với
    `MOBILE_RUNTIME_UNAVAILABLE` / `VISUAL_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests/regression/contract checks: chỉ các suite `context_notebook` và
    assertion không-rò-nhãn ở `gift_ideas`; không chạy toàn bộ `flutter test`
  - Required assertion evidence: hai chuỗi nhãn ứng với hai nhánh dò thẻ, và nhãn vắng
    mặt trên bề mặt tiêu thụ
  - Trước khi ghi marker hoàn thành, `git status` phải sạch với ảnh PNG của story khác.

## 7. Status

- Status: DONE
- Last updated: 2026-09-28
- Bằng chứng: `test-results.md` mục `P4 — Nhãn xuất xứ trên màn Sổ tay người yêu`
  (Gate 1–6, tất cả exit 0) và `../visual-fidelity/visual-fidelity-report.md`
  Phần II (`VISUAL_FIDELITY: PASS`).
- Không cần mở rộng Write Scope: hai tham số mới của `NotebookScreen`
  (`originCopy`, `cardProbe`) đều tuỳ chọn và tự giải mặc định phía trong màn,
  nên `context_notebook_entry_point.dart` không phải sửa.
