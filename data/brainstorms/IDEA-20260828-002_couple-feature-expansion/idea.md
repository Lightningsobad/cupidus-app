# Idea Master: IDEA-20260828-002 Couple Feature Expansion
Lifecycle: ACTIVE
Development Status: EXPANDED
Source: user
Created: 2026-08-28
Last Updated: 2026-08-29
Linked Requirement: N/A

## Seed

Original idea:

Tạm gác hệ thống hearts. Phát triển tiếp tính năng cho app Cupid để nó **cuốn hút
hơn**, **unique hơn**, và **đặc biệt là hữu ích hơn** cho các cặp đôi.

Hiện trạng feature quan sát được trong repo:

- Backend: `admin`, `alarms`, `auth`, `data-export`, `dream-jar`, `emojis`,
  `expenses`, `gallery`, `ghost-config`, `invitations`, `love-contracts`, `mail`,
  `messages`, `notifications`, `pets`, `themes`, `timeline`, `uploads`, `users`,
  `vibes`, `zodiac`.
- Mobile: thêm `anti_ghosting`, `chat`, `home`, `onboarding`, `pairing`,
  `reminders`, `vow` (vow hiện chỉ có ở mobile, chưa có backend).
- Phân bố hiện tại nghiêng mạnh về **biểu đạt/trang trí** (vibes, themes, emoji,
  pet, gallery, zodiac, timeline) và mỏng về **hữu dụng đời thực** (chỉ có
  `expenses` ở mức ghi chép, `alarms`, `reminders`, `dream-jar`).

## Current Business Framing

- **[CHỐT c2] Phân khúc: cặp đôi mới yêu.** Có chủ đích, không phải lệch chiến lược.
- **[CHỐT c3] Chiến lược Y1 = (a) tốt nghiệp + (b) tối ưu lan truyền, cả hai.**
- **[CHỐT c3] Hướng rẽ: mở rộng ngược lên chặng tán tỉnh, sản phẩm dùng được khi
  còn một mình.** Lý do cấu trúc: rào cản X1 ("còn sớm để cài app couple") có gốc
  là X1e — sản phẩm hiện có giá trị bằng 0 cho một người.
- **[CHỐT c4] Định khung chặng 1 = Lựa chọn 1 + 2.** Nguyên văn user: *"Lựa chọn 1
  không phải theo hướng phân tích chiến thuật, mà chỉ mang tính trợ giúp như 'lên
  kế hoạch du lịch, xem phim...v.v' thôi."* Tức là **trợ giúp thực dụng trên hoạt
  động + nhật ký riêng**.
- **[CHỐT c7] Bảy câu Phần F đã có trả lời:** một app đổi chế độ · một người tại
  một thời điểm · ghi chú chặng 1 giữ vĩnh viễn trong kho kỷ niệm riêng có thể
  khoá · C8 giữ dưới dạng "thi thoảng chèn câu hỏi" + học từ chat chung (chỉ từ
  chặng 2) · gợi ý fix cứng trước, AI sau · chặng 3 hoãn · BE5 để mở.
- **[LUẬT c4 — R-1] Trợ lý làm việc trên HOẠT ĐỘNG, không làm việc trên CON NGƯỜI.**
  Ba hướng, hai được phép: hướng ra ngoài (hoạt động) ✅, hướng vào mình (nhật ký)
  ✅, hướng vào người kia (phân tích, chiến thuật, kịch bản) ❌. Đây là lưỡi dao
  đạo đức ở dạng quy tắc về đối tượng, nên nó tự thực thi thay vì phải hứa.

- Problem: Ba trục user muốn (cuốn hút / unique / hữu ích) không xung đột, nhưng
  với cặp mới yêu thì "hữu ích" **không** nghĩa là tiện ích vận hành gia đình. Nó
  nghĩa là giúp họ **nghĩ ra và chuẩn bị những việc hay ho để làm cùng nhau**.
- Target actor: **ba chặng, một đối tượng.** Chặng 1 người đang tán tỉnh (một
  người) → chặng 2 cặp mới yêu (app hiện tại) → chặng 3 cặp sống chung. Đối tượng
  *"một việc hai đứa sẽ làm cùng nhau"* đi xuyên cả ba chặng, chỉ thay đổi số chủ
  sở hữu: danh sách của tôi → danh sách chung → kế hoạch vận hành chung.
- Value hypothesis: Sản phẩm **đi cùng người dùng qua cả ba chặng của một mối quan
  hệ**, bắt đầu từ lúc còn một mình. Vì bắt đầu từ đó, lúc mời người kia vào thì
  trao được một món quà cụ thể — *"đây là 12 chỗ anh đã ghi lại để đưa em đi"* —
  chứ không phải một lời nhờ vả. Một khoảnh khắc này giải đồng thời rào cản gia
  nhập X1, chiến lược tốt nghiệp (a), và vòng lan truyền (b).
- Why this might matter now: Codebase đã có sẵn nguyên thuỷ **hai chìa khoá
  (mutual consent) trong 6 module** nhưng chưa từng đặt tên cho nó; và có nhiều
  thứ dựng dở (`vow` không backend, `wishlist` chưa thành luồng). Chi phí thấp
  bất thường cho phần nền tảng.
- Kết quả hội tụ (Affinity Clustering, c4, ~166 ứng viên → 13 cụm):
  - Xương sống: **C1 danh sách hoạt động xuyên chặng** (đối tượng trung tâm, mọi
    cụm khác cắm vào) · C2 máy quyết định · **C3 chuyến đi đầu tiên** (khác biệt
    nhất, chưa app nào làm) · C4 cùng xem gì.
  - Nền tảng: C5 hai chìa khoá + lật bài · C6 nhật ký riêng.
  - Chiều sâu: C7 cột mốc · C8 tìm hiểu nhau · C9 bản địa hoá VN.
  - Vận hành: C10 thương mại trên hoạt động (đường doanh thu sạch duy nhất còn
    lại) · C11 đồ dựng dở trong repo.
  - Hoãn/loại: C12 hoãn sang chặng 3 · C13 loại theo R-1.
- **Đã kiểm chứng bằng nghiên cứu bên ngoài (c6, WebSearch x6 + WebFetch x1):**
  - ✅ X1e là nguyên nhân chết có thật của thể loại, không phải suy luận riêng.
  - ✅ Khoảng trống thị trường chặng 1 **trùng khít định vị user**: đối thủ hiện
    có (DateTrack, Dateforce, 404Log, DateWise) đều là CRM hẹn hò nhiều người —
    đúng vùng lưỡi dao R-1 đã cấm.
  - ✅ Phản ứng chống CRM-hoá quan hệ có thật → C19 là tài sản định vị.
  - ✅ Lời khuyên chuyên môn cho giai đoạn đầu là "nhắn tin chỉ để lo hậu cần gặp
    mặt, gặp ngoài đời sớm" — gần như mô tả nguyên văn định vị user đã chọn.
  - ✅ Meta-analysis 2025 (52 nghiên cứu, 19.698 người) về phubbing chống lưng cho
    TR1/TR4 — differentiator duy nhất có bằng chứng cỡ này.
  - ✅ BD5 (sống với bố mẹ), BD6 (quán cà phê/rạp phim), BD3 (ra mắt gia đình rất
    nặng) đều đúng.
- **Nghiên cứu BÁC LẠI hai kết luận cũ và ép ba điều chỉnh:**
  1. Hạ ưu tiên C8/GI6 — kho câu hỏi soạn sẵn cạn trong 2-4 tuần, là mô hình chết
     phổ biến thứ hai của thể loại. Chỉ giữ nếu đổi sang RS2 (nội dung sinh từ dữ
     liệu của chính cặp đôi).
  2. Đổi khung C1/C3 theo bài học Cupla — đừng hứa gắn kết rồi giao một cái lịch.
  3. Thay GI10 bằng RS1 — thoả thuận kỳ vọng liên lạc bằng hai chìa khoá, không
     hiển thị con số nhịp.
- **JTBD chặng 1 được sửa:** nỗi đau số một là **mắc kẹt trong talking stage,
  không biết cách đẩy quan hệ tiến lên**, không phải thiếu ý tưởng hoạt động.
- **Rủi ro mới:** lỗi đồng bộ hai máy là 16% khiếu nại toàn ngành và đánh thẳng
  vào nguyên thuỷ lõi C5/P6 → đồng bộ phải là tính năng hạng nhất (RS4).
- **Điều chỉnh chiến lược VN:** chặng 2 → chặng 3 ngắn hơn phương Tây nhiều (áp
  lực cưới trước 30, tuổi kết hôn nữ ~22) → C12 đang bị hoãn quá xa.
- Rủi ro còn lại: **M2** codebase khoá `coupleId` khắp nơi nên chế độ một người là
  bổ sung kiến trúc thật · **L1** chặng 1 phải là sản phẩm hoàn chỉnh chứ không chỉ
  là phễu · **Y8** người đang tán tỉnh giữ bí mật nên kênh giới thiệu qua bạn bè
  yếu · **R8/R6** kiểm soát cưỡng chế và kho lưu bằng chứng vẫn phải xử lý ·
  **AC7** chia tiền chuyến đi ở chặng đầu rất tế nhị.
- Đã giải ở c4: lưỡi dao đạo đức (R-1) và phần lớn rủi ro thương hiệu M1 (R-3).
- **Ba việc chặn từ c7 — nay còn một:**
  - **G-1 ✅ CHỐT c9:** "học từ chat" chỉ áp dụng cho chat chung TRONG app, chỉ từ
    chặng 2, bật bằng hai chìa khoá. Chặng 1 học từ C1/C6/C7. Không đọc app khác.
  - **G-2 ✅ CHỐT c8:** bản (ii-b) "không giấu cánh cửa, bỏ ổ khoá" — khu riêng công
    khai và đối xứng, nhưng nội dung và cả việc có-hay-không đều bất khả truy cập với
    tài khoản kia. Câu trả lời cho người bạn đời cưỡng ép trở thành *"app không có
    chức năng đó"*: sản phẩm chịu trách nhiệm thay người dùng.
  - **G-3 ⚠️ MỞ:** M2 là hạng mục kiến trúc bắt buộc (1 chủ → 2 chủ). Việc của
    tech-lead sau handoff, không giải được trong brainstorm.
- **[CHỐT c9] Đã chạy Impact/Effort** trên tập đã duyệt — kỹ thuật bị nợ từ c4 nay đã
  trả. Bốn góc phần tư cộng nhóm "quyết chứ không build". Chi tiết ở
  `candidate-review.md` Phần I và `development.md` § Convergence Notes.
- **[CHỐT c10] Thứ tự = lối B: chặng 1 xếp trước, cùng một phase với chặng 2.**
  B là thứ tự chứ không phải phạm vi; phase dài hơn được chấp nhận. Lý do user:
  *"phải có user đã"* — chặng 2 đã tồn tại nhưng chưa có người dùng, nên ship sớm
  vào chặng 2 không đem lại phản hồi thật. Điều này bác tiền đề của đề xuất lối C ở
  c9 và sao đã được rút (D10-1).
- **Thứ tự trong phase:** đợt 0 nền (M2, BD1, 12 luật) → đợt 1 chặng 1 tự đứng được
  (C1, C6, BD2, KY2/GI7/GI3 bản một người) → đợt 2 bản lề (C0 + lời mời G-b) → đợt 3
  chặng 2 phần rẻ (XD6, RS1, SC7+DS2, DS1, XD7, SC3) → đợt 4 chặng 2 phần dày (KY1,
  SC2, C3, RS4, TR1, TR4, GI5). Chi tiết ở `candidate-review.md` Phần J.
- ⭐⭐ **D10-4:** bốn mục chạy được ở chặng 1 là **nguồn nạp cho khoảnh khắc mời**,
  không phải đồ thừa. G-1 đã chốt chặng 1 học từ C1/C6/C7 chứ không từ chat, nên
  KY2/GI7/GI3 là ba cái vòi đổ vào C6; thiếu chúng thì lời mời G-b không có gì trưng.
- **Ghi trung thực về B:** giá thật là bốn mục dựng hai lần (D10-3, giảm nhẹ nhờ G-e
  nếu M2 đúng) · lợi ích bị đánh giá thấp là B tự nuốt nửa rẻ của C nên D9-4 tan
  (D10-2) · rủi ro không né được là không kiểm chứng gì trước khi trả M2, giảm thiểu
  duy nhất là kiểm thử L1 cuối đợt 1 (D10-6).
- **[CHỐT c11] BD1 xưng hô anh/em: chốt, vào đợt 0.**
- **[CHỐT c11] Vòng đào AI (Phần H) đã chạy** — WebSearch x6, không lỗi công cụ.
  - ⭐⭐⭐ **R-1 giờ có bằng chứng thực nghiệm.** Nghiên cứu trên *Science* thử 11 hệ
    AI: tất cả đều nịnh, xác nhận lập luận sai trong 73% kịch bản, và **một lần tương
    tác đủ khiến người ta ít xin lỗi và ít sửa hành vi trong xung đột quan hệ**. Nịnh
    hót là chế độ hỏng mặc định khi AI làm việc trên **con người**; khi AI làm việc
    trên **hoạt động** thì bề mặt gây hại gần như bằng không.
  - ⚠️ **G-1 là chỗ bốn rủi ro chồng lên nhau:** chi phí gấp 100-1000 lần, chuyển dữ
    liệu nhạy cảm xuyên biên giới, rủi ro pháp lý đọc tin nhắn (Luật BVDLCN hiệu lực
    01/01/2026; NĐ 356/2025 xếp đời sống/xu hướng tình dục là dữ liệu nhạy cảm), và
    bề mặt nịnh hót lớn nhất.
  - ⭐ **Luật AI-1 mới:** AI đọc chat chỉ được **trích xuất hoạt động**, không được
    **mô tả con người**; ràng bằng schema đầu ra ở tầng API. Biến R-1 từ ý định thành
    kiến trúc cưỡng chế được.
  - **Đợt 1 không có AI** (D11-5). AI vào từ đợt 3-4 và chỉ trên hoạt động, chi phí
    ~$0.003-0.02/người/tháng. Động tới chat thì chạy trên máy, hoặc không làm.
  - **"Chế độ không-AI" không phải một chế độ** — xây fix cứng trước thì tắt AI là rơi
    về preset, chi phí bằng không.
  - Khoảng trống trung thực: không tìm được số sẵn sàng chi trả của sinh viên VN; dữ
    liệu phản ứng ngược với AI là US/UK/CA chứ không phải VN.
- **[c12] Chặng 1 solo được mở lại và đào sâu** (user yêu cầu: hiện có gì, thêm gì để
  tăng tỉ lệ lên chặng 2, customize Nam/Nữ). WebSearch x6, không lỗi công cụ.
  - **Kiểm kê:** chặng 1 hiện có 6 tính năng (C1, C6, BD2, KY2, GI7, GI3) + onboarding/
    chọn chế độ + khoảnh khắc mời C0. **Năm trong tám ô bắt đầu bằng hộp rỗng.**
  - ⚠️ **D12-1:** chặng 1 pass L1 ở **ngày 30**, không pass ở **ngày 1**. L1 nói "hoàn
    chỉnh kể cả người kia không vào" nhưng không nói "hoàn chỉnh ngay từ đầu" — kẽ hở
    tôi đã bỏ sót suốt c9-c11.
  - ⭐⭐⭐ **D12-2: gánh nặng đổi vai đúng lúc app đổi chế độ.** Chặng 1 gánh *khởi xướng*
    (nghiêng nam); chặng 2 gánh *duy trì / mental load / kin-keeping* (nghiêng nữ).
    Failure mode: build chặng 2 cũng phục vụ người khởi xướng ⇒ người còn lại thành
    **người vận hành app không công** = mankeeping số hoá.
  - ⭐ **D12-3 (CHỜ USER QUYẾT): đề xuất rẽ theo VAI, không rẽ theo GIỚI.** Pew 2024
    (n=6,204) bác tiền đề "nam ít bạn hơn"; 50-75% phụ nữ đã từng chủ động; không có
    dữ liệu VN về ai trả tiền/ai chủ động. Giới chỉ dùng cho ngôn ngữ (BD1 anh/em).
    Giá phải trả: vai phải hỏi thêm một câu hoặc phải suy, còn giới thì đã có sẵn.
  - ⭐ **D12-7: lỗ to nhất và nó vô hình** — không có tính năng nào phục vụ **người thứ
    hai trong 60 giây đầu**. Đường nối giữa hai chặng không ai sở hữu.
  - **12 ứng viên mới CS1-CS12**, không cái nào vi phạm L3. Mạnh nhất: CS2 (mời vào
    HOẠT ĐỘNG không mời vào MỐI QUAN HỆ), CS7 (giao kèm nội dung VN, không giao hộp
    rỗng), CS5+CS6 (màn hình người thứ hai, hành động trước tài khoản sau), CS11 (bàn
    giao gánh nặng ở lúc chuyển chặng).
  - **Luật mới đề xuất L14:** đẩy ra ngoài, không chỉ hút vào — app không được thành
    ống xả duy nhất (R12-3b: hệ thống hỗ trợ của nam xoay quanh quan hệ tình cảm).
  - **Tự đính chính c11:** L4 nới từ "giấu AI" thành "không lấy AI làm đầu bài" (68%
    Gen Z VN tin AI gợi ý được chủ đề trò chuyện). R-1 và AI-1 không đổi.
  - **Câu hỏi mở mới:** OQ-12A (vai tự khai hay suy từ hành vi), OQ-12B (CS2 có làm
    loãng khoảnh khắc G-b không — tôi chưa giải được).
  - Khoảng trống trung thực: không có dữ liệu VN đương đại về ai trả tiền / ai chủ động.
- **[c13] User đẩy lại D12-3** bằng hai ví dụ: nam quan tâm "đèn đỏ", nữ quan tâm "có
  tâm lý không". WebSearch x2, không lỗi.
  - **D13-1: tôi sai ở c12.** Có **hai trục**, không một. D12-3 chỉ bác trục *ai khởi
    xướng* rẽ theo giới; trục *chú ý gì ở đối phương* c12 **bỏ trống hoàn toàn**.
  - **D13-2..D13-4: nhưng vẫn phải chặn hai ví dụ.** Cả hai lấy **con người** làm đối
    tượng. "Đèn đỏ" ở chặng 1 bất khả thi về **cấu trúc** — chủ thể dữ liệu không có tài
    khoản nên **không có đường xin đồng ý** (R13-1: NĐ 356/2025, hiệu lực 01/01/2026);
    là vector R8 có văn liệu chống lưng (R13-2); và **đã nằm trong danh sách đã loại**
    ở §9 từ trước. "Tâm lý" vi phạm R-1 + XD2 + L13, và đúng chế độ nịnh hót của H-R1.
  - ⭐⭐ **D13-5: R-1 có tác dụng phụ theo giới.** JTBD người rủ hình dạng *hoạt động*
    (R-1 phục vụ trọn vẹn); JTBD người được rủ hình dạng *con người* (R-1 cấm theo định
    nghĩa). Không làm gì thì chặng 1 thành sản phẩm cho nam **do hình học của lưỡi dao**,
    không do chủ ý. **User cảm đúng, chẩn sai nguyên nhân.**
  - ⭐ **D13-6: ổ khoá là nguồn thứ ba — người kia TỰ KHAI về chính mình.** Sạch R-1
    hoàn toàn, chưa từng dùng trong cả idea. Mở ra gần hết trục B một cách hợp pháp.
  - ⭐ **D13-7 lời giải: cấu trúc giá trị hai chiều — cô ấy hưởng lợi từ tính năng ANH
    ẤY dùng.** Vá D13-5 mà không phá R-1 lần nào.
  - **GA1** "hôm nay đi nhẹ thôi" (cô ấy bật, trạng thái không phải dự đoán, tự hết hạn,
    0 byte dữ liệu sức khoẻ) · **GA2** app **làm cho** anh ấy tâm lý hơn thay vì **chấm
    điểm** anh ấy · **GA3** giới rẽ an toàn ở **nội dung** (20/10, 8/3) · **GA4** học từ
    hành vi người dùng, không từ giới.
  - **L17 mới:** mọi thông tin về người kia chỉ đến từ chính người đó hoặc từ tay người
    dùng ghi; **app không bao giờ là nguồn** — biến R-1 thành quy tắc về nguồn dữ liệu,
    kiểm tra được ở tầng kiến trúc. **L15 nới:** giới đổi *chữ và nội dung*, không đổi *cơ chế*.
  - **Mở:** OQ-13A (cho cô ấy đọc lại chữ của chính mình về anh ấy — tự soi hay hồ sơ
    buộc tội? chưa giải) · **OQ-13B/A-18** (có mở lại "đồng bộ chu kỳ" đã loại không?).
- Notes: **Hội tụ xong, thứ tự xong, nghiên cứu xong.** Idea sẵn sàng handoff.
  `design-brief.md` và `handoff-to-scrum-master.md` **đã tái sinh theo kết quả c12**.
  Ba quyết định đang chờ user: **A-16 (vai vs giới)**, **A-17 (L14)**, **A-18 (có mở lại
  "đồng bộ chu kỳ và sức khoẻ" đã loại không)**. Còn lại là
  việc tech-lead (M2, và quyết định on-device nếu bao giờ làm G-1).



## Artifacts

- **Bảng duyệt ứng viên: `candidate-review.md`** (bản rút gọn user duyệt được,
  trước khi chạy Impact/Effort)
- **Brief cho designer người thật: `design-brief.md`**
- **Message handoff: `handoff-to-scrum-master.md`** (paste-ready, 2 requirement)
- Development: `development.md`
- Checkpoint: `brainstormer-checkpoint.md`

## Routing Notes

- Current owner: brainstormer
- Next action: sẵn sàng handoff. Chờ user quyết A-16 (vai vs giới) và A-17 (L14) —
  không chặn handoff, nhưng chặn phần customize trong đợt 1.
- Delivery handoff: explicit user switch to `scrum-master` only
