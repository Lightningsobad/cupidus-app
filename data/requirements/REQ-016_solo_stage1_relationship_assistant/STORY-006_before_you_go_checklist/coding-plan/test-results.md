# STORY-006 — Test Results

## Phase P1 — Gói nội dung, resolver tất định, và cổng nhập

- Date: 2026-09-11
- Lane: Mobile
- Working dir cho mọi lệnh: `mobile/` trong story worktree
  `story-REQ-016_solo_stage1_relationship_assistant-STORY-006_before_you_go_checklist`

### Commands

| # | Command | Result |
|---|---|---|
| 1 | `flutter analyze lib/features/before_you_go test/features/before_you_go` | PASS — `No issues found! (ran in 1.7s)` |
| 2 | `flutter test test/features/before_you_go/` | PASS — `+64: All tests passed!` |
| 3 | `flutter test test/features/context_notebook/context_content_gate_test.dart test/features/gift_ideas/gift_content_gate_test.dart` | PASS — `+65: All tests passed!` |

Lệnh 3 không nằm trong phạm vi bắt buộc của phase nhưng phải chạy: hai cổng nhập
này quét **toàn bộ** `lib/` để chặn lexicon bất biến bị khai báo lần thứ hai và
chặn nhãn gói bị chép vào Dart. Thêm một module `lib/` mới là đúng đầu vào của
hai test đó, nên chúng là hồi quy trực tiếp chứ không phải chạy rộng.

Không chạy `flutter test` / `flutter analyze` toàn repo: repo có lỗi tồn đọng
đã theo dõi ở `BUG-20260907-001` / `BUG-20260908-001`.

### Coverage đối chiếu `## 4. Acceptance Criteria` của phase P1

| Acceptance criterion | Test | Kết quả |
|---|---|---|
| Gói ship parse được, `schemaId == 'req016.before_you_go.v1'` | `the pack exists on disk and parses under the pinned schema id` | PASS |
| Mọi `items[].id` duy nhất và ASCII | `every shipped row id is unique and ASCII` | PASS |
| Tất định — cùng (thẻ, ngày, gói) → cùng danh sách (AC-10) | `the same inputs give the same rows twice running (AC-10)` | PASS |
| Đúng ba dòng + chia sẻ vị trí, không dòng nào khác (AC-7) | `price, distance, and booking give three rows plus share location` | PASS |
| Thẻ `indoor` không bao giờ ra dòng áo mưa (AC-8) | `indoor never gives the rain row, rainy month or not (AC-8)` | PASS |
| Thiếu trường → dòng phụ thuộc vắng mặt, không mặc định (AC-9) | nhóm `a missing field drops its row, it is never defaulted (AC-9/BR-4)`, 4 test | PASS |
| `location` không khớp alias → `rainySeason == null` → không dòng áo mưa | `a location matching no alias leaves rainySeason null` | PASS |
| Gói 0 dòng resolve thành danh sách rỗng, không ném (AC-30) | `a pack trimmed to zero rows resolves to an empty list (AC-30)` | PASS |
| Cổng nhập thực sự bắt được vi phạm (negative control) | nhóm `negative control: the gate rejects a violating row (AC-31)`, 18 test | PASS |

### Negative control của cổng nhập — không vacuous

18 test trong nhóm `negative control`. 17 test dựng một dòng **vi phạm** và
assert cổng trả về đúng luật bị vi phạm; test thứ 18 (`a clean functional row
reports nothing`) là đối chứng dương để chứng minh 17 test kia không xanh vì
cổng luôn kêu.

- Sáu luật bất biến dùng chung (`flattery`, `percent_display`,
  `streak_display`, `score_or_ratio`, `recipient_behaviour`,
  `manipulative_tone`) — lexicon đọc từ `core/content/invariant_terms.dart`,
  **không** khai báo lại. Test `every shared invariant rule has a name in this
  gate (D-15)` khoá ánh xạ này.
- Hai luật riêng của họ gói này: `completion_count` (AC-27, đếm số lần hoàn
  thành) và `partner_directed_tone` (BR-14, giọng điệu nói về người kia).
- Luật lược đồ: id không ASCII, id trùng, nhãn rỗng, nhãn quá 60 ký tự, icon
  ngoài allowlist, `when` rỗng, tháng ngoài 1..12, alias thuộc hai miền.
- `the violation names the offending row` assert vi phạm nêu đúng `id` dòng vi
  phạm chứ không phải dòng sạch bên cạnh.

### Chuỗi cứng và nguồn dữ liệu (AC-29/BR-15)

- `no shipped row label is written into any Dart file (AC-29/BR-15)` quét
  `lib/features/before_you_go/**` đối chiếu với danh sách nhãn **đọc từ gói
  trên đĩa**, không phải hằng chép tay.
- `the distance threshold is data, not a Dart constant` xác nhận ngưỡng khoảng
  cách nằm trong `when` của dòng `fuel` trong JSON.
- `no path in this module reads the clock directly (AC-10)` quét module, không
  file nào gọi đồng hồ trực tiếp; ngày luôn là tham số.

### DSL đóng — lỗi lược đồ ném lúc load (11 test)

Fact lạ (`priceVND`), toán tử lạ (`greaterThan`), action lạ (`shareLocation`),
khoá lạ trong item, khoá lạ trong mệnh đề, `when` rỗng, toán tử một ngôi mang
`value`, so sánh không có số, `order` không phải int, `schema_id` khác, và id
trùng — tất cả ném `ContentPackageFormatException`, không degrade.

### Ghi chú hợp đồng

`architecture/contract-summary.md` §1 minh hoạ khoá phong bì là `schemaId`,
nhưng `core/content/content_package.dart` (hạ tầng dùng lại, ngoài write scope
của phase) đọc khoá JSON `schema_id`. Gói ship dùng `schema_id` cho khớp hạ
tầng; thuộc tính Dart `ContentPackage.schemaId` vẫn bằng
`req016.before_you_go.v1` đúng như AC yêu cầu. Mọi gói `req016` hiện có cũng
dùng `schema_id`.

`mobile/pubspec.yaml` đã khai báo `assets/data/req016/`, nên gói mới vào bundle
mà không cần sửa pubspec.

## Phase P2 — khối màn chi tiết và đóng/mở lại

Ngày chạy: 2026-09-11. Thư mục làm việc: `mobile/`.
`flutter` không nằm sẵn trên PATH của máy này; mọi lệnh chạy sau
`export PATH="$HOME/flutter/bin:$PATH"`.

| # | Lệnh | Kết quả |
| --- | --- | --- |
| 1 | `flutter analyze lib/features/before_you_go` | PASS — `No issues found!` |
| 2 | `flutter test test/features/before_you_go/before_you_go_dismissal_store_test.dart` | PASS — `+6` |
| 3 | `flutter test test/features/before_you_go/before_you_go_block_test.dart` | PASS — `+15 ~2` (2 skipped là nhóm chụp ảnh, chỉ chạy khi bật dart-define) |
| 4 | `FLUTTER_ROOT="$HOME/flutter" flutter test test/features/before_you_go/before_you_go_block_test.dart --dart-define=CAPTURE_VISUALS=true --plain-name="visual fidelity capture"` | PASS — `+2`, ghi ra 2 ảnh |
| 5 | `flutter test test/features/before_you_go/ test/features/activity_cards/` | PASS — `+298 ~4`, không có hồi quy |
| 6 | `flutter analyze lib/features/before_you_go lib/features/activity_cards test/features/before_you_go` | 7 `info` `prefer_initializing_formals`, tất cả nằm trong file P2 không đụng tới (`activity_card_repository_impl.dart:21,22,23`, `occasion_suggestion_service.dart:110`, `activity_card_detail_cubit.dart:76`, `activity_card_list_cubit.dart:102,103`); `before_you_go` sạch |

Lệnh 5 là cổng hồi quy §6 yêu cầu: khối mới thêm chiều cao vào cột màn chi tiết
nhưng không đẩy `tap()` nào của suite cũ ra ngoài khung, nên không phải chỉnh
`physicalSize` hay `scrollUntilVisible` ở test có sẵn.

### Kho lưu trữ đóng (6 test)

Khoá đúng hợp đồng STORY-012 `before_you_go.dismissed_on.<cardId>` và **chỉ**
khoá đó được ghi; `reopen` xoá khoá chứ không để chuỗi rỗng; mỗi thẻ giữ ngày
riêng; khoá ghi từ hôm trước vẫn đọc được và tự thành cũ (không cần job dọn);
accessor tiêm vào là đường duy nhất chạm đĩa.

### Khối trên màn chi tiết (15 test)

Hiện/ẩn theo AC-1/AC-2/AC-3/AC-14 (hôm nay mở sẵn; hôm qua, ngày mai, thẻ ý
tưởng/đã xong/kỷ niệm đều không dựng gì; resolve rỗng thì giấu cả tiêu đề và màn
vẫn cuộn); đúng một hành động chính cấp thẻ với nhãn không đổi (AC-4); đóng →
sống sót qua lần mở màn lại trong cùng ngày → `Mở lại` khôi phục (AC-16/AC-17);
đóng chỉ ghi khoá dismissal và không đổi `status` của thẻ (BR-8); một chạm mở
sheet đúng một lần và không ghi lại gì (AC-18/AC-19/AC-20); bỏ qua dòng chia sẻ
không chặn gì, không cảnh báo gì (AC-21); nội dung vẫn là dữ liệu (AC-29: không
nhãn nào của gói ship xuất hiện dạng literal trong Dart; map icon của widget phủ
đúng allowlist của gate; mọi nhãn hiển thị đều truy về gói).

Test đọc **gói ship trên đĩa** chứ không dựng gói inline, nên nếu widget lệch
khỏi nội dung đã ship thì test đỏ chứ không lặng.

### Ảnh chụp thị giác

- `visual-fidelity/design-reference-sb-211-truoc-gio-di-ios.png`
- `visual-fidelity/implemented-sb-211-truoc-gio-di-ios.png`
- `visual-fidelity/implemented-sb-211-truoc-gio-di-ios-collapsed.png`
- Báo cáo: `visual-fidelity/visual-fidelity-report.md` (`VISUAL_FIDELITY: PASS`,
  kèm 6 mục `DESIGN_SPEC_CONFLICT` cần người dùng phân xử)

### Lệch cần ghi nhận (ngoài write scope của P2, không sửa ở đây)

- `ux/uiux-spec.md` §2 gọi icon `ev_station` và nhãn "Đổ xăng / sạc xe trước khi
  đi", "Xác nhận lại chỗ đã đặt"; gói ship từ P1 dùng `local_gas_station`,
  "Đổ xăng hoặc sạc pin trước khi đi", "Gọi đặt chỗ trước". Widget bám gói ship
  vì AC-29 đặt nội dung ở gói.
- `test/features/activity_cards/activity_card_detail_screen_test.dart` dùng
  fixture `scheduledOn: '2026-10-01'`. Đúng ngày lịch đó khối sẽ tự bật trong
  các test có sẵn ấy. File nằm ngoài write scope của P2.

## Entry Point Reachability

`Reachable: YES` — khối đến được từ `main()` đã ship, không qua harness preview,
không thêm route.

| Bước | Bằng chứng tại HEAD hiện tại |
| --- | --- |
| 1. Màn (1) — danh sách thẻ hoạt động | Bề mặt người dùng đã tồn tại trước story này; `story_master.md` §System Integration ghi "Existing user-visible surface: YES — chi tiết thẻ ở màn (1)" |
| 2. Chạm một thẻ trạng thái *Đã hẹn ngày* có `scheduledOn` = hôm nay | Điều hướng có sẵn của màn (1) sang chi tiết thẻ; story này không đụng vào nó |
| 3. `ActivityCardDetailScreen` dựng thân màn | `_ActivityCardDetailBodyState.build`, `Column` trong `SliverList` |
| 4. `BeforeYouGoSection` tự mở | `activity_card_detail_screen.dart:455`, đặt ngay sau `_primaryAction(context, state, cubit)` ở dòng 450, trước `SizedBox(height: CupidSpacing.xl)` ở dòng 460 |

Không có route mới, không có mục menu mới, không có công tắc bật. `BeforeYouGoSection`
luôn được gắn vào cây; nó tự quyết định vẽ hay trả `SizedBox.shrink()` theo
`(status == scheduled && scheduledOn == today)` — đúng AC-1/AC-6, và AC-2/AC-3 là
nhánh `shrink`.

Đường đi này được kiểm bằng test chứ không chỉ bằng mắt: 15 test hành vi ở
`before_you_go_block_test.dart` **pump `ActivityCardDetailScreen` thật** với
repository giả (yêu cầu của phase §6 "Mobile discoverability / navigation
integration"), không pump `BeforeYouGoBlock` rời. Nếu điểm mount bị gỡ khỏi màn
chi tiết thì các test đó đỏ.

## Story Runtime Startup Smoke

**Result: PASS**

Chạy trên `main()` đã ship, không phải `main_preview.dart`.

Runtime registry entry: `data/devops/system/runtime-command-registry.json` →
`mobile-app` (`path: mobile`, `buildCommand: flutter build apk --debug`).
Thiết bị: `emulator-5554` (`sdk_gphone64_arm64`, `device:emu64a`), đã ở trạng thái
`device` từ trước — tái sử dụng, không boot AVD mới.

```
flutter build apk --debug --flavor local -t lib/main.dart --split-per-abi
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-local-debug.apk
adb shell am force-stop com.snapsofts.cupid
adb shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
```

| Tín hiệu | Kết quả |
| --- | --- |
| Build | `✓ Built build/app/outputs/flutter-apk/app-arm64-v8a-local-debug.apk`, exit 0 |
| Install trên `emulator-5554` | `Success` |
| `am start -W` | `Status: ok`, `LaunchState: COLD`, `TotalTime: 7791`, `WaitTime: 7806` |
| Readiness probe (`dumpsys activity activities`) | `topResumedActivity=…com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` |
| `FATAL EXCEPTION` trong logcat | 0 |
| `E/flutter` trong logcat | 0 |

Màn hình đầu tiên: `../visual-fidelity/runtime-smoke-main-first-screen-emulator-5554.png`
— **chính là màn (1)**, tab `Muốn làm`, đã vẽ xong hoàn toàn (tiêu đề "Bắt đầu từ
một điều nhỏ nhé.", hai thẻ hành động "Dán cái link vừa thấy" / "Để mình mách cho,
theo dịp gần nhất", ba chip `Gợi ý quà` / `Mồi chuyện` / `Vỏ hoàng đạo`, thanh
điều hướng dưới đủ 4 mục), không phải khung splash. Ảnh đã được xem tận mắt: chữ
tiếng Việt có đủ dấu, không ô tofu, biểu tượng dựng đúng.

Đây cũng là bằng chứng runtime cho mục `## Entry Point Reachability` ở trên: bước
1 của đường đi — màn (1) — có thật trong bản build `main()` và là màn đầu tiên
người dùng thấy sau khi đăng nhập. Danh sách thẻ đang rỗng trên thiết bị này nên
smoke dừng ở đó; khối "Trước giờ đi" đã được chứng minh bằng 15 test dựng
`ActivityCardDetailScreen` thật, và bằng ảnh chụp `RepaintBoundary` ở mục
`### Ảnh chụp thị giác`.

Hai trở ngại hạ tầng gặp phải và cách xử lý, ghi lại để lần sau khỏi mất thời gian:

1. **Đĩa máy chủ đầy.** Lần chạy đầu `flutter build apk --debug --flavor local`
   gặp lỗi thoát mã 255 với `java.io.IOException: No space left on device`; `df -h /`
   khi đó còn 250 MiB trên 460 GiB. Sau khi đĩa được giải phóng (còn 10 GiB) lệnh
   build y nguyên chạy lại và PASS exit 0. Không sửa gì trong code để vượt qua.
2. **Đĩa thiết bị đầy.** APK debug gộp mọi ABI nặng 521 MB, vượt chỗ trống
   `/data/user/0` (≈890 MB), nên `adb install` trả
   `INSTALL_FAILED_INSUFFICIENT_STORAGE`. `--target-platform android-arm64` không
   giảm kích thước (assets chỉ 15 MB, phần nặng là native debug libs), nhưng
   `--split-per-abi` cho `app-arm64-v8a-local-debug.apk` chỉ 109 MB và cài được.
   Bản cài cũ được gỡ bằng `adb shell cmd package uninstall -k` — cờ `-k` **giữ
   nguyên data/cache**, nên phiên đăng nhập đã seed sẵn trên thiết bị không bị
   xoá (đó là lý do ảnh chụp ra thẳng màn (1) chứ không phải màn đăng nhập).

Cả hai đều là hạ tầng máy/thiết bị, không phải hồi quy sản phẩm, và không có thay
đổi source nào cho pass này.
