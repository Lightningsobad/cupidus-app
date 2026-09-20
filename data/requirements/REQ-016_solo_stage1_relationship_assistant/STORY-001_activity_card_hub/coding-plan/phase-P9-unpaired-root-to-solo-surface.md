# P9 — Cổng gốc phiên chưa ghép đôi vào bề mặt solo

Spec nguồn: `coding-plan/master-plan.md` §8 (§8.1-§8.11).
Commit: `cfde25c` (đổi nhánh + dọn seam + 2 file test điều hướng) và
`93ff105` (giải quyết xung đột test AC4 theo phán quyết §8.11).

## Vấn đề (§8.1)

Nhánh `PairGateUnpaired()` trong `_AppShellView.build` của
`mobile/lib/core/navigation/pair_gate_shell.dart` trả `PairingChoiceScreen`.
Đó là màn cuối đường cho phiên chưa ghép đôi, nên `HomeScreen` không bao giờ
được dựng và toàn bộ nhánh solo P4 (`_SoloStageOneShell` → `ActivityCardHubView`)
là mã sống nhưng **không tới được** trong bản dựng thật. Widget test không bắt
được vì chúng dựng `HomeScreen` trực tiếp.

## Phương án đã chọn (§8.2, §8.3)

Định tuyến phiên chưa ghép đôi vào hub solo thay vì pairing stack. Đây là thi
hành ba nguồn đã chốt sẵn, không phải quyết định sản phẩm mới: cổng cứng của
`req_master.md` (chặng 1 phải dùng được trọn vẹn khi người kia không tham gia),
`story_master.md` → `## System Integration And Discoverability`, và
`ux/uiux-spec.md` §1 (thanh tab áp cho nhánh solo, gồm cả phiên chưa từng ghép).

P9 **không** xoá cửa vào ghép đôi nào (§8.3): `core/navigation/onboarding_chain.dart`
vẫn map `OnboardingNode.profileSetup → OnboardingNode.pairingChoice`, nên
`PairingChoiceScreen` giữ nguyên vai trò của nó. Nhánh unpaired của
`PairGateShell` chỉ là bức tường thứ hai mà phiên quay lại đâm vào; P9 gỡ đúng
bức tường thừa đó.

## Thay đổi

File nguồn duy nhất: `mobile/lib/core/navigation/pair_gate_shell.dart`.

1. **§8.4 — thu về một nhánh.** Trong `switch` của `_AppShellView.build`, đổi
   **một** nhánh `PairGateUnpaired()` sang `HomeScreen(...)`. Ba nhánh
   `PairGateChecking()`, `PairGateNetworkError()`, `PairGatePaired()` giữ
   nguyên văn.
2. **§8.5 — ghim `_soloPairingStatus`.** Nhánh mới truyền một hàm tĩnh trả
   `PairingStatus.unpaired` thay vì để `HomeScreen` tự phân giải. Bắt buộc,
   không phải khẩu vị: mặc định `_defaultResolvePairingStatus` đọc
   `CouplePairingStore` — một nguồn sự thật thứ hai, độc lập với `PairGateCubit`
   — và có thể trả `PairingStatus.unknown`, mà `_SoloHomeGateState` map mọi giá
   trị khác `unpaired` sang `coupleBuilder`. Không ghim thì một lần đọc store
   hỏng sẽ dựng dashboard cặp đôi bên trong phiên chưa ghép, đúng bất biến mà
   `pair_gate_cubit.dart` dựng ra để giữ. Ghim làm cho "unpaired ⇒ chỉ có thể
   ra bề mặt solo" thành đúng theo cấu trúc.
3. **§8.6 — dọn seam chết.** Sau khi đổi nhánh, `_router`,
   `_createInviteCubit`, `_createJoincodeCubit` chỉ còn được dùng ở nhánh cũ
   nên thành mã chết; gỡ theo đúng thứ tự bắt buộc (đổi nhánh → chạy
   `flutter analyze lib test` → gỡ đúng những gì analyze báo unused). Ba call
   site production không truyền chúng, nên bán kính thật rất hẹp.

## Test (§8.7, §8.11)

`cfde25c` sửa `test/app/cupid_app_entry_routing_test.dart` và thêm
`test/core/navigation/pair_gate_shell_test.dart` (test hồi quy §8.7 rule 3:
`PairGateUnpaired` khi `CouplePairingStore` trả `unknown` vẫn phải ra bề mặt
solo). Cặp khẳng định chuẩn ở mọi chỗ: `Key('solo_stage_one_shell')`
`findsOneWidget` và `Key('home_screen_ready_signal')` `findsNothing`.

`93ff105` thi hành đúng bảng phân loại 7 test của §8.11 cho group
`PairGateShell gate (AC4)` trong
`test/features/pairing/presentation/pair_gate_cubit_test.dart` — §8.11 đã nới
§8.7 rule 4 (nguyên văn cũ "giữ nguyên") vì group này dựng `PairGateShell` đầy
đủ và khẳng định đích cũ:

| Test (dòng trước patch) | Phán quyết §8.11 |
|---|---|
| 203-228 "unpaired routes into the pairing stack..." | **SỬA** sang cặp khẳng định §8.7 rule 1/2; bỏ đoạn tap `createCodeRowKey` → `InviteScreen` |
| 230-246 "'They already have a code' navigates directly to JoincodeScreen" | **XOÁ** — đã phủ ở `pairing_choice_screen_test.dart:99-108` |
| 248-264 "'Scan the QR on their phone' reaches the same JoincodeScreen (AC3)" | **XOÁ** — đã phủ ở `pairing_choice_screen_test.dart:110-121` |
| 266-293 "accepting a code ... navigates through to PairedScreen" | **XOÁ** — exercise đúng `_router`/`_createInviteCubit`/`_createJoincodeCubit` mà §8.6 gỡ; sau §8.6 không còn compile được |
| 295-308 "paired routes into the main tab shell" | **GIỮ NGUYÊN** |
| 310-336 "a failed check with network error renders network error screen..." | **GIỮ NGUYÊN** — §8.8 cấm đổi hành vi `PairGateNetworkError` |
| 338-347 "a non-network failed check falls back to the pairing stack" | **SỬA** — fail-safe của `PairGateCubit` cũng đi qua đích mới vô điều kiện; đổi cả khẳng định lẫn tên test |

Nhóm `PairGateCubit` thuần (dòng 112-200) giữ nguyên tuyệt đối, không chạm.

`93ff105` cũng xoá nguyên `group('AC4/AC5 back edges from the unpaired pair
gate', ...)` cùng helper `_gateHarness()` trong
`test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
theo §8.11: helper đó cũng dựng `PairGateShell` đầy đủ và tap
`createCodeRowKey`/`enterCodeRowKey`, hai key không còn tồn tại trên
`HomeScreen`. Không mất phủ sản phẩm — `_harness()` của chính
`PairingChoiceScreen` đã kiểm ba cạnh create/enter/scan khi dựng màn trực tiếp.

Vòng vá này (2026-09-08, S9-F-3) đổi thêm đúng **tên** của test dòng 227-228
sang `'unpaired routes into the solo surface, never the couple dashboard'`:
tên cũ còn nói "pairing stack" trong khi thân test đã khẳng định hành vi
post-P9 đúng. Không chạm thân test.

## Cấm đã tuân thủ (§8.8)

Không chạm nhánh solo của `home_screen.dart`, `_SoloStageOneShell`, thanh tab 4
mục, hay `ActivityCardHubView` (hợp đồng canvas D-3 đang khoá). Không thêm tab
thứ 5, route mới, `PairGateState` mới, hay màn sản phẩm mới. Không chạm
`schemaVersion`/migration. Không chạm `onboarding_chain.dart`. Không đổi hành vi
`PairGateNetworkError`.

## Xác minh

Xem `coding-plan/test-results.md` → `## P9` (analyze + test toàn cây) và
`## Story Runtime Startup Smoke` (rule-12g lần chạy thứ 3, điều kiện "phiên chưa
ghép đôi vào thẳng hub solo" là bằng chứng trên máy thật của chính P9).

## Còn lại, ngoài phạm vi P9

- **§8.10** — phiên chưa ghép đôi **mất mạng** vẫn rơi vào `_NetworkErrorView`
  vì `PairGateCubit` phát `PairGateNetworkError` trước mọi quyết định solo.
  Hành vi này có trước REQ-016 và tác động y hệt lên phiên đã ghép; sửa nó là
  quyết định riêng về ngưỡng offline. Việc tiếp theo cấp requirement.
- **§8.3** — người dùng cài mới có được bỏ qua `OnboardingNode.pairingChoice`
  để vào chặng 1 hay không: OQ cho PO, không phải blocker.
- **§8.11** — phủ "back edges khi vào `PairingChoiceScreen` từ chuỗi onboarding"
  là khoảng hở thật nhưng ngoài phạm vi P9 (§8.8 cấm chạm
  `onboarding_chain.dart`).
