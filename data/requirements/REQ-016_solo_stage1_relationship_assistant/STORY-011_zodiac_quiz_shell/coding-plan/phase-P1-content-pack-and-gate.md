# Phase P1 – Gói nội dung và cổng nhập

## 1. Objective

Hai gói nội dung JSON có lược đồ + id bền, mô hình domain parse chúng, và một
content gate chạy được từ chối nội dung vi phạm luật bất biến ở cả tầng câu HỎI
lẫn tầng ĐẦU RA.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-content-pack-and-gate.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/assets/data/req016/zodiac_quiz.v1.json`
  - `mobile/assets/data/req016/zodiac_outcomes.v1.json`
  - `mobile/lib/features/zodiac_shell/domain/zodiac_shell_content.dart`
  - `mobile/lib/features/zodiac_shell/domain/zodiac_shell_content_gate.dart`
  - `mobile/test/features/zodiac_shell/zodiac_shell_content_test.dart`
  - `mobile/test/features/zodiac_shell/zodiac_shell_content_gate_test.dart`
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
  - `req016.zodiac_quiz.v1`, `req016.zodiac_outcomes.v1`
- Shared Interfaces Consumed:
  - `ContentPackage.parse` / `ContentPackageLoader`
    (`mobile/lib/core/content/content_package.dart`)
  - `invariantHitsIn` / `starterStructureHitsIn`
    (`mobile/lib/core/content/invariant_terms.dart`)
- Risk Surfaces:
  - Cổng nhập nội dung
  - N là thuộc tính dữ liệu
  - Giọng R-1e/R-1g ở đầu ra
  - Ngoại tuyến / không AI
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md` §3, §4
  - consumer contract: P2 (resolver), P3 (màn kết quả), CMS ngoài repo
- Primary Inputs Summary:
  - requirements: AC-29..AC-34, BR-12/BR-13/BR-14
  - architecture: `../architecture/contract-summary.md` §1-§4,
    `../architecture/solution.md` §4 bảng risk
  - OQ constraints: OQ-3 ĐÃ ĐÓNG bằng D-15 → R-15a/b/c là ràng buộc bắt buộc
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một hợp đồng dữ liệu + cổng kiểm của chính nó
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (Nhóm I, Nhóm J, Business Rules)
- `../architecture/contract-summary.md`
- `../requirements/` OQ Impact section
- mẫu tham chiếu trong repo: `mobile/lib/features/date_script/domain/date_script_content.dart`
  và `.../date_script_content_gate.dart`

## 3. Tasks

- Khai báo `zodiacQuizAssetKey` / `zodiacQuizSchemaId` và
  `zodiacOutcomesAssetKey` / `zodiacOutcomesSchemaId` theo đúng chuỗi ở
  contract-summary §2; viết model + `ContentItemParser` cho cả hai gói.
- Seed hai gói: bộ seed 10 mục cho gói xoay vòng là **giá trị bản đầu**, không
  phải hằng số — không viết bất kỳ hằng nào trong code dựa vào con số đó.
- Viết `ZodiacContentGate`:
  - đầu ra: `invariantHitsIn` trên `insight`, `ask_line`, `suggestions[].title`,
    `suggestions[].note` (cấm %, giọng phán quyết, tâng bốc, streak);
  - `about_other == true` ⇒ `ask_line` không rỗng và `starterStructureHitsIn`
    trả rỗng (AC-15);
  - `suggestions.length >= 3` (AC-4 ở tầng dữ liệu);
  - đầu vào: từ chối `questions[].prompt` hỏi tần suất/hành vi người kia
    (AC-34, R-1b tầng câu HỎI) — dùng danh sách từ khoá riêng của gate này;
  - tham chiếu chéo: mọi `mapping[].outcome_id` và `fallback_outcome_id` phải
    tồn tại trong gói outcomes;
  - cấm khoá theo-thời-gian (`daily`, `valid_from`, `unlocks_at`, `streak`,
    `play_count`) ở bất kỳ mục nào.
- Test nạp **asset thật** qua `ContentPackageLoader` và assert 0 vi phạm; thêm
  fixture vi phạm cho từng luật và assert gate ném.

## 4. Acceptance Criteria

- Cả hai gói parse được với `expectedSchemaId` đúng; `schemaId` sai ném
  `ContentPackageFormatException`.
- Gate ném với: mục có `%`, mục nói về người kia mà `ask_line` không kết bằng
  `?`/`？`, mục có ít hơn 3 suggestion, câu hỏi đo hành vi người kia, và
  `mapping` trỏ tới `outcome_id` không tồn tại.
- Không hằng số đếm mục nào trong code; mọi số mục đọc từ `ContentPackage.length`.
- Không import `http`/`dio`/API client trong `features/zodiac_shell`.

## 5. Planned Outputs

- Code: `mobile/lib/features/zodiac_shell/domain/`
- Contracts: hai gói asset JSON theo contract-summary §3/§4
- Evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, domain layer
- Required levels:
  - unit: parser hai gói, mọi luật của gate (một test cho mỗi luật), nạp asset
    thật từ bundle
  - mobile build/type-check/static-analysis: `flutter analyze lib test` giới hạn
    ở các file trong Write Scope; baseline của repo khác 0, chỉ so sánh delta
- Required checks: không hằng số N trong code; không khoá theo-thời-gian trong
  gói; gate chạy trên asset thật
- Minimum gates by risk surface:
  - Cổng nhập nội dung → gate test trên asset thật + fixture vi phạm
  - N là thuộc tính dữ liệu → parser test với fixture N=1 và N=7
  - Giọng R-1e/R-1g ở đầu ra → fixture `about_other` thiếu `ask_line`
  - Ngoại tuyến / không AI → test quét import cấm trong module
- Required regression or contract coverage: không đổi hành vi của
  `ContentPackage.parse`; test hiện có của `core/content` phải vẫn xanh
- Evidence format: lệnh + kết quả trong `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase chỉ tạo dữ liệu và domain,
  không dựng bề mặt UI nào
- Verification strategy:
  - Targeted tests: `flutter test test/features/zodiac_shell/` và
    `flutter test test/core/content/`
  - Build/type-check: `flutter analyze lib test`
  - Required assertion evidence: tên test + số test pass cho từng luật gate
- Runtime startup smoke: NO

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-24
