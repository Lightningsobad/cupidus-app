# UX Spec: STORY-011 Vỏ hoàng đạo / trắc nghiệm — màn (7), CỬA VÀO

Requirement: REQ-016 · Story-Class: standard · Depends On: STORY-001,
STORY-004, STORY-005, STORY-008 (SB-174 — ràng buộc sản phẩm, không phải
ràng buộc kỹ thuật)
Nguồn bắt buộc: `story_master.md`, `requirements/requirements.md`,
`../ux/requirement-ux-survey.md` mục 0/4/5/7, `STORY-001/ux/uiux-spec.md` mục
6 (khung dải lối-vào-nhanh — ô 3 do story này điền nội dung).
`DESIGN_SOURCE_NOT_DETECTED` bình thường ở giai đoạn này — spec dùng luật đo
được, không tham chiếu ảnh render.

## 1. Vị trí và cách mở

Màn (7), nhóm CỬA VÀO — KHÔNG khoá vị trí (khác STORY-009/010). Mở từ **ô 3**
trong dải lối-vào-nhanh 3 ô trên đầu tab Nhà (khung STORY-001 mục 6): icon
Material Symbols Rounded `auto_awesome` (variant filled, nhất quán với ô
1/2), nhãn 1 dòng "Vỏ hoàng đạo". Push full-screen, nút quay lại về tab Nhà.

## 2. Bố cục màn chọn (nếu có nhiều lát/bộ)

1. Nếu kho nội dung có nhiều lựa chọn (nhiều lát hoàng đạo hoặc nhiều bộ trắc
   nghiệm ngắn): danh sách thẻ chọn đơn giản, mỗi thẻ 1-2 dòng mô tả, KHÔNG
   khoá theo ngày (AC-18) — mọi lựa chọn luôn mở, không có mục "hôm nay mới
   mở khoá".
2. Chơi được ngay, không có bước điền hồ sơ/thiết lập trước (AC-2).
3. Bỏ dở giữa chừng và quay lại: bắt đầu lại sạch sẽ, không đếm số lần bỏ dở,
   không nội dung trách móc (AC-3).

## 3. Bố cục màn kết quả — một bề mặt duy nhất (SC-2/SB-136)

1. Nhận định/kết quả và **đúng 3 thẻ hoạt động đề xuất** nằm **trên cùng một
   màn, cùng một lượt cuộn** — không nút "xem gợi ý" phải bấm thêm, không
   "xem thêm" đóng sẵn che 3 thẻ (AC-5/AC-6). Thứ tự từ trên xuống: đoạn nhận
   định (`body 17pt`, dùng đúng kiểu khối "Câu để hỏi" ở
   `STORY-009/ux/uiux-spec.md` mục 3.4 nếu đoạn nhắc tới người kia, R-1g) →
   tiêu đề phụ ngăn cách (ví dụ "Thử ngay") → 3 thẻ đề xuất xếp dọc, dùng
   style thẻ gợi ý dùng chung với STORY-004/005 (khối `--r-sm` + 1 hành động
   chính "Thêm vào kho của tôi" mỗi thẻ).
2. Bấm "Thêm vào kho của tôi" ở một trong 3 thẻ → **tạo thẻ ngay** trạng
   thái *Mới nghĩ ra* + snackbar hoàn tác 5 giây (đúng mẫu "tạo ngay +
   snackbar hoàn tác" mục 7 survey) — không hộp thoại xác nhận chặn. Người
   dùng chọn tiếp thẻ khác trên cùng màn được, không giới hạn chỉ 1 lựa chọn.
3. Không chọn thẻ nào và rời màn: không hệ quả, không nhắc lại (AC-10).
4. Không phần tử nào ngụ ý AI đang xử lý — chuyển từ màn chọn sang màn kết
   quả là tức thời hoặc skeleton tải-dữ-liệu thường, không hiệu ứng gõ chữ
   dần/spinner "đang tính vận mệnh" (R-7).

## 4. Ranh giới đạo đức và định vị (R-10)

- Không DẢI, %, điểm số, hay bất kỳ chỉ số ăn khớp nào ở màn này (AC-14) —
  chỉ số ăn khớp sống sau cửa khoá vị trí của STORY-010; nếu nội dung muốn
  nhắc tới ăn khớp, chỉ được làm vậy bằng một liên kết văn bản nhỏ dẫn sang
  màn (10)/(5), không hiển thị giá trị tại chỗ.
- Không ngôn ngữ tiên tri/vận mệnh/"số phận đã định" (AC-17) trong tiêu đề
  hay đoạn nhận định.
- Không streak, không đếm số lần chơi, không huy hiệu, không "vận mệnh hôm
  nay" khoá theo ngày (AC-18/AC-19/AC-20) — mở lại bao nhiêu lần trong ngày
  cũng ra cùng nội dung nếu cùng đầu vào (tất định, AC-21).
- Không phần nào sau paywall (AC-19/R-14).

## 5. Trách nhiệm bàn giao

- Story này **điền nội dung ô 3** của dải lối-vào-nhanh do STORY-001 sở hữu
  khung — không đổi kích thước/bố cục 3 ô, không thêm badge/chấm "mới" lên ô
  (đối chiếu STORY-001 mục 6/7: không tín hiệu thúc giục mở hằng ngày).
- Không vẽ chỉ số ăn khớp hay chân dung ở bất kỳ đâu trong story này — hai
  đích đó chỉ liên kết-nhắc tới, không hiển thị tại chỗ.
- Thẻ style "gợi ý → thêm vào kho" dùng chung với STORY-004/005 mục hành
  động chính của thẻ gợi ý — không định nghĩa biến thể thẻ thứ ba.

## Completion
Điều kiện ship nội dung kho trắc nghiệm/hoàng đạo vào bản build người dùng
thật nay là R-15: qua cổng nhập nội dung chạy được (R-15c) và có truy vết
duyệt qua id bền; không chặn màn, ô lối-vào, hay cơ chế 3-thẻ ở mục 3 — **con
số 3 thẻ ở mục 3 là hợp đồng bố cục (BR-2), không phải N của gói nội dung**;
R-15b (N là thuộc tính dữ liệu) áp cho kích cỡ kho trắc nghiệm/hoàng đạo, còn
BR-2 giữ nguyên cố định (`requirements.md` → Open Question Impact).
