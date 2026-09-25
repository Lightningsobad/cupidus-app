# Phase P12 – Build native + chụp ảnh widget thật cho ô 7 (R-5)

## 1. Objective

Đóng khoản mở cuối cùng của bảng đối chiếu hình ảnh: ô 7
(`../visual-fidelity/visual-fidelity-report.md` dòng 106, 422, 538) vẫn
`NOT_COMPARED` vì story **chưa từng** có một file `implemented-widget-*.png`.
Lý do đã ghi rõ ở báo cáo dòng 507-530: bề mặt cần chụp là widget màn hình
chính của hệ điều hành (`RemoteViews` phía Android, WidgetKit phía iOS), không
nằm trong cây widget Flutter, nên harness `RepaintBoundary` đang tạo sáu ảnh
kia không với tới được; mà `phase-P9-widget-phase-label-and-dot.md` §6 lại ghi
"không chạy build native".

Quyết định người dùng 2026-09-25 (đã ghi trong
`../scrum-master-checkpoint.md`) mở scope cho đúng khoản này: **được** build
native và chụp trên thiết bị/AVD để tạo một ảnh `implemented-widget-*.png`
thật. Phạm vi mở chỉ áp cho lỗ hổng bằng chứng này, **không** biến P9 §6 thành
"luôn build native" cho các phase khác.

Cấm tuyệt đối, nhắc lại từ báo cáo dòng 520-523: **không** vẽ lại widget bằng
Dart rồi chụp bản vẽ đó. Ảnh như vậy chứng minh một cây widget Flutter không
tồn tại trong sản phẩm, không chứng minh gì về `CupidPhaseWidgetProvider.kt`
hay `CupidPhaseWidget.swift`. Nếu không chụp được ảnh thật thì trả blocker, chứ
không thay bằng ảnh dựng lại.

## 1A. Ownership

- Phase ID: P12
- Canonical Phase File: `phase-P12-widget-native-capture.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P11 (**bắt buộc** — ảnh phải cho thấy glyph tia chớp cuối cùng
  của D-13, không phải chấm cũ; chụp trước P11 là chụp lại thứ sắp bị thay)
- Parallelizable: NO (lane Mobile chỉ có một code-writer:
  `MAX_CODE_WRITERS_PER_STORY: 1`; P12 là phase cuối của chuỗi P10 → P11 → P12)
- Write Scope:
  - `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/visual-fidelity/`
    (ảnh `implemented-widget-*.png` mới + `visual-fidelity-report.md`)
  - `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/coding-plan/test-results.md`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: mobile-app
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: REQUIRED (chỉ ở mức "app cài được và khởi động" để widget có
    dữ liệu; không phải smoke toàn luồng)
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry (`flutter run` / cài APK)
  - Readiness Check: app mở được tới màn đầu, và provider nhận được một broadcast
    `APPWIDGET_UPDATE` không crash (`adb logcat` không có exception của
    `com.snapsofts.cupid`)
  - Port Contract: N/A (mobile; không chiếm port nào — không `devstack port claim`)
- Shared Interfaces Produced: none (phase bằng chứng, không đổi mã sản phẩm)
- Shared Interfaces Consumed:
  - `../architecture/contract-summary.md` §2 (sáu khoá payload phải seed để
    widget có nội dung), §3a (bảng bốn vai trò + hình dạng để đối chiếu)
- Risk Surfaces:
  - `VISUAL-FIDELITY` (đây là phase đóng nó)
  - `WIDGET-STALE` (chụp được cả hành vi làm tươi: mỗi lần đổi payload phải thấy
    widget đổi theo, không giữ nội dung cũ)
- Source Of Truth:
  - authoritative artifact: `../visual-fidelity/visual-fidelity-report.md`
  - consumer contract: canvas `sb-84-widget-bon-pha` qua ảnh neo
    `../visual-fidelity/design-reference-sb-84-widget-bon-pha-ios.png`
- Primary Inputs Summary:
  - requirements: AC-2 (widget bốn pha), AC-9 (bản vá 2026-09-25), AC-12
  - architecture: `../architecture/contract-summary.md` §2, §3a
  - OQ constraints: none
  - upstream phase outputs: P4, P5, P9 (widget hai nền tảng), P11 (glyph D-13)
  - UX constraints: `../ux/uiux-spec.md` §2
  - review findings: `../visual-fidelity/visual-fidelity-report.md` dòng
    507-530 (ô 7 thiếu ảnh) và dòng 528-530 (yêu cầu một quyết định — đã có)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: một lượt thu bằng chứng cho đúng một ô của bảng đối chiếu
  - Source/Test File Count: 0 file mã nguồn, 2 artifact bằng chứng
  - Split Required: NO
  - Split Rationale: N/A

## 2. Required Reads

- `../visual-fidelity/visual-fidelity-report.md` dòng 460-543 (bảng đối chiếu
  canvas ↔ mã của P9, lý do ô 7 mở, và verdict hiện tại)
- `../architecture/contract-summary.md` §2 (tên chính xác của sáu khoá payload
  và bốn giá trị `phase_id`)
- `mobile/lib/features/phase_status/data/home_widget_bridge.dart` (đường ghi
  payload thật của Dart — nguồn để biết khoá nào mang gì)
- `mobile/android/app/src/main/kotlin/com/snapsofts/cupid/CupidPhaseWidgetProvider.kt`
  dòng 28-70 (provider đọc gì, cập nhật view nào)
- `data/devops/system/runtime-command-registry.json` mục `mobile-app`
  (`buildCommand` chuẩn của repo)
- `phase-P11-widget-date-day-bolt-glyph.md` §3 (hình dạng phải thấy trong ảnh)

## 3. Tasks

Thứ tự dưới đây là thứ tự thực thi. Dừng và báo blocker ở đúng bước không làm
được, không nhảy bước.

### 3.1 Preflight

- Dùng Flutter SDK theo cách repo đã dùng (prefix PATH tới SDK trước mọi lệnh
  `flutter`); nếu worktree này chưa từng chạy, `flutter gen-l10n` trước.
- Xác nhận có một đích chạy Android: `adb devices` phải liệt kê đúng một thiết
  bị thật hoặc một AVD đang chạy. Nếu rỗng và không khởi động được đích nào,
  dừng với blocker `NO_ANDROID_TARGET` (nêu nguyên văn lệnh + output).

### 3.2 Build + cài (Android trước — đây là đích khả thi cao nhất)

- Build debug **tách theo ABI**: `flutter build apk --debug --split-per-abi`.
  Không build APK gộp mọi ABI — bản gộp quá lớn để cài trong môi trường này.
- Nếu đã có bản cũ trên đích, gỡ bằng `adb shell cmd package uninstall -k
  <applicationId>` để giữ dữ liệu đã seed; xác nhận `applicationId` từ
  `mobile/android/app/build.gradle.kts`, không đoán.
- Cài APK khớp ABI của đích (`adb shell getprop ro.product.cpu.abi`), rồi mở
  app một lần để nó tạo `shared_prefs` và ghi payload lần đầu.

### 3.3 Seed payload cho từng pha

- Liệt kê `adb shell run-as <applicationId> ls /data/data/<applicationId>/shared_prefs`
  để lấy **tên file thật** của prefs mà `home_widget` dùng; không hardcode tên
  theo phỏng đoán.
- Với mỗi `phase_id` cần chụp, ghi sáu khoá §2 vào prefs đó (qua `run-as` +
  `cat > ...xml`, giống cách seed session của lượt smoke trước), rồi đẩy một
  lượt cập nhật:
  `adb shell am broadcast -a android.appwidget.action.APPWIDGET_UPDATE -n <applicationId>/com.snapsofts.cupid.CupidPhaseWidgetProvider`.
- Ưu tiên tuyệt đối là `date_day` (ô 7 tồn tại để chứng minh D-10 + D-13).
  Chụp thêm `waiting`, `upcoming`, `quiet` **nếu** ba pha kia không tốn thêm
  bước nào ngoài ghi prefs + broadcast + chụp.
- Sau mỗi broadcast, kiểm `adb logcat -d` không có exception của
  `com.snapsofts.cupid` (bắt luôn rủi ro `WIDGET-STALE`: nội dung phải đổi theo
  payload, không đứng lại ở pha trước).

### 3.4 Đặt widget lên launcher và chụp

- Widget phải nằm trên màn hình chính thật để ảnh có giá trị: thêm một lần qua
  giao diện (long-press màn hình chính → Widgets → kéo `Cupid` vào), sau đó cả
  bốn pha chỉ cần lặp lại bước 3.3 + chụp, không phải thêm lại.
- Chụp bằng `adb exec-out screencap -p > <đường dẫn tuyệt đối>.png`, rồi crop về
  đúng vùng widget (giữ trọn viền widget, không crop mất nền — nền gradient là
  một phần của D-12 cần đối chiếu).
- Lưu vào `../visual-fidelity/` với tên:
  `implemented-widget-date-day.png` (bắt buộc), và nếu có:
  `implemented-widget-waiting.png`, `implemented-widget-upcoming.png`,
  `implemented-widget-quiet.png`.
- **Mở từng ảnh ra xem bằng mắt** trước khi ghi verdict: một lượt chụp "xanh"
  vẫn có thể ra ô trống, ảnh splash, chữ thành ô vuông tofu, hoặc widget chưa
  kịp cập nhật. Ảnh không đọc được không phải bằng chứng.
- Nếu bước đặt widget lên launcher không thực hiện được trong môi trường này,
  dừng với blocker `WIDGET_PLACEMENT_BLOCKED` và nêu chính xác bước hỏng. Không
  thay bằng ảnh Dart dựng lại.

### 3.5 iOS — làm nếu môi trường cho phép, không bắt buộc

- Nếu có Xcode + simulator iOS 17+ khả dụng: build Runner + target
  `CupidPhaseWidget`, thêm widget lên màn hình chính của simulator, seed cùng
  payload `date_day`, chụp `implemented-widget-date-day-ios.png`.
- Nếu không: ghi rõ trong báo cáo rằng ô 7 được đóng bằng ảnh Android, **nêu tên
  nền tảng của ảnh**, và nêu rõ ảnh thiết kế neo là bản `-ios` nên phần đối
  chiếu chỉ tính hình dạng/màu/tỉ lệ, không tính chrome của hệ điều hành. Đây là
  một hạn chế được ghi nhận, không phải PASS ngầm.

### 3.6 Cập nhật bảng đối chiếu

- Trong `../visual-fidelity/visual-fidelity-report.md`: thêm một mục lượt mới
  (không xoá/sửa lại verdict các lượt cũ), gán ảnh vào ô 7, và đối chiếu từng
  thuộc tính với canvas `sb-84-widget-bon-pha`: hình dạng chỉ báo pha (glyph tia
  chớp ở `date_day`, chấm ở ba pha còn lại), màu chỉ báo, màu chữ nhãn-mí, nền
  pha, cỡ số, một vùng chạm duy nhất.
- Ghi verdict ô 7 rõ ràng: `PASS` / `FAIL` + lệch cụ thể. Nếu tổng
  `VISUAL_FIDELITY` vẫn `FAIL` vì R-1 (`hub-waiting`, hai chip hành động) thì
  nói thẳng; đóng ô 7 không tự lật verdict tổng.
- Chạy cổng bằng `python3 .claude/hooks/lib/visual_fidelity.py --dir
  <đường dẫn tuyệt đối tới visual-fidelity/> --stage <stage tương ứng>` và dán
  output. Không dùng bản `.sh` để tự kiểm: nó im lặng trả 0 khi tự chạy.
- Trước khi ghi completion marker, chạy `git -C <worktree> status --short` và
  xác nhận lượt này **không** làm bẩn PNG visual-fidelity của story khác (đã
  từng xảy ra); nếu có, hoàn nguyên đúng những file đó.

## 4. Acceptance Criteria

- AC-2 / D-10 / D-13: tồn tại ít nhất một file `implemented-widget-date-day.png`
  là **ảnh chụp bề mặt widget thật của hệ điều hành**, đọc được, cho thấy hàng
  nhãn-mí với glyph tia chớp trên nền pha `date_day`.
- Ô 7 của `../visual-fidelity/visual-fidelity-report.md` không còn
  `NOT_COMPARED`: có ảnh, có bảng đối chiếu từng thuộc tính, có verdict.
- Không có ảnh nào trong `visual-fidelity/` được tạo bằng cách vẽ lại widget
  bằng Dart.
- Không đổi một dòng mã sản phẩm nào trong phase này (Write Scope chỉ có
  artifact). Nếu lúc chụp phát hiện lỗi hình, lỗi đó là finding ghi vào báo cáo
  + blocker về Scrum Master, không sửa mã trong P12.

## 5. Planned Outputs

- Code directories or files: none
- Contracts or schemas: none
- Requirement configuration guide updates: none
- Notes or evidence:
  - `../visual-fidelity/implemented-widget-date-day.png` (+ các pha khác nếu
    chụp được, + bản `-ios` nếu môi trường cho phép)
  - mục lượt mới trong `../visual-fidelity/visual-fidelity-report.md`
  - lệnh build/cài/seed/chụp + output dán nguyên văn vào
    `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope` + quyết định người dùng
  2026-09-25 (mở scope build native cho đúng lỗ hổng bằng chứng này)
- Platform / Surface: Android `RemoteViews` trên thiết bị thật/AVD; iOS
  WidgetKit nếu môi trường cho phép
- Required levels (omit N/A levels):
  - mobile build: `flutter build apk --debug --split-per-abi` (thành công)
  - manual visual verification: mở từng PNG đã chụp và đọc bằng mắt
- Required checks: không chạy `flutter test` không đối số. Nếu cần chạy lại test
  canh của P11, chạy đúng file
  `test/features/phase_status/native_copy_scan_test.dart`. Không pipe output của
  lệnh build qua `|` — một lượt build bị pipe sẽ làm cổng bằng chứng không xác
  định được nguyên nhân.
- Mobile discoverability / navigation integration: vùng chạm widget mở đúng deep
  link (chạm thử một lần, ghi kết quả; không đổi mã)
- Minimum gates by risk surface:
  - `VISUAL-FIDELITY` → ô 7 có ảnh + verdict
  - `WIDGET-STALE` → nội dung widget đổi theo payload sau broadcast, có bằng
    chứng ít nhất hai pha khác nhau nếu chụp được nhiều hơn một pha
- Required regression or contract coverage: không đổi mã nên không có hồi quy
  mã; xác nhận `git status` sạch ngoài Write Scope
- Evidence format: lệnh + output nguyên văn trong `coding-plan/test-results.md`;
  ảnh trong `visual-fidelity/`
- Per-story visual fidelity: REQUIRED — đây là phase đóng nó
- Runtime startup smoke (omit if NO): YES, giới hạn ở `mobile-app` cài được và
  mở tới màn đầu để widget có dữ liệu; không chạy smoke của service khác

## 7. Status

- Status: PENDING
- Last updated: 2026-09-25
