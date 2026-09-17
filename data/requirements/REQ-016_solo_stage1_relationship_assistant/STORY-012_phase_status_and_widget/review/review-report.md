# Review Report: STORY-012 Trạng thái theo pha, widget, và bộ đếm "của cải đang lớn"

Outcome: PATCH_REQUIRED

Reviewer: Iris-QC · Ngày: 2026-09-17 · Mode: `final-synthesis` (lượt S7)
Thay thế toàn bộ báo cáo cũ (`Outcome: BLOCKED`, B-1 `REVIEW_SCOPE_TOO_BROAD`),
vốn là phán quyết về **phạm vi handoff**, không phải về mã.
Scope gate: `review/scope-gate.md` (`SCOPE_GATE_COMPLETE: YES`)
Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`

## Baseline Correction

Handoff khai `BaseHead: 27c0a7e8e27e88ece9841a3ee00b2aedd0e11795`, nhưng đó
chính là HEAD hiện tại của worktree, nên mọi diff theo nó trả về **rỗng**
(đã đo: `git diff --stat 27c0a7e8 -- <2 tệp S7>` không ra dòng nào). Lượt này
dùng cùng base mà S6a/S6b đã dùng,
`b58afbe073eff4e1ebb9151735221532a9cf5a82` (= `git merge-base HEAD
codex/REQ-016_..._-integration`, HEAD đi trước 14 commit). Diff thật:
**95 tệp**, trong đó ~56 tệp nguồn/test/cấu hình.

## Cơ sở tổng hợp

7 lát cắt, tất cả `REVIEW_SLICE_COMPLETE: YES`:

| Lát | Phạm vi | Kết quả lát | Test |
|---|---|---|---|
| S1 | P1 gói nội dung + cổng bất biến | AC-1(nửa nội dung)/AC-37/AC-38/AC-39 PASS | `+35` |
| S2 | P2+P7 resolver, dòng pha, đếm ngược | AC-2/AC-3/AC-14/AC-15 + R-1b PASS | `+58 ~4` |
| S3 | P4 cầu nối + provider Android | AC-9..AC-13 PASS, `WIDGET-STALE` nửa (a) PASS | `+47` |
| S4 | P5 extension iOS WidgetKit | AC-9..AC-13 (phía native) PASS | không có test Dart |
| S5 | P6 nhắc 23h + thu hẹp guard chéo yêu cầu | AC-4 PASS, không rò rỉ dependency | `+46 ~1` |
| S6a | P3 bộ đếm, cột mốc J12, nhịp nhỏ giọt | AC-5/AC-6/BR-2/BR-4/BR-9/BR-14 PASS | `+33` |
| S6b | P8 bề mặt khoảng lặng + tích hợp hub/thẻ | mọi cổng AC/BR đã nêu PASS (trừ F-1, F-2) | `+12`, `+7`, `+1 ~1`, suite `+439 ~8` |

Không lát nào phát sinh finding mức BLOCKER ở tầng mã. **Phán quyết
`PATCH_REQUIRED` không đến từ các lát cắt** — nó đến từ cổng đối chiếu thiết kế
ở mục kế tiếp, thứ mà không lát cắt nào sở hữu.

## Độ phủ tệp (kiểm tra của lượt S7)

`git diff --name-only b58afbe0 HEAD` trừ đi toàn bộ kiểm kê S1-S6b + 2 tệp
S7 → phần còn lại **chỉ gồm artifact tài liệu/bằng chứng**, đúng một ngoại lệ
là tệp cấu hình sản xuất thật:

- `mobile/android/app/build.gradle.kts` (+8): xuất hiện **sau** khi scope-gate
  được viết (lượt sửa desugaring ngày 2026-09-17) nên không nằm trong kiểm kê
  của lát nào. **S7 đã review trực tiếp: PASS.**
  `isCoreLibraryDesugaringEnabled = true` trong `compileOptions`, khối
  `dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") }`
  ở mức module. `sourceCompatibility`/`targetCompatibility` giữ
  `VERSION_17`, `minSdk` vẫn đọc từ `flutter.minSdkVersion` — không hạ gì.
  Version `2.1.4` khớp đúng build file của chính
  `flutter_local_notifications-22.3.1`, không phải số chọn bừa.

Kết luận: không có tệp mã nào lọt khỏi vòng review.

## Hai tệp độc quyền của S7

### 1 · `mobile/lib/l10n/arb/app_en.arb` (+10/-1) — PASS

- 9 khoá mới, khớp **1-1** với 9 khoá mà `app_vi.arb` thêm (`notifs_row_*` ×4,
  `evening_check_in_*` ×5). Không lệch parity, không khoá mồ côi.
- `mobile/l10n.yaml:2` khai `template-arb-file: app_vi.arb`, nên việc
  `app_en.arb` **không** mang metadata `@key` là đúng vai trò tệp dịch, không
  phải thiếu sót. Placeholder `{count}` của
  `evening_check_in_photos_attached` có mặt ở cả hai locale và được khai
  `"type": "int"` ở template — `gen-l10n` sinh ra chữ ký thống nhất.
- R-15a/BR-15: cả 9 khoá đều là **chrome** (nhãn nút, gợi ý ô nhập, mô tả hàng
  cài đặt), không một câu nội dung story nào. Nội dung pha/nhắc/nhỏ giọt vẫn
  nằm trọn trong ba gói JSON như S1 xác lập. Không mâu thuẫn với kết luận
  "không chuỗi hiển thị trong mã" của S6b.
- Nhất quán dữ kiện: bản EN `"Once a week at most."` khớp trần
  `dripMinimumDaysBetweenShows = 7` mà S6a đã đo — lời hứa trong cài đặt không
  lệch khỏi thứ policy thực thi.

### 2 · `deployment/configuration-guide.md` (+140, mới) — PASS có điều kiện, 2 finding

Nội dung đúng và hữu ích: bảng định danh dùng chung, quy tắc 9 configuration,
thứ tự phase Embed, yêu cầu App Group phía Apple Developer portal, và mục
"Recovery After Regeneration" — đúng lớp rủi ro mà `flutter create .` hay một
lần merge lấy "theirs" trên `project.pbxproj` sẽ âm thầm xoá. Hai vấn đề:

- **S7-1 (LOW, độ chính xác tài liệu).** Guide viết "Both rules are asserted by
  `native_copy_scan_test.dart`". Chỉ **một rưỡi** là đúng: quy tắc 2 (9
  configuration) được khẳng định thật tại `native_copy_scan_test.dart:389-399`,
  và sự **tồn tại** của phase Embed tại `:426`
  (`pbxproj.contains('Embed App Extensions')`). Quy tắc 1 — Embed phải đứng
  **trước** `Thin Binary` — không có assertion nào: grep `-iE
  "embed|thin binary|dstSubfolder"` trên tệp test chỉ khớp dòng `:426` và một
  dòng dartdoc. Đây đúng là quy tắc mà guide nói sẽ gây
  `Cycle inside Runner`, tức là quy tắc đắt nhất lại đang không có khoá.
- **S7-2 (MEDIUM, gắn với S4-F1).** Guide liệt kê deep link
  `cupidapp://card/<card_id>` ở hàng thứ 5 của bảng "The Shared Identifiers"
  (dòng 20), nhưng **không nhắc** rằng iOS còn phải khai `CFBundleURLTypes`
  cho scheme `cupidapp`. S7 đã đo lại độc lập:
  `grep -n -m 5 -E "CFBundleURLTypes|CFBundleURLSchemes|cupidapp"
  mobile/ios/Runner/Info.plist` → exit 1, không khớp dòng nào. Vì vậy người
  dựng lại theo đúng guide sẽ tái tạo y nguyên cú chạm chết của S4-F1.
- Ghi nhận cần người quyết: guide nói thẳng "iOS 13 devices can no longer
  install the app" (nâng 9 mục `IPHONEOS_DEPLOYMENT_TARGET` 13.0 → 14.0). Đây
  là hệ quả **sản phẩm**, không phải kỹ thuật; nó chỉ đang nằm trong guide,
  chưa có ở `story_master.md` hay ghi chú triển khai cấp yêu cầu.

## Cổng quyết định `PATCH_REQUIRED`

### P-1 · `VISUAL_FIDELITY: FAIL` — đối chiếu thiết kế mobile (rule 12e2/12e3)

`visual-fidelity/visual-fidelity-report.md:3` ghi `VISUAL_FIDELITY: FAIL`, do
chính lane mobile viết sau khi đã render thật bản thiết kế. Đây là bằng chứng
mạnh nhất trong hồ sơ, và nó **không thể defer**: 4 trên 6 màn đã chụp ở trạng
thái FAIL, màn thứ 7 (widget bốn pha) `NOT_COMPARED`.

| Ảnh | Trạng thái AC | Verdict |
|---|---|---|
| `implemented-hub-waiting.png` | AC-1, AC-6/AC-7 | FAIL |
| `implemented-hub-upcoming.png` | AC-3 | FAIL |
| `implemented-hub-date_day.png` | AC-2 (pha 4 trên màn 1) | FAIL |
| `implemented-hub-quiet.png` | BR-2 | PASS |
| `implemented-evening-check-in-sheet.png` | AC-4 | FAIL |
| `implemented-quiet-surfaces.png` | AC-5, AC-6 | PASS |
| *(không có ảnh)* | AC-2 (widget) | NOT_COMPARED |

Gate 12e2 đã được thực hiện đúng quy trình (Design-Surface `cupid-ch-ng-1` ghim
sau khi liệt kê cả ba canvas mobile; 7 ảnh design-reference render thật; lệnh
ghi lại nguyên văn), nên G-1 của báo cáo cũ **đã đóng về mặt thủ tục** — nhưng
kết quả nó trả về là một danh sách patch, không phải một chữ ký duyệt.

Trong 12 delta, **D-3 tự nó đã đủ để không CLEAN**: thẻ hiện ngày dạng ISO thô
`2026-09-20` / `2026-09-16` cho người dùng, trong khi thiết kế là
"CN 14/9, 19:20" / "HÔM NAY, 19:20". Đây là lỗi định dạng user-visible thật ở
locale `vi`, không phải khác biệt thẩm mỹ, và nó nằm ngay trên bề mặt AC-3
(`hub-upcoming`) lẫn AC-2 (`hub-date_day`). Không lát cắt nào bắt được nó vì
cả hai bên đều đúng ở tầng dữ liệu — S2 đã chứng minh `civilDaysUntil` trả `4`
chính xác; cái sai nằm ở chỗ ngày gốc được *vẽ* ra sao.

Phân loại 12 delta để chuyển tiếp:

- **Patch của mobile-dev (10):** D-1, D-2, D-3, D-4, D-5, D-7, D-8, D-9, D-11,
  D-12.
- **Cần Scrum Master/PO quyết trước khi sửa (2):**
  - **D-6** — sheet 23h: canvas là màn hình đầy đủ, `ux/uiux-spec.md:78` lại
    viết "gộp trong một **sheet nhỏ**". Đây là lệch spec-prose vs canvas, đúng
    lớp mà precedent design-anchor của REQ-016 xử lý; nhưng phạm vi rework hai
    hướng chênh nhau rất nhiều, nên phải chốt trước rồi mới patch. Lưu ý: AC-16
    và AC-18 thoả ở **cả hai** phương án, nên đây không phải lệch AC.
  - **D-10** — nhãn-mí pha + chấm màu trên widget. Không sửa được trong phạm vi
    "chỉnh cho khớp thiết kế": hợp đồng payload
    (`architecture/contract-summary.md` §2) chỉ có 5 khoá, đúng 2 khoá chữ, và
    AC-37/BR-15 cấm viết chuỗi hiển thị trong mã widget. Muốn có nhãn-mí thì
    phải mở rộng hợp đồng **và** gói nội dung → thay đổi kiến trúc, cần quyết
    định, đúng như S6b N-2 đã nêu.

Ghi nhận công bằng: ba khác biệt **chữ** mà báo cáo thị giác chủ động không
chấm là delta ("Chuẩn bị dần cho buổi tới" vs "Đừng ngồi đoán…", "Về tới nhà
chưa?" vs "Về tới nhà rồi chứ?") là đúng — đó là dữ liệu gói nội dung do
AC-37/BR-15 quản, thuộc quyền Product Owner sửa trên pack, không phải lỗi dựng.
Đồng thời, việc rút J12 từ khoảnh khắc toàn màn xuống một dòng công nhận là
**thu hẹp có chủ ý và đúng phạm vi** (`story_master.md:51-59`: mặt user-visible
duy nhất của J12 trong REQ-016 là bộ đếm; luồng mời/gói-lại nằm ở Out of Scope
chặng 1.5). Không tính là delta.

### P-2 · Golden test bị chặn hợp lệ

`visual-fidelity-report.md:266-271`: chưa đặt `matchesGoldenFile` cho bốn pha vì
`--update-goldens` chỉ được phép **sau khi** so sánh thị giác PASS. Đây là xử
lý đúng — đóng băng ảnh hiện tại thành golden sẽ ghim vĩnh viễn D-1..D-12. Việc
đặt golden thuộc lượt rework, không phải điều kiện của lượt này.

## Các cổng bằng chứng khác

| Cổng | Trạng thái | Bằng chứng |
|---|---|---|
| G-1 đối chiếu thiết kế (12e2/12e3) | **Đã thực hiện, verdict FAIL** → P-1 | `visual-fidelity/visual-fidelity-report.md` (284 dòng, 7 design-reference thật) |
| G-2 Entry Point Reachability (12e1) | **ĐÓNG** | `coding-plan/test-results.md:1216-1316`, `Reachable: YES` cho cả 4 bề mặt, có nêu cơ chế cho lối vào widget của HĐH |
| G-3 Story Runtime Startup Smoke (12g) | **ĐÓNG một phần** | iOS PASS thật: build → `simctl install` → `launch` → tiến trình `Ss` → ảnh màn đầu **đã mở ra nhìn**, không màn đỏ/trắng, không crash log; `Runner.app/PlugIns/CupidPhaseWidget.appex` có mặt. Android: build APK PASS sau lượt sửa desugaring, **chưa** cài/chạy trên máy ảo |
| Build / static analysis | PASS | `flutter analyze lib test`: 227 issue, **0 error** (nền 225/0 → +2 warning mới, không error). Mốc nền khác 0 là trạng thái đã biết của repo |
| Test đơn vị/widget | PASS | 7 lượt chạy của 7 lát, tất cả xanh ngay lượt đầu; các skip đều là nhóm `CAPTURE_VISUALS`, không bỏ assertion nào |
| Web Playwright / e2e trình duyệt | `NOT_APPLICABLE` | lane `mobile` |
| e2e/emulator/ký/store mobile | `NOT_APPLICABLE in ordinary continue` | — |
| Mobile visual audit cấp yêu cầu | Còn nợ ở mức REQ-016 | `integration-review/mobile-visual-audit.md`, tách khỏi story này |

Ghi chú cho DONE gate: iOS đã thoả "khởi chạy và tới màn đầu mà không crash"
của rule 12g. Nhưng P4 (`CupidPhaseWidgetProvider` + layout RemoteViews) tới
giờ **chỉ được xác minh tĩnh** — chưa từng chạy trên máy ảo Android. Không ghi
`Runtime-Smoke: WAIVED` ở đâu cả, và đúng như mobile-dev đã ghi, điều kiện
waive chưa thoả vì lỗi chặn trước đó đã sửa được.

## Danh sách finding hợp nhất

### Phải sửa trước khi DONE

| Id | Mức | Nguồn | Nội dung |
|---|---|---|---|
| **C-1** | BLOCKING-FOR-DONE | S7 (P-1) | `VISUAL_FIDELITY: FAIL`. 10 delta cài đặt (D-1..D-5, D-7..D-9, D-11, D-12) thuộc mobile-dev; D-3 (ngày ISO thô trên thẻ) là lỗi user-visible độc lập với tranh luận thẩm mỹ. Chủ: mobile-dev |
| **C-2** | QUYẾT ĐỊNH TRƯỚC | S6b N-2, báo cáo thị giác D-6/D-10 | D-6 (sheet nhỏ vs màn đầy đủ) và D-10 (nhãn-mí widget vs hợp đồng 5 khoá + AC-37). Chủ: Scrum Master/PO — mobile-dev không tự quyết được |
| **C-3** | MEDIUM | S4-F1 + S7-2 | Scheme `cupidapp` không được đăng ký trong `mobile/ios/Runner/Info.plist` (đo lại ở lượt này: 0 khớp). Chạm widget iOS không mở được app → affordance tương tác duy nhất của widget chết trên iOS. Sửa: thêm `CFBundleURLTypes`, và bổ sung bước đó vào `deployment/configuration-guide.md`. Chủ: mobile-dev |

### Hoãn được (không chặn, cần ghi nhận)

| Id | Mức | Nguồn | Nội dung |
|---|---|---|---|
| D-A | MEDIUM | S6b F-1 | `WealthCounterLine` (`wealth_counter_line.dart:34-36`) thoát sớm chỉ theo nhãn counter, nên nuốt luôn cột mốc đã bị `milestone_resolver.dart:72` tiêu thụ. Không tái hiện với `nudges.v1.json` đang ship (pack có mục slot `counter`), nhưng chính thiết kế content-as-data tồn tại để sửa pack mà không đụng mã — một lượt biên tập bỏ slot `counter` sẽ lặng lẽ giết cột mốc của mọi người dùng vượt ngưỡng |
| D-B | LOW (sản phẩm) / MEDIUM (độ tin test) | S6b F-2 | Test canh gác BR-12 (`wealth_counter_line_test.dart:314-334`) chạy `git diff --name-only HEAD` — trong worktree đã commit luôn trả rỗng, nên không bao giờ đỏ được. Bất biến thật sự vẫn giữ (đã đo `b58afbe0..HEAD` trên `activity_card_repository.dart`: rỗng). Lỗi của cái khoá, không phải của cánh cửa |
| D-C | MEDIUM | S5 O-1 (S7 đối chiếu với S2) | Nhắc 23h chỉ tồn tại nếu app được mở ít nhất một lần **trong chính ngày hẹn**: `_sync` chỉ xếp hàng từ một resolution đã ở `SoloPhase.dateDay`, và call site duy nhất là `phase_status_cubit.dart:153` chạy lúc mount/resume. AC-4 không nêu tiền đề "phải mở app". Cần PO xác nhận cách đọc AC-4 hoặc dev pre-schedule từ pha `upcoming` |
| D-D | MEDIUM | S4-F2 (S7 đính chính) | Widget gallery iOS không có `configurationDisplayName`/`.description`, nên hiện định danh lập trình `CupidPhaseWidget`. **Đính chính S4**: đây không phải sơ suất — `native_copy_scan_test.dart:336-342` chủ động khẳng định cả hai vắng mặt, lý do ghi thẳng trong test là AC-37 ("nhãn gallery cũng là chuỗi hiển thị"), và Android cố ý bỏ `android:label` cho đối xứng. Vậy đây là căng thẳng AC-37 ↔ khả năng khám phá (AC-9 dựa vào gallery), cần PO quyết, **không** được "sửa" bằng cách thêm chuỗi vào mã — làm thế là đỏ test |
| D-E | MEDIUM | test-results.md §Android | Chưa có smoke chạy thật trên Android: build APK PASS nhưng chưa cài/khởi chạy, nên `CupidPhaseWidgetProvider` chưa từng thực thi. iOS đã PASS đầy đủ |
| D-F | LOW | S3 F-1 | Hai lượt push widget sát nhau không có thứ tự/debounce (`home_widget_bridge.dart:187` không await, `:201-207` await tuần tự 5 khoá) → có thể rách payload trong một lần vẽ. Tự sửa ở lần push kế; không AC nào đòi thứ tự |
| D-G | LOW | S4-F3 | Trạng thái chưa có payload vẽ hai `Text` rỗng, thiếu nửa tích cực "icon + nền" mà `contract-summary.md:65-67` mô tả. Nửa quan trọng (không hardcode câu mặc định) thì đạt |
| D-H | LOW | S5 O-3 | `EveningCheckInScheduler.setEnabled(false)` gọi `cancelAll()`, xoá mọi local notification của app. Vô hại hôm nay (đây là producer duy nhất), thành lỗi chéo tính năng ngay khi có producer thứ hai. `cancel(int id)` đã có sẵn trên port và đang không dùng |
| D-I | LOW | S1 M-1 | Cổng bất biến nội dung chỉ làm đỏ `flutter test`, không làm đỏ `flutter build`, và repo không có CI chạy `flutter test` (`.github/workflows` chỉ có `deploy-backend.yml`, `deploy-web.yml`). AC-39 đòi "làm hỏng bản dựng" — cơ chế có thật và không vacuous, nhưng mạnh đúng bằng cổng test của quy trình giao hàng |
| D-J | LOW | S7-1 | Quy tắc "Embed App Extensions đứng trước Thin Binary" được tài liệu hoá nhưng không có assertion; chỉ sự tồn tại của phase được kiểm (`native_copy_scan_test.dart:426`) |
| D-K | LOW | S5 O-4 | Tên test `"pubspec.yaml declares no native-alarm/local-notification dependency (AC4)"` không còn mô tả đúng thân nó sau khi thu hẹp guard — `flutter_local_notifications` **đang** được khai. Assertion đúng, chỉ tên sai |
| D-L | LOW | báo cáo cũ D-1 | Guard chéo yêu cầu chỉ bắt import **trực tiếp**; một tệp dưới `lib/features/reminders/` import `local_notification_scheduler.dart` sẽ tới cùng năng lực mà vẫn xanh. Hôm nay không tồn tại import như vậy |
| D-M | INFO | S6b N-3 | `implemented-quiet-surfaces.png` còn dải DEBUG; harness nên đặt `debugShowCheckedModeBanner: false` |
| D-N | INFO | S7 (guide dòng 42) | "iOS 13 devices can no longer install the app" là hệ quả sản phẩm của việc nâng deployment target lên 14.0, hiện chỉ nằm trong configuration guide. Nên được Scrum Master/PO ghi nhận ở cấp yêu cầu |

### Đã đóng trong lượt tổng hợp này

- **S2 F-S2-1** (`beforeYouGo` không có caller sản xuất, nên
  `isBeforeYouGoDismissed` vĩnh viễn `false`) — **không phải lỗi AC-2**. Đối
  chiếu ba lát tiêu thụ: S3 dựng payload **chỉ** từ `resolution.phase`
  (`home_widget_bridge.dart:56-80`), S4 đọc đúng 3 khoá và không rẽ nhánh theo
  pha, S6b không nêu consumer nào. Không bề mặt nào rẽ nhánh theo trường đó, nên
  nó là **mã chết**, không phải phản chiếu sai. Pha thứ tư vẫn đúng vào ngày hẹn.
- **S6a F-1** (consume-on-resolve) — S6b đã xác nhận các widget vẽ đúng thứ
  `PhaseStatusState` mang sang trong cùng một lần build, không resolve suy đoán.
  Ngoại lệ duy nhất đã tách thành D-A.
- **S6a N-1** (chuỗi cứng trong `.dart`) — S6b đóng: không câu hiển thị nào nằm
  trong mã; test đọc thẳng nội dung từ `nudges.v1.json`/`drip.v1.json` trên đĩa.
- **S4 R-2** (chưa có bằng chứng biên dịch cho target iOS mới) — đóng bằng smoke
  iOS: `flutter build ios --simulator --debug --flavor local` exit 0, và
  `.appex` có mặt trong `Runner.app/PlugIns/`, tức 406 dòng sửa `project.pbxproj`
  là well-formed và được nhúng đúng chỗ.
- **G-2** — đóng.

### Rủi ro tồn đọng (không phải finding, cần biết khi rework)

- **R-a** — `_scanLimit = 50` (`phase_status_cubit.dart:132-134`, `:301-309`)
  chỉ đúng nếu `ActivityCardRepository.cardsByStatus` sắp `scheduled` theo
  `scheduled_on`. Mã đó là STORY-001, ngoài mọi kiểm kê lát cắt, và S7 không đo
  được (Grep bị tắt trong phiên, shell grep đệ quy bị guard chặn — xem "Giới hạn
  công cụ"). Nếu nó sắp theo `updated_at`, người có >50 thẻ đã hẹn có thể mất
  đếm ngược (AC-3/AC-14).
- **R-b** — hai guard quét nguồn của S2
  (`solo_phase_resolver_test.dart:457-477`, `:483-510`) là so khớp chuỗi con
  trên danh sách tên đã biết; mạnh với hồi quy đã đặt tên, mù với cái chưa đặt
  tên. Không vacuous hôm nay vì `ActivityCard` không phơi trường nào như thế.
- **R-c** — `lib/core/content/invariant_terms.dart` (`invariantHitsIn`,
  `invariantDeniedTerms`) là mã dùng chung có sẵn, không nằm trong diff và không
  thuộc lát nào. AC-39 rốt cuộc dựa vào ngữ nghĩa so khớp trong đó.
  **Reviewed-by-reference**, không phải đã kiểm.
- **R-d** — App Group `group.com.snapsofts.cupid` phải được bật trên Apple
  Developer portal cho **cả hai** App ID trước khi có bản ký; thiếu bước này chỉ
  nổ lúc ký, không nổ lúc build. Không kiểm được từ repo.
- **R-e** — `_anchorIndex` trong query key của handoff không tồn tại trong S2 và
  không lát nào xác nhận đã kiểm. Nhiều khả năng là ký hiệu của
  `activity_card_hub_view.dart`; ghi lại để không ai tưởng nó đã được verify.
- **R-f** — `native_copy_scan_test.dart:203` ghim `DEEP_LINK_SCHEME = "cupidapp"`
  ở phía Kotlin và `:277` ghim từ vựng deep link `{cupidapp, card, home}`, nhưng
  **không** kiểm phía tiêu thụ: không lát nào chứng minh Dart có đọc
  `HomeWidget.widgetClicked` / `initiallyLaunchedFromHomeWidget`. Cần xác nhận
  khi sửa C-3, nếu không cú chạm có thể chết ở cả hai nền tảng chứ không riêng
  iOS.

## Giới hạn công cụ của lượt này

Công cụ `Grep` báo `No such tool available: Grep. Grep is not available in this
session`; `grep` đệ quy và `grep` một tệp qua Bash trên `mobile/lib/**` bị chặn
bởi `guard-query-first-bash-read.sh` (`SHELL_GREP_SOURCE`). Vì vậy ba đối chiếu
chéo mà các lát chuyển sang S7 — R-a (thứ tự `cardsByStatus`), R-e
(`_anchorIndex`), R-f (consumer của deep link phía Dart) — được ghi thành rủi ro
tồn đọng thay vì được đo. Chúng không đổi được phán quyết: cổng quyết định
(P-1) đã độc lập đặt story ở `PATCH_REQUIRED`.

## Khuyến nghị trạng thái

- Để `Review (Reviewer)` **chưa tích** trong `story_master.md`.
- **Không** đánh dấu STORY-012 `DONE`. Ngoài C-1/C-2/C-3, DONE gate sẽ độc lập
  từ chối vì `VISUAL_FIDELITY: FAIL`.
- Thứ tự việc đề nghị:
  1. Scrum Master/PO chốt **C-2** (D-6 và D-10) — vì D-6 quyết định phạm vi
     rework của cả màn 23h.
  2. mobile-dev patch **C-1** (10 delta cài đặt) + **C-3** (CFBundleURLTypes,
     kèm cập nhật configuration-guide), tiện thể D-A, D-B, D-K.
  3. Chụp lại `implemented-*`, viết lại verdict thị giác; chỉ đặt golden **sau
     khi** verdict thành PASS.
  4. Bổ sung smoke chạy thật Android (D-E) để P4 thoát khỏi trạng thái chỉ
     xác minh tĩnh.
- Các mục D-C, D-D, D-N cần quyết định của PO chứ không phải patch của dev; đừng
  để dev "sửa" D-D bằng cách thêm chuỗi vào mã native.

## Truy vết

| Đầu vào | Dùng cho |
|---|---|
| `review/scope-gate.md` | định nghĩa 7 lát, ranh giới S7 |
| `review/slice-S1.md` … `slice-S6b.md` | verdict AC/BR theo lát, danh sách finding nguồn |
| `story_master.md` | AC-1..AC-8, Out of Scope, cờ UI-facing, trạng thái artifact |
| `mobile/lib/l10n/arb/app_en.arb` + `app_vi.arb` (diff) + `mobile/l10n.yaml` | verdict S7 tệp 1 |
| `deployment/configuration-guide.md` | verdict S7 tệp 2, S7-1, S7-2, D-N |
| `visual-fidelity/visual-fidelity-report.md` | P-1, C-1, C-2 |
| `coding-plan/test-results.md` (đọc theo dải: 1216-1316, 1317-1442) | G-2, G-3, analyze, lịch sử blocker Android |
| `data/devops/system/design-fidelity-config.json` | rule 12e2 có áp dụng, ba canvas mobile |
| `mobile/android/app/build.gradle.kts` (diff) | tệp mã duy nhất ngoài mọi kiểm kê lát cắt |
| `mobile/test/features/phase_status/native_copy_scan_test.dart:320-429` | đính chính S4-F2, S7-1 |
| `mobile/ios/Runner/Info.plist` (grep) | xác nhận lại S4-F1 → C-3 |
| `git diff --name-only b58afbe0 HEAD` | kiểm tra độ phủ, đính chính BaseHead |

## Đếm finding

- Chặn DONE: 3 (C-1, C-2, C-3)
- Hoãn được: 14 (D-A … D-N)
- Rủi ro tồn đọng: 6 (R-a … R-f)
- Đóng trong lượt này: 5
