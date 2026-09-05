# Message handoff sang Helen-SC (paste nguyên khối)

> Tái sinh **c18** theo kết quả c14 (móc nối) · c15 (bản đồ màn hình) · c16 (A-19=3, L18)
> · c17-c18 (A-16/A-17/A-18/A-21 chốt, L14 phủ định, L19).
> **Không còn quyết định nào chờ user.** Bản trước (c12) đã lỗi thời — đừng dùng lại.

---

thêm yêu cầu: Mở rộng Cupid theo hướng "trợ lý cho người đang yêu" — chốt từ
brainstorm IDEA-20260828-002. Tách thành **đúng 2 requirement**, không hơn.

**Nguồn — đọc trước khi breakdown, đừng suy diễn lại.** Thư mục
`data/brainstorms/IDEA-20260828-002_couple-feature-expansion/`:

- ⭐ **`screen-map.md`** — 21 màn hình có mã S-01..S-21, phân loại MỚI/SỬA/DỜI/NỐI/GIỮ,
  5 user journey J1-J5, ngân sách tab. **Đọc tệp này TRƯỚC.** Mọi story dưới đây đều
  trỏ về một mã S-xx trong đó.
- ⭐ **`wiring-map.md`** — móc nối vào 41 module đang có, quét thanh lý, hiện trạng đồ
  thị điều hướng thật.
- **`candidate-review.md`** — Phần A quyết định đã chốt · **Phần B luật (có L14/L18/L19
  mới)** · Phần C ứng viên · Phần I Impact/Effort · Phần J thứ tự · Phần K chặng 1 solo
  · Phần L trục B.
- **`open-decisions.md`** — lập luận và các phương án **đã loại** của 4 quyết định vừa
  chốt. Đọc khi muốn mở lại thứ gì đó.
- **`idea.md`** — quyết định đã chốt, dạng gọn.
- `development.md` **~190 KB — grep rồi ranged read**, đừng đọc cả tệp.
  Query keys: `## Convergence Notes` · `## Research Notes` · `## Session Log`

## ⭐ Điều quan trọng nhất, đọc trước mọi thứ khác

Brainstorm đã **quét mã nguồn thật** (c14/c15/c17), nên phạm vi đã được định lượng chứ
không còn là ước đoán:

- **App hiện có 39 màn hình.** Sau toàn bộ thay đổi:
  **6 MỚI · 11 SỬA · 1 DỜI · 3 NỐI · 18 GIỮ · 0 XOÁ.**
- **Ngân sách tab không tăng.** Chặng 1 hiện **3 tab** (Nhà · Danh sách · Tôi), chặng 2
  hiện **5 tab**. Cơ chế tab-theo-điều-kiện **đã chạy sẵn** (`ChatEntryGate` +
  `_ShellDestination` trong `app_shell.dart`) — tổng quát hoá thành `ModeGate`, **không
  xây mới**.
- ⛔ **Chặng 1 hôm nay là ĐƯỜNG CỤT, không phải "trải nghiệm nghèo".**
  `OnboardingChain._forwardOrder` có **đúng một cạnh** ra khỏi `profileSetup` →
  `pairingChoice`, và `AppShell` chỉ mount **sau `paired`**. Một người dùng chặng 1
  **bất khả đạt tới mọi tab**. ⇒ **M2 gồm CẢ tầng điều hướng**, không chỉ tầng dữ liệu.
- ⭐ **Nửa điều hướng của M2 rẻ hơn nhiều so với nửa dữ liệu** (D14-4). Đừng gộp hai
  nửa vào một ước lượng.
- ⭐ **Ba việc giá trị cao nhất là SỬA màn hình đã có, không phải xây mới:**
  `WaitingScreen` · `JoinCodeScreen`/`PairedScreen` · dời `LoveContract`+`Vow`.

## REQ-A — Chặng 1: trợ lý cho người đang yêu một mình

Sản phẩm dùng được trọn vẹn kể cả khi người kia **không bao giờ** tham gia.

- **STORY shared-foundation, phải xong trước mọi story khác:**
  - **M2 mô hình sở hữu 1 chủ → 2 chủ.** Hôm nay mọi thứ khoá theo `coupleId`. Hạng mục
    lớn nhất, **chặn toàn bộ** REQ-A + REQ-B. **Hai nửa, ước lượng riêng:**
    (a) **tầng điều hướng** — thêm cạnh thứ hai vào `onboarding_chain.dart` (tệp ~60
    dòng, cố ý viết widget-free, có unit test thứ tự) + `ModeGate` tổng quát từ
    `ChatEntryGate`. **Rẻ.**
    (b) **tầng dữ liệu** — chưa ai đo. Việc của tech-lead.
    ⚠️ `coupleType` **KHÔNG rảnh** để chở chế độ — nó đã dùng thật (`SAME_CITY`, hiện
    trên Home) và mang nghĩa khoảng cách địa lý.
  - **BD1 xưng hô anh/em.** Chạm mọi chuỗi text. ⚠️ **`gender` KHÔNG tồn tại trong repo**
    (0 tệp backend, 0 tệp mobile) — phải thêm trường mới. `User` entity hiện có
    `birthday`, `relationshipStartDate`, `zodiacSign`, `coupleType`, `vowTaken`, không có giới.
  - **Nạp toàn bộ luật (Phần B, gồm L14/L17/L18/L19 mới) vào `req_master.md`** làm ràng buộc.
- **S-01 chọn chế độ [MỚI]** — cạnh thứ hai duy nhất phải thêm vào onboarding. Chữ nói
  về **việc**, không về **tình trạng quan hệ**. Lối "một mình" **không được** trình bày
  như bản dùng thử.
- **S-02 Nhà hình thái một người [MỚI]** — `_CoupleHero` hiện tại cần hai avatar và
  `relationshipStartDate`, **bất khả render khi một mình**. ⚠️ **Ràng buộc nặng nhất
  toàn sản phẩm: màn hình này KHÔNG ĐƯỢC RỖNG Ở NGÀY 1** (5/8 ô chặng 1 hiện là hộp
  rỗng ⇒ giá trị ngày 1 ≈ 0).
- **S-03 danh sách hoạt động [MỚI, tab]** — C1 đối tượng xương sống. **Lấy ô tab "Ví
  chung"**, ô này trống ra vì `dream_jar` **gộp vào S-03** làm bộ lọc "tầm xa". Danh
  sách phải **có hướng đi** (chuỗi mỗi cái thân mật hơn một nấc), không phẳng — JTBD
  thật là *"mắc kẹt, không biết đẩy quan hệ tiến lên"*, không phải thiếu ý tưởng.
- **S-04 một hoạt động [MỚI]** · **S-05 khu riêng (C6) [MỚI]** · **S-06 máy quyết định [MỚI]**.
- **CS7 nội dung mồi:** S-03 phải **giao kèm nội dung Việt biên tập sẵn** theo thành
  phố, bám xu hướng hẹn hò-vận-động 2026. Người dùng **cắt bớt**, không **nghĩ ra**.
- **CS8:** đưa đếm ngược dịp Việt (BD2) lên sớm — thứ duy nhất có giá trị ở giây thứ 5
  với 0 dữ liệu. Nó thay đúng chỗ `_DaysCounter` trên S-02.
- **KY2 / GI7 / GI3 bản một người** — ba cái vòi đổ dữ liệu vào S-05. Không có chúng thì
  khoảnh khắc mời ở REQ-B **không có gì để trưng**.
- ⭐ **S-20 chiêm tinh đổi vai [SỬA] — story mới, chốt A-19=3.** `zodiac` đang ship
  `GET /zodiac/red-flag/today` → `ZodiacConflictIndex` (`score`/`scoreMax`/`fillFraction`,
  2 partner) + `dailyTips`. Đó là **tầng 3 của R-1e** đang chạy trong production. Việc phải làm:
  - **bỏ `conflictIndex`** (trường điểm số — L18 cấm);
  - **`dailyTips` lời khuyên → hạt câu hỏi** (lời khuyên là tầng 3 mềm + đúng bề mặt
    nịnh hót H-R1);
  - **đổi tên** endpoint và màn hình `red-flag` — tên mang chính khái niệm bị cấm, **đây
    là hạng mục công việc, không phải mỹ phẩm**;
  - **bản chặng 1** dùng ngày sinh **của chính người dùng** ⇒ chiêm tinh **về bản thân**
    = tầng 1 sạch tuyệt đối ⇒ **cái vòi thứ tư** đổ vào S-05, và là vòi **duy nhất có
    nội dung từ ngày 1 mà không cần nhập gì**.
  - ⭐ **Đây là C8 được hồi sinh.** C8 từng bị hạ ưu tiên vì *"kho câu hỏi soạn sẵn cạn
    trong 2-4 tuần"*, chỉ giữ nếu đổi sang **RS2** (nội dung sinh từ dữ liệu của chính
    cặp đôi). Zodiac sinh câu hỏi mỗi ngày từ ngày sinh của chính hai người = **đúng
    RS2**, đúng hình dạng A-9. Máy sinh câu hỏi **đã chạy sẵn, chỉ đang xuất ra sai thức**.
- ⭐ **GA2 — story quan trọng, dễ bị đọc nhầm thành "nice to have":** hệ thống **nhắc
  đúng lúc** để người rủ **trở nên tâm lý hơn** ("hôm nay 20/10", "hai tuần rồi chưa đi
  đâu"). Lý do: JTBD của người **được rủ** có hình dạng **con người** nên R-1 cấm phục
  vụ trực tiếp ⇒ không có GA2 thì chặng 1 tự nhiên thành sản phẩm cho một phía.
  **Cô ấy hưởng lợi từ tính năng anh ấy dùng.**
- **GA3:** nội dung dịp lễ rẽ theo giới (20/10, 8/3) — gộp vào BD2.
- ❌ **CS9 KHÔNG còn là story.** A-17 đã chốt L14 thành **luật phủ định** — xem ràng
  buộc #12. Đừng tạo story cho nó.
- ❌ **CS10 KHÔNG còn là story hỏi user.** A-16 đã chốt: **vai đọc từ cấu trúc phễu
  mời** (L19) — xem ràng buộc #13.
- **KHÔNG có AI trong REQ-A.** Toàn bộ gợi ý là preset biên tập tay.
- **Cửa kiểm để đóng REQ-A (bắt buộc, đưa vào AC):** chặng 1 có dùng trọn vẹn được kể cả
  nếu người kia không bao giờ tham gia không? Không đạt thì **dừng, đừng mở REQ-B**.

## REQ-B — Từ một người thành hai: khoảnh khắc mời và chặng 2

Cùng một phase với REQ-A, xếp sau. Phụ thuộc cứng vào M2.

- ⭐⭐ **S-07 khoảnh khắc mời [SỬA `WaitingScreen`] — story giá trị cao nhất toàn phase.**
  `WaitingScreen` hôm nay là **màn hình chờ kỹ thuật thuần tuý**. Khoảnh khắc giải
  **đồng thời** rào cản gia nhập X1 + chiến lược tốt nghiệp + vòng lan truyền **đang là
  một spinner**. Nội dung phải là *"đây là N chỗ anh đã ghi lại để đưa em đi"* — một
  **món quà cụ thể**, không phải lời nhờ vả. **Không sinh node mới; đổ nội dung vào node
  đã có.**
- ⭐⭐ **S-08/S-09 người thứ hai [SỬA `JoinCodeScreen` + `PairedScreen`].**
  `JoinCodeScreen` hôm nay **hỏi mã trước, nội dung sau — ngược**. Phải là **hành động
  trước, tài khoản sau** (CS6): người thứ hai **nhìn thấy N chỗ kia trước khi bị hỏi bất
  cứ điều gì**. Cần bề mặt **web** mở được không cần cài app. ⚠️ **Đây là chỗ D12-2 sống
  hoặc chết** — nếu vẫn phục vụ người khởi xướng thì người thứ hai thành người vận hành
  app không công. **CS11 bàn giao gánh nặng** sống ở S-09.
- ⭐ **S-10 nghi thức đổi chế độ [DỜI].** `loveContract` và `vow` hôm nay là **node bắt
  buộc** giữa `paired` và `home` — app bắt hai người thề nguyện **ngay giây sau khi quét
  mã**, trước khi có gì để hứa. **Dời** chúng xuống đúng khoảnh khắc chuyển chặng.
  Ghi chú: `vow` **có** route + cờ `profile.vowTaken`, nhưng **không có module backend
  riêng** (DS1 vẫn cần).
- **CS1-CS4 "dám mời":** diễn thử trước khi gửi · **mời vào một HOẠT ĐỘNG chứ không vào
  một MỐI QUAN HỆ** · mời từng phần · **hết hạn im lặng** (không "đã xem", không đếm
  ngược hiển thị cho người gửi).
- **Ba màn hình đã build nhưng BỊ CHÔN — mở lối vào, đừng build lại (D14-9/D15-4).**
  Cả ba neo vào S-04 "một hoạt động đã làm xong":
  **S-14 `ExpenseHistoryScreen`** (AC7 chia tiền chuyến đi) · **S-15 `GalleryScreen`**
  (album buổi hẹn) · **S-13 `TimelineScreen`** (C7 cột mốc + C16 ký ức tự viết).
  `ExpenseHistoryScreen` và `GalleryScreen` hiện **không tệp nào ngoài thư mục của chúng
  tham chiếu tới**.
- **Nhóm rẻ:** XD6 nút "em đang giận, chưa nói được, nhưng anh đừng lo" (tỉ lệ giá
  trị/chi phí tốt nhất toàn danh mục) · **S-16 RS1** thoả thuận kỳ vọng liên lạc (nối
  vào `AntiGhostScreen` đã có) · SC7+DS2 quà bất ngờ qua `wishlistThemeId` (field đã có,
  chưa nối) · DS1 backend cho `vow` · XD7 hẹn giờ nguội · SC3 huỷ hẹn cũng cần hai chìa
  khoá · **S-17** nhắc nhau (C14 ô giữa) · bản chặng-2 của GI3 và KY2.
- ⭐ **S-21 pet đổi vai [SỬA] — story mới, chốt A-21=1.** `pets` ship `happiness` ·
  `level` · `streak` · `mood` · `points` · `percent` + `pet_stats_row.dart`. Phải phản
  ánh **NHỊP**, không **ĐIỂM**: bỏ `level`/`points`/`percent`/`streak`, giữ `mood` như
  trạng thái **định tính** phái sinh từ hoạt động. (`streak` đã bị ràng buộc #12 cấm sẵn.)
- **Nhóm dày:** KY1 `timeline` tự viết · SC2 cả hai chọn mù · C3 chuyến đi đầu tiên ·
  RS4 đồng bộ thành tính năng hạng nhất · TR1 app tự câm khi hai máy ở gần · TR4 chế độ
  để-điện-thoại-xuống · GI5 phiên làm việc chung.
- **Nguyên thuỷ đã có, dùng lại:** mutual consent đang chạy ở 6 module · blind-reveal ·
  `invitations` (đã có `inviter`) · `notifications` · `alarms` · `messages` · `timeline`.

## Ràng buộc bất biến — nạp vào cả hai req_master, không mở lại

1. **R-1:** trợ lý làm việc trên **HOẠT ĐỘNG**, không làm việc trên **CON NGƯỜI**. Có
   bằng chứng thực nghiệm chống lưng (Phần H).
2. **R-1e luật ba tầng — công cụ phân loại chính thức.** Tầng 1 người dùng **ghi** ✅ ·
   tầng 2 người dùng **đoán**, app không xác nhận ✅ *(hợp lệ, và là trò chơi)* · tầng 3
   **app khẳng định** về người kia ❌. Phân loại theo **ai khẳng định**, **không** theo
   chủ đề.
3. **G-1:** "học từ chat" chỉ áp dụng cho **chat chung trong app**, chỉ **từ chặng 2**,
   bật bằng **hai chìa khoá**. Không bao giờ đọc Zalo/Messenger/app khác.
4. **G-2 (ii-b):** khu riêng **công khai và đối xứng**; cái vô hình là **nội dung và cả
   việc có-hay-không**. Không có đường nào — kể cả mật khẩu — để một tài khoản xem của
   tài khoản kia. `data-export` **phải loại trừ** khu riêng. Không hiển thị số mục chưa
   chia sẻ.
5. **AI-1:** nếu cho model đọc chat, đầu ra chỉ được **trích xuất hoạt động**, không được
   **mô tả con người**. Ràng bằng structured output/JSON schema ở tầng API.
6. AI chỉ vào từ REQ-B nhóm dày, và chỉ trên hoạt động. Đụng chat thì **chạy trên máy,
   hoặc bỏ tính năng**.
7. Không marketing đây là app AI, nhưng **không cần giấu AI** (68% Gen Z VN coi AI gợi ý
   chủ đề là bình thường). Chỉ đừng lấy AI làm đầu bài.
8. **L3:** không bao giờ khoá tính năng để ép người dùng mời.
9. **L15:** giới chỉ đổi **chữ và nội dung**, **không** đổi **cơ chế**. Không làm "chế độ
   an toàn cho nữ" — chế độ gắn với giới sẽ báo cho kẻ kiểm soát biết ai có gì để giấu.
10. **L16:** ngày một phải có giá trị. Sản phẩm phải đáng dùng khi chưa nhập gì.
11. ⭐ **L17:** mọi thông tin về người kia chỉ đến từ **chính người đó** hoặc từ **tay
    người dùng tự ghi**. **App không bao giờ là nguồn.**
12. ⭐ **L18 (mới, c16) — cưỡng chế bằng schema, không bằng thiện chí.**
    **Chủ thể khẳng định quyết định tính hợp lệ, không phải chủ đề.** App được **NÊU**
    chủ đề về hai người; app **không được KẾT LUẬN** về họ. Schema đầu ra của mọi nội
    dung mô tả người/cặp đôi **không được có trường điểm số** — cấm `score`, `index`,
    `percent`, `compatibility`, `level` và mọi biến thể. **Đây là bản tổng quát của R-1e
    + AI-1.** Phép kiểm nhanh cho reviewer: quét payload tìm
    `score|index|percent|compatibility|level|streak`.
13. ⭐ **L14 (mới, chốt c18) — dạng PHỦ ĐỊNH.** **Cấm mọi cơ chế làm tăng thời gian
    trong app vì chính thời gian đó** — streak, điểm chuyên cần, combo, thông báo mồi.
    App giữ chân bằng **giá trị của việc đã làm xong**, không bằng **nghĩa vụ quay lại**.
14. ⭐ **L19 (mới, chốt c18) — vai xác định bởi CẤU TRÚC, không bởi câu hỏi.**
    Vai (*đang rủ* / *đang được rủ*) đọc từ phễu mời: **người tạo lời mời = khởi xướng**,
    **người mở link = được rủ**. `invitations.service.ts` đã có `inviter`. **Không hỏi
    người dùng, không suy từ hành vi.** Không xác định được ⇒ **bản trung tính, đừng đoán**.
15. ⛔ **Hai thứ ĐÃ BỊ CHẶN, đừng để lọt vào story:**
    (a) **theo dõi chu kỳ/sức khoẻ của người kia** — chốt **A-18: KHÔNG mở lại**.
    ⚠️ **Ghi đúng lý do:** *GA1 đã lấy gần hết giá trị ở rủi ro gần 0* + *chi phí NĐ
    356/2025 (hiệu lực 01/01/2026)* + *vector R8*. **KHÔNG** phải "bất khả thi về cấu
    trúc" — lập luận đó **chỉ đúng cho chặng 1**; ở chặng 2 cả hai đều có tài khoản nên
    đường đồng ý tồn tại. Bản **được phép** là **GA1** ("hôm nay đi nhẹ thôi": cô ấy bật,
    trạng thái không phải dự đoán, tự hết hạn, **không đếm, không chu kỳ hoá, không dự
    đoán lần sau**, chỉ từ chặng 2).
    (b) **mọi thứ chấm điểm/đánh giá tính cách người kia** — R-1 + XD2 + L13 + H-R1.
    Bản được phép là **GA2**.

## Ngoài phạm vi phase này

Chặng 3 (đã hoãn) · thương mại/đối tác · sách in · tính năng đôi-bạn-cùng-chơi (chờ đủ
mật độ người dùng) · ghi chú về bạn bè người kia (chưa quyết) · `themes`/`emojis`/`vibes`
(trục biểu đạt, không phản đối nhưng idea không cấp việc cho).

## Việc thuộc tech-lead, không phải product-owner

- **M2 nửa tầng dữ liệu** — brainstorm **chưa đo**, cố ý không kết luận.
- Cưỡng chế **L18** bằng schema đầu ra, cùng chỗ với **AI-1**.
- Quyết on-device vs bỏ tính năng nếu REQ-B chạm chat.
- **S-08 màn người thứ hai là web ⇒ quyết stack và đường deep-link vào app.**
- Đổi tên endpoint `zodiac/red-flag` → phải có đường di trú cho client đang chạy.

## Hai câu brainstorm CHƯA GIẢI ĐƯỢC (không chặn, ghi để không ai tưởng đã quyết)

- **OQ-12B:** CS2 (mời vào *hoạt động*) có làm loãng khoảnh khắc mời S-07 không? Hai cái
  kéo ngược nhau.
- **OQ-13A:** cho người dùng đọc lại chính ghi chép của mình về người kia ("3 tuần bạn
  ghi 4 lần 'anh ấy quên'") là **tự soi** hay **app dựng hồ sơ buộc tội**?

Idea liên quan đang đỗ: `IDEA-20260828-001_hearts-currency-economy`. TR4 trong REQ-B bắc
cầu sang nó. Chưa handoff, đừng kéo vào phase này.
