# Phase P6 – Nhãn, affordance, caption và ngày-trong-tên (ruling mục 3, 4, 5, 6b)

## 1. Objective

Bốn thay đổi bề mặt trên màn (6), gộp một phase vì cùng chạm đúng hai widget và
cùng một bộ test nhãn:

- mục 3: nút đặc `Chép để nhắn` + nút tròn icon `refresh` thay cho icon copy
  trần + text button `Xem câu khác`
- mục 4: thêm dòng trấn an "Câu này nhắn liền, không cần lưu. Quay lại là có
  câu khác."
- mục 5: `Sự kiện có lịch` → `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC`, `Thêm vào kho` →
  `Thêm vào Muốn làm`
- mục 6b: bỏ badge `dd/mm` leading, ngày viết lẫn vào dòng tên sự kiện

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-labels-affordances-and-date-inline.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P5
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/conversation_starters/presentation/widgets/starter_hero_card.dart`
  - `mobile/lib/features/conversation_starters/presentation/widgets/starter_line.dart`
  - `mobile/lib/features/conversation_starters/presentation/screens/conversation_starters_screen.dart`
  - `mobile/lib/features/conversation_starters/domain/event_date_label.dart`
  - `mobile/lib/design_system/icons/cupid_icons.dart` — **chỉ thêm token
    `refresh`**, không sửa token nào đang có
  - `mobile/test/features/conversation_starters/conversation_starters_screen_test.dart`
  - `mobile/test/features/conversation_starters/event_date_label_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `CupidIcons.refresh` — token dùng chung, mọi màn khác đọc được
- Shared Interfaces Consumed:
  - `CupidPrimaryButton` (`mobile/lib/design_system/adaptive/cupid_primary_button.dart`)
  - `CupidIcons.add`, `CupidIcons.event`, `CupidIcons.contentCopy` — đã có token
  - `VisibleCalendarEvent.date` (P3) — đọc nguyên trạng
- Risk Surfaces:
  - Visual fidelity màn (6)
  - Không mạng / không AI (AC-15/AC-16) — nút `refresh` **không** gọi mạng
- Source Of Truth:
  - authoritative artifact or convention: canvas
    `../visual-fidelity/design-reference-6-moi-chuyen-a-a-ios.png`, neo bởi
    Design Ruling Log `req_master.md` hàng `2026-09-20 | STORY-005`
  - consumer contract: none
- Primary Inputs Summary:
  - requirements: AC-2, AC-3, AC-4, AC-11, AC-13, AC-14, AC-27
  - architecture: `../architecture/solution.md` §4 Mobile Lane guardrails (đọc
    lại, **không sửa**)
  - upstream phase outputs: P5 (thẻ hero đã tồn tại để gắn CTA vào)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một tập nhãn/affordance của cùng một màn
  - Source/Test File Count: 7
  - Split Required: NO
  - Split Rationale: bốn mục ruling này chạm đúng hai widget
    (`starter_hero_card.dart`, `conversation_starters_screen.dart`) và **cùng
    một** file test nhãn. Tách ra sẽ bắt hai lần dispatch cùng sửa cùng một
    hàm assert, và để lại một cây đỏ ở giữa. Hai file phụ là token icon
    (một hằng số) và một helper thuần + test của chính nó.

## 1C. Prerequisite Ngoài Phase (không phải việc của mobile-dev)

Mục 6b **va trực tiếp** với `../ux/uiux-spec.md` §2 mục 5, gạch đầu dòng
`Leading: badge ngày (dd/mm, caption 13pt)` (dòng 47 tại thời điểm lập kế
hoạch). Theo cột "Hệ quả" của ruling, **Scrum Master vá `uiux-spec.md` trực
tiếp từ ruling trước khi phase này bắt đầu** — Tech Lead không vá ở vòng này
(ngoài WriteScope), mobile-dev cũng không.

Trạng thái chặn: nếu gạch đầu dòng badge vẫn còn nguyên khi phase này được
dispatch, mobile-dev **dừng và báo blocker `UX_SPEC_PATCH_MISSING`**, không tự
sửa `uiux-spec.md` và cũng không thi hành mục 6b trái spec đang có hiệu lực.
Ba mục còn lại (3, 4, 5) không phụ thuộc bản vá này.

## 2. Required Reads

- Design Ruling Log hàng `2026-09-20 | STORY-005` trong `../../req_master.md`
- `../visual-fidelity/design-reference-6-moi-chuyen-a-a-ios.png` (nhìn bằng mắt)
- `../visual-fidelity/visual-fidelity-report.md` §7 hàng `3`, `4`, `5`, `6b`
- `../ux/uiux-spec.md` §2 mục 2 và mục 5 (**bản đã vá**)
- `mobile/lib/design_system/icons/cupid_icons.dart` phần đầu file — quy tắc tự
  cấm bịa codepoint

## 3. Tasks

### Mục 3 — affordance hero

- Trong thẻ hero: một hàng gồm nút đặc chiếm phần lớn bề ngang, nhãn
  `Chép để nhắn` kèm icon `CupidIcons.contentCopy` dẫn đầu; bên phải là một nút
  **tròn** icon `refresh`. Ưu tiên tái dùng `CupidPrimaryButton`; chỉ tự dựng
  container nếu gradient của nó lệch canvas, và khi đó dùng token gradient có
  sẵn, không hard-code màu mới.
- Bấm nút đặc = đúng hành vi copy hiện tại: ghi clipboard, bắn toast
  `starter_copied_toast` 2 giây, **không** tạo thẻ, **không** ghi danh sách nào
  (AC-2/AC-3).
- Nút tròn `refresh` gọi đúng `cubit.nextPage` — cùng hành vi của text button
  cũ. **Luôn bật**, không trạng thái tắt, không "đã xem hết", không `x/N`
  (AC-4/AC-27). Không lời gọi mạng nào phát sinh khi bấm (AC-15/AC-16).
- `CupidIcons` **chưa có** token `refresh` (đã kiểm tra: không có `refresh`,
  `autorenew`, `sync`, `cached`, `restart`). Tra **codepoint thật** của glyph
  `refresh` trong cmap của font icon đang bundle rồi thêm token, kèm comment
  ghi rõ codepoint đã xác nhận — đúng khuôn các token hiện có. **Cấm tuyệt đối
  bịa codepoint từ trí nhớ** (tiền lệ D-20/R8-F-2 trong Design Ruling Log).
- Nút tròn là icon-only ⇒ bọc `Semantics(button: true, label: 'Xem câu khác')`
  và giữ vùng chạm ≥ `kStarterCopyTapTarget` (tiền lệ STORY-010 mục 6:
  icon-only được, nhưng target chạm và nhãn trợ năng phải còn).
- Text button `Xem câu khác` cũ (`Key('starter_next_round')`) biến mất khỏi
  thân màn. Key mới của nút tròn: `starter_next_round` — **giữ nguyên tên key**
  để regression của P4 không mất dấu, chỉ đổi widget bên dưới.

### Mục 4 — dòng trấn an

- Ngay dưới hàng CTA trong thẻ hero: `Câu này nhắn liền, không cần lưu. Quay
  lại là có câu khác.` — `type.caption`, màu `colorTextMuted`, key
  `starter_hero_reassurance`.
- Là **chrome của màn**, đi qua `starterText(context, vi, en)`; không khoá ARB,
  không lấy từ gói nội dung (BR-15).

### Mục 5 — nhãn khối sự kiện

- Tiêu đề khối: `Sự kiện có lịch` → `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC`, IN HOA,
  `type.caption`, kèm icon `CupidIcons.event` dẫn đầu như canvas. Key
  `starter_events_heading` giữ nguyên.
- Nhãn pill: `Thêm vào kho` → `Thêm vào Muốn làm`, kèm icon `CupidIcons.add`
  dẫn đầu. Cập nhật luôn `Semantics.label` cho khớp nhãn mới.
- **Chỉ đổi chữ và icon.** Hành vi không đổi: vẫn gọi `cubit.addEventToStore`,
  mục vẫn biến mất khỏi dải sau khi thêm, vẫn không có màn xác nhận dẫn sang
  thẻ vừa tạo (AC-12). Nút "bỏ qua" (AC-14) **không** thuộc phạm vi phase này —
  mục 6a đã đóng riêng, giữ nguyên.

### Mục 6b — ngày trong tên sự kiện

- Bỏ hẳn `_dayMonthBadge`, `DecoratedBox` badge và key
  `starter_event_date_<id>`.
- Thêm `event_date_label.dart`: một hàm **thuần**
  `String eventDateLabel(String isoDate)` trả `thứ Bảy 16/08` — thứ trong tuần
  lấy từ `DateTime.parse(isoDate).weekday` qua một bảng tra tiếng Việt cố định
  trong file, cộng `dd/MM`. **Không** thêm dependency `intl`, **không** đọc
  đồng hồ, **không** nhận `today`.
- Dòng tên sự kiện render đúng một `Text`:
  `'<tên sự kiện> — <eventDateLabel(event.date)>'`, key
  `starter_event_name_<id>` giữ nguyên.
- **Ngoài phạm vi, không tự thêm:** lối viết tương đối kiểu `thứ Bảy này` /
  `tuần sau` mà canvas dùng. Ruling chỉ đóng "bỏ badge, gộp ngày vào tên";
  một nhánh tương đối theo `today` là hành vi mới chưa ai phán quyết. Nếu
  Reviewer đọc canvas theo nghĩa đen ở chỗ này, đó là một Design Ruling mới,
  không phải lỗi cài đặt của phase này.
- Nguồn ngày vẫn là `VisibleCalendarEvent.date` — đúng ngày dân dụng chốt sẵn
  mà thẻ được mang theo, nên nhãn không thể trôi khỏi ngày của thẻ.

### Test nhãn kéo theo

- Sửa các khẳng định nhãn trong
  `mobile/test/features/conversation_starters/conversation_starters_screen_test.dart`
  (tại thời điểm lập kế hoạch: 5 chỗ khớp `Sự kiện có lịch` / `Thêm vào kho` /
  `Xem câu khác` / `starter_event_date` / `starter_line_copy`).
- **Đính chính so với ruling:** cột "Hệ quả" viết "kéo theo cập nhật test nhãn
  ở P1/P4". Đã rà: P1 (`starter_content_gate_test.dart`) chỉ test cổng nhập nội
  dung, **không** chứa nhãn chrome nào; `app_vi.arb` cũng không (chuỗi
  `Thêm vào kho của tôi` ở đó thuộc feature `compat`, không phải màn này). Chỉ
  test của P4 phải sửa. Không đụng `app_vi.arb`.

## 4. Acceptance Criteria

- Thẻ hero có đúng một nút đặc nhãn `Chép để nhắn` và đúng một nút tròn
  `refresh`; không còn text button `Xem câu khác` dạng chữ trên thân màn.
- Bấm nút đặc ghi đúng câu hero vào clipboard và hiện toast; không thẻ nào được
  tạo, không danh sách nào được lưu.
- Bấm nút tròn nhiều lần hơn tổng số mục: luôn ra câu dùng được, nút không bao
  giờ bị tắt, không chuỗi "đã hết" nào xuất hiện.
- Nút tròn có `Semantics` nhãn `Xem câu khác` và vùng chạm ≥44pt.
- Dòng `Câu này nhắn liền, không cần lưu. Quay lại là có câu khác.` hiện dưới
  hàng CTA của thẻ hero.
- Tiêu đề khối sự kiện đọc `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC`; pill đọc
  `Thêm vào Muốn làm`; hành vi thêm/bỏ qua không đổi.
- Không còn widget badge ngày riêng; mỗi hàng sự kiện có đúng một dòng tên chứa
  cả ngày, và ngày hiển thị khớp `VisibleCalendarEvent.date`.
- `CupidIcons.refresh` mang codepoint tra được từ cmap của font đang bundle,
  render ra glyph thật (không ô tofu) trong ảnh chụp.
- Không khoá ARB mới; không chuỗi nội dung nào chuyển từ gói sang Dart; không
  lời gọi mạng mới.

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`.
- Contracts or schemas: `CupidIcons.refresh`.
- Notes or evidence: `coding-plan/test-results.md`,
  `visual-fidelity/implemented-6-moi-chuyen-a-a-material.png` chụp lại.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng UI widget cộng một helper thuần
- Required levels:
  - unit: `eventDateLabel` — bảy thứ trong tuần, ngày một chữ số phải ra
    `dd/MM` có số 0 dẫn đầu, chuỗi `YYYY-MM-DD` hợp lệ là đầu vào duy nhất
  - widget: nhãn mới hiện, nhãn cũ vắng mặt; copy từ nút đặc ghi clipboard;
    `starter_next_round` bấm được nhiều lần; badge cũ không còn trong cây widget
  - widget (a11y): `Semantics` của nút tròn và của pill mang nhãn mới
  - mobile build/type-check/static-analysis: `flutter analyze lib test` — gate
    là zero analyzer **error** và không warning mới ở file đã chạm; exit code
    **không** phải gate
- Required checks: chạy lại toàn bộ `mobile/test/features/conversation_starters/`;
  thêm `mobile/test/design_system/` nếu có test token icon
- Minimum gates by risk surface: nút `refresh` phải được test ở cả nhánh N nhỏ
- Required regression or contract coverage: mọi nơi khác đọc `CupidIcons` phải
  còn xanh sau khi thêm token
- Evidence format: lệnh `flutter test <đường dẫn>` và tóm tắt pass/fail trong
  `coding-plan/test-results.md`
- Per-story visual fidelity: **REQUIRED** — phase này đổi affordance và nhãn
  trên màn (6).
  - Chụp lại `visual-fidelity/implemented-6-moi-chuyen-a-a-material.png`.
  - Fallback được phép: `RepaintBoundary` trong widget test của phase này, với
    `CupidAppBackground`, một lớp nền đục và font MaterialIcons của framework.
  - **Bắt buộc nhìn bằng mắt ảnh đã chụp**: icon `refresh` mới thêm là chỗ dễ
    ra ô tofu nhất trong cả story, và một lần chạy "xanh" không phát hiện được.
  - Chạy `git status` trước khi báo hoàn thành; không commit PNG của story khác.
- Verification strategy:
  - Targeted tests/regression/contract checks: như trên
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: ảnh chụp đối chiếu cạnh canvas; bảng
    `nhãn cũ → nhãn mới` cho 4 chuỗi; codepoint `refresh` kèm nguồn tra được

## 7. Status

- Status: DONE
- Last updated: 2026-09-20
