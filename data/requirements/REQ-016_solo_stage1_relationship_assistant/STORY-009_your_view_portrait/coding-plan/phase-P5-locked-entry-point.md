# Phase P5 – Điểm vào duy nhất và khoá vị trí R-13

## 1. Objective

Màn (8) mở được từ đúng một chỗ — hàng đoán trong luồng gợi ý quà — qua một cửa
vào có kiểu, và **không** mở được bằng bất cứ cách nào khác: không route đặt tên,
không menu, không tab bar, không deep link. Khoá vị trí trở thành tính chất kiểm
được ở mức biên dịch, không phải quy ước.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-locked-entry-point.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P4
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/your_view_portrait/your_view_portrait_entry_point.dart`
  - `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart`
    (chỉ `_GuessRow`: thay snackbar bằng lời gọi cửa vào)
  - `mobile/test/features/your_view_portrait/your_view_portrait_entry_point_test.dart`
  - `mobile/test/features/your_view_portrait/portrait_location_lock_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `runCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `openYourViewPortrait(BuildContext, {required PortraitEntrySource from})` và
    `enum PortraitEntrySource { giftIdeas }`
    (`../architecture/contract-summary.md` mục 3) — STORY-008 sau này thêm giá
    trị `dateScript`, đó là điểm mở rộng duy nhất
- Shared Interfaces Consumed:
  - widget màn library-private của P4
  - `_GuessRow` với `Key('gift-ideas-guess-row')` (STORY-004, đã để dành sẵn)
- Risk Surfaces:
  - Khoá vị trí R-13 (AC-2/AC-3)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md`
    mục 3 (luật điều hướng) và mục 6 (điều cấm với consumer)
  - consumer contract: `_GiftIdeas` là consumer duy nhất trong story này
- Primary Inputs Summary:
  - requirements: AC-2, AC-3, AC-4 (`story_master.md`); `../requirements/requirements.md`
    mục khoá vị trí SC-6/R-13
  - architecture: `../architecture/contract-summary.md` mục 3, 6;
    `../architecture/solution.md` mục 1 `### Key Discovery` (phát hiện `routes:`
    thật ở `mobile/lib/app/cupid_app.dart`) và mục 4
  - OQ constraints: none
  - upstream phase outputs: màn của P4
  - UX constraints, if truly required: `../ux/uiux-spec.md` mục 1 (push toàn màn,
    có nút quay lại, đóng màn về đúng luồng nguồn giữ nguyên trạng thái)
  - review findings: none yet
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: một cụm — "một cửa vào, và không cửa nào khác"
  - Source/Test File Count: 4 source/test
  - Split Required: NO
  - Split Rationale: N/A

## 2. Required Reads

- `../requirements/requirements.md` (SC-6/R-13, AC liên quan)
- `../architecture/contract-summary.md` mục 3 và 6
- `../architecture/solution.md` mục 1 `### Key Discovery`, mục 4
- `../ux/uiux-spec.md` mục 1
- `mobile/lib/app/cupid_app.dart` — map `routes:` thật, để khẳng định sự vắng mặt
- `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart`
  quanh `_GuessRow` — chỗ nối đã để dành

## 3. Tasks

- Viết `your_view_portrait_entry_point.dart`: chỉ export `PortraitEntrySource` và
  `openYourViewPortrait`. **Không** export widget màn, **không** hằng `routeName`.
- Bên trong cửa vào, push trên Navigator của chính luồng nguồn. Không
  `pushReplacement`, không `rootNavigator: true`, không `popUntil` — đóng màn phải
  trả người dùng về đúng luồng gợi ý quà với trạng thái nguyên vẹn (AC-4 story).
- Nối `_GuessRow` trong `gift_ideas_screen.dart` gọi
  `openYourViewPortrait(context, from: PortraitEntrySource.giftIdeas)`, và **xoá**
  snackbar `gift_ideas_guess_coming_soon` cùng chuỗi ARB của nó nếu không còn ai
  dùng.
- Viết `portrait_location_lock_test.dart` khẳng định khoá vị trí bằng chứng cứ,
  không bằng lời: map `routes:` của `cupid_app.dart` **không** chứa khoá nào của
  chân dung; không có đường public nào dựng được widget màn từ ngoài thư viện
  feature; và không mục menu/tab bar nào mang tên màn này.
- Viết test cửa vào: bấm `Key('gift-ideas-guess-row')` mở màn chân dung; bấm nút
  quay lại trả về màn gợi ý quà đúng như trước.

## 4. Acceptance Criteria

- Bấm hàng đoán ở luồng gợi ý quà mở màn chân dung kèm nhãn xuất xứ ở đầu (AC-1
  story).
- `routes:` trong `cupid_app.dart` không có mục nào cho màn chân dung, và test
  khẳng định điều đó (AC-2, AC-3 story).
- Không tệp nào ngoài `features/your_view_portrait/` import trực tiếp widget màn;
  nếu kiểm bằng regex, phải phân giải URI import thật — `lib/` dùng import tương
  đối, nên so khớp chuỗi con `features/...` sẽ xanh giả trong khi vi phạm thật
  đang nằm đó.
- Đóng màn trả về luồng gợi ý quà với trạng thái nguyên vẹn (AC-4 story).
- Snackbar "sắp có" đã biến mất khỏi `_GuessRow`.

## 5. Planned Outputs

- Code directories or files:
  `mobile/lib/features/your_view_portrait/your_view_portrait_entry_point.dart`,
  `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart`
- Contracts or schemas: `openYourViewPortrait` + `PortraitEntrySource` (mục 3)
- Requirement configuration guide updates: none
- Notes or evidence: kết quả test khoá vị trí và test cửa vào

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter widget test + kiểm tĩnh nguồn
- Required levels (omit N/A levels):
  - unit: cửa vào push đúng Navigator, không thay thế ngăn xếp
  - integration: widget test đi từ màn gợi ý quà sang màn chân dung rồi quay lại
  - mobile build/type-check/static-analysis: `flutter analyze lib test` so với nền
    khác 0 đã biết, tiêu chí là không lỗi mới
- Required checks: kiểm tĩnh map `routes:` và kiểm biên giới import (phân giải URI)
- Mobile discoverability / navigation integration: story này cố ý **không** khám
  phá được từ menu/tab bar; cổng ở đây là khẳng định sự vắng mặt, cộng với đúng
  một đường vào từ `_GuessRow` đã kiểm bằng test
- Minimum gates by risk surface:
  - Khoá vị trí R-13: test `routes:` vắng mặt + test biên giới import + test
    điều hướng đi-và-về
- Required regression or contract coverage: `flutter test test/features/gift_ideas/`
  vẫn xanh sau khi đổi `_GuessRow`; test của P4 vẫn xanh
- Evidence format: lệnh đã chạy + dòng tóm tắt, dán vào `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — cổng này thuộc P4, nơi dựng màn;
  P5 chỉ nối điều hướng và không đổi bố cục nào
- Verification strategy:
  - Targeted tests/regression/contract checks: hai file test của phase +
    `test/features/gift_ideas/` + test của P4
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: assertion map `routes:` không chứa khoá chân dung

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
