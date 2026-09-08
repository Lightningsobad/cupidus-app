# Master Coding Plan – STORY-003 Nhật ký riêng

## 1. Planning Metadata

- Story ID: STORY-003 (REQ-016)
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — story không đổi env
  var, secret, hay tích hợp bên thứ ba nào; cấu hình loại-trừ-sao-lưu ở P2 là
  cấu hình native của app, thuộc output của P2.

## 2. Planning Goal

- Shared contract owner: P5 (`journal_entry_point.dart`,
  `../architecture/contract-summary.md`)
- Contract-first phase required: NO — hợp đồng `openJournalComposer` không có
  consumer nào **trong story này**; consumer là STORY-007/008 ở story sau. Vì
  vậy nó không đứng thành phase riêng mà đi cùng phase nối điểm vào (P5), là
  phase cuối theo thứ tự tự nhiên.
- Parallel execution possible: YES (P3 ‖ P4)
- Critical path: P1 → P2 → P4 → P5
- Parallelism notes: P3 (màn danh sách + xoá) và P4 (màn soạn + đính ảnh) đều
  chỉ phụ thuộc P2 và ghi vào các file rời nhau; chạy song song được. P5 cần cả
  hai vì nó mở màn soạn từ ngoài và điều hướng vào màn danh sách.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| `openJournalComposer` + `JournalComposerSeed` | Mobile Developer | P5 | ngoài story (STORY-007, STORY-008) | `../architecture/contract-summary.md` section 1-3 |
| Sao chép ảnh mồi vào media root của nhật ký | Mobile Developer | P2 | P4, P5 | `../architecture/contract-summary.md` section 3 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Rò rỉ nội dung ra ngoài (chia sẻ/xuất/mạng/AI) | P3, P4, P5 (gate grep chạy được khi thư mục `features/journal/**` đã tồn tại đủ; chạy lại ở mỗi phase sau) |
| File ảnh mồ côi sau khi xoá | P1 + P2 |
| Mất dữ liệu người dùng qua đường cache | P1 |
| Nội dung lộ sang tài khoản khác trên cùng máy | P1 (DAO), tái kiểm ở P2 (repository) |
| Sao lưu tự động của OS đẩy nhật ký lên cloud | P2 |
| Trôi dạt "cho vui" thành streak/mục tiêu | P1 (schema) + P3 (màn danh sách) |
| Tranh chấp `me_screen.dart` trong wave song song | P5 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `mobile-app` (`installCommand`, `buildCommand`,
    `testCommand`); SDK resolve qua `FLUTTER_SDK_PATH`, không phải bare
    `flutter` trên PATH.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | DONE |
| P3 | Mobile Developer | Mobile | P2 | YES (với P4) | DONE |
| P4 | Mobile Developer | Mobile | P2 | YES (với P3) | NOT_STARTED |
| P5 | Mobile Developer | Mobile | P3, P4 | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-journal-persistence-schema.md` |
| P2 | `phase-P2-journal-media-store-and-repository.md` |
| P3 | `phase-P3-journal-list-screen-and-delete.md` |
| P4 | `phase-P4-journal-composer-screen.md` |
| P5 | `phase-P5-journal-entry-point-and-menu.md` |

Artifact hygiene:

- Mỗi phase id ánh xạ đúng một file `phase-Px-*.md`; không có file trùng id.
- Phase mobile phải vừa một vòng đời specialist (khoảng sáu file source/test)
  hoặc phải tách; không phase nào ở đây vượt sáu.
- Không phase nào tách chỉ vì trùng file ghi, và không phase nào lặp lại khuôn
  của phase anh em cho một biến thể cùng cụm hành vi.
- Không có phase hợp đồng đứng riêng: hợp đồng `openJournalComposer` gộp vào P5
  cùng phần nối điểm vào.
- Không có phase kiểm thử/xác minh đuôi; mỗi phase tự chạy test và
  build/analyze của chính nó.
- Test scope các phase không chứa e2e backend, e2e trình duyệt, vòng đời thiết
  bị ảo, ký ứng dụng, hay startup smoke.

## 6. Notes

- Thứ tự merge: P5 chạm `me_screen.dart`, file mà STORY-004 cũng thêm hàng vào
  trong cùng wave. P5 chỉ được **thêm** một `_MenuRow`; nếu khối card
  "Kho riêng của tôi" chưa tồn tại thì P5 tạo khối đó và STORY-004 thêm hàng vào
  sau. Xung đột merge ở file này giải bằng giữ cả hai hàng, không phải chọn một.
- `OS_BACKUP_EXCLUSION_UNVERIFIED` (từ `../architecture/solution.md` section 4)
  chuyển thành một task tra tài liệu nền tảng bắt buộc trong P2; Tech Lead không
  xác minh được vì công cụ nghiên cứu bị tắt cho session.
- P2 (2026-09-07) vẫn không đóng được blocker này: `WebSearch`/`WebFetch` cũng bị
  tắt ở cấp session trong run của Mobile Developer, nên không nền tảng nào được
  chốt cơ chế và không file native nào được ghi. Phần còn lại của P2 đã xong và
  xanh. Chỉ người dùng mới bật lại được công cụ nghiên cứu, nên P2 không thể tự
  retry từ trong subagent — xem `test-results.md` mục Phase P2 để biết chính xác
  còn thiếu gì.
