# Phase P6 – J13: cổng quay lại, màn quay lại, và nút xoá sạch

## 1. Objective

Dựng màn quay lại sau vắng cùng cổng quyết định hiện nó, và đặt nút xoá sạch ngay
trên màn đó. Ràng buộc quyết định kiến trúc của phase: `ReturnGateResolver` chỉ
trả `bool` — UI không có đường nào lấy được số đo khoảng vắng để vẽ, nên AC-20
được thi hành ở tầng kiểu chứ không ở tầng rà soát chữ.

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-return-gate-and-screen.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/chapter_closure/domain/return_gate_resolver.dart`
  - `mobile/lib/features/chapter_closure/data/stage1_last_opened_store.dart`
  - `mobile/lib/features/chapter_closure/presentation/screens/return_screen.dart`
  - `mobile/lib/features/chapter_closure/presentation/widgets/wipe_confirm_dialog.dart`
  - `mobile/lib/features/auth/presentation/screens/splash_screen.dart`
  - `mobile/test/features/chapter_closure/return_gate_resolver_test.dart`
  - `mobile/test/features/chapter_closure/return_screen_test.dart`
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
  - `kReturnAbsenceThreshold`, `req016.last_opened_at`
    (`../architecture/contract-summary.md` §2)
- Shared Interfaces Consumed:
  - `Stage1WipeService.wipeAll()` (P3)
- Risk Surfaces:
  - Màn J13 trở thành cổng chặn
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §4
    `Contracts And Integrations`; `mobile/lib/features/before_you_go/data/before_you_go_dismissal_store.dart`
    là tiền lệ cho store `SharedPreferences` tiêm được
  - consumer contract: `../architecture/contract-summary.md` §2, §6
- Primary Inputs Summary:
  - requirements: AC-18..AC-32
  - architecture: `../architecture/solution.md` §3 `UI Delivery Anchor`, §4
  - OQ constraints: none
  - upstream phase outputs: P3 — `Stage1WipeService.wipeAll()`
  - UX constraints, if truly required: `../ux/uiux-spec.md` §2 (chữ hộp thoại xoá
    sạch là yêu cầu đo được)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: cổng quay lại + màn quay lại + xoá sạch tại chỗ
  - Source/Test File Count: 7
  - Split Required: NO
  - Split Rationale: khoảng sáu file; `return_gate_resolver.dart` và
    `stage1_last_opened_store.dart` mỗi cái vài chục dòng và chỉ có ý nghĩa cùng
    màn mà chúng điều khiển, `splash_screen.dart` là một nhánh `switch` thêm vào

## 2. Required Reads

- `../requirements/requirements.md` (AC-18..AC-32)
- `../ux/uiux-spec.md` §2
- `../architecture/solution.md` §3, §4
- `mobile/lib/features/auth/presentation/screens/splash_screen.dart`
- `mobile/lib/core/navigation/pair_gate_shell.dart`
- `mobile/lib/features/before_you_go/data/before_you_go_dismissal_store.dart`
- P3 outputs

## 3. Tasks

- Viết `Stage1LastOpenedStore` đọc/ghi đúng một khoá `req016.last_opened_at`
  (epoch ms) qua `SharedPreferences` sau một accessor tiêm được. Không khoá thứ
  hai nào đếm lần mở app hay lưu lịch sử vắng (BR-7).
- Viết `ReturnGateResolver.shouldShow()` trả **`bool`**, so sánh hiện tại với mốc
  đã lưu qua **một** hằng số `kReturnAbsenceThreshold = Duration(days: 30)`.
  Không nhiều bậc ngưỡng, không leo thang, không hàm public nào trả `Duration`,
  `DateTime`, hay số ngày (AC-19, AC-20).
- Điều kiện kích hoạt **chỉ** là sự vắng mặt của chính người dùng — không bao giờ
  là việc người kia không trả lời, không bao giờ là trạng thái của một thẻ
  (AC-23). Resolver không được nhận dữ liệu thẻ làm đầu vào.
- Cắm nhánh vào `splash_screen._tryNavigate`: khi phiên đã xác thực và
  `shouldShow()` là `true`, `pushReplacement` sang `ReturnScreen`; ngược lại giữ
  nguyên đường hiện tại. Ghi mốc mở app mới ngay khi quyết định xong, để màn chỉ
  hiện **một lần** (AC-18, AC-24).
- Dựng `ReturnScreen`: lời chào không nhắc gì tới sự vắng mặt (AC-21); một tập
  lựa chọn cố định, tất định, dựng từ tài sản sống sót — mở kho thẻ, mở hồ sơ kỹ
  năng/sổ tay, bắt đầu một việc mới — không lựa chọn nào được chấm điểm, xếp
  hạng, hay gắn nhãn "nên làm trước" (AC-22).
- Mọi lối ra, kể cả nút đóng X, đều `pushReplacement` sang một màn dùng được;
  màn không được là cổng chặn (AC-24, AC-30).
- Dựng `wipe_confirm_dialog.dart` theo kiểu `delete_card_dialog.dart`: nút xoá
  sạch nằm ngay trên `ReturnScreen`, cách **một** thao tác (AC-25). Hộp thoại nêu
  phạm vi bị xoá và tính không hoàn tác dưới dạng dữ kiện, không can ngăn, không
  gợi cảm giác mất mát, không đề nghị giữ lại, không hỏi lý do (AC-28).
- Xác nhận một lần → `Stage1WipeService.wipeAll()` → điều hướng thẳng về trạng
  thái rỗng lần đầu của màn (1). Không màn tiễn biệt (AC-26, AC-29).

## 4. Acceptance Criteria

- Không có API public nào trong phase trả về số ngày vắng, `Duration`, hay mốc mở
  app trước đó; grep toàn bộ chữ hiển thị của `ReturnScreen` không có số đếm thời
  gian, nhãn "cũ"/"bỏ quên", huy hiệu mất, hay trạng thái mờ (AC-20).
- Lời chào không chứa bất kỳ cách nhắc nào tới sự vắng mặt (AC-21).
- Bốn lối ra (ba lựa chọn + nút X) mỗi lối dẫn tới một màn dùng được, và sau khi
  chọn, màn không hiện lại trong cùng phiên (AC-24).
- Dưới ngưỡng vắng, màn **không** hiện; trên ngưỡng, hiện **đúng một lần**
  (AC-18).
- Resolver cho cùng kết quả bất kể trạng thái thẻ hay việc người kia có trả lời
  hay không (AC-23).
- Xoá sạch: một lần xác nhận → mọi bảng trong `Stage1WipeRegistry` rỗng, media
  root biến mất, và app về trạng thái rỗng dùng được ngay, người dùng vẫn đăng
  nhập (AC-26, AC-27, AC-29).
- Không tài sản nào bị suy giảm, hết hạn, hay dọn tự động vì lý do thời gian
  (AC-31).
- Toàn bộ màn dùng được và không ngõ cụt kể cả khi người kia chưa bao giờ tham
  gia (AC-32).

## 5. Planned Outputs

- Code directories or files: `return_gate_resolver.dart`,
  `stage1_last_opened_store.dart`, `return_screen.dart`,
  `wipe_confirm_dialog.dart`, sửa `splash_screen.dart`
- Contracts or schemas: `kReturnAbsenceThreshold`, `req016.last_opened_at`
  (`../architecture/contract-summary.md` §2)
- Requirement configuration guide updates: none
- Notes or evidence: `coding-plan/test-results.md`, PNG visual fidelity

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (Flutter, `mobile/`)
- Required levels:
  - unit: resolver — dưới ngưỡng, trên ngưỡng, chưa có mốc nào, và bất biến với
    trạng thái thẻ
  - integration: widget test `ReturnScreen` bốn lối ra cộng lối X; luồng xoá sạch
    tới `wipeAll()` và điều hướng về trạng thái rỗng
  - mobile build/type-check/static-analysis: có
  - visual inspection: có
- Required checks:
  - test chữ cấm: quét mọi `Text` của `ReturnScreen` và hộp thoại, fail nếu khớp
    danh sách cấm ở AC-20/AC-21/AC-28
  - test kiểu: `ReturnGateResolver` không phơi thành viên public nào có kiểu trả
    về `Duration`/`DateTime`/`int` ngày
  - `flutter analyze lib test` không sinh error mới
- Mobile discoverability / navigation integration: `ReturnScreen` phải tới được
  qua `splash_screen` trong widget test, không chỉ dựng trực tiếp
- Minimum gates by risk surface:
  - Màn J13 trở thành cổng chặn → widget test bốn lối ra cộng lối X phải chạy và
    xanh; không đạt thì BLOCKER
- Required regression or contract coverage: test hiện có của `splash_screen`
  (mọi nhánh `SessionGate`) và của `PairGateShell` phải còn xanh khi
  `shouldShow()` là `false`
- Evidence format: `coding-plan/test-results.md` cộng hai PNG (design, implemented)
- Per-story visual fidelity: REQUIRED
  - Design screen id + how it is rendered: khung SB-100 (J13) trên canvas
    `cupid-ch-ng-1`. Liệt kê khung bằng
    `.ai-team-bundle/runtime/tools/render-design-canvas.js` để lấy id chính xác,
    rồi `capture-mobile-screen.sh --mode=design --screen=<id>`. Nếu canvas không
    có khung cho màn này, ghi `NOT_APPLICABLE — <lý do>` kèm danh sách khung làm
    bằng chứng.
  - How the implemented screen is captured:
    `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh` trên thiết bị. Màn
    chỉ hiện khi mốc mở app vượt ngưỡng, nên hoặc seed
    `req016.last_opened_at` cũ rồi khởi động app, hoặc dùng fallback đã có tiền lệ
    trong REQ-016: chụp `RepaintBoundary` trong widget test của chính phase này.
  - NOTE: đây là cổng của chính story, xét ở review của story. Không bao giờ được
    thoả bằng, hay hoãn sang, đợt audit cấp requirement. Không có thiết bị hay
    runtime nào tới được thì phase chặn ở `MOBILE_RUNTIME_UNAVAILABLE` /
    `VISUAL_RUNTIME_UNAVAILABLE` — blocker, không phải deferral.
  - Cả hai PNG phải được nhìn bằng mắt trước khi kết luận (kiểm ô tofu ở lời chào
    và nhãn ba lựa chọn).
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/chapter_closure/ test/features/auth/`
  - Build/type-check/lint command when required: `flutter build apk --debug`
  - Required assertion evidence: chuỗi thực tế của lời chào và ba lựa chọn; màn
    đích sau mỗi lối ra; số hàng từng bảng sau `wipeAll()`

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
