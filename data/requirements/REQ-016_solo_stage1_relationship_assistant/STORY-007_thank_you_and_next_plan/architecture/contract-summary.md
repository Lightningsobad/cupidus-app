# Cross-Lane Contract — REQ-016 Cảm ơn + chốt việc kế tiếp

Authoritative source: module solo-stage-1 của app `mobile` (STORY-007).
Consumers: gói dữ liệu preset + cổng nhập nội dung của STORY-002; đường tạo thẻ
của STORY-001/STORY-005; mọi story sau đọc lại payload lời cảm ơn đã lưu.

Story này single-lane (mobile). File tồn tại vì các hợp đồng dưới đây **vượt
ranh giới story**: chúng được sở hữu bởi module của story khác và chỉ được
**thêm dữ liệu vào**, không được sửa hình dạng.

## 1. Envelope

Không có envelope mạng. Ba hợp đồng đều là **in-process**, tất định, trên thiết
bị:

1. **Danh mục preset** — dữ liệu tĩnh nạp qua đúng loader và đúng lược đồ mà
   STORY-002 đã ship (STORY-002 AC-20/AC-29). Envelope: **unchanged**.
2. **Payload lời cảm ơn đã lưu** — cùng payload render-lại-được SB-125 mà
   STORY-002 AC-17 đã định nghĩa. Envelope: **unchanged**.
3. **Tạo thẻ** — cùng lời gọi mà STORY-005 AC-11 dùng. Envelope: **unchanged**.

Sai khớp ở (1) là **lỗi bản dựng** (cổng nhập từ chối mục vi phạm, BR-18). Sai
khớp ở (2) là **mất dữ liệu im lặng**: payload cũ vẫn nạp được nhưng render ra
văn bản khác, không có lỗi nào được ném — đây là kiểu hỏng nguy hiểm nhất trong
ba cái, và là lý do mục 6 dưới đây tồn tại.

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---|---|---|
| Id danh mục preset mới | `thank_you_after_date` | tham số `categoryId` của sheet STORY-002; cạnh `inviteCategoryId = 'invite'` |
| File gói preset | `mobile/assets/data/req016/presets.thank_you_after_date.v1.json` | sinh ra từ `presetAssetKey(categoryId)`, quy ước chuỗi, **không** sửa hàm đó |
| Schema id của gói | `req016.presets.v1` | hằng `presetsSchemaId` dùng chung mọi danh mục |
| Id từng preset trong danh mục | `thank_you_after_date.<slug>` | khoá bền, dùng làm khoá truy vết duyệt (BR-16) |
| Nguồn sinh của thẻ tạo từ phần 3 | `next_plan_after_date` | trường `nguồn sinh` của thẻ, STORY-001 AC-9 |

Schema id là cái bẫy được ghi sẵn trong code: comment tại
`preset_catalogue.dart:5` gọi đích danh story này và cấm đúc
`req016.presets.thanks.v1`, vì một schema id theo danh mục sẽ tách cổng nội
dung thành nhánh thứ hai và phá AC-29.

Rules for the consumer side:

- Id danh mục và id preset là **append-only**: không đổi tên, không sắp xếp
  lại, không tái dùng một id đã ship cho nội dung khác. Một preset bị gỡ phải
  để lại id của nó vĩnh viễn không được cấp lại — payload đã lưu tham chiếu tới
  nó (mục 1, hợp đồng 2).
- Viết `thankYouAfterDate`, `thank-you-after-date`, hay `thankyou_after_date`
  là **sai**: khớp là khớp chuỗi thuần, và sai chính tả ở đây không làm hỏng
  bản dựng — nó làm danh mục im lặng không nạp được.
- Consumer **không** được đặt id danh mục nào khác bắt đầu bằng
  `thank_you_` cho tới khi story này ship xong.

## 3. Mục preset của danh mục `thank_you_after_date`

| Order | Key | Rendered/exposed as | Value contract |
|---|---|---|---|
| 1 | id preset | không hiển thị | chuỗi bền, duy nhất trong gói, append-only |
| 2 | khung nhại (template) | văn bản người dùng đọc | cùng cú pháp mad-libs của danh mục `lời mời`; biến thiếu phải tự tiêu biến (AC-11) |
| 3 | phiên bản preset | không hiển thị | tăng khi nội dung đổi; payload đã lưu ghim phiên bản này |
| 4 | truy vết duyệt | không hiển thị | khoá theo id preset (BR-15/BR-16) |

- **Lược đồ do STORY-002 sở hữu.** Nếu một trường trong bảng trên không tồn
  tại trong gói đã ship, đó là dấu hiệu STORY-002 AC-20/AC-21 đã bị phá — dừng
  theo BR-5, **không** thêm trường riêng cho danh mục này.
- Số preset `N` của danh mục là **thuộc tính dữ liệu**, không phải hằng số
  (BR-17). Không consumer nào được viết logic dựa trên một giá trị N cụ thể.
- Mục thừa/thiếu khoá bị cổng nhập từ chối và làm hỏng bản dựng (BR-18).

## 4. Lời gọi tạo thẻ từ phần 3

| Order | Key | Rendered/exposed as | Value contract |
|---|---|---|---|
| 1 | trạng thái khởi tạo | ngăn *Mới nghĩ ra* ở màn (1) | luôn là *Mới nghĩ ra* (AC-20) |
| 2 | tiêu đề | tiêu đề thẻ | lấy nguyên văn từ chip gợi ý đã chọn |
| 3 | ngày hẹn | trường ngày của thẻ | điền sẵn **chỉ khi** gợi ý gắn với dịp có ngày cụ thể (AC-21); người dùng sửa được ngay |
| 4 | nguồn sinh | không bao giờ hiển thị như chỉ số đánh giá | `next_plan_after_date` (AC-24, STORY-001 AC-9) |

- Ngày của dịp lịch âm **phải** lấy từ hàm tính trên thiết bị của STORY-005
  (AC-18), không tự tính lại, không gọi dịch vụ ngoài.
- Undo (snackbar 5 giây) phải xoá thẻ qua **cùng** contract, không để lại bản
  ghi mồ côi nào.

## 5. Deploy / rollout order

Một app, một lần build — không có thứ tự triển khai giữa hai bên. Ràng buộc thứ
tự duy nhất là **thứ tự merge**: nhánh story này phải đứng trên một base đã có
STORY-001/002/003/005. Nếu build trên base thiếu chúng, hỏng là **ồn và thấy
ngay** (lỗi biên dịch), không im lặng — xem `solution.md` mục 1 Key Discovery (a).

## 6. What the consumer must NOT do

- Không sửa engine render để phục vụ danh mục này (BR-5, STORY-002 AC-21).
- Không tạo lược đồ/gói dữ liệu riêng cho danh mục mới (AC-33).
- Không thêm nhánh cổng nhập thứ hai (AC-36, STORY-002 AC-29).
- Không lưu lời cảm ơn dưới dạng chuỗi text đã bẹp (AC-13, BR-7).
- Không tạo danh sách "việc kế tiếp" thứ hai ngoài kho thẻ chung (BR-11).
- Không cấp lại một id preset đã ship cho nội dung khác — payload đã lưu sẽ
  render ra câu khác mà không báo lỗi.
