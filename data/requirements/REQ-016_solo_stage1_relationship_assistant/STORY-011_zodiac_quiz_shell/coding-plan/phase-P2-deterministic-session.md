# Phase P2 – Giải kết quả tất định, xoay vòng, và phiên chơi

## 1. Objective

Một resolver thuần ánh xạ câu trả lời → outcome và chọn đúng 3 gợi ý (có làm
giàu từ sổ tay, suy giảm êm khi sổ tay rỗng), một con trỏ xoay vòng bền không
lộ số đếm, một cubit phiên chơi tạo thẻ hoạt động với nguồn sinh mới.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-deterministic-session.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart`
  - `mobile/lib/features/zodiac_shell/data/zodiac_rotation_store.dart`
  - `mobile/lib/features/zodiac_shell/presentation/cubit/zodiac_shell_cubit.dart`
  - `mobile/lib/features/activity_cards/domain/activity_card.dart`
  - `mobile/test/features/zodiac_shell/zodiac_shell_resolver_test.dart`
  - `mobile/test/features/zodiac_shell/zodiac_rotation_store_test.dart`
  - `mobile/test/features/zodiac_shell/zodiac_shell_cubit_test.dart`
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
  - `ActivityCardOrigin.zodiacShell` (`wireValue` = `zodiac_shell`)
  - `ZodiacShellCubit` + state cho P3
- Shared Interfaces Consumed:
  - `req016.zodiac_quiz.v1`, `req016.zodiac_outcomes.v1` (P1)
  - `ActivityCardRepository` (`features/activity_cards`)
  - `ContextNotebookRepository.entries()` (chỉ đọc)
- Risk Surfaces:
  - Tất định, không xoay theo ngày
  - N là thuộc tính dữ liệu
  - Hợp đồng thẻ chỉ-đọc
  - Ngoại tuyến / không AI
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md` §2, §4
  - consumer contract: P3 (màn kết quả đọc state của cubit)
- Primary Inputs Summary:
  - requirements: AC-7/8/18/21/24/25/26/31/32, BR-4/BR-7/BR-9/BR-13
  - architecture: `../architecture/solution.md` §3 (giả định AC-21), §4 bảng risk
  - upstream phase outputs: model + asset key của P1
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm "giải kết quả tất định + phiên chơi", enum nguồn
    sinh gộp vào phase tiêu thụ đầu tiên của nó (rule 11a)
  - Source/Test File Count: 7
  - Split Required: NO
  - Split Rationale: 7 vẫn nằm trong "khoảng sáu"; tách resolver khỏi cubit sẽ
    tạo hai dispatch cho cùng một cụm hành vi, và `activity_card.dart` chỉ là
    một dòng enum nên không xứng một phase riêng.

## 2. Required Reads

- `../requirements/` (Nhóm B, Nhóm E, Nhóm F, Nhóm G, Business Rules)
- `../architecture/contract-summary.md` §2, §4
- `../architecture/solution.md` §3 (giả định về AC-21), §4 bảng risk
- output của P1: model, asset key, schema id
- mẫu tham chiếu: `mobile/lib/features/before_you_go/data/before_you_go_dismissal_store.dart`

## 3. Tasks

- `ZodiacShellResolver.resolve({required set, required answers, required
  outcomes, required notebookTags})`: nối các `outcome_key` đã chọn theo thứ tự
  câu hỏi, tra `mapping`, rơi về `fallback_outcome_id` khi không khớp. Hàm
  thuần, không `DateTime`, không random, không I/O.
- Chọn gợi ý: lấy trước các suggestion có `notebook_tags` giao với tag sổ tay
  (giữ thứ tự gói), bù cho đủ **đúng 3** theo thứ tự gói. Pool < 3 là lỗi dữ
  liệu đã bị P1 chặn; ở đây assert chứ không dựng kết quả thiếu thẻ.
- `ZodiacRotationStore`: một khoá `zodiac_shell.rotation_cursor.v1` giữ JSON
  `{setId: cursor}`; `nextWindow(setId, total, perRound)` trả chỉ số câu hỏi
  theo modulo và ghi con trỏ mới. Không API nào trả về "đã làm bao nhiêu",
  "còn bao nhiêu", hay "đã hết".
- Cubit: nạp hai gói một lần rồi cache trong phiên; đọc sổ tay qua
  `ContextNotebookRepository.entries()` trong `try/catch` — lỗi hoặc rỗng đều
  cho `notebookTags = []` và **không** phát trạng thái lỗi ra UI.
- Thêm `zodiacShell('zodiac_shell')` vào **cuối** `ActivityCardOrigin`; tạo thẻ
  qua `ActivityCardRepository` với tiêu đề là trường bắt buộc duy nhất, trạng
  thái *Mới nghĩ ra*.

## 4. Acceptance Criteria

- Cùng `(setId, answers, notebookTags)` → cùng `outcomeId` và cùng 3 gợi ý, lặp
  lại nhiều lần trong cùng test.
- Không token `DateTime.now` trong `lib/features/zodiac_shell/`.
- Chơi hết kho câu hỏi rồi chơi tiếp → quay lại từ đầu **cùng thứ tự**, không
  trạng thái "đã hết", không số đếm nào lộ ra API công khai của store.
- Sổ tay rỗng và sổ tay ném lỗi đều cho đúng 3 gợi ý.
- `ActivityCardOrigin.values` giữ nguyên thứ tự và `wireValue` cũ; giá trị mới
  ở cuối.

## 5. Planned Outputs

- Code: `mobile/lib/features/zodiac_shell/domain/`,
  `mobile/lib/features/zodiac_shell/data/`,
  `mobile/lib/features/zodiac_shell/presentation/cubit/`
- Contracts: `ActivityCardOrigin.zodiacShell`
- Evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, domain + data + cubit
- Required levels:
  - unit: resolver (tất định, fallback, chọn 3 có/không sổ tay), rotation store
    (wrap-around, bền qua lần đọc lại)
  - integration: cubit với `ContentPackageLoader` nạp asset thật +
    `ActivityCardRepository` in-memory/fake
  - mobile build/type-check/static-analysis: `flutter analyze lib test` giới hạn
    ở Write Scope; so delta với baseline khác 0 của repo
- Required checks: quét token cấm `DateTime.now` / `Random` trong module; test
  append-only trên `ActivityCardOrigin.values`
- Minimum gates by risk surface:
  - Tất định, không xoay theo ngày → test lặp resolver + quét token cấm
  - N là thuộc tính dữ liệu → rotation test với fixture N=1 và N=7, cùng hành vi
  - Hợp đồng thẻ chỉ-đọc → test thẻ tạo ra có origin mới, trạng thái *Mới nghĩ
    ra*, không trường mới
  - Ngoại tuyến / không AI → test quét import cấm
- Required regression or contract coverage: chạy lại
  `test/features/activity_cards/` vì phase sửa `activity_card.dart`
- Evidence format: lệnh + kết quả trong `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng hay đổi bề mặt UI
- Verification strategy:
  - Targeted tests: `flutter test test/features/zodiac_shell/ test/features/activity_cards/`
  - Build/type-check: `flutter analyze lib test`
  - Required assertion evidence: tên test tất định + test wrap-around + test
    append-only enum
- Runtime startup smoke: NO

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-24
