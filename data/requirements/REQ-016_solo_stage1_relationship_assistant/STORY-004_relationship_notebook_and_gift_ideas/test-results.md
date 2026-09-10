# STORY-004 — Test Results

## Phase P1 — Kho ngữ cảnh: bảng Drift + repository

- Lane: Mobile
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`
- Date: 2026-09-10
- Per-story visual fidelity: NOT_APPLICABLE (phase dựng không màn nào)

### schemaVersion

Đọc sống trên nhánh này và trên `codex/REQ-016_solo_stage1_relationship_assistant-integration`
(`git show <integration>:mobile/lib/core/database/cupid_database.dart`): cả hai
đều là **5**. P1 cộng đúng một → **6**. Nhánh migration chỉ `CREATE TABLE`
(`notebook_entries`, `skill_profile_entries`, `ask_prompt_state`) trong khối
`if (from < 6)`; không `ALTER`, không huỷ-tạo-lại bảng nào.

### Commands

| Lệnh | Kết quả |
|---|---|
| `flutter test test/features/context_notebook test/core/database --reporter failures-only` | `+99: All tests passed!` |
| `flutter test test/core/database/context_notebook_migration_test.dart --reporter expanded` | `+8: All tests passed!` (8 case liệt kê tên) |
| `flutter test test/features/context_notebook/context_notebook_repository_test.dart --reporter expanded` | `+17: All tests passed!` (17 case liệt kê tên) |
| `flutter test test/features/activity_cards test/features/journal test/features/invite_composer --reporter failures-only` | `+401 ~6: All other tests passed!` (6 skip có sẵn) |
| `flutter analyze lib test` | 0 error · 35 warning · 178 info (exit 1 do info/warning có sẵn) |

Mọi lệnh chạy với `PATH="$HOME/flutter/bin:$PATH"` trong `mobile/`.
Trước đó chạy một lần `flutter pub get`, `flutter gen-l10n` (worktree mới,
`lib/l10n/generated/` bị gitignore) và `dart run build_runner build`.

### Analyzer

0 error. Toàn bộ output quy được cho P1 là **4 info
`prefer_initializing_formals`** ở `context_notebook_repository.dart:27-30` —
đúng dạng đã có ở `ActivityCardRepositoryImpl` (tham số tên có giá trị mặc định
không dùng được initializing formal cho field private). 35 warning và 174 info
còn lại nằm ở file P1 không đụng tới; nền không đổi.

### Gate migration (AC bắt buộc của phase)

`context_notebook_migration_test.dart` dựng fixture bằng cách mở schema hiện
tại trên file, seed một hàng thật cho mỗi bảng client-owned đã có, `DROP` đúng
ba bảng mới rồi `PRAGMA user_version = 5`. Sau khi mở lại:

- `user_version` = 6, ba bảng mới có mặt và ghi được ngay.
- `activity_cards` / `journal_entries` / `invite_messages` giữ nguyên hàng và
  nội dung (`Đi ăn lẩu`, `Hôm nay trời đẹp`, `invite.rap_phim.v1`).
- `ask_prompt_state` có PK gộp đúng `(owner_key, question_id)`.

### Gate cột bị cấm (AC-12 / AC-25 / R-1b)

Ba test so **tập cột sinh ra** với allowlist chính xác của
`contract-summary.md` §4, cộng assert phủ định:

- `skill_profile_entries`: không có `level` / `star` / `stars` / `score` /
  `rank` / `rating` / `proficiency`.
- `notebook_entries`: không cột nào bắt đầu bằng `partner_` / `seen_` /
  `reply_` / `frequency_`.
- `ask_prompt_state`: không cột đếm.

Vì so bằng tập bằng nhau (không phải `containsAll`), mọi cột thêm về sau — kể
cả tên chưa nằm trong danh sách cấm — đều làm test đỏ.

### AC coverage

| AC | Bằng chứng |
|---|---|
| AC-4 | `an answered question round-trips with its stable question id`; `a manually typed entry carries no question id` |
| AC-6 | Cột `detail` là ghi chú trong chính mục đó; enum `NotebookKind` đóng ở `interest`/`event`, không kind thứ ba |
| AC-9 | Nhóm `sửa và xoá có hiệu lực ngay (AC-9)` — 4 test, gồm xoá trả `1` và đọc lại `null` |
| AC-12 | `skill_profile_entries carries no proficiency dimension (AC-12)` |
| AC-25 | `notebook_entries measures nothing about the partner (AC-25)` |

### Deviations from the declared Write Scope

Hai nhóm file ngoài Write Scope buộc phải sửa vì chính việc tăng
`schemaVersion` mà phase yêu cầu:

1. `mobile/lib/core/database/cupid_database.g.dart` — output của
   `build_runner`, có commit trong repo; không tái sinh thì ba bảng mới không
   tồn tại. Không có file `.g.dart` nào khác đổi.
2. Sáu file test có sẵn hard-code hằng số phiên bản cũ (`5` → `6`). Đây là
   hằng số đã cũ, không phải hành vi đổi; nếu không sửa thì yêu cầu "test hiện
   có giữ nguyên xanh" của chính §6 không thể thoả cùng lúc với yêu cầu tăng
   `schemaVersion`:
   - `test/core/database/migration_v5_test.dart` (2 chỗ)
   - `test/core/database/activity_card_migration_test.dart` (2 chỗ)
   - `test/core/database/activity_card_dao_test.dart` (1 chỗ + tên test)
   - `test/core/database/timeline_dao_test.dart` (1 chỗ)
   - `test/core/database/journal_dao_test.dart` (1 chỗ)
   - `test/core/database/expense_dao_test.dart` (1 chỗ)
   - `test/features/activity_cards/activity_type_test.dart` (1 chỗ + comment)

Không sửa gì khác trong các file đó.

### Ghi chú thiết kế đáng lưu ý cho reviewer

`ContextNotebookDao` là lớp bọc thường, **không** phải `@DriftAccessor` đăng ký
trong danh sách `daos:` của annotation database. Đăng ký như vậy sẽ buộc
`core/database/cupid_database.dart` import `features/`, phạm ADR-010 — và test
có sẵn `lib declares exactly one @DriftDatabase (ADR-010)` quét văn bản file
`lib/**`, nên ngay cả chuỗi `@DriftDatabase` trong comment cũng làm nó đỏ.
