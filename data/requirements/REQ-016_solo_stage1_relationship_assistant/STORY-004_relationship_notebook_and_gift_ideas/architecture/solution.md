# STORY-004 Gợi ý quà, sổ tay và hồ sơ kỹ năng thu thập tại chỗ — solution

## 0. Metadata

- Complexity: complex (`Story-Class: shared-foundation`)
- Date: 2026-09-10

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: SC-3 (không điền trước) buộc cơ chế thu thập phải là một
  **component inline dùng chung**, không phải một luồng onboarding; R-15 buộc
  toàn bộ nội dung thành **gói dữ liệu có lược đồ + cổng nhập chạy được**; BR-15
  biến hình dạng kho ngữ cảnh thành **hợp đồng khoá** cho STORY-005/008/009/010.
- Architectural invariants / non-goals: không backend, không mạng, không AI
  runtime (R-7/AC-28); không bảng "quà đã lưu" (SC-1'/AC-22); không cột đo hành
  vi người kia và không cột mức độ kỹ năng (R-1b/AC-12); không hằng số `10`
  hay bất kỳ ràng buộc nào lên N (R-15b); không VNĐ trên bất kỳ bề mặt nào
  (R-11).
- Proposed technical direction: hai module Flutter mới —
  `features/context_notebook/` (sổ tay + hồ sơ kỹ năng + hỏi-tại-chỗ, pha 1) và
  `features/gift_ideas/` (màn (5), pha 2 và 3) — trên ba bảng Drift cộng thêm và
  năm gói asset JSON đi qua `ContentPackage` sẵn có. Đầu ra của quà ghi vào kho
  thẻ STORY-001 qua `createCard`, không dựng kho thứ hai.
- Why this fits: cả `ContentPackage`/`ContentPackageLoader`, `CupidDatabase`
  (một Drift owner duy nhất, ADR-010), và mẫu `*_entry_point.dart` một chiều của
  STORY-003 đều đã có. Story này thêm dữ liệu và màn, không thêm hạ tầng.

### Key Discovery

**Luật bất biến của R-15c hiện đang nằm trong một feature, gắn kiểu với một họ
gói.** `mobile/lib/features/invite_composer/domain/preset_content_gate.dart`
chứa `_deniedTerms` (tâng bốc, `%`, streak, điểm/hạng, hành vi người nhận, giọng
thao túng) nhưng `validatePresetPack` nhận đúng
`ContentPackage<InvitePreset>`. Năm gói của story này có hình dạng item khác
hẳn, nên cách rẻ nhất là chép danh sách từ cấm sang gate mới — và đó chính là
thứ D-15 cấm: hai bộ luật song song, nội dung CMS bị xử theo bộ nào chạy trước,
nới một bộ không làm đỏ bộ kia. Quyết định: **tách tầng luật, không tách lần
hai.** `_deniedTerms` + hàm so khớp nguyên-từ chuyển sang
`mobile/lib/core/content/invariant_terms.dart`; `preset_content_gate.dart` giữ
nguyên `PresetGateRule`, `PresetViolation`, `validatePresetPack` và mọi hành vi
quan sát được, chỉ đổi nguồn danh sách. Đây là điều kiện để có một câu trả lời
duy nhất cho "luật bất biến là gì" khi gói thứ sáu xuất hiện ở STORY-005/007.

Hệ quả thứ hai, ngược chiều với trực giác: STORY-002 §6 viết "không thêm
`schema_id` riêng cho danh mục mới". Ràng buộc đó áp cho **danh mục mới của họ
preset mad-libs** (`presets.thanks`), nơi một schema id riêng sẽ nhân đôi nhánh
cổng nhập cho cùng một hình dạng item. Năm gói ở đây là **họ khác**: ép chúng
vào `req016.presets.v1` sẽ tạo một lược đồ hợp-nhiều-hình-dạng mà không validator
nào kiểm được chặt. Mỗi họ một `schema_id`, mọi họ **một** tầng luật.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md`

## 3. Scope And Assumptions

- In Scope: ba bảng Drift cộng thêm, năm gói asset + hai cổng nhập chạy được,
  component hỏi-tại-chỗ dùng chung, ba màn ((2), (3), (5)) và hai lối vào.
- Out Of Scope: mọi thay đổi hợp đồng thẻ STORY-001, CMS/đồng bộ nội dung, và
  liên kết khoá vị trí sang STORY-009/010 (chỉ chừa chỗ đặt liên kết văn bản).
- Assumptions affecting design:
  - `schemaVersion` trên nhánh tích hợp là 5 lúc viết tài liệu này, nhưng
    STORY-003 còn đang chạy. Người cài đặt **đọc giá trị thật rồi cộng một**;
    con số cụ thể không được chép từ tài liệu.
  - `QuickEntryCell.giftIdeas` đã tồn tại trong
    `features/activity_cards/presentation/widgets/quick_entry_strip.dart` với
    nhãn "Gợi ý quà" và một `onSelected` để trống (đang rơi vào snackbar "Sắp
    có"). Lối vào màn (5) là **nối dây `onSelected` ở nơi dựng strip**, không
    phải thêm ô mới.
  - Thư mục `assets/data/req016/` đã khai báo trong `pubspec.yaml`.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| OQ-3 | ĐÃ ĐÓNG 2026-09-06 (D-15 → R-15) | Không còn chặn gì | Toàn bộ story | Ba ràng buộc thành thiết kế: (a) năm gói có `schema_id` + id bền (§4 Contracts); (b) N là thuộc tính gói, xoay vòng modulo `length`, không con trỏ lưu xuống DB; (c) luật bất biến là hai cổng nhập chạy được dựng trên `core/content/invariant_terms.dart`, không phải quy ước biên tập |

### UI Delivery Anchor

- Design Scope Description: ba màn tách biệt, không màn nào là tab con của màn
  kia. Màn (5) "Gợi ý quà" = header + dải nhánh/bộ lọc (tab nhánh, chip "2 tiếng
  tối nay", thanh chọn công sức theo **giờ**) + danh sách thẻ gợi ý, mỗi thẻ đúng
  một pill "Thêm vào kho của tôi", cộng một chỗ chèn `AskOnTheSpotSlot` giữa
  danh sách và một liên kết văn bản nhỏ cuối màn. Màn (2) "Sổ tay người yêu" =
  hai group header cố định ("Sở thích", "Sự kiện"), hàng đơn giản + menu "..."
  chỉ chứa Sửa/Xoá, nút "+ tự thêm" mở hàng nhập inline ở cuối mỗi nhóm. Màn (3)
  "Những gì bạn giỏi" = danh sách chỉ-tên-kỹ-năng, không mức độ, cộng dải chip
  mồi khi rỗng. Không màn nào có icon chia sẻ/xuất.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/` package `cupid_mobile`.
- New or changed boundaries: `features/context_notebook/` sở hữu sổ tay, hồ sơ
  kỹ năng, và cơ chế hỏi-tại-chỗ; nó xuất **một** file mặt tiền một chiều
  (`context_notebook_entry_point.dart`, theo đúng mẫu
  `features/journal/journal_entry_point.dart`) và không rò DAO/Cubit/widget nội
  bộ. `features/gift_ideas/` sở hữu màn (5) và là **phía tiêu thụ** của cả kho
  ngữ cảnh lẫn `ActivityCardRepository`; nó không có bảng riêng.
- Shared patterns reused or introduced: reused — `ContentPackage`/
  `ContentPackageLoader`, `CupidDatabase` một-owner, `getIt`, mẫu entry-point
  một chiều. Introduced — `core/content/invariant_terms.dart` (tầng luật bất
  biến dùng chung, tách ra từ `preset_content_gate.dart`).

### Affected Modules

- Mobile: `features/context_notebook`, `features/gift_ideas`,
  `features/invite_composer` (chỉ đổi nguồn danh sách từ cấm),
  `core/content`, `core/database`, `core/di`, `features/activity_cards` (nối dây
  `onSelected` của quick-entry strip), `features/account` (hai `_MenuRow` mới
  trong khối "Kho riêng của tôi").
- Data: `assets/data/req016/` — năm gói `*.v1.json` mới.

### Contracts And Integrations

- Error, retry, timeout, idempotency, empty-state: gói sai `schema_id` hoặc
  thiếu khoá bắt buộc ném `ContentPackageFormatException` ngay lúc load — không
  có nhánh "im lặng bỏ qua" và không có giá trị mặc định thay thế. Trạng thái
  rỗng là **hợp lệ ở mọi tầng**: sổ tay rỗng vẫn ra gợi ý (AC-15), hồ sơ kỹ năng
  rỗng rơi êm về nhánh pha 2 kèm một dòng trung tính (AC-13), một nhánh không còn
  mục khớp rơi vào trạng thái rỗng đã định của chính nhánh đó, không báo lỗi và
  không ô giữ chỗ (AC-34). Hết-tập là **quay vòng modulo `length`** với con trỏ
  giữ trong Cubit, nên cùng đầu vào cho cùng kết quả sau mỗi lần mở màn (AC-28).
- Compatibility posture: id bền của cả năm gói là append-only; `notebook_entries.
  question_id` và `skill_profile_entries.seed_id` trỏ ngược vào chúng, nên xoá
  một id đã ship làm mồ côi dữ liệu người dùng. Migration chỉ cộng thêm.
- External or trust-boundary implications: nội dung tương lai do CMS ngoài repo
  cấp và **không đi qua review của repo này** — đó là lý do luật sống trong Dart
  còn câu chữ sống trong asset, không bao giờ ngược lại.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Rẽ đôi tầng luật bất biến (bộ thứ hai trong gate mới) | `core/content/invariant_terms.dart` | Tách `_deniedTerms` ra core; hai cổng nhập mới **import**, không chép | Unit test: `preset_content_gate_test.dart` giữ nguyên xanh sau khi tách; test mới khẳng định cả ba gate đọc cùng một map | `CONTENT_GATE_FORK` |
| Ranh giới sổ tay bị bẩn từ tầng ĐẦU VÀO (AC-36) | `ask_questions.v1.json` + gate câu hỏi | Quy tắc validation từ chối câu hỏi về tần suất/hành vi/đánh giá con người; `target` là enum đóng ba giá trị | Test quét asset từ đĩa; fixture vi phạm phải làm đỏ | `NOTEBOOK_INPUT_GATE_MISSING` |
| VNĐ/giá lọt vào bề mặt quà (AC-16/AC-19/AC-23) | `gift_content_gate.dart` + `contract-summary.md` §4 | Gate từ chối token VNĐ/`₫`/rẻ-đắt/link mua trong gói; luồng quà **không bao giờ** ghi `price_vnd`; cấm tái dùng component "price range slider" của design system | Test cổng nhập + widget test khẳng định không widget nào của màn (5) đọc `price_vnd`; visual-fidelity của phase dựng màn (5) | `PRICE_LEAK` |
| Hằng số N rò vào hành vi (AC-33/AC-34/BR-17) | `ContentPackage.length` | Nhánh và bậc công sức là item dữ liệu; xoay vòng modulo; cấm chỉ báo tiến độ/đếm | Test chạy cùng bộ kịch bản với gói N=1 và N=200, kết quả cùng hình dạng; grep khẳng định không có `10` cứng | `N_COUPLING` |
| Migration Drift đụng độ với STORY-003 đang chạy | `CupidDatabase.schemaVersion` trên nhánh tích hợp | Chỉ `CREATE TABLE`, không sửa bảng cũ; đọc `schemaVersion` thật rồi +1; cấm huỷ-tạo-lại | Drift migration test v(n)→v(n+1) giữ nguyên mọi hàng `activity_cards`/`journal_entries`/`invite_messages` | `SCHEMA_CONTENTION` |
| Hợp đồng shared-foundation bị định hình sai (BR-15) | `architecture/contract-summary.md` §3/§4 | `AskOnTheSpotSlot` tự giữ bất biến "một câu một lần"; `ContextNotebookReader` là API duy nhất đọc ra ngoài feature | Test: dựng hai slot trên cùng route → slot thứ hai render rỗng; test import-boundary như STORY-003 | `SHARED_CONTRACT_UNSTABLE` |
| Hồ sơ kỹ năng trượt về hình dạng CV (AC-10/AC-11/AC-12) | `skill_seeds.v1.json` + màn (3) | Gói không có trường nhóm/hạng nên không thể vẽ "nhóm phụ"; gate bắt buộc đủ bốn id kỹ năng mềm; bảng không có cột mức độ | Widget test: khi rỗng, ≥4 chip mồi hiện trước mọi ô nhập; test khẳng định không sao/điểm/thanh mức độ | `CV_SHAPE_REGRESSION` |
| Kho thẻ thứ hai / điểm dừng chân (SC-1'/SC-2/AC-21) | `STORY-001/architecture/contract-summary.md` | `features/gift_ideas` không có bảng và không có DAO; hành động chính gọi `createCard(origin: gift_suggestion)` | Widget test: bấm pill tạo đúng một thẻ `idea`; test khẳng định module không đăng ký bảng nào | `SECOND_HUB` |
| Đường đi không tất định / gọi mạng (AC-28/R-7) | Repository quà | Toàn bộ chỉ mục là bảng tra ship kèm; không `http`, không SDK AI trong hai module mới | Test gọi cùng đầu vào hai lần cho kết quả bằng nhau; grep import khẳng định không có client mạng | `NONDETERMINISM` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: cả story. Không có lane backend, frontend, hay devops —
  không endpoint mới, không biến môi trường, không secret, không thay đổi
  runtime registry.
- Authoritative inputs: `architecture/contract-summary.md` (hợp đồng),
  `requirements/requirements.md` (AC/BR), `ux/uiux-spec.md` (bố cục ba màn),
  `STORY-001/architecture/contract-summary.md` (`createCard`, enum, cột cấm).
- Guardrails:
  - Không thêm cột nào vào `activity_cards`. Ước lượng công sức đi vào
    `duration_minutes` (đơn vị phút, hiển thị theo quy ước Việt) — cột này đã có
    từ phán quyết B-1 và B-1 là **tập đóng**; `price_vnd` để `null` vĩnh viễn.
  - Không chép danh sách từ cấm sang gate mới.
  - Không lưu con trỏ xoay vòng, không lưu "quà đã chọn", không lưu bất kỳ số
    đếm nào của người dùng.
  - Không thêm route/nút/menu nào cho phép xuất, chia sẻ, hay copy toàn bộ sổ
    tay — kể cả trong menu "..." của từng mục.
  - Giữ nguyên thứ tự pha SB-174 (sổ tay/kỹ năng → quà → handmade) khi lập
    `coding-plan/master-plan.md`.

## 5. Non-Functional Impact

- Năm gói asset nạp một lần rồi giữ trong bộ nhớ; ở N vài trăm mục, lọc là quét
  danh sách trong RAM nên AC-34 ("không bước tải/đợi mới") đạt được bằng thiết
  kế, không bằng tối ưu. Nếu một gói tương lai lớn tới mức phải phân trang, đó
  là thay đổi hợp đồng, không phải tinh chỉnh.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Tách luật bất biến sang `core/content/invariant_terms.dart`, hai cổng nhập mới import | R-15c cần **một** câu trả lời cho "luật là gì" khi gói thứ sáu xuất hiện | ACCEPTED | Chi phí là một lần sửa cơ học trong `preset_content_gate.dart` với hành vi quan sát được giữ nguyên |
| Ép năm gói vào `schema_id` `req016.presets.v1` để khỏi thêm nhánh cổng nhập | STORY-002 §6 đọc thoáng qua có vẻ cấm schema id mới | REJECTED | Một lược đồ hợp-nhiều-hình-dạng thì không validator nào kiểm chặt được; ràng buộc đó áp cho danh mục mới của họ preset, không áp cho họ khác (§1 Key Discovery) |
