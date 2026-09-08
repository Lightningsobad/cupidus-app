# Phase P7 – Từ vựng đóng `ActivityType` và icon dẫn dòng 2 của thẻ

## 1. Objective

Thay `ActivityCard.activityType` từ `String?` tự do thành một từ vựng đóng
(`ActivityType`) đúng như hợp đồng đã cam kết ở `../architecture/contract-summary.md`
§3 ("định danh trong gói dữ liệu loại hoạt động"), rồi dùng nó làm nguồn duy nhất
cho icon dẫn dòng 2 của thẻ rút gọn. Đây là điều kiện đo được để đóng delta
**D-5** trong `../visual-fidelity/visual-fidelity-report.md` §3.

## 1A. Ownership

- Phase ID: P7
- Canonical Phase File: `phase-P7-activity-type-enum-and-card-icon.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P4
- Parallelizable: NO
- Thứ tự thực thi: P7 chạy **sau P4, trước P5 và P6**. Số hiệu phase là
  append-only nên P7 lớn hơn P5/P6 về số, nhưng nhỏ hơn về thứ tự — đọc cột
  `Depends On` ở `master-plan.md` §5, không đọc theo số hiệu.
- Write Scope:
  - `mobile/lib/features/activity_cards/domain/activity_type.dart` (mới)
  - `mobile/lib/features/activity_cards/domain/activity_card.dart`
  - `mobile/lib/features/activity_cards/domain/occasion_suggestion_service.dart`
  - `mobile/lib/features/activity_cards/data/activity_card_repository_impl.dart`
  - `mobile/lib/core/database/tables/activity_cards_table.dart`
  - `mobile/lib/core/database/cupid_database.g.dart` (sinh lại bằng build_runner)
  - `mobile/lib/design_system/icons/cupid_icons.dart`
  - `mobile/lib/features/activity_cards/presentation/widgets/activity_card_tile.dart`
  - `mobile/lib/main_preview.dart`
  - `mobile/test/features/activity_cards/activity_type_test.dart` (mới)
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
- Shared Interfaces Produced:
  - `ActivityType` — từ vựng đóng cho `activity_cards.activity_type`, hợp đồng
    dùng chung cho STORY-002/004/005/006/007/008/011/012/013
- Shared Interfaces Consumed:
  - `ActivityCard`, `NewActivityCard`, repository thẻ từ P2
  - Gói nội dung `occasions.v1.json` từ P3
  - `CupidIcons` từ design system
- Risk Surfaces:
  - Vỡ hợp đồng cho 11 story sau (đổi kiểu trường trên cửa ghi `createCard`)
  - Mất dữ liệu gốc: hàng đã có giá trị tự do không parse được
  - D-5 — icon loại hoạt động trên thẻ rút gọn
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md` §2, §3
  - từ vựng: `mobile/assets/data/req016/occasions.v1.json` khoá `activity_type`
  - UX: `../ux/uiux-spec.md` §2
- Primary Inputs Summary:
  - requirements: AC-6, AC-9, BR-2
  - architecture: `../architecture/contract-summary.md` §2, §3
  - upstream phase outputs: P2 (`ActivityCard`), P3 (gói dịp), P4 (tile)
  - visual fidelity: `../visual-fidelity/visual-fidelity-report.md` §3 hàng D-5
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — giới thiệu đúng một từ vựng đóng và render nó.
  - Source/Test File Count: 9 hand-authored + 1 sinh tự động; 5 trong số đó chỉ
    là sửa kiểu 1–3 dòng để luồng kiểu chạy thông.
  - Split Required: NO. Tách enum khỏi chỗ render sẽ tạo ra một contract phase mà
    toàn bộ consumer nằm cùng lane, cùng specialist, chạy tuần tự — SKILL rule
    11a cấm đúng trường hợp này.

## 2. Required Reads

- `../architecture/contract-summary.md` §2, §3
- `../visual-fidelity/visual-fidelity-report.md` §3 (chỉ hàng D-5)
- `mobile/lib/design_system/icons/cupid_icons.dart` phần chú thích đầu file

## 3. Tasks

- `ActivityType`: enum ASCII **đóng, append-only**, đúng 8 thành viên lấy từ
  `occasions.v1.json` — `outing`, `home`, `visit`, `dining`, `handmade`, `walk`,
  `photo`, `gift`. Không thêm thành viên nào ngoài danh sách này; gói nội dung là
  producer duy nhất.
- Trường vẫn **nullable**: thẻ người dùng tự viết (P5, STORY-002) không có loại,
  và AC-6 quy định `title` là trường bắt buộc duy nhất. `null` = chưa biết loại,
  không phải thành viên `other`.
- Lưu trữ: **không migration, không bump `schemaVersion`**. Cột `activity_type`
  giữ nguyên `TEXT NULL` trong SQLite; chỉ kiểu Dart đổi, qua Drift
  `TypeConverter` null-aware trên `activityType` ở `activity_cards_table.dart`.
  Ràng buộc `master-plan.md` §6 (bảng thẻ là dữ liệu gốc, cấm huỷ-tạo-lại) được
  giữ nguyên vì không có DDL nào chạy.
- Converter đọc **khoan dung**: chuỗi không nhận ra → `null`, không ném lỗi.
  Máy đã cài có thể chứa giá trị tự do cũ; hàng đó phải sống sót, chỉ mất icon.
  Converter ghi luôn ghi tên ASCII chuẩn của enum.
- `occasion_suggestion_service.dart`: parse `activity_type` trong JSON qua cùng
  hàm parse khoan dung đó, không tự map chuỗi lần thứ hai.
- `CupidIcons`: thêm token cho các glyph còn thiếu. Codepoint phải đọc từ cmap
  của `MaterialSymbolsRounded-Variable.ttf` bằng `fontTools`
  (`TTFont.getBestCmap()`) theo đúng quy tắc ghi ở đầu `cupid_icons.dart` — cấm
  chép codepoint từ trí nhớ hoặc từ PUA của font icon khác.
- Ánh xạ `ActivityType` → token icon (tên glyph Material Symbols Rounded):
  `dining` → `restaurant` (đã có), `handmade` → `draw` (đã có), `outing` →
  `local_activity`, `home` → `home`, `visit` → `groups`, `walk` →
  `directions_walk`, `photo` → `photo_camera`, `gift` → `card_giftcard`. Ánh xạ
  là hàm thuần trong `activity_type.dart`, không rải `switch` trong widget.
- `activity_card_tile.dart`: `activityType` **thôi làm một đoạn text** trong
  `_subtitle`, chuyển thành icon dẫn đầu dòng 2 (UX §2, D-5). Khi `activityType`
  là `null` mà dòng 2 vẫn có nội dung, dùng token trung tính để mọi thẻ có dòng 2
  đều có icon dẫn. Icon phải có `semanticLabel` lấy từ l10n, không để trần.
- `main_preview.dart`: 4 fixture đang gán sai ngữ nghĩa (`'chiều'`, `'tối nay
  được'`, `'theo lịch âm'`, `'ngoài trời đang mưa'` là nhãn bối cảnh, không phải
  loại hoạt động). Gán lại bằng thành viên enum hợp lệ trước khi chụp lại màn.

## 4. Acceptance Criteria

- `ActivityCard.activityType` và `NewActivityCard.activityType` là `ActivityType?`;
  gán chuỗi tự do là lỗi biên dịch Dart (contract-summary §1).
- `CupidDatabase.schemaVersion` **không đổi**; không có bước migration mới.
- Hàng có giá trị `activity_type` không hợp lệ vẫn đọc được, trả `null`.
- Mỗi thẻ có dòng 2 đều render đúng một icon dẫn đầu (D-5).
- Không thêm cột mới nào vào `activity_cards` (SC-1', R-1b).

## 5. Planned Outputs

- Code: enum + ánh xạ icon, converter Drift, token icon mới, tile có icon dẫn.
- Notes: bằng chứng test và ảnh chụp màn ghi vào `coding-plan/test-results.md`;
  kết quả đo lại D-5 ghi vào `visual-fidelity/visual-fidelity-report.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng domain + data + presentation
- Required levels:
  - unit: parse/serialize enum, round-trip qua converter
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
  - visual inspection: ảnh chụp màn kho thẻ ở ngăn có dữ liệu
- Required checks:
  - Unit test: 8 thành viên round-trip qua tên ASCII chuẩn, không rơi rớt.
  - Unit test: chuỗi lạ (`'chiều'`, `''`, `'Outing'`) → `null`, không ném lỗi.
  - Drift test: ghi rồi đọc lại một thẻ có `activityType` giữ nguyên giá trị.
  - Widget test: mỗi thành viên enum render đúng token icon đã ánh xạ.
  - Widget test: `activityType == null` + dòng 2 có nội dung → vẫn có icon dẫn.
  - Widget test: tên loại hoạt động không còn xuất hiện dưới dạng text ở dòng 2.
- Minimum gates by risk surface: ba risk surface ở §1B đều có gate ở trên
  (hợp đồng → unit + `analyze`; mất dữ liệu → test chuỗi lạ + Drift round-trip;
  D-5 → widget test icon + đo lại visual fidelity).
- Evidence format: output `flutter test` + ảnh chụp màn, ghi vào
  `coding-plan/test-results.md`.
- Per-story visual fidelity: REQUIRED
  - Đo lại **chỉ D-5** trên cùng `Design-Screen` id mà P4 đã khoá; không mở lại
    D-1/D-2/D-3/D-4/D-6/D-7 (xem `../req_master.md` § Design Ruling Log).
  - Render design bằng `capture-mobile-screen.sh --mode=design`, chụp bản hiện
    thực bằng `capture-mobile-screen.sh`.
  - Cảnh báo đo lường: bỏ chữ loại hoạt động khỏi dòng 2 làm đổi chuỗi text của
    dòng đó. Nếu bản design có một từ bối cảnh ở dòng 2 (ví dụ `chiều`) thì từ đó
    thuộc về một trường **khác** `activity_type` — báo blocker để Product Owner
    phân xử, cấm tự thêm cột hoặc tự nhét lại chữ vào enum.
  - Không tới được runtime thì block bằng `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests: `flutter test test/features/activity_cards/`
  - Build/type-check: `flutter analyze lib test`
  - Required assertion evidence: tên test + kết quả pass, kèm ảnh chụp so sánh.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-08
