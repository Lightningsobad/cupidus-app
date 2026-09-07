# UX Spec: STORY-009 Chân dung "theo cách BẠN nhìn" — màn (8), KHOÁ VỊ TRÍ

Requirement: REQ-016 · Story-Class: standard · Depends On: STORY-004
Nguồn bắt buộc: `story_master.md`, `requirements/requirements.md`,
`../ux/requirement-ux-survey.md` mục 0/1/2 (khoá vị trí, nhãn xuất xứ) và mục
4 (action-tier). `DESIGN_SOURCE_NOT_DETECTED` bình thường ở giai đoạn này —
spec dùng luật đo được, không tham chiếu ảnh render.

## 1. Vị trí và cách mở

Màn (8), nhóm KHOÁ VỊ TRÍ. Mở DUY NHẤT từ liên kết văn bản cuối màn (5) Gợi ý
quà (chỗ đã để dành ở `STORY-004/ux/uiux-spec.md` mục "Liên kết khoá vị trí")
hoặc liên kết tương tự trong màn (9) khi STORY-008 đã giao
(`STORY-008/ux/uiux-spec.md` mục 5). Push full-screen, có nút quay lại. Không
route đặt tên gõ tay được, không mục menu/tab bar nào dẫn tới (AC-2, AC-3).
Đóng màn → quay lại đúng luồng nguồn, giữ nguyên trạng thái luồng đó (AC-4).

## 2. Bố cục bộ câu hỏi (nhập liệu)

1. Danh sách câu hỏi hiển thị TỪNG CÂU MỘT (không phải form dài cuộn), có nút
   "Bỏ qua" cùng hàng với mỗi câu (mọi câu đều tuỳ chọn, AC-27) và nút "Tiếp"
   để sang câu kế.
2. Chỉ báo vị trí trong bộ câu hỏi hiện tại (ví dụ "câu 3/8") được phép, chỉ
   trong MỘT phiên câu hỏi — KHÔNG phải progress bar mang nghĩa "hoàn thành
   bao nhiêu %" tồn tại giữa các phiên, KHÔNG có badge nhắc "chưa xong" ở bất
   cứ đâu trong app giữa các lần dùng (AC-26).
3. Bỏ dở giữa chừng: đóng màn ở bất kỳ câu nào, mở lại lần sau vào ĐÚNG câu
   đang dở, không banner "hoàn tất chân dung của bạn" ở bất cứ đâu (AC-25).
4. Câu hỏi thuộc loại sở thích/sự kiện gắn cờ ngầm "sẽ lưu vào sổ tay" — ẩn
   với người dùng, không cần họ xác nhận riêng; câu thuần phỏng đoán tính
   cách không gắn cờ này (AC-22/AC-23).

## 3. Bố cục kết quả — nhãn xuất xứ nằm trong BỐ CỤC (pattern owner, STORY-010 dùng lại)

1. Đầu màn kết quả: khối tiêu đề gồm (a) tên màn tự gọi đúng "Chân dung TƯỞNG
   TƯỢNG theo cách bạn nhìn" (AC-9 — không dùng chữ "hồ sơ"/"phân tích"/"đánh
   giá") và (b) **nhãn xuất xứ "Dựa trên những gì bạn đã nhập"** ngay dưới
   tiêu đề, cùng khối, `body 17pt` hoặc `caption 13pt` nhưng **không nhỏ hơn
   13pt và không đặt trong tooltip/banner tắt-được** — là một dòng cố định
   của bố cục đầu trang, cùng cấp thị giác với nội dung (AC-6).
2. **Nhãn xuất xứ là sticky header phụ**: khi cuộn kết quả, nhãn ở lại trong
   vùng nhìn thấy (ghim ngay dưới app bar cùng tiêu đề rút gọn) — không cuộn
   mất theo nội dung ở bất kỳ vị trí cuộn nào (AC-7). Luật đo được để nghiệm
   thu: cuộn hết màn, nhãn vẫn đọc được.
3. Thân kết quả chia theo phần (mỗi phần ứng một nhóm câu hỏi đã đủ dữ
   liệu). Mỗi phần là một khối `--r-sm`, tiêu đề phụ + đoạn văn `body 17pt`
   viết ở giọng "theo cách bạn đang thấy" ("bạn đang thấy rằng…", "theo cách
   bạn kể…") — KHÔNG BAO GIỜ giọng khẳng định ("người ấy là…"). Nội dung
   chính xác là trách nhiệm biên tập (R-15), nhưng UI khoá khuôn câu mở đầu
   này cho mọi phần, không để nội dung tự do chọn giọng.
4. **Mỗi khối phần kết thúc bằng một dòng "Câu để hỏi"** tách biệt thị giác:
   nền khác tông (nhạt hơn/đậm hơn đoạn văn phía trên) trong cùng `--r-sm`,
   icon `help_outline` (line) đứng trước, chữ `500` weight — đủ khác để
   người đọc nhận ra đây là điểm hành động, không phải câu kết luận (AC-16).
5. Nếu dữ liệu quá mỏng để dựng một phần, phần đó KHÔNG hiện (không khối
   rỗng, không "chưa đủ dữ liệu") — hoặc hiện thẳng câu-để-hỏi không kèm đoạn
   văn diễn giải phía trên (AC-19). Không trạng thái loading/spinner "đang
   phân tích" ở bất kỳ bước chuyển nào — nếu cần độ trễ, nó trông như tải dữ
   liệu tất định (skeleton tĩnh), không như đang suy nghĩ (không hiệu ứng gõ
   chữ dần, không icon "AI đang đọc bạn").
6. Cuối toàn màn kết quả: KHÔNG có nút xuất/chia sẻ/sao chép (AC-24) — chỉ
   nút quay lại luồng nguồn.

## 4. Ranh giới đạo đức và luật ba tầng thể hiện trong UI

- Không phần tử nào trên màn hiển thị điểm số, %, sao, hay xếp hạng về người
  kia (AC-12) — không biểu đồ, không thanh, không huy hiệu kết quả.
- Không streak, không đếm số câu đã trả lời, không huy hiệu hoàn thành
  (AC-28) — kể cả một con số nhỏ kiểu "bạn đã hiểu 60% về X" là vi phạm R-1
  nấc 4 dù không tự xưng là %.
- Không phần nào của story nằm sau paywall (AC-28/R-14).
- Toàn bộ render tất định — hai lần xem cùng bộ trả lời phải giống hệt nhau
  (AC-29), không yếu tố ngẫu nhiên hoá cách trình bày.

## 5. Trách nhiệm bàn giao cho STORY-010

- **Nhãn xuất xứ ở mục 3.1/3.2 là pattern khoá**: STORY-010 dùng lại đúng vị
  trí (đầu kết quả, sticky khi cuộn) và đúng ngưỡng cỡ chữ tối thiểu khi hiển
  thị nhãn "đây là dữ liệu bạn tự khai/tự đoán" cho dấu hoàng đạo/MBTI của
  người kia — không định nghĩa biến thể thứ hai.
- Khối "Câu để hỏi" ở mục 3.4 là pattern khoá dùng chung cho mọi màn có kết
  bằng câu hỏi (R-1g) trong REQ-016 — STORY-010/011 tái dùng đúng kiểu khối.
- Story này không vẽ lại màn (5)/(9) — chỉ tiêu thụ liên kết đã có sẵn ở đó.

## Completion
Điều kiện ship nội dung bộ câu hỏi/chân dung/câu-để-hỏi vào bản build người
dùng thật nay là R-15: qua cổng nhập nội dung chạy được (R-15c) và có truy
vết duyệt qua id bền; không chặn màn, bố cục nhãn xuất xứ, cơ chế lưu-bỏ-dở,
hay đường ghi sổ tay (đối chiếu `requirements.md` → Open Question Impact).
