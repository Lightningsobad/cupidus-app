# Phase P4 – Ba cửa ra bắt buộc và nguồn gốc thẻ `date_script`

## 1. Objective

Màn (9) thôi là điểm dừng chân: thanh dính đáy có đủ ba cửa ra — xuất lời mời,
tạo thẻ mới, ghi vào nhật ký — mỗi cửa gọi lại đúng cơ chế đã có của STORY-002 /
STORY-001 / STORY-003, không dựng bản sao thứ hai. Thẻ sinh ra từ đây mang
`ActivityCardOrigin.dateScript`.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-three-exits-and-card-origin.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/date_script/presentation/widgets/date_script_exit_bar.dart`
  - `mobile/lib/features/date_script/presentation/screens/date_script_screen.dart`
  - `mobile/lib/features/activity_cards/domain/activity_card.dart`
  - `mobile/test/features/date_script/date_script_exits_test.dart`
  - `mobile/test/features/activity_cards/activity_card_test.dart`
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
  - `ActivityCardOrigin.dateScript` (`date_script`) —
    `../architecture/contract-summary.md` §2
- Shared Interfaces Consumed:
  - `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart`
    (`showInviteComposerSheet`)
  - `mobile/lib/features/journal/journal_entry_point.dart` (cửa ra nhật ký)
  - STORY-001 kho thẻ, chỉ qua bề mặt đã công bố
- Risk Surfaces:
  - Ba cửa ra gọi lại — `EXIT_REUSE_UNVERIFIED`
  - Ranh giới J7 — `J7_BOUNDARY_UNVERIFIED` (không cửa ra nào đặt lịch/nhắc)
  - Visual fidelity màn (9) — `VISUAL_FIDELITY_BLOCKED`
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md` §2, §5
  - consumer contract: STORY-001 hub (chỉ đọc `origin`)
- Primary Inputs Summary:
  - requirements: AC-3, AC-4, AC-13..AC-16; BR-3, BR-6, SC-2
  - architecture: `../architecture/solution.md` §3 UI Delivery Anchor, §4;
    `../architecture/contract-summary.md` §2, §5
  - upstream phase outputs: P3 (màn + cubit + entry point)
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: ba cửa ra đi ra ngoài feature + nguồn gốc thẻ + tự đóng màn
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` (các AC/BR liệt kê ở trên)
- `../architecture/contract-summary.md` §2 (giá trị `origin`), §5 (danh sách cấm)
- `mobile/lib/features/activity_cards/domain/activity_card.dart` — enum
  `ActivityCardOrigin` là **append-only** theo STORY-001 contract §2
- `mobile/lib/features/journal/journal_entry_point.dart`
- `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart`
  (`showInviteComposerSheet`)

## 3. Tasks

- `activity_card.dart`: **thêm** `dateScript('date_script')` vào cuối
  `ActivityCardOrigin`. Không đổi thứ tự, không đổi `wireValue` nào đang có,
  không sửa `fromWireValue`.
- `date_script_exit_bar.dart`: thanh dính đáy, ba nút viền, không nút nào là
  hành động chính thứ hai của thẻ. Nhãn nút là nhãn chức năng widget, không phải
  nội dung gói.
  - "Xuất lời mời" → `showInviteComposerSheet(context, card, ...)`, y nguyên cơ
    chế STORY-002. Không dựng composer thứ hai.
  - "Tạo thẻ mới" → form tạo thẻ có sẵn của STORY-001, với
    `origin: ActivityCardOrigin.dateScript`.
  - "Ghi vào nhật ký" → `openJournalComposer(...)` mang ngữ cảnh thẻ (AC-4).
    Mục nhật ký được tạo/mở ở màn (4), không phải bản sao trong feature này.
- `date_script_screen.dart`: lắp thanh cửa ra vào chỗ P3 đã chừa; sau khi một
  cửa ra hoàn tất, màn (9) tự đóng để người dùng về đúng ngữ cảnh nguồn (BR-6).
  Cửa ra bị huỷ giữa chừng → ở lại màn (9), không mất trạng thái đoạn đang xem.
- Không cửa ra nào tạo lịch, nhắc nhở, thông báo, hay bất cứ thứ gì kích hoạt
  trong khoảng thời gian buổi hẹn (BR-3).
- Không share, không copy-link trên màn này.
- Hai file test theo `## 6`.

## 4. Acceptance Criteria

- Màn (9) có đủ **ba** cửa ra, đọc được, bấm được (AC-3 / SC-2).
- "Ghi vào nhật ký" → một mục nhật ký được tạo/mở ở màn (4) mang ngữ cảnh của
  thẻ (AC-4).
- "Xuất lời mời" mở đúng composer của STORY-002, không phải bản dựng lại.
- "Tạo thẻ mới" sinh thẻ có `origin.wireValue == 'date_script'`.
- Cửa ra hoàn tất → màn (9) đóng (BR-6). Cửa ra bị huỷ → ở lại, giữ đoạn đang xem.
- `ActivityCardOrigin.fromWireValue('date_script')` trả đúng giá trị mới; mọi
  `wireValue` cũ vẫn giải mã đúng như trước.
- Không thông báo, không lịch, không timer phát sinh từ bất kỳ cửa ra nào
  (AC-13..AC-16).
- Không nút share / copy-link trên màn (9).

## 5. Planned Outputs

- Code: `mobile/lib/features/date_script/presentation/widgets/date_script_exit_bar.dart`,
  phần lắp vào `date_script_screen.dart`, một giá trị enum thêm vào
  `activity_card.dart`
- Contracts: `../architecture/contract-summary.md` §2 được hiện thực hoá
- Notes: bằng chứng test + ảnh chụp ghi vào `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, widget test
- Required levels:
  - widget: `date_script_exits_test.dart`
  - unit: `activity_card_test.dart` (vòng tròn `origin`)
  - mobile build/type-check/static-analysis:
    `flutter analyze lib/features/date_script lib/features/activity_cards
    test/features/date_script test/features/activity_cards`
- Required checks:
  - Ba cửa ra, mỗi cửa một test, dùng seam tiêm được (fake presenter/opener) để
    assert **đúng hàm có sẵn** được gọi với đúng thẻ. Đây là thứ bắt được việc
    ai đó dựng lại composer riêng.
  - `origin` vòng tròn: mọi giá trị `ActivityCardOrigin` qua
    `wireValue` → `fromWireValue` → chính nó, gồm cả giá trị mới.
  - Tự đóng màn: sau khi cửa ra trả về thành công, assert màn (9) không còn
    trong cây; sau khi huỷ, assert vẫn còn và đoạn đang xem không đổi.
  - Quét source `lib/features/date_script/**` không có `Share`, `Clipboard`,
    hay literal liên quan tới copy-link.
  - Frame test đủ cao trước khi `tap` thanh dính đáy; mặc định 800x600 không đủ
    khi có cả header, điều khiển ba đoạn, và ô hỏi tại chỗ.
- Minimum gates by risk surface:
  - Ba cửa ra gọi lại → ba test seam xanh
  - Ranh giới J7 → quét source không phát sinh lịch/nhắc/timer từ cửa ra
- Required regression or contract coverage: chạy lại **cả**
  `flutter test test/features/activity_cards/` vì `activity_card.dart` bị sửa,
  và `flutter test test/features/date_script/` cho toàn story.
- Evidence format: lệnh + tóm tắt pass/fail ghi vào `coding-plan/test-results.md`
- Per-story visual fidelity (REQUIRED — phase này dựng UI):
  - Design screen id + cách render: phân giải và khoá `design_source` theo
    `contracts/design-fidelity-spec.md` "Design source detection and locking".
    Nếu sau khi phân giải vẫn không có design source, ghi
    `DESIGN_SOURCE_NOT_DETECTED` kèm bằng chứng đã thử, đừng bỏ trống.
  - Cách chụp màn đã hiện thực: màn (9) không có tên route (BR-1a), nên chụp
    bằng `RepaintBoundary` trong `date_script_exits_test.dart`: một ảnh màn (9)
    đầy đủ có thanh ba cửa ra dính đáy, thấy rõ cả ba nhãn nút.
  - Harness phải bọc `CupidAppBackground` và nạp MaterialIcons của framework.
    Mắt phải nhìn ảnh: kiểm chữ tiếng Việt có dấu trên nhãn nút không ra ô tofu.
  - NOTE: đây là cổng riêng của story, kiểm ở review của chính nó. Không được
    hoãn sang audit cấp requirement. Nếu không chụp được, phase chặn với
    `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests: `flutter test test/features/date_script/ test/features/activity_cards/`
  - Build/type-check: lệnh `flutter analyze` phạm vi hẹp ở trên
  - Required assertion evidence: ba test seam chứng minh cửa ra gọi hàm có sẵn,
    không phải bản dựng lại trong feature.

## 7. Status

- Status: TODO
- Last updated: 2026-09-11
- Evidence: (chưa có)
