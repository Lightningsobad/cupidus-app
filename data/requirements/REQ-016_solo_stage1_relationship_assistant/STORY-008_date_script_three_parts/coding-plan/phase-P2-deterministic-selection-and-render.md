# Phase P2 – Chọn preset tất định và dựng câu mad-libs

## 1. Objective

Từ `(gói, thẻ, sổ tay)` ra đúng một kịch bản ba phần, tất định và toàn phần: cùng
đầu vào luôn cho cùng đầu ra, và **không** đầu vào hợp lệ nào rơi vào nhánh "không
có kịch bản". Câu nào thiếu biến thì biến mất cả câu, không để lại `{place}` trần.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-deterministic-selection-and-render.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/date_script/domain/date_script_selector.dart`
  - `mobile/lib/features/date_script/domain/date_script_renderer.dart`
  - `mobile/test/features/date_script/date_script_selector_test.dart`
  - `mobile/test/features/date_script/date_script_renderer_test.dart`
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
  - Hàm băm ổn định nội bộ `domain/` (nguồn tất định, không phải
    `String.hashCode`)
  - `renderScript(...)` — bề mặt P3 tiêu thụ
- Shared Interfaces Consumed:
  - P1: `DateScriptPreset`, `DateScriptPart`, `DateScriptVariable`,
    `dateScriptAssetKey`
  - `mobile/lib/features/context_notebook/context_notebook_entry_point.dart`
    (`NotebookEntry`, `NotebookKind`) — chỉ đọc, chỉ qua file entry point
  - `mobile/lib/features/activity_cards/domain/activity_card.dart` — chỉ đọc
  - `../architecture/contract-summary.md` §3 (luật chọn và luật lấy giá trị sổ tay)
- Risk Surfaces:
  - Tất định + toàn phần — `DETERMINISM_UNVERIFIED`
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md` §3
  - consumer contract: P3
- Primary Inputs Summary:
  - requirements: AC-1, AC-5, AC-6, AC-8, AC-22, AC-24, AC-35; BR-2, BR-16
  - architecture: `../architecture/contract-summary.md` §3 và §5;
    `../architecture/solution.md` §4 Mobile Lane guardrails
  - upstream phase outputs: P1 (`domain/date_script_content.dart`, gói ship)
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: phép chọn tất định + ràng buộc biến + dựng câu
  - Source/Test File Count: 4
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` (các AC/BR liệt kê ở trên)
- `../architecture/contract-summary.md` §2 (bảng biến), §3 (luật chọn), §5
- `mobile/lib/features/date_script/domain/date_script_content.dart` (P1 vừa viết)
- STORY-002 `coding-plan/phase-P1-mad-libs-render-engine.md` — tiền lệ
  `requires`-drop cả câu, bám đúng ngữ nghĩa đó, đừng phát minh lại
- STORY-004 `coding-plan/phase-P6-gift-repository-and-deterministic-selector.md`
  — tiền lệ selector tất định của REQ này
- `mobile/lib/features/context_notebook/context_notebook_entry_point.dart`

## 3. Tasks

- `date_script_selector.dart`:
  - Hàm băm ổn định tự định nghĩa (FNV-1a 32-bit hoặc tương đương) trên
    `card.id`. **Không** `String.hashCode`, **không** `Random`, **không** đồng
    hồ, **không** thứ tự chèn — §5 cấm cả bốn.
  - `DateScriptPreset selectPreset(ContentPackage<DateScriptPreset> pack, ActivityCard card)`:
    lọc preset theo `card.activityType`; nếu không có preset nào khớp, hoặc
    `activityType == null`, đi thẳng nhánh preset chung (`activityTypes` rỗng);
    chọn `candidates[stableHash(card.id) % candidates.length]`.
  - `int cycleIndex(int current, int length)` — xoay vòng modulo `length`. Không
    trạng thái "đã hết", không dead-end, không thanh tiến độ (R-15b, AC-35).
  - Toàn phần: với gói hợp lệ (P1 đã bảo đảm ≥ 1 preset chung), hàm không bao
    giờ ném và không bao giờ trả `null`.
- `date_script_renderer.dart`:
  - `Map<DateScriptVariable, String> bindVariables(ActivityCard card, List<NotebookEntry> notebook)`:
    `activity`·`date`·`time`·`place`·`duration` lấy từ trường thẻ;
    `interest`·`event` lấy từ sổ tay theo §3 — sắp `NotebookEntry` theo `id`
    tăng dần, lấy mục **đầu tiên** đúng `kind`. Không xếp hạng độ liên quan,
    không ưu tiên mục mới nhất: cả hai đều là đo lường hành vi (R-1b).
    Trường thẻ vắng hoặc sổ tay không có mục đúng kind → biến vắng khỏi map,
    không giá trị mặc định, không chuỗi rỗng.
  - `List<String> renderPart(DateScriptPreset preset, DateScriptPart part, Map<DateScriptVariable, String> vars)`:
    giữ câu khi **mọi** biến trong `requires` có mặt; thay `{biến}` bằng giá trị;
    bỏ cả câu khi thiếu bất kỳ biến nào. Engine chỉ nối các câu sống sót bằng
    một dấu cách — dấu câu và cách hành văn thuộc về phía nội dung (§3).
  - Kết quả cuối không bao giờ còn chuỗi `{` hoặc `}`.
  - Không `DateTime.now()` bên trong: mọi thứ phụ thuộc ngày đi qua tham số.
- Hai file test theo `## 6`.

## 4. Acceptance Criteria

- Cùng `(gói, thẻ, sổ tay)` → cùng kịch bản, gọi liên tiếp nhiều lần (AC-8).
- Hai thẻ khác `id` cùng `activityType` có thể ra preset khác nhau, nhưng mỗi
  thẻ luôn ổn định với chính nó.
- Thẻ có `activityType` không preset nào khai báo → rơi về preset chung, không
  ném, không màn trống (toàn phần).
- Thẻ `activityType == null` → nhánh preset chung.
- Sổ tay trống → kịch bản vẫn có nội dung dùng được ở cả ba phần (AC-6), vì P1
  bảo đảm mỗi phần có câu `requires` rỗng.
- Thẻ thiếu `place` → mọi câu cần `place` biến mất, không câu nào còn `{place}`.
- Đầu ra không chứa `{` hay `}` trong mọi tổ hợp đầu vào được test.
- `cycleIndex` quay vòng đúng với `length` là 1, 2, và N lớn; không có trạng
  thái kết thúc.
- Hàm băm ổn định khớp vector cố định ghi thẳng trong test.

## 5. Planned Outputs

- Code: `mobile/lib/features/date_script/domain/` (2 file)
- Contracts: `../architecture/contract-summary.md` §3 được hiện thực hoá
- Notes: bằng chứng test ghi vào `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, thuần Dart (không widget ở phase này)
- Required levels:
  - unit: `date_script_selector_test.dart`, `date_script_renderer_test.dart`
  - mobile build/type-check/static-analysis:
    `flutter analyze lib/features/date_script test/features/date_script`
- Required checks:
  - Vector băm cố định: ít nhất ba cặp `(chuỗi, giá trị)` viết thẳng trong test.
    Đây là thứ bắt được việc ai đó đổi sang `String.hashCode` sau này.
  - Tất định lặp lại: gọi `selectPreset` 100 lần trên cùng đầu vào, assert một
    giá trị duy nhất.
  - Toàn phần: chạy `selectPreset` qua **mọi** giá trị `ActivityType` cộng
    `null`, assert không lần nào ném và luôn có preset.
  - Ma trận `requires`-drop: cho mỗi biến trong bảy biến, dựng một map thiếu
    đúng biến đó và assert các câu phụ thuộc nó vắng mặt còn câu khác còn nguyên.
  - Quét đầu ra: không kết quả render nào chứa `{` hoặc `}`.
  - Chọn giá trị sổ tay: sổ tay có ba mục `interest` với `id` xáo trộn → luôn
    lấy mục `id` nhỏ nhất, bất kể thứ tự truyền vào.
- Minimum gates by risk surface:
  - Tất định + toàn phần → vector băm + lặp 100 lần + quét toàn bộ `ActivityType`
- Required regression or contract coverage: không đụng test hiện có; chạy
  `flutter test test/features/date_script/` (gồm cả test P1) là đủ.
- Evidence format: lệnh + tóm tắt pass/fail ghi vào `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase này không dựng UI.
- Verification strategy:
  - Targeted tests: `flutter test test/features/date_script/`
  - Build/type-check: `flutter analyze lib/features/date_script test/features/date_script`
  - Required assertion evidence: vector băm cố định xanh, và quét toàn bộ
    `ActivityType` không có nhánh nào không ra kịch bản.

## 7. Status

- Status: TODO
- Last updated: 2026-09-11
- Evidence: (chưa có)
