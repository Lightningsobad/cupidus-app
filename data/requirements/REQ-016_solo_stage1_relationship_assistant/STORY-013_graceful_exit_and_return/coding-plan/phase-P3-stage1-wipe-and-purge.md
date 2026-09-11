# Phase P3 – Sổ đăng ký xoá sạch, dịch vụ xoá sạch, và xoá hẳn kho đã đóng

## 1. Objective

Dựng `Stage1WipeRegistry` — danh sách tường minh một chỗ của mọi bảng, thư mục
file, và khoá `SharedPreferences` mà REQ-016 sở hữu — cùng hai thao tác xoá dùng
chung nó: xoá sạch toàn bộ dữ liệu chặng 1 (AC-26/AC-27) và xoá hẳn riêng phần
đã đóng (AC-15). Phase này chưa gắn nút bấm nào; UI gọi nó ở P5 và P6.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-stage1-wipe-and-purge.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart`
  - `mobile/lib/features/chapter_closure/data/stage1_wipe_service.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/chapter_closure/stage1_wipe_service_test.dart`
  - `mobile/test/features/chapter_closure/stage1_wipe_registry_parity_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `runCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `Stage1WipeRegistry` ba danh sách (`../architecture/contract-summary.md` §4)
  - `Stage1WipeService.wipeAll()` / `.purgeClosed()`
- Shared Interfaces Consumed:
  - `ChapterClosureGate` (P1)
  - `JournalMediaStore.deleteRoot()` — tiền lệ ở
    `mobile/lib/features/journal/data/journal_repository.dart` §148-155
- Risk Surfaces:
  - Dư lượng sau xoá sạch
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §4
  - consumer contract: `../architecture/contract-summary.md` §4, §6
- Primary Inputs Summary:
  - requirements: AC-15, AC-26, AC-27, AC-29
  - architecture: `../architecture/solution.md` §4 `Boundaries And Ownership`
  - OQ constraints: none
  - upstream phase outputs: P1 sổ ghi, P2 dịch vụ đóng ngăn
  - UX constraints, if truly required: none
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: xoá dữ liệu chặng 1 — toàn bộ, và riêng phần đã đóng
  - Source/Test File Count: 5
  - Split Required: NO
  - Split Rationale: `purgeClosed()` dùng đúng bộ máy xoá bảng + xoá file của
    `wipeAll()`, chỉ khác phạm vi hàng; tách sẽ nhân đôi cùng một logic

## 2. Required Reads

- `../requirements/requirements.md` (AC-15, AC-26, AC-27, AC-29)
- `../architecture/contract-summary.md` §4, §6
- `mobile/lib/features/journal/data/journal_repository.dart`
- `mobile/lib/core/journal/journal_media_store.dart`
- `mobile/lib/core/database/cupid_database.dart` (danh sách bảng hiện có)
- P1, P2 outputs

## 3. Tasks

- Viết `Stage1WipeRegistry` với đúng ba danh sách ở `contract-summary.md` §4:
  `tables`, `mediaRoots`, `preferenceKeys`. Điền đầy đủ bảng REQ-016 đang tồn
  tại: `activity_cards`, `activity_card_photos`, `invite_messages`,
  `notebook_entries`, `skill_profile_entries`, `ask_prompt_state`,
  `journal_entries`, `journal_photos`, `chapter_closures`,
  `chapter_closure_items`. Liệt kê cả bảng đã có cascade — cascade là bảo hiểm,
  sổ đăng ký là nguồn sự thật.
- Viết `Stage1WipeService.wipeAll()`: xoá mọi bảng trong `tables` lọc theo
  `ownerKey` trong **một** transaction, rồi gọi từng `mediaRoots`, rồi xoá từng
  `preferenceKeys`. Thứ tự bảng trước file theo tiền lệ `JournalRepository`: sự
  cố giữa chừng chỉ được phép để lại file thừa, không được để lại hàng trỏ vào
  file đã mất.
- Viết `Stage1WipeService.purgeClosed()`: đọc id đang đóng theo từng `item_kind`
  qua `ChapterClosureGate`, xoá đúng những hàng đó cùng ảnh đính kèm của chúng,
  rồi xoá các hàng `chapter_closures` tương ứng (AC-15).
- **Không** gọi `clearOnSignOut()` từ bất kỳ đường nào ở đây: người dùng vẫn đang
  đăng nhập sau khi xoá sạch (AC-29), và các kho REQ-016 cố ý không phải
  `SessionScopedStore`.
- Nối dây trong `service_locator.dart`.

## 4. Acceptance Criteria

- Sau `wipeAll()`, mọi bảng trong `Stage1WipeRegistry.tables` không còn hàng nào
  của `ownerKey` đó, mọi `mediaRoots` không còn tồn tại trên đĩa, và mọi
  `preferenceKeys` đã bị xoá (AC-26, AC-27).
- Sau `wipeAll()`, không còn file ảnh mồ côi: quét thư mục media trả về rỗng.
- Sau `wipeAll()`, `hasAnyClosure()` là `false` và mọi đường đọc trả rỗng mà
  không ném lỗi — đúng trạng thái rỗng lần đầu (AC-29).
- Sau `purgeClosed()`, vật liệu đã đóng biến mất thật khỏi bảng gốc, còn vật liệu
  **không** đóng còn nguyên vẹn từng id (AC-15).
- Test đối chiếu sổ đăng ký: danh sách `tables` khớp đúng tập bảng REQ-016 đọc từ
  `CupidDatabase.allTables`, loại trừ tường minh các bảng không thuộc REQ-016.
  Thêm bảng REQ-016 mới mà quên đăng ký phải làm test này **đỏ**.
- Phiên đăng nhập của người dùng còn nguyên sau `wipeAll()`.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart`,
  `mobile/lib/features/chapter_closure/data/stage1_wipe_service.dart`, sửa
  `service_locator.dart`
- Contracts or schemas: `../architecture/contract-summary.md` §4 ba danh sách
- Requirement configuration guide updates: none
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (Flutter, `mobile/`)
- Required levels:
  - unit: `purgeClosed()` phân biệt đúng hàng đóng và hàng sống
  - integration: `wipeAll()` trên database thật có dữ liệu ở **mọi** bảng đăng ký
    cộng file ảnh thật trong thư mục tạm
  - mobile build/type-check/static-analysis: có
- Required checks:
  - test đối chiếu sổ đăng ký phải fail khi cố tình bỏ một bảng REQ-016 ra khỏi
    `tables` — chứng minh nó không rỗng nghĩa
  - `flutter analyze lib test` không sinh error mới
- Minimum gates by risk surface:
  - Dư lượng sau xoá sạch → cả hai test (bảng rỗng + media root biến mất + test
    đối chiếu sổ đăng ký) phải chạy và xanh; không đạt thì BLOCKER
- Required regression or contract coverage: test hiện có của
  `JournalRepository.deleteAll()` và của media store phải còn xanh
- Evidence format: `coding-plan/test-results.md` — lệnh đầy đủ, tóm tắt pass/fail,
  và danh sách bảng đã kiểm rỗng
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng hay đổi màn hình nào
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/chapter_closure/ test/features/journal/`
  - Build/type-check/lint command when required: `flutter build apk --debug`
  - Required assertion evidence: số hàng từng bảng trước và sau `wipeAll()`, và
    kết quả `existsSync()` của từng media root

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
