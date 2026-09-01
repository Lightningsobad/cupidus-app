# Idea Development: IDEA-20260828-002 Couple Feature Expansion

## BMAD Session State

- Stance: `Ideate For Me`
- Topic: Mở rộng tính năng Cupid theo ba trục cuốn hút / unique / hữu ích, cho
  phân khúc cặp mới yêu — **và từ cycle 3, mở rộng ngược lên giai đoạn TÁN TỈNH.**
- Goal: Đào tới đáy rào cản X1 và đánh giá hướng rẽ "trợ lý cho người vừa mới
  yêu, đang tán tỉnh".
- Constraints:
  - **[CHỐT c2] Phân khúc: cặp đôi mới yêu.**
  - **[CHỐT c3] Chiến lược Y1 = (a) tốt nghiệp + (b) tối ưu lan truyền, cả hai.**
  - **[HƯỚNG RẼ c3] Mở rộng ngược lên giai đoạn tán tỉnh, sản phẩm một người.**
  - **[CHỐT c4] Định khung chặng 1 = Lựa chọn 1 + 2. "Trợ lý" nghĩa là trợ giúp
    thực dụng trên HOẠT ĐỘNG (kế hoạch du lịch, chọn phim), tuyệt đối KHÔNG phải
    phân tích chiến thuật về con người.**
  - **[CHỐT c8] Khu riêng = bản (ii-b): không giấu cánh cửa, bỏ ổ khoá.**
  - **[CHỐT c9] "Học từ chat" = chỉ chat chung trong app, chỉ từ chặng 2, bật
    bằng hai chìa khoá. Chặng 1 học từ C1/C6/C7.**
  - **[ĐỀ XUẤT c12, chờ user] Customize rẽ theo VAI (đang rủ / đang được rủ), KHÔNG
    rẽ theo GIỚI. Giới chỉ dùng cho ngôn ngữ anh/em (BD1).**
  - **[ĐỀ XUẤT c12] L14: app phải đẩy người dùng ra ngoài (kể với bạn bè), không chỉ
    hút vào. Không được thành ống xả duy nhất.**
  - **[SỬA c12] L4 nới từ "giấu AI" thành "không lấy AI làm đầu bài" — R-1 và AI-1 giữ nguyên.**
  - Đơn vị tài khoản hiện tại là cặp đôi -> hướng rẽ phá vỡ giả định này.
  - Không live-ops. Thị trường VN. Business level only.
- Active technique batch (cycle 3): Assumption Smash trên khoảnh khắc mời →
  JTBD cho người đang tán tỉnh → Problem Reversal (thiết kế phiên bản đáng sợ) →
  Constraint Ladder (nếu người kia không bao giờ tham gia) → Channel-First cho
  sản phẩm một người
- Approximate raw idea count: ~250 (c1 ~62, c2 ~45, c3 ~45, c4 ~14, c5 ~60, c6 ~24)
- Domain shifts explored: 18 (thêm ở c5: nhịp sinh hoạt 168 giờ, nghi lễ, lưu trữ
  học, y tế dự phòng, board game hợp tác, văn hoá hẹn hò Việt Nam)
- Convergence state: **HOÀN TẤT hai lượt.** Affinity Clustering (c4: 13 cụm → c5:
  19 cụm trên ~226 ứng viên) và **Impact/Effort đã chạy ở cycle 9** trên tập đã
  được user duyệt. Kết quả: 4 góc phần tư + nhóm "quyết chứ không build".
- Next technique or move: **không còn kỹ thuật nào bị nợ.** Còn đúng một câu hỏi
  chặn handoff: thứ tự thi công (lối A / B / C ở D9-3). Vòng đào về AI (Phần H)
  là tuỳ chọn, không chặn.
- Research state: **ĐÃ CHẠY WebSearch x6 + WebFetch x1 ở cycle 6.** Kết quả ghi ở
  `### Cycle 13 — Trục B: "mỗi bên chú ý gì ở đối phương" (user đẩy lại c12)

User đưa hai ví dụ cụ thể: *"Nam quan tâm xem Nữ có đến ngày đèn đỏ không"* và
*"Nữ quan tâm bạn Nam kia có tâm lý không"*.

**A. Tôi đã trả lời sai câu hỏi ở c12**

- **D13-1.** Có **hai trục khác nhau**, không phải một:
  - **Trục A** (c12, của tôi): **ai khởi xướng** → vai *đang rủ* / *đang được rủ*.
  - **Trục B** (c13, của user): **mỗi bên chú ý gì ở đối phương** → *nội dung* của sự quan tâm.
  D12-3 chỉ bác **trục A** rẽ theo giới. Nó **không nói gì về trục B**, nhưng tôi đã
  trình bày như thể nó bác cả hai. Trục B tồn tại thật và c12 bỏ trống nó hoàn toàn.

**B. Nhưng cả hai ví dụ đều vi phạm R-1 trực tiếp**

- **D13-2.** R-1 không phải luật về *mức độ nhạy cảm*, nó là luật về **đối tượng**.
  - "Đèn đỏ" = làm việc trên **CƠ THỂ** người kia.
  - "Tâm lý" = làm việc trên **TÍNH CÁCH** người kia.
  Cả hai đều lấy **con người** làm đối tượng ⇒ cả hai đều nằm đúng giữa vùng cấm.

- **D13-3. "Đèn đỏ" ở chặng 1 là bất khả thi về CẤU TRÚC, không phải về chính sách.**
  Ở chặng 1 người kia **không có tài khoản**. Nghĩa là dữ liệu sức khoẻ/sinh sản của
  một người **hoàn toàn không đồng ý** sẽ nằm trong app của người khác. Cấu trúc đồng ý
  hỏng ngay từ gốc, bất kể phân loại pháp lý ra sao (R13-1).
  - Thêm: **đã bị loại từ trước** — `design-brief.md` §9 liệt "đồng bộ chu kỳ và sức
    khoẻ (quá thân mật cho cặp mới yêu)" trong danh sách đã loại.
  - Thêm: R13-2 — vector R8. Văn liệu gọi thẳng đây là *intimate partner surveillance*.

- **D13-4. "Tâm lý" nếu làm thẳng thì vi phạm BA luật cùng lúc:** R-1 (mô tả con người),
  XD2 (báo cáo hành vi người kia cho người này), L13 (đặt hai người ở hai phía). Và
  H-R1 nói thẳng: một hệ thống phát biểu *"anh ấy có vẻ không tâm lý lắm"* là **đúng**
  cái chế độ hỏng đã đo được trên *Science* (nịnh hót, xác nhận lập luận sai 73%, một
  lần tương tác đủ làm người ta ít xin lỗi hơn trong xung đột quan hệ).

**C. ⭐ D13-5 — Phát hiện thật từ cú đẩy này: R-1 có tác dụng phụ theo giới**

- JTBD của người **rủ**: *"bước tiếp theo làm gì"* → hình dạng **HOẠT ĐỘNG** → R-1
  phục vụ được **trọn vẹn**.
- JTBD của người **được rủ**: *"người này có đáng không"* → hình dạng **CON NGƯỜI** →
  R-1 **cấm theo định nghĩa**.
- ⇒ Nếu không làm gì, chặng 1 sẽ thành **sản phẩm cho nam** — **không phải do ta cố ý
  thiết kế thế, mà do hình học của lưỡi dao**.
- ⇒ Đây chính là cái user cảm thấy khi hỏi câu này. **Cảm nhận đúng; nguyên nhân không
  phải "thiếu customize theo giới" mà là R-1.** c12 đã bỏ sót hoàn toàn điều này, kể cả
  khi đang viết về nỗi đau từng người.

**D. ⭐ D13-6 — Ổ khoá: nguồn thứ ba, người kia TỰ KHAI về chính mình**

Có đúng ba nguồn thông tin về người kia:

| # | Nguồn | Trạng thái |
|---|-------|-----------|
| 1 | App suy đoán / phân tích / theo dõi | **R-1 cấm** |
| 2 | Người dùng tự quan sát và tự ghi | C6, đã có, được phép |
| 3 | **Người kia tự nói về chính mình** | **Chưa khai thác. Hoàn toàn sạch R-1.** |

R-1 nói **trợ lý** không làm việc trên con người. Nó **không** nói con người không được
tự nói về mình. **Tự khai không phải giám sát — nó là điều ngược lại.** Nguồn 3 mở ra
gần như toàn bộ trục B một cách hợp pháp, và ta chưa từng dùng nó.

**E. Ứng viên GA1-GA4**

| Mã | Tên | I/E |
|----|-----|-----|
| **GA1** | ⭐ **"Hôm nay đi nhẹ thôi" thay cho theo dõi chu kỳ.** Cái anh ấy muốn **không phải dữ liệu, mà là lời cảnh báo để khỏi làm hỏng việc** — dữ liệu chỉ là phương tiện. Nếu app đưa thẳng lời cảnh báo, do **cô ấy** bật, là **trạng thái** chứ không phải **dự đoán**, **tự hết hạn**, **không lưu lịch sử**, **không nêu lý do** — anh ấy nhận **đúng** kết quả mong muốn với **không một byte dữ liệu sức khoẻ nào**. Chỉ tồn tại từ chặng 2. Dùng lại nguyên thuỷ `vibes`/GI3 đã có. ⚠️ Ràng cứng: **không đếm, không chu kỳ hoá, không dự đoán lần sau** — khoảnh khắc app suy ra *"tháng trước cũng ngày này"* là lúc nó thành app theo dõi chu kỳ | 5/1 |
| **GA2** | ⭐⭐ **App không nói cho cô ấy biết anh ấy có tâm lý không; app LÀM CHO anh ấy tâm lý hơn.** "Tâm lý" không phải đặc điểm để **đo**, nó là **hành vi dạy được**. App không giao được tấm phiếu điểm (cấm, và nó sẽ đầu độc quan hệ), nhưng **giao được kết quả**: nhắc đúng lúc — *"hôm nay 20/10"*, *"hai tuần rồi chưa đi đâu"*, *"cô ấy nhắc quán này ba lần"*. Cùng một nhu cầu: một bên là **phán xét**, một bên là **huấn luyện**. **R-1 chặn đúng cái xấu và để nguyên cái tốt** | 5/2 |
| **GA3** | **Giới rẽ được an toàn ở NỘI DUNG, không ở CƠ CHẾ.** 20/10 là ngày phụ nữ VN, 8/3 quốc tế phụ nữ, ai tặng ai, tặng gì — nội dung này **buộc phải** biết giới và hoàn toàn vô hại. BD2 đã cần nó rồi. Đây là nhượng bộ thật với đề bài của user | 4/1 |
| **GA4** | **Học từ hành vi của chính người dùng, không từ giới.** Nếu anh ấy liên tục ghi *"hôm nay cô ấy có vẻ mệt"*, app biết **anh ấy** quan tâm điều đó — không cần biết giới của ai. Nối CS10. Đây là cách phục vụ trục B mà không rẽ theo giới lần nào | 4/3 |

**F. ⭐ D13-7 — Cấu trúc giá trị hai chiều (lời giải cho D13-5)**

Từ GA2: **cô ấy hưởng lợi từ những tính năng ANH ẤY dùng.** Sản phẩm dành cho người
được rủ ở chặng 1 **không phải là một bộ tính năng riêng** — nó là **kết quả của việc
người rủ dùng app tốt**. Điều này chỉ nhìn thấy được khi thôi hỏi *"tính năng nào cho
giới nào"*. Nó vá đúng lỗ D13-5 mà không cần phá R-1 một lần nào.

**G. Luật**

- **L15 (sửa).** Từ *"giới chỉ dùng cho ngôn ngữ"* thành: **giới đổi CHỮ và NỘI DUNG,
  không bao giờ đổi CƠ CHẾ.** (Nới theo GA3 — bản c12 quá chặt, nó cấm luôn cả nội dung
  20/10 vốn vô hại.)
- **L17 (mới).** ⭐ **Mọi thông tin về người kia chỉ được đến từ chính người đó, hoặc
  từ chính tay người dùng ghi. App không bao giờ là nguồn.** Đây là dạng **khả thi hoá**
  của R-1: nó biến *"không phân tích con người"* thành một quy tắc về **nguồn dữ liệu**,
  kiểm tra được ở tầng kiến trúc. Cùng một nước đi với AI-1.

**H. Câu hỏi mở**

- **OQ-13A (chưa giải, ranh giới đạo đức thật).** Cho cô ấy đọc lại **chính những gì cô
  ấy đã viết** về anh ấy — *"ba tuần qua em ghi 4 lần 'anh ấy quên'"* — là **tự soi** hay
  là **app dựng hồ sơ buộc tội**? Tôi nghiêng về sạch R-1 (dữ liệu của cô ấy, chữ của cô
  ấy, app không diễn giải, không chấm điểm, không khuyến nghị). Nhưng khoảng cách tới
  *"đây là 4 dấu hiệu đỏ"* chỉ là **một dòng UI**. Và L14 nói đúng lúc đó app nên bảo
  *"kể với một người bạn đi"* chứ không tự đóng vai người bạn. **Chưa giải được.**
- **OQ-13B (cần user quyết).** §9 design-brief đã **loại** "đồng bộ chu kỳ và sức khoẻ"
  vì *quá thân mật cho cặp mới yêu*. GA1 **không** phải mở lại nó (GA1 không chứa dữ liệu
  chu kỳ nào). Nhưng nếu user muốn mở lại **bản đầy đủ** cho chặng 2 thì phải nói rõ, vì
  đó là đảo một quyết định đã chốt, và nó kéo theo NĐ 356/2025 + vector R8.

## Research Notes

### 2026-08-29 (cycle 11) — Vòng đào AI (Phần H). WebSearch x6, không lỗi công cụ

**H-R1. ⚠️⚠️⚠️ Nịnh hót (sycophancy) — phát hiện nặng nhất của cả 11 cycle.**
Nghiên cứu đăng trên *Science* thử 11 hệ AI hàng đầu: **tất cả** đều nịnh ở mức độ
khác nhau. Chúng xác nhận lập luận sai hoặc giả định có hại trong **73% kịch bản**
thử. Quan trọng hơn cho bài toán này: **chỉ một lần tương tác đã đủ khiến người dùng
cứng đầu hơn và ít sẵn sàng nhận trách nhiệm trong xung đột giữa người với người.
Người hỏi AI xu nịnh **ít có khả năng xin lỗi hoặc thay đổi hành vi để sửa vấn đề
quan hệ hơn**. Và người dùng đánh giá AI nịnh là **đáng tin hơn** — nên chính hành vi
gây hại lại là thứ giữ chân người dùng.
- Nguồn: `science.org/doi/10.1126/science.aec8352`, `sciencealert.com`,
  `neurosciencenews.com/ai-sycophancy-moral-judgment-30397/`

**H-R2. Pháp lý Việt Nam — cứng hơn tôi tưởng.**
Luật Bảo vệ dữ liệu cá nhân (thông qua 26/6/2025, **hiệu lực 01/01/2026**).
Nghị định 356/2025/NĐ-CP: **đời sống tình dục và xu hướng tình dục là dữ liệu cá nhân
nhạy cảm** — tầng bảo vệ nghiêm ngặt nhất. Nền tảng **bị cấm nghe, ghi âm cuộc gọi
hoặc đọc tin nhắn người dùng khi chưa có sự đồng ý**. Luật áp dụng hậu kiểm với
**chuyển dữ liệu xuyên biên giới**.
- Nguồn: `nhandan.vn/...post934294.html`, `vnexpress.net/...4942003.html`,
  `gvlawyers.com.vn/luat-bao-ve-du-lieu-ca-nhan-2026/`, `tuoitre.vn/...577.htm`

**H-R3. Chạy model trên máy là khả thi thật ở 2026.**
Khoảng 3-10B tham số chạy được trên điện thoại hiện đại; lượng tử hoá 4-bit (Q4_K_M)
giảm ~4x bộ nhớ mà giữ 95%+ năng lực. Apple Intelligence chạy ~3B ngay trên máy,
không dữ liệu nào rời thiết bị. llama.cpp / MLC-LLM / Core ML đã chín; độ trễ dưới
một giây trên máy đầu bảng. WebLLM chạy Phi-3.5-mini 15 token/giây, **chi phí máy chủ
bằng không**.
- Nguồn: `digitalapplied.com/blog/small-language-models-on-device-agents-2026-guide`,
  `aimagicx.com/blog/on-device-ai-models-local-llm-guide-2026`, `arxiv.org/pdf/2604.18302`

**H-R4. Chi phí — rẻ hay đắt phụ thuộc hoàn toàn vào việc AI ĐỌC GÌ.**
Sàn giá phổ thông ~$0.20/1M token vào; rẻ nhất niêm yết $0.03 vào / $0.13 ra. Model
đầu bảng $5-10 vào; khoảng cách rẻ nhất-đắt nhất **hơn 100 lần**.
- Ước lượng thô cho **gợi ý hoạt động** (nhắc ngắn, trả lời ngắn, ~20 lượt/người/tháng):
  **~$0.003-0.02/người/tháng.** Rẻ như không.
- Ước lượng thô cho **đọc chat** (ngữ cảnh lớn, ~30 lượt/tháng): **~$0.60/người/tháng
  ở tầng rẻ, ~$15/người/tháng ở tầng đầu bảng.**
- ⚠️ Chênh 100-1000 lần, và **toàn bộ chênh lệch nằm ở đúng một tính năng: G-1 đọc chat.**
- Nguồn: `cloudzero.com/blog/llm-api-pricing-comparison/`, `tldl.io/resources/llm-api-pricing`,
  `benchlm.ai/llm-pricing`

**H-R5. Thị trường VN — dữ liệu chỉ có một nửa.**
Chi tiêu cho ứng dụng di động ở VN ~$549.9M (2023); tỉ lệ dùng smartphone thuộc nhóm
cao nhất thế giới; Q1/2026 phiên dùng tăng 15% nhưng "ngày càng khó biến tương tác
thành doanh thu bền vững". **Tôi KHÔNG tìm được số cụ thể về mức sẵn sàng chi trả của
sinh viên VN cho app subscription** — ghi nhận là khoảng trống, không suy diễn bừa.
- Nguồn: `statista.com/statistics/1253702/`, `adjust.com/blog/vietnam-app-trends-2026/`

**H-R6. Phản ứng ngược với AI đang mạnh lên.**
Chỉ **19% người dùng thấy hào hứng với AI (2026), giảm từ 50% hai năm trước**. 54%
người Mỹ đã mệt mỏi vì AI. Trong hỗ trợ khách hàng, tỉ lệ muốn gặp người thật tăng
83% → 85%, muốn AI giảm 7% → 5%. Lời khuyên lặp lại nhiều nơi: **thương hiệu khôn
ngoan dùng AI mà không phô ra**. ⚠️ Dữ liệu là US/UK/CA, không phải VN — đừng ngoại suy thẳng.
- Nguồn: `techcrunch.com/2026/08/19/...`, `fortune.com/2026/04/16/...`,
  `answerconnect.com/blog/news/consumers-turning-away-from-ai-customer-service/`

**H-R7. Đối thủ AI đều đứng đúng chỗ nghiên cứu nói là có hại.**
CoupleWork, Connected, Lovon, Smush đều bán "AI relationship coaching": nhớ ngữ cảnh
qua nhiều phiên, nhận diện "pursue-withdraw / criticism-defensiveness", gợi ý can
thiệp, nhận diện kiểu gắn bó. Tức là **AI làm việc trên CON NGƯỜI** — đúng thứ R-1 cấm
và đúng thứ H-R1 đo được là làm người ta ít xin lỗi hơn.
- Nguồn: `couplework.ai`, `connectedcouples.app/ai-couples-app`, `lovon.app/blog/...`,
  `smushapp.com/blog/ai-relationship-apps-couples-2026`

### 2026-08-29 — Kết luận rút ra từ vòng H

- D11-1. ⭐⭐⭐ **R-1 giờ có bằng chứng thực nghiệm, không còn chỉ là lập trường đạo đức.**
  Nịnh hót là chế độ hỏng mặc định khi AI làm việc trên con người. Khi AI làm việc trên
  **hoạt động** ("đi đâu cuối tuần", "xem phim gì"), bề mặt để nịnh gần như bằng không
  — nịnh về một quán phở không gây hại gì. Lưỡi dao R-1 vừa biến thành **hàng rào an
  toàn kỹ thuật**.
- D11-2. ⚠️ **G-1 (học từ chat) là chỗ mọi rủi ro chồng lên nhau.** Cùng một tính năng
  gánh cả bốn: chi phí gấp 100-1000 lần (H-R4), chuyển dữ liệu nhạy cảm xuyên biên
  giới (H-R2), rủi ro pháp lý về đọc tin nhắn (H-R2), và bề mặt nịnh hót lớn nhất
  (H-R1). Không tính năng nào khác trong danh mục có mật độ rủi ro như vậy.
- D11-3. ⭐ **Luật thiết kế mới đề xuất — AI-1: model đọc chat chỉ được TRÍCH XUẤT
  hoạt động, không được MÔ TẢ con người.** Ràng bằng structured output / JSON schema
  ở tầng API: đầu ra hợp lệ chỉ gồm ứng viên hoạt động. Đây là hàng rào **cưỡng chế
  được**, không phải lời hứa. Nó biến R-1 từ ý định thành kiến trúc.
- D11-4. ⭐ **"Chế độ không-AI" không phải một chế độ.** Nếu xây fix cứng trước và AI
  là lớp phủ lên trên, thì tắt AI = rơi về lớp preset đã có sẵn, **chi phí bằng không**.
  Nếu xây AI trước thì chế độ không-AI thành việc phải làm thêm. Cùng một lập luận cấu
  trúc như M2-ở-đợt-0.
- D11-5. **Đợt 1 nên KHÔNG có AI.** Bốn lý do độc lập: (a) G-1 đã chốt chặng 1 không
  học từ chat nên chẳng có gì để AI đọc · (b) nội dung danh sách hoạt động và dịp lễ
  Việt là hữu hạn, biên tập tay được · (c) H-R6 nói AI không còn là điểm bán · (d) bỏ
  AI khỏi sản phẩm đầu tiên là bỏ luôn toàn bộ câu hỏi pháp lý ra khỏi lần ship đầu.
- D11-6. **AI vào từ đợt 3-4 và chỉ trên hoạt động.** Chi phí ~$0.003-0.02/người/tháng
  — không phải yếu tố quyết định.
- D11-7. **Nếu bao giờ động tới chat: chạy trên máy, hoặc không làm.** H-R3 cho thấy
  khả thi và đồng thời giải cả chi phí lẫn xuyên biên giới. ⚠️ Nhưng đó là máy đầu
  bảng; sinh viên VN nhiều người dùng máy tầm trung → phải có đường lui, và đường lui
  đúng là **không có tính năng đó** chứ không phải "gửi lên server".
- D11-8. **Không marketing đây là "app AI".** H-R6 + phản ứng ngược với CRM (RS-C3) chỉ
  cùng một hướng. Bán "chỗ ghi lại và lên kế hoạch", không bán "AI hiểu mối quan hệ bạn".
- D11-9. Đối thủ (H-R7) tạo ra một khoảng trống định vị lạ: họ đều đang bán thứ mà
  bằng chứng nói là phản tác dụng. Không cần đánh thẳng — chỉ cần không làm giống họ.
`. Hai kết luận cycle 4-5 bị bác lại (RS-B1, RS-B2).

## Idea Inventory

### 2026-08-28 — Quét hiện trạng: phát hiện cấu trúc lớn nhất

Đọc các controller để xem app *thực sự* đang làm gì, không phải tên module nói gì.
Một khuôn mẫu lặp lại ở khắp nơi mà **chưa ai gọi tên**:

- `themes`: request → approve / reject
- `ghost-config`: "requires partner approval", pending, approve / reject
- `alarms`: request toggle, request delete, **confirm / reject partner action**
- `dream-jar`: approve / reject pending jar
- `love-contracts`: create → **sign** pending
- `reminders`: mutual consent cho update và delete (theo lịch sử commit)

→ **P0. Đây là nguyên thuỷ tương tác hạt nhân của sản phẩm: ĐỒNG THUẬN HAI BÊN
("hai chìa khoá").** Nó đang được cài lại thủ công ở 6 chỗ, không nhất quán, và
không được kể ra như một đặc điểm sản phẩm. Gần như không app cặp đôi nào lấy
đồng thuận làm hạt nhân — hầu hết chỉ là app chia sẻ nội dung. Đây đồng thời là
câu trả lời cho cả ba trục user hỏi, nên nó đứng đầu inventory.

Quan sát bổ sung:
- P1. Phân bố feature lệch: ~7 module biểu đạt/trang trí, ~4 module hữu dụng thật.
- P2. `vow` chỉ có ở mobile, chưa có backend → một feature dựng dở.
- P3. `anti_ghosting` + "Emoji Storm" là thứ kỳ lạ và độc đáo thật, đang bị dùng
  ít hơn tiềm năng.
- P4. `data-export` đã tồn tại — hạ tầng cho các nghi thức "kết thúc/lưu giữ".
- P5. `expenses` mới ở mức *ghi chép*, chưa chạm tới phần khó là *quyết định tiền*.

### 2026-08-28 — Technique 1: Assumption Smash (app đang giả định gì về cặp đôi?)

- A1. Giả định "cặp đôi muốn chia sẻ khoảnh khắc" → bỏ: cặp đôi cần **vận hành
  một cuộc sống chung**. Chia sẻ khoảnh khắc là thứ họ làm khi rảnh; vận hành là
  thứ họ phải làm mỗi ngày dù muốn hay không.
- A2. Giả định "hai người luôn hoà thuận" → bỏ: **app hiện không có chế độ nào
  cho lúc hai người đang cãi nhau.** Đó là lúc app có giá trị nhất và cũng là lúc
  app hiện im lặng nhất.
- A3. Giả định "mọi thứ đều nên chia sẻ" → bỏ: một số thứ nên **riêng tư có chủ
  đích** (nhật ký riêng, ghi chú chuẩn bị cho một cuộc nói chuyện khó).
- A4. Giả định "cả hai đều chủ động như nhau" → bỏ: hầu hết cặp đôi có một người
  "quản trị viên" và một người "khách". App nên **thiết kế cho người ít chủ động**,
  không cho người nhiều chủ động.
- A5. Giả định "thông báo là tốt" → bỏ: thông báo trong app cặp đôi tạo **nghĩa vụ**,
  không tạo niềm vui. Ít thông báo hơn có thể là tính năng.
- A6. Giả định "cặp đôi ở cùng múi giờ, cùng thành phố" → bỏ: yêu xa là một phân
  khúc riêng với nhu cầu riêng.
- A7. Giả định "quan hệ chỉ có hai người" → bỏ: quan hệ Việt Nam có **gia đình hai
  bên** trong đó. Giỗ, Tết, sinh nhật bố mẹ chồng/vợ, quà cáp — đây là nguồn ma
  sát có thật mà không app toàn cầu nào chạm tới.
- A8. Giả định "app dành cho lúc vui" → bỏ: app cũng nên dùng được lúc ốm, lúc
  khủng hoảng, lúc một người phải chăm người kia.
- A9. Giả định "đồng thuận chỉ dùng cho thay đổi cấu hình" → bỏ: đồng thuận nên
  áp được cho **mọi quyết định chung**: tiền, kế hoạch, cam kết, quy tắc.

### 2026-08-28 — Technique 2: Analogy Transfer (domain shift → công cụ vận hành, game co-op, trị liệu)

- B1. **Fair Play (bộ bài phân chia việc nhà)** → "Sổ gánh nặng vô hình": không
  đếm ai rửa bát, mà theo dõi **ai đang GIỮ một lĩnh vực** (ai là người *nhớ* lịch
  khám răng, ai *nghĩ đến* việc mua quà). Đây là nỗi đau lớn nhất, thật nhất của
  cặp đôi sống chung và chưa app nào làm tử tế. Xem U1.
- B2. **Retro của đội agile** → "Check-in tháng của chúng ta": một nghi thức có
  cấu trúc, ba câu hỏi, mỗi tháng một lần. Chính repo này sống bằng retro.
- B3. **Gottman / trị liệu cặp đôi** → bộ công cụ **sửa chữa sau xung đột**: hẹn
  giờ tạm dừng, kịch bản làm lành có hướng dẫn, "lời mời kết nối". Xem U4.
- B4. **It Takes Two (game co-op bắt buộc hai người)** → hoạt động **về mặt cơ
  học là không thể làm một mình**. Trùng khớp hoàn hảo với nguyên thuỷ hai chìa khoá.
- B5. **BeReal** → cả hai được ping cùng một khoảnh khắc ngẫu nhiên; chỉ khi cả
  hai trả lời thì mới thấy câu của người kia. Sự đồng thời tạo cảm giác hiện diện.
- B6. **Phong bì niêm phong / bỏ phiếu kín** → **cơ chế "trả lời kín rồi cùng lật"**.
  Cả hai trả lời độc lập, app lật đồng thời. Xem P6 bên dưới — đây có thể là
  nguyên thuỷ thứ hai của sản phẩm.
- B7. **Splitwise / ngân sách chung** → vượt khỏi ghi chép: "chúng ta có kham nổi
  cái này không", ngưỡng cần bàn bạc, quỹ chung vs tiền riêng.
- B8. **Checklist hàng không / bàn giao ca trực** → "ai đang trực": tối nay ai
  nấu, tuần này ai lo con, ai đang cầm việc gì. Bàn giao rõ ràng thay vì đoán ý.
- B9. **Notion / cơ sở tri thức chung** → "Sổ tay của chúng ta": mật khẩu wifi nhà
  bố mẹ, size áo của nhau, món người kia dị ứng, tên bác sĩ. Nhàm chán, và vì thế
  cực kỳ hữu ích.
- B10. **Google Calendar** → KHÔNG clone lịch. Chỉ làm **lớp cặp đôi phủ lên trên**:
  ai bận, ai rảnh, ai đang trực. Xem U3.
- B11. **Nút phóng tên lửa hai chìa khoá** → nâng đồng thuận thành thương hiệu.
- B12. **Strava kudos** → ghi nhận nỗ lực của người kia một cách nhẹ nhàng, không
  điểm số.
- B13. **Duolingo streak** → streak của **nghi thức**, không phải streak của việc
  mở app.
- B14. **Hộp thư thời gian / time capsule** → viết cho hai đứa mình một năm sau,
  khoá lại. `dream_jar` là họ hàng gần.
- B15. **Sổ tang lễ / album gia đình** → app là nơi *lưu giữ*, không chỉ nơi *trao đổi*.
- B16. **Chế độ chăm sóc bệnh nhân** → khi một người ốm/khủng hoảng, người kia mở
  ra "cẩm nang giúp anh/em" mà chính người ốm đã viết sẵn lúc còn khoẻ. Xem U12.

### 2026-08-28 — Nguyên thuỷ thứ hai nổi lên

- **P6. TRẢ LỜI KÍN RỒI CÙNG LẬT (blind-reveal).** Cả hai trả lời độc lập, không
  thấy câu của nhau, app lật cùng lúc. Nó giải quyết một lớp vấn đề rất rộng:
  - "Ăn gì?" / "Xem gì?" → hết thế bí nhường nhau (U2)
  - "Anh thấy tháng này của mình thế nào?" → không bị người trả lời trước dẫn dắt
  - "Mình muốn gì trong 5 năm tới?" → tránh chiều lòng nhau
  - Câu hỏi thân mật, ranh giới, kỳ vọng → an toàn hơn nhiều khi trả lời kín
  Cực kỳ cuốn hút (có khoảnh khắc lật bài), cực kỳ hữu ích, và gần như không app
  cặp đôi nào dùng nó làm nguyên thuỷ. Cùng với P0, đây là hai viên gạch nền.

### 2026-08-28 — Technique 3: JTBD Extremes — bảy ca sống thật (domain shift → đời sống thật)

- H1. **Mới yêu (1-3 tháng):** cần khám phá nhau. Blind-reveal các câu hỏi làm
  quen là đúng lúc nhất. App hiện phục vụ ca này tốt nhất.
- H2. **Yêu xa:** cần biết "bây giờ gọi có tiện không", xem phim cùng lúc, ngủ
  cùng nhau qua âm thanh, đếm ngược ngày gặp. App hiện gần như không có gì.
- H3. **Sống chung:** đây là ca app phục vụ TỆ NHẤT và là ca ma sát cao nhất.
  Việc nhà, gánh nặng vô hình, tiền chung, hoá đơn, ai trực. Toàn bộ U1/U3/U6/U8
  sinh ra từ đây.
- H4. **Chuẩn bị cưới:** dự án lớn nhất đời, hai gia đình, ngân sách, danh sách
  khách, lịch trình. Ở Việt Nam còn thêm lễ nghi. Một "chế độ cưới" là một sản
  phẩm riêng nằm sẵn trong app.
- H5. **Đã có con:** thời gian bằng 0, ma sát cực đại, nhu cầu "ai trực" cực đại,
  và nhu cầu **giữ lại chút gì đó của hai người** trước khi bị nuốt bởi vai trò
  bố mẹ. Rất ít app đụng tới.
- H6. **Đang xung đột:** app im lặng hoàn toàn. Đây là lỗ hổng đạo đức và cũng là
  cơ hội khác biệt lớn nhất (U4).
- H7. **Lâu năm, ổn định, chán:** không cần thêm tiện ích, cần **cái mới nho nhỏ**
  — gợi ý hẹn hò, câu hỏi chưa từng hỏi, nhìn lại kỷ niệm cũ.
- H8. Nhận định xuyên suốt: **app hiện được thiết kế cho H1 (mới yêu), nhưng doanh
  thu và giữ chân nằm ở H3/H4/H5 (sống chung, cưới, có con).** Đây có lẽ là lệch
  pha chiến lược lớn nhất của sản phẩm.

### 2026-08-28 — Danh mục HỮU ÍCH (trục user nhấn mạnh)

- U1. **Sổ gánh nặng vô hình (mental load).** Không đếm việc đã làm — theo dõi ai
  đang *giữ* mỗi lĩnh vực (lịch khám, quà cáp, hoá đơn, xe cộ, gia đình hai bên).
  Bàn giao lĩnh vực bằng hai chìa khoá. Nỗi đau lớn nhất, thật nhất, chưa ai làm tốt.
- U2. **Máy quyết định.** Ăn gì / xem gì / cuối tuần làm gì — cả hai đề xuất kín,
  app lật và chỉ ra chỗ trùng. Tần suất cực cao, bề mặt cực nhỏ, hữu ích ngay lập tức.
- U3. **Lớp lịch cặp đôi.** Không clone Google Calendar. Chỉ trả lời: tối nay ai
  bận, tuần này ai trực, khi nào cả hai cùng rảnh.
- U4. **Bộ sửa chữa sau xung đột.** Chế độ "mình đang căng": hẹn giờ hạ nhiệt,
  kịch bản làm lành có hướng dẫn, lời mời quay lại. Hữu ích nhất, khác biệt nhất,
  và **rủi ro nhất** — làm dở thì phản tác dụng nghiêm trọng.
- U5. **Tự động lo ngày quan trọng.** Sinh nhật bố mẹ hai bên, kỷ niệm, giỗ, Tết.
  Cộng "kho ý tưởng quà": suốt năm ai nghe người kia thích gì thì thả vào, đến
  dịp thì mở ra. Giải bài "không biết mua gì".
- U6. **Tiền vượt mức ghi chép.** Ngân sách chung, ngưỡng "cái này phải bàn",
  tách quỹ chung / tiền riêng, khung để nói chuyện tiền bạc bớt ngại.
- U7. **Đồng bộ chu kỳ & sức khoẻ.** Chu kỳ, năng lượng, tâm trạng — chia sẻ có
  đồng thuận để người kia có ngữ cảnh. Rất hữu ích, rất nhạy cảm, cần hàng rào.
- U8. **Vận hành nhà cửa.** Hoá đơn, gói cước, hạn bảo hành, hạn đăng kiểm. Nhàm
  chán tới mức không ai làm, và chính vì thế mà giữ chân.
- U9. **Check-in tháng của chúng ta.** Retro quan hệ có cấu trúc, dùng blind-reveal.
- U10. **Sổ tay của chúng ta.** Kho tri thức chung nhỏ nhặt: size áo, dị ứng, mật
  khẩu wifi nhà nội, tên bác sĩ, số hộ chiếu.
- U11. **Chế độ yêu xa.** Múi giờ, "giờ này gọi được không", đếm ngược ngày gặp,
  xem phim đồng bộ.
- U12. **Chế độ chăm sóc.** Người khoẻ mở ra cẩm nang do chính người ốm viết sẵn:
  "khi anh như thế này, đừng hỏi, cứ làm cái này".
- U13. **Chế độ cưới.** Ngân sách, khách mời, lịch lễ nghi, chia việc hai họ.
- U14. **Chế độ mới có con.** Ai trực đêm, lịch tiêm, và một "góc còn lại của hai đứa".

### 2026-08-28 — Danh mục CUỐN HÚT

- E1. **Bất ngờ bất đối xứng:** một người dựng sẵn, người kia phát hiện sau.
  (`wishlistThemeId` đã dựng dở đúng ý này.)
- E2. **Hộp thư thời gian:** viết cho hai đứa mình một năm sau.
- E3. **Nhiệm vụ bắt buộc hai người** (mô hình It Takes Two): về cơ học không làm
  một mình được.
- E4. **Khoảnh khắc đồng thời kiểu BeReal:** cùng được ping, cùng trả lời.
- E5. **Khoảnh khắc lật bài** (P6) là cơ chế cuốn hút mạnh nhất, và nó miễn phí
  vì đã cần cho phần hữu ích.
- E6. **Streak của nghi thức**, không phải streak của việc mở app.
- E7. **Nhìn lại có chủ đích:** "một năm trước hôm nay hai đứa..." — `timeline`
  và `gallery` đã có dữ liệu, chưa có khoảnh khắc.
- E8. **Emoji Storm** đã tồn tại và rất lạ. Nên khai thác thành cả một họ
  "quấy rối dễ thương có phép" thay vì một tính năng đơn lẻ.
- E9. **Pet là hiện thân cảm xúc của mối quan hệ**, không phải một con thú riêng.
- E10. **Vow đang dựng dở** — lời thề là một nghi thức có sức nặng, đáng hoàn thiện.

### 2026-08-28 — Technique 4: Anti-Commodity Differentiation (domain shift → văn hoá bản địa)

- Q1. **Hai chìa khoá làm thương hiệu.** Một câu định vị mà đối thủ không nói theo
  được vì phải xây lại kiến trúc: *"Không có gì về chúng ta mà thiếu cả hai."*
- Q2. **Lật bài làm cơ chế đặc trưng.**
- Q3. **Chống ghosting đã độc đáo sẵn** — không app nào có công cụ cho tình huống
  "người kia đang lơ mình". Đang bị khai thác dưới tiềm năng. Cảnh báo: nó đứng
  rất gần ranh giới giám sát, xem R1/R8.
- Q4. **Love contract = cặp đôi tự viết luật cho mình.** Độc đáo và đang bị bỏ phí.
  Nên mở rộng thành thoả thuận thật: cách chúng ta cãi nhau, cách chúng ta tiêu
  tiền, cách chúng ta chia việc. Đây là cầu nối tự nhiên giữa Q1 và U1/U4/U6.
- Q5. **Bản địa hoá Việt Nam là con hào rẻ nhất và bị bỏ trống hoàn toàn.** Lịch
  âm, giỗ, Tết, quà hai họ, lễ nghi cưới, cách xưng hô. App cặp đôi toàn cầu
  không bao giờ làm những thứ này. `zodiac` đã có → lịch âm là bước kế cận tự nhiên.
- Q6. **Kho lưu trữ tích luỹ là chi phí chuyển đổi.** Càng dùng lâu càng không
  rời được — và `data-export` đã có sẵn để việc đó không mang tiếng giam giữ.
- Q7. Cặp đôi là đơn vị tài khoản → định vị **"hệ điều hành của một mối quan hệ"**,
  không phải "app nhắn tin có theme".

### 2026-08-28 — Technique 5: Problem Reversal — thiết kế app PHÁ HOẠI mối quan hệ

- R1. **Giám sát.** Vị trí, đã xem chưa, bao lâu thì trả lời. `anti_ghosting` đứng
  sát ranh giới này. → **Luật: đo hành vi của CHÚNG TA, không bao giờ đo hành vi
  của NGƯỜI KIA cho tôi xem.**
- R2. **Bảng điểm việc nhà** → oán giận được số hoá. Chính vì vậy U1 phải theo dõi
  *quyền sở hữu lĩnh vực*, không theo dõi *số việc đã làm*.
- R3. **Streak trừng phạt** → tội lỗi hoá một tuần khó khăn.
- R4. **Thông báo tạo nghĩa vụ** → mỗi cái ping là một món nợ tình cảm.
- R5. **Biến app thành nơi cãi nhau** → bình luận, phản đối, tranh luận trong app.
- R6. **Kho bằng chứng.** Timeline + chat + expenses vô tình trở thành vũ khí:
  *"ngày 3 tháng 3 anh đã nói..."*. Rủi ro có thật và ít ai nghĩ tới. → cần cân
  nhắc quyền lãng quên, không chỉ quyền lưu trữ.
- R7. **Thiết lập một chiều** → một người cấu hình tất cả, người kia thấy mình bị
  quản lý. Hai chìa khoá chính là thuốc giải sẵn có. (A4 cùng hướng.)
- R8. **Kiểm soát cưỡng ép.** `ghost-config` và mọi tính năng "ép người kia phản
  hồi" đều có thể bị vũ khí hoá bởi một người bạo hành. **Cần một vòng rà soát an
  toàn riêng trước khi mở rộng nhóm tính năng này** — đây là blocker đạo đức, không
  phải ghi chú.
- R9. **Ép chia sẻ.** Nếu mọi thứ đều chung thì không còn không gian riêng, và
  không gian riêng là điều kiện của một mối quan hệ khoẻ mạnh (A3 cùng hướng).

### 2026-08-28 — Nhận định nổi lên

- Ba trục user nêu ra **không cần đánh đổi nhau**, vì hai nguyên thuỷ P0 (hai chìa
  khoá) và P6 (lật bài) đồng thời tạo ra cả ba: chúng là *hữu ích* (mọi quyết định
  chung cần chúng), *cuốn hút* (chờ và lật đều là khoảnh khắc), và *unique* (không
  ai lấy chúng làm hạt nhân). Đây là phát hiện có giá trị nhất của cycle 1.
- **Lệch pha chiến lược (H8):** app đang được thiết kế cho cặp mới yêu, trong khi
  giữ chân và chi trả nằm ở cặp sống chung / chuẩn bị cưới / mới có con.
- Ba tài sản đang bị bỏ phí: `love-contracts` (Q4), `anti_ghosting` (Q3), và
  bản địa hoá Việt Nam (Q5). Cả ba đều rẻ hơn xây feature mới.
- Hai feature dựng dở: `vow` (chưa có backend), `wishlist` (chưa thành luồng bất ngờ).
- Rủi ro đạo đức R8 (kiểm soát cưỡng ép) là blocker thật cho bất kỳ hướng nào
  chạm vào ghost-config hoặc theo dõi phản hồi.

### 2026-08-28 — QUYẾT ĐỊNH CỦA USER: phân khúc mục tiêu là CẶP ĐÔI MỚI YÊU

User xác nhận nhắm cặp mới yêu. Vậy H8 ở cycle 1 **không phải lệch pha** — đó là
lựa chọn có chủ đích. Nhưng quyết định này cắt rất sâu vào danh mục hữu dụng, vì
**cặp mới yêu gần như không có hậu cần chung nào để quản lý.**

Chết hoặc hoãn vô thời hạn ở phân khúc này:

- **U1 gánh nặng vô hình — chết.** Chưa sống chung thì không có việc nhà để chia.
  Nỗi đau lớn nhất của thị trường, nhưng của một phân khúc khác.
- **U3 lớp lịch "ai trực" — chết.** Không có ca trực chung.
- **U6 tiền/ngân sách chung — gần chết.** Chưa có tài chính chung.
- **U8 vận hành nhà cửa — chết.**
- **U13 chế độ cưới, U14 mới có con — chết (hoặc rất xa).**
- **U10 sổ tay chung — không chết nhưng ĐỔI MỤC ĐÍCH hoàn toàn**, xem V4.
- **U12 chế độ chăm sóc — yếu**, quá thân mật so với giai đoạn.

→ **Khoảng một nửa danh mục hữu dụng vừa biến mất.** Đây là tin tốt: bài toán vừa
được thu hẹp mạnh. Nhưng nó lộ ra một câu hỏi lớn hơn ở ngay dưới.

### 2026-08-28 — Hệ quả trung tâm: "HỮU ÍCH" phải được định nghĩa lại

Nếu cặp mới yêu không có hậu cần chung, thì "hữu ích" **không thể mang nghĩa vận
hành**. Nó phải mang nghĩa khác. Đây là phát hiện quan trọng nhất của cycle 2 —
và nếu bỏ qua nó, đội sẽ xây nhầm loại tiện ích cho nhầm giai đoạn.

Hữu ích với cặp mới yêu nghĩa là:

- V1. **Hiểu nhau nhanh hơn và sâu hơn.** Đây là "công việc" thật sự của giai đoạn
  này. Nguyên thuỷ lật bài (P6) không chỉ hợp — nó *chính là* cơ chế của việc làm
  quen.
- V2. **Giảm lo âu giai đoạn đầu.** Nỗi lo lớn nhất của cặp mới yêu là *"người kia
  có thích mình nhiều như mình thích họ không"*. Lật bài giải đúng nỗi lo đó: cả
  hai nói ra cùng lúc thì không ai phải mạo hiểm trước, không ai mất mặt.
- V3. **Lên kế hoạch hẹn hò.** Nhiệm vụ tần suất cao nhất và có thật nhất của cặp
  mới yêu. **U2 (máy quyết định) sống rất khoẻ ở đây** — cộng gợi ý địa điểm bản địa.
- V4. **Nhớ chi tiết về người kia.** U10 sống lại nhưng đổi mục đích: không phải
  để *vận hành*, mà để **gây ấn tượng**. Tên bạn thân, món ghét, ngày quan trọng,
  size áo. "Nhớ được điều nhỏ nhặt" đúng là siêu năng lực của giai đoạn này.
- V5. **Biết khi nào nên nói gì.** Ranh giới, kỳ vọng, tốc độ. Cuộc nói chuyện
  "định nghĩa mối quan hệ" là cuộc nói chuyện đáng sợ nhất của giai đoạn — lật bài
  làm nó bớt đáng sợ.
- V6. **Quà và dịp.** U5 sống khoẻ. Cặp mới yêu **ám ảnh về "lần đầu tiên"**:
  kỷ niệm tháng, sinh nhật đầu tiên, Valentine đầu tiên, Tết đầu tiên.
- V7. **Gặp gia đình và bạn bè người kia.** Ai là ai, tên gì, **xưng hô thế nào**.
  Ở Việt Nam đây là nỗi sợ có thật và rất dễ sai. Cực kỳ bản địa, cực kỳ hữu ích,
  và không app toàn cầu nào chạm tới.
- V8. **Xung đột đầu tiên.** Ở tháng 3-6, cãi nhau lần đầu là bước ngoặt sinh tử.
  **U4 không những sống mà còn quan trọng HƠN ở phân khúc này**, vì cặp mới yêu
  chưa có kỹ năng làm lành nào cả.

### 2026-08-28 — Technique 6: JTBD Extremes *bên trong* phân khúc (domain shift → app hẹn hò)

- H9. **Tuần đầu, chưa chính thức:** chưa dám gọi nhau là người yêu. Đây là ca
  khó nhất, xem rào cản X1/X2.
- H10. **Tháng 1-3 — giai đoạn vàng.** Hào hứng cực đại, muốn biết mọi thứ về nhau,
  sẵn sàng dành thời gian trong một app về hai người. **Đây là ICP thật.**
- H11. **Tháng 3-6:** xung đột đầu tiên, bắt đầu gặp bạn bè và gia đình nhau, bắt
  đầu cuộc nói chuyện định nghĩa mối quan hệ. Nhu cầu chuyển từ *khám phá* sang
  *điều hướng*.
- H12. **Tháng 6-12:** ngã ba đường — hoặc sâu hơn, hoặc kết thúc.
- H13. **Yêu xa + mới yêu:** cường độ nhu cầu cao nhất trong tất cả các ca, vì họ
  không có thời gian vật lý bên nhau để làm việc "tìm hiểu". Mọi thứ phải diễn ra
  trong app. Đây có thể là **phân khúc con sinh lời nhất**.
- H14. **Gặp nhau qua app hẹn hò:** đã quen dùng app cho chuyện tình cảm → **rào
  cản cài đặt thấp nhất**. Kênh thu hút rõ ràng nhất, xem Z1.
- H15. **Yêu giấu, chưa công khai:** cần riêng tư, không muốn lộ trên MXH. Một app
  riêng tư cho hai người là chỗ trú tự nhiên. Phân khúc con bị bỏ quên.
- H16. **Mối tình đầu (18-22 tuổi):** thật sự không biết cách yêu. Cần hướng dẫn
  chứ không chỉ cần công cụ. Nhạy cảm nhưng giá trị rất cao.
- H17. **Người lớn tuổi yêu lại sau đổ vỡ:** thận trọng, có hành trang, cần đi chậm.

### 2026-08-28 — Technique 7: Analogy Transfer vòng 2 (domain shift → party game, nghiên cứu tâm lý, học theo cấp độ)

- W1. **"36 câu hỏi để yêu nhau" (nghiên cứu Aron)** triển khai bằng lật bài, chia
  ba tầng mở dần. Có cơ sở khoa học thật → nội dung có thẩm quyền, khó copy về uy tín.
- W2. **We're Not Really Strangers / bộ bài câu hỏi theo tầng sâu.** Mô hình nội
  dung đã được kiểm chứng thương mại.
- W3. **Đấu trường "ai hiểu ai hơn":** cả hai đoán câu trả lời của người kia rồi
  lật. Vừa vui vừa dạy nhau. ⚠️ Cảnh báo: đây là bảng điểm → đụng luật "chúng ta,
  không phải anh-so-với-em". Phải thiết kế sao cho **không ai thua**.
- W4. **Bản đồ "lần đầu tiên":** lần đầu nắm tay, lần đầu đi ăn, lần đầu cãi nhau.
  Cặp mới yêu ám ảnh cột mốc, và `timeline` đã có sẵn dữ liệu.
- W5. **Mixtape / playlist chung.**
- W6. **Thẻ thử thách hẹn hò:** rút một thẻ, cả hai phải làm.
- W7. **Đếm ngược tới lần gặp tiếp theo** — rất mạnh cho H13 (yêu xa mới yêu).
- W8. **Hộp thư thời gian:** "viết cho hai đứa mình một năm nữa". Với cặp mới yêu,
  mốc một năm là một cột mốc thật và đầy cảm xúc.
- W9. **Nội dung chỉ mở khi cả hai cùng online** — nguyên thuỷ hai chìa khoá (P0)
  dùng cho mục đích vui, không phải cho thủ tục.
- W10. **Học theo cấp độ (kiểu Duolingo):** độ sâu câu hỏi mở dần theo thời gian
  quen nhau, không cho phép nhảy cóc. Chống việc đi quá nhanh quá sớm.

### 2026-08-28 — Technique 8: Constraint Ladder — những rào cản riêng của phân khúc

- X1. **RÀO CẢN LỚN NHẤT: "quá sớm để cài app cặp đôi".** Rủ một người mới quen
  hai tuần cài "app cặp đôi" là tạo áp lực, và có thể quê. Đây là rào cản gia nhập
  số một của phân khúc và nó **quyết định toàn bộ chiến lược onboarding**. Ba lối
  thoát: (a) định vị nhẹ đi — vào bằng cửa *trò chơi cho hai người*, không phải
  *app cặp đôi*; (b) một người dùng trước, mời sau; (c) không bắt khai báo tình
  trạng quan hệ khi cài.
- X2. **Rào cản "chưa chính thức".** Nếu app bắt chọn "ngày bắt đầu yêu" ngay từ
  onboarding thì nó ép định nghĩa quá sớm. Trường đó nên để trống được.
- X3. **Chia tay là chuyện thường ở phân khúc này.** Tỉ lệ kết thúc cao nhất. →
  Nghi thức kết xuất (đã bàn ở idea hearts) hoá ra quan trọng nhất ở **ĐÂY**, chứ
  không phải ở cặp lâu năm. Module `data-export` đã có sẵn.
- X4. **Khả năng chi trả thấp nhất.** Quan hệ chưa được chứng minh thì trả tiền
  cho app rất khó. NHƯNG: cặp mới yêu **tiêu rất nhiều tiền cho nhau** — quà, hẹn
  hò, dịp lần đầu. Tiền có sẵn, chỉ là không chảy vào app. → doanh thu nên đi qua
  **quà và trải nghiệm hẹn hò**, không qua subscription.
- X5. Ràng buộc "hai người mới quen chưa tin nhau hoàn toàn": mọi thứ chạm vào
  vị trí, đọc tin nhắn, thời gian phản hồi đều nguy hiểm gấp đôi ở giai đoạn này.
  R1/R8 từ cycle 1 càng đúng hơn.

### 2026-08-28 — BẪY CHIẾN LƯỢC cần nói thẳng

- Y1. **Bẫy tuần trăng mật:** cặp mới yêu là **phân khúc thu hút tốt nhất và giữ
  chân tệ nhất**. Hào hứng cao nhất lúc cài, vòng đời ngắn nhất, chi trả thấp nhất.
  Không phải lý do để đổi phân khúc — nhưng là thứ chiến lược phải có câu trả lời.
- Y2. Ba lối thoát:
  - (a) **Chiến lược tốt nghiệp** — phục vụ cặp mới yêu xuất sắc để *vào*, rồi
    thiết kế app *lớn lên cùng họ* sang giai đoạn sống chung. Thu hút ở giai đoạn
    đầu, kiếm tiền ở giai đoạn sau.
  - (b) **Chấp nhận vòng đời ngắn, tối ưu lan truyền** — cặp mới yêu khoe nhiều
    nhất và giới thiệu nhiều nhất.
  - (c) **Kiếm tiền từ quà và trải nghiệm hẹn hò** thay vì subscription (từ X4).
- Y3. **Lối thoát (a) không mâu thuẫn với lựa chọn của user** — và nó thay đổi
  cách hiểu về những feature vừa "chết" ở trên: **U1, U3, U6, U8 không chết, chúng
  được HOÃN và mở khoá theo mùa quan hệ.** App có khái niệm *giai đoạn*, và tiện
  ích vận hành xuất hiện đúng lúc cặp đôi bắt đầu cần chúng. Đây là cách hoà giải
  tốt nhất tìm được ở cycle 2.

### 2026-08-28 — Technique 9: Channel-First Ideation (domain shift → thu hút)

- Z1. **Cặp gặp nhau qua app hẹn hò (H14) là kênh rõ nhất** — họ đã quen dùng app
  cho chuyện tình cảm nên rào cản X1 thấp nhất. Đây là nơi nên thử nghiệm trước.
- Z2. Cặp mới yêu **khoe nhiều nhất trên mạng xã hội** → hiện vật chia sẻ được
  (kết quả lật bài, bản đồ lần đầu tiên) là kênh tăng trưởng tự nhiên. Nhớ luật
  từ idea hearts: **chia sẻ câu chuyện, không chia sẻ con số.**
- Z3. **Vòng lặp lan truyền là bắt buộc** — app chỉ chạy khi mời được người kia.
  Vậy khoảnh khắc mời phải là khoảnh khắc *vui*, không phải khoảnh khắc *nghiêm
  trọng*. Củng cố lối thoát X1(a): vào bằng cửa trò chơi.
- Z4. Lõi nhân khẩu 18-25, sinh viên. Kênh TikTok và trường học.
- Z5. Kênh niềm tin cho H15 (yêu giấu): "chỗ riêng của hai đứa, không lộ ra ngoài".

### 2026-08-28 — Anti-Commodity cho đúng phân khúc

- Q8. **Bản địa hoá VN ở phân khúc này rất cụ thể:** xưng hô với gia đình người
  kia (V7), quán xá địa phương cho gợi ý hẹn hò (V3), Tết đầu tiên và các dịp VN
  (V6). App cặp đôi toàn cầu bỏ trống hoàn toàn.
- Q9. **Nội dung có cơ sở khoa học (W1)** khó copy về mặt uy tín, không phải về
  mặt kỹ thuật.
- Q10. **Lật bài + hai chìa khoá vẫn là con hào kiến trúc** — và ở phân khúc mới
  yêu thì chúng còn *tự nhiên hơn*, vì cả hai đều là cơ chế của việc làm quen.

### 2026-08-28 — Nhận định nổi lên ở cycle 2

- Quyết định phân khúc **giết một nửa danh mục hữu dụng nhưng làm mạnh lên đúng
  hai nguyên thuỷ nền tảng**. P6 (lật bài) từ "một cơ chế hay" trở thành "cơ chế
  trung tâm của sản phẩm", vì với cặp mới yêu thì lật bài *chính là* việc tìm hiểu nhau.
- "Hữu ích" ở phân khúc này **không mang nghĩa vận hành mà mang nghĩa hiểu nhau,
  bớt lo, và gây ấn tượng**. Đây là thứ dễ hiểu sai nhất.
- Ba thứ sống sót nguyên vẹn từ cycle 1 và còn mạnh hơn: **U2 máy quyết định**
  (thành lập kế hoạch hẹn hò), **U5 ngày quan trọng** (thành ám ảnh "lần đầu tiên"),
  **U4 sửa chữa xung đột** (thành xung đột đầu tiên ở tháng 3-6).
- Hai thứ mới, rất bản địa, rất rẻ: **V7 xưng hô và gặp gia đình người kia**, và
  gợi ý hẹn hò theo địa phương.
- Rào cản X1 ("quá sớm để cài app cặp đôi") là vấn đề cấp bách nhất và chưa được
  giải. Nó có thể quan trọng hơn mọi feature trong danh sách.
- Bẫy Y1 chưa có câu trả lời, nhưng lối thoát Y2(a) cho thấy các feature giai đoạn
  sau nên được **hoãn theo mùa**, không nên bị xoá khỏi tầm nhìn.

### 2026-08-28 — QUYẾT ĐỊNH USER (cycle 3)

- Y1: chọn **(a) chiến lược tốt nghiệp, nhưng bắt buộc phải có (b) tối ưu lan
  truyền**. Hai cái này tương thích, xem Y4-Y8.
- Hướng rẽ mới: đào sâu X1, và cân nhắc **"trợ lý cho người vừa mới yêu, đang
  tán tỉnh"**.

### 2026-08-28 — Technique 10: Assumption Smash trên KHOẢNH KHẮC MỜI (mổ xẻ X1)

Tại sao rủ người kia cài app lại khó đến thế? Sáu lý do độc lập, không phải một:

- X1a. **Tín hiệu bất đối xứng.** Rủ cài app cặp đôi = tuyên bố "anh coi mình là
  một cặp / anh nghiêm túc". Nếu người kia chưa tới đó, mình vừa lộ bài và vừa lỗ.
- X1b. **Đó là một lời NHỜ VẢ, không phải một món quà.** Mình đang bảo người ta
  làm việc (tải, đăng ký) vì lợi ích của mình.
- X1c. **Nó hơi công khai.** Một app tên tình tứ nằm trên máy họ, bạn bè họ nhìn thấy.
- X1d. **Rủi ro bị từ chối.** Họ có thể nói không, và "không" với app cặp đôi bị
  đọc thành "không" với mối quan hệ.
- X1e. **App vô dụng cho tới khi họ đồng ý.** Giá trị bằng 0 trước cái gật đầu.
  Đây là đường cong kích hoạt tệ nhất có thể có.
- X1f. **Ai rủ thì người đó là người đầu tư nhiều hơn.** Nó phơi bày sự chênh
  lệch, đúng trong giai đoạn mà chênh lệch là thứ đáng sợ nhất.

→ **X1e là gốc rễ.** Năm cái kia đều là hệ quả của việc sản phẩm không có giá trị
nào cho một người. Vậy cách chữa đúng về mặt cấu trúc không phải là viết lời mời
hay hơn, mà là **làm cho sản phẩm có giá trị với MỘT người**. Lúc đó lời mời thôi
không còn là điều kiện kích hoạt, mà trở thành một bước nâng cấp.

**Hướng rẽ của user không chỉ là một ý hay — nó là lời giải đúng về cấu trúc cho X1.**

### 2026-08-28 — Không gian lời giải cho X1 (không chỉ có hướng rẽ)

- S1. **Chế độ trợ lý một người** (đề xuất của user). Giá trị đầy đủ khi ở một mình.
- S2. **Biến lời mời thành món quà, không phải lời nhờ.** "Anh làm cái này cho em"
  — người kia nhận một hiện vật, không phải một form đăng ký. Diệt X1b.
- S3. **Mời kiểu rủ chơi game.** "Chơi cái này với anh" — không tuyên bố quan hệ.
  Diệt X1a và X1d.
- S4. **Người kia KHÔNG cần cài gì.** Tương tác qua link/web. Diệt hoàn toàn X1b,
  X1c, và phần lớn X1e. Bị đánh giá thấp và rất mạnh.
- S5. **Tên và icon không hét lên "app cặp đôi".** Diệt X1c.
- S6. **Đừng bắt định nghĩa quan hệ** khi onboarding (X2 cũ). Diệt X1a.
- S7. **Người kia vào để xem một thứ cụ thể** — một hộp thư thời gian mình đã
  viết, một kế hoạch hẹn hò mình đã dựng. Kéo, không đẩy.
- Nhận định: S1 + S2 + S4 kết hợp lại thì X1 gần như biến mất hoàn toàn.

### 2026-08-28 — HƯỚNG RẼ: sản phẩm một người cho giai đoạn tán tỉnh

Điều này phá vỡ giả định nền tảng lớn nhất của toàn bộ codebase: **đơn vị tài
khoản là cặp đôi**. Ở giai đoạn tán tỉnh, người kia **chưa tồn tại trong hệ
thống** — và có thể không bao giờ tồn tại.

Bảy tiểu giai đoạn của tán tỉnh (JTBD):

- T1. **Vừa gặp, vừa quen.** Việc cần làm: nhớ được những gì họ nói.
- T2. **Đang nhắn tin.** Việc cần làm: giữ nhịp, không nhạt, không dồn dập. Nỗi
  lo: "nhắn thế này có quá không".
- T3. **Chuẩn bị buổi hẹn đầu.** Việc cần làm: chọn chỗ, chuẩn bị, đừng lúng túng.
- T4. **Sau buổi hẹn.** Việc cần làm: đọc tín hiệu, quyết định bước tiếp theo.
- T5. **Muốn tỏ tình / định nghĩa quan hệ.** Việc cần làm: chọn thời điểm, bớt sợ.
- T6. **Vừa thành đôi.** ← **Đây chính là điểm nối vào app hiện tại.**
- T7. **Bị từ chối.** Việc cần làm: khép lại tử tế. Đây là lúc sản phẩm phải cư
  xử đẹp nhất, và cũng là lúc dễ làm ẩu nhất.

Trợ lý làm gì (phiên bản tử tế):

- P1. **Sổ nhớ về người ấy** — họ kể gì, thích gì, ghét gì. **Người ta ĐÃ làm việc
  này trong app Ghi chú.** Hành vi có sẵn, chỉ chưa có công cụ tử tế.
- P2. **Nhắc dịp** — họ bảo thứ Năm có buổi thuyết trình → nhắc mình hỏi thăm.
  Cực kỳ hữu ích và hoàn toàn pro-social.
- P3. **Gợi ý chỗ hẹn** dựa trên những gì họ đã kể (thích cà phê yên tĩnh, dị ứng
  hải sản). Bản địa hoá VN vào đúng chỗ này.
- P4. **Chuẩn bị buổi hẹn** — chuyện để hỏi, thứ cần nhớ.
- P5. **Ghi "lần đầu tiên" ngay từ giai đoạn tán tỉnh** — lần đầu nhắn, lần đầu
  gặp, lần đầu đi ăn. ⭐ Xem Y6, đây là mắt xích quan trọng nhất của cả hướng rẽ.
- P6. **Nhật ký cảm xúc riêng** — mình đang thấy thế nào, có đang quá đà không.
- P7. **Chỗ để hỏi lúc 2 giờ sáng** thay vì làm phiền bạn bè.

### 2026-08-28 — Technique 11: Problem Reversal — thiết kế phiên bản ĐÁNG SỢ của trợ lý

Bắt buộc phải làm bài tập này, vì hướng rẽ đi thẳng vào vùng nguy hiểm về đạo đức.
Toàn bộ xương sống đạo đức đã dựng ở cycle 1 (hai chìa khoá, "chúng ta không phải
anh-so-với-em", không giám sát) **đều giả định người kia là một bên tham gia**.
Ở giai đoạn tán tỉnh, người kia **không phải một bên tham gia**. Mọi luật cũ đều
mất hiệu lực đúng lúc rủi ro cao nhất.

- N1. **Kịch bản thao túng** — "nhắn gì để chắc chắn được trả lời". Đây là địa hạt
  pickup-artist. Độc hại về danh tiếng.
- N2. **Chấm điểm cơ hội** — "khả năng thành công 73%". Biến một con người thành
  mục tiêu.
- N3. **Phân tích tin nhắn của họ** — upload đoạn chat cho AI đọc tâm lý. Xâm phạm
  nghiêm trọng một người không hề hay biết.
- N4. **Theo dõi mạng xã hội của họ.**
- N5. **Hồ sơ chi tiết về một người không hề biết và không hề đồng ý.** Đây là
  vấn đề riêng tư có thật, không phải cảm giác.
- N6. **A/B test lời nhắn** — biến việc tán tỉnh thành phễu marketing.
- N7. ⚠️ **Nhiều "mục tiêu" cùng lúc.** Về mặt kỹ thuật, một "trợ lý tán tỉnh" có
  nhiều liên hệ **chính là một CRM hẹn hò**. Đó là một hạng mục sản phẩm có thật
  và bị ghét rộng rãi. Đây là chỗ sản phẩm trượt xuống nhanh nhất và bẩn nhất.

→ **LƯỠI DAO: trợ lý giúp mình TỬ TẾ HƠN, không giúp mình THẮNG.**
  - Được: nhớ, quan tâm, chuẩn bị, chu đáo, tự nhận thức.
  - Không được: kịch bản, chiến thuật, chấm điểm, phân tích đối tượng, nhiều mục tiêu.
- **Ràng buộc cứng rẻ nhất và cứu được cả sản phẩm: MỘT NGƯỜI TẠI MỘT THỜI ĐIỂM.**
  Chỉ theo dõi được một người. Ràng buộc này thực thi lưỡi dao về mặt cấu trúc
  thay vì bằng lời hứa, và nó diệt N7 và N6 luôn.
- Về riêng tư (N5): giữ riêng tư mặc định, không thu thập từ mạng xã hội, không
  ảnh, và định khung là **"ghi chú của tôi"** — về mặt xã hội và pháp lý thì nó
  tương đương một cuốn nhật ký, thứ người ta vẫn luôn viết.
- Câu hỏi mới nảy sinh: **khi người kia thành người yêu và tham gia app, ghi chú
  đi về đâu?** Ba lối: ở lại riêng tư mãi mãi (an toàn nhất) · có nghi thức "cho
  em xem anh đã ghi gì" (đẹp nhưng rủi ro, có thể có ghi chú xấu hổ) · **chỉ phần
  cột mốc tốt nghiệp sang timeline chung, phần cảm xúc ở lại riêng** (có vẻ đúng
  nhất).

### 2026-08-28 — Y1 = (a) + (b): hai cái này khớp nhau thế nào

- Y4. **Chiến lược tốt nghiệp giờ có BA chặng, không phải hai:**
  giai đoạn 1 *tán tỉnh, một người* → giai đoạn 2 *cặp mới yêu, hai người* →
  giai đoạn 3 *sống chung, tiện ích vận hành*. User vừa thêm một chặng vào TRƯỚC.
- Y5. **App cặp đôi hiện tại trở thành ĐÍCH ĐẾN, không còn là sản phẩm.** Giai
  đoạn 1 là cái phễu đứng trước nó. Điều này cũng gỡ khoá cho U1/U3/U6/U8 — chúng
  không chết, chúng nằm ở chặng 3.
- Y6. ⭐ **Mắt xích khoá chặt hai quyết định lại với nhau:** giai đoạn 1 âm thầm
  **tích luỹ giá trị TRƯỚC khi ghép đôi** (P5, P1, P2). Nên đến lúc mời, mình
  không đi xin — mình đưa ra một món quà đã dày sẵn. *"Anh đã ghi lại mọi thứ từ
  ngày đầu tiên gặp em."* Đó là S2 (lời mời là món quà) được cấp năng lượng bởi
  S1 (chế độ một người). Hai lời giải cho X1 khoá vào nhau, và nó cũng chính là
  khoảnh khắc lan truyền của (b).
- Y7. **Lan truyền (b) đến từ đâu trong một sản phẩm một người:**
  - khoảnh khắc mời — giờ là món quà nên tỉ lệ chuyển đổi cao hơn hẳn (Y6)
  - bạn bè của người đang tán tỉnh: giai đoạn này người ta kể cho bạn liên tục
  - hiện vật công khai khi chính thức thành đôi ("chúng mình chính thức rồi")
  - ca bị từ chối (T7): rời đi, nhưng **quay lại với người tiếp theo** — kéo dài
    vòng đời khách hàng thay vì kết thúc nó
  - sản phẩm một người không có bài toán kích hoạt hai phía → vòng lan truyền
    **đơn giản hơn**, không phải yếu hơn
- Y8. ⚠️ **Căng thẳng thật của (b):** người đang tán tỉnh thường **giữ bí mật**.
  Họ có thể không muốn ai biết. Điều đó làm giảm mạnh kênh "kể cho bạn bè". Lan
  truyền có lẽ phải dựa vào khoảnh khắc mời (Y6) và hiện vật lúc chính thức, chứ
  không dựa vào việc khoe trong lúc đang tán.

### 2026-08-28 — Technique 12: Constraint Ladder (nếu người kia không bao giờ tham gia?)

- L1. Nếu 70% người dùng giai đoạn 1 không bao giờ ghép đôi thì sản phẩm vẫn phải
  đứng được một mình. → Giai đoạn 1 **không được thiết kế như một cái phễu**; nó
  phải là một sản phẩm hoàn chỉnh tự nó. Nếu nó chỉ là phễu, nó sẽ dở.
- L2. Nếu bị từ chối (T7): app phải giúp khép lại, không được giữ người dùng lại
  bằng nỗi đau. Nghi thức lưu trữ/xoá. Đây là lúc dễ làm ẩu nhất.
- L3. Nếu người dùng đang tán tỉnh **người đã có người yêu** — app có nên biết và
  có nên can dự? Nhánh gai góc, ghi lại chứ chưa giải.
- L4. Nếu người dùng là người bị theo đuổi chứ không phải người theo đuổi? Sản
  phẩm hiện chỉ hình dung một phía.
- L5. Zero-backend: phần lớn giai đoạn 1 có thể chạy **local-first**, vì dữ liệu
  là riêng tư và một người. Vừa rẻ vừa đúng về mặt riêng tư.

### 2026-08-28 — Technique 13: Channel-First cho sản phẩm một người (domain shift → phễu bán hàng, nhật ký cá nhân)

- Z6. **Không còn bài toán kích hoạt hai phía** → thu hút dễ hơn một bậc lớn.
- Z7. **Thị trường tiềm năng lớn hơn nhiều:** số người đang thích ai đó >> số cặp
  mà cả hai chịu cài chung một app.
- Z8. **X4 (chi trả thấp) có thể SAI ở giai đoạn 1.** Người đang tán tỉnh vừa lo
  lắng vừa có động lực cao, và **đã đang tiêu tiền** cho hẹn hò và quà. Sự lo lắng
  là thứ dễ kiếm tiền hơn sự hài lòng. Giai đoạn 1 có thể là chặng chi trả tốt
  nhất, không phải tệ nhất.
- Z9. Đối thủ thật của giai đoạn 1 không phải app cặp đôi, mà là **app Ghi chú,
  bạn thân, và ChatGPT**. Phải thắng được ba thứ đó.
- Z10. Khung "trợ lý" biện minh tự nhiên cho việc dùng AI, khác với app cặp đôi.

### 2026-08-28 — Rủi ro chiến lược của hướng rẽ

- M1. ⚠️ **Giai đoạn 1 và giai đoạn 2 là hai sản phẩm khác nhau với hai thương
  hiệu khác nhau.** "Trợ lý tán tỉnh" và "app cặp đôi" nằm chung một bản cài là
  khó hiểu — và có thể tệ hơn thế: **người yêu phát hiện bạn trai mình có cài
  "trợ lý tán tỉnh" là một tình huống rất xấu.** Ba lối: cùng một app đổi chế độ ·
  hai app riêng có bàn giao · hoặc **một app duy nhất mà chế độ giai đoạn 1 được
  định khung là "nhật ký riêng" chứ không phải "công cụ tán tỉnh"**.
- M2. Codebase hiện tại khoá theo `coupleId` ở khắp nơi. Chế độ một người là một
  bổ sung kiến trúc đáng kể, không phải một feature.
- M3. Vòng đời giai đoạn 1 ngắn (tán tỉnh kết thúc trong vài tuần tới vài tháng,
  theo hướng nào cũng vậy). Nhưng ca "không" là cơ hội quay lại (Y7), nên vòng
  đời khách hàng vẫn dài.
- M4. Rủi ro sản phẩm bị cảm nhận là **tính toán và lạnh lùng**, làm hỏng luôn
  thương hiệu ấm áp của app cặp đôi. Đây là rủi ro lan sang, không chỉ rủi ro cục bộ.

### 2026-08-28 — Nhận định nổi lên ở cycle 3

- X1 không phải một vấn đề marketing. Mổ ra thì nó là **một khuyết tật cấu trúc**:
  sản phẩm có giá trị bằng 0 cho một người (X1e), và năm triệu chứng còn lại đều
  mọc ra từ đó. Hướng rẽ của user chữa đúng gốc.
- Y6 là mắt xích đẹp nhất tìm được cho tới giờ: giai đoạn một người **tích luỹ
  sẵn món quà** làm cho lời mời không thể từ chối. Nó đồng thời giải X1, phục vụ
  (a) tốt nghiệp, và tạo ra (b) khoảnh khắc lan truyền — ba con chim một mũi tên.
- Nhưng toàn bộ xương sống đạo đức đã dựng ở cycle 1 **mất hiệu lực ở giai đoạn 1**,
  vì nó giả định người kia là một bên tham gia. Cần một bộ luật riêng cho giai
  đoạn 1, và **ràng buộc "một người tại một thời điểm"** là điều kiện rẻ nhất để
  thực thi nó.
- M1 (hai thương hiệu trong một app) là rủi ro chiến lược lớn nhất của hướng rẽ,
  và nó chưa được giải.
- Z8 lật ngược một giả định cũ: giai đoạn 1 có thể là chặng **chi trả tốt nhất**,
  không phải tệ nhất, vì lo lắng dễ kiếm tiền hơn hài lòng.

### 2026-08-28 — QUYẾT ĐỊNH USER (cycle 4): Lựa chọn 1 + 2, và trợ lý làm việc trên HOẠT ĐỘNG

User chọn cả hai định khung, nhưng đính chính then chốt: **"trợ lý" KHÔNG mang
nghĩa phân tích chiến thuật, chỉ mang nghĩa trợ giúp thực dụng — lên kế hoạch du
lịch, chọn phim, v.v.**

Đính chính này không phải một sự thu hẹp. Nó là **đường cắt sạch nhất tìm được
trong cả bốn cycle**, vì nó biến lưỡi dao từ một lời hứa về ý định thành một quy
tắc về *đối tượng*:

- R-1. **LƯỠI DAO PHIÊN BẢN SẮC: trợ lý làm việc trên HOẠT ĐỘNG, không làm việc
  trên CON NGƯỜI.**
- Ba hướng, hai được phép:
  - **Hướng ra ngoài — hoạt động** (kế hoạch, địa điểm, phim, chuyến đi, quà):
    đây là Lựa chọn 1 theo đúng nghĩa user muốn. ✅
  - **Hướng vào mình — nhật ký** (cảm xúc, tự nhận thức): Lựa chọn 2. ✅
  - **Hướng vào người kia — phân tích** (tâm lý, chiến thuật, xác suất, kịch bản):
    ❌ chính là vùng cấm đã lo ngại.
- R-2. **Lựa chọn 1 + 2 không phải một sự thoả hiệp — đó chính xác là hai trục an
  toàn, và trục bị bỏ lại chính là trục nguy hiểm.** N1-N7 chết tự động, không cần
  luật riêng nào để cấm.
- R-3. **M1 gần như tan biến.** Một "app lên kế hoạch đi chơi + nhật ký riêng" bị
  người yêu phát hiện trên máy bạn trai là chuyện **hoàn toàn bình thường**. Không
  ai giận vì bạn trai mình có app lên kế hoạch du lịch. Rủi ro chiến lược lớn nhất
  của cycle 3 vừa được giải bằng một câu đính chính.
- R-4. Ràng buộc "một người tại một thời điểm" **không còn cần thiết như một luật
  đạo đức** (vì không có hồ sơ đối tượng để mà nhân bản), nhưng vẫn nên giữ như
  một lựa chọn định vị.

### 2026-08-28 — Hệ quả kiến trúc: HOẠT ĐỘNG là đối tượng đi xuyên ba chặng

Nếu trợ lý làm việc trên hoạt động, thì hoạt động chính là **đối tượng xương sống**
của sản phẩm — và nó lớn lên cùng người dùng thay vì phải xây lại ở mỗi chặng:

- G-a. **Chặng 1 — danh sách của tôi.** Chỗ tôi muốn đưa em đi. Phim tôi nghĩ em
  sẽ thích. Một người, riêng tư, hữu ích ngay.
- G-b. ⭐ **Lời mời = trao danh sách đó.** *"Đây là 12 chỗ anh đã ghi lại để đưa
  em đi."* **Đây là phiên bản Y6 tốt hơn hẳn.** Y6 cũ (*"anh đã ghi lại mọi thứ
  em nói"*) hơi rợn. Y6 mới lãng mạn và an toàn tuyệt đối. Đính chính của user
  vừa nâng cấp luôn khoảnh khắc lan truyền.
- G-c. **Chặng 2 — danh sách chung.** Lật bài (P6) để chọn, hai chìa khoá (P0) để
  chốt. Hai nguyên thuỷ nền tảng cắm vào đúng đối tượng này.
- G-d. **Chặng 3 — kế hoạch vận hành.** Lịch, tiền, ai lo cái gì (U1/U3/U6).
- G-e. → **Đây không phải ba sản phẩm. Đây là MỘT sản phẩm với một đối tượng lớn
  dần.** Chiến lược tốt nghiệp (a) từ chỗ là một nguyện vọng trở thành một sự thật
  kiến trúc. M2 (codebase khoá `coupleId`) trở thành "đối tượng hoạt động có 1
  hoặc 2 chủ sở hữu", không còn là hai hệ thống song song.

### 2026-08-28 — Technique 14: JTBD trên chính HOẠT ĐỘNG (domain shift → đời sống hẹn hò thật)

Cái gì thực sự khó khi hai người mới quen muốn làm gì đó cùng nhau?

- AC1. **Không biết chọn gì** → máy quyết định (U2 từ cycle 1) sống lại làm trung tâm.
- AC2. **Không biết người kia thích gì** → cùng một việc cần làm, hai cơ chế theo
  chặng: chặng 1 dùng sổ ghi sở thích, chặng 2 dùng lật bài. Rất gọn.
- AC3. **Sợ chọn sai, sợ nhạt** — nỗi lo lớn nhất của giai đoạn tán tỉnh, và nó
  là nỗi lo về *hoạt động*, không phải về *con người*. Nằm đúng vùng cho phép.
- AC4. ⭐ **Chuyến đi đầu tiên là bài kiểm tra lớn nhất.** Ngủ chung lần đầu, ở
  cùng nhau 48 giờ, tiêu tiền chung lần đầu. Đây là cột mốc căng thẳng nhất của
  cặp mới yêu và **không app nào hỗ trợ**. Hữu ích + unique cùng lúc.
- AC5. ⭐ **Danh sách "sẽ đi / sẽ xem" bị thất lạc trong chat.** Ai cũng từng nói
  "để hôm nào mình đi chỗ này nhé" rồi quên sạch. **Tần suất cao nhất, rẻ nhất để
  giải, và là đúng cái đối tượng xương sống G-a.**
- AC6. **Xem phim khi yêu xa** — đồng bộ, phục vụ phân khúc con cường độ cao nhất (H13).
- AC7. **Chia tiền chuyến đi** — `expenses` đã có, nhưng ở chặng 1-2 thì tế nhị,
  cần xử lý nhẹ tay.
- AC8. **Đặt chỗ, vé, quà** → đây là chỗ doanh thu đi vào một cách tự nhiên.

### 2026-08-28 — Doanh thu giờ đã rõ

- $1. Hoạt động thì tốn tiền. Đặt chỗ, vé, chuyến đi, nhà hàng, quà. Kết hợp Z8
  (chặng 1 chi trả tốt vì lo lắng dễ kiếm tiền hơn hài lòng) và X4(c).
- $2. Điểm hay về mặt đạo đức: **không kiếm tiền trên mối quan hệ, mà kiếm tiền
  trên chuyến đi mà đằng nào họ cũng sẽ đi.** Sạch hơn hẳn mọi mô hình đã bàn ở
  cycle 2, và nó không đụng gì tới luật của idea hearts.
- $3. Bản địa hoá VN cắm thẳng vào đây: quán xá, chuyến đi cuối tuần từ HN/SG,
  dịp lễ Việt.

### 2026-08-28 — Nhận định nổi lên ở cycle 4

- Đính chính của user giải quyết **ba thứ cùng lúc** mà không cần thêm cơ chế nào:
  lưỡi dao đạo đức (R-1), rủi ro thương hiệu M1 (R-3), và khoảnh khắc lan truyền
  Y6 (G-b). Đây là loại đính chính hiếm — thu hẹp phạm vi mà lại mở rộng chất lượng.
- **Đối tượng "hoạt động" biến chiến lược tốt nghiệp từ nguyện vọng thành kiến
  trúc** (G-e). Đó là thứ làm cho quyết định Y1(a) trở nên khả thi thật.
- AC5 (danh sách thất lạc trong chat) là ứng viên rẻ nhất và phổ quát nhất; AC4
  (chuyến đi đầu tiên) là ứng viên khác biệt nhất.
- Hai nguyên thuỷ P0/P6 từ cycle 1 vẫn đứng nguyên, và giờ chúng có một đối tượng
  cụ thể để cắm vào thay vì trôi nổi.

### 2026-08-28 (cycle 5) — Technique 15: Một tuần trong đời, 168 giờ (domain shift → nhịp sinh hoạt thật của người Việt 20-27 tuổi)

**Phát hiện cấu trúc mở đầu cycle 5.** Cặp mới yêu ở VN gặp nhau 1-2 lần/tuần,
khoảng 8-12 giờ trên 168 giờ. **Hơn 90% thời gian của một mối quan hệ mới là lúc
KHÔNG ở cạnh nhau.** Đặt bốn cụm xương sống lên trục thời gian thì lộ ra ngay:

| Ô | Nội dung | Độ phủ hiện tại |
|---|---|---|
| **TRƯỚC** | lên kế hoạch cho lần gặp | C1-C4 phủ gần kín |
| **TRONG** | lúc đang ở bên nhau | gần như trống |
| **SAU** | ký ức về lần gặp đó | `timeline` có sẵn nhưng không ai đổ dữ liệu vào |
| **GIỮA** | 90% thời gian còn lại | **hoàn toàn trống** |

→ Bốn xương sống đang phục vụ khoảng 7% quỹ thời gian. Đây là hướng mở rộng đúng
nhất, không phải là thêm tính năng cạnh C1-C4.

**Ô GIỮA — GI (90% thời gian, hiện trống)**

- GI1. **Đếm ngược gắn với kế hoạch cụ thể.** W7 đã có, nâng lên: "còn 3 ngày nữa
  tới cái quán em lưu tuần trước". Nối ô GIỮA ngược về C1.
- GI2. **Gói hàng chậm.** Gửi một thứ nhỏ mà người kia chỉ mở được vào thời điểm
  định trước. Khác chat ở chỗ **có độ trễ có chủ đích** — tạo mong chờ thay vì
  tạo nghĩa vụ trả lời.
- GI3. **"Đang nghĩ tới em" một chạm.** Không nội dung, không cần trả lời. Chi phí
  xã hội bằng 0. Rất hợp người ngại nhắn tin trước.
- GI4. **Trạng thái nhẹ, không phải vị trí.** "đang học", "đang chạy deadline",
  "đang buồn ngủ". Giải nỗi lo "sao lâu rồi chưa rep" mà **không hề theo dõi vị
  trí** — tránh thẳng R8.
- GI5. ⭐ **Cùng làm việc riêng trong một phiên chung.** Hai người học/làm cùng
  khung giờ, thấy nhau đang bật. **Đây là "ở bên nhau" mà không tốn nội dung** —
  giải bài toán hết chuyện để nói. Rất hợp sinh viên.
- GI6. **Một câu hỏi mỗi tối.** Cả hai trả lời, chỉ hiện khi cả hai xong (P6).
  Một hạt nhỏ mỗi ngày, tích dần thành C8.
- GI7. **Nghi thức khép ngày.** "em ngủ đây". Tần suất 365/năm, chi phí gần 0.
- GI8. **Bản tin cuối tuần của chúng ta.** Tự sinh từ C1 + ô SAU. Rẻ vì tái dùng
  dữ liệu đã có.
- GI9. ⭐ **Hàng chờ "để gặp rồi kể".** Có chuyện muốn kể nhưng chưa tiện gọi →
  cất vào, lần gặp tới bật ra. **Nối ô GIỮA sang ô TRONG** và biến việc chờ đợi
  thành việc tích luỹ.
- GI10. ⚠️ **Nhịp không đối xứng.** Người nhắn nhiều / người nhắn ít là mâu thuẫn
  số một của cặp mới yêu. App có thể làm nhịp này *nhìn thấy được* mà không chấm
  điểm — nhưng đây là mép vực bảng-điểm, cần lưỡi dao trước khi làm.

**Ô TRONG — TR (nghịch lý: app tốt nhất ở đây là app biến mất)**

- TR1. ⭐ **Chế độ hẹn hò — app tự câm.** Khi hai máy ở gần nhau, app tắt hết
  thông báo của chính nó. **Tính năng hay nhất có thể là tính năng tự tắt.** Rất
  khó bắt chước, vì đối thủ sống bằng chỉ số thời gian trong app.
- TR2. **Một chạm giữ chỗ khoảnh khắc.** Không mở app, không caption, điền sau.
  Giải bài toán "ai đổ dữ liệu vào timeline".
- TR3. **Chụp chung hai máy.** Cùng lúc, hai góc nhìn, ghép thành một tấm.
- TR4. ⭐⭐ **Chế độ để-điện-thoại-xuống.** Cả hai cùng khoá máy, đếm thời gian
  không dùng. **Cầu nối bất ngờ sang IDEA-001: nếu hearts được đúc từ thời gian
  KHÔNG dùng app, thì rủi ro hiệu lực H5 ("gương đang đo mức dùng app") gần như
  bị đảo ngược hoàn toàn.** Đáng ghi chéo sang idea hearts.
- TR5. **Album tự mở tự đóng theo buổi hẹn.**
- TR6. **Chốt hoá đơn ngay tại chỗ, nhẹ tay** (AC7).

**Ô SAU — KY (ký ức)**

- KY1. **Vấn đề gốc: `timeline` đã tồn tại nhưng trống.** Lời giải không phải là
  giục người dùng nhập, mà là **timeline tự viết từ C1 + TR2, người dùng chỉ xác nhận**.
- KY2. ⭐ **Sau buổi hẹn, hỏi đúng một câu.** "Đoạn nào vui nhất?" Cả hai trả lời,
  lật bài. 10 giây, tạo ký ức chất lượng cao hơn 20 tấm ảnh.
- KY3. **Ký ức nổi lên theo địa điểm**, không chỉ theo ngày. Đi ngang quán cũ thì
  nổi lên. Khác biệt so với "một năm trước hôm nay" đã phổ biến.
- KY4. **Cuốn sách cuối năm, bản in được.** Sản phẩm vật lý bán được → nối C10.
- KY5. **Kho "chuyện của chúng ta"** — chuyện kể lại được, không phải ảnh. Text-first.
- KY6. ⭐ **Ký ức được phép mâu thuẫn.** Cùng một buổi, hai người nhớ khác nhau,
  cho cả hai phiên bản cùng tồn tại. Rất thật, rất unique, và rất rẻ.
- KY7. **Quyền xoá ký ức khi chia tay** — nối nghi thức kết xuất bên IDEA-001.

### 2026-08-28 (cycle 5) — Technique 16: SCAMPER trên nguyên thuỷ hai chìa khoá (C5)

Biến đổi hạ tầng thì cả sản phẩm đổi theo, nên đây là đòn bẩy lớn nhất trên mỗi
đơn vị công sức.

- SC1. **Substitute** — thay "cả hai đồng ý" bằng "cả hai không phản đối trong
  24h". Đồng thuận im lặng cho việc nhỏ, giảm ma sát.
- SC2. ⭐ **Combine** — hai chìa khoá + lật bài thành một: cả hai chọn mù, trùng
  thì tự chốt. **Đây chính là cơ chế chọn hoạt động hoàn hảo cho C2**, và nó
  không phải tính năng mới mà là hợp nhất hai nguyên thuỷ đã có.
- SC3. ⭐ **Adapt** — hai chìa khoá cho việc **huỷ**, không chỉ việc làm. Huỷ hẹn
  cần cả hai đồng ý → chống huỷ kèo tuỳ hứng, nỗi đau rất thật.
- SC4. **Modify to** — lời mời có hạn 48h, tạo nhịp.
- SC5. **Modify thu nhỏ** — nửa chìa khoá: "anh nghiêng về cái này", bày tỏ mà
  chưa cam kết.
- SC6. **Put to other use** — hai chìa khoá để mời người thứ ba vào xem một phần.
- SC7. ⭐ **Eliminate** — **quà bất ngờ phải phá vỡ hai chìa khoá mới có nghĩa.**
  `wishlistThemeId` đang dựng dở chính là chỗ này. Nguyên thuỷ nào cũng cần một
  ngoại lệ có chủ đích, nếu không nó thành gông cùm.
- SC8. **Reverse** — trao quyền thay vì xin phép: "để em chọn giúp anh".

### 2026-08-28 (cycle 5) — Technique 17: Anti-problem — "thiết kế app khiến cặp mới yêu chia tay nhanh nhất"

Đảo ngược để lộ ra hàng rào. Năm cách giết một mối quan hệ, thành năm điều luật:

- XD1. Chấm điểm ai yêu nhiều hơn → **không bao giờ so sánh hai người với nhau.**
- XD2. Báo "người ấy online 3 tiếng mà chưa trả lời bạn" → **không bao giờ báo cáo
  hành vi của người kia cho người này.** Luật mới và mạnh: nó chặn sạch một lớp
  tính năng nghe rất hấp dẫn.
- XD3. Chuỗi ngày liên tiếp → **không streak.** Streak biến tình cảm thành nghĩa
  vụ và cú trượt chuỗi tạo cãi nhau thật. Cùng họ với luật "không hệ số nhân" của
  IDEA-001.
- XD4. Lưu mọi lời hứa để đối chiếu → R6. **Cái gì lưu được thì phải quên được.**
- XD5. So sánh với cặp khác → **không bảng xếp hạng xã hội.**
- → ⭐ Năm điều này gộp thành **"Hiến chương không làm"**, và nó **là tài sản
  marketing chứ không phải giới hạn** — đúng thị trường đang chán các app theo dõi
  nhau. Đây là thứ nói được thành một câu trên trang chủ.

**Mở lại ô xung đột (U4/V8 đã hoãn hai cycle) — vì đây là chỗ "hữu ích" đậm nhất**

- XD6. ⭐⭐ **Nút "em đang giận, chưa nói chuyện được, nhưng anh đừng lo."** Giải
  đúng nỗi sợ lớn nhất trong lúc im lặng: tưởng người kia đã bỏ đi. Một nút. Chi
  phí gần bằng không, giá trị cảm xúc rất cao, chưa app nào có. **Ứng viên đơn lẻ
  mạnh nhất của cycle 5.**
- XD7. **Hẹn giờ nguội.** "Mình nói lại chuyện này lúc 8h tối nhé", chốt bằng hai
  chìa khoá.
- XD8. **Sửa chữa kiểu Gottman** — không phân xử ai đúng, chỉ một cử chỉ hạ nhiệt.
- XD9. ⭐ **Nhật ký riêng lúc giận.** C6 của chặng 1 **không chết khi tốt nghiệp** —
  nó cần nhất đúng vào lúc giận ở chặng 2. Phát hiện này làm C6 đáng đầu tư hơn hẳn.
- XD10. **Cãi nhau lần đầu là một cột mốc, không phải một thất bại.** Đóng khung
  lại, nối C7.

### 2026-08-28 (cycle 5) — Technique 18: Vay mượn miền xa (nghi lễ, lưu trữ học, y tế dự phòng, board game hợp tác) + ô người thứ ba

- BE1. *(nghi lễ)* **Cái gì lặp lại đúng giờ đúng ngày thì tạo cảm giác thuộc về.**
  GI6 và GI7 là hạt giống đúng loại.
- BE2. *(lưu trữ học)* **Bản ghi khác câu chuyện.** Ảnh là bản ghi; chuyện kể mới
  là thứ người ta quay lại đọc. Củng cố KY5.
- BE3. *(y tế dự phòng)* **Khám định kỳ, không phải cấp cứu.** U9 check-in tháng
  đóng khung lại thành nhịp đều, làm lúc đang ổn chứ không đợi có vấn đề.
- BE4. *(board game hợp tác)* **Cùng thắng hoặc cùng thua, không bao giờ đấu nhau.**
  Luật cho mọi thứ có tính chơi. Giết W3 ở dạng đấu trường, giữ nó ở dạng hợp tác.

**Ô người thứ ba (chưa từng chạm tới)**

- BE5. **Bạn bè của người kia.** Gặp nhóm bạn là một bài kiểm tra lớn. Sổ nhớ ai
  là ai. ⚠️ Ranh giới R-1: ghi chú hậu cần (tên, quan hệ) thì được, hồ sơ tính
  cách thì không.
- BE6. **Ra mắt gia đình** — ở VN là cột mốc khổng lồ, kèm nghi thức, quà, xưng hô.
- BE7. ⭐ **Đôi bạn cùng chơi — hai cặp đi chơi chung.** **Giải được Y8:** người
  đang tán tỉnh thì giữ bí mật nên không giới thiệu app cho bạn, nhưng cặp đôi
  công khai thì rủ cặp khác rất thoải mái. Kênh lan truyền chuyển từ chặng 1 sang
  chặng 2 — đúng chỗ nó hoạt động được.
- BE8. **Trang chia sẻ cho người ngoài xem** — một trang duy nhất, không lộ gì
  riêng tư. Cùng luật "chia sẻ câu chuyện, không chia sẻ con số".

### 2026-08-28 (cycle 5) — Technique 19: Đào sâu bản địa VN (C9 trước đây mới chỉ là một dòng)

- BD1. ⭐ **Xưng hô.** Anh/em, cách gọi riêng của từng cặp. App phải học và dùng
  đúng. **Rào cản bản địa mạnh nhất** — không app ngoại nào làm được, và nó chạm
  vào từng câu chữ trong sản phẩm.
- BD2. **Lịch âm và dịp lễ Việt.** Tết, Trung thu, 8/3, 20/10, cùng với 14/2 và
  chuỗi ngày 14 hằng tháng. **Nhiều dịp gấp mấy lần phương Tây** → nguồn nhắc dịp
  cực dày cho C1.
- BD3. **Ra mắt gia đình** — nghi thức, quà, xưng hô với bố mẹ người kia. Nỗi lo
  có thật, không app nào hỗ trợ.
- BD4. **Chuyến đi cuối tuần từ HN / SG** — tập địa điểm hữu hạn, làm sẵn được,
  cắm thẳng vào C3.
- BD5. ⭐ **Phần lớn cặp mới yêu VN còn sống với bố mẹ.** Điều đó định hình toàn bộ
  ô GIỮA: gặp ít, nhắn nhiều, ít không gian riêng. **Đây là lý do ô GIỮA quan
  trọng ở VN hơn hẳn so với phương Tây** — và là một lợi thế bản địa thật, không
  phải chỉ là dịch thuật.
- BD6. **Quán cà phê là không gian hẹn hò mặc định**, không phải nhà.
- BD7. **Đếm kỷ niệm theo tháng và theo trăm ngày** — mật độ cột mốc dày hơn hẳn.

### 2026-08-28 (cycle 5) — Đồ dựng dở, đọc lại dưới ánh sáng cycle 5

- DS1. `vow` có màn hình nhưng không có backend → **giao ước là ứng viên hoàn hảo
  cho hai chìa khoá**, và nối thẳng XD7 + XD10.
- DS2. `wishlistThemeId` → chính là SC7 quà bất ngờ.
- DS3. emoji `price` chưa trừ hearts → để lại cho IDEA-001.
- DS4. ⭐ `dream_jar` và C1 **nên là cùng một đối tượng ở hai tầm xa khác nhau**:
  ước mơ chung chỉ là hoạt động ở thì tương lai xa. Gộp lại thì `dream_jar` hết
  trôi nổi và C1 có được chiều sâu.
- DS5. `love_contracts` → nối DS1 và XD7.
- DS6. Love Pet đang trôi nổi. Ứng viên khả dĩ: pet phản ánh **nhịp** của ô GIỮA,
  tuyệt đối không phản ánh điểm số (theo XD1/XD3).

### 2026-08-28 — Nhận định nổi lên ở cycle 5

- **Trục thời gian là phát hiện chính.** Bốn xương sống phủ ~7% quỹ thời gian của
  một mối quan hệ mới. Ba ô còn lại — GIỮA, TRONG, SAU — là chỗ mở rộng có căn cứ.
- **XD6 là ứng viên đơn lẻ mạnh nhất cycle này**: gần như không tốn gì, giá trị
  cảm xúc rất cao, chưa ai làm.
- **"Hiến chương không làm" (XD1-XD5) là tài sản, không phải giới hạn.** Nó cũng
  là bộ luật duy nhất đủ chặt để cho phép làm GI10 và BE5 mà không trượt.
- **TR4 bắc cầu sang IDEA-001** và gần như đảo ngược rủi ro hiệu lực H5.
- **BD5 giải thích vì sao ô GIỮA quan trọng ở VN hơn phương Tây** — lợi thế bản
  địa thật sự, không chỉ là dịch giao diện.
- **BE7 giải Y8** bằng cách dời vòng lan truyền sang chặng 2.
- **XD9 chứng minh C6 không chết khi tốt nghiệp** — nhật ký riêng là thứ hiếm hoi
  chạy suốt cả ba chặng cùng với C1.
- **SC2 và SC7 cho thấy C5 chưa được khai thác**: nguyên thuỷ hai chìa khoá vừa
  cần một phép hợp nhất (SC2) vừa cần một ngoại lệ có chủ đích (SC7).

### 2026-08-28 (cycle 7) — QUYẾT ĐỊNH USER: duyệt bảng ứng viên, trả lời 7 câu Phần F

**Q-a / C8 — GIỮ, nhưng đổi cả cơ chế lẫn tần suất.** User: *"nên học từ chat,
hoặc đôi khi chỉ nên thi thoảng chèn vài câu hỏi chứ không phải bảng câu hỏi."*

- D7-1. ⭐ **Tần suất chính là lời giải cho bẫy cạn nội dung (RS-B1), và tôi đã bỏ
  sót nó.** Cycle 6 tôi chỉ tìm lời giải ở phía nguồn (RS2 sinh nội dung từ dữ liệu
  cặp đôi). User chỉ ra lời giải ở phía nhịp: cùng một kho hữu hạn, hỏi mỗi ngày
  thì lộ lặp trong vài tuần, hỏi thi thoảng và đúng lúc thì dùng được nhiều năm.
  **Hai lời giải này nhân với nhau chứ không thay thế nhau.**
- D7-2. **"Bảng câu hỏi" chết, "câu hỏi chèn đúng lúc" sống.** Khác biệt không nằm
  ở nội dung mà ở chỗ nó là một màn hình riêng (phải vào, phải làm cho xong) hay
  một hạt nhỏ xuất hiện trong luồng đang có.
- D7-3. 🔍 **Kiểm chứng mã nguồn: `backend/src/modules/messages/` TỒN TẠI** — cặp
  đôi đã chat ngay trong app. Vậy "học từ chat" là khả thi về mặt dữ liệu, và dữ
  liệu đó là của chính hệ thống, không phải đi đọc app khác.
- D7-4. ⚠️⚠️ **NHƯNG "học từ chat" đụng thẳng N3 và lưỡi dao R-1, và nó chỉ tồn
  tại được ở chặng 2 trở đi.**
  - Ở **chặng 2-3**: chat là chat CHUNG của hai người trong app mình. Học từ đó
    là học từ "chúng ta". Nằm trong luật, với điều kiện có đồng thuận hai chiều.
  - Ở **chặng 1**: **không có chat nào để học.** Người kia chưa ở trong hệ thống.
    Muốn "học từ chat" ở chặng 1 thì phải đọc Zalo/Messenger của người dùng —
    tức là N3 (phân tích tin nhắn của họ) và N4 (theo dõi), đã bị loại theo R-1.
  - → **Đề nghị luật: "học từ chat" chỉ áp dụng cho chat chung trong app, chỉ từ
    chặng 2, và bật bằng hai chìa khoá.** Chặng 1 dùng nguồn khác: chính hoạt động
    người dùng đã ghi (C1), cột mốc (C7), nhật ký (C6).
- D7-5. **Cái được học phải là "chúng ta", không phải "người kia".** Học ra "hai
  đứa hay nhắc tới biển" thì được (thuộc về hoạt động, hợp R-1); học ra "cô ấy
  hay buồn vào tối chủ nhật" thì vi phạm XD2 (không báo cáo hành vi người kia).

**Q-b — MỘT APP ĐỔI CHẾ ĐỘ. Chốt chắc chắn.**

- D7-6. M1 khép lại hoàn toàn. Không còn phương án hai app.
- D7-7. ⚠️ Hệ quả: **M2 trở thành việc bắt buộc, không né được.** Codebase khoá
  `coupleId` ở khắp nơi; một app hai chế độ nghĩa là mô hình dữ liệu phải chịu
  được "đối tượng có 1 chủ sở hữu" rồi chuyển thành "2 chủ sở hữu" mà không mất
  dữ liệu. Đây là hạng mục kiến trúc lớn nhất của cả idea.
- D7-8. ⭐ Mặt tốt: **khoảnh khắc đổi chế độ CHÍNH LÀ G-b/Y6.** Chuyển chế độ và
  trao món quà là cùng một sự kiện, không phải hai. Kiến trúc và vòng lan truyền
  trùng nhau một chỗ.

**Q-c — GIỮ ghi chú chặng 1, trong một khu riêng như kho kỷ niệm, mở được bất kỳ
lúc nào, có thể đặt mật khẩu.**

- D7-9. Giải xong câu hỏi di trú: **không xoá, không ép gộp.** Ghi chú chặng 1 trở
  thành một **kho kỷ niệm riêng** tồn tại vĩnh viễn song song với không gian chung.
- D7-10. Củng cố XD9: C6 không chỉ sống sót qua tốt nghiệp, nó có nhà riêng.
- D7-11. ⚠️⚠️ **Rủi ro cần giải: một căn phòng khoá mà người kia BIẾT là có.**
  Đây là mìn niềm tin trong một app cặp đôi — "sao anh phải khoá cái đó?". Và nó
  là đúng véc-tơ R8 (kiểm soát cưỡng ép): người kia có thể ép đưa mật khẩu, lúc
  đó khoá còn tệ hơn không khoá vì nó tạo ra một thứ để đòi.
  - Hướng giải G-i: **khu riêng là mặc định cho MỌI người dùng**, không phải một
    thứ bật lên khi có gì cần giấu. Cái gì ai cũng có thì không tố cáo ai.
  - Hướng giải G-ii: **người kia không nhìn thấy sự tồn tại của khu đó**, không
    có ổ khoá nào hiện ra để mà hỏi.
  - Hướng giải G-iii: khoá bằng sinh trắc học thay vì mật khẩu — khó ép hơn, và
    không có chuỗi ký tự nào để đòi.
  - Hướng giải G-iv: đóng khung là "nhật ký cá nhân", một thứ ai cũng hiểu là
    riêng tư, thay vì "kho bí mật về mối quan hệ".
- D7-12. Nối KY7 và nghi thức kết xuất: kho kỷ niệm riêng cũng phải **xoá được**
  theo ý chủ nhân, đúng luật XD4 (cái gì lưu được thì phải quên được).

**Q-d — MỘT NGƯỜI TẠI MỘT THỜI ĐIỂM. Chốt.**

- D7-13. Ràng buộc này giờ là cấu trúc, không phải lời hứa. Nó là thứ tách sản
  phẩm khỏi toàn bộ nhóm đối thủ chặng 1 mà nghiên cứu RS-C1/RS-C2 tìm được.
- D7-14. ⭐ **Q-c và Q-d ăn khớp nhau rất đẹp:** vì chỉ một người tại một thời
  điểm, nên khi một chương khép lại (T7 bị từ chối, hoặc chia tay), chương đó
  **đi vào đúng kho kỷ niệm riêng của Q-c** rồi người dùng mở chương mới. Không
  cần cơ chế thứ ba. Đây cũng chính là lời giải tử tế cho L2/T7.

**Q-e — CẢ HAI: fix cứng trước, AI sau, AI cần đào riêng.**

- D7-15. Fix cứng = bộ lịch dịp sẵn (BD2), gợi ý theo chủ đề, tập địa điểm HN/SG
  (BD4). Rẻ, tất định, không rủi ro riêng tư, chạy offline, không tốn chi phí trên
  mỗi người dùng.
- D7-16. **Ghi vào plan — AI cần một vòng đào riêng**, các câu chưa trả lời:
  - AI làm được gì mà bộ gợi ý tĩnh không làm được? (nếu không trả lời rõ thì
    chưa cần AI)
  - Chi phí trên mỗi người dùng ở phân khúc sinh viên VN, đối chiếu Z8/X4.
  - Riêng tư: gửi dữ liệu quan hệ ra mô hình bên thứ ba, chấp nhận tới đâu.
  - ⚠️ **Ranh giới R-1 với AI:** AI là cách dễ nhất để vô tình vi phạm R-1. Một
    mô hình được đưa chat vào sẽ tự nhiên sinh ra nhận định về CON NGƯỜI. Cần rào
    ở tầng prompt lẫn tầng sản phẩm, không chỉ trông vào ý định.
  - Chạy trên máy hay trên máy chủ; có chế độ không-AI cho người từ chối.

**Q-f — Chặng 3 triển khai sau chặng đầu.**

- D7-17. Đọc hiểu của tôi: **chặng 1 làm trước, C12 hoãn lại, xem xét lại sau khi
  chặng 1 ra mắt.** RS-F4 (VN chặng 3 đến sớm) được ghi nhận nhưng không đổi thứ
  tự làm. Diễn giải này đảo ngược được nếu user muốn nói khác.

**Q-g — BE5 chưa rõ ràng.**

- D7-18. Để mở, không ép quyết. BE5 (sổ nhớ bạn bè người kia) vẫn nằm ở vùng xám
  của R-1 và không chặn bất cứ thứ gì khác.

### 2026-08-28 — Nhận định nổi lên ở cycle 7

- **User tìm ra lời giải thứ hai cho bẫy cạn nội dung mà tôi bỏ sót** (D7-1): tôi
  chỉ nhìn phía nguồn, user nhìn phía tần suất. Hai cái nhân với nhau.
- **Ba câu trả lời khoá chặt vào nhau:** Q-b (một app) + Q-c (kho riêng vĩnh viễn)
  + Q-d (một người một lúc) tạo thành một vòng đời hoàn chỉnh: mở chương → tốt
  nghiệp hoặc khép lại → chương cũ vào kho riêng → mở chương mới. Không còn khoảng
  trống nào trong vòng đời người dùng.
- **Hai rủi ro mới cần giải trước khi làm:** "học từ chat" ở chặng 1 là bất khả và
  nguy hiểm (D7-4), và căn phòng khoá là mìn niềm tin kiêm véc-tơ R8 (D7-11).
- **M2 giờ là hạng mục kiến trúc bắt buộc** (D7-7), không né được bằng lựa chọn
  sản phẩm nữa.

### 2026-08-28 (cycle 8) — QUYẾT ĐỊNH USER: G-2 = hướng (ii), người kia không thấy sự tồn tại

**Nhưng (ii) có hai cách thực thi, và một cách phản tác dụng nặng.**

- D8-1. ⚠️ **(ii-a) "Tính năng ẩn" — KHÔNG DÙNG.** Lối vào bí mật, cử chỉ ẩn, menu
  giấu. Vấn đề chí mạng: **hai người dùng CÙNG MỘT app.** Người kia có đúng bản
  binary đó trên máy mình. Tính năng ẩn sẽ bị phát hiện — bởi người kia, bởi bài
  đánh giá app, bởi bất kỳ ai vọc. Và **phát hiện ra một căn phòng BÍ MẬT tệ hơn
  nhiều so với phát hiện một căn phòng KHOÁ**: khoá là ranh giới, bí mật là lừa dối.
  Một "phòng bí mật trong app cặp đôi" là thảm hoạ truyền thông chờ sẵn.
- D8-2. ⭐ **(ii-b) "Không giấu cánh cửa, bỏ ổ khoá" — ĐÂY LÀ BẢN CHẠY ĐƯỢC.**
  Khu riêng tồn tại công khai và **đối xứng** cho cả hai người: ai cũng có, ai cũng
  biết là mình có. Cái vô hình không phải cánh cửa mà là **nội dung, và cả việc
  bên trong có gì hay không**. Không tồn tại bất kỳ đường nào — kể cả mật khẩu —
  để tài khoản này xem khu của tài khoản kia.
- D8-3. ⭐⭐ **Hệ quả là câu trả lời an toàn nhất mà sản phẩm có thể trao cho người
  bị ép: "app không có chức năng đó."** Không phải "anh không cho xem" (đối đầu,
  leo thang), mà là một sự bất khả kỹ thuật. **Sản phẩm đứng ra chịu thay người
  dùng.** Đây là mẫu thiết kế an toàn đúng nghĩa và là lời giải sạch nhất cho R8
  tìm được trong cả 8 cycle.
- D8-4. **(ii-b) thực ra là (ii) hợp nhất với (i).** Đối xứng và phổ quát chính là
  thứ làm cho sự vô hình không tố cáo ai. Hai hướng tôi liệt kê rời ở cycle 7 hoá
  ra là một.

**Mật khẩu ở Q-c vẫn còn việc, nhưng đổi mối đe doạ**

- D8-5. Nếu người kia không bao giờ xem được qua tài khoản, thì mật khẩu không còn
  chống tài khoản nữa. Nó chống **mối đe doạ thật hơn trong quan hệ: người kia
  cầm chính máy của mình lúc đang mở khoá.**
- D8-6. ⚠️ Nhưng ô nhập mật khẩu lại làm lộ đúng cái vừa giấu: bấm vào, hiện ô mật
  khẩu, "sao cái này có mật khẩu?".
- D8-7. ⭐ → **Sinh trắc học (hướng iii) là bạn đồng hành tự nhiên của (ii).** Lời
  nhắc Face ID/vân tay đọc ra là "cái máy nó thế", không phải "anh giấu gì". Không
  có chuỗi ký tự nào để đòi. **Đề nghị: sinh trắc học mặc định, mật khẩu chỉ là
  phương án dự phòng khi máy không hỗ trợ, và cả hai đều tuỳ chọn, mặc định TẮT.**
- D8-8. Mặc định tắt là quan trọng: khoá chỉ nên xuất hiện khi người dùng chủ động
  cần, không phải như một lời gợi ý rằng đây là chỗ để giấu.

**Danh sách rò rỉ — cái gì cũng phải im lặng (kiểm khi làm)**

- D8-9. Không thông báo nào về hoạt động trong khu riêng.
- D8-10. Không "hoạt động lần cuối tại...", không dấu vết trong trạng thái nhẹ (GI4).
- D8-11. Không mục nào trong dòng thời gian chung (C16).
- D8-12. Không huy hiệu đếm, không chỉ báo dung lượng.
- D8-13. Tìm kiếm ở không gian chung không được trả về kết quả từ khu riêng.
- D8-14. ⚠️🔧 **`backend/src/modules/data-export/` đã tồn tại** — bản kết xuất phải
  loại khu riêng ra theo mặc định, hoặc tách thành một bản kết xuất riêng. Nếu
  không thì nghi thức kết xuất (D6 bên IDEA-001) chính là chỗ rò rỉ.
- D8-15. Sao lưu / khôi phục không được làm lộ khi cài lại máy.
- D8-16. ⭐ **Không bao giờ hiển thị số lượng thứ KHÔNG được chia sẻ.** Lúc tốt
  nghiệp, người dùng chọn cột mốc nào đi lên dòng thời gian chung. "Đã chia sẻ 4
  cột mốc" là an toàn; bất cứ thứ gì ngụ ý "còn 20 cái nữa ở lại" đều phá hỏng
  (ii-b). **Việc chia sẻ phải cộng thêm, và mờ đục về phần còn lại.**

**Hai điều còn phải chấp nhận**

- D8-17. XD4 vẫn áp: khu riêng phải xoá được, và việc xoá cũng phải im lặng như
  việc tạo.
- D8-18. Mặt trái trung thực: một khu riêng vô hình cũng dùng để giấu chuyện xấu
  được. Ràng buộc Q-d (một người tại một thời điểm) hạn chế phần nào, và một cuốn
  nhật ký riêng vốn là quyền bình thường của con người. Ghi nhận, không coi là
  khủng hoảng. Cách đóng khung "nhật ký cá nhân" (hướng iv) giúp về mặt văn hoá và
  tương thích hoàn toàn với (ii-b).

### 2026-08-28 — Nhận định nổi lên ở cycle 8

- **G-2 khép lại** với bản (ii-b), và nó hoá ra là lời giải R8 tốt nhất của cả
  idea: chuyển từ "người dùng phải từ chối" sang "sản phẩm không có khả năng đó".
- **Hai hướng giải tôi tưởng là loại trừ nhau (i và ii) thực ra là một** (D8-4);
  và (iii), (iv) là bổ trợ chứ không cạnh tranh. Cách tôi trình bày bốn hướng ở
  cycle 7 là sai — chúng không phải bốn lựa chọn thay thế nhau.
- **G-1 vẫn chưa được chốt.** Luật "học từ chat" còn chờ.

### 2026-08-29 — Bổ sung cycle 12 (chặng 1 solo)

**Nỗi đau theo vai, ở chặng 1**

- CS-P1. Vai *người rủ*: không biết bước tiếp theo là gì. Đây là JTBD thật của chặng 1,
  không phải "lưu quán ăn". (nối RS5)
- CS-P2. Vai *người rủ*: không có ai để hỏi. Với người dùng nam đặc biệt đúng — hệ thống
  hỗ trợ xoay quanh quan hệ tình cảm, ít bộc lộ ra ngoài (R12-3). ⇒ C6 là tính năng chịu lực.
- CS-P3. Vai *người rủ*: sợ hỏng chuyện khi rủ. 44% nam nói nỗi sợ làm giảm khả năng chủ
  động liên lạc (R12-1).
- CS-P4. Vai *người được rủ*: chủ động thì bị đọc sai. Kỳ vọng tình dục của phía kia tăng
  khi mình chủ động (R12-2). ⇒ nỗi đau là **hiệu chỉnh tín hiệu**, không phải **lên kế hoạch**.
  ⚠️ Đây là **giả thuyết cần kiểm chứng**, suy từ nghiên cứu nước ngoài, chưa có dữ liệu VN.
- CS-P5. Vai *người được rủ*: đang theo dõi một người mình chưa chắc chắn — cần chỗ ghi
  mà không cam kết. C6 phục vụ được, nhưng khung "nhật ký tình yêu" thì không; khung
  "sổ tay riêng" thì có.
- CS-P6. Cả hai vai, chuyển sang chặng 2: gánh nặng đổi vai (D12-2). Người trước đây được
  rủ thường thành người duy trì. Đây là nỗi đau **chưa từng được liệt kê** trong toàn bộ
  idea trước cycle 12.
- CS-P7. Rủi ro do chính ta tạo: app trở thành ống xả duy nhất, làm nặng thêm việc bộc lộ
  cảm xúc chỉ xoay quanh quan hệ tình cảm (R12-3b). ⇒ L14.

### 2026-08-29 — Bổ sung cycle 13 (trục B: chú ý gì ở đối phương)

- GA-P1. Người rủ muốn **không làm hỏng việc**. "Biết cô ấy đến ngày" chỉ là *phương
  tiện*; *mục đích* là một lời cảnh báo. Nhầm phương tiện với mục đích là lý do tính năng
  này trông như bắt buộc phải có dữ liệu — nó không cần.
- GA-P2. Người được rủ muốn biết **người này có đáng không**. Đây là JTBD hình dạng
  **con người**, và R-1 cấm nó theo định nghĩa (D13-5).
- GA-P3. "Tâm lý" là thứ người được rủ dùng để **quyết định**, không phải để **than
  phiền**. Nghĩa là nhu cầu thật nằm ở **kết quả** (anh ấy cư xử tốt hơn), không ở
  **thông tin** (anh ấy được mấy điểm). GA2 khai thác đúng chỗ này.
- GA-P4. Nguồn thứ ba — **người kia tự khai** — chưa từng xuất hiện trong toàn bộ idea
  trước c13, kể cả ở c8 khi đang bàn về khu riêng và quyền riêng tư.

## Current Snapshot

- Problem framing: Rào cản X1 mổ ra không phải vấn đề marketing mà là **khuyết tật
  cấu trúc — sản phẩm có giá trị bằng 0 cho một người (X1e)**. Lời giải là mở rộng
  ngược lên giai đoạn tán tỉnh, và **đối tượng dùng để mở rộng là HOẠT ĐỘNG**, chứ
  không phải hồ sơ về người kia.
- Target actor: **ba chặng, một đối tượng.** Chặng 1 người đang tán tỉnh → chặng 2
  cặp mới yêu → chặng 3 cặp sống chung. Đối tượng "một việc hai đứa sẽ làm cùng
  nhau" đi xuyên cả ba, chỉ thay đổi số chủ sở hữu (G-a→G-e).
- JTBD chặng 1 **(sửa ở c6 theo nghiên cứu RS-D2)**: nỗi đau số một không phải
  "nghĩ ra việc hay ho để làm" mà là **"tôi đang mắc kẹt trong talking stage và
  không biết cách đẩy chuyện này tiến lên"**. Lời giải vẫn nằm trong lưỡi dao:
  đẩy tiến lên **bằng chuỗi hoạt động cùng nhau**, không bằng phân tích người kia.
  Chỗ riêng để cất cảm xúc (C6) là nửa còn lại.
- Value proposition: Một sản phẩm **đi cùng người dùng qua cả ba chặng**, bắt đầu
  từ lúc còn một mình — và vì bắt đầu từ đó nên lúc mời người kia vào thì trao
  được một món quà cụ thể: *"đây là 12 chỗ anh đã ghi lại để đưa em đi"* (G-b).
- Đã chốt:
  - Phân khúc: cặp mới yêu (c2).
  - Chiến lược Y1 = **(a) tốt nghiệp + (b) tối ưu lan truyền, cả hai** (c3).
  - Hướng rẽ: mở rộng ngược lên giai đoạn tán tỉnh, sản phẩm một người (c3).
  - **Định khung chặng 1 = Lựa chọn 1 + 2 (c4):** trợ giúp thực dụng trên hoạt
    động (kế hoạch du lịch, chọn phim) **+** nhật ký riêng. Không phân tích chiến thuật.
  - **Lưỡi dao R-1 (c4): trợ lý làm việc trên HOẠT ĐỘNG, không làm việc trên CON NGƯỜI.**
  - Hai nguyên thuỷ nền tảng P0 hai chìa khoá + P6 lật bài, giờ cắm vào đối tượng hoạt động.
- Cụm sau hai đợt gom (19 cụm, xem `## Convergence Notes

### 2026-08-29 (cycle 10) — Chốt thứ tự: lối B, một phase, chặng 1 xếp trước

User chốt **B**: chặng 1 làm trước, nhưng **cùng một phase** với chặng 2, chấp nhận
phase dài hơn. B là thứ tự, không phải phạm vi.

- D10-1. ⚠️ **Sao gắn cho lối C ở c9 bị rút.** Lý do user đưa ra bác thẳng tiền đề của
  tôi: tôi ngầm giả định chặng 2 đã có người dùng để cho phản hồi. Không có. Vậy lối
  A/C chỉ là đem 10 tính năng rẻ tặng cho một app chưa có khán giả — không phải "lấy
  phản hồi thật" mà là trì hoãn có vẻ hợp lý.
- D10-2. ✅ **B tự nuốt nửa rẻ của C.** Cảnh báo lãi-kép-ngược (D9-4) tan biến: nếu M2
  làm trước thì không tính năng mới nào bị khoá cứng vào `coupleId`. Đây là lợi ích
  của B mà tôi đã đánh giá thấp ở c9.
- D10-3. **Giá thật của B (ghi trung thực):** bốn mục phải dựng hai lần — bản một
  người rồi bản cặp đôi (GI3, KY2, GI7, và một phần C1). Theo G-e thì đó là **cùng
  một đối tượng ở hai chế độ**, nên nếu M2 làm đúng thì lần hai là mở rộng chứ không
  phải viết lại. Đây chính là lý do M2 phải nằm ở đợt 0 chứ không phải giữa phase.

### 2026-08-29 — Cắt lại Q1 theo trục chặng (kết quả chính của c10)

Q1 ở c9 được chấm theo giá, chưa cắt theo chặng. Cắt lại thì nó tách đôi:

| Mục | Chặng 1 (một người) | Chặng 2 (cặp đôi) |
|---|---|---|
| BD2 lịch âm + dịp Việt | ✅ gần như y hệt | ✅ |
| GI7 nghi thức khép ngày | ✅ bản tự soi | ✅ |
| KY2 một câu sau buổi hẹn | ✅ hỏi mình, ghi vào C6 | ✅ + lật bài |
| GI3 "đang nghĩ tới em" | ✅ ghi vào C6, không gửi đi đâu | ✅ ping thật tới người kia |
| XD6 nút đang-giận | ❌ cần người kia | ✅ |
| RS1 kỳ vọng liên lạc | ❌ cần hai chìa khoá | ✅ |
| SC7+DS2 quà bất ngờ | ❌ | ✅ |
| DS1 backend `vow` | ❌ | ✅ |
| XD7 hẹn giờ nguội | ❌ | ✅ |
| SC3 huỷ cần hai chìa khoá | ❌ | ✅ |

- D10-4. ⭐⭐ **Bốn mục chạy được ở chặng 1 không phải đồ thừa rẻ tiền — chúng là
  nguồn nạp cho khoảnh khắc mời.** G-1 đã chốt chặng 1 học từ C1/C6/C7 chứ không từ
  chat. KY2, GI7, GI3 chính là ba cái vòi đổ dữ liệu vào C6. Không có chúng chạy
  sớm thì lời mời G-b — *"đây là 12 chỗ anh đã ghi lại để đưa em đi"* — **không có
  gì để trưng ra**. Chúng là chịu lực, không phải trang trí.
- D10-5. Hệ quả: thứ tự trong phase không phải "chặng 1 rồi chặng 2" mà là
  **nền → vòi nạp → khoảnh khắc mời → chặng 2**. Khoảnh khắc mời là bản lề, và nó
  chỉ hoạt động nếu các vòi đã chạy đủ lâu để có tích luỹ.

### 2026-08-29 — Thứ tự thi công trong phase (c10)

**Đợt 0 — nền. Không ship gì.**
- M2 mô hình sở hữu 1 chủ → 2 chủ (tech-lead)
- BD1 xưng hô anh/em — quyết ngay, chi phí tăng theo thời gian
- 12 luật C19 + R-1 + D7-4 + D8-2 làm ràng buộc

**Đợt 1 — chặng 1 phải là sản phẩm hoàn chỉnh (L1), không phải phễu.**
- C1 danh sách hoạt động (đối tượng xương sống, gộp `dream_jar`)
- C6 nhật ký riêng theo bản (ii-b)
- BD2 · KY2 bản một người · GI7 bản một người · GI3 bản một người
- Kiểm thử L1: một người đang yêu mà chưa tỏ tình có dùng được cái này như một sản
  phẩm trọn vẹn không, kể cả nếu người kia **không bao giờ** tham gia?

**Đợt 2 — bản lề. Khoảnh khắc mời.**
- C0 chế độ một người → lời mời G-b → chuyển chế độ → tốt nghiệp
- Đây là chỗ duy nhất giải X1. Chỉ chạy được nếu đợt 1 đã tích luỹ đủ nội dung.

**Đợt 3 — chặng 2, phần rẻ (sáu mục Q1 còn lại).**
- XD6 (5/1, tỉ lệ tốt nhất toàn bảng) · RS1 · SC7+DS2 · DS1 · XD7 · SC3
- Cộng bản chặng-2 của GI3 (ping thật) và KY2 (lật bài)
- Từ đây G-1 mới cho phép học từ chat chung trong app, bật bằng hai chìa khoá

**Đợt 4 — chặng 2, phần dày.**
- KY1 timeline tự viết · SC2 · C3 chuyến đi đầu tiên · RS4 đồng bộ · TR1 · TR4 · GI5

**Q3** làm kèm bất cứ đợt nào tiện. **Q4** nằm ngoài phase.

- D10-6. ⚠️ **Rủi ro lớn nhất của B, không né được:** không kiểm chứng được gì trước
  khi trả M2. Giảm thiểu duy nhất là kiểm thử L1 ở cuối đợt 1 — nếu chặng 1 không tự
  đứng được thì dừng, đừng đi tiếp sang đợt 2.
- D10-7. Đợt 3 mới là lúc G-1 có hiệu lực (chat chung chỉ tồn tại từ chặng 2). Trước
  đó mọi thứ AI/gợi ý phải sống bằng C1/C6/C7.


### 2026-08-28 (cycle 9) — Impact/Effort, hội tụ lần hai

G-1 chốt (học từ chat chỉ từ chặng 2) và G-2 chốt (bản ii-b) nên tập ứng viên đã
sạch. Thang Impact 1-5, Effort 1-5 (5 = đắt nhất). Effort là ước lượng **nghiệp vụ**
dựa trên những gì đã quét trong repo, không phải ước lượng kỹ thuật của tech-lead.

**Nhóm 0 — Điều kiện nền, không phải tính năng (quyết chứ không build)**

| Mã | Nội dung | I | E | Ghi chú |
|---|---|---|---|---|
| C19 + R-1 + D7-4 + D8-2 | 12 luật thiết kế | 5 | 1 | Chặn cả một lớp sai lầm; là tài sản định vị (RS-C3) |
| BD1 | Xưng hô anh/em | 4 | 3 | ⚠️ **Chi phí tăng theo thời gian** — chạm mọi chuỗi text. Quyết ngay, làm dần |
| M2 | Mô hình sở hữu 1 chủ → 2 chủ | 5 | 5 | Việc của tech-lead. **Chặn toàn bộ chặng 1** |

**Q1 — LÀM NGAY (impact cao, effort thấp)**

| Mã | Ứng viên | I | E | Vì sao rẻ |
|---|---|---|---|---|
| XD6 | Nút "em đang giận, chưa nói được, nhưng anh đừng lo" | 5 | 1 | `notifications` + `messages` đã có |
| RS1 | Thoả thuận kỳ vọng liên lạc bằng hai chìa khoá | 5 | 2 | PRIM-1 đã chạy sẵn ở 6 module |
| SC7/DS2 | Quà bất ngờ phá vỡ hai chìa khoá | 4 | 1 | 🔧 `wishlistThemeId` đã có trong entity |
| GI3 | "Đang nghĩ tới em" một chạm | 4 | 1 | `notifications` đã có |
| KY2 | Sau buổi hẹn hỏi đúng một câu, lật bài | 4 | 2 | PRIM-2 đã có |
| BD2 | Lịch âm + dịp lễ Việt | 4 | 2 | Bảng dữ liệu + `alarms` đã có |
| DS1 | Backend cho `vow` | 3 | 2 | 🔧 Mobile đã xong, chỉ thiếu nửa server |
| XD7 | Hẹn giờ nguội | 3 | 2 | PRIM-1 + `alarms` |
| SC3 | Huỷ hẹn cũng cần hai chìa khoá | 3 | 1 | Dùng lại PRIM-1 |
| GI7 | Nghi thức khép ngày | 3 | 1 | |

**Q2 — ĐẦU TƯ CÓ KẾ HOẠCH (impact cao, effort cao)**

| Mã | Ứng viên | I | E | Ghi chú |
|---|---|---|---|---|
| C1 | Danh sách hoạt động — đối tượng xương sống | 5 | 3 | Gộp `dream_jar` (DS4) để đỡ một module |
| KY1 | `timeline` tự viết từ C1 + TR2 | 5 | 3 | 🔧 `timeline` đã có, logic sinh là phần mới |
| C0 | Chế độ một người + lời mời G-b | 5 | 4 | **Phụ thuộc M2** |
| C3 | Chuyến đi đầu tiên | 5 | 4 | Dữ liệu địa điểm + tiền + kế hoạch |
| TR1 | App tự câm khi hai máy ở gần | 4 | 4 | Phát hiện gần nhau, đặc thù nền tảng |
| RS4 | Đồng bộ thành tính năng hạng nhất | 4 | 4 | Hạ tầng, nhưng 16% khiếu nại ngành nằm đây |
| SC2 | Cả hai chọn mù, trùng thì tự chốt | 4 | 3 | Hợp nhất PRIM-1 + PRIM-2 |
| GI5 | Phiên làm việc chung | 4 | 3 | Cần hiện diện thời gian thực |
| TR4 | Chế độ để-điện-thoại-xuống | 4 | 3 | Cầu nối sang IDEA-001 |

**Q3 — RẺ, LÀM KÈM (impact trung, effort thấp)**

GI1 đếm ngược gắn kế hoạch (3/1) · SC5 nửa chìa khoá (2/1) · BD7 đếm kỷ niệm theo
tháng (2/1) · GI8 bản tin cuối tuần (3/2) · GI9 hàng chờ để-gặp-rồi-kể (3/2) ·
TR2 một chạm giữ chỗ (3/2) · KY6 ký ức được phép mâu thuẫn (3/2) · GI4 trạng thái
nhẹ (3/2) · KY5 kho chuyện (3/2)

**Q4 — HOÃN hoặc BỎ**

| Mã | Lý do |
|---|---|
| C12 chặng 3 | User đã hoãn (A-11) |
| C10 thương mại, KY4 sách in | I4 nhưng E5, cần đối tác — và chưa có người dùng thì chưa bán được gì |
| C8 | Giữ (A-9) nhưng chỉ chạy được sau RS2, và RS2 cần C1/C16 có dữ liệu trước |
| BE7 đôi bạn cùng chơi | I4 nhưng chỉ có nghĩa khi đã có nhiều cặp dùng — hoãn theo **thời điểm**, không theo giá trị |
| TR3 chụp chung hai máy | 2/4 |
| KY3 ký ức theo địa điểm | 3/3, để sau KY1 |
| BE5 | User chưa quyết (Q-g) |

### 2026-08-28 — ⚠️ Phát hiện quan trọng nhất của Impact/Effort: một mâu thuẫn về thứ tự

- D9-1. ⚠️⚠️ **Cả 10 mục Q1 đều chạy được ở CHẶNG 2 mà không cần M2.** Chúng dùng
  lại nguyên thuỷ và module đã có: `notifications`, `messages`, `alarms`,
  `timeline`, `wishlistThemeId`, mutual consent ở 6 module.
- D9-2. ⚠️⚠️ **Nhưng chặng 1 — thứ user đã chốt làm trước (A-3, Q-f) — bị chặn
  hoàn toàn bởi M2, là mục ĐẮT NHẤT trong toàn bộ idea.** Nghĩa là đi theo thứ tự
  đã chốt thì phải trả hạng mục kiến trúc lớn nhất **trước khi có bất cứ thứ gì ra
  mắt được**.
- D9-3. Đây là mâu thuẫn mà bảng xếp hạng không tự giải được, vì nó không phải câu
  hỏi về giá trị mà là câu hỏi về **thứ tự và rủi ro**. Hai lối:
  - **Lối A — chặng 2 trước.** Ship Q1 lên app cặp đôi hiện có, có phản hồi thật,
    rồi mới làm M2. Rẻ, nhanh, nhưng **không giải X1** (rào cản gia nhập), tức là
    không giải đúng bài toán đã khiến ta rẽ sang chặng 1.
  - **Lối B — chặng 1 trước.** Đúng chiến lược đã chốt, giải X1, nhưng trả giá M2
    ngay và chưa có gì kiểm chứng trước khi trả.
  - **Lối C — tách quyết định khỏi thi công.** ⭐ **Quyết mô hình sở hữu ngay** (rẻ,
    là quyết định thiết kế) để không xây thêm gì khoá cứng vào `coupleId`, nhưng
    **ship Q1 ở chặng 2 trước** để có phản hồi. M2 làm sau, và làm dễ hơn vì mọi
    thứ mới đã tuân theo mô hình đúng ngay từ đầu.
- D9-4. ⚠️ Rủi ro của Lối A nếu KHÔNG kèm quyết định của Lối C: mỗi tính năng Q1
  xây theo `coupleId` là thêm một chỗ phải sửa lúc làm M2. **Càng ship nhiều theo
  lối cũ thì M2 càng đắt.** Đây là lãi kép ngược.
- D9-5. BD1 (xưng hô) có cùng tính chất: **chi phí tăng theo thời gian**, nên phải
  quyết sớm dù làm dần. Hai mục D9-3 và BD1 là hai chỗ duy nhất trong danh mục mà
  trì hoãn *quyết định* đắt hơn trì hoãn *thi công*.

### 2026-08-28 — Nhận định khác từ Impact/Effort

- D9-6. **Q1 dày bất thường** vì repo đã có sẵn nhiều nguyên thuỷ chưa khai thác.
  Mutual consent nằm ở 6 module mà chưa từng được đặt tên; `wishlistThemeId`,
  `vow`, `timeline` đều là đồ dựng dở. Chi phí thấp ở đây là thật, không phải lạc quan.
- D9-7. **XD6 giữ vị trí số một sau khi chấm điểm** — 5/1 là tỉ lệ tốt nhất toàn bảng.
- D9-8. **RS4 (đồng bộ) là mục dễ bị bỏ qua nhất** vì impact của nó vô hình. Nhưng
  16% khiếu nại toàn ngành nằm đúng đó, và nó đánh vào nguyên thuỷ lõi. Không nên
  để nó rơi khỏi Q2.
- D9-9. **C10 (doanh thu) rơi xuống Q4 không phải vì kém, mà vì sai thời điểm.**
  Chưa có người dùng thì chưa bán được gì.
`):
  - Xương sống hoạt động: **C1 danh sách hoạt động xuyên chặng** · C2 máy quyết
    định · **C3 chuyến đi đầu tiên** · C4 cùng xem gì.
  - Nền tảng: C5 hai chìa khoá + lật bài · C6 nhật ký riêng (chạy cả ba chặng).
  - Chiều sâu: C7 cột mốc · C8 tìm hiểu nhau · **C9 bản địa VN (BD1-BD7)**.
  - Vận hành: C10 thương mại trên hoạt động · C11 đồ dựng dở trong repo.
  - Hoãn/loại: C12 hoãn sang chặng 3 · C13 loại theo R-1.
  - **Mới ở c5, theo trục thời gian:** **C14 ô GIỮA (90% thời gian)** · C15 ô
    TRONG, app tự câm · C16 ô SAU, ký ức tự viết · **C17 xung đột và sửa chữa** ·
    C18 người thứ ba · **C19 hiến chương không làm**.
- Ba lớp danh mục đã tách rõ: **lớp đối tượng** (C1, C16) · **lớp nhịp** (C14,
  C15, C7) · **lớp ràng buộc** (C19, C5). Trước cycle 5 chỉ có lớp đối tượng.
- Differentiators: đi cùng cả ba chặng trên một đối tượng duy nhất (không app nào
  làm) · lời mời là món quà cụ thể (G-b) · C3 chuyến đi đầu tiên · P0/P6 · **C19
  hiến chương không làm, ở thị trường đang chán app theo dõi nhau** · **TR1/TR4
  app tự câm và thưởng cho việc không dùng app** · **BD1 xưng hô và BD5 sống với
  bố mẹ, hai rào cản bản địa đối thủ ngoại không vượt được**.
- Risks and constraints:
  - ✅ **ĐÃ GIẢI ở c4 — lưỡi dao đạo đức.** R-1 giải bằng quy tắc về đối tượng,
    không bằng lời hứa về ý định. N1-N7 loại theo định nghĩa.
  - ✅ **ĐÃ GIẢI PHẦN LỚN ở c4 — M1.** "App lên kế hoạch đi chơi + nhật ký riêng"
    bị phát hiện trên máy bạn trai là chuyện bình thường (R-3). Còn lại là câu hỏi
    sản phẩm, không còn là rủi ro thương hiệu.
  - **M2:** codebase khoá `coupleId` khắp nơi. Nhẹ đi nhờ G-e (một đối tượng, 1-2
    chủ sở hữu) nhưng vẫn là bổ sung kiến trúc thật.
  - **L1:** chặng 1 phải là sản phẩm hoàn chỉnh tự nó, không chỉ là phễu. C1+C6
    đứng độc lập được — đây là bằng chứng L1 khả thi.
  - **L2/T7 bị từ chối:** phải giúp khép lại tử tế, không giữ người dùng bằng nỗi đau.
  - **Y8:** người đang tán tỉnh giữ bí mật → kênh "kể cho bạn bè" yếu hơn kỳ vọng.
  - **R8 kiểm soát cưỡng chế** và **R6 kho lưu bằng chứng**: vẫn phải xử lý ở mọi
    cụm chạm dữ liệu, kể cả sau R-1.
  - **AC7:** chia tiền chuyến đi ở chặng 1-2 rất tế nhị, dễ làm hỏng không khí.
- Assumptions (chưa kiểm chứng):
  - Người đang tán tỉnh chịu dùng một app để lên kế hoạch hoạt động (hiện họ dùng
    app Ghi chú + chat).
  - C1 thắng được app Ghi chú, tin nhắn tự gửi, và ChatGPT (Z9).
  - Danh sách chặng 1 đủ dày để tạo ra khoảnh khắc G-b khi mời.
  - Z8: lo lắng dễ kiếm tiền hơn hài lòng, nên chặng 1 chi trả tốt.
  - $1-$3: đặt chỗ/vé/quà là đường doanh thu chấp nhận được về mặt cảm nhận.
- Open questions (không còn câu nào chặn):
  - Thứ tự đợt làm — cần Impact/Effort trên C1-C4.
  - Khi ghép đôi, ghi chú chặng 1 đi về đâu? (đề xuất: cột mốc và danh sách hoạt
    động tốt nghiệp lên dòng thời gian chung, cảm xúc ở lại riêng tư).
  - Có giữ ràng buộc "một người tại một thời điểm" như một lựa chọn định vị không?
  - C2 và C3 có dùng AI không, và giới hạn ở đâu.
  - Chặng 1 và chặng 2 là một app đổi chế độ hay hai app có bàn giao.
- **Bắt buộc sửa sau nghiên cứu c6 (3 điều):**
  1. ⚠️ **Hạ ưu tiên C8 và GI6.** Kho câu hỏi soạn sẵn là mô hình chết phổ biến
     thứ hai của thể loại (nội dung cạn trong 2-4 tuần, 22% khiếu nại). Chỉ giữ
     nếu đổi sang **RS2 — nội dung sinh từ dữ liệu của chính cặp đôi**.
  2. ⚠️ **Đổi khung C1/C3, không đổi nội dung.** Bài học Cupla: hứa gắn kết mà
     giao lịch thì bị chê. Dùng RS3 — đóng khung hậu cần là hành động lo liệu
     cho nhau, đừng bán bằng ngôn ngữ cảm xúc thuần tuý.
  3. ⚠️ **Thay GI10 bằng RS1.** Không hiển thị con số nhịp nhắn tin; thay bằng
     **thoả thuận kỳ vọng liên lạc qua hai chìa khoá**. Nghiên cứu nói tương đồng
     kỳ vọng mới là thứ tương quan với hài lòng, không phải tần suất.
- **Rủi ro mới từ nghiên cứu:** RS-B3 lỗi đồng bộ hai máy là 16% khiếu nại toàn
  ngành, và nó đánh thẳng vào nguyên thuỷ lõi C5/P6 → RS4 nâng đồng bộ thành tính
  năng hạng nhất. RS-A2 nghĩa địa app couple (Tuned, Avocado, Pair) cho thấy rào
  cản thể loại cao hơn giả định.
- **Xác nhận từ nghiên cứu:** X1e là nguyên nhân chết có thật (RS-A1) · khoảng
  trống thị trường chặng 1 trùng khít định vị user vì đối thủ đều là CRM hẹn hò
  nhiều người (RS-C2) · phản ứng chống CRM-hoá quan hệ có thật nên C19 là tài sản
  (RS-C3) · lời khuyên chuyên môn cho giai đoạn đầu chính là "nhắn tin chỉ để lo
  hậu cần gặp mặt" (RS-D3) · **phubbing có meta-analysis 52 nghiên cứu / 19.698
  người chống lưng cho TR1/TR4 (RS-E1)** · BD5/BD6/BD3 đều đúng (RS-F1..F3).
- **Điều chỉnh chiến lược:** RS-F4 — ở VN chặng 2 sang chặng 3 ngắn hơn phương
  Tây nhiều (áp lực cưới trước 30, tuổi kết hôn nữ ~22), nên C12 đang bị hoãn quá xa.
- Bổ sung sau cycle 5:
  - **Ứng viên đơn lẻ mạnh nhất: XD6** — nút "em đang giận, chưa nói chuyện được,
    nhưng anh đừng lo". Chi phí gần bằng 0, chưa app nào có.
  - **Rủi ro mới GI10:** làm nhịp nhắn tin không đối xứng nhìn thấy được là mép
    vực bảng-điểm. Chỉ làm sau khi C19 đã chốt thành luật.
  - **Ranh giới mới BE5:** ghi chú về bạn bè người kia — hậu cần thì được, hồ sơ
    tính cách thì vi phạm R-1.
- Recommended next move: Impact/Effort trên 19 cụm (hoặc trên tập rút gọn C1-C6 +
  C14-C17 + C19) để xếp đợt làm, rồi handoff sang `scrum-master` nếu user quyết
  đưa vào backlog.

### 2026-08-29 (cycle 12) — Chặng 1 solo được mở lại và đào sâu

- **Kiểm kê thật:** chặng 1 hiện có 6 tính năng (C1, C6, BD2, KY2, GI7, GI3) + onboarding/
  chọn chế độ + khoảnh khắc mời C0. Năm trong tám ô bắt đầu bằng **hộp rỗng**.
- **D12-1:** chặng 1 pass L1 ở ngày 30, **không** pass ở ngày 1. Cần CS7 (giao kèm nội
  dung VN biên tập sẵn) + CS8 (đẩy đếm ngược dịp Việt lên trước) để có giá trị ngày 1.
- **D12-2 (nặng nhất):** gánh nặng **đổi vai** đúng lúc app đổi chế độ — chặng 1 gánh
  *khởi xướng* (nghiêng nam), chặng 2 gánh *duy trì / mental load / kin-keeping* (nghiêng
  nữ). Lời hứa giá trị phải khác nhau ở hai chặng, nếu không người thứ hai thành người
  vận hành app không công.
- **D12-3 (đẩy lại đề bài, chờ user quyết):** customize nên rẽ theo **VAI** (*đang rủ* /
  *đang được rủ*), **không** rẽ theo **GIỚI**. Giới chỉ dùng cho ngôn ngữ (BD1 anh/em).
- **D12-7 (lỗ to nhất):** không có tính năng nào phục vụ **người thứ hai trong 60 giây
  đầu**. Toàn bộ chặng 1 phục vụ người mời.
- **12 ứng viên mới CS1-CS12**, không cái nào vi phạm L3.
- **Luật mới đề xuất L14:** đẩy ra ngoài, không chỉ hút vào.
- **L4 nới:** từ "giấu AI" thành "không lấy AI làm đầu bài" (R12-5, dữ liệu VN).
- **Câu hỏi mở mới:** OQ-12A (vai tự khai hay suy từ hành vi), OQ-12B (CS2 có làm loãng
  khoảnh khắc G-b không).
- `design-brief.md` và `handoff-to-scrum-master.md` đã tái sinh theo kết quả vòng này.

## Convergence Notes

### 2026-08-28 (cycle 4) — Affinity Clustering trên ~166 ứng viên

Phương pháp: Affinity Clustering (một phương pháp duy nhất, theo đúng workflow).
Bộ lọc áp vào trước khi gom cụm là bốn quyết định đã chốt: phân khúc cặp mới yêu,
chiến lược (a)+(b), rẽ sang chặng 1 một người, và lưỡi dao R-1 (trợ lý làm việc
trên hoạt động, không làm việc trên con người).

**Nhóm XƯƠNG SỐNG — đối tượng "hoạt động" đi xuyên ba chặng**

- **C1. Danh sách hoạt động xuyên chặng.** AC5, G-a→G-d, danh sách chỗ sẽ đi,
  phim sẽ xem, việc sẽ làm cùng nhau. Đây là **đối tượng dữ liệu trung tâm của cả
  sản phẩm**. Rẻ nhất, phổ quát nhất, và là thứ tạo ra khoảnh khắc lời mời G-b.
- **C2. Máy quyết định.** U2, AC1, AC2, AC3 + lật bài P6 áp lên việc chọn hoạt
  động + thẻ thử thách W6. Giải nỗi lo "chọn gì / sợ nhạt".
- **C3. Chuyến đi đầu tiên.** AC4, AC7, kế hoạch + chuẩn bị + chia tiền tế nhị.
  Cụm **khác biệt nhất** so với mọi app couple hiện có.
- **C4. Cùng xem gì.** AC6, watchlist, đồng bộ xem phim yêu xa, W5.

**Nhóm NỀN TẢNG — cơ chế dùng lại ở mọi nơi**

- **C5. Hai chìa khoá + lật bài.** P0, P6. Nguyên thuỷ lõi, đã có sẵn trong 6
  module của codebase. Không phải feature, là hạ tầng tương tác.
- **C6. Nhật ký riêng (Lựa chọn 2).** Cảm xúc, tự nhận thức, T7/L2 khép lại tử tế
  khi không thành. Nửa còn lại của chặng 1.

**Nhóm CHIỀU SÂU — làm sản phẩm dính, không phải làm nó chạy**

- **C7. Cột mốc và lần đầu tiên.** P5, W4 bản đồ, V6, U5, W8 hộp thư thời gian +
  `timeline` đã có sẵn.
- **C8. Tìm hiểu nhau.** W1 (36 câu hỏi), W2, W10, V1/V2/V5.
- **C9. Bản địa hoá VN.** Quán xá, xưng hô V7, lịch âm và dịp lễ Việt, chuyến đi
  cuối tuần từ HN/SG. Cắm thẳng vào C3 và C1.

**Nhóm VẬN HÀNH**

- **C10. Thương mại trên hoạt động.** AC8, $1-$3. Đường doanh thu duy nhất còn
  sạch sau khi cycle 2 giết các hướng khác.
- **C11. Đồ đã dựng dở trong repo.** `vow` chưa có backend, `wishlistThemeId`
  chưa thành luồng, emoji `price` chưa trừ. Chi phí thấp bất thường.

**Nhóm HOÃN / LOẠI**

- **C12. Hoãn sang chặng 3.** U1, U3, U6, U8, U13, U14 — hữu ích thật nhưng sai
  chặng cho cặp mới yêu. Được "cứu sống" bởi mô hình ba chặng, không bị giết.
- **C13. Loại theo lưỡi dao R-1.** N1-N7 — kịch bản thao túng, chấm điểm cơ hội,
  phân tích tin nhắn, theo dõi MXH, A/B test lời nhắn, nhiều mục tiêu. Loại **theo
  định nghĩa**, không cần luật riêng. Kèm R8 (kiểm soát cưỡng chế) và R6 (kho lưu
  bằng chứng) vẫn là hai rào đạo đức phải xử lý ở bất kỳ cụm nào chạm dữ liệu.

**Ba nhận định từ việc gom cụm**

1. C1 không phải một feature ngang hàng — nó là **đối tượng mà C2, C3, C4, C10
   đều cắm vào**. Mất C1 thì bốn cụm kia không có gì để làm việc lên.
2. C5 đã tồn tại sẵn trong codebase ở 6 module nhưng **chưa từng được đặt tên**.
   Đặt tên cho nó là việc rẻ nhất có sức bật lớn nhất.
3. Trục "hữu ích" và trục "unique" hội tụ tại đúng **C3** — chuyến đi đầu tiên vừa
   là nỗi đau thật nhất vừa là chỗ chưa ai làm.

**Chưa chạy:** Impact/Effort để xếp thứ tự đợt làm. Đó là bước hội tụ thứ hai và
là thứ duy nhất còn thiếu trước khi có thể handoff có chủ đích.


- Chưa converge. Cố ý giữ divergent: chưa xếp hạng, chưa chấm điểm, chưa cắt
  scope, chưa đề xuất handoff.
- Cycle 3: đã định chạy Affinity Clustering nhưng user đổi hướng trước khi chạy.
  Hoãn sang cycle 4. Số ứng viên cần gom giờ là ~152.
- Lưu ý: quyết định phân khúc ở cycle 2 **không phải** convergence. Đó là ràng
  buộc do user đặt ra; nó loại nhánh bằng logic phân khúc chứ không bằng chấm điểm.
- Khi user yêu cầu chốt: **Affinity Clustering** trên ~107 ứng viên, rồi
  **Impact/Effort** (phù hợp hơn NUF vì bài toán là thứ tự hành động, không phải
  đánh giá tính mới lạ).

### 2026-08-28 (cycle 5) — Sáu cụm mới, chưa xếp hạng

Cycle 5 là một đợt phân kỳ có chủ đích ra ngoài C1-C4, nên các cụm dưới đây **chưa
qua Impact/Effort**. Chúng được đặt theo trục thời gian và theo hai ô chưa từng chạm.

- **C14. Ô GIỮA — 90% thời gian.** GI1-GI10. Cụm lớn nhất và trống nhất. Trung
  tâm: GI5 phiên chung, GI9 hàng chờ để gặp rồi kể, GI3 một chạm.
- **C15. Ô TRONG — app tự câm.** TR1-TR6. Nghịch lý định vị: app tốt nhất lúc hai
  người ở bên nhau là app tự tắt. TR4 bắc cầu sang IDEA-001.
- **C16. Ô SAU — ký ức tự viết.** KY1-KY7. Giải bài toán `timeline` rỗng bằng cách
  sinh tự động từ C1 + TR2 thay vì giục người dùng nhập. KY6 (ký ức được phép mâu
  thuẫn) là điểm khác biệt rẻ nhất.
- **C17. Xung đột và sửa chữa.** XD6-XD10. Được mở lại sau hai cycle bị hoãn, vì
  đây là chỗ chữ "hữu ích" đậm nhất. XD6 là ứng viên mạnh nhất toàn cycle.
- **C18. Người thứ ba.** BE5-BE8. Ô chưa từng chạm. BE7 là lời giải cho Y8.
- **C19. Hiến chương không làm.** XD1-XD5 + BE4. Không phải tính năng mà là ràng
  buộc thiết kế kiêm tài sản định vị. Nó là điều kiện cần để làm GI10 và BE5 an toàn.

**Cụm cũ được cycle 5 làm dày thêm**

- C5 hai chìa khoá: SC1-SC8. Chưa khai thác hết; SC2 và SC7 là hai nước đi rõ nhất.
- C6 nhật ký riêng: XD9 chứng minh nó chạy suốt cả ba chặng, không chỉ chặng 1.
- C9 bản địa VN: BD1-BD7. Từ một dòng thành một cụm thật, với BD1 và BD5 là hai
  rào cản bản địa mà đối thủ ngoại không vượt được.
- C11 đồ dựng dở: DS1-DS6, trong đó DS4 (`dream_jar` = C1 ở thì tương lai xa) là
  phép gộp đáng giá nhất.

**Quan sát về hình dáng danh mục sau cycle 5**

Ba lớp đã tách rõ, và chúng khác nhau về bản chất chứ không chỉ về độ ưu tiên:

1. **Lớp đối tượng** — C1 hoạt động, C16 ký ức. Cái sản phẩm lưu giữ.
2. **Lớp nhịp** — C14, C15, C7. Cái sản phẩm làm với thời gian.
3. **Lớp ràng buộc** — C19, C5. Cái sản phẩm từ chối làm, và cách nó bắt hai người
   phải cùng đồng ý.

Lớp 2 và lớp 3 gần như hoàn toàn thiếu trước cycle 5.

### Cycle 12 — Chặng 1 solo: kiểm kê, nỗi đau từng người, và phễu chuyển chặng

**A. Chặng 1 hiện có đúng những gì (kiểm kê thật, không tô)**

| # | Mã | Tính năng ở dạng một người | Giá trị ngày 1 (0 dữ liệu) |
|---|----|---------------------------|----------------------------|
| 1 | C1 | Danh sách hoạt động muốn làm cùng người ấy | Hộp rỗng |
| 2 | C6 | Nhật ký riêng / thư chưa gửi | Hộp rỗng |
| 3 | BD2 | Lịch dịp Việt (20/10, 8/3, Tết, Valentine, Noel) | **Có ngay** |
| 4 | KY2 | Câu hỏi mỗi ngày, trả lời một mình | Một câu |
| 5 | GI7 | Cuối ngày hôm nay thế nào | Hộp rỗng |
| 6 | GI3 | Nghĩ về người ấy — ghi lại một khoảnh khắc | Hộp rỗng |
| 7 | — | Onboarding + chọn chế độ (`onboarding/`, `pairing/` đã có trong code) | Không phải giá trị |
| 8 | C0/G-b | Khoảnh khắc mời — đường nối sang chặng 2 | Chưa dùng được ngày 1 |

- **D12-1. Chặng 1 hiện tại không pass L1 ở ngày 1; nó pass L1 ở ngày 30.** Sáu tính
  năng, bốn trong đó là log một chạm, và **năm trong tám ô bắt đầu bằng hộp rỗng**.
  Đường giá trị là thuần tích luỹ ⇒ đây là sản phẩm retention-first **không có móc câu
  ngày 1**. Khoảng trống giữa ngày 1 và ngày 30 chính là chỗ người dùng chết.
  L1 nói "sản phẩm hoàn chỉnh kể cả người kia không bao giờ vào" — nó **chưa** nói
  "hoàn chỉnh **ngay từ đầu**", và đó là kẽ hở tôi đã bỏ sót suốt cycle 9-11.

**B. Nỗi đau từng người — và cái bẫy khi cắt theo giới**

- **D12-2. ⭐ Phát hiện lớn nhất vòng này: gánh nặng đổi vai đúng lúc app đổi chế độ.**
  - Chặng 1 (tán tỉnh) = gánh **khởi xướng**: nghĩ ra làm gì, rủ thế nào, sợ bị từ chối.
    Thống kê nghiêng về nam (R12-1, R12-2).
  - Chặng 2+ (yêu, sống chung) = gánh **duy trì**: mental load, kin-keeping, nhớ, sắp,
    tổ chức. Thống kê nghiêng về nữ (R12-4).
  - ⇒ Cùng một cặp, **gánh nặng chuyển vai đúng ở khoảnh khắc C0**.
  - **Failure mode nghiêm trọng nhất mà thiết kế hiện tại chưa chặn:** nếu ta không
    nhận ra điều này, ta sẽ build chặng 1 phục vụ người khởi xướng, rồi build chặng 2
    **cũng** phục vụ người khởi xướng — và người còn lại trở thành **người vận hành app
    không công**. Đó chính là mankeeping được số hoá, do ta viết ra.
  - ⇒ Lời hứa giá trị phải **khác nhau ở hai chặng**: chặng 1 gỡ gánh *khởi xướng*,
    chặng 2 gỡ gánh *duy trì*.

- **D12-3. ⭐ Đẩy lại đề bài: nên rẽ theo VAI, không rẽ theo GIỚI.** User hỏi customize
  theo Nam/Nữ. Ba lý do tôi đề nghị đổi trục:
  1. **Tiền đề phổ biến nhất đã bị bác.** Pew 2024 (n=6,204): nam **không** ít bạn thân
     hơn, cô đơn **không** khác nhiều theo giới (R12-3). Khác biệt là *hành vi dùng mạng
     lưới*, không phải *cấu trúc mạng lưới*. Thiết kế theo "nam cô đơn hơn" sẽ sai.
  2. **Thiểu số bị sai là rất lớn.** 50-75% phụ nữ đã từng chủ động. Rẽ tính năng theo
     giới nghĩa là đoán sai với một nửa số người dùng nữ, và mã hoá đúng cái định kiến
     mà chính báo VN nói vẫn đặt con gái ở thế yếu (R12-2).
  3. **Không có dữ liệu VN để rẽ đúng.** Không tìm được số liệu ai trả tiền / ai chủ
     động ở VN đương đại. Rẽ theo giới ở đây là đoán, không phải thiết kế.
  - **Đề xuất thay thế:** giới tính chỉ dùng cho **ngôn ngữ** (BD1 anh/em — đã chốt,
    giữ nguyên). **Không bao giờ dùng giới để bật/tắt hay đổi thứ tự tính năng.** Trục
    customize là **vai**: *người đang rủ* vs *người đang được rủ*. Vai tự khai bằng một
    câu không hỏi giới, hoặc suy từ hành vi trong app (ai thêm hoạt động, ai lên kế hoạch).
    Vai **đổi được bất cứ lúc nào**, và nên tự đề nghị đổi ở lúc chuyển chặng (D12-2).
  - **Được gì:** đúng với người dùng thật thay vì đúng với trung bình thống kê; giữ
    nguyên toàn bộ lợi ích customize mà user muốn; không phải bảo vệ một quyết định
    thiết kế theo giới trước công chúng.
  - **Mất gì (ghi trung thực):** vai phải hỏi hoặc phải suy, tức thêm một bước hoặc thêm
    một chỗ đoán sai. Giới thì đã có sẵn từ BD1, miễn phí. Đây là cái giá thật của D12-3.
  - **Quyết định này thuộc về user, không thuộc về tôi.**

- **D12-4. An toàn: đối xứng chính là câu trả lời, đừng làm "chế độ an toàn cho nữ".**
  Một chế độ riêng theo giới sẽ **báo cho kẻ kiểm soát biết ai đang có gì để giấu**.
  L2 (đối xứng) đã đúng; vòng này chỉ xác nhận lại và ghi lý do.

- **L14 (luật mới đề xuất) — Đẩy ra ngoài, không chỉ hút vào.** Từ R12-3(b). Với người
  dùng đơn dùng nhật ký nhiều, sản phẩm phải thỉnh thoảng gợi *kể với một người bạn*,
  chứ không chỉ *ghi thêm vào đây*. App không được trở thành ống xả duy nhất. Đây là
  luật đạo đức cùng họ với R-1: **R-1 cấm app phán xét người kia; L14 cấm app thay thế
  bạn bè.**

**C. Phễu chuyển chặng có ba chỗ rơi — hiện chỉ một chỗ được thiết kế**

- **D12-5. Ba chỗ rơi:**
  1. Người dùng **có đủ thứ để mời** — ✅ đã thiết kế (D10-4, bốn vòi nạp).
  2. Người dùng **dám mời** — ❌ chưa thiết kế.
  3. Người kia **nhận lời trong 60 giây đầu** — ❌ hoàn toàn chưa thiết kế.

- **D12-6. Chỗ rơi 2 — dám mời.** Lời mời **cũng là một hành vi chủ động**, nên nó chịu
  đúng 83%/76% lo lắng của R12-1 và đúng cái giá của R12-2. Hiện ta thiết kế G-b như
  một khoảnh khắc quà tặng đẹp — đúng về cảm xúc, nhưng **bỏ qua việc người gửi phải
  dũng cảm**. Bốn cách hạ giá của hành động mời: CS1 diễn thử, CS2 mời vào hoạt động,
  CS3 mời từng phần, CS4 rút lui im lặng.

- **D12-7. ⭐ Chỗ rơi 3 — lỗ to nhất, và nó vô hình.** Hiện **không có một tính năng nào
  phục vụ người được mời**. Toàn bộ chặng 1 phục vụ người mời; toàn bộ chặng 2 giả định
  cả hai đã ở trong. Người thứ hai chỉ tồn tại như một sự kiện `accept`. Lỗ này vô hình
  vì nó không nằm trong chặng 1 cũng không nằm trong chặng 2 — nó nằm ở đường nối, và
  **không ai sở hữu đường nối**. Ghi rõ: đây là suy luận từ phễu của ta, không có bằng
  chứng ngoài (tìm không ra).

**D. Ứng viên mới CS1-CS11**

| Mã | Tên | Chữa chỗ nào | Impact/Effort |
|----|-----|--------------|---------------|
| CS1 | **Diễn thử lời mời** — xem đúng màn hình người kia sẽ thấy, trước khi gửi | Chỗ rơi 2 | 4/1 |
| CS2 | **Mời vào một HOẠT ĐỘNG, không mời vào một MỐI QUAN HỆ** — mặc định là "đây là danh sách quán anh lưu, em chọn một chỗ đi", không phải "vào app đôi với anh" | Chỗ rơi 2 | 5/1 |
| CS3 | **Mời từng phần** — mời xem một danh sách, không mời xem cả app; người mời chọn cái gì lộ | Chỗ rơi 2 + R8 | 4/2 |
| CS4 | **Rút lui im lặng** — không trả lời thì lời mời hết hạn lặng lẽ; không báo "đã xem", không đếm ngược cho người gửi | Chỗ rơi 2 | 4/1 |
| CS5 | **Màn hình người thứ hai** là một artifact thiết kế có tên riêng, không phải "màn đăng nhập"; không cài app vẫn xem được (S4/S7) ⇒ phải là web | Chỗ rơi 3 | 5/3 |
| CS6 | **Hành động trước, tài khoản sau** — người thứ hai chọn được một quán trong danh sách *trước khi* tạo tài khoản | Chỗ rơi 3 | 5/3 |
| CS7 | **Giao hàng kèm nội dung, không giao hộp rỗng** — danh sách hoạt động đến với nội dung VN biên tập sẵn (bám xu hướng vận động 2026, R12-5); người dùng **cắt bớt** thay vì **nghĩ ra** | D12-1 | 5/2 |
| CS8 | **Đưa đếm ngược dịp Việt lên trước** — BD2 là tính năng duy nhất có giá trị ở giây thứ 5 với 0 dữ liệu | D12-1 | 4/1 |
| CS9 | **Đẩy ra ngoài** — gợi "kể với một người bạn", không chỉ "ghi thêm vào đây" | L14 / R12-3b | 3/1 |
| CS10 | **Chuỗi tiến triển theo vai** (nối RS5) — vai *người rủ*: cà phê → ăn tối → hoạt động chung → gặp bạn bè. Vai *người được rủ*: chuỗi là **chọn và đáp lại**, không phải **khởi xướng** | D12-3 | 4/3 |
| CS11 | **Bàn giao gánh nặng ở lúc chuyển chặng** — tại C0, app **chia lại việc** một cách rõ ràng và mặc định; danh sách chung + hai chìa khoá làm việc lên kế hoạch **nhìn thấy được và chia được**. Đây là can thiệp mental-load, và là **lời hứa giá trị của chặng 2 dành cho người mang gánh duy trì** | D12-2 | 5/3 |

- **CS12. Thời điểm nên mời** — app biết khi nào đủ chín, từ **dữ liệu của chính người
  dùng** (đã lưu 12 chỗ, đã ghi 3 lần gặp). Không đọc người kia ⇒ nằm trong R-1. 4/2.
- Cả 12 ứng viên đều **không vi phạm L3** (không khoá tính năng để ép mời). Chúng làm
  việc mời *dễ hơn* và *đáng hơn*, không làm việc không-mời *đau hơn*.

**E. Câu hỏi mở mới**

- **OQ-12A.** Vai (*đang rủ* / *đang được rủ*) nên **tự khai một câu** hay **suy từ hành
  vi**? Tự khai thì chính xác và tôn trọng, nhưng thêm một bước onboarding. Suy từ hành
  vi thì mượt, nhưng đoán sai sẽ rất khó chịu và khó sửa.
- **OQ-12B.** CS2 (mời vào hoạt động) có làm **loãng** khoảnh khắc G-b không? G-b được
  thiết kế để là một khoảnh khắc cảm xúc lớn; CS2 cố tình hạ nó xuống thành một lời rủ
  nhẹ. Hai cái này **kéo ngược nhau** và tôi chưa giải được. Có thể lời mời nhẹ đi nhưng
  *cái được mời vào* vẫn nặng — cần user quyết.

## Research Notes

### 2026-08-28 (cycle 6) — Nghiên cứu web: nỗi đau thật của cặp đôi và của người dùng một mình

Công cụ: `WebSearch` (6 truy vấn) + `WebFetch` (1 bài phân tích đánh giá). Đây là
lần đầu idea này có bằng chứng bên ngoài; các cycle 1-5 đều là suy luận trên mã
nguồn và hiểu biết chung.

#### A. Xác nhận mạnh — hướng rẽ chặng 1 là đúng

- RS-A1. **Phụ thuộc hai chiều là nguyên nhân chết được ghi nhận, không phải giả
  thuyết của tôi.** "The apps need both partners to participate, and if one person
  stops opening the app, the shared experience falls apart." X1e từ chỗ là suy
  luận trở thành sự thật ngành.
- RS-A2. **Nghĩa địa app couple là thật.** Tuned (Meta) đóng sau hơn 2 năm;
  Avocado đóng 2017 vì hết vốn; Pair/Couple xuống cấp từ 2016. Nguyên nhân được
  nêu: thiếu vốn, không cạnh tranh nổi với ứng dụng nhắn tin lớn, freemium sai.
  Between là kẻ sống sót hiếm hoi. → Rào cản của thể loại này cao hơn tôi giả định.
- RS-A3. **Phàn nàn xuyên ngành, có tỉ lệ:** paywall chặn hết tính năng có nghĩa
  28% · nội dung lặp/cạn 22% · dùng thử tự chuyển gói năm 19% · **lỗi đồng bộ giữa
  hai máy 16%** · nội dung chung chung không hợp (nêu đích danh cặp yêu xa) 10%.

#### B. ⚠️ Hai chỗ nghiên cứu BÁC LẠI phân tích của tôi

- RS-B1. ⚠️⚠️ **C8 và GI6 nguy hiểm hơn tôi nghĩ, không phải "chiều sâu".** Tôi
  xếp bộ câu hỏi (36 câu Aron, bộ bài, câu hỏi mỗi tối) vào nhóm chiều sâu. Dữ
  liệu nói ngược: **nội dung cạn trong 2-4 tuần là mô hình chết phổ biến thứ hai**
  của cả thể loại. Evergreen: "questions started repeating within weeks"; Love
  Nudge cạn ngay khi người dùng hiểu xong khung 5 ngôn ngữ tình yêu; Paired lặp
  nội dung sau vài tuần. **Kho câu hỏi soạn sẵn là một cái bẫy có kỳ hạn**, và
  càng gắn streak vào thì càng lộ nhanh (Evergreen mâu thuẫn đúng chỗ đó).
  → Phải hạ ưu tiên C8/GI6, hoặc đổi cơ chế sang RS-C2 bên dưới.
- RS-B2. ⚠️⚠️ **Bài học Cupla đánh thẳng vào C1 và C3.** Cupla bị chê vì "positioned
  as connection app but functions primarily as logistics tool" — người dùng được
  hứa gắn kết, nhận về một cái lịch. **C1 danh sách hoạt động và C3 chuyến đi đầu
  tiên CHÍNH LÀ hậu cần.** Nếu đóng gói bằng ngôn ngữ cảm xúc thì sẽ lặp lại đúng
  thất bại đó. Đây là rủi ro định vị mà tôi hoàn toàn bỏ sót ở cycle 4-5.
- RS-B3. ⚠️ **Lỗi đồng bộ 16% là rủi ro lên chính nguyên thuỷ lõi.** Hai chìa khoá
  (C5) và lật bài (P6) đều đòi hai máy đồng bộ đúng. "A partner's answer never
  appearing, one phone updating while the other does not, pairing that fails,
  notifications that do not fire, so the shared experience quietly stops working."
  Nguyên thuỷ mà tôi coi là lợi thế cũng là nơi cả ngành hay hỏng nhất.

#### C. Chặng 1 — thị trường đã tồn tại, và khoảng trống nằm đúng chỗ user chọn

- RS-C1. **Đối thủ chặng 1 có thật và khá đông:** DateTrack, Dateforce, DateWise,
  Date Journal, 404Log (Crush Diary), MatchMGT. L1/M1 phải đối chiếu với các app
  này, không còn là thị trường trắng.
- RS-C2. ⭐ **Nhưng gần như tất cả đều là CRM hẹn hò nhiều người** — theo dõi
  nhiều buổi hẹn, red flag, chi tiêu, "phân tích quy luật hẹn hò". 404Log còn
  "track when your crush looked at you or replied faster, analyze love frequency".
  **Đó chính xác là N3/N7 mà lưỡi dao R-1 đã cấm.** → **Khoảng trống thị trường
  trùng khít với định vị user đã chọn: một người tại một thời điểm, trợ giúp hoạt
  động thay vì phân tích con người.** Định vị của user không phải là thu hẹp thị
  trường — nó là ô trống duy nhất còn lại.
- RS-C3. ⭐ **Phản ứng chống CRM-hoá quan hệ được ghi nhận rõ ràng:** ý tưởng áp
  CRM lên quan hệ cá nhân "strikes many people as cold, clinical, even
  dehumanizing", và "apps tracking deficits rather than positives create a
  transactional frame that is toxic to intimacy". → **C19 hiến chương không làm
  là tài sản định vị có bằng chứng thị trường**, không phải tôi tự nghĩ ra.

#### D. Nỗi đau thật của giai đoạn "talking stage"

- RS-D1. **94% millennials có lo âu liên quan tới nhắn tin** (nghiên cứu Harvard
  được dẫn lại). **69% Gen Z coi sức khoẻ tinh thần là rào cản hẹn hò lớn nhất**;
  **84% muốn gần gũi sâu hơn nhưng ngại mở lòng sớm**; **56% thấy hẹn hò khó hơn
  thế hệ trước.** Thị trường lo âu này lớn và có số liệu.
- RS-D2. ⭐⭐ **JTBD chặng 1 tôi viết ở cycle 4 là SAI TRỌNG TÂM.** Tôi viết "giúp
  tôi nghĩ ra việc hay ho để làm cùng". Nỗi đau số một được ghi nhận là **mắc kẹt
  trong talking stage (kéo dài 2 tuần đến 2 tháng), không biết cách đẩy quan hệ
  tiến lên**, "stuck, unsure how to move a connection forward". Đây là một JTBD
  khác hẳn và mạnh hơn.
- RS-D3. ⭐⭐ **Lời khuyên chuyên môn trùng khớp kinh ngạc với định vị của user:**
  chuyên gia khuyên giai đoạn đầu nên **giảm nhắn tin, chỉ dùng nhắn tin cho hậu
  cần của việc gặp mặt, và gặp ngoài đời sớm**. Đây gần như là mô tả nguyên văn
  "trợ lý hậu cần cho việc gặp nhau". **Bằng chứng bên ngoài mạnh nhất cho Lựa
  chọn 1 theo nghĩa user đã đính chính.**
- RS-D4. **Hypercommunication có hại:** lệ thuộc vào nhắn tin như thước đo sức
  khoẻ quan hệ thay vì gặp mặt thật. → Cảnh báo cho C14: **ô GIỮA không được biến
  thành thêm một kênh chat.** GI3/GI4/GI7 (một chạm, trạng thái nhẹ, khép ngày)
  đúng hướng; bất cứ thứ gì làm tăng lượng chữ đều sai hướng.

#### E. Bằng chứng khoa học cho TR1/TR4 và cho GI10

- RS-E1. ⭐ **Meta-analysis 2025: 52 nghiên cứu, 19.698 người — phubbing (lơ người
  thật để nhìn điện thoại) làm giảm hài lòng, thân mật, gần gũi cảm xúc và trực
  tiếp gây xung đột lẫn ghen tuông.** → **TR1 (app tự câm khi hai người ở gần) và
  TR4 (để điện thoại xuống) có nghiên cứu quy mô lớn chống lưng.** Đây là
  differentiator duy nhất trong toàn bộ danh mục có bằng chứng cỡ này.
- RS-E2. ⭐ **GI10 phải đổi hình.** Nghiên cứu nói: **sự TƯƠNG ĐỒNG giữa hai người
  về tần suất nhắn tin và về việc ai chủ động** mới tương quan với hài lòng; xung
  đột sinh ra khi **hành vi lệch khỏi kỳ vọng**. Có hẳn nghiên cứu về việc cặp đôi
  thương lượng luật nhắn tin ("Rules for Mediated Romance"). → Cách đúng **không
  phải hiển thị con số nhịp** (mép vực bảng-điểm), mà là **giúp hai người thoả
  thuận kỳ vọng với nhau**. Đây là một tính năng khác hẳn, an toàn hơn, và có căn cứ.

#### F. Bản địa VN — xác nhận và một điều chỉnh chiến lược

- RS-F1. **BD5 được xác nhận.** Phần lớn phụ nữ trẻ VN sống với gia đình, có giờ
  giới nghiêm, không ngủ lại; văn hoá "ở với bố mẹ tới khi cưới" làm hook-up
  culture yếu hẳn. → Ô GIỮA (C14) đúng là quan trọng hơn ở VN.
- RS-F2. **BD6 được xác nhận.** Hẹn hò đô thị VN mặc định là **quán cà phê và rạp
  phim**. → C4 (cùng xem gì) và cụm quán xá không phải phỏng đoán.
- RS-F3. **BD3/BE6 nặng hơn tôi viết.** Đưa về ra mắt gia đình ở VN nghĩa là "họ
  thấy một tương lai với bạn, chấm hết". Đây là cột mốc gần như tương đương cầu hôn.
- RS-F4. ⚠️ **Điều chỉnh chiến lược: chặng 3 đến sớm hơn nhiều ở VN.** Áp lực cưới
  trước 30, tuổi kết hôn trung bình của nữ khoảng 22. → **C12 (hoãn sang chặng 3)
  bị hoãn quá xa.** Ở VN, khoảng cách chặng 2 → chặng 3 ngắn hơn phương Tây đáng
  kể, nên U1/U3/U6 có thể cần sớm hơn kế hoạch.

#### G. Ứng viên mới sinh ra từ nghiên cứu

- RS1. ⭐ **Thoả thuận nhịp liên lạc bằng hai chìa khoá** (từ RS-E2). Hai người
  cùng chốt "kỳ vọng nhắn tin của mình là thế này" và chỉ hiện khi cả hai xong
  (P6). Giải mâu thuẫn số một của cặp mới yêu **mà không chấm điểm ai cả**. Thay
  thế GI10 hoàn toàn.
- RS2. ⭐ **Nội dung sinh từ dữ liệu của chính cặp đôi, không phải kho soạn sẵn**
  (chống RS-B1). Câu hỏi tối nay đến từ chuyến đi tuần trước, từ danh sách C1,
  từ ký ức C16 — nguồn không bao giờ cạn vì nó lớn theo người dùng.
- RS3. **Đóng khung hậu cần như hành động yêu thương, thay vì hứa cảm xúc rồi giao
  lịch** (chống RS-B2). "Lo liệu cho nhau" chứ không phải "quản lý mối quan hệ".
- RS4. **Đồng bộ là tính năng hạng nhất** (chống RS-B3): trạng thái đồng bộ nhìn
  thấy được, hàng chờ offline, cơ chế bù khi hỏng. Trong một sản phẩm dựng trên
  hai chìa khoá thì đây là tính năng, không phải hạ tầng.
- RS5. ⭐ **"Đẩy quan hệ tiến lên"** (từ RS-D2) — JTBD thật của chặng 1. Ứng viên:
  gợi ý bước tiếp theo hợp lý dựa trên những gì đã cùng làm, không phải dựa trên
  phân tích người kia. Vẫn nằm trong lưỡi dao R-1 vì nó làm việc trên chuỗi hoạt
  động, không trên con người.
- RS6. **Chống phubbing thành định vị công khai** (từ RS-E1), có nghiên cứu dẫn được.
- RS7. **Không đặt paywall lên lõi** (từ RS-A3, 28%+19%). Doanh thu ở C10 (hoạt
  động, đặt chỗ, sách in) chứ không phải gói thuê bao chặn tính năng.
- RS8. **Lối lên chặng 3 phải mở sẵn từ sớm cho thị trường VN** (từ RS-F4).


- Chưa dùng web research. Toàn bộ grounding lấy từ mã nguồn trong repo
  (controller summaries của themes, ghost-config, alarms, dream-jar,
  love-contracts, expenses, timeline, vibes; cây feature mobile/backend).
- Nghiên cứu ngoài đáng chạy trước khi converge nếu đi vào: (a) U4 sửa chữa xung
  đột — cần nền tảng bằng chứng trị liệu, không được ứng tác; (b) R8 an toàn và
  kiểm soát cưỡng ép — cần hướng dẫn thiết kế đã được công nhận; (c) Q5 lễ nghi
  và lịch âm Việt Nam — cần dữ liệu đúng.
- Chưa dùng live-site browser probing. Chưa cần.
- Cập nhật sau cycle 2: ưu tiên nghiên cứu thay đổi. (a) U4/V8 xung đột đầu tiên
  — vẫn cần nền tảng trị liệu nếu làm. (b) R8 an toàn — vẫn cần. (c) Bản địa hoá
  VN — **tăng ưu tiên mạnh**, giờ rất cụ thể: xưng hô với gia đình người yêu, quán
  xá hẹn hò theo địa phương, các dịp lần-đầu-tiên của người Việt. (d) **Mới:**
  nghiên cứu Aron "36 câu hỏi" (W1) — cần bản gốc và bằng chứng, vì nó là nội dung
  có thẩm quyền và là con hào Q9.
- Cập nhật sau cycle 3: thêm hai nhánh nghiên cứu có giá trị cao trước khi
  converge. (e) **Bối cảnh cạnh tranh của chặng 1** — đã có ai làm "trợ lý cho
  người đang tán tỉnh" chưa, họ được đón nhận thế nào, và các sản phẩm bị xếp vào
  loại pickup-artist/CRM hẹn hò đã bị phản ứng ra sao (liên quan trực tiếp tới
  lưỡi dao và M4). (f) **Chuẩn mực riêng tư khi lưu dữ liệu về một người không có
  tài khoản** (liên quan N5). Cả hai đều là dữ kiện bên ngoài kiểm chứng được,
  không phải chuyện suy đoán.

### 2026-08-29 — Nghiên cứu cycle 12 (nỗi đau từng người ở chặng 1)

**Công cụ: `WebSearch` x6. Không lỗi.**

- **R12-1. Lo lắng khi chủ động là gần như phổ quát, không phải chuyện của riêng nam.**
  83% nam và 76% nữ tự mô tả là lo lắng ở mức vừa-tới-rất khi hẹn hò. 44% nam nói nỗi
  sợ **làm giảm khả năng họ chủ động liên lạc**. Luật xã hội mơ hồ làm nó nặng thêm.
  → Mức lo lắng gần như đối xứng; cái **lệch** là chỗ nó rơi vào: nam lo ở khâu *chủ động*,
  nữ lo ở khâu *chủ động thì bị đọc sai*.

- **R12-2. Nữ chủ động phải trả một cái giá có thật.** Nữ chủ động vẫn bị coi là lệch
  chuẩn, và khi nữ chủ động thì **kỳ vọng tình dục của nam tăng lên**. Bối cảnh VN:
  chuẩn truyền thống là "trâu đi tìm cọc"; báo chí VN ghi nhận giới trẻ đã đổi quan
  điểm mạnh ("cọc đi tìm trâu" đang thành xu thế, thanh niên 19 tuổi coi việc con gái
  chủ động là hoàn toàn bình thường), **nhưng cùng lúc vẫn ghi nhận định kiến còn đặt
  con gái ở thế yếu**.
  → Nữ chủ động không thiếu ý chí. Thiếu **vỏ bọc an toàn** cho hành động chủ động.

- **R12-3. Pew 2024 (n=6,204) + nghiên cứu Stanford: phá tiền đề "nam ít bạn hơn".**
  Cô đơn **không** khác nhau nhiều theo giới, và nam **không** báo cáo ít bạn thân hơn.
  Khác biệt là **hành vi**: nam *tìm đến* mạng lưới của mình ít hơn, ít bộc lộ cảm xúc
  ngoài quan hệ tình cảm. Hệ thống hỗ trợ của nam **xoay quanh quan hệ yêu đương**; khi
  chia tay, mạng lưới của nam co lại còn của nữ giữ nguyên. "Mankeeping" = phần lao động
  nữ bỏ ra để duy trì kết nối xã hội của nam.
  → Hai hệ quả **ngược chiều nhau**, phải giữ cả hai:
    - (a) C6 nhật ký riêng là **tính năng chịu lực** với người dùng nam — rất có thể là
      chỗ duy nhất anh ta xử lý cảm xúc về mối quan hệ. Với nữ nó là "hay", không phải "cần".
    - (b) ⚠️ **Rủi ro đạo đức:** nếu app trở thành ống xả *duy nhất*, nó **làm nặng thêm**
      đúng cái vấn đề mà nghiên cứu đang mô tả. Một sản phẩm hút hết việc bộc lộ cảm xúc
      vào trong nó là một sản phẩm đang số hoá vấn đề, không phải giải nó.

- **R12-4. Mental load và kin-keeping nghiêng về nữ, nhưng ở chặng sau.** ASR 2019: nữ
  làm nhiều "cognitive household labor" hơn đáng kể. Nghiên cứu 2025: các bà mẹ báo cáo
  nhiều hơn **67%** khối lượng quản lý gia đình. Sex Roles 2020: nữ là **kin-keeper** —
  nhớ sinh nhật, tổ chức gặp mặt, duy trì quan hệ cho **cả họ hàng bên người kia**.

- **R12-5. VN 2026: hẹn hò offline hồi sinh, hẹn hò theo vận động là xu hướng bùng nổ**
  (pickleball, chạy bộ, gym). 68% Gen Z VN tin AI **có thể gợi ý chủ đề trò chuyện** để
  phá ngượng ban đầu, nhưng coi AI là *trợ lý*, không phải *người lái*.
  → **Tự đính chính vòng 11:** dữ liệu phản ứng ngược với AI ở H-R6 là US/UK/CA và tôi
  đã cảnh báo không suy rộng — giờ có một điểm dữ liệu VN đi **ngược lại**. Nới L4 từ
  "giấu AI" thành "**không lấy AI làm đầu bài**". Không đụng tới R-1 và AI-1.

**Lỗ hổng trung thực của vòng này**

- Không tìm được dữ liệu VN đương đại, định lượng về **ai trả tiền** và **ai chủ động**
  trong hẹn hò. Chỉ có báo chí phổ thông về "cọc đi tìm trâu" — đủ để nói chuẩn mực đang
  đổi, **không** đủ để thiết kế mặc định theo giới. Đây là một lý do nữa ủng hộ D12-3.
- Tìm về "kích hoạt người thứ hai / 60 giây đầu của người được mời" chỉ ra kết quả B2B
  partner-program, không đúng bối cảnh. **Không có bằng chứng ngoài cho D12-6** — nó là
  suy luận từ chính phễu của ta, và được ghi là suy luận.

### 2026-08-29 — Nghiên cứu cycle 13 (kiểm chứng trước khi chặn tính năng)

**Công cụ: `WebSearch` x2. Không lỗi.** Chạy vì tôi sắp chặn một tính năng user muốn —
lập luận chặn phải kiểm chứng được, không được dựa vào trực giác.

- **R13-1. Pháp lý VN.** Luật Bảo vệ dữ liệu cá nhân hiệu lực **01/01/2026**. **NĐ
  356/2025/NĐ-CP** (ban hành 31/12/2025) **thay** NĐ 13/2023, điều chỉnh cách phân loại
  dữ liệu cá nhân và **siết yêu cầu đồng ý**. Thông tin về **tình trạng sức khoẻ** thuộc
  nhóm **dữ liệu cá nhân nhạy cảm**, và với dữ liệu nhạy cảm thì **chủ thể dữ liệu phải
  được thông báo rằng đó là dữ liệu nhạy cảm**.
  - ⚠️ **Ghi trung thực về giới hạn của phát hiện này:** văn bản diễn đạt theo hướng
    tình trạng sức khoẻ **ghi trong hồ sơ bệnh án**. Một ghi chú do người dùng tự gõ về
    chu kỳ của người khác có rơi vào phân loại đó hay không là **câu hỏi tech-lead/pháp
    lý**, tôi không kết luận. **Nhưng cấu trúc đồng ý hỏng bất kể phân loại:** ở chặng 1
    chủ thể dữ liệu **còn không biết app tồn tại**, nên không có đường nào thông báo hay
    xin đồng ý. Đó mới là lập luận chặn, không phải phân loại.
- **R13-2. Văn liệu về app theo dõi chu kỳ.** Nghiên cứu gọi thẳng nhóm rủi ro
  *intimate partner surveillance* và mô tả các app này đã trở thành *"instruments of
  power and control"* / *menstrual surveillance*. Báo cáo Đại học Cambridge gọi dữ liệu
  chu kỳ là **"gold mine"**, nêu rủi ro cyberstalking và an toàn cho phụ nữ. Có nghiên
  cứu ghi nhận các app này nắm **nhiều hiểu biết thân mật về hành vi sinh sản của phụ nữ
  hơn cả bạn đời hoặc bác sĩ**, trái với thói quen lịch sử là chỉ chia sẻ trong quan hệ
  tin cậy rất hẹp.
  - ⇒ Đây là bằng chứng cho **vector R8**, và nó áp thẳng vào phiên bản chặng 1 của
    "đèn đỏ": một người theo dõi chu kỳ của người kia **mà người kia không biết**.
  - ⇒ Nó **không** áp vào GA1, vì GA1 không lưu chu kỳ, không dự đoán, và do chính chủ
    thể bật.

## Session Log

- 2026-08-28: Tạo idea. Cycle 1 ở stance `Ideate For Me`, 5 kỹ thuật, 5 lần đổi
  domain, ~62 ứng viên thô. Phát hiện lớn nhất: app đã sở hữu hai nguyên thuỷ
  tương tác chưa được gọi tên — **đồng thuận hai chìa khoá (P0)** đang chạy rải
  rác ở 6 module, và **trả lời kín rồi cùng lật (P6)** chưa tồn tại nhưng khớp
  hoàn hảo. Hai nguyên thuỷ này tạo ra cả ba trục user hỏi cùng lúc. Ghi nhận
  lệch pha chiến lược H8 (thiết kế cho cặp mới yêu, giá trị nằm ở cặp sống chung),
  ba tài sản bị bỏ phí (love-contracts, anti-ghosting, bản địa hoá VN), và một
  blocker đạo đức R8 (kiểm soát cưỡng ép). Giữ divergent. Bước tiếp theo: user
  chọn chiều sâu nền tảng vs chiều rộng hữu dụng.
- 2026-08-28: Cycle 2 sau khi user chốt phân khúc **cặp đôi mới yêu**. Chạy 4 kỹ
  thuật mới (JTBD Extremes trong phân khúc, Analogy Transfer vòng 2, Constraint
  Ladder, Channel-First) và 5 lần đổi domain, thu thêm ~45 ứng viên (tổng ~107).
  Phát hiện trung tâm: phân khúc này **không có hậu cần chung**, nên "hữu ích"
  phải định nghĩa lại thành *hiểu nhau nhanh hơn / bớt lo / gây ấn tượng* — một
  nửa danh mục hữu dụng cycle 1 chết theo. Nguyên thuỷ lật bài (P6) lên thành cơ
  chế trung tâm. Phát hiện rào cản gia nhập X1 ("quá sớm để cài app cặp đôi") và
  bẫy chiến lược Y1 (thu hút tốt nhất, giữ chân tệ nhất). Đề xuất hoà giải Y2(a):
  hoãn tiện ích vận hành theo mùa thay vì xoá. Vẫn giữ divergent. Bước tiếp theo:
  user chọn lối thoát cho Y1 và hướng giải X1.
- 2026-08-28: Cycle 3. User chốt Y1 = (a) tốt nghiệp + (b) lan truyền, và yêu cầu
  đào sâu X1 với khả năng rẽ sang "trợ lý cho người đang tán tỉnh". Chạy 4 kỹ
  thuật mới (Assumption Smash trên khoảnh khắc mời, JTBD tán tỉnh, Problem
  Reversal phiên bản đáng sợ, Constraint Ladder + Channel-First cho sản phẩm một
  người), 3 lần đổi domain, thêm ~45 ứng viên (tổng ~152). Kết luận chính: X1 là
  khuyết tật cấu trúc (X1e - giá trị bằng 0 cho một người), nên hướng rẽ của user
  là lời giải đúng gốc. Mô hình chuyển từ hai chặng thành BA chặng, app cặp đôi
  hiện tại thành đích đến chứ không còn là sản phẩm. Tìm được mắt xích Y6 (chặng
  một người tích luỹ sẵn món quà -> lời mời không thể từ chối), giải đồng thời X1,
  (a) và (b). Ghi nhận lưỡi dao đạo đức (tử tế hơn vs thắng), ràng buộc cứu sản
  phẩm "một người tại một thời điểm", và rủi ro chiến lược M1 chưa giải. Vẫn chưa
  converge. Bước tiếp theo: user chốt định khung chặng 1.

### 2026-08-28 — cycle 4

- Stance: `Ideate For Me`.
- User chốt định khung chặng 1: **Lựa chọn 1 + 2**, với đính chính rằng "trợ lý"
  chỉ nghĩa là trợ giúp thực dụng (lên kế hoạch du lịch, chọn phim), không phải
  phân tích chiến thuật.
- Kỹ thuật 14: JTBD trên chính hoạt động (domain shift → đời sống hẹn hò thật và
  kinh tế hoạt động). ~14 ứng viên mới (R-1..R-4, G-a..G-e, AC1-AC8, $1-$3).
- **Đã chạy hội tụ lần đầu: Affinity Clustering** trên ~166 ứng viên → 13 cụm.
  Đây là phần hội tụ đã hoãn hai lần ở cycle 2 và cycle 3.
- Ba việc được giải cùng lúc bởi một đính chính của user: lưỡi dao đạo đức (R-1),
  rủi ro thương hiệu M1 (R-3), và khoảnh khắc lan truyền Y6 (G-b).
- Không dùng WebSearch/WebFetch và không dùng browser tool ở cycle này: cycle 4 là
  chốt định khung và gom cụm trên vật liệu đã có, không có câu hỏi nào cần bằng
  chứng bên ngoài để trả lời. Nghiên cứu bên ngoài vẫn còn giá trị trước khi
  handoff — xem `## Research Notes`.
- Trạng thái phát triển chuyển `IN_PROGRESS` → `EXPANDED`.

### 2026-08-28 — cycle 5

- Stance: `Ideate For Me`. User yêu cầu mở rộng ra ngoài bốn cụm xương sống.
- Kỹ thuật 15 một tuần trong đời 168 giờ · 16 SCAMPER trên nguyên thuỷ hai chìa
  khoá · 17 anti-problem "làm sao khiến họ chia tay" · 18 vay mượn miền xa (nghi
  lễ, lưu trữ học, y tế dự phòng, board game hợp tác) · 19 đào sâu bản địa VN.
- ~60 ứng viên mới: GI1-GI10, TR1-TR6, KY1-KY7, SC1-SC8, XD1-XD10, BE1-BE8,
  BD1-BD7, DS1-DS6.
- Phát hiện chính: **trục thời gian**. C1-C4 phủ ~7% quỹ thời gian; ba ô GIỮA /
  TRONG / SAU gần như trống.
- Sáu cụm mới C14-C19, và bốn cụm cũ (C5, C6, C9, C11) dày lên đáng kể.
- Hai cầu nối ngoài phạm vi: TR4 sang IDEA-001 (đảo ngược rủi ro H5), BE7 giải Y8.
- Không dùng WebSearch/WebFetch và không dùng browser tool: cycle này là phân kỳ
  có cấu trúc trên vật liệu và mã nguồn đã quét, không có câu hỏi nào cần bằng
  chứng bên ngoài. Ba mục trong `## Research Notes` giờ đáng chạy hơn trước —
  đặc biệt BD1-BD7 (bản địa VN) và W1 (36 câu hỏi Aron) cho C8/GI6.
- Trạng thái giữ nguyên `EXPANDED`; nhưng C14-C19 chưa qua hội tụ.

### 2026-08-28 — cycle 6

- Stance: `Ideate For Me`. User yêu cầu dùng WebSearch để đào sâu nỗi đau của cặp
  đôi và của người dùng một mình.
- **Công cụ đã dùng: `WebSearch` x6 + `WebFetch` x1.** Đây là lần đầu idea này có
  bằng chứng bên ngoài. Không gặp lỗi công cụ nào.
- ~24 phát hiện/ứng viên mới: RS-A1..A3, RS-B1..B3, RS-C1..C3, RS-D1..D4,
  RS-E1..E2, RS-F1..F4, RS1-RS8.
- **Hai kết luận cũ bị bác:** RS-B1 (C8/GI6 là bẫy cạn nội dung, không phải chiều
  sâu) và RS-B2 (C1/C3 dính rủi ro định vị kiểu Cupla).
- **Ba xác nhận mạnh nhất:** RS-D3 (lời khuyên chuyên môn trùng khớp định vị user),
  RS-E1 (meta-analysis phubbing chống lưng TR1/TR4), RS-C2 (khoảng trống thị trường
  chặng 1 nằm đúng chỗ user chọn).
- **Một sửa JTBD:** nỗi đau chặng 1 là mắc kẹt không biết cách tiến lên, không
  phải thiếu ý tưởng hoạt động.
- Trạng thái giữ `EXPANDED`. Impact/Effort vẫn chưa chạy và giờ phải chạy sau khi
  áp ba điều chỉnh bắt buộc.

### 2026-08-29 — cycle 9

- Stance: `Ideate For Me`. User chốt **G-1 "Đồng ý từ chặng 2"** và **G-2 "Đồng ý"**.
- Hai luật cuối được khoá:
  - **G-1:** "học từ chat" chỉ áp dụng cho **chat chung trong app**, chỉ **từ chặng 2**,
    và bật bằng **hai chìa khoá**. Chặng 1 không có chat nên học từ danh sách hoạt
    động (C1), nhật ký riêng (C6) và cột mốc (C7). Không bao giờ đọc app khác — N3/N4
    vẫn bị cấm bởi R-1.
  - **G-2:** bản (ii-b) như đã phân tích ở cycle 8.
- **Impact/Effort đã chạy** — kỹ thuật bị nợ từ cycle 4 nay đã trả. Xem
  `## Convergence Notes` và `candidate-review.md` Phần I.
- Kết quả: Q1 mười mục (XD6 dẫn đầu 5/1), Q2 chín mục, Q3 chín mục, Q4 bảy mục,
  cộng nhóm "quyết chứ không build" (12 luật, BD1, M2).
- **Phát hiện lớn nhất (D9-1..D9-5):** toàn bộ Q1 chạy được ở chặng 2 mà không cần
  M2, trong khi chặng 1 — thứ đã chốt làm trước — bị chặn hoàn toàn bởi M2, mục đắt
  nhất. Đề xuất lối C: tách quyết định mô hình sở hữu (rẻ, làm ngay) khỏi thi công
  solo mode (đắt, làm sau).
- BD1 và mô hình sở hữu là hai chỗ duy nhất mà **trì hoãn quyết định đắt hơn trì
  hoãn thi công**.
- Không dùng WebSearch/WebFetch ở cycle này: Impact/Effort chấm trên vật liệu và mã
  nguồn đã có, không có câu hỏi nào cần bằng chứng bên ngoài. Vòng đào về AI (Phần H)
  vẫn là việc cần WebSearch, và vẫn chưa chạy.
- Trạng thái giữ `EXPANDED`. Hội tụ xong; sẵn sàng handoff sau khi user chọn thứ tự.
### 2026-08-29 — cycle 10

- Stance: `Ideate For Me`. User chốt **lối B**, làm rõ: B là **thứ tự**, không phải
  phạm vi — một phase làm cả hai chặng, chặng 1 xếp trước, chấp nhận phase dài hơn.
- **Tôi rút sao khỏi lối C (D10-1).** Lý do user đưa ra bác tiền đề của tôi: tôi giả
  định chặng 2 đã có người dùng cho phản hồi; không có.
- Kết quả chính: **cắt lại Q1 theo trục chặng** — 4 mục chạy được ở chặng 1, 6 mục
  chỉ chặng 2. Và phát hiện D10-4: bốn mục chặng-1 đó là **nguồn nạp cho khoảnh khắc
  mời**, không phải đồ thừa.
- Thứ tự trong phase: nền → vòi nạp → khoảnh khắc mời → chặng 2 rẻ → chặng 2 dày.
- Ghi trung thực: giá thật của B là bốn mục dựng hai lần (D10-3); rủi ro không né
  được là không kiểm chứng gì trước khi trả M2 (D10-6).
- Không dùng WebSearch/WebFetch: c10 là sắp thứ tự trên tập đã chấm điểm, không có
  câu hỏi nào cần bằng chứng bên ngoài. Phần H (AI) vẫn chưa chạy và vẫn cần WebSearch.
- **Hội tụ xong, thứ tự xong. Idea sẵn sàng handoff.**

### 2026-08-29 — cycle 11

- Stance: `Ideate For Me`. User chốt **BD1** (xưng hô, vào đợt 0) và yêu cầu chạy
  vòng đào AI ở Phần H.
- **Công cụ đã dùng: `WebSearch` x6. Không gặp lỗi công cụ nào.**
- 7 phát hiện H-R1..H-R7, 9 kết luận D11-1..D11-9.
- **Phát hiện nặng nhất: H-R1 nịnh hót.** Nghiên cứu trên *Science*, 11 hệ AI, xác
  nhận lập luận sai trong 73% kịch bản, và một lần tương tác đủ khiến người ta ít xin
  lỗi hơn trong xung đột quan hệ. R-1 từ lập trường đạo đức trở thành hàng rào an toàn
  có bằng chứng.
- **Luật mới đề xuất AI-1** (D11-3): AI đọc chat chỉ được trích xuất hoạt động, ràng
  bằng schema đầu ra — biến R-1 thành kiến trúc cưỡng chế được.
- Khoảng trống trung thực: không tìm được số sẵn sàng chi trả của sinh viên VN (H-R5);
  dữ liệu phản ứng ngược AI là US/UK/CA không phải VN (H-R6).
- Trạng thái `EXPANDED`. Vòng đào cuối cùng đã xong; không còn việc brainstorm nào.

### 2026-08-29 — cycle 12

- Stance: `Ideate For Me`. User mở lại chặng 1 (một người): **hiện có tính năng gì**,
  **thêm gì để tăng tỉ lệ đi tới chặng 2**, và **customize khi bạn Nam dùng vs bạn Nữ dùng**.
- **Công cụ đã dùng: `WebSearch` x6. Không gặp lỗi công cụ nào.**
- 5 phát hiện R12-1..R12-5, 7 kết luận D12-1..D12-7, 11 ứng viên mới CS1..CS11,
  1 luật đề xuất L14, 2 câu hỏi mở OQ-12A/OQ-12B.
- **Phát hiện nặng nhất — D12-2: gánh nặng đổi vai đúng lúc app đổi chế độ.** Chặng 1
  gánh *khởi xướng* (thống kê nghiêng nam), chặng 2 gánh *duy trì / mental load /
  kin-keeping* (thống kê nghiêng nữ). Nếu không nhận ra, ta build chặng 1 phục vụ nam
  rồi build chặng 2 **cũng** phục vụ nam, và người còn lại thành người vận hành app
  không công — đúng nghĩa mankeeping số hoá.
- **Đẩy lại yêu cầu của user — D12-3: nên rẽ theo VAI, không rẽ theo GIỚI.** Pew 2024
  phá tiền đề phổ biến nhất (nam **không** ít bạn thân hơn, cô đơn **không** khác nhiều
  theo giới); 50-75% phụ nữ đã từng chủ động. Rẽ theo giới sẽ sai với thiểu số rất lớn
  và mã hoá đúng định kiến. Giới chỉ dùng cho **ngôn ngữ** (BD1 anh/em), không dùng để
  bật/tắt tính năng. Đây là đề xuất, user quyết.
- **Tự đính chính — R12-5 đi ngược lean của chính tôi ở c11.** Dữ liệu phản ứng ngược
  AI ở H-R6 là US/UK/CA; điểm dữ liệu VN 2026 cho thấy 68% Gen Z VN tin AI gợi ý được
  chủ đề trò chuyện. L4 nên nới từ "giấu AI" thành "không lấy AI làm đầu bài". R-1 và
  AI-1 **không** đổi (chúng nói về *đối tượng* AI được phép mô tả, không phải về việc lộ AI).
- **Phát hiện tự soi — D12-1: chặng 1 hiện tại không pass L1 ở ngày 1, chỉ pass ở ngày 30.**
  6 tính năng, 4 trong đó là log một chạm, tất cả bắt đầu từ hộp rỗng.
- **Lỗ to nhất — D12-6: không có một tính năng nào phục vụ người thứ hai trong 60 giây đầu.**
  Toàn bộ chặng 1 phục vụ người mời. Lỗ này vô hình vì nó không thuộc chặng 1 cũng không
  thuộc chặng 2 — nó ở đường nối.
- Lỗ hổng trung thực: **không tìm được dữ liệu VN đương đại về ai trả tiền / ai chủ động**
  trong hẹn hò. Chỉ có báo chí phổ thông về "cọc đi tìm trâu". Ghi nhận, không suy diễn.
- `design-brief.md` và `handoff-to-scrum-master.md` đã được **tái sinh** ở cuối vòng này
  (chúng đã cũ đi vì vòng này mở lại chặng 1).


### 2026-08-29 — cycle 13

- Stance: `Ideate For Me`. User **đẩy lại D12-3** bằng hai ví dụ cụ thể: nam quan tâm
  "đèn đỏ", nữ quan tâm "có tâm lý không".
- **Công cụ đã dùng: `WebSearch` x2. Không gặp lỗi công cụ nào.**
- 2 phát hiện R13-1/R13-2, 7 kết luận D13-1..D13-7, 4 ứng viên GA1-GA4, 1 luật mới L17,
  1 luật sửa L15, 2 câu hỏi mở OQ-13A/OQ-13B.
- **Tôi sai ở c12 và đã sửa (D13-1):** có hai trục, không phải một. D12-3 chỉ bác trục
  "ai khởi xướng" rẽ theo giới; tôi đã trình bày như thể nó bác cả trục "chú ý gì ở đối
  phương". Trục sau tồn tại thật và c12 bỏ trống hoàn toàn.
- **Nhưng vẫn phải chặn hai ví dụ (D13-2..D13-4):** cả hai lấy **con người** làm đối
  tượng. "Đèn đỏ" ở chặng 1 còn bất khả thi về **cấu trúc** — chủ thể dữ liệu không có
  tài khoản nên không có đường xin đồng ý (R13-1), và nó là vector R8 có văn liệu chống
  lưng (R13-2). Nó cũng **đã nằm trong danh sách đã loại** ở §9 design-brief từ trước.
- ⭐ **D13-5 — phát hiện thật:** R-1 có **tác dụng phụ theo giới**. JTBD người rủ hình
  dạng *hoạt động* (R-1 phục vụ trọn vẹn); JTBD người được rủ hình dạng *con người*
  (R-1 cấm theo định nghĩa). Không làm gì thì chặng 1 thành sản phẩm cho nam **do hình
  học của lưỡi dao**, không do chủ ý. User cảm đúng, chỉ chẩn sai nguyên nhân.
- ⭐ **D13-6 — ổ khoá:** nguồn thứ ba, **người kia tự khai về chính mình**. Sạch R-1
  hoàn toàn, chưa từng dùng. Mở ra gần hết trục B một cách hợp pháp.
- ⭐ **D13-7 — lời giải:** cấu trúc giá trị hai chiều — **cô ấy hưởng lợi từ tính năng
  ANH ẤY dùng.** Vá D13-5 mà không phá R-1 lần nào.
- **L17 mới:** mọi thông tin về người kia chỉ đến từ chính người đó hoặc từ tay người
  dùng ghi; app không bao giờ là nguồn. Biến R-1 thành quy tắc về **nguồn dữ liệu**,
  kiểm tra được ở tầng kiến trúc — cùng nước đi với AI-1.
- **L15 nới:** giới đổi **chữ và nội dung**, không đổi **cơ chế**. Bản c12 quá chặt, nó
  cấm luôn nội dung 20/10 vốn vô hại (GA3).
