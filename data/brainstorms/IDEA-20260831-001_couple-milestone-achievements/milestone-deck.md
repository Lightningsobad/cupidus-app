# Bộ Bài Mốc — Bản Đã Duyệt Vòng 1

Phụ lục của `development.md` (IDEA-20260831-001). Business-level, không phải spec.

**Trạng thái: đã duyệt vòng 1 (chốt c6).**

- **[CHỐT c6 / Q13]** Đã BỎ `G03`, `I10`, `I11` (vi phạm luật 2 / 1 / 3).
  **Tổng còn 147 lá.**
- **[CHỐT c6 / Q14] Mở hạn mức tập `H` lên TOÀN BỘ** — mọi lá đều có hiện vật khoe
  riêng. Thực thi bằng **hệ sinh hiện vật theo tham số**, không phải 147 thiết kế
  thủ công: 12 khung theo nhóm x 6 bố cục theo loại dữ liệu + 1 con dấu riêng mỗi
  lá. Giữ **phân cấp nghi lễ** (không phải phân cấp thiết kế): ~15 mốc lớn được
  toàn màn hình + hoạt hình + gợi ý in vật lý, phần còn lại là thiệp tĩnh.
- **[CHỐT c6 / Q15] Onboarding hồi tố cho lướt TOÀN BỘ**, không lọc bỏ lá nào.
  Thực thi bằng **xếp thứ tự + dừng được bất cứ lúc nào**, và **nhóm G nằm sau một
  vách ngăn rõ ràng** ở cuối.

## Cách duyệt

Với mỗi lá: giữ / bỏ / đổi tập / đổi tên / đổi vòng khán giả. Cứ ghi thẳng vào
cột **Duyệt** hoặc nhắn lại theo ID (ví dụ *"bỏ C27, G03; đổi D08 sang H"*).

## Ký hiệu

**Tập** (ba tập lồng nhau, chốt c4):
- `T` = **Tự khai** — có trong bộ bài onboarding hồi tố + thêm tay. Rẻ, rộng.
- `H` = **Có hiện vật khoe riêng** — **[c6] nay là TOÀN BỘ lá**; cột `H` bên dưới
  giữ lại để đánh dấu ~15 lá được **nghi lễ lớn** (toàn màn hình, hoạt hình, gợi ý in).
- `A` = **Auto-detect** — có pattern phán đoán. Đắt nhất, gánh rủi ro hỏi sai.
- Lá `A` và `H` đương nhiên cũng nằm trong `T`.

**Tầng nguồn** (chốt c2): `1` sự kiện cứng · `2` tự khai · `3` app gợi ý rồi xác
nhận · `4` người ngoài làm chứng · `5` cảm tính chính chủ.

**Khán giả mặc định**: `CK` công khai · `BT` bạn thân · `R` chỉ hai đứa.

**Giọng**: app xưng **"tụi mình"** (chốt c5).

---

## A. Mốc thời gian thuần (đếm ngày — không cần ai nhập gì)

| ID | Tên lá bài | Tập | Tầng | KG | Ghi chú | Duyệt |
|---|---|---|---|---|---|---|
| A01 | Ngày tụi mình bắt đầu | T H | 1 | CK | gốc của mọi mốc; `startDate` sửa lùi tự do (chốt c5) | |
| A02 | Tụi mình được 7 ngày | T | 1 | BT | thắng lợi sớm, chống churn tuần đầu | |
| A03 | Tròn một tháng | T H | 1 | CK | | |
| A04 | 100 ngày | T H | 1 | CK | văn hoá VN rất chuộng | |
| A05 | Nửa năm | T H | 1 | CK | | |
| A06 | 200 ngày | T | 1 | CK | | |
| A07 | Một năm | T H | 1 | CK | mốc lớn — gắn với bản in vật lý | |
| A08 | 500 ngày | T H | 1 | CK | | |
| A09 | 1000 ngày | T H | 1 | CK | mốc lớn nhất trước năm thứ 3 | |
| A10 | Năm thứ N | T H | 1 | CK | lặp hằng năm | |
| A11 | 2000 ngày | T | 1 | CK | | |
| A12 | Kỷ niệm hằng tháng | T | 1 | R | mốc mềm, mặc định TẮT để tránh nhiễu | |
| A13 | Đã bên nhau đủ bốn mùa | T H | 1 | CK | cách nói ấm hơn "365 ngày" | |
| A14 | Sinh nhật đầu tiên có nhau | T H | 1 | CK | mỗi người một lá | |
| A15 | Sinh nhật thứ N cùng nhau | T | 1 | BT | | |
| A16 | Ngày số đẹp (11/11, 22/2...) | T | 1 | BT | chỉ khi trùng thật; dễ thành nhiễu | |

## B. Lễ & mùa Việt Nam (khan hiếm thật — mỗi năm chỉ có một lần)

| ID | Tên lá bài | Tập | Tầng | KG | Ghi chú | Duyệt |
|---|---|---|---|---|---|---|
| B01 | Cái Tết đầu tiên của tụi mình | T H | 1+2 | CK | mốc theo mùa mạnh nhất | |
| B02 | Giao thừa đầu tiên bên nhau | T H | 2 | CK | | |
| B03 | Mùng một đi chùa cùng nhau | T | 2 | BT | | |
| B04 | Lì xì đầu tiên | T | 2 | BT | rất VN | |
| B05 | Valentine đầu tiên | T H | 1 | CK | | |
| B06 | 8/3 đầu tiên | T | 1 | BT | | |
| B07 | 20/10 đầu tiên | T | 1 | BT | | |
| B08 | Trung Thu đầu tiên | T H | 1 | CK | | |
| B09 | Giáng sinh đầu tiên | T H | 1 | CK | | |
| B10 | Đón năm mới đầu tiên (31/12) | T | 1 | CK | | |
| B11 | Đi lễ đầu năm cùng nhau | T | 2 | BT | | |
| B12 | Kỳ nghỉ dài đầu tiên (30/4, 2/9) | T | 1+2 | BT | | |
| B13 | Mùa thi đầu tiên cùng vượt qua | T | 2 | BT | hợp phân khúc sinh viên | |
| B14 | Cái Tết thứ N | T H | 1 | CK | tích luỹ — càng lâu càng đáng khoe | |
| B15 | Lần đầu mắc mưa cùng nhau | T | 2 | BT | mùa mưa/bão, rất VN | |
| B16 | 20/11 cùng nhau | T | 1 | BT | chỉ hợp nhóm học sinh/SV | |
| B17 | Halloween đầu tiên | T | 1 | BT | biên; có thể bỏ | |

## C. "Lần đầu" đời thường (xương sống của tự khai)

| ID | Tên lá bài | Tập | Tầng | KG | Ghi chú | Duyệt |
|---|---|---|---|---|---|---|
| C01 | Tin nhắn đầu tiên | T | 2 | R | | |
| C02 | Lần đầu gặp ngoài đời | T H | 2 | CK | | |
| C03 | Ly cà phê đầu tiên | T | 2 | BT | | |
| C04 | Bữa cơm đầu tiên | T | 2 | BT | | |
| C05 | Lần đầu nắm tay | T H | 2 | BT | | |
| C06 | Lần đầu nói "thương" | T | 2 | R | | |
| C07 | Lần đầu nói "yêu" | T H | 2 | R | **CẤM auto-detect** — quá thiêng | |
| C08 | Cuộc gọi video đầu tiên | T | 2 | R | | |
| C09 | Lần đầu gọi tới quá nửa đêm | T | 3 | R | lớp A thuần (giờ gọi) | |
| C10 | Lần đầu ngủ quên khi đang gọi | T | 2 | R | dễ thương, rất hay xảy ra | |
| C11 | Lần đầu nấu cho nhau | **T H A** | 3 | BT | auto: từ khoá + ảnh món ăn | |
| C12 | Lần đầu cùng đi chợ/siêu thị | T | 2 | BT | | |
| C13 | Cùng xem hết một bộ phim | **T A** | 3 | BT | auto: "tập cuối", "xem xong" | |
| C14 | Bài hát của tụi mình | T H | 2 | CK | có thể gắn link nhạc vào hiện vật | |
| C15 | Tấm ảnh đôi đầu tiên | T H | 1 | CK | gallery có sẵn | |
| C16 | Lần đầu để ảnh đại diện có nhau | T | 2 | CK | | |
| C17 | Lần đầu công khai chuyện tụi mình | **T H A** | 3 | CK | auto: "đăng ảnh", "công khai" | |
| C18 | Món quà đầu tiên | T | 2 | BT | | |
| C19 | Lá thư tay đầu tiên | T H | 2 | BT | | |
| C20 | Lần đầu mặc đồ đôi | T | 2 | BT | | |
| C21 | Lần đầu cùng chơi một game | T | 2 | BT | | |
| C22 | Lần đầu cùng đọc một cuốn sách | T | 2 | BT | | |
| C23 | Lần đầu cùng tập thể dục | T | 2 | BT | | |
| C24 | Lần đầu đi rạp | T | 2 | BT | | |
| C25 | Lần đầu đi karaoke | T | 2 | BT | | |
| C26 | Lần đầu ăn món mình không thích, vì người kia | T | 2 | BT | có duyên, rất "couple" | |
| C27 | Lần đầu cắt tóc / chọn kiểu tóc cho nhau | T | 2 | BT | biên | |
| C28 | Lần đầu chở nhau đi làm/đi học | T | 2 | BT | | |
| C29 | Lần đầu cùng ngắm bình minh | T H | 2 | CK | | |
| C30 | Lần đầu thức tới sáng nói chuyện | T | 3 | R | lớp A: nhịp nhắn xuyên đêm | |
| C31 | Lần đầu đưa nhau đi khám | T | 2 | R | | |
| C32 | Lần đầu tin nhau đủ để đưa điện thoại | T | 2 | R | biên, khá riêng tư | |

## D. Đi lại & địa lý (tín hiệu rõ nhất, rủi ro đoán sai gần 0)

| ID | Tên lá bài | Tập | Tầng | KG | Ghi chú | Duyệt |
|---|---|---|---|---|---|---|
| D01 | Chuyến đi đầu tiên | **T H A** | 1+3 | CK | auto: expense travel + geotag + từ khoá | |
| D02 | Chuyến bay đầu tiên cùng nhau | T H | 3 | CK | | |
| D03 | Đêm đầu tiên xa nhà cùng nhau | T | 2 | BT | | |
| D04 | Lần đầu ra biển | T H | 2 | CK | | |
| D05 | Lần đầu lên núi | T H | 2 | CK | | |
| D06 | Chuyến phượt đầu tiên | T H | 2 | CK | | |
| D07 | Lần đầu ra nước ngoài cùng nhau | T H | 3 | CK | | |
| D08 | Đã cùng đi qua N tỉnh thành | T H | 1 | CK | **bản đồ tô màu dần** — hiện vật khoe rất mạnh | |
| D09 | Đã cùng đi qua N quốc gia | T H | 1 | CK | | |
| D10 | Lần đầu về quê người kia | T H | 3 | BT | rất VN; gần E01 nhưng khác | |
| D11 | Chuyến tàu đầu tiên | T | 2 | BT | | |
| D12 | Chuyến đi dài nhất từ trước tới giờ | T | 1 | CK | **so với chính mình** — đúng tinh thần Q2 | |
| D13 | Lần đầu lạc đường cùng nhau | T | 2 | BT | có duyên | |
| D14 | Lần đầu cắm trại | T | 2 | BT | | |

## E. Gia đình & vòng xã hội

| ID | Tên lá bài | Tập | Tầng | KG | Ghi chú | Duyệt |
|---|---|---|---|---|---|---|
| E01 | Lần đầu ra mắt gia đình | **T H A** | 3 | CK | auto: từ khoá + ảnh đông người + quà | |
| E02 | Lần đầu ăn cơm nhà người kia | T | 2 | BT | | |
| E03 | Lần đầu ngủ lại nhà người kia | T | 2 | R | | |
| E04 | Lần đầu gặp anh chị em người kia | T | 2 | BT | | |
| E05 | Lần đầu gặp hội bạn thân người kia | T | 3 | BT | auto yếu — cân nhắc | |
| E06 | Lần đầu đi đám cưới cùng nhau | T H | 2 | CK | | |
| E07 | Lần đầu làm phù dâu/phù rể cùng nhau | T | 2 | BT | | |
| E08 | Lần đầu dự lễ giỗ nhà người kia | T | 2 | R | rất VN, khá sâu | |
| E09 | Lần đầu được nhà người kia gọi thân mật | T | 2 | BT | mốc cảm xúc mạnh | |
| E10 | Tấm ảnh đầu tiên với gia đình người kia | T H | 1 | CK | | |
| E11 | Chuyến đi đầu tiên cùng gia đình | T | 2 | BT | | |
| E12 | Lần đầu được nhắc trong nhóm chat gia đình | T | 2 | BT | biên | |

## F. Cùng làm & cùng xây

| ID | Tên lá bài | Tập | Tầng | KG | Ghi chú | Duyệt |
|---|---|---|---|---|---|---|
| F01 | Món đồ đầu tiên tụi mình mua chung | T | 2 | BT | | |
| F02 | Lần đầu nuôi chung một sinh linh | T H | 2 | CK | cây, cá, mèo, chó | |
| F03 | Ngày đặt tên cho bé cưng | T | 2 | BT | | |
| F04 | Quỹ chung đầu tiên | T | 1 | R | nối `expenses` — **chỉ sự kiện, không số tiền** | |
| F05 | Mục tiêu tiết kiệm đầu tiên hoàn thành | T H | 1 | BT | | |
| F06 | Lần đầu cùng nấu cho người khác | T | 2 | BT | | |
| F07 | Lần đầu cùng làm một dự án | T | 2 | BT | | |
| F08 | Lần đầu cùng học một thứ mới | T | 2 | BT | | |
| F09 | Lần đầu cùng dọn nhà | T | 2 | BT | | |
| F10 | Ngày tụi mình dọn về gần nhau | T H | 3 | CK | hiếm ở cặp mới yêu → để tự khai | |
| F11 | Lần đầu có chìa khoá nhà của nhau | T H | 2 | R | mốc tin tưởng rất mạnh | |
| F12 | Giao ước đầu tiên | T | 1 | BT | nối `love-contracts` | |
| F13 | Giao ước đầu tiên hoàn thành | T H | 1 | BT | | |
| F14 | Điều ước đầu tiên thành sự thật | T H | 1 | CK | nối `dream-jar` — rất đẹp | |
| F15 | Lần đầu cùng giúp một người lạ | T | 2 | BT | | |
| F16 | Cái cây đầu tiên tụi mình trồng | T H | 2 | CK | | |

## G. "Sẹo" — chỉ hỏi riêng, chỉ khoe dạng tổng hợp (L9)

| ID | Tên lá bài | Tập | Tầng | KG | Ghi chú | Duyệt |
|---|---|---|---|---|---|---|
| G01 | Cãi nhau xong vẫn nắm tay | **T A** | 3 | R | auto — **chỉ hỏi ở cửa sổ lành** (L11) | |
| G02 | Lần đầu mình xin lỗi trước | T | 2 | R | mỗi người tự ghi cho mình | |
| G04 | Tụi mình đã làm lành N lần | T H | 1 | BT | **dạng tổng hợp → khoe được** | |
| G05 | Lần đầu nói ra điều khó nói | T | 2 | R | | |
| G06 | Lần đầu tha thứ | T | 2 | R | | |
| G07 | Lần đầu ở bên nhau lúc ốm | **T A** | 3 | R | auto, hỏi trễ ≥3–7 ngày, giọng rất nhẹ | |
| G08 | Lần đầu đưa nhau đi bệnh viện | T | 3 | R | | |
| G09 | Lần đầu thức trắng chăm nhau | T | 2 | R | | |
| G10 | Đã cùng nhau đi qua một mất mát | T | 2 | R | **CẤM auto-detect, cấm gợi ý khoe** | |
| G11 | Vẫn đi tiếp dù nhà chưa thuận | T | 2 | R | tự khai; rủi ro cao nếu auto | |
| G12 | Đã cùng qua một lúc túng thiếu | T | 2 | R | | |
| G13 | Đã cùng qua một mùa áp lực | T | 2 | R | thi cử / công việc | |
| G14 | Tụi mình đã quay lại | T | 2 | R | tự khai; auto quá rủi ro | |
| G15 | Một hiểu lầm đã được gỡ | T | 3 | R | nối `anti_ghosting` | |
| G16 | Người kia biết điều mình giấu, và vẫn ở lại | T | 2 | R | nặng nhưng rất thật | |
| G17 | Lần đầu cùng đi tư vấn/trị liệu | T | 2 | R | biên; có thể bỏ | |
| G18 | Đã cùng đi qua N tháng khó khăn | T H | 1 | BT | dạng tổng hợp → khoe được | |
| G19 | Lần đầu chấp nhận một khác biệt không sửa được | T | 2 | R | mốc trưởng thành | |

## H. Yêu xa (ngách có giá trị cảm xúc cao nhất)

| ID | Tên lá bài | Tập | Tầng | KG | Ghi chú | Duyệt |
|---|---|---|---|---|---|---|
| H01 | Ngày tụi mình bắt đầu yêu xa | T | 3 | BT | | |
| H02 | Tháng đầu tiên yêu xa | **T H A** | 3 | CK | auto: giờ nhắn lệch + từ khoá | |
| H03 | Lần gặp lại thứ N | **T H A** | 3 | CK | auto: ảnh chung trở lại sau chuỗi trống | |
| H04 | Khoảng cách xa nhất tụi mình từng chịu | T H | 1 | CK | so với chính mình | |
| H05 | Lần xa nhau lâu nhất | T | 1 | BT | | |
| H06 | Tổng quãng đường đã đi để gặp nhau | T H | 1 | CK | **hiện vật rất mạnh** | |
| H07 | Lần đầu ra sân bay đón nhau | T H | 2 | CK | | |
| H08 | Lần đầu tiễn nhau | T | 2 | BT | | |
| H09 | Ngày yêu xa kết thúc | T H | 2 | CK | mốc lớn | |
| H10 | Món quà đầu tiên gửi qua bưu điện | T | 2 | BT | | |
| H11 | Cuộc gọi dài nhất | T | 1 | BT | ⚠️ có mùi cày được — cân nhắc | |

## I. Mốc trong app (nối feature sẵn có)

| ID | Tên lá bài | Tập | Tầng | KG | Ghi chú | Duyệt |
|---|---|---|---|---|---|---|
| I01 | Ngày tụi mình ghép đôi trên Cupid | T | 1 | BT | | |
| I02 | Tấm ảnh thứ 100 / 500 / 1000 | T H | 1 | CK | | |
| I03 | Album đầu tiên | T | 1 | BT | | |
| I04 | Kỷ niệm đầu tiên ghi vào dòng thời gian | T | 1 | R | | |
| I05 | Điều ước đầu tiên bỏ vào hũ | T | 1 | R | | |
| I06 | Theme đầu tiên mở khoá cùng nhau | T | 1 | R | | |
| I07 | Lần đầu xuất kho kỷ niệm | T | 1 | R | nối `data-export` | |
| I08 | Hộ chiếu đủ N con dấu | T H | 1 | CK | mốc meta của chính hệ này | |
| I09 | Trang công khai của tụi mình ra đời | T | 1 | CK | | |

## J. Chặng 1 solo + khoảnh khắc chuyển đổi

| ID | Tên lá bài | Tập | Tầng | KG | Ghi chú | Duyệt |
|---|---|---|---|---|---|---|
| J01 | Nơi đầu tiên mình muốn dẫn người ấy đi | T | 2 | R | | |
| J02 | Mình đã ghi lại N nơi | T H | 1 | R | | |
| J03 | Kế hoạch đầu tiên mình chuẩn bị | T | 2 | R | | |
| J04 | Nhật ký riêng ngày thứ N | T | 1 | R | | |
| J05 | **Ngày trao kho kỷ niệm cho người ấy** | T H | 2 | CK | **mốc cảm xúc mạnh nhất toàn sản phẩm** + mốc chuyển đổi kinh doanh | |
| J06 | Người ấy mở món quà đầu tiên | T H | 1 | R | | |
| J07 | Một kế hoạch từ hồi còn một mình đã thành thật | T H | 2 | CK | vòng khép rất đẹp | |

## K. Do người ngoài trao (chốt c5: **không cần cài app**)

| ID | Tên lá bài | Tập | Tầng | KG | Ghi chú | Duyệt |
|---|---|---|---|---|---|---|
| K01 | Người làm chứng đầu tiên | T H | 4 | CK | | |
| K02 | N người đã chứng kiến | T H | 4 | CK | **thay cho mọi chỉ số chất lượng quan hệ** | |
| K03 | Được gia đình làm chứng | T H | 4 | CK | | |
| K04 | Được hội bạn thân làm chứng | T H | 4 | CK | | |
| K05 | Danh hiệu bạn bè trao | T H | 4 | CK | bộ danh hiệu vui do bạn bè bình chọn: "cặp ồn ào nhất", "cặp ăn nhiều nhất", "cặp đi nhiều nhất" — **định tính, không phần trăm** (đúng Q2) | |
| K06 | Lời chúc thứ 100 | T | 4 | CK | | |
| K07 | Một người lạ đã chúc mừng tụi mình | T | 4 | CK | | |

## L. Tốt nghiệp & dài hạn

| ID | Tên lá bài | Tập | Tầng | KG | Ghi chú | Duyệt |
|---|---|---|---|---|---|---|
| L01 | Lần đầu nói về tương lai | T | 2 | R | | |
| L02 | Lần đầu bàn chuyện cưới | T | 2 | R | **CẤM auto-detect** | |
| L03 | Ngày cầu hôn | T H | 2 | CK | | |
| L04 | Đám hỏi | T H | 2 | CK | | |
| L05 | **Đám cưới** | T H | 2 | CK | mốc tốt nghiệp — khoảnh khắc giới thiệu mạnh nhất vòng đời | |
| L06 | Kỷ niệm cưới năm thứ N | T H | 1 | CK | thang giấy → gỗ → bạc → vàng | |
| L07 | Ngôi nhà đầu tiên | T H | 2 | CK | | |
| L08 | Con đầu lòng | T | 2 | CK | ngoài phân khúc, nhưng nên có chỗ | |

---

## Tổng kết bản đã duyệt

- **Tổng: 147 lá** trên 12 nhóm A-L.
- **Auto-detect (`A`): 9 lá** — C11, C13, C17, D01, E01, G01, G07, H02, H03. Khớp
  hạn mức 8-10 của c4.
- **Hiện vật riêng: 147/147** (c6). Xem §Hệ sinh hiện vật bên dưới.
- **Nghi lễ lớn (~15 lá)**: A04, A07, A09, B01, B14, C02, C15, D01, D08, E01, G04,
  H03, H06, J05, L05.
- **Cấm auto-detect vĩnh viễn**: C07 (lần đầu nói yêu), G10 (mất mát), G11, G14,
  L02 (bàn chuyện cưới), mọi thứ thân mật thể xác, mọi suy luận về lỗi một người.

## Hệ sinh hiện vật theo tham số (thực thi cho Q14 = toàn bộ)

Không làm 147 thiết kế thủ công. Ba lớp tổ hợp:

1. **Khung theo nhóm (12 bộ)** — mỗi nhóm A-L một ngôn ngữ thị giác riêng.
   Ví dụ: B lễ Tết đỏ-vàng-hoa mai · H yêu xa xanh đêm + bản đồ + múi giờ ·
   G sẹo tối giản, trầm, không lấp lánh · K chứng nhận có chữ ký · L trang trọng.
2. **Bố cục theo loại dữ liệu (6 kiểu)** — không theo từng lá:
   số lớn (mốc ngày) · bản đồ (địa lý) · ảnh tràn (mốc có ảnh) · danh sách tích
   luỹ (mốc đếm N) · chứng nhận (mốc do người ngoài trao) · tem hộ chiếu (mặc định).
3. **Một con dấu/icon riêng cho từng lá (147 cái)** — rẻ vì là icon, không phải layout.

12 x 6 = 72 tổ hợp khung-bố cục, cộng con dấu riêng → **mỗi lá đều có hiện vật
thật sự riêng**, mà khối lượng design là 12 + 6 + 147 icon.

**Rủi ro phải quản: đẹp đều = không gì nổi bật.** Giải bằng **phân cấp NGHI LỄ chứ
không phải phân cấp thiết kế** — 15 lá lớn được toàn màn hình + hoạt hình + âm
thanh + gợi ý in vật lý; 132 lá còn lại là thiệp tĩnh đẹp nhưng lặng lẽ.

## Onboarding hồi tố toàn bộ (thực thi cho Q15)

Không lọc bỏ lá nào. Thay vào đó:

- **Xếp thứ tự theo xác suất đã xảy ra**, suy từ độ dài quan hệ user vừa khai:
  đợt 1 những lá gần như chắc chắn đã có → đợt 2 → ... → *"còn 90 lá nữa, xem
  tiếp không?"*
- **Dừng được bất cứ lúc nào**, quay lại tiếp bất cứ lúc nào. Không có màn hình
  bắt buộc hoàn thành.
- **Nhóm G (sẹo) nằm cuối, sau một vách ngăn rõ ràng**: *"Phần tiếp theo nói về
  những lúc khó. Xem sau cũng được."* Cặp mới yêu 2 tuần lướt trúng "đã cùng đi
  qua một mất mát" ở phút thứ nhất là hỏng tông ngay.
- **Kho tra cứu đầy đủ 147 lá luôn mở** ở màn hình mốc — không giấu gì, chỉ không
  ép nuốt hết trong một lần.
