# STORY-002_invite_message_composer-solution.md

## 0. Metadata

- Complexity: complex (Story-Class: shared-foundation)
- Date: 2026-09-10

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: nội dung phải là **dữ liệu có id bền** chứ không phải
  chuỗi trong code (R-15a); luật bất biến phải là thứ **máy kiểm được ở cổng
  nhập**, không phải quy ước biên tập (R-15c/BR-16); payload lưu phải **render
  lại được** để chặng 1.5 không thiết kế lại (SB-125); renderer phải nhận danh
  mục làm **tham số dữ liệu** để STORY-007 chỉ thêm file (AC-20..AC-22).
- Architectural invariants / non-goals: runtime tất định, không một lời gọi
  mạng nào trên đường sinh nội dung (R-7/AC-8); đầu ra duy nhất là OS Share
  Sheet (AC-16); không lưu và không hiển thị bất kỳ đại lượng hành vi nào của
  người nhận (R-1b); không đếm, không xếp hạng, không A/B test lời mời (R-1e);
  thẻ vẫn có đúng một hành động chính (SC-4/AC-2).
- Proposed technical direction: một feature module mobile-only
  `features/invite_composer/` gồm ba lớp tách rời — (a) **engine** thuần Dart
  (parser preset + renderer clause + cổng nhập luật), (b) **gói nội dung** là
  asset JSON theo danh mục, (c) **bộ biến mad-libs** rút từ `ActivityCard`.
  Lớp (a) tái dùng nguyên vẹn `core/content/ContentPackage` của STORY-001. Lưu
  trữ là một bảng drift mới `invite_messages` (schema v5, migration cộng thêm).
- Why this fits the current system: STORY-001 đã giao đúng nửa "nội dung là dữ
  liệu" của R-15a và ghi rõ trong source rằng đó là hình dạng "STORY-002+ preset
  stores reuse". Story này bổ sung nửa còn lại — nửa **luật**.

### Key Discovery

1. **Thẻ không có trường địa điểm.** AC-4 liệt kê "địa điểm" là một chỗ trống
   được điền bằng trường thật của thẻ, và AC-6 xử lý trường hợp nó thiếu; nhưng
   `ActivityCard` (v4, 16 trường) **không có** cột nào mang nghĩa địa điểm —
   `note`, `note_keywords`, `link_source_label` đều mang nghĩa khác. Suy ra địa
   điểm từ ba trường đó là suy diễn, R-1e cấm. Quyết định: thêm cột nullable
   `location` vào `activity_cards` ở v5 và một ô nhập tương ứng trong form chi
   tiết thẻ đã có (nó đã chứa 14 trường tuỳ chọn cùng dạng; đây là trường thứ
   15, không phải bề mặt mới). Không có cột này thì AC-4 không thể thoả — mọi
   lời mời sẽ vĩnh viễn đi nhánh AC-6. **Cần PO biết**: đây là mở rộng nhỏ hợp
   đồng dữ liệu của STORY-001, cộng thêm và không phá vỡ.
2. **Hành động "Chuẩn bị" hiện là stub.** `activity_card_detail_screen.dart`
   đang hiện snackbar "Phần chuẩn bị nằm ở bước sau" và ghi chú rằng STORY-002
   sở hữu bước này. Vậy story này sở hữu **cả bề mặt "Chuẩn bị"** (danh sách
   lựa chọn mà STORY-006/STORY-008 sẽ nối thêm vào), không chỉ bottom sheet
   soạn lời mời. Bỏ sót điều này là bỏ sót cửa vào — AC-1 không thoả.
3. **AC-7 và AC-18 kéo ngược nhau, AC-17 đứng giữa.** Người dùng sửa được toàn
   văn (AC-7), bản lưu phải là payload có cấu trúc chứ không phải chuỗi bẹp
   (AC-17), nhưng render lại phải ra **đúng** văn bản đã xuất kể cả sau khởi
   động lại (AC-18). Ba điều đó chỉ đồng thời đúng khi bản sửa tay được lưu như
   một **trường ghi đè phụ** bên cạnh payload có cấu trúc, không thay thế nó.
   Chi tiết ở `contract-summary.md` §4.
4. **Luật đi ngược chiều với nội dung.** Vì nguồn nội dung sẽ chuyển sang CMS
   ngoài repo (R-15a), cổng nhập chỉ có giá trị khi luật **không** nằm trong dữ
   liệu: nội dung là asset, luật là Dart. Một denylist đặt trong asset sẽ cho
   phép chính CMS nới luật của nó.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md`

## 3. Scope And Assumptions

- In Scope: bề mặt "Chuẩn bị" + bottom sheet soạn lời mời, engine render tất
  định đa danh mục, gói preset danh mục `invite`, cổng nhập luật bất biến, bảng
  `invite_messages` (drift v5), cột `location` trên `activity_cards`.
- Out Of Scope: danh mục `thanks` (STORY-007), cửa vào từ kịch bản (STORY-008),
  mọi kênh phản hồi/link hai chiều của chặng 1.5, backend, DevOps, l10n hoá câu
  chữ preset.
- Assumptions affecting design:
  - Gói preset stage 1 là **một locale (`vi`)**. Locale thứ hai là một gói mới
    theo cùng quy ước khoá asset, không phải một nhánh engine.
  - Kiểm duyệt biên tập hai lớp (BR-10) là quy trình con người ghi vết trong
    `editorial_review`; không có bề mặt app nào cho nó (UX §7).
  - Bộ 5 biến mad-libs là **đóng** ở story này. Thêm biến thứ 6 là đổi hợp đồng
    §2, không phải thêm dữ liệu.

### UI Delivery Anchor

- Design Scope Description: hai bề mặt modal chồng nhau mở từ chi tiết thẻ ở
  trạng thái *Đã hẹn ngày* — (1) sheet "Chuẩn bị" dạng danh sách lựa chọn, chỉ
  một mục ở story này ("Xuất lời mời"), cố ý để trống chỗ cho mục của
  STORY-006/008; (2) sheet "Soạn lời mời" bo góc `--r-sheet`, cao ~70% và kéo
  giãn được, gồm dải chip khung nhại cuộn ngang, khối xem trước sửa được tại
  chỗ, và một pill `--grad` "Chia sẻ". Không route mới, không mục menu, không ô
  nhập người nhận.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/lib/features/invite_composer/`.
- New or changed boundaries:
  - `domain/` là **thuần Dart**: không `flutter/material.dart`, không
    `dio`/`cupid_api`, không `DateTime.now()`, không `Random`. Đây là ranh giới
    làm cho AC-8 (không AI runtime) và AC-9 (tất định) kiểm được bằng test import
    chứ không bằng lời hứa.
  - `preset_content_gate.dart` là **nguồn duy nhất** của luật bất biến, đặt
    trong `lib/` chứ không trong `test/`, vì đường nạp CMS tương lai phải gọi
    được đúng hàm mà bản dựng đang gọi.
  - Cột `location` và bảng `invite_messages` là mở rộng cộng thêm lên
    `core/database/`; module này **không** sửa ngữ nghĩa cột nào của STORY-001.
- Shared patterns reused: `ContentPackage`/`ContentPackageLoader`
  (`core/content/`) không sửa một dòng; `SharePlus.instance.share(ShareParams)`
  đúng như tiền lệ đã kiểm chứng trong `features/home/presentation/home_screen.dart`
  (share_plus 13.3.0, `Share.share` tĩnh đã deprecated ở phiên bản này);
  `flutter_bloc` cubit + repository interface như `activity_cards/`.

### Affected Modules

- Mobile: `features/invite_composer/` (mới), `features/activity_cards/`
  (điểm vào "Chuẩn bị", cột `location` trên model/repository/form chi tiết),
  `core/database/` (schema v5).
- Data: `mobile/assets/data/req016/` (gói preset danh mục `invite`).

### Contracts And Integrations

- Migration v4 → v5 có **hai** bước độc lập và một cái bẫy thứ tự: máy đến từ
  `from < 3` nhận `createTable(activityCards)` vốn đã phát sinh định nghĩa
  *hiện tại* nên đã có sẵn `location`, còn máy dừng ở v3 hoặc v4 thì chưa. Vì
  vậy `addColumn(location)` phải nằm trong nhánh `else` của `from < 3` và có
  điều kiện riêng `from < 5`, không nối vào chuỗi `else if (from < 4)` đang có
  — nối vào đó sẽ bỏ sót đúng nhóm máy đang ở v4. `createTable(inviteMessages)`
  thì vô điều kiện với mọi `from < 5`.
- Share Sheet là **fire-and-forget**: `ShareResult` không được đọc, không
  snackbar, không retry, không lưu. Người dùng đóng sheet là kết cục bình
  thường, và đọc kết quả chính là cửa sau dẫn tới đo hành vi (R-1b).
- Payload được ghi tại thời điểm bấm "Chia sẻ", **trước** khi Share Sheet mở, và
  một lần cho mỗi lần bấm. Không có idempotency key: bấm chia sẻ hai lần là hai
  vật phẩm, và vì không bề mặt nào đếm chúng (AC-14/UX §4) thì trùng lặp không
  quan sát được. Lần xuất đầu tiên đặt `activity_cards.invited = true`, đó là
  toàn bộ liên hệ giữa story này và toggle *đã/chưa trả lời* mà STORY-001 đã vẽ.
- Empty-state: gói preset đã qua cổng nhập luôn có ≥ 1 preset, nên sheet rỗng là
  lỗi lập trình chứ không phải trạng thái người dùng. Nếu danh mục không giải
  ra được gói nào, mục "Xuất lời mời" **không xuất hiện** trong danh sách
  "Chuẩn bị" — không mở sheet rỗng, không màn lỗi (AC-27).

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Luật bất biến lọt qua nội dung (R-1b/c/d/e, R-10, %, streak, tâng bốc) | AC-28, BR-16 | `validatePresetPack` trong `lib/`: cấu trúc (`targets` không có giá trị `recipient`, đúng một clause `decline_door` với `requires: []`) + denylist từ vựng đặt trong Dart | Test quét **mọi** file `assets/data/req016/presets.*.json` từ đĩa và chạy gate; gói vi phạm làm đỏ `flutter test` → hỏng bản dựng | `CONTENT_GATE_UNVERIFIED` — không ship gói preset |
| Hình dạng payload SB-125 (hợp đồng với STORY-007/008 và chặng 1.5) | AC-17..AC-19, `contract-summary.md` §4 | payload có cấu trúc + `user_edited_text` là trường ghi đè phụ | Test round-trip: lưu → khởi động lại (mở lại DB) → render lại ra **đúng** chuỗi đã xuất, cả nhánh có sửa tay và không sửa | `PAYLOAD_CONTRACT_UNVERIFIED` |
| Migration phá dữ liệu chỉ tồn tại trên máy | STORY-001 §1 Key Discovery | v5 chỉ cộng thêm; nhánh `location` tách khỏi chuỗi `else if` (§4) | Test migration từ **cả** v3 và v4 lên v5, khẳng định hàng `activity_cards` cũ còn nguyên | `MIGRATION_UNVERIFIED` |
| Cửa vào và SC-4 | AC-1..AC-3, UX §1/§8 | sheet "Chuẩn bị" là danh sách lựa chọn; thẻ không có hành động chính thứ hai | Widget test: thẻ *Đã hẹn ngày* có đúng 1 hành động chính; đi từ hành động đó tới sheet soạn lời mời; không route/menu mới | `ENTRYPOINT_UNVERIFIED` |
| Tất định và không AI runtime | AC-8, AC-9 | `domain/` thuần Dart, không client HTTP | Test render hai lần cùng thẻ + cùng khung ra chuỗi bằng nhau; test khẳng định `domain/` không import `dio`/`cupid_api`/`http` | `DETERMINISM_UNVERIFIED` |
| N là thuộc tính dữ liệu | AC-26, AC-27, R-15b | chỉ số chip tính modulo `ContentPackage.length`; không chỉ báo tiến độ | Test cùng hành vi với gói N = 1 và N = 200: quay vòng đúng thứ tự, không widget nào hiện số lượng/tiến độ | `N_INDEPENDENCE_UNVERIFIED` |
| Trung thực thị giác của hai sheet | UX §1, §2 | dựng theo token `--r-sheet`/`--r-card`/`--grad` sẵn có | Per-story visual-fidelity capture của phase dựng UI | `VISUAL_FIDELITY_UNVERIFIED` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: toàn bộ story. Không có lane backend, frontend, hay DevOps —
  không endpoint, không biến môi trường, không secret, không thay đổi runtime.
- Authoritative inputs: `requirements/requirements.md`, `ux/uiux-spec.md`,
  `architecture/contract-summary.md`, và source hiện có của
  `core/content/`, `core/database/`, `features/activity_cards/`.
- Guardrails:
  - Không đặt bất kỳ câu chữ lời mời nào vào Dart hay l10n; không đặt bất kỳ
    luật bất biến nào vào asset.
  - Không sửa `core/content/content_package.dart` — nếu thấy cần sửa, đó là dấu
    hiệu schema preset đang đi chệch hình dạng dùng chung; dừng và báo.
  - Không đọc `ShareResult`, không thêm cột thời gian/trạng thái người nhận,
    không thêm API đếm payload theo thẻ.
  - Không thêm hành động chính thứ hai lên thẻ, không thêm route hay mục menu.
  - Không dùng chỉ số danh sách làm định danh preset ở bất kỳ đâu.

## 5. Non-Functional Impact

- Gói preset được parse một lần cho mỗi danh mục rồi giữ trong bộ nhớ suốt vòng
  đời sheet: đổi chip là thao tác trong RAM, nên hành vi không đổi giữa N = 1 và
  N vài trăm và không sinh bước tải mới (AC-27).
- Toàn bộ đường sinh nội dung chạy offline; máy bay chế độ không đổi hành vi.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Clause có `requires`, thiếu biến thì **bỏ nguyên câu** | AC-6 cấm placeholder rỗng/ngoặc trống, UX §3 đã ràng buộc preset phải soạn thành câu ngắn rời | ACCEPTED | Ngữ pháp câu còn lại không bao giờ gãy vì không câu nào bị sửa dở; cửa từ chối `requires: []` nên bất tử |
| Thay placeholder bằng chuỗi rỗng rồi dọn dấu câu bằng regex | Ít dữ liệu hơn trong gói preset | REJECTED | Dọn dấu câu tiếng Việt bằng regex là heuristic: nó **có thể** để lọt " ở ." tới người đọc, đúng thứ AC-6 cấm, và lỗi chỉ lộ ra ở tổ hợp trường thiếu hiếm gặp |
