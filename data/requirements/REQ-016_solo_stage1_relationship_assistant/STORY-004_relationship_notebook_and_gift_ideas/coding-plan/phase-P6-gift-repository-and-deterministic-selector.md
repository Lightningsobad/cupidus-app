# Phase P6 – Repository quà + bộ chọn tất định

## 1. Objective

Gợi ý quà được sinh ra tất định từ ngữ cảnh đã ghi, xoay vòng khi hết tập, và
nhánh tự làm biết đọc hồ sơ kỹ năng — tất cả không tạo kho lưu trữ thứ hai.

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-gift-repository-and-deterministic-selector.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P5
- Parallelizable: YES (với P4)
- Write Scope:
  - `mobile/lib/features/gift_ideas/data/gift_repository.dart`
  - `mobile/lib/features/gift_ideas/domain/gift_selector.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/gift_ideas/gift_selector_test.dart`
  - `mobile/test/features/gift_ideas/gift_repository_test.dart`
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
  - `GiftRepository` (đọc ba gói + đọc ngữ cảnh), `GiftSelector`
- Shared Interfaces Consumed:
  - `ContextNotebookReader` (P3 công bố, P1 hiện thực), ba gói quà (P5)
- Risk Surfaces:
  - Số lượng ý tưởng bị đóng băng thành hằng số
  - Kho thứ hai mọc ra ngoài hub
  - Gợi ý mất tính tất định
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §3, §6
  - consumer contract: `../architecture/contract-summary.md` §6 (cấm bảng riêng, cấm con trỏ lưu)
- Primary Inputs Summary:
  - requirements: AC-16, AC-17, AC-18, AC-19, AC-21, AC-27, AC-28, AC-33
  - architecture: `../architecture/contract-summary.md` §3, §6
  - OQ constraints: R-15b (N là thuộc tính dữ liệu)
  - upstream phase outputs: repository kho ngữ cảnh (P1), ba gói quà (P5)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một tầng đọc/chọn của luồng quà, gồm cả nhánh tự làm
  - Source/Test File Count: 5
  - Split Required: NO
  - Split Rationale: nhánh tự làm là một mục dữ liệu trong `gift_taxonomy`, không
    phải một tầng riêng; tách nó ra sẽ buộc hai phase cùng sửa `gift_selector.dart`
    mà không tách được hành vi nào.

## 2. Required Reads

- `../architecture/contract-summary.md` §3, §6
- `../requirements/requirements.md` (AC-16..AC-21, AC-27, AC-28, AC-33)

## 3. Tasks

- `GiftRepository`: nạp ba gói qua `ContentPackageLoader`, đọc ngữ cảnh qua
  `ContextNotebookReader`. **Không** bảng Drift mới, **không** DAO, **không** cột
  "quà đã lưu" (`contract-summary.md` §6).
- `GiftSelector.suggest(...)`: từ ngữ cảnh đã ghi → tra `gift_index` → lọc theo
  nhánh và mức công sức đang chọn → xếp hạng tất định (khoá phụ là `id` bền để
  hai ý tưởng cùng điểm luôn ra cùng thứ tự). Không `Random`, không `DateTime.now()`,
  không hash phụ thuộc thứ tự chèn.
- Khi ngữ cảnh rỗng: vẫn trả về một tập gợi ý chung hợp lệ, không trả rỗng và
  không yêu cầu điền trước (AC-16, AC-21).
- Nhánh `handmade`: giao ngữ cảnh với hồ sơ kỹ năng của người dùng; khi hồ sơ
  kỹ năng rỗng, trả gợi ý tự làm không đòi kỹ năng, không trả rỗng (AC-19, AC-27).
- Hết tập: `nextBatch` quay vòng `index % package.length`. Con trỏ xoay vòng chỉ
  sống trong bộ nhớ của phía gọi trong một vòng đời màn — **không** lưu xuống đĩa
  (AC-28, `contract-summary.md` §6).
- Đăng ký `GiftRepository` và `GiftSelector` trong `service_locator.dart`.

## 4. Acceptance Criteria

- Cùng một trạng thái ngữ cảnh + cùng bộ lọc → cùng danh sách theo cùng thứ tự,
  kể cả sau khi khởi động lại tiến trình test (AC-28).
- Chạy toàn bộ kịch bản với một gói N=1 và một gói N=200: mọi assert giữ nguyên,
  không lỗi tràn chỉ số, không hành vi "đã hết ý tưởng" (AC-33, R-15b).
- Ngữ cảnh rỗng vẫn cho danh sách gợi ý không rỗng (AC-16, AC-21).
- Nhánh tự làm với hồ sơ kỹ năng rỗng vẫn cho danh sách không rỗng (AC-19, AC-27).
- `features/gift_ideas/**` không chứa `Table`, `DAO`, `drift`, `Random`,
  `DateTime.now`, hay import HTTP/SDK mô hình; grep khẳng định điều đó
  (AC-17, AC-18).

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`
- Contracts or schemas: không tạo schema mới (đây là điểm chính của phase)
- Notes or evidence: `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng domain/dữ liệu
- Required levels:
  - unit: xếp hạng tất định, lọc theo nhánh/mức công sức, quay vòng, nhánh tự làm
  - integration: selector ↔ repository kho ngữ cảnh thật (in-memory Drift)
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
- Required checks: chạy cùng bộ test hai lần trong hai tiến trình và so khớp thứ
  tự đầu ra; grep chống-kho-thứ-hai và chống-nguồn-ngẫu-nhiên
- Minimum gates by risk surface: test N=1/N=200 (thiếu → `N_COUPLING`); grep
  không-bảng-mới (thiếu → `SECOND_HUB`); test lặp-lại-cùng-thứ-tự (thiếu →
  `NONDETERMINISM`)
- Required regression or contract coverage: test P1 và P5 giữ nguyên xanh
- Evidence format: lệnh + kết quả tóm tắt trong `test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn nào
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/features/gift_ideas test/features/context_notebook`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: log hai lần chạy cho thứ tự giống nhau, và log
    lần chạy với gói N=1 và N=200

## 7. Status

- Status: IMPLEMENTED_PENDING_COMMIT
- Last updated: 2026-09-11
- Evidence: `test-results.md` → "Phase P6 — Gift repository and deterministic
  selector" (two-process same-order log, N=1/N=200 log, no-second-store scan,
  `flutter analyze lib test` = 219 info / 0 error vs the 217 P4 baseline)
