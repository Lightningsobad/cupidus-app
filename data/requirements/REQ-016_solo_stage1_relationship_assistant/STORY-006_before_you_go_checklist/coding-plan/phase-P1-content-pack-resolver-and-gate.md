# Phase P1 – Gói nội dung, resolver tất định, và cổng nhập

## 1. Objective

Toàn bộ nửa "tất định" của story tồn tại và chứng minh được **trước khi** có
pixel nào: gói dữ liệu có id bền, resolver hàm thuần trên DSL điều kiện đóng,
value object trạng thái pha cho STORY-012, và cổng nhập làm hỏng bản dựng khi
một dòng vi phạm luật bất biến.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-content-pack-resolver-and-gate.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/assets/data/req016/before_you_go.v1.json`
  - `mobile/lib/features/before_you_go/domain/before_you_go_content.dart`
  - `mobile/lib/features/before_you_go/domain/before_you_go_content_gate.dart`
  - `mobile/lib/features/before_you_go/domain/before_you_go_resolver.dart`
  - `mobile/test/features/before_you_go/before_you_go_content_gate_test.dart`
  - `mobile/test/features/before_you_go/before_you_go_resolver_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `../architecture/contract-summary.md` §1-§3 (gói `before_you_go.v1.json`)
  - `../architecture/contract-summary.md` §4 (`BeforeYouGoPhase`)
- Shared Interfaces Consumed:
  - `mobile/lib/core/content/content_package.dart` (`ContentPackage<T>`,
    `ContentItem`, `requireContentString`, `ContentPackageFormatException`)
  - STORY-001 `architecture/contract-summary.md` §2-§3 (trường thẻ, chỉ đọc)
- Risk Surfaces:
  - Cổng nhập nội dung (AC-31/BR-17)
  - Chuỗi cứng trong widget (AC-29/BR-15)
  - Suy miền từ `location` free-text (AC-11)
  - Điều kiện hai vế của khối (AC-1/AC-2/AC-3)
  - Trạng thái pha cho STORY-012 (AC-24/BR-11)
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md`
  - consumer contract: P2 và STORY-012
- Primary Inputs Summary:
  - requirements: AC-1..AC-3, AC-7..AC-12, AC-22..AC-24, AC-29..AC-31;
    BR-3, BR-4, BR-6, BR-10, BR-11, BR-15..BR-17
  - architecture: `../architecture/solution.md` §1 Key Discovery, §4;
    `../architecture/contract-summary.md`
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: gói dữ liệu + đánh giá điều kiện + trạng thái pha + cổng nhập
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` (các AC/BR liệt kê ở trên)
- `../architecture/contract-summary.md` (toàn bộ — đây là lược đồ)
- `../architecture/solution.md` §1 Key Discovery và §4
- `mobile/lib/core/content/content_package.dart`
- `mobile/lib/features/gift_ideas/domain/gift_content_gate.dart` **và**
  `mobile/lib/features/context_notebook/domain/context_content_gate.dart` — tái
  dùng lexicon/luật bất biến của chúng, không viết danh sách thứ ba
- `mobile/lib/features/activity_cards/domain/activity_card.dart` (chỉ đọc)

## 3. Tasks

- Viết `before_you_go.v1.json` đúng lược đồ `../architecture/contract-summary.md`
  §1-§3: năm dòng seed (`cash`, `fuel`, `rain`, `booking`, `share_location`) và
  bảng `regions` ba miền với alias tỉnh/thành đã chuẩn hoá (thường, bỏ dấu).
  Ngưỡng khoảng cách nằm trong `when` của dòng `fuel`, **không** trong Dart.
- `before_you_go_content.dart`: `beforeYouGoAssetKey`,
  `ChecklistHint implements ContentItem`, `HintClause`, enum đóng
  `HintFact`/`HintOp`/`HintAction`, `RegionEntry`, parser dùng các helper
  `requireContentString` / `requireContentObjectList` có sẵn. Fact, op, hay khoá
  lạ → `ContentPackageFormatException`.
- `before_you_go_resolver.dart`:
  - `BeforeYouGoFacts.fromCard(ActivityCard, {required DateTime today,
    required List<RegionEntry> regions})` — dựng tập fact đóng; `rainySeason` là
    `null` khi không suy được miền từ `card.location`.
  - `resolveHints(...) -> List<ChecklistHint>` sắp theo `order`; một dòng qua khi
    **mọi** mệnh đề đúng; mệnh đề trên fact `null` là **sai**.
  - `BeforeYouGoPhase` theo §4, dựng từ `(card, today, dismissedOnIso)`.
  - Không `DateTime.now()` bên trong: ngày luôn là tham số.
- `before_you_go_content_gate.dart`: luật bất biến AC-31 trên gói đã parse —
  id ASCII duy nhất, `labelVi` không rỗng ≤ 60 ký tự, `icon` thuộc allowlist,
  `when` không rỗng, `action` thuộc enum đóng, và lexicon cấm (nội dung có giọng
  điệu nói về người kia, đo hành vi người kia, tâng bốc, `%`, streak/đếm số lần).
  Trả về danh sách vi phạm có nêu `id` dòng, đúng khuôn `GiftViolation`.
- Hai file test theo `## 6`.

## 4. Acceptance Criteria

- Gói ship parse được, `schemaId == 'req016.before_you_go.v1'`, mọi `items[].id`
  duy nhất và ASCII.
- Cùng `(thẻ, ngày, gói)` → cùng danh sách dòng, hai lần gọi liên tiếp (AC-10).
- Thẻ đủ ba điều kiện `priceVnd > 0` / `distanceKm >= ngưỡng` / `needsBooking ==
  true` cho **đúng ba dòng** cộng dòng chia sẻ vị trí, không dòng nào khác (AC-7).
- Thẻ `indoor` không bao giờ ra dòng áo mưa, kể cả khi đang tháng mùa mưa (AC-8).
- Thẻ thiếu trường → dòng phụ thuộc trường đó vắng mặt, không giá trị mặc định
  (AC-9).
- `location` không khớp alias nào → `rainySeason == null` → không dòng áo mưa.
- Gói rút xuống 0 dòng vẫn resolve thành danh sách rỗng, không ném (AC-30).
- Cổng nhập **thực sự bắt được** vi phạm: negative-control trong test phải fail
  gate; kiểm tra đó không được vacuously pass.

## 5. Planned Outputs

- Code: `mobile/lib/features/before_you_go/domain/` (3 file),
  `mobile/assets/data/req016/before_you_go.v1.json`
- Contracts: `../architecture/contract-summary.md` §1-§4 được hiện thực hoá
- Notes: bằng chứng test ghi vào `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, thuần Dart (không widget ở phase này)
- Required levels:
  - unit: `before_you_go_resolver_test.dart`, `before_you_go_content_gate_test.dart`
  - mobile build/type-check/static-analysis:
    `flutter analyze lib/features/before_you_go test/features/before_you_go`
- Required checks:
  - Parse gói thật từ đĩa (`File(beforeYouGoAssetKey).existsSync()`) đúng khuôn
    `gift_content_gate_test.dart` đang dùng.
  - **Negative control bắt buộc**: dựng trong test một `ChecklistHint` vi phạm
    mỗi luật bất biến và assert cổng trả về vi phạm cho đúng dòng đó. Một test
    cổng chỉ assert `offenders isEmpty` trên gói sạch là test rỗng nghĩa.
  - Quét source `lib/features/before_you_go/**` không chứa literal `labelVi` nào
    của gói (AC-29/BR-15). Quét phải so với danh sách nhãn đọc từ gói, không so
    với hằng chép tay.
  - Fact/op/action lạ ném `ContentPackageFormatException` (một test mỗi loại).
- Minimum gates by risk surface:
  - Cổng nhập nội dung → negative control xanh
  - Suy miền → ba nhánh khớp / không khớp / khớp nhưng `indoor`
  - Trạng thái pha → bốn tổ hợp `isActive` × `isDismissed`
- Required regression or contract coverage: không đụng test hiện có; chạy
  `flutter test test/features/before_you_go/` là đủ cho phase này.
- Evidence format: lệnh + tóm tắt pass/fail ghi vào `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase này không dựng UI.
- Verification strategy:
  - Targeted tests: `flutter test test/features/before_you_go/`
  - Build/type-check: `flutter analyze lib/features/before_you_go test/features/before_you_go`
  - Required assertion evidence: negative control của cổng nhập fail đúng dòng
    vi phạm và pass trên gói ship.

## 7. Status

- Status: DONE
- Last updated: 2026-09-11
- Evidence: `coding-plan/test-results.md` (P1)
- Verified with: `flutter analyze lib/features/before_you_go
  test/features/before_you_go` (no issues) và `flutter test
  test/features/before_you_go/` (64/64 pass)
