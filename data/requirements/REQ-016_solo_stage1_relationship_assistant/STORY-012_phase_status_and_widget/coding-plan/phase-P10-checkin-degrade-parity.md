# Phase P10 – Màn check-in 23h: ẩn cùng lúc khi thiếu STORY-003 (AC-18)

## 1. Objective

Đóng đúng một khoảng trống thật, đã xác minh trực tiếp trên mã nguồn hiện có:
`evening_check_in_sheet.dart` render khối "viết một câu" + hai chip mô tả
**vô điều kiện** (`build()` dòng 233-276 của phiên bản hiện tại không có
nhánh nào rẽ theo `widget.openJournal`), trong khi ac-patch PO/UX hôm nay
(`requirements.md` AC-18, commit `84bdd6b2`) đòi khi STORY-003 chưa giao thì
**ẩn cùng lúc** ô nhập, chip nhật ký, và lối thoát "viết một câu" — màn chỉ
còn lưới ảnh tuỳ chọn, không hiện ô/khối nào ở trạng thái xám vô hiệu hoá.
Phần còn lại của D-6 (màn toàn màn hình, khối ngữ cảnh, lưới ba ô ảnh, dòng
trấn an giới hạn đúng một lời hứa) đã DONE và có bằng chứng test PASS ở P8 —
phase này **không** đụng lại phần đó.

## 1A. Ownership

- Phase ID: P10
- Canonical Phase File: `phase-P10-checkin-degrade-parity.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P6 (chủ sở hữu gốc của `evening_check_in_sheet.dart`), P8 (lượt
  patch D-6 toàn màn hình đã DONE)
- Parallelizable: YES (không đụng file nào P9 sửa)
- Write Scope:
  - `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart`
  - `mobile/test/features/phase_status/evening_check_in_sheet_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: mobile-app
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced: None
- Shared Interfaces Consumed:
  - `../../journal/journal_entry_point.dart` (đã tồn tại, STORY-003 **đã
    giao** trong codebase hiện tại — nhánh AC-18 là phòng thủ/graceful
    degradation, không phải trạng thái sản phẩm hiện hành; xem §3 Tasks)
- Risk Surfaces:
  - `REMIND-REPEAT` (dòng trấn an chân màn — đã DONE ở P8, phase này chỉ giữ
    nguyên, không sửa lại)
- Source Of Truth:
  - authoritative artifact: `../requirements/requirements.md` AC-16..AC-19
    (bản đã vá bởi commit `84bdd6b2`)
  - consumer contract: `evening_check_in_sheet_test.dart`
- Primary Inputs Summary:
  - requirements: AC-18 (bản vá hôm nay — câu "ẩn cùng lúc ô nhập, chip nhật
    ký, và lối thoát 'viết một câu'"), AC-16, AC-17, AC-19 (không đổi, chỉ
    làm bối cảnh)
  - architecture: none
  - OQ constraints: none
  - upstream phase outputs: P6 (`EveningCheckInSheet` gốc), P8 (D-6 toàn màn
    hình đã DONE)
  - UX constraints: `../ux/uiux-spec.md` §4, đoạn "Nếu STORY-003 chưa giao
    (AC-18)" (bản vá hôm nay)
  - review findings: `../review/review-report.md` không có finding riêng cho
    khoảng trống này — đây là gap phát sinh **sau** review S7, từ chính
    ac-patch hôm nay, không phải rework của một finding cũ
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: một nhánh hiển thị có/không của đúng một khối UI trong
    một file, theo một điều kiện đã có sẵn tín hiệu (`openJournal` nullable)
  - Source/Test File Count: 2 file (1 nguồn, 1 test)
  - Split Required: NO
  - Split Rationale: N/A — quá nhỏ để cần tách

## 2. Required Reads

- `../requirements/requirements.md` AC-16..AC-19 (anchor, bản vá hôm nay)
- `../ux/uiux-spec.md` §4 đoạn "Nếu STORY-003 chưa giao (AC-18)"
- `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart`
  dòng 121-280 (khối `_Block` context + khối `_Block` câu viết/chip)
- `mobile/lib/features/journal/journal_entry_point.dart` (tín hiệu sẵn có,
  không tạo cổng mới)

## 3. Tasks

- Trong `_EveningCheckInSheetState.build()`, bọc khối `_Block` thứ hai (nhãn
  "viết một câu" + `TextField` + hai `_Chip`, hiện ở dòng ~233-276) trong một
  điều kiện `widget.openJournal != null` (giữ đúng tín hiệu widget đã nhận,
  không thêm tham số/cổng mới, không đọc trạng thái STORY-003 từ nơi khác).
  Khi `null`: không render khối đó — **ẩn hẳn**, không set `enabled: false`
  hay đổi màu xám. Khối ảnh (context + lưới ba ô) giữ nguyên không điều kiện.
- Xác nhận dòng trấn an chân màn (`eveningCheckInReassuranceKey`, đã DONE ở
  P8) không nằm trong khối bị ẩn — nó luôn hiện, đúng D-6.
- Không đổi chữ ký `EveningCheckInSheet`/`EveningCheckInSheet.show` (public
  API của widget này đã ổn định qua P6-P8); không đổi nơi gọi
  (`_openFromPayload`, ngoài Write Scope của phase này).
- Cập nhật `evening_check_in_sheet_test.dart`: đổi case AC-18 hiện có ("the
  sentence field is never disabled or greyed out") — case đó vẫn giữ cho
  nhánh `openJournal != null`, cộng thêm case mới cho nhánh `openJournal ==
  null`: `find.byKey(eveningCheckInFieldKey)` và cả hai `_Chip` phải
  `findsNothing`, còn `find.byKey(eveningCheckInAttachKey)` (lưới ảnh) vẫn
  `findsOneWidget`.

## 4. Acceptance Criteria

- AC-18: khi widget dựng với `openJournal: null`, `eveningCheckInFieldKey`,
  hai `_Chip` mô tả, KHÔNG có mặt trong cây widget (`findsNothing`) — không
  chỉ "không bị khoá/xám".
- AC-18 (nhánh còn lại): khi `openJournal` khác `null` (đường sản phẩm thật,
  STORY-003 đã giao), hành vi giữ nguyên như P8 đã đóng — không hồi quy.
- AC-16/AC-17/AC-19, D-6/D-7/D-8/D-9 (đã DONE ở P8): không đổi assertion nào
  ngoài case AC-18 nêu trên.

## 5. Planned Outputs

- Code directories or files: xem Write Scope
- Contracts or schemas: none
- Requirement configuration guide updates: none
- Notes or evidence: cập nhật `coding-plan/test-results.md` với lượt patch
  AC-18; nếu ảnh `implemented-evening-check-in-sheet.png` không đổi bố cục ở
  nhánh mặc định (`openJournal != null`) thì ghi rõ không cần chụp lại, chỉ
  cần chụp thêm ảnh nhánh `openJournal == null` nếu design có canvas riêng
  cho nhánh đó; nếu không có canvas riêng, ghi `NOT_APPLICABLE — bản vẽ chỉ
  có nhánh đủ dữ liệu`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (Dart widget test)
- Required levels (omit N/A levels):
  - unit: N/A
  - mobile build/type-check/static-analysis: `flutter analyze
    lib/features/phase_status` (0 error)
- Required checks: `flutter test test/features/phase_status/evening_check_in_sheet_test.dart`
- Mobile discoverability / navigation integration: N/A — không đổi route
- Minimum gates by risk surface: `REMIND-REPEAT` → khẳng định lại (không sửa)
  case dòng trấn an vẫn PASS
- Required regression or contract coverage: toàn bộ
  `test/features/phase_status` phải PASS không giảm case so với P8/P9
- Evidence format: lệnh + kết quả dán nguyên văn vào
  `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — thay đổi là ẩn/hiện một khối đã
  có, không đổi bố cục nhánh mặc định đã được P8 chụp và duyệt; nếu mobile-dev
  phát hiện bố cục nhánh mặc định cũng đổi thì phải nâng mục này lên REQUIRED
  và chụp lại, không tự ý bỏ qua.
- Runtime startup smoke (omit if NO): NO

## 7. Status

- Status: PENDING
- Last updated: 2026-09-25
