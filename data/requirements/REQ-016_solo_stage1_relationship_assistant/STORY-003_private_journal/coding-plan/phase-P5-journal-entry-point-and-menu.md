# Phase P5 – Điểm nhận + hàng menu vào màn

## 1. Objective

Làm cho nhật ký **tới được** từ tab "Tôi" và công bố đúng một bề mặt công khai
`openJournalComposer` cho STORY-007/008 gọi sau này — một bề mặt một chiều, chỉ
ghi, không đọc ngược.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-journal-entry-point-and-menu.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3, P4
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/journal/journal_entry_point.dart`
  - `mobile/lib/features/account/presentation/screens/me_screen.dart`
  - `mobile/lib/l10n/arb/app_vi.arb`
  - `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/test/features/journal/journal_entry_point_test.dart`
  - `mobile/test/features/account/me_screen_journal_row_test.dart`
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
  - `openJournalComposer` + `JournalComposerSeed` — hợp đồng cho STORY-007/008
- Shared Interfaces Consumed:
  - `JournalScreen` (P3), `JournalComposerScreen` (P4)
- Risk Surfaces:
  - Tranh chấp `me_screen.dart` trong wave song song
  - Rò rỉ nội dung ra ngoài (chia sẻ/xuất/mạng/AI)
- Source Of Truth:
  - authoritative artifact or convention:
    `../architecture/contract-summary.md` (toàn bộ)
  - consumer contract: STORY-007, STORY-008 (ngoài story này)
- Primary Inputs Summary:
  - requirements: AC-7, AC-15, AC-16, AC-17, BR-5, BR-6
  - architecture: `../architecture/contract-summary.md` section 1-3 và 5
  - UX constraints: `../ux/uiux-spec.md` mục 1 (vị trí trong shell, khối card
    "Kho riêng của tôi"), mục 6 (điểm nhận), mục 8 (ranh giới với Sổ tay)
  - upstream phase outputs: `JournalScreen` (P3), `JournalComposerScreen` (P4)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: bề mặt tiếp xúc với phần còn lại của app
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../architecture/contract-summary.md` (toàn bộ — file nhỏ và là nguồn chuẩn)
- `../ux/uiux-spec.md` mục 1, 6, 8
- `mobile/lib/features/account/presentation/screens/me_screen.dart`

## 3. Tasks

- `journal_entry_point.dart` export **đúng hai** thứ công khai:
  `openJournalComposer(context, {seed})` và `JournalComposerSeed`, đúng chữ ký ở
  `../architecture/contract-summary.md` section 1. Trả `id` mục vừa tạo, hoặc
  `null` khi người dùng huỷ.
- File này cũng là nơi duy nhất mở `JournalScreen` từ ngoài feature.
- **Không** export `JournalDao`, `JournalRepository`, `JournalMediaStore`, cubit,
  hay widget nội bộ. **Không** thêm hàm đọc/đếm/tìm kiếm/xem trước mục nhật ký
  cho lane gọi — hợp đồng là một chiều (AC-7).
- Đường dẫn ảnh mồi không đọc được thì bỏ qua ảnh đó và vẫn mở màn soạn; không
  ném exception ra phía caller.
- Trong `me_screen.dart`: thêm **đúng một** `_MenuRow` "Nhật ký riêng" (icon
  sách/line variant) mở `JournalScreen`. Nếu khối card "Kho riêng của tôi" chưa
  tồn tại thì tạo khối card mới đó; nếu đã tồn tại thì chỉ **thêm** hàng vào
  cuối. Không sửa, không đổi thứ tự, không xoá hàng nào có sẵn — STORY-004 sẽ
  thêm hai hàng khác vào cùng khối.
- Không thêm route ở tab khác, không thêm tab, không tab con chuyển đổi giữa
  Nhật ký và Sổ tay (AC-17).
- Thêm chuỗi nhãn hàng menu vào cả hai file ARB.

## 4. Acceptance Criteria

- Từ tab "Tôi", chạm hàng "Nhật ký riêng" mở màn nhật ký full-screen.
- `openJournalComposer` với `seed` có chữ và ảnh mở màn soạn đã điền sẵn; thoát
  không lưu thì không mục nào được tạo; lưu thì trả về `id` mục mới.
- Ảnh mồi tồn tại thành bản sao của nhật ký; xoá file nguồn của caller không
  ảnh hưởng mục nhật ký.
- Không file nào ngoài `mobile/lib/features/journal/**` và
  `mobile/lib/core/journal/**` import symbol nội bộ của nhật ký; điểm chạm duy
  nhất là `journal_entry_point.dart`.
- Diff của `me_screen.dart` chỉ gồm phần thêm.

## 5. Planned Outputs

- Code directories or files: các file trong Write Scope
- Contracts or schemas: `openJournalComposer`, `JournalComposerSeed`
- Notes or evidence: ảnh chụp tab "Tôi" có hàng menu mới, trong `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (widget test)
- Required levels:
  - unit: `journal_entry_point_test.dart` — mở với seed rỗng / có chữ / có ảnh;
    huỷ trả `null`; lưu trả `id`; đường dẫn ảnh hỏng bị bỏ qua không ném lỗi
  - integration: `me_screen_journal_row_test.dart` — hàng "Nhật ký riêng" hiện
    ra và điều hướng tới `JournalScreen`
  - mobile build/type-check/static-analysis: analyze giới hạn `lib test`
  - visual inspection: ảnh chụp tab "Tôi" cho thấy hàng menu mới
- Required checks:
  - grep toàn `mobile/lib` xác nhận không file nào ngoài feature import symbol
    nội bộ của nhật ký (đây là cách AC-7 nghiệm thu được)
  - grep `journal_entry_point.dart` xác nhận không có hàm đọc ngược
    (list/count/search/preview)
- Mobile discoverability / navigation integration: REQUIRED — hàng menu ở tab
  "Tôi" là bề mặt khám phá được duy nhất; màn không được chỉ tới được bằng
  push trực tiếp trong code.
- Minimum gates by risk surface: `PRIVACY_EGRESS_GATE_UNRUNNABLE`,
  `MERGE_CONTENTION_UNRESOLVED` (theo `../architecture/solution.md` section 4)
- Evidence format: lệnh + kết quả + đường dẫn ảnh chụp trong `test-results.md`
- Per-story visual fidelity: REQUIRED
  - Design screen id + how it is rendered: chạy bước dò design source cho tab
    "Tôi" (màn có sẵn, có thể có khung đối chiếu) và ghi lại kết quả thật.
  - How the implemented screen is captured: `capture-mobile-screen.sh` cho tab
    "Tôi" sau khi thêm hàng menu.
  - NOTE: cổng riêng của story, kiểm ở review của story này, không hoãn sang
    audit mức requirement. Không chạm được thiết bị/runtime thì chặn với
    `MOBILE_RUNTIME_UNAVAILABLE`.
- Required regression or contract coverage: chạy lại test của P3 và P4 sau khi
  nối CTA "Viết điều gì đó" của màn danh sách vào màn soạn.
- Verification strategy:
  - Targeted tests: hai file test của phase này + test của P3, P4
  - Build/type-check/lint command when required: analyze phạm vi `lib test` sau
    khi sinh l10n

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-07
