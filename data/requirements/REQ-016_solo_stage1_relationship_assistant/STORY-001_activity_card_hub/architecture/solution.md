# 001_activity_card_hub-solution.md

## 0. Metadata

- Complexity: complex (Story-Class: shared-foundation)
- Date: 2026-09-07

## 1. Decision Summary

- Mode: Brownfield (mở rộng app Flutter `cupid_mobile` đang chạy)
- Architecture Drivers: SC-1' một kho duy nhất · SB-76 thẻ có cấu trúc · SC-4/SC-5
  vòng đời 4 trạng thái · R-1b cấm đo hành vi người kia · R-7/BR-8 không AI và
  không API nội dung ở runtime · R-15a schema + id bền · AC-23 chạy trọn vẹn khi
  không có người kia.
- Architectural invariants / non-goals:
  - **Không thêm bề mặt backend nào.** Hợp đồng backend đang **đóng băng (A1)**
    theo `data/architecture/system/system_architecture_memory.md` §1/§8: client
    phải thích nghi, mọi thay đổi hợp đồng cần escalation — REQ-016 không có
    escalation nào và `requirements.md` §System Integration ghi rõ "không có tích
    hợp bên ngoài".
  - Không route mới, không tab mới (UX §1): story giao **nhánh solo** của tab
    "Nhà" hiện có.
  - Zero network call trên mọi đường đi của story này, kể cả link preview.
- Proposed technical direction: một feature module mobile `activity_cards` với
  Drift là **nguồn sự thật cục bộ** (không phải cache), Cubit cho CRUD theo
  ADR-003, và một gói dữ liệu dịp ship kèm asset cho AC-3. Hợp đồng dùng chung
  cho 11 story sau nằm ở `architecture/contract-summary.md`.
- Why this fits: ADR-005 (một package Flutter, feature-first) và ADR-010 (một
  `CupidDatabase` duy nhất) đã có sẵn chỗ cho một domain mới mà không phá cấu
  trúc; thêm bảng vào `core/database/` là đường đi đã được dùng ở timeline và
  expenses.

### Key Discovery

Baseline hệ thống nói **hai điều mà story này buộc phải làm khác**, và đây là
phần không artifact nào khác mang:

1. **ADR-007: "Drift là read-through cache, không bao giờ là nguồn sự thật;
   server là nguồn sự thật."** Với REQ-016 điều đó không thể áp dụng: không có
   endpoint nào ở backend đóng băng để làm nguồn sự thật, và AC-23 đòi màn chạy
   được khi không hề có phía bên kia. Vì vậy story này giới thiệu **lớp dữ liệu
   thứ hai** trong cùng `CupidDatabase`: *dữ liệu solo do client sở hữu* — không
   sync, không counterpart server, và **cấm migration huỷ-tạo-lại** (ngược với
   bảng cache, nơi huỷ-tạo-lại là hợp lệ theo ADR-015.6). Ranh giới này phải
   được ghi ngay trong `cupid_database.dart` cạnh khai báo bảng, nếu không lần
   migration sau sẽ xoá dữ liệu gốc của người dùng theo đúng quy ước cache.
2. **`SessionScopedStore.clearOnSignOut()`** (`mobile/lib/core/auth/cupid_session.dart:8`)
   là hook mà mọi store dữ liệu đã xác thực trong repo này đăng ký. Nếu DAO thẻ
   đăng ký theo thói quen đó, **đăng xuất = xoá vĩnh viễn toàn bộ "kho tài sản"**
   — trực tiếp phá AC-22 và biến việc mất dữ liệu thành tác dụng phụ chứ không
   phải hành động của người dùng (R-12). Quyết định: DAO thẻ **không** đăng ký
   `SessionScopedStore`; cách ly người dùng khác trên cùng thiết bị làm bằng cột
   `owner_key` trong mọi truy vấn.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` (mô hình thẻ, 4 định
  danh trạng thái, danh sách cột cấm theo R-1b, cửa ghi `createCard`).

## 3. Scope And Assumptions

- In Scope: bảng `activity_cards` + `activity_card_photos` trong `CupidDatabase`
  (schema v3), repository/DAO thẻ, `ActivityCardListCubit` +
  `ActivityCardDetailCubit`, nhánh solo của `home_screen.dart`, segmented filter
  4 ngăn, dải lối-vào-nhanh 3 ô (khung), nhập nhanh "+"/dán link, chi tiết thẻ,
  đổi trạng thái, xoá, và gói asset dịp `occasions.v1.json` + loader.
- Out Of Scope: mọi endpoint backend, sync/đồng bộ, link preview, upload ảnh,
  bottom sheet lời mời (STORY-002), khối SB-211/SB-212 (STORY-006/007), bộ đếm
  của cải (STORY-012).
- Assumptions affecting design:
  - `home_screen.dart` đã có nhánh `isPaired` (`profile.partnerId != null`,
    `mobile/lib/features/home/presentation/home_screen.dart:382`); nhánh solo là
    chỗ gắn màn này.
  - `owner_key` lấy từ backend `User.id` đã có sẵn qua `BackendUserIdStore`.
  - Ảnh ký ức được **copy vào thư mục app sở hữu**, không giữ tham chiếu tới thư
    viện ảnh hệ thống, để xoá thẻ dọn được file và ảnh không biến mất khi người
    dùng dọn gallery.

### UI Delivery Anchor

- Design Scope Description: nhánh solo (chưa ghép đôi) của màn "Nhà" — header rút
  gọn, dải lối-vào-nhanh 3 ô, segmented control 4 ngăn sticky, danh sách thẻ rút
  gọn với đúng một nút hành động chính mỗi thẻ, trạng thái rỗng "Phút 1" hai lời
  mời, và màn chi tiết thẻ full-screen. Không đụng nhánh đã-ghép-đôi.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/lib/features/activity_cards/`
  (domain + data + presentation), với bảng/DAO đặt tại
  `mobile/lib/core/database/tables/` và `.../daos/` theo ADR-010 vì `core/`
  không được import `features/`.
- New or changed boundaries:
  - **Ranh giới mobile ↔ backend: toàn bộ story nằm ở mobile. Backend không có
    thay đổi nào, không có endpoint mới, không có DTO mới.** Đây là hợp đồng cho
    11 story sau: cửa vào sinh thẻ là hàm Dart, không phải HTTP.
  - Lớp "dữ liệu solo do client sở hữu" bên trong `CupidDatabase` (§1 Key
    Discovery), tách biệt về vòng đời với các bảng cache hiện có.
  - `primaryActionFor(status)` là hàm thuần, **nguồn duy nhất** ánh xạ trạng thái
    → hành động chính, để story sau không thể thêm hành động chính thứ hai.
- Shared patterns reused or introduced: Drift + DAO (ADR-007 pattern, ngữ nghĩa
  mới), Cubit cho CRUD (ADR-003), đăng ký trong
  `mobile/lib/core/di/service_locator.dart`; **mới**: `ContentPackage` loader đọc
  asset JSON có `id` + `version` + `items[]` — hình dạng tối thiểu để STORY-002+
  dùng lại cho kho preset của chúng (R-15a/R-15b: hành vi phải đúng với mọi N,
  cấm giả định "đúng 10 mục").

### Affected Modules

- Mobile: `features/activity_cards`, `features/home` (nhánh solo),
  `core/database`, `core/di`, `core/content` (loader gói dữ liệu), `assets/data`,
  l10n.

### Contracts And Integrations

- Error, retry, timeout, idempotency, empty-state:
  - **Không có lỗi mạng để xử lý** — mọi thao tác là ghi cục bộ; lỗi duy nhất có
    thật là lỗi I/O ổ đĩa, xử lý bằng thông báo trung tính, không kịch tính hoá.
  - Dán link mà không lấy được tiêu đề/ảnh là **suy giảm êm, không phải lỗi**
    (AC-7): thẻ vẫn tạo với `title` mặc định từ host của URL, `source_link` giữ
    nguyên. Story này không thử lấy metadata, nên không có timeout nào.
  - **Chuyển trạng thái là thao tác thuần trên cột `status`** (AC-15): không hàm
    nào được xoá kèm `scheduled_on`, ghi chú hay ảnh. Xoá dữ liệu chỉ xảy ra qua
    một mutation riêng do người dùng chọn rõ ràng trong hộp thoại.
  - **Không ràng buộc chéo cột**: `status = scheduled` **không** kéo theo
    `scheduled_on NOT NULL`. AC-14 cho phép chuyển tay tới mọi trạng thái theo cả
    hai chiều; thêm ràng buộc "cho gọn" ở DB sẽ phá AC-14.
  - Rỗng: kho rỗng tuyệt đối → ẩn segmented filter, hiện 2 lời mời (UX §4a);
    một ngăn rỗng → một dòng trung tính (UX §4b). Hai trạng thái này khác nhau,
    không dùng chung widget.
- Compatibility posture: định danh append-only; schema bump cộng thêm; không
  migration huỷ-tạo-lại cho bảng thẻ.
- External / trust boundary: không có. Không key, không config, không dịch vụ
  ngoài. `deployment/configuration-guide.md` **không** cần cập nhật.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Mất dữ liệu gốc khi đăng xuất | `cupid_session.dart:8` | DAO thẻ không đăng ký `SessionScopedStore`; cách ly bằng `owner_key` | Unit test: gọi toàn bộ `clearOnSignOut()` đã đăng ký rồi khẳng định thẻ vẫn còn, và truy vấn với `owner_key` khác trả về rỗng | `LOCAL_DATA_OWNERSHIP_UNVERIFIED` |
| R-1b — trôi schema sang đo hành vi người kia | `contract-summary.md` §4 | Danh sách cột cho phép là hợp đồng; `reply_state` chỉ 2 giá trị | Test khẳng định tập cột của `activity_cards` **đúng bằng** allowlist → thêm cột cấm là **gãy build** (R-15c) | `R1B_SCHEMA_GATE_MISSING` |
| Migration v2→v3 trên máy đã cài | `cupid_database.dart:35` | `onUpgrade` chỉ `createTable`, cấm huỷ-tạo-lại | Migration test: DB tạo ở v2 có dữ liệu cache → nâng lên v3, dữ liệu cũ còn nguyên, bảng mới tồn tại | `MIGRATION_TEST_UNAVAILABLE` |
| AC-15 mất dữ liệu âm thầm khi lùi trạng thái | `requirements.md` AC-15 | `updateStatus` thuần với các cột khác | Unit test: `scheduled → idea` giữ nguyên `scheduled_on`, ghi chú, ảnh | `LIFECYCLE_PURITY_UNVERIFIED` |
| SC-4/SC-5 — đúng một hành động chính, không ngõ cụt | `uiux-spec.md` §2 bảng SC-4 | `primaryActionFor` là hàm thuần duy nhất | Widget test 4 trạng thái: đúng 1 nút hành động chính, nhãn khớp bảng; mọi trạng thái có đường đi tiếp hoặc xoá | `SC4_MATRIX_UNVERIFIED` |
| R-7/BR-8 — AI hoặc API nội dung ở runtime | `requirements.md` AC-5 | Gợi ý dịp là hàm thuần trên asset đã ship | Test: luồng gợi ý chạy với HTTP client giả ném lỗi nếu bị gọi → vẫn ra 1–2 gợi ý tất định | `DETERMINISM_GATE_MISSING` |
| R-15a/R-15b — id bền, N là dữ liệu | `req_master.md` mục 15 | `ContentPackage` có `id`+`version`; không hằng số đếm | Test loader với gói N=1 và N=50: hành vi và trạng thái hết-tập đúng ở cả hai | `CONTENT_PACKAGE_N_GATE_MISSING` |
| SC-1' — danh sách thứ hai | `requirements.md` BR-1 | Một bảng, một repository, một cửa ghi | Review gate: không `@DriftDatabase` thứ hai, không bảng thẻ thứ hai | `SINGLE_STORE_GATE_MISSING` |
| Điểm vào không tới được | UX §1 | Gắn vào nhánh solo tab "Nhà", không route mới | Widget test: `isPaired == false` render kho thẻ | `ENTRYPOINT_UNVERIFIED` |
| Vỡ hợp đồng cho 11 story sau | `contract-summary.md` | Định danh append-only, kiểu Dart chứ không Map | Review gate của story sau đối chiếu `contract-summary.md` | `CONTRACT_DRIFT` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: toàn bộ story — schema + migration v3, DAO/repository, hai
  Cubit, nhánh solo `home_screen.dart`, segmented filter, dải 3 ô, nhập nhanh,
  chi tiết thẻ, xoá, gói dịp + loader, l10n, và toàn bộ gate ở bảng rủi ro.
- Authoritative inputs: `story_master.md`, `requirements/requirements.md`
  (AC-1..AC-23), `ux/uiux-spec.md` §1-§8, `architecture/contract-summary.md`.
- Guardrails:
  - Không thêm/ sửa bất kỳ file nào dưới `backend/`.
  - Không gọi mạng, không gọi mô hình AI, không thêm dependency HTTP mới.
  - Không đăng ký DAO thẻ làm `SessionScopedStore`.
  - Không tạo `@DriftDatabase` thứ hai (ADR-010) và không đặt bảng trong
    `features/`.
  - Không hard-code chuỗi nội dung dịp trong Dart; không giả định số mục cố định.
  - Không lưu, tính, hay hiển thị bất kỳ đại lượng hành vi nào của người kia; cờ
    `reply_state` chỉ đổi bởi thao tác của người dùng.
  - Không đổi 4 nhãn hành động chính và không thêm hành động chính thứ hai.

## 5. Non-Functional Impact

- Dữ liệu gốc chỉ tồn tại trên thiết bị: gỡ app hoặc mất máy là mất kho. Đây là
  đánh đổi có ý thức do A1 đóng băng backend; sao lưu/khôi phục là phạm vi của
  một requirement sau, không được xử lý bằng cách lén thêm endpoint ở story này.
- Danh sách thẻ phải phân trang từ Drift theo `status` + `owner_key` (chỉ mục
  trên cặp cột này), không giữ toàn bộ kho trong state Cubit — cùng lý do đã ghi
  trong system memory cho chat/timeline.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Drift cục bộ là nguồn sự thật, không backend | Backend A1 đóng băng; AC-23 đòi độc lập hoàn toàn | ACCEPTED | Kèm hai hệ quả bắt buộc ở §1 Key Discovery |
| Thêm module NestJS `activity-cards` + sync | Khớp ADR-007 "server là nguồn sự thật" | REJECTED | Vi phạm A1 (cần escalation chưa có), thêm bề mặt lưu dữ liệu quan hệ trên server đúng lúc R-1b/R-1f đang thu hẹp việc lưu trữ, và chặn cả 13 story sau sau một quyết định hạ tầng |
