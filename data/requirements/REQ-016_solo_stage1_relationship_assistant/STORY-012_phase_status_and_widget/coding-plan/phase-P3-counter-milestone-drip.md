# Phase P3 – Bộ đếm "của cải đang lớn", cột mốc J12, và nhịp nhỏ giọt

## 1. Objective

Ba chính sách chọn-cái-gì-hiện-trong-khoảng-lặng, viết sao cho **không thể** trở
thành streak trá hình: bộ đếm là lực lượng một tập, cột mốc dừng ở "nhận ra", và
nhỏ giọt cạn thì im lặng.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-counter-milestone-drip.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: YES (song song P2, P6)
- Write Scope:
  - `mobile/lib/features/phase_status/domain/wealth_counter.dart`
  - `mobile/lib/features/phase_status/domain/milestone_resolver.dart`
  - `mobile/lib/features/phase_status/domain/drip_cadence_policy.dart`
  - `mobile/test/features/phase_status/wealth_counter_test.dart`
  - `mobile/test/features/phase_status/milestone_resolver_test.dart`
  - `mobile/test/features/phase_status/drip_cadence_policy_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
- Shared Interfaces Produced:
  - `WealthCounter`, `MilestoneResolver`, `DripCadencePolicy`
- Shared Interfaces Consumed:
  - `ActivityCardRepository.countsByStatus()` (chỉ đọc, không mở rộng)
  - P1 `phase_content_repository.dart` (kho nhỏ giọt + `thresholds`)
  - P2 `PhaseStatusPrefs`
- Risk Surfaces:
  - `COUNTER-STREAK`
  - `DRIP-CADENCE`
- Source Of Truth:
  - authoritative artifact or convention: `../requirements/` nhóm F, G + BR-5..BR-9
  - consumer contract: P4 (payload pha `quiet`) và P8 (bề mặt màn (1))
- Primary Inputs Summary:
  - requirements: AC-20..AC-29, AC-38, BR-5, BR-6, BR-7, BR-8, BR-9, BR-16
  - architecture: `../architecture/solution.md` §4 bảng rủi ro
    (`COUNTER-STREAK`, `DRIP-CADENCE`), `../architecture/contract-summary.md` §4
  - upstream phase outputs: P1, P2
  - UX constraints: `../ux/uiux-spec.md` §5, §6
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: ba chính sách chọn nội dung khoảng lặng, cùng một cụm
  - Source/Test File Count: 3 source + 3 test
  - Split Required: NO
  - Split Rationale: cùng một mẫu (đọc gói + đọc prefs → trả nội dung hoặc
    `null`) áp cho ba biến thể; rule 11 nói gộp, không tách

## 2. Required Reads

- `../requirements/` nhóm F (AC-20..AC-23), nhóm G (AC-24..AC-29), AC-38
- `../architecture/solution.md` §4 bảng rủi ro
- `../ux/uiux-spec.md` §5, §6
- `mobile/lib/features/context_notebook/domain/ask_cadence_policy.dart` làm khuôn

## 3. Tasks

- `WealthCounter`: chữ ký **không có tham số thời gian nào**. Đầu vào duy nhất
  là `Map<ActivityCardStatus,int>` từ `countsByStatus()`; trả `int` = số thẻ
  `memory` (vắng mặt = 0). Không hàm nào trong file này nhận `DateTime`.
- `MilestoneResolver`: đọc `thresholds` từ gói `nudges.v1.json`; khi giá trị bộ
  đếm vượt một ngưỡng **chưa từng hiện**, trả về item caption cột mốc **đúng một
  lần**, rồi ghi `phase_status.milestone.last_shown_value`. Không hành động,
  không nút, không luồng hai chiều (AC-28/BR-8).
- `DripCadencePolicy`: trả một `DripItem?`. Trả `null` khi
  (a) `last_shown_on` cách hôm nay < 7 ngày, hoặc (b) mọi id trong kho đã nằm
  trong `seen_ids`, hoặc (c) kho có 0 mục. Khi trả item thì ghi `last_shown_on`
  và thêm id vào `seen_ids`.
- **Không** đọc `package.length` để đổi hành vi; **không** nới cửa sổ 7 ngày khi
  kho gần cạn (BR-9/BR-16).
- Bộ đếm giảm chỉ khi người dùng xoá thẻ; không thêm cảnh báo, không hỏi lý do
  (AC-29).

## 4. Acceptance Criteria

- Cùng tập thẻ, hai `DateTime.now()` cách nhau 60 ngày → bộ đếm **cùng giá trị**
  và **không** sinh nội dung nào (AC-26/BR-6).
- Không hàm nào trong `wealth_counter.dart` có tham số kiểu `DateTime`,
  `Duration`, hay đếm ngày (BR-5).
- Cột mốc hiện đúng một lần cho mỗi ngưỡng, không hiện lại ở lần mở kế tiếp
  (AC-28), và không kèm nút hành động nào.
- Nhỏ giọt: trong 8 tuần mô phỏng, ≤ 1 lần mỗi tuần và không bao giờ hai ngày
  liền (AC-22/BR-9).
- Kho nhỏ giọt 0 mục hoặc đã cạn → `null`, và **không** thông điệp "đã hết",
  không chỉ báo tiến độ, không số mục còn lại (AC-38).
- Không có ý tưởng quà đang chạy → nguồn tiến triển quà trả `null` chứ không trả
  một chỗ trống mời gọi (AC-21).

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/phase_status/domain/`
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Dart thuần + `SharedPreferences` mock
- Required levels:
  - unit: bộ đếm bất biến theo thời gian, cột mốc một-lần, nhịp 8 tuần, kho rỗng
  - mobile build/type-check/static-analysis: `flutter analyze lib test`, đếm *error*
- Required checks:
  - test **tĩnh** khẳng định `wealth_counter.dart` không chứa `DateTime` /
    `Duration` (grep trong test) — đây là cách `COUNTER-STREAK` chứng minh được
  - test mô phỏng kho nhỏ giọt 1 mục qua 8 tuần: đúng 1 lần hiện rồi im lặng
  - test kho 0 mục: không exception, trả `null`, không chuỗi nào được đọc
- Minimum gates by risk surface: `COUNTER-STREAK`, `DRIP-CADENCE`
- Required regression or contract coverage:
  `mobile/test/features/activity_cards/` vẫn xanh (P3 chỉ gọi `countsByStatus`)
- Evidence format: `flutter test` output dán vào `coding-plan/test-results.md`
- Per-story visual fidelity: `NOT_APPLICABLE — phase không dựng bề mặt UI nào`
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/phase_status/ test/features/activity_cards/`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: tên test + số test pass/fail nguyên văn

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
