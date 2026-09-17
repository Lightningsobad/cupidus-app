# STORY-009_your_view_portrait-solution.md

## 0. Metadata

- Complexity: complex (`story_master.md` ghi `standard`; handoff ghi `complex` —
  không đổi kiến trúc, cả hai đều bắt buộc `coding-plan/`)
- Date: 2026-09-11

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: R-13 khoá vị trí (AC-2/AC-3), nhãn xuất xứ nằm trong bố
  cục (AC-6..AC-8), luật ba tầng R-1e (AC-10..AC-15), R-1g kết bằng câu hỏi
  (AC-16..AC-19), ranh giới sổ tay R-1f (AC-22/AC-23), lưu-bỏ-dở không thúc ép
  (AC-25..AC-28), tất định + offline (AC-29/AC-30), nội dung là dữ liệu có cổng
  nhập chạy được ở **cả tầng đầu ra lẫn tầng đầu vào** (AC-33..AC-37).
- Architectural invariants / non-goals: không backend, không HTTP, không mô hình
  AI ở runtime; không route đặt tên và không deep link tới màn (8); không bảng
  điểm/%/streak/đếm; không cửa xuất-chia sẻ; không cửa ghi điền-trước vào sổ tay.
- Proposed technical direction: một feature mobile duy nhất
  `mobile/lib/features/your_view_portrait/`, chạy trên ba gói asset
  (`portrait_questions` / `portrait_sections` / `portrait_asks`), một bảng Drift
  `portrait_answers`, và một composer tất định kiểu **preset + mad-libs** tái
  dùng nguyên ngữ nghĩa clause của STORY-002. Cổng nhập nội dung là một test quét
  asset từ đĩa, tái dùng `core/content/invariant_terms.dart` của D-15.
- Why this fits: mọi mảnh hạ tầng story này cần đã có sẵn và đã qua review —
  `ContentPackage`/`ContentPackageLoader` (STORY-001), ngữ nghĩa clause + cổng
  nhập (STORY-002), sổ tay đọc/ghi + `AskOnTheSpotSlot` (STORY-004), denylist
  luật bất biến dùng chung (STORY-004). Story này thêm **giá trị và gói dữ
  liệu**, không thêm cơ chế.

### Key Discovery

Ba phát hiện đọc code làm đổi thiết kế so với cách đọc thẳng requirements:

1. **`AskOnTheSpotSlot` không dựng được bộ câu hỏi của story này.** Widget chọn
   câu theo `AskTarget` từ gói `req016.ask_questions.v1` của STORY-004, và tự trả
   `SizedBox.shrink()` khi không thiếu trường (`ask_on_the_spot_slot.dart:26-68`).
   Bộ câu hỏi màn (8) có gói riêng, id riêng, con trỏ bỏ-dở riêng và phải hiện
   **đúng một câu kể cả khi sổ tay đã đầy**. Tái dùng widget ở đây là ép hai ngữ
   nghĩa vào một widget, không phải tiết kiệm.
2. **Vì (1), AC-22 đụng thẳng vào `STORY-004/architecture/contract-summary.md`
   §6** ("không mở đường ghi thứ hai vào sổ tay ngoài `AskOnTheSpotSlot` và nút
   + tự thêm"). Phán quyết: mở **một** cửa ghi hẹp, đặt trong chính module
   STORY-004 (`context_notebook_entry_point.dart`), nhận đúng một câu trả lời
   kèm `question_id` bền, chỉ `interest`/`event`, không bulk/sửa/xoá — giữ
   nguyên **mục đích** của §6 (cấm điền-trước, cấm UI hỏi thứ hai, cấm nhập
   ngoài) trong khi đạt AC-22. Đây là bản sửa đổi có chủ đích của §6, ghi ở
   `contract-summary.md` §3 của story này, không phải một ngoại lệ im lặng.
3. **Khoá vị trí là ràng buộc biên dịch, không phải ràng buộc điều hướng.**
   `cupid_app.dart:104` có một `routes:` map thật (một route của STORY-011), nên
   "không đăng ký route" là điều kiện đủ chỉ khi widget màn (8) cũng **không
   export** khỏi thư viện feature. Cách duy nhất dựng được nó là
   `openYourViewPortrait(..., from: PortraitEntrySource)` — AC-3 khi đó là lỗi
   biên dịch, không phải một test hy vọng không ai gọi nhầm.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` (gói nội dung, bảng,
  hai API Dart, bản sửa đổi §6 của STORY-004, thứ tự cổng nhập + migration).

## 3. Scope And Assumptions

- In Scope: một feature mobile mới, ba gói asset, một bảng Drift + migration
  cộng thêm, một cổng nhập nội dung chạy được, một luật denylist mới trong
  `core/content/invariant_terms.dart`, và việc nối dây `_GuessRow` của màn (5).
- Out Of Scope: backend (không lane backend trong story này), STORY-010 bảng tra
  ăn khớp, cửa vào thứ hai từ màn (9) của STORY-008, mọi chức năng xuất/chia sẻ.
- Assumptions affecting design:
  - `_GuessRow` (`gift_ideas_screen.dart:346-400`) là chỗ nối dây đã dành sẵn;
    story này thay snackbar `gift_ideas_guess_coming_soon` bằng lời gọi mở màn
    (8). Nhãn hàng đó là **chrome điều hướng**, được phép ở l10n; STORY-010 sau
    này tự lo cửa vào của nó.
  - Con trỏ bỏ-dở là **dẫn xuất**, không lưu: câu đang dở = item đầu tiên của gói
    chưa có hàng trong `portrait_answers`. Khi mọi câu đã có trạng thái, màn mở
    thẳng vào kết quả. Một câu `skipped` được hỏi lại ở lượt sau qua liên kết
    trung tính trên màn kết quả (AC-27), và liên kết đó không đếm, không % , không
    nhãn "chưa xong" (AC-26/AC-28).
  - `owner_key` lấy từ `BackendUserIdStore` đã có; đây là lý do duy nhất backend
    xuất hiện trong câu chuyện và nó **không** cần thay đổi gì.

### UI Delivery Anchor

- Design Scope Description: màn (8) full-screen push từ luồng (5), hai trạng thái
  trên **một** route — (a) bộ câu hỏi từng-câu-một với hàng "Bỏ qua"/"Tiếp", (b)
  kết quả cuộn được với khối tiêu đề + nhãn xuất xứ ghim dưới app bar, thân chia
  thành các khối phần `--r-sm`, mỗi khối kết bằng dòng "Câu để hỏi" khác tông có
  icon `help_outline`. Không nút xuất/chia sẻ, không biểu đồ, không spinner "đang
  phân tích".

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/lib/features/your_view_portrait/` (mới).
- New or changed boundaries: một cửa vào có kiểu (`openYourViewPortrait`) thay
  cho route; một cửa ghi hẹp thêm vào `context_notebook_entry_point.dart` của
  STORY-004; một luật `assertiveClaim` **append-only** vào
  `core/content/invariant_terms.dart` (dùng chung mọi họ gói — đã kiểm: không gói
  `assets/data/req016/*.json` hiện có nào chứa khuôn khẳng định, nên luật mới
  không làm đỏ nội dung đã ship).
- Shared patterns reused: `ContentPackage`/`ContentPackageLoader`; ngữ nghĩa
  clause `requires` + bỏ-nguyên-câu của STORY-002; hình dạng gate
  `validate*Packs` → `List<Violation>` → test quét đĩa; `SessionScopedStore`
  không áp dụng (dữ liệu gốc, xem `STORY-001/architecture/solution.md` §4).

### Affected Modules

- Mobile: `features/your_view_portrait/` (mới), `features/context_notebook/`
  (thêm một hàm ở entry point), `features/gift_ideas/` (nối dây `_GuessRow`),
  `core/content/invariant_terms.dart`, `core/database/` (bảng + migration),
  `core/di/service_locator.dart`, `l10n/` (chỉ chrome: tiêu đề màn, "Bỏ qua",
  "Tiếp", nhãn xuất xứ, nhãn liên kết hỏi tiếp).

### Contracts And Integrations

- Error, retry, timeout, idempotency, empty-state: gói hỏng là lỗi **ồn** lúc
  load (`ContentPackageFormatException`), không có trạng thái suy biến; không có
  retry vì không có I/O mạng. Ghi câu trả lời là idempotent theo
  (`owner_key`, `question_id`): trả lời lại ghi đè hàng cũ và thay
  `notebook_entry_id`. Rỗng là kết quả **hợp lệ**: không dữ liệu → chân dung chỉ
  còn các dòng câu-để-hỏi, không màn rỗng, không lời mời hoàn tất.
- Compatibility posture: `schemaVersion` +1 với migration chỉ-`CREATE TABLE`;
  gói nội dung version hoá qua `version` + id bền, đổi nguồn sang CMS không sửa
  code (AC-33).
- External or trust-boundary implications: không có, và đó là **ràng buộc** —
  đường đi của story này không được phép có client HTTP, SDK, hay lời gọi mô hình.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Khoá vị trí R-13 (AC-2/AC-3) | `your_view_portrait_entry_point.dart`, `app/cupid_app.dart` | Widget màn private trong thư viện, không `routeName`, không vào `routes:`; cửa vào là enum có kiểu | Unit/widget test: `routes:` không chứa màn (8); không API công khai nào dựng được màn ngoài `openYourViewPortrait` | `PORTRAIT_LOCK_UNVERIFIABLE` |
| Cổng nhập nội dung đầu ra + đầu vào (AC-36/AC-37) | `portrait_content_gate.dart`, `core/content/invariant_terms.dart` | Luật ở Dart, chữ ở asset; khuôn câu mở đầu là allowlist Dart; mỗi phần bắt buộc `ask_ids` không rỗng | `portrait_content_gate_test.dart` quét ba gói từ đĩa; fixture vi phạm mỗi luật phải đỏ | `CONTENT_GATE_NOT_RUNNABLE` |
| Ranh giới sổ tay R-1f (AC-22/AC-23) | `PortraitAnswerTarget`, `recordAnsweredQuestion` | `portrait.guess` không có đường đi tới sổ tay ở mức kiểu; cửa ghi chỉ nhận `interest`/`event` + `question_id` | Repository test: trả lời `portrait.guess` không sinh hàng `notebook_entries`; trả lời `notebook.*` sinh đúng một hàng, sửa/xoá được | `NOTEBOOK_BOUNDARY_UNVERIFIABLE` |
| Bỏ dở, không thúc ép (AC-25..AC-28) | `portrait_answers`, cubit con trỏ dẫn xuất | Con trỏ dẫn xuất, không cột đếm, không badge, không banner | Cubit test: thoát giữa chừng → mở lại đúng câu; mọi câu bỏ qua được; không surface nào đọc số câu đã trả lời | `RESUME_UNVERIFIABLE` |
| Tất định + offline (AC-29/AC-30) | `portrait_composer.dart` | Thứ tự khai báo, không random, không timestamp trong đầu ra; chọn câu-để-hỏi từ hàm thuần trên id | Test dựng hai lần cùng đầu vào ⇒ chuỗi giống hệt; test khẳng định đường đi không import client mạng/AI | `DETERMINISM_UNVERIFIABLE` |
| Nhãn xuất xứ trong bố cục (AC-6..AC-8) | màn kết quả | Nhãn là dòng cố định của header ghim, ≥ 13pt, không tooltip/banner | Widget test cuộn tới cuối vẫn thấy nhãn; dòng visual-fidelity của chính phase UI | `VISUAL_FIDELITY_BLOCKED` |
| Migration `schemaVersion` (ADR-010) | `core/database/cupid_database.dart` | Chỉ `CREATE TABLE`, cấm huỷ-tạo-lại; đọc giá trị thật lúc cài đặt rồi +1 | Migration test v(n)→v(n+1) giữ nguyên mọi hàng cũ | `MIGRATION_TEST_RED` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: toàn bộ story. Không có lane backend, frontend, hay devops —
  không endpoint mới, không biến môi trường, không mục runtime registry mới (app
  chạy bằng lệnh Flutter đã đăng ký).
- Authoritative inputs: `architecture/contract-summary.md` (story này),
  `STORY-004/architecture/contract-summary.md` §2/§3/§4, `ux/uiux-spec.md`
  mục 2/3/4, `requirements/requirements.md` AC-1..AC-37.
- Guardrails:
  - Không export widget màn (8); không thêm `routeName`; không chạm `routes:`.
  - Không viết câu chữ hỏi/đoạn chân dung/câu-để-hỏi vào l10n hay hằng Dart;
    không viết luật bất biến vào asset.
  - Không thêm cột đếm/điểm/%/streak vào `portrait_answers`, kể cả "chỉ để log".
  - Không gọi `ContextNotebookRepository` trực tiếp từ feature chân dung — chỉ đi
    qua hai hàm ở `context_notebook_entry_point.dart`.
  - Không chép `schemaVersion` từ tài liệu: đọc giá trị thật trên nhánh tích hợp
    rồi cộng một. Bump này làm đỏ các assertion `schemaVersion` ở test hiện có —
    sửa chúng thuộc cùng phase với migration, không để sang phase khác.
  - Không thêm `AskTarget` value mới; `portrait.guess` sống ở enum của feature này.

## 5. Non-Functional Impact

- Quyền riêng tư là ràng buộc kiến trúc, không phải NFR mềm: toàn bộ dữ liệu về
  người kia ở story này nằm trong `portrait_answers` + sổ tay, trên máy, không rời
  thiết bị và không có API đọc hàng loạt để một màn "tổng kết" mọc lên sau này.
- Offline hoàn toàn (AC-30): gói nội dung nằm trong bundle; không có đường đi nào
  chờ mạng, nên không có trạng thái loading nào có thể trông như "đang suy nghĩ".

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Cửa ghi hẹp `recordAnsweredQuestion` trong module STORY-004 | AC-22 buộc câu trả lời sở thích/sự kiện vào sổ tay, mà `AskOnTheSpotSlot` không dựng được bộ câu hỏi này | ACCEPTED | Giữ đúng mục đích §6 của STORY-004: một câu hỏi có id bền, một câu trả lời do người dùng gõ, không bulk, không điền-trước |
| Nhét bộ câu hỏi màn (8) vào gói `req016.ask_questions.v1` | Sẽ tái dùng được `AskOnTheSpotSlot` nguyên vẹn | REJECTED | Luật ánh xạ câu trả lời → đoạn chân dung không có chỗ sống trong gói đó, và nó đổi schema của STORY-004 (AC-33/AC-34) |
