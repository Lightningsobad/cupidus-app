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
| P7 | Mobile Developer | NOT_STARTED | — |
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
