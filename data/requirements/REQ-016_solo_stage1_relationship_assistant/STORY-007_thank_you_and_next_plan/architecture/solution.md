# STORY-007_thank_you_and_next_plan-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-09-20

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: một lượt kích hoạt trọn đời mỗi thẻ (AC-1..AC-5, BR-2,
  BR-3); tái dùng renderer STORY-002 không sửa engine (AC-8/AC-9, BR-5);
  riêng-tư-mặc-định của nhật ký khi đính ảnh (AC-17/AC-18, BR-8); đúng một
  đường tạo thẻ (AC-20, BR-11); tất định + ngoại tuyến (AC-29/AC-30).
- Architectural invariants / non-goals: không engine nội dung mới; không
  backend, không API ngoài, không AI; không đường tạo thẻ thứ hai; không phát
  trạng thái pha cho widget (BR-12); không lưu bất kỳ đại lượng hành vi nào của
  người kia (AC-26, BR-13); không đồng hồ hết hạn cho lượt kích hoạt (BR-3).
- Proposed technical direction: một **máy trạng thái lượt-kích-hoạt gắn theo
  thẻ, có trạng thái hấp thụ**, lưu cục bộ bằng drift; một **khối widget lồng**
  trong luồng "ghi lại" của chi tiết thẻ; ba phần bên trong khối chỉ **gọi lại**
  ba hạ tầng đã giao (renderer STORY-002, ảnh STORY-003/STORY-001, tạo thẻ
  STORY-001/STORY-005). Lane: **mobile duy nhất**.
- Why this fits: mọi AC đều là hành vi trên thiết bị, tất định, ngoại tuyến;
  tích hợp ngoài duy nhất là OS Share Sheet (+ image picker của OS). Không có
  AC nào cần lưu trữ hay tính toán phía máy chủ.

### Key Discovery

**(a) Ràng buộc module đã kiểm chứng trên base đã rebase.** Base hiện là
`bfe231aa` và đã mang code STORY-001/002/003/005. Các tên vật lý chốt cứng, hết
chỗ đoán: module thẻ là `mobile/lib/features/activity_cards`; engine preset của
STORY-002 là `mobile/lib/features/invite_composer` (`invite_preset.dart`,
`invite_renderer.dart`, `mad_libs.dart`, `preset_content_gate.dart`,
`preset_catalogue.dart`, `invite_payload.dart`); nhật ký là
`mobile/lib/features/journal` với bề mặt công khai duy nhất
`journal_entry_point.dart`. Mọi bảng drift khai báo tập trung ở
`mobile/lib/core/database/tables/`, không nằm trong thư mục feature, và
`schemaVersion` trong `mobile/lib/core/database/cupid_database.dart` hiện là
**9**.

**(b) Nguồn ảnh nhật ký của AC-14 hiện KHÔNG truy cập được.** Đây là phát hiện
đắt nhất của lượt kiểm chứng. `JournalEntries` không có khoá ngoại tới thẻ; cột
duy nhất có thể mang dấu vết nguồn là `originRef`, được tài liệu hoá là "opaque
provenance tag ... never parsed, never rendered, never turned into a link", và
**hiện không caller nào trong `lib/` điền giá trị cho nó**. Nặng hơn:
`journal_entry_point.dart` cố ý là hợp đồng **một chiều** — "a caller can hand
content in and can never read anything back out (AC-7)" — không có hàm liệt kê,
đếm, tìm hay xem trước, và không file nào ngoài `features/journal/**` được phép
import nội bộ nhật ký. Vậy nên AC-14 không thể hiện thực bằng code hiện có mà
không mở rộng hợp đồng của STORY-003. P4 dừng với
`JOURNAL_SOURCE_CONTRACT_CLOSED` cho tới khi có quyết định (A) thêm đúng một
hàm chiếu chỉ-đọc trả về danh sách đường dẫn ảnh theo `originRef` cộng với một
story ghi `originRef`, hay (B) thu hẹp AC-14 còn nguồn ảnh của thẻ. Nguồn ảnh
phía thẻ đã có sẵn và không vướng gì: bảng `ActivityCardPhotos` với cột
`cardId` tham chiếu `ActivityCards`.

**(b2) Cổng nội dung gắn cứng ngữ nghĩa lời mời vào mọi danh mục.**
`preset_content_gate.dart` bắt buộc **đúng một** clause `decline_door` cho mọi
preset, không phân nhánh theo danh mục. AC-21/AC-29 hứa thêm danh mục là thêm
dữ liệu, và `presetAssetKey()` đúng là ánh xạ bằng quy ước chuỗi tới
`assets/data/req016/presets.<categoryId>.v1.json`; nhưng một gói cảm ơn không
có "cửa từ chối" tự nhiên sẽ chết ở cổng với `declineDoorMissing`. P3 dừng với
`CONTENT_GATE_CATEGORY_COUPLING` cho tới khi chốt (A) đưa luật về phạm vi danh
mục, hay (B) PO chấp nhận preset cảm ơn vẫn mang clause tương đương.

**(c) AC-7 của STORY-003 không mâu thuẫn với AC-14 ở đây.** AC-7 cấm mọi bề mặt
khác hiển thị/trích/tham chiếu *nội dung* nhật ký, nhưng STORY-003 tự liệt
"đính ảnh từ nhật ký vào lời cảm ơn" vào Out of Scope và nhường cho STORY-007.
Ranh giới dung hoà chính là AC-17: **chỉ ảnh đi ra, chữ và siêu dữ liệu ở lại**
— được cưỡng chế bằng kiểu dữ liệu, xem mục 4.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` (hợp đồng dữ liệu
  danh mục preset mới + lời gọi tạo thẻ; story này single-lane nên file tồn tại
  để phục vụ ràng buộc cross-STORY, không phải cross-repo).

## 3. Scope And Assumptions

- In Scope: bảng trạng thái lượt-kích-hoạt + service vòng đời; khối widget lồng
  trong chi tiết thẻ; gói dữ liệu preset danh mục mới; projection ảnh chỉ-đọc;
  service gợi ý việc kế tiếp + lời gọi tạo thẻ.
- Out Of Scope: engine render; lược đồ/cổng nhập nội dung (chỉ thêm dữ liệu);
  bảng nhật ký STORY-003; mô hình thẻ STORY-001; mọi thứ thuộc STORY-012.
- Assumptions affecting design:
  - Renderer STORY-002 nhận `presetCategoryId` làm tham số và đã tách engine /
    gói dữ liệu / biến mad-libs (STORY-002 AC-20/AC-21). Nếu sai, dừng theo
    BR-5, không vá tại chỗ.
  - Cổng nhập nội dung chạy được của STORY-002 (AC-29) đã tồn tại và áp cho mọi
    danh mục; story này không thêm nhánh cổng.
  - Kho mồi STORY-005 và hàm tính dịp lịch âm trên thiết bị (STORY-005 AC-18)
    đọc được từ module STORY-005 mà không cần sửa nó.
  - `share_plus ^13.3.0` đã có trong `mobile/pubspec.yaml`; API hiện hành là
    `SharePlus.instance.share(ShareParams(text:, files: [XFile...]))` — chia sẻ
    text kèm nhiều file ảnh trong một lời gọi là được hỗ trợ; `Share.shareXFiles`
    đã deprecated (xác minh tại pub.dev, 13.3.0).

### UI Delivery Anchor

- Design Scope Description: khối con lồng **dưới cùng** vùng ảnh/ghi chú của
  **chi tiết thẻ ở trạng thái *Đã đi rồi*** (màn (1)), dùng đúng mẫu container
  của STORY-006. Không phải màn hình riêng, không thêm destination. Trạng thái
  cần dựng để đối chiếu: khối đầy đủ ba phần, và biến thể **không có ảnh**
  (phần 2 biến mất hoàn toàn).

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: module solo-stage-1 do STORY-001 giao trong
  `mobile/lib/features/activity_cards` (đã kiểm chứng, xem Key Discovery
  a). Story này thêm một sub-feature `thank_you` bên trong module đó.
- New or changed boundaries: một bảng drift mới thuộc sở hữu story này; một
  projection chỉ-đọc sang dữ liệu ảnh; **không** bảng nào của STORY-001/003 bị
  sửa lược đồ.
- Shared patterns reused: mẫu container khối lồng của STORY-006; bottom sheet
  renderer STORY-002; lời gọi tạo thẻ của STORY-005 AC-11.

### Affected Modules

- Mobile: sub-feature `thank_you` (mới), gói dữ liệu preset của STORY-002
  (thêm dữ liệu), lớp drift database của app (bump `schemaVersion` + migration).

### Contracts And Integrations

- Trạng thái rỗng: không có ảnh → phần 2 **không tồn tại** trong cây widget,
  không placeholder, không hàng xám (AC-15, BR-9). Kho mồi có N < số chip cần
  → render đúng phần có sẵn, không ô giữ chỗ, không màn rỗng (AC-35).
- Idempotency: `consume` của lượt kích hoạt phải idempotent — gọi lại trên thẻ
  đã CONSUMED là no-op, không ghi đè `consumedAt`. Đây là điều kiện để AC-3 giữ
  được khi widget rebuild nhiều lần.
- Ranh giới tin cậy: vật phẩm chia sẻ rời app qua OS Share Sheet; app **không**
  lưu kết quả trả về của Share Sheet dưới bất kỳ dạng trạng thái "đã gửi" nào
  (AC-26, BR-13).
- Compatibility: `presetCategoryId` là **append-only**; không đổi tên, không
  sắp xếp lại id đã ship.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Lượt kích hoạt một lần trọn đời | AC-1..AC-5, BR-2, BR-3 | Máy trạng thái `ARMED → CONSUMED\|CANCELLED` với hai trạng thái **hấp thụ**; không đường quay lại ARMED | Unit test phủ 5 chuyển: arm, đủ điều kiện sang ngày mới, consume, re-enter *Đã đi rồi* sau CONSUMED, rời trạng thái khi còn ARMED | `ACTIVATION_RULES_UNTESTABLE` |
| Biên ngày lịch địa phương | AC-1 vs AC-2 | So sánh **ngày lịch địa phương** (y/m/d), không so timestamp UTC, không so "24 giờ trôi qua" | Unit test với giờ 23:59 và 00:01 cùng một thẻ, và một lần đổi timezone | `LOCAL_DATE_RULE_UNVERIFIED` |
| Bump `schemaVersion` của drift | ADR-010 + lớp database hiện có | Số hiện tại là 9; bump lên 10 đúng một lần, viết migration, chạy lại codegen. Nếu khi bắt đầu P1 số đã khác 9 thì một nhánh song song đã bump trước — dừng, đừng bump chồng | Test migration + chạy bộ test đang assert `schemaVersion` | `DRIFT_SCHEMA_COLLISION` |
| Engine STORY-002 không bị sửa | AC-9, STORY-002 AC-21, BR-5 | Danh mục mới **chỉ** là dữ liệu; không thêm tham số, không nhánh `if category == ...` trong engine | Diff của phase không chạm file engine; test render danh mục mới chỉ qua id | `ENGINE_CONTRACT_BROKEN` |
| Cổng nhập nội dung dùng chung | AC-36, BR-18, STORY-002 AC-29 | Dữ liệu mới đi qua đúng cổng đã có; không nhánh cổng thứ hai | Fixture vi phạm (đo hành vi người kia / có %) phải làm **hỏng bản dựng** | `CONTENT_GATE_NOT_ENFORCING` |
| Hết-vòng đúng với mọi N | AC-34, BR-17 | Hành vi xoay vòng do renderer STORY-002 quyết định, story này không thêm logic đếm | Test với N=1 và N=seed: quay vòng, không thông báo "đã hết", không chỉ báo tiến độ | `WRAPAROUND_BEHAVIOR_DIVERGES` |
| Riêng tư nhật ký khi đính ảnh | AC-17, AC-18, BR-8, STORY-003 AC-7 | **Privacy by projection type**: kiểu ảnh trả về chỉ mang tham chiếu file, **không có trường** text/thời gian/nhãn — vi phạm thành lỗi biên dịch, không phải lỗi kỷ luật | Test khẳng định kiểu projection không phơi trường văn bản; test khẳng định xoá mục nhật ký vẫn xoá hết ảnh của nó | `JOURNAL_PRIVACY_UNPROVEN` |
| Nguồn ảnh nhật ký | `journal_entry_point.dart` (hợp đồng một chiều, AC-7) | Nhật ký không phơi ra bất kỳ lối đọc nào và không ai điền `originRef`; cần quyết định (A) thêm hàm chiếu chỉ-đọc + story ghi `originRef`, hay (B) thu hẹp AC-14 | P4 dừng ở bước 1 cho tới khi có quyết định; **cấm** migration lên bảng STORY-003 và cấm import vòng qua entry point | `JOURNAL_SOURCE_CONTRACT_CLOSED` |
| Luật `decline_door` áp cho mọi danh mục | `preset_content_gate.dart` | Gói cảm ơn chết ở cổng với `declineDoorMissing`; cần đưa luật về phạm vi danh mục hoặc PO chấp nhận clause tương đương | P3 dừng trước khi soạn nội dung | `CONTENT_GATE_CATEGORY_COUPLING` |
| Đúng một đường tạo thẻ | AC-20, AC-24, BR-11 | Gọi lại đúng contract STORY-005 AC-11, truyền `nguồn sinh` + ngày dịp | Test khẳng định thẻ mới vào *Mới nghĩ ra*, mang nguồn sinh, và undo xoá sạch | `CARD_CREATION_PATH_DUPLICATED` |
| Không phạt im lặng | AC-22, AC-25, AC-28 | Không ghi bất kỳ bộ đếm/huy hiệu/streak nào khi bỏ qua | Test: đóng khối không tạo thẻ, không sinh bản ghi nào ngoài `CONSUMED` | `SILENCE_PENALTY_LEAK` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: toàn bộ story — lớp dữ liệu lượt kích hoạt, khối widget và
  điểm gắn, gói dữ liệu preset, projection ảnh, service gợi ý + tạo thẻ.
- Authoritative inputs: `../requirements/requirements.md`, `../ux/uiux-spec.md`,
  file này, `architecture/contract-summary.md`.
- Guardrails: không sửa engine render STORY-002; không sửa lược đồ bảng nhật ký
  STORY-003 hay bảng thẻ STORY-001; không thêm nhánh cổng nhập nội dung; không
  tạo đường tạo thẻ thứ hai; không đọc trạng thái pha hay vẽ widget của
  STORY-012 (AC-31); không thêm hành động chính cấp thẻ thứ hai (AC-6, BR-1);
  không lưu trạng thái "đã gửi/đã xem" của người kia.

## 5. Non-Functional Impact

- Toàn bộ đường đi phải chạy đúng khi **không có mạng** tới tận Share Sheet
  (AC-29) — cấm mọi lời gọi mạng, cấm skeleton chờ mạng trong khối.
- Bump `schemaVersion` là thay đổi có rủi ro lan: nó làm đỏ các assertion về
  phiên bản ở nhiều file test hiện có; P1 phải sửa chúng trong cùng phase.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Máy trạng thái gắn theo **thẻ** với trạng thái hấp thụ | Là cách duy nhất làm AC-3, AC-4, AC-5 nhất quán cùng lúc | ACCEPTED | AC-5 huỷ lặng lẽ, AC-4 cấm tái kích hoạt ⇒ CANCELLED cũng phải hấp thụ, đúng BR-2 "đúng một lượt trọn đời" |
| Suy ra điều kiện hiện khối từ mốc thời gian chuyển trạng thái, không lưu bảng riêng | Tránh bump schema | REJECTED | Không phân biệt được "chưa từng hiện" với "đã hiện rồi" sau khi thẻ đổi trạng thái hai chiều (AC-4), và không diễn đạt được huỷ lặng lẽ (AC-5) |
