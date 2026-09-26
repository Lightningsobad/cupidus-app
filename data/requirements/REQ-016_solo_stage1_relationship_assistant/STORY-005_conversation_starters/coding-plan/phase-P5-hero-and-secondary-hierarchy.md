# Phase P5 – Phân cấp hero/phụ cho khối câu gợi chuyện (ruling mục 2)

## 1. Objective

Khối Bản A của màn (6) đổi từ **ba dòng ngang hàng** sang **một câu hero trong
thẻ nổi (caption `CÂU HÔM NAY`) + hai câu phụ dưới caption `CÙNG CHỦ ĐỀ`**,
đúng canvas `6-moi-chuyen-a-a`. Chỉ đổi phân cấp/bố cục — affordance và nhãn
giữ nguyên ở phase này, P6 mới đổi chúng.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-hero-and-secondary-hierarchy.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None (nền là bản đã merge của P4)
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/conversation_starters/presentation/widgets/starter_hero_card.dart`
  - `mobile/lib/features/conversation_starters/presentation/widgets/starter_line.dart`
  - `mobile/lib/features/conversation_starters/presentation/screens/conversation_starters_screen.dart`
  - `mobile/test/features/conversation_starters/conversation_starters_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE — phase này chỉ sắp lại widget trong một màn
    đã có, không đổi đường khởi động app
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced: none
- Shared Interfaces Consumed:
  - `RenderedStarter`, `StarterSelector` (P3) — **đọc nguyên trạng, không sửa**
  - `CupidHeader`, `CupidSpacing`, `CupidColorTokens`, `CupidTypographyTokens`
- Risk Surfaces:
  - Visual fidelity màn (6)
  - Hành vi hết-vòng với mọi N (AC-27/AC-28) — bề mặt UI của nó
- Source Of Truth:
  - authoritative artifact or convention: canvas
    `../visual-fidelity/design-reference-6-moi-chuyen-a-a-ios.png`, neo bởi
    Design Ruling Log `req_master.md` hàng `2026-09-20 | STORY-005 | §7 mục
    2,3,4,5,6b,7`
  - consumer contract: none (không phase nào ngoài P6 đọc widget này)
- Primary Inputs Summary:
  - requirements: AC-1, AC-4, AC-17, AC-27, AC-28
  - architecture: `../architecture/solution.md` §3 UI Delivery Anchor (đọc lại,
    **không sửa** — vòng này không chạm `architecture/`)
  - upstream phase outputs: P4 (màn hiện tại)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một khối UI và phân cấp của chính nó
  - Source/Test File Count: 4
  - Split Required: NO

## 2. Required Reads

- Design Ruling Log hàng `2026-09-20 | STORY-005` trong
  `../../req_master.md` — cột "Phán quyết" và "Hệ quả", mục 2
- `../visual-fidelity/design-reference-6-moi-chuyen-a-a-ios.png` (nhìn bằng mắt)
- `../visual-fidelity/visual-fidelity-report.md` §7 hàng `2`
- `mobile/lib/features/conversation_starters/presentation/screens/conversation_starters_screen.dart`
- `mobile/lib/features/conversation_starters/presentation/widgets/starter_line.dart`

## 3. Tasks

- Thêm `StarterHeroCard` trong `starter_hero_card.dart`: một thẻ bo góc nền
  `colorSurfaceAlt`, bên trong là caption `CÂU HÔM NAY` (IN HOA, `caption`,
  letter-spacing rộng) rồi câu hero ở cỡ chữ lớn/đậm hơn `type.body` — đúng
  tương quan thị giác của canvas, không phải cùng một cỡ với câu phụ.
- Màn: câu đầu tiên của `state.starters` render bằng `StarterHeroCard`; các câu
  còn lại render dưới một caption `CÙNG CHỦ ĐỀ` (IN HOA, `caption`, muted), mỗi
  câu vẫn là một `StarterLine` nhưng đặt trong một hộp bo góc nền
  `colorSurfaceAlt` như canvas vẽ.
- **Thứ tự không đổi:** hero là phần tử `[0]` của danh sách `StarterSelector`
  đã trả về. Không thêm quy tắc chọn hero, không thêm con trỏ, không thêm
  trường nào vào `RenderedStarter` — thứ tự đã tất định theo AC-17 và phase này
  không được thay đổi nó.
- **N nhỏ (AC-28):** `starters.length == 1` ⇒ chỉ vẽ thẻ hero, **không** vẽ
  caption `CÙNG CHỦ ĐỀ`, không ô giữ chỗ, không hộp rỗng.
  `starters.isEmpty` ⇒ giữ nguyên hành vi hiện tại, không thêm trạng thái mới.
- Hai caption `CÂU HÔM NAY`/`CÙNG CHỦ ĐỀ` là **chrome của màn**, đi qua
  `starterText(context, vi, en)` — không thêm khoá ARB, không lấy từ gói nội
  dung (BR-15, `architecture/solution.md` §4).
- Key mới cho test/ảnh chụp: `starter_hero_card`, `starter_hero_caption`,
  `starter_topic_caption`. Key `starter_line_<id>` và
  `starter_line_text_<id>` của câu phụ **giữ nguyên tên**.
- **Giữ nút copy trên câu phụ.** Canvas không vẽ nút copy ở hai thẻ phụ, nhưng
  đó **không** nằm trong 6 mục đã phán quyết ở §7, còn `ux/uiux-spec.md` §2
  mục 2 đang yêu cầu mỗi câu có nút copy ≥44pt. Gỡ một affordance đang chạy
  ngoài phạm vi ruling là tự phân xử — không làm ở phase này.

## 4. Acceptance Criteria

- Màn vẽ đúng một thẻ hero có caption `CÂU HÔM NAY`, và tối đa hai câu phụ
  dưới caption `CÙNG CHỦ ĐỀ`.
- Với kho N = 1: có thẻ hero, **không** có caption `CÙNG CHỦ ĐỀ`, không hộp
  rỗng, không chuỗi giữ chỗ.
- Với kho N = 2: một hero + đúng một câu phụ.
- Bấm "Xem câu khác" nhiều lần hơn tổng số mục: hero luôn có nội dung, không
  lần nào rỗng, không nút nào bị tắt — hành vi AC-27/AC-28 không đổi.
- Cùng (ngày, sổ tay, page) cho ra cùng một câu ở vị trí hero qua hai lần dựng
  (AC-17).
- Trên màn vẫn không tồn tại: bộ đếm mục còn lại, phần trăm, chuỗi "đã xem
  hết", nút lưu/yêu thích, hay bất kỳ điều khiển chấm điểm câu nào.
- Không khoá ARB mới, không chuỗi nội dung nào bị chuyển từ gói sang Dart.

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`.
- Contracts or schemas: none.
- Notes or evidence: `coding-plan/test-results.md`,
  `visual-fidelity/implemented-6-moi-chuyen-a-a-material.png` chụp lại.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng UI widget
- Required levels:
  - widget: dựng màn với N = 1, N = 2, N = 12; khẳng định `starter_hero_card`
    tồn tại đúng một lần, số câu phụ đúng, caption `CÙNG CHỦ ĐỀ` vắng mặt khi
    N = 1
  - widget (regression): bấm "Xem câu khác" quá số mục vẫn ra hero có chữ
  - mobile build/type-check/static-analysis: `flutter analyze lib test` — gate
    là zero analyzer **error** và không warning mới ở file đã chạm; exit code
    **không** phải gate (baseline của repo khác 0)
- Required checks: quét cây widget, khẳng định không có chuỗi cấm nêu ở
  Acceptance Criteria
- Minimum gates by risk surface: N nhỏ hơn số ô mỗi lượt phải được test, không
  chỉ test kho đầy
- Required regression or contract coverage:
  `mobile/test/features/conversation_starters/` toàn thư mục
- Evidence format: lệnh `flutter test <đường dẫn>` và tóm tắt pass/fail trong
  `coding-plan/test-results.md`
- Per-story visual fidelity: **REQUIRED** — phase này đổi bố cục màn (6).
  - Chụp lại `visual-fidelity/implemented-6-moi-chuyen-a-a-material.png`.
  - Fallback được phép: `RepaintBoundary` ngay trong widget test của phase này;
    dùng `CupidAppBackground`, một lớp nền đục, và nạp font MaterialIcons của
    framework — thiếu một trong ba thì icon ra ô tofu.
  - **Bắt buộc nhìn bằng mắt ảnh đã chụp** trước khi kết luận đạt: một lần chạy
    "xanh" vẫn có thể chứa glyph tofu ở chữ tiếng Việt.
  - Chạy `git status` trước khi báo hoàn thành: bộ test mobile có thể ghi đè
    PNG visual-fidelity của story khác; chỉ commit PNG của story này.
- Verification strategy:
  - Targeted tests/regression/contract checks: như trên
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: ảnh chụp đối chiếu cạnh canvas, cộng bảng
    `N → (số thẻ hero, số câu phụ, caption có/không)`

## 7. Status

- Status: DONE
- Last updated: 2026-09-20
- Evidence: `coding-plan/test-results.md` §"P5 — Phân cấp hero/phụ",
  `visual-fidelity/implemented-6-moi-chuyen-a-a-material.png`
