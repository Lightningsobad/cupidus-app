# Phase P2 – Bảng nhãn tự khai `relationship_labels`

## 1. Phase Metadata

- Phase Id: P2
- Owner: Mobile Developer
- Lane: Mobile
- Depends On: None
- Parallelizable: YES (chạy song song P1)
- Status: COMPLETE
- Runtime Registry Id: `mobile-app`
- Build Command Source: runtime registry `mobile-app.buildCommand`
- Startup Smoke: NOT_APPLICABLE

## 2. Goal

Dựng nơi lưu nhãn hoàng đạo/MBTI mà người dùng **tự khai** cho mình và cho đối
phương, kèm cờ chắc chắn `known | guess`, cùng migration Drift tăng
`schemaVersion`.

Nhãn này **không** vào sổ tay. `notebook_entries` có `kind` là enum đóng
`interest | event` thuộc STORY-004; nhét nhãn vào đó là đổi contract của story
khác, điều BR-10 cấm. BR-5 nói nhãn "được phép lưu ở sổ tay" là câu cho phép
**lưu**, không phải mệnh lệnh về **chỗ lưu**. Lập luận đầy đủ:
`../architecture/solution.md` section 1 Key Discovery 5.

## 3. Primary Inputs

- `../architecture/contract-summary.md` section 4 (bảng `relationship_labels`,
  đầy đủ cột, ràng buộc UNIQUE, danh sách cột **vĩnh viễn bị cấm**)
- `mobile/lib/core/database/cupid_database.dart` — chủ sở hữu `schemaVersion`
  và `MigrationStrategy` duy nhất theo ADR-010
- `mobile/lib/core/database/tables/context_notebook_tables.dart` — mẫu khai báo
  bảng và quy ước đặt tên
- `mobile/lib/core/database/daos/` — mẫu DAO
- `mobile/lib/core/di/service_locator.dart`
- `../requirements/requirements.md` — AC-29, AC-31
- `../coding-plan/coding-agent-guide.md`

## 4. Write Scope

- `mobile/lib/core/database/tables/relationship_labels_table.dart`
- `mobile/lib/core/database/daos/relationship_labels_dao.dart`
- `mobile/lib/core/database/cupid_database.dart` (sửa: thêm bảng, thêm DAO,
  tăng `schemaVersion`, thêm một bước migration)
- `mobile/lib/features/compatibility_lookup/data/relationship_label_repository.dart`
- `mobile/lib/core/di/service_locator.dart` (sửa: đăng ký repository)
- `mobile/test/features/compatibility_lookup/relationship_label_repository_test.dart`

File sinh (`cupid_database.g.dart`) do `build_runner` tạo lại; commit nó nhưng
đừng sửa tay.

## 5. Planned Outputs

- Bảng Drift `relationship_labels` đúng cột trong contract-summary section 4:
  `id` TEXT PK (uuid v4) · `owner_key` TEXT NOT NULL · `subject` TEXT NOT NULL
  (`self` | `partner`) · `system` TEXT NOT NULL (`zodiac` | `mbti`) · `value`
  TEXT NOT NULL · `certainty` TEXT NOT NULL (`known` | `guess`) · `created_at`
  / `updated_at` DATETIME NOT NULL. UNIQUE (`owner_key`, `subject`, `system`).
- Repository với API upsert-theo-khoá-tự-nhiên và đọc theo `owner_key`.
- Migration chỉ-`CREATE TABLE`, không đụng bảng cũ.

## 6. Implementation Steps

1. Khai báo bảng đúng contract. Bốn cột `subject` / `system` / `value` /
   `certainty` lưu dạng TEXT với hằng giá trị trong Dart, **không** dùng chỉ số
   enum — chỉ số enum sẽ đổi nghĩa khi ai đó chèn giá trị vào giữa enum.
2. Đọc `schemaVersion` **thật** trên nhánh tích hợp hiện tại rồi **cộng một**.
   Đừng chép số từ tài liệu nào, kể cả contract-summary: các story khác trong
   requirement này cũng đang bump song song và tài liệu sẽ cũ. Một lần bump làm
   đỏ khoảng mười khẳng định ở bảy file test khác nhau — đó là chuyện đã xảy ra
   ở requirement này, hãy dự trù công sửa chúng ngay trong phase.
3. Thêm nhánh `onUpgrade` chỉ tạo bảng mới. **Không** sửa, đổi tên, hay bỏ cột
   của bảng đang tồn tại.
4. Ràng buộc UNIQUE là ràng buộc nghiệp vụ: một người chỉ có một nhãn hoàng đạo
   cho mình và một cho đối phương. Repository ghi bằng upsert trên khoá tự
   nhiên `(owner_key, subject, system)`, không phải chèn mới mỗi lần.
5. Đăng ký repository trong `service_locator.dart` theo đúng mẫu các repository
   sẵn có.
6. Viết test: upsert hai lần cùng khoá tự nhiên ra **một** hàng với `value` mới
   và `updated_at` mới; đọc theo `owner_key` trả đúng cặp self/partner; migration
   từ phiên bản trước lên phiên bản mới chạy sạch trên database trong bộ nhớ.
7. Thêm một test khẳng định bảng **không có** các cột bị cấm liệt kê trong
   contract-summary section 4 (không lưu kết quả tra, không lưu nội dung ô,
   không lưu lịch sử xem). Test này là hàng rào chống rò kết quả sang tầng lưu
   trữ, tương ứng AC-31.

## 7. Test Scope

- `mobile/test/features/compatibility_lookup/relationship_label_repository_test.dart`
- Các file test bị đỏ do bump `schemaVersion`: sửa **con số khẳng định** trong
  chúng, không sửa hành vi của chúng.

Chạy từng file một trước, chỉ chạy gộp khi từng file đã xanh.

Ngoài phạm vi: e2e, chạy trên thiết bị, script gate ở gốc repo, runtime startup
smoke.

## 8. Build Gate

`flutter build apk --debug` (nguồn: runtime registry `mobile-app.buildCommand`),
chạy sau `dart run build_runner build --delete-conflicting-outputs`. Không nối
ống.

## 9. Runtime Startup Gate

NOT_APPLICABLE.

## 10. Completion Criteria

- Bảng, DAO, repository, migration tồn tại và biên dịch.
- Test repository và test cột-bị-cấm xanh.
- Mọi test bị bump `schemaVersion` làm đỏ đã xanh trở lại.
- Build gate xanh.

## 11. Stop Rule

Dừng với `SCHEMA_BUMP_BLOCKED` nếu việc bump `schemaVersion` làm đỏ test của
story khác theo cách **không** sửa được bằng cập nhật con số khẳng định — ví dụ
hai story cùng nhắm một số phiên bản. Báo đúng file, đúng số, đúng story xung
đột và chờ Scrum Master xếp thứ tự; **đừng** tự chọn số nhảy cóc để né.
