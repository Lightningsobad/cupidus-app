# Review slice — P9/P10 delta (STORY-001)

Outcome: PARTIAL_SLICE_ONLY

Phán quyết đóng story vẫn thuộc dòng `Outcome:` chuẩn trong `review-report.md`
do lượt `final-synthesis` sở hữu; dòng trên chỉ là kết quả của slice này.

Mode: `scoped-slice` · Reviewer: Iris-QC · Ngày: 2026-09-08

Đây là một slice, không phải phán quyết đóng story. Quyết định
CLEAN/DEFERRED_ONLY/PATCH_REQUIRED cuối cùng thuộc về lượt final-synthesis và
Scrum Master, sau khi hai phát hiện chặn S9-F-1/S9-F-2 và khoảng trống phạm vi
S9-F-4 được xử lý.

Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
BaseHead: `9207f72` · HEAD lúc review: `d4852f5`
Baseline thực dụng của slice: `c92fd1b` (kết thúc vòng vá 2) → `d4852f5`, tức
đúng delta P9 + P10.

Đây KHÔNG phải lần chạy lại 8 pass. Slice 1-7 và `review-report.md` đã phủ phần
còn lại của story và nằm ngoài phạm vi ở đây.

## Bảng kết quả

| # | Hạng mục được giao | Kết quả |
|---|---------------------|---------|
| 1 | P9 §8.11 — 7 test trong group `PairGateShell gate (AC4)` của `pair_gate_cubit_test.dart` | **PASS** |
| 2 | P9 §8.11 — xoá group `AC4/AC5 back edges` + `_gateHarness()` khỏi `pairing_choice_screen_test.dart` | **PASS** |
| 3 | P9 §8.7 rule 4 (đã sửa) — group `PairGateCubit` dòng 112-200 giữ nguyên tuyệt đối | **PASS** |
| 4 | P9 §8 — artifact bắt buộc `phase-P9-unpaired-root-to-solo-surface.md` | **FAIL** (S9-F-1) |
| 5 | P9 §8.4/§8.5/§8.6 — `pair_gate_shell.dart` (nguồn) | **UNVERIFIED** — ngoài danh sách file của slice (S9-F-4) |
| 6 | P10 §9.4 File 1 — `BackendUserIdStore.readPersistedUserId` + nạp lười trong `resolve()` | **PASS** |
| 7 | P10 §9.4 File 2 + §9.5 — dây nối `service_locator.dart`, mặc định `null` | **PASS** |
| 8 | P10 §9.6 rule 1-3 — `backend_user_id_store_test.dart` | **PASS** |
| 9 | P10 §9.6 rule 4 — test khởi động nguội trong `activity_card_repository_test.dart` | **PASS** |
| 10 | P10 §9.6 rule 5 — chỉ THÊM, không đổi khẳng định cũ trong 2 file test đó | **PASS** |
| 11 | P10 §9.7 — danh sách cấm chạm | **PASS** |
| 12 | P10 §9.9 — `flutter analyze lib test` 0 error, `flutter test` xanh | **PASS** (bằng chứng do reviewer chạy; hồ sơ của lane thiếu — S9-F-2) |
| 13 | rule-12g startup smoke lần 3 — 4/4 điều kiện | **PASS** |
| 14 | Nhãn "không chặn" §8.10 (unpaired + mất mạng → `_NetworkErrorView`) | **PASS** — vẫn đúng nhãn, không bị nới |
| 15 | Nhãn "không chặn" §8.11 (back-edge qua chuỗi onboarding mất phủ test) | **PASS** — vẫn đúng nhãn, không bị nới |

## Bằng chứng

### 1-2. Phân loại 7 test §8.11 (`git diff c92fd1b..HEAD`)

| Test §8.11 | Phán quyết TL | Thực tế trong diff |
|---|---|---|
| "unpaired routes into the pairing stack..." (cũ 203-228) | SỬA | SỬA — nay `pair_gate_cubit_test.dart:236-237` khẳng định `solo_stage_one_shell` `findsOneWidget` + `home_screen_ready_signal` `findsNothing`; đoạn tap `createCodeRowKey` → `InviteScreen` đã bỏ hết ✅ |
| "'They already have a code' navigates directly to JoincodeScreen" | XOÁ | XOÁ ✅ |
| "'Scan the QR...' reaches the same JoincodeScreen (AC3)" | XOÁ | XOÁ ✅ |
| "accepting a code ... to PairedScreen (onPaired production wiring)" | XOÁ | XOÁ ✅ |
| "paired routes into the main tab shell" | GIỮ NGUYÊN | không đổi ✅ |
| "a failed check with network error ... retry works" | GIỮ NGUYÊN | không đổi ✅ |
| "a non-network failed check falls back to the pairing stack" | SỬA + đổi tên | SỬA — `:283` đổi tên thành `...falls back to the solo surface (fail-safe)`, khẳng định đảo đúng: `pairing_stack` `findsNothing`, `solo_stage_one_shell` `findsOneWidget`, `pair_gate_network_error` `findsNothing` ✅ |

`pairing_choice_screen_test.dart`: diff là `+0 -73`, xoá đúng group
`AC4/AC5 back edges from the unpaired pair gate` + helper `_gateHarness()` + 4
import chết theo. Không đụng gì trước dòng 147. Phủ tự thân của
`PairingChoiceScreen` (`_harness()`) còn nguyên 3 cạnh create/enter/scan tại
`pairing_choice_screen_test.dart:82-118` ✅ — đúng lập luận "không mất phủ" ở
§8.11.

### 3. §8.7 rule 4 (bản đã sửa)

Group `PairGateCubit` (`pair_gate_cubit_test.dart:136-224`) không có hunk nào
trong diff ✅. Hai hunk duy nhất ngoài group AC4 là helper mới
`_registerActivityCardRepository()` và một dòng gọi nó trong `setUp` (`:119`) —
cần thiết vì bề mặt solo nay phân giải `ActivityCardRepository` qua `getIt`.
`tearDown(() => getIt.reset())` tại `:134` có sẵn nên đăng ký thêm không rò
sang test khác. Không phải "chạm" vào group được bảo vệ.

### 6-7. P10 mã nguồn

`backend_user_id_store.dart:10-41` khớp **nguyên văn** chữ ký và thân hàm ở
§9.4 File 1: tham số tuỳ chọn mặc định `null`, RAM-cache thắng, reader `null`
thì trả `cached`, chuỗi rỗng không được cache.
`service_locator.dart:171-175` khớp nguyên văn §9.4 File 2. Đã xác minh
`JwtTokenProvider.getSavedUserId` tồn tại đúng chữ ký `Future<String?>
Function()` tại `jwt_token_provider.dart:38-41`, và `JwtTokenProvider` đăng ký ở
dòng 107 (trước 174) nên thứ tự resolve đúng ✅.

### 8-10. P10 test

`backend_user_id_store_test.dart:76-136` — group `cold-start rehydration (P10)`
5 test: reader gọi đúng 1 lần cho 2 `resolve()` (rule 1); RAM thắng persisted +
reader trả `null`/rỗng không cache (rule 2); bất biến teardown bằng đồ thật
`SharedPreferences.setMockInitialValues` + `JwtTokenProvider` thật +
`CupidSession(firebaseAuth: null)` + `registerScopedStore` (rule 3) ✅.
`activity_card_repository_test.dart` — diff `+29 -0`, đúng một test khởi động
nguội khẳng định `createCard` trả `ownerKey == 'persisted-user-cold'` và
`cardsByStatus` thấy thẻ (rule 4) ✅. Cả hai file đều `-0` dòng ⇒ rule 5 ✅.

### 11. §9.7

Delta `c92fd1b..HEAD` chỉ chạm `service_locator.dart` (+6/-1),
`backend_user_id_store.dart`, và các file test. Không có
`home_screen.dart`, `cupid_session.dart`, `jwt_token_provider.dart`,
`cupid_database.dart`, `couple_pairing_store.dart`, `main_preview.dart`,
`preview_reminder_fixture.dart` trong delta ✅. `pair_gate_shell.dart` có trong
delta nhưng thuộc P9 (commit `cfde25c`), không phải P10 mở lại phạm vi.

### 12. Cổng đóng §9.9 (reviewer tự chạy vì hồ sơ thiếu)

```
$ flutter test test/features/pairing/presentation/pair_gate_cubit_test.dart \
    test/features/pairing/presentation/screens/pairing_choice_screen_test.dart \
    test/core/navigation/pair_gate_shell_test.dart \
    test/app/cupid_app_entry_routing_test.dart \
    test/core/realtime/backend_user_id_store_test.dart \
    test/features/activity_cards/activity_card_repository_test.dart
00:01 +48: All tests passed!

$ flutter analyze lib test
191 issues found. (ran in 4.3s)   # `grep -c "error •"` = 0
```

0 error toàn cây (giảm từ 196 issue ở vòng vá 2, khớp với việc P9 gỡ import/mã
chết). Cả 6 file test P9/P10 chạm đều xanh.

### 13. rule-12g lần chạy thứ 3

`test-results.md:1239-1293`. Chạy tại HEAD `ea59bae` trên `emulator-5554`,
`main.dart` thật, không `main_preview.dart`, không fixture, không harness test.

| Điều kiện | Ghi nhận | Xác minh độc lập |
|---|---|---|
| App khởi động + migrate v2→v3 | 36864 → 57344 byte, `PRAGMA user_version` 2 → 3 | nhất quán |
| Migration quan sát được (không suy luận) | bảng mới `activity_cards`, `activity_card_photos` xuất hiện cạnh 5 bảng cũ; đo state trước/sau | nhất quán |
| Phiên chưa ghép đôi vào thẳng hub solo | ảnh `screen2.png` | **đã mở ảnh** — bản dựng thật (dải DEBUG), vào thẳng hub solo với đúng 4 tab `Muốn làm / Ý tưởng / Sổ tay / Nhật ký`, không phải `PairingChoiceScreen`, không phải dashboard cặp đôi ✅ |
| Mở một thẻ sang màn chi tiết P6 | ảnh `screen5.png` | **đã mở ảnh** — màn chi tiết P6 đủ: chip `MỚI NGHĨ RA`, tiêu đề, "Sổ tay có ghi", "Giá"/"Khoảng cách", tags, "Chuyển trạng thái", "Xoá thẻ", "Hẹn ngày" ✅ |

Logcat: `/tmp/req016-p10-r12g3-logcat2.txt` (22.7K) tồn tại; hồ sơ ghi không
`E flutter`, không `FATAL EXCEPTION`, không `StateError`, không
`SqliteException`; nhiễu còn lại (`FirebaseInstallations SERVICE_NOT_AVAILABLE`,
`flutter_facebook_auth`) đã ghi nhận từ các vòng trước. Cả 4 ĐẠT.

Chú ý tích cực: đúng thao tác từng ném
`Bad state: ActivityCardRepository used before a backend user id resolved`
(§9.1) nay chạy sạch ⇒ P10 sửa đúng nguyên nhân gốc mà R-2 vòng trước bắt được.

### 14-15. Hai khoảng hở "không chặn"

- **§8.10** (`master-plan.md:426-433`): phiên chưa ghép đôi + mất mạng vẫn rơi
  vào `_NetworkErrorView`. Vẫn ghi đúng là "việc tiếp theo ở cấp requirement,
  không phải blocker của P9", lý do vẫn đứng (hành vi có trước REQ-016, tác động
  y hệt lên phiên đã ghép). Không bị nới âm thầm: §8.8 cấm đổi hành vi
  `PairGateNetworkError`, và test "a failed check with network error" trong
  `pair_gate_cubit_test.dart` không có hunk nào trong diff ✅.
- **§8.11 phát hiện thứ hai** (`master-plan.md:500-503`): back-edge khi vào từ
  chuỗi onboarding mất phủ test trực tiếp sau khi xoá group AC4/AC5. Vẫn ghi
  đúng là "khoảng hở thật nhưng ngoài phạm vi P9, cùng mẫu với §8.10". Không bị
  nới: diff xoá **đúng** group + helper được phán quyết, `+0 -73`, không xoá
  thêm test nào của `PairingChoiceScreen` ✅.

## Phát hiện

### S9-F-1 — CHẶN (P9): thiếu artifact phase file bắt buộc

`master-plan.md:291` yêu cầu nguyên văn: "Phase file mobile-dev phải tạo:
`phase-P9-unpaired-root-to-solo-surface.md`". File này **không tồn tại**.
`coding-plan/` chỉ có phase file P1-P8 và P10.

Hệ quả: vòng P9 (2 commit `cfde25c`, `93ff105`; 52 dòng đổi ở
`pair_gate_shell.dart`, 5 test xoá, 2 test viết lại, 1 file test 135 dòng mới)
không có artifact ghi lại lựa chọn thiết kế, sai lệch so với plan, hay thay đổi
ngoài write scope.

Chủ: mobile-dev. Hành động: tạo `phase-P9-unpaired-root-to-solo-surface.md`
theo §8.

### S9-F-2 — CHẶN (P9/P10): thiếu mục bằng chứng test/analyze cho vòng P9

`test-results.md` không có mục `## P9` nào. Mục P10 (`:1188-1237`) chỉ ghi
analyze/test **thu hẹp 4 file**, và tự ghi "Chưa chạy lại startup smoke R-2".
Vì vậy điều kiện đóng §9.9 (`flutter analyze lib test` 0 error + `flutter test`
xanh) chưa từng được ghi ở mức toàn cây cho cả P9 lẫn P10.

Bản chất đã ĐẠT — reviewer đã chạy và ghi ở mục 12 trên (48/48 xanh, 0 error).
Đây là lỗ hổng **hồ sơ**, không phải lỗ hổng chất lượng. Nhưng nó là hồ sơ mà
cổng DONE đọc.

Kèm hai điểm hình thức cùng loại:
- Bằng chứng rule-12g nằm dưới tiêu đề `### Startup smoke rule-12g — lần chạy
  thứ 3 ...`, **không** phải tiêu đề chuẩn `## Story Runtime Startup Smoke` mà
  reviewer rule 12g và cổng DONE đọc. `test-results.md` cũng không có mục
  `## Entry Point Reachability` (rule 12e1) — hạng mục này thuộc slice 4, chỉ
  ghi lại ở đây vì phát hiện khi rà tiêu đề.
- Toàn bộ ảnh + logcat của rule-12g chỉ nằm ở `/tmp/req016-p10-r12g3-*`
  (đã kiểm: còn tồn tại lúc review). `/tmp` là bộ nhớ tạm — bằng chứng vận hành
  duy nhất chứng minh app boot sẽ biến mất, và không có bản nào trong repo.

Chủ: mobile-dev (mục bằng chứng + tiêu đề chuẩn), Scrum Master (quyết định có
đưa ảnh vào `visual-fidelity/` hay một thư mục evidence của story).

### S9-F-3 — HOÃN (nhỏ, bảo trì): tên test lạc hậu

`pair_gate_cubit_test.dart:227-228` vẫn tên
`'unpaired routes into the pairing stack with no tab bar and a reachable
"I''ll create the code" entry action'`, trong khi thân test nay khẳng định đúng
điều ngược lại (bề mặt solo, không có pairing stack, không tap
`createCodeRowKey`). §8.11 chỉ bắt buộc đổi tên cho test cuối cùng, nên đây
không phải sai phán quyết — nhưng tên hiện mô tả sai chính nó. Test thứ 7 đã
được đổi tên đúng; test thứ 1 thì không.

Đề xuất: đổi thành dạng "unpaired routes into the solo surface, never the couple
dashboard". Không chặn.

### S9-F-4 — Phạm vi slice: 3 file trong delta P9/P10 nằm ngoài danh sách được giao

`git diff --name-only c92fd1b..HEAD` cho thấy delta P9/P10 chạm 9 file mã/test.
Ba trong số đó **không** có trong danh sách 14 file của handoff:

- `mobile/lib/core/navigation/pair_gate_shell.dart` (+52/-52) — đây chính là
  **file nguồn duy nhất của P9** (§8.4). Toàn bộ tuân thủ §8.4 (đổi đúng một
  nhánh), §8.5 (ghim `_soloPairingStatus`), §8.6 (dọn `_router`,
  `_createInviteCubit`, `_createJoincodeCubit`) **không được xác minh** trong
  slice này.
- `mobile/test/core/navigation/pair_gate_shell_test.dart` (mới, 135 dòng) —
  test hồi quy §8.7 rule 3 (`CouplePairingStore` không đăng ký / trả `unknown`).
  Không xác minh nội dung; chỉ xác nhận nó **chạy xanh** ở mục 12.
- `mobile/test/app/cupid_app_entry_routing_test.dart` (+55/-…) — §8.7 rule 1/2.
  Cùng tình trạng.

Chiều ngược lại: 7 file **có** trong danh sách slice lại **không** có delta
P9/P10 nào (`activity_card_hub_view.dart`, `activity_card_repository.dart`,
`activity_card_repository_impl.dart`, `activity_card_list_cubit.dart`,
`app_shell_test.dart`, `card_lifecycle_ui_test.dart`,
`activity_card_hub_view_test.dart`) — chúng thuộc vòng P4/P6/P8, đã được slice
4/6 phủ.

Ghi chú: quan sát dán tiếp về `pair_gate_shell.dart` từ diff test —
`pair_gate_cubit_test.dart:52-58` mô tả `createInviteCubit`/`createJoincodeCubit`
là "still-accepted (but now unreachable) constructor seams", tức tham số
constructor **chưa** bị gỡ dù §8.6 dự kiến gỡ. Điều này **không** làm sai bất kỳ
phán quyết §8.11 nào (§8.11 đã nói rõ "dù constructor có giữ tham số đó hay
không", 2 test kia vẫn phải xoá), nhưng cần một slice có
`pair_gate_shell.dart` trong phạm vi mới kết luận được §8.6.

Chủ: Scrum Master. Hành động: một slice bổ sung phủ đúng 3 file trên trước khi
final-synthesis, hoặc xác nhận slice trước đó đã phủ chúng.

## Khuyến nghị

Slice này **không** đưa ra quyết định đóng story (thuộc Scrum Master sau
final-synthesis). Xét riêng phạm vi được giao:

- Toàn bộ phán quyết P9 §8.11 và P10 §9.3-§9.7 đã thi hành **đúng nguyên văn**;
  không có sai lệch hành vi, không có nới phạm vi, không có khoảng hở "không
  chặn" nào bị nới âm thầm.
- Cổng chất lượng thực chất đều xanh (48/48 test, 0 error analyze, 4/4 rule-12g
  với ảnh đã tự xem).
- Hai phát hiện S9-F-1 và S9-F-2 là **hồ sơ artifact/evidence còn thiếu**, không
  phải khiếm khuyết mã. Chúng vẫn cần đóng trước khi story qua cổng DONE, vì
  chính cổng DONE và rule 12g đọc những mục đó.
- S9-F-4 để lại một mảng §8.4/§8.5/§8.6 chưa ai xác minh ở tầng mã nguồn trong
  đợt slice này.
