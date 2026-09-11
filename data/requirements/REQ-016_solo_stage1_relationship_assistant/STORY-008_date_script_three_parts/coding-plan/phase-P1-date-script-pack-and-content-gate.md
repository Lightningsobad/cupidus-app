# Phase P1 – Họ gói `req016.date_script.v1` và cổng nhập nội dung

## 1. Objective

Toàn bộ nửa "dữ liệu" của story tồn tại và tự bảo vệ được **trước khi** có pixel
nào: một họ gói nội dung mới với ba phần lồng nhau (`before`/`during`/`after`),
bộ biến mad-libs đóng, và một cổng nhập làm hỏng bản dựng khi một câu vi phạm
luật bất biến — kể cả luật **cấu trúc** R-1g mà chưa cổng nào trong repo có.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-date-script-pack-and-content-gate.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/assets/data/req016/date_script.v1.json`
  - `mobile/lib/features/date_script/domain/date_script_content.dart`
  - `mobile/lib/features/date_script/domain/date_script_content_gate.dart`
  - `mobile/test/features/date_script/date_script_content_test.dart`
  - `mobile/test/features/date_script/date_script_content_gate_test.dart`
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
  - `../architecture/contract-summary.md` §1 (phong bì gói, khoá asset)
  - `../architecture/contract-summary.md` §2 (định danh, bộ biến đóng)
  - `../architecture/contract-summary.md` §3 (bảng trường `items[]`)
- Shared Interfaces Consumed:
  - `mobile/lib/core/content/content_package.dart` (`ContentPackage<T>`,
    `ContentPackage.parse`, `ContentPackageFormatException`, helper
    `requireContentString` / `requireContentObjectList`)
  - `mobile/lib/core/content/invariant_terms.dart` (`InvariantRule`,
    `invariantHitsIn`, `notebookBoundaryHitsIn`, `InvariantTermHit`)
- Risk Surfaces:
  - Cổng nhập nội dung — `CONTENT_GATE_UNVERIFIED`
  - Ranh giới J7 — `J7_BOUNDARY_UNVERIFIED` (phần "trong" là nội dung đọc trước
    khi đi, không phải touchpoint)
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md`
  - consumer contract: P2, P3, và CMS ngoài repo sau này
- Primary Inputs Summary:
  - requirements: AC-5..AC-7, AC-24, AC-26, AC-31, AC-33..AC-37; BR-3, BR-16,
    BR-17, BR-18
  - architecture: `../architecture/solution.md` §1 Key Discovery (b) và (c), §4
    Mobile Lane guardrails; `../architecture/contract-summary.md` §1-§3, §5
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: gói dữ liệu ba phần + parser + cổng nhập (từ vựng uỷ quyền,
    cấu trúc tự có)
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` (các AC/BR liệt kê ở trên)
- `../architecture/contract-summary.md` (toàn bộ — đây là lược đồ, có ví dụ JSON
  đầy đủ và bảng định danh)
- `../architecture/solution.md` §1 Key Discovery và §4, §6
- `mobile/lib/core/content/content_package.dart`
- `mobile/lib/core/content/invariant_terms.dart` — đọc cả doc comment: nó cấm
  bản sao thứ hai của danh sách luật
- `mobile/lib/features/invite_composer/domain/preset_content_gate.dart` — khuôn
  `validatePresetPack` / `PresetViolation` / `_lexicalViolations` cần bám theo
- `mobile/assets/data/req016/presets.invite.v1.json` (chỉ đọc, để thấy giọng văn
  preset đã qua kiểm duyệt trông thế nào)

## 3. Tasks

- Viết `mobile/assets/data/req016/date_script.v1.json` đúng phong bì
  `../architecture/contract-summary.md` §1: `id`, `version`,
  `schemaId: "req016.date_script.v1"`, `items[]`. Mỗi item có `activityTypes`
  (rỗng nghĩa là preset chung), `parts[]` đúng ba phần theo thứ tự
  `before`·`during`·`after`, mỗi phần có `sentences[]` với `text`, `requires`,
  `aboutPartner`, và khối `editorial_review` (layer1/layer2/approved_at) theo
  SB-123.
  - Seed phải có **ít nhất một** preset chung (`activityTypes: []`) và vài
    preset theo loại hoạt động, đủ để P2 test được cả hai nhánh chọn.
  - Mỗi phần phải có ít nhất một câu `requires: []` để kịch bản không bao giờ
    rỗng khi thẻ thiếu trường (AC-6).
  - Mọi câu `aboutPartner: true` phải kết thúc bằng `?` — đây là hiện thân dữ
    liệu của R-1g (AC-26).
  - Phần `during` là nội dung **đọc trước khi đi**. Không câu nào ra lệnh mở
    app, bấm nút, hay ghi lại gì trong lúc đang hẹn (BR-3).
- `date_script_content.dart`:
  - `const String dateScriptAssetKey = 'assets/data/req016/date_script.v1.json';`
  - `enum DateScriptPart { before, during, after }` — tập đóng, ba giá trị, có
    `wireValue`.
  - `enum DateScriptVariable` — đúng bảy giá trị theo §2:
    `activity`·`date`·`time`·`place`·`duration`·`interest`·`event`. Tên dây phải
    khớp chính xác; §2 có danh sách tên-gần-đúng-nhưng-sai, đọc nó.
  - `class DateScriptSentence` (`text`, `requires: List<DateScriptVariable>`,
    `aboutPartner: bool`), `class DateScriptPartContent`,
    `class DateScriptPreset implements ContentItem` (`id`, `activityTypes`,
    `parts`).
  - Parser dùng helper có sẵn của `content_package.dart`. Biến lạ, tên phần lạ,
    thiếu phần, sai thứ tự phần → `ContentPackageFormatException`.
- `date_script_content_gate.dart`:
  - `List<DateScriptViolation> validateDateScriptPack(ContentPackage<DateScriptPreset>)`
  - Luật **cấu trúc** (mới, story này sở hữu):
    1. Đúng ba phần, đúng thứ tự `before`·`during`·`after`, không thừa không thiếu.
    2. Gói phải có ≥ 1 preset chung (`activityTypes` rỗng) — nếu không, thẻ loại
       lạ sẽ không ra được kịch bản và phép chọn không còn toàn phần.
    3. Mỗi phần của mỗi preset có ≥ 1 câu `requires` rỗng.
    4. Mọi `{biến}` xuất hiện trong `text` phải được khai báo trong `requires`
       của chính câu đó, và phải là thành viên `DateScriptVariable`.
    5. Câu `aboutPartner: true` phải kết thúc bằng `?` (R-1g / AC-26).
    6. `id` duy nhất, ASCII.
    7. `editorial_review` có đủ layer1, layer2, `approved_at` (SB-123).
  - Luật **từ vựng**: uỷ quyền cho `invariantHitsIn` và `notebookBoundaryHitsIn`
    trong `core/content/invariant_terms.dart`. Không viết danh sách từ cấm thứ
    hai trong file này — doc comment ở đó cấm, và `preset_content_gate.dart` là
    khuôn mẫu cách ghép `InvariantRule` sang loại vi phạm của story.
- Hai file test theo `## 6`.

## 4. Acceptance Criteria

- Gói ship parse được, `schemaId == 'req016.date_script.v1'`, mọi `items[].id`
  duy nhất và ASCII.
- Mọi preset trong gói ship có đúng ba phần đúng thứ tự (AC-7).
- Gói ship có ≥ 1 preset chung và mọi phần có ≥ 1 câu không điều kiện (AC-6).
- Mọi câu `aboutPartner: true` trong gói ship kết thúc bằng `?` (AC-26 / R-1g).
- Mọi `{biến}` trong gói ship đều thuộc bảy giá trị `DateScriptVariable` và đều
  được khai báo trong `requires` của câu chứa nó.
- Gói ship sạch với `invariantHitsIn`: không tâng bốc, không `%`, không streak,
  không đo hành vi người kia, không giọng thao túng (AC-31, R-1b/R-1e).
- Phần `during` không chứa chỉ dẫn thao tác app trong lúc hẹn (AC-13/BR-3).
- JSON có biến lạ, phần lạ, hoặc thiếu phần → `ContentPackageFormatException`.
- Cổng nhập **thực sự bắt được** vi phạm: negative control trong test phải fail
  gate cho từng luật cấu trúc và cho tầng từ vựng; kiểm tra đó không được
  vacuously pass.

## 5. Planned Outputs

- Code: `mobile/lib/features/date_script/domain/` (2 file),
  `mobile/assets/data/req016/date_script.v1.json`
- Contracts: `../architecture/contract-summary.md` §1-§3 được hiện thực hoá
- Notes: bằng chứng test ghi vào `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, thuần Dart (không widget ở phase này)
- Required levels:
  - unit: `date_script_content_test.dart`, `date_script_content_gate_test.dart`
  - mobile build/type-check/static-analysis:
    `flutter analyze lib/features/date_script test/features/date_script`
- Required checks:
  - Parse gói **thật từ đĩa** (`File(dateScriptAssetKey).existsSync()`) đúng
    khuôn `preset_content_gate_test.dart` đang dùng, rồi chạy
    `validateDateScriptPack` trên nó và assert không vi phạm.
  - **Negative control bắt buộc**: dựng trong test một preset vi phạm **từng**
    luật cấu trúc (thiếu phần, sai thứ tự, không preset chung, phần không có câu
    vô điều kiện, `{biến}` không khai báo, `aboutPartner: true` không kết thúc
    bằng `?`, `id` trùng, thiếu `editorial_review`) và assert cổng trả về vi
    phạm cho đúng preset/câu đó. Thêm một negative control từ vựng (một câu có
    từ trong `invariantDeniedTerms`) để chứng minh tầng uỷ quyền có chạy. Một
    test cổng chỉ assert `violations isEmpty` trên gói sạch là test rỗng nghĩa.
  - Quét source `lib/features/date_script/**` không chứa literal câu kịch bản
    nào của gói (R-15a). Quét phải so với danh sách câu đọc từ gói, không so với
    hằng chép tay.
  - Quét source `lib/features/date_script/**` không chứa danh sách từ cấm riêng:
    không có literal nào trùng `invariantDeniedTerms` ngoài lời gọi hàm (R-15c).
  - Biến/phần lạ ném `ContentPackageFormatException` (một test mỗi loại).
- Minimum gates by risk surface:
  - Cổng nhập nội dung → negative control xanh cho cả bảy luật cấu trúc và cho
    tầng từ vựng
  - Ranh giới J7 → test quét phần `during` của gói ship không chứa các cụm ra
    lệnh thao tác app; danh sách cụm đọc từ hằng của test, và test phải có một
    negative control chứng minh nó bắt được
- Required regression or contract coverage: không đụng test hiện có; chạy
  `flutter test test/features/date_script/` là đủ cho phase này.
- Evidence format: lệnh + tóm tắt pass/fail ghi vào `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase này không dựng UI.
- Verification strategy:
  - Targeted tests: `flutter test test/features/date_script/`
  - Build/type-check: `flutter analyze lib/features/date_script test/features/date_script`
  - Required assertion evidence: negative control của cổng nhập fail đúng
    preset/câu vi phạm và pass trên gói ship.

## 7. Status

- Status: TODO
- Last updated: 2026-09-11
- Evidence: (chưa có)
