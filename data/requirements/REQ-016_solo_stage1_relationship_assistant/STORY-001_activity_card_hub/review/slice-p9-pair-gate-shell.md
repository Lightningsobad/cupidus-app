# Slice review — P9 `pair_gate_shell` (đóng khoảng hở S9-F-4)

Outcome: PARTIAL_SLICE_ONLY

- Review type: `scoped-slice`
- Story: STORY-001 (REQ-016), Story-Class `shared-foundation`
- RunId: `RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-reviewer-p9gateshell`
- BaseHead: `9207f7296a64cd37ca60e432939469ca96860762` · Worktree HEAD `b8c4bef`
- Nguồn chi phối: `coding-plan/master-plan.md` §8.4, §8.5, §8.6, §8.7 rule 1-3
  (kèm §8.11 sửa rule 4, và §8.12 chỉ ở vai trò ngữ cảnh chéo file)
- Khoảng hở được giao đóng: `review/slice-p9-p10-delta.md` → **S9-F-4**

## Scope Gate

Review type: `scoped-slice`
Review report path: `review/slice-p9-pair-gate-shell.md`

### Source/Test Files In Scope

Đúng 3 file của S9-F-4. **Cả 3 đường dẫn trong handoff đều sai**; đã phân giải
sang đường dẫn thật, không mơ hồ (xem S9B-F-1):

| Handoff | Đường dẫn thật (đã review) | Delta so với BaseHead |
|---|---|---|
| `mobile/lib/features/pairing/presentation/pair_gate_shell.dart` | `mobile/lib/core/navigation/pair_gate_shell.dart` | +22 / -30 |
| `mobile/test/features/pairing/presentation/pair_gate_shell_test.dart` | `mobile/test/core/navigation/pair_gate_shell_test.dart` | mới, 135 dòng |
| `mobile/test/core/navigation/cupid_app_entry_routing_test.dart` | `mobile/test/app/cupid_app_entry_routing_test.dart` | +50 / -5 |

Đọc chéo tối thiểu, chỉ để xác minh hợp đồng liên file mà §8.6/§8.11 dựng ra:
`test/features/pairing/presentation/pair_gate_cubit_test.dart:56,77-86` (call
site của 3 tham số constructor), và định vị `pairing_stack` trên toàn `lib`/
`test` để kiểm ứng viên còn lại của §8.7 rule 1.

### Evidence Files In Scope

- `review/slice-p9-p10-delta.md` — chỉ đoạn S9-F-4 (dòng 209-241)
- `master-plan.md` §8.4-§8.7 (dòng 337-400), §8.9-§8.11 (dòng 411-513),
  §8.12 mở đầu (dòng 515-540)
- Bằng chứng chạy trực tiếp trong slice này (mục Kết quả kiểm chứng)

### Query Keys

`_soloPairingStatus` · `PairGateUnpaired()` · `solo_stage_one_shell` ·
`home_screen_ready_signal` · `_createInviteCubit` · `_createJoincodeCubit` ·
`_router` · `pairing_stack` · `CouplePairingStore` · `PairingStatus.unknown`

### Phase 2 Approval

Được phép. Phạm vi 3 file + 1 artifact chi phối, nằm trong ngân sách
`scoped-slice`.

## Bảng phán quyết

| # | Quy tắc | Phán quyết | Bằng chứng |
|---|---|---|---|
| 1 | §8.4 — đổi **đúng một** nhánh `PairGateUnpaired()` sang `HomeScreen(resolvePairingStatus: _soloPairingStatus)` | **PASS** | `pair_gate_shell.dart:136-138` khớp nguyên văn khối mã §8.4 |
| 2 | §8.4 — 3 nhánh `PairGateChecking()`/`PairGateNetworkError()`/`PairGatePaired()` giữ nguyên văn | **PASS** | `pair_gate_shell.dart:134-135,139-145`; diff không có hunk nào chạm 3 nhánh này |
| 3 | §8.4 — hàm tĩnh `_soloPairingStatus` cùng file | **PASS** | `pair_gate_shell.dart:127-128`, chữ ký khớp nguyên văn |
| 4 | §8.5 — ghim giá trị, không để `HomeScreen` tự phân giải qua `getIt<CouplePairingStore>()` | **PASS** | `HomeScreen` chỉ nhận `resolvePairingStatus`, không có đường nào rơi về resolver mặc định; test #8/#9 chứng minh bằng hành vi |
| 5 | §8.6 — dọn seam chết `_router`/`_createInviteCubit`/`_createJoincodeCubit` | **PASS (có deferred)** | 3 **field** + 3 assignment + 3 tham số của `_AppShellView` đã gỡ (`pair_gate_shell.dart:70-75`, `102-118`). 3 **tham số constructor public** của `PairGateShell` còn lại, không lưu — xem S9B-F-2 |
| 6 | §8.6 — trình tự "đổi nhánh → analyze → gỡ đúng cái analyze báo" | **PASS** | `flutter analyze` trên 3 file: 0 error, 0 warning. Analyzer Dart không báo tham số constructor không dùng, nên phần còn lại không nằm trong "cái analyze báo" |
| 7 | §8.7 rule 1 — test khẳng định cạnh gốc-app đổi sang `find.byKey(Key('solo_stage_one_shell'))` findsOneWidget | **PASS** | `cupid_app_entry_routing_test.dart:31-33` (`_routedDestination` đổi định nghĩa) + 5 khẳng định `findsOneWidget` tại dòng 153, 183, 191, 204, 214 |
| 7b | §8.7 rule 1 — ứng viên còn lại `chain_tail_edges_test.dart` | **PASS (không áp dụng)** | `grep -rl 'pairing_stack' lib test` chỉ trả 3 file, không có `chain_tail_edges_test.dart` → file này không khẳng định cạnh đó, không có gì để sửa |
| 8 | §8.7 rule 2 — khẳng định âm `find.byKey(Key('home_screen_ready_signal'))` findsNothing cùng chỗ | **PASS** | `cupid_app_entry_routing_test.dart:37-39` (`_coupleDashboardSignal`) + 5 khẳng định `findsNothing` thêm mới tại dòng 151, 181, 189, 202, 212 |
| 9 | §8.7 rule 3 — test hồi quy: `PairGateCubit` giả phát `PairGateUnpaired` khi `CouplePairingStore` không đăng ký **hoặc** trả `unknown` | **PASS** | `pair_gate_shell_test.dart` phủ **cả hai** nhánh: dòng 93-105 (`getIt.isRegistered<CouplePairingStore>()` khẳng định `isFalse` trước khi pump) và dòng 107-134 (đăng ký store thật với adapter luôn lỗi, **khẳng định `status == PairingStatus.unknown`** ở dòng 126 trước khi pump). Mỗi nhánh khẳng định đủ cặp solo-có / dashboard-không |
| 10 | §8.12 — có ràng buộc liên file nào chi phối 3 file này không | **Không** | §8.12 cấp quyền hẹp, giới hạn tuyệt đối trong `splash_screen_test.dart` dòng 208. Nó **đọc** `pair_gate_shell.dart:136-138` làm tiền đề (dòng 521-522) và tiền đề đó đúng với mã hiện tại. Không ràng buộc ngược lên 3 file của slice |

## Kết quả kiểm chứng (chạy trực tiếp trong slice này)

```
flutter test test/core/navigation/pair_gate_shell_test.dart \
             test/app/cupid_app_entry_routing_test.dart --reporter expanded
→ 00:01 +9: All tests passed!
```

- **9 pass / 0 fail / 0 skip.** Phân bổ: `pair_gate_shell_test.dart` 2 case
  (cả hai đều được reporter gọi tên), `cupid_app_entry_routing_test.dart` 7 case.
- `DioException [connection error]` in ra giữa run là **có chủ đích**:
  `_AlwaysFailingAdapter` (`pair_gate_shell_test.dart:38-53`) dựng đúng điều
  kiện `PairingStatus.unknown`. Không phải lỗi hạ tầng.

```
flutter analyze --no-fatal-infos --no-fatal-warnings \
  lib/core/navigation/pair_gate_shell.dart \
  test/core/navigation/pair_gate_shell_test.dart \
  test/app/cupid_app_entry_routing_test.dart
→ 11 issues found (1.7s)
```

- **0 error, 0 warning, 11 info** — toàn bộ là `prefer_initializing_formals`
  trên `pair_gate_shell.dart:63-68,108-112`, đúng mẫu nhiễu nền sẵn có của
  package. Không có issue nào do P9 tạo ra.

## Phát hiện

### S9B-F-1 — Cả 3 đường dẫn file trong handoff đều không tồn tại (INFO, chủ: Scrum Master)

Handoff giao `mobile/lib/features/pairing/presentation/pair_gate_shell.dart`,
`mobile/test/features/pairing/presentation/pair_gate_shell_test.dart`,
`mobile/test/core/navigation/cupid_app_entry_routing_test.dart`.
`git diff --stat <BaseHead> -- <3 đường dẫn đó>` trả về **rỗng**. Đường dẫn thật
nằm ở bảng Scope Gate. Ba đường dẫn sai này bị hoán vị đúng theo cặp
`core/navigation` ↔ `features/pairing/presentation` và `test/app` ↔
`test/core/navigation`, nên phân giải được không mơ hồ và slice vẫn phủ đúng
S9-F-4. Ghi lại để lần dispatch sau lấy đường dẫn từ `git diff --name-only`
thay vì gõ tay: một diffstat rỗng rất dễ bị đọc nhầm thành "không có thay đổi
để review" và cho ra một PASS rỗng.

### S9B-F-2 — 3 tham số constructor public của `PairGateShell` được nhận rồi bỏ im lặng (DEFERRED, chủ: Tech Lead quyết, mobile-dev thực thi nếu chọn gỡ)

`pair_gate_shell.dart:55-57` vẫn nhận `createInviteCubit`, `createJoincodeCubit`,
`router`, nhưng danh sách khởi tạo (dòng 63-68) không còn lưu chúng và không nơi
nào đọc. Truyền chúng vào giờ **không có tác dụng gì và cũng không báo lỗi**.
Hệ quả kèm theo: `invite_cubit.dart`/`joincode_cubit.dart` vẫn phải import chỉ
để khai kiểu cho 3 tham số chết.

Vì sao **không chặn**:

- §8.6 nói gỡ "đúng những **field**/tham số mà analyze báo unused" và cấm giữ
  lại **field** unused. Field đã gỡ hết; analyzer Dart không báo tham số
  constructor không dùng (đo ở mục trên: 0 warning), nên phần còn lại nằm ngoài
  cái mà §8.6 ra lệnh gỡ theo đúng câu chữ.
- §8.11 dòng 489-491 đã **lường trước** đúng trạng thái này: *"dù constructor có
  giữ tham số đó hay không, cả 2 test trong group đều fail runtime"* — tức Tech
  Lead viết phán quyết sao cho đúng ở **cả hai** kết cục, nên việc giữ nằm trong
  dung sai của phán quyết chi phối.
- Có ràng buộc thật buộc phải giữ: harness dùng chung của
  `pair_gate_cubit_test.dart:77-86` truyền cả 3 vào `PairGateShell`, mà §8.11
  dòng 509-511 ghim nhóm `PairGateCubit` (dòng 112-200) là *"giữ nguyên tuyệt
  đối, không được chạm"*. Gỡ tham số sẽ làm file đó **không compile**, kéo theo
  phải sửa harness — chính là thứ §8.11 cấm.

Việc cần làm sau, không thuộc P9: hoặc gỡ 3 tham số kèm sửa harness trong một
vòng có §8.11 nới ghim, hoặc `@Deprecated` chúng để call site mới không im lặng
truyền vào hư không.

### S9B-F-3 — Doc comment trong `pair_gate_shell.dart` viện dẫn bản §8.7 rule 4 đã bị thay (DEFERRED, chủ: mobile-dev)

`pair_gate_shell.dart:30-36` giải thích việc giữ 3 tham số là để
*"`pair_gate_cubit_test.dart` — pinned unchanged by §8.7 rule 4 — keeps
compiling"*. §8.11 (dòng 509-513) đã **sửa trực tiếp** rule 4: chỉ nhóm
`PairGateCubit` dòng 112-200 còn được ghim tuyệt đối, còn nhóm
`PairGateShell gate (AC4)` dòng 202-348 bị lệnh sửa/xoá. Nên "pinned unchanged"
mô tả sai trạng thái hiện tại của chính file test đó. Lý do kỹ thuật thì vẫn
đúng (harness dòng 77-86 nằm ngoài cả hai vùng và vẫn cần compile) — chỉ câu
viện dẫn là lỗi thời. Sửa một dòng comment, không đổi hành vi.

### Ghi nhận không thành finding

`cupid_app_entry_routing_test.dart` trước đây cố ý **không** đăng ký gì vào
`getIt` để một lookup lọt ra đường launch sẽ làm đỏ test (comment cũ, dòng 23-26
bản trước). P9 buộc phải nới: `setUp(_registerActivityCardRepository)` (dòng
116) đăng ký `CupidDatabase` + `ActivityCardRepository`. Đây là hệ quả bắt buộc
của §8.4 (đích mới `HomeScreen` → `ActivityCardHubView` có phụ thuộc `getIt`
thật), phạm vi hẹp đúng 2 đăng ký, có `tearDown(() => getIt.reset())` (dòng 117),
và comment mới (dòng 34-45) nói rõ bất biến còn lại: *"nothing else on the launch
path may read from `getIt`"*. Bất biến bị thu hẹp một cách có kiểm soát và có tài
liệu, không phải bị xoá.

## Kết luận slice

S9-F-4 **đã đóng**. §8.4, §8.5, §8.6, §8.7 rule 1-3 đều PASS ở tầng mã nguồn
với bằng chứng chạy trực tiếp; không có phát hiện chặn nào trong 3 file này.
Hai finding DEFERRED (S9B-F-2, S9B-F-3) đều là chất lượng bề mặt API/tài liệu,
không ảnh hưởng hành vi và đã được §8.11 lường trước.

Slice này **không** ra quyết định đóng story — đó là việc của `final-synthesis`.
