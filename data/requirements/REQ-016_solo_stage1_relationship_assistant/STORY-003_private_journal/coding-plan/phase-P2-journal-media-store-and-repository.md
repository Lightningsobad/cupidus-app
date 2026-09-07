# Phase P2 – Journal media store + repository

## 1. Objective

Cho nhật ký một nơi cất ảnh nằm trong sandbox app và **bị loại khỏi sao lưu tự
động của OS**, cùng một repository gói DAO + file lại thành các thao tác nguyên
tử mà UI gọi: lưu mục kèm ảnh, xoá một mục, xoá toàn bộ, và quét ảnh mồ côi.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-journal-media-store-and-repository.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/journal/journal_media_store.dart`
  - `mobile/lib/features/journal/domain/journal_entry.dart`
  - `mobile/lib/features/journal/data/journal_repository.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/core/journal/journal_media_store_test.dart`
  - `mobile/test/features/journal/journal_repository_test.dart`
  - cấu hình native loại-trừ-sao-lưu dưới `mobile/android/app/src/main/` và/hoặc
    `mobile/ios/Runner/` — chỉ file mà task 2 xác định là cần
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
  - `JournalMediaStore` (chủ sở hữu duy nhất của đường dẫn media root)
  - `JournalRepository`, `JournalEntry` (model domain)
- Shared Interfaces Consumed:
  - `JournalDao` (P1)
- Risk Surfaces:
  - File ảnh mồ côi sau khi xoá
  - Sao lưu tự động của OS đẩy nhật ký lên cloud
  - Nội dung lộ sang tài khoản khác trên cùng máy
  - Rò rỉ nội dung ra ngoài (chia sẻ/xuất/mạng/AI)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md`
    section 4 → `Contracts And Integrations`
  - consumer contract: `../architecture/contract-summary.md` section 3 (luật
    sao chép ảnh mồi)
- Primary Inputs Summary:
  - requirements: AC-2, AC-9, AC-11, AC-12, AC-13
  - architecture: `../architecture/solution.md` section 4 (xoá hai pha, orphan
    sweep, hàng rủi ro sao lưu OS)
  - upstream phase outputs: `JournalDao` từ P1
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: tầng dữ liệu phía thiết bị (file + giao dịch xoá)
  - Source/Test File Count: 6 (+ tối đa 2 file cấu hình native khai báo)
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` (section 4 `Contracts And Integrations`, bảng rủi ro)
- `../architecture/contract-summary.md` (section 3)
- `mobile/lib/core/di/service_locator.dart` (khuôn đăng ký `getIt`)

## 3. Tasks

- `JournalMediaStore` là **nơi duy nhất** quyết định đường dẫn: `rootDir()`,
  `entryDir(entryId)`, `importPhoto(entryId, sourcePath)` (sao chép ra file mới
  với id riêng, trả `relativePath`), `deleteEntryDir(entryId)`,
  `deleteRoot()`, `sweepOrphans(liveEntryIds)`.
- **Task tra cứu bắt buộc (mang từ `OS_BACKUP_EXCLUSION_UNVERIFIED`):** tra tài
  liệu nền tảng hiện hành để chọn cơ chế loại-trừ-sao-lưu cho **cả hai** nền
  tảng, rồi ghi cơ chế đã chọn + nguồn tài liệu vào `test-results.md`. Tech Lead
  không xác minh được tên API/định dạng cấu hình vì công cụ nghiên cứu bị tắt
  cho session; **không đoán từ trí nhớ**. Nếu không xác lập được cơ chế cho một
  nền tảng, dừng phase với blocker `OS_BACKUP_EXCLUSION_UNVERIFIED` thay vì ship
  mặc định của OS.
- `JournalEntry` là model domain thuần Dart (repo không có `freezed`); giữ đúng
  các trường ở `../architecture/solution.md` section 4.
- `JournalRepository` gói lại:
  - `saveEntry(...)`: import ảnh vào media root **trước**, rồi ghi DB trong một
    transaction; nếu ghi DB hỏng thì xoá các file vừa import.
  - `deleteEntry(...)`: transaction xoá hàng DB **trước**, xoá thư mục ảnh sau.
  - `deleteAll(...)`: một transaction xoá hết hàng của owner, rồi `deleteRoot()`.
  - `sweepOrphans()`: gọi lúc khởi tạo feature, đối chiếu `liveEntryIds` từ DAO
    và xoá mọi thư mục thừa dưới media root.
- Đăng ký `JournalMediaStore` và `JournalRepository` vào `getIt`. **Không**
  đăng ký vào `CupidSession.registerScopedStore`.
- Repository lấy `ownerUserId` từ `BackendUserIdStore`; khi chưa có id, mọi
  thao tác đọc trả rỗng và mọi thao tác ghi bị từ chối — **không bao giờ** truy
  vấn không lọc owner.

## 4. Acceptance Criteria

- Sau `deleteEntry` và sau `deleteAll`, media root không còn file nào của mục
  đã xoá; sau `deleteAll` media root rỗng.
- Mô phỏng tiến trình chết giữa hai pha xoá: `sweepOrphans()` ở lần khởi tạo kế
  tiếp dọn sạch phần còn lại (AC-13).
- `importPhoto` tạo bản sao độc lập: xoá file nguồn của caller không ảnh hưởng
  mục nhật ký, và ngược lại.
- Media root resolve về đúng thư mục đã cấu hình loại-trừ-sao-lưu; cơ chế và
  nguồn tài liệu được ghi lại.
- Không file nào trong Write Scope import `share_plus`, `dio`, `cupid_api`, hay
  `RealtimeCoordinator`.

## 5. Planned Outputs

- Code directories or files: các file trong Write Scope
- Contracts or schemas: `JournalMediaStore`, `JournalRepository`, `JournalEntry`
- Notes or evidence: cơ chế loại-trừ-sao-lưu đã chọn + nguồn tài liệu, ghi vào
  `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (Dart, filesystem tạm, không cần thiết bị)
- Required levels:
  - unit: `journal_media_store_test.dart` — import/xoá/`sweepOrphans` trên thư
    mục tạm; assert `rootDir()` trỏ đúng thư mục đã cấu hình
  - integration: `journal_repository_test.dart` — DAO in-memory + thư mục tạm;
    xoá một mục, xoá toàn bộ, kill giữa hai pha rồi sweep, và ca chưa có
    `ownerUserId`
  - mobile build/type-check/static-analysis: analyze giới hạn `lib test`
- Required checks: grep Write Scope xác nhận không có import bị cấm
- Minimum gates by risk surface: `DELETE_SWEEP_TEST_UNRUNNABLE`,
  `OS_BACKUP_EXCLUSION_UNVERIFIED` (theo `../architecture/solution.md` section 4)
- Evidence format: lệnh + kết quả tóm tắt trong `test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn UI nào.
- Verification strategy:
  - Targeted tests: chỉ hai file test của phase này
  - Build/type-check/lint command when required: analyze phạm vi `lib test`

## 7. Status

- Status: COMPLETE (every P2 acceptance criterion passes)
- Lane status: BLOCKED — one blocker outside this phase's Write Scope, recorded
  in `test-results.md` and needing Scrum Master: `PREEXISTING_TEST_FAILURE`
  (`flutter build ios` cannot exit 0 for any flavor on this project; the Xcode
  project has no `Debug-<flavor>` configuration and is unchanged since
  BaseHead). The story's design reference was resolved and rendered in this run
  (`Design-Screen: s1:diary`, iOS frame) and is no longer outstanding.
- Last updated: 2026-09-07

`OS_BACKUP_EXCLUSION_UNVERIFIED` is cleared. The section 3 lookup ran against
live vendor documentation in a later session that had `WebSearch`/`WebFetch`
enabled, and both mechanisms were then implemented:

- Android — `android:dataExtractionRules` + `android:fullBackupContent` in the
  manifest, pointing at two new `res/xml` rule files.
- iOS — `URLResourceValues.isExcludedFromBackup`, applied per directory by
  `JournalMediaStore` through a method channel in `AppDelegate.swift`.

Chosen mechanisms, doc sources, and verification (30/30 phase tests, 36/36
regression, `flutter analyze lib test` 0 errors, Android APK built, Runner
Swift type-checked) are recorded in `test-results.md` under `Phase P2`.

One item is deliberately out of this phase's Write Scope and left for Scrum
Master: the iOS side of the *database* file exclusion. The Android rules cover
the DB (`app_flutter`), but on iOS the `cupid.sqlite` path is owned by
`mobile/lib/core/database/cupid_database.dart`, a P1 file. See the `Residual`
subsection of `test-results.md`.
