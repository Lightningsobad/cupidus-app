# Bốn quyết định — mô tả + phương án (vòng 17) → ✅ **ĐÃ CHỐT TOÀN BỘ (vòng 18)**

> **KẾT QUẢ (user, 2026-09-03): `A-16=1 · A-17=1 · A-18=1 · A-21=1` — theo khuyến nghị.**
> Sinh ra **L19** (vai xác định bởi cấu trúc phễu) và **L14 dạng phủ định**.
> Tệp này giữ lại **lập luận và các phương án đã loại**, để sau này không ai mở lại mà
> không biết vì sao đã đóng. Bảng chốt chính thức nằm ở `candidate-review.md` Phần A/B.

Trạng thái: **A-19 ✅ chốt lối 3 (c16)**. Bốn câu còn lại **✅ chốt c18**.
Không cái nào chặn handoff; chúng chặn *nội dung* của một số bề mặt trong `screen-map.md`.

Vòng này đo thêm mã nguồn (`user.entity.ts`, `onboarding_profile_setup_screen.dart`,
`invitations.service.ts`) và kết quả **lật ngược lập luận chính của A-16**.

---

## A-16 — Customize rẽ theo **VAI** hay theo **GIỚI**?

### Mô tả

Từ c12: chặng 1 gánh việc **khởi xướng**, chặng 2 gánh việc **duy trì / mental load /
kin-keeping** (D12-2). Nếu chặng 2 cũng phục vụ người khởi xướng thì người còn lại thành
**người vận hành app không công** — *mankeeping số hoá*. Nên app cần biết **người này
đang ở vai nào** để nội dung không phục vụ nhầm người.

Câu hỏi ban đầu của user là rẽ theo **giới**. c12 đề xuất rẽ theo **vai**, với hai chứng
cứ: Pew 2024 (n=6.204) bác tiền đề *"nam ít bạn hơn"*; và 50-75% phụ nữ đã từng chủ
động. Không có dữ liệu VN đương đại về ai trả tiền / ai chủ động.

### ⭐⭐ Đo được ở vòng 17 — lập luận giá cả của c12 là **SAI**

c12 viết: *"Giá phải trả: vai phải hỏi thêm một câu hoặc phải suy, còn **giới thì đã có
sẵn**."* Tôi vừa quét toàn repo:

| | Thực tế đo được |
|---|---|
| **`gender`** | **Không tồn tại ở đâu cả** — 0 tệp backend, 0 tệp mobile |
| `User` entity có | `email` · `displayName` · `photoUrl` · **`birthday`** · `relationshipStartDate` · `zodiacSign` · `language` · `partnerId` · `coupleType` · `vowTaken` · `isGhostModeEnabled` · `role` |
| `coupleType` | **đã dùng thật** (`SAME_CITY`…, hiện trên Home) — là khoảng cách địa lý, **không** rảnh để chở chế độ |

⇒ **Giới cũng phải thêm trường và thêm một câu hỏi.** Lập luận "giới rẻ hơn vì đã có
sẵn" **không còn tồn tại**. Đó là lập luận duy nhất chống lưng cho lối giới.

*(Lưu ý: `gender` **vẫn phải thêm** bất kể chọn gì — **A-15/BD1 xưng hô anh/em đã chốt**
và cần giới cho **ngôn ngữ**. Theo **L15**, giới đổi *chữ và nội dung*, **không** đổi
*cơ chế*.)*

### ⭐⭐ Và câu hỏi phụ của A-16 có **lời giải thứ ba** mà c12 không nghĩ tới

OQ-12A hỏi: nếu rẽ theo vai thì **tự khai một câu** hay **suy từ hành vi**? Cả hai đều
có giá. Nhưng theo bản đồ journey ở c15, **vai được phễu xác định sẵn**:

- **J3** — người bấm "rủ người này đi", tạo lời mời ⇒ **người khởi xướng**.
- **J4** — người mở link, nhận lời mời ⇒ **người được rủ**.
- `invitations.service.ts` **đã có `inviter`** trong luồng — dữ liệu đã nằm đó.

⇒ **Vai không cần hỏi, cũng không cần suy từ hành vi. Nó đọc được từ cấu trúc lời mời,
chi phí bằng 0, không hỏi ai câu nào.** Đây là điều c12 không thể thấy vì c12 chưa có
bản đồ journey.

### Phương án

| | Phương án | Được | Mất |
|---|---|---|---|
| **1** ⭐ | **Rẽ theo VAI, vai đọc từ cấu trúc lời mời** (người tạo lời mời = khởi xướng; người mở link = được rủ) | **0 câu hỏi thêm, 0 suy đoán.** Sạch Pew 2024. Phục vụ đúng D12-2/CS11 | Vai của người **không đi qua phễu mời** (cả hai tự cài rồi ghép mã) phải có mặc định. Cần một quy tắc dự phòng |
| **2** | Rẽ theo VAI, **tự khai một câu** ở S-01/S-18 | Rõ ràng, người dùng kiểm soát | Thêm một câu hỏi vào lúc onboarding vốn đã dài; và người ta hay khai theo hình ảnh mong muốn |
| **3** | Rẽ theo VAI, **suy từ hành vi** | Không hỏi gì | App **suy về người dùng** — mấp mé R-1, và sai thì sai âm thầm |
| **4** | Rẽ theo **GIỚI** | Đúng trực giác ban đầu của user | Bị Pew 2024 bác; **và giờ không còn rẻ hơn** (đo được). Rủi ro sản phẩm đóng khuôn giới |
| **5** | **Không rẽ** — một trải nghiệm cho tất cả | Rẻ nhất, không rủi ro | **D12-2 không được vá** ⇒ chặng 2 phục vụ người khởi xướng ⇒ mankeeping số hoá. Đây là rủi ro c12 đánh giá ⭐⭐⭐ |

**Khuyến nghị: 1**, kèm quy tắc dự phòng (không xác định được vai ⇒ dùng bản trung tính,
đừng đoán). Giữ **giới** riêng cho **ngôn ngữ + nội dung dịp lễ** (BD1, GA3) theo **L15**.

---

## A-17 — Chốt **L14** thành luật hay không?

### Mô tả

**L14 (đề xuất c12):** *"Đẩy ra ngoài, không chỉ hút vào — app không được trở thành ống
xả duy nhất."* Nền: **R12-3b** — hệ thống hỗ trợ của nam giới có xu hướng xoay quanh
quan hệ tình cảm. Nếu app hút hết mọi biểu đạt vào trong, nó **làm trầm trọng** đúng cái
mà nó định giúp.

### ⚠️ Ghi trung thực: sau khi vẽ 21 màn hình, L14 **không đáp xuống bề mặt nào**

Tôi đã lập bản đồ S-01..S-21 ở c15. L14 chỉ được nhắc thoáng ở S-19 (Tôi) — và đó không
phải một bề mặt, đó là một chỗ để nhét. **Một luật không có bề mặt là trang trí.**

Ba chỗ L14 *có thể* sống thật, nhưng cả ba đều có giá:

- **S-03/S-04**: hoạt động được phép là *đi với bạn bè*, không chỉ *đi với người kia* —
  nhưng điều đó **làm loãng** đối tượng xương sống (*"một việc hai đứa sẽ làm cùng nhau"*).
- **S-05 khu riêng**: nhắc *"kể chuyện này với một người bạn đi"* — nhưng đó là app
  **khuyên về đời sống xã hội của người dùng**, mấp mé tầng 3 của chính L18.
- **Không làm gì trong sản phẩm**, chỉ giữ L14 làm **luật phủ định**: *cấm mọi cơ chế
  làm tăng thời gian trong app vì bản thân thời gian* (streak, combo, điểm chuyên cần).
  Cái này **không cần bề mặt nào** và cưỡng chế được — và nó **trùng khớp với A-21**.

⭐ Lối thứ ba là lối duy nhất trong ba lối không phải trả giá bằng thứ khác.

### Phương án

| | Phương án | Được | Mất |
|---|---|---|---|
| **1** ⭐ | **Chốt L14 dưới dạng luật PHỦ ĐỊNH:** cấm mọi cơ chế tăng thời-gian-trong-app vì chính nó (streak, chuyên cần, combo, thông báo mồi). Không yêu cầu bề mặt nào | Cưỡng chế được, không tốn màn hình, **ăn khớp thẳng với A-21** (`streak` của pets) | Không chủ động đẩy người dùng ra ngoài — chỉ không kéo vào |
| **2** | Chốt L14 dưới dạng **khẳng định** (app chủ động nhắc kể với bạn bè) | Đúng tinh thần R12-3b nhất | Cần bề mặt mới; và app **khuyên về đời sống xã hội** — mấp mé L18 |
| **3** | Giữ L14 làm **nguyên tắc thiết kế mềm**, không cưỡng chế | Rẻ, linh hoạt | Sẽ bị bỏ qua lúc có áp lực chỉ số. Luật mềm là luật chết |
| **4** | **Bỏ L14** | Bớt một ràng buộc | Mất một khác biệt định vị hiếm; và R12-3b không tự biến mất |

**Khuyến nghị: 1.** Nó biến L14 từ một câu khẩu hiệu thành một phép cấm kiểm tra được,
và nó cùng một nước với L18 (cấm trường điểm số) — hai luật cùng một hình dạng, dễ nhớ
và dễ cưỡng chế.

**Ghi trung thực:** R12-3b là văn liệu quốc tế, **không có dữ liệu VN**. Và đây là luật
**chống lại chỉ số tương tác** — nếu sau này có áp lực tăng trưởng, đây là luật bị đem
ra xin nới đầu tiên. Chốt hay không nên tính cả điều đó.

---

## A-18 — Có mở lại **"đồng bộ chu kỳ và sức khoẻ"** (đã loại ở §9) cho chặng 2 không?

### Mô tả

Đã loại ở §9. c13 chặn lại lần nữa khi user đưa ví dụ "đèn đỏ". **GA1 không phải là mở
lại nó** — GA1 là *"hôm nay đi nhẹ thôi"*: cô ấy **tự bật**, là **trạng thái** chứ không
phải **dự đoán**, **tự hết hạn**, và **0 byte dữ liệu sức khoẻ**.

### Phân tích lại bằng công cụ mới (L18 + luật ba tầng)

Lập luận chặn ở c13 có **hai phần**, và chúng **không còn giá trị như nhau**:

| Lập luận chặn c13 | Còn đúng ở chặng 2? |
|---|---|
| **Cấu trúc:** chủ thể dữ liệu không có tài khoản ⇒ **không có đường xin đồng ý** | ❌ **Không còn đúng.** Ở chặng 2 **cả hai đều có tài khoản** ⇒ đường đồng ý tồn tại, và **hai chìa khoá (PRIM-1)** chính là nó. Đây là lập luận **mạnh nhất** của c13 và nó **chỉ áp cho chặng 1** |
| **Pháp lý:** NĐ 356/2025, hiệu lực 01/01/2026, xếp dữ liệu sức khoẻ / đời sống tình dục là **dữ liệu nhạy cảm** | ✅ Vẫn đúng, và là chi phí thật (nghĩa vụ lưu trữ, xoá, báo cáo) |
| **R8:** vector kiểm soát cưỡng chế | ✅ Vẫn đúng — biết chu kỳ là một công cụ kiểm soát có thật |

Và **luật ba tầng** cho một lát cắt sắc hơn ba mức:

- **Cô ấy tự ghi cho chính mình** ⇒ **tầng 1 (GHI)** ⇒ ✅ hợp lệ hoàn toàn.
- **Cô ấy chủ động chia sẻ một trạng thái định tính** ⇒ vẫn tầng 1, có đồng ý ⇒ ✅ —
  **và đây chính là GA1, đã có rồi.**
- **App dự đoán chu kỳ và nói với anh ấy** ⇒ **tầng 3** ⇒ ❌ cấm bởi cả `R-1e` lẫn **L18**.

⭐ ⇒ **GA1 đã lấy gần hết giá trị ở mức rủi ro gần bằng 0.** Phần còn lại mà "mở lại" đem
thêm được **chủ yếu nằm ở tầng 3** — đúng phần bị cấm.

### Phương án

| | Phương án | Được | Mất |
|---|---|---|---|
| **1** ⭐ | **Không mở lại. GA1 là đủ.** | 0 byte dữ liệu nhạy cảm, 0 nghĩa vụ NĐ 356/2025, 0 vector R8, giữ nguyên §9 | Không phục vụ người muốn theo dõi chu kỳ thật sự |
| **2** | Mở ở **tầng 1 thuần**: tự ghi cho chính mình, **không chia sẻ gì** | Sạch luật hoàn toàn | Đó là **một app theo dõi chu kỳ**, ngoài phạm vi sản phẩm, và có app khác làm tốt hơn nhiều. Vẫn phát sinh nghĩa vụ dữ liệu nhạy cảm |
| **3** | Mở **có chia sẻ**, bằng **hai chìa khoá**, chỉ **trạng thái định tính**, không con số, không dự đoán | Đường đồng ý ở chặng 2 là thật; PRIM-1 làm đúng việc của nó | Về mặt trải nghiệm gần **trùng GA1** nhưng **kéo theo toàn bộ chi phí pháp lý** mà GA1 tránh được. Trả giá cao để mua thứ gần như đã có |
| **4** | Mở **đầy đủ** (có dự đoán) | Đúng thứ user hỏi ban đầu | ❌ **Tầng 3 — L18 cấm.** Đảo ngược §9, R8, và NĐ 356/2025 cùng lúc |

**Khuyến nghị: 1.** Đáng ghi rõ: tôi **rút lại một phần lập luận c13** — lý do *cấu trúc*
(không có đường đồng ý) **không áp cho chặng 2**, nên nếu ta vẫn nói "không" thì phải nói
vì **GA1 đã đủ + chi phí pháp lý**, chứ **không** vì "bất khả thi về cấu trúc". Chặn đúng
kết luận bằng sai lý do là một lỗi, kể cả khi kết luận đúng.

---

## A-21 — `pets` trượt **L18**

### Mô tả (đo được, không đoán)

`pets` ship **`happiness` · `level` · `streak` · `mood` · `points` · `percent`**, kèm
widget `pet_stats_row.dart`. Đó là một **bảng điểm**. design-brief §6.12 đã tự phán quyết
từ trước: *"chỉ được phản ánh **nhịp** — có đang cùng nhau làm gì không — **tuyệt đối
không phản ánh điểm số**."*

**Không cùng ca với zodiac:** chủ thể của `happiness` là **hoạt động chung**, không phải
**con người** ⇒ **không** vi phạm `R-1e`. Nó vi phạm **L18** (trường điểm số mô tả cặp
đôi) và vi phạm **§6.12**. `streak` nặng nhất: bảng điểm chuỗi ngày đụng luật *"chúng ta,
không phải tôi vs anh"*, và biến việc yêu nhau thành nghĩa vụ giữ chuỗi.

**Lớn hơn zodiac:** 1 tab trong 5 + entity backend + 6 trường số rải trong 4 tệp.

### Phương án

| | Phương án | Được | Mất |
|---|---|---|---|
| **1** ⭐ | **Cùng lối 3:** pet phản ánh **nhịp**, không **điểm**. Bỏ `level`/`points`/`percent`/`streak`; giữ `mood` như **trạng thái định tính** phái sinh từ hoạt động | Nhất quán với A-19 và §6.12. **Nếu A-17=1 thì luật này đã tự động cấm `streak` rồi** | Sửa entity + API + màn hình. Mất cơ chế giữ chân dạng streak |
| **2** | **Miễn trừ** — pet là vật nuôi ảo, điểm số của nó không nói về con người | Không phải sửa gì | **Ngoại lệ đầu tiên của L18**, và ngay sau khi L18 vừa ra đời. Luật có lỗ ở tuần đầu |
| **3** | **Gỡ pet khỏi tab**, hạ xuống một ô trong Nhà, giữ nguyên điểm số | Trả lại 1/5 ngân sách điều hướng cho việc khác | Không giải quyết vi phạm L18, chỉ giấu nó đi |
| **4** | **Bỏ pet** | Sạch nhất | Mất một tính năng đã ship, và pet không phải thứ xấu — nó chỉ đang đo sai thứ |

**Khuyến nghị: 1.** Và lưu ý: **A-17 và A-21 nên chốt cùng nhau** — nếu A-17 = phương
án 1 (cấm cơ chế tăng thời-gian-trong-app vì chính nó) thì `streak` của pet **đã bị luật
đó cấm sẵn**, và A-21 chỉ còn là việc thi hành.

---

## Tóm tắt để chốt

| Mã | Câu hỏi | Khuyến nghị |
|---|---|---|
| **A-16** | Rẽ theo vai hay giới? | **1** — vai, **đọc từ cấu trúc lời mời** (0 câu hỏi thêm). Giới giữ riêng cho ngôn ngữ + nội dung dịp lễ (L15) |
| **A-17** | L14 thành luật? | **1** — luật **phủ định**: cấm cơ chế tăng thời-gian-trong-app vì chính nó |
| **A-18** | Mở lại đồng bộ chu kỳ? | **1** — không; **GA1 đã đủ**. Nhưng lý do là *GA1 + chi phí pháp lý*, **không** phải *bất khả thi về cấu trúc* (lập luận đó chỉ đúng cho chặng 1) |
| **A-21** | `pets` trượt L18 | **1** — cùng lối 3: nhịp, không điểm. Chốt cùng A-17 |

✅ **User chốt: `A-16=1 A-17=1 A-18=1 A-21=1` (2026-09-03, c18).**
**Không còn quyết định nào chặn.** Hai câu duy nhất còn mở là OQ-12B (CS2 có làm loãng
khoảnh khắc mời không) và OQ-13A (đọc lại chính ghi chép của mình — tự soi hay hồ sơ
buộc tội) — cả hai brainstorm **chưa giải được**, và cả hai **không chặn** delivery.
