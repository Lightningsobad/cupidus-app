# Phase P4 – Cửa vào từ CỬA VÀO của menu chính

## 1. Objective

Ô thứ ba của dải quick-entry mở màn thật thay vì snackbar "Sắp có", và không có
khoá theo địa điểm nào chắn trước nó.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-entry-point-wiring.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/zodiac_shell/zodiac_shell_entry_point.dart`
  - `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart`
  - `mobile/test/features/zodiac_shell/zodiac_shell_entry_point_test.dart`
  - `mobile/test/features/activity_cards/quick_entry_strip_test.dart`
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
  - `openZodiacShellScreen(BuildContext)` — điểm vào duy nhất của module
- Shared Interfaces Consumed:
  - `QuickEntryCell.zodiacShell` (đã tồn tại trong
    `features/activity_cards/presentation/widgets/quick_entry_strip.dart`)
  - `ZodiacShellScreen` (P3)
- Risk Surfaces:
  - Cửa vào thấy được
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §1 (dải 3 ô, nhãn, icon)
  - consumer contract: `features/activity_cards`
- Primary Inputs Summary:
  - requirements: AC-1, AC-27, AC-28, BR-3, BR-10
  - architecture: `../architecture/solution.md` §3 Key Discovery (ô và case
    snackbar đã có sẵn), §4 hàng "Cửa vào thấy được"
  - UX constraints: `../ux/uiux-spec.md` §1 — ô thứ 3, icon `auto_awesome`
    filled, nhãn "Vỏ hoàng đạo", đẩy toàn màn
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: nối cửa vào (rule 13a — story có cửa vào riêng thì cửa vào
    là phase của chính nó, không giấu trong phase UI)
  - Source/Test File Count: 4
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (Nhóm A, Nhóm H, Business Rules)
- `../ux/uiux-spec.md` §1
- `../architecture/solution.md` §3 Key Discovery
- `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart`
  quanh `_openQuickEntryCell`
- `mobile/lib/features/activity_cards/presentation/widgets/quick_entry_strip.dart`

## 3. Tasks

- Tạo `zodiac_shell_entry_point.dart` phơi ra **một** hàm
  `openZodiacShellScreen(BuildContext context)` dựng cubit của P2 và đẩy
  `ZodiacShellScreen` toàn màn. Hub không được import trực tiếp screen hay cubit.
- Trong `_openQuickEntryCell`, thay thân `case QuickEntryCell.zodiacShell:` —
  hiện đang hiện snackbar "Sắp có" — bằng lời gọi `openZodiacShellScreen`. Không
  đổi hai case còn lại, không đổi `kQuickEntryCellCount`, không đổi thứ tự ô.
- Không thêm điều kiện mở khoá nào: không kiểm tra địa điểm (R-13 **không** áp
  dụng cho story này), không kiểm tra gói trả phí (R-14), không kiểm tra tiến độ
  onboarding.
- Giữ nguyên key widget `activity_quick_entry_slot_2` và key dải
  `activity_quick_entry_strip` để test hiện có không gãy.

## 4. Acceptance Criteria

- Chạm ô thứ ba từ hub → điều hướng tới màn của story, không snackbar nào.
- Key snackbar `activity_quick_entry_coming_soon` không còn xuất hiện cho
  `QuickEntryCell.zodiacShell` (vẫn có thể còn cho ô khác nếu ô đó chưa xong).
- Ô hiển thị nhãn "Vỏ hoàng đạo" và icon `auto_awesome` filled trong mọi trạng
  thái tài khoản; không có biến thể "bị khoá".
- `activity_card_hub_view.dart` không import `ZodiacShellScreen` hay
  `ZodiacShellCubit` trực tiếp.

## 5. Planned Outputs

- Code: `mobile/lib/features/zodiac_shell/zodiac_shell_entry_point.dart`, sửa
  hub view
- Contracts: `openZodiacShellScreen`
- Evidence: `coding-plan/test-results.md`, PNG capture của dải quick-entry

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, navigation wiring
- Required levels:
  - integration: widget test chạm ô thứ ba trong hub và assert màn đích được đẩy
    (dùng `NavigatorObserver` giả hoặc route observer trong test)
  - mobile build/type-check/static-analysis: `flutter analyze lib test`, so delta
    với baseline khác 0 của repo; `flutter build apk --debug` theo `buildCommand`
    của `mobile-app`
  - visual inspection: đọc PNG dải quick-entry bằng mắt để xác nhận nhãn tiếng
    Việt hiển thị đủ dấu, không glyph tofu
- Required checks: quét `activity_card_hub_view.dart` không còn nhánh snackbar
  cho `zodiacShell`; quét import cấm trong hub
- Mobile discoverability / navigation integration: REQUIRED — đây chính là phase
  chứng minh cửa vào; test phải bắt đầu từ hub, không đẩy màn trực tiếp
- Minimum gates by risk surface:
  - Cửa vào thấy được → widget test chạm-từ-hub + test không-có-điều-kiện-khoá
- Required regression or contract coverage: chạy lại toàn bộ
  `test/features/activity_cards/` vì phase sửa hub view; kiểm `git status` trước
  khi báo hoàn tất để không để lại PNG của story khác bị suite ghi đè
- Evidence format: lệnh + kết quả trong `coding-plan/test-results.md`; PNG kèm
  đường dẫn tuyệt đối
- Per-story visual fidelity: REQUIRED
  - Design screen id + how it is rendered: giải bằng `--screen=<slug id>` trên
    canvas đã neo của REQ-016 cho màn hub; **không** truyền `--label`.
  - How the implemented screen is captured: `capture-mobile-screen.sh`; nếu
    không có thiết bị/runtime, chụp dải quick-entry bằng `RepaintBoundary` trong
    widget test của chính phase này.
- Verification strategy:
  - Targeted tests: `flutter test test/features/zodiac_shell/ test/features/activity_cards/`
  - Build/type-check: `flutter analyze lib test` rồi `flutter build apk --debug`
    (không pipe output của lệnh build)
  - Required assertion evidence: tên test điều hướng-từ-hub và kết quả build
- Runtime startup smoke: NO

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-24
