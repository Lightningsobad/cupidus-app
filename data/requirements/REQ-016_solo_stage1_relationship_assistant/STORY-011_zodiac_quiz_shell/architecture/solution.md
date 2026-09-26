# STORY-011 Vỏ hoàng đạo / trắc nghiệm — solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-09-24

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: SC-2/BR-1 (nhận định và 3 thẻ là **một** bề mặt), R-15a/b/c
  (nội dung là gói dữ liệu có cổng nhập chạy được), R-7 (tất định, ngoại tuyến,
  không AI), R-1e/R-1g (không chấm điểm, kết bằng câu để hỏi), R-1 cấm (f)
  (không cơ chế tạo thói quen mở app).
- Architectural invariants / non-goals:
  - **Không có lane backend.** AC-22/AC-23 cấm mọi lời gọi API ngoài và bắt luồng
    chạy đủ khi mất mạng; toàn bộ nội dung ship trong asset bundle. Handoff để
    Tech Lead chốt ranh giới `shared` — ranh giới chốt ở đây là **mobile-only**,
    backend participation = NONE.
  - **Không đụng Drift.** Không bảng mới, `CupidDatabase.schemaVersion` giữ
    nguyên. Con trỏ xoay vòng (AC-32) nằm ở `SharedPreferences` theo đúng mẫu
    `before_you_go_dismissal_store.dart` / `stage1_last_opened_store.dart`.
  - Không tự định nghĩa trạng thái thẻ mới, không thêm trường thẻ (BR-7).
  - Không chỉ số ăn khớp, không DẢI, không % ở bất kỳ bề mặt nào (BR-5/AC-14).
- Proposed technical direction: một feature mobile mới
  `mobile/lib/features/zodiac_shell/`, dựng trên hạ tầng nội dung đã có
  (`core/content/content_package.dart` + `core/content/invariant_terms.dart`),
  hai gói nội dung JSON mới, một content gate riêng, một resolver thuần, một
  cubit phiên chơi, và một màn kết quả một-bề-mặt.
- Why this fits: REQ-016 đã có 6 feature cùng khuôn (`gift_ideas`,
  `conversation_starters`, `date_script`, `context_notebook`,
  `your_view_portrait`, `compatibility_lookup`), mỗi cái gồm
  `domain/<x>_content.dart` + `domain/<x>_content_gate.dart` + gói
  `assets/data/req016/<x>.v1.json` + `test/features/<x>/<x>_content_gate_test.dart`.
  Story này là biến thể thứ bảy của đúng khuôn đó.

### Key Discovery

Cửa vào đã tồn tại sẵn và đang **chờ đúng story này**:
`mobile/lib/features/activity_cards/presentation/widgets/quick_entry_strip.dart`
đã có `QuickEntryCell.zodiacShell` với glyph `CupidIcons.autoAwesome` và nhãn
"Vỏ hoàng đạo"; `activity_card_hub_view.dart:315` là một `case` đang trả về
snackbar "Sắp có". Cửa vào vì vậy là **một case cần thay**, không phải một dải
lối-vào-nhanh cần dựng — đúng như UX §5 dặn (không đổi kích thước/bố cục 3 ô).

Phát hiện thứ hai: `invariant_terms.dart` đã export sẵn `invariantHitsIn()`
(cấm %, cấm giọng phán quyết, cấm streak) và `starterStructureHitsIn()` (bắt
buộc kết bằng dấu hỏi, chấp cả `?` và `？`). AC-33/AC-34 do đó **không** cần
luật văn bản mới — chỉ cần một gate mới gọi lại hai hàm này trên đúng các
trường của gói mới, cộng một luật riêng cho tầng câu HỎI (AC-34) và một luật
đếm đúng-3 (AC-4).

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md`

## 3. Scope And Assumptions

- In Scope: feature mobile `zodiac_shell` (content pack + gate + resolver +
  rotation store + cubit + 2 màn + wiring ô 3 của dải lối-vào-nhanh).
- Out Of Scope: backend, Drift, chỉ số ăn khớp (STORY-010), chân dung
  (STORY-009), kênh gửi riêng (BR-10), widget/pha (BR-8).
- Assumptions affecting design:
  - AC-21 "cùng đầu vào → cùng kết quả" được đọc là: ánh xạ
    `(setId, answers, notebook snapshot)` → `outcomeId` là **hàm thuần**. Con
    trỏ xoay vòng chỉ quyết định **vòng câu hỏi nào được hỏi tiếp**, không bao
    giờ tham gia ánh xạ ra kết quả.
  - Sổ tay đổi thì gợi ý đổi — đó là đầu vào đổi, không phải vi phạm AC-21.
  - `editorial_review` (layer1/layer2/approved_at) giữ nguyên quy ước STORY-008
    để AC-29/AC-30 truy vết được theo id bền.

### UI Delivery Anchor

- Design Scope Description: hai bề mặt trong một route push toàn màn hình mở từ
  ô thứ 3 của dải lối-vào-nhanh trên tab Nhà — (a) danh sách thẻ chọn lát/bộ,
  mỗi thẻ 1-2 dòng, không khoá theo ngày; (b) màn kết quả một-lượt-cuộn gồm
  đoạn nhận định, khối "câu để hỏi" khi đoạn nhắc tới người kia, tiêu đề phụ
  ngăn cách, rồi đúng 3 thẻ gợi ý xếp dọc, mỗi thẻ một hành động
  "Thêm vào kho của tôi". Không thanh tiến độ, không huy hiệu, không DẢI/%.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/zodiac_shell/` (mới, sở hữu toàn bộ).
- New or changed boundaries: một điểm sửa ngoài module — `case
  QuickEntryCell.zodiacShell` trong `activity_card_hub_view.dart` gọi
  `openZodiacShellScreen(context)`; và một giá trị **append-only** thêm vào
  `ActivityCardOrigin` (`activity_card.dart`). Không sửa gì khác ngoài module.
- Shared patterns reused: `ContentPackage.parse` + `ContentPackageLoader`,
  `invariantHitsIn` / `starterStructureHitsIn`, `ActivityCardRepository`,
  mẫu store `SharedPreferences` một khoá, mẫu `l10n/arb` cho chrome.

### Affected Modules

- Mobile: `features/zodiac_shell` (mới), `features/activity_cards` (một enum
  value + một case điều hướng), `l10n`, `assets/data/req016`.

### Contracts And Integrations

- Empty-state / suy giảm êm: sổ tay rỗng hoặc `ContextNotebookRepository` ném
  lỗi (nó cần backend user id, xem `context_notebook_repository.dart:217`) →
  resolver chạy tiếp với danh sách rỗng và vẫn trả **đủ 3** gợi ý theo thứ tự
  gói (AC-25/BR-4). Lỗi sổ tay **không bao giờ** nổi lên UI.
- Gói nội dung sai lược đồ → `ContentPackageFormatException` tại parse; vi phạm
  luật bất biến → gate ném tại test nạp gói, làm hỏng bản dựng (AC-33/AC-34).
- Compatibility posture: `ActivityCardOrigin` chỉ thêm đuôi, không đổi thứ tự,
  không đổi `wireValue` cũ (R-15a append-only).
- Không có trust boundary mới: không mạng, không quyền hệ thống mới.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Bề mặt kết quả một-lượt-cuộn | AC-4/5/6, BR-1/BR-2 | Đúng-3 là hằng bố cục trong widget kết quả; resolver luôn trả 3; không nhánh nào dựng kết quả thiếu thẻ | widget test: kết quả mọi outcome của gói seed đều render 3 thẻ trên cùng scrollable, không `ExpansionTile`, không nút "xem gợi ý" | `RESULT_SURFACE_GATE_UNVERIFIED` |
| Cổng nhập nội dung | AC-30/33/34, BR-12/BR-14 | Gate mới gọi `invariantHitsIn` + `starterStructureHitsIn` + luật tầng câu HỎI + luật đúng-3 | test nạp **gói asset thật** và assert 0 vi phạm; thêm fixture vi phạm assert gate ném | `CONTENT_GATE_UNVERIFIED` |
| Tất định, không xoay theo ngày | AC-18/21, BR-9 | Không `DateTime.now()` trong resolver/cubit/gói; con trỏ xoay theo lượt chơi, không theo ngày | unit test: cùng input → cùng outcomeId qua nhiều lần gọi; grep test cấm `DateTime.now` trong `features/zodiac_shell` | `DETERMINISM_GATE_UNVERIFIED` |
| N là thuộc tính dữ liệu | AC-31/32, BR-13 | Mọi số mục đọc từ `ContentPackage.length`; không hằng số N trong code; hết vòng → quay đầu cùng thứ tự | unit test chạy resolver/rotation trên gói fixture N=1 và N=7, cùng hành vi, không lộ số đếm | `DATA_DRIVEN_N_GATE_UNVERIFIED` |
| Giọng R-1e/R-1g ở đầu ra | AC-12/13/15/17 | Đoạn nói về người kia bắt buộc có `ask_line`; gate ép `aboutOther == true` ⇒ `ask_line` kết bằng dấu hỏi | gate test + widget test khối "câu để hỏi" hiện đúng khi `aboutOther` | `VOICE_GATE_UNVERIFIED` |
| Hợp đồng thẻ chỉ-đọc | AC-7/8, BR-7 | Chỉ thêm `ActivityCardOrigin.zodiacShell`; tạo thẻ qua `ActivityCardRepository` hiện có, tiêu đề là trường bắt buộc duy nhất | unit test: thẻ tạo ra có `status` *Mới nghĩ ra* + origin mới; test append-only trên thứ tự enum | `CARD_CONTRACT_GATE_UNVERIFIED` |
| Cửa vào thấy được | AC-1/2, rule 13a | Thay `case QuickEntryCell.zodiacShell` snackbar bằng `openZodiacShellScreen` | widget test: chạm ô slot 2 của `QuickEntryStrip` đẩy màn (7), không còn snackbar "Sắp có" | `ENTRY_POINT_GATE_UNVERIFIED` |
| Ngoại tuyến / không AI | AC-22/23 | Không HTTP client, không plugin mạng trong module | grep test cấm `http`/`dio`/`api` import trong `features/zodiac_shell` | `OFFLINE_GATE_UNVERIFIED` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: toàn bộ 4 phase của story.
- Authoritative inputs: `../requirements/requirements.md`, `../ux/uiux-spec.md`,
  `architecture/contract-summary.md`, mã nguồn `core/content/`,
  `features/activity_cards/`.
- Guardrails:
  - KHÔNG bump `CupidDatabase.schemaVersion`, KHÔNG thêm bảng Drift.
  - KHÔNG đặt chuỗi nội dung (câu hỏi, nhận định, văn bản 3 thẻ) vào `.arb` hay
    widget — `.arb` chỉ giữ chrome (tiêu đề màn, nhãn nút, snackbar).
  - KHÔNG thêm thanh tiến độ, số câu đã làm, số mục còn lại, streak, huy hiệu.
  - KHÔNG đổi thứ tự hay `wireValue` của các `ActivityCardOrigin` đã có.
  - KHÔNG ghi vào sổ tay; chỉ gọi `ContextNotebookRepository.entries()`.
  - KHÔNG dựng nút gửi/chia sẻ, KHÔNG sinh ảnh kết quả (BR-10).

## 5. Non-Functional Impact

- Gói nội dung nạp qua `rootBundle` mỗi lần mở màn; giữ cache trong cubit để
  không parse lại giữa các vòng chơi trong cùng phiên.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Con trỏ xoay vòng ở `SharedPreferences` | AC-32 cần trạng thái bền qua lần mở app | ACCEPTED | Một khoá `String`; tránh bump `schemaVersion` — hai nhánh song song từng va nhau đúng ở chỗ này |
| Bảng Drift cho con trỏ | Nhất quán với kho thẻ | REJECTED | Một `int` không xứng một migration, và bump schema là rủi ro va chạm nhánh đã biết của REQ-016 |
