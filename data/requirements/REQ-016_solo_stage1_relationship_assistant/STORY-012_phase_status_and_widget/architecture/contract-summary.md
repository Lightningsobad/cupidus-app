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

### 3a. Chấm màu theo pha — native design token, KHÔNG phải payload key

D-10 (2026-09-17) thêm một chấm màu cạnh `eyebrow_line`. Đây là **design
token do native tự tra theo `phase_id` đã có sẵn trong payload** (§2/§3) —
**không** phải khoá payload thứ bảy, không đi qua Dart/`home_widget`. Cùng cơ
chế branch-theo-`phase_id` mà `home_widget_bridge.dart` đã dùng cho nền pha
`date_day` (`widgetPhaseIdDateDay`, dòng 39-43) — native tự map bốn giá trị
đóng của `phase_id` (§2) sang bốn vai trò token dưới đây, không có giá trị thứ
năm và không có logic nội suy:

| `phase_id` | Vai trò token | Nhóm ngữ nghĩa (D-12) |
|---|---|---|
| `waiting` | `--dot-waiting` | trung tính |
| `upcoming` | `--dot-upcoming` | nhóm "đã xác nhận" (`--mint`/`--green`) |
| `date_day` | `--dot-today` | nhóm hành động chính (`--pink`/`--grad`) |
| `quiet` | `--dot-quiet` | biến thể tối/desaturated cùng bảng |

- Bốn tên vai trò này là **định danh ổn định** implementation phải dùng
  nguyên văn (Android: 4 color resource có tên tương ứng trong
  `mobile/android/app/src/main/res/`, ví dụ
  `@color/dot_waiting`/`dot_upcoming`/`dot_today`/`dot_quiet`; iOS: 4 Color
  Set/asset cùng tên trong `CupidPhaseWidget.swift`,
  `mobile/ios/CupidPhaseWidget/`).
- Giá trị hex/màu cụ thể do System UX Memory D-12 (bảng màu thương hiệu tối)
  định — **không lặp lại ở đây**; contract này chỉ cố định tên vai trò và
  ánh xạ `phase_id -> vai trò`.
- Cấm: không đọc màu từ payload, không dùng màu mặc định hệ điều hành, không
  suy màu bằng logic khác ngoài bảng tra bốn dòng trên (AC-12, "Chấm màu theo
  pha là design token, không phải nội dung", `ux/uiux-spec.md` §2).

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
- Không chọn màu chấm ngoài bảng tra bốn vai trò ở §3a — không màu mặc định
  hệ điều hành, không suy màu bằng logic riêng theo ngày/ngôn ngữ/số.
- Không thêm hành động thứ hai lên widget (không nút "đã xong") — widget có đúng
  một vùng chạm mở deep link (`ux/uiux-spec.md` §2).
- Không đọc `activity_cards` hay `cupid.sqlite` từ native; native chỉ đọc §2.
- Không tự tính ngày/đếm ngược trong native, kể cả để "làm tươi lúc nửa đêm".
- Không thêm khoá mang văn bản người dùng tự gõ, dù trông vô hại (BR-11).
