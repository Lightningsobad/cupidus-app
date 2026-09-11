# Phase P1 – Gói nội dung mồi chuyện + cổng nhập R-15c

## 1. Objective

Hai gói asset JSON mới với model/parser của chúng, và một cổng nhập chạy được
từ chối nội dung vi phạm luật bất biến — bao gồm luật R-1g mới (câu phải kết
thúc bằng dấu hỏi), cài theo tiền lệ `NotebookBoundaryRule`.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-content-packs-and-gate.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/assets/data/req016/starters.v1.json`
  - `mobile/assets/data/req016/calendar_events.v1.json`
  - `mobile/lib/features/conversation_starters/domain/starter_content.dart`
  - `mobile/lib/features/conversation_starters/domain/starter_content_gate.dart`
  - `mobile/lib/core/content/invariant_terms.dart`
  - `mobile/test/features/conversation_starters/starter_content_gate_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `req016.starters.v1`, `req016.calendar_events.v1`
    (`../architecture/contract-summary.md` §3, §4)
  - luật R-1g dùng chung trong `core/content/invariant_terms.dart`
- Shared Interfaces Consumed:
  - `ContentPackage` / `ContentPackageLoader`
    (`mobile/lib/core/content/content_package.dart`)
- Risk Surfaces:
  - Cổng nhập nội dung R-15c (AC-29)
  - Hành vi hết-vòng với mọi N (AC-27/AC-28)
  - Không mạng / không AI (AC-15/AC-16)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md`
    §3 và §4
  - consumer contract: P3, P4 và STORY-007
- Primary Inputs Summary:
  - requirements: AC-20, AC-22, AC-26..AC-30, BR-15/BR-16/BR-17
  - architecture: `../architecture/solution.md` §1 Key Discovery 3, §3 A-1/A-3
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một họ gói nội dung mới và cổng nhập của chính nó
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (Nhóm E, Nhóm G)
- `../architecture/contract-summary.md` §3, §4, §6
- `../architecture/solution.md` §1 Key Discovery 3

## 3. Tasks

- Mở rộng `core/content/invariant_terms.dart` với **một họ rule mới**:
  `enum StarterStructureRule { missingQuestionEnding }` + hàm
  `Iterable<StarterStructureHit> starterStructureHitsIn(String text)`. Đây là
  mẫu `NotebookBoundaryRule` / `notebookBoundaryHitsIn()` đã có trong chính
  file đó.
- Viết `starter_content.dart`: `StarterItem` (`id`, `kind`, `text`,
  `contextSlot`) và `CalendarEvent` (`id`, `name`, `calendar`, `dates`,
  `activityType`), mỗi cái một `ContentItemParser`, dùng các helper
  `requireContentString` / `optionalContentString` / `requireContentStringList`
  đã có.
- Viết `starter_content_gate.dart` với `validateStarterPacks({starters,
  calendarEvents})` trả `List<StarterViolation>`, theo đúng hình dạng
  `gift_content_gate.dart`: enum rule riêng của họ gói, sáu giá trị đầu ghép
  wire value với `InvariantRule`, ánh xạ qua `firstWhere` trên wire value.
- Rule của cổng nhập, tối thiểu: mọi `text` của mọi `StarterItem` phải kết thúc
  bằng `?`; `kind == contextual` ⇒ có `context_slot` và đúng một `{value}`;
  `kind == generic` ⇒ không có `context_slot` và không có `{value}`; mọi
  `CalendarEvent.dates[]` khớp `YYYY-MM-DD` và `dates` không rỗng;
  `activity_type` nếu có phải là một trong 8 giá trị `ActivityType`; và mọi
  chuỗi hiển thị đi qua `invariantHitsIn()`.
- Soạn nội dung seed cho hai gói (placeholder nội bộ là đủ để build và verify).
  Gói sự kiện ghi ngày dân dụng chốt sẵn cho cả dịp dương và dịp âm; `calendar`
  chỉ là provenance.

## 4. Acceptance Criteria

- `validateStarterPacks` trả rỗng cho hai gói ship kèm.
- Mỗi rule của cổng nhập có ít nhất một case âm chứng minh nó bắt được vi phạm.
- Không giá trị nào được thêm vào `InvariantRule`, và `invariantHitsIn()`
  không yield rule mới. Bốn cổng nhập đang chạy (`gift_content_gate.dart`,
  `preset_content_gate.dart`, `context_content_gate.dart`,
  `before_you_go_content_gate.dart`) vẫn xanh.
- Không có `import` HTTP, không dependency lịch âm nào được thêm vào
  `pubspec.yaml`.
- Không có cờ dữ liệu nào cho phép một mục thoát luật R-1g.

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`.
- Contracts or schemas: `req016.starters.v1`, `req016.calendar_events.v1`.
- Notes or evidence: `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng domain/nội dung, không UI
- Required levels:
  - unit: `validateStarterPacks` với gói thật đọc từ đĩa, cộng case âm cho từng
    rule; parser từ chối JSON sai hình dạng
  - mobile build/type-check/static-analysis: `flutter analyze lib test` — gate
    là zero analyzer **error** và không warning mới ở file đã chạm; exit code
    không phải gate (baseline khác 0)
- Required checks: chạy lại bốn bộ test cổng nhập đang có để chứng minh việc
  mở rộng `invariant_terms.dart` không làm chúng đỏ
- Minimum gates by risk surface: cổng nhập R-15c phải đỏ bản dựng khi nội dung
  vi phạm
- Required regression or contract coverage:
  `mobile/test/features/invite_composer/preset_content_gate_test.dart`,
  `mobile/test/features/gift_ideas/`, `mobile/test/features/before_you_go/`,
  `mobile/test/features/context_notebook/`
- Evidence format: lệnh `flutter test <đường dẫn>` và tóm tắt pass/fail trong
  `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase này không dựng màn nào
- Verification strategy:
  - Targeted tests/regression/contract checks: như trên
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: `violations.isEmpty` cho gói ship kèm; danh
    sách vi phạm khác rỗng cho từng case âm

## 7. Status

- Status: DONE
- Last updated: 2026-09-11
- Evidence: `test-results.md` → `## Phase P1`
- Verification: `flutter test test/features/conversation_starters/` → +38 pass ·
  four shipped gates re-run → +297 ~7 pass · scoped
  `flutter analyze --no-fatal-infos --no-fatal-warnings` on touched files →
  `No issues found!`
- Deviations: none. `pubspec.yaml` untouched, no `InvariantRule` member added,
  no lunar-calendar or HTTP dependency added.
- Note for consumers: `CalendarEvent` exposes both `activityTypeWireValue` (raw,
  for the gate) and `activityType` (lenient enum, for P3/P4). The substitution
  token is exported as `starterValueToken`.
