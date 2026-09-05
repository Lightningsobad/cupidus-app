# Bảng duyệt ứng viên — IDEA-20260828-002

Mục đích: gom toàn bộ vật liệu từ 6 cycle thành một danh sách user duyệt được,
TRƯỚC khi chạy Impact/Effort. Đây là bản rút gọn có chọn lọc, không phải bản đầy
đủ ~250 ứng viên thô — những thứ đã chết ở cycle trước nằm ở Phần E.

Ký hiệu: ⭐ nổi bật · ⚠️ có rủi ro cần quyết · 🔬 có bằng chứng nghiên cứu ·
🔧 đã dựng dở trong repo · ❌ đề nghị loại

## Sửa lỗi nhãn (phát hiện khi gom bảng này)

Artifact có ba chỗ trùng nhãn. Bảng duyệt dùng nhãn đã sửa:

- `P0` (hai chìa khoá) → **PRIM-1**
- `P6` cycle 1 (lật bài / blind reveal) → **PRIM-2**
- `P1-P5` cycle 2 (quan sát mã nguồn) → **OBS1-OBS5**
- `P1-P7` cycle 3 (tính năng chặng 1) giữ nguyên **P1-P7**

## Phần A — Quyết định user đã chốt (duyệt lại xem còn đúng không)

| # | Quyết định | Cycle |
|---|---|---|
| A-1 | Phân khúc: cặp đôi mới yêu | c2 |
| A-2 | Chiến lược: (a) tốt nghiệp + (b) tối ưu lan truyền, cả hai | c3 |
| A-3 | Rẽ sang chặng 1 — sản phẩm dùng được khi còn một mình | c3 |
| A-4 | Chặng 1 = Lựa chọn 1 + 2: trợ giúp thực dụng trên hoạt động + nhật ký riêng | c4 |
| A-5 | Hearts (IDEA-001) tạm gác | c2 |
| A-6 | **Một app đổi chế độ** (không phải hai app) | c7 |
| A-7 | **Một người tại một thời điểm** — ràng buộc cấu trúc | c7 |
| A-8 | **Ghi chú chặng 1 giữ vĩnh viễn** trong kho kỷ niệm riêng, mở bất kỳ lúc nào, có thể khoá | c7 |
| A-9 | **C8 giữ**, nhưng dạng "thi thoảng chèn câu hỏi" + học từ chat, không phải bảng câu hỏi | c7 |
| A-10 | **Gợi ý: fix cứng trước, AI sau** (AI cần vòng đào riêng) | c7 |
| A-11 | **Chặng 3 (C12) hoãn** — làm chặng 1 trước | c7 |
| A-12 | **G-2 = hướng (ii-b): không giấu cánh cửa, bỏ ổ khoá.** Khu riêng công khai và đối xứng cho cả hai; nội dung và cả việc có-hay-không đều bất khả truy cập từ tài khoản kia | c8 |
| A-13 | **G-1 = học từ chat chung trong app, chỉ từ chặng 2, bật bằng hai chìa khoá.** Chặng 1 không có chat nên học từ danh sách hoạt động (C1), nhật ký riêng (C6) và cột mốc (C7) | 2026-08-29 |
| A-14 | **Thứ tự = lối B: chặng 1 xếp trước, nhưng CÙNG MỘT PHASE với chặng 2.** B là thứ tự, không phải phạm vi. Chấp nhận phase dài hơn | 2026-08-29 |
| A-15 | **BD1 xưng hô anh/em: CHỐT, vào đợt 0** | 2026-08-29 |
| A-16 | ✅ **CHỐT — rẽ theo VAI, và VAI ĐỌC TỪ CẤU TRÚC PHỄU MỜI** (J3 người tạo lời mời = khởi xướng · J4 người mở link = được rủ · `invitations.service.ts` đã có `inviter`). **Không hỏi câu nào, không suy từ hành vi, chi phí 0.** Dự phòng: không xác định được ⇒ bản trung tính, đừng đoán. Cơ sở lật lối "giới": **`gender` không tồn tại trong repo** (D17-1) nên "giới rẻ hơn" là sai. Giới giữ riêng cho **ngôn ngữ + nội dung dịp lễ** (BD1, GA3) theo L15 | **c18** |
| A-17 | ✅ **CHỐT — L14 thành LUẬT PHỦ ĐỊNH**, không phải story: *cấm mọi cơ chế làm tăng thời gian trong app vì chính thời gian đó* (streak, điểm chuyên cần, combo, thông báo mồi). Lý do: sau khi vẽ đủ 21 màn hình, L14 **không đáp xuống bề mặt nào** (D17-4) — bản khẳng định cần bề mặt mới và mấp mé tầng 3 của L18; bản phủ định cưỡng chế được, không tốn màn hình, và cấm sẵn `streak` của A-21 | **c18** |
| A-18 | ✅ **CHỐT — KHÔNG mở lại. GA1 là đủ.** ⚠️ **Lý do phải ghi cho đúng (D17-5):** *GA1 đã lấy gần hết giá trị ở rủi ro gần 0* + *chi phí NĐ 356/2025* + *vector R8*. **KHÔNG** phải "bất khả thi về cấu trúc" — lập luận đó chỉ đúng cho **chặng 1**; ở chặng 2 cả hai đều có tài khoản nên PRIM-1 chính là đường đồng ý. Lát cắt tầng: tự ghi cho mình = tầng 1 ✅ · chủ động chia sẻ định tính = **chính là GA1** ✅ · app dự đoán rồi nói với người kia = tầng 3 ❌ | **c18** |
| A-19 | ✅ **CHỐT lối 3 — zodiac đổi vai từ *chấm điểm cặp đôi* sang *mồi chuyện*.** Bỏ `conflictIndex`; `dailyTips` → hạt câu hỏi; đổi tên endpoint/màn hình `red-flag`. **Không mở ngoại lệ cho R-1** — đây là dịch chuyển tầng 3 → tầng 2, luật đứng yên. Sinh ra **L18**, và **hồi sinh C8** đúng điều kiện RS2 của c6 | **c16** |
| A-20 | ✅ **CHỐT — brainstormer được sinh bản đồ màn hình mức nghiệp vụ** (`screen-map.md`). Layout/component/token vẫn là `ui-ux-designer` sau handoff | c15 |
| A-21 | ✅ **CHỐT lối 3 — pet phản ánh NHỊP, không ĐIỂM.** Bỏ `level`/`points`/`percent`/`streak`; giữ `mood` như trạng thái định tính phái sinh từ hoạt động. `streak` đã bị **A-17** cấm sẵn nên đây chỉ là thi hành. *(gốc: `pets` trượt L18* (đo được: `happiness`/`level`/`streak`/`mood`/`points`/`percent` + `pet_stats_row`). Không cùng ca với zodiac (chủ thể là *hoạt động chung*, không phải *con người*) nên **không** vi phạm `R-1e`; nhưng vi phạm **L18** và vi phạm **§6.12** của chính idea này. — chủ thể là *hoạt động chung* nên không vi phạm `R-1e`, nhưng vi phạm **L18** + **§6.12**)* | **c16→c18** |

## Phần B — Luật thiết kế (đề nghị chốt thành ràng buộc, không phải feature)

> ⭐ **L14 (c18, chốt A-17) — dạng PHỦ ĐỊNH, cùng hình dạng với L18.**
> **Cấm mọi cơ chế làm tăng thời gian trong app vì chính thời gian đó** — streak, điểm
> chuyên cần, combo, thông báo mồi. App được giữ chân bằng **giá trị của việc đã làm
> xong**, không bằng **nghĩa vụ quay lại**. Nền: R12-3b. Ghi trung thực: đây là luật
> **chống lại chỉ số tương tác**, sẽ là luật bị xin nới đầu tiên khi có áp lực tăng trưởng.
>
> ⭐ **L19 (c18, chốt A-16) — vai xác định bởi CẤU TRÚC, không bởi câu hỏi.**
> Vai (*đang rủ* / *đang được rủ*) đọc từ phễu mời: người tạo lời mời = khởi xướng,
> người mở link = được rủ. **Không hỏi người dùng, không suy từ hành vi.** Không xác
> định được ⇒ dùng bản trung tính, **đừng đoán**. Giới **không** dùng cho cơ chế (L15).
>
> ⭐ **L18 (c16, rút ra từ A-19) — luật tổng quát nhất của cả nhóm này.**
> **Chủ thể khẳng định quyết định tính hợp lệ, không phải chủ đề.** App được phép
> **NÊU** một chủ đề về hai người; app **không được KẾT LUẬN** về họ. Cưỡng chế ở tầng
> API cùng nước đi với **AI-1**: schema đầu ra của mọi nội dung mô tả con người hoặc cặp
> đôi **không được có trường điểm số** — cấm `score`, `index`, `percent`,
> `compatibility`, `level` và mọi biến thể. L18 là bản tổng quát của `R-1e` + `AI-1`, và
> là phép thử máy chạy được cho A-19/A-21 và cho mọi tính năng tương lai.

| # | Luật | Nguồn |
|---|---|---|
| **R-1** | ⭐ Trợ lý làm việc trên **HOẠT ĐỘNG**, không làm việc trên **CON NGƯỜI** | c4, user |
| XD1 | Không bao giờ so sánh hai người với nhau | c5 |
| XD2 | Không bao giờ báo cáo hành vi của người kia cho người này | c5 |
| XD3 | Không streak | c5 |
| XD4 | Cái gì lưu được thì phải quên được | c5 |
| XD5 | Không bảng xếp hạng xã hội | c5 |
| BE4 | Cùng thắng hoặc cùng thua, không bao giờ đấu nhau | c5 |
| RS7 | 🔬 Không đặt paywall lên lõi (28% + 19% khiếu nại ngành) | c6 |
| RS3 | 🔬 Đóng khung hậu cần là "lo liệu cho nhau", đừng hứa cảm xúc rồi giao lịch | c6 |
| **D7-4** | ⚠️ "Học từ chat" **chỉ** trên chat chung trong app, **chỉ** từ chặng 2, bật bằng hai chìa khoá. Chặng 1 không có chat để học — đọc Zalo/Messenger là N3/N4, cấm | c7 |
| **D7-5** | Cái được học phải là "chúng ta", không phải "người kia" (nếu không thì vi phạm XD2) | c7 |
| **D7-16** | ⚠️ AI phải bị rào ở tầng prompt lẫn tầng sản phẩm để không sinh nhận định về CON NGƯỜI | c7 |
| **D8-3** | ⭐ Câu trả lời sản phẩm trao cho người bị ép phải là **"app không có chức năng đó"**, không phải "tôi không cho xem" | c8 |
| **D8-16** | ⭐ **Không bao giờ hiển thị số lượng thứ KHÔNG được chia sẻ.** Chia sẻ là cộng thêm, và mờ đục về phần còn lại | c8 |
| **AI-1** | ⚠️ AI đọc chat **chỉ được trích xuất HOẠT ĐỘNG**, không bao giờ được MÔ TẢ con người. Ràng bằng JSON schema ở tầng API | c11 |
| **L17** | ⭐ **Mọi thông tin về người kia chỉ đến từ chính người đó, hoặc từ tay người dùng ghi. App không bao giờ là nguồn.** Dạng khả thi hoá của R-1: biến "không phân tích con người" thành quy tắc về **nguồn dữ liệu**, kiểm tra được ở tầng kiến trúc | c13 |
| **L14** | ⏳ **Đẩy ra ngoài, không chỉ hút vào.** App gợi "kể với một người bạn", không được thành ống xả duy nhất | c12, đề xuất |
| **L2** | Đối xứng tuyệt đối. **Không làm "chế độ an toàn cho nữ"** — một chế độ theo giới sẽ báo cho kẻ kiểm soát biết ai có gì để giấu (D12-4) | c8, xác nhận lại c12 |
| **L4 (sửa)** | Nới từ "giấu AI" thành **"không lấy AI làm đầu bài"**. R-1 và AI-1 không đổi | c12, R12-5 |
| **L15 (sửa c13)** | Nới từ "giới chỉ dùng cho ngôn ngữ" thành **"giới đổi CHỮ và NỘI DUNG, không bao giờ đổi CƠ CHẾ"**. Bản c12 quá chặt — nó cấm luôn nội dung 20/10 vốn vô hại | c13, GA3 |

→ Gộp lại thành **C19 "Hiến chương không làm"**, và nghiên cứu c6 cho thấy đây là
tài sản định vị, không phải giới hạn.

## Phần C — Ứng viên theo cụm

### C0. Gia nhập và tốt nghiệp (cơ chế, không phải màn hình)

| Mã | Ứng viên |
|---|---|
| S1 | Chế độ trợ lý một người |
| S2 ⭐ | Lời mời là món quà, không phải lời nhờ |
| G-b ⭐ | Cụ thể hoá S2: "đây là 12 chỗ anh đã ghi lại để đưa em đi" |
| S3 | Mời kiểu rủ chơi game |
| S4 ⭐ | Người kia KHÔNG cần cài gì để xem lần đầu |
| S5 | Tên và icon không hét lên "app cặp đôi" |
| S6 | Đừng bắt định nghĩa quan hệ |
| S7 | Người kia vào để xem một thứ cụ thể |
| RS5 ⭐🔬 | "Đẩy quan hệ tiến lên" — JTBD thật của chặng 1, giải bằng chuỗi hoạt động |

### C1. Danh sách hoạt động xuyên chặng — đối tượng xương sống

| Mã | Ứng viên |
|---|---|
| AC5 ⭐ | Danh sách "sẽ đi / sẽ xem" hiện đang thất lạc trong chat |
| G-a→G-d | Cùng một đối tượng: danh sách của tôi → chung → kế hoạch vận hành |
| DS4 ⭐🔧 | Gộp `dream_jar` vào C1 — ước mơ chung là hoạt động ở thì tương lai xa |
| U10 | Sổ tay của chúng ta |
| P3 | Gợi ý chỗ hẹn (chặng 1) |
| ⚠️ RS-B2 | Rủi ro định vị kiểu Cupla — phải áp RS3 |

### C2. Máy quyết định

| Mã | Ứng viên |
|---|---|
| U2 | Máy quyết định: hôm nay ăn gì, đi đâu |
| SC2 ⭐ | Cả hai chọn mù, trùng thì tự chốt (hợp nhất PRIM-1 + PRIM-2) |
| W6 | Thẻ thử thách hẹn hò |
| AC1/AC3 | Nỗi đau nền: không biết chọn gì, sợ chọn sai/nhạt |

### C3. Chuyến đi đầu tiên — khác biệt nhất

| Mã | Ứng viên |
|---|---|
| AC4 ⭐ | Chuyến đi đầu tiên: 48h đầu ở cạnh nhau, tiêu tiền chung lần đầu |
| BD4 | Chuyến đi cuối tuần từ HN / SG — tập địa điểm hữu hạn, làm sẵn được |
| AC7 ⚠️ | Chia tiền chuyến đi — rất tế nhị ở chặng đầu |
| TR6 | Chốt hoá đơn ngay tại chỗ, nhẹ tay |
| P4 | Chuẩn bị buổi hẹn (chặng 1) |

### C4. Cùng xem gì

| Mã | Ứng viên |
|---|---|
| AC6 | Xem phim đồng bộ khi yêu xa |
| W5 | Mixtape / playlist chung |
| U11 | Chế độ yêu xa |
| BD6 🔬 | Xác nhận: hẹn hò đô thị VN mặc định là quán cà phê và rạp phim |

### C5. Hai chìa khoá + lật bài — nguyên thuỷ lõi

| Mã | Ứng viên |
|---|---|
| PRIM-1 ⭐🔧 | Hai chìa khoá (mutual consent) — đã có sẵn trong 6 module, chưa đặt tên |
| PRIM-2 ⭐ | Lật bài (blind reveal) |
| SC7 ⭐ | Quà bất ngờ phải **phá vỡ** hai chìa khoá mới có nghĩa |
| SC3 | Hai chìa khoá cho việc **huỷ**, chống huỷ kèo tuỳ hứng |
| SC1 | "Không phản đối trong 24h" cho việc nhỏ |
| SC4 | Lời mời có hạn 48h |
| SC5 | Nửa chìa khoá: "anh nghiêng về cái này" |
| SC6 | Hai chìa khoá để mời người thứ ba xem một phần |
| SC8 | Trao quyền thay vì xin phép: "để em chọn giúp anh" |
| RS4 ⚠️🔬 | **Đồng bộ phải là tính năng hạng nhất** — 16% khiếu nại ngành đánh đúng đây |

### C6. Nhật ký riêng — chạy suốt cả ba chặng

| Mã | Ứng viên |
|---|---|
| P6 | Nhật ký cảm xúc riêng (chặng 1, Lựa chọn 2) |
| XD9 ⭐ | Nhật ký lúc giận ở chặng 2 — chứng minh C6 không chết khi tốt nghiệp |
| T7 / L2 | Khép lại tử tế khi bị từ chối, không giữ người dùng bằng nỗi đau |
| P7 ⚠️ | "Chỗ để hỏi lúc 2h sáng" — cần thu hẹp về hậu cần theo R-1 |
| D7-9 ⭐ | **Kho kỷ niệm riêng vĩnh viễn** — ghi chú chặng 1 không xoá, không ép gộp, mở bất kỳ lúc nào |
| D7-14 ⭐ | Vì "một người một lúc": chương khép lại → vào kho riêng → mở chương mới. Đây cũng là lời giải tử tế cho L2/T7 |
| D8-2 ✅⭐ | **GIẢI ở c8 — bản (ii-b):** khu riêng công khai, đối xứng, ai cũng có. Vô hình là **nội dung** và cả **việc bên trong có gì hay không**, không phải cánh cửa |
| D8-1 ❌ | **Không dùng "tính năng ẩn" (ii-a)** — hai người cùng một binary, sẽ bị phát hiện, và phòng BÍ MẬT tệ hơn phòng KHOÁ |
| D8-7 | Sinh trắc học mặc định, mật khẩu chỉ dự phòng, **cả hai tuỳ chọn và mặc định TẮT** |
| D8-9..16 | **Danh sách rò rỉ phải kiểm khi làm** — thông báo, trạng thái nhẹ, dòng thời gian, huy hiệu đếm, tìm kiếm, kết xuất, sao lưu, và số lượng thứ không chia sẻ |
| D8-14 ⚠️🔧 | `backend/src/modules/data-export/` đã tồn tại → bản kết xuất phải loại khu riêng ra, nếu không nghi thức kết xuất chính là chỗ rò |
| D7-12 | Kho riêng cũng phải xoá được, theo XD4 |

### C7. Cột mốc và lần đầu tiên

| Mã | Ứng viên |
|---|---|
| P5 | Ghi "lần đầu tiên" ngay từ chặng tán tỉnh |
| W4 | Bản đồ lần đầu tiên |
| W8 / E2 | Hộp thư thời gian |
| U5 | Tự động lo ngày quan trọng |
| V6 | Quà và dịp |
| BD7 🔬 | Đếm kỷ niệm theo tháng và trăm ngày — mật độ cột mốc VN dày hơn |
| XD10 | Cãi nhau lần đầu là cột mốc, không phải thất bại |

### C8. Tìm hiểu nhau — ✅ GIỮ, nhưng đổi hình hoàn toàn (quyết định c7)

| Mã | Ứng viên |
|---|---|
| D7-1 ⭐ | **Tần suất là lời giải thứ hai cho bẫy cạn nội dung** — cùng kho hữu hạn, hỏi mỗi ngày thì lộ lặp trong vài tuần, hỏi thi thoảng thì dùng được nhiều năm |
| D7-2 ⭐ | **"Thi thoảng chèn một câu hỏi" thay cho "bảng câu hỏi"** — hạt nhỏ trong luồng đang có, không phải màn hình phải làm cho xong |
| RS2 ⭐🔬 | Nội dung sinh từ dữ liệu của chính cặp đôi (C1, C6, C7, C16) |
| D7-3 🔧 | **Học từ chat khả thi: `backend/src/modules/messages/` đã tồn tại**, chat chung nằm trong hệ thống mình |
| D7-4 ⚠️ | **Nhưng chỉ từ chặng 2.** Chặng 1 không có chat để học; đọc app khác là N3/N4 |
| D7-5 ⚠️ | Học ra "hai đứa hay nhắc tới biển" ✅ · học ra "cô ấy hay buồn tối chủ nhật" ❌ (XD2) |
| W1 | 36 câu hỏi Aron — **sống lại** dưới dạng nguồn hạt giống, không phải bộ đề |
| W2 | Bộ bài câu hỏi — như trên |
| GI6 | Câu hỏi mỗi tối → **đổi thành thi thoảng, không hằng ngày** |
| W10 ❌ | Học theo cấp độ kiểu Duolingo — vẫn loại (đụng XD3 không-streak) |

### C9. Bản địa hoá VN — con hào rẻ nhất

| Mã | Ứng viên |
|---|---|
| BD1 ⭐ | Xưng hô anh/em và cách gọi riêng — app phải học và dùng đúng |
| BD5 ⭐🔬 | Sống với bố mẹ → ô GIỮA quan trọng ở VN hơn phương Tây (đã xác nhận) |
| BD2 | Lịch âm + dịp lễ Việt: Tết, Trung thu, 8/3, 20/10, chuỗi ngày 14 |
| BD3 🔬 | Ra mắt gia đình — ở VN nghĩa là "họ thấy tương lai với bạn, chấm hết" |
| Q5/Q8 | Bản địa VN đang bị bỏ trống hoàn toàn bởi đối thủ ngoại |

### C10. Thương mại trên hoạt động — đường doanh thu

| Mã | Ứng viên |
|---|---|
| AC8 | Đặt chỗ, vé, quà |
| KY4 | Cuốn sách cuối năm bản in được — sản phẩm vật lý |
| $2 ⭐ | Không kiếm tiền trên mối quan hệ, mà trên chuyến đi họ vẫn sẽ đi |
| RS7 🔬 | Không paywall lên lõi |

### C11. Đồ đã dựng dở trong repo — chi phí thấp bất thường

| Mã | Ứng viên |
|---|---|
| DS1 🔧 | `vow` có màn hình, không có backend → ứng viên hoàn hảo cho PRIM-1 |
| DS2 🔧 | `wishlistThemeId` đã có trong entity → chính là SC7 quà bất ngờ |
| DS5 🔧 | `love_contracts` → nối DS1 và XD7 |
| Q3 🔧 | `anti_ghosting` đã độc đáo sẵn, chưa khai thác |
| DS6 🔧⚠️ | Love Pet đang trôi nổi → chỉ phản ánh **nhịp**, tuyệt đối không phản ánh điểm |
| DS3 | emoji `price` chưa trừ hearts → để lại cho IDEA-001 |

### C12. Chặng 3 — ⚠️ NGHIÊN CỨU NÓI ĐANG HOÃN QUÁ XA

| Mã | Ứng viên |
|---|---|
| A-11 ✅ | **Quyết định c7: hoãn — làm chặng 1 trước.** RS-F4 ghi nhận nhưng không đổi thứ tự |
| RS8 ⚠️🔬 | Ở VN tuổi kết hôn nữ ~22, áp lực cưới trước 30 → chặng 3 đến sớm |
| U1 | Sổ gánh nặng vô hình (mental load) |
| U3 | Lớp lịch cặp đôi "ai trực" |
| U6 | Tiền / ngân sách chung |
| U8 | Vận hành nhà cửa |
| U13/U14 | Chế độ cưới / mới có con |

### C14. Ô GIỮA — 90% quỹ thời gian, hiện trống

| Mã | Ứng viên |
|---|---|
| GI5 ⭐ | Cùng làm việc riêng trong một phiên chung — ở bên nhau mà không tốn nội dung |
| GI9 ⭐ | Hàng chờ "để gặp rồi kể" — nối ô GIỮA sang ô TRONG |
| GI3 | "Đang nghĩ tới em" một chạm, không cần trả lời |
| GI4 | Trạng thái nhẹ, không phải vị trí (tránh R8) |
| GI7 | Nghi thức khép ngày — 365 lần/năm |
| GI2 | Gói hàng chậm — độ trễ có chủ đích |
| GI1 | Đếm ngược gắn với kế hoạch cụ thể trong C1 |
| GI8 | Bản tin cuối tuần, tự sinh từ C1 |
| RS1 ⭐🔬 | **Thoả thuận kỳ vọng liên lạc bằng hai chìa khoá** — thay GI10 |
| GI10 ❌ | Hiển thị nhịp nhắn tin không đối xứng — **loại, thay bằng RS1** |
| ⚠️ RS-D4 | Cảnh báo: ô GIỮA không được biến thành thêm một kênh chat |

### C15. Ô TRONG — app tự câm

| Mã | Ứng viên |
|---|---|
| TR1 ⭐🔬 | App tự tắt thông báo khi hai máy ở gần nhau |
| TR4 ⭐🔬 | Chế độ để-điện-thoại-xuống — cũng là cầu nối sang IDEA-001 |
| RS6 🔬 | Chống phubbing thành định vị công khai (meta-analysis 52 NC / 19.698 người) |
| TR2 | Một chạm giữ chỗ khoảnh khắc, điền sau |
| TR3 | Chụp chung hai máy, hai góc nhìn |
| TR5 | Album tự mở tự đóng theo buổi hẹn |

### C16. Ô SAU — ký ức tự viết

| Mã | Ứng viên |
|---|---|
| KY1 ⭐🔧 | `timeline` đã có nhưng trống → **tự viết từ C1 + TR2**, người dùng chỉ xác nhận |
| KY2 ⭐ | Sau buổi hẹn hỏi đúng một câu, cả hai lật bài |
| KY6 ⭐ | Ký ức được phép mâu thuẫn — hai người nhớ khác nhau, giữ cả hai bản |
| KY3 | Ký ức nổi lên theo địa điểm, không chỉ theo ngày |
| KY5 | Kho "chuyện của chúng ta" — text-first, không phải ảnh |
| KY7 | Quyền xoá ký ức khi chia tay |

### C17. Xung đột và sửa chữa — chữ "hữu ích" đậm nhất

| Mã | Ứng viên |
|---|---|
| XD6 ⭐⭐ | **Nút "em đang giận, chưa nói chuyện được, nhưng anh đừng lo"** |
| XD7 | Hẹn giờ nguội, chốt bằng hai chìa khoá |
| XD8 | Sửa chữa kiểu Gottman — không phân xử ai đúng |
| U4/V8 | Bộ sửa chữa sau xung đột, xung đột đầu tiên |

### C18. Người thứ ba — ô chưa từng chạm

| Mã | Ứng viên |
|---|---|
| BE7 ⭐ | Đôi bạn cùng chơi — hai cặp đi chung. **Giải Y8** |
| BE6 🔬 | Ra mắt gia đình (nặng ở VN) |
| BE5 ⚠️ | Sổ nhớ bạn bè người kia — hậu cần được, hồ sơ tính cách vi phạm R-1 |
| BE8 | Trang chia sẻ cho người ngoài xem, không lộ gì riêng tư |

## Phần D — Bằng chứng nghiên cứu (c6)

| # | Kết luận | Ảnh hưởng |
|---|---|---|
| RS-A1 | Phụ thuộc hai chiều là nguyên nhân chết có thật | Xác nhận A-3 |
| RS-A2 | Nghĩa địa: Tuned, Avocado, Pair/Couple chết; Between sống | Rào cản cao hơn giả định |
| RS-A3 | Khiếu nại ngành: paywall 28% · cạn nội dung 22% · auto-renew 19% · lỗi đồng bộ 16% · nội dung chung chung 10% | Sinh RS7, RS2, RS4 |
| RS-B1 | ⚠️ C8/GI6 là bẫy cạn nội dung, không phải chiều sâu | Hạ C8 |
| RS-B2 | ⚠️ C1/C3 dính rủi ro định vị kiểu Cupla | Sinh RS3 |
| RS-B3 | ⚠️ Lỗi đồng bộ đánh vào nguyên thuỷ lõi C5 | Sinh RS4 |
| RS-C2 | Đối thủ chặng 1 đều là CRM hẹn hò nhiều người → khoảng trống trùng khít A-4 | Xác nhận A-4 |
| RS-C3 | Phản ứng chống CRM-hoá quan hệ có thật | C19 là tài sản |
| RS-D2 | JTBD chặng 1 là "mắc kẹt, không biết cách tiến lên" | Sửa JTBD, sinh RS5 |
| RS-D3 | Chuyên gia khuyên: nhắn tin chỉ để lo hậu cần gặp mặt | Xác nhận mạnh nhất cho A-4 |
| RS-E1 | Meta-analysis phubbing 52 NC / 19.698 người | Chống lưng TR1/TR4 |
| RS-E2 | Tương đồng **kỳ vọng** mới tương quan hài lòng | GI10 → RS1 |
| RS-F4 | VN: chặng 3 đến sớm | C12 hoãn quá xa |

## Phần E — Đã loại, và lý do

| Mã | Nội dung | Lý do loại | Cycle |
|---|---|---|---|
| N1-N7 | Kịch bản thao túng, chấm điểm cơ hội, phân tích tin nhắn, theo dõi MXH, A/B test lời nhắn, nhiều mục tiêu | Vi phạm R-1 theo định nghĩa | c4 |
| GI10 | Hiển thị nhịp nhắn tin không đối xứng | Mép vực bảng-điểm; thay bằng RS1 | c6 |
| W3 | Đấu trường "ai hiểu ai hơn" | Vi phạm BE4 và XD1 (dạng đấu nhau) | c5 |
| W10 | Học theo cấp độ kiểu Duolingo | Đụng XD3 không-streak + bẫy cạn nội dung | c6 |
| E6/B13 | Streak của nghi thức | XD3 | c5 |
| R1-R9 | Giám sát, bảng điểm việc nhà, streak trừng phạt, kho bằng chứng, kiểm soát cưỡng ép... | Hàng rào đạo đức từ c1 | c1 |
| U7 | Đồng bộ chu kỳ & sức khoẻ | Quá thân mật cho cặp mới yêu — có thể mở lại ở chặng 3 | c2 |
| U12 | Chế độ chăm sóc | Như trên | c2 |

## Phần F — Trạng thái 7 câu (cập nhật c7)

| # | Câu hỏi | Trả lời |
|---|---|---|
| Q-a | C8 giữ hay bỏ? | ✅ **GIỮ** — "thi thoảng chèn câu hỏi" + học từ chat, không phải bảng câu hỏi |
| Q-b | Một app hay hai app? | ✅ **Một app đổi chế độ**, chắc chắn |
| Q-c | Ghi chú chặng 1 đi về đâu? | ✅ **Giữ trong kho kỷ niệm riêng**, mở bất kỳ lúc nào, có thể khoá |
| Q-d | Một người tại một thời điểm? | ✅ **Có** |
| Q-e | C2/C3 có dùng AI? | ✅ **Cả hai** — fix cứng trước, AI sau, AI cần vòng đào riêng |
| Q-f | C12 kéo sớm tới đâu? | ✅ **Hoãn** — làm chặng 1 trước |
| Q-g | BE5 làm không? | ⏸️ **Chưa rõ ràng** — để mở, không chặn gì |

## Phần G — Ba việc phát sinh từ quyết định c7 (2/3 đã đóng)

| # | Việc | Vì sao |
|---|---|---|
| G-1 ✅ | **ĐÃ CHỐT c9 — "học từ chat" chỉ áp dụng cho chat chung TRONG app, chỉ từ chặng 2, và bật bằng hai chìa khoá.** Chặng 1 học từ C1/C6/C7 thay vì từ tin nhắn | Không bao giờ đọc Zalo/Messenger (N3/N4) |
| G-2 ✅ | **ĐÃ GIẢI c8 — bản (ii-b).** Xem C6 và `development.md` cycle 8 | Chuyển từ "người dùng phải từ chối" sang "sản phẩm không có khả năng đó" |
| G-3 ⚠️ | **M2 giờ là hạng mục kiến trúc bắt buộc** | Một app hai chế độ = mô hình dữ liệu phải chịu được 1 chủ → 2 chủ. Hạng mục lớn nhất của idea |

## Phần H — Ghi cho plan: vòng đào riêng về AI (theo Q-e)

Chưa trả lời được, cần một cycle riêng hoặc một vòng nghiên cứu:

- AI làm được gì mà bộ gợi ý tĩnh không làm được? Nếu không trả lời rõ thì chưa cần AI.
- Chi phí trên mỗi người dùng ở phân khúc sinh viên VN — đối chiếu Z8 và X4.
- Riêng tư: gửi dữ liệu quan hệ ra mô hình bên thứ ba, chấp nhận tới đâu.
- ⚠️ Ranh giới R-1: mô hình được đưa chat vào sẽ **tự nhiên** sinh nhận định về
  con người. Cần rào ở tầng prompt lẫn tầng sản phẩm, không trông vào ý định.
- Chạy trên máy hay trên máy chủ; có chế độ không-AI cho người từ chối.


## Phần I — Kết quả Impact/Effort (c9)

Thang I 1-5, E 1-5 (5 = đắt nhất). Effort là ước lượng nghiệp vụ dựa trên những gì
đã quét trong repo, **không phải** ước lượng kỹ thuật của tech-lead.

### Nhóm 0 — Quyết chứ không build

| Mã | Nội dung | I | E |
|---|---|---|---|
| C19 + R-1 + D7-4 + D8-2 | 12 luật thiết kế | 5 | 1 |
| BD1 | Xưng hô anh/em — ⚠️ chi phí tăng theo thời gian, quyết ngay làm dần | 4 | 3 |
| M2 | Mô hình sở hữu 1 chủ → 2 chủ — việc tech-lead, chặn toàn bộ chặng 1 | 5 | 5 |

### Q1 — Làm ngay

XD6 (5/1) · RS1 (5/2) · SC7+DS2 (4/1) · GI3 (4/1) · KY2 (4/2) · BD2 (4/2) ·
DS1 (3/2) · XD7 (3/2) · SC3 (3/1) · GI7 (3/1)

### Q2 — Đầu tư có kế hoạch

C1 (5/3) · KY1 (5/3) · C0 (5/4, phụ thuộc M2) · C3 (5/4) · TR1 (4/4) ·
RS4 (4/4) · SC2 (4/3) · GI5 (4/3) · TR4 (4/3)

### Q3 — Rẻ, làm kèm

GI1 (3/1) · SC5 (2/1) · BD7 (2/1) · GI8 (3/2) · GI9 (3/2) · TR2 (3/2) ·
KY6 (3/2) · GI4 (3/2) · KY5 (3/2)

### Q4 — Hoãn hoặc bỏ

C12 (user hoãn) · C10 + KY4 (sai thời điểm, chưa có người dùng thì chưa bán được) ·
C8 (chờ RS2, chờ C1/C16 có dữ liệu) · BE7 (chờ đủ mật độ cặp đôi) · TR3 (2/4) ·
KY3 (3/3, sau KY1) · BE5 (Q-g chưa quyết)

### ⚠️ Mâu thuẫn thứ tự mà bảng xếp hạng không tự giải được

- **Cả 10 mục Q1 đều chạy được ở chặng 2 mà không cần M2** — chúng dùng lại
  `notifications`, `messages`, `alarms`, `timeline`, `wishlistThemeId`, và mutual
  consent đã có ở 6 module.
- **Nhưng chặng 1 — thứ đã chốt làm trước (A-3, Q-f) — bị chặn hoàn toàn bởi M2,
  mục đắt nhất trong toàn bộ idea.**
- Ba lối:
  - **A — chặng 2 trước:** rẻ, nhanh, có phản hồi thật, nhưng không giải X1.
  - **B — chặng 1 trước:** đúng chiến lược, giải X1, nhưng trả giá lớn nhất trước
    khi kiểm chứng được gì.
  - **C ⭐ — tách quyết định khỏi thi công:** chốt mô hình sở hữu ngay (rẻ, là
    quyết định thiết kế) để không xây thêm gì khoá cứng vào `coupleId`, nhưng ship
    Q1 ở chặng 2 trước. M2 làm sau và làm dễ hơn.
- ⚠️ Nếu chọn A mà không kèm quyết định của C: mỗi tính năng Q1 xây theo `coupleId`
  là thêm một chỗ phải sửa lúc làm M2. **Càng ship nhiều theo lối cũ, M2 càng đắt.**

**Đây là câu hỏi duy nhất còn chặn handoff.**

## Phần J — Thứ tự thi công trong phase (c10, chốt lối B)

**Đợt 0 — nền, không ship gì:** M2 mô hình sở hữu 1 chủ → 2 chủ · BD1 xưng hô ·
12 luật thành ràng buộc.

**Đợt 1 — chặng 1 phải tự đứng được (L1):** C1 danh sách hoạt động · C6 nhật ký
riêng (ii-b) · BD2 · KY2 bản một người · GI7 bản một người · GI3 bản một người.
→ Kiểm thử L1: dùng được trọn vẹn kể cả nếu người kia **không bao giờ** tham gia?

**Đợt 2 — bản lề:** C0 chế độ một người → lời mời G-b → chuyển chế độ → tốt nghiệp.
Chỗ duy nhất giải X1. Chỉ chạy được nếu đợt 1 đã tích luỹ đủ nội dung.

**Đợt 3 — chặng 2 phần rẻ:** XD6 · RS1 · SC7+DS2 · DS1 · XD7 · SC3, cộng bản
chặng-2 của GI3 (ping thật) và KY2 (lật bài). G-1 bắt đầu có hiệu lực từ đây.

**Đợt 4 — chặng 2 phần dày:** KY1 · SC2 · C3 · RS4 · TR1 · TR4 · GI5.

**Q3** làm kèm đợt nào tiện. **Q4** ngoài phase.

### Q1 cắt lại theo chặng

| Chạy được ở chặng 1 | Chỉ chặng 2 |
|---|---|
| BD2 · GI7 · KY2 · GI3 (bản một người) | XD6 · RS1 · SC7+DS2 · DS1 · XD7 · SC3 |

⭐⭐ **D10-4 — bốn mục chặng-1 đó không phải đồ thừa rẻ tiền.** G-1 đã chốt chặng 1
học từ C1/C6/C7 chứ không từ chat, nên KY2/GI7/GI3 chính là ba cái vòi đổ dữ liệu
vào C6. Không có chúng chạy sớm thì lời mời G-b — *"đây là 12 chỗ anh đã ghi lại để
đưa em đi"* — không có gì để trưng ra. Chúng chịu lực.

### Ghi trung thực về lối B

- **Giá thật (D10-3):** bốn mục dựng hai lần, bản một người rồi bản cặp đôi. Theo
  G-e đó là cùng một đối tượng ở hai chế độ, nên nếu M2 làm đúng thì lần hai là mở
  rộng chứ không viết lại. Chính vì thế M2 phải ở đợt 0, không phải giữa phase.
- **Lợi ích bị đánh giá thấp (D10-2):** B tự nuốt nửa rẻ của lối C — không tính năng
  mới nào bị khoá cứng vào `coupleId`, nên cảnh báo lãi-kép-ngược D9-4 tan.
- **Rủi ro không né được (D10-6):** không kiểm chứng được gì trước khi trả M2. Giảm
  thiểu duy nhất là kiểm thử L1 ở cuối đợt 1 — nếu chặng 1 không tự đứng được thì
  dừng, đừng sang đợt 2.

## Phần H (đã chạy c11) — Kết quả vòng đào AI

`WebSearch` x6, không lỗi công cụ. Chi tiết + nguồn ở `development.md` § Research Notes.

| Mã | Phát hiện | Hệ quả |
|---|---|---|
| **H-R1** ⚠️⚠️⚠️ | *Science*: 11/11 hệ AI đều nịnh; xác nhận lập luận sai trong **73%** kịch bản; **một lần tương tác đủ khiến người ta ít xin lỗi và ít sửa hành vi trong xung đột quan hệ**; người dùng thấy AI nịnh **đáng tin hơn** | R-1 có bằng chứng thực nghiệm |
| **H-R2** ⚠️⚠️ | Luật BVDLCN hiệu lực 01/01/2026. NĐ 356/2025: **đời sống và xu hướng tình dục = dữ liệu nhạy cảm**. Cấm đọc tin nhắn khi chưa đồng ý. Hậu kiểm chuyển dữ liệu xuyên biên giới | G-1 chạm cả ba điều cùng lúc |
| **H-R3** | 3-10B chạy được trên máy; Q4 giữ 95%+ năng lực; Apple Intelligence ~3B on-device; llama.cpp/MLC-LLM/Core ML đã chín | Đường thoát cho G-1 |
| **H-R4** ⚠️ | Gợi ý hoạt động ~**$0.003-0.02**/người/tháng. Đọc chat ~**$0.60-15**/người/tháng. Chênh 100-1000x | Toàn bộ chi phí nằm ở G-1 |
| **H-R5** | VN chi $549.9M cho app (2023), tương tác cao nhưng khó chuyển thành doanh thu. **Không tìm được số sẵn sàng chi trả của sinh viên VN** | Khoảng trống, không suy diễn |
| **H-R6** | **19%** hào hứng với AI (2026), giảm từ 50%. 54% mệt mỏi vì AI. ⚠️ dữ liệu US/UK/CA | AI không còn là điểm bán |
| **H-R7** | CoupleWork/Connected/Lovon/Smush đều bán AI phân tích **con người** | Họ đứng đúng chỗ H-R1 nói là hại |

### Kết luận

- ⭐⭐⭐ **D11-1: R-1 vừa biến từ lập trường đạo đức thành hàng rào an toàn kỹ thuật.**
  Nịnh hót là chế độ hỏng mặc định khi AI làm việc trên con người. Khi AI làm việc trên
  **hoạt động**, bề mặt để nịnh gần như bằng không — nịnh về một quán phở không hại ai.
- ⚠️ **D11-2: G-1 là chỗ bốn rủi ro chồng lên nhau** — chi phí 100-1000x, chuyển dữ
  liệu nhạy cảm xuyên biên giới, rủi ro pháp lý đọc tin nhắn, và bề mặt nịnh lớn nhất.
  Không tính năng nào khác có mật độ rủi ro như vậy.
- ⭐ **AI-1 (luật mới đề nghị chốt): AI đọc chat chỉ được TRÍCH XUẤT hoạt động, không
  được MÔ TẢ con người.** Ràng bằng structured output/JSON schema ở tầng API — hàng rào
  **cưỡng chế được**, không phải lời hứa. Biến R-1 thành kiến trúc.
- ⭐ **D11-4: "chế độ không-AI" không phải một chế độ.** Xây fix cứng trước, AI là lớp
  phủ → tắt AI = rơi về preset, chi phí bằng không. Xây AI trước thì nó thành việc phải
  làm thêm. Cùng lập luận cấu trúc với M2-ở-đợt-0.
- **D11-5: đợt 1 KHÔNG có AI.** (a) G-1 đã chốt chặng 1 không học từ chat · (b) nội
  dung hoạt động/dịp lễ Việt hữu hạn, biên tập tay được · (c) H-R6 · (d) bỏ luôn câu
  hỏi pháp lý khỏi lần ship đầu.
- **D11-6: AI vào từ đợt 3-4, chỉ trên hoạt động.** ~$0.003-0.02/người/tháng.
- **D11-7: động tới chat thì chạy trên máy, hoặc không làm.** Đường lui đúng là **bỏ
  tính năng**, không phải "gửi lên server".
- **D11-8: không marketing đây là app AI.** Bán "chỗ ghi lại và lên kế hoạch".


## Phần K — Chặng 1 solo đào sâu (c12): kiểm kê, nỗi đau theo vai, phễu chuyển chặng

### K.1 — Chặng 1 hiện có đúng những gì

| # | Mã | Ở dạng một người | Giá trị ngày 1 (0 dữ liệu) |
|---|----|------------------|----------------------------|
| 1 | C1 | Danh sách hoạt động muốn làm cùng người ấy | Hộp rỗng |
| 2 | C6 | Nhật ký riêng / thư chưa gửi | Hộp rỗng |
| 3 | BD2 | Lịch dịp Việt (20/10, 8/3, Tết, Valentine, Noel) | **Có ngay** |
| 4 | KY2 | Câu hỏi mỗi ngày, trả lời một mình | Một câu |
| 5 | GI7 | Cuối ngày hôm nay thế nào | Hộp rỗng |
| 6 | GI3 | Nghĩ về người ấy — ghi một khoảnh khắc | Hộp rỗng |
| 7 | — | Onboarding + chọn chế độ (`onboarding/`, `pairing/` đã có code) | Không phải giá trị |
| 8 | C0/G-b | Khoảnh khắc mời | Chưa dùng được ngày 1 |

**⚠️ D12-1 — chỗ tôi đã bỏ sót suốt c9-c11:** L1 nói "sản phẩm hoàn chỉnh kể cả người kia
không bao giờ vào", nhưng **không** nói "hoàn chỉnh **ngay từ đầu**". Sáu tính năng, bốn
là log một chạm, **năm trong tám ô bắt đầu bằng hộp rỗng**. Đường giá trị là thuần tích
luỹ ⇒ retention-first, **không có móc câu ngày 1**. Khoảng trống ngày-1-tới-ngày-30 là
chỗ người dùng chết, và nó nằm **trước** mọi thứ ta đã tối ưu.

### K.2 — Nỗi đau theo vai (đây là phần user hỏi "từng người")

| Mã | Vai | Nỗi đau | Bằng chứng |
|----|-----|---------|-----------|
| CS-P1 | Người rủ | Không biết **bước tiếp theo** là gì — JTBD thật của chặng 1 | RS5 |
| CS-P2 | Người rủ | **Không có ai để hỏi.** Hệ thống hỗ trợ của nam xoay quanh quan hệ tình cảm, ít bộc lộ ra ngoài ⇒ **C6 là tính năng chịu lực với nam** | R12-3 (Pew 2024, n=6,204 + Stanford) |
| CS-P3 | Người rủ | **Sợ hỏng chuyện khi rủ.** 44% nam nói nỗi sợ làm giảm khả năng chủ động liên lạc; 83% nam / 76% nữ lo lắng mức vừa-tới-rất | R12-1 |
| CS-P4 | Người được rủ | **Chủ động thì bị đọc sai** — kỳ vọng tình dục phía kia tăng khi mình chủ động ⇒ nỗi đau là **hiệu chỉnh tín hiệu**, không phải **lên kế hoạch**. ⚠️ Giả thuyết, chưa có dữ liệu VN | R12-2 |
| CS-P5 | Người được rủ | Đang theo dõi một người **mình chưa chắc chắn** — cần chỗ ghi mà không cam kết. Khung "nhật ký tình yêu" hỏng việc này; khung "sổ tay riêng" thì được | suy luận từ R12-2 |
| CS-P6 | **Cả hai, ở lúc chuyển chặng** | **Gánh nặng đổi vai** (D12-2). Nỗi đau này **chưa từng được liệt kê** trong toàn bộ idea trước c12 | R12-4 (ASR 2019, Sex Roles 2020) |
| CS-P7 | Rủi ro do chính ta tạo | App thành ống xả duy nhất ⇒ **làm nặng thêm** đúng vấn đề nghiên cứu mô tả | R12-3(b) |

### K.3 — ⭐ D12-2: gánh nặng đổi vai đúng lúc app đổi chế độ

- Chặng 1 = gánh **khởi xướng** (nghĩ ra làm gì, rủ thế nào, sợ bị từ chối) — thống kê
  nghiêng nam.
- Chặng 2+ = gánh **duy trì** (mental load, kin-keeping, nhớ, sắp, tổ chức) — thống kê
  nghiêng nữ. ASR 2019: nữ làm nhiều cognitive household labor hơn đáng kể. 2025: mẹ báo
  cáo nhiều hơn **67%** khối lượng quản lý. Sex Roles 2020: nữ là **kin-keeper**, duy trì
  quan hệ cho **cả họ hàng bên người kia**.
- ⇒ **Failure mode nghiêm trọng nhất chưa được chặn:** build chặng 1 phục vụ người khởi
  xướng, rồi build chặng 2 **cũng** phục vụ người khởi xướng ⇒ người còn lại thành **người
  vận hành app không công**. Đó là mankeeping được số hoá, do ta viết ra.
- ⇒ **Lời hứa giá trị phải khác nhau ở hai chặng.** Chặng 1 gỡ gánh *khởi xướng*; chặng 2
  gỡ gánh *duy trì*. Đây là lý do CS11 tồn tại.

### K.4 — ⭐ D12-3: đề xuất rẽ theo VAI, không rẽ theo GIỚI (chờ user quyết)

User hỏi customize theo Nam/Nữ. Tôi đề nghị đổi trục, với ba lý do kiểm chứng được:

1. **Tiền đề phổ biến nhất đã bị bác.** Pew 2024 (n=6,204): nam **không** ít bạn thân
   hơn, cô đơn **không** khác nhiều theo giới. Khác biệt là *hành vi dùng mạng lưới*,
   không phải *cấu trúc mạng lưới*. Thiết kế theo "nam cô đơn hơn" sẽ sai ngay từ tiền đề.
2. **Thiểu số bị sai là rất lớn.** 50-75% phụ nữ đã từng chủ động. Rẽ tính năng theo giới
   = đoán sai với khoảng một nửa người dùng nữ, và mã hoá đúng cái định kiến mà chính báo
   VN nói vẫn đặt con gái ở thế yếu.
3. **Không có dữ liệu VN để rẽ đúng.** Không tìm được số liệu đương đại về ai trả tiền /
   ai chủ động ở VN. Rẽ theo giới ở đây là **đoán**, không phải thiết kế.

**Đề xuất:** giới chỉ dùng cho **ngôn ngữ** (BD1 anh/em — đã chốt, giữ nguyên). Trục
customize là **vai**: *đang rủ* vs *đang được rủ*, tự khai bằng một câu không hỏi giới
hoặc suy từ hành vi. Vai **đổi được bất cứ lúc nào** và nên tự đề nghị đổi ở lúc chuyển
chặng (D12-2).

**Cái giá thật của đề xuất này (ghi trung thực):** vai phải hỏi thêm một câu hoặc phải
suy — tức thêm một bước onboarding hoặc thêm một chỗ đoán sai. Giới thì đã có sẵn từ BD1,
miễn phí. **Quyết định thuộc về user.**

**D12-4 — an toàn:** không làm "chế độ an toàn cho nữ". Chế độ theo giới sẽ **báo cho kẻ
kiểm soát biết ai có gì để giấu**. L2 đối xứng đã đúng; c12 xác nhận lại và ghi lý do.

### K.5 — Phễu chuyển chặng có ba chỗ rơi, hiện chỉ một chỗ được thiết kế

| Chỗ rơi | Nội dung | Trạng thái |
|---------|----------|-----------|
| 1 | Người dùng **có đủ thứ để mời** | ✅ đã thiết kế (D10-4, bốn vòi nạp) |
| 2 | Người dùng **dám mời** | ❌ chưa thiết kế (D12-6) |
| 3 | Người kia **nhận lời trong 60 giây đầu** | ❌ hoàn toàn chưa thiết kế (D12-7) |

**D12-6 — dám mời.** Lời mời **cũng là một hành vi chủ động**, nên nó chịu đúng 83%/76%
lo lắng của R12-1 và đúng cái giá của R12-2. Ta đang thiết kế G-b như một khoảnh khắc quà
tặng đẹp — đúng về cảm xúc, nhưng **bỏ qua việc người gửi phải dũng cảm**.

**D12-7 — ⭐ lỗ to nhất, và nó vô hình.** Không có **một** tính năng nào phục vụ người
được mời. Toàn bộ chặng 1 phục vụ người mời; toàn bộ chặng 2 giả định cả hai đã ở trong.
Người thứ hai chỉ tồn tại như một sự kiện `accept`. Lỗ này vô hình vì nó không nằm trong
chặng 1 cũng không nằm trong chặng 2 — **nó nằm ở đường nối, và không ai sở hữu đường
nối.** Ghi rõ: đây là suy luận từ phễu của ta; tìm bằng chứng ngoài không ra.

### K.6 — Ứng viên mới CS1-CS12

| Mã | Tên | Chữa | I/E |
|----|-----|------|-----|
| **CS2** | ⭐ **Mời vào một HOẠT ĐỘNG, không mời vào một MỐI QUAN HỆ.** Mặc định là *"đây là danh sách quán anh lưu, em chọn một chỗ đi"*, không phải *"vào app đôi với anh"*. Khớp hoàn hảo với R-1 và S7 | rơi 2 | 5/1 |
| **CS7** | ⭐ **Giao hàng kèm nội dung, không giao hộp rỗng.** Danh sách đến với nội dung VN biên tập sẵn (bám xu hướng vận động 2026 — pickleball, chạy bộ, gym). Người dùng **cắt bớt** thay vì **nghĩ ra**; curation dễ hơn generation cả bậc. **Lật ngược empty state ở §7.4 design brief** | D12-1 | 5/2 |
| **CS5** | ⭐ **Màn hình người thứ hai** là artifact thiết kế **có tên riêng**, không phải "màn đăng nhập". Không cài app vẫn xem được (S4/S7) ⇒ phải là web | rơi 3 | 5/3 |
| **CS6** | ⭐ **Hành động trước, tài khoản sau.** Người thứ hai chọn được một quán *trước khi* tạo tài khoản | rơi 3 | 5/3 |
| **CS11** | ⭐ **Bàn giao gánh nặng ở lúc chuyển chặng.** Tại C0, app **chia lại việc** rõ ràng và mặc định; danh sách chung + hai chìa khoá làm việc lên kế hoạch **nhìn thấy được và chia được**. Đây là can thiệp mental-load, và là **lời hứa giá trị của chặng 2 cho người mang gánh duy trì** | D12-2 | 5/3 |
| CS1 | **Diễn thử lời mời** — xem đúng màn hình người kia sẽ thấy, trước khi gửi | rơi 2 | 4/1 |
| CS3 | **Mời từng phần** — mời xem một danh sách, không mời xem cả app | rơi 2 + R8 | 4/2 |
| CS4 | **Rút lui im lặng** — không trả lời thì hết hạn lặng lẽ; **không** báo "đã xem", **không** đếm ngược cho người gửi. Bảo vệ thể diện — đúng cái R12-2 nói nữ thiếu và 44% nam sợ | rơi 2 | 4/1 |
| CS8 | **Đưa đếm ngược dịp Việt lên trước** — BD2 là thứ duy nhất có giá trị ở giây thứ 5 với 0 dữ liệu | D12-1 | 4/1 |
| CS10 | **Chuỗi tiến triển theo vai** (nối RS5). Vai *người rủ*: cà phê → ăn tối → hoạt động chung → gặp bạn bè. Vai *người được rủ*: chuỗi là **chọn và đáp lại**, không phải **khởi xướng** | D12-3 | 4/3 |
| CS12 | **Thời điểm nên mời** — từ dữ liệu của **chính người dùng** (đã lưu 12 chỗ, đã ghi 3 lần gặp). Không đọc người kia ⇒ trong R-1 | rơi 1→2 | 4/2 |
| CS9 | **Đẩy ra ngoài** — gợi "kể với một người bạn", không chỉ "ghi thêm vào đây" | L14 | 3/1 |

**Kiểm tra L3:** không ứng viên nào khoá tính năng để ép mời. Tất cả làm việc mời *dễ
hơn* và *đáng hơn*; không làm việc không-mời *đau hơn*.

### K.7 — Câu hỏi mở mới

- **OQ-12A.** Vai (*đang rủ* / *đang được rủ*) nên **tự khai một câu** hay **suy từ hành
  vi**? Tự khai: chính xác, tôn trọng, nhưng thêm một bước onboarding. Suy: mượt, nhưng
  đoán sai rất khó chịu và khó sửa.
- **OQ-12B.** CS2 có làm **loãng** khoảnh khắc G-b không? G-b được thiết kế để là khoảnh
  khắc cảm xúc lớn; CS2 **cố tình hạ nó xuống** thành lời rủ nhẹ. Hai cái kéo ngược nhau
  và **tôi chưa giải được**. Có thể lời mời nhẹ đi nhưng *cái được mời vào* vẫn nặng.

### K.8 — Tự đính chính vòng 11

Ở c11 tôi nghiêng về L4 "giấu AI", dựa trên H-R6 — **dữ liệu US/UK/CA**, và tôi đã tự
cảnh báo không suy rộng ra VN. Vòng này có điểm dữ liệu VN đi **ngược lại**: 68% Gen Z VN
tin AI **gợi ý được chủ đề trò chuyện**, coi AI là trợ lý không phải người lái. ⇒ Nới L4
thành **"không lấy AI làm đầu bài"**. **R-1 và AI-1 không đổi** — chúng nói về *đối tượng*
AI được phép mô tả, không phải về việc lộ AI. Nguồn VN yếu hơn *Science* của H-R1, nên
đây là nới, không phải đảo.


## Phần L — Trục B: "mỗi bên chú ý gì ở đối phương" (c13, user đẩy lại)

User đưa hai ví dụ: *"Nam quan tâm xem Nữ có đến ngày đèn đỏ không"* · *"Nữ quan tâm
bạn Nam kia có tâm lý không"*.

### L.1 — Tôi trả lời sai câu hỏi ở c12 (D13-1)

Có **hai trục**, không phải một:

| | Trục | Câu hỏi | c12 xử lý? |
|---|---|---|---|
| **A** | **Ai khởi xướng** | đang rủ hay đang được rủ | ✅ D12-3 bác rẽ theo giới |
| **B** | **Chú ý gì ở đối phương** | mỗi bên nhìn cái gì ở người kia | ❌ **bỏ trống hoàn toàn** |

D12-3 chỉ bác **trục A**. Tôi đã trình bày như thể nó bác cả hai. **Trục B tồn tại thật.**

### L.2 — Nhưng cả hai ví dụ đều vi phạm R-1 trực tiếp (D13-2..D13-4)

R-1 không phải luật về *mức độ nhạy cảm*, nó là luật về **đối tượng**:
"đèn đỏ" = làm việc trên **cơ thể** người kia · "tâm lý" = làm việc trên **tính cách**
người kia. Cả hai lấy **con người** làm đối tượng.

**"Đèn đỏ" ở chặng 1 — bất khả thi về CẤU TRÚC, không phải về chính sách (D13-3):**
1. Người kia **không có tài khoản** ⇒ dữ liệu sức khoẻ/sinh sản của một người **hoàn
   toàn không đồng ý** nằm trong app của người khác. **Không có đường nào để thông báo
   hay xin đồng ý** — chủ thể dữ liệu còn không biết app tồn tại.
2. **Đã bị loại từ trước:** `design-brief.md` §9 — "đồng bộ chu kỳ và sức khoẻ (quá thân
   mật cho cặp mới yêu)".
3. **R13-1 pháp lý:** Luật BVDLCN hiệu lực 01/01/2026; NĐ 356/2025 (31/12/2025) thay NĐ
   13/2023, siết yêu cầu đồng ý; tình trạng sức khoẻ thuộc **dữ liệu nhạy cảm** và chủ
   thể **phải được thông báo** rằng đó là dữ liệu nhạy cảm. ⚠️ *Ghi trung thực:* văn bản
   diễn đạt theo hướng "ghi trong hồ sơ bệnh án" — một ghi chú tự gõ có rơi vào đó không
   là **câu hỏi tech-lead/pháp lý**, tôi không kết luận. **Lập luận chặn nằm ở cấu trúc
   đồng ý, không ở phân loại.**
4. **R13-2 vector R8:** văn liệu gọi thẳng *intimate partner surveillance*; các app chu
   kỳ được mô tả là *"instruments of power and control"*; báo cáo Cambridge gọi dữ liệu
   chu kỳ là "gold mine", nêu rủi ro cyberstalking.

**"Tâm lý" nếu làm thẳng — vi phạm BA luật cùng lúc (D13-4):** R-1 (mô tả con người) ·
XD2 (báo cáo hành vi người kia cho người này) · L13 (đặt hai người hai phía). Và H-R1:
một hệ thống phát biểu *"anh ấy có vẻ không tâm lý lắm"* là **đúng** chế độ hỏng đã đo
được trên *Science*.

### L.3 — ⭐⭐ D13-5: R-1 có tác dụng phụ theo giới mà ta chưa từng nhận ra

| Vai | JTBD | Hình dạng | R-1 |
|---|---|---|---|
| Người **rủ** | "bước tiếp theo làm gì" | **HOẠT ĐỘNG** | ✅ phục vụ trọn vẹn |
| Người **được rủ** | "người này có đáng không" | **CON NGƯỜI** | ❌ **cấm theo định nghĩa** |

⇒ Không làm gì thì chặng 1 thành **sản phẩm cho nam** — **do hình học của lưỡi dao, không
do chủ ý thiết kế**. Đây chính là cái user cảm thấy. **Cảm nhận đúng, chẩn đoán sai:**
nguyên nhân không phải "thiếu customize theo giới" mà là **R-1**.

### L.4 — ⭐ D13-6: ổ khoá là nguồn thứ ba

| # | Nguồn thông tin về người kia | Trạng thái |
|---|---|---|
| 1 | App suy đoán / phân tích / theo dõi | **R-1 cấm** |
| 2 | Người dùng tự quan sát và tự ghi | C6, đã có |
| 3 | **Người kia tự nói về chính mình** | **Chưa khai thác. Sạch R-1 hoàn toàn.** |

R-1 nói **trợ lý** không làm việc trên con người. Nó **không** nói con người không được
tự nói về mình. **Tự khai không phải giám sát — nó là điều ngược lại.**

### L.5 — Ứng viên GA1-GA4

| Mã | Tên | I/E |
|---|---|---|
| **GA2** | ⭐⭐ **App không nói cho cô ấy biết anh ấy có tâm lý không; app LÀM CHO anh ấy tâm lý hơn.** "Tâm lý" không phải đặc điểm để **đo**, nó là **hành vi dạy được**. App không giao được phiếu điểm (cấm, và nó đầu độc quan hệ) nhưng **giao được kết quả**: nhắc đúng lúc — *"hôm nay 20/10"*, *"hai tuần rồi chưa đi đâu"*, *"cô ấy nhắc quán này ba lần"*. Cùng một nhu cầu: một bên **phán xét**, một bên **huấn luyện**. **R-1 chặn đúng cái xấu, để nguyên cái tốt** | 5/2 |
| **GA1** | ⭐ **"Hôm nay đi nhẹ thôi" thay cho theo dõi chu kỳ.** Cái anh ấy muốn **không phải dữ liệu, mà là lời cảnh báo để khỏi làm hỏng việc**. Nếu app đưa thẳng cảnh báo — do **cô ấy** bật, là **trạng thái** không phải **dự đoán**, **tự hết hạn**, **không lịch sử**, **không nêu lý do** — anh ấy nhận **đúng** kết quả với **0 byte dữ liệu sức khoẻ**. Chỉ từ chặng 2. Dùng lại `vibes`/GI3 đã có. ⚠️ Ràng cứng: **không đếm, không chu kỳ hoá, không dự đoán lần sau** | 5/1 |
| **GA3** | **Giới rẽ được an toàn ở NỘI DUNG, không ở CƠ CHẾ.** 20/10, 8/3, ai tặng ai, tặng gì — nội dung này **buộc phải** biết giới và hoàn toàn vô hại. BD2 đã cần nó. Nhượng bộ thật với đề bài user | 4/1 |
| **GA4** | **Học từ hành vi của chính người dùng, không từ giới.** Anh ấy liên tục ghi *"hôm nay cô ấy có vẻ mệt"* ⇒ app biết **anh ấy** quan tâm điều đó, không cần biết giới ai. Nối CS10 | 4/3 |

### L.6 — ⭐ D13-7: cấu trúc giá trị hai chiều (lời giải cho D13-5)

**Cô ấy hưởng lợi từ những tính năng ANH ẤY dùng.** Sản phẩm cho người được rủ ở chặng 1
**không phải một bộ tính năng riêng** — nó là **kết quả của việc người rủ dùng app tốt**.
Chỉ nhìn ra được khi thôi hỏi *"tính năng nào cho giới nào"*. Vá đúng D13-5 mà **không
phá R-1 lần nào**.

### L.7 — Câu hỏi mở

- **OQ-13A (chưa giải).** Cho cô ấy đọc lại **chính chữ cô ấy đã viết** về anh ấy —
  *"ba tuần qua em ghi 4 lần 'anh ấy quên'"* — là **tự soi** hay **app dựng hồ sơ buộc
  tội**? Tôi nghiêng về sạch R-1 (dữ liệu của cô ấy, chữ của cô ấy, app không diễn giải,
  không chấm điểm, không khuyến nghị). Nhưng khoảng cách tới *"đây là 4 dấu hiệu đỏ"* chỉ
  là **một dòng UI**, và L14 nói đúng lúc đó app nên bảo *"kể với một người bạn đi"* chứ
  không tự đóng vai người bạn.
- **OQ-13B (cần user quyết, = A-18).** §9 đã **loại** "đồng bộ chu kỳ và sức khoẻ". GA1
  **không** phải mở lại nó. Muốn mở lại **bản đầy đủ** cho chặng 2 thì phải nói rõ — đó
  là đảo một quyết định đã chốt, kéo theo NĐ 356/2025 + vector R8.
