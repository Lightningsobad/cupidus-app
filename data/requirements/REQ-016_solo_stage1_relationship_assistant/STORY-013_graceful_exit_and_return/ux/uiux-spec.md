# UX Spec: STORY-013 Lối ra khi im lặng/bị từ chối, và lối quay lại sau vắng

Trạng thái đặc biệt của màn (1) (J11 đóng ngăn) + một màn takeover tự hiện khi
mở app sau vắng dài (J13). **Không** phải màn hình thứ 12 — tổng vẫn 11 màn
(SC-1'). Đọc `requirement-ux-survey.md` mục 0-5 trước — token, action-tier,
và bản đồ điều hướng không lặp lại tại đây.

Đây là bề mặt nguy hiểm cảm xúc nhất của cả requirement. Việc trung tâm của
spec này là biến R-1c ("cửa thoát sạch") thành **luật đo được**, không phải
tính từ — xem mục 2.

## 1. "Đóng ngăn gọn gàng" — điểm vào

Đây là hành động phụ **của toàn màn (1)**, không phải hành động trên một thẻ
cụ thể (đối tượng cố định — chỉ một "mối" tại một thời điểm, nên không có
danh sách người để chọn). Điểm vào: icon overflow (`more_vert`, biến thể
`line`) ở app bar của tab "Nhà", mở một menu dọc tối giản tái dùng đúng hàng
kiểu `_MenuRow` đã có ở `me_screen.dart` (không phát minh component menu
mới) — hiện đúng một mục: "Đóng ngăn gọn gàng". Đặt ở overflow, không phải
nút nổi bật cấp thẻ, đúng tinh thần "hành động phụ" (action-tier, survey mục
4) vì đây là hành động ít dùng, không phải luồng chính hằng ngày.

## 2. Luật đo được cho cửa thoát sạch (R-1c) — áp dụng cho CẢ đóng ngăn (mục 1) VÀ xoá sạch (mục 6)

| Thuộc tính | Ngưỡng bắt buộc | Vi phạm cụ thể bị cấm |
|---|---|---|
| Số bước xác nhận | Đúng **1** hộp thoại | Không hộp thoại nối tiếp kiểu "bạn chắc chắn chứ?" sau khi đã xác nhận |
| Số câu hỏi trong hộp thoại | **0** | Không hỏi lý do, không khảo sát, không ô nhập text tự do |
| Số nút | Đúng **2**, ngang hàng thị giác | Không nút thứ 3 dạng "Để sau" / "Nghĩ thêm" / "Giữ liên lạc" |
| Nhãn nút | Chỉ động từ hành động: "Huỷ" / "Đóng ngăn" (hoặc "Huỷ" / "Xoá sạch") | Cấm mọi nhãn gợi cảm xúc/trì hoãn: "Chắc chứ?", "Thử lại sau", "Đừng bỏ cuộc" |
| Nội dung thân hộp thoại | Chỉ liệt kê **dữ kiện phạm vi tác động** (cái gì đóng/xoá, cái gì giữ) | Cấm từ khoá: "tiếc quá", "buồn", "nhớ", "chắc chắn không đổi ý", "để lại một lời nhắn", "thử nhắn lại", bất kỳ câu nào ngụ ý nên tiếp tục theo đuổi (AC-4) |
| Màu / tông | `--red` **chỉ** trên nút hành động chính, không tô toàn hộp thoại đỏ | Không icon mặt buồn, không hình minh hoạ cảm xúc, không âm thanh cảnh báo |
| Phản hồi sau khi hoàn tất | 1 dòng xác nhận trung tính, tự ẩn (snackbar-style, không cần nút "Xong") | Không hiệu ứng chuyển cảnh, không âm thanh, không câu động viên/chúc mừng (AC-3, AC-17) |
| Nút quay lại/đổi ý sau khi xong | Không tồn tại như một CTA mới | Cấm hiện nút "Mở lại ngay" ngay sau khi vừa đóng — mở lại chỉ có ở kho đã đóng (mục 3), do người dùng **chủ động** tìm tới, không phải được mời |

Bài kiểm tra nghiệm thu: đọc to toàn bộ chữ trong luồng — nếu bất kỳ câu nào
đọc lên nghe như đang **an ủi**, **can ngăn**, hoặc **gợi ý thử lại**, luồng
đó fail, bất kể nó đúng ngưỡng số ở bảng trên.

## 3. Kho đã đóng — một bộ lọc, không phải kho thứ hai (SC-1', BR-4)

Tái dùng đúng segmented control tham số hoá theo số đoạn (survey mục 6/RUN-2)
đã có ở STORY-001 mục 3: thêm **đúng một** đoạn thứ 5 "Đã đóng" vào cuối dải
4 đoạn hiện có (Mới nghĩ ra / Đã hẹn ngày / Đã đi rồi / Đã thành kỷ niệm /
**Đã đóng**). Đây vẫn là **một** segmented control, **một** danh sách bên
dưới nó — không route mới, không tab mới, đúng nghĩa "bộ lọc trên kho thẻ của
STORY-001" (BR-4).

- Đoạn "Đã đóng" chỉ **xuất hiện** sau khi người dùng đã đóng ngăn ít nhất một
  lần (progressive disclosure) — phần lớn người dùng chưa từng đóng ngăn
  không thấy đoạn thứ 5 này, giữ segmented control 4 đoạn quen thuộc.
- Nội dung đoạn "Đã đóng": danh sách thẻ đã gắn người (AC-7) ở kiểu thẻ bình
  thường + một chip nhãn tĩnh "Đã đóng" (kiểu DẢI, survey mục 8) trên mỗi
  thẻ, icon leading dạng khoá/hộp lưu trữ (`archive`, biến thể `line`).
- Mở chi tiết một thẻ đã đóng: hiển thị **read-only**, gồm cả vật liệu gắn
  người khác đã từng tồn tại cho thẻ đó (sổ tay người yêu, chân dung, kết quả
  ăn khớp, lời mời — AC-7) dưới dạng **khối text tĩnh, không phải nút/route**.
  Đây là ràng buộc trực tiếp từ BR-13: kho đã đóng **không được** tạo một lối
  vào mới tới Chân dung (màn 8) hay Bảng tra ăn khớp (màn 10) — hai màn đó
  vẫn khoá vị trí tuyệt đối, kể cả từ trong kho đã đóng.
- Đầu danh sách "Đã đóng": một text link nhỏ "Xoá toàn bộ mục đã đóng" (nhãn
  `caption 13pt`, không nền, không icon nổi bật) → mở đúng 1 hộp thoại xác
  nhận theo bảng mục 2 → xoá thật, không bản sao ẩn (AC-15/AC-27).
- App **không bao giờ** tự đề xuất/nhắc người dùng vào đoạn "Đã đóng" — không
  badge số, không chấm đỏ trên đoạn này (AC-16, chống nagging).

## 4. SB-65 "tắt hồi tưởng" — biểu hiện là sự VẮNG MẶT của nội dung

Không có UI mới cần vẽ ở đây — luật là *âm*: sau khi đóng ngăn, mọi bề mặt
khác (dải lối-vào-nhanh, widget/pha của STORY-012, nhỏ giọt khoảng lặng,
thông báo) phải **không** tham chiếu vật liệu đã đóng ở AC-7. Điều này ràng
buộc lên chính STORY-012 và các cửa vào 5/6/7: khi sổ tay đã đóng, các cửa
vào đó suy giảm êm về mức nội dung chung (AC-12), y hệt hành vi "sổ tay còn
trống" — không thông điệp lỗi, không khoảng trống mời gọi tạo lại.

## 5. Sổ tay/kỹ năng "sống sót" — không đổi hình dạng menu

Hồ sơ kỹ năng "phiên bản tôi" (AC-8) tiếp tục hiện nguyên trong menu tab
"Tôi" như trước — story này **không** đổi vị trí, nhãn, hay hành vi của mục
menu đó. Nếu sổ tay người yêu (mục gắn người) đã đóng, hàng menu tương ứng
trong tab "Tôi" đổi phụ đề nhỏ thành "Đã đóng" nhưng **vẫn cùng một hàng
menu, cùng một route** dẫn vào bản read-only của nó — không thêm hàng menu
mới, giữ đúng "một lối vào, một hàng" như STORY-004 đã định nghĩa.

## 6. Màn quay lại — J13 (SB-100)

Chèn ngay sau gate splash-as-auth-check hiện có (system UX memory §11), trước
khi vào tab "Nhà" — chỉ khi ngưỡng vắng vượt (AC-18/AC-19, hằng số cố định,
một phép so sánh boolean, hiện đúng 1 lần cho lần mở đó).

**Bố cục** (full-screen takeover, không phải bottom sheet — đây là một quyết
định vào-luồng, không phải một lựa chọn phụ):

1. Góc trên-phải: icon `close` (`line`, nhỏ, vùng chạm ≥44/48pt) — bấm vào có
   tác dụng **giống hệt** chọn một lối đi mặc định (vào thẳng tab "Nhà"), để
   màn này không bao giờ là cổng chặn (AC-24, SC-5).
2. Lời chào trung tính, **không** đề cập thời gian vắng dưới bất kỳ hình thức
   nào — cấm mọi biến thể "lâu quá không gặp"/"chúng tôi nhớ bạn" (AC-21).
3. Một dòng dẫn: "Bạn muốn bắt đầu từ đâu?"
4. Đúng 3 ô lựa chọn cố định, **cùng cỡ, cùng kiểu, cùng trọng lượng chữ** —
   tái dùng đúng kiểu tile ngang hàng của mẫu "Phút 1" (STORY-001 mục 4a):
   không ô nào có badge "gợi ý"/"nên làm trước", không thứ tự ngụ ý xếp hạng
   (AC-22).

   | Ô | Đích |
   |---|---|
   | "Xem kho ý tưởng" | Tab Nhà, đoạn "Mới nghĩ ra" |
   | "Xem sổ tay & kỹ năng" | Tab Tôi → menu tương ứng |
   | "Bắt đầu một việc mới" | Mở đúng luồng tạo thẻ 1 chạm đã có ở mẫu Phút-1 |

5. Cách rõ với 3 ô trên bằng khoảng trống `lg` (24px) trở lên: một text link
   de-emphasized (mục "hành động phụ" ở action-tier, `--red`, `caption 13pt`,
   không nền, không icon) "Xoá hết dữ liệu chặng 1" → luồng xoá sạch (mục 7).
   Vị trí thấp + trọng lượng thị giác nhẹ là chủ đích: đây là lối thoát cần
   tồn tại (SC-5) nhưng không được cạnh tranh thị giác với 3 lối đi tiếp tích
   cực ở trên.
6. Không hình minh hoạ, không mascot, không animation ăn mừng hay an ủi ở màn
   này — nền trung tính giống các màn tiện ích khác trong app.

Chọn bất kỳ ô nào trong 4 lối (kể cả bấm X) → màn này không hiện lại trong
phiên đó (AC-24).

## 7. Xoá sạch một thao tác (Nhóm F)

- Từ text link ở mục 6.5 → đúng 1 hộp thoại xác nhận theo bảng luật đo được
  ở mục 2, nội dung nêu rõ phạm vi ("toàn bộ dữ liệu chặng 1: thẻ, sổ tay, hồ
  sơ kỹ năng, nhật ký và ảnh, chân dung, kết quả ăn khớp, lời mời, bộ đếm")
  và tính không hoàn tác, dưới dạng dữ kiện (AC-28).
- Sau khi xác nhận: xoá thật (AC-27), không toast "đã xoá thành công" kiểu ăn
  mừng — chỉ chuyển thẳng về trạng thái rỗng lần đầu của STORY-001 AC-1, dùng
  được ngay, không màn tiễn biệt (AC-29).

## 8. Ranh giới bàn giao

- Story này **không** đổi hợp đồng thẻ (STORY-001), hợp đồng sổ tay/kỹ năng
  (STORY-004 BR-15), hay bộ đếm (STORY-012 BR-6/BR-7) — chỉ thêm trạng thái
  *đã đóng* ở tầng của chính nó (BR-3/BR-5).
- Nhật ký (STORY-003) không bao giờ bị đóng/xoá bởi story này (BR-6) — không
  UI nào ở đây hiển thị nút "đóng nhật ký".
- Không thêm bất kỳ lối vào menu/tab mới nào tới Chân dung (STORY-009) hay
  Bảng tra ăn khớp (STORY-010) — kể cả từ kho đã đóng (BR-13, mục 3).

## Completion

- [x] R-1c biến thành bảng luật đo được (mục 2), áp dụng thống nhất cho đóng
      ngăn và xoá sạch.
- [x] Kho đã đóng = đoạn thứ 5 trên cùng một segmented control, không kho
      song song, không lộ đường vào màn khoá-vị-trí (mục 3).
- [x] Màn quay lại không có bất kỳ chỉ số/lời trách móc định lượng vắng mặt
      nào; không phải cổng chặn (mục 6).
- Không phát hiện mâu thuẫn artifact mới ngoài các mục đã ghi ở
  `requirement-ux-survey.md` mục 6.
