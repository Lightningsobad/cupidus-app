# STORY-006 "Trước giờ đi" — checklist tất định (SB-211) — solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-09-11

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC-1/AC-2 (khối tự mở, không cần thao tác), AC-10/AC-22/
  AC-23 (tất định, ngoại tuyến, không AI/API ngoài), AC-29..AC-31 (R-15: nội dung
  là gói dữ liệu có id bền + cổng nhập chạy được), BR-10 (chỉ ĐỌC mô hình thẻ
  STORY-001, không thêm cột).
- Architectural invariants / non-goals: không thêm cột `activity_cards`, không
  bump `schemaVersion` Drift, không route/destination mới, không backend, không
  gọi mạng trên bất kỳ đường đi nào của story, không vẽ widget OS (BR-11).
- Proposed technical direction: một feature module mobile mới
  `mobile/lib/features/before_you_go/` gồm (a) gói nội dung JSON dùng lại
  `core/content/content_package.dart` đã có, (b) một resolver **hàm thuần**
  `(facts thẻ, ngày hôm nay, miền) -> List<ChecklistHint>` chạy trên một **DSL
  điều kiện đóng**, (c) cổng nhập nội dung chạy trong `flutter test`, (d) một
  khối UI lồng gắn ngay dưới hành động chính cấp thẻ trên
  `activity_card_detail_screen.dart`.
- Why this fits: STORY-002/003/004 đã dựng sẵn đúng khuôn này
  (`ContentPackage<T>` + `*_content.dart` + `*_content_gate.dart` +
  `assets/data/req016/*.v1.json` + một test cổng). Story này thêm một gói nữa,
  không thêm hạ tầng nội dung mới.

### Key Discovery

Ba phát hiện đọc code đổi cách hiểu đề bài, cả ba đều buộc phải chốt ở đây:

1. **`ux/uiux-spec.md` mục 1 mô tả sai code đã merge.** Spec khẳng định "khu vực
   Chuẩn bị" của STORY-002 là danh sách inline trong chi tiết thẻ, "không phải
   bottom sheet". Code đã merge là
   `invite_composer/presentation/widgets/prepare_actions_sheet.dart` →
   `showModalBottomSheet` (`showPrepareActionsSheet`), mở từ
   `ActivityCardPrimaryAction.prepare`. Đặt khối vào sheet đó sẽ **vi phạm AC-1**
   ("mở chi tiết thẻ" → khối phải hiện, không cần thao tác bật). **Chốt:** AC-1
   thắng. Khối render **inline trên chi tiết thẻ**, chèn ngay sau
   `_primaryAction(...)` (`activity_card_detail_screen.dart:433`), ở tầng thị
   giác "hành động phụ" — nên nó vẫn đọc là *lồng bên trong* luồng "Chuẩn bị"
   (AC-5) mà không thêm hành động chính cấp thẻ thứ hai (AC-4) và không thêm
   destination (AC-6). Sheet STORY-002 **không** bị sửa.
2. **"Hình thức trả tại chỗ" không tồn tại trên thẻ.** `contract-summary.md`
   STORY-001 §3 có `price_vnd` nhưng không có cột phương thức thanh toán, và B-1
   đã khoá "tập đầy đủ" cột được phép thêm. BR-10 cấm thêm trường, BR-4 cấm
   đoán. **Chốt:** điều kiện dòng "tiền mặt" thu về `priceVnd > 0`, viết thẳng
   trong gói dữ liệu; khi CMS sau này có trường thanh toán, đó là thêm **mệnh đề
   dữ liệu**, không phải sửa code (BR-15).
3. **"Miền" không có nguồn.** Không có trường miền trên thẻ lẫn trên
   `CupidProfile`. Thứ duy nhất có là `ActivityCard.location` — free-text, "never
   geocoded". **Chốt:** miền suy ra bằng **khớp token chuẩn hoá** (thường hoá,
   bỏ dấu, gộp khoảng trắng) giữa `location` và bảng alias tỉnh/thành trong gói
   dữ liệu. Không khớp → miền = `null` → fact `rainySeason` = `null` → dòng áo
   mưa **không hiện** (BR-4, không mặc định, không đoán). Không gọi bản
   đồ/thời tiết (AC-23).

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` (gói nội dung
  `before_you_go.v1.json` + trạng thái pha AC-24 mà STORY-012 đọc).

## 3. Scope And Assumptions

- In Scope: module mobile `features/before_you_go/` (domain + data + presentation),
  một asset JSON mới, một cổng nội dung chạy trong test, một điểm gắn trên
  `activity_card_detail_screen.dart`.
- Out Of Scope: backend, Drift/migration, notification, widget OS, sửa
  `prepare_actions_sheet.dart`, sửa hợp đồng thẻ STORY-001.
- Assumptions affecting design:
  - Lane chốt là **Mobile only**. `story_master.md` để ngỏ "backend + mobile";
    không AC nào cần server, và AC-22/AC-23 cấm mạng — nên backend lane = không
    tham gia.
  - Ngày dân dụng theo lịch thiết bị, cùng quy ước `scheduled_on`
    (`YYYY-MM-DD`, không phải instant/UTC).
  - `share_plus: ^13.3.0` đã có trong `pubspec.yaml`; thư mục
    `assets/data/req016/` đã khai báo — **không** cần sửa `pubspec.yaml`.
  - Với gói v1, dòng "Chia sẻ vị trí" có điều kiện `always` nên khối không bao
    giờ thực sự rỗng; đường render khối rỗng vẫn phải tồn tại và được test, vì
    AC-30 buộc hành vi đúng với **mọi N kể cả N = 0**.

### UI Delivery Anchor

- Design Scope Description: khối con lồng, chỉ trên `ActivityCardDetailScreen`
  của thẻ `scheduled` có `scheduledOn == hôm nay`, nằm giữa
  `_primaryAction(...)` và khoảng đệm cuối `Column` trong `SliverList` của
  `_ActivityCardDetailBodyState.build`. Không màn hình mới, không route mới.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile-app` → `mobile/lib/features/before_you_go/`.
- New or changed boundaries: module mới **chỉ đọc**
  `features/activity_cards/domain/activity_card.dart`; chiều ngược lại chỉ có
  đúng một điểm — `activity_card_detail_screen.dart` mount widget khối. Không
  feature nào khác import module này trong story này.
- Shared patterns reused: `core/content/content_package.dart`
  (`ContentPackage<T>`, `ContentItem`, `ContentItemParser`,
  `ContentPackageFormatException`, `requireContentString(...)`); khuôn cổng nhập
  của `gift_content_gate.dart` / `context_content_gate.dart`;
  `shared_preferences` cho trạng thái nhẹ (như `notification_preferences_store.dart`).

### Affected Modules

- Mobile: `features/before_you_go` (mới), `features/activity_cards/presentation`
  (một điểm mount), `assets/data/req016` (một gói mới).

### Contracts And Integrations

- **DSL điều kiện là tập ĐÓNG.** Fact hợp lệ: `always`, `priceVnd`, `distanceKm`,
  `needsBooking`, `indoorOutdoor`, `rainySeason`. Toán tử hợp lệ: `isTrue`,
  `isPresent`, `eq`, `gt`, `gte`. Một dòng hiện khi **mọi** mệnh đề đúng; mệnh đề
  trên fact `null` luôn **sai** (BR-4: không đoán, không mặc định, không dòng
  xám). Fact/op lạ = lỗi cổng nhập, không phải bỏ qua âm thầm.
- **Hành vi vẫn thuộc code.** Gói dữ liệu chỉ được mang `action` thuộc enum đóng
  `{share_location}`. Nội dung không bao giờ mô tả hành vi — đây là ranh giới giữ
  BR-15 ("đổi nguồn sang CMS không sửa code") không biến thành lỗ chèn logic.
- **Rỗng/thưa là trạng thái hợp lệ, không phải lỗi.** 0 dòng → **ẩn toàn bộ khối
  kể cả tiêu đề** (AC-14), không khung giữ chỗ, không thông điệp "thiếu thông
  tin" (AC-13). Không có trạng thái loading/skeleton/lỗi mạng ở bất kỳ nhánh nào.
- **Hỏng gói = lỗi to, không degrade.** Giữ đúng hợp đồng
  `ContentPackageFormatException` đã có: asset sai lược đồ ném lỗi lúc load, không
  trả gói rỗng.
- Compatibility: gói mới, `schemaId` mới, không đụng gói/bảng nào đang chạy.
  `id` từng dòng là ASCII bền, append-only.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Cổng nhập nội dung (AC-31/BR-17) | `before_you_go_content_gate.dart` | Luật bất biến chạy ở tầng lược đồ/validation; tái dùng lexicon của `gift_content_gate.dart` thay vì tạo danh sách thứ ba | `flutter test test/features/before_you_go/before_you_go_content_gate_test.dart` **kèm negative-control**: một dòng vi phạm dựng trong test phải bị từ chối | `CONTENT_GATE_NOT_RUNNABLE` |
| Chuỗi cứng trong widget (AC-29/BR-15) | `before_you_go.v1.json` | Nhãn dòng + icon + điều kiện + ngưỡng đều là dữ liệu; widget chỉ nhận `ChecklistHint` | Test quét source `features/before_you_go/**` không chứa literal nhãn checklist nào | `CONTENT_GATE_NOT_RUNNABLE` |
| Suy miền từ `location` free-text (AC-11) | `before_you_go_resolver.dart` + bảng alias trong gói | Khớp token chuẩn hoá theo alias tỉnh/thành có kiểm soát, **và** bắt buộc `indoorOutdoor == outdoor`; không khớp → bỏ dòng | Test resolver: khớp, không khớp, khớp nhưng `indoor`, và cùng đầu vào → cùng đầu ra (AC-10) | `RESOLVER_TESTS_BLOCKED` |
| Điều kiện hai vế của khối (AC-1/AC-2/AC-3) | `before_you_go_resolver.dart` | `status == scheduled` **và** `scheduledOn == hôm nay` (ngày dân dụng thiết bị); `now` là seam tiêm được | Widget test 3 nhánh: hôm nay / ngày khác / status khác | `WIDGET_TESTS_BLOCKED` |
| Hồi quy layout chi tiết thẻ | test hiện có của `activity_cards` | Khối chèn thêm chiều cao vào `Column` → `tap()` của test cũ có thể trượt trong khung mặc định 800x600 | Chạy lại **toàn bộ** `flutter test test/features/activity_cards/` sau khi mount | `MOBILE_REGRESSION_BLOCKED` |
| Trạng thái pha cho STORY-012 (AC-24/BR-11) | `architecture/contract-summary.md` | Phát ra value object thuần ở domain, không phụ thuộc widget; story này không vẽ widget OS | Test unit trên `BeforeYouGoPhase` cho 4 tổ hợp active/dismissed | `CONTRACT_UNVERIFIED` |
| Rò rỉ quyền riêng tư khi chia sẻ (AC-19/AC-20) | `before_you_go_block.dart` | Gọi OS Share Sheet **một lần**, không persist vị trí/người nhận/lịch sử, không permission vị trí liên tục | Test: hành động gọi đúng một lần seam share; không ghi khoá nào ngoài khoá đóng khối | `WIDGET_TESTS_BLOCKED` |

### Mobile Lane

- Responsibilities: toàn bộ story — gói nội dung, cổng nhập, resolver, store
  đóng khối, khối UI, điểm mount, và test cho từng mặt rủi ro ở trên.
- Authoritative inputs: `requirements/requirements.md` (AC-1..AC-31, BR-1..BR-17),
  `architecture/contract-summary.md`, `ux/uiux-spec.md` mục 2-3 (bố cục, icon,
  hàng gọn sau khi đóng), STORY-001 `architecture/contract-summary.md` §2-§3.
- Guardrails:
  - Không thêm cột `activity_cards`, không sửa `cupid_database.dart`, không bump
    `schemaVersion`.
  - Không sửa `prepare_actions_sheet.dart` và không thêm hành động chính cấp thẻ.
  - Không `http`/`dio`/`Geolocator`/permission vị trí, không package thời tiết
    hay bản đồ.
  - Không checkbox, không đánh dấu đã-làm, không đếm số lần, không streak, không
    `%` (AC-27).
  - Không hardcode nhãn checklist, icon, hay ngưỡng khoảng cách trong Dart.
  - Không dùng `DateTime.now()` trực tiếp trong resolver/cubit — đi qua seam.
