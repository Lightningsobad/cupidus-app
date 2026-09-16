# Test Results – STORY-012 Trạng thái theo pha, widget, và bộ đếm

## Phase Status

| Phase | Owner | Status | Verified On |
|-------|-------|--------|-------------|
| P1 | Mobile Developer | DONE | 2026-09-11 |
| P2 | Mobile Developer | DONE | 2026-09-12 |
| P3 | Mobile Developer | NOT_STARTED | — |
| P4 | Mobile Developer | NOT_STARTED | — |
| P5 | Mobile Developer | NOT_STARTED | — |
| P6 | Mobile Developer | NOT_STARTED | — |
| P7 | Mobile Developer | DONE | 2026-09-17 |
| P8 | Mobile Developer | NOT_STARTED | — |

## P1 – Ba gói nội dung preset + cổng nhập luật bất biến

### Files shipped

Source:

- `mobile/lib/features/phase_status/domain/phase_content.dart`
- `mobile/lib/features/phase_status/domain/phase_content_gate.dart`
- `mobile/lib/features/phase_status/data/phase_content_repository.dart`

Assets:

- `mobile/assets/data/req016/phase_content.v1.json` (`req016.phase_content.v1`)
- `mobile/assets/data/req016/drip.v1.json` (`req016.drip.v1`)
- `mobile/assets/data/req016/nudges.v1.json` (`req016.nudges.v1`)

Tests:

- `mobile/test/features/phase_status/phase_content_gate_test.dart`
- `mobile/test/features/phase_status/phase_content_repository_test.dart`

`pubspec.yaml` unchanged: `assets/data/req016/` is already declared.

### Commands run

Toolchain: `FLUTTER_SDK_PATH=$HOME/flutter` per runtime registry `mobile-app.sdk`
(`flutter` is not on PATH). `flutter pub get` and `flutter gen-l10n` were run
first in this worktree.

1. `flutter test test/features/phase_status/ test/core/content/`

```
00:00 +50: All tests passed!
```

35 new tests in `test/features/phase_status/`, plus the 15 pre-existing
`test/core/content/content_package_test.dart` regression tests, all green.

2. `flutter analyze lib/features/phase_status test/features/phase_status`

```
Analyzing 2 items...
No issues found! (ran in 3.7s)
```

3. `flutter analyze --no-fatal-infos --no-fatal-warnings lib test`

```
222 issues found. (ran in 13.9s)
```

Exit code 0 with only errors fatal, so **0 errors** across `lib test`. The 222
entries are the pre-existing info/warning baseline recorded in `master-plan.md`
§6 — none of them names a `phase_status` file, and the count is unchanged by
this phase. Plain `flutter analyze lib test` never exits 0 in this repo, so the
gate is read as error count, not exit code.

### AC coverage

| AC / BR | What it demands | Where it is enforced | Result |
|---|---|---|---|
| AC-37 | Nội dung là gói có lược đồ + id bền, không chuỗi cứng trong code | `phase_content_repository_test.dart` → "each pack carries the schema id the contract pins", "every item id is durable and unique inside its pack", "itemById resolves a shipped line by its durable id" | PASS |
| AC-37 | Đổi nguồn sang CMS không kéo theo sửa code | Mọi chuỗi hiển thị nằm trong ba asset; `phase_content_gate_test.dart` → "no phase_status source redeclares an invariant term" quét source sau khi bóc chuỗi/chú thích | PASS |
| AC-38 / BR-16 | Không mã nào đọc `length` để suy hành vi | `phase_content_gate_test.dart` → "no phase_status source reads a package length (AC-38/BR-16)" | PASS |
| AC-38 / BR-16 | Luật đúng với mọi N, kể cả N = 0 | `phase_content_gate_test.dart` → "an empty drip pack is a legal shipped state (AC-38/BR-16)" | PASS |
| AC-38 / BR-16 | `thresholds` là dữ liệu gói, không phải hằng Dart | `phase_content_repository_test.dart` nhóm "milestone thresholds are package data (BR-16)": trả về tăng dần, thiếu khoá / phần tử không nguyên / ≤ 0 / trùng đều ném | PASS |
| AC-39 / BR-17 | Cổng từ chối mục vi phạm và làm đỏ bản dựng | `phase_content_gate_test.dart` → "every InvariantRule is caught in a phase line / a drip body / a nudge body" chạy fixture cho **từng** từ của **từng** `InvariantRule`; "a \"%\" figure is caught wherever it appears" phủ cả năm chuỗi hiển thị | PASS |
| AC-39 | Gói ship thật phải sạch, nếu không build đỏ | `phase_content_gate_test.dart` → "the packs on disk report no violation" đọc `assets/data/req016/` từ đĩa | PASS |
| AC-34 / BR-13 | Tất định, không AI, không API ngoài | `phase_content_gate_test.dart` → "no phase_status source reaches the network or a model (AC-34)"; đường nạp duy nhất là `ContentPackageLoader` + `AssetBundle` | PASS |
| BR-15 | Không chuỗi nội dung trong mã | Không file Dart nào của phase mang chuỗi hiển thị; `{n}` là cú pháp thay số duy nhất, khẳng định ở "only \"{n}\" is used as a substitution site" | PASS |
| BR-4 | Nội dung nói về việc của chính người dùng | Nội dung seed soạn theo bài kiểm tra BR-4 (bỏ người kia ra, câu vẫn đứng); cưỡng chế máy nằm ở `InvariantRule.recipientBehaviour` trong cổng | PASS (nội dung do reviewer đọc lại) |
| Hợp đồng §4 | `schema_id` sai → `ContentPackageFormatException`, không suy biến thành rỗng | `phase_content_repository_test.dart` → "a wrong schema_id throws instead of yielding an empty pack" | PASS |
| Hợp đồng §2 | `phase_id` là tập đóng bốn giá trị ASCII | `PhaseId` enum + "an unknown phase_id throws instead of defaulting"; "every phase of the closed set ships at least one line" | PASS |

Regression: `mobile/test/core/content/content_package_test.dart` vẫn xanh (15/15).

### Design notes for the phases downstream

- Cổng dùng thẳng `InvariantRule` của `core/content/invariant_terms.dart` làm
  kiểu vi phạm, **không** dựng enum song song như `GiftGateRule`. Gift gate cần
  enum riêng vì nó thêm luật của riêng họ nhà quà (`price_or_commerce`,
  `dangling_gift_id`, …); phase content không thêm luật nào, nên một enum thứ
  hai ở đây chính là bản sao luật mà D-15 cấm.
- `thresholds` nằm ở khoá gốc của `nudges.v1.json`, mà `ContentPackageLoader`
  không phát ra khoá gốc nào ngoài `id`/`version`/`schema_id`/`items`. Vì
  `core/content/` ngoài write scope của P1, repository tự đọc lại đúng asset đó
  qua `AssetBundle` (bundle có cache chuỗi) thay vì sửa loader dùng chung.
- `PhaseSurface.allowsWidget` / `allowsScreen` đã có sẵn cho P4/P7/P8: quyết
  định dòng nào được lên widget là **dữ liệu**, không phải nhánh `if` ở lane
  native (BR-11).
- Không phase nào sau được đọc `catalogue.drip.length` để đổi hành vi; test
  quét source `lib/features/phase_status/` sẽ đỏ nếu có.

### Next unlockable set

Theo `master-plan.md` §5, P1 đã DONE nên mở khoá đồng thời:

- **P2** (`phase-P2-phase-resolver.md`) — Depends On P1, Parallelizable YES
- **P3** (`phase-P3-counter-milestone-drip.md`) — Depends On P1, Parallelizable YES
- **P6** (`phase-P6-evening-check-in.md`) — Depends On P1, P2

Lưu ý điều phối: P6 khai Depends On **P1 và P2**, nên trong vòng dispatch kế
tiếp chỉ **P2 và P3** chạy song song được thật. P6 vào được ngay sau khi P2
xong. Critical path vẫn là P1 → P2 → P7 → P8.

## P2 – Resolver bốn pha + kho trạng thái SharedPreferences

### Files shipped

Source:

- `mobile/lib/features/phase_status/domain/solo_phase.dart`
- `mobile/lib/features/phase_status/domain/solo_phase_resolver.dart`
- `mobile/lib/features/phase_status/data/phase_status_prefs.dart`

Tests:

- `mobile/test/features/phase_status/solo_phase_resolver_test.dart`
- `mobile/test/features/phase_status/phase_status_prefs_test.dart`

Ngoài write scope khai trong phase file, một sửa **một dòng** ở test P1 —
xem "Sửa kèm theo" bên dưới. Không file nào khác bị chạm; `pubspec.yaml` không
đổi (P2 không thêm package).

### Commands run

Toolchain: `FLUTTER_SDK_PATH=$HOME/flutter` per runtime registry `mobile-app.sdk`
(`flutter` is not on PATH).

1. `flutter test test/features/phase_status/solo_phase_resolver_test.dart test/features/phase_status/phase_status_prefs_test.dart --reporter github`

```
🎉 44 tests passed.
```

26 test trong `solo_phase_resolver_test.dart` + 18 test trong
`phase_status_prefs_test.dart`.

2. `flutter test test/features/phase_status/ test/features/before_you_go/`

```
00:07 +164 ~2: All tests passed!
```

164 pass, 2 skip, 0 fail. Hai test skip là hai ảnh chụp visual-fidelity của
STORY-006 (`before_you_go_block_test.dart`), skip sẵn từ trước phase này.

3. `flutter analyze lib test --no-fatal-infos --no-fatal-warnings --suppress-analytics`

```
222 issues found. (ran in 3.6s)
```

Exit code 0 với chỉ error là fatal, nên **0 error** trên `lib test`. Con số 222
đúng bằng baseline ghi ở P1 và ở `master-plan.md` §6 — P2 không thêm mục nào.
Gate đọc theo **số error**, không đọc exit code.

### AC coverage

| AC / BR | What it demands | Where it is enforced | Result |
|---|---|---|---|
| AC-1 | Pha `dateDay` phản chiếu "trước giờ đi" của STORY-006 | `solo_phase_resolver_test.dart` → "a dismissed BeforeYouGoPhase carries its flag and card id" | PASS |
| AC-2 | `BeforeYouGoPhase == null` vẫn suy `dateDay` từ `scheduled_on` | → "a null BeforeYouGoPhase still derives dateDay from the date (AC-2)" | PASS |
| AC-3 | Story này không thành phụ thuộc ngược của STORY-006 | `BeforeYouGoPhase?` chỉ làm giàu, không tạo pha: → "BeforeYouGoPhase does not create a phase on its own" | PASS |
| AC-4 / BR-12 | Chỉ đọc trường thẻ STORY-001, không đổi `ActivityCardRepository` | Resolver nhận `List<ActivityCard>`; → "the resolver holds no repository and no content package" quét source | PASS |
| AC-5 | Bốn pha là nhãn rời rạc từ tập đóng | → "wire values are the four ASCII identifiers of contract §2", "an unknown identifier resolves to null, never to a default" | PASS |
| AC-6 | Không so sánh với lần trước, không ước lượng thời gian phản hồi | → "waiting is identical however long the invite has been out (AC-6)" | PASS |
| AC-7 | Nhánh `waiting` không sinh số ngày nào | → "the waiting branch carries no date to count from (AC-7)" + → "the phase types expose no elapsed or remaining quantity" quét `Duration`/`inDays`/`.difference(`/`elapsed` trên cả hai file domain | PASS |
| AC-15 | Ngày hẹn quá khứ không kéo pha và không sinh nội dung trách móc | → "a past scheduled date never pulls the phase to upcoming (AC-15)", "a past date loses to a future one rather than winning as nearest" | PASS |
| BR-1 / BR-2 | Rỗng là trạng thái đúng, không phải lỗi | → "no card at all is quiet, not an error state" | PASS |
| BR-3 | Không đại lượng hành vi người kia; `reply_state` là tín hiệu phản hồi duy nhất | → "the resolver reads no partner-behaviour quantity (BR-3)" quét 16 tên cột bị cấm ở `../../STORY-001_activity_card_hub/architecture/contract-summary.md` §4 | PASS |
| BR-4 | Tất định, cùng đầu vào cùng đầu ra | → "shuffling the card list never changes the answer" (20 hoán vị), "same scheduled_on/updated_at breaks the tie on ascending id", "the clock time of day does not change the phase", "the resolver reads no clock of its own" | PASS |
| Hợp đồng §2 | `phase_id` ∈ {`waiting`,`upcoming`,`date_day`,`quiet`} | `SoloPhase.wireValue` + test thứ tự bốn giá trị | PASS |
| AC-17 / BR-10 | Một thẻ đúng một lịch 23h | `phase_status_prefs_test.dart` nhóm "reminder record": khoá theo thẻ, ghi ngày dân dụng, `clearReminded` xoá khoá thay vì ghi sentinel | PASS (kho trạng thái; vòng lên lịch là P6/P7) |
| AC-30 | Tắt thông báo không làm hỏng gì | nhóm "notification toggles": hai toggle mặc định `true` **không** cần ghi lần đầu, tắt là `false` tường minh, hai toggle độc lập | PASS |
| BR-9 / AC-38 | Con trỏ nhỏ giọt theo **id bền**, không theo chỉ số | nhóm "drip cursor": `seen_ids` cộng dồn theo thứ tự, đánh dấu lại là no-op, danh sách trả về bất biến | PASS |
| ADR-010 | Không cột Drift mới, không bump `schemaVersion` | Toàn bộ trạng thái P2 nằm trong `SharedPreferences`; không file nào chạm `core/database/` | PASS |

Regression: `mobile/test/features/before_you_go/` vẫn xanh (lệnh 2).

### Sửa kèm theo ngoài write scope

`mobile/test/features/phase_status/phase_content_gate_test.dart` — test P1 "no
phase_status source redeclares an invariant term" so **chuỗi con** từng từ cấm
với source đã bóc chuỗi/chú thích. Khoá `phase_status.drip.seen_ids` do chính
phase file P2 chốt nguyên văn, nên định danh `dripSeenIds`/`markDripSeen` chứa
chuỗi con `seen` và làm test đỏ dù không có bản sao luật nào.

Sửa: so theo **từ đứng riêng** (`_standaloneTerm`, lookaround
`(?<![a-z0-9_])…(?![a-z0-9_])`) thay vì chuỗi con. Cố ý **không** dùng `\b`: một
số từ cấm mở/đóng bằng ký tự tiếng Việt ngoài ASCII, mà `\b` của Dart chỉ tính
ranh giới ASCII, nên `\b` sẽ âm thầm trượt đúng những từ mà phép quét này sinh ra
để bắt. Phạm vi test không đổi: nó vẫn bắt một từ cấm đứng riêng trong source,
chỉ thôi bắt định danh camelCase có chứa từ đó.

### Design notes for the phases downstream

- `PhaseResolution` **cố ý không có** trường số lượng nào (không `daysUntil`,
  không `Duration`). P4/P7 muốn đếm ngược thì tự suy từ `scheduledOn`, mà
  `scheduledOn` là `null` ở đúng những nhánh cấm đếm (`waiting`, `quiet`). Đây
  là cách rẻ nhất giữ AC-6/AC-7 đúng qua mọi consumer.
- So sánh ngày làm **thuần chuỗi** `YYYY-MM-DD` (`compareTo`), không `DateTime`
  arithmetic. Nhờ vậy không có instant, không múi giờ, không nửa đêm trong toàn
  bộ đường đi, đúng như `scheduled_on` của STORY-001.
- `civilDateIso` dùng lại từ `before_you_go_resolver.dart`, không chép lại. Đây
  là file P2 đã được phase file cho phép consume.
- Thẻ `scheduled` có ngày quá khứ bị **bỏ qua** ở bước 1 chứ không gộp vào
  `upcoming`. Consumer đừng "sửa" điều này: pha suy từ một ngày đã lỡ chính là
  nội dung trách móc AC-15 cấm.
- `beforeYouGo?.cardId` thắng `nearest.id` ở nhánh `dateDay` vì AC-1 nói pha này
  **phản chiếu** STORY-006. P7 (dòng trạng thái + đếm ngược) và P4 (payload
  widget) dùng thẳng `PhaseResolution.cardId`, không tự tra lại thẻ.
- `PhaseStatusPrefs` đã có sẵn cả sáu khoá cho P3 (milestone), P6 (toggle +
  `reminded_on`) và P7. Đừng thêm khoá `SharedPreferences` thứ bảy ở feature
  khác cho cùng mục đích.

### Next phase

Theo `master-plan.md` §5, sau khi P2 DONE:

- **P3** (`phase-P3-counter-milestone-drip.md`) — Depends On P1, sẵn sàng ngay
- **P6** (`phase-P6-evening-check-in.md`) — Depends On P1, P2 → vừa mở khoá
- **P7** (`phase-P7-phase-line-and-countdown.md`) — Depends On P2 → vừa mở khoá,
  Parallelizable NO
- **P4** (`phase-P4-widget-bridge-android.md`) — Depends On P2, P3, nên chờ P3
- Critical path vẫn P1 → P2 → P7 → P8; P8 còn chờ cả P3.

## P7 – Dòng trạng thái theo pha + đếm ngược trên màn (1)

### Files shipped

Mới:

- `mobile/lib/features/phase_status/presentation/phase_status_line.dart` —
  widget dòng trạng thái (primary + secondary) và `civilDaysUntil`, hàm đếm
  ngày dân dụng duy nhất của story. Không chuỗi hiển thị nào nằm trong file này.
- `mobile/lib/features/phase_status/presentation/phase_status_cubit.dart` —
  `PhaseStatusCubit` (điểm giải pha **duy nhất** của màn (1)),
  `PhaseStatusState`, và cổng `PhaseWidgetPublisher`.
- `mobile/test/features/phase_status/phase_status_line_test.dart` — 18 test +
  4 ảnh chụp `RepaintBoundary`.

Sửa:

- `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart`
- `mobile/lib/features/activity_cards/presentation/widgets/activity_card_tile.dart`
- `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart`

Sửa đường dẫn write scope: phase file §1B ghi ba file sửa nằm thẳng dưới
`presentation/`, thực tế repo đặt chúng ở `presentation/screens/` và
`presentation/widgets/`. Cùng ba file, chỉ khác thư mục con; không file thứ tư
nào bị chạm (`git diff` trên `mobile/lib` đúng 3 file).

### Commands run

Toolchain: `FLUTTER_SDK_PATH=$HOME/flutter` per runtime registry `mobile-app.sdk`
(`flutter` is not on PATH).

1. `flutter test test/features/phase_status/phase_status_line_test.dart --dart-define=CAPTURE_VISUALS=true`

```
00:01 +18: All tests passed!
```

Bốn ảnh `VISUAL-FIDELITY` được sinh trong lần chạy này.

2. `flutter test test/features/activity_cards test/features/phase_status`

```
+306 ~6: 6 skipped tests.
+306 ~6: All other tests passed!
```

306 pass, 6 skip, 0 fail. Sáu test skip = 4 ảnh chụp của phase này + 2 ảnh
STORY-006 đã skip sẵn; chúng chỉ chạy khi có `--dart-define=CAPTURE_VISUALS=true`
(xem lệnh 1).

3. `flutter analyze lib/features/phase_status lib/features/activity_cards test/features/phase_status test/features/activity_cards`

```
9 issues found. (ran in 2.4s)
```

**0 error.** 7/9 là `prefer_initializing_formals` có sẵn trong
`activity_cards`; 2 mục còn lại là cùng lint đó trên
`phase_status_cubit.dart:68,70`. Lint này **không sửa được** ở đây: Dart cấm
tham số **có tên** mang định danh private, nên `{required this._repository}`
không hợp lệ, và 18+ chỗ khác trong repo (`pair_gate_shell.dart`,
`activity_card_list_cubit.dart`, …) đang mang đúng hình dạng này trong baseline
222. Delta so với baseline: **+2 info, +0 warning, +0 error**.

4. `flutter test` (toàn bộ) — `+601 ~9 -3`

Ba test đỏ nằm trọn trong `test/design_system/` và **có sẵn từ trước** phase này:

| Test đỏ | Nó tố cáo dòng nào | Có trong diff P7 không |
|---|---|---|
| `shared_backdrop_occlusion_guard_test.dart` AC2 | `activity_card_detail_screen.dart:371` + `reminder_schedule_screen.dart:79` (`Scaffold(backgroundColor:)`) | Không — hunk sớm nhất của P7 ở dòng 436 |
| `no_fork_guard_test.dart` AC 4 | 7 vị trí `Colors.` / `Platform.is` ở `context_notebook`, `quick_capture_sheet`, `gift_ideas`, `invite_composer`, `service_locator`, `activity_card_detail_screen.dart:616` | Không — diff P7 không chứa chuỗi `Colors.` nào |
| `shared_backdrop_occlusion_test.dart` "chat …" | `pumpAndSettle timed out` trên route chat | Không — P7 không chạm `chat` |

`git diff <BaseHead> -- mobile/lib` chỉ có 3 file (hub view, tile, detail
screen) nên không dòng nào trong ba lỗi trên do P7 sinh ra. Đây là nợ của story
khác, ghi lại chứ không tự sửa trong phạm vi P7.

### AC coverage

| AC / BR | What it demands | Where it is enforced | Result |
|---|---|---|---|
| AC-1 / AC-37 | Bốn pha hiện đúng dòng của mình, lấy từ gói, không chuỗi cứng | nhóm "the phase line draws the shipped copy for each phase" — test so với item đọc **từ chính gói** (`_screenItem`), không chép chuỗi vào test | PASS |
| AC-2 | `BeforeYouGoPhase == null` vẫn ra `dateDay` | → "date day says today, with no number at all" (store không có `BeforeYouGoPhase`) | PASS |
| AC-5 | Pha `waiting` trỏ vào một việc chuẩn bị | → "waiting points at a preparation action (AC-5)" | PASS |
| AC-6 / AC-7 / BR-3 | Không đếm ngày chờ, không leo thang, không chỉ báo hành vi người kia | → "AC-6/AC-7: the waiting line carries no digit anywhere" quét **mọi** `Text` trên cây; và cubit chỉ tính `days` khi `phase == upcoming` | PASS |
| AC-9 / AC-10 | Widget khớp pha của thẻ gần nhất và làm mới cùng lúc màn (1) | nhóm "the widget payload is published from the same resolution": đúng **một** lần mỗi mount, thêm một lần sau `resumed`, và pha `quiet` vẫn publish | PASS |
| AC-14 | Đếm ngược tới ngày hẹn, theo ngày | → "AC-14: a future date counts whole days, with no clock time" + "the day of the date reads as today rather than as zero days" | PASS |
| AC-15 | Ngày đã qua hiện trung tính | → "AC-15: a past date is drawn plainly, with no countdown and no elapsed count" | PASS |
| AC-37 / BR-15 | Không chuỗi hiển thị trong mã widget | → "no display string is written in phase_status_line.dart" — bóc chú thích rồi khẳng định không chuỗi nào của gói xuất hiện **và** không ký tự có dấu tiếng Việt nào tồn tại | PASS |
| BR-2 | Pha không nội dung → không khung rỗng | → "quiet has no screen line yet and collapses to nothing" + "nothing to say renders as nothing, not as an empty row" (`SizedBox` kích thước `Size.zero`) | PASS |
| BR-4 | Tất định | `civilDaysUntil` thuần hàm, `today` bơm qua seam; → "the day count is civil days, and negative once the date has passed" | PASS |
| `WIDGET-STALE` | Làm mới khi mount và khi quay lại foreground, **không** timer | `_ActivityCardHubBodyState with WidgetsBindingObserver`; test "exactly once per mount" chứng minh sliver rebuild không kích hoạt lần giải pha thứ hai | PASS |
| `VISUAL-FIDELITY` | Ảnh chụp bốn pha đối chiếu thiết kế | `../visual-fidelity/implemented-hub-{waiting,upcoming,date_day,quiet}.png` | PASS |

Regression: toàn bộ `mobile/test/features/activity_cards/` vẫn xanh (lệnh 2);
không `tap()` nào trượt vì màn cao thêm, nên không phải nới khung test.

### Visual fidelity

Khung 412×915, `devicePixelRatio: 1`, font thật nạp từ `assets/fonts/`
(Nunito / Roboto / Roboto Mono / Material Symbols Rounded).

| Ảnh | Đối chiếu |
|---|---|
| `implemented-hub-waiting.png` | Dòng "Chuẩn bị dần cho buổi tới" + phụ đề, **không chữ số nào**, thẻ `Đi xem phim` không đếm ngược | khớp |
| `implemented-hub-upcoming.png` | "Còn 4 ngày tới buổi đã hẹn" trên dòng chính, "còn 4 ngày" trên thẻ — cùng một con số từ cùng một hàm | khớp |
| `implemented-hub-date_day.png` | "Hôm nay là ngày đã hẹn" + thẻ đọc "Hôm nay", không phải "còn 0 ngày" | khớp |
| `implemented-hub-quiet.png` | Không dòng trạng thái, không khung rỗng — thẻ nằm ngay dưới hàng lọc | khớp |

Đã soi từng ảnh: dấu tiếng Việt (`ầ`, `ị`, `ẹ`, `ã`, `ự`, `ấ`) và icon Material
Symbols đều dựng đúng, không ô tofu nào.

Ghi chú về harness: bản chụp đầu tiên để nền `RepaintBoundary` **trong suốt**,
khiến mọi viền khử răng cưa của dòng chính trông bạc màu khi mở file bằng trình
xem có nền sáng — đo pixel cho thấy chữ vẫn đạt đúng `colorText` `#F7EEFB` ở
alpha 255. `_capture` nay lót một `ColoredBox(colors.colorBackground)` dưới app
trước khi chụp, nên PNG đục hoàn toàn và đọc được đúng như trên thiết bị.

### Hai điểm cần Scrum Master / Reviewer quyết

1. **Ảnh của STORY-002 sẽ đổi khi P7 merge.** Lần chạy `flutter test` toàn bộ
   làm hai file dựng lại khác byte:
   `STORY-002_invite_message_composer/visual-fidelity/implemented-chi-tiet-the-da-hen-ngay-ios-cho-hen.png`
   và `.../implemented-11-chuan-bi-chon-hanh-dong-ios.png`. Cả hai chụp **màn
   chi tiết thẻ**, nơi P7 vừa chèn dòng đếm ngược — nên khác biệt là **thật**,
   không phải nhiễu. Chúng nằm ngoài write scope của P7 nên đã được
   `git checkout` trả về bản đã commit; bản dựng lại giữ tạm ở
   `/tmp/story012-collateral/`. Quyết định làm mới bằng chứng STORY-002 thuộc về
   Scrum Master, không phải phase này.
2. **Thư mục `visual-fidelity/` của STORY-012 không có trong write scope của
   handoff.** Phase file §6 lại bắt buộc chụp ảnh per-story. Bốn PNG do **tiến
   trình test** ghi ra (không phải bằng công cụ Write/Edit). Nếu write scope là
   bản chuẩn thì nó thiếu đúng một đường dẫn mà chính phase file đòi.

### Sửa trích dẫn AC trong phase file

`phase-P7-phase-line-and-countdown.md` §4 ghi "AC-9..AC-11" cho đếm ngược và
"AC-33" cho đồng bộ widget. Theo `requirements/requirements.md`: Nhóm C
(AC-9..AC-13) là widget, Nhóm D (AC-14/AC-15) mới là đếm ngược, còn AC-33 là
luật "không chỉ báo hành vi người kia" của Nhóm I. Đã sửa hai id trong phase
file về đúng nhóm và ghi chú ngay tại chỗ; yêu cầu thực chất không đổi, và bảng
AC coverage ở trên dùng id đã sửa.

### Design notes for the phases downstream

- `PhaseWidgetPublisher` (cổng `pushWidgetPayload`) do **P7 khai**, vì P4 chưa
  làm. P4 chỉ cần `implements PhaseWidgetPublisher` rồi đăng ký vào DI; đừng
  tạo cổng thứ hai và đừng gọi kênh nền tảng thẳng từ view.
- Pha `quiet` hiện **không có** item nào `allowsScreen` mà P7 điền được, vì câu
  của nó cần `{n}` (bộ đếm kỷ niệm của P3). Cubit bỏ qua item thiếu số thay vì
  điền 0 — nhờ đó `waiting` **về mặt cấu trúc** không thể sinh chữ số (AC-7).
  Khi P3/P8 cấp được `{n}`, `quiet` sẽ tự hiện mà không phải sửa widget.
- `_anchorIndex` chèn dòng trạng thái **phía trên thẻ neo** ngay trong
  `SliverChildBuilderDelegate` sẵn có, nên danh sách vẫn lazy. P8 muốn thêm bề
  mặt thì mở rộng `PhaseStatusState`, đừng thêm sliver thứ hai.
- `civilDaysUntil` là hàm đếm ngày **duy nhất**; thẻ ở hub, màn chi tiết và
  dòng trạng thái đều gọi nó, nên ba chỗ không thể lệch nhau.
- Cả hai lần đọc (kho thẻ, gói nội dung) bọc `try/catch` → phát state rỗng.
  Hỏng kho để lại danh sách thẻ nguyên vẹn và mất đúng dòng trạng thái (BR-2).

### Next phase

- **P8** (`phase-P8-counter-and-quiet-surfaces.md`) — Depends On P3 **và** P7;
  P7 xong nên P8 chỉ còn chờ P3. P8 mở rộng chính `PhaseStatusCubit` và chính
  `activity_card_hub_view.dart` này.
- **P4** (`phase-P4-widget-bridge-android.md`) — cổng `PhaseWidgetPublisher` đã
  sẵn; vẫn chờ P3.
- **P3** (`phase-P3-counter-milestone-drip.md`) — Depends On P1, chưa bắt đầu,
  đang chặn cả P4 lẫn P8.
