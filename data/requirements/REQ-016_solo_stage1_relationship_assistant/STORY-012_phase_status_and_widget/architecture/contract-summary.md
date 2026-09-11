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
| Khoá thẻ liên quan | `card_id` | UUID v4 của thẻ, chỉ dùng cho deep link |
| Khoá ngày tính payload | `computed_on` | ngày dân dụng `YYYY-MM-DD` |
| Deep link khi chạm widget | `cupidapp://card/<card_id>` | đọc qua `HomeWidget.widgetClicked`; thiếu `card_id` thì dùng `cupidapp://home` |

Quy tắc cho phía tiêu thụ (native):

- Bốn giá trị `phase_id` là **tập đóng, ASCII, append-only**. Không dịch, không
  đổi thứ tự, không dùng chuỗi tiếng Việt làm khoá.
- `primary_line` / `secondary_line` là **sản phẩm cuối** — native vẽ y nguyên,
  không nối chuỗi, không chèn đơn vị, không chọn giữa hai biến thể.
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
| `card_id` | String? | vắng mặt ở pha `quiet` |
| `computed_on` | String | ngày Dart tính payload; native **không** so sánh với ngày hệ thống |

- Dart sở hữu **toàn bộ** việc định dạng, chọn biến thể, và thay số. Native
  không có nhánh logic nào theo ngày, theo pha, hay theo ngôn ngữ.
- **Chưa có payload nào** (mới cài, widget thêm trước lần mở app đầu): native vẽ
  khung trung tính **không chữ** (icon + nền). Không hardcode một chuỗi mặc định
  nào trong mã native — đó là vi phạm AC-37/BR-15 trực tiếp.
- Payload có thể cũ tới lần mở app gần nhất. Đây là **giới hạn được chấp nhận**
  (xem `solution.md` §4 risk `WIDGET-STALE`), không phải lỗi cần native bù.

## 4. Lược đồ gói nội dung (R-15a / AC-37)

Ba gói, cùng `ContentPackage` ở `mobile/lib/core/content/content_package.dart`
(khoá gốc `schema_id` / `id` / `version` / `items`, mỗi item có `id` bền):

| Asset | `schema_id` | Mỗi item mang |
|---|---|---|
| `assets/data/req016/phase_content.v1.json` | `req016.phase_content.v1` | `phase_id`, `primary`, `secondary?`, `surface` (`widget` \| `screen` \| `both`) |
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

- Không đặt bất kỳ chuỗi nội dung nào trong mã Swift/Kotlin/XML (AC-37/BR-15).
- Không thêm hành động thứ hai lên widget (không nút "đã xong") — widget có đúng
  một vùng chạm mở deep link (`ux/uiux-spec.md` §2).
- Không đọc `activity_cards` hay `cupid.sqlite` từ native; native chỉ đọc §2.
- Không tự tính ngày/đếm ngược trong native, kể cả để "làm tươi lúc nửa đêm".
- Không thêm khoá mang văn bản người dùng tự gõ, dù trông vô hại (BR-11).
