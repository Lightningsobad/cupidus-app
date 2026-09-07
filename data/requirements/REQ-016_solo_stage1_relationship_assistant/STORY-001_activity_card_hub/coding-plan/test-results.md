# Test Results — REQ-016 / STORY-001

## Phase P1 — Kho thẻ cục bộ (schema + DAO + migration)

- Lane: Mobile
- Date: 2026-09-07
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Package: `mobile/` (`cupid_mobile`)

### Codegen

```
$ dart run build_runner build
  8s drift_dev on 2104 inputs: 526 skipped, 1030 output, 548 no-op; spent 5s analyzing, 1s resolving
  0s source_gen:combining_builder on 1052 inputs: 526 skipped, 5 output, 521 no-op
  Built with build_runner/aot in 22s; wrote 1035 outputs.
```

### Targeted unit + integration tests

```
$ flutter test test/core/database/
00:02 +40: All tests passed!
exit=0
```

Named gates from `phase-P1-local-card-store.md` §6, enumerated with
`--reporter expanded` (same run, 40/40 pass):

| Gate (§6 / §4) | Test name | Result |
|---|---|---|
| Cột đúng bằng allowlist §3 | `activity_cards schema (contract-summary.md §3 allowlist) exposes exactly the agreed column set and nothing more` | pass |
| Không cột đo hành vi người kia (R-1b, §4) | `... carries no column that measures the partner behind their back (R-1b, contract-summary.md §4)` | pass |
| Cột bảng ảnh | `... activity_card_photos exposes exactly its agreed columns` | pass |
| Không có `@DriftDatabase` thứ hai (ADR-010) | `... lib declares exactly one @DriftDatabase (ADR-010)` | pass |
| schemaVersion = 3 | `opens at schema version 3 with both activity card tables` | pass |
| DAO CRUD | `ActivityCardDao CRUD upsertCard inserts, then a second write on the same id updates in place` | pass |
| Trường thiếu = null hợp lệ | `ActivityCardDao CRUD optional fields default to null rather than being rejected` | pass |
| Đổi ngăn trạng thái | `ActivityCardDao CRUD updateCard moves a card between status panes` | pass |
| Phân trang | `ActivityCardDao CRUD cardsByStatus pages newest-updated first` | pass |
| Watch theo ngăn | `ActivityCardDao CRUD watchCardsByStatus emits the pane again after a write` | pass |
| Đếm số thẻ mỗi ngăn | `ActivityCardDao.countsByStatus counts each pane for one owner without loading the rows` | pass |
| Cách ly `owner_key` (đọc) | `owner_key isolation a different owner_key sees none of the cards` | pass |
| Cách ly `owner_key` (xoá) | `owner_key isolation deleting under the wrong owner_key writes nothing` | pass |
| Xoá thẻ xoá kèm ảnh (ON DELETE CASCADE) | `photo cascade deleting a card deletes its photo rows` | pass |
| DAO không đăng ký hook đăng xuất | `sign-out survival (AC-22) ActivityCardDao does not implement SessionScopedStore` | pass |
| Thẻ sống sót qua `clearOnSignOut()` | `sign-out survival (AC-22) running every registered clearOnSignOut leaves the cards intact` | pass |
| Migration v2→v3 giữ dữ liệu cache | `a v2 database with cache data upgrades to v3 keeping that data` | pass |
| Migration tạo bảng + chỉ mục ngăn | `the upgrade creates the activity card tables and the pane index` | pass |
| Thẻ bền qua reopen | `cards written after the upgrade survive a reopen` | pass |

Ghi chú về fixture migration: DB v2 được dựng bằng cách mở schema hiện tại trên
file rồi gỡ đúng phần thêm ở v3 và đặt `PRAGMA user_version = 2`, nên hình dạng
v1/v2 luôn khớp định nghĩa bảng thật thay vì DDL chép tay.

### Static analysis

```
$ flutter analyze lib/core/database test/core/database
Analyzing database, database...
No issues found!
exit=0
```

```
$ flutter analyze lib test
188 issues found. (ran in 2.5s)
exit=1
```

- `error` count: **0**
- `warning` count: 35 — toàn bộ nằm ngoài write scope của P1
  (`features/chat`, `features/gallery`, `test/features/**`, ...), có sẵn từ
  BaseHead `a2aaf1c`.
- Không có issue nào trỏ vào `activity_cards_table.dart`,
  `activity_card_dao.dart`, `cupid_database.dart`, hay hai file test mới
  (đã kiểm bằng lọc tên file trên output đầy đủ: 0 dòng khớp).
- `flutter analyze` thoát khác 0 với bất kỳ mức nào kể cả `info`, nên kết luận
  đọc theo severity count chứ không theo exit code.

### Thay đổi ngoài write scope đã khai báo

`schemaVersion` bump 2 → 3 làm hai assertion ghim cứng phiên bản trong test có
sẵn sai:

- `mobile/test/core/database/expense_dao_test.dart` — `expect(schemaVersion, 2)`
- `mobile/test/core/database/timeline_dao_test.dart` — `expect(schemaVersion, 2)`
  (tên test còn ghi "version 1", đã lệch từ trước)

Cả hai được sửa thành `expect(database.schemaVersion, 3)` và đổi tên thành
"opens at the current schema version with both tables present" để lần bump sau
không phải sửa lại tên. Đây là hệ quả bắt buộc của P1 chứ không phải thay đổi
hành vi; không có assertion nào khác trong hai file bị đụng tới.

### Không chạy ở phase này

- Runtime startup smoke: NOT_APPLICABLE theo §1B (P1 không dựng màn hình).
- Per-story visual fidelity: NOT_APPLICABLE theo §6.
