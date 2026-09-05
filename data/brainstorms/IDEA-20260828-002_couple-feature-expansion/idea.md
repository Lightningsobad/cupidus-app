# Idea Master: IDEA-20260828-002 Couple Feature Expansion
Lifecycle: ACTIVE
Development Status: EXPANDED
Source: user
Created: 2026-08-28
Last Updated: 2026-09-03 (vòng 19)
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
- **[c14] Vòng móc nối — idea gặp mã nguồn.** User chặn handoff: *"mới dừng ở ý tưởng,
  chưa móc nối tới tính năng hiện tại, chưa sinh màn hình, chưa có user journey."*
  **User đúng.** 13 vòng trước chạy trên ý tưởng; chưa vòng nào mở `app_shell.dart`.
  Không dùng web research; đọc mã nguồn thật. Kết quả đầy đủ: **`wiring-map.md`**.
  - ⭐⭐⭐ **D14-1: chặng 1 không thiếu màn hình — chặng 1 KHÔNG CÓ CỬA.**
    `OnboardingChain` có đúng một cạnh ra khỏi `profileSetup` → `pairingChoice`, và
    `AppShell` (5 tab) chỉ mount sau `paired`. Người dùng một mình **bất khả đạt tới mọi
    tab**. M2 lớn hơn ta ghi: đồ thị điều hướng cũng chỉ có một chế độ.
  - ⭐⭐ **D14-2: đối tượng xương sống C1 không có tab — nhưng ô đã có sẵn.** Tab "Ví
    chung" đang mount `DreamJarListScreen`, mà §5 đã chốt gộp hũ ước mơ **vào** C1. Việc
    gộp tự nó giải phóng đúng cái tab C1 cần. Móc nối rẻ nhất toàn idea.
  - ⭐⭐ **D14-3: tab Nhà bất khả render ở chế độ một người** (`_CoupleHero` cần hai
    avatar, `_DaysCounter` cần ngày bắt đầu của cặp). Nhà phải có **hai hình thái**;
    đếm ngược dịp Việt thay đúng chỗ `_DaysCounter`.
  - ⭐ **D14-4: cơ chế "một app đổi chế độ" ĐÃ có trong repo.** `ChatEntryGate` làm tab
    Chat rơi hẳn khỏi danh sách khi khoá. Tổng quát hoá `ModeGate`, không xây mới —
    **nửa điều hướng của M2 rẻ hơn ta tưởng.**
  - ⭐⭐ **D14-5/D14-6: nghi thức đổi chế độ đã có chỗ, đang bị dùng sai.**
    `loveContract` + `vow` là node **bắt buộc** giữa `paired` và `home` — app bắt hứa
    trước khi có gì để hứa. §4.3 cần **dời**, không cần màn hình mới. Kèm theo: `vow`
    không có backend nhưng vẫn là node bắt buộc.
  - ⭐⭐ **D14-7: D12-7 sai một nửa.** Đường nối hai chặng **có** chủ kỹ thuật
    (`invitations` + `invite/waiting/joinCode/paired`); chúng chỉ **rỗng nội dung**.
    Khoảnh khắc mời đắt nhất sản phẩm đang là một màn hình chờ.
  - ⭐⭐⭐ **D14-8 (CHẶN, A-19): luật R-1 mâu thuẫn với tính năng ĐANG CHẠY.** `zodiac`
    ship `GET /zodiac/red-flag/today` → `ZodiacConflictIndex` (`score`/`scoreMax`, thanh
    fill, hai partner) + `dailyTips`, màn hình `ZodiacRedFlagScreen` có ô trên Nhà. Đó
    **đúng tầng 3** của `R-1e` (*"độ ăn khớp 78%"*, đã loại 2 lần) và đúng ví dụ **"đèn
    đỏ"** tôi chặn ở c13. **17 luật chưa bao giờ được đối chiếu với tập tính năng đang
    chạy** — lỗ hổng phương pháp. Phân biệt thật: nguồn là ngày sinh **tự khai**, cả hai
    có tài khoản ⇒ sạch L17; nhưng `conflictIndex` vẫn là app khẳng định bằng con số.
  - **D14-9:** `expenses` (có backend + route), `gallery`, `emojis` **bị chôn không lối
    vào**. AC7 móc vào `expenses` đã có. Hộp rỗng không chỉ ở chặng 1.
  - **D14-10 (trung thực):** vòng này đọc **điều hướng và bề mặt**, không đọc mô hình dữ
    liệu ⇒ **không nói gì về chi phí M2 tầng dữ liệu**. G-3 vẫn nguyên vẹn của tech-lead.
  - **Quét thanh lý 41 module:** 6 NỐI · 1 ĐỔI VAI · 2 DỜI · 5 CHỜ · 1 xung đột luật.
    **Không module nào phải xoá** — chống lưng D10-2.
  - ⭐ **Kết luận gộp của 5 journey:** cả năm journey chỉ cần **đúng ba bề mặt mới**
    (chọn chế độ · Nhà hình thái một người · tab C1). Còn lại là **nhét nội dung vào node
    đã có** hoặc **dời**. Chi phí bề mặt thấp hơn nhiều so với giả định ngầm của 13 vòng trước.
- **[c15] Bản đồ màn hình + user journey** (user yêu cầu trực tiếp). Kết quả:
  **`screen-map.md`**. Không dùng web research.
  - **A-20 (user quyết):** brainstormer được phép sinh bản đồ màn hình mức nghiệp vụ.
    Layout/component/token vẫn là `ui-ux-designer` sau handoff.
  - ⭐ **D15-1 — chi phí bề mặt của cả hướng đi, lần đầu được định lượng:**
    app có **39 màn hình**; sau thay đổi là **6 MỚI · 9 SỬA · 1 DỜI · 3 NỐI · 2 CHỜ ·
    18 GIỮ**, **không màn hình nào bị xoá**. Sáu màn hình mới: S-01 chọn chế độ ·
    S-02 Nhà solo · S-03 Danh sách hoạt động (C1) · S-04 Một hoạt động · S-05 Khu riêng
    (C6) · S-06 Máy quyết định. **Nhỏ hơn nhiều so với giả định ngầm "mở sang chặng 1 =
    làm sản phẩm thứ hai" của 13 vòng đầu.**
  - ⭐ **D15-2 — ngân sách tab KHÔNG tăng:** chặng 1 thấy 3 tab (Nhà · Danh sách · Tôi),
    chặng 2 thấy 5 tab. Dùng lại cơ chế tab-có-điều-kiện đã chạy (D14-4). `dream_jar`
    rời tab, thành bộ lọc "tầm xa" trong S-03.
  - **D15-3 (đính chính c14):** `vow` **có** route và **có** cờ `profile.vowTaken` —
    đúng hơn là *không có module backend riêng, chỉ một cờ boolean*; D14-5 không đổi,
    chi phí dời thấp hơn. `love_contracts` **không** bị chôn (có lối vào từ `MeScreen`).
    Chôn thật chỉ còn `ExpenseHistoryScreen` và `GalleryScreen`.
  - ⭐ **D15-4:** ba màn hình bị chôn **có nhà ở S-04** (chi tiêu/album/cột mốc neo vào
    "một hoạt động đã làm xong"). Mở lối vào cho đồ đã build rẻ hơn build mới.
  - ⭐⭐ **D15-5:** **J3 (khoảnh khắc mời) đang là một spinner.** `WaitingScreen` thuần
    kỹ thuật, trong khi đó là khoảnh khắc giải đồng thời X1 + tốt nghiệp (a) + lan truyền
    (b). Ưu tiên số một của mọi requirement sinh ra từ idea này.
  - ⭐⭐ **D15-6:** **J4 là chỗ D12-2 sống hoặc chết.** `JoinCodeScreen` hôm nay hỏi mã
    trước, nội dung sau — ngược với CS6 (hành động trước, tài khoản sau).
  - **A-19 mở thành bốn lối** (`screen-map.md` Phần 5): (1) miễn trừ có tên · (2) R-1 hồi
    tố · (3) **đổi vai zodiac từ chấm điểm → mồi chuyện** ← khuyến nghị · (4) hoãn. Lập
    luận cứu zodiac có thật: nguồn là ngày sinh **tự khai**, cả hai đều có tài khoản ⇒
    **sạch L17**, khác cấu trúc với ca "đèn đỏ chặng 1". `pets` cùng họ, nên đi cùng lối.
- **[CHỐT c16] A-19 = lối 3: zodiac đổi vai từ *chấm điểm cặp đôi* → *mồi chuyện*.**
  Việc truy **cơ chế** của lối 3 sinh ra ba kết quả vượt ngoài bản thân quyết định:
  - ⭐⭐ **D16-1: lối 3 không phải ngoại lệ — là dịch chuyển tầng.** `R-1e` phân loại
    theo **ai khẳng định**, không theo **chủ đề**. Đổi *thức* từ **kết luận** → **câu
    hỏi** thì chủ thể khẳng định chuyển từ app sang người dùng ⇒ rơi từ **tầng 3 (cấm)**
    xuống **tầng 2 (ĐOÁN — "hợp lệ, và là trò chơi")**. **R-1 đứng yên, không có ngoại
    lệ nào được mở.**
  - ⭐⭐ **D16-2 / L18 (luật mới):** *chủ thể khẳng định quyết định tính hợp lệ, không
    phải chủ đề. App được **NÊU** chủ đề về hai người; app không được **KẾT LUẬN** về
    họ.* Cưỡng chế ở tầng API cùng nước đi **AI-1**: schema đầu ra mô tả người/cặp đôi
    **cấm mọi trường điểm số** (`score`, `index`, `percent`, `compatibility`, `level`).
    **L18 là bản tổng quát của `R-1e` + `AI-1`** và là phép thử máy chạy được.
  - ⭐⭐⭐ **D16-3: A-19=3 HỒI SINH C8.** **A-9 (c7)** đã chốt C8 phải có dạng *"thi
    thoảng chèn câu hỏi"*; **nghiên cứu c6** hạ ưu tiên C8 vì *"kho câu hỏi soạn sẵn cạn
    trong 2-4 tuần — mô hình chết phổ biến thứ hai của thể loại; chỉ giữ nếu đổi sang
    **RS2**"*. Zodiac sau đổi vai sinh câu hỏi **mỗi ngày từ ngày sinh của chính hai
    người** = **đúng RS2**, **đúng hình dạng A-9**. App **đã có sẵn một máy sinh câu hỏi
    hằng ngày chạy trong production, chỉ đang xuất ra sai thức.**
  - ⭐ **D16-4: S-20 chạy được ở CẢ HAI chặng.** Chặng 1 dùng ngày sinh **của chính người
    dùng** ⇒ chiêm tinh **về bản thân** = tầng 1, sạch tuyệt đối. Đây là **cái vòi thứ
    tư** đổ vào S-05 (cạnh KY2/GI7/GI3), và là **vòi duy nhất có nội dung từ ngày 1 mà
    không cần nhập gì** ⇒ vá thẳng **D12-1**.
  - **D16-5/D16-6:** phải đổi **tên** endpoint/màn hình `red-flag` (tên mang chính khái
    niệm bị cấm — không phải mỹ phẩm), và `dailyTips` phải đổi từ **lời khuyên** sang
    **hạt câu hỏi** (lời khuyên là tầng 3 mềm + đúng bề mặt nịnh hót H-R1).
- **[c16] A-21 mới (chờ user, KHÔNG chặn): `pets` trượt L18.** Đo được:
  `happiness`/`level`/`streak`/`mood`/`points`/`percent` + `pet_stats_row.dart`. **Phân
  biệt trung thực:** chủ thể là **hoạt động chung**, không phải **con người** ⇒ **không**
  vi phạm `R-1e` như zodiac; nhưng vi phạm **L18** và vi phạm **§6.12** của chính idea
  này. `streak` nặng nhất. **Lớn hơn zodiac** (một tab + entity backend + 6 trường số).
  Khuyến nghị cùng lối 3.
- **[c17] Bốn quyết định còn mở đã đóng gói thành phương án: `open-decisions.md`.**
  Đo thêm mã nguồn, và **hai lập luận cũ bị lật**:
  - ⭐⭐ **D17-1: lập luận giá cả của A-16 ở c12 là SAI.** c12 nói *"giới thì đã có sẵn"*
    — quét toàn repo: **`gender` không tồn tại ở đâu cả** (0 tệp). Giới cũng phải thêm
    trường + câu hỏi ⇒ **lập luận duy nhất chống lưng lối giới đã biến mất.**
  - ⭐⭐ **D17-2: vai đọc được từ CẤU TRÚC PHỄU MỜI** — J3 người tạo lời mời = khởi
    xướng, J4 người mở link = được rủ, `invitations.service.ts` đã có `inviter`.
    **Không hỏi câu nào, không suy đoán, chi phí 0.** Lời giải thứ ba cho OQ-12A.
  - ⚠️ **D17-4: L14 không đáp xuống bề mặt nào** sau khi vẽ đủ 21 màn hình. Lối cứu duy
    nhất không phải trả giá: chốt L14 làm **luật PHỦ ĐỊNH** (cấm mọi cơ chế tăng
    thời-gian-trong-app vì chính nó) — cưỡng chế được, không tốn màn hình, **trùng khớp A-21**.
  - ⭐⭐ **D17-5: rút lại một phần lập luận c13 về A-18.** Lập luận *cấu trúc* (không có
    đường xin đồng ý) **chỉ áp cho chặng 1**; ở chặng 2 cả hai đều có tài khoản nên
    PRIM-1 chính là đường đồng ý. Kết luận "không mở lại" **giữ nguyên**, nhưng lý do
    phải đổi thành **GA1 đã đủ + chi phí NĐ 356/2025 + vector R8**.
  - ⭐ **D17-6:** tự ghi cho mình = tầng 1 ✅ · chủ động chia sẻ trạng thái định tính =
    **chính là GA1, đã có** ✅ · app dự đoán rồi nói với anh ấy = tầng 3 ❌. **Phần "mở
    lại" thêm được chủ yếu nằm đúng ở tầng bị cấm.**
  - **D17-7: A-17 và A-21 nên chốt cùng nhau** — luật phủ định của A-17 đã cấm sẵn
    `streak` của pet.
  - **Khuyến nghị gộp: `A-16=1 · A-17=1 · A-18=1 · A-21=1`.**
- **[CHỐT c18] Bốn quyết định cuối: `A-16=1 · A-17=1 · A-18=1 · A-21=1`.**
  - **A-16=1:** rẽ theo **VAI**, vai **đọc từ cấu trúc phễu mời** ⇒ **L19**. Giới giữ
    riêng cho ngôn ngữ + nội dung dịp lễ (L15).
  - **A-17=1:** **L14 dạng PHỦ ĐỊNH** — cấm mọi cơ chế tăng thời-gian-trong-app vì chính
    nó. **CS9 không còn là story**, nó thành ràng buộc.
  - **A-18=1:** không mở lại đồng bộ chu kỳ. **Lý do đúng: GA1 đủ + NĐ 356/2025 + R8**,
    không phải "bất khả thi cấu trúc" (D17-5).
  - **A-21=1:** pet phản ánh **nhịp**, không **điểm** — thành story S-21 trong REQ-B.
  - ⭐ **D18-1: ba luật mới cùng một HÌNH DẠNG** — L18 cấm *trường điểm số* · L14 cấm
    *cơ chế tăng thời gian* · L19 cấm *hỏi/suy đoán về vai*. Cả ba là **phép cấm quét
    được bằng máy**, cùng nước đi với AI-1. Bộ luật toàn khẳng định thì chết; bộ này sống.
  - **D18-2:** backlog xoá 2 story (CS9, CS10-hỏi-user → thành luật), thêm 2 story
    (**S-20 zodiac đổi vai** = C8 hồi sinh, **S-21 pet đổi vai**). Hai story mới đều là
    **sửa nợ luật đang chạy trong production**.
- **[c18] `handoff-to-scrum-master.md` ĐÃ TÁI SINH** theo c14-c18. Bản c12 lỗi thời.
  **Idea sẵn sàng handoff — không còn quyết định treo.**
- **[c19] `design-brief.md` cập nhật lên bản 4 — và sửa GỐC của việc lệch.**
  ⭐ **D19-1: bản 3 lệch vì nó CHÉP LẠI thông tin mà tệp khác sở hữu.** Chỉ cập nhật nội
  dung thì 3 vòng nữa sẽ lệch lại. Bản 4 thêm **§0 bảng "nguồn duy nhất"**: mỗi loại
  thông tin có **đúng một tệp sở hữu**, tệp khác chỉ trỏ tới, và ghi rõ *"nếu mâu thuẫn
  thì tệp sở hữu đúng"*. design-brief từ nay **không giữ danh sách màn hình** (thuộc
  `screen-map.md`) và **không giữ bản chuẩn của luật** (thuộc `candidate-review.md` Phần
  B); nó sở hữu **định vị · hai chế độ · mẫu dùng lại · thứ tự thiết kế**.
  - **D19-2: bản 3 CẨN THẬN HƠN bản tóm tắt c13 của tôi.** §4.0b(1) đã tự giới hạn
    *"ở chế độ một người thì bất khả thi về cấu trúc"* — đúng như D17-5 kết luận. Phần
    phải sửa nhỏ hơn dự đoán; chỉ cần **thêm câu trả lời cho chặng 2** (A-18=1) và ghi
    rõ **đừng chặn bằng lý do cấu trúc nữa**.
  - **D19-3: L14 dạng phủ định LẤY MẤT một lối thoát của câu hỏi mở OQ-13A.** Bản 3 gợi
    ý dùng L14 để trả lời ranh giới "tự soi vs hồ sơ buộc tội" (*app nói "kể với bạn
    đi"*). L14 giờ là luật phủ định ⇒ **không còn đưa ra lối thoát đó**. OQ-13A **trần
    trụi hơn trước**, không dễ hơn. Đã ghi thẳng vào brief thay vì để designer tự vấp.
  - **4/9 câu hỏi ở §10 nay đã trả lời được** (xưng hô một nửa · thanh tab · web · một
    hay hai bề mặt · vai). Hai câu **vẫn chưa ai giải được** (OQ-12B, OQ-13A) được đánh
    dấu rõ là chưa giải, không giả vờ đã quyết.
- Notes: **[SỬA c14] "Idea sẵn sàng handoff" ở c13 là kết luận vội.** Hội tụ xong,
  thứ tự xong, nghiên cứu xong — nhưng **móc nối thì chưa**, và vòng 14 tìm ra một mâu
  thuẫn luật đang chạy trong production. Nay đã có bản đồ bề mặt và journey.
  `design-brief.md` và `handoff-to-scrum-master.md` **đã tái sinh theo kết quả c12**.
  ✅ **TOÀN BỘ quyết định đã đóng** (A-16..A-21, c15-c18). Còn đúng **hai câu brainstorm
  chưa giải được**, không chặn delivery: **OQ-12B** (CS2 có làm loãng khoảnh khắc mời
  không) và **OQ-13A** (đọc lại ghi chép của chính mình — tự soi hay hồ sơ buộc tội). Còn lại là việc tech-lead
  (M2 tầng dữ liệu, và quyết định on-device nếu bao giờ làm G-1).



## Artifacts

- **⭐ Bốn quyết định còn mở + phương án: `open-decisions.md`** (c17 — A-16/A-17/A-18/A-21,
  17 phương án, bảng được/mất, khuyến nghị)
- **⭐ Bản đồ màn hình + user journey: `screen-map.md`** (c15 — 21 màn hình có mã
  S-01..S-21, phân loại MỚI/SỬA/DỜI/NỐI/GIỮ, 5 journey, 4 lối A-19)
- **⭐ Bản đồ móc nối: `wiring-map.md`** (c14 — bề mặt nào mới, cái gì
  nối vào module đang có, 5 journey đầu-cuối, quét thanh lý 41 module)
- **Bảng duyệt ứng viên: `candidate-review.md`** (bản rút gọn user duyệt được,
  trước khi chạy Impact/Effort)
- **Brief cho designer người thật: `design-brief.md`**
- **Message handoff: `handoff-to-scrum-master.md`** (paste-ready, 2 requirement)
- Development: `development.md`
- Checkpoint: `brainstormer-checkpoint.md`

## Routing Notes

- Current owner: brainstormer
- Next action: ✅ **handoff đã tái sinh (c18) và sẵn sàng.** Việc còn lại **duy nhất**:
  user paste `handoff-to-scrum-master.md` vào Helen-SC khi muốn bắt đầu delivery.
  Brainstormer không tạo `data/requirements/` — đó là việc của `scrum-master`. Đặc tả màn hình là việc `ui-ux-designer` sau handoff, không làm
  trong brainstorm.
- Delivery handoff: explicit user switch to `scrum-master` only
