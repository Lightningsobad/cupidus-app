# Cross-Lane Contract — REQ-016 Pha, widget hệ điều hành, và bộ đếm

Authoritative source: `mobile/` package `cupid_mobile` (STORY-012).
Consumers: **mã native trong cùng repo** — WidgetKit extension (Swift,
`mobile/ios/CupidPhaseWidget/`) và AppWidgetProvider (Kotlin,
`mobile/android/app/src/main/kotlin/.../CupidPhaseWidgetProvider.kt`) — cộng với
đội soạn nội dung / CMS tương lai đọc lược đồ §4. Story này **không** phát trạng
thái cho story Dart nào khác (AC-3); ranh giới duy nhất cần hợp đồng là ranh
giới Dart ↔ native, vì ở đó sai khớp tên khoá là **mất âm thầm**, không phải lỗi
biên dịch.

## 1. Envelope

Không có wire protocol và không có backend. Payload đi qua **kho khoá-giá trị
dùng chung của `home_widget`**: iOS App Group `group.com.snapsofts.cupid`,
Android `SharedPreferences` mặc định của app. Dart ghi bằng
`HomeWidget.saveWidgetData<T>(key, value)` rồi `HomeWidget.updateWidget(...)`;
native đọc đúng các khoá ở §2.

Khớp là **khớp chuỗi thuần**. Sai một ký tự trong tên khoá → native đọc `null` →
widget hiện khung rỗng, **không** có lỗi biên dịch và **không** có log. Đây là
lý do file này tồn tại: mọi tên khoá phải copy nguyên văn từ §2.

`applicationId` là `com.snapsofts.cupid` cho **mọi** flavor (không có
`applicationIdSuffix`, xem `mobile/android/app/build.gradle.kts`), nên chỉ có
**một** App Group và **một** provider dùng chung cho `local` và `prod`.

## 2. Identifiers — copy exactly

| Mục đích | Định danh | Ràng buộc |
|---|---|---|
| App Group (iOS) | `group.com.snapsofts.cupid` | đặt trong `Runner.entitlements` **và** entitlements của extension |
| Widget kind (iOS) | `CupidPhaseWidget` | trùng `kind:` trong Swift `Widget` và tham số `iOSName` của `updateWidget` |
| Provider (Android) | `CupidPhaseWidgetProvider` | trùng tham số `androidName` của `updateWidget` |
| Khoá pha | `phase_id` | giá trị: `waiting` \| `upcoming` \| `date_day` \| `quiet` |
| Khoá dòng chính | `primary_line` | chuỗi đã dựng xong phía Dart |
| Khoá dòng phụ | `secondary_line` | vắng mặt = không vẽ dòng phụ |
| Khoá nhãn-mí pha | `eyebrow_line` | chuỗi hiển thị thứ ba, đã dựng xong phía Dart; MỚI, D-10 (2026-09-17), AC-37/BR-15 |
| Khoá thẻ liên quan | `card_id` | UUID v4 của thẻ, chỉ dùng cho deep link |
| Khoá ngày tính payload | `computed_on` | ngày dân dụng `YYYY-MM-DD` |
| Deep link khi chạm widget | `cupidapp://card/<card_id>` | đọc qua `HomeWidget.widgetClicked`; thiếu `card_id` thì dùng `cupidapp://home` |

Quy tắc cho phía tiêu thụ (native):

- Bốn giá trị `phase_id` là **tập đóng, ASCII, append-only**. Không dịch, không
  đổi thứ tự, không dùng chuỗi tiếng Việt làm khoá.
- `primary_line` / `secondary_line` / `eyebrow_line` là **ba sản phẩm cuối** —
  native vẽ y nguyên, không nối chuỗi, không chèn đơn vị, không chọn giữa các
  biến thể.
- `eyebrow_line` chỉ mang **tên pha khái quát** ("Đang đợi" / "Sắp hẹn" /
  "Đúng ngày hẹn" / "Khoảng lặng" hoặc tương đương) — không giờ, không số
  ngày, không tên thẻ/hoạt động, không gì về người kia (AC-9, AC-11, AC-12).
  Cùng ràng buộc cấm-chuỗi-cứng của §2 áp dụng: giá trị luôn tới từ payload,
  không bao giờ literal trong `cupid_phase_widget.xml`
  (`mobile/android/app/src/main/res/layout/`) hay `CupidPhaseWidget.swift`
  (`mobile/ios/CupidPhaseWidget/`).
- Khoá **bị cấm tuyệt đối** (BR-11/AC-11/AC-12): tiêu đề thẻ, ghi chú, từ khoá
  ghi chú, tên hoạt động/món quà do người dùng gõ, mọi nội dung nhật ký, mọi
  nội dung sổ tay, và mọi đại lượng hành vi người kia. Payload chỉ mang preset
  đã dựng + số do app tính.

## 3. Payload fields

| Khoá | Kiểu | Hợp đồng giá trị |
|---|---|---|
| `phase_id` | String | bắt buộc khi có payload; một trong bốn định danh §2 |
| `primary_line` | String | bắt buộc; đã bao gồm mọi số đã thay (ví dụ "còn 3 ngày") |
| `secondary_line` | String? | tuỳ chọn; vắng mặt là trạng thái hợp lệ, không phải lỗi |
| `eyebrow_line` | String | bắt buộc khi có payload; nguồn: trường `eyebrow` của item pha đang active trong `phase_content.v1.json` (§4); MỚI, D-10 (2026-09-17) |
| `card_id` | String? | vắng mặt ở pha `quiet` |
| `computed_on` | String | ngày Dart tính payload; native **không** so sánh với ngày hệ thống |

- Dart sở hữu **toàn bộ** việc định dạng, chọn biến thể, và thay số. Native
  không có nhánh logic nào theo ngày, theo pha, hay theo ngôn ngữ.
- **Chưa có payload nào** (mới cài, widget thêm trước lần mở app đầu): native vẽ
  khung trung tính **không chữ** (icon + nền). Không hardcode một chuỗi mặc định
  nào trong mã native — đó là vi phạm AC-37/BR-15 trực tiếp.
- Payload có thể cũ tới lần mở app gần nhất. Đây là **giới hạn được chấp nhận**
  (xem `solution.md` §4 risk `WIDGET-STALE`), không phải lỗi cần native bù.
- Implementation target cho `eyebrow_line` ở phía Dart: thêm hằng số
  `widgetKeyEyebrowLine = 'eyebrow_line'` cạnh khối hằng số hiện có
  (`mobile/lib/features/phase_status/data/home_widget_bridge.dart:22-26`) và
  thêm vào `widgetPayloadKeys` (cùng file, dòng 31-37) để mọi lần push đều ghi
  đủ sáu khoá — giữ đúng cơ chế "ghi `null` cho khoá vắng mặt" đã có cho
  `secondary_line`/`card_id`, tránh khoá cũ sống sót qua pha kế (`WIDGET-STALE`).

### 3a. Chỉ báo pha — native design token, KHÔNG phải payload key

D-10 (2026-09-17) thêm một chỉ báo pha cạnh `eyebrow_line`. Đây là **design
token do native tự tra theo `phase_id` đã có sẵn trong payload** (§2/§3) —
**không** phải khoá payload thứ bảy, không đi qua Dart/`home_widget`. Cùng cơ
chế branch-theo-`phase_id` mà `home_widget_bridge.dart` đã dùng cho nền pha
`date_day` (`widgetPhaseIdDateDay`, dòng 39-43) — native tự map bốn giá trị
đóng của `phase_id` (§2) sang bốn vai trò token dưới đây, không có giá trị thứ
năm và không có logic nội suy:

| `phase_id` | Vai trò token | Hình dạng (D-13) | Nhóm ngữ nghĩa (D-12) |
|---|---|---|---|
| `waiting` | `--dot-waiting` | chấm màu đặc | trung tính |
| `upcoming` | `--dot-upcoming` | chấm màu đặc | nhóm "đã xác nhận" (`--mint`/`--green`) |
| `date_day` | `--dot-today` | **glyph tia chớp** | nhóm hành động chính (`--pink`/`--grad`) |
| `quiet` | `--dot-quiet` | chấm màu đặc | biến thể tối/desaturated cùng bảng |

- Bốn tên vai trò này là **định danh ổn định** implementation phải dùng
  nguyên văn (Android: 4 color resource có tên tương ứng trong
  `mobile/android/app/src/main/res/`, ví dụ
  `@color/dot_waiting`/`dot_upcoming`/`dot_today`/`dot_quiet`; iOS: 4 Color
  Set/asset cùng tên trong `CupidPhaseWidget.swift`,
  `mobile/ios/CupidPhaseWidget/`).
- Giá trị hex/màu cụ thể do System UX Memory D-12 (bảng màu thương hiệu tối)
  định — **không lặp lại ở đây**; contract này chỉ cố định tên vai trò, ánh xạ
  `phase_id -> vai trò`, và hình dạng của từng vai trò.
- **Hình dạng (D-13, 2026-09-25).** Ba vai trò `--dot-waiting`,
  `--dot-upcoming`, `--dot-quiet` giữ nguyên hợp đồng cũ: chấm tròn màu đặc.
  Riêng `--dot-today` **phải** vẽ bằng **glyph tia chớp** khớp canvas
  `sb-84-widget-bon-pha`, không phải chấm tròn — vì nền gradient hồng→tím của
  D-12 ở pha `date_day` làm chấm hồng đặc gần như mất tương phản
  (`requirements.md` AC-9 vá 2026-09-25, `ux/uiux-spec.md` §2).
- Tên vai trò `--dot-today` **không đổi** dù hình dạng đổi: nó vẫn là khoá tra
  màu duy nhất cho pha `date_day`, nên ánh xạ D-12 không phải sửa. Glyph lấy
  màu (tint) từ chính `dot_today`; không có color resource/asset thứ năm.
- Glyph là **tài nguyên native ship kèm app**, không phải nội dung: Android là
  một vector drawable trong `mobile/android/app/src/main/res/drawable/`
  (`dot_today_bolt`) được tint bằng `@color/dot_today`; iOS là một symbol/asset
  tương đương trong `mobile/ios/CupidPhaseWidget/` tô bằng Color Set
  `dot_today`. Nó **không** là mục của gói nội dung §4, **không** thêm khoá
  payload, và **không** bao giờ đi qua `home_widget` (AC-37/BR-15: chỉ báo pha
  là token kể cả khi nó là glyph).
- Cấm: không đọc màu **hoặc hình dạng** từ payload, không dùng màu/icon mặc
  định hệ điều hành, không suy màu hay hình dạng bằng logic khác ngoài bảng tra
  bốn dòng trên (AC-12, "Chỉ báo pha là design token, không phải nội dung",
  `ux/uiux-spec.md` §2). Không dùng glyph cho ba pha còn lại và không dùng chấm
  cho `date_day`.

## 4. Lược đồ gói nội dung (R-15a / AC-37)

Ba gói, cùng `ContentPackage` ở `mobile/lib/core/content/content_package.dart`
(khoá gốc `schema_id` / `id` / `version` / `items`, mỗi item có `id` bền):

| Asset | `schema_id` | Mỗi item mang |
|---|---|---|
| `assets/data/req016/phase_content.v1.json` | `req016.phase_content.v1` | `phase_id`, `primary`, `secondary?`, `eyebrow` (MỚI, D-10: chuỗi khái quát tên pha, nguồn của `eyebrow_line` §3), `surface` (`widget` \| `screen` \| `both`) |
| `assets/data/req016/drip.v1.json` | `req016.drip.v1` | `body` |
| `assets/data/req016/nudges.v1.json` | `req016.nudges.v1` | `slot` (`evening_check_in` \| `countdown` \| `counter` \| `milestone` \| `gift_progress` \| `neutral`), `title?`, `body` |

- Chỗ thay số dùng placeholder `{n}` (ví dụ `"còn {n} ngày"`). Dart thay; ngoài
  `{n}` không có cú pháp template nào khác.
- `milestones.thresholds` là **mảng số nguyên trong `nudges.v1.json`** dưới khoá
  gốc `thresholds`, không phải hằng số Dart và **không** phải giá trị backend.
- Số mục mỗi gói là thuộc tính dữ liệu (R-15b). Không mã nào được đọc `length`
  để suy ra hành vi, và không AC nào được suy từ bộ seed.

## 5. Deploy / rollout order

Một bản dựng app duy nhất, không có thứ tự triển khai giữa hai bên. Ràng buộc
thay thế là **khoá native không hot-update được**: đổi tên bất kỳ khoá §2 nào
đòi hỏi người dùng cập nhật app, và trong lúc chưa cập nhật, widget đã đặt trên
màn hình **im lặng chuyển sang rỗng**. Vì vậy tập khoá §2 là append-only ngang
với `activity_cards` — thêm khoá được, đổi tên thì không.

Story này **không** đổi `CupidDatabase.schemaVersion` và **không** thêm cột nào
(BR-12/AC-4). Trạng thái riêng của story nằm trong `SharedPreferences`.

## 6. Phía tiêu thụ KHÔNG được làm

- Không đặt bất kỳ chuỗi nội dung nào trong mã Swift/Kotlin/XML, kể cả
  `eyebrow_line` (AC-37/BR-15).
- Không chọn màu **hoặc hình dạng** chỉ báo pha ngoài bảng tra bốn vai trò ở
  §3a — không màu/icon mặc định hệ điều hành, không suy bằng logic riêng theo
  ngày/ngôn ngữ/số.
- Không thêm hành động thứ hai lên widget (không nút "đã xong") — widget có đúng
  một vùng chạm mở deep link (`ux/uiux-spec.md` §2).
- Không đọc `activity_cards` hay `cupid.sqlite` từ native; native chỉ đọc §2.
- Không tự tính ngày/đếm ngược trong native, kể cả để "làm tươi lúc nửa đêm".
- Không thêm khoá mang văn bản người dùng tự gõ, dù trông vô hại (BR-11).

## 7. Quyết định P10 — tín hiệu suy biến AC-18 (2026-09-25)

Phạm vi: `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart`
và test của nó. Không liên quan hợp đồng widget §2-§4.

**Chọn phương án (a): bỏ lệnh cấm "không thêm tham số" của
`coding-plan/phase-P10-checkin-degrade-parity.md` §3, thêm một cờ năng lực
build tường minh, mặc định là "đã giao".**

Lý do phương án cũ sai, không chỉ là dead code:

- `_openFromPayload` (`evening_check_in_sheet.dart:562-568`) — nơi gọi sản
  xuất **duy nhất** — gọi `EveningCheckInSheet.show()` **không** truyền
  `openJournal`. Vậy `widget.openJournal` là `null` trên **đúng đường sản
  phẩm thật**, trong khi STORY-003 **đã** giao. Gate `widget.openJournal !=
  null` của P10 §3 vì thế bị **đảo ngược**: nếu implement đúng như viết, khối
  "viết một câu" sẽ biến mất ở bản ship — hồi quy trực tiếp AC-16, chứ không
  phải nhánh phòng thủ không bao giờ chạy. P10 §4 dòng 111-112 mô tả
  `openJournal != null` là "đường sản phẩm thật" — mô tả này sai so với mã.
- `_save()` (`evening_check_in_sheet.dart:368`) dùng
  `widget.openJournal ?? _openJournal`: tham số này là **seam cho test**
  (thay tuyến điều hướng), không phải tín hiệu tồn tại của nhật ký.
- `openJournalComposer` (`mobile/lib/features/journal/journal_entry_point.dart:57`)
  là hàm top-level vô điều kiện — không có trạng thái "vắng mặt" nào để dò ở
  runtime. `requirements.md:199` (AC-18) có mệnh đề Given phản thực tế hôm nay.

Hợp đồng phải implement:

- Thêm đúng **một** tham số tuỳ chọn có mặc định vào `EveningCheckInSheet` và
  `EveningCheckInSheet.show`, ví dụ `bool journalAvailable = true`. Đây là
  **cờ năng lực của bản dựng**, không phải seam test và không phải trạng thái
  runtime; tài liệu hoá ngay tại khai báo rằng giá trị sản xuất hiện tại luôn
  là `true`.
- Khối "viết một câu" (`TextField` + hai `_Chip`, dòng ~233-276) gate bằng
  `widget.journalAvailable`, **không** bằng `widget.openJournal`. Khi `false`:
  ẩn hẳn, không `enabled: false`, không xám. Lưới ảnh và dòng trấn an chân màn
  giữ nguyên vô điều kiện.
- Vì tham số là tuỳ chọn có mặc định `true`, `_openFromPayload` **không** phải
  sửa (giữ nguyên ngoài Write Scope của P10), và helper `_sheet()` trong
  `mobile/test/features/.../evening_check_in_sheet_test.dart:51-65` — vốn để
  `openJournal` mặc định `null` — vẫn gõ + lưu thành công. **Không assertion
  P6/P8 nào phải đổi.**
- Test AC-18 mới dựng sheet với `journalAvailable: false` và khẳng định
  `eveningCheckInFieldKey` + hai `_Chip` `findsNothing`, còn
  `eveningCheckInAttachKey` vẫn `findsOneWidget`.

Vì sao không chọn (b)/(c):

- (b) cho `_openFromPayload` truyền `openJournal` tường minh vẫn **không** tạo
  ra trạng thái vắng mặt nào (nó sẽ luôn truyền non-null), nên gate vẫn chết,
  đồng thời nới phạm vi sang nơi gọi mà không đổi được kết quả.
- (c) ghi AC-18 là `NOT_APPLICABLE` là cách đọc mã trung thực nhất, nhưng đổi
  trạng thái một AC là quyết định của Product Owner, không phải của Tech Lead,
  và sẽ chặn P10 chờ một vòng ac-patch. Phương án (a) đóng AC-18 ngay trong
  story này với ~3 dòng. Nếu Product Owner sau này chính thức rút AC-18, gỡ cờ
  `journalAvailable` là một thay đổi đảo ngược đúng bằng số dòng đã thêm.
