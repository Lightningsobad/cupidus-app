# Review Report — STORY-013 Lối ra (J11) và lối quay lại (J13)

- Review mode: compact story review
- Reviewer: Iris-QC
- Ngày: 2026-09-17
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-013_graceful_exit_and_return`
- BaseHead: `b58afbe073eff4e1ebb9151735221532a9cf5a82` → HEAD `241b936d`
- Worktree sạch (`git status --porcelain` rỗng)

## Scope Gate

- Lane: mobile-only (Flutter, `mobile/`). Không có diff backend/web/devops — khớp
  `story_master.md` "Implementation Lane: mobile".
- Diff: 66 tệp. Nguồn `lib/` chạm 6 khu vực (`core/database`, `core/di`,
  `features/chapter_closure`, `features/activity_cards`, `features/context_notebook`,
  `features/auth/.../splash_screen.dart`) — nằm đúng trong phạm vi P1..P6 của
  `coding-plan/master-plan.md`.
- Không đổi hợp đồng của STORY-001/004: không cột `closed_at`/`archived` mới trên
  bảng thẻ, không giá trị thứ năm cho `ActivityCardStatus` (BR-3, BR-4,
  `contract-summary.md` §6) — xác nhận qua P2 mục 6 và qua diff không chạm
  `activity_cards_table.dart`.
- Tệp đọc trong review này: `story_master.md`, `requirements/requirements.md`
  (AC + BR + OQ), `coding-plan/master-plan.md`, `phase-P6` §4-§7,
  `coding-plan/test-results.md` (các mục AC coverage + visual fidelity),
  `architecture/contract-summary.md` §2/§4/§6, `ux/uiux-spec.md` §6,
  `stage1_wipe_registry.dart`, `stage1_last_opened_store.dart`, `return_screen.dart`.

## Kiểm tra quyết định OQ

- **OQ-3 / R-15 (kho nội dung preset)** — requirements §"Scope Items BLOCKED"
  khẳng định story không ship gói preset nào; chữ hiển thị là chuỗi giao diện cố
  định. Hiện thực tuân thủ: lời chào J13, ba nhãn lựa chọn, và chữ hai hộp thoại
  đều là hằng chuỗi trong code, không có nguồn nội dung xoay vòng. ĐẠT.
- **L45 / OQ-18 (chặng 1 là kho tài sản)** — được **thi hành** chứ không chỉ tuyên
  bố: AC-8 có test `hồ sơ kỹ năng không bao giờ là thành viên` /
  `không bao giờ bị lọc` (P2), và P3 có `hồ sơ kỹ năng và nhật ký riêng không bao
  giờ bị purge chạm vào`. ĐẠT.
- **Ngưỡng vắng một hằng số (BR-7)** — `kReturnAbsenceThreshold = 30 ngày`, test
  `exactly one absence threshold constant exists, at 30 days`, và
  `Stage1LastOpenedStore` ghi đúng một khoá, không phơi `Duration`/`DateTime`/`int`.
  ĐẠT.
- **BR-6 (nhật ký riêng không bị đóng)** — P4 mục 4 ghi rõ khung thiết kế vẽ nhật
  ký ở phía "sẽ đóng"; hiện thực đặt nó ở phía "giữ lại" vì BR-6 cấm. Quyết định
  đúng hướng: AC thắng khung vẽ. ĐẠT.

## Bề mặt rủi ro và cổng tới hạn

| Bề mặt rủi ro (`master-plan.md` §3A) | Cổng tới hạn | Kết quả |
|---|---|---|
| Phân loại gắn người sai → mất tài sản (P2) | `chapter_closure_service_test.dart` — vị từ chỉ tín hiệu dương tính + 2 ca biên + ca không dứt khoát giữ lại (AC-6/AC-7/AC-10) | PASS |
| Rò rỉ vật liệu đã đóng ra luồng thường ngày (P2/P5) | duyệt cả 5 ô, `countsByStatus`, `watchCardsByStatus`, `closedCardsCalls == 0` (AC-11) | PASS |
| Phân trang sai do lọc sau khi đọc (P2) | `excludes closed ids inside SQL, so LIMIT still fills the page` + bảng số hàng từng trang | PASS |
| Dư lượng sau xoá sạch (P3) | số hàng trước/sau `wipeAll()`, `existsSync()` gốc media, khoá prefs | **FAIL — xem F1** |
| Cột cấm lọt vào schema (P1) | `chapter_closure_migration_test.dart` → `cột bị cấm vĩnh viễn` (AC-5/BR-9) | PASS |
| Màn J13 trở thành cổng chặn (P6) | bốn lối ra + X, `the screen cannot be popped back to`, `markOpenedCalls == 1` (AC-24) | PASS |
| Migration phá dữ liệu người dùng (P1) | `v6 -> v7` 4 test có số hàng trước/sau và kiểm nội dung | PASS |

## Bằng chứng build / phân tích tĩnh / test

- Build: `flutter build apk --debug --flavor local` exit 0 ở cả P1, P2, P3, P4, P5, P6.
  Lệch khỏi chữ `flutter build apk --debug` trong phase file được ghi lý do (dự án
  bắt buộc flavor) — chấp nhận.
- Analyze: phạm vi thu hẹp theo phase — `0 error, 0 warning mới` ở cả sáu phase;
  `flutter analyze lib test` ở P6 cho `241 issues, 0 error`. Khớp nền đã biết của
  repo (analyze không bao giờ exit 0). Hai `info` mới của P6 được ghi và giải trình.
- Test: các lần chạy nhóm đều xanh (`+438 ~6`, `+292 ~4`, `+227 ~2`, `+114 ~4`).
- Bốn lỗi ở lệnh 3 của P6 (`test/features/auth/`) được **đo** là lỗi nền bằng A/B
  `git stash` trên cùng worktree: `110 passed, 4 failed` ở cả hai lần, và cả bốn
  nằm trong `welcome_screen`/`auth_repository` — không tệp nào trong diff story.
  Chấp nhận là nền, không phải hồi quy của story.
- `shared_backdrop_occlusion_test.dart:565` là lỗi nền đã ghi nhất quán ở P1..P5
  với ba bằng chứng loại trừ liên quan tới bump `schemaVersion`. Ngoài scope.

## Visual fidelity theo story

| Màn | Neo thiết kế | Ảnh hiện thực | Kết quả |
|---|---|---|---|
| J11 đóng ngăn (P4) | `design-reference-j11-dong-ngan-gon-gang-ios.png` (`j11-dong-ngan-gon-gang`) | `implemented-j11-dong-ngan-gon-gang-ios.png` | PASS, 1 lệch có chủ ý (dialog thay vì màn full, chân trang "mở lại" bị AC-16 cấm) |
| Kho đã đóng (P5) | `design-reference-kho-da-dong-ios.png` (`ngan-da-hen-ngay-dang-doi`) | `implemented-kho-da-dong-ios.png` | PASS, 2 lệch có chủ ý (không app bar theo AC-22/D-3; dải lọc đã cuộn) |
| J13 quay lại (P6) | `design-reference-j13-quay-lai-sau-3-thang-ios.png` (`j13-quay-lai-sau-3-thang`) | `implemented-j13-man-quay-lai-ios.png` | PASS, 5 lệch có chủ ý, tất cả do AC-20/AC-21/AC-22 ép |
| P1, P2, P3 | — | — | NOT_APPLICABLE có lý do (không dựng/đổi màn nào) |

Cả ba cặp ảnh được ghi là đã nhìn tận mắt, có kiểm ô tofu trên chuỗi tiếng Việt cụ
thể, và id khung được liệt kê thật bằng `render-design-canvas.js` (P6 sửa lại id
đoán sai "SB-100" thành `j13-quay-lai-sau-3-thang`; P5 liệt kê đủ 29 khung để
chứng minh không có khung riêng cho kho đã đóng). Đây là bằng chứng đúng chuẩn.

## Findings

### F1 — PATCH_REQUIRED: `req016.last_opened_at` chưa nằm trong `Stage1WipeRegistry.preferenceKeys` (AC-27)

- Tệp: `mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart:150-152`
  (`preferenceKeys` chỉ có `'before_you_go.dismissed_on.'`).
- Khoá `'req016.last_opened_at'` do chính story này tạo ở P6
  (`stage1_last_opened_store.dart:13`) và được liệt kê trong
  `architecture/contract-summary.md` §2 là định danh của REQ-016.
- `contract-summary.md` §4 nói thẳng: "Story tạo bảng/thư mục/khoá mới **phải**
  thêm nó vào đúng danh sách trên **trong cùng story**. Bỏ sót không làm hỏng
  build; nó để lại dư lượng và **fail AC-27 ở review**."
- P3 đã cảnh báo trước và giao việc: `test-results.md` mục "Quan sát để Reviewer
  đọc trước" #3 — "Khoá đó do P6 tạo... **P6 phải thêm nó vào registry khi tạo**".
  P6 mục 7 từ chối với lý do write scope của phase.
- Lý do write scope là lý do cấp phase, không phải cấp story: `stage1_wipe_registry.dart`
  do chính story này tạo ra ở P3. Lập luận giảm nhẹ của P6 (splash làm mới mốc ngay
  trong cùng lần chạy nên J13 không hiện lại) đúng về hành vi, nhưng AC-27 nói về
  **dư lượng trên thiết bị**, không nói về hành vi màn hình.
- Tripwire parity chỉ đối chiếu `tables` với `CupidDatabase.allTables`, nên nó
  không thể bắt được thiếu sót ở `preferenceKeys` — đó là lý do nó lọt xanh.
- Sửa tối thiểu: thêm `'req016.last_opened_at'` vào `preferenceKeys`, và thêm một
  khẳng định trong `stage1_wipe_service_test.dart` rằng khoá này không còn sau
  `wipeAll()` (nhóm test `khoá tuỳ chọn của REQ-016 bị xoá...` đã có sẵn chỗ đặt).

### F2 — DEFERRED: ba lựa chọn J13 cùng đổ về `PairGateShell`, không về ba đích của UX spec

- Tệp: `mobile/lib/features/chapter_closure/presentation/screens/return_screen.dart:67-78`
  (`_leave()` luôn `pushReplacement` sang `PairGateShell`).
- `ux/uiux-spec.md` §6 quy định ba đích riêng: "Xem kho ý tưởng" → Tab Nhà đoạn
  "Mới nghĩ ra"; "Xem sổ tay & kỹ năng" → Tab Tôi → menu tương ứng; "Bắt đầu một
  việc mới" → luồng tạo thẻ 1 chạm.
- **Không chặn** vì chữ AC-22 chỉ buộc "mỗi lựa chọn dẫn thẳng tới một màn dùng
  được", và điều đó đạt; `phase-P6 §3` đã gộp ba đích thành "một màn dùng được"
  trước khi thi công, và P6 đo trước khi quyết (`AppShell` không có seam chọn tab
  ban đầu, `HomeScreen` không có seam chọn ô ban đầu). Hai seam đó nằm ngoài story.
- Rủi ro tồn dư: hai trong ba nhãn hứa một đích mà màn không đưa tới. Khuyến nghị
  mở một mục backlog thêm seam tab/pane ban đầu rồi nối lại ba đích.

### F3 — DEFERRED: AC-13, AC-27, AC-31, AC-32 không có dòng nào trong bảng AC coverage

- Không mục AC coverage nào của P1..P6 nhắc bốn AC này (đã kiểm bằng grep toàn
  `test-results.md`).
- AC-27 về bản chất **đã** có bằng chứng ở P3 mục 3/4 (số hàng trước/sau, `existsSync()`
  gốc media, khoá prefs) nhưng bị gắn nhãn AC-14; sau khi F1 được sửa, chỉ cần gắn
  lại đúng nhãn AC-27.
- AC-13 (không thông báo/nội dung tưởng niệm theo mốc thời gian): story không thêm
  đường sinh thông báo nào, và `features/reminders` / `features/in_app_notifications`
  hiện có đều là bề mặt chế độ đã ghép đôi, không tiêu thụ vật liệu chặng 1 — nên
  nhiều khả năng đạt một cách hiển nhiên. Vẫn cần một dòng coverage: hoặc một
  khẳng định phủ định, hoặc `NOT_APPLICABLE` kèm lý do.
- AC-31 và AC-32 là AC phủ định cấp story; cần một dòng lý giải, không cần test mới.

## Residual risks

- `hasAnyClosure()` không lọc theo chủ sở hữu (P3 quan sát #1): trên máy dùng chung
  nhiều tài khoản, ô "Đã đóng" có thể lộ ra cho tài khoản thứ hai. Đã có test ghi
  lại ngữ cảnh đó. Đổi hợp đồng §3 — ngoài story này, để lại làm rủi ro đã biết.
- `activity_card_photos.localPath` không xoá tệp (P3 quan sát #4): đúng quyết định
  hiện tại vì app chưa từng sao chép ảnh đó vào thư mục riêng; phải đăng ký
  `mediaRoots` ngay khi có luồng sao chép.

## Recommendation

Sửa F1 (một dòng trong `preferenceKeys` + một khẳng định test), gắn lại nhãn AC-27
cho bằng chứng P3 đã có, rồi quay lại cổng review. F2 và F3 (phần AC-13/AC-31/AC-32)
ghi nhận làm việc tiếp theo, không chặn.

Outcome: PATCH_REQUIRED
