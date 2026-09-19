# STORY-010_compatibility_lookup-solution.md

## 0. Metadata

- Complexity: complex
- Date: 2026-09-11

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: R-7 (tất định, không AI runtime), R-8 (DẢI, cấm %),
  R-13/SC-6 (khoá vị trí), R-15 (cổng nhập nội dung chạy được), AC-29 (ngoại
  tuyến toàn phần), BR-2 (400 ô **có hướng**).
- Architectural invariants / non-goals:
  - Không lane backend. Không HTTP, không endpoint, không mô hình AI trên mọi
    đường đi của story này (AC-28). "Tích hợp bên ngoài: không có" là **ràng
    buộc**, không phải hiện trạng.
  - Kết quả là **hàm thuần** `(axis, selfId, partnerId) -> Cell` qua gói asset
    (BR-3). Không cache theo thời gian, không ngẫu nhiên, không xoay vòng.
  - Story này **không ghi gì vào sổ tay** (AC-31). Nó không giữ tham chiếu tới
    một writer của `notebook_entries`.
  - Không `routeName`, không mục trong `routes:` của `cupid_app.dart`, không
    mục menu/tab (AC-2/AC-3).
- Proposed technical direction: một feature Flutter mới
  `mobile/lib/features/compatibility_lookup/`, gồm (a) ba gói asset JSON dựng
  trên engine `ContentPackage` có sẵn, (b) một cổng nhập `CompatContentGate`
  chạy trong test, (c) một bảng Drift `relationship_labels` cho nhãn tự khai,
  (d) một màn tiêu thụ mở bằng hàm entry-point, không bằng route.
- Why this fits: bốn story trước đã ship đúng khuôn này (`preset_content_gate`,
  `gift_content_gate`, `context_content_gate`, `before_you_go_content_gate`).
  Story này là biến thể thứ năm, không phải cơ chế mới.

### Key Discovery

**(1) Không có lane backend — `story_master.md` ghi "shared (backend + mobile)"
là phỏng đoán của backlog, không phải ranh giới thật.** `requirements.md`
`## System Integration And Discoverability` khoá "không nguồn dữ liệu ngoài,
không đồng bộ", và AC-28/AC-29 biến điều đó thành AC. Phần việc trông giống
backend — soạn 400 ô, validate, làm hỏng bản dựng — là **cổng nhập chạy bằng
Dart trong `mobile/test/`**, không phải một service. Lane của story này là
**mobile duy nhất**. Mở một lane backend ở đây là tạo ra một đường mạng mà
AC-28 cấm.

**(2) Nửa cổng nhập của AC-37 ĐÃ tồn tại và không được chép lại.**
`mobile/lib/core/content/invariant_terms.dart` đã là "the one home of the R-15c
invariant rules", và docstring của nó nói thẳng rằng một bản sao thứ hai cạnh
một họ gói thứ hai chính là kiểu hỏng nó được viết ra để chặn. Ánh xạ:

| AC-37 | Nguồn cưỡng chế |
|---|---|
| (a) hành vi/tần suất người kia | `InvariantRule.recipientBehaviour` **+ riêng** `NotebookBoundaryRule.frequencyProbe` |
| (b) không có điểm cọ xát | **mới, cấu trúc** — trường `friction` bắt buộc |
| (c) %, điểm, thang, hạng, sao | `InvariantRule.percentDisplay` + `scoreOrRatio` **+ mới, cấu trúc**: cấm mọi JSON number |
| (d) streak / chuỗi ngày | `InvariantRule.streakDisplay` |
| (e) kết bằng kết luận | **mới, cấu trúc** — trường `question` bắt buộc, kết bằng `?` |

Chỉ (b), (e), và nửa cấu trúc của (c) là code mới. Viết một denylist thứ hai
cho (a)/(c)/(d) là vi phạm R-15c.

**(3) `notebookBoundaryHitsIn` KHÔNG được nối nguyên khối.** Nó được chỉnh cho
*câu hỏi ở tầng nhập sổ tay*. `NotebookBoundaryRule.judgementProbe` chứa
`tính cách`, `điểm mạnh`, `điểm yếu` — đó **chính là** chủ đề hợp lệ của một ô
ăn khớp. Nối cả ba rule làm cổng nhập không thể qua được và đẩy người viết vào
lối nói vòng. Cổng của story này đọc **đúng một** khoá:
`notebookBoundaryTerms[NotebookBoundaryRule.frequencyProbe]`. Không thêm danh
sách mới, không nối `behaviourProbe`/`judgementProbe`.

**(4) AC-36 và AC-38 kéo ngược nhau; ranh giới là `lib/` vs `test/`.** AC-36
cấm 12/16 làm hằng số biên dịch; AC-38 đòi đúng 144/256 ô. Giải: **`lib/` suy
`n` từ số item `kind: axis_value` trong chính gói** và kiểm phủ `n²`;
**`mobile/test/` ghim bộ seed đang ship ở 12 và 16**. Một khẳng định về bộ seed
hiện tại nằm trong test không phải là logic tra cứu. Viết 12/16 vào `lib/` là
vi phạm AC-36; không khẳng định ở đâu cả là vi phạm AC-38.

**(5) `AskOnTheSpotSlot` không chở được nhãn này, và đó là lý do STORY-010 tự
giữ chỗ nhập.** `AskTarget` là enum đóng ba giá trị với docstring "an unknown
value is a parse error ... so a CMS cannot invent a fourth destination"; câu
trả lời của nó là **văn tự do** ghi vào `notebook_entries.value`. Nhãn hoàng
đạo/MBTI là **từ vựng đóng 12/16 giá trị kèm cờ chắc chắn** (AC-8 `known` |
`guess`) — không biểu diễn được nếu không đổi hợp đồng STORY-004, mà BR-10 cấm
đúng điều đó. Thêm nữa, cadence "đúng một câu một lần" của slot là *cơ hội*,
còn story này cần **cả hai nhãn trước khi có gì để hiện** — một tiền điều kiện
chặn, sai vòng đời. Vì vậy: STORY-010 dựng chỗ nhập của riêng nó, **dùng lại
đúng dáng thị giác** (thẻ inline, không dialog, nút bỏ qua trung tính) theo
`ux/uiux-spec.md` mục 2, và **không ghi một byte nào vào sổ tay** — chính là
điều AC-31 đòi ở dạng cấu trúc. STORY-004 §6 cấm "mở đường ghi thứ hai vào sổ
tay"; story này không mở đường ghi nào cả.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md`

## 3. Scope And Assumptions

- In Scope: feature `compatibility_lookup` (gói asset + cổng nhập + bảng nhãn +
  màn tiêu thụ), một giá trị `ActivityCardOrigin` cộng thêm, và việc nối cửa
  vào đã dành sẵn `_GuessRow` ở `gift_ideas_screen.dart`.
- Out Of Scope: mọi thay đổi của `context_notebook`, `activity_cards` (ngoài một
  giá trị enum), `cupid_app.dart` `routes:`, và màn (9) của STORY-008.
- Assumptions affecting design:
  - `assets/data/req016/` đã khai báo trong `pubspec.yaml`; thêm gói không sửa
    `pubspec.yaml` (STORY-004 contract §1).
  - Cửa vào màn (9) chưa tồn tại; AC-5 xác nhận cửa vào (5) là đủ. Story này
    **không** chờ STORY-008.
  - `ActivityCardOrigin` hiện có 4 giá trị và là append-only (STORY-001 §2).

### UI Delivery Anchor

- Design Scope Description: một màn push full-screen duy nhất do module
  `compatibility_lookup` sở hữu, mở từ hàng `gift-ideas-guess-row` sẵn có ở
  cuối màn (5). Màn có hai trạng thái do cùng module dựng: *thiếu nhãn* (thẻ
  nhập inline, từ vựng đóng, nút "Bỏ qua, quay lại") và *kết quả* (nhãn xuất xứ
  sticky, rồi năm khối theo đúng thứ tự DẢI → hợp → va → hoạt động → câu hỏi).
  Hai khối "hợp"/"va" là **cùng một widget khối** dựng hai lần khác icon — đó
  là cách duy nhất luật đối xứng thị giác của `uiux-spec.md` mục 3.3 đứng vững
  qua các lần sửa sau. Không vẽ lại màn (5).

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/compatibility_lookup/` (mới).
- New or changed boundaries:
  - **Cửa vào duy nhất** là `compatibility_lookup_entry_point.dart`, xuất đúng
    một hàm nhận một token xuất xứ bắt buộc. Widget màn không được xuất ra
    ngoài feature. Không `routeName`, không `pushNamed`, không deep link —
    AC-3 đúng vì **không tồn tại tên route nào để trỏ tới**, không phải vì có
    một lệnh kiểm tra lúc chạy.
  - Bảng Drift mới `relationship_labels` trong `CupidDatabase` (ADR-010: một
    Drift owner duy nhất). Không tạo database thứ hai.
- Shared patterns reused: `ContentPackage`/`ContentPackageLoader`,
  `invariantHitsIn`, khuôn `*_content_gate.dart` + test quét asset từ đĩa,
  khuôn "tạo ngay + snackbar hoàn tác 5s" của `gift_ideas_cubit.dart`.

### Affected Modules

- Mobile: `features/compatibility_lookup` (mới), `features/gift_ideas` (đổi
  `onTap` của `_GuessRow`), `features/activity_cards/domain/activity_card.dart`
  (một giá trị enum), `core/database` (một bảng + migration cộng thêm),
  `core/di/service_locator.dart` (đăng ký append-only), `l10n/arb` (chữ khung
  màn, **không** chữ nội dung ô).
- Data: `mobile/assets/data/req016/compat_*.v1.json`.

### Contracts And Integrations

- Error / empty-state: gói hỏng là **lỗi to và dừng** lúc nạp
  (`ContentPackageFormatException`), không bao giờ suy giảm êm thành gói rỗng.
  Ở tầng UI **không có trạng thái rỗng**: AC-15 nói mọi cặp nhãn hợp lệ đều có
  đúng một ô, nên một màn "chưa có dữ liệu" là lỗi thiết kế, không phải nhánh
  cần vẽ. Nhánh duy nhất được phép là *thiếu nhãn* → thẻ nhập.
- Không có trạng thái chờ: không skeleton "đang tra cứu", không hiệu ứng gõ
  dần, không icon xoay (uiux-spec mục 5). Tra cứu là một phép tìm trong bộ nhớ.
- Compatibility posture: gói asset và enum `ActivityCardOrigin` đều append-only.
  Máy đã cài phải đi qua đúng chuỗi migration cộng thêm, không huỷ-tạo-lại.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Trượt thành thang đo (DẢI hoá số) | AC-16/AC-17, BR-7 | Item `band`/`cell` **cấm chứa mọi JSON number**; DẢI là chip chữ tĩnh; tập nhãn không có trường thứ tự | Test cổng nhập quét asset từ đĩa + widget test khẳng định không `LinearProgressIndicator`/`CircularProgressIndicator`/gradient trong subtree khối DẢI | `DATA_GATE_BLOCKED` |
| Thiếu ô / nội dung dự phòng chung chung | AC-15/AC-38 | Kiểm phủ `n²` có hướng suy từ dữ liệu + phát hiện bộ bốn trùng byte giữa hai ô | Test cổng nhập: phủ 100%, không cặp trùng, không ô trùng nội dung | `DATA_GATE_BLOCKED` |
| Ô chỉ toàn lời khen | AC-13/AC-14, R-7 | `friction` là trường bắt buộc ở tầng parse + rule `frictionMissing` | Test cổng nhập trên toàn bộ 400 ô | `DATA_GATE_BLOCKED` |
| Rò cửa vào (khoá vị trí vỡ) | AC-2/AC-3, R-13 | Không `routeName`, không mục `routes:`, widget màn không xuất ra ngoài feature | Test cấu trúc: `routes:` map không chứa màn này; test phân giải URI import khẳng định không file nào ngoài `features/compatibility_lookup/` import file màn | `NAV_LOCK_UNVERIFIABLE` |
| Kết quả rò vào sổ tay | AC-31, BR-5 | Feature không giữ tham chiếu `ContextNotebookRepository`; bảng nhãn không có cột kết quả/DẢI | Test phân giải import: `compatibility_lookup` không import `context_notebook`; test cột cấm trên `relationship_labels` | `NAV_LOCK_UNVERIFIABLE` |
| Đối xứng thị giác "hợp"/"va" vỡ ở lần sửa sau | uiux-spec mục 3.3, BR-9 | Hai khối là **một widget** dựng hai lần, chỉ khác icon và chuỗi l10n | Widget test khẳng định hai khối cùng kiểu chữ/độ đậm/bề rộng; per-story visual fidelity capture | `VISUAL_FIDELITY_BLOCKED` |
| Bump `schemaVersion` làm đỏ test story khác | ADR-010, STORY-001 §5 | Migration **chỉ `CREATE TABLE`**; đọc giá trị thật trên nhánh tích hợp rồi cộng một | Test migration v(n) → v(n+1) giữ nguyên mọi hàng `activity_cards`/`notebook_entries` | `SCHEMA_BUMP_BLOCKED` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: toàn bộ story — gói dữ liệu, cổng nhập, bảng nhãn, màn,
  cửa vào, và việc soạn/duyệt 400 ô.
- Authoritative inputs: `architecture/contract-summary.md`,
  `ux/uiux-spec.md`, STORY-001 và STORY-004 `contract-summary.md`,
  `mobile/lib/core/content/invariant_terms.dart`.
- Guardrails:
  - **Không** tạo denylist thứ hai. Luật hiển thị đọc từ
    `core/content/invariant_terms.dart`; chỉ luật *cấu trúc* của họ gói này mới
    là code mới.
  - **Không** nối `notebookBoundaryHitsIn` nguyên khối — chỉ khoá
    `frequencyProbe` (Key Discovery 3).
  - **Không** viết `12`, `16`, `144`, `256` vào bất kỳ file nào dưới
    `mobile/lib/`. Chúng chỉ được xuất hiện trong `mobile/test/`.
  - **Không** đặt chữ nội dung ô vào ARB, widget, hay hằng Dart; ngược lại,
    **không** đặt luật bất biến vào asset (R-15c).
  - **Không** thêm `routeName`, không sửa `routes:` trong `cupid_app.dart`,
    không thêm mục menu/tab bar.
  - **Không** import `context_notebook` từ feature này, và không thêm cột nào
    ghi DẢI/kết quả/nhận định vào bất kỳ bảng nào.
  - **Không** chép con số `schemaVersion` từ tài liệu này — đọc giá trị thật
    trên nhánh tích hợp rồi cộng một.
  - **Không** prefill nhãn của người dùng từ `CupidProfile.zodiacSign`: giá trị
    đó do `zodiacSignFor(birthday)` **suy ra** và tới từ `account_repository`
    qua mạng, nên dùng nó phá AC-29 (ngoại tuyến) và làm nhoè cờ
    `known`/`guess` của AC-8.

## 5. Non-Functional Impact

- Gói 400 ô (~250-400 KB JSON) nạp **lười lúc mở màn**, không lúc khởi động
  app, và giữ trong bộ nhớ đúng một vòng đời màn. Không nạp gói MBTI khi người
  dùng chỉ có nhãn hoàng đạo (AC-11 cho phép một hệ).
- Bề mặt quyền riêng tư: bảng nhãn chỉ chứa dữ liệu người dùng tự gõ về chính
  họ và về người kia, lọc theo `owner_key` như mọi bảng khác. Không xuất, không
  chia sẻ, không chụp ảnh có thương hiệu (BR-8).

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Nhãn tự khai sống trong bảng riêng `relationship_labels` do STORY-010 sở hữu | BR-5 nói nhãn "được phép lưu ở sổ tay" | ACCEPTED | "Được phép lưu" là phát biểu **quyền**, không phải chỉ định chỗ lưu. `notebook_entries.kind` là enum đóng `interest\|event` và nhãn cần thêm `subject`/`system`/`certainty` — nhét vào đó vừa đổi hợp đồng STORY-004 (BR-10 cấm) vừa đẩy dấu hoàng đạo lên danh sách sở thích của màn (2). |
| Mở rộng `AskTarget` thêm `self_label.zodiac` / `self_label.mbti` | uiux-spec mục 2 nói "dùng đúng cơ chế của STORY-004" | REJECTED | Đúng cái mà docstring của `AskTarget` được viết ra để chặn ("a CMS cannot invent a fourth destination"), và câu trả lời tự do của slot không biểu diễn được từ vựng đóng + cờ chắc chắn. Story dùng lại **dáng thị giác**, không dùng lại đường ghi. |
