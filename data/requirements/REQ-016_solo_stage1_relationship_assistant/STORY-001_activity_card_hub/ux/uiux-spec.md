# UX Spec: STORY-001 Danh sách việc-cần-làm — kho chung và vòng đời thẻ

Requirement: REQ-016 · Story-Class: shared-foundation
Nguồn bắt buộc: `story_master.md`, `requirements/requirements.md`,
`../ux/requirement-ux-survey.md` (bản đồ điều hướng, action-tier, empty-state).
`detect_design_source.py` → `DESIGN_SOURCE_NOT_DETECTED` là bình thường ở giai
đoạn này; spec dưới đây dùng luật đo được, không tham chiếu ảnh render.

## 1. Vị trí trong shell

**Đã sửa theo D-3 (anchor on design, `../../req_master.md` →
`## Design Ruling Log`).** Bề mặt solo chặng 1 **có thanh tab riêng 4 mục**
thay cho thanh shell hiện có; story này sở hữu thanh tab đó và route của nó.

- 4 mục, đúng thứ tự: **Muốn làm · Ý tưởng · Sổ tay · Nhật ký**.
- "Muốn làm" là mục **đầu tiên và mặc định**, và trỏ tới màn danh sách của
  story này. Ba mục còn lại là **vỏ giữ chỗ** trong phạm vi story này (route
  tồn tại, điều hướng chạy được, nội dung do story khác điền) — chúng không
  được trở thành kho thẻ thứ hai (AC-21/SC-1').
- Mỗi mục: icon `line` + nhãn chữ bên dưới; mục đang chọn tô `--pink`, mục
  chưa chọn `colorTextMuted`. Ô chạm tối thiểu 44pt (iOS) / 48dp (Android).
- Thanh tab chỉ áp cho nhánh solo (`isPaired == false` hoặc chưa từng ghép)
  trong `home_screen.dart`; nhánh đã ghép giữ nguyên shell cũ.

Bố cục màn "Muốn làm", từ trên xuống:

1. Header rút gọn (không thuộc phạm vi story này — giữ chỗ cho STORY-012 gắn
   bộ đếm "của cải đang lớn").
2. Dải lối-vào-nhanh 3 ô cố định (khung layout của story này; nội dung ô do
   STORY-004/005/011 điền — xem mục 6).
3. Segmented filter 5 ngăn (component mới, xem mục 3).
4. Danh sách thẻ của ngăn đang chọn, hoặc trạng thái rỗng.
5. Nút nổi/inline "+" tạo thẻ nhanh (luôn hiện, trừ lúc màn ở trạng thái rỗng
   Phút-1 nơi hai CTA lời mời đã thay thế nó — xem mục 4).

## 2. Mô hình thẻ và bố cục thẻ trong danh sách

Trường (SB-76, AC-8 STORY-001): tiêu đề (bắt buộc), loại hoạt động, ngày hẹn,
giá, khoảng cách, cần đặt trước (có/không), trong nhà/ngoài trời, ghi chú,
ảnh/ký ức, link nguồn, nguồn sinh (ẩn với người dùng, chỉ dùng nội bộ — AC-9).

**Thẻ rút gọn (list item)** — `--r-card` (26/24px), đệm `md` (16px):
- Dòng 1: tiêu đề, `body 17pt / 600`, tối đa 2 dòng, ellipsis.
- Dòng 2 (tuỳ chọn, chỉ hiện nếu có dữ liệu): icon loại hoạt động (`line`
  variant) + nhãn ngày hẹn hoặc khoảng cách, `caption 13pt`, màu `colorTextMuted`.
- Không hiển thị giá trên thẻ rút gọn nếu nguồn sinh = "gợi ý quà" (đối chiếu
  BR-6/AC-23 của STORY-004 — trường `giá` để trống ở luồng quà; ở STORY-001,
  quy tắc trình bày là: **giá chỉ hiện trên thẻ rút gọn khi trường có giá trị
  > 0**, không hiện nhãn "chưa có giá").
- Footer: đúng **một** hành động chính (pill, `--r-btn`, nền `--grad`), căn
  phải hoặc full-width tuỳ số ký tự nhãn — nhãn theo đúng bảng SC-4 dưới đây.
  Không có hành động chính thứ hai trên cùng thẻ (AC-11, AC-2 của STORY-002).
- **Ô tràn "…" (đã sửa theo D-2, `../../req_master.md` →
  `## Design Ruling Log`):** thẻ được phép mang thêm **tối đa một** ô tràn, đặt
  **ngay bên phải CTA** trên cùng hàng footer, dạng nút tròn nền mờ (`--r-btn`
  bo tròn hoàn toàn, nền `colorSurfaceMuted`, không dùng `--grad`), icon "…"
  `line`, ô chạm 44pt/48dp. Nội dung ô tràn chỉ là **lựa chọn phụ**: "Chuyển
  trạng thái", "Sửa", "Xoá". Ô tràn không được chứa một CTA thứ hai, không được
  dùng nền gradient, và không được rộng ngang CTA. Đường xoá hiện có trên mặt
  thẻ **giữ nguyên** (AC-13/AC-16); D-4 không nằm trong phán quyết D-1/D-2/D-3
  nên không đổi ở vòng này.

**Bảng SC-4 — nhãn hành động chính theo trạng thái (đo được, không đổi bởi
story sau):**

| Trạng thái | Nhãn hành động chính | Kết quả khi bấm |
|---|---|---|
| Mới nghĩ ra | "Hẹn ngày" | Mở date picker → lưu ngày → chuyển *Đã hẹn ngày* |
| Đã hẹn ngày | "Chuẩn bị" | Mở luồng chuẩn bị (bottom sheet xuất lời mời của STORY-002 là một lựa chọn bên trong luồng này, không phải nhãn nút thay thế) |
| Đã đi rồi | "Ghi lại" | Mở chi tiết thẻ ở chế độ ghi ký ức (ảnh/ghi chú) |
| Đã thành kỷ niệm | "Xem lại" | Mở chi tiết thẻ ở chế độ chỉ đọc + ảnh/ký ức |

Story sau (STORY-002/006/007/008) không được đổi 4 nhãn này hay thêm hành
động chính thứ hai; chúng chỉ được thêm **lựa chọn bên trong** luồng mà một
nhãn đã dẫn tới, hoặc **mục phụ trong ô tràn "…"**, theo luật action-tier ở
`../ux/requirement-ux-survey.md` mục 4. D-2 nới **dạng trình bày** của hành
động phụ, không nới bảng nhãn CTA ở trên.

**Phạm vi áp dụng của bảng SC-4 (đã sửa theo D-18/D-19,
`../../req_master.md` → `## Design Ruling Log`):** bảng SC-4 ở trên là
**nguồn sự thật duy nhất** về chữ nhãn hành động chính cho thẻ rút gọn (P4)
và cho **mọi** màn hình trừ màn chi tiết thẻ A4 ("Chi tiết thẻ mới nghĩ ra").
Riêng khu CTA của màn A4:
- **Chữ CTA (D-18):** được phép dùng văn bản theo ngữ cảnh riêng của màn theo
  canvas (`design-reference-chi-tiet-the-moi-nghi-ra-ios.png`), ví dụ "Chốt
  ngày đi thôi" · "Đọc lại · rủ đi lần nữa", thay cho chữ cố định trong bảng.
  Chỉ **chữ** được nới; **hành vi khi bấm** và **kết quả chuyển trạng thái**
  vẫn phải khớp đúng dòng tương ứng của bảng SC-4.
- **Dòng hành động phụ (D-19):** được phép thêm **đúng một** dòng hành động
  phụ đặt **dưới** CTA chính (ví dụ theo canvas: "hoặc soạn lời rủ cho ngọt ·
  để dành hôm khác"). Dòng này là **hành động phụ**, không phải CTA thứ hai:
  không nền `--grad`, không dạng pill ngang hàng CTA, không được chọn hoặc
  tính như hành động chính (AC-11).

Ngoại lệ này **không** đổi hợp đồng/hành vi của `activityPrimaryActionFor` cho
thẻ rút gọn: P4 vẫn lấy nhãn cố định từ bảng SC-4 ("Hẹn ngày" / "Chuẩn bị" /
"Ghi lại" / "Xem lại") và vẫn giữ đúng một CTA, không có dòng hành động phụ.

**Chỉ báo "đã rủ" (R-1b):** nếu thẻ đang ở trạng thái *Đã hẹn ngày* và mang cờ
"đã rủ", hiện một toggle 2 trạng thái nhỏ cạnh dòng 2: "Chưa trả lời" /
"Đã trả lời" — chip nhỏ, `caption 13pt`, màu trung tính khi "chưa trả lời",
màu `--mint` khi "đã trả lời". Đây là **thông tin**, không phải hành động
chính; không đặt cạnh hoặc thay thế nút "Chuẩn bị". Không có biến thể thứ ba,
không có nhãn thời gian đi kèm ("đã trả lời 2 giờ trước" là vi phạm R-1b).

## 3. Segmented filter 5 ngăn (component mới — owner: STORY-001)

**Đã sửa theo D-1 (anchor on design, `../../req_master.md` →
`## Design Ruling Log`).** Trả lời OQ-2 phần UI còn mở. Quyết định: **segmented
control cố định 5 ô**, neo ngay dưới dải lối-vào-nhanh, sticky khi cuộn danh
sách.

- 5 nhãn cố định, không rút gọn bằng số: "Tất cả", "Mới nghĩ ra", "Đã hẹn
  ngày", "Đã đi rồi", "Đã thành kỷ niệm".
- Ngăn **"Tất cả" đứng đầu** và là ngăn **được chọn mặc định** khi mở màn. Nó
  liệt kê thẻ ở mọi trạng thái, và số đếm của nó là **tổng** số thẻ trong kho
  (ví dụ canvas: "Tất cả · 14" = 8 + 2 + 3 + 1).
- "Tất cả" là một **view lọc**, không phải trạng thái thứ 5: không thẻ nào
  được lưu ở trạng thái này, picker chuyển trạng thái ở mục 5 vẫn đúng 4 lựa
  chọn, và bảng SC-4 ở mục 2 không đổi.
- Nếu tổng chiều rộng 5 nhãn vượt màn hình nhỏ nhất hỗ trợ, toàn bộ dải cuộn
  ngang được (không rút gọn chữ, không dùng số/icon thay chữ) — đây là dải
  điều hướng thứ 2 trong màn, khác về bản chất với dải lối-vào-nhanh ở mục 6
  (dải đó dẫn ra màn khác; dải này lọc trong cùng một kho — không vi phạm
  SC-1' vì cả hai không phải là danh sách dữ liệu thứ hai).
- Trạng thái đang chọn: nền pill đặc `--pink`, chữ trắng, `body 17pt/600`.
  Trạng thái chưa chọn: viền mỏng, nền trong suốt, chữ `colorTextMuted`,
  `body 17pt/400`.
- Chiều cao tối thiểu ô chạm: 44pt (iOS) / 48dp (Android).
- Mỗi ô hiển thị số lượng thẻ trong ngăn dưới dạng số nhỏ cạnh nhãn (`caption
  13pt`, không phải badge đỏ báo động) — số này chỉ đếm dữ liệu của **chính
  người dùng**, không liên quan hành vi người kia (không vi phạm R-1b).

## 4. Trạng thái rỗng

### 4a. Rỗng tuyệt đối lần đầu (AC-1..AC-5) — mẫu "Phút 1"
Khi kho không có thẻ nào (bất kể ngăn): ẩn segmented filter (không có gì để
lọc), hiện đúng 2 thẻ lời mời lớn, xếp dọc, mỗi thẻ là một pill/card riêng
(không phải form):

1. "Dán 1 link em vừa thấy" — icon link (`line`), chạm mở ô dán nhanh (1
   trường duy nhất: URL), lưu ngay khi dán xong, không có nút "Lưu" phụ chờ
   xác nhận thêm trường nào khác.
2. "Để app gợi ý 1 việc theo dịp gần nhất" — icon lịch (`line`), chạm hiện
   1-2 gợi ý tất định (AC-3), mỗi gợi ý là một hàng chạm-để-tạo-thẻ ngay.

Không có ảnh minh hoạ lớn kiểu "hộp thư trống", không có câu mời gọi dài dòng
kiểu marketing — tối đa một dòng tiêu đề ngắn phía trên 2 lời mời (ví dụ:
"Bắt đầu bằng 1 trong 2 cách này"), không có mô tả đoạn văn.

Dải lối-vào-nhanh 3 ô (mục 6) **vẫn hiện** ở trạng thái này — nó không phải
form và không cạnh tranh với 2 lời mời.

### 4b. Một ngăn cụ thể rỗng (kho đã có thẻ ở ngăn khác)
Một dòng trung tính, `body 17pt`, màu `colorTextMuted`, ví dụ: "Chưa có thẻ
nào ở đây." + một liên kết văn bản (không phải pill đầy màu) quay về ngăn
"Tất cả". Không lặp lại 2 lời mời Phút-1.

## 5. Chi tiết thẻ, chuyển trạng thái, xoá

- Chi tiết thẻ mở dạng full-screen (không phải bottom sheet, để chừa chỗ cho
  các khối mở rộng của STORY-006/007 lồng bên trong sau này).
- Chuyển trạng thái thủ công 2 chiều (AC-14): một hàng "Chuyển trạng thái"
  trong chi tiết thẻ, mở picker 4 lựa chọn (không giới hạn hướng tiến/lùi).
- Lùi trạng thái làm mất ngày hẹn/dữ liệu đã nhập (AC-15): khi lùi từ *Đã hẹn
  ngày* về *Mới nghĩ ra*, hiện hộp thoại xác nhận ngắn "Giữ ngày hẹn đã lưu
  hay xoá luôn?" — 2 lựa chọn rõ ràng, không có lựa chọn mặc định được bấm
  ngầm định là xoá.
- Xoá thẻ (AC-16, R-1c): 1 hộp thoại xác nhận trung tính — tiêu đề "Xoá thẻ
  này?", không hỏi lý do, không câu cảm xúc, 2 nút ngang hàng thị giác ("Huỷ" /
  "Xoá" màu `--red` chỉ trên nút xoá, không tô đỏ toàn hộp thoại).

## 6. Dải lối-vào-nhanh 3 ô (khung — owner STORY-001, nội dung ô — story khác)

Nằm ngay dưới header, trên segmented filter. Đúng 3 ô cố định, không thêm/bớt
theo dữ liệu người dùng, không cuộn kiểu feed vô hạn (khác về bản chất với
kho thẻ — không vi phạm SC-1'):

| Vị trí | Ô | Story điền nội dung |
|---|---|---|
| 1 | Gợi ý quà | STORY-004 |
| 2 | Mồi chuyện | STORY-005 |
| 3 | Vỏ hoàng đạo | STORY-011 |

Mỗi ô: icon (`filled` variant, để phân biệt thị giác với hành động phụ theo
mục 4 của survey) + nhãn 1 dòng, kích thước bằng nhau, bố cục hàng ngang 3
cột đều nhau trên màn hình chuẩn (cuộn ngang nếu màn quá hẹp). Ô KHÔNG có
badge số, không có chấm "mới" — tránh mọi tín hiệu thúc giục mở hằng ngày.

Nếu story điền nội dung (004/005/011) chưa giao, ô vẫn hiện nhưng dẫn tới màn
"sắp có" trung tính — không ẩn ô, để layout 3 cột không đổi hình dạng giữa các
story.

## 7. Ranh giới đạo đức thể hiện trong UI

- Không nơi nào trên màn hiển thị "đã xem", giờ mở, số lần mở, hay bất kỳ số
  liệu tần suất nào của người kia (AC-18). Toggle "đã rủ" ở mục 2 là **cờ nhị
  phân do người dùng tự bấm**, không phải nhật ký thời gian.
  Chỉ số đếm số lượng thẻ theo ngăn (mục 3) đếm dữ liệu của người dùng, không
  phải hành vi người kia — không vi phạm.
- Không streak, không chuỗi ngày, không huy hiệu ở bất kỳ đâu trên màn này
  (AC-20). Bộ đếm "của cải đang lớn" (khác — đếm số kỷ niệm tích luỹ, không có
  tham số thời gian liên tục) thuộc STORY-012, không vẽ ở story này.
- Giọng nội dung: "trợ lý hoạt động", tránh mọi câu văn có ngữ điệu bói toán
  hoặc tán tỉnh (BR-9).

## 8. Trách nhiệm bàn giao cho story sau (không được vẽ khác)

- Mô hình thẻ, 4 nhãn hành động chính, action-tier hai tầng (CTA + tối đa một ô
  tràn "…"), dải lối-vào-nhanh 3 ô, và thanh tab 4 mục chặng 1 là **hợp đồng
  khoá**. STORY-002/004/005/006/007/008/009/010/011/012/013 đọc nguyên các quy
  ước này; đổi khác ở UI của story sau mà không quay lại story này là vi phạm
  shared-foundation.
- Ba mục tab "Ý tưởng · Sổ tay · Nhật ký" là vỏ giữ chỗ do story này tạo. Story
  gắn nội dung vào chúng phải giữ AC-21/SC-1': không mục nào được trở thành kho
  thẻ thứ hai.
- STORY-006/007 lồng khối mở rộng vào "Chi tiết thẻ" (mục 5) theo action-tier
  ở mục 4 của survey — không đổi 4 nhãn SC-4.

## Completion
Không có OQ nào chặn phạm vi UX của story này (đối chiếu `requirements.md` →
`## Open Question Impact`: KHÔNG CÓ scope item bị chặn). Spec trên là đầy đủ.
