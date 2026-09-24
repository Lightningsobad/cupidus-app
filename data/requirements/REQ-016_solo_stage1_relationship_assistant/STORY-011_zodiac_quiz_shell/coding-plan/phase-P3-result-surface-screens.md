# Phase P3 – Màn chọn, màn hỏi, và bề mặt kết quả một-lượt-cuộn

## 1. Objective

Bề mặt kết quả duy nhất: đoạn nhận định, khối "câu để hỏi" khi đoạn nhắc tới
người kia, rồi đúng 3 thẻ gợi ý với hành động "Thêm vào kho của tôi" — tất cả
trên cùng một lượt cuộn, cộng màn chọn lát/bộ dẫn vào nó.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-result-surface-screens.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/zodiac_shell/presentation/screens/zodiac_shell_screen.dart`
  - `mobile/lib/features/zodiac_shell/presentation/widgets/zodiac_result_surface.dart`
  - `mobile/lib/l10n/arb/app_vi.arb`
  - `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/test/features/zodiac_shell/zodiac_shell_screen_test.dart`
  - `mobile/test/features/zodiac_shell/zodiac_result_surface_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ZodiacShellScreen` (P4 đẩy màn này)
- Shared Interfaces Consumed:
  - `ZodiacShellCubit` + state (P2)
  - design system: `CupidSpacing`, `CupidTypographyTokens`, `CupidColorTokens`,
    `CupidIcon`/`CupidIcons`
- Risk Surfaces:
  - Bề mặt kết quả một-lượt-cuộn
  - Giọng R-1e/R-1g ở đầu ra
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §2, §3, §4
  - consumer contract: P4 (điều hướng vào màn này)
- Primary Inputs Summary:
  - requirements: AC-2/3/4/5/6/9/10/12/13/14/15/17/19/20, BR-1/BR-2/BR-5/BR-11
  - architecture: `../architecture/solution.md` §3 UI Delivery Anchor, §4 risk
  - upstream phase outputs: state của cubit P2
  - UX constraints: `../ux/uiux-spec.md` §2 (màn chọn), §3 (thứ tự khối kết
    quả, snackbar hoàn tác 5 giây, không hiệu ứng "đang tính"), §4 (ranh giới
    đạo đức), §5 (tái dùng style thẻ gợi ý của STORY-004/005, không định nghĩa
    biến thể thẻ thứ ba)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: các bề mặt hiển thị của story
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (Nhóm A, Nhóm B, Nhóm C, Nhóm D, Nhóm E)
- `../ux/uiux-spec.md` §2-§5
- `../architecture/solution.md` §3 UI Delivery Anchor, §4
- output của P2: hình dạng state của cubit
- mẫu tham chiếu: `mobile/lib/features/compatibility_lookup/presentation/widgets/compat_activity_block.dart`
  (hành động "Thêm vào kho của tôi")

## 3. Tasks

- Màn chọn: danh sách thẻ, mỗi thẻ `title` + `blurb` 1-2 dòng, mọi lựa chọn
  luôn mở. Không mục "hôm nay mới mở khoá", không badge, không số đếm.
- Màn hỏi: một câu mỗi lần theo cửa sổ rotation của P2. Câu có
  `subject == guess_about_other` phải hiện nhãn phỏng đoán của người dùng
  (AC-12). Bỏ dở và quay lại bắt đầu lại sạch, không đếm lần bỏ dở (AC-3).
- Bề mặt kết quả, thứ tự từ trên xuống trong **một** scrollable: đoạn nhận định
  (`body 17pt`) → khối "câu để hỏi" khi `about_other` → tiêu đề phụ ngăn cách →
  3 thẻ gợi ý xếp dọc. Không `ExpansionTile`, không nút "xem gợi ý", không màn
  thứ hai.
- Mỗi thẻ: một hành động chính "Thêm vào kho của tôi" → tạo thẻ ngay + snackbar
  hoàn tác 5 giây, không hộp thoại xác nhận. Chọn được nhiều thẻ trên cùng màn.
- Chuyển từ màn hỏi sang màn kết quả tức thời hoặc skeleton tải-dữ-liệu thường
  — không hiệu ứng gõ chữ dần, không spinner kiểu "đang tính".
- `.arb`: chỉ chrome (tiêu đề màn, nhãn nút, nhãn phỏng đoán, tiêu đề phụ,
  nội dung snackbar). **Không** đặt câu hỏi, nhận định, hay văn bản thẻ vào
  `.arb` — chúng thuộc gói nội dung (BR-12).

## 4. Acceptance Criteria

- Với **mọi** outcome trong gói seed, màn kết quả render đúng 3 thẻ trên cùng
  một scrollable; không tồn tại nhánh render kết quả không kèm 3 thẻ.
- Không widget nào hiển thị `%`, điểm số, DẢI, thanh tiến độ, số câu đã làm,
  streak, hay huy hiệu.
- Rời màn kết quả mà không chọn thẻ nào: không chặn, không nhắc lại, không
  snackbar trách móc.
- Khối "câu để hỏi" hiện đúng khi và chỉ khi `about_other == true`.
- `flutter gen-l10n` chạy được sau khi sửa `.arb` (chạy trước `flutter test`
  trong worktree mới).

## 5. Planned Outputs

- Code: `mobile/lib/features/zodiac_shell/presentation/`
- Contracts: không hợp đồng mới
- Evidence: `coding-plan/test-results.md`, PNG capture của màn kết quả

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, widget layer
- Required levels:
  - unit: chọn nhãn/thứ tự khối theo `about_other`
  - integration: widget test màn kết quả trên toàn bộ outcome của gói seed
  - mobile build/type-check/static-analysis: `flutter gen-l10n` rồi
    `flutter analyze lib test`, so delta với baseline khác 0 của repo
  - visual inspection: đọc PNG capture bằng mắt, đối chiếu chữ thật (kiểm tra
    không có glyph tofu) trước khi ghi bằng chứng
- Required checks: quét widget tree kết quả không chứa `ExpansionTile`,
  `LinearProgressIndicator`, hay chuỗi `%`
- Mobile discoverability / navigation integration: N/A ở phase này — P4 sở hữu
  cửa vào; phase này chỉ chứng minh màn dựng được khi được đẩy trực tiếp
- Minimum gates by risk surface:
  - Bề mặt kết quả một-lượt-cuộn → widget test lặp qua mọi outcome seed
  - Giọng R-1e/R-1g ở đầu ra → widget test khối "câu để hỏi" + nhãn phỏng đoán
- Required regression or contract coverage: chạy lại
  `test/features/activity_cards/` vì thẻ mới được tạo qua repository chung;
  kiểm `git status` trước khi báo hoàn tất để không để lại PNG của story khác
  bị suite ghi đè
- Evidence format: lệnh + kết quả trong `coding-plan/test-results.md`; PNG kèm
  đường dẫn tuyệt đối
- Per-story visual fidelity: REQUIRED
  - Design screen id + how it is rendered: giải bằng `--screen=<slug id>` trên
    canvas đã neo của REQ-016; **không** truyền `--label`. Id thật do
    implementer chốt sau khi render, theo `contracts/design-fidelity-spec.md`
    "Design source detection and locking".
  - How the implemented screen is captured: `capture-mobile-screen.sh`; nếu
    không có thiết bị/runtime, dùng `RepaintBoundary` trong widget test của
    chính phase này để chụp bề mặt kết quả. Nếu cả hai đường đều không chạy
    được, phase block với `MOBILE_RUNTIME_UNAVAILABLE` — đây là blocker, không
    phải hoãn sang audit cấp requirement.
- Verification strategy:
  - Targeted tests: `flutter test test/features/zodiac_shell/ test/features/activity_cards/`
  - Build/type-check: `flutter gen-l10n` rồi `flutter analyze lib test`
  - Required assertion evidence: số outcome seed đã duyệt trong test đúng-3, và
    tên test cho từng luật cấm hiển thị
- Runtime startup smoke: NO

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-24
