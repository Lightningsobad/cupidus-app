# Message handoff sang Helen-SC (paste nguyên khối)

---

thêm yêu cầu: Mở rộng Cupid theo hướng "trợ lý cho người đang yêu" — chốt từ
brainstorm IDEA-20260828-002. Tách thành **đúng 2 requirement**, không hơn.

**Nguồn — đọc trước khi breakdown, đừng suy diễn lại:**
- `data/brainstorms/IDEA-20260828-002_couple-feature-expansion/candidate-review.md`
  (bản gọn, đã duyệt: Phần B luật · Phần C ứng viên · Phần H AI · Phần I Impact/Effort
  · Phần J thứ tự thi công · **Phần K chặng 1 solo · Phần L trục B — hai phần này mới nhất và đè lên phần cũ**)
- `data/brainstorms/IDEA-20260828-002_couple-feature-expansion/idea.md` (quyết định đã chốt)
- `development.md` **~165 KB — grep rồi ranged read**, đừng đọc cả file.
  Query keys: `## Convergence Notes` · `## Research Notes` · `## Session Log`

## REQ-A — Chặng 1: trợ lý cho người đang yêu một mình

Sản phẩm dùng được trọn vẹn kể cả khi người kia **không bao giờ** tham gia.

- **STORY shared-foundation, phải xong trước mọi story khác:**
  - M2: mô hình sở hữu dữ liệu **1 chủ → 2 chủ**. Hôm nay mọi thứ khoá theo
    `coupleId`. Đây là hạng mục lớn nhất và nó **chặn toàn bộ** REQ-A + REQ-B.
  - BD1: xưng hô anh/em. Chạm mọi chuỗi text nên phải quyết ngay từ đầu.
  - 12 luật thiết kế (Phần B) nạp vào `req_master.md` làm ràng buộc.
- **Các story còn lại:** C1 danh sách hoạt động (đối tượng xương sống, gộp
  `dream_jar` đang dựng dở) · C6 nhật ký riêng · BD2 lịch âm + dịp lễ Việt ·
  KY2 một câu sau buổi hẹn (bản một người) · GI7 nghi thức khép ngày (bản một
  người) · GI3 "đang nghĩ tới em" (bản một người, ghi vào C6, không gửi đi đâu).
- ⭐ **Bốn story mới, thêm sau vòng đào chặng 1 (Phần K):**
  - **CS7 nội dung mồi:** C1 phải **giao kèm nội dung Việt biên tập sẵn** theo thành
    phố, bám xu hướng hẹn hò-vận-động 2026. Người dùng **cắt bớt**, không **nghĩ ra**.
    Lý do: 5/8 ô của chặng 1 hiện bắt đầu bằng hộp rỗng ⇒ giá trị ngày 1 ≈ 0.
  - **CS8:** đưa đếm ngược dịp Việt (BD2) lên sớm — thứ duy nhất có giá trị ở giây
    thứ 5 với 0 dữ liệu.
  - **CS10 vai:** trục cá nhân hoá là **VAI** (*đang rủ* / *đang được rủ*), **không
    phải GIỚI**. Giới **chỉ** dùng cho ngôn ngữ anh/em (BD1). ⏳ Còn một OQ mở: vai
    tự khai hay suy từ hành vi — hỏi user trước khi viết AC.
  - **CS9 (L14):** app phải thỉnh thoảng đẩy người dùng ra ngoài ("kể với bạn bè"),
    không chỉ hút vào.
- ⭐ **GA2 — story quan trọng, dễ bị đọc nhầm thành "nice to have":** hệ thống **nhắc
  đúng lúc** để người rủ **trở nên tâm lý hơn** ("hôm nay 20/10", "hai tuần rồi chưa đi
  đâu", "cô ấy nhắc quán này ba lần"). Lý do nó quan trọng: JTBD của người **được rủ**
  có hình dạng **con người** nên R-1 cấm phục vụ trực tiếp ⇒ nếu không có GA2 thì chặng 1
  tự nhiên thành sản phẩm chỉ cho một phía. **Cô ấy hưởng lợi từ tính năng anh ấy dùng.**
- **GA3:** nội dung dịp lễ rẽ theo giới (20/10, 8/3, ai tặng ai) — gộp vào BD2.
- **KHÔNG có AI trong REQ-A.** Toàn bộ gợi ý là preset biên tập tay.
- **Cửa kiểm để đóng REQ-A (bắt buộc, đưa vào AC):** chặng 1 có dùng trọn vẹn được
  kể cả nếu người kia không bao giờ tham gia không? Không đạt thì **dừng, đừng mở
  REQ-B**. Đây là cách giảm thiểu duy nhất cho rủi ro lớn nhất của thứ tự đã chọn.

## REQ-B — Từ một người thành hai: khoảnh khắc mời và chặng 2

Cùng một phase với REQ-A, xếp sau. Phụ thuộc cứng vào M2.

- **Story bản lề, làm trước trong REQ-B:** C0 chế độ một người → lời mời → chuyển
  chế độ → tốt nghiệp. Lời mời là *"đây là N chỗ anh đã ghi lại để đưa em đi"*, lấy
  thẳng từ C1/C6 mà REQ-A đã tích luỹ. Đây là chỗ **duy nhất** giải bài toán rào cản
  gia nhập.
- ⭐ **Ba story mới trong bản lề, phễu chuyển chặng có 3 chỗ rơi và ta mới thiết kế 1:**
  - **CS1-CS4 "dám mời":** diễn thử trước khi gửi · **mời vào một HOẠT ĐỘNG chứ không
    vào một MỐI QUAN HỆ** · mời từng phần (một danh sách, không phải cả app) · **hết
    hạn im lặng** (không "đã xem", không đếm ngược hiển thị cho người gửi).
  - **CS5+CS6 màn hình NGƯỜI THỨ HAI:** hiện **không có tính năng nào** phục vụ người
    được mời. Cần một màn **web** (không cài app vẫn xem được) và người thứ hai phải
    **làm được một việc trước khi tạo tài khoản**. Đây là lỗ lớn nhất của phễu.
  - **CS11 bàn giao gánh nặng:** ở khoảnh khắc đổi chế độ, app **chia lại việc** rõ
    ràng và mặc định. Gánh nặng đổi vai đúng lúc app đổi chế độ (chặng 1 gánh *khởi
    xướng*, chặng 2 gánh *duy trì*); nếu không chặn, người còn lại thành người vận
    hành app không công.
- **Nhóm rẻ, làm ngay sau bản lề:** XD6 nút "em đang giận, chưa nói được, nhưng anh
  đừng lo" (tỉ lệ giá trị/chi phí tốt nhất toàn danh mục) · RS1 thoả thuận kỳ vọng
  liên lạc · SC7+DS2 quà bất ngờ qua `wishlistThemeId` (field đã có, chưa nối) ·
  DS1 backend cho `vow` (mobile đã xong, thiếu nửa server) · XD7 hẹn giờ nguội ·
  SC3 huỷ hẹn cũng cần hai chìa khoá · bản chặng-2 của GI3 và KY2.
- **Nhóm dày, làm sau:** KY1 `timeline` tự viết · SC2 cả hai chọn mù · C3 chuyến đi
  đầu tiên · RS4 đồng bộ thành tính năng hạng nhất · TR1 app tự câm khi hai máy ở
  gần · TR4 chế độ để-điện-thoại-xuống · GI5 phiên làm việc chung.
- Tận dụng nguyên thuỷ đã có: mutual consent đang chạy ở 6 module, blind-reveal,
  `notifications`, `alarms`, `messages`, `timeline`.

## Ràng buộc bất biến — nạp vào cả hai req_master, không mở lại

1. **R-1:** trợ lý làm việc trên **HOẠT ĐỘNG**, không làm việc trên **CON NGƯỜI**.
   Mọi tính năng phân tích/chấm điểm/đoán ý người kia đều đã bị loại. Có bằng chứng
   thực nghiệm chống lưng (Phần H).
2. **G-1:** "học từ chat" chỉ áp dụng cho **chat chung trong app**, chỉ **từ chặng 2**,
   và bật bằng **hai chìa khoá**. Không bao giờ đọc Zalo/Messenger/app khác.
3. **G-2 (ii-b):** khu riêng **công khai và đối xứng** cho cả hai tài khoản; cái vô
   hình là **nội dung và cả việc có-hay-không**. Không có đường nào — kể cả mật khẩu
   — để một tài khoản xem của tài khoản kia. `data-export` **phải loại trừ** khu
   riêng. Không bao giờ hiển thị số lượng mục chưa chia sẻ.
4. **AI-1:** nếu bao giờ cho model đọc chat, đầu ra chỉ được **trích xuất hoạt động**,
   không được **mô tả con người**. Ràng bằng structured output/JSON schema ở tầng API
   — hàng rào cưỡng chế được, không phải lời hứa.
5. AI chỉ vào từ REQ-B nhóm dày, và chỉ trên hoạt động. Đụng tới chat thì **chạy model
   trên máy, hoặc bỏ tính năng** — không có phương án "gửi lên server".
6. Không marketing đây là app AI, nhưng **không cần giấu AI** — 68% Gen Z VN coi AI
   gợi ý chủ đề là bình thường. Chỉ là đừng lấy AI làm đầu bài.
7. **L3:** không bao giờ khoá tính năng để ép người dùng mời. Mọi thứ ở REQ-B làm việc
   mời *dễ hơn* và *đáng hơn*, không làm việc không-mời *đau hơn*.
8. **L15:** giới tính chỉ dùng cho ngôn ngữ. **Không làm "chế độ an toàn cho nữ"** —
   chế độ gắn với giới sẽ báo cho kẻ kiểm soát biết ai có gì để giấu. Đối xứng tuyệt đối.
9. **L16:** ngày một phải có giá trị. Sản phẩm phải đáng dùng khi người dùng chưa nhập gì.
10. ⭐ **L17 — ràng buộc kiến trúc, không phải khẩu hiệu:** mọi thông tin về người kia
    chỉ được đến từ **chính người đó** hoặc từ **tay người dùng tự ghi**. **App không bao
    giờ là nguồn.** Đây là dạng kiểm tra được của R-1 và tech-lead phải cưỡng chế nó cùng
    chỗ với AI-1.
11. ⛔ **Hai thứ ĐÃ BỊ CHẶN, đừng để lọt vào story:** (a) theo dõi chu kỳ/sức khoẻ của
    người kia — ở chặng 1 là **bất khả thi về cấu trúc** vì chủ thể dữ liệu chưa có tài
    khoản nên không có đường xin đồng ý (Luật BVDLCN hiệu lực 01/01/2026, NĐ 356/2025),
    và là vector R8; (b) mọi thứ chấm điểm/đánh giá tính cách người kia ("có tâm lý
    không") — R-1 + XD2 + L13 + H-R1. Bản được phép của (a) là **GA1** ("hôm nay đi nhẹ
    thôi": cô ấy bật, trạng thái không phải dự đoán, tự hết hạn, **không đếm, không chu
    kỳ hoá, không dự đoán lần sau**, chỉ từ chặng 2). Bản được phép của (b) là **GA2**.

## Ngoài phạm vi phase này

Chặng 3 (đã hoãn) · thương mại/đối tác · sách in · tính năng đôi-bạn-cùng-chơi
(chờ đủ mật độ người dùng) · ghi chú về bạn bè người kia (chưa quyết).

## Việc thuộc tech-lead, không phải product-owner

M2 mô hình sở hữu · cưỡng chế AI-1 bằng schema đầu ra · quyết on-device vs bỏ tính
năng nếu REQ-B chạm chat · **CS5 màn người thứ hai là web ⇒ cần quyết stack và đường
deep-link vào app**.

## Hai câu hỏi cần hỏi user trước khi viết AC

- Vai (*đang rủ* / *đang được rủ*): **tự khai một câu** hay **suy từ hành vi**?
- CS2 (mời vào hoạt động) có làm loãng khoảnh khắc mời không? Hai cái kéo ngược nhau
  và brainstorm chưa giải được.
- Có mở lại "đồng bộ chu kỳ và sức khoẻ" (đã loại) cho chặng 2 không? **GA1 không phải
  là mở lại nó.** Mở lại = đảo một quyết định đã chốt.
- Cho người dùng đọc lại chính ghi chép của mình về người kia ("3 tuần bạn ghi 4 lần
  'anh ấy quên'") là tự soi hay app dựng hồ sơ buộc tội? Chưa giải được.

Idea liên quan đang đỗ: `IDEA-20260828-001_hearts-currency-economy`. TR4 trong REQ-B
bắc cầu sang nó. Chưa handoff, đừng kéo vào phase này.
