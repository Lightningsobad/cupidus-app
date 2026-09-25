# Phase P10 – Màn check-in 23h: ẩn cùng lúc khi thiếu STORY-003 (AC-18)

## 1. Objective

Đóng đúng một khoảng trống thật, đã xác minh trực tiếp trên mã nguồn hiện có:
`evening_check_in_sheet.dart` render khối "viết một câu" + hai chip mô tả
**vô điều kiện** (`build()` dòng 232-276 của phiên bản hiện tại không có
nhánh nào rẽ theo trạng thái nhật ký), trong khi ac-patch PO/UX hôm nay
(`requirements.md` AC-18, commit `84bdd6b2`) đòi khi STORY-003 chưa giao thì
**ẩn cùng lúc** ô nhập, chip nhật ký, và lối thoát "viết một câu" — màn chỉ
còn lưới ảnh tuỳ chọn, không hiện ô/khối nào ở trạng thái xám vô hiệu hoá.
Phần còn lại của D-6 (màn toàn màn hình, khối ngữ cảnh, lưới ba ô ảnh, dòng
trấn an giới hạn đúng một lời hứa) đã DONE và có bằng chứng test PASS ở P8 —
phase này **không** đụng lại phần đó.

**Lượt sửa 2026-09-25 (bắt buộc đọc trước khi implement).** Bản P10 đầu tiên
chỉ định gate bằng `widget.openJournal != null`. Chỉ định đó **sai và đã bị
thay thế** bởi `../architecture/contract-summary.md` §7: nơi gọi sản xuất duy
nhất `_openFromPayload` (`evening_check_in_sheet.dart:529+`) **không** truyền
`openJournal`, nên trên đúng đường ship `widget.openJournal` là `null` trong
khi STORY-003 **đã** giao — implement theo bản cũ sẽ làm khối "viết một câu"
biến mất ở bản phát hành, hồi quy trực tiếp AC-16. `openJournal` là **seam
test** (`_save()` dòng 368: `widget.openJournal ?? _openJournal`), không phải
tín hiệu tồn tại của nhật ký. §7 chốt phương án (a): thêm một **cờ năng lực
bản dựng** tường minh, mặc định `true`. §3 dưới đây là bản đã theo §7.

## 1A. Ownership

- Phase ID: P10
- Canonical Phase File: `phase-P10-checkin-degrade-parity.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P6 (chủ sở hữu gốc của `evening_check_in_sheet.dart`), P8 (lượt
  patch D-6 toàn màn hình đã DONE)
- Parallelizable: NO (lane Mobile chỉ có một code-writer:
  `MAX_CODE_WRITERS_PER_STORY: 1`, và P10 → P11 → P12 là ba phase còn lại của
  cùng lane, chạy tuần tự theo thứ tự đó)
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
- Shared Interfaces Produced:
  - `EveningCheckInSheet({... bool journalAvailable = true})` và
    `EveningCheckInSheet.show(... bool journalAvailable = true)` — cờ năng lực
    bản dựng, hợp đồng ở `../architecture/contract-summary.md` §7
- Shared Interfaces Consumed:
  - `mobile/lib/features/journal/journal_entry_point.dart` (`openJournalComposer`
    là hàm top-level vô điều kiện, STORY-003 **đã** giao — không có trạng thái
    "vắng mặt" nào dò được ở runtime, nên nhánh AC-18 phải do cờ bản dựng
    quyết định, không phải do dò runtime; xem §3 Tasks)
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
  - architecture: `../architecture/contract-summary.md` §7 (quyết định
    2026-09-25, hợp đồng bắt buộc của phase này)
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
    một file, theo đúng một cờ tuỳ chọn mới có mặc định (`journalAvailable`)
  - Source/Test File Count: 2 file (1 nguồn, 1 test)
  - Split Required: NO
  - Split Rationale: N/A — quá nhỏ để cần tách

## 2. Required Reads

- `../architecture/contract-summary.md` §7 (hợp đồng chốt — đọc trước tiên)
- `../requirements/requirements.md` AC-16..AC-19 (anchor, bản vá hôm nay)
- `../ux/uiux-spec.md` §4 đoạn "Nếu STORY-003 chưa giao (AC-18)"
- `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart`
  dòng 65-119 (khai báo widget + `show`), dòng 160-280 (khối `_Block` context +
  khối `_Block` câu viết/chip), dòng 360-375 (`_save()`, nơi `openJournal` được
  dùng như seam test), dòng 529-575 (`_openFromPayload`, nơi gọi sản xuất)

## 3. Tasks

- Thêm đúng **một** tham số tuỳ chọn có mặc định vào `EveningCheckInSheet`
  (constructor, dòng 66-74) và `EveningCheckInSheet.show` (dòng 93-115):
  `bool journalAvailable = true`, kèm truyền xuống trong thân `show` (cạnh
  `openJournal: openJournal`, dòng 111). Không có tham số thứ hai, không có
  enum, không có cổng runtime.
- Tài liệu hoá ngay tại khai báo field rằng đây là **cờ năng lực bản dựng**,
  giá trị sản xuất hiện tại luôn `true` vì `openJournalComposer` là hàm
  top-level vô điều kiện, và nó **không** phải seam test (`openJournal` mới là
  seam test). Một câu, không đoạn dài.
- Trong `_EveningCheckInSheetState.build()`, gate khối `_Block` thứ hai (nhãn
  "viết một câu" + `TextField` `eveningCheckInFieldKey` + hai `_Chip`, hiện ở
  dòng 233-276) bằng `widget.journalAvailable` — **không** bằng
  `widget.openJournal`. Gate phải bao luôn `const SizedBox(height:
  CupidSpacing.md)` ở dòng 232 (khoảng đệm dẫn vào khối đó), nếu không nhánh
  `false` để lại một khoảng trắng kép. Cách gọn nhất là đổi hai phần tử đó
  thành một spread điều kiện trong `children`:
  `if (widget.journalAvailable) ...<Widget>[const SizedBox(...), _Block(...)]`.
- Khi `journalAvailable == false`: **ẩn hẳn** — không render khối đó, không
  `enabled: false`, không đổi màu xám, không giữ lại nhãn. Khối ảnh (context +
  lưới ba ô `eveningCheckInAttachKey`) và dòng trấn an chân màn
  (`eveningCheckInReassuranceKey`, đã DONE ở P8) giữ nguyên **vô điều kiện** —
  xác nhận cả hai nằm ngoài phần bị gate trước khi chạy test.
- **Không** sửa `_openFromPayload` (dòng 529-575) và **không** sửa `_save()`
  (dòng 368, `widget.openJournal ?? _openJournal`): vì tham số mới là tuỳ chọn
  có mặc định `true`, nơi gọi sản xuất tiếp tục biên dịch và tiếp tục hiện khối
  câu viết, đúng AC-16.
- Cập nhật `evening_check_in_sheet_test.dart`: **giữ nguyên mọi case P6/P8**,
  kể cả helper `_sheet()` (dòng 51-65) vốn để `openJournal` mặc định `null` —
  nó vẫn phải gõ + lưu thành công mà không đổi assertion nào. Thêm đúng một
  case AC-18 mới dựng sheet với `journalAvailable: false` và khẳng định:
  `find.byKey(eveningCheckInFieldKey)` `findsNothing`,
  `find.byType(_Chip)`/hai nhãn chip (`l10n.evening_check_in_journal_chip`,
  `l10n.evening_check_in_private_chip`) `findsNothing`, còn
  `find.byKey(eveningCheckInAttachKey)` vẫn `findsOneWidget`. `_Chip` là
  private nên khẳng định qua `find.text(...)` của hai nhãn đó, không export
  `_Chip`.

## 4. Acceptance Criteria

- AC-18: khi sheet dựng với `journalAvailable: false`, `eveningCheckInFieldKey`
  và hai nhãn chip mô tả KHÔNG có mặt trong cây widget (`findsNothing`) — không
  chỉ "không bị khoá/xám"; lưới ảnh vẫn `findsOneWidget`.
- AC-16 (không hồi quy): khi dựng qua đường mặc định (`journalAvailable` không
  truyền, kể cả khi `openJournal == null` như `_openFromPayload` và helper
  `_sheet()` đang làm), khối câu viết **vẫn hiện** và lưu vẫn chạy — hành vi
  giữ nguyên như P6/P8 đã đóng, không một assertion cũ nào phải sửa.
- AC-16/AC-17/AC-19, D-6/D-7/D-8/D-9 (đã DONE ở P8): không đổi assertion nào
  ngoài case AC-18 nêu trên.

## 5. Planned Outputs

- Code directories or files: xem Write Scope
- Contracts or schemas: none
- Requirement configuration guide updates: none
- Notes or evidence: cập nhật `coding-plan/test-results.md` với lượt patch
  AC-18. Nhánh mặc định (`journalAvailable` không truyền) không đổi bố cục nên
  `implemented-evening-check-in-sheet.png` **không** phải chụp lại — ghi rõ câu
  đó. Nhánh `journalAvailable: false` không có canvas riêng trong bộ thiết kế
  đã neo, nên per-story capture cho nhánh đó là `NOT_APPLICABLE — bản vẽ chỉ
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
