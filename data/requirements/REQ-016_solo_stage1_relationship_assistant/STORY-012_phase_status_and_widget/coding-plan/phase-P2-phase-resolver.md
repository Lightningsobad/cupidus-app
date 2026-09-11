# Phase P2 – Resolver bốn pha + kho trạng thái SharedPreferences

## 1. Objective

Một hàm tất định duy nhất trả lời "thẻ gần nhất đang ở pha nào", dùng chung cho
cả dòng trạng thái màn (1) lẫn payload widget. Hai chỗ suy pha độc lập là lỗi
thiết kế — chúng sẽ lệch nhau.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-phase-resolver.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: YES (song song P3, P6)
- Write Scope:
  - `mobile/lib/features/phase_status/domain/solo_phase.dart`
  - `mobile/lib/features/phase_status/domain/solo_phase_resolver.dart`
  - `mobile/lib/features/phase_status/data/phase_status_prefs.dart`
  - `mobile/test/features/phase_status/solo_phase_resolver_test.dart`
  - `mobile/test/features/phase_status/phase_status_prefs_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
- Shared Interfaces Produced:
  - `SoloPhase` (tập đóng bốn giá trị) + `PhaseResolution`
  - `PhaseStatusPrefs` (khoá `SharedPreferences` của story)
- Shared Interfaces Consumed:
  - `mobile/lib/features/activity_cards/domain/activity_card_repository.dart` (chỉ đọc)
  - `mobile/lib/features/before_you_go/domain/before_you_go_resolver.dart` → `BeforeYouGoPhase`
- Risk Surfaces:
  - None trực tiếp; P2 là đầu vào của `WIDGET-LEAK` và `WIDGET-STALE`
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §4
    `Lane Handoff` (quy tắc "thẻ gần nhất")
  - consumer contract: P4, P6, P7 gọi resolver này, không suy pha lại
- Primary Inputs Summary:
  - requirements: AC-1..AC-13 (nhóm A, B, C), BR-1..BR-4, BR-12
  - architecture: `../architecture/solution.md` §4 `Lane Handoff`
  - upstream phase outputs: P1 `phase_content_repository.dart`
  - UX constraints: `../ux/uiux-spec.md` §1 bảng bốn pha (điều kiện nguồn)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: suy pha + kho trạng thái phụ trợ
  - Source/Test File Count: 3 source + 2 test
  - Split Required: NO

## 2. Required Reads

- `../requirements/` nhóm A, B, C
- `../architecture/solution.md` §4 `Lane Handoff`
- `../architecture/contract-summary.md` §2 (giá trị `phase_id`)
- `../../STORY-001_activity_card_hub/architecture/contract-summary.md` §2, §3
- `mobile/lib/features/before_you_go/data/before_you_go_dismissal_store.dart`
  làm khuôn khoá `SharedPreferences` theo thẻ

## 3. Tasks

- `enum SoloPhase { waiting, upcoming, dateDay, quiet }` với `wireValue` ASCII
  đúng `waiting` / `upcoming` / `date_day` / `quiet`.
- Viết `resolveSoloPhase` **thuần hàm**, chữ ký nhận: danh sách thẻ ứng viên,
  `DateTime today`, và `BeforeYouGoPhase?`. Không đọc repository bên trong, không
  đọc `DateTime.now()` bên trong.
- Quy tắc "thẻ gần nhất", tất định, theo đúng thứ tự này:
  1. thẻ `scheduled` có `scheduled_on` **gần nhất từ hôm nay trở đi**;
     `scheduled_on == hôm nay` → `dateDay`, tương lai → `upcoming`;
  2. còn lại, thẻ `invited == true && reply_state == not_answered` có
     `updated_at` mới nhất → `waiting`;
  3. còn lại → `quiet` (không `cardId`).
  Hoà thì phá hoà bằng `id` tăng dần, để hai lần chạy cho cùng kết quả.
- `BeforeYouGoPhase?` chỉ **làm giàu** pha `dateDay` (mang theo `cardId` và cờ
  `isDismissed`). `null` → vẫn `dateDay` suy từ `scheduled_on` (AC-2).
- `PhaseStatusPrefs`: khoá `phase_status.reminded_on.<cardId>`,
  `phase_status.drip.last_shown_on`, `phase_status.drip.seen_ids`,
  `phase_status.milestone.last_shown_value`,
  `notifications.evening_check_in.enabled`, `notifications.quiet_drip.enabled`.
  Hai khoá toggle mặc định `true`.
- Ngày là **ngày dân dụng** `YYYY-MM-DD` theo lịch thiết bị, đúng như
  `scheduled_on` của STORY-001. Không dùng instant/UTC ở bất kỳ so sánh nào.

## 4. Acceptance Criteria

- Bốn pha suy đúng từ đúng bốn nguồn AC-4 cho phép; không nguồn nào khác.
- Resolver **không** nhận và **không** đọc bất kỳ đại lượng hành vi người kia
  nào (BR-3); `reply_state` là đầu vào duy nhất về phản hồi.
- `BeforeYouGoPhase == null` → mọi AC còn lại vẫn đạt (AC-2).
- Không đếm số ngày đợi và không leo thang: resolver trả pha, không trả thời
  lượng, ở nhánh `waiting` (AC-7).
- Không thêm cột, không đổi `ActivityCardRepository` (BR-12/AC-4).
- Cùng đầu vào → cùng đầu ra, kể cả thứ tự danh sách thẻ bị xáo.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/phase_status/{domain,data}/`
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Dart thuần + `SharedPreferences` mock
- Required levels:
  - unit: bốn pha, nhánh `BeforeYouGoPhase == null`, phá hoà, danh sách xáo
  - mobile build/type-check/static-analysis: `flutter analyze lib test`, đếm *error*
- Required checks:
  - test khẳng định nhánh `waiting` không sinh ra con số ngày nào (AC-7)
  - test khẳng định thẻ `scheduled` có ngày **quá khứ** không kéo pha về
    `upcoming` và không sinh nội dung trách móc (AC-15)
  - `setMockInitialValues` cho `SharedPreferences`, không chạm đĩa thật
- Required regression or contract coverage:
  `mobile/test/features/before_you_go/` vẫn xanh (P2 chỉ đọc `BeforeYouGoPhase`)
- Evidence format: `flutter test` output dán vào `coding-plan/test-results.md`
- Per-story visual fidelity: `NOT_APPLICABLE — phase không dựng bề mặt UI nào`
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/phase_status/ test/features/before_you_go/`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: tên test + số test pass/fail nguyên văn

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
