# Phase P11 – Chỉ báo pha `date_day`: chấm → glyph tia chớp (D-13)

## 1. Objective

D-13 (2026-09-25, `../architecture/contract-summary.md` §3a) đổi **hình dạng**
của đúng một vai trò token: `--dot-today` (pha `date_day`) phải vẽ bằng **glyph
tia chớp** khớp canvas `sb-84-widget-bon-pha`, không phải chấm tròn — vì nền
gradient hồng→tím của D-12 làm chấm hồng đặc gần như mất tương phản
(`../requirements/requirements.md` AC-9 bản vá 2026-09-25,
`../ux/uiux-spec.md` §2, và phát hiện #2 của
`../visual-fidelity/visual-fidelity-report.md`).

Phase này **chỉ** đổi hình dạng của vai trò `--dot-today` trên cả hai nền
tảng. Ba vai trò còn lại (`--dot-waiting`, `--dot-upcoming`, `--dot-quiet`) giữ
nguyên chấm tròn màu đặc. Tên vai trò, bảng ánh xạ `phase_id -> vai trò`, và
mọi giá trị màu **không đổi** — glyph lấy màu từ chính giá trị `dot_today` đã
ship ở P4/P5/P9, không có vai trò/màu thứ năm.

## 1A. Ownership

- Phase ID: P11
- Canonical Phase File: `phase-P11-widget-date-day-bolt-glyph.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P4 (provider Android + bảng token), P5 (extension iOS), P9 (hàng
  nhãn-mí và chấm hiện tại — P11 sửa đúng chỗ P9 dựng)
- Parallelizable: NO (lane Mobile chỉ có một code-writer:
  `MAX_CODE_WRITERS_PER_STORY: 1`; thứ tự còn lại là P10 → P11 → P12)
- Write Scope:
  - `mobile/android/app/src/main/res/drawable/dot_today_bolt.xml` (file mới)
  - `mobile/android/app/src/main/kotlin/com/snapsofts/cupid/CupidPhaseWidgetProvider.kt`
  - `mobile/android/app/src/main/res/layout/cupid_phase_widget.xml` (chỉ chú
    thích + nếu cần, kích thước ô `ImageView`)
  - `mobile/ios/CupidPhaseWidget/CupidPhaseWidget.swift`
  - `mobile/test/features/phase_status/native_copy_scan_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: mobile-app
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE (bề mặt là widget hệ điều hành; build native
    + chụp thật là phạm vi của P12, không phải P11)
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `@drawable/dot_today_bolt` — nguồn duy nhất của **hình dạng** glyph phía
    Android (vector path), được tint bằng giá trị vai trò `DOT_TODAY`
  - `CupidPhaseBolt` (`Shape` trong `CupidPhaseWidget.swift`) — hình dạng
    tương đương phía iOS, tô bằng `CupidWidgetPalette.dotToday`
- Shared Interfaces Consumed:
  - `../architecture/contract-summary.md` §2 (`phase_id`, tập bốn giá trị
    đóng), §3a (bảng bốn vai trò + cột "Hình dạng (D-13)")
- Risk Surfaces:
  - `HARDCODED-COPY` (glyph là **tài nguyên native ship kèm app**, không phải
    mục của gói nội dung §4; không thêm khoá payload, không đi qua
    `home_widget`)
  - `VISUAL-FIDELITY` (ô 7 của bảng đối chiếu — P11 dựng hình, P12 chụp)
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md` §3a
  - consumer contract: `mobile/test/features/phase_status/native_copy_scan_test.dart`
- Primary Inputs Summary:
  - requirements: AC-9 (bản vá 2026-09-25), AC-12 ("chỉ báo pha là design
    token, không phải nội dung"), AC-37/BR-15 (không chuỗi/nội dung trong
    native)
  - architecture: `../architecture/contract-summary.md` §3a (D-13), §6 (danh
    sách cấm phía tiêu thụ)
  - OQ constraints: none
  - upstream phase outputs: P4 (`CupidWidgetPalette` Kotlin, `dotBitmap`), P5 +
    P9 (`CupidWidgetPalette` Swift, hàng nhãn-mí `HStack`)
  - UX constraints: `../ux/uiux-spec.md` §2 (chỉ báo pha), canvas
    `sb-84-widget-bon-pha`, ảnh neo
    `../visual-fidelity/design-reference-sb-84-widget-bon-pha-ios.png`
  - review findings: `../visual-fidelity/visual-fidelity-report.md` phát hiện
    #2 ("chấm `date_day` gần như không đọc được trên chính nền của nó")
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: một thuộc tính hiển thị (hình dạng) của đúng một vai trò
    token, áp dụng cùng một cách trên hai nền tảng
  - Source/Test File Count: 5 file (1 mới, 3 sửa, 1 test)
  - Split Required: NO
  - Split Rationale: N/A — một mẫu áp cho hai biến thể nền tảng là một phase

## 2. Required Reads

- `../architecture/contract-summary.md` §3a (toàn bộ, kể cả bảng bốn dòng và
  gạch đầu dòng "Hình dạng (D-13)") và §6
- `mobile/android/app/src/main/kotlin/com/snapsofts/cupid/CupidPhaseWidgetProvider.kt`
  dòng 28-82 (`update`, `dotBitmap`) và dòng 100-140 (`CIRCLE_PX`, `PHASE_ID_*`,
  `CupidWidgetPalette`)
- `mobile/android/app/src/main/res/layout/cupid_phase_widget.xml` dòng 35-55
  (chú thích D-10 + `ImageView` `cupid_phase_widget_dot`)
- `mobile/ios/CupidPhaseWidget/CupidPhaseWidget.swift` dòng 44-67
  (`CupidWidgetPalette` + `dot(for:)`) và dòng 237-250 (hàng nhãn-mí
  `HStack`, `Circle()`, `entry.isDateDay`)
- `mobile/test/features/phase_status/native_copy_scan_test.dart` dòng 460-510
  (ba khẳng định canh sẽ bị P11 chạm tới, nêu rõ ở §3)
- `../visual-fidelity/design-reference-sb-84-widget-bon-pha-ios.png` (tỉ lệ và
  độ nghiêng của tia chớp trên canvas — nhìn bằng mắt trước khi viết path)

## 3. Tasks

### 3.1 Android — vector drawable là nguồn duy nhất của hình dạng

- Thêm `mobile/android/app/src/main/res/drawable/dot_today_bolt.xml`: một
  `<vector>` viewport `24x24`, `android:width`/`android:height` `24dp`, đúng
  **một** `<path>` khép kín vẽ tia chớp, `android:fillColor="#FFFFFFFF"` (màu
  giữ chỗ đặc, sẽ bị tint thay hoàn toàn). Không gradient, không `<group>`,
  không nhiều path, không `android:tint` cứng trong file.
  - `pathData` khởi điểm (điều chỉnh được để khớp độ nghiêng canvas, nhưng phải
    giữ đúng một path khép kín):
    `M13,2 L4,13 h6 l-1,9 9,-12 h-6 z`
  - File phải là ASCII thuần ngoài chú thích (test "every .kt and .xml file is
    pure ASCII once comments are removed" quét đệ quy cả `res/drawable/`).
- Trong `CupidPhaseWidgetProvider.kt`, thêm hàm rasterize cạnh `dotBitmap`:
  nạp drawable bằng `ContextCompat.getDrawable(context, R.drawable.dot_today_bolt)!!.mutate()`
  (thêm `import androidx.core.content.ContextCompat`), gọi `setTint(color)`,
  `setBounds(0, 0, GLYPH_PX, GLYPH_PX)`, rồi `draw(Canvas(bitmap))` vào một
  `Bitmap.createBitmap(GLYPH_PX, GLYPH_PX, Bitmap.Config.ARGB_8888)`.
  - Thêm `const val GLYPH_PX = 48` cạnh `CIRCLE_PX = 24` (dòng 105). Rasterize
    to hơn ô 8dp để glyph không bị răng cưa; **không** đổi `CIRCLE_PX` và
    **không** đổi đường vẽ chấm của ba vai trò còn lại.
  - App tự rasterize trong process của mình rồi gửi `Bitmap` đi, nên không phụ
    thuộc việc launcher có hỗ trợ `VectorDrawable` trong `RemoteViews` hay
    không, và không phụ thuộc `flutter.minSdkVersion`.
- Tại dòng 45, chọn hình theo `phaseId` và giữ nguyên **một** lời gọi
  `setImageViewBitmap`:
  `if (phaseId == PHASE_ID_DATE_DAY) boltBitmap(context, dotColor) else dotBitmap(dotColor)`.
  Không thêm nhánh nào khác, không đọc hình dạng từ payload, không thêm khoá
  payload, không dùng icon mặc định hệ điều hành (§3a + §6).
- Màu vẫn đến từ đúng một nguồn: `CupidWidgetPalette.dotFor(phaseId)` (dòng
  38). **Không** thêm color resource `@color/dot_today` và **không** thêm hằng
  số `DOT_*` thứ năm — test dòng 476-488 khoá tập `DOT_[A-Z_]+` ở đúng bốn tên,
  còn dòng 489-491 khoá "không `?android:attr/`, không `android.R.color`, có
  `setImageViewBitmap`". Cả ba khẳng định đó phải tiếp tục xanh không sửa.
  - Ghi chú hợp đồng cho Scrum Master/Reviewer: §3a mô tả cơ chế Android là
    "vector drawable `dot_today_bolt` được tint bằng `@color/dot_today`".
    Phase này giữ **đúng tên vector drawable và đúng vai trò màu**, nhưng lấy
    giá trị màu từ `DOT_TODAY` trong Kotlin (nguồn P4 đã ship, cũng là nguồn
    màu chữ nhãn-mí ở dòng 44) thay vì tạo thêm một `@color/dot_today` song
    song. Đây là lựa chọn cơ chế để **tránh hai nguồn màu cho cùng một vai
    trò**, không phải mở lại D-13; hình dạng, tên vai trò và ánh xạ đều đúng
    §3a. Nếu Reviewer muốn §3a nói đúng cơ chế đã ship, đó là một dòng patch
    `architecture/contract-summary.md`, ngoài Write Scope của phase này.
- Cập nhật chú thích dòng 35-39 của `cupid_phase_widget.xml` cho khớp: ô
  `ImageView` nhận một bitmap do provider vẽ; `date_day` là glyph tia chớp
  rasterize từ `dot_today_bolt`, ba pha còn lại là chấm tròn. Chỉ nới
  `layout_width`/`layout_height` khỏi `8dp` nếu glyph đọc thành một vệt mờ trên
  thiết bị ở P12 — nếu nới thì ghi lý do vào chú thích và vào
  `coding-plan/test-results.md`.

### 3.2 iOS — cùng hình dạng, không dùng SF Symbol

- Trong `mobile/ios/CupidPhaseWidget/CupidPhaseWidget.swift`, thêm
  `private struct CupidPhaseBolt: Shape` với `func path(in rect: CGRect) -> Path`
  dựng **cùng** đường gấp khúc như `pathData` Android, chuẩn hoá từ hệ toạ độ
  `24x24` sang `rect` (chia 24, nhân `rect.width`/`rect.height`) để hai nền
  tảng ra đúng một hình.
- Tại hàng nhãn-mí (dòng 241-244), rẽ bằng `entry.isDateDay` (đã có sẵn, dòng
  234): `date_day` vẽ `CupidPhaseBolt().fill(entry.dotColor)` với
  `.frame(width: 7, height: 9)`; ba pha còn lại giữ `Circle().fill(entry.dotColor)`
  `.frame(width: 7, height: 7)`. Giữ `HStack(spacing: 5)` và mọi thuộc tính
  chữ nhãn-mí không đổi.
- **Không** dùng SF Symbol (`Image(systemName: "bolt.fill")` hay tương đương):
  §3a/§6 cấm icon mặc định hệ điều hành. **Không** thêm Asset Catalog/Color Set
  mới và **không** thêm file `.swift` mới — file mới đòi sửa `project.pbxproj`,
  vốn có bộ test canh riêng (dòng 515-600) và không thuộc phạm vi D-13.
- **Không** đặt tên định danh Swift mới khớp mẫu `dot[A-Z]...`: test dòng
  494-505 khoá tập `{dotWaiting, dotUpcoming, dotToday, dotQuiet}`. Dùng
  `CupidPhaseBolt` như trên.

### 3.3 Test canh (Dart, không cần build native)

Bổ sung vào `mobile/test/features/phase_status/native_copy_scan_test.dart`,
không xoá/nới case nào đang có:

- `res/drawable/dot_today_bolt.xml` tồn tại, chứa đúng một `<path`, có
  `android:pathData=`, **không** chứa `gradient`, và không chứa chuỗi văn bản
  người dùng.
- Provider (đã strip chú thích) chứa `R.drawable.dot_today_bolt`,
  `PHASE_ID_DATE_DAY` xuất hiện trong nhánh chọn hình, và vẫn còn `drawCircle`
  cho nhánh chấm — tức là hai hình cùng tồn tại, không phải đổi hết thành
  glyph.
- Provider **không** chứa `systemName`, `android.R.drawable`, hay
  `?android:attr/`.
- Swift (đã strip chú thích) chứa `CupidPhaseBolt`, chứa `entry.isDateDay`
  trong hàng nhãn-mí, vẫn chứa `Circle()`, và **không** chứa `Image(systemName:`.
- Tập `dot[A-Z][A-Za-z]*` trong Swift và tập `DOT_[A-Z_]+` trong Kotlin vẫn
  đúng bốn tên cũ (case sẵn có — chỉ cần chạy lại, không sửa).

## 4. Acceptance Criteria

- AC-9 / D-13: pha `date_day` vẽ glyph tia chớp; ba pha còn lại vẫn là chấm
  tròn màu đặc. Không pha nào dùng hình của pha khác.
- AC-12 / §3a: hình dạng **và** màu vẫn chỉ đến từ bảng tra bốn vai trò theo
  `phase_id`; không khoá payload mới, không suy từ ngày/ngôn ngữ/số, không màu
  hay icon mặc định hệ điều hành.
- AC-37 / BR-15: glyph là tài nguyên native ship kèm app, không phải mục gói
  nội dung, không đi qua `home_widget`; không chuỗi người dùng nào xuất hiện
  trong `.kt`/`.xml`/`.swift`.
- Không hồi quy: toàn bộ case `native_copy_scan_test.dart` của P4/P5/P9 vẫn
  PASS, kể cả ba khẳng định ở dòng 476-491, mà không phải sửa case nào.
- Hợp đồng widget §2 (tập khoá payload) và `CupidDatabase.schemaVersion` không
  đổi (BR-12/AC-4).

## 5. Planned Outputs

- Code directories or files: xem Write Scope
- Contracts or schemas: none (không đổi §2/§4; §3a chỉ được **thực hiện**, không
  sửa)
- Requirement configuration guide updates: none
- Notes or evidence: dán lệnh + kết quả test vào `coding-plan/test-results.md`.
  Ảnh bản dựng thật của widget **không** thuộc phase này — P12 chụp; P11 chỉ
  ghi rằng ô 7 của `../visual-fidelity/visual-fidelity-report.md` vẫn mở và
  chuyển cho P12.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: native Android (`RemoteViews`) + native iOS (WidgetKit),
  xác minh ở lượt này bằng test canh phía Dart (không build native ở P11 —
  build + chụp là P12)
- Required levels (omit N/A levels):
  - unit: `flutter test test/features/phase_status/native_copy_scan_test.dart`
  - mobile build/type-check/static-analysis: `flutter analyze lib/features/phase_status`
    (0 error; cảnh báo nền của repo không phải bằng chứng cổng)
- Required checks: chạy `native_copy_scan_test.dart` **trước** khi ghi bất kỳ
  completion marker nào; nếu đỏ thì sửa rồi chạy lại. Không chạy `flutter test`
  không đối số (baseline repo đang đỏ ở `test/design_system/`, một lượt full
  suite sẽ chặn cổng build của cả session).
- Mobile discoverability / navigation integration: N/A — không đổi route, không
  đổi deep link
- Minimum gates by risk surface:
  - `HARDCODED-COPY` → case "không chuỗi người dùng trong native" vẫn PASS
  - `VISUAL-FIDELITY` → chỉ ghi nhận, ô 7 do P12 đóng
- Required regression or contract coverage: toàn bộ `test/features/phase_status`
  PASS, không giảm số case so với P9/P10
- Evidence format: lệnh + kết quả dán nguyên văn vào
  `coding-plan/test-results.md`
- Per-story visual fidelity: DEFERRED_TO_P12 — bề mặt là widget hệ điều hành,
  không nằm trong cây widget Flutter nên harness `RepaintBoundary` không với
  tới; vẽ lại bằng Dart rồi chụp là bịa bằng chứng (đã bác ở
  `phase-P9-widget-phase-label-and-dot.md` §6 và
  `../visual-fidelity/visual-fidelity-report.md`). Trước khi ghi marker, chạy
  `git -C <worktree> status --short` và xác nhận P11 **không** làm bẩn các PNG
  visual-fidelity của story khác.
- Runtime startup smoke (omit if NO): NO

## 7. Status

- Status: DONE
- Last updated: 2026-09-25
- Evidence: `coding-plan/test-results.md` mục "P11 – Chỉ báo pha `date_day`:
  chấm → glyph tia chớp (D-13)" (lệnh + kết quả nguyên văn:
  `flutter test test/features/phase_status/native_copy_scan_test.dart` `+38`,
  hồi quy `flutter test test/features/phase_status` `+250 ~6`,
  `flutter analyze lib/features/phase_status test/features/phase_status` 0 error)
- Deferred to P12: build native + chụp widget thật (ô 7 của
  `../visual-fidelity/visual-fidelity-report.md` vẫn mở)
