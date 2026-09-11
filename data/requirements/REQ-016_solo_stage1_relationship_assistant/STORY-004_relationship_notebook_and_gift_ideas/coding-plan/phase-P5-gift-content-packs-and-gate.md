# Phase P5 – Ba gói nội dung quà + cổng nhập luồng quà

## 1. Objective

Kho ý tưởng quà, chỉ mục ngữ cảnh→quà, và phân loại nhánh/mức công sức tồn tại
dưới dạng dữ liệu có id bền, và một cổng nhập chạy được chặn mọi rò rỉ giá tiền.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-gift-content-packs-and-gate.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: YES (với P3)
- Write Scope:
  - `mobile/lib/features/gift_ideas/domain/gift_content.dart`
  - `mobile/lib/features/gift_ideas/domain/gift_content_gate.dart`
  - `mobile/assets/data/req016/gifts.v1.json`
  - `mobile/assets/data/req016/gift_index.v1.json`
  - `mobile/assets/data/req016/gift_taxonomy.v1.json`
  - `mobile/test/features/gift_ideas/gift_content_gate_test.dart`
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
  - `req016.gifts.v1`, `req016.gift_index.v1`, `req016.gift_taxonomy.v1`
  - `GiftIdea`, `GiftIndexRow`, `GiftTaxonomyItem`
- Shared Interfaces Consumed:
  - `core/content/invariant_terms.dart` (P2), `ContentPackage` / `ContentPackageLoader`
- Risk Surfaces:
  - Giá tiền rò vào luồng quà
  - Số lượng ý tưởng bị đóng băng thành hằng số
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §1, §2
  - consumer contract: `../architecture/contract-summary.md` §6 (P6/P7 chỉ đọc, không đoán kích cỡ gói)
- Primary Inputs Summary:
  - requirements: AC-13, AC-14, AC-15, AC-20, AC-26, AC-33, AC-34, BR-11, BR-17
  - architecture: `../architecture/contract-summary.md` §1, §2
  - OQ constraints: R-15a (id bền), R-15b (N là thuộc tính dữ liệu)
  - upstream phase outputs: tầng luật dùng chung của P2
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một họ gói nội dung + cổng nhập của chính nó
  - Source/Test File Count: 6
  - Split Required: NO
  - Split Rationale: ba gói được validate bởi cùng một validator và tham chiếu
    chéo id của nhau; tách ra sẽ buộc hai phase cùng sửa `gift_content_gate.dart`.

## 2. Required Reads

- `../architecture/contract-summary.md` §1, §2, §6
- `../requirements/requirements.md` (AC-13..AC-15, AC-20, AC-26, AC-33, AC-34, BR-11, BR-17)
- `../ux/uiux-spec.md` Phần D (câu chữ thẻ quà) — chỉ để biết trường nào cần có

## 3. Tasks

- `gifts.v1.json`: mỗi ý tưởng gồm `id` bền, tiêu đề, mô tả ngắn, `branch_id`,
  `effort_tier_id`, và cờ cho biết ý tưởng có phải loại tự làm hay không. Mô tả
  nói **làm gì**, không nói mua ở đâu.
- `gift_index.v1.json`: ánh xạ từ giá trị ngữ cảnh (sở thích/sự kiện/kỹ năng đã
  ghi) sang danh sách `gift_id`. Đây là chỗ duy nhất chứa tri thức "ngữ cảnh nào
  hợp quà nào" — không nhúng luật này vào Dart.
- `gift_taxonomy.v1.json`: các mục `kind: branch` (`by_occasion`, `no_cost`,
  `handmade`) và `kind: effort_tier` (thang **giờ công**, ví dụ "≤30 phút" /
  "1–2 giờ" / "một buổi"). Không thang giá, không đơn vị tiền.
- `validateGiftPacks`: áp `invariant_terms` lên mọi chuỗi hiển thị, cộng ba luật
  riêng — (a) từ chối mọi chuỗi chứa `₫`, `VNĐ`, `VND`, `đ` sau chữ số, chuỗi
  khoảng giá, nhãn rẻ/đắt/tiết kiệm, URL mua hàng, hay tên cửa hàng (AC-14,
  AC-15, AC-26); (b) từ chối `branch_id`/`effort_tier_id` không có trong
  `gift_taxonomy` (AC-34); (c) từ chối `gift_id` trong `gift_index` không có
  trong `gifts` (R-15a).
- Không hằng số đếm ở bất kỳ đâu trong phase này: số ý tưởng, số nhánh, số mức
  công sức đều đọc từ `length` của gói tương ứng (R-15b, BR-17).

## 4. Acceptance Criteria

- Fixture chứa `250.000₫`, "khoảng 200k", "quà rẻ", "mua trên Shopee", hoặc một
  URL cửa hàng đều làm test đỏ (AC-14, AC-15, AC-26).
- Fixture có `branch_id` hoặc `effort_tier_id` lạ làm test đỏ (AC-34).
- Fixture có `gift_index` trỏ tới `gift_id` không tồn tại làm test đỏ.
- Không file Dart nào trong phase chứa số lượng ý tưởng/nhánh/mức công sức dưới
  dạng hằng (AC-33, BR-17); grep khẳng định điều đó.
- Ba nhánh bắt buộc `by_occasion` / `no_cost` / `handmade` đều có mặt trong
  `gift_taxonomy` và mỗi nhánh có ít nhất một ý tưởng trỏ tới (BR-11).
- Mọi chuỗi hiển thị của luồng quà sống trong asset, không trong Dart hay l10n.

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`
- Contracts or schemas: `req016.gifts.v1`, `req016.gift_index.v1`, `req016.gift_taxonomy.v1`
- Notes or evidence: `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng nội dung/validation
- Required levels:
  - unit: parser ba gói, từng luật của `validateGiftPacks`, fixture vi phạm
  - integration: test quét ba file `assets/data/req016/gift*.json` **từ đĩa** rồi
    chạy validator — cùng cơ chế làm hỏng bản dựng như P2, mở rộng sang họ gói quà
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
- Required checks: grep khẳng định không có hằng số đếm và không có ký hiệu tiền
  tệ trong `lib/features/gift_ideas/**`
- Minimum gates by risk surface: gate quét-từ-đĩa + fixture giá tiền; thiếu →
  `PRICE_LEAK`. Grep hằng số đếm; thiếu → `N_COUPLING`.
- Required regression or contract coverage: gate của P2 và test
  `test/features/invite_composer/` giữ nguyên xanh
- Evidence format: lệnh + kết quả tóm tắt trong `test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn nào
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/features/gift_ideas test/features/context_notebook`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: log fixture giá tiền làm đỏ đúng luật mong đợi

## 7. Status

- Status: COMPLETE (tự đánh giá — chờ Scrum Master xác minh và tick checkbox)
- Last updated: 2026-09-11
- Evidence: `../test-results.md` §Phase P5
- Gates: cổng quét-từ-đĩa xanh; 13 fixture đã chứng minh đỏ được (giá, khoảng
  giá, nhãn rẻ, tên cửa hàng, URL, id taxonomy lạ, `gift_id` treo, BR-11);
  grep hằng số đếm và ký hiệu tiền tệ sạch, có ca tự kiểm chứng chống xanh giả
- Commands: `flutter test test/features/gift_ideas test/features/context_notebook`
  → `+105 All tests passed!`; `flutter analyze lib/features/gift_ideas
  test/features/gift_ideas` → `No issues found!`; `flutter analyze
  --no-fatal-infos --no-fatal-warnings lib test` → EXIT=0 (0 error)
