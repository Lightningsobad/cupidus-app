# UX Spec: STORY-010 Bảng tra ăn khớp — màn (10), KHOÁ VỊ TRÍ

Requirement: REQ-016 · Story-Class: standard (complexity: complex) · Depends
On: STORY-004
Nguồn bắt buộc: `story_master.md`, `requirements/requirements.md`,
`../ux/requirement-ux-survey.md` mục 0/1/2/4/5, `STORY-009/ux/uiux-spec.md`
mục 3 (nhãn xuất xứ — dùng lại đúng vị trí/kiểu). `DESIGN_SOURCE_NOT_DETECTED`
bình thường ở giai đoạn này — spec dùng luật đo được, không tham chiếu ảnh
render.

## 1. Vị trí và cách mở

Màn (10), nhóm KHOÁ VỊ TRÍ. Mở từ liên kết văn bản cuối màn (5) (STORY-004,
chỗ đã dành) hoặc liên kết trong màn (9) khi STORY-008 đã giao. Push
full-screen, nút quay lại trả về đúng luồng nguồn, giữ nguyên trạng thái
(AC-4). Không route gõ tay được, không mục menu/tab bar (AC-2/AC-3).

## 2. Nhập liệu tự khai (khi thiếu nhãn)

1. Nếu sổ tay đã có nhãn hoàng đạo/MBTI của cả hai bên: bỏ qua bước này, vào
   thẳng kết quả.
2. Nếu thiếu nhãn của người kia (hoặc của chính người dùng): hỏi-tại-chỗ,
   dùng đúng cơ chế một-câu-một-lần của STORY-004 — KHÔNG hiện sẵn giá trị
   gợi ý/mặc định/đoán trước cho ô nhập của người kia (AC-6). Cho nhập riêng
   hoàng đạo hoặc riêng MBTI, không bắt đủ cả hai hệ (AC-11): kết quả bộ bốn
   ra ngay khi có đủ MỘT hệ nhãn cho cả hai bên.
3. Nhãn nhập ở chế độ "đoán" (người dùng tự nhận không chắc) hiển thị kèm dấu
   hiệu phỏng đoán, dùng đúng kiểu nhãn xuất xứ mà STORY-009 định nghĩa (icon
   nhỏ + chữ "bạn đang đoán" cạnh giá trị, không tô đậm như một trường dữ
   liệu đã xác nhận) — AC-8.
4. Người dùng từ chối nhập: nút "Bỏ qua, quay lại" trung tính, không nội
   dung trách móc, không hỏi lại trong cùng phiên (AC-10). Sửa/xoá nhãn đã
   nhập làm được ngay tại chỗ nhập, kết quả cập nhật theo (AC-9).

## 3. Bố cục kết quả — bộ bốn bắt buộc, DẢI là kiểu dữ liệu, điểm cọ xát ngang hàng

Đây là mục có luật đo được nghiêm ngặt nhất trong REQ-016 (D-14 + rủi ro
"trượt tâng bốc"). Bốn khối xuất hiện **theo đúng thứ tự cố định** sau, không
đảo, không gộp, không rút gọn:

1. **Khối DẢI** (đầu kết quả, ngay dưới nhãn xuất xứ sticky — dùng lại đúng
   vị trí/kiểu của STORY-009 mục 3.1/3.2 cho dòng "dựa trên nhãn bạn đã
   nhập"): giá trị DẢI hiển thị dưới dạng **một chip nhãn văn bản tĩnh**
   (pill nhỏ, nền `--r-sm`, một cụm từ lấy từ tập đóng ship kèm gói dữ liệu).
   Cấm tuyệt đối ở khối này — đây là nơi dễ trượt nhất: thanh progress dù
   không ghi số, vòng tròn dù không ghi %, dải màu chuyển sắc theo mức
   (gradient ngụ ý vị trí trên một trục liên tục), số sao, hay bất kỳ hình
   khối nào cho phép mắt "đọc" ra một vị trí tương đối. DẢI là MỘT NHÃN,
   không phải một điểm trên một thang — nếu component có thể trả lời câu
   "cái này đầy bao nhiêu phần?", nó SAI (AC-16/AC-17).
2. **Khối "Chỗ dễ hợp"** — khối `--r-sm`, tiêu đề phụ `600` + đoạn văn `body
   17pt`.
3. **Khối "Chỗ dễ va"** (điểm cọ xát, R-7) — đặt **NGAY SAU** khối "Chỗ dễ
   hợp", dùng **ĐÚNG HỆT** kiểu container, cỡ chữ, độ đậm tiêu đề, và bề rộng
   với khối "Chỗ dễ hợp" (cùng `--r-sm`, cùng `body 17pt`, cùng tiêu đề phụ
   `600`). **Cấm**: đặt khối này ở cuối màn, thu nhỏ cỡ chữ xuống `caption`,
   gập vào accordion "xem thêm"/"chi tiết", hay tô nhạt màu hơn khối "hợp".
   Luật đo được để nghiệm thu: che tiêu đề đi và đưa cho người khác xem, họ
   không được đoán ra khối nào là "điểm mạnh" và khối nào là "điểm cọ xát"
   chỉ bằng kiểu chữ/khung — hai khối đối xứng thị giác tuyệt đối, khác nhau
   CHỈ ở icon đầu tiêu đề (ví dụ `favorite` line cho "hợp" và `bolt` line cho
   "va" — icon khác, trọng lượng khung giống).
4. **Khối "1 hoạt động nên thử"** — khối `--r-sm`, đoạn văn ngắn + hành động
   phụ (không phải hành động chính SC-4) "Thêm vào kho của tôi" (text
   button/outline chip, `body 17pt/400`, đúng cột "hành động phụ" ở mục 4
   survey — không tô đặc `--grad` vì đây không phải hành động chính cấp
   thẻ).
5. **Khối "1 câu để hỏi"** — LUÔN đứng cuối cùng (AC-19), dùng đúng kiểu khối
   ở `STORY-009/ux/uiux-spec.md` mục 3.4 (nền tách lớp, icon `help_outline`,
   khác tông so với 3 khối trên).

## 4. Đẩy thẻ (SC-2)

Bấm "Thêm vào kho của tôi" ở khối "1 hoạt động nên thử" → **tạo thẻ ngay**,
trạng thái *Mới nghĩ ra*, snackbar hoàn tác 5 giây "Đã tạo thẻ mới trong kho
hoạt động — Hoàn tác" (đúng mẫu "tạo ngay + snackbar hoàn tác" mục 7 survey —
không hộp thoại xác nhận chặn). Màn (10) **không tự đóng** sau khi tạo thẻ
(khác STORY-008): người dùng có thể còn đọc "1 câu để hỏi" bên dưới, nên chỉ
snackbar nổi lên, màn giữ nguyên vị trí cuộn (AC-23/AC-25/AC-26).

## 5. Ngoại tuyến, tất định, kiểm duyệt

- Toàn bộ 400 ô là gói dữ liệu tĩnh — không skeleton chờ mạng, không trạng
  thái "đang tra cứu…"/"đang tính…" (R-7, AC-28/AC-29) — nếu cần độ trễ hiển
  thị (ví dụ chuyển màn), nó phải trông như tải dữ liệu (skeleton block
  tĩnh) chứ không như đang suy nghĩ (không hiệu ứng gõ dần, không icon xoay
  kiểu "AI đang đọc").
- Không nơi nào trên màn hiển thị "đã xem"/giờ mở/đếm lần của người kia
  (AC-30). Không lưu DẢI/kết quả vào sổ tay — sổ tay chỉ giữ nhãn tự khai
  (AC-31).
- Không ngôn ngữ tiên tri/vận mệnh (AC-32, R-10) — khối DẢI không dùng chữ
  "định mệnh", "số phận", "duyên số".
- Không streak/đếm số lần tra, không phần nào sau paywall (AC-33).

## 6. Trách nhiệm bàn giao

- Kiểm tra tự động "mỗi ô có ≥1 điểm cọ xát" (AC-14) là cổng dữ liệu, không
  phải việc của UI — nhưng UI cam kết **không layout nào có thể ẩn** khối
  "Chỗ dễ va" dù nội dung ngắn (ví dụ 1 câu): khối vẫn giữ đúng khung `--r-sm`
  full-width, không co lại thành một dòng caption.
- Không vẽ lại màn (5)/(9); chỉ tiêu thụ liên kết đã có.

## Completion
Điều kiện ship nội dung 400 ô vào bản build người dùng thật nay là R-15: qua
cổng nhập nội dung chạy được (R-15c) và có truy vết duyệt qua id bền; không
chặn màn, bố cục bộ bốn, luật DẢI, hay đường đẩy thẻ (`requirements.md` →
Open Question Impact).
