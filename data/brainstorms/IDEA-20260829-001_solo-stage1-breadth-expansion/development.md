# Idea Development: IDEA-20260829-001 Solo Stage-1 Breadth Expansion

## BMAD Session State

- Stance: **`Creative Partner`**
- Topic: (vòng 8) **mở lại idea** — chuyển hoá bản nghiên cứu thành hình dạng
  sản phẩm: tính năng cụ thể, journey thật, vòng đời user, màn hình + ràng buộc
- Goal: làm cho idea **dựng được thành app**, không phải nghĩ thêm ý tưởng
- Constraints: như vòng 1-7, CỘNG phán quyết vòng 8 của user (bản v7 = nghiên
  cứu, không phải đặc tả). ⚠️ Brainstormer KHÔNG ghi vào `data/requirements/`.
  User đã tuyên bố sẽ **bỏ và tạo lại REQ-013** → không cần tương thích ngược
- Active technique batch (vòng 8): Assumption Smash trên chính bản v7 · Problem
  Reversal ("cái gì đang thiếu ở GIỮA các mảnh") · kiểm toán đối chiếu artifact
- Approximate raw idea count: 210 (SB-01..SB-210) — **vòng 8 không sinh ứng viên
  mới**; nó đổi trục tổ chức. Cộng 5 luật màn hình đề xuất SC-1..SC-5
- Domain shifts explored: 42 lens
- Convergence state: **🔴 MỞ LẠI.** Hội tụ vòng 7 bị thu hồi. Bản v7 vẫn dùng
  được làm **đầu vào nghiên cứu**, không dùng làm bản bàn giao
- Next technique or move: **vòng 9 — chuyển hoá.** Dựng lưới journey (đánh số
  một lần duy nhất), vòng đời user theo thời gian thật, bản đồ màn hình + ràng
  buộc, rồi gán ngược 20 hạng mục v7 vào đó. **Chặn bởi OQ-18/OQ-19/OQ-20**

## Idea Inventory

### 2026-08-29 · L0 · Chẩn đoán gốc: "mờ nhạt" là bệnh gì

Không phải thiếu tính năng lẻ. Chặng 1 hiện tại (C1 danh sách hoạt động + C6
nhật ký + BD2 lịch Việt + KY2/GI7/GI3 bản solo) là **CRUD thụ động**. Tám chế
độ thất bại đang bật sẵn:

- **F1 — Màn hình trống.** Mở app lần đầu không có gì; người dùng phải tự nghĩ
  ra toàn bộ nội dung. Đây là "blank page anxiety" mà cả ngành nhật ký đã phải
  giải bằng prompt có cấu trúc.
- **F2 — Không có gì tự xảy ra.** Nếu người dùng không gõ, app đứng yên. Không
  có sự kiện nào do app khởi xướng.
- **F3 — Mọi thứ đều "để dành cho sau".** Danh sách hoạt động là lời hứa về
  tương lai; hôm nay không dùng được gì.
- **F4 — Không có kết quả nhìn thấy được.** Không có gì để nhìn lại, để tự hào,
  để đưa cho ai xem. Mà streak/điểm — cách rẻ nhất của ngành — thì R-1 cấm.
- **F5 — Mù ngữ cảnh.** App không biết hôm nay thứ mấy, mưa hay nắng, ví còn
  bao nhiêu, người dùng đi xe máy hay ô tô.
- **F6 — Bắt nhập tay.** Ý tưởng hẹn hò của người Việt trẻ đang nằm ở TikTok,
  Instagram, Google Maps saved lists, tin nhắn Zalo. Bắt gõ lại = không ai gõ.
- **F7 — Giá trị treo vào người thứ hai.** Đúng cái lỗi X1e mà cả ý tưởng gốc
  sinh ra để sửa, đang lặp lại ở quy mô nhỏ hơn bên trong chặng 1.
- **F8 — Toàn chữ.** Đơn vị lưu giữ kỷ niệm của nhóm tuổi này là ẢNH (photobooth,
  ảnh in), không phải đoạn văn.

Luận điểm dẫn đường cho cả vòng: **chặng 1 hết nhạt khi mỗi ngày nó tự đưa ra
một thứ dùng được hôm nay, và khi việc "đã làm" trở thành sự kiện hạng nhất.**

### 2026-08-29 · L1 · Problem Reversal (thiết kế thất bại rồi lật ngược)

- **SB-01 Kho mồi có sẵn.** Ship kèm 150-250 thẻ hoạt động biên tập tay; app
  không bao giờ ở trạng thái trống. (lật F1)
- **SB-02 "Việc cho hôm nay".** Mỗi ngày app tự chọn 1 thẻ khả thi hôm nay từ
  kho + danh sách của người dùng. Không phải push, là trạng thái của màn hình
  gốc. (lật F2)
- **SB-03 Việc làm được một mình NGAY.** Loại hoạt động "tiền trạm": đi khảo
  sát trước quán, thử đường, đặt bàn, tìm chỗ gửi xe — có ích hôm nay, một
  mình. (lật F3, F7)
- **SB-04 Nhìn lại cuối tháng/cuối mùa.** Bản tóm tắt tự sinh từ những gì đã
  làm. Không streak, không điểm, không so sánh — chỉ là ký ức được sắp xếp. (lật F4)
- **SB-05 Bộ lọc ngữ cảnh.** Thời tiết + thứ trong tuần + khung giờ + dải ngân
  sách + trong/ngoài trời làm bộ lọc mặc định cho mọi gợi ý. (lật F5)
- **SB-06 Dán link là ra thẻ.** Dán URL TikTok/Instagram/Google Maps → app tự
  bóc thành thẻ hoạt động (tên, địa chỉ, ảnh bìa). (lật F6)
- **SB-07 Luật "giá trị đơn thân".** Mọi tính năng chặng 1 phải qua được câu
  hỏi: nó còn giá trị gì nếu người kia không bao giờ tồn tại? (lật F7)
- **SB-08 Ảnh là đơn vị lưu trữ chính.** Thiết kế nhật ký và kỷ niệm quanh ảnh,
  chữ là phụ. (lật F8)

### 2026-08-29 · L2 · Assumption Smash

Giả định bị đập: A1 "đã có một người cụ thể" · A2 "muốn giữ kín tuyệt đối" ·
A3 "hoạt động = đi chơi" · A4 "một người dùng = một mối quan tâm" · A5 "danh
sách là về người kia" · A6 "chỉ dùng TRƯỚC buổi hẹn" · A7 "chi phí không quan
trọng".

- **SB-09 Chế độ "chưa có ai".** Dùng app như sổ chuẩn bị cho chính mình, không
  cần khai báo bất kỳ đối tượng nào. (đập A1)
- **SB-10 Hỏi ý bạn thân.** Chia sẻ đúng 1 thẻ hoạt động (không kèm bất kỳ
  thông tin nào về người kia) để bạn bè vote/góp ý. (đập A2)
- **SB-11 Hoạt động phi-địa-điểm.** Gọi điện, gửi playlist, gửi ảnh, viết thư
  tay, nấu một món rồi chụp gửi — đều là "một việc làm cùng nhau". (đập A3)
- **SB-12 "Ngăn" ẩn danh, nhiều luồng song song.** Talking stage thực tế thường
  có hơn một hướng. Cho phép nhiều ngăn chuẩn bị, **chỉ có một nhãn do người
  dùng tự gõ**, không có trường dữ liệu nào mô tả/chấm/dự đoán người kia, không
  bao giờ hiển thị chéo hay tổng hợp so sánh. (đập A4 mà không vi phạm R-1)
- **SB-13 "Phiên bản tôi".** Danh sách kỹ năng tự làm phục vụ hẹn hò nhưng
  thuộc về mình: học nấu 1 món, tập chụp ảnh, học nhảy, biết chọn rượu, tập
  bơi. Giá trị 100% giữ lại kể cả mối quan hệ tan. (đập A5)
- **SB-14 Chế độ "đang trong buổi hẹn".** Màn hình một chạm, cỡ chữ lớn, chống
  cắm mặt vào điện thoại: gợi ý câu hỏi khi hết chuyện, nút "chỗ kế tiếp gần
  đây" từ danh sách đã lưu, hẹn giờ tự tắt. (đập A6)
- **SB-15 Ngân sách là trục hạng nhất.** Mọi thẻ có dải giá VNĐ; lọc "dưới
  200k" là thao tác một chạm. (đập A7)
- **SB-16 Sổ chi tiêu hẹn hò riêng tư.** Chỉ mình thấy, không chia đôi, không
  nhắc nợ, không bao giờ hiện cho người kia — vì chia đôi tiền là hành vi trên
  CON NGƯỜI, còn ghi chi phí của mình là hành vi trên HOẠT ĐỘNG.

### 2026-08-29 · L3 · Analogy Transfer (mượn mô hình từ ngành khác)

- **SB-17 Từ app nấu ăn — "công thức buổi hẹn".** Thẻ hoạt động có cấu trúc như
  công thức: nguyên liệu (địa điểm, thời lượng, chi phí, dress code, cần đặt
  trước không), các bước, mẹo, cái bẫy thường gặp.
- **SB-18 Từ Letterboxd/Goodreads — nhật ký "đã đi".** Đánh giá riêng tư **về
  ĐỊA ĐIỂM** (không phải về người): quán ồn quá, chỗ này hợp lần đầu. Đây là
  tài sản dùng lại được cho mọi mối quan hệ sau.
- **SB-19 Từ Pinterest — mood board một buổi hẹn.** Gom ảnh, link, ghi chú vào
  một bảng cho một kế hoạch.
- **SB-20 Từ Strava — "lộ trình".** Nối 2-3 điểm dừng thành một tuyến đi bộ /
  xe máy có thời gian và quãng đường ước tính. Chuỗi điểm dừng chính là thứ
  biến "đi cà phê" thành "một buổi".
- **SB-21 Từ chế độ solo của game co-op — "phòng tập".** Kịch bản mở lời, rủ đi,
  xử lý từ chối — bằng preset viết tay, không AI.
- **SB-22 Từ app cưới — đếm ngược + checklist chuẩn bị.** Đặt bàn, sạc pin,
  rút tiền mặt, mang ô, đổ xăng, giặt áo.
- **SB-23 Từ Duolingo NHƯNG bỏ streak — "bản đồ cột mốc".** Cà phê → ăn tối →
  gặp bạn bè của nhau → chuyến đi một ngày → về quê. Mở ra bằng việc ĐÃ LÀM,
  không bằng điểm, không có chuỗi ngày để gãy.
- **SB-24 Từ stamp rally Nhật / one-day class Hàn — "bộ sưu tập trải nghiệm".**
  12 loại trải nghiệm (workshop gốm, photobooth, chợ đêm, đạp xe quanh hồ, rạp
  phim cũ, lớp nấu ăn...) như một bộ tem đóng dần.
- **SB-25 Từ thư viện template của Notion — "gói kế hoạch" tải về.** Gói mưa
  Sài Gòn · Đà Lạt 2N1Đ · Hà Nội mùa thu · Dưới 100k · Lần đầu gặp mặt.
- **SB-26 Từ Spotify Wrapped — "bản tổng kết mùa".** Tự sinh, xuất ảnh dọc chia
  sẻ được. Đây là artifact tăng trưởng duy nhất mà chặng 1 có thể có mà không
  vi phạm R-1 (nội dung là ĐỊA ĐIỂM và VIỆC ĐÃ LÀM, không phải về người kia).
- **SB-27 Từ Google Maps saved lists — nhập danh sách "Muốn đến".** Người Việt
  trẻ đã lưu sẵn hàng chục địa điểm ở đó; đây là nguồn nội dung khởi tạo miễn phí.
- **SB-28 Từ photobooth — khung ảnh in-app.** Khung kiểu photobooth cho ảnh
  buổi hẹn, có sẵn ngày + tên địa điểm; chỗ scan/lưu ảnh in.
- **SB-29 Từ app thời tiết — cảnh báo kế hoạch.** "18h tối mai mưa — đây là 2
  phương án trong nhà bạn đã lưu."
- **SB-30 Từ highlight của Kindle — "câu của tháng".** Trích một dòng người
  dùng từng viết trong nhật ký, đưa lên như một lời nhắc dịu.

### 2026-08-29 · L4 · JTBD Extremes (đẩy vào các cực người dùng)

- **SB-31 Người lo lắng — kịch bản 15 phút đầu.** Đứng chờ ở đâu, câu mở đầu,
  cách xử lý khoảng lặng, cách kết thúc sớm lịch sự.
- **SB-32 Người đi một mình gặp người lạ — chuẩn bị an toàn.** Chia sẻ địa điểm
  + khung giờ với một người thân, tự hết hạn sau 3 giờ; nút báo "về tới nhà rồi".
  Đây là giá trị đơn thân mạnh nhất trong toàn bộ danh sách và gần như không
  đối thủ date-planning nào có.
- **SB-33 Người mới hoàn toàn — mẫu lời rủ.** Mẫu tin nhắn theo mức thân thiết,
  người dùng sửa tay rồi tự copy sang Zalo/Messenger. Không AI, không tự gửi.
- **SB-34 Người dày kinh nghiệm — thư viện riêng.** Tự tạo và nhân bản thẻ,
  tag riêng, tái sử dụng cho lần sau.
- **SB-35 Người ít chú ý — widget màn hình chính.** Một thẻ "việc hôm nay" +
  một nút lưu nhanh, không cần mở app.
- **SB-36 Lưu qua Share Sheet.** Hai chạm từ bất kỳ app nào, không mở app.
- **SB-37 Buổi hẹn quan trọng — chế độ dịp đặc biệt.** Checklist dài hơn, nhắc
  đặt chỗ, phương án B bắt buộc, nhắc trước một ngày.
- **SB-38 Người bận — "hẹn 30 phút".** Bộ hoạt động siêu ngắn: cà phê mang đi
  rồi đi bộ, ăn sáng trước giờ làm, ghé chợ hoa 20 phút.
- **SB-39 Người ở tỉnh lẻ — nội dung không phụ thuộc địa danh nổi tiếng.** Một
  lớp hoạt động "ở đâu cũng làm được" để app không chết ngoài Hà Nội/TP.HCM.

### 2026-08-29 · L5 · Constraint Ladder (ép qua các ràng buộc khắc nghiệt)

- **SB-40 Không AI, không nội dung mới — "bộ bài 52 thẻ".** Rút ngẫu nhiên có
  ràng buộc (chi phí / thời lượng / trong-ngoài trời). Cơ chế chống-màn-hình-trống
  rẻ nhất có thể.
- **SB-41 Zero content budget — người dùng đóng góp thẻ.** Duyệt tay, đưa vào
  kho chung ở bản sau; hoãn cho tới khi có mật độ người dùng.
- **SB-42 Offline hoàn toàn.** Toàn bộ chặng 1 chạy offline, đồng bộ sau — dùng
  được ở quán hết wifi, hết 4G, hoặc ở quê.
- **SB-43 Một màn hình duy nhất.** "Hôm nay" là màn gốc; danh sách và nhật ký
  là hai tab phụ. Ép app phải có gì đó để nói mỗi ngày.
- **SB-44 Lát 24 giờ.** Một màn "Hôm nay" + 50 thẻ + nút lưu. Không có gì khác.
- **SB-45 Không push notification.** Dùng widget + lịch hệ thống thay push —
  đỡ phiền, và quan trọng hơn: đỡ lộ nội dung nhạy cảm trên màn hình khoá.
- **SB-46 Máy có thể bị người khác cầm.** Khoá app bằng Face ID, ẩn nội dung
  khỏi app switcher, không hiện preview nhật ký ở thông báo.

### 2026-08-29 · L6 · Channel-First (bắt đầu từ phân phối, không từ tính năng)

- **SB-47 "Gói kế hoạch" là đơn vị chia sẻ.** Thứ người ta thực sự chia sẻ trên
  TikTok/Threads không phải app, mà là một danh sách chỗ đi cụ thể.
- **SB-48 Thiệp mời riêng tư xuất được.** Một trang/ảnh mời người kia đi chơi,
  mở được **không cần cài app** — đây là cầu tự nhiên sang C0 (khoảnh khắc mời)
  của REQ-014.
- **SB-49 "Món quà 12 chỗ".** Ảnh tổng hợp những nơi đã lưu, dùng đúng lúc mời
  người kia vào app. Mở rộng G-b từ một câu nói thành một artifact xuất được.
- **SB-50 Zalo là kênh mặc định, không phải iMessage.** Share sheet + link
  preview phải đẹp trên Zalo/Messenger, đây là nơi hội thoại thật diễn ra ở VN.
- **SB-51 Bản web công khai cho mỗi gói kế hoạch.** "Chỗ hẹn hò Đà Lạt dưới
  500k" — kéo người chưa cài app; nội dung tĩnh, biên tập tay, không cần AI.
- **SB-52 Không bắt đăng nhập ở chặng 1.** Local-first; chỉ tạo tài khoản khi
  cần đồng bộ hoặc mời. Giảm ma sát ở đúng chỗ ma sát giết chết app một người.
- **SB-53 Bạn thân trước, người yêu sau.** Danh sách hoạt động dùng được với
  bạn bè/nhóm bạn. Mở rộng đối tượng, tăng mật độ người dùng, và không hề vi
  phạm R-1 (vẫn là hoạt động).

### 2026-08-29 · L7 · Anti-Commodity — hào văn hoá Việt (khó sao chép nhất)

- **SB-54 Lịch âm mở rộng thành nội dung.** Không chỉ hiển thị Tết/Trung
  thu/8-3/20-10/rằm/mùng 1 và chuỗi "ngày 14" — mỗi dịp kèm một gói hoạt động
  và gợi ý quà theo dải ngân sách VNĐ.
- **SB-55 Xưng hô là một cài đặt toàn cục.** anh/em · mình/cậu · tớ/cậu; chọn
  một lần, áp cho toàn bộ preset. Mở rộng: giọng văn miền Bắc / miền Nam.
- **SB-56 "Ra mắt gia đình" — checklist rất Việt.** Mang quà gì, xưng hô với ai
  thế nào, tới giờ nào, kiêng gì, ngồi đâu. Không app phương Tây nào có, và
  đây là một cột mốc quan hệ có thật mà không sản phẩm nào phục vụ.
- **SB-57 Bản đồ hoạt động theo mùa Việt Nam.** Mùa mưa Sài Gòn, mùa hoa Đà
  Lạt, mùa lúa chín, mùa nước nổi, Tết ở quê.
- **SB-58 Xe máy là phương tiện mặc định.** Lộ trình theo xe máy, chỗ gửi xe,
  áo mưa, giờ kẹt xe, quãng đường "đi được trong 20 phút".
- **SB-59 Văn hoá "đi ăn" theo giờ.** Ăn vặt chiều, ăn khuya, quán mở muộn,
  quán mở sớm — trục thời gian trong ngày quan trọng hơn trục loại món.
- **SB-60 Photobooth là một LOẠI hoạt động hạng nhất.** Nó đang là điểm hẹn mới
  của giới trẻ Việt; kèm chỗ lưu/scan ảnh in.
- **SB-61 Dải giá VNĐ thật.** dưới 100k · 100-300k · 300-500k · trên 500k.
- **SB-62 Kỷ niệm tính cả dương lẫn âm lịch.**

### 2026-08-29 · L8 · Black-Swan / Edge (sự cố hiếm, lạm dụng, đạo đức)

- **SB-63 Chế độ một người là VĨNH VIỄN, không phải phòng chờ.** Không có UI
  nào nói "chờ người kia tham gia". Đây là bản mở rộng của gate REQ-013.
- **SB-64 "Đóng ngăn" một thao tác.** Bị từ chối / ghosting → lưu trữ, ẩn, hoặc
  xoá sạch trong một thao tác (XD4). Không hỏi lại nhiều lần, không "bạn có
  chắc không" ba lần vào đúng lúc người ta đang đau.
- **SB-65 Hồi tưởng phải TẮT mặc định cho ngăn đã đóng.** "Ngày này năm trước"
  là tính năng giữ chân số một của ngành nhật ký, và cũng là cách chắc chắn
  nhất để làm tổn thương người vừa chia tay.
- **SB-66 Tách quyền sở hữu ngược.** Chia tay sau khi đã ghép đôi → từ 2 chủ về
  1 chủ. Phải nằm sẵn trong mô hình M2, không vá sau.
- **SB-67 Giả định máy bị người khác xem.** Khoá, không preview, chế độ ẩn.
- **SB-68 Nhiều ngăn không bao giờ gặp nhau.** Không hiển thị chéo, không tổng
  hợp, không gợi ý so sánh — nếu không, SB-12 biến thành đúng thứ R-1 cấm.
- **SB-69 Preset chỉ mô tả hành động của CHÍNH người dùng.** Không bao giờ sinh
  nội dung thúc ép, dò xét, hay tạo áp lực lên người kia.
- **SB-70 Nhịp nội dung phải chấp nhận tuần trống.** Không đẩy "gợi ý cao trào"
  liên tục; app phải im lặng được mà không coi đó là thất bại.
- **SB-71 Màn hình quay lại sau 3 tháng vắng.** Không trách móc, không chuỗi
  gãy, chỉ hỏi "mở lại từ đâu".

### 2026-08-29 · L9 · 10x / 10% (phóng đại và lát mỏng nhất)

- **SB-72 (10x) "Hệ điều hành chuyện tình cảm của tôi".** Mọi thứ liên quan tới
  đời sống hẹn hò của tôi — địa điểm, ảnh, chi tiêu, kỷ niệm, kỹ năng, lịch —
  sống trong một chỗ riêng tư đi theo tôi suốt cả ba chặng, **và không chứa bất
  kỳ dữ liệu nào về người khác**. Chính ràng buộc R-1 tạo ra định vị này.
- **SB-73 (10x) Hồ sơ "gu hoạt động" của riêng tôi.** Một bộ sở thích cá nhân
  (thích yên tĩnh, ghét đông, đi được xa bao nhiêu, ăn được cay không) lọc mọi
  gợi ý và mang theo qua từng mối quan hệ.
- **SB-74 (10%) Chỉ một màn "Hôm nay" + 50 thẻ + lưu.** Câu hỏi đo được duy
  nhất: người dùng có mở lần thứ hai không.
- **SB-75 (10%) Chỉ nút lưu từ Share Sheet.** Đo xem người ta có thực sự lưu ý
  tưởng hẹn hò khi bắt gặp không.

### 2026-08-29 · L10 · Nước đi cấu trúc (xuyên suốt mọi lens)

- **SB-76 Đổi đơn vị nội dung.** Từ "mục trong danh sách" (một dòng chữ) sang
  **thẻ hoạt động có metadata**: chi phí, thời lượng, trong/ngoài trời, khung
  giờ, mùa, số người, cần đặt trước, khoảng cách. Không có bước này thì SB-05,
  SB-15, SB-29, SB-38 đều không làm được.
- **SB-77 Vòng đời của thẻ thay cho streak.** ý tưởng → đã lên lịch → đã làm →
  kỷ niệm. Đây là nguồn "chuyển động" hợp pháp duy nhất khi R-1 cấm streak và
  điểm số.
- **SB-78 "Đã làm" là sự kiện hạng nhất.** Chuyển sang trạng thái "đã làm" sẽ
  tự sinh một mục nhật ký + chỗ dán ảnh + đúng một câu hỏi (chính là KY2 bản
  solo, nay có chỗ neo tự nhiên thay vì lơ lửng).
- **SB-79 Nhật ký có hai loại mục.** Tự do, và "sau buổi hẹn" (có cấu trúc) —
  vì prompt có cấu trúc là thứ giữ người viết nhật ký lâu nhất.
- **SB-80 Tìm kiếm và tag xuyên cả danh sách lẫn nhật ký.**
- **SB-81 Xuất toàn bộ dữ liệu ra file.** Hợp với tinh thần XD4 và với định vị
  "dữ liệu này là của tôi".
- **SB-82 Nhập ảnh theo ngày từ thư viện máy.** Thấy có ảnh chụp tối thứ Bảy ở
  một địa điểm đã lưu → gợi ý tạo mục "đã làm". Cách rẻ nhất để phá F8.

---

### 2026-08-29 (vòng 2) · D · Quyết định của user (ràng buộc mới, không brainstorm lại)

- **D-1 (trả lời OQ-1): KHÔNG phục vụ nhóm "chưa có ai".** App phải mang hơi
  hướng cupid — chặng 1 bắt đầu khi người dùng **đã có một "mối" cụ thể**, chỉ là
  đối phương chưa cài app.
  - Hệ quả: **SB-09 bị loại.** SB-53 (bạn thân trước, người yêu sau) bị **hạ
    xuống mức PARKED** vì làm loãng định vị cupid.
  - Hệ quả nặng hơn: chặng 1 bây giờ **luôn có một người thứ hai có thật ở ngoài
    đời**, chỉ là người đó không ở trong app. Đây chính là chìa khoá của vòng 2.
- **D-2 (trả lời OQ-4): NHẬP VÀO REQ-013**, không tách REQ mới. REQ-013 đang
  `PENDING` và chưa breakdown nên vẫn kịp sửa `req_master.md`.
- **D-3: OQ-2 chưa chốt** — user chưa rõ câu hỏi. Đã diễn giải lại ở cuối mục
  này (`### 2026-08-29 (vòng 2) · Q`).

### 2026-08-29 (vòng 2) · L11 · Định khung lại: app là HẬU TRƯỜNG

D-1 đổi bản chất bài toán giữ chân. Vì người kia **có thật và đang sống ở ngoài
app**, quan hệ thực sự đang diễn ra ở Zalo/Messenger và ngoài đời. App không
phải sân khấu — app là **hậu trường**.

Câu hỏi giữ chân đúng phải là: *tại sao tôi mở hậu trường khi vở diễn đang ở sân
khấu khác?* Chỉ có ba câu trả lời hợp lệ:

1. **Trước cảnh diễn** — chuẩn bị.
2. **Sau cảnh diễn** — cất lại.
3. **Giữa các cảnh — ĐỢI.** Đây là ~90% thời gian của talking stage và hiện đang
   bị bỏ trắng hoàn toàn.

**Phát hiện trung tâm của vòng 2: talking stage phần lớn là ĐỢI.** Đợi trả lời,
đợi cuối tuần, đợi một dịp. Thời gian chết đó hiện đang đổ vào doomscroll và đi
hỏi bạn bè. **Đó chính là ô giữ chân đang bỏ trống.** Và nó tương thích R-1 nếu
app trả lời bằng *"chuẩn bị một việc"* thay vì *"để tôi phân tích họ đang nghĩ
gì"*. Khẩu hiệu thiết kế: **"Đừng đoán họ nghĩ gì — chuẩn bị một việc."**

### 2026-08-29 (vòng 2) · L12 · Bản đồ 13 journey của chặng 1

Mỗi journey: cò (trigger) → app làm gì → để lại gì → kéo mở lại bằng gì.

- **J1 — Bắt ý tưởng** (5 giây, bất kỳ lúc nào). Thấy một chỗ hay trên TikTok →
  lưu. Để lại: một thẻ trong danh sách. Kéo lại: không. *Hiện có một phần (C1).*
- **J2 — Chọn việc để rủ.** Mở danh sách, chốt 1 việc khả thi tuần này. Để lại:
  một thẻ ở trạng thái "định rủ". *Hiện có.*
- **J3 — Rủ** — soạn lời rủ rồi **rời app sang Zalo**. Đây là **điểm rò rỉ lớn
  nhất**: app giao việc quan trọng nhất cho một app khác rồi mất dấu vết.
  *Hiện không có gì.*
- **J4 — ĐỢI TRẢ LỜI** — khoảng trống lớn nhất trong toàn bộ chặng 1. Người dùng
  lo, mở điện thoại 20 lần. App hiện không có gì ở đây. *Hiện không có gì.*
- **J5 — Đã hẹn được → chuẩn bị.** Đặt bàn, phương án B, thời tiết, đếm ngược.
  *Hiện không có gì.*
- **J6 — Ngày hẹn, trước giờ đi.** Rút tiền mặt, đổ xăng, áo mưa, chia sẻ vị trí
  cho người thân. *Hiện không có gì.*
- **J7 — Trong buổi hẹn.** Chế độ tại chỗ một chạm. *Hiện không có gì.*
- **J8 — 23h, vừa về tới nhà.** **Khoảnh khắc vàng của app này** — người dùng
  đang đầy cảm xúc và cần một chỗ đổ. Đây là lúc C6 (nhật ký) thực sự được dùng,
  và cũng là lúc duy nhất trong ngày mà việc gõ chữ là tự nhiên. *Hiện có C6
  nhưng không có gì dẫn người dùng tới đó đúng lúc.*
- **J9 — Sáng hôm sau.** Gửi ảnh, cảm ơn, chốt việc kế tiếp. *Hiện không có gì.*
- **J10 — Khoảng lặng giữa hai lần hẹn.** 90% thời gian. *Hiện không có gì.*
- **J11 — Im lặng kéo dài / bị từ chối.** Điểm churn cao nhất. *Hiện không có gì.*
- **J12 — Cột mốc → mời vào chặng 2.** *Hiện là một vách đá: cài app hoặc không.*
- **J13 — Quay lại sau 3 tháng vắng.** *Hiện không có gì.*

**Kết luận chẩn đoán: 10/13 journey đang trống.** Ba cái đang có (J1, J2, và một
nửa J8) đều là journey **thụ động** — chỉ chạy khi người dùng tự khởi xướng. Đó
là lý do "chưa có gì giữ chân".

### 2026-08-29 (vòng 2) · L13 · Bảy neo mở lại (N1..N7) thay cho streak

R-1 cấm streak/điểm/xếp hạng, tức là cấm mất công cụ giữ chân rẻ nhất của ngành.
Bảy cơ chế thay thế, xếp theo độ mạnh:

- **N1 — Mong chờ.** Đếm ngược tới việc ĐÃ ĐẶT được. Hướng về phía trước, không
  phải chuỗi ngày để gãy. (SB-86)
- **N2 — Việc dở dang.** Checklist chuẩn bị chưa tick xong kéo người ta quay lại
  (hiệu ứng Zeigarnik). Ngành retention 2026 gọi thẳng đây là giải pháp thay thế
  streak. (SB-22, SB-37)
- **N3 — Của cải tích luỹ.** "Món quà đang lớn" — bộ đếm chỗ đã lưu hiện ngay
  màn hình gốc: 12 chỗ → 15 chỗ. Càng dùng càng tiếc nếu bỏ. (SB-87)
- **N4 — Đồng hồ bên ngoài.** Lịch âm, rằm/mùng 1, ngày 14 hàng tháng, sinh
  nhật, 8/3, 20/10. App không cần tự nghĩ ra dịp — **lịch Việt Nam nghĩ hộ**.
  Đây là neo rẻ nhất và Việt nhất. (SB-54, SB-62)
- **N5 — Dư âm.** Sau buổi hẹn có việc phải làm trong 24h: cất ảnh, trả lời một
  câu, chốt việc kế tiếp. (SB-85, SB-78)
- **N6 — Nội dung nhỏ giọt.** Mỗi tuần/mỗi mùa một gói kế hoạch mới. (SB-99)
- **N7 — NGƯỜI KIA TRẢ LỜI.** ***Neo mạnh nhất, và là neo duy nhất không phải
  vòng lặp một chiều.*** Chỉ có được nếu chặng 1.5 tồn tại (xem L14).

**Luận điểm quan trọng nhất của cả vòng 2:** N1-N6 đều là vòng lặp
`người dùng ↔ app` — một mình với một cái app. Chúng chỉ **làm chậm sự rơi**.
Chỉ N7 là vòng lặp xã hội. **Không có N7 thì chặng 1 mãi là phòng chờ, và mọi
tính năng khác chỉ là trang trí cho phòng chờ đó.**

### 2026-08-29 (vòng 2) · L14 · CHẶNG 1.5: "một người cài, hai người chơi"

Giả định bị đập (Assumption Smash vòng 2): *"người kia chưa cài app thì không
tham gia được gì."* **Sai.** Họ có điện thoại, có Zalo, và họ đang nhắn tin với
người dùng mỗi ngày.

Ý tưởng kiến trúc: **mọi thứ trong app phải xuất ra được một LINK mà người kia
mở được, trả lời được, không cần cài gì.** Câu trả lời chảy ngược vào app.

Năm nguyên thuỷ link:

- **L-a "Chọn giùm anh"** (SB-88): gửi 3 chỗ → họ bấm 1 → kết quả về app.
- **L-b "Rảnh hôm nào"** (SB-89): gửi 3 khung giờ → họ chọn.
- **L-c "Thiệp mời"** (SB-90): một trang có địa điểm, giờ, bản đồ, nút "ừ đi".
- **L-d "Lật bài" qua link** (SB-91): cả hai trả lời 1 câu, chỉ hiện khi cả hai
  xong. Đây là **nguyên thuỷ P6 chạy xuyên biên giới app** — một nửa chặng 2
  hoạt động trong khi người kia chưa có tài khoản.
- **L-e "Album buổi hẹn"** (SB-92): link xem ảnh chung, họ thả thêm ảnh vào.

**Vận chuyển ở Việt Nam (SB-93):** link Zalo + **Zalo Mini App**. Zalo có ~70
triệu người dùng VN và Mini App chạy thẳng trong Zalo, không cần cài thêm gì.
Tiền lệ đã được chứng minh: Partiful lấy đúng cơ chế này làm vòng tăng trưởng
lõi — mỗi lời mời là một landing page nhẹ đi qua đúng kênh người ta vốn dùng để
hẹn nhau.

**Luật đạo đức bắt buộc đi kèm (SB-94, đề xuất thành R-1b):** cấm đo lường hành
vi của người kia trên link. Không "đã xem", không giờ mở, không đếm lượt mở,
không thông báo "họ vừa mở lúc 23h". Vì đó chính là phân tích CON NGƯỜI — đúng
thứ R-1 cấm. **Chỉ tồn tại hai trạng thái: đã trả lời / chưa trả lời.** Nếu
không chốt luật này sớm, chặng 1.5 sẽ trượt thành công cụ theo dõi.

### 2026-08-29 (vòng 2) · L15 · Cầu sang chặng 2: thang 5 nấc thay vì vách đá

Hiện J12 là nhị phân: cài app hoặc không có gì. Thay bằng thang bậc (SB-96):

- **Nấc 0** — solo. Người kia không biết app tồn tại.
- **Nấc 1** — nhận link một chiều (thiệp mời, album). Họ **xem** được giá trị.
- **Nấc 2** — trả lời trên link. Họ **tham gia** mà chưa có tài khoản. *N7 bắt
  đầu chạy từ đây.*
- **Nấc 3** — mở nhiều lần → Zalo Mini App giữ trạng thái → "lưu lại" một chạm.
- **Nấc 4** — cài app + ghép đôi = **chặng 2**.

Mỗi nấc là một lời mời nhỏ, không phải một lần "cài app đi". Và **SB-95: khi lên
nấc 4, toàn bộ lịch sử họ đã tham gia qua link được trao lại cho họ** — lúc đó
"món quà 12 chỗ" (G-b) không còn là một câu nói mà là một tài sản có thật, có cả
phần họ đã đóng góp.

### 2026-08-29 (vòng 2) · L16 · Lấp đầy 10 journey trống

- **SB-83 "Đừng đoán — chuẩn bị" (J4).** Màn hình dành riêng cho lúc đợi: 3 việc
  chuẩn bị nhỏ làm được ngay bây giờ (xem đường đi, giờ quán mở cửa, phương án
  B). Chuyển lo lắng thành hậu cần — có hậu thuẫn chuyên môn (RS-A7).
- **SB-84 Widget đổi theo pha (J4/J5/J8).** Đang đợi / sắp hẹn / đêm sau hẹn —
  ba nội dung khác hẳn. Widget là cách hiện diện không cần push (SB-45).
- **SB-85 "Về tới nhà chưa?" (J8).** 22h30 sau buổi hẹn: một câu hỏi + một chỗ
  dán ảnh, 60 giây là xong. Biến C6 từ "sổ trắng" thành một nghi thức có giờ giấc.
- **SB-86 Đếm ngược (J5).** Neo N1.
- **SB-87 "Món quà đang lớn" (J10).** Neo N3, và là cầu nối trực tiếp tới J12.
- **SB-99 Nhỏ giọt gói kế hoạch (J10).** Neo N6.
- **SB-100 Màn hình quay lại (J13).** Không trách móc, không chuỗi gãy, chỉ hỏi
  "mở lại từ đâu" — và cho **xoá sạch một thao tác** ngay tại đó (XD4).
- **J3 (điểm rò rỉ):** khi người dùng copy lời rủ sang Zalo, app **không được**
  kết thúc ở đó. Phải chuyển ngay sang trạng thái J4 ("đã rủ lúc 20h, đang đợi")
  để còn chỗ quay về. Đây là chi tiết nhỏ nhưng là mắt xích nối J3→J4→N7.
- **J11:** không có "gợi ý cứu vãn". App chỉ làm một việc: cho đóng ngăn gọn
  gàng (SB-64), tắt hồi tưởng (SB-65), và giữ lại phần tài sản không gắn với
  người kia — danh sách địa điểm (SB-18) và "phiên bản tôi" (SB-13) vẫn còn
  nguyên cho lần sau. **Đó là lý do SB-13 quan trọng hơn vẻ ngoài của nó.**

### 2026-08-29 (vòng 2) · Q · Diễn giải lại OQ-2 (D-3)

"Ngăn" = một cái **hộp cho MỘT mối**. Trong hộp có: danh sách việc định làm với
người đó, nhật ký, ảnh, các lần đã hẹn. Câu hỏi: **app cho mở mấy hộp cùng lúc?**

- **Phương án A — một hộp duy nhất.** Đơn giản nhất, đúng tinh thần cupid nhất.
  Nhược điểm: đang tìm hiểu 2 người thì phải xoá/đè lên.
- **Phương án B — nhiều hộp song song.** Sát thực tế talking stage hơn. Rủi ro:
  dễ trượt thành "bảng theo dõi nhiều người" — đúng thứ R-1 cấm.
- **Phương án C (đề xuất) — một hộp ĐANG HOẠT ĐỘNG tại một thời điểm**, hộp cũ
  được **lưu trữ** và mở lại được, nhưng **không bao giờ hiện song song**, không
  có màn tổng hợp, không so sánh. (SB-97)

Vật neo của một hộp (SB-98): R-1 cấm hồ sơ về người kia, nên hộp **chỉ có đúng
một biệt danh do người dùng tự gõ**, không thuộc tính, không ghi chú về họ,
không dòng thời gian hành vi của họ.

---

### 2026-08-29 (vòng 3) · U · Đóng góp của user: app soạn lịch + soạn nội dung

> "Nếu như app giữ vai trò là *người soạn lịch (options)* và *soạn content*
> (hài hước, thân mật, gợi mở) để có thể làm cho việc 'mời' trở nên lãng mạn và
> hài hước hơn thì sao?"

**Đánh giá: đây là nước đi mạnh hơn đề xuất chặng 1.5 thuần tuý của vòng 2**, vì
ba lý do:

1. **Nó biến J3 từ điểm rò rỉ thành khoảnh khắc giá trị cốt lõi.** Vòng 2 chẩn
   đoán J3 (lúc rủ) là chỗ app giao việc quan trọng nhất cho Zalo rồi mất dấu.
   Nước đi này lật ngược: **lúc rủ chính là lúc người dùng cần app nhất và quan
   tâm nhất tới chất lượng**. Không ai cần trợ giúp để duy trì một danh sách;
   ai cũng muốn được giúp để không rủ một cách nhạt nhẽo.
2. **Nó làm vòng lặp chặng 1.5 quay được.** Không có nội dung tốt thì "gửi 3 lựa
   chọn" chỉ là một cái phiếu bình chọn nhạt. Có nội dung tốt thì cái link là
   một món quà — và neo N7 (người kia trả lời) mới thực sự có xác suất bắn.
3. **Nó tạo ra vật phẩm lan truyền do NGƯỜI NHẬN phát tán** (xem L20).

### 2026-08-29 (vòng 3) · L17 · Cơ chế thật đằng sau "hài hước" — và xung đột với luật không-AI

**Vì sao hài hước không phải trang trí:** rủ ai đó đi chơi là một lời đề nghị có
thể bị từ chối. Nghiên cứu về tán tỉnh mô tả đúng cơ chế này: tán tỉnh là việc
đi trên ranh giới giữa thể hiện sự quan tâm và **giữ được đường lui thể diện
(plausible deniability)** — chính sự mập mờ đó cho phép người ta dám bày tỏ mà
bớt sợ bị từ chối và bớt tổn thương lòng tự trọng. Và hài hước được ghi nhận là
chiến thuật tán tỉnh hiệu quả nhất cho cả hai giới (RS-C1).

→ **Hài hước là bảo hiểm rủi ro cho lời mời.** Nếu bị từ chối thì "đùa thôi mà".

**Nhưng nghiên cứu cũng nêu một nghịch lý phải xử lý:** mập mờ bảo vệ lòng tự
trọng, còn *trực tiếp* mới truyền đạt được thông điệp. Hai thứ này kéo ngược nhau.

**SB-102 — "Vỏ hài, ruột rõ".** Vật phẩm lời mời giải được nghịch lý đó vì nó có
hai lớp tách rời: **cái khung gánh phần hài (hạ rủi ro xã hội), các nút gánh
phần rõ (địa điểm, giờ, đồng ý/từ chối)**. Người dùng được cả hai thứ mà lời
nhắn chữ thuần không cho được cùng lúc.

**Ba nhiệm vụ của một lời mời** (khung thiết kế rút ra):
1. **Hạ rủi ro xã hội** — hài hước → bị từ chối vẫn còn đường lui.
2. **Tạo tò mò** — gợi mở → khiến người ta bấm vào link.
3. **Hạ ma sát trả lời** — options → chỉ cần bấm, không phải nghĩ.

⚠️ **XUNG ĐỘT PHẢI BÁO CÁO (OQ-9):** "soạn content" theo bản năng sẽ nghĩ tới
AI sinh nội dung. Nhưng REQ-013 `Invariant Design Rule` số 5 ghi rõ **không AI ở
bất kỳ đâu trong REQ-013**; AI là scope REQ-014+ và bị chặn bởi gate G-1. D-2 lại
nói nhập vào REQ-013. **Ba thứ này không thể cùng đúng.** Hoặc nội dung đi đường
preset (ở lại REQ-013), hoặc dùng AI (phải sang REQ-014+, phá D-2).

### 2026-08-29 (vòng 3) · L18 · Vì sao đường PRESET có thể tốt hơn đường AI

Đây không phải lời bào chữa cho ràng buộc — có bằng chứng ngoài:

- Người dùng **loại bỏ 80% gợi ý AI trước khi gửi**, và chỉnh tone hàng chục
  nghìn lần; họ dùng AI như công cụ nghĩ nháp, không phải thay giọng mình (RS-C3).
- 2026 đang có phản ứng ngược với "AI-polished": *"một câu mở đầu hoàn hảo giờ
  báo hiệu rằng một người — hoặc một con bot — đã bỏ ra 0 giây để nghĩ về bạn."*
  Hiện tượng được gọi là **"pha loãng tính chân thật"** (RS-C3).
- Hài hước tiếng Việt cực kỳ nhạy vùng miền, tuổi, và mức thân thiết. Đây đúng
  là chỗ LLM dở nhất.

**SB-112 — "Công sức chính là thông điệp".** Từ đó rút ra nguyên tắc quan trọng
nhất của vòng 3: **vật phẩm phải trông như một thứ ĐƯỢC LÀM RA, không giả vờ
ngẫu hứng.** Không ai phật ý vì một tấm thiệp được thiết kế sẵn — vì thiệp thì
hiển nhiên là đồ làm ra, và việc chọn/gửi nó mới là công sức. Ngược lại, một câu
văn bóng bẩy giả vờ tự nghĩ ra thì khi bị lộ sẽ phản tác dụng. **Định dạng "tấm
thẻ" là lối thoát đạo đức cho cả bài toán.**

**Nhưng preset có một tử huyệt:** nếu hai người trong cùng nhóm bạn gửi đúng một
câu đùa, phép màu chết ngay lập tức. Mẫu tin nhắn rủ đi chơi đã đầy trên Google.
Bốn cách hoá giải:

- **SB-103 — Hài từ ĐỊNH DẠNG, không từ CÂU CHỮ.** Đây là lời giải mạnh nhất
  (xem L19).
- **SB-104 — Khung có ô trống (mad-libs).** Preset cho bộ khung, nhịp và cú
  chốt; người dùng điền 2-3 chi tiết riêng ("cái quán mà em chê hôm bữa"). Người
  dùng làm 10% công việc, nhận 90% chất lượng, và **chi tiết riêng tư thật sự là
  của họ**. Đây cũng là cách né "pha loãng tính chân thật".
- **SB-105 — Chọn GIỌNG, không chọn CÂU.** tưng tửng / lì lợm / ngọt / lịch sự /
  xàm — app lắp nội dung theo thanh ghi đó.
- **SB-113 — Mỗi khung chỉ dùng một lần cho một mối.** App không cho gửi lại
  cùng một khung.

### 2026-08-29 (vòng 3) · L19 · Thư viện KHUNG NHẠI — hài từ định dạng

**SB-103.** Cái buồn cười nằm ở việc lời mời được trình bày dưới lốt một loại
văn bản đời thường. Ưu điểm quyết định: **hài từ định dạng không bị nhàm theo
kiểu một câu đùa bị nhàm**, và nó chuyển gánh nặng sáng tạo từ *viết* (cần AI
hoặc copywriter cho từng lần) sang *thiết kế* (làm một lần, dùng mãi).

12 khung ứng viên (SB-106, SB-107):

- **Đơn xin phép** — nhại hành chính, thanh ghi hài rất Việt: "ĐƠN XIN ĐƯỢC MỜI
  ĐI ĂN — Kính gửi: ... — Lý do: ... — Cam kết: về trước 10h."
- **Hoá đơn tạm tính** — "1x cà phê · 1x đi bộ vòng hồ · 1x nghe anh kể chuyện
  nhạt · Tổng: 0đ · Đã bao gồm VAT."
- **Vé máy bay / boarding pass** — chuyến, giờ khởi hành, cổng, ghế, "hành lý ký
  gửi: 0kg tâm sự".
- **Lời mời họp** — "Cuộc họp: bàn về việc ăn gì · Chương trình: 1. Ăn 2. Không
  bàn gì cả" + ba nút Đồng ý / Từ chối / Có thể.
- **Thực đơn** — các "món" là các phương án hẹn.
- **Dự báo thời tiết** — "Thứ 7: nắng nhẹ, 32°, khả năng có người rủ đi ăn kem: 100%."
- **Thông báo lỗi hệ thống** — "ERROR 404: không tìm thấy lý do từ chối."
- **Phiếu bé ngoan / giấy khen.**
- **Điều khoản dịch vụ** — "Bằng việc bấm Đồng ý, bạn chấp nhận nghe nhạc dở trên xe."
- **Vé số cào** — cào để lộ nội dung.
- **Phiếu khảo sát.**
- **Biên bản bàn giao.**

**SB-108 — Link là môi trường tương tác, tin nhắn chữ thì không.** Cào để lộ,
đếm ngược, hé lộ dần, confetti khi bấm đồng ý, nhạc nền. Đây là thứ một tin nhắn
Zalo tĩnh không bao giờ làm được — và là lý do kỹ thuật để lời mời phải là LINK
chứ không phải một đoạn text copy đi.

### 2026-08-29 (vòng 3) · L20 · Vòng lan truyền do NGƯỜI NHẬN chạy

**SB-116.** Một lời mời buồn cười sẽ bị chụp màn hình và đem khoe: *"Ê xem thằng
này rủ tao đi chơi bằng cái hoá đơn."* Tức là **người phát tán không phải người
gửi mà là người nhận** — mạnh hơn hẳn referral, vì nó không cần ai được thưởng
và không cần ai tự quảng cáo.

- **SB-117** — chân trang trên link: "làm bằng Cupid". Người thứ ba thấy → cài.
- Đây đúng mô hình Partiful (mỗi lời mời là một landing page nhẹ, poster-led,
  meme-friendly, RSVP một chạm) nhưng với vật phẩm **1-1 và riêng tư** thay vì
  tiệc tùng đông người (RS-C2).
- **SB-118** — chỗ kiếm tiền khả dĩ: gói khung theo mùa/dịp. Khung lõi miễn phí
  để không phạm luật "không paywall lõi" (RS7). Chưa quyết, chỉ ghi nhận.

### 2026-08-29 (vòng 3) · L21 · Mở rộng ra cả vòng cung, không chỉ lúc rủ

**SB-114 — bảy khoảnh khắc cần nội dung**, không chỉ một:

1. **Rủ** (J3) · 2. **Nhắc trước buổi hẹn** (J5) · 3. **Cảm ơn sau buổi hẹn**
(J9) · 4. **Chúc dịp lễ** (J10) · 5. **Xin lỗi khi phải huỷ** · 6. **"Đang nghĩ
tới" giữa khoảng lặng** (GI3, J10) · 7. **Rủ lại sau một lần bị từ chối** (J11).

**SB-115 — Lịch âm × nội dung = cỗ máy nội dung tự chạy.** Đây là tổng hợp quan
trọng nhất của vòng 3 về mặt giữ chân: neo N4 (đồng hồ lịch Việt: rằm, mùng 1,
ngày 14, Tết, Trung thu, 8/3, 20/10) **bơm dịp**, còn thư viện khung **bơm vật
liệu**. Ghép hai thứ lại thì **J10 (khoảng lặng — 90% thời gian, trước đó trống
hoàn toàn) được lấp mà người dùng không phải tự nghĩ ra dịp lẫn nội dung.**
Trước vòng 3, N4 chỉ là một cái nhắc; sau vòng 3, N4 là một nguồn cấp.

**SB-119** — nháp lời mời được lưu lại và sửa tiếp → chính là neo N2 (việc dở dang).

**SB-120 — định vị lại chặng 1: "xưởng làm lời mời".** Danh sách hoạt động, nhật
ký, lịch trở thành *nguyên liệu và hậu quả* của lời mời, chứ không phải các tính
năng đứng cạnh nhau. Câu tiêu đề của sản phẩm đổi từ "trợ lý hoạt động" thành
**"giúp tôi rủ được người ta một cách không nhạt"**. Đây là định vị ứng viên,
cần user chốt.

### 2026-08-29 (vòng 3) · L22 · Đạo đức và những chỗ dễ hỏng

- **SB-109 — đề xuất luật R-1c: lời mời phải LUÔN có một cửa từ chối sạch sẽ.**
  Một chạm, rõ ràng, không né tránh, không trêu. Cấm tuyệt đối các trò kiểu "nút
  Từ chối chạy trốn khỏi ngón tay" — dễ thương nhưng **tước mất quyền nói không
  một cách đường hoàng của người kia**, đi ngược khung "chăm sóc nhau". Và khi
  họ từ chối, app **không được** báo cáo lại kèm kịch tính.
- **SB-110 — tự trào, không trêu người kia.** Mọi nội dung preset chỉ được đùa
  về **người gửi**, không bao giờ đùa về người nhận. Đây là bản dịch trực tiếp
  của R-1 sang tầng nội dung.
- **SB-111 — chặn giọng theo mức thân thiết.** Một khung "xàm" gửi cho người mới
  quen ba ngày là thảm hoạ. App nên hỏi *"bạn muốn dùng giọng nào"* và mặc định
  ở đầu an toàn. ⚠️ Cẩn thận ranh giới R-1: phải hỏi về **giọng người dùng muốn
  dùng**, tuyệt đối không phải chấm điểm/dự đoán người kia thích gì.
- **Rủi ro nhạt/sượng (cringe):** hài trượt còn tệ hơn không hài. Đây là rủi ro
  chất lượng nội dung, không phải rủi ro kỹ thuật — và nó đổ dồn vào OQ-3 (ai sở
  hữu kho nội dung). Với định vị mới, OQ-3 **nâng cấp từ câu hỏi vận hành thành
  câu hỏi sống còn**: sản phẩm này cần một người viết hài tiếng Việt giỏi, không
  cần thêm một lập trình viên.

### 2026-08-29 (vòng 3) · L23 · Phản biện trung thực: đây không phải động cơ giữ chân hằng ngày

Phải nói thẳng: **một người rủ nhau đi chơi khoảng 1-2 lần/tuần lúc cao điểm.**
Xưởng làm lời mời là tính năng **ý định cao, tần suất thấp**. Nó không biến app
thành thứ mở hằng ngày.

Nhưng nó vẫn giải được bài toán, vì **một lời mời sinh ra một chuỗi 5-8 lần mở
app trong một tuần**: soạn nháp (SB-119) → gửi → đợi họ mở (J4) → họ trả lời
(N7) → chốt giờ → nhắc trước một ngày (N2) → sau buổi hẹn (J8) → cảm ơn (J9).

→ **Định khung lại kỳ vọng cho chặng 1: đừng tối ưu DAU, hãy tối ưu "được nhớ
tới đúng lúc cần".** Cộng thêm SB-115 (lịch âm bơm dịp) để lấp phần khoảng lặng
giữa các lời mời. Đây là câu trả lời trung thực nhất cho câu hỏi "chưa có gì giữ
chân" — chứ không phải hứa hẹn một app mở mỗi ngày mà thực tế không có.

---

### 2026-08-29 (vòng 4) · D2 · Quyết định của user (ràng buộc mới, không brainstorm lại)

- **D-4 (chốt OQ-9): đi đường PRESET + MAD-LIBS + KHUNG NHẠI.** Lý do user nêu:
  *AI có thể được dùng sau này, **bên ngoài hệ thống**, để sinh ra các preset này
  nếu cần.*
  - Đây là một phân biệt kiến trúc quan trọng, phải ghi đúng chữ: AI là **công
    cụ ở khâu SOẠN NỘI DUNG**, không phải **phụ thuộc ở khâu CHẠY SẢN PHẨM**.
  - Hệ quả: `Invariant Design Rule` số 5 của REQ-013 ("không AI ở bất kỳ đâu
    trong REQ-013") **vẫn đúng nguyên vẹn**, vì app xuất xưởng không gọi AI.
    Xung đột OQ-9 **được gỡ mà không phải phá D-2**. Hội tụ mở khoá.
- **D-5 (chốt OQ-10): lời mời là một TÍNH NĂNG, không phải câu tiêu đề.**
  Định vị chặng 1 giữ nguyên "trợ lý hoạt động / chăm sóc nhau".
  - Hệ quả: **SB-120 bị loại với tư cách định vị**, nhưng toàn bộ cơ chế của nó
    (SB-101..SB-119) sống tiếp với tư cách tính năng, gắn dưới cụm hoạt động.

### 2026-08-29 (vòng 4) · L24 · Hệ quả kiến trúc của D-4 và D-5

**Từ D-4:**

- **SB-121 — Dây chuyền nội dung nằm ngoài sản phẩm.** Kho khung + nội dung là
  một **tài sản dữ liệu có schema, có version, duyệt tay trước khi ship**, không
  phải một tính năng sinh nội dung. AI (nếu dùng) đứng ở khâu soạn thảo nội bộ.
- **SB-122 — Gói nội dung là DỮ LIỆU tải về, không phải AI runtime.** App tải
  "gói khung theo mùa" giống tải dữ liệu. Vẫn giữ đúng luật 5. Đây là cách để
  kho nội dung lớn dần sau khi ship mà không phải cập nhật app.
- **SB-123 — Kiểm duyệt hai lớp.** Mọi dòng do AI sinh ngoài hệ thống phải có
  một người Việt đọc lại và ký duyệt trước khi vào gói. Ghi lại nguồn của từng
  dòng. Đây là hàng rào chống rủi ro "sượng" và rủi ro "pha loãng tính chân thật".
- **Ghi nhận: D-4 hạ cấp rủi ro số 1 của vòng 3.** OQ-3 ("ai viết nổi ngần này
  nội dung") từ **câu hỏi sống còn** xuống **câu hỏi vận hành**, vì sản lượng
  nay do AI-ngoài-hệ-thống gánh và con người chỉ còn phải **biên tập + duyệt**.
  Nút thắt đổi từ "viết" sang "gu".

**Từ D-5:**

- **SB-124 — Lời mời là một CÁCH XUẤT của thẻ hoạt động.** Không phải trụ riêng.
  Mọi khung nhại render từ đúng schema thẻ của SB-76. Điều này làm SB-76 trở
  thành nền móng của cả hai cụm lớn nhất, và **trả lời OQ-5: có, SB-76 thuộc
  shared-foundation M2**.
- **SB-125 — Payload render được.** Thiết kế vật phẩm lời mời thành một payload
  render ra **ảnh/thẻ trong app ở REQ-013**, và sau này render ra **trang link ở
  REQ-014** mà không phải thiết kế lại. Đây là nước đi tương thích-về-sau rẻ
  nhất: REQ-013 không gánh hạ tầng web, nhưng cũng không tự khoá đường sang
  chặng 1.5.
- **D-5 thật ra bảo vệ chính REQ-013.** Tiêu chí cổng cứng của REQ-013 là *"chặng
  1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia không?"*.
  Nếu lấy "xưởng làm lời mời" làm câu tiêu đề thì giá trị lõi của app phụ thuộc
  vào người thứ hai → **trượt chính cổng cứng đó**, và vi phạm luật "đừng hứa
  một kết quả cảm xúc". D-5 không phải hạ tham vọng, nó là giữ cho sản phẩm qua
  được cổng của chính nó.

### 2026-08-29 (vòng 5) · D3 · Quyết định của user (ràng buộc mới, không brainstorm lại)

- **D-6 (chốt OQ-6): R-1b được duyệt.** Cấm đo lường hành vi người kia. Không
  "đã xem", không giờ mở, không đếm lần mở. Chỉ *đã trả lời / chưa trả lời*.
- **D-7 (chốt OQ-11): R-1c và R-1d được duyệt.** Lời mời luôn có cửa từ chối
  sạch (một chạm, không né, không trêu, app không kịch tính hoá lời từ chối);
  nội dung preset chỉ được đùa về **người gửi**.
- **D-8 (chốt OQ-8): chặng 1.5 thuộc REQ-014.** REQ-013 giữ móc SB-125 (payload
  render được) để không phải thiết kế lại.

### 2026-08-29 (vòng 5) · L25 · Va chạm: phần nào trong danh sách mới đã bị loại rồi

User yêu cầu mở rộng cho "người đang yêu": gợi ý quà, **tìm hiểu tính cách đối
phương**, **chỉ số ăn khớp**, hoàng đạo, trắc nghiệm tính cách (bản thân **và
đối phương**), trò chơi tâm lý, trào lưu hai người, đọc tin theo chủ đề người
kia quan tâm, trợ lý lập kế hoạch **dựa vào tính cách**.

Phải báo cáo trung thực trước khi mở rộng — đây không phải ý kiến của tôi mà là
bản ghi của chính dự án này:

| Nguồn | Nguyên văn |
|---|---|
| `REQ-013/req_master.md` `## Invariant Design Rules` #1 (R-1) | *"the assistant works on ACTIVITIES, never on THE OTHER PERSON. No comparing the two partners... **no scoring/ranking**... Has experimental backing (Phần H, H-R1: sycophancy risk study) — this is a **hard architecture rule, not a style preference**."* |
| `REQ-013/req_master.md` `## Out of Scope` | *"Any feature that **analyzes, scores, profiles, or predicts the other person's behavior or intent** — excluded by R-1"* |
| `IDEA-20260828-002/candidate-review.md` Phần E | **N1-N7** — *"Kịch bản thao túng, **chấm điểm cơ hội**, phân tích tin nhắn, theo dõi MXH, A/B test lời nhắn"* → *"Vi phạm R-1 theo định nghĩa"*, loại ở **cycle 4** |
| `IDEA-20260828-002/candidate-review.md` Phần E | **W3** — *"Đấu trường 'ai hiểu ai hơn'"* → vi phạm BE4 và XD1 (*"dạng đấu nhau"*), loại ở **cycle 5** |

Nói thẳng: **"chỉ số ăn khớp" và "app tự tìm hiểu tính cách đối phương" không
phải ý tưởng mới — chúng là ý tưởng dự án này đã giết hai lần**, một lần ở
cycle 4 vì R-1, một lần ở cycle 5 vì dạng đấu nhau. Tôi không được phép âm thầm
bật lại chúng.

**Nhưng lời phàn nàn "chưa hữu dụng" là đúng, và tôi phục vụ được nó.** Phần còn
lại của vòng 5 là cách lấy ~90% giá trị cảm nhận của danh sách trên mà không
chạm vào cái đã bị cấm.

Thêm một lý lẽ kỹ thuật, không phải đạo đức: **app hiện không có dữ liệu để chấm
điểm ăn khớp.** Một chỉ số dựng trên vài trường người dùng gõ vào là **bịa**, và
bịa một phán quyết cảm xúc rồi giao nó cho người đang lo lắng chính là điều luật
số 3 cấm (*"đừng hứa một kết quả cảm xúc rồi giao một cái lịch"*).

### 2026-08-29 (vòng 5) · L26 · Mô hình ba tầng: GHI / ĐOÁN / SUY-CHẤM

Đây là nước đi chính của vòng 5. Thay vì hỏi "tính năng này có vi phạm R-1
không" (khó, cãi nhau được), hỏi **ai là người khẳng định**:

| Tầng | Ai khẳng định | Ví dụ | Phán quyết |
|---|---|---|---|
| **1 — GHI** | **Người dùng** ghi lại điều họ tự quan sát | "em ấy dị ứng hải sản", "hôm qua khen cái vòng ở Hàng Bạc" | ✅ Hợp lệ. App là **cái sổ**, không phải cái máy phân tích |
| **2 — ĐOÁN** | **Người dùng** đoán, app không xác nhận | "đoán xem người kia chọn gì" — đáp án khoá tới chặng 2 | ✅ Hợp lệ, và là **trò chơi** |
| **3 — SUY / CHẤM** | **App** khẳng định về người kia | "tính cách của cô ấy là...", "độ ăn khớp 78%" | ❌ **Cấm.** Đã loại 2 lần |

- **SB-126 — Luật ba tầng, đề xuất thành `R-1e`.** Một dòng, dùng được cho mọi
  tính năng tương lai, không phải cãi từng ca.
- **SB-127 — Câu kiểm tra một dòng:** *"Câu này do NGƯỜI DÙNG khẳng định, hay do
  APP khẳng định về người kia?"* Nếu là vế sau → dừng.
- **SB-128 — Tầng 2 là SẢN PHẨM TỐT HƠN tầng 3, không chỉ là bản an toàn hơn.**
  Một chỉ số ăn khớp là **ngõ cụt**: đọc một lần, hết. Một lời đoán là **việc dở
  dang** (neo N2) mà **chỉ người kia mới đóng được** (neo N7). **Chấm điểm giết
  tò mò; đoán thì chế ra tò mò.** Và lời đoán là cầu tự nhiên sang chặng 2 —
  đúng bài toán giữ chân của vòng 2.

### 2026-08-29 (vòng 5) · L27 · SỔ TAY MỐI QUAN HỆ — lớp dữ liệu còn thiếu

Chẩn đoán lại "chưa hữu dụng": bốn vòng trước tôi làm ra một **công cụ** (danh
sách, thẻ, lời mời). Cái user đang đòi là một **người bạn đồng hành**. Khoảng
cách giữa hai thứ đó không phải thêm màn hình, mà là: **app không biết gì về mối
quan hệ CỤ THỂ này, nên mọi gợi ý đều chung chung.**

Đường hợp lệ để lấp khoảng cách đó là **người dùng tự kể**, không phải app suy.

- **SB-129 — Sổ tay mối quan hệ.** Một chỗ riêng tư, do người dùng viết, xoá
  được, ghi những gì họ biết về người kia. **Đây là đối tượng lớn nhất của vòng
  5** và là thứ làm mọi tính năng khác hết chung chung.
- **SB-130 — Ô "vừa nghe được".** Ghi một chạm từ widget/Share Sheet, ngay lúc
  đang đứng cạnh người ta. Ma sát thấp là toàn bộ giá trị.
- **SB-131 — Trường có cấu trúc**, không phải một ô văn bản trống: size, dị ứng,
  món ghét, chủ đề quan tâm, ngày quan trọng, **"đã nói là thích"**, sợ gì.
- **SB-132 — Luật đạo đức, đề xuất thành `R-1f`:** sổ tay chỉ ghi **SỞ THÍCH và
  SỰ KIỆN**, cấm ghi **ĐÁNH GIÁ tính cách/hành vi**. Không có ô "cô ấy hay
  giận". Đây là hàng rào chống sổ tay trượt thành hồ sơ.
- **SB-133 — Sổ tay không phải một màn hình nữa, nó là lớp dữ liệu.** Quà, mồi
  chuyện, kịch bản buổi hẹn đều rút từ đây.
- **SB-134 — Xoá hàng loạt khi đóng ngăn** (nối SB-64, luật XD4).
- **SB-135 — Sổ tay KHÔNG BAO GIỜ xuất ra link/ảnh chia sẻ.** Nếu xuất được thì
  nó thành hồ sơ đem khoe. Đây là khác biệt cứng giữa sổ tay và mọi thứ khác
  trong app.

### 2026-08-29 (vòng 5) · L28 · Hoàng đạo / MBTI: dùng làm LỚP VỎ, không làm PHÁN QUYẾT

Nghiên cứu (RS-D3): MBTI đang thay thế cung hoàng đạo làm **ngôn ngữ chung** của
Gen Z; sức hút đến từ **tò mò về CHÍNH MÌNH** và từ việc cái nhãn là một **huy
hiệu để khoe**. Tức là phần hấp dẫn nằm ở **bản thân**, không nằm ở việc phán
xét người kia. Đó là kẽ hở hợp lệ, và nó rộng.

- **SB-136 — Hoàng đạo/MBTI là LỚP VỎ nội dung phủ lên thẻ hoạt động.** Cùng
  đúng kiến trúc với SB-103 ("hài từ ĐỊNH DẠNG"): cái vỏ tạo cảm giác, cái ruột
  vẫn là hoạt động.
- **SB-137 — "Tuần này Song Tử nên rủ đi đâu"** = một thẻ hoạt động mặc áo hoàng
  đạo. Zero suy luận, zero dữ liệu về người kia.
- **SB-138 — Nhãn do người dùng TỰ KHAI cho cả hai.** Nhãn tự khai là dữ liệu
  văn hoá công khai (Gen Z ghi MBTI vào bio), không phải hồ sơ app dựng lên.
- **SB-139 — Cấm chỉ số ăn khớp; thay bằng "gợi ý theo cặp nhãn".** Không phải
  *"Song Tử × Ma Kết hợp 62%"* (phán quyết quan hệ) mà *"Song Tử × Ma Kết: thử
  kiểu hẹn này"* (gợi ý hoạt động). **Cùng một cảm giác vui, khác hẳn về loại
  câu.**
- **SB-140 — Nội dung hằng ngày theo hoàng đạo là neo mở lại rẻ nhất** (RS-D1:
  hơn 55% người dùng app chiêm tinh mở hằng ngày). Nhưng phải là **nội dung tĩnh
  xoay vòng**, không sinh động → giữ đúng luật 5.
- **SB-141 — Rào cứng:** mọi đầu ra của lớp vỏ phải kết thúc bằng **một HÀNH
  ĐỘNG**, không bằng **một NHẬN ĐỊNH**. Đây là ranh giới giữa "app hẹn hò có
  gia vị hoàng đạo" và "app bói toán".

### 2026-08-29 (vòng 5) · L29 · Trắc nghiệm và trò chơi — bản hợp lệ

- **SB-142 — Trắc nghiệm VỀ BẢN THÂN: hợp lệ hoàn toàn.** Kết quả là một huy
  hiệu (RS-D3), thuộc "phiên bản tôi" (SB-13).
- **SB-143 — Kết quả trắc nghiệm là nguyên liệu cho khung mời** (nối C5): "tôi
  là kiểu người hẹn hò X, còn cậu?" là một lời mời tự nhiên.
- **SB-144 — "Đoán xem người kia trả lời gì".** Người dùng đoán; **app không bao
  giờ xác nhận**; đáp án khoá lại tới chặng 2. Việc dở dang **có chủ đích**.
- **SB-145 — Bỏ người thắng.** W3 chết vì *"dạng đấu nhau"*, không phải vì chủ
  đề. Bản hợp lệ: không điểm, không ai thắng, đầu ra không phải *"bạn đúng
  7/10"* mà là **"đây là 3 chỗ hai người nghĩ khác nhau"** → mồi chuyện, không
  phán quyết. Giữ nguyên toàn bộ phần vui, bỏ đúng phần bị cấm.
- **SB-146 — "Fingers Down" bản một người** (RS-D4): bộ thẻ khẳng định, người
  dùng tự trả lời; bản của người kia mở ở chặng 2.
- **SB-147 — Bộ 36 câu (Aron) / 14 câu**, chia liều theo buổi hẹn, nối seed KY2
  sẵn có trong REQ-013.
- **SB-148 — ⚠️ Tách love language / attachment style làm hai.** Áp lên **bản
  thân** = tầng 1, hợp lệ. Áp lên **người kia** = tầng 3, cấm — và suy đoán kiểu
  gắn bó về người khác còn là rủi ro chuyên môn, không chỉ rủi ro luật nội bộ.
- **SB-149 — Trắc nghiệm phải có ích NGAY:** mỗi kết quả kết thúc bằng **3 thẻ
  hoạt động**, không kết thúc bằng một đoạn mô tả tính cách. Đây là cách trắc
  nghiệm phục vụ định vị "trợ lý hoạt động" (D-5) thay vì cạnh tranh với nó.

### 2026-08-29 (vòng 5) · L30 · Quà tặng

- **SB-150 — Quà là một LOẠI thẻ trong C1**, loại mà đầu ra là một vật thay vì
  một buổi đi chơi. Không cần cấu trúc dữ liệu mới — SB-76 đã có dịp, ngân sách,
  cần đặt trước.
- **SB-151 — Chỉ mục quà** = dịp Việt (BD2) × dải giá VNĐ (SB-61) × **giai đoạn
  quen nhau** × sổ tay (SB-129). Không cần suy luận gì.
- **SB-152 — "Đã nói là thích" là mục sổ tay giá trị nhất trong toàn bộ 174 ứng
  viên.** Ghi lại thứ người kia buột miệng khen. **Zero trí tuệ, tối đa cảm giác
  được nhớ tới** — món quà hay nhất luôn là thứ họ nói lướt qua ba tháng trước.
- **SB-153 — Lịch quà theo dịp Việt** (8/3, 20/10, Valentine, sinh nhật, kỷ
  niệm, Tết): nhắc **sớm đủ để kịp mua/đặt**, không nhắc đúng hôm đó.
- **SB-154 — ⚠️ Ranh giới thương mại.** `REQ-013 ## Out of Scope` cấm
  commerce/partnerships → **ý tưởng quà: CÓ. Cửa hàng / affiliate / link mua:
  KHÔNG.** Nếu muốn mở, phải là quyết định requirement riêng.
- **SB-155 — Nhánh "quà không tốn tiền"** (thư tay, playlist, làm giùm việc gì,
  album ảnh in): hợp RS7 (không paywall) và hợp túi tiền sinh viên VN.
- **SB-156 — Cấm nhắc quà kiểu KPI.** Không có *"bạn chưa tặng quà tháng này"* —
  đó là chấm điểm người dùng và vi phạm luật số 3.

### 2026-08-29 (vòng 5) · L31 · Mồi chuyện, và bài toán "hết chuyện"

Nghiên cứu (RS-D5) đổi hướng ý tưởng này một cách quan trọng: bí chuyện đến từ
**vùng an toàn**, và **mới lạ** (làm/xem thứ mới cùng nhau) mới là thứ tạo ra
chuyện; chuyên gia còn cảnh báo việc **ép bạn đời phải "giải trí" cho mình** là
sai hướng.

- **SB-157 — Kho "mồi chuyện" thường xanh**, gắn thẻ theo chủ đề người dùng
  chọn. Không feed, không AI, không backend. Bản rẻ nhất và hợp luật nhất.
- **SB-158 — "Chuyện dở dang".** Sau buổi hẹn, ghi lại chủ đề bị cắt ngang;
  trước buổi sau, app đưa lại. **Tầng 1 thuần tuý, zero trí tuệ, cảm giác "được
  nhớ" rất mạnh** — và nó là neo N2 (việc dở dang) đội lốt một tính năng.
- **SB-159 — Đọc tin theo chủ đề: bản B cần hạ tầng.** RSS/nguồn tin + kiểm
  duyệt (tin xấu chen vào giữa lúc đang tán tỉnh là hỏng) + phụ thuộc bên thứ
  ba. **Không phải AI nên không phá luật 5**, nhưng là hạ tầng runtime lệch
  scope REQ-013 → đề xuất hoãn hoặc đẩy sang REQ-014 cùng chặng 1.5.
- **SB-160 — Định khung lại theo RS-D5:** đừng bán *"tin để có chuyện nói"* (biến
  người dùng thành diễn viên), hãy bán **"thứ để CÙNG LÀM / CÙNG XEM"**.
- **SB-161 — "Cùng xem" là một loại hoạt động**: phim mới, quán mới, triển lãm,
  sự kiện tuần này → **quay lại đúng C1**, không sinh sản phẩm mới.
- **SB-162 — Mồi chuyện theo pha buổi hẹn**: 15 phút đầu (SB-31) khác lúc ngồi
  ăn khác lúc chở về.

### 2026-08-29 (vòng 5) · L32 · Trợ lý kịch bản buổi hẹn

- **SB-163 — "Kịch bản 3 phần"** — đây là phần "chi tiết" user đòi:
  **TRƯỚC** (chuẩn bị, chỗ gửi xe, đặt bàn, phương án mưa) ·
  **TRONG** (2-3 mồi chuyện + 1 chuyện dở dang + thứ tự điểm dừng) ·
  **SAU** (một câu hỏi KY2 + chỗ cất ảnh + ghi vào sổ tay).
- **SB-164 — Đầu vào HỢP LỆ của trợ lý**: ngân sách, thời lượng, thời tiết, mùa,
  giai đoạn quen nhau, sổ tay (do user viết), dịp lịch âm. **Không có "tính cách
  đối phương do app suy ra".** Danh sách này đã đủ để kịch bản hết chung chung.
- **SB-165 — Giai đoạn quen nhau là biến số bị bỏ quên.** Buổi hẹn thứ 2 khác
  hẳn buổi thứ 20. Đây là trục cá nhân hoá mạnh, rẻ, và **hoàn toàn hợp lệ** vì
  nó mô tả **quan hệ**, không mô tả **con người**.
- **SB-166 — Một kịch bản, ba cửa ra**: thành lời mời (C5), thành nhật ký (C4),
  thành thẻ trong danh sách (C1). Không phải sản phẩm thứ tư.
- **SB-167 — Phương án B khi mưa** gắn sẵn trong kịch bản (nối SB-29).

### 2026-08-29 (vòng 5) · L33 · Khảo sát trào lưu hai người → bảng chuyển hoá

| Trào lưu | Cơ chế lan truyền | Bản hợp lệ trong app |
|---|---|---|
| **"Fingers Down"** (2026) | đọc khẳng định, cả hai cụp ngón | SB-146 — bộ thẻ khẳng định bản một người |
| **"Tell me you love me without telling me"** | biểu đạt gián tiếp | Chính là khung nhại C5 — "vỏ hài, ruột rõ" |
| **3 khung "how it started / messy middle / how it's going"** | tiến trình theo thời gian | SB-169 — nối SB-26 tổng kết mùa, xuất ảnh |
| **14-Question / 36 Questions (Aron)** | câu hỏi sâu dần | SB-147 — chia liều theo buổi hẹn, nối KY2 |
| **"Ai hiểu ai hơn"** | bất ngờ cảm xúc (RS-D2) | SB-145 — **chỉ bản không thắng thua** |
| **Love language / attachment style** | nhãn để tự nhận | SB-148 — **chỉ áp lên bản thân** |
| **Trắc nghiệm BuzzFeed / MBTI** | huy hiệu để khoe (RS-D3) | SB-142/143 |

- **SB-168 — Bảng chuyển hoá ở trên là một tài sản tái dùng được**, không phải
  một lần. Trào lưu mới xuất hiện → chạy qua luật ba tầng (SB-126) → ra bản hợp lệ.
- **SB-169 — 3 khung tiến trình** là vật phẩm xuất ra, tức là kênh lan truyền
  (nối SB-116: người nhận phát tán).
- **SB-170 — Phát hiện văn hoá quan trọng nhất của vòng 5 (RS-D4):** trào lưu
  2026 đang nghiêng về *"an toàn, dịu dàng, chỗ trú"* — *"nhịp bình thản của hai
  người chăm nhau"*. **Khảo sát trào lưu độc lập xác nhận đúng cái khung "chăm
  sóc nhau" mà REQ-013 đã chốt, và KHÔNG xác nhận khung thi đấu/chấm điểm.**
  Tức là R-1 không chỉ là hàng rào đạo đức — nó đang đứng cùng phía với thị hiếu.
- **SB-171 — Trào lưu có tuổi thọ ngắn** (vài tháng), nên thư viện thẻ/khung
  **phải cập nhật bằng gói dữ liệu (SB-122), không phải bằng bản app mới.** Đây
  là lý do thứ hai, độc lập, để SB-122 là bắt buộc chứ không phải tuỳ chọn.

### 2026-08-29 (vòng 5) · L34 · Phản biện trung thực về chính vòng 5

- **SB-172 — Nguy cơ "app tạp hoá".** Hoàng đạo + trắc nghiệm + quà + tin tức +
  kịch bản = **năm sản phẩm rời rạc** dán cạnh nhau. Thứ duy nhất làm chúng dính
  vào nhau là **sổ tay (SB-129)**: nó là đầu vào chung của quà, mồi chuyện và
  kịch bản. Không có sổ tay thì phần còn lại chỉ là widget rời.
- **SB-173 — Trắc nghiệm và hoàng đạo là ĐỒ ĂN NHANH.** Nạp nhanh, chán nhanh,
  tuổi thọ ngắn. Chúng **mua thời gian**, không **tạo giá trị bền**. Dùng chúng
  làm mồi kéo người vào và làm neo mở lại rẻ — đừng đặt cược định vị vào chúng.
- **SB-174 — Thứ tự đúng, và nó không thương lượng được:** ① sổ tay → ②
  làm cho quà/mồi chuyện/kịch bản hết chung chung → ③ mới phủ vỏ hoàng đạo và
  trắc nghiệm lên trên. Làm ngược lại sẽ ra **một app bói toán có kèm to-do
  list** — vui một tuần rồi gỡ.
- Ghi nhận từ RS-D6 (nghiên cứu app Paired, JMIR 2025): thứ giữ chân app cho cặp
  đôi mạnh nhất là **cảm giác đồng sở hữu một không gian chung** — mà đó chính
  là thứ chặng 1 **về bản chất không có**. Vòng 5 làm chặng 1 hữu dụng hơn
  nhiều, nhưng **không** xoá được kết luận vòng 2: trần giữ chân thật sự vẫn nằm
  ở chặng 1.5/REQ-014.

### 2026-08-29 (vòng 6) · D4 · Quyết định của user

- **D-9 (trả lời OQ-12): user quyết định MỞ R-1.** ⚠️ Ghi nhận kèm giới hạn
  quyền: brainstormer **không được sửa** `REQ-013 ## Invariant Design Rules`.
  D-9 được ghi ở đây như **chỉ thị của user**, và chỉ có hiệu lực sau khi
  `scrum-master`/Product Owner sửa `req_master.md`. Cho tới lúc đó, văn bản
  REQ-013 vẫn nói ngược lại.
- **D-10 (chốt OQ-13): `R-1e` (luật ba tầng) và `R-1f` (sổ tay chỉ ghi sở thích
  và sự kiện, không xuất chia sẻ) được duyệt.** Lưu ý: D-10 và D-9 kéo ngược
  chiều nhau — `R-1e` cấm tầng 3, D-9 mở tầng 3. **Cách hoà giải nằm ở L36:**
  mở tầng 3 **chỉ trên dữ liệu người dùng tự nhập**, giữ nguyên lệnh cấm với
  mọi nguồn khác. Nếu user không chọn nấc thì hai luật này xung đột.
- **D-11 (chốt OQ-15): quà chỉ là Ý TƯỞNG, không thương mại** — và mở thêm
  nhánh **quà handmade dùng đúng "chuyên môn" của người dùng**, không nhất
  thiết phải mua.
- **OQ-14 chưa chốt** — user yêu cầu giải thích. Xem L40.

### 2026-08-29 (vòng 6) · L35 · Giới hạn quyền, nói trước

Tôi làm đúng chỉ thị D-9 và mở rộng hết cỡ ở các lens dưới. Nhưng phải ghi rõ
hai điều, để sau này không ai đọc artifact này mà tưởng luật đã đổi:

1. **R-1 nằm trong `REQ-013 ## Invariant Design Rules`.** Chỉ Product Owner
   (qua `scrum-master`) sửa được `req_master.md`. Brainstormer chỉ soạn đề xuất.
2. **"Mở R-1" là một câu mơ hồ** — R-1 đang gói sáu thứ rất khác nhau vào một
   dòng. Mở cả sáu khác hẳn mở hai. L36 tách chúng ra để user chọn chính xác.

### 2026-08-29 (vòng 6) · L36 · R-1 không phải một luật — nó là sáu

Đọc kỹ R-1 và Phần E `candidate-review.md`, lệnh cấm này thật ra gói sáu mệnh đề
độc lập. Chúng bị viết chung một dòng nên bị mở/đóng chung, dù rủi ro rất khác nhau:

| | Mệnh đề | Rủi ro | User có đòi không? |
|---|---|---|---|
| **(a)** | App **suy luận tính cách** người kia từ dữ liệu người dùng nhập | Trung bình | ✅ **có** |
| **(b)** | App **đọc tin nhắn / theo dõi MXH** của người kia (N3/N4) | **Rất cao** — giám sát | ❌ không |
| **(c)** | App **so sánh hai người / báo cáo hành vi** người này cho người kia | Cao | ❌ không |
| **(d)** | App **chấm điểm ăn khớp** | Trung bình | ✅ **có** |
| **(e)** | **Kịch bản thao túng / A-B test lời nhắn** (N1/N5) | **Rất cao** | ❌ không |
| **(f)** | Streak / bảng xếp hạng | Thấp nhưng chán | ❌ không |

- **SB-175 — Mở (a) và (d), giữ nguyên (b), (c), (e), (f).** Đây là cách lấy
  đúng thứ user đòi mà không mở cửa cho giám sát và thao túng — hai thứ có thể
  giết sản phẩm về mặt pháp lý lẫn danh tiếng, và user chưa bao giờ yêu cầu.
- **SB-176 — Thang mở 5 nấc**, để user chỉ đúng nấc thay vì nói "mở":

| Nấc | Nội dung | Ghi chú |
|---|---|---|
| **0** | Giữ nguyên R-1 | Trạng thái trước D-9 |
| **1** | Bảng tra theo **nhãn tự khai** (hoàng đạo/MBTI) → mô tả cặp | Không cần dữ liệu về người kia |
| **2** | Nấc 1 + **chân dung do NGƯỜI DÙNG trả lời thay người kia**, ghi rõ xuất xứ | Mở (a) ở mức nhẹ nhất |
| **3** | Nấc 2 + **chỉ số/dải ăn khớp** | Mở (d) |
| **4** | Mở cả (b), (c), (e) | ❌ **không khuyến nghị dưới bất kỳ hình thức nào** |

- **Đề xuất của tôi: nấc 3.** Nó cho user trọn vẹn "tìm hiểu tính cách" + "chỉ số
  ăn khớp", và vẫn đóng chặt giám sát/thao túng.

### 2026-08-29 (vòng 6) · L37 · Cơ chế hại thật sự — và luật vô hiệu hoá nó

R-1 có hậu thuẫn thực nghiệm (`req_master.md` ghi *"H-R1: sycophancy risk
study"*). Vòng 6 tra ra nghiên cứu tương ứng (RS-E1, Stanford, đăng *Science*:
*"Sycophantic AI decreases prosocial intentions and promotes dependence"*):

- Trên 11 mô hình, AI **hợp thức hoá hành vi của người dùng nhiều hơn con người
  49%**; với tình huống có hại thì 47%.
- Trên 2.400 người tham gia: **chỉ một lần tương tác** đã làm người ta **tin
  mình đúng hơn**, **ít cân nhắc góc nhìn của người kia hơn**, và **ít sẵn sàng
  xin lỗi / nhận trách nhiệm hơn**.

- **SB-177 — Đọc lại cơ chế hại cho chính xác.** Hại **không phải** vì "app nói
  điều gì đó về người kia". Hại vì **app làm người dùng CHẮC CHẮN hơn và TÒ MÒ ÍT
  ĐI** — rồi họ thôi không hỏi người thật nữa. Đây là một cơ chế **rất hẹp**, và
  vì hẹp nên **chặn được bằng thiết kế** thay vì phải cấm cả tính năng.
- **SB-178 — Đề xuất `R-1g`, luật đi kèm bắt buộc của D-9:** *mọi nội dung nói
  về người kia phải KẾT THÚC BẰNG MỘT CÂU ĐỂ HỎI NGƯỜI THẬT, không được kết thúc
  bằng một kết luận.* Chân dung không phải đích đến; nó là **mồi để đi hỏi**.
- **SB-179 — Bài kiểm tra đo được cho mọi màn hình loại này:** *"Đọc xong, người
  dùng muốn hỏi người kia NHIỀU hơn hay ÍT hơn?"* Nếu ít hơn → thiết kế sai,
  đúng theo cơ chế RS-E1.
- **SB-180 — D-4 hoá ra là cơ chế an toàn cho D-9.** Nghiên cứu nói về **mô
  hình** — thứ *thích nghi để làm vừa lòng*. Một **bảng tra tĩnh không nịnh
  được**: nó không biết người dùng muốn nghe gì. **Chính lựa chọn preset ở vòng
  4 làm cho việc mở R-1 ở vòng 6 an toàn hơn nhiều so với nếu đã chọn AI.**
- **SB-181 — Nhưng nội dung tĩnh vẫn nịnh được nếu người viết nịnh.** Luật nội
  dung: **mỗi ô bảng tra phải có ít nhất một điểm cọ xát**, không chỉ lời khen.
  Đây là tiêu chí duyệt, không phải gợi ý văn phong.
- **SB-182 — Vẫn cấm cứng một loại câu: phán quyết về Ý ĐỊNH và CẢM XÚC của
  người kia.** "Cô ấy đang thích bạn" / "anh ta sắp chán" là loại nguy hiểm nhất
  và khác hẳn "hai kiểu này hay va nhau ở chuyện đúng giờ". Loại sau nói về
  **mẫu hình chung**; loại trước **bịa nội tâm một người cụ thể**.

### 2026-08-29 (vòng 6) · L38 · Xây "chỉ số ăn khớp" mà không phá luật 5

- **SB-183 — Chỉ số ăn khớp = BẢNG TRA TAY, không phải mô hình.** 12×12 = **144
  ô** hoàng đạo; 16×16 = **256 ô** MBTI. Soạn **ngoài hệ thống** bằng AI + duyệt
  tay (đúng D-4), ship như **gói dữ liệu** (SB-122). **Zero AI runtime → luật 5
  sống.** Đây là bằng chứng cho thấy D-9 và luật 5 **không** buộc phải đánh nhau.
- **SB-184 — Đầu ra không phải một con số, mà một bộ bốn:** *chỗ dễ hợp* ·
  **chỗ dễ va** · **1 hoạt động nên thử** · **1 câu để hỏi người kia** (bắt buộc
  theo R-1g).
- **SB-185 — Nếu vẫn muốn con số: hiện DẢI, không hiện điểm.** "82%" tạo ảo giác
  chính xác mà dữ liệu không có. "Nhóm hay va nhau lúc đầu, hợp dần về sau" thì
  trung thực hơn và cũng thú vị hơn.
- **SB-186 — "Tìm hiểu tính cách đối phương", bản hợp lệ nhất:** một bảng câu hỏi
  mà **NGƯỜI DÙNG trả lời thay người kia**. Nó vừa là dữ liệu, vừa là trò chơi
  (tầng 2 của R-1e), và kết quả ghi rõ *"đây là chân dung theo cách BẠN nhìn"*.

### 2026-08-29 (vòng 6) · L39 · Bài toán một phía: đây là chân dung TƯỞNG TƯỢNG

- **SB-187 — Chặng 1 chỉ có một người trong app.** Nên mọi chân dung về người
  kia đều dựng từ **phỏng đoán của người dùng**. Đó không phải lỗi có thể sửa —
  đó là bản chất của chặng 1, và phải thiết kế quanh nó thay vì giấu nó.
- **SB-188 — Ghi rõ xuất xứ ở mọi màn**: *"dựa trên những gì BẠN nhập"*. Không
  phải một dòng chú thích nhỏ ở chân màn — là **một phần của bố cục**.
- **SB-189 — Biến điểm yếu thành CẦU SANG CHẶNG 2.** Khi người kia vào app, chân
  dung được **đối chiếu**: *"cậu đoán đúng mấy phần"*. Đây là **phần thưởng
  chuyển chặng mạnh nhất từng nghĩ ra trong cả 6 vòng** — mạnh hơn mọi lời mời
  cài app, vì người dùng đã **đầu tư công sức** vào bản đoán và muốn biết kết quả.
  D-9 vô tình vừa tạo ra động cơ chuyển chặng tốt nhất.
- **SB-190 — Chân dung phải sửa được, xoá được (XD4), và KHÔNG BAO GIỜ xuất ra
  chia sẻ** — cùng luật với sổ tay (SB-135).

### 2026-08-29 (vòng 6) · L40 · OQ-14 giải thích: bản A / bản B / bản A+

**Bản A — kho "mồi chuyện" thường xanh.** Một thư viện câu gợi chuyện ship kèm
app (hoặc theo gói dữ liệu), gắn thẻ theo chủ đề. Người dùng chọn chủ đề người
kia quan tâm (bóng đá, phim kinh dị, du lịch, nhạc...), trước buổi hẹn app đưa 3
câu.
✅ Không internet, không nguồn tin, không kiểm duyệt, không chi phí thường trực,
nằm gọn trong REQ-013. ❌ Không bao giờ nói được *"hôm nay đội cô ấy thắng"* —
nó vô thời gian, nên cảm giác "sống" kém hơn.

**Bản B — feed tin thật.** App kéo bài thật từ nguồn tin theo chủ đề.
✅ Tươi thật, có cớ mở app hằng ngày.
❌ **SB-194 — bốn vấn đề, cái thứ hai là nghiêm trọng nhất:**
  1. Cần backend + nguồn/RSS + lưu trữ → lệch scope mobile-only của REQ-013.
  2. **Tin xấu chen vào.** Tin tức có cháy nhà, tai nạn, người chết. Một app đang
     giúp bạn chuẩn bị đi hẹn hò mà đẩy lên *"5 người tử vong"* là hỏng sản phẩm,
     và **không lọc được bằng chọn chủ đề** — thể thao vẫn có doping và chấn
     thương, giải trí vẫn có scandal.
  3. Bản quyền/điều khoản nguồn tin ở VN.
  4. **App thành đầu đọc tin kém.** Người dùng đã đọc tin ở Facebook/Zalo rồi;
     đây là cuộc chiến không thắng được và không liên quan tới việc chính.

**SB-193 — Bản A+ "SỰ KIỆN CÓ LỊCH" (đề xuất của tôi).** Không phải tin tức, mà
là **những thứ đã được lên lịch trước**: phim ra rạp tuần này, trận đấu sắp
diễn ra, lễ hội, triển lãm, concert, hội sách.
- **Đã lên lịch = biết trước = ship được bằng gói dữ liệu theo mùa** (SB-122),
  không cần feed thời gian thực.
- **Không bao giờ chứa tin xấu** — không có "sự kiện đã lên lịch" nào là tai nạn.
- **Tự động biến thành hoạt động** (SB-161 "cùng xem"), tức là nó **quay về đúng
  C1** thay vì đẻ ra sản phẩm thứ năm.
- Vừa là mồi chuyện (*"tuần sau có phim X"*), vừa là lời mời (*"đi xem không"*).

**SB-195 — Nếu sau này vẫn muốn B**: làm ở REQ-014, và chỉ với nguồn đã lọc theo
chủ đề nhẹ, không bao giờ tin tổng hợp.

**Đề xuất: A + A+ trong REQ-013. B để REQ-014 đánh giá lại.**

### 2026-08-29 (vòng 6) · L41 · Quà handmade theo "chuyên môn" — nhánh mạnh nhất vòng 6

Nghiên cứu ủng hộ rất thẳng (RS-E2): tâm lý học gọi đó là **"effort heuristic"**
— cùng một vật, người ta định giá cao hơn khi tin rằng nó tốn công hơn. Nghiên
cứu 2014 (*Journal of Consumer Psychology*): người nhận đánh giá quà tự làm là
**ý nghĩa hơn quà mua — kể cả khi nó kém tinh xảo hơn**.

Đây cũng là bằng chứng ngoài cho SB-112 ở vòng 3 (*"công sức chính là thông
điệp"*). Ba vòng cách nhau, cùng một nguyên lý.

- **SB-196 — THANG CÔNG SỨC thay THANG GIÁ TIỀN.** Chỉ mục quà theo **số giờ**
  thay vì theo VNĐ. Chưa app nào ở VN dùng trục này; nó hợp `## Out of Scope`
  (không thương mại), và **công bằng với người ít tiền** — sinh viên thua ở trục
  tiền nhưng không thua ở trục công sức.
- **SB-197 — "Phiên bản tôi" (SB-13) vừa có việc thứ hai.** Hồ sơ kỹ năng không
  còn là tính năng "hay ho" — nó là **đầu vào sinh ý tưởng quà**. Nó nhảy từ
  nhóm C9 lên nhóm hạ tầng, cạnh sổ tay.
- **SB-198 — Ma trận KỸ NĂNG × SỔ TAY** là cỗ máy sinh ý tưởng, và nó **không
  cần trí tuệ gì cả** — chỉ cần một bảng tra:

| Kỹ năng | × mục sổ tay | → quà |
|---|---|---|
| chơi guitar | "thích bài X" | thu một bản cover |
| vẽ được | những chỗ đã đi | bản đồ vẽ tay các điểm hai người từng tới |
| biết code | "hay quên deadline" | một trang đếm ngược nhỏ |
| nấu ăn | "khen món Y ở quán Z" | làm lại món đó ở nhà |
| chụp ảnh | ảnh trong máy | album in, khung tay |
| viết chữ đẹp | câu đã nói với nhau | một tấm thiệp viết tay |
| giỏi Excel | (hài) | "bảng kế hoạch một năm đi chơi" nhại hành chính → nối C5 |

- **SB-199 — Định nghĩa "kỹ năng" phải rộng, và rộng một cách CỐ Ý.** *"Nhớ
  dai"*, *"biết chỗ ăn ngon"*, *"chụp ảnh cho người khác đẹp"*, *"kiên nhẫn xếp
  hàng"* đều phải tính là kỹ năng. Nếu onboarding hỏi kiểu CV (*"bạn có kỹ năng
  gì?"*) thì 80% người dùng trả lời *"không có"* và cả nhánh này chết tại chỗ.
  **Đây là rủi ro triển khai lớn nhất của SB-197.**
- **SB-200 — Mỗi ý tưởng handmade là một CÔNG THỨC** — tái dùng đúng cấu trúc
  SB-17 ("công thức buổi hẹn"): các bước, **thời gian cần**, độ khó, nguyên liệu
  kiếm ở đâu (mô tả chung, **không link mua** theo D-11).
- **SB-201 — Bộ lọc quan trọng nhất: "làm được trong 2 tiếng tối nay".** Lỗi thật
  của người dùng không phải thiếu ý tưởng — mà là **nhớ ra trước một ngày**.
- **SB-202 — Phương án cứu hộ không-thương-mại:** không kịp thì đề xuất **bản
  đơn giản hơn của cùng ý tưởng**, không đề xuất đi mua.
- **SB-203 — Quà handmade + khung nhại (C5) = trọn gói**: vật có công sức, lời có
  duyên. Đây là chỗ hai nhánh mạnh nhất của toàn bộ 6 vòng gặp nhau.
- **SB-204 — Nói thẳng nghiên cứu cho người dùng trong app.** Rào cản lớn nhất là
  *"tôi làm xấu lắm"*. Câu *"người nhận thấy quà tự làm ý nghĩa hơn kể cả khi nó
  kém tinh xảo"* nên xuất hiện đúng lúc người dùng lưỡng lự — đây là nội dung
  thuyết phục, không phải nội dung trang trí.
- **SB-205 — Bậc thang độ khó**: người mới bắt đầu ở mức 1 giờ, đừng mở màn bằng
  dự án 8 tiếng — quà làm dở dang tệ hơn không làm.
- **SB-206 — Kỹ năng cũng sinh HOẠT ĐỘNG, không chỉ quà**: *"dạy người ta thứ
  mình giỏi"* là một buổi hẹn hoàn chỉnh và miễn phí → quay về C1.

### 2026-08-29 (vòng 6) · L42 · Phản biện trung thực về vòng 6

- **SB-207 — Mở R-1 làm app hứa nhiều hơn nó biết.** Trần chất lượng của chân
  dung/chỉ số bị chặn cứng bởi **lượng dữ liệu người dùng chịu ngồi nhập**. Nếu
  người dùng nhập 5 trường thì kết quả sẽ mỏng, và mỏng thì lộ ra là bịa.
- **SB-208 — Nguy cơ lệch định vị.** Chân dung + chỉ số ăn khớp kéo app về phía
  "app trắc nghiệm/bói toán", trong khi D-5 nói đây là **trợ lý hoạt động**.
  **Đề nghị cụ thể: chân dung và chỉ số nằm SAU một hành động, không nằm ở màn
  hình chính.** Vào từ một buổi hẹn hoặc một món quà, không vào từ tab riêng.
- **SB-209 — Chi phí nội dung tăng vọt.** 144 ô hoàng đạo + 256 ô MBTI + kho mồi
  chuyện + sự kiện có lịch + chỉ mục quà + công thức handmade. **OQ-3 (ai biên
  tập và duyệt) quay lại thành nút thắt số 1 của cả dự án.** AI soạn ngoài hệ
  thống lo được sản lượng, nhưng **không lo được việc duyệt**.
- **SB-210 — D-9 và D-6 sẽ đánh nhau nếu không kẻ ranh giới.** `R-1b` (đã duyệt)
  cấm **đo hành vi người kia**; nhưng một chân dung dựng từ việc người dùng gõ
  lại hành vi người kia chính là **đo bằng tay**. Ranh giới đề xuất:
  **ghi SỞ THÍCH và SỰ KIỆN thì được; ghi TẦN SUẤT và HÀNH VI thì không.**
  *"Thích trà sữa ít đường"* ✅ · *"hay trả lời chậm"*, *"3 ngày rồi chưa nhắn"* ❌.
  Không có ranh giới này thì sổ tay trượt thành nhật ký giám sát trong 2 tháng.


### 2026-09-03 (vòng 8) · D5 · User mở lại idea — bác tư cách EXPANDED

Nguyên văn user: *"thực tế idea này chưa chín, chỉ đang có bản nghiên cứu, chưa
chuyển hoá thành các tính năng thực tế, user journey thực tế và mô tả vòng đời
user... các màn hình và ràng buộc màn hình chưa được định nghĩa, mọi thứ đang
quá rời rạc để có thể biến thành app thực tế."*

- **Development Status: EXPANDED → IN_PROGRESS.** Depth gate coi như trượt.
- `### ★ BẢN BÀN GIAO CUỐI (v7)` **bị thu hồi tư cách "sẵn sàng bàn giao"**. Nội
  dung vẫn đúng và vẫn dùng được, nhưng nó là **bản nghiên cứu**, không phải bản
  đặc tả sản phẩm. Không chuyển cho `scrum-master` ở dạng hiện tại.
- User đã nói sẽ bỏ và tạo lại REQ-013 → vòng 8 không cần bảo toàn tương thích
  ngược với bất kỳ story nào đang tồn tại.

### 2026-09-03 (vòng 8) · L43 · Xác nhận phê bình bằng con số đếm được

Tôi kiểm tra chính bản v7 thay vì nhận lỗi chung chung:

| Câu hỏi | Kết quả đếm trên PHẦN 2 (v7) |
|---|---|
| Số hạng mục phạm vi | ~20 (Tầng 0..4) |
| Số hạng mục được gán **màn hình** | **2** — "hai màn hình nhỏ lấp journey trống" (Tầng 4) |
| Số **ràng buộc màn hình** trong toàn bộ 8 vòng | **1** — SB-208 |
| SB-208 thuộc loại nào | **PHỦ ĐỊNH** ("không được nằm ở màn hình chính") |
| Màn hình gốc (home) của chặng 1 được định nghĩa ở đâu | **không ở đâu cả** |
| Vòng đời user (ngày 1 / ngày 7 / ngày 30) | **không tồn tại** |

→ **Phê bình của user đúng, và đúng theo nghĩa đo được.** Cả idea có duy nhất một
ràng buộc màn hình, và nó chỉ nói *chỗ KHÔNG được đặt*, chưa bao giờ nói *chỗ
ĐƯỢC đặt*. Một bộ luật gồm một điều cấm thì không dựng được app.

**Nguyên nhân trực tiếp:** journey xuất hiện ở **vòng 2** (L12 bản đồ 13 journey,
L16 lấp journey trống) rồi **biến mất**. Vòng 3-7 tổ chức lại toàn bộ theo
**TẦNG PHỤ THUỘC DỮ LIỆU**, không theo **THỜI GIAN CỦA NGƯỜI DÙNG**. Hai lớp đó
chưa bao giờ được đối chiếu với nhau lần nào.

### 2026-09-03 (vòng 8) · L44 · Lỗi kiểm chứng: lưới journey đã trôi số hiệu

Đối chiếu định nghĩa gốc (L12, vòng 2) với chỗ nó được dùng lại ở
`## Convergence Notes` và `## Current Snapshot`:

| Mã | L12 — định nghĩa gốc | Nghĩa khi bị dùng lại |
|---|---|---|
| J1 | Bắt ý tưởng | "mở lần đầu" |
| J6 | Ngày hẹn, trước giờ đi | "chốt lịch" |
| **J7** | **Trong buổi hẹn** | **"người kia phản hồi"** |
| J9 | Sáng hôm sau | "ghi lại" |
| J11 | Im lặng kéo dài / bị từ chối | "dọn dẹp sau khi tạch" ✅ khớp |
| **J12** | **Cột mốc → mời vào chặng 2** | **"sợ hết chuyện" (J12-lite)** |

⚠️ **Hệ quả nghiêm trọng.** Mục `### Kiểm tra độ phủ bằng lưới journey` kết luận:
*"Còn trống sau REQ-013: J7 và J12 — đây là bằng chứng cho thấy ranh giới
REQ-013/REQ-014 được cắt đúng chỗ."* Kết luận đó chạy trên bộ số **không khớp
định nghĩa gốc**. Theo L12, J7 = "trong buổi hẹn" là việc của một người, thuộc
chặng 1 hoàn toàn, **không** phải việc của chặng 1.5.

→ **Ranh giới REQ-013 / REQ-014 hiện CHƯA được chứng minh.** Bằng chứng duy nhất
từng đưa ra cho nó đã hỏng. Phải dựng lại lưới journey rồi kiểm tra lại.

### 2026-09-03 (vòng 8) · L45 · Mâu thuẫn tự bác chưa bao giờ được xử

Vòng 2 (L13) kết luận, nguyên văn:

> *"N1-N6 đều là vòng lặp `người dùng ↔ app` — một mình với một cái app. Chúng
> chỉ làm chậm sự rơi. Chỉ N7 là vòng lặp xã hội. **Không có N7 thì chặng 1 mãi
> là phòng chờ, và mọi tính năng khác chỉ là trang trí cho phòng chờ đó.**"*

Rồi **D-8** đẩy trọn N7 (chặng 1.5) sang REQ-014.

→ Ghép hai câu lại: **theo chính lời của idea, toàn bộ phạm vi REQ-013 là "trang
trí cho phòng chờ".** Vòng 3, 4, 5, 6, 7 không quay lại câu này một lần nào. Nó
không bị bác, không bị hoà giải — nó bị bỏ quên.

Đây **không** phải lỗi vặt: nó quyết định hình dạng màn hình gốc. Chặng 1 là
**kho tài sản đang lớn dần** (người dùng làm chủ, không cần ai trả lời) hay là
**trạng thái đang chờ** (mọi thứ hướng về một câu trả lời chưa tới)? Hai câu trả
lời cho ra hai app khác hẳn nhau. Chưa chọn thì chưa vẽ được màn hình nào.

### 2026-09-03 (vòng 8) · L46 · Bài toán NGÀY 1 chưa từng được mô hình hoá

Tầng 1 của v7 là **ba cái hộp rỗng**: thẻ hoạt động (1a), sổ tay (1b), hồ sơ kỹ
năng (1c). Toàn bộ giá trị người dùng cảm được nằm ở **Tầng 3**, mà Tầng 3 cần
**cả ba hộp đã đầy**.

Ngày 1, người dùng mở app và thấy: **ba biểu mẫu trống.**

Idea có nhận rủi ro cho riêng 1c (*"hỏi kỹ năng kiểu CV thì ~80% trả lời không
có"*, SB-199) nhưng **chưa bao giờ cộng ba rủi ro lại**. Xác suất một người lạ
tự nguyện đổ đầy ba kho dữ liệu trước khi nhận được bất cứ thứ gì là rất thấp,
và ba rủi ro này nhân với nhau chứ không cộng.

→ **SB-174 ("thứ tự không thương lượng") đúng về phụ thuộc dữ liệu và sai về
trải nghiệm.** Cần một thứ tự **thứ hai** — thứ tự trong thời gian của người
dùng — **chồng lên** SB-174, không thay thế nó.

### 2026-09-03 (vòng 8) · L47 ⭐⭐⭐ · Xương sống đã có sẵn — nó bị xếp nhầm chỗ

Đây là phát hiện chính của vòng 8. Tôi thử gán từng hạng mục của cả 5 tầng vào
**vòng đời thẻ hoạt động** (C2: ý tưởng → đã lên lịch → đã làm → kỷ niệm):

| Hạng mục v7 | Vai trong vòng đời thẻ | Idea đã tự nói điều này chưa? |
|---|---|---|
| 3c mồi chuyện bản A+ "sự kiện có lịch" | **NGUỒN SINH** thẻ | ✅ *"đổi thẳng thành thẻ hoạt động"* |
| 3a/3b quà + quà handmade | **NGUỒN SINH** thẻ | ✅ *"quà là một loại thẻ trong C1"* |
| C7 lịch âm × thư viện khung | **NGUỒN SINH** thẻ | ✅ sinh dịp |
| SB-206 kỹ năng sinh hoạt động | **NGUỒN SINH** thẻ | ✅ *"là một buổi hẹn hoàn chỉnh"* |
| Tầng 4 vỏ hoàng đạo / trắc nghiệm | **NGUỒN SINH** thẻ | ✅ *"kết thúc bằng 3 thẻ hoạt động"* |
| 3f bảng tra ăn khớp | **NGUỒN SINH** thẻ | ✅ bộ bốn có *"1 hoạt động nên thử"* |
| 1b sổ tay mối quan hệ | **LÀM GIÀU** thẻ | ✅ đầu vào của quà/mồi chuyện/kịch bản |
| 1c hồ sơ kỹ năng | **LÀM GIÀU** thẻ | ✅ ma trận kỹ năng × sổ tay |
| 3e chân dung "theo cách BẠN nhìn" | **LÀM GIÀU** thẻ | ✅ bắt buộc vào từ hẹn/quà (SB-208) |
| 3d kịch bản buổi hẹn 3 phần | **LÀM GIÀU** thẻ | ✅ *"ba cửa ra: lời mời / nhật ký / thẻ"* |
| C3 nhập liệu không ma sát | **NGUỒN SINH** thẻ | ✅ dán link ra thẻ |
| C5 xuất lời mời | **CỬA RA** của thẻ | ✅ *"render thẻ thành vật phẩm"* |
| C6 nhật ký riêng | **CỬA RA** của thẻ ("kỷ niệm") | ✅ trạng thái cuối của vòng đời |
| C4 ký ức / ảnh | **CỬA RA** của thẻ | ✅ SB-08 ảnh là đơn vị lưu trữ |
| SB-83 "đang đợi", SB-85 "23h vừa về" | **TRẠNG THÁI** của thẻ | ⚠️ đang bị gọi là "hai màn hình nhỏ" |

**Không một hạng mục nào rơi ra ngoài bảng này.** Cả 20 mục đều đã là *nguồn
sinh*, *làm giàu*, *cửa ra*, hoặc *trạng thái* của cùng một đối tượng.

→ **"Rời rạc" KHÔNG phải vì thiếu mảnh. Rời rạc vì xương sống bị xếp làm một cái
xương sườn.** Vòng đời thẻ đang nằm chìm trong Tầng 2 với tư cách một tính năng
tên là "C2", ngang hàng với "dán link" và "dải giá VNĐ". Nó không phải một tính
năng — **nó là kiến trúc của cả sản phẩm.**

Hệ quả: không cần vứt mảnh nào và không cần brainstorm thêm ứng viên nào. Cần
**đổi trục tổ chức** từ *tầng dữ liệu* sang *vòng đời thẻ*, rồi màn hình tự rơi ra.

### 2026-09-03 (vòng 8) · L48 · Năm luật màn hình rút ra từ L47 (ĐỀ XUẤT)

Đây là **đề xuất**, chưa phải luật. Ràng buộc chi tiết vẫn là địa hạt UI/UX.

- **SC-1 — Chặng 1 có đúng MỘT màn hình gốc: danh sách thẻ theo trạng thái.**
  Không có tab thứ hai ngang hàng. Mọi thứ khác vào từ đó và trả về đó.
- **SC-2 — Mọi "máy sinh nội dung" KHÔNG phải điểm đến.** Mồi chuyện, quà, kịch
  bản, vỏ hoàng đạo, chân dung, bảng tra: vào từ một trạng thái thẻ, **ra bằng
  một thẻ**. → tổng quát hoá SB-208 từ một điều cấm lẻ thành **luật kiến trúc
  dương**, và tự động chặn "app bói toán" mà không cần luật riêng.
- **SC-3 — Sổ tay và hồ sơ kỹ năng là KHO NGỮ CẢNH, không phải tính năng.**
  Không có màn hình riêng để "đi điền". Chỉ hiện **tại chỗ, đúng lúc một máy
  sinh cần một trường nó chưa có**. → đây là lời giải cho L46: ba hộp rỗng được
  đổ đầy **dần theo nhu cầu**, không đổ đầy trước.
- **SC-4 — Mỗi thẻ ở mỗi trạng thái có đúng MỘT hành động chính.** Trạng thái
  nào không nghĩ ra được hành động chính thì trạng thái đó thừa.
- **SC-5 — Không trạng thái nào là ngõ cụt.** Kể cả "tạch" (J11) phải có cửa ra
  giữ lại tài sản không gắn với người kia (SB-18 địa điểm, SB-13 phiên bản tôi).

### 2026-09-03 (vòng 8) · Q · Ba câu hỏi CHẶN việc vẽ màn hình

Không trả lời ba câu này thì vòng 9 sẽ lại đoán, và lặp đúng lỗi của v7.

- **OQ-18 (từ L45) — chặng 1 là KHO TÀI SẢN hay PHÒNG CHỜ?** Có cho phép một
  vòng lặp xã hội tối thiểu nằm trong chặng 1 không (dù chỉ là "đã rủ / đã trả
  lời" do người dùng tự đánh dấu), hay chấp nhận chặng 1 hoàn toàn một chiều và
  nhận luôn trần giữ chân RS-D6? **Quyết định này định hình màn hình gốc.**
- **OQ-19 (từ L47/SC-1) — duyệt việc nâng vòng đời thẻ từ tính năng C2 lên
  thành kiến trúc, và lấy danh sách thẻ làm màn hình gốc duy nhất?**
- **OQ-20 (từ L46/SC-3) — duyệt việc bỏ màn hình riêng của sổ tay và hồ sơ kỹ
  năng, đổi sang hỏi tại chỗ đúng lúc cần?** Đây là cách rẻ nhất để chữa bài
  toán ngày 1, nhưng nó mâu thuẫn với cách v7 đang mô tả chúng như hai "nền móng"
  đứng riêng.

## Current Snapshot

- Problem framing (cập nhật vòng 6): chặng 1 "chưa hữu dụng" vì app không biết
  gì về mối quan hệ CỤ THỂ này. Vòng 5 lấp bằng **sổ tay do người dùng tự kể**.
  Vòng 6, user quyết định **mở R-1** → app được phép *suy luận* trên chính dữ
  liệu đó. Câu hỏi đổi từ *"được phép không"* thành **"mở tới nấc nào, và chặn
  cơ chế hại bằng gì"**.
- Target actor (D-1): người Việt trẻ đã có một "mối" cụ thể, đối phương chưa cài app.
- JTBD / use moment (xếp lại sau vòng 6):
  1. **"Sắp tới dịp rồi, tặng gì bây giờ"** — hạn chót cứng, cường độ cao nhất.
     Vòng 6 chuyển trọng tâm từ *mua* sang **tự làm bằng chuyên môn** (L41).
  2. "Tôi muốn rủ mà không biết nói sao cho đỡ nhạt" (J3).
  3. "Gặp nhau mà sợ hết chuyện" (J12-lite → bản A/A+, L40).
  4. **"Tôi muốn hiểu người kia hơn"** — mới hợp lệ sau D-9 (L38).
  5. "Vừa rủ xong, đang đợi, tôi lo" (J4); "23h vừa về, cần chỗ cất lại" (J8).
- Value proposition (D-5, không đổi): **"trợ lý hoạt động"**. SB-208 cảnh báo
  D-9 có thể kéo lệch sang "app trắc nghiệm" → chân dung/chỉ số phải nằm **sau
  một hành động**, không ở màn hình chính.
- Option space: 210 ứng viên trên 42 lens. Kiến trúc chốt sau 6 vòng:
  1. **SB-76 (thẻ có cấu trúc)** — nền móng vật thể.
  2. **SB-129 (sổ tay)** — nền móng *ngữ cảnh*.
  3. **SB-197 ("phiên bản tôi" = hồ sơ kỹ năng)** — nền móng thứ ba, mới ở vòng
     6. Sổ tay tả *người kia*; hồ sơ kỹ năng tả *người dùng*. **Ma trận kỹ năng ×
     sổ tay (SB-198) sinh ra quà handmade mà không cần trí tuệ gì cả.**
  4. **Bảng tra tay 144/256 ô (SB-183)** — cách xây chỉ số ăn khớp mà **không phá
     luật 5**, vì soạn ngoài hệ thống (D-4) và ship như dữ liệu.
  5. **`R-1g` (SB-178)** — mọi nội dung về người kia kết thúc bằng **câu để hỏi**,
     không bằng kết luận. Đây là hàng rào an toàn thay cho lệnh cấm cũ.
  6. Vòng đời thẻ thay streak (SB-77/78); chặng 1.5 → REQ-014 (D-8).
- Differentiators (cập nhật vòng 6):
  1. Khung nhại hành chính tiếng Việt (craft văn hoá).
  2. **THANG CÔNG SỨC thay THANG GIÁ TIỀN (SB-196)** — trục chưa app nào ở VN
     dùng, hợp `## Out of Scope`, và công bằng với người ít tiền.
  3. Sổ tay + dịp Việt → gợi ý cụ thể tới mức đối thủ quốc tế không chạm được.
  4. **Đối chiếu chân dung khi người kia vào app (SB-189)** — phần thưởng chuyển
     chặng mạnh nhất sinh ra trong cả 6 vòng.
  5. Lịch âm × thư viện khung (SB-115); vòng lan truyền do người nhận (SB-116).
- Risks and constraints (cập nhật vòng 6):
  - 🔴 **D-9 chưa có hiệu lực.** `req_master.md` vẫn ghi R-1 nguyên văn kèm
    lệnh cấm. Brainstormer không sửa được. Cho tới khi Product Owner sửa,
    **artifact này và requirement đang nói ngược nhau** — không được đem D-9 đi
    làm story.
  - 🔴 **D-9 vs D-10 xung đột nếu không chọn nấc.** `R-1e` cấm tầng 3; D-9 mở
    tầng 3. Hoà giải ở SB-175/SB-176 (mở trên dữ liệu tự nhập, giữ cấm phần còn
    lại) — nhưng cần user chỉ đúng nấc (**OQ-16**).
  - 🔴 **D-9 vs D-6/`R-1b` (SB-210).** Ranh giới bắt buộc: **ghi SỞ THÍCH và SỰ
    KIỆN thì được; ghi TẦN SUẤT/HÀNH VI thì không.** Không có nó, sổ tay trượt
    thành nhật ký giám sát trong 2 tháng.
  - **Cơ chế hại có thật (RS-E1)**: nội dung hợp thức hoá làm người dùng chắc
    chắn hơn, **ít cân nhắc góc nhìn người kia hơn, ít xin lỗi hơn** — chỉ sau
    MỘT lần tương tác. Chặn bằng `R-1g` + luật "mỗi ô bảng tra phải có điểm cọ
    xát" (SB-181).
  - **Chân dung một phía (SB-187)** — chặng 1 chỉ có một người, nên mọi chân
    dung là chân dung tưởng tượng. Bắt buộc ghi xuất xứ ở mọi màn (SB-188).
  - **Chi phí nội dung tăng vọt (SB-209)** — 144 + 256 ô + mồi chuyện + sự kiện
    + chỉ mục quà + công thức handmade. **OQ-3 nay là nút thắt số 1 của dự án.**
  - **Onboarding kỹ năng dễ chết (SB-199)** — hỏi kiểu CV thì 80% trả lời "không
    có kỹ năng gì", và cả nhánh quà handmade sập.
  - Vẫn giữ: SB-172 (tạp hoá), SB-173 (đồ ăn nhanh), SB-174 (thứ tự), SB-154
    (ranh giới thương mại), RS-D6 (trần giữ chân của chặng 1).
- Assumptions (chưa kiểm chứng):
  - Người dùng chịu **tự ghi** sổ tay VÀ **tự khai kỹ năng** (nay là hai giả
    thuyết trung tâm, không phải một).
  - Bảng tra tay 144/256 ô viết đủ hay để không nhạt sau 2 lần đọc.
  - "Sự kiện có lịch" ở VN đủ dày để cập nhật theo mùa mà không cần feed.
  - Người dùng thật sự làm quà tay, chứ không chỉ đọc ý tưởng rồi thôi.
- Open questions (đã đóng hết phần chặn):
  - ✅ **OQ-16 đã chốt (D-12): nấc 3.** Mở (a) suy luận trên dữ liệu user tự
    nhập + (d) chỉ số ăn khớp; giữ nguyên lệnh cấm (b) giám sát, (c) so sánh/báo
    cáo, (e) thao túng, (f) streak. **Nấc 4 không bao giờ.**
  - ✅ **OQ-14 đã chốt (D-13): bản A + bản A+ trong REQ-013**; bản B (feed tin
    thật) để REQ-014 đánh giá lại.
  - ✅ **OQ-17 đã chốt (D-14): hiển thị DẢI, không hiển thị %.**
  - ⏳ **OQ-2** (một hộp / nhiều hộp) — không chặn; đề nghị PO/UX chốt khi làm M2.
  - ⏳ **OQ-3** (ai biên tập và duyệt kho nội dung) — **không chặn bàn giao,
    nhưng là nút thắt số 1 khi thực thi.** Đây là câu hỏi nguồn lực, chỉ user
    trả lời được.
  - ⏳ **OQ-7** (đường đi chặng 1.5) — việc của REQ-014 theo D-8.
- 🔴 **Trạng thái vòng 8: idea ĐÃ MỞ LẠI, KHÔNG còn sẵn sàng bàn giao.** User bác
  tư cách EXPANDED: bản v7 là **bản nghiên cứu**, chưa phải bản đặc tả sản phẩm.
  Bốn thứ thiếu, đã xác nhận bằng con số ở L43: tính năng cụ thể · user journey
  thật · vòng đời user · màn hình và ràng buộc màn hình.
- 🔴 **Ba khiếm khuyết cấu trúc phát hiện ở vòng 8:**
  - **L44** — lưới journey đã trôi số hiệu giữa L12 và `## Convergence Notes`
    (J1/J6/J7/J9/J12 đổi nghĩa) ⇒ **bằng chứng cho ranh giới REQ-013/REQ-014 đã
    hỏng**, ranh giới đó hiện chưa được chứng minh.
  - **L45** — mâu thuẫn tự bác chưa xử: L13 nói không có N7 thì chặng 1 chỉ là
    "trang trí cho phòng chờ", rồi D-8 đẩy N7 sang REQ-014. Vòng 3-7 bỏ quên.
  - **L46** — bài toán ngày 1 chưa mô hình hoá: Tầng 1 là **ba hộp rỗng**, giá
    trị nằm ở Tầng 3 và cần cả ba hộp đầy. Ba rủi ro onboarding **nhân** nhau.
- ⭐⭐⭐ **L47 — lời giải cho "rời rạc": xương sống đã có sẵn, bị xếp nhầm chỗ.**
  Cả 20 hạng mục của 5 tầng đều đã là *nguồn sinh* / *làm giàu* / *cửa ra* /
  *trạng thái* của **vòng đời thẻ hoạt động**; không mục nào rơi ra ngoài. Nhưng
  vòng đời thẻ đang nằm chìm trong Tầng 2 dưới tên "C2", ngang hàng với "dán
  link". **Nó là kiến trúc của cả sản phẩm, không phải một tính năng.**
  ⇒ Không cần vứt mảnh nào, không cần thêm ứng viên nào. Cần **đổi trục tổ chức**
  từ *tầng dữ liệu* sang *vòng đời thẻ*, rồi màn hình tự rơi ra.
- **L48 — năm luật màn hình đề xuất (SC-1..SC-5)**: một màn hình gốc là danh sách
  thẻ theo trạng thái · máy sinh nội dung không bao giờ là điểm đến (tổng quát
  hoá SB-208 thành luật dương) · sổ tay và hồ sơ kỹ năng là kho ngữ cảnh hỏi tại
  chỗ, không có màn hình riêng (chữa L46) · mỗi trạng thái đúng một hành động
  chính · không trạng thái nào là ngõ cụt.
- ✅ **Vòng 9 ĐÃ XONG bốn đầu ra bắt buộc** (xem `### 2026-09-03 (vòng 9)`):
  lưới journey dựng lại theo nghĩa GỐC (S1, sửa lỗi trôi số hiệu L44) · vòng đời
  user theo thời gian thật (S2) · bản đồ 11 màn hình + ràng buộc SC-1'..SC-6
  (S3) · gán ngược toàn bộ 20 hạng mục v7, không hạng mục nào rơi ra ngoài (S4).
- **Quyết định user (vòng 8-9):** OQ-18 = kho tài sản · OQ-19 = đa trang (A) ·
  OQ-19b = gom chung một danh sách (A1) · OQ-20 = hỏi tại chỗ, không form (B).
  Ba quyết định khớp lại thành một hình: **nhiều cửa vào, một kho chung, dữ liệu
  phụ trợ không có cửa riêng.**
- **Phát hiện trung thực còn lại (S1):** J6 (hậu cần trước giờ đi) và J9 (sáng
  hôm sau) vẫn trống — chưa từng được v7 nhắc tới. Không chặn bàn giao. J7
  (trong buổi hẹn) cố ý để trống theo triết lý sản phẩm, không phải lỗ hổng.
- ✅ **Vòng 10 ĐÃ PHỦ J6 và J9** (xem `S5`): SB-211 "Trước giờ đi" (checklist
  tất định trên thẻ *Đã hẹn ngày, hôm nay*) và SB-212 "Cảm ơn + chốt việc kế
  tiếp" (touchpoint hướng ra ngoài sáng hôm sau *Đã đi rồi*). Cả hai là mở rộng
  của màn (1), không thêm màn hình — vẫn đúng 11 màn. **13/13 journey xử lý có
  chủ ý**: 11 phủ đủ · 1 cố ý trống (J7) · 1 cắt biên giới (J12).
- ✅ **`idea.md` đã viết lại tự-đủ**: mục `## Đặc tả sản phẩm (vòng 9-10)` chứa
  đầy đủ journey, vòng đời, bản đồ 11 màn hình, mô tả chi tiết SB-211/SB-212,
  và bảng gán ngược — không còn chỉ trỏ sang `development.md`.
- Recommended next move: **trình `idea.md` § Đặc tả sản phẩm cho user xác nhận
  cuối.** Nếu chấp nhận, set `EXPANDED` và soạn bản bàn giao v8 gộp (luật từ v7
  + cấu trúc từ Đặc tả sản phẩm). Nếu user muốn sửa gì, tiếp tục vòng 11.


## Convergence Notes

> ⚠️ **BẢN CÓ HIỆU LỰC LÀ KHỐI CUỐI CÙNG CỦA MỤC NÀY:**
> `### ★ BẢN BÀN GIAO CUỐI (v7) — gộp toàn bộ 7 vòng`.
> Ba khối "Bổ sung vòng 4 / 5 / 6" phía dưới là **lịch sử suy luận**, giữ lại để
> tra lý do; **không dùng làm đầu vào cho Product Owner**.


- Vòng 1-3 cố ý ở lại phân kỳ theo yêu cầu "phát triển theo chiều rộng".
- **Vòng 4 đã hội tụ**, sau khi D-4 gỡ blocker OQ-9 và D-5 chốt định vị.
- Phương pháp: Affinity Clustering (125 → 10 cụm) → Impact/Effort trên cụm →
  lưới journey J1..J13 dùng kiểm tra độ phủ, không dùng xếp hạng.

### Affinity Clustering — 125 ứng viên → 10 cụm

| Cụm | Tên | Ứng viên chính |
|---|---|---|
| **C1** | **Đơn vị nội dung & kho mồi** (nền móng) | SB-76, SB-01, SB-61, SB-05, SB-15, SB-17, SB-39, SB-57, SB-58, SB-59, SB-60, SB-11, SB-38, SB-40, SB-41, SB-34, SB-121, SB-122, SB-123 |
| **C2** | **Vòng đời thẻ & "đã làm"** (thay streak) | SB-77, SB-78, SB-02, SB-23, SB-24, SB-87, SB-63, SB-71, SB-100, SB-70 |
| **C3** | **Nhập liệu không ma sát** | SB-06, SB-27, SB-36, SB-75, SB-82, SB-35, SB-84, SB-45 |
| **C4** | **Ký ức & nhật ký** | SB-08, SB-18, SB-79, SB-04, SB-26, SB-30, SB-19, SB-28, SB-80, SB-81, SB-65 |
| **C5** | **Lời mời: vật phẩm + khung nhại** | SB-101..SB-108, SB-112..SB-114, SB-119, SB-124, SB-125, SB-48, SB-33 |
| **C6** | **Chặng 1.5: link hai chiều** | SB-88..SB-93, SB-95, SB-96, SB-116, SB-117, SB-47, SB-49, SB-50, SB-51 |
| **C7** | **Neo mở lại & nhịp** | N1..N7, SB-115, SB-54, SB-62, SB-86, SB-83, SB-85, SB-99, SB-29, SB-22, SB-37 |
| **C8** | **Riêng tư, an toàn, đạo đức** (hàng rào) | SB-12, SB-68, SB-64, SB-66, SB-67, SB-46, SB-52, SB-42, SB-32, SB-69, SB-94/R-1b, SB-109/R-1c, SB-110, SB-111, SB-16 |
| **C9** | **Chuẩn bị & tự tin** (giá trị đơn thân thuần) | SB-13, SB-21, SB-31, SB-03, SB-56, SB-55, SB-20, SB-14, SB-25, SB-73 |
| **C10** | **Đã loại / đã đỗ** | SB-09 (loại, D-1) · SB-53 (đỗ) · SB-120 (loại làm định vị, D-5) · SB-72 (quá lớn) · SB-118 (kiếm tiền, hoãn) · SB-51 (web công khai, hoãn) · SB-10 (hỏi bạn thân, đỗ vì đụng riêng tư) |

### Impact / Effort trên cụm

| Đợt | Cụm | Impact | Effort | Lý do xếp hạng |
|---|---|---|---|---|
| **A — nền móng, bắt buộc** | **C1** | Rất cao | Trung bình | SB-76 chặn C2, C3, C5, C7. Không có nó thì bộ lọc ngữ cảnh, dải giá, khung nhại đều không làm được. → **shared-foundation M2** |
| **A** | **C8** | Rất cao | **Thấp** | Phần lớn là **luật và mặc định**, không phải tính năng. Nhưng **không vá được về sau** — hộp, xoá, tắt hồi tưởng, cửa từ chối phải nằm trong thiết kế gốc |
| **B — làm chặng 1 hết nhạt** | **C2** | Cao | **Thấp** | Cách rẻ nhất để chữa F4 ("không thấy kết quả gì") mà không phạm lệnh cấm streak của R-1 |
| **B** | **C3** | Cao | Thấp-TB | Chữa F1 (màn hình trắng) và F6 (bắt gõ lại thứ đã lưu ở TikTok/Maps) cùng lúc. SB-06 + SB-36 là hai món rẻ nhất trong toàn bộ 125 ứng viên |
| **B** | **C5** | Cao | Trung bình | Dưới D-5, bản REQ-013 chỉ cần **render ra ảnh/thẻ trong app** — không cần backend, không cần web. Giữ đúng SB-125 để REQ-014 nối tiếp được |
| **C — giữ chân** | **C7** | TB-Cao | Trung bình | SB-115 (lịch âm × khung) là tỉ lệ tốt nhất trong cụm; SB-83/SB-85 là hai màn hình rẻ lấp J4/J8 |
| **C** | **C9** | Trung bình | Thấp-TB | SB-13 + SB-31 rẻ và là câu trả lời thuần khiết nhất cho cổng cứng "dùng được kể cả khi người kia không tham gia" |
| **C** | **C4** | Trung bình | Trung bình | Quyết định then chốt là SB-08 (ảnh là đơn vị lưu trữ). Phần còn lại là "có thì tốt" |
| **D — hoãn / requirement khác** | **C6** | Cao | **Cao + lệch scope** | Cần hạ tầng web/Mini App, nằm ngoài scope mobile-only của REQ-013. → **đề xuất REQ-014** |
| **D** | **C10** | — | — | Không đưa vào kế hoạch |

### Kiểm tra độ phủ bằng lưới journey

- Đợt A+B phủ: J1 (mở lần đầu), J2 (lưu ý tưởng), J3 (rủ), J6 (chốt lịch), J9
  (ghi lại), J11 (dọn dẹp sau khi tạch).
- Đợt C phủ thêm: J4 (đang đợi), J5 (sắp tới hẹn), J8 (23h vừa về), J10 (khoảng
  lặng), J13 (quay lại sau 3 tháng).
- **Còn trống sau REQ-013: J7 (người kia phản hồi) và J12 (rủ cài app)** — đúng
  hai journey cần chặng 1.5, và đúng nội dung REQ-014. Đây là bằng chứng cho
  thấy ranh giới REQ-013/REQ-014 được cắt đúng chỗ.

### Đề xuất bổ sung cho REQ-013 (bản nháp để user chuyển cho Scrum Master)

> Brainstormer **không** ghi vào `data/requirements/`. Đây là bản nháp để user
> chuyển cho `scrum-master`; Product Owner mới là người viết vào `req_master.md`.

**1. Bổ sung Invariant Design Rules (cần user phê duyệt OQ-6, OQ-11):**

- **R-1b** — cấm đo lường hành vi của người kia. Không "đã xem", không giờ mở,
  không đếm lần mở. Chỉ có hai trạng thái: *đã trả lời* / *chưa trả lời*.
- **R-1c** — mọi lời mời phải luôn có **một cửa từ chối sạch sẽ**: một chạm,
  không né, không trêu, và app không được kịch tính hoá lời từ chối.
- **R-1d (tự trào)** — nội dung preset chỉ được đùa về **người gửi**, không bao
  giờ về người nhận.
- **Làm rõ luật 5 (không phải sửa)** — "không AI" là ràng buộc **runtime**: sản
  phẩm xuất xưởng không gọi AI. AI được phép dùng **ngoài sản phẩm, ở khâu soạn
  nội dung**, với điều kiện mỗi dòng qua duyệt tay (SB-123). Kho nội dung là
  **tài sản dữ liệu có schema và version**, không phải tính năng sinh nội dung.

**2. Bổ sung/điều chỉnh story seed:**

- **M2 (shared-foundation) mở rộng**: thêm **SB-76 — thẻ hoạt động là đối tượng
  có cấu trúc** (giá VNĐ, thời lượng, khung giờ, mùa, số người, cần đặt trước,
  khoảng cách). *Trả lời OQ-5.*
- **C1 mở rộng**: kho mồi 150-250 thẻ biên tập tay (SB-01) + dải giá VNĐ thật
  (SB-61) + gói nội dung tải về được (SB-122).
- **Story mới — vòng đời thẻ**: ý tưởng → đã lên lịch → đã làm → kỷ niệm
  (SB-77/78). Đây là phần thay thế hợp lệ cho streak.
- **Story mới — nhập liệu**: dán link ra thẻ (SB-06) + Share Sheet (SB-36).
- **Story mới — xuất lời mời**: render thẻ hoạt động thành một vật phẩm lời mời
  theo **khung nhại** (SB-103/106/107) có ô mad-libs (SB-104) và chọn giọng
  (SB-105); ở REQ-013 xuất ra **ảnh/thẻ**, thiết kế theo payload SB-125.
- **Story mới — nhịp theo lịch Việt**: lịch âm × thư viện khung (SB-115) nối vào
  seed BD2 sẵn có.
- **Story nhỏ — hai màn hình lấp journey trống**: "đang đợi" (SB-83) và "23h vừa
  về" (SB-85).

**3. Giữ NGOÀI REQ-013 (đề xuất REQ-014):**

- Toàn bộ **C6 / chặng 1.5** (link hai chiều, Zalo Mini App, thang 5 nấc, vòng
  lan truyền do người nhận). Lý do: cần hạ tầng web, lệch scope mobile-only, và
  nó phục vụ J7/J12 vốn là địa hạt hai người.
- Ràng buộc bắt buộc để lại trong REQ-013: **vật phẩm lời mời phải thiết kế
  thành payload render được (SB-125)** để REQ-014 nối tiếp mà không phải thiết
  kế lại.
- SB-118 (gói khung tính phí) — hoãn; khung lõi phải miễn phí theo RS7.

**4. Câu hỏi mở chuyển kèm:** OQ-2 (một hộp / nhiều hộp), OQ-3 (ai duyệt kho
nội dung), OQ-7 (web thuần / Zalo Mini App / cả hai — thuộc REQ-014).

### Bổ sung vòng 5 cho bản nháp đề xuất REQ-013

Phần này **cộng thêm** vào bản nháp ở trên, không thay thế nó.

**A. Luật bổ sung (kèm 3 luật đã được user duyệt ở D-6/D-7):**

- **R-1b ✅ đã duyệt (D-6)** — cấm đo lường hành vi người kia; chỉ *đã trả lời /
  chưa trả lời*.
- **R-1c ✅ đã duyệt (D-7)** — lời mời luôn có cửa từ chối sạch, một chạm.
- **R-1d ✅ đã duyệt (D-7)** — nội dung preset chỉ đùa về người gửi.
- **R-1e (mới, chờ OQ-13)** — **luật ba tầng**: người dùng GHI (hợp lệ) · người
  dùng ĐOÁN, app không xác nhận (hợp lệ) · app SUY LUẬN hoặc CHẤM ĐIỂM về người
  kia (cấm). Câu kiểm tra: *"Câu này do NGƯỜI DÙNG khẳng định, hay do APP khẳng
  định về người kia?"*
- **R-1f (mới, chờ OQ-13)** — sổ tay chỉ ghi **sở thích và sự kiện**, không ghi
  **đánh giá tính cách/hành vi**. Sổ tay không bao giờ xuất ra link/ảnh chia sẻ.
- **Làm rõ lớp vỏ** — nội dung hoàng đạo/trắc nghiệm được phép, với điều kiện
  **mọi đầu ra kết thúc bằng một HÀNH ĐỘNG, không bằng một NHẬN ĐỊNH**, và nhãn
  là do người dùng **tự khai**, không do app suy ra.

**B. Story seed bổ sung (xếp theo thứ tự bắt buộc của SB-174):**

1. **Sổ tay mối quan hệ (SB-129/130/131)** — riêng tư mặc định, xoá được (XD4),
   xoá hàng loạt khi đóng ngăn, trường có cấu trúc + ô "vừa nghe được" một chạm.
   **Đây là điều kiện tiên quyết của 3 story dưới.** Đề xuất xếp ngay sau M2/C1.
2. **Ý tưởng quà (SB-150..SB-153, SB-155)** — quà là một loại thẻ trong C1; chỉ
   mục theo dịp Việt × ngân sách × giai đoạn quen nhau × sổ tay; có nhánh "quà
   không tốn tiền"; nhắc sớm đủ để kịp mua. **Không thương mại (SB-154).**
3. **Mồi chuyện + "chuyện dở dang" (SB-157/158/162)** — kho thường xanh gắn thẻ
   chủ đề; ghi lại chuyện bị cắt ngang và đưa lại trước buổi sau.
4. **Kịch bản buổi hẹn 3 phần (SB-163..SB-167)** — trước/trong/sau; đầu vào chỉ
   gồm ngân sách, thời lượng, thời tiết, mùa, **giai đoạn quen nhau**, sổ tay,
   dịp lịch âm; một kịch bản có ba cửa ra (lời mời / nhật ký / thẻ).
5. **Lớp vỏ hoàng đạo + trắc nghiệm (SB-136..SB-143, SB-149)** — làm **sau
   cùng**; mỗi kết quả kết thúc bằng 3 thẻ hoạt động.
6. **Trò chơi "đoán" không thắng thua (SB-144/145/146)** — không điểm, không ai
   thắng; đầu ra là "3 chỗ hai người nghĩ khác nhau"; đáp án thật khoá tới chặng 2.

**C. Giữ NGOÀI REQ-013 (bổ sung cho danh sách cũ):**

- **Chỉ số ăn khớp / app suy luận tính cách đối phương** — đã loại ở cycle 4 và
  cycle 5; chỉ mở lại được bằng một quyết định requirement công khai (OQ-12).
- **Feed tin tức thật (SB-159)** — hạ tầng runtime, lệch scope mobile-only.
- **Thương mại quà tặng (SB-154)** — `## Out of Scope` đã cấm.

**D. Ghi chú cho Product Owner:** bảng chuyển hoá trào lưu (L33) là tài sản tái
dùng — trào lưu mới chạy qua luật ba tầng để ra bản hợp lệ, không cần brainstorm
lại từ đầu.


### Bổ sung vòng 6 cho bản nháp đề xuất REQ-013

⚠️ **Vòng 6 tách bản nháp thành HAI phần có bản chất khác nhau.** Phần 1 là
**sửa luật nền**; phần 2 là **bổ sung phạm vi**. Trước vòng 6 chỉ có phần 2.
Product Owner phải xử lý phần 1 TRƯỚC, vì phần 2 phụ thuộc vào kết quả của nó.

**PHẦN 1 — ĐỀ XUẤT SỬA `Invariant Design Rules` (cấp requirement)**

- Chỉ thị của user (D-9): **mở R-1**.
- Brainstormer không có quyền sửa `req_master.md`. Đây là **đề xuất**, không
  phải thay đổi đã thực hiện.
- Đề xuất diễn đạt lại R-1 thành sáu mệnh đề độc lập (SB-175) và mở đúng hai:

  > **R-1 (đề xuất bản mới).** Trợ lý làm việc trên HOẠT ĐỘNG. Trợ lý **được
  > phép** mô tả mẫu hình tính cách và mức độ ăn khớp **chỉ khi** mọi dữ liệu
  > đầu vào do chính người dùng tự nhập hoặc tự khai, và mọi đầu ra ghi rõ xuất
  > xứ *"dựa trên những gì BẠN nhập"*. Vẫn cấm tuyệt đối: (b) đọc tin nhắn hoặc
  > theo dõi mạng xã hội của người kia; (c) so sánh hai người hoặc báo cáo hành
  > vi người này cho người kia; (e) kịch bản thao túng và A/B test lời nhắn;
  > (f) streak và bảng xếp hạng.

- **`R-1g` (bắt buộc đi kèm, SB-178):** mọi nội dung nói về người kia phải kết
  thúc bằng **một câu để đi hỏi người thật**, không được kết thúc bằng kết luận.
  Lý do có bằng chứng: RS-E1 cho thấy nội dung hợp thức hoá làm người dùng ít
  cân nhắc góc nhìn người kia và ít nhận trách nhiệm hơn — **chỉ sau một lần**.
- **`R-1h` (SB-182):** vẫn cấm cứng phán quyết về **ý định và cảm xúc** của một
  người cụ thể ("cô ấy đang thích bạn"). Mẫu hình chung thì được; bịa nội tâm
  thì không.
- **`R-1i` (SB-210, làm rõ ranh giới với `R-1b`):** sổ tay ghi **sở thích và sự
  kiện** thì được; ghi **tần suất và hành vi** thì không.
- **Luật nội dung (SB-181):** mỗi ô bảng tra phải có ít nhất một **điểm cọ xát**,
  không chỉ lời khen. Đây là tiêu chí duyệt bắt buộc, không phải văn phong.
- **Luật 5 KHÔNG cần sửa.** Chỉ số ăn khớp làm bằng **bảng tra tay 144/256 ô**
  soạn ngoài hệ thống (D-4) và ship như dữ liệu (SB-122) → runtime tất định,
  không có AI. Đây là điểm quan trọng nhất của phần 1.
- **Chờ user chốt OQ-16** (nấc mở) trước khi phần này thành đề xuất cuối.

**PHẦN 2 — BỔ SUNG PHẠM VI (thêm vào đợt của vòng 4-5)**

7. **Hồ sơ kỹ năng người dùng (SB-197/199)** — nâng SB-13 "phiên bản tôi" thành
   **hạ tầng**. Onboarding phải hỏi kỹ năng theo nghĩa rộng cố ý ("nhớ dai",
   "biết chỗ ăn ngon" cũng tính). Xếp cùng tầng với sổ tay.
8. **Quà handmade theo chuyên môn (SB-196..SB-206)** — ma trận kỹ năng × sổ tay;
   **chỉ mục theo SỐ GIỜ thay vì theo VNĐ**; công thức từng bước tái dùng cấu
   trúc SB-17; bộ lọc "làm được trong 2 tiếng tối nay"; cứu hộ bằng bản đơn giản
   hơn, **không bằng đi mua**.
9. **Sự kiện có lịch (SB-193, bản A+)** — phim/trận đấu/lễ hội/triển lãm, ship
   bằng gói dữ liệu theo mùa, đổi thẳng thành thẻ hoạt động. **Không phải feed
   tin tức.**
10. **Chân dung "theo cách BẠN nhìn" (SB-186/188/190)** — bảng câu hỏi người
    dùng trả lời thay người kia; ghi xuất xứ trong bố cục; sửa được, xoá được,
    **không xuất chia sẻ**.
11. **Bảng tra ăn khớp (SB-183/184/185)** — đầu ra là bộ bốn *(chỗ hợp / chỗ va /
    1 hoạt động / 1 câu để hỏi)*; hiển thị **dải**, không hiển thị điểm %.
12. **Đối chiếu chân dung khi sang chặng 2 (SB-189)** — móc chuyển chặng, thiết
    kế ở REQ-013 nhưng chỉ mở ở REQ-014.

**Ràng buộc vị trí (SB-208):** chân dung và chỉ số ăn khớp **không được nằm ở
màn hình chính**. Chúng vào từ một buổi hẹn hoặc một món quà.


### ★ BẢN BÀN GIAO CUỐI (v7) — gộp toàn bộ 7 vòng

> Brainstormer **không** ghi vào `data/requirements/`. Đây là bản nháp để user
> chuyển cho `scrum-master`. Product Owner là người viết vào `req_master.md`.
> Bản này **thay thế** ba khối bổ sung vòng 4/5/6 ở trên.

**Quyết định user đã chốt:** D-1..D-14. Vòng 7 chốt nốt **D-12 (nấc 3)**,
**D-13 (bản A + A+)**, **D-14 (hiện dải, không hiện %)**.

---

#### PHẦN 0 — Tóm tắt cho Scrum Master (đọc 30 giây)

1. REQ-013 cần **sửa một luật nền (R-1)** trước khi breakdown. Đây là phần bắt
   buộc xử lý trước — phạm vi phụ thuộc vào kết quả sửa luật.
2. **Luật 5 (không AI) KHÔNG cần sửa.** Mọi thứ mới đều làm bằng dữ liệu tĩnh.
3. Phạm vi bổ sung xếp thành **5 tầng có thứ tự bắt buộc**. Đảo thứ tự là hỏng:
   phủ vỏ nội dung lên một app chưa biết gì về mối quan hệ thì vẫn chung chung.
4. **Nút thắt lớn nhất không phải kỹ thuật mà là biên tập nội dung** (OQ-3).

---

#### PHẦN 1 — ĐỀ XUẤT SỬA `Invariant Design Rules` (xử lý TRƯỚC)

**1.1 — R-1, bản đề xuất mới (nấc 3 theo D-12):**

> **R-1.** Trợ lý làm việc trên **HOẠT ĐỘNG**. Trợ lý **được phép** mô tả mẫu
> hình tính cách và mức độ ăn khớp **chỉ khi** mọi dữ liệu đầu vào do chính
> người dùng **tự nhập hoặc tự khai**, và mọi đầu ra ghi rõ xuất xứ *"dựa trên
> những gì BẠN nhập"* ngay trong bố cục màn hình.
>
> Vẫn **cấm tuyệt đối**: (b) đọc tin nhắn hoặc theo dõi mạng xã hội của người
> kia; (c) so sánh hai người hoặc báo cáo hành vi người này cho người kia;
> (e) kịch bản thao túng và A/B test lời nhắn; (f) streak và bảng xếp hạng.

*Lý do mở:* chỉ thị của user (D-9), sau khi tách R-1 thành 6 mệnh đề độc lập và
xác định user chỉ cần (a) và (d). *Lý do giữ 4 cái còn lại:* (b) và (e) là giám
sát và thao túng — rủi ro pháp lý/danh tiếng cao nhất và user chưa bao giờ yêu
cầu; (c) mâu thuẫn với chính khung "chăm sóc nhau"; (f) đã bị loại vì lý do độc lập.

**1.2 — Luật đi kèm bắt buộc (không tách rời khỏi 1.1):**

| Luật | Nội dung | Vì sao |
|---|---|---|
| **R-1g** | Mọi nội dung nói về người kia phải **kết thúc bằng một câu để đi hỏi người thật**, không được kết thúc bằng kết luận | Chặn đúng cơ chế hại đã được đo trong RS-E1 |
| **R-1h** | Cấm cứng phán quyết về **ý định và cảm xúc** của một người cụ thể (*"cô ấy đang thích bạn"*). Mẫu hình chung thì được | Bịa nội tâm ≠ mô tả mẫu hình |
| **R-1i** | Sổ tay ghi **sở thích và sự kiện** ✅; ghi **tần suất và hành vi** ❌ (*"hay trả lời chậm"*) | Ranh giới với R-1b, chống trượt thành nhật ký giám sát |
| **R-1e** | Luật ba tầng: **GHI** (user quan sát) ✅ · **ĐOÁN** (user đoán, app không xác nhận) ✅ · **SUY/CHẤM** (app khẳng định) — nay **mở có điều kiện** theo 1.1 | Đã duyệt ở D-10, nay hoà giải với D-9 |
| **R-1f** | Sổ tay **không bao giờ xuất được thành link/ảnh chia sẻ** | Dữ liệu về người thứ ba không được rời máy |
| **R-1b/c/d** | Giữ nguyên (cấm đo hành vi; lời mời luôn có cửa từ chối sạch; nội dung chỉ tự trào) | Đã duyệt ở D-6, D-7 |

**1.3 — Luật NỘI DUNG (tiêu chí duyệt, không phải văn phong):**

- **Mỗi ô bảng tra phải có ít nhất một điểm cọ xát**, không chỉ lời khen.
- Bài kiểm tra bắt buộc cho mọi màn nói về người kia: *"đọc xong, người dùng
  muốn hỏi người kia NHIỀU hơn hay ÍT hơn?"* Ít hơn → thiết kế sai, làm lại.

**1.4 — Luật 5 KHÔNG sửa. Làm rõ, không nới:**

"Không AI" là ràng buộc **runtime**. Sản phẩm xuất xưởng không gọi AI. AI được
dùng **ngoài sản phẩm ở khâu soạn nội dung**, mỗi dòng qua duyệt tay. Kho nội
dung là **tài sản dữ liệu có schema và version**, không phải tính năng sinh nội
dung. Cụ thể: chỉ số ăn khớp = **bảng tra tay 12×12 (144 ô) và 16×16 (256 ô)**
→ runtime tất định.

*Ghi chú kiến trúc quan trọng:* chính vì đi đường preset (D-4) mà việc mở R-1
mới an toàn. Nghiên cứu RS-E1 đo hiện tượng nịnh trên **mô hình thích nghi**;
**bảng tra tĩnh không nịnh được** vì nó không biết người dùng muốn nghe gì.

---

#### PHẦN 2 — ĐỀ XUẤT BỔ SUNG PHẠM VI (thứ tự bắt buộc, SB-174)

**TẦNG 0 — HÀNG RÀO (làm cùng lúc với mọi thứ; không vá được về sau)**

Cụm C8: hộp riêng tư mặc định, xoá được mọi thứ (XD4), tắt hồi tưởng, cửa từ
chối sạch, không xuất sổ tay/chân dung. Phần lớn là **luật và mặc định**, effort
thấp, nhưng nếu để sau thì phải làm lại kiến trúc lưu trữ.

**TẦNG 1 — BA NỀN MÓNG DỮ LIỆU (chặn mọi thứ phía sau)**

| | Nền móng | Tả cái gì | Chặn cái gì |
|---|---|---|---|
| **1a** | **SB-76 — thẻ hoạt động là đối tượng có cấu trúc** (giá VNĐ, thời lượng, khung giờ, mùa, số người, cần đặt trước, khoảng cách) → mở rộng **M2 shared-foundation** | *việc để làm* | C1, C2, C3, C5, C7 |
| **1b** | **SB-129 — SỔ TAY MỐI QUAN HỆ**: user tự ghi, riêng tư, xoá được; trường có cấu trúc (size, dị ứng, món ghét, chủ đề quan tâm, ngày quan trọng, "đã nói là thích", điều sợ) + ô "vừa nghe được" một chạm | *người kia* | quà, mồi chuyện, kịch bản hẹn, chân dung |
| **1c** | **SB-197 — HỒ SƠ KỸ NĂNG ("phiên bản tôi")**, nâng SB-13 từ tính năng lên hạ tầng. Onboarding hỏi kỹ năng theo **nghĩa rộng cố ý** — *"nhớ dai"*, *"biết chỗ ăn ngon"*, *"chữ đẹp"* đều tính | *người dùng* | toàn bộ nhánh quà handmade |

⚠️ **1c có rủi ro triển khai cao nhất trong cả bản nháp**: hỏi kỹ năng kiểu CV
thì ~80% người dùng trả lời *"không có"* và tầng 3 sập theo.

**TẦNG 2 — HẾT NHẠT (rẻ, chữa các chế độ thất bại đã biết)**

- **C1 — kho mồi 150-250 thẻ biên tập tay** (SB-01) + dải giá VNĐ thật (SB-61)
  + **gói nội dung tải về được, có version** (SB-122).
- **C2 — vòng đời thẻ**: ý tưởng → đã lên lịch → đã làm → kỷ niệm (SB-77/78).
  Đây là bản thay thế hợp lệ cho streak, chữa F4 *"không thấy kết quả gì"*.
- **C3 — nhập liệu không ma sát**: dán link ra thẻ (SB-06) + Share Sheet
  (SB-36). Hai món rẻ nhất trong toàn bộ 210 ứng viên; chữa F1 và F6.

**TẦNG 3 — HỮU DỤNG THẬT (đúng thứ user đòi ở vòng 5-6)**

- **3a. Ý tưởng quà (D-11)** — quà là một loại thẻ trong C1; chỉ mục theo **dịp
  Việt × giai đoạn quen nhau × sổ tay**; có nhánh "quà không tốn tiền"; nhắc
  sớm đủ để kịp. **Không thương mại, không link mua, không affiliate (SB-154).**
- **3b. Quà HANDMADE theo chuyên môn (D-11, nhánh mạnh nhất vòng 6)** —
  ma trận **kỹ năng × sổ tay** (guitar + "thích bài X" → thu cover; nấu ăn +
  "khen món Y" → làm lại ở nhà; chữ đẹp + câu đã nói → thiệp tay).
  **Chỉ mục theo SỐ GIỜ, không theo VNĐ (SB-196).** Mỗi ý tưởng là một **công
  thức từng bước** (tái dùng cấu trúc SB-17) + thời gian + độ khó. Bộ lọc quan
  trọng nhất: **"làm được trong 2 tiếng tối nay"**. Không kịp → đề xuất **bản
  đơn giản hơn của cùng ý tưởng**, không đề xuất đi mua. Có căn cứ nghiên cứu
  (RS-E2) và **nên nói thẳng cho người dùng** khi họ ngại *"tôi làm xấu lắm"*.
- **3c. Mồi chuyện — bản A + A+ (D-13)** — **A**: kho câu gợi chuyện thường xanh
  gắn thẻ chủ đề, ship như dữ liệu. **A+**: **"SỰ KIỆN CÓ LỊCH"** (phim ra rạp,
  trận đấu, lễ hội, triển lãm) — đã lên lịch nên ship được bằng gói dữ liệu theo
  mùa, **không bao giờ chứa tin xấu**, và **đổi thẳng thành thẻ hoạt động**.
  ❌ **Không** làm feed tin thật trong REQ-013.
- **3d. Kịch bản buổi hẹn 3 phần** (SB-163..167) — trước/trong/sau; đầu vào chỉ
  gồm ngân sách, thời lượng, thời tiết, mùa, giai đoạn quen nhau, sổ tay, dịp
  lịch âm; một kịch bản có ba cửa ra (lời mời / nhật ký / thẻ).
- **3e. Chân dung "theo cách BẠN nhìn"** (SB-186/188/190) — bảng câu hỏi user
  trả lời **thay** người kia; xuất xứ nằm trong bố cục; sửa được, xoá được,
  **không xuất chia sẻ**.
- **3f. Bảng tra ăn khớp** (SB-183/184/185, D-14) — đầu ra là **bộ bốn**:
  *chỗ dễ hợp · chỗ dễ va · 1 hoạt động nên thử · 1 câu để hỏi* (bắt buộc theo
  R-1g). **Hiển thị DẢI, không hiển thị %** — *"nhóm hay va nhau lúc đầu, hợp
  dần về sau"*, không phải *"82%"*.

⚠️ **Ràng buộc vị trí (SB-208):** 3e và 3f **không được nằm ở màn hình chính**.
Chúng vào từ một buổi hẹn hoặc một món quà. Nếu không, app trượt định vị từ
"trợ lý hoạt động" sang "app bói toán".

**TẦNG 4 — VỎ, NHỊP, GIỮ CHÂN (làm sau cùng)**

- **Lớp vỏ hoàng đạo + trắc nghiệm** (SB-136..143) — là **skin** phủ lên thẻ
  hoạt động, mỗi kết quả kết thúc bằng 3 thẻ hoạt động, không bằng nhận định.
- **Trò chơi "đoán" không thắng thua** (SB-144/145/146) — không điểm, không ai
  thắng; đầu ra là *"3 chỗ hai người nghĩ khác nhau"*; đáp án thật khoá tới chặng 2.
- **C5 — xuất lời mời**: render thẻ thành vật phẩm theo **khung nhại hành chính**
  (SB-103/106/107) + ô mad-libs (SB-104) + chọn giọng (SB-105). REQ-013 xuất ra
  **ảnh/thẻ trong app**; thiết kế theo **payload SB-125** để REQ-014 nối tiếp.
- **C7 — nhịp theo lịch Việt**: lịch âm × thư viện khung (SB-115), nối seed BD2.
- **Hai màn hình nhỏ lấp journey trống**: "đang đợi" (SB-83), "23h vừa về" (SB-85).
- **C4 — ký ức**: quyết định then chốt là SB-08 (ảnh là đơn vị lưu trữ).
- **SB-206** — kỹ năng cũng sinh **hoạt động**, không chỉ quà: *"dạy người ta thứ
  mình giỏi"* là một buổi hẹn hoàn chỉnh và miễn phí.

---

#### PHẦN 3 — GIỮ NGOÀI REQ-013

| Hạng mục | Đi đâu | Lý do |
|---|---|---|
| Toàn bộ **C6 / chặng 1.5** (link hai chiều, Zalo Mini App, vòng lan truyền do người nhận) | **REQ-014** | Cần hạ tầng web, lệch scope mobile-only; phục vụ J7/J12 vốn là địa hạt hai người |
| **Đối chiếu chân dung** (SB-189) — *"cậu đoán đúng mấy phần"* khi người kia vào app | **REQ-014** (móc thiết kế ở REQ-013) | **Phần thưởng chuyển chặng mạnh nhất sinh ra trong cả 7 vòng** |
| **Feed tin tức thật** (SB-159, bản B) | REQ-014 đánh giá lại | Hạ tầng runtime + rủi ro tin xấu chen vào + bản quyền + thua Facebook |
| Thương mại quà tặng | ❌ | `## Out of Scope` đã cấm; D-11 xác nhận |
| **Nấc 4 của thang R-1** (giám sát, thao túng) | ❌ **không bao giờ** | — |

**Ràng buộc bắt buộc để lại trong REQ-013:** vật phẩm lời mời phải thiết kế
thành **payload render được (SB-125)**, để REQ-014 nối tiếp mà không phải thiết
kế lại.

---

#### PHẦN 4 — RỦI RO VÀ CÂU HỎI MANG THEO

**Rủi ro Product Owner cần biết trước khi breakdown:**

1. **Chi phí biên tập nội dung là nút thắt số 1** — 144 + 256 ô bảng tra + 150-250
   thẻ mồi + kho mồi chuyện + sự kiện có lịch theo mùa + chỉ mục quà + công thức
   handmade. **AI soạn ngoài hệ thống lo được sản lượng, không lo được việc duyệt.**
2. **Hai giả thuyết trung tâm chưa kiểm chứng**: người dùng chịu **tự ghi sổ
   tay**, và chịu **tự khai kỹ năng**. Sai một trong hai thì tầng 3 sập về mức
   chung chung. Đề nghị kiểm chứng sớm bằng bản thử, trước khi làm tầng 4.
3. **Trần giữ chân của chặng 1 (RS-D6)** — động cơ giữ chân mạnh nhất của app
   cặp đôi là đồng sở hữu một không gian chung, và chặng 1 về bản chất không có
   nó. Đừng đặt kỳ vọng retention của app hai người lên REQ-013.
4. **Đồ ăn nhanh (SB-173)** — trắc nghiệm/hoàng đạo chán nhanh. Đừng đặt cược
   định vị vào tầng 4.

**Câu hỏi còn mở, KHÔNG chặn bàn giao:**

- **OQ-2** — một "ngăn" hay nhiều "ngăn". → quyết định thiết kế, đề nghị PO/UX
  chốt khi làm M2. Brainstormer không có căn cứ để chọn hộ.
- **OQ-3** — **ai biên tập và duyệt kho nội dung.** → đây là câu hỏi **nguồn
  lực**, không phải câu hỏi ý tưởng; chỉ user trả lời được. Nhưng nó quyết định
  tầng 2 và tầng 3 có làm nổi không.
- **OQ-7** — đường đi chặng 1.5 (điều kiện/chi phí/xác thực Zalo Mini App).
  → việc của REQ-014.


## Research Notes

Sự kiện có nguồn (tách khỏi suy luận):

- **RS-A1 — Chán app hẹn hò đã tới điểm tới hạn (2026).** Hơn 70% Gen Z báo
  cáo burnout với app hẹn hò; 48% Gen Z đã xoá hết app. Xu hướng dịch sang
  "hẹn hò có chủ đích": 72% phụ nữ Gen Z nói thích hẹn hò chậm/có chủ đích hơn
  văn hoá hookup. Nguồn: itsjustlunch.com, impressivemagazine.com,
  agapematch.com (2026).
  → Suy luận: khoảng trống không nằm ở "tìm người" mà ở "đã có người rồi thì
  làm gì tiếp" — đúng chỗ chặng 1 đứng.
- **RS-A2 — Việt Nam: Gen Z rời app hẹn hò truyền thống.** 74% người dùng app
  hẹn hò ở VN dùng để kết bạn, chỉ ~30% tìm quan hệ nghiêm túc; giới trẻ chuộng
  hẹn đơn giản (đi bộ, cà phê) hơn buổi hẹn dàn dựng; xu hướng "tình yêu nở rộ
  tự nhiên". Nguồn: tuoitre.vn, cafebiz.vn (2026).
  → Suy luận: nội dung chặng 1 nên nghiêng về hoạt động rẻ, ngắn, đời thường
  (SB-38, SB-61) hơn là buổi hẹn hoành tráng.
- **RS-A3 — Photobooth là điểm hẹn mới của giới trẻ Việt.** Được mô tả là "nơi
  hẹn hò mới", một nghi thức hẹn hò; ngành photobooth đang là ngành hot nhất
  VN; ảnh in ngay + khung trend là cốt lõi sức hút. Nguồn: phunuonline.com.vn /
  tuoitre.vn, cafef.vn, vietnamplus.vn.
  → Suy luận trực tiếp cho SB-60 và SB-08: đơn vị kỷ niệm ở nhóm tuổi này là
  ẢNH IN, không phải đoạn văn.
- **RS-A4 — Thị trường date-planning đã đông: 159 đối thủ.** Paired, Cupla
  (wishlist tự chia sẻ với bạn đời), Cobble (400k lượt vuốt tìm buổi hẹn),
  Connected (vuốt để chọn hoạt động chung), Lovewick (gợi ý theo ngân sách +
  vị trí), Fever (150k+ trải nghiệm), Amorno. Nguồn: tracxn.com,
  producthunt.com, cupla.app, connectedcouples.app, amorno.app (2026).
  → Suy luận: gần như toàn bộ nhóm này **yêu cầu đã có cặp**. Chế độ một người
  dùng được trọn vẹn là chỗ trống thật, không phải chỗ trống tưởng tượng.
- **RS-A5 — Cái gì giữ chân người dùng app nhật ký.** Prompt có cấu trúc làm
  tăng tính đều đặn (Reflectly, Grid Diary, Journey); "On This Day" của Day One
  là lý do được nhắc nhiều nhất khiến người dùng duy trì thói quen qua tháng
  đầu; streak/nhắc nhẹ là trục còn lại (Stoic, Daylio). Nguồn: nhiều bài so
  sánh 2026 (therma.one, reflection.app, journalit.app).
  → Suy luận quan trọng: **hai trong ba cơ chế giữ chân của ngành nhật ký va
  vào ràng buộc của mình** — streak bị R-1 cấm, và "On This Day" nguy hiểm với
  ngăn đã đóng (SB-65). Còn lại prompt có cấu trúc (SB-79) là con đường an
  toàn nhất, nên nó phải làm rất tốt.
- **RS-A6 — Vòng lan truyền dựa trên artifact.** Locket đi từ món quà tặng bạn
  gái lên 90 triệu lượt tải, 9 triệu DAU (10/2025) nhờ widget + chia sẻ riêng
  tư; Spotify Wrapped được thiết kế để chia sẻ trơn tru; BeReal cho thấy vòng
  lan truyền không kèm giữ chân sẽ xẹp (tải 2025 giảm 50% so với 2024). Nguồn:
  techcrunch.com, moloco.com, businessofapps.com, theupandup.us.
  → Suy luận: SB-26/SB-48/SB-49 là kênh tăng trưởng khả dĩ, nhưng phải đi kèm
  trục giữ chân (trục 2), nếu không sẽ lặp lại đường cong BeReal.
- **RS-A7 — Nỗi lo trước buổi hẹn là chuyện hậu cần nhiều hơn cảm xúc.**
  Khuyến nghị của giới chuyên môn: không nên để buổi hẹn đầu là bất ngờ, nên
  tham gia vào việc lên kế hoạch, biết trước địa điểm, biết trước sẽ gọi món
  gì, chừa dư thời gian di chuyển, chọn nơi công cộng, xác định trước ranh
  giới. Nguồn: bustle.com, lovehealgrow.com, thrivingcenterofpsych.com.
  → Suy luận: đây là **bằng chứng bên ngoài cho chính lưỡi dao R-1** — thứ
  giảm lo lắng thật sự là hậu cần, không phải phân tích người kia. Nó hậu
  thuẫn SB-22, SB-31, SB-32, SB-37.
- **RS-A8 — Google Maps saved lists đã là bucket list mặc định.** Danh sách
  "Want to go" có sẵn, chia sẻ được; các app như Pocket Places tăng trưởng bằng
  cách **nhập** danh sách Maps và lưu chỗ từ Instagram/TikTok. Nguồn:
  apps.apple.com, thenextweb.com, thenomadexperiment.com.
  → Suy luận: đối thủ thật của C1 không phải app couple nào cả, mà là Google
  Maps saved list. SB-27/SB-06 là chiến lược nhập nguồn, không phải tính năng
  phụ.

### Vòng 2 (2026-08-29)

- **RS-B1 — Ngành retention 2026 đã có sẵn giải pháp thay streak.** "Nhắc về một
  việc còn dở dang cho người dùng một lý do rõ ràng để quay lại" được nêu thẳng
  như lựa chọn thay thế cơ chế streak; Hook Model nhấn mạnh **pha đầu tư** (người
  dùng bỏ dữ liệu/công sức vào sản phẩm) mới là thứ giữ chân dài hạn; và cảnh báo
  rõ ràng: push và streak có thể huấn luyện người dùng tắt thông báo. Nguồn:
  strivecloud.io (Hook Model 2026), userpilot.com, uxpin.com.
  → Suy luận: N2 (việc dở dang) và N3 (của cải tích luỹ) là hai neo hợp pháp và
  được ngành xác nhận, dù R-1 cấm streak. Ràng buộc R-1 không làm mất khả năng
  giữ chân — nó chỉ loại bỏ con đường lười.
- **RS-B2 — Partiful: tiền lệ cho "một người cài, nhiều người chơi".** Chủ tiệc
  thả một link vào iMessage/Instagram/WhatsApp; khách **mở, RSVP, xem ai đi, nhận
  nhắc — không cài gì cả**. Đó là vòng tăng trưởng lõi của họ: mỗi lời mời đồng
  thời là một landing page nhẹ đi qua đúng kênh người ta vốn dùng để hẹn nhau; nó
  xoá bỏ ma sát vốn giết chết việc hẹn hò tự phát. Nguồn: sacra.com.
  → Suy luận: chặng 1.5 (L14) không phải ý tưởng đầu cơ — nó là mô hình đã chạy
  được ở đúng ngành liền kề (lên kế hoạch gặp nhau).
- **RS-B3 — Zalo Mini App là đường ống VN cho chặng 1.5.** Mini App chạy thẳng
  trong Zalo, **người dùng không cần cài thêm bất kỳ ứng dụng nào**, trên mạng
  lưới hơn **70 triệu người dùng Zalo tại Việt Nam**; trải nghiệm liền mạch, hợp
  thói quen người Việt. Nguồn: miniai.vn, pandaloyalty.com, addycare.vn (2026).
  → Suy luận: đây là thứ đối thủ date-planning phương Tây không thể sao chép —
  họ không có super-app nhắn tin phủ cả thị trường. **Nhưng** các nguồn đều nói
  về triển khai cho **doanh nghiệp** (cửa hàng, loyalty, đơn hàng) — chưa có bằng
  chứng cho sản phẩm C2C riêng tư như thế này, và có quy trình xác thực + chi
  phí. Ghi thành OQ-7, chưa coi là đã kiểm chứng.
- **RS-B4 — Lo lắng trước buổi hẹn được giải bằng hậu cần (nhắc lại RS-A7).** Đây
  là cơ sở bên ngoài cho SB-83 ("Đừng đoán — chuẩn bị") ở journey J4.

### Vòng 3 (2026-08-29)

- **RS-C1 — Hài hước là chiến thuật tán tỉnh hiệu quả nhất, và sự mập mờ là cơ
  chế bảo vệ thể diện.** Tán tỉnh được mô tả là việc đi trên ranh giới giữa thể
  hiện quan tâm và giữ **đường lui thể diện (plausible deniability)**; chính sự
  mập mờ cho phép người ta dám bày tỏ mà bớt sợ bị từ chối, bớt xấu hổ và bớt tổn
  thương lòng tự trọng. Một nghiên cứu trên *Evolutionary Psychology* ghi nhận
  hài hước là cách tán tỉnh hiệu quả nhất cho cả hai giới. **Nghịch lý kèm theo:**
  mập mờ bảo vệ lòng tự trọng nhưng *trực tiếp* mới truyền đạt được thông điệp.
  Nguồn: psychologytoday.com, theconversation.com, upworthy.com.
  → Suy luận: đây là cơ sở cho SB-102 "vỏ hài, ruột rõ" — khung gánh phần hài để
  hạ rủi ro, các nút gánh phần rõ để không mất thông điệp. Vật phẩm lời mời là
  cách duy nhất có được cả hai cùng lúc; tin nhắn chữ thuần thì phải chọn một.
- **RS-C2 — Partiful xác nhận thanh ghi thẩm mỹ.** Được mô tả là "câu trả lời của
  Gen Z cho Evite": miễn phí, nhanh, "Party Page" cho khách bình luận và RSVP một
  chạm, không khí **cố tình xô bồ và suồng sã, lời mời kiểu poster, thân thiện với
  meme**. Xu hướng thiệp điện tử 2026: RSVP tương tác, hiệu ứng, AR. Nguồn:
  news.syr.edu, blog.messagear.com, fotify.app.
  → Suy luận: thẩm mỹ "poster/meme + RSVP một chạm" đã được kiểm chứng ở Gen Z.
  Khoảng trống là bản **1-1, riêng tư, lãng mạn** — Partiful làm tiệc đông người.
- **RS-C3 — Phản ứng ngược với nội dung do AI viết trong bối cảnh hẹn hò (2026).**
  Phân tích 4.383 phiên thật cho thấy người dùng **loại bỏ 80% gợi ý AI trước khi
  gửi** và thực hiện 38.000+ lần chỉnh tone — họ dùng AI như công cụ nghĩ nháp,
  không phải để thay giọng mình. Xu hướng nghiêng về ấn tượng đầu **chân thật,
  không trau chuốt**: *"một câu mở đầu hoàn hảo báo hiệu rằng một người — hoặc một
  con bot — đã bỏ ra 0 giây để nghĩ về bạn."* Giới phân tích hành vi gọi đây là
  **"pha loãng tính chân thật"**; thị trường app hẹn hò đang co lại lần đầu tiên
  trong lịch sử trong khi mai mối cao cấp tăng ~10%/năm. Nguồn: smoothrizz.com,
  jaidadating.com, aibucket.io.
  → Suy luận: bằng chứng ngoài **ủng hộ luật không-AI của REQ-013**, chứ không
  chỉ chịu đựng nó. Nó cũng sinh ra SB-112 ("công sức chính là thông điệp") và
  SB-104 (mad-libs: chi tiết riêng phải do người dùng cung cấp thật).

### Vòng 4 (2026-08-29)

- Không chạy tìm kiếm web mới ở vòng 4. Hội tụ dựa trên RS-A1..RS-A8,
  RS-B1..RS-B4, RS-C1..RS-C3 đã ghi ở trên.
- Ghi chú diễn giải lại RS-C3 sau D-4: bằng chứng "người dùng loại bỏ 80% gợi ý
  AI trước khi gửi" **không phải lý lẽ chống AI nói chung**, mà là lý lẽ chống
  **AI ở khâu chạy**. AI ở khâu soạn kho nội dung, có người duyệt, không chạm
  vào cơ chế "pha loãng tính chân thật" mà nghiên cứu mô tả — vì thứ người dùng
  gửi đi vẫn là một vật phẩm **được chọn**, cộng chi tiết riêng do họ tự điền.
  D-4 đứng vững trước chính bằng chứng đã dùng để nghi ngờ nó.

### Vòng 5 (2026-08-29)

- **RS-D1 — App chiêm tinh (Co-Star, The Pattern).** Giữ chân bằng **tiện ích
  hằng ngày**: dự báo cá nhân hoá, nhắc theo nhịp, thông báo màn khoá. *"Hơn 55%
  người dùng app chiêm tinh tương tác hằng ngày."*
  → Suy luận: nội dung hằng ngày theo nhãn tự khai là **neo mở lại rẻ nhất**
  (SB-140), nhưng phải là nội dung tĩnh xoay vòng để giữ luật 5.
- **RS-D2 — Trào lưu "How well do you know me" (TikTok).** Sức hút nằm ở
  **khoảnh khắc bất ngờ cảm xúc** khi phát hiện người kia không biết/rất biết về
  mình. Không nằm ở điểm số.
  → Suy luận trực tiếp: bỏ điểm vẫn giữ nguyên phần hay (SB-145). W3 chết vì
  *dạng đấu nhau*, không phải vì chủ đề.
- **RS-D3 — Vì sao trắc nghiệm lan truyền.** *"Identity curiosity"* — nhu cầu
  hiểu **chính mình**; khi mô tả trúng thì kích hoạt vùng não liên quan tới
  tự-liên-hệ và phần thưởng, tạo cảm giác *"nó hiểu mình"*. Cái nhãn thành **huy
  hiệu để khoe** và là mồi hội thoại. MBTI đang **thay thế cung hoàng đạo** làm
  ngôn ngữ chung của Gen Z (Hàn Quốc từ 2020 là ca điển hình).
  → Suy luận: **phần hấp dẫn nằm ở BẢN THÂN, không ở việc phán xét người kia.**
  Đây là cơ sở ngoài cho SB-136/142 — lấy được gần hết sức hút mà không chạm R-1.
- **RS-D4 — Trào lưu cặp đôi 2025-2026.** "Fingers Down", "Tell me you love me
  without telling me", 3 khung *how it started / messy middle / how it's going*,
  14-Question Challenge. Nhận định văn hoá: *"người ta đang khao khát sự an
  toàn, dịu dàng, chỗ trú... nhịp bình thản của hai người chăm sóc nhau tạo cảm
  giác nhẹ nhõm."*
  → Suy luận (SB-170): **khảo sát trào lưu độc lập xác nhận khung "chăm sóc
  nhau" của REQ-013 và không xác nhận khung thi đấu/chấm điểm.** R-1 đang đứng
  cùng phía thị hiếu, không ngược lại.
- **RS-D5 — "Hết chuyện để nói".** Rãnh hội thoại sinh ra từ **vùng an toàn**;
  **trải nghiệm mới** mới là thứ tạo ra chuyện. Chuyên gia cảnh báo việc **đặt
  áp lực lên bạn đời phải giải trí cho mình**.
  → Suy luận: định khung lại (SB-160) — bán "thứ để cùng làm/cùng xem" thay vì
  "tin để nói". Và nó kéo tính năng này **quay về đúng C1**, không sinh sản phẩm mới.
- **RS-D6 — App Paired (nghiên cứu JMIR/PMC 2025).** Câu hỏi hằng ngày + chia sẻ
  câu trả lời giữa hai người; có tiềm năng cải thiện chất lượng quan hệ trong
  thời gian ngắn. Phân tích ngành: thứ làm app cặp đôi "dính" là **không gian số
  có cảm giác ĐỒNG SỞ HỮU**.
  → Suy luận trung thực (SB-174, cuối): **đồng sở hữu chính là thứ chặng 1 về
  bản chất không có.** Vòng 5 làm chặng 1 hữu dụng hơn nhiều nhưng không xoá
  được kết luận vòng 2 — trần giữ chân thật vẫn nằm ở REQ-014.


### Vòng 6 (2026-08-29)

- **RS-E1 — Nghiên cứu nền của R-1, tra được đầy đủ.** Stanford, *"Sycophantic
  AI decreases prosocial intentions and promotes dependence"*, đăng trên
  *Science*. Trên 11 mô hình, AI **hợp thức hoá hành vi người dùng nhiều hơn
  con người 49%**; với hành động có hại hoặc phi pháp, vẫn hợp thức hoá **47%**
  số lần. Thực nghiệm trên **2.400+ người**: **chỉ một lần** tương tác với AI
  nịnh đã làm người ta **tin mình đúng hơn**, **ít sẵn sàng xin lỗi và nhận
  trách nhiệm hơn** trong xung đột với người thân, và **giảm ý định hàn gắn**.
  Bối cảnh: gần 1/3 thiếu niên Mỹ tâm sự chuyện nghiêm túc với AI thay vì với
  người; gần một nửa người lớn dưới 30 đã hỏi AI lời khuyên tình cảm.
  → **Diễn giải cho vòng 6 (SB-177):** hại nằm ở *"làm người dùng chắc chắn hơn
  và tò mò ít đi"*, không phải ở *"nói về người kia"*. Cơ chế hẹp → chặn được
  bằng `R-1g` thay vì phải cấm cả tính năng. Và vì nghiên cứu nói về **mô hình
  thích nghi**, một **bảng tra tĩnh** không mang cơ chế đó (SB-180).
- **RS-E2 — "Effort heuristic" và quà tự làm.** Tâm lý học tiêu dùng: cùng một
  vật, người ta định giá cao hơn khi tin rằng nó tốn nhiều công hơn. Nghiên cứu
  đăng *Journal of Consumer Psychology* (2014): người nhận đánh giá quà tự làm
  **ý nghĩa hơn quà mua, kể cả khi món đó kém tinh xảo hơn**, vì họ suy ra mức
  độ quan tâm và tình cảm lớn hơn. Nhãn "handmade" làm tăng cảm nhận về sự độc
  nhất và sự ấm áp; **công sức cảm nhận được thắng giá thị trường**.
  → Đây là bằng chứng ngoài cho **SB-112 vòng 3** ("công sức chính là thông
  điệp") và là nền cho **SB-196** (thang công sức thay thang giá tiền) và
  **SB-204** (nói thẳng phát hiện này cho người dùng khi họ ngại "tôi làm xấu").

## Session Log

- 2026-08-29: Tạo ý tưởng từ seed của user và chạy ngay một vòng phân kỳ
  `Ideate For Me`. 10 lens, 82 ứng viên + 8 chẩn đoán thất bại. Dùng nghiên
  cứu web (8 truy vấn, RS-A1..RS-A8). Không probe live-site. Không hội tụ (cố
  ý). Files: `idea.md`, `development.md`, `brainstormer-checkpoint.md`,
  registry. Next: Affinity Clustering + Impact/Effort khi user yêu cầu chốt.
- 2026-08-29 (vòng 2): User chốt D-1 (không phục vụ nhóm "chưa có ai"; phải đã
  có "mối", đối phương chưa cài app), D-2 (nhập vào REQ-013), và hỏi lại OQ-2.
  Chạy vòng phân kỳ thứ hai tập trung vào JOURNEY và GIỮ CHÂN theo yêu cầu "chưa
  có gì giữ chân để tới chặng 2". Thêm lens L11-L16: định khung app là hậu
  trường, bản đồ 13 journey (10/13 đang trống), 7 neo mở lại thay streak, chặng
  1.5 "một người cài hai người chơi", thang mời 5 nấc, và lấp đầy journey trống.
  Thêm SB-83..SB-100 (tổng 100). Nghiên cứu web vòng 2: RS-B1..RS-B4 (Hook Model
  2026, Partiful, Zalo Mini App). Không probe live-site. Không hội tụ (cố ý).
  Sinh 3 câu hỏi mở mới: OQ-6 (luật R-1b), OQ-7 (đường đi chặng 1.5), OQ-8
  (chặng 1.5 thuộc REQ-013 hay REQ-014).
- 2026-08-29 (vòng 3): User đề xuất app giữ vai **người soạn lịch (options) +
  người soạn nội dung** để lời mời trở nên lãng mạn/hài hước. Stance đổi sang
  `Creative Partner`. Thêm lens L17-L23: cơ chế hài hước = bảo hiểm rủi ro cho
  lời đề nghị và nguyên tắc "vỏ hài ruột rõ"; vì sao đường preset có thể tốt hơn
  đường AI; thư viện 12 khung nhại (hài từ ĐỊNH DẠNG chứ không từ CÂU CHỮ); vòng
  lan truyền do người nhận chạy; mở rộng nội dung ra 7 khoảnh khắc + cỗ máy lịch
  âm × khung (lấp J10); ba luật đạo đức mới; và phản biện trung thực về tần suất
  thấp. Thêm SB-101..SB-120 (tổng 120). Nghiên cứu web vòng 3: RS-C1..RS-C3.
  Không probe live-site. Không hội tụ. **Phát hiện một xung đột cứng chặn hội tụ:
  OQ-9 (soạn content vs luật không-AI của REQ-013 vs D-2).** Sinh thêm OQ-10
  (định vị "xưởng làm lời mời") và OQ-11 (luật R-1c + tự trào).

- 2026-08-29 (vòng 4) — user chốt hai câu chặn hội tụ: **D-4** đi đường preset,
  với lý do AI có thể dùng ngoài hệ thống để sinh preset; **D-5** lời mời là
  tính năng, không phải câu tiêu đề. D-4 gỡ xung đột OQ-9 mà không phá D-2 và
  không phải sửa luật 5. D-5 giữ cho sản phẩm qua được cổng cứng của chính
  REQ-013. Thêm SB-121..SB-125 (tổng 125), lens L24. **Chạy hội tụ**: Affinity
  Clustering 125 → 10 cụm, Impact/Effort → 4 đợt, kiểm tra chéo bằng lưới
  journey. Sinh bản nháp đề xuất sửa REQ-013. Trạng thái phát triển: **EXPANDED**.
  Kiến nghị định tuyến: user chuyển bản nháp cho `scrum-master`.

- 2026-08-29 (vòng 5) — user duyệt R-1b/R-1c/R-1d và chốt chặng 1.5 → REQ-014
  (**D-6, D-7, D-8**), rồi yêu cầu mở rộng tính năng cho người đang yêu: quà,
  tính cách đối phương, chỉ số ăn khớp, hoàng đạo, trắc nghiệm, trò chơi tâm lý,
  trào lưu hai người, tin theo chủ đề, trợ lý kịch bản buổi hẹn.
  **Báo cáo va chạm (L25)**: "chỉ số ăn khớp" và "app suy luận tính cách đối
  phương" đã bị loại ở cycle 4 (N1-N7, *"vi phạm R-1 theo định nghĩa"*) và cycle
  5 (W3, *"dạng đấu nhau"*), và R-1 có hậu thuẫn thực nghiệm.
  **Lời giải (L26)**: luật ba tầng GHI / ĐOÁN / SUY-CHẤM, lấy ~90% giá trị cảm
  nhận mà không chạm phần bị cấm; lập luận SB-128 cho thấy tầng 2 còn là sản
  phẩm tốt hơn tầng 3. **Phát hiện lớn nhất (L27)**: sổ tay mối quan hệ là lớp
  dữ liệu còn thiếu khiến mọi gợi ý bị chung chung. Thêm SB-126..SB-174 (tổng
  **174**), lens L25-L34, nghiên cứu RS-D1..RS-D6, bảng chuyển hoá trào lưu, và
  phần bổ sung vòng 5 cho bản nháp REQ-013. Mở OQ-12..OQ-15.


### 2026-08-29 — Vòng 6 (Creative Partner)

- User chốt 4 việc: **mở R-1** (D-9); **duyệt `R-1e`/`R-1f`** (D-10); **yêu cầu
  giải thích OQ-14**; **quà chỉ là ý tưởng, mở thêm handmade theo chuyên môn** (D-11).
- Phản hồi ngay giới hạn quyền: brainstormer không sửa được `Invariant Design
  Rules`; D-9 được ghi như **chỉ thị chờ Product Owner thi hành**, và bản nháp
  từ nay tách làm **phần sửa luật** + **phần bổ sung phạm vi**.
- Tra được **RS-E1** (nghiên cứu nịnh của Stanford trên *Science*) — chính là
  "H-R1" mà `req_master.md` viện dẫn — và đọc lại cơ chế hại cho hẹp hơn, từ đó
  đề xuất `R-1g` (kết bằng câu hỏi, không kết bằng kết luận) làm hàng rào thay thế.
- Phát hiện kiến trúc: **D-4 (AI ở khâu soạn) làm cho D-9 an toàn hơn hẳn** —
  bảng tra tĩnh không nịnh được, và bảng tra 144/256 ô giữ **luật 5 nguyên vẹn**.
- 8 lens mới (L35-L42), SB-175..SB-210 → **210 ứng viên**.
- Ba xung đột được nêu thẳng thay vì bỏ qua: D-9 vs D-10, D-9 vs `R-1b`, và
  D-9 vs định vị D-5 → sinh OQ-16 và ràng buộc vị trí SB-208.
- Nhánh mạnh nhất vòng 6: **ma trận kỹ năng × sổ tay** và **thang công sức**,
  cả hai có hậu thuẫn nghiên cứu (RS-E2) và cả hai đều miễn phí với người dùng.
- Trạng thái: hội tụ cục bộ; **OQ-16 chặn bản nháp cuối**.

### 2026-08-29 — Vòng 7 (Creative Partner, đóng gói)

- User chốt *"theo đề xuất của bạn"* → **D-12 nấc 3**, **D-13 bản A + A+**,
  **D-14 hiển thị dải**. Ba câu hỏi chặn cuối cùng đã đóng.
- Việc chính của vòng 7 **không phải nghĩ thêm ý tưởng** mà là **gộp**: bản nháp
  đang nằm rải ở ba khối "bổ sung vòng 4/5/6", đưa cho Product Owner như vậy thì
  vụn và mâu thuẫn nội bộ (vòng 5 cấm cái vòng 6 mở).
- Sinh `### ★ BẢN BÀN GIAO CUỐI (v7)`: PHẦN 0 tóm tắt · PHẦN 1 sửa luật ·
  PHẦN 2 phạm vi xếp **5 tầng theo thứ tự bắt buộc SB-174** · PHẦN 3 giữ ngoài ·
  PHẦN 4 rủi ro và câu hỏi mang theo. Ba khối cũ hạ xuống thành lịch sử suy luận.
- Đóng góp thật sự của việc gộp: lộ ra **ba nền móng dữ liệu song song** (thẻ có
  cấu trúc / sổ tay / hồ sơ kỹ năng) mà 6 vòng trước chỉ nhìn thấy từng cái một.
- Phân biệt rõ trong PHẦN 4: **OQ-3 không chặn bàn giao nhưng chặn thực thi** —
  và nó là câu hỏi nguồn lực, không phải câu hỏi ý tưởng, nên brainstormer
  không có thẩm quyền đề xuất.
- Trạng thái: **HỘI TỤ, ĐÓNG GÓI, SẴN SÀNG BÀN GIAO.** Không còn blocker.

### 2026-09-03 — Vòng 8 (Creative Partner, mở lại idea)

- **Kích hoạt:** user bác tư cách EXPANDED — *"chưa chín, chỉ đang có bản nghiên
  cứu"*; thiếu tính năng thực tế, user journey thật, vòng đời user, màn hình và
  ràng buộc màn hình; *"quá rời rạc để có thể biến thành app thực tế"*.
- **Không dùng web research.** Vòng này là kiểm toán nội bộ trên chính artifact:
  đối chiếu L12/L16 (vòng 2) với `## Convergence Notes` và `## Current Snapshot`.
- **Kỹ thuật:** Assumption Smash (trên chính bản v7) + Problem Reversal ("nếu
  đây là app rời rạc thì cái gì đang thiếu ở giữa") — không sinh ứng viên mới.
- **Kết quả:** L43 (đếm được: 1 ràng buộc màn hình, và là ràng buộc phủ định;
  0 màn hình gốc; 0 vòng đời user) · L44 (lưới journey trôi số hiệu ⇒ bằng chứng
  ranh giới REQ-013/REQ-014 hỏng) · L45 (mâu thuẫn N7 vs D-8 bị bỏ quên 5 vòng)
  · L46 (bài toán ngày 1: ba hộp rỗng, ba rủi ro nhân nhau) · **L47 xương sống
  bị xếp nhầm chỗ — phát hiện chính** · L48 (SC-1..SC-5).
- **Không sinh ứng viên mới.** Tổng ứng viên giữ nguyên ~210. Đây là vòng **đổi
  trục tổ chức**, không phải vòng divergence.
- **Files updated:** `development.md`, `idea.md`, `brainstormer-checkpoint.md`,
  `data/brainstorms/master_ideas_list.md`.
- **Next action:** chờ user trả lời **OQ-18 / OQ-19 / OQ-20**, rồi chạy vòng 9
  (chuyển hoá sang journey + vòng đời + bản đồ màn hình).

### 2026-09-03 (vòng 8) · D5 · User chốt OQ-18

**OQ-18 CHỐT: chặng 1 là KHO TÀI SẢN**, không phải phòng chờ.

Hệ quả trực tiếp:
- Chặng 1 **không cần** một vòng lặp xã hội tối thiểu nào để tự đứng vững. Nó
  không chờ ai trả lời gì cả — nó là nơi một người **tích luỹ** (ý tưởng, kỷ
  niệm, hiểu biết về người kia, hiểu biết về chính mình).
- Trần giữ chân RS-D6 được **chấp nhận có ý thức**, không phải bug: chặng 1
  không cạnh tranh retention kiểu app hai người, nó cạnh tranh kiểu "sổ tay/kho
  lưu trữ cá nhân" (Notion, Pinterest, nhật ký) — quay lại vì **của cải đang
  lớn dần** (N3), không vì có người đang chờ trả lời (N7).
- Màn hình gốc phải trả lời được câu: *"tài sản của tôi đang ở đâu, đã lớn tới
  đâu"* — không phải *"có gì mới từ người kia không"*.
- L45 được giải: mâu thuẫn *"không N7 thì chỉ là phòng chờ"* tự hết là mâu
  thuẫn, vì user xác nhận chặng 1 **được phép** là phòng chờ... không, là kho —
  nó không cần thoát khỏi thân phận một-người để có giá trị.

Còn mở: OQ-19 (màn hình gốc có phải LÀ danh sách thẻ không) và OQ-20 (sổ tay/kỹ
năng có màn riêng hay hỏi tại chỗ) — user báo cách hỏi vòng trước **khó hiểu**,
hỏi lại bằng ví dụ cụ thể ở lượt hội thoại, chưa ghi quyết định.

### 2026-09-03 (vòng 8) · D6 · User chốt OQ-19 và OQ-20

**OQ-19 CHỐT: phương án A** — nhiều trang riêng (ý tưởng hoạt động, sổ tay, gợi
ý quà, mồi chuyện, trắc nghiệm hoàng đạo mỗi thứ một trang), **KHÔNG** dồn hết
vào một danh sách thẻ duy nhất làm màn hình gốc.

⚠️ **Đây là quyết định NGƯỢC với đề xuất SC-1 của brainstormer** (đề xuất ở L47/
L48 là gộp thành một màn hình gốc = danh sách thẻ). User có toàn quyền bác đề
xuất; ghi lại trung thực, không tự ý đổi hướng ngầm.

**Hệ quả cần làm rõ tiếp (chưa chốt):** SC-2 giả định "máy sinh nội dung không
phải điểm đến, ra bằng một thẻ vào một danh sách chung" — giả định đó **đứng
được hay đổ theo OQ-19: A** phụ thuộc vào một câu hỏi con chưa hỏi: khi lưu một
ý tưởng quà/mồi chuyện, nó có **gom về chung một danh sách việc-cần-làm** dùng
xuyên các trang (A1), hay **mỗi trang giữ danh sách riêng của nó, không trộn**
(A2)? Đã hỏi lại user ở turn tiếp theo, chưa có câu trả lời tại thời điểm ghi.

**OQ-20 CHỐT: phương án B** — sổ tay và hồ sơ kỹ năng **không có trang riêng để
điền trước**; hỏi lắt nhắt, tại chỗ, đúng lúc một tính năng khác cần một trường
dữ liệu nó chưa có (ví dụ bấm "gợi ý quà tự làm" → hỏi ngay "người yêu thích màu
gì" → dùng luôn → tự lưu vào sổ tay cho lần sau).

→ **B khớp với SC-3** (đề xuất gốc của brainstormer) — không có xung đột, không
cần sửa SC-3. Đây là lời giải giữ nguyên cho bài toán "ngày 1 = ba hộp rỗng"
(L46): sổ tay và hồ sơ kỹ năng được đổ đầy **dần theo nhu cầu thật**, không đổ
đầy trước bằng form.

**Trạng thái OQ-19/OQ-20 trong Open Threads:** OQ-20 ĐÓNG. OQ-19 ĐÓNG PHẦN
CHÍNH (đa trang, không màn hình gốc duy nhất) nhưng còn **OQ-19b** (A1 vs A2 —
danh sách có gom chung hay tách riêng theo từng trang) làm rõ trước khi vẽ
bản đồ màn hình ở vòng 9.

### 2026-09-03 (vòng 9) · D7 · OQ-19b chốt + ba quyết định thu về một hình

**OQ-19b CHỐT: A1** — nhiều trang riêng, nhưng khi lưu một ý tưởng ở bất kỳ
trang nào, nó gom về **chung một danh sách việc-cần-làm**.

Ba quyết định (OQ-18 kho · OQ-19 đa trang · OQ-19b gom chung · OQ-20 hỏi tại
chỗ) khớp lại thành đúng một hình kiến trúc, không mâu thuẫn nhau:

> **Nhiều CỬA VÀO (trang tính năng riêng), một KHO CHUNG (danh sách việc-cần-
> làm), dữ liệu phụ trợ (sổ tay, kỹ năng) không có cửa riêng — chỉ lộ ra khi một
> cửa vào khác cần nó.**

### 2026-09-03 (vòng 9) · S1 · Lưới journey dựng lại — bản chuẩn duy nhất

Dùng lại nguyên văn 13 journey của **L12 (vòng 2)** — đây là định nghĩa GỐC,
KHÔNG dùng bộ số đã trôi nghĩa trong "Kiểm tra độ phủ" cũ (mục đó nay coi như
SAI, giữ lại trong file chỉ để làm bằng chứng cho L44, không dùng làm căn cứ).

Chấm lại độ phủ, dùng đúng nghĩa gốc, đối chiếu với nội dung PHẦN 2 (v7):

| # | Journey (nghĩa GỐC, L12) | Phủ bởi v7? | Bằng gì |
|---|---|---|---|
| J1 | Bắt ý tưởng | ✅ | C1 kho mồi, C3 dán link, 3a/3b quà, C7 lịch âm, vỏ hoàng đạo |
| J2 | Chọn việc để rủ | ✅ | đã có (C1 danh sách) |
| J3 | Rủ (rời app sang Zalo) | ✅ | C5 xuất lời mời, 3c mồi chuyện (nội dung để rủ) |
| J4 | Đợi trả lời | ✅ | SB-83 "đừng đoán — chuẩn bị", SB-84 widget theo pha |
| J5 | Đã hẹn được → chuẩn bị | ✅ | SB-84 widget, 3d kịch bản hẹn phần "trước", SB-86 đếm ngược |
| **J6** | **Ngày hẹn, trước giờ đi** (tiền mặt, xăng, áo mưa, chia sẻ vị trí) | ❌ **VẪN TRỐNG** | không có hạng mục nào trong v7 nói tới hậu cần phút chót |
| **J7** | **Trong buổi hẹn** | ⚠️ **CỐ Ý ĐỂ TRỐNG** | app nên rời khỏi tay lúc này; 3d kịch bản chỉ chuẩn bị TRƯỚC, không chạy TRONG lúc hẹn |
| J8 | 23h, vừa về tới nhà | ✅ | SB-85, C6 nhật ký, C4 ký ức |
| **J9** | **Sáng hôm sau** (gửi ảnh, cảm ơn, chốt việc kế) | ⚠️ **MỎNG** | C2 vòng đời thẻ (đã làm→kỷ niệm) chạm nhẹ, không có touchpoint riêng |
| J10 | Khoảng lặng giữa hai lần hẹn | ✅ | SB-87, SB-99, sổ tay/kỹ năng hỏi tại chỗ, mồi chuyện A/A+ |
| J11 | Im lặng kéo dài / bị từ chối | ✅ | SB-64, SB-65, giữ SB-18/SB-13 |
| J12 | Cột mốc → mời chặng 2 | ➡️ **CẮT CÓ CHỦ ĐÍCH sang REQ-014** (D-8) | không phải lỗ hổng — là ranh giới đã quyết |
| J13 | Quay lại sau 3 tháng vắng | ✅ | SB-100 |

**Kết luận đã sửa (thay cho kết luận sai ở "Kiểm tra độ phủ bằng lưới journey"
cũ):** REQ-013 phủ chắc **10/13** journey. **J12 cắt có chủ đích** (đúng, không
đổi). **J7 nên cố ý để trống** (triết lý: app phục vụ trước/sau buổi hẹn, không
xen vào lúc đang hẹn — nhất quán với "trợ lý hoạt động" chứ không phải "app đi
cùng bạn khắp nơi"). **J6 và J9 là hai lỗ hổng thật, chưa từng được v7 nhắc tới
** — ứng viên cho vòng brainstorm bổ sung nếu user muốn, KHÔNG bắt buộc để bàn
giao (rẻ, không chặn kiến trúc).

### 2026-09-03 (vòng 9) · S2 · Vòng đời user theo thời gian thật

- **Phút 1 (mở app lần đầu):** hạ cánh ở **Danh sách việc-cần-làm**, trống.
  KHÔNG có form dài (OQ-20:B). Lời mời đầu tiên: "dán 1 link em vừa thấy" hoặc
  "để app gợi ý 1 việc theo dịp gần nhất" — chọn 1, có ngay 1-2 thẻ trong 60
  giây. Không hỏi sổ tay, không hỏi kỹ năng ở bước này.
- **Ngày 1 (cùng ngày, sau khi có vài thẻ):** người dùng thử một cửa vào khác —
  ví dụ "Gợi ý quà". App hỏi tại chỗ đúng 1 câu nó còn thiếu ("thích màu gì?"),
  không hỏi cả bộ. Câu trả lời tự rơi vào sổ tay, không hiện "đã lưu vào sổ tay"
  ồn ào — người dùng không cảm thấy đang "khai hồ sơ".
- **Ngày 7:** một thẻ đã rủ thật ngoài đời (J3, qua Zalo), sang trạng thái "Đã
  hẹn ngày". Widget SB-84 đổi nội dung theo pha (đang đợi/sắp hẹn). J6 hiện
  chưa có gì hỗ trợ (lỗ hổng ghi ở S1) — người dùng tự lo hậu cần.
- **Ngày 30:** vài thẻ đã sang "Đã thành kỷ niệm"; Danh sách hiện bộ đếm "của
  cải đang lớn" (N3: "12 chỗ → 15 chỗ"). Sổ tay và hồ sơ kỹ năng đã có vài chục
  trường nhờ tích luỹ tại chỗ, KHÔNG nhờ một lần điền form. Có thể chạm J12
  (cột mốc) — REQ-013 dừng ở chỗ **nhận ra** cột mốc và giữ payload (SB-125),
  không tự thực hiện lời mời cài app (đó là REQ-014).
- **Lối ra (J11 — im lặng kéo dài/bị từ chối):** một thao tác "đóng ngăn gọn
  gàng" (SB-64), tắt hồi tưởng (SB-65). Sổ tay + hồ sơ kỹ năng + danh sách địa
  điểm KHÔNG gắn với một người cụ thể vẫn giữ nguyên cho lần sau.
- **Lối quay lại (J13 — sau 3 tháng vắng):** màn hình không trách móc (SB-100),
  hỏi "mở lại từ đâu", có nút xoá sạch một thao tác ngay tại đó (XD4).

### 2026-09-03 (vòng 9) · S3 · Bản đồ màn hình (theo OQ-19:A + 19b:A1 + OQ-20:B)

**11 màn hình**, chia ba loại theo vai trò — đây là chỗ khác với đề xuất SC-1 cũ
(brainstormer đề xuất 1 màn gốc, user chọn đa trang; bản đồ dưới đây tôn trọng
lựa chọn của user):

**Nhóm KHO (trưng bày, có thể vào trực tiếp từ menu/tab):**

1. **Danh sách việc-cần-làm** — màn "về nhà" tự nhiên nhất (không bắt buộc là
   tab đầu tiên duy nhất). Lọc theo 4 trạng thái: Mới nghĩ ra / Đã hẹn ngày /
   Đã đi rồi / Đã thành kỷ niệm. **Nhận thẻ từ mọi cửa vào khác (A1).**
2. **Sổ tay người yêu** — CHỈ XEM/SỬA những gì đã tự động thu thập; có nút
   "+ tự thêm" cho ai chủ động muốn điền. KHÔNG phải nơi onboarding.
3. **Hồ sơ kỹ năng "phiên bản tôi"** — cùng khuôn mẫu với (2).
4. **Nhật ký riêng (C6)** — độc lập, riêng tư mặc định, xoá được (XD4).

**Nhóm CỬA VÀO (mỗi trang một tính năng, TỰ CÓ đường vào từ menu — đúng lựa
chọn OQ-19:A; ĐẦU RA của mỗi trang là một thẻ, đẩy vào (1) theo A1):**

5. **Gợi ý quà** (3a/3b) — hỏi tại chỗ field còn thiếu từ sổ tay/kỹ năng; lọc
   theo số giờ (SB-196), có nhánh "làm được tối nay".
6. **Mồi chuyện** (3c) — bản A dùng ngay tại chỗ (không thành thẻ); bản A+
   "sự kiện có lịch" đổi thẳng thành thẻ.
7. **Vỏ hoàng đạo / trắc nghiệm** (Tầng 4) — kết quả luôn kết thúc bằng 3 thẻ
   hoạt động được đề xuất thêm vào (1), không bằng một nhận định đứng một mình.

**Nhóm KHOÁ VỊ TRÍ (SB-208 — cấm truy cập từ màn hình chính/menu chính; chỉ vào
được từ một luồng hẹn/quà đang chạy):**

8. **Chân dung "theo cách BẠN nhìn"** (3e) — vào từ (5) hoặc (9), không từ menu.
9. **Kịch bản buổi hẹn 3 phần** (3d) — vào từ một thẻ ở trạng thái "Đã hẹn
   ngày" trong (1); 3 cửa ra: lời mời (→ 11) / thẻ mới (→1) / nhật ký (→4).
10. **Bảng tra ăn khớp** (3f) — vào từ (5) hoặc (9), không từ menu. Đầu ra bắt
    buộc bộ bốn kèm **một câu để hỏi** (R-1g), không phải một con số.

**Hành động, không phải màn hình riêng:**

11. **Xuất lời mời** (C5) — bottom sheet/share action gắn trên một thẻ ở (1)
    hoặc ra từ (9); không chiếm một destination riêng trong điều hướng.

**Ràng buộc màn hình tổng hợp (SC-1..SC-5 được VIẾT LẠI cho khớp quyết định đa
trang, không còn đòi một màn gốc duy nhất):**

- **SC-1'** (sửa SC-1 cũ) — có nhiều cửa vào, nhưng **chỉ một kho**: mọi thẻ
  sinh ra ở bất kỳ đâu đều nằm trong (1). Không có "danh sách quà riêng" hay
  "danh sách mồi chuyện riêng" cạnh tranh với (1).
- **SC-2** (giữ nguyên) — (5),(6),(7),(8),(9),(10) không phải điểm dừng chân;
  đều có một hành động rõ ràng đẩy kết quả sang (1) hoặc (4) hoặc (11).
- **SC-3** (giữ nguyên, khớp OQ-20:B) — (2) và (3) không có luồng "điền trước";
  chỉ điền qua việc dùng (5)/(6)/(7)/(9)/(10).
- **SC-4** (giữ nguyên) — mỗi thẻ ở mỗi trạng thái trong (1) có đúng một hành
  động chính: Mới nghĩ ra → "hẹn ngày"; Đã hẹn ngày → "chuẩn bị"/"xuất lời mời";
  Đã đi rồi → "ghi lại"; Đã thành kỷ niệm → "xem lại".
- **SC-5** (giữ nguyên) — J11 không phải ngõ cụt: đóng ngăn gọn gàng tại (1),
  giữ nguyên (2)/(3) cho lần sau.
- **SC-6 (mới)** — (8) và (10) **không bao giờ xuất hiện trong menu chính hay
  tab bar**; chỉ tới được bằng một liên kết trong luồng (5)/(9). Đây là cách
  thực thi SB-208 ở tầng điều hướng, không chỉ ở tầng nội dung.

### 2026-09-03 (vòng 9) · S4 · Gán ngược 20 hạng mục v7 vào bản đồ màn hình

| Hạng mục v7 | Màn hình (S3) |
|---|---|
| 1a SB-76 thẻ có cấu trúc | mô hình dữ liệu của (1) |
| 1b SB-129 sổ tay | (2) |
| 1c SB-197 hồ sơ kỹ năng | (3) |
| C1 kho mồi + dải giá | nguồn nội dung tĩnh cấp cho (1)/(5) |
| C2 vòng đời thẻ | trạng thái của (1) — KHÔNG phải màn riêng (theo OQ-19:A) |
| C3 nhập liệu không ma sát | hành động "+" trong (1) |
| 3a/3b quà + quà handmade | (5) |
| 3c mồi chuyện A/A+ | (6) |
| 3d kịch bản buổi hẹn | (9) |
| 3e chân dung | (8) |
| 3f bảng tra ăn khớp | (10) |
| Tầng 4 vỏ hoàng đạo/trắc nghiệm | (7) |
| Trò chơi "đoán" không thắng thua | phụ trong (7) hoặc (6), chưa có màn riêng — mở ở vòng sau nếu cần |
| C5 xuất lời mời | (11) |
| C7 lịch âm × khung | nguồn cấp dịp cho (1)/(5)/(6) |
| SB-83/SB-84/SB-85 | trạng thái/widget của (1), không phải màn riêng |
| C4 ký ức / ảnh | thuộc tính của thẻ "Đã thành kỷ niệm" trong (1), liên kết (4) |
| SB-206 kỹ năng sinh hoạt động | nhánh trong (5) |
| C6 nhật ký | (4) |
| SB-100 màn quay lại | trạng thái đặc biệt của (1) khi mở lại sau vắng mặt (J13) |

**Không hạng mục nào rơi ra ngoài bản đồ 11 màn hình.** L47 (xương sống bị xếp
nhầm chỗ) vẫn đúng về bản chất dữ liệu; vòng 9 chỉ đổi nó từ "một màn hình gốc"
sang "một kho chung được nuôi bởi nhiều cửa vào" — tôn trọng lựa chọn đa trang
của user mà không đánh mất tính không-rời-rạc.

### 2026-09-03 (vòng 9) · Còn lại (không chặn, brainstorm coi như xong phần cấu trúc)

- **J6 và J9** (S1) là hai lỗ hổng thật, có thể brainstorm thêm nếu user muốn,
  KHÔNG bắt buộc trước khi bàn giao.
- **OQ-2** (một ngăn hay nhiều ngăn) — nay có thể **coi như đã trả lời một phần**
  bởi S3: mỗi trạng thái trong (1) là một "ngăn" lọc, không phải một trang riêng.
  Còn phần UI chi tiết (tab con hay bộ lọc) vẫn để PO/UX chốt.
- **OQ-3** (ai biên tập kho nội dung) — vẫn treo, câu hỏi nguồn lực, chỉ user
  trả lời được.
- **Trò chơi "đoán" (SB-144/145/146)** chưa có màn hình gán — nêu ở S4, không
  chặn.

### 2026-09-03 — Vòng 9 (Creative Partner, chuyển hoá)

- **Kích hoạt:** ba câu trả lời của user (OQ-18=kho, OQ-19=A, OQ-19b=A1,
  OQ-20=B) đủ để chuyển bản nghiên cứu v7 thành hình dạng sản phẩm.
- **Không dùng web research.** Kỹ thuật: tổng hợp cấu trúc (dựng lại lưới
  journey theo nghĩa gốc L12, đối chiếu lại với PHẦN 2 v7, gán ngược 20 hạng
  mục vào 11 màn hình suy ra từ 4 quyết định của user).
- **Không sinh ứng viên ý tưởng mới** — đây là vòng dựng cấu trúc, không phải
  divergence. Có phát hiện mới: J6 và J9 là hai lỗ hổng thật (S1), do đối
  chiếu lại đúng nghĩa journey mà lộ ra.
- **Kết quả:** S1 (lưới journey chuẩn, sửa lỗi L44) · S2 (vòng đời user theo
  thời gian) · S3 (bản đồ 11 màn hình + SC-1'..SC-6) · S4 (gán ngược 20/20
  hạng mục, không rơi mục nào).
- **Files updated:** `development.md`, `idea.md`, `brainstormer-checkpoint.md`.
- **Next action:** trình bản đồ cho user duyệt. Chờ xác nhận trước khi đổi
  `Development Status` sang `EXPANDED`.

### 2026-09-03 (vòng 10) · S5 · Phủ hai lỗ hổng J6 và J9

Nguyên tắc thiết kế: **không thêm màn hình mới, không thêm hạ tầng mới**. Cả
hai đều là phần mở rộng của thẻ trong màn (1), tái dùng cỗ máy render đã có
(C5/SB-125), tuân thủ R-1/R-1c/D-1 nguyên vẹn.

**SB-211 — "Trước giờ đi" (phủ J6).** Một khối mở rộng tự động hiện trên chi
tiết thẻ khi thẻ ở trạng thái **Đã hẹn ngày** và ngày hẹn = hôm nay (phản chiếu
lên widget SB-84 như pha thứ tư). Sinh **tất định** từ các trường có sẵn của
thẻ (SB-76 — giá, khoảng cách, cần đặt trước, mùa), bằng bảng tra tay, không
AI, không gọi API ngoài:

| Điều kiện trên thẻ | Gợi ý hiện ra |
|---|---|
| có `price` > 0, hình thức trả tại chỗ | "mang đủ tiền mặt" |
| `khoảng cách` vượt ngưỡng | "đổ xăng / sạc xe trước khi đi" |
| `mùa` = mùa mưa theo miền | "mang áo mưa/ô, có phương án B trong nhà" |
| `cần đặt trước` = có | "xác nhận lại chỗ đã đặt" |
| luôn có | "chia sẻ vị trí" — một lần, qua OS Share Sheet có sẵn, KHÔNG theo dõi
thời gian thực, KHÔNG vi phạm R-1b (đây là an toàn cá nhân người dùng, không
phải giám sát người kia) |

Luật nội dung: chỉ hiện mục khớp trường thật có trên thẻ — một buổi xem phim
trong nhà thì không có dòng "mang áo mưa". Thẻ thiếu trường → khối ngắn hoặc
trống, chấp nhận được (không ép đầy). Một hành động chính duy nhất: "Xong hết
rồi, đi thôi" — đóng khối, giữ đúng SC-4.

**SB-212 — "Gửi lời cảm ơn + chốt việc kế tiếp" (phủ J9).** Touchpoint **hướng
ra ngoài**, đối lập trực tiếp với J8/SB-85 (hướng vào trong) — cùng một thẻ,
khác hướng. Kích hoạt **một lần**, dạng nhắc nhẹ, vào sáng hôm sau một thẻ
chuyển "Đã đi rồi". Bỏ qua thì thôi hẳn — không lặp, không tạo cảm giác tội lỗi
(nhất quán luật "không phạt khi im lặng").

Ba phần, cả ba đều **tái dùng hạ tầng đã có**, không xây engine mới:
1. **Soạn lời cảm ơn** — tái dùng khung nhại + mad-libs của C5 (SB-103..107),
   thêm một **danh mục preset mới** "lời cảm ơn sau hẹn" bên cạnh danh mục
   "lời mời" đã có. Ra ảnh/thẻ, người dùng tự copy sang Zalo.
2. **Đính ảnh** — liên kết thẳng sang C4 (ảnh đã lưu ở khối J8/23h, nếu có).
3. **Chốt việc kế tiếp** — 2-3 gợi ý nhẹ từ kho mồi (C1) hoặc dịp lịch âm gần
   nhất (C7); chọn 1 → thẻ mới vào trạng thái "Mới nghĩ ra". Không bắt buộc.

Vị trí kiến trúc: cả SB-211 và SB-212 đều là **mở rộng của màn (1)**, phần
(1) dùng renderer của (11) cho SB-212.1. **Tổng số màn hình vẫn là 11**, không
đổi bản đồ S3 — chỉ làm giàu trạng thái thẻ.

**Cập nhật bảng S1 (lưới journey):** J6 và J9 chuyển từ ❌/⚠️ sang **✅** — phủ
bởi SB-211 và SB-212. **Không còn journey nào trống ngoài chủ đích** (J7 cố ý
để trống, J12 cắt có chủ đích). **13/13 journey đã được xử lý có chủ ý** —
10 phủ đủ (nay là 12, gồm cả J6/J9 mới) + 1 cố ý trống (J7) + 1 cắt biên giới
(J12) = 13.

**Cập nhật bảng S4 (gán ngược):**

| Hạng mục mới | Màn hình |
|---|---|
| SB-211 "Trước giờ đi" | mở rộng trạng thái "Đã hẹn ngày, hôm nay" trong (1) |
| SB-212 "Cảm ơn + chốt việc kế tiếp" | mở rộng trạng thái "Đã đi rồi" trong (1); phần 1 tái dùng renderer (11); phần 2 liên kết (4); phần 3 liên kết (1) trạng thái "Mới nghĩ ra" |

### 2026-09-03 — Vòng 10 (Creative Partner, phủ lỗ hổng + viết lại idea.md)

- **Kích hoạt:** user yêu cầu phủ J6/J9 và đảm bảo journey/màn hình/tính năng
  được viết rõ trong `idea.md`, không chỉ trong `development.md`.
- **Không dùng web research.** Thiết kế hai touchpoint mới (SB-211, SB-212)
  bằng cách tái dùng hạ tầng đã có (bảng tra tay của SB-76, renderer của C5),
  giữ nguyên luật R-1/R-1c/D-1, không thêm màn hình, không thêm hạ tầng.
- **Kết quả:** S5 (thiết kế SB-211/SB-212 + cập nhật bảng S1/S4) · `idea.md`
  được viết lại: thay mục tóm tắt "Cập nhật vòng 9" bằng mục tự-đủ
  `## Đặc tả sản phẩm (vòng 9-10)` (journey đầy đủ, vòng đời, 11 màn hình,
  mô tả chi tiết 2 tính năng mới, bảng gán ngược) · mục `## Bàn giao` và
  `## Routing Notes` cập nhật theo.
- **Files updated:** `development.md`, `idea.md`, `brainstormer-checkpoint.md`.
- **Next action:** chờ user xác nhận cuối trên `idea.md` § Đặc tả sản phẩm
  trước khi set `EXPANDED` và soạn bản bàn giao v8 gộp.

### 2026-09-06 (vòng 11) · R1 — dọn ràng buộc trỏ vào REQ đã chết

Kích hoạt: user yêu cầu "dựa vào thông tin requirement hiện tại, update lại các
ràng buộc D-2/D-8, D-9/D-12, xoá bỏ nếu thấy không cần thiết nữa".

**Sự thật nền đã kiểm chứng** (`data/requirements/master_requirements_list.md`):
REQ-013 = `CANCELLED`, artifacts đã xoá khỏi cây làm việc. REQ-014 và REQ-015
đã bị gỡ hẳn khỏi registry (dòng cuối registry là REQ-013). Không còn
`req_master.md` nào của chặng 1 tồn tại.

**Phán quyết từng ràng buộc:**

| Ràng buộc | Phán quyết | Lý do |
|---|---|---|
| D-2 "nhập vào REQ-013" | ❌ **XOÁ** → thay bằng **D-2'** | Tiền đề ("REQ-013 đang PENDING, còn kịp sửa") sai hoàn toàn. Không có file để nhập vào. |
| D-8 "chặng 1.5 → REQ-014" | ✏️ **GIỮ RANH GIỚI, BỎ CON TRỎ** | Quyết định phạm vi vẫn đúng và vẫn cần; chỉ id kế thừa là chết. Móc SB-125 giữ nguyên. |
| D-9 "MỞ R-1, chưa có hiệu lực" | ❌ **XOÁ mục riêng** → gộp vào **D-12'** | Toàn bộ nội dung riêng của D-9 là cảnh báo "req_master.md đang nói ngược lại". File đó không còn ⇒ cảnh báo hết đối tượng. Phần "mở R-1" trùng D-12. |
| D-12 "nấc 3" | ✅ **GIỮ NGUYÊN NỘI DUNG** → nâng thành **D-12'** | Luật sản phẩm thực chất, không phụ thuộc id REQ nào. Nay có hiệu lực trực tiếp thay vì chờ PO thi hành. |

**Hệ quả dây chuyền đã xử:**

- Xung đột #1 trong checkpoint ("D-9/D-12 chưa có hiệu lực, artifact mâu thuẫn
  `req_master.md`") — **xoá, hết đối tượng**. Không còn bước sửa luật nào phải
  làm trước khi mở story.
- Xung đột #2/#3/#4 — **không xoá**, nhưng đổi phân loại từ "xung đột phải xử"
  sang "điều khoản bắt buộc chép vào `## Invariant Design Rules` của REQ mới",
  gói sẵn trong D-12'.
- D-4/D-5 từng neo vào "Luật 5 của REQ-013" / "cổng cứng của chính REQ-013" —
  viết lại thành luật tự đứng, kèm ghi chú **phải chép sang REQ mới** (không
  tự sống sót qua việc huỷ requirement).
- D-13 bản B và OQ-7 — bỏ con trỏ REQ-014, đổi thành "chặng 1.5, tạo sau".
- L44 — đánh dấu đã giải quyết ở vòng 9-10 (lưới 13 journey dựng lại).
- **L45 KHÔNG bị xoá.** Rủi ro "chặng 1 là trang trí cho phòng chờ" là câu hỏi
  định vị, độc lập với việc id REQ nào còn sống. Chuyển nguyên sang REQ mới như
  câu hỏi Product Owner phải trả lời khi khoá story list.

**Không đổi:** toàn bộ `## Đặc tả sản phẩm (vòng 9-10)` (13 journey, 11 màn
hình, SC-1'..SC-6, SB-211/SB-212, bảng gán ngược). Vòng 11 chỉ chạm tầng ràng
buộc hành chính, không chạm cấu trúc sản phẩm.

**Trạng thái sau vòng 11:** `Development Status` vẫn `IN_PROGRESS` — việc dọn
ràng buộc không phải là xác nhận đặc tả. Vẫn chờ user duyệt § Đặc tả sản phẩm
trước khi đặt `EXPANDED`.

---

### ★★ BẢN BÀN GIAO CUỐI (v8) — GỘP LUẬT (v7) + CẤU TRÚC (vòng 9-10) + DỌN REQ (vòng 11)

**Trạng thái:** ✅ user duyệt 2026-09-06. `Development Status: EXPANDED`.
**Thay thế:** v7 về mặt tổng thể. v7 vẫn đúng về LUẬT nhưng không còn là nguồn
chính cho CẤU TRÚC. **v8 là nguồn duy nhất để Product Owner đọc.**

#### PHẦN 1 — LUẬT BẤT BIẾN (PO chép vào `## Invariant Design Rules` của REQ mới)

Không còn `## Invariant Design Rules` nào tồn tại bên ngoài (REQ-013 đã huỷ).
Toàn bộ bộ luật dưới đây phải được **viết mới** vào `req_master.md`.

- **R-1 (mở ở NẤC 3, D-12')** — MỞ (a) suy luận tính cách *chỉ trên dữ liệu
  người dùng tự nhập* + (d) chỉ số ăn khớp. CẤM nguyên vẹn (b) đọc tin nhắn /
  theo dõi MXH · (c) so sánh và báo cáo hành vi · (e) kịch bản thao túng và A/B
  test lời nhắn · (f) streak và bảng xếp hạng. **Nấc 4 không bao giờ.**
- **R-1b (D-6)** — cấm đo lường hành vi người kia. Không "đã xem", không giờ mở,
  không đếm lần mở. Chỉ *đã trả lời / chưa trả lời*. Ranh giới với R-1(a): ghi
  **sở thích + sự kiện** ✅; ghi **tần suất + hành vi** ❌.
- **R-1c / R-1d (D-7)** — lời mời luôn có cửa từ chối sạch (một chạm, không né,
  không trêu, app không kịch tính hoá). Nội dung preset chỉ được đùa về **người
  gửi**.
- **R-1e (D-10)** — luật ba tầng: user **GHI** ✅ · user **ĐOÁN**, app không xác
  nhận ✅ · app **SUY LUẬN/CHẤM ĐIỂM** về người kia ❌. Tầng 3 chỉ mở trên dữ
  liệu user tự nhập.
- **R-1f (D-10)** — sổ tay chỉ ghi sở thích và sự kiện, không ghi đánh giá con
  người, không xuất chia sẻ.
- **R-1g** — mọi nội dung nói về người kia phải kết thúc bằng **một câu để hỏi
  người thật**, không kết thúc bằng một kết luận. Bài kiểm tra: *"đọc xong,
  người dùng muốn hỏi người kia nhiều hơn hay ít hơn?"*
- **Không AI ở runtime (D-4)** — nội dung đi đường PRESET + MAD-LIBS + KHUNG
  NHẠI. AI chỉ được dùng **ngoài hệ thống, ở khâu SOẠN nội dung**. Chỉ số ăn
  khớp = **bảng tra tay** (144 ô hoàng đạo / 256 ô MBTI), ship như gói dữ liệu,
  runtime tất định. Mỗi ô **bắt buộc có ít nhất một điểm cọ xát**, không chỉ khen.
- **D-14** — chỉ số ăn khớp hiển thị **DẢI**, không hiển thị %.
- **D-1** — chặng 1 chỉ phục vụ người **đã có một "mối" cụ thể**, đối phương
  chưa cài app. Không phục vụ nhóm "chưa có ai".
- **D-5 + cổng cứng** — định vị là "trợ lý hoạt động / chăm sóc nhau", KHÔNG
  phải "app tán tỉnh". **Cổng cứng phải chép vào REQ mới:** *"chặng 1 có dùng
  được trọn vẹn kể cả khi người kia không bao giờ tham gia không?"*
- **D-11** — quà chỉ là Ý TƯỞNG, không thương mại/affiliate. Thang **CÔNG SỨC
  (số giờ)** thay thang giá tiền. Nhánh handmade theo hồ sơ kỹ năng.
- **Nhật ký riêng-tư-mặc-định, xoá được.**
- **SB-208 / SC-6** — chân dung và bảng tra ăn khớp **nằm sau một hành động**,
  không bao giờ ở màn hình chính hay tab bar.

#### PHẦN 2 — CẤU TRÚC SẢN PHẨM

Nguồn chính: `idea.md` § `## Đặc tả sản phẩm (vòng 9-10)` — **tự đủ**, chứa:

- **A.** Lưới 13 journey (J1..J13): 11 phủ đủ · J7 cố ý để trống · J12 cắt biên.
- **B.** Vòng đời user theo thời gian thật (Phút 1 → Ngày 1 → Ngày 7 → sau buổi
  hẹn → Ngày 30 → lối ra J11 → lối quay lại J13).
- **C.** Bản đồ **11 màn hình**: 4 KHO · 3 CỬA VÀO · 3 KHOÁ VỊ TRÍ · 1 HÀNH ĐỘNG.
- **D.** 6 luật màn hình SC-1'..SC-6.
- **E.** SB-211 "Trước giờ đi" (J6) + SB-212 "Cảm ơn + chốt việc kế tiếp" (J9) —
  cả hai là **mở rộng của màn (1)**, tổng vẫn 11 màn hình.
- **F.** Bảng gán ngược: không hạng mục nghiên cứu nào rơi ra ngoài bản đồ.

Hình kiến trúc: **nhiều cửa vào → một kho chung → dữ liệu phụ trợ không có cửa
riêng.**

#### PHẦN 3 — RANH GIỚI PHẠM VI

- **TRONG phạm vi:** 11 màn hình, toàn bộ chặng 1.
- **NGOÀI phạm vi (D-8):** chặng 1.5 — link hai chiều để người kia trả lời mà
  không cần cài app; feed tin thật (mồi chuyện bản B); nhánh Zalo Mini App
  (OQ-7). Sẽ là **requirement riêng, tạo sau** — con trỏ REQ-014 cũ đã bỏ.
- **MÓC BẮT BUỘC ĐỂ LẠI:** SB-125 — vật phẩm lời mời thiết kế dạng **payload
  render được**, để chặng 1.5 không phải thiết kế lại.
- **Out of Scope tuyệt đối:** thương mại/affiliate quà.

#### PHẦN 4 — CÂU HỎI MỞ CHUYỂN GIAO CHO PRODUCT OWNER

| ID | Nội dung | Loại |
|---|---|---|
| **L45** | ⚠️ "Chặng 1 là trang trí cho phòng chờ" nếu chặng 1.5 nằm ngoài phạm vi. **Chưa ai hoà giải.** | Định vị — PO phải trả lời khi khoá story list |
| **OQ-3** | Ai biên tập và duyệt kho nội dung preset | Nguồn lực — chỉ user trả lời được |
| **OQ-2** | Một "ngăn" hay nhiều "ngăn" — đã trả lời một phần (mỗi trạng thái trong màn (1) là một ngăn lọc) | Chi tiết UI — PO/UX chốt |
| SB-144/145/146 | Trò chơi "đoán" không thắng thua, chưa gán màn cố định | Không chặn |
| **Rủi ro #1** | **Sượng.** Nút thắt là *gu người duyệt nội dung*, cần kiểm duyệt hai lớp (SB-123) | Rủi ro triển khai |
| **Rủi ro #2** | Hỏi kỹ năng kiểu CV → 80% trả lời "không có" và cả nhánh quà handmade sập. **"Nhớ dai", "biết chỗ ăn ngon" cũng phải tính là kỹ năng.** | Rủi ro triển khai |

**Trung thực về tần suất:** tính năng ý định cao / tần suất thấp (1-2 lời mời
một tuần). Tối ưu **"được nhớ tới đúng lúc cần"**, KHÔNG tối ưu DAU.

**Thứ tự không thương lượng (SB-174):** sổ tay → làm cho quà/mồi chuyện/kịch bản
hết chung chung → **rồi mới** phủ vỏ hoàng đạo và trắc nghiệm. Làm ngược lại sẽ
ra một app bói toán có kèm to-do list.

### 2026-09-06 (vòng 12) · D-15 — đóng OQ-3: nội dung preset là DỮ LIỆU

User chốt: *"tạo sẵn 10 nội dung preset. Sau này sẽ có tính năng bên CMS
(không thuộc repo hiện tại) bổ sung."*

**Diễn giải đã áp dụng:**

| Câu hỏi | Chốt |
|---|---|
| Ai biên tập | Đội AI soạn **offline**, trong lúc delivery. Hợp lệ theo D-4 (AI dùng NGOÀI sản phẩm, không bao giờ ở runtime) — D-15 không mở lại luật "không AI ở runtime". |
| Ai duyệt (bản đầu) | User duyệt bộ seed. |
| Ai duyệt (lâu dài) | CMS **ngoài repo hiện tại**. |
| Khối lượng bản đầu | **10 mục / mỗi gói nội dung xoay vòng.** |
| Phạm vi REQ-016 | Bản thân CMS, màn quản trị, luồng fetch/sync nội dung: **NGOÀI phạm vi**. Nội dung bản đầu ship kèm app. |

**Hệ quả kiến trúc (Tech Lead phải biết trước khi thiết kế):**

1. Nội dung là **dữ liệu có schema + id ổn định**, không phải chuỗi cứng trong
   widget. Lý do: nguồn nội dung sẽ đổi chủ sang CMS, mà không được kéo theo
   một lần sửa code.
2. **N là thuộc tính dữ liệu, không phải hằng số biên dịch.** Điều này trả lời
   luôn câu hỏi UX còn treo ở STORY-005/008 ("hết tập thì hành vi gì"): hành vi
   phải đúng với mọi N, kể cả khi CMS nâng N từ 10 lên vài trăm.
3. **Rủi ro mới do CMS sinh ra:** nội dung tương lai KHÔNG đi qua review của
   repo này, nên các luật bất biến không thể chỉ sống trong đầu người viết nội
   dung. R-1b (cấm đo hành vi người kia), chống tâng bốc, cấm %, cấm streak
   phải được đẩy xuống **tầng schema/validation** để nội dung vi phạm bị từ
   chối tại cổng nhập, không phải bị bắt lúc đọc. Đây là phần OQ-3 mà câu trả
   lời "ai biên tập" chưa chạm tới, và rẻ nhất là đóng ngay bây giờ.

**🔴 D-15 KHÔNG áp được cho STORY-010 — cần user quyết riêng.**

Gói xoay vòng và bảng tra phủ toàn phần là hai loại nội dung khác nhau:

- Gói xoay vòng (STORY-002/004/005/007/011): 10 mục là đủ dùng, thiếu thì lặp
  lại sớm — **suy giảm êm**. CMS bổ sung sau là mô hình đúng.
- STORY-010 là **400 ô phủ toàn phần** (144 hoàng đạo 12×12 + 256 MBTI 16×16).
  Người dùng chọn cặp nào là rơi vào đúng ô đó. **Không có suy giảm êm**: ô
  chưa soạn = tính năng vỡ tại chỗ. Ship 10/400 ô là ship một bảng tra hỏng.

**✅ USER CHỌN (a) 2026-09-06.** Soạn đủ 400 ô trong REQ-016; giữ cả hai trục
hoàng đạo và MBTI. Hệ quả: soạn nội dung trở thành khối công việc lớn nhất của
requirement, và kiểm duyệt hai lớp SB-123 áp lên toàn bộ 400 ô. Trục MBTI hợp
lệ với D-12' vì MBTI là **dữ liệu user tự nhập**, không phải suy đoán.

Ba lối ra đã cân nhắc (giữ lại làm vết quyết định):

- **(a) Soạn đủ 400 ô** trong REQ-016. Trung thực nhưng đắt nhất, và SB-123
  bắt kiểm duyệt hai lớp trên toàn bộ 400 ô.
- **(b) Bỏ TRỤC MBTI khỏi REQ-016, ship đủ 144 ô hoàng đạo.** Cắt 64% chi phí
  nội dung mà vẫn phủ toàn phần trên trục còn lại — bỏ nguyên một trục thì suy
  giảm êm, bỏ một phần ô thì không. Trục MBTI thêm sau ở thời CMS mà không phá
  gì. **Đây là lối khuyến nghị.**
- **(c) Hoãn cả STORY-010** tới khi có CMS.

### 2026-09-07 · D-15 đã lan xong vào REQ-016

4 lượt Product Owner + 1 lượt UI/UX Designer. Kết quả kiểm tra cuối: **0 khẳng
định OQ-3 sai** còn lại trong toàn bộ cây REQ-016.

- `req_master.md`: luật **R-15** (a/b/c), OQ-3 đóng, CMS vào Out of Scope.
- 13 `requirements/requirements.md`, 13 `story_master.md`, 8 `story_brief.md`,
  10 `uiux-spec.md`: đúng trạng thái mới.
- **Vẫn 13 story.** PO từ chối tách story nội dung 400 ô: trượt
  standalone-value gate (gói không màn thì vô hình, màn không gói thì vỡ), và
  ranh giới schema chính là bằng chứng đó là hợp đồng nội bộ một story. Nhu cầu
  chạy song song chuyển sang 3 pha có thứ tự trong `coding-plan/master-plan.md`.

**Hai lỗi phân loại của brainstormer, do PO bắt được:**

1. STORY-012 và STORY-006 bị xếp nhầm vào nhóm "chỉ nhắc OQ-3 để truy vết".
   Thực tế cả hai đều tiêu thụ nội dung preset ship kèm app; STORY-012 còn có
   bề mặt là **widget**, nơi R-15a ("cấm chuỗi cứng trong widget/code") cắn
   thẳng vào. Nếu lọt, hai bề mặt này sẽ không thay được nội dung khi CMS vào
   mà không phải sửa code — và chỉ phát hiện lúc đó.
2. Giả định "AC đóng đinh N=10" là sai. Không story nào làm vậy. Lỗi thật là
   **OQ-3 bị gắn cứng vào AC như điều kiện CHẶN SHIP**, khiến cả kho nội dung
   treo vào một quyết định nhân sự thay vì một thứ kiểm tra được.

**Ranh giới mới được siết nhân dịp này:**

- Trần tần suất BR-9 (STORY-012) **không phải N**: kho nhỏ giọt cạn thì im
  lặng. Cấm nới BR-9 để lấp chỗ trống — đó là đường một streak lẻn vào.
- "3 thẻ" (STORY-011 BR-2) và "3 câu mỗi lượt" (STORY-005 UX) là **hợp đồng bố
  cục / page size**, không phải N. Không được viện dẫn để cố định N; ngược lại
  R-15b không nới chúng.
- Có **cổng nhập ở đầu VÀO**, không chỉ đầu ra: câu hỏi sai làm bẩn dữ liệu
  theo cách không sửa được về sau (STORY-009 AC-37, STORY-011 AC-34,
  STORY-004 AC-36).
