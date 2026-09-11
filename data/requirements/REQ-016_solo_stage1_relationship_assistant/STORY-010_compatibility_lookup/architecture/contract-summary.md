# Cross-Lane Contract — REQ-016 STORY-010 Bảng tra ăn khớp

Authoritative source: `mobile/` package `cupid_mobile` (STORY-010).
Consumers: `mobile/` STORY-008 (cửa vào thứ hai từ màn (9)) và mọi nguồn nội
dung ngoài repo (CMS) cấp gói `compat_*`. Hợp đồng này tự chứa.

## 1. Envelope

Không wire protocol, không HTTP, không backend, không mô hình AI (AC-28).

**(A) Ba gói nội dung — Flutter asset JSON** trên engine `ContentPackage`
(`mobile/lib/core/content/content_package.dart`, do STORY-001 giao). Đây là một
**họ gói mới**; thư mục `assets/data/req016/` đã khai báo trong `pubspec.yaml`,
nên thêm gói không sửa `pubspec.yaml` và không sửa engine.

**(B) Cửa vào — một hàm Dart trong tiến trình.** Không route, không tên route,
không deep link (AC-3).

```dart
// mobile/lib/features/compatibility_lookup/compatibility_lookup_entry_point.dart
enum CompatibilityEntry { giftIdeas('gift_ideas'), dateScript('date_script') }

/// Push full-screen. Quay lại trả về đúng luồng gọi, giữ nguyên trạng thái.
Future<void> openCompatibilityLookup(
  BuildContext context, {
  required CompatibilityEntry from,
});
```

Sai khớp tên trường là **lỗi biên dịch Dart**; gói sai hình dạng là
`ContentPackageFormatException` **to và dừng** lúc nạp, không bao giờ suy giảm
thành gói rỗng.

## 2. Identifiers — copy exactly

| Mục đích | Định danh | Ràng buộc |
|---|---|---|
| Gói tập nhãn DẢI (dùng chung hai trục) | `req016.compat_bands.v1` | `assets/data/req016/compat_bands.v1.json` |
| Gói tra cứu hoàng đạo | `req016.compat_zodiac.v1` | `assets/data/req016/compat_zodiac.v1.json` |
| Gói tra cứu MBTI | `req016.compat_mbti.v1` | `assets/data/req016/compat_mbti.v1.json` |
| Loại item trong gói tra cứu | `axis_value` · `cell` | khoá `kind`; enum đóng, giá trị lạ là lỗi parse |
| Hệ nhãn (`CompatAxis`) | `zodiac` · `mbti` | hai gói **độc lập**, cấm gộp thành một chỉ số (BR-4) |
| Chủ thể một nhãn | `self` · `partner` | cột `relationship_labels.subject` |
| Độ chắc chắn của nhãn | `known` · `guess` | cột `relationship_labels.certainty`; `guess` bắt buộc hiện dấu phỏng đoán (AC-8) |
| Nguồn sinh thẻ của story này | `compatibility_lookup` | giá trị **cộng thêm** vào `ActivityCardOrigin` (STORY-001 §2 append-only) |
| Cửa vào hợp lệ | `gift_ideas` · `date_script` | `CompatibilityEntry`; append-only |
| Quy ước id ô | `<self_axis_id>__<partner_axis_id>` | ví dụ `aries__pisces`, `intj__enfp` |

Quy tắc cho phía tiêu thụ:

- `items[].id` là **id bền**: append-only, không đổi tên, không tái dùng, không
  xoá một id đã ship. Chỉ số trong `items` **không bao giờ** là định danh.
- Ô là **có hướng** (BR-2): `aries__pisces` và `pisces__aries` là **hai ô khác
  nhau**. Rút gọn về cặp không thứ tự là vi phạm phạm vi.
- `12`, `16`, `144`, `256` **không được xuất hiện trong `mobile/lib/`**. Kích
  thước trục là `số item kind: axis_value` của chính gói; độ phủ là `n²`
  (AC-36). Bộ seed đang ship được ghim ở 12/16 trong `mobile/test/`.
- Tập nhãn DẢI là **từ vựng**, không phải thang. Không trường thứ tự, không
  trường trọng số.

## 3. `compat_zodiac.v1` / `compat_mbti.v1` — item fields

| Khoá | Kiểu | Hợp đồng giá trị |
|---|---|---|
| `id` | string, bắt buộc | id bền; với `cell` theo quy ước `<self>__<partner>` |
| `kind` | string, bắt buộc | `axis_value` \| `cell` |
| `label` | string, bắt buộc khi `kind == axis_value` | nhãn hiển thị của một giá trị trục |
| `self_id` / `partner_id` | string, bắt buộc khi `kind == cell` | phải trỏ tới một `axis_value.id` trong **cùng gói** |
| `band_id` | string, bắt buộc khi `kind == cell` | phải trỏ tới một item của `req016.compat_bands.v1` |
| `fit` | string không rỗng, bắt buộc | *chỗ dễ hợp* |
| `friction` | string không rỗng, bắt buộc | *chỗ dễ va*; thiếu là **lỗi parse**, không phải biến thể hợp lệ (AC-13) |
| `activity` | string không rỗng, bắt buộc | *1 hoạt động nên thử*; là `title` của thẻ khi người dùng đẩy |
| `question` | string không rỗng, bắt buộc | *1 câu để hỏi*; **phải kết bằng `?`** (AC-20/AC-21) |

`compat_bands.v1` item: `id` + `label`, và **không gì khác**.

- **Cấm mọi JSON number** ở mọi item của cả ba gói. Không `order`, không `rank`,
  không `weight`, không `score`, không `level`. Một khi con số tồn tại ở tầng dữ
  liệu, nó sẽ rò ra màn hình ở lần sửa sau (BR-7/AC-16).
- Trường thiếu hoặc rỗng là **lỗi**, không phải `null` hợp lệ: bộ bốn không có
  trường tuỳ chọn.

## 4. `relationship_labels` — bảng Drift (STORY-010 sở hữu)

`id` TEXT PK (uuid v4) · `owner_key` TEXT NOT NULL (backend `User.id`, mọi truy
vấn lọc theo cột này) · `subject` TEXT NOT NULL (`self` | `partner`) · `system`
TEXT NOT NULL (`zodiac` | `mbti`) · `value` TEXT NOT NULL (một `axis_value.id`
của gói tương ứng) · `certainty` TEXT NOT NULL (`known` | `guess`) ·
`created_at` / `updated_at` DATETIME NOT NULL.
UNIQUE (`owner_key`, `subject`, `system`) — sửa/xoá nhãn (AC-9) là upsert/delete
trên đúng một hàng.

- **Cột bị cấm vĩnh viễn** (AC-31/AC-30, cưỡng chế ở test): mọi cột ghi DẢI,
  `band_id`, kết quả tra cứu, nhận định tính cách, hay điểm/hạng; mọi cột đo
  hành vi người kia (`partner_*`, `seen_*`, `reply_*`, `frequency_*`); mọi cột
  đếm số lần tra (AC-33).
- Bảng này là **nơi duy nhất** story lưu dữ liệu. Story **không** ghi vào
  `notebook_entries` / `skill_profile_entries` và không giữ tham chiếu tới
  `ContextNotebookRepository`.

## 5. Deploy / rollout order

Một binary duy nhất mang cả engine, gói nội dung, và schema — không có thứ tự
triển khai đa phía. Ba thứ tự có thật:

1. **Cổng nhập chạy trước khi bản dựng ra đời.** Test quét
   `assets/data/req016/compat_*.v1.json` từ đĩa và chạy `validateCompatPacks`;
   gói vi phạm → test đỏ → **bản dựng hỏng** (AC-14/AC-37/AC-38). Không có
   nhánh nào để vi phạm lọt tới người đọc.
2. **Migration cộng thêm.** `relationship_labels` là DDL mới nên
   `CupidDatabase.schemaVersion` +1. Đọc giá trị thật trên nhánh tích hợp lúc
   cài đặt rồi cộng một — **không** chép một con số từ tài liệu này. Chỉ
   `CREATE TABLE`; huỷ-tạo-lại bị cấm tuyệt đối.
3. **Bộ seed chưa qua lớp 2 chỉ dùng được ở bản dựng nội bộ** (AC-35/SB-123).
   Người duyệt lớp 2 của bộ seed là user (D-15).

## 6. Phía tiêu thụ KHÔNG được làm

- Không thêm `routeName`, không thêm mục vào `routes:` của `cupid_app.dart`,
  không thêm mục menu/tab bar. Cửa vào duy nhất là `openCompatibilityLookup`
  với một `CompatibilityEntry` (AC-2/AC-3).
- Không viết denylist luật hiển thị thứ hai. Luật sống ở
  `mobile/lib/core/content/invariant_terms.dart` và chỉ ở đó (R-15c). Không
  nối `notebookBoundaryHitsIn` nguyên khối — chỉ khoá `frequencyProbe`.
- Không gộp kết quả hai trục thành một chỉ số tổng hợp, không xếp hạng các lần
  tra với nhau, không lưu lịch sử tra để tạo thứ tự (BR-4/AC-18).
- Không thêm chức năng xuất/chia sẻ/chụp ảnh kết quả dưới bất kỳ tên nào
  (BR-8) — khác hẳn "xuất lời mời" của STORY-002.
- Không đặt chữ nội dung ô vào widget, ARB, hay hằng Dart; ngược lại không đặt
  luật bất biến vào asset (R-15a/R-15c).
- Không thêm bảng/danh sách thẻ thứ hai cho hoạt động đẩy từ màn này: dùng
  `ActivityCardRepository.createCard` với `origin: compatibility_lookup`, chỉ
  `title` là bắt buộc (STORY-001 §1).
- Không thêm trạng thái chờ mạng, skeleton "đang tra cứu", hay hiệu ứng gõ dần
  — tra cứu là một phép tìm trong bộ nhớ (AC-28/AC-29).
