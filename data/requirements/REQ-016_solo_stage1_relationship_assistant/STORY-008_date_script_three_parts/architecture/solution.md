# STORY-008_date_script_three_parts-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-09-11

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: khoá vị trí không thể lách (AC-3/AC-4/AC-5); J7 để trống
  là ràng buộc kiến trúc, không phải "chưa làm" (AC-13..AC-16); nội dung là gói
  dữ liệu qua cổng nhập chạy được cho mọi N (AC-33..AC-37); ba cửa ra **gọi lại**
  hạ tầng STORY-001/002/003, không nhân bản (BR-7).
- Architectural invariants / non-goals: màn (9) **không có route đặt tên** và
  **không có bảng/cột mới** — story này không ghi gì xuống DB, `schemaVersion`
  giữ nguyên; không mạng, không AI, không timer/notification ở mọi đường đi.
- Proposed technical direction: một feature mobile mới
  `mobile/lib/features/date_script/`, thuần đọc. Nó nạp một **họ gói nội dung
  mới** (`req016.date_script.v1`), chọn preset bằng một hàm toàn phần tất định
  theo `(pack, card)`, render mad-libs từ trường thẻ + sổ tay, và điều hướng ra
  ngoài qua đúng ba entry point đã có.
- Why this fits: bốn story phụ thuộc đều đã hội tụ về cùng một khuôn — gói asset
  `ContentPackage` + cổng nhập test-time + entry-point file duy nhất cho mỗi
  feature. Story này lắp thêm một mắt xích cùng khuôn, không dựng khuôn mới.

### Key Discovery

**(a) "Khu vực Chuẩn bị" không phải một widget — nó là hai bề mặt.** Mục 1
("Xuất lời mời") là một hàng trong bottom sheet
`mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart`;
mục 3 ("Trước giờ đi") là `BeforeYouGoSection` dựng **inline** trên
`activity_card_detail_screen.dart` vì nó tự quyết định có hiện hay không. Nên
"mục thứ 2" của `ux/uiux-spec.md` §1 rơi vào **sheet**, và `_resolveActions`
trong file đó đã dành sẵn chỗ cho STORY-008 bằng chính doc comment của nó. Hệ
quả: điểm vào của story này là **một hàng thêm vào file của feature khác**, đi
qua đúng một import entry-point — không phải một widget mới trên màn chi tiết.
Debt đã biết, **không sửa trong story này**: bộ chọn dùng chung đang nằm trong
`features/invite_composer/` dù nó không còn thuộc về lời mời.

**(b) Cổng nhập R-15c đã có nhà, và nhà đó cấm nhà thứ hai.**
`mobile/lib/core/content/invariant_terms.dart` (`InvariantRule`,
`invariantHitsIn`) là nơi duy nhất của luật bất biến, và doc comment của chính
nó nói rõ: một bản sao danh sách luật cạnh một họ gói thứ hai là cùng một thất
bại lùi lại một bước. Nên AC-36 **không phải** "xây một cổng nhập"; nó là "thêm
luật **cấu trúc** vào một gate feature-local, ủy quyền tầng từ vựng cho lớp dùng
chung". Luật R-1g (AC-26) là luật đầu tiên trong REQ cần tầng cấu trúc: gói lời
mời không bao giờ chạm nó vì `recipient` không phải thành viên `ClauseTarget`,
còn kịch bản thì **cố ý** nói về người kia.

**(c) AC-24 không sinh dữ liệu mới.** `assets/data/req016/ask_questions.v1.json`
đã ship 3 câu `notebook.interest` + 2 câu `notebook.event`. Story này chỉ khai
báo `entryPointId` mới và dựng `AskOnTheSpotSlot`; **không** sửa asset của
STORY-004.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md`

## 3. Scope And Assumptions

- In Scope: feature `date_script` (domain chọn/render, gate nội dung, màn (9),
  entry point), gói asset `date_script.v1.json`, một hàng trong
  `_resolveActions`, một giá trị enum `ActivityCardOrigin.dateScript`.
- Out Of Scope: mọi thay đổi schema Drift; mọi sửa hành vi của STORY-001/002/003/004;
  liên kết đi ra tới màn (8)/(10) (STORY-009/010); cơ chế "xem kịch bản khác".
- Assumptions affecting design: `mobile/pubspec.yaml` đã khai báo thư mục
  `assets/data/req016/` nên thêm gói **không** sửa pubspec; app hiện **không**
  có package thông báo/scheduler nào, nên AC-13/AC-15 là luật "không được thêm"
  chứ không phải luật "phải gỡ".

### UI Delivery Anchor

- Design Scope Description: một destination full-screen được `push` không tên,
  nhận bắt buộc một `ActivityCard` trạng thái `scheduled`. Thân màn gồm header
  có nút quay lại, một segmented control 3 đoạn cố định dùng lại **style** của
  bộ lọc STORY-001, một vùng nội dung đổi theo đoạn (đoạn "Trong" có caption rào
  chắn cố định do widget sở hữu), một chỗ cắm `AskOnTheSpotSlot`, và một sticky
  footer ba nút pill outline. Không ô tìm kiếm, không chỉ báo tiến độ, không
  nút chia sẻ/copy-link ở bất kỳ đâu trên màn.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/date_script/` (mới, mobile lane duy nhất).
- New boundaries: `date_script_entry_point.dart` là **mặt tiếp xúc duy nhất** của
  feature với phần còn lại của app, đúng khuôn `journal_entry_point.dart` và
  `gift_ideas_entry_point.dart`. Nó export hàm mở màn và `dateScriptEntryPointId`;
  **không** export cubit, selector, renderer, hay widget nội bộ.
- Shared patterns reused: `ContentPackage`/`ContentPackageLoader` (core),
  `invariantHitsIn` (core), `AskOnTheSpotSlot` + `ContextNotebookReader`
  (STORY-004), `showInviteComposerSheet` (STORY-002), `openJournalComposer`
  (STORY-003), `ActivityCardRepository.createCard` (STORY-001).

### Affected Modules

- Mobile: `features/date_script` (mới); `features/invite_composer` (một hàng
  trong `_resolveActions`); `features/activity_cards/domain` (một giá trị enum);
  `assets/data/req016` (một gói mới).

### Contracts And Integrations

- Empty-state: gói thiếu/hỏng → `_hasPresets`-style catch → **hàng biến mất khỏi
  sheet**, không màn lỗi, không sheet rỗng (khuôn AC-27 của STORY-002). Sổ tay
  trống **không** phải empty-state: nó là đường đi bình thường, preset tổng quát
  vẫn ra đủ ba phần (AC-23).
- Không có retry/timeout/idempotency: không có lời gọi mạng nào trên đường đi.
- Compatibility: `date_script` được thêm vào `ActivityCardOrigin` theo luật
  **append-only** của `STORY-001/architecture/contract-summary.md` §2 — thêm
  **giá trị**, không thêm cột, không bump `schemaVersion`.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Khoá vị trí | AC-3/AC-4/AC-5, BR-1 | Không route đặt tên; hàm mở nhận `ActivityCard` bắt buộc; hàng sheet chỉ dựng khi `status == scheduled` | Test khẳng định `openDateScriptScreen` có **đúng một** call site và không xuất hiện trong bảng route/tab/menu; widget test trên thẻ `idea`/`done`/`memory` không thấy hàng | LOCATION_LOCK_UNVERIFIED |
| Ranh giới J7 | AC-13..AC-16, BR-3 | Feature không khai báo phụ thuộc timer/notification/scheduler; `scheduledOn` chỉ dùng làm giá trị mad-libs | Test quét import của `features/date_script/**` chặn `Timer`, `Stream.periodic`, và mọi package thông báo; test khẳng định caption rào chắn luôn dựng ở đoạn "Trong" | J7_BOUNDARY_UNVERIFIED |
| Cổng nhập nội dung | AC-26..AC-30, AC-36, AC-37, BR-18 | 7 luật ở `date_script_content_gate.dart`, tầng từ vựng ủy quyền cho `invariantHitsIn` | Test quét `assets/data/req016/date_script.*.json` từ đĩa, chạy validator; vi phạm → **bản dựng đỏ** | CONTENT_GATE_UNVERIFIED |
| Tất định + toàn phần | AC-8, AC-10, AC-34, AC-37 | Hash ổn định tự định nghĩa trên `card.id`; fallback preset tổng quát; luật câu `requires: []` mỗi phần | Unit test: cùng input → cùng output qua 2 lần dựng; property test chọn preset với N=1 và mọi `ActivityType` kể cả `null`; render với thẻ rỗng + sổ tay rỗng không lộ `{`, `}`, `()` | DETERMINISM_UNVERIFIED |
| Ba cửa ra gọi lại | AC-17..AC-21, BR-7 | Chỉ import ba entry-point file; màn tự pop sau khi cửa ra hoàn tất | Widget test ba cửa ra với seam giả, khẳng định gọi đúng hàm và màn (9) đóng lại | EXIT_REUSE_UNVERIFIED |
| Visual fidelity màn (9) | `ux/uiux-spec.md` §2 | Capture màn (9) trong widget test của chính story | Bằng chứng visual-fidelity per-story cho màn (9) | VISUAL_FIDELITY_BLOCKED |

### Lane Handoff

#### Mobile Lane

- Responsibilities: toàn bộ story. **Không có lane backend, frontend, hay devops.**
- Authoritative inputs: `architecture/contract-summary.md` của story này; §2/§3
  của contract-summary STORY-001/002/003/004; `ux/uiux-spec.md`.
- Guardrails:
  - Không thêm bảng, cột, hay `schemaVersion`. Story này **không ghi DB**.
  - Không đặt câu chữ kịch bản vào widget/l10n/hằng Dart; ngược lại **không** đặt
    luật bất biến vào gói asset.
  - Không sao chép danh sách từ cấm sang feature này — gọi `invariantHitsIn`.
  - Không dùng `String.hashCode` làm nguồn tất định (không bảo đảm ổn định giữa
    các bản Dart/nền tảng); định nghĩa hash ổn định trong `domain/`.
  - Không đặt tên route, không đăng ký màn (9) vào bảng route/tab/menu nào.
  - Không import gì của `journal`, `invite_composer`, `context_notebook` ngoài
    file entry point của chúng.
  - Caption rào chắn của đoạn "Trong" thuộc **widget**, không thuộc gói nội dung
    — để không nguồn nội dung nào xoá được nó (BR-3).

## 5. Non-Functional Impact

- Ngoại tuyến tuyệt đối là ràng buộc thiết kế, không phải tối ưu: mọi đầu vào
  nằm trong binary hoặc trong Drift cục bộ, nên không tồn tại trạng thái chờ để
  phải vẽ skeleton (AC-11).

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Họ gói mới `req016.date_script.v1` | Item kịch bản có hình dạng khác hẳn preset lời mời (3 phần lồng câu, thay vì danh sách clause phẳng) | ACCEPTED | Đúng tiền lệ STORY-004 §1: hình dạng item khác ⇒ họ gói mới, mỗi họ một `schema_id` |
| Thêm danh mục `date_script` vào họ `req016.presets.v1` | Tái dùng nguyên engine + gate của STORY-002 | REJECTED | `STORY-002/architecture/contract-summary.md` §6 cấm thêm `schema_id`/nhánh gate cho danh mục mới; ép hình dạng ba phần vào `clauses[]` phẳng sẽ làm mất chính ranh giới phần mà AC-7 yêu cầu |
