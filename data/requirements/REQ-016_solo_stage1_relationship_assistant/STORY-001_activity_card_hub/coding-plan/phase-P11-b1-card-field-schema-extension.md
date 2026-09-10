# P11 — Mở rộng schema thẻ theo phán quyết B-1 (5 cột phụ)

- Lane: Mobile
- Scope: `REQ-016_solo_stage1_relationship_assistant/STORY-001_activity_card_hub`
- Nguồn đặc tả: `coding-plan/master-plan.md` §10
- BaseHead: `fb66046`
- Ngày: 2026-09-08

## 1. Việc đã làm

Phán quyết B-1 thêm đúng **năm** cột nullable vào `activity_cards`, nâng
`schemaVersion` 3 → 4. Không có cột thứ sáu, không đụng ngữ nghĩa cột cũ.

| Cột SQL | Kiểu Drift | Kiểu domain |
|---|---|---|
| `duration_minutes` | `integer().nullable()` | `int?` |
| `time_of_day_slot` | `text().nullable().map(TimeOfDaySlotConverter)` | `TimeOfDaySlot?` |
| `note_keywords` | `text().nullable()` | `String?` |
| `link_source_label` | `text().nullable()` | `String?` |
| `link_saved_at` | `integer().nullable()` | `int?` |

`TimeOfDaySlot` là enum đóng bốn phần tử với wire-value ASCII: `sang`, `trua`,
`chieu`, `toi`. `timeOfDaySlotFromWireValue` khoan dung — chuỗi lạ hoặc `null`
đọc ra `null` thay vì ném, cùng khuôn với `activityTypeFromWireValue` của P7.

## 2. Ba điều cấm của §10.2 — trạng thái

1. **Không suy ra `time_of_day_slot` từ `scheduled_on`.** Không có một điểm nào
   trong `lib/` đọc `scheduledOn` để sinh slot; cột chỉ nhận giá trị người dùng
   chọn, đi qua `ActivityCardEdit`. Có test khẳng định `scheduledOn` vẫn `null`
   sau khi ghi đủ năm trường B-1.
2. **Không thêm cột thứ sáu.** Bảng đi từ 17 lên đúng 22 cột; hai test
   (`activity_card_dao_test.dart` allowlist, `activity_card_migration_test.dart`
   `hasLength(22)`) chốt con số này. D-24/D-25 đóng, không có cột chống lưng.
3. **Không đụng ngữ nghĩa `note`.** `note_keywords` là cột anh em mới, hoàn toàn
   độc lập; `note` không bị đọc, ghi, chuyển đổi hay di trú. Test round-trip
   khẳng định `note` vẫn `null` sau khi ghi năm trường mới.

## 3. An toàn di trú (§10.4)

`activity_cards` là dữ liệu người dùng sở hữu, không có bản sao trên server, nên
`deleteTable`/`createAll` bị cấm tuyệt đối. Vòng này **không** dùng cả hai.

### Sai lệch có chủ đích so với chữ của §10.4

§10.4 viết "thêm đúng một nhánh `if (from < 4)`". Áp dụng nguyên văn sẽ **hỏng**
đường v2 → v4:

```dart
if (from < 3) {
  await m.createTable(activityCards);   // phát ra định nghĩa bảng HIỆN TẠI (v4)
  ...
}
if (from < 4) {
  await m.addColumn(activityCards, activityCards.durationMinutes);  // trùng cột
}
```

`Migrator.createTable` luôn phát ra DDL của định nghĩa bảng **hiện hành**, không
phải ảnh chụp lịch sử. Máy đang ở v2 vừa được `createTable` dựng bảng đã có sẵn
năm cột mới; `addColumn` ngay sau đó ném `duplicate column name`.

Cách chữa là đổi nhánh thứ hai thành `else if`, kèm chú thích lý do:

```dart
if (from < 3) {
  ...
} else if (from < 4) {
  await m.addColumn(activityCards, activityCards.durationMinutes);
  await m.addColumn(activityCards, activityCards.timeOfDaySlot);
  await m.addColumn(activityCards, activityCards.noteKeywords);
  await m.addColumn(activityCards, activityCards.linkSourceLabel);
  await m.addColumn(activityCards, activityCards.linkSavedAt);
}
```

Ý định an toàn dữ liệu của §10.4 được giữ nguyên vẹn: không `deleteTable`, không
`createAll`, máy v2 vẫn cập bến v4 đầy đủ trong một lần mở, máy v3 giữ nguyên
từng dòng có sẵn. Chỉ hình dạng cú pháp của nhánh khác chữ đặc tả. Nhánh
`from < 2` không bị chạm; thân nhánh `from < 3` giữ nguyên từng byte.

**Cần Tech Lead xác nhận** sai lệch này khi rà §10.4, hoặc sửa lại chữ của đặc
tả cho khớp hành vi thật của `createTable`.

## 4. File đã đổi

Tạo mới:

- `mobile/lib/features/activity_cards/domain/time_of_day_slot.dart`

Sửa:

- `mobile/lib/core/database/tables/activity_cards_table.dart` — 5 cột +
  `TimeOfDaySlotConverter` + `export` kiểu enum (bắt buộc, vì
  `cupid_database.g.dart` là `part` và gọi tên kiểu này trong row type)
- `mobile/lib/core/database/cupid_database.dart` — `schemaVersion` 4 + nhánh di trú
- `mobile/lib/core/database/cupid_database.g.dart` — **sinh lại** bằng
  `build_runner`, không sửa tay
- `mobile/lib/features/activity_cards/domain/activity_card.dart` — 5 trường trên
  `ActivityCard` và `ActivityCardEdit` (+ `ActivityCardEdit.from`).
  `NewActivityCard` **không** đổi: §10.5 không đưa nó vào phạm vi, thẻ mới tạo
  để năm trường ở `null`.
- `mobile/lib/features/activity_cards/data/activity_card_repository_impl.dart` —
  5 `Value(...)` trong companion của `updateCardDetails`, 5 `row.X` trong
  `_toDomain`. Ngữ nghĩa snapshot đầy đủ của `ActivityCardEdit` giữ nguyên:
  `null` nghĩa là "xoá cột này", không phải "giữ nguyên".

Test:

- `mobile/test/core/database/activity_card_migration_test.dart` — tách hai nhóm
  `v2 -> v4` và `v3 -> v4`. Fixture v3 được dựng bằng cách mở schema hiện tại,
  ghi một thẻ thật, rồi `ALTER TABLE ... DROP COLUMN` đúng năm cột và đặt
  `PRAGMA user_version = 3`, nên hình dạng cũ luôn bám sát định nghĩa bảng thật
  thay vì bị chép tay.
- `mobile/test/core/database/activity_card_dao_test.dart` — allowlist 22 cột,
  `schemaVersion` 4. Nhóm cấm-mảnh-tên R-1b giữ nguyên.
- `mobile/test/features/activity_cards/activity_card_repository_test.dart` —
  nhóm `năm trường B-1 (P11, AC-8)`: thẻ mới toàn `null`; round-trip đủ 5 trường
  (kèm khẳng định điều cấm 1 và 3); giá trị rác `'khuya'` ghi bằng SQL thô đọc
  ra `null`; `null` xoá được giá trị cũ.

Ba test hạ tầng khác khoá cứng `schemaVersion` 3 nên phải theo lên 4:
`expense_dao_test.dart:38`, `timeline_dao_test.dart:37`,
`activity_type_test.dart:176`. Với `activity_type_test.dart`, tên test và chú
thích cũng được sửa để ý định gốc ("converter không tự sinh di trú nào") còn
đúng thay vì bị lật ngầm.

## 5. Cổng kiểm chứng

- `flutter analyze lib test` → **191 issue, 0 error**. Đúng bằng mốc S9-F-6,
  toàn bộ thuộc `BUG-20260908-001`. **ĐẠT**.
- `flutter test` toàn cây, chạy tách theo thư mục gốc để đọc được đủ output:

  | Phạm vi | Kết quả |
  |---|---|
  | `test/core` | 238 pass, 0 fail |
  | `test/app` `test/design_system` `test/l10n` `test/openapi` `test/tooling` | 108 pass, 3 fail |
  | `test/features` (16 thư mục xanh) | 1280 pass, 4 skip, 0 fail |
  | `test/features/auth` | 110 pass, 4 fail |
  | `test/features/gallery` + `in_app_notifications` | 48 pass, 2 fail |
  | `test/features/love_contracts` + `zodiac` | 120 pass, 5 fail |
  | **Tổng** | **1904 pass, 4 skip, 14 fail** |

  Mốc S9-F-6 là 1890 / 4 / 14. Chênh **+14 test xanh mới** (đúng số test P11 bổ
  sung), **0 lỗi mới**. 14 test đỏ trùng khớp từng dòng với bảng "14 test đỏ còn
  lại" ở mục `### S9-F-5` — cùng file, cùng tên, không thêm không bớt; chúng
  thuộc `BUG-20260907-001`, ngoài phạm vi STORY-001.
- Runtime startup smoke: **NOT_APPLICABLE** cho P11 theo §10.8 (R-2). P11 chỉ
  đổi schema và tầng dữ liệu, không có bề mặt màn hình mới để khởi động.

## 6. Chưa làm (ngoài phạm vi P11)

- Không có bề mặt UI nào cho năm trường này; nhập liệu và hiển thị thuộc các
  dispatch sau (§11/§12), không đọc trong vòng này.
- `NewActivityCard` chưa nhận năm trường — theo đúng §10.5.
- Không chạm `architecture/contract-summary.md` §3/§5: Tech Lead đã vá sẵn, vòng
  này chỉ đọc như hợp đồng có sẵn.
