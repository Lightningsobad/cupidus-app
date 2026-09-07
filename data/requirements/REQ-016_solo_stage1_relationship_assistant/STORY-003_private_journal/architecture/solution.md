# STORY-003 Nhật ký riêng — Architecture Solution

## 0. Metadata

- Complexity: standard
- Date: 2026-09-07

## 1. Decision Summary

- Mode: Brownfield (app Flutter `mobile/` đã tồn tại; ADR-007/009/010 đang hiệu lực)
- Architecture Drivers: AC-6..AC-10 (riêng tư mặc định, không xuất/chia sẻ, không
  rời thiết bị, không gửi AI/bên thứ ba), AC-11..AC-13 (xoá sạch, không bản sao
  ẩn), AC-16 (dùng trọn vẹn một mình), AC-15 (điểm nhận cho STORY-007/008).
- Architectural invariants / non-goals:
  - **Ranh giới lane đã chốt: MOBILE-ONLY. Bề mặt backend cho story này = KHÔNG
    CÓ.** `Implementation Lane: shared` trong `story_master.md` được giải quyết
    thành: backend viết 0 dòng, 0 endpoint, 0 cột DB, 0 field OpenAPI. Lý do:
    bất kỳ hợp đồng backend nào cho nhật ký cũng chính là con đường rời thiết bị
    mà AC-9/AC-10 và BR-1/BR-2 cấm; "đồng bộ đa thiết bị" không phải tính năng
    bị hoãn mà là **non-goal vĩnh viễn** của thực thể này.
  - Không streak, không mục tiêu ngày, không đếm chuỗi, không huy hiệu (BR-4).
  - Không AI runtime, không gợi ý sinh động; câu mồi viết là chuỗi tĩnh (BR-8).
  - Nhật ký chỉ ghi cái người dùng gõ; app không tự sinh nhận định (BR-5).
- Proposed technical direction: một feature mobile khép kín
  `mobile/lib/features/journal/`, dữ liệu chữ nằm ở Drift trong
  `CupidDatabase` (ADR-010, thêm 2 bảng + 1 DAO, `schemaVersion` 2 → 3), ảnh
  nằm ở thư mục media riêng của nhật ký trong sandbox app. Feature không import
  `dio`, `cupid_api`, `RealtimeCoordinator`, `share_plus`.
- Why this fits: tái dùng đúng hạ tầng sẵn có (Drift owner duy nhất,
  `image_picker`, `getIt`, `flutter_bloc`, l10n ARB) mà không mở thêm bề mặt
  mạng nào.

### Key Discovery

Ba phát hiện làm đổi thiết kế so với cách làm mặc định của repo:

1. **Nhật ký là domain ĐẦU TIÊN device-authoritative trong một database mà
   ADR-007 định nghĩa là read-through cache server-authoritative.** Ba bảng cũ
   (`Messages`, `TimelineEntries`, `Expenses`) mất là lấy lại được bằng refetch;
   một mục nhật ký mất là mất vĩnh viễn. Mọi lối tắt "cache vứt được" trong
   `core/database/` không còn đúng khi bảng nhật ký nằm cùng file.
2. **Copy convention "clear on sign-out" vào nhật ký sẽ là bug mất dữ liệu.**
   `TimelineDao` và `_MessageDaoScopedStore` đăng ký `SessionScopedStore` để xoá
   sạch khi đăng xuất (`mobile/lib/core/auth/cupid_session.dart`). Áp cùng khuôn
   vào nhật ký sẽ xoá vĩnh viễn nội dung người dùng tự viết ở một thao tác mà họ
   không hề yêu cầu xoá. Quyết định: **JournalDao KHÔNG đăng ký
   `SessionScopedStore`**; cách ly nhiều tài khoản trên cùng máy làm bằng cột
   `ownerUserId` bắt buộc trong mọi truy vấn (xem Guardrails).
3. **`CupidDatabase.migration` hiện tự cho phép destructive-recreate** (comment
   ở `cupid_database.dart:37-40`: "cache is disposable"). Kể từ v3 điều đó không
   còn đúng: một migration recreate trong tương lai sẽ xoá âm thầm nội dung
   người dùng. Đây là ràng buộc mới cho toàn app, không riêng story này.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` (điểm nhận AC-15 cho
  STORY-007/008 — hợp đồng một chiều, chỉ ghi, không đọc ngược).

## 3. Scope And Assumptions

- In Scope: feature mobile `journal` (màn danh sách, màn soạn/sửa, xoá 1 + xoá
  tất cả), 2 bảng Drift + 1 DAO trong `core/database/`, `JournalMediaStore`,
  1 hàng menu vào màn ở `me_screen.dart`, chuỗi l10n, hợp đồng điểm nhận.
- Out Of Scope: mọi thay đổi backend/OpenAPI, đồng bộ, sao lưu chủ động, cửa vào
  từ STORY-007/008, thuộc tính "Đã thành kỷ niệm" của STORY-001, nhắc nhở
  STORY-012.
- Assumptions affecting design:
  - `ownerUserId` lấy từ backend `User.id` qua `BackendUserIdStore`
    (`mobile/lib/core/realtime/backend_user_id_store.dart`), cùng khoá mà
    `RealtimeCoordinator` dùng — không dùng Firebase uid.
  - Chuỗi hiển thị đi qua ARB l10n như `me_screen.dart` đang làm
    (`l10n.me_menu_*`); `context.viEn(...)` chỉ dùng nếu phase thống nhất theo
    tiền lệ tại chỗ.

### UI Delivery Anchor

- Design Scope Description: hai màn full-screen của module `journal` — (1) màn
  danh sách "Nhật ký riêng" gồm header đơn giản, list mục theo thời gian giảm
  dần với ngày + 1-2 dòng trích + thumbnail vuông, một CTA nổi "Viết điều gì
  đó", và trạng thái rỗng trung tính một dòng; (2) màn soạn/sửa gồm ô nhập tự
  giãn, thanh đính ảnh dưới bàn phím, nút "Lưu" góc trên phải. Không có icon
  share, không menu "..." chứa hành động nào ngoài "Xoá", không thanh tiến trình
  hay chỉ số chuỗi ngày ở bất kỳ đâu trên cả hai màn.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/lib/features/journal/` (data/domain/
  presentation theo ADR-009), cộng `core/database/tables/journal_entries.dart`,
  `core/database/tables/journal_photos.dart`, `core/database/daos/journal_dao.dart`
  (giữ luật `core` không import `features/`).
- New or changed boundaries: `CupidDatabase` chuyển từ "cache thuần vứt được"
  sang "cache + 1 domain device-authoritative". `JournalMediaStore` là chủ sở
  hữu duy nhất của đường dẫn thư mục ảnh nhật ký.
- Shared patterns reused: Drift DAO + `getIt` + Cubit (không phải HydratedCubit),
  `ImagePicker.pickMultiImage` như `gallery_upload_cubit.dart` — nhưng **dừng ở
  bước chọn ảnh**, không đi tiếp sang upload.

### Entry Data Model (nội bộ feature, không phải hợp đồng liên lane)

`JournalEntries` — khoá chính `id` TEXT, UUID v4 sinh trên máy, **ổn định trọn
đời mục**: sửa là ghi đè đúng hàng đó, không tạo hàng mới (AC-3).

| Cột | Kiểu | Ràng buộc |
|---|---|---|
| `id` | TEXT | PK, UUID v4, không tái sinh khi sửa |
| `ownerUserId` | TEXT | NOT NULL, backend `User.id`; mọi truy vấn bắt buộc lọc theo cột này |
| `bodyText` | TEXT | NOT NULL, cho phép rỗng khi mục chỉ có ảnh |
| `createdAt` | INT | epoch ms UTC; khoá sắp xếp danh sách (giảm dần) |
| `updatedAt` | INT | epoch ms UTC; cập nhật khi sửa |
| `origin` | TEXT | `manual` \| `external`, mặc định `manual` (xem `contract-summary.md`) |
| `originRef` | TEXT NULL | thẻ xuất xứ mờ do story gọi đặt; **không bao giờ render, không bao giờ là link** |

`JournalPhotos` — `id` TEXT PK (UUID v4), `entryId` TEXT FK →
`JournalEntries.id` ON DELETE CASCADE, `relativePath` TEXT (tương đối so với
media root, **không lưu đường dẫn tuyệt đối**), `sortIndex` INT, `createdAt` INT.

Không có cột `deletedAt`, không có cột đếm/streak, không có cột trạng thái chia
sẻ — sự vắng mặt của chúng là một phần của yêu cầu (BR-2, BR-4).

### Affected Modules

- Mobile: `features/journal` (mới), `core/database` (2 bảng + 1 DAO + migration
  v3), `features/account/presentation/screens/me_screen.dart` (1 hàng menu),
  l10n ARB.

### Contracts And Integrations

- Error, retry, timeout, idempotency, empty-state:
  - Ghi/sửa/xoá là giao dịch cục bộ, không có retry mạng, không có hàng đợi
    offline (ADR-007 (b) vẫn đúng theo nghĩa mạnh hơn: không có mạng để hỏng).
  - **Xoá là hai pha có bù**: transaction xoá hàng DB trước, xoá file sau. Nếu
    app bị kill giữa chừng, **orphan sweep lúc mở feature** xoá mọi thư mục dưới
    media root không khớp `entryId` còn sống. Đây là cơ chế duy nhất bảo đảm
    AC-13 khi tiến trình chết giữa chừng.
  - Xoá toàn bộ = **một** transaction xoá hết hàng + xoá cả media root, sau một
    hộp thoại xác nhận duy nhất (AC-12), không snackbar hoàn tác giữ bản sao.
  - Trạng thái rỗng và trạng thái "chưa có `ownerUserId`" hiển thị giống nhau
    (rỗng trung tính); **không bao giờ** truy vấn không lọc `ownerUserId`.
- Compatibility posture: migration v2 → v3 thuần cộng thêm (`createTable` ×2),
  không đụng bảng cũ. Từ v3 trở đi cấm destructive-recreate.
- External or trust-boundary implications: biên tin cậy duy nhất là OS image
  picker (đọc vào). Không có biên đi ra.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Rò rỉ nội dung ra ngoài (chia sẻ/xuất/mạng/AI) | AC-6, AC-7, AC-10, BR-1, BR-2 | Feature cấm import `share_plus`, `dio`, `cupid_api`, `RealtimeCoordinator`, `Clipboard`, và mọi API export | Gate grep trong test: không ký tự nào của các import trên xuất hiện dưới `mobile/lib/features/journal/**`; và không file ngoài `features/journal/**` import symbol journal ngoài 2 điểm công khai ở `contract-summary.md` | `PRIVACY_EGRESS_GATE_UNRUNNABLE` |
| File ảnh mồ côi sau khi xoá | AC-12, AC-13 | Xoá DB-trước-file + orphan sweep khi mở feature | Unit test: xoá 1 mục / xoá tất cả rồi assert media root không còn file; test mô phỏng kill giữa hai pha rồi assert sweep dọn sạch | `DELETE_SWEEP_TEST_UNRUNNABLE` |
| Mất dữ liệu người dùng qua đường cache | Key Discovery 1 & 2, `cupid_session.dart`, `cupid_database.dart:37-40` | JournalDao không đăng ký `SessionScopedStore`; migration v3 thuần cộng thêm; cấm destructive-recreate từ v3 | Test migration v2 → v3 giữ nguyên dữ liệu; test đăng xuất/đăng nhập lại giữ nguyên mục của cùng `ownerUserId` | `MIGRATION_TEST_UNRUNNABLE` |
| Nội dung lộ sang tài khoản khác trên cùng máy | AC-2, AC-7 | Mọi truy vấn/ghi bắt buộc lọc `ownerUserId`; không có API DAO nào không nhận `ownerUserId` | DAO test: user B không đọc được mục của user A; review chữ ký DAO không có phương thức thiếu `ownerUserId` | `DAO_SCOPE_TEST_UNRUNNABLE` |
| Sao lưu tự động của OS đẩy nhật ký lên cloud | AC-9 | Media root và file DB phải nằm ở vị trí bị loại khỏi sao lưu tự động trên **cả hai** nền tảng; `JournalMediaStore` là nơi duy nhất quyết định đường dẫn | Test khẳng định media root resolve đúng thư mục đã cấu hình loại-trừ-sao-lưu, + ghi chú cấu hình native tương ứng cho từng nền tảng | `OS_BACKUP_EXCLUSION_UNVERIFIED` — Tech Lead **không xác minh được** tên API/định dạng cấu hình nền tảng trong run này (WebSearch/WebFetch/ToolSearch đều bị tắt cho session); implementer phải tra tài liệu nền tảng hiện hành trước khi chốt cơ chế |
| Trôi dạt "cho vui" thành streak/mục tiêu | AC-1, BR-4, R-1(f) | Không có cột/biến nào đếm ngày, chuỗi, hay tổng số mục trong schema lẫn state | Widget test màn rỗng và màn có ≥2 mục: không render số đếm/chuỗi/tiến trình; schema không có cột `streak*`/`goal*`/`count*` | `STREAK_ABSENCE_TEST_UNRUNNABLE` |
| Tranh chấp `me_screen.dart` trong wave song song | Wave REQ-016 nhiều story cùng thêm hàng menu | Story này chỉ **thêm** đúng một `_MenuRow`, không sửa hàng có sẵn, không đổi thứ tự | Diff review: thay đổi trong `me_screen.dart` chỉ là thêm; xung đột merge giải bằng giữ cả hai hàng | `MERGE_CONTENTION_UNRESOLVED` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: toàn bộ story — schema + DAO + migration v3, feature
  `journal` (list/composer/detail/xoá), `JournalMediaStore` + orphan sweep,
  hàng menu vào màn ở `me_screen.dart`, chuỗi l10n, và hợp đồng điểm nhận ở
  `contract-summary.md`.
- Authoritative inputs: `requirements/requirements.md` (AC-1..AC-17, BR-1..BR-10),
  `ux/uiux-spec.md` mục 2-8, file này, `contract-summary.md`.
- Guardrails:
  - Không thêm endpoint, DTO, hay field OpenAPI nào. Không chạm `backend/`.
  - Không import `share_plus`, `dio`, `cupid_api`, `RealtimeCoordinator`,
    `Clipboard`, `hydrated_bloc` trong `features/journal/**`.
  - Không tạo `@DriftDatabase` thứ hai (ADR-010) và không tạo file `.sqlite`
    riêng cho nhật ký.
  - Không cột `deletedAt`, không bảng thùng rác, không lưu bản nháp ra đĩa,
    không "hoàn tác 5 giây" giữ bản sao (AC-13).
  - Không ghi ảnh nhật ký vào thư viện ảnh OS và không đọc ảnh nhật ký từ ngoài
    feature (AC-7).
  - Không đăng ký `JournalDao` vào `CupidSession.registerScopedStore`.
  - Không sinh nội dung tự động vào mục nhật ký (BR-5, BR-8).

## 5. Non-Functional Impact

- Danh sách mục phải phân trang/lazy qua DAO như quy tắc ADR-007 cho domain lịch
  sử dài; không giữ toàn bộ mục trong state Cubit.
- Ảnh hiển thị ở list là thumbnail đọc từ file cục bộ; không dùng
  `cached_network_image` (không có URL mạng nào tồn tại).
- Rủi ro bảo mật ở mức thiết bị bị chiếm quyền nằm ngoài phạm vi: DB không mã
  hoá thêm, dựa trên sandbox app — story không đặt ra yêu cầu mã hoá at-rest.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Bảng nhật ký trong `CupidDatabase` + thư mục ảnh sandbox, không backend | Tái dùng Drift owner duy nhất (ADR-010), không mở bề mặt mạng | ACCEPTED | Đổi lại phải nâng luật migration của cả database (Key Discovery 3) |
| Đồng bộ nhật ký qua backend để không mất khi đổi máy | Đây là lý do `Implementation Lane` ban đầu ghi "shared" | REJECTED | Tạo đúng đường rời thiết bị mà AC-9/AC-10 cấm; mất dữ liệu khi đổi máy là hệ quả **được chấp nhận có chủ đích** của R-12 |
