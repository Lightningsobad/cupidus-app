# Design Brief — Cupid: mở rộng thành "trợ lý cho người đang yêu"

Người nhận: designer.

Cập nhật **2026-09-03 (bản 4)**. Nếu bạn đã đọc bản 3, đọc lại đúng: **§0 (mới)** ·
**§4.0b(1)** (đã có câu trả lời cho chặng 2) · **§6.12** (pet) · **§8** (L14 viết lại,
thêm L18/L19) · **§9** (thêm 2 mục đã loại) · **§10** (4/9 câu đã được trả lời) ·
**§12**.

⚠️ **Bản 4 KHÔNG còn là danh sách màn hình.** Danh sách màn hình chính thức nay nằm ở
`screen-map.md` (S-01..S-21) — xem §0. Tài liệu này giữ phần **"vì sao"**: định vị,
hai chế độ, luật, mẫu dùng lại, và những thứ đã bị chặn. Phần "vì sao" không phải để đọc
lướt — nhiều luật ở đây **phản trực giác**, và nếu không nắm lý do thì rất dễ thiết kế
ngược lại một cách hoàn toàn hợp lý.

---

## 0. Nguồn duy nhất cho mỗi loại thông tin — đọc trước

Bản 3 đã bị lệch với thực tế vì nó **chép lại** thông tin mà tài liệu khác sở hữu. Bản 4
sửa gốc của lỗi đó: mỗi loại thông tin có **đúng một tệp sở hữu**, các tệp khác chỉ trỏ
tới. Nếu bạn thấy tài liệu này mâu thuẫn với tệp sở hữu, **tệp sở hữu đúng**.

| Bạn cần | Đọc tệp | Tài liệu này |
|---|---|---|
| **Danh sách màn hình**, phân loại mới/sửa/dời/nối, ngân sách tab | `screen-map.md` §1-§3 | không giữ |
| **User journey** J1-J5 đầu-cuối | `screen-map.md` §4 | không giữ |
| **Móc nối vào module đang chạy**, hiện trạng điều hướng | `wiring-map.md` | không giữ |
| **Luật** bản chuẩn, đánh số toàn cục | `candidate-review.md` Phần B | §8 là bản diễn giải cho designer |
| **Quyết định đã chốt** và lý do | `candidate-review.md` Phần A | §9, §10 |
| **Phương án đã loại** và vì sao loại | `open-decisions.md` | §9 |
| **Định vị, hai chế độ, mẫu dùng lại, thứ tự thiết kế** | — | ⭐ **tài liệu này sở hữu** |

⚠️ **Cảnh báo đánh số:** trong §8 dưới đây, **`L1` nghĩa là "làm việc trên hoạt động,
không trên con người"** — ở các tệp khác luật đó tên là **`R-1`**. Từ `L14` trở đi thì
đánh số trùng khớp với `candidate-review.md` Phần B.

---

## 1. Sản phẩm là gì, và KHÔNG là gì

App hiện tại phục vụ **cặp đôi đã có đôi**: ví chung, theme chung, nhắn tin, thú cưng,
album, dòng thời gian, chia tiền, lời hứa. Vấn đề: muốn dùng thì **cả hai phải cùng
cài và cùng đồng ý** — rào cản gia nhập rất lớn.

Hướng mở rộng: app phục vụ được **một người đang yêu, dùng một mình**, và khi người kia
đồng ý thì **cùng một app đổi chế độ** thành app cho hai người.

**Không phải:**
- ❌ app hẹn hò / ghép đôi
- ❌ "AI huấn luyện viên tình yêu". Đối thủ (CoupleWork, Connected, Lovon, Smush) đều
  bán thứ này. Nghiên cứu đăng trên *Science* thử 11 hệ AI: tất cả đều nịnh người dùng,
  xác nhận lập luận sai trong 73% kịch bản, và **chỉ một lần tương tác đã đủ khiến
  người ta ít xin lỗi và ít sửa hành vi hơn trong xung đột**. Ta cố ý không làm.
- ❌ CRM quản lý người yêu: ghi chú chiến thuật, chấm điểm hợp nhau, phân tích tin nhắn

**Là:** chỗ để **lên kế hoạch** và **ghi lại**. Những nơi muốn đưa người ta đi, phim
muốn cùng xem, dịp không được quên, và một quyển nhật ký riêng.

**Người dùng:** người trẻ Việt Nam đang yêu hoặc đang tán tỉnh một người cụ thể.

---

## 2. Hai chế độ, một app — điều quan trọng nhất phải hiểu

| | Chế độ MỘT NGƯỜI | Chế độ HAI NGƯỜI |
|---|---|---|
| Danh sách hoạt động | của tôi | của chúng ta |
| Ghi chép | nhật ký riêng | nhật ký riêng **vẫn còn** + kỷ niệm chung |
| "Đang nghĩ tới em" | ghi vào nhật ký, không gửi | gửi thật, người kia nhận được |
| Câu hỏi sau buổi hẹn | hỏi mình, tự trả lời | cả hai trả lời rồi cùng lật bài |
| Cột mốc | tôi ghi | cả hai cùng ghi, cùng nhìn lại |

**Cùng một đối tượng ở hai chế độ** — không phải hai sản phẩm. Danh sách tôi ghi một
mình, sau khi đổi chế độ, trở thành danh sách chung. Nhật ký riêng **không biến mất**
khi có đôi; nó chạy suốt.

---

## 3. ⚠️ Thiết kế TOÀN BỘ, không chia đợt

**Không có chuyện thiết kế chế độ một người trước rồi chế độ hai người sau.**

Đây không phải sở thích quản lý mà là ràng buộc cấu trúc: vì cùng một đối tượng sống ở
hai chế độ, thiết kế màn hình chế độ một người mà chưa biết hình hài của nó ở chế độ
hai người **chính là cách chắc chắn nhất tạo ra thứ không sống sót qua lúc chuyển**.
Mọi màn hình phải được vẽ ở **cả hai trạng thái** ngay từ đầu, và phải chỉ ra được
đường biến hình giữa chúng.

Bên kỹ thuật có thứ tự thi công riêng (nền dữ liệu trước, rồi chế độ một người, rồi
khoảnh khắc mời, rồi tính năng cặp đôi). Thứ tự đó **không được phép định hình công
việc thiết kế**. Bạn giao trọn bộ.

⭐ **Phạm vi đã được đo, không còn là ước đoán.** App hiện có **39 màn hình**. Sau toàn
bộ thay đổi: **6 MỚI · 11 SỬA · 1 DỜI · 3 NỐI · 18 GIỮ · 0 XOÁ**, và **ngân sách tab
không tăng** (chặng 1 dùng 3 tab, chặng 2 dùng 5). Danh sách đầy đủ ở `screen-map.md`.
Phần lớn việc của bạn là **mở rộng ngôn ngữ thiết kế sẵn có**, không phải vẽ một sản
phẩm thứ hai.

---

## 4. Vào app, và khoảnh khắc mời

### 4.0 ⭐ Trục cá nhân hoá: theo VAI, không theo GIỚI TÍNH

Sản phẩm này **có** cá nhân hoá, nhưng cắt theo một trục có thể gây bất ngờ.

- **Giới tính chỉ dùng cho ngôn ngữ.** Tiếng Việt bắt buộc phải biết ai xưng "anh", ai
  xưng "em". App cần biết điều đó, và **chỉ** dùng nó cho chữ.
- **Giới tính KHÔNG BAO GIỜ bật/tắt hay đổi thứ tự tính năng.** Lý do là dữ liệu, không
  phải chính trị: khảo sát Pew 2024 trên 6.204 người cho thấy nam **không** có ít bạn
  thân hơn nữ và mức cô đơn **không** khác nhau nhiều theo giới — cái khác là *hành vi*,
  không phải *cấu trúc*. Và 50-75% phụ nữ đã từng là người chủ động. Thiết kế theo giới
  sẽ đoán sai với khoảng một nửa số người dùng nữ.
- **Trục thật là VAI:** người dùng đang là **người rủ** hay **người được rủ**?
  - *Người rủ* cần: bước tiếp theo là gì, rủ thế nào cho đỡ sợ, chỗ nghĩ một mình.
  - *Người được rủ* cần: chỗ ghi lại một người mình **chưa chắc chắn**, và cách đáp lại
    hoặc chọn mà không bị đọc thành nhiều hơn ý mình.
- **Vai phải đổi được bất cứ lúc nào**, và app nên tự đề nghị xem lại vai ở lúc chuyển
  chế độ (xem 4.3).
- ⏳ **Còn đang chờ chủ sản phẩm quyết** (câu hỏi 6 ở mục 10): hỏi thẳng một câu lúc
  onboarding, hay suy từ hành vi trong app. Bạn cần thiết kế **cả hai phương án**, vì
  chúng cho ra hai onboarding rất khác nhau.

**Giới tính ĐƯỢC phép đổi hai thứ: CHỮ và NỘI DUNG. Không bao giờ đổi CƠ CHẾ.**
- Chữ: anh/em.
- Nội dung: 20/10 là ngày phụ nữ Việt Nam, 8/3 là quốc tế phụ nữ — ai tặng ai, tặng gì,
  gợi ý gì. Nội dung này **buộc phải** biết giới và hoàn toàn vô hại.
- Cơ chế: **không bao giờ**. Không có màn hình nào, nút nào, luồng nào chỉ hiện ra với
  một giới.

### 4.0b ⚠️ Hai thứ người dùng RẤT muốn mà sản phẩm này sẽ không bao giờ làm

Bạn sẽ nghe thấy hai nhu cầu này từ mọi buổi phỏng vấn người dùng, và chúng nghe rất
hợp lý. Chúng đã được xem xét kỹ và **đã bị chặn**. Đừng thiết kế chúng, và nếu ai đề
xuất lại thì đây là lý do.

**(1) "Nam muốn biết bạn nữ có đang đến ngày không."**
Đây là làm việc trên **cơ thể** người kia. Ba lý do chặn, lý do thứ hai là lý do cứng:
- Vi phạm L1 (làm việc trên hoạt động, không trên con người).
- ⚠️ **Ở chế độ một người thì nó bất khả thi về mặt cấu trúc, không phải về mặt chính
  sách.** Người kia **chưa có tài khoản**. Nghĩa là dữ liệu sức khoẻ của một người
  **hoàn toàn không hay biết** sẽ nằm trong máy người khác — không có đường nào để báo
  cho cô ấy, càng không có đường xin phép. Luật Bảo vệ dữ liệu cá nhân Việt Nam có hiệu
  lực **01/01/2026** và siết chặt yêu cầu đồng ý với dữ liệu nhạy cảm.
- Nghiên cứu về app theo dõi chu kỳ gọi thẳng nhóm rủi ro này là **giám sát bạn đời**,
  và mô tả các app đó đã trở thành *"công cụ của quyền lực và kiểm soát"*.
→ **Phiên bản được phép, xem 6.7b.**

  ⭐ **Bổ sung bản 4 — câu hỏi "thế còn chặng 2?" đã được hỏi và đã có câu trả lời.**
  Lập luận *bất khả thi về cấu trúc* ở trên **chỉ đúng cho chế độ một người**, và đoạn
  văn trên đã cẩn thận nói đúng như vậy. Ở chế độ **hai người** thì cả hai đều có tài
  khoản nên **đường xin đồng ý tồn tại** (chính là mẫu hai chìa khoá ở 7.1). Dù vậy
  quyết định vẫn là **KHÔNG mở**, và lý do đúng phải được ghi lại cho đúng:
  **(a)** 6.7b đã lấy gần hết giá trị ở **0 byte dữ liệu sức khoẻ**; **(b)** chi phí
  pháp lý thật của dữ liệu nhạy cảm (NĐ 356/2025); **(c)** vector kiểm soát cưỡng chế
  không biến mất chỉ vì có nút đồng ý. **Đừng chặn nó bằng lý do "bất khả thi về cấu
  trúc" nữa** — ở chặng 2 lý do đó sai, và chặn đúng bằng sai lý do thì lần sau sẽ bị
  lật.

**(2) "Nữ muốn biết bạn nam kia có 'tâm lý' không."**
Đây là làm việc trên **tính cách** người kia. Vi phạm L1, L2 (không báo cáo hành vi
người này cho người kia) và L13 (không đặt hai người hai phía) cùng lúc. Ngoài ra có
nghiên cứu trên *Science* cho thấy hệ AI xu hướng **xác nhận lập luận sai của người
dùng** trong 73% kịch bản, và **một lần** tương tác đủ khiến người ta ít xin lỗi hơn
trong xung đột tình cảm. Một app nói *"anh ấy có vẻ không tâm lý lắm"* không giúp ai cả.
→ **Phiên bản được phép, xem 6.7c — và nó tốt hơn bản gốc.**

---

### 4.1 Onboarding và chọn chế độ
Người mới mở app chọn: "đang yêu một mình" hay "đã có đôi".
- ⚠️ Chọn một mình **không được cảm giác là hạng thấp hơn**, không phải bản dùng thử.
- **Đừng bắt định nghĩa quan hệ.** Không hỏi "hai bạn đang là gì của nhau" — người
  đang tán tỉnh không trả lời được câu đó, và bắt trả lời là đuổi họ đi.
- **Tên và icon không được hét lên "app cặp đôi".** Người dùng chặng 1 có thể chưa
  muốn ai thấy trên màn hình chính điện thoại rằng họ đang dùng app tình yêu.

### 4.2 ⭐ Khoảnh khắc mời — màn hình quan trọng nhất toàn sản phẩm
Đây là chỗ **duy nhất** giải bài toán rào cản gia nhập. Dành cho nó nhiều thời gian
hơn tỉ trọng số màn hình của nó gợi ý.

- **Lời mời là món quà, không phải lời nhờ.** Thông điệp cốt lõi:
  *"đây là 12 chỗ anh đã ghi lại để đưa em đi."* Không phải *"cài app này với anh đi"*.
- Nội dung lời mời lấy thẳng từ những gì người dùng đã tích luỹ ở chế độ một người.
  Càng dùng lâu, lời mời càng dày — đó là động cơ tự nhiên thay cho mọi thứ ép buộc.
- ⭐ **Người kia KHÔNG cần cài gì để xem lần đầu.** Họ mở được một trang, thấy một thứ
  cụ thể, rồi mới quyết định. Cần thiết kế trang này cho người chưa cài app.
- **Lời mời có hạn 48h** — tạo nhịp, tránh treo lơ lửng vô hạn.
- Có thể có biến thể mời kiểu rủ chơi game, nhẹ nhàng hơn.
- ⚠️ **Đường từ chối tử tế.** Nếu người kia không nhận lời, người dùng không được cảm
  thấy bị bỏ rơi hay bị app trừng phạt. Dữ liệu đã ghi **vẫn còn nguyên**.

**⭐ Bốn điều mới, và đây là phần dễ bị bỏ sót nhất của cả brief.**

Chúng ta đã thiết kế lời mời như một khoảnh khắc quà tặng đẹp. Đúng về cảm xúc, nhưng
bỏ qua một sự thật: **gửi lời mời cũng là một hành động chủ động, và người gửi phải
dũng cảm.** 83% nam và 76% nữ tự mô tả là lo lắng ở mức vừa-tới-rất khi hẹn hò; 44% nam
nói nỗi sợ **làm giảm khả năng họ chủ động liên lạc**. Nếu màn hình này chỉ đẹp mà không
hạ được chi phí tâm lý của việc bấm nút, nó sẽ không được bấm.

- **(a) Diễn thử trước khi gửi.** Người dùng xem **đúng** màn hình người kia sẽ thấy,
  trước khi gửi. Bất định là phần đắt nhất của nỗi sợ; cái này xoá nó gần như miễn phí.
- **(b) ⭐ Mời vào một HOẠT ĐỘNG, không mời vào một MỐI QUAN HỆ.** Mặc định của lời mời
  phải là *"đây là danh sách quán anh lưu, em chọn một chỗ đi"* — **không** phải *"vào
  app đôi với anh"*. Cái sau bắt người kia phải định nghĩa quan hệ ngay tại chỗ, đúng
  cái mà 4.1 đã cấm ta làm với người dùng thứ nhất. Đây cũng là biểu hiện trực tiếp của
  L1: sản phẩm làm việc trên hoạt động, không làm việc trên quan hệ.
- **(c) Mời từng phần.** Mời xem **một danh sách**, không phải mời xem cả app. Người gửi
  chọn cái gì lộ ra. Vừa hạ rủi ro tâm lý, vừa là một lớp bảo vệ riêng tư thật.
- **(d) ⭐ Rút lui im lặng.** Nếu không được trả lời, lời mời hết hạn **lặng lẽ**.
  **Không** báo "đã xem". **Không** đếm ngược 48h hiển thị cho người gửi nhìn. Người gửi
  không bao giờ được ngồi xem đồng hồ chạy trên sự im lặng của người kia. Cái này bảo vệ
  thể diện cho **cả hai** phía — bên gửi không bị làm nhục bởi sự im lặng, bên nhận không
  bị ép trả lời bằng áp lực thời gian.
- **(e) Gợi ý thời điểm.** App có thể gợi *khi nào* nên mời, dựa trên dữ liệu của **chính
  người dùng** (đã lưu 12 chỗ, đã ghi 3 lần gặp) — không bao giờ dựa trên gì về người kia.

### 4.3 Nghi thức đổi chế độ
Không phải một cái toggle trong settings. Là một chuyển tiếp có nghi thức: chương cũ
khép lại, chương mới mở ra. Cần thiết kế cả việc **những gì đã ghi ở chế độ một người
hiển thị ra sao** sau khi đổi.

**⭐ Và đây là chỗ có một điều quan trọng chưa ai nhìn ra cho tới gần đây: gánh nặng đổi
vai đúng ở khoảnh khắc này.**

- Ở chế độ một người, gánh nặng là **khởi xướng** — nghĩ ra làm gì, rủ thế nào, sợ bị
  từ chối. Thống kê thì gánh này nghiêng về phía nam.
- Ở chế độ hai người, gánh nặng đổi thành **duy trì** — nhớ, sắp xếp, tổ chức, giữ liên
  lạc với họ hàng hai bên. Nghiên cứu về "mental load" và "kin-keeping" cho thấy gánh này
  nghiêng nặng về phía nữ (một nghiên cứu 2025: các bà mẹ báo cáo nhiều hơn **67%** khối
  lượng quản lý gia đình).
- ⇒ **Nếu chế độ hai người cũng chỉ phục vụ người khởi xướng, thì người còn lại trở thành
  người vận hành app không công.** Đó là kết cục tệ nhất mà sản phẩm này có thể tạo ra,
  và nó sẽ xảy ra một cách rất tự nhiên nếu ta không cố tình chặn.
- ⇒ **Thiết kế cần:** ở khoảnh khắc đổi chế độ, app **chia lại việc** một cách rõ ràng và
  **mặc định**. Danh sách chung + mẫu hai chìa khoá (7.1) chính là công cụ: chúng làm cho
  việc lên kế hoạch trở nên **nhìn thấy được và chia được** thay vì vô hình và dồn vào một
  người. Hãy coi đây là **lời hứa giá trị của chế độ hai người dành cho người mang gánh
  duy trì**, và cho nó một màn hình, không phải một dòng chữ.

### 4.4 Mô hình chương
Một người chỉ có **một mối quan hệ tại một thời điểm**. Khi một chương khép lại (chia
tay, hoặc bị từ chối), toàn bộ chương đó **chuyển vào kho ký ức riêng** — không xoá,
không ép gộp — rồi mở chương mới. Đây cũng chính là lời giải cho việc bị từ chối ở
4.2: không có gì bị mất, chỉ được cất đi.

### 4.5 ⭐ Màn hình của NGƯỜI THỨ HAI — lỗ hổng lớn nhất hiện nay

Đọc kỹ mục này. Hiện tại **không có một màn hình nào trong toàn bộ sản phẩm phục vụ
người được mời.** Toàn bộ chế độ một người phục vụ người mời; toàn bộ chế độ hai người
giả định cả hai đã ở trong. Người thứ hai chỉ tồn tại như một sự kiện "đã đồng ý".

Lỗ này vô hình vì nó không thuộc chế độ một người, cũng không thuộc chế độ hai người —
nó nằm ở **đường nối**, và không ai sở hữu đường nối. Nhưng cả sản phẩm sống chết ở đó:
người thứ hai không đồng ý thì chế độ hai người không bao giờ tồn tại.

- **Đây là một artifact thiết kế có tên riêng**, không phải "màn hình đăng nhập", không
  phải "landing page". Đặt cho nó một cái tên và thiết kế nó như một màn hình hạng nhất.
- **Không cài app vẫn xem được** (đã chốt) ⇒ nó là **web**. Thiết kế responsive thật, mở
  từ link trong Zalo/Messenger, trên điện thoại, mạng chậm.
- ⭐ **Hành động trước, tài khoản sau.** Người thứ hai phải **làm được một việc có ý nghĩa
  trước khi tạo tài khoản** — ví dụ chọn một quán trong danh sách người kia gửi. Bắt đăng
  ký trước khi cho làm gì là cách chắc chắn nhất để mất họ.
- **60 giây đầu là toàn bộ thiết kế.** Họ cần hiểu ngay: đây là cái gì, ai gửi, tôi được
  gì, tôi phải làm gì. Không tour, không onboarding nhiều bước.
- **Không được ép định nghĩa quan hệ**, y hệt luật ở 4.1 — và ở đây còn gắt hơn, vì người
  thứ hai chưa có bất kỳ cam kết nào với sản phẩm.
- **Đường từ chối phải im lặng** (xem 4.2(d)). Người thứ hai phải có thể **không làm gì**
  mà không bị phạt, không bị nhắc lại, không bị báo cho người gửi.

---

## 5. Danh sách hoạt động — đối tượng xương sống

Đây là vật thể trung tâm của cả sản phẩm. Mọi thứ khác gắn vào nó.

**⭐ 5.0 — Danh sách phải đến KÈM NỘI DUNG, không phải đến như một cái hộp rỗng.**

Chế độ một người hiện có sáu tính năng, và **năm trong số đó bắt đầu bằng màn hình
rỗng**. Nghĩa là giá trị của sản phẩm ở ngày thứ nhất gần bằng không, và chỉ tăng dần
theo tích luỹ. Đó là một sản phẩm giữ chân tốt nhưng **không có gì để giữ chân ai cả**,
vì người dùng rời đi ở ngày một.

- **Danh sách hoạt động phải được giao kèm nội dung Việt Nam biên tập sẵn**: quán, chỗ
  đi, việc làm cùng nhau, theo thành phố. Xu hướng 2026 ở Việt Nam là **hẹn hò theo vận
  động** (pickleball, chạy bộ, gym) và hẹn hò offline đang hồi sinh — nội dung nên bám
  vào đó, không chỉ là "quán cà phê đẹp".
- **Người dùng CẮT BỚT, không phải NGHĨ RA.** Chọn lọc dễ hơn sáng tạo cả một bậc. Đây
  là thay đổi lớn về mặt thiết kế: màn hình đầu tiên là một **danh sách đã có sẵn đồ để
  vuốt bỏ**, không phải một nút "+" trên nền trắng.
- **Đưa đếm ngược dịp Việt (6.6) lên sớm.** Nó là tính năng **duy nhất** trong chế độ một
  người có giá trị ở giây thứ năm với không dữ liệu nào: *"còn 12 ngày nữa tới 20/10"*.

- **Danh sách "sẽ đi / sẽ xem".** Hôm nay những thứ này thất lạc trong lịch sử chat của
  người dùng. App là chỗ chúng có nhà.
- **Vòng đời xuyên chế độ:** danh sách của tôi → danh sách của chúng ta → kế hoạch được
  vận hành. Cùng một đối tượng, ba hình thái. Phải vẽ cả ba.
- **Gộp "hũ ước mơ" vào đây.** App đang có module `dream_jar` riêng; ước mơ chung thực
  chất là hoạt động ở thì tương lai xa. Một danh sách, nhiều tầm xa, không phải hai màn
  hình rời.
- ⭐ **Nhu cầu thật của người dùng chế độ một người không phải "hết ý tưởng đi chơi" mà
  là "mắc kẹt, không biết cách đẩy quan hệ tiến lên".** Lời giải là **một chuỗi hoạt
  động có tiến triển** — mỗi cái thân mật hơn cái trước một nấc — chứ không phải một rổ
  gợi ý ngẫu nhiên. Điều này ảnh hưởng trực tiếp tới cách sắp xếp và trình bày danh
  sách: nó cần có **hướng đi**, không chỉ là danh sách phẳng.
- **Sổ tay của chúng ta** — dạng xem tổng hợp mọi thứ đã ghi.
- **Gợi ý chỗ hẹn** ở chế độ một người: nội dung biên tập sẵn, không AI.
- ⚠️ Rủi ro định vị: nếu đóng khung thành "công cụ quản lý hẹn hò" thì hỏng. Khung
  đúng là **"lo liệu cho nhau"** — đừng hứa cảm xúc rồi giao ra một cái lịch.

### 5.1 Máy quyết định
Nỗi đau nền: không biết chọn gì, sợ chọn nhạt.
- **Hôm nay ăn gì / đi đâu** — máy quyết định nhanh.
- ⭐ **Cả hai chọn mù, trùng thì tự chốt.** Hợp nhất hai mẫu lõi ở mục 7: mỗi người
  chọn khi chưa thấy lựa chọn của người kia; trùng nhau thì hệ thống tự chốt luôn.
- **Thẻ thử thách hẹn hò** — gợi ý hoạt động dạng thẻ rút.

---

## 6. Các nhóm tính năng còn lại

### 6.1 Chuyến đi đầu tiên
Tính năng khác biệt nhất trong cả danh mục. 48 giờ đầu ở cạnh nhau, lần đầu tiêu tiền
chung — vừa là cột mốc lớn vừa là chỗ nhiều thứ dễ hỏng.
- **Chuyến cuối tuần từ Hà Nội / Sài Gòn** — tập địa điểm hữu hạn, làm nội dung sẵn được.
- **Chuẩn bị buổi hẹn** ở chế độ một người: checklist nhẹ, không phải quản lý dự án.
- ⚠️ **Chia tiền chuyến đi rất tế nhị ở chặng đầu.** Đừng thiết kế như app chia bill.
  Cần **chốt hoá đơn ngay tại chỗ, nhẹ tay** — một chạm, không truy vấn, không nhắc nợ.

### 6.2 Cùng xem gì / yêu xa
- **Xem phim đồng bộ khi yêu xa.**
- **Playlist / mixtape chung.**
- **Chế độ yêu xa** như một trạng thái của app.
- Bối cảnh VN: hẹn hò đô thị mặc định là **quán cà phê và rạp phim** — nội dung gợi ý
  nên bám thực tế đó.

### 6.3 Nhật ký riêng và kho ký ức riêng
Đọc kỹ luật L2 ở mục 8 **trước khi vẽ**. Đây là chỗ dễ thiết kế sai nhất.
- **Nhật ký cảm xúc riêng** ở chế độ một người.
- **Nhật ký lúc giận** ở chế độ hai người — bằng chứng rằng nhật ký riêng không chết
  khi có đôi, nó chỉ đổi vai.
- ⭐ **Kho kỷ niệm riêng vĩnh viễn:** ghi chú từ chế độ một người **không bị xoá, không
  bị ép gộp** vào dữ liệu chung, mở ra được bất kỳ lúc nào.
- **Khoá bằng sinh trắc học, mật khẩu chỉ là dự phòng. Cả hai tuỳ chọn, mặc định TẮT.**
- Kho riêng cũng phải **xoá được** (luật XD4: cái gì lưu được thì phải quên được).
- ⚠️ Nếu có mục "chỗ để hỏi lúc 2h sáng" thì phải thu hẹp về **hậu cần**, không được
  thành nơi xin lời khuyên về con người.

### 6.4 Cột mốc và lần đầu tiên
- **Ghi "lần đầu tiên" ngay từ chế độ một người** — lần đầu nhắn, lần đầu gặp, lần đầu
  đi ăn.
- **Bản đồ lần đầu tiên** — cột mốc theo không gian.
- **Hộp thư thời gian** — viết bây giờ, mở ở tương lai.
- **Tự động lo ngày quan trọng** — app nhớ giùm.
- **Quà và dịp.**
- **Đếm kỷ niệm theo tháng và mốc trăm ngày** — mật độ cột mốc của người Việt dày hơn
  phương Tây, đừng chỉ làm kỷ niệm năm.
- ⭐ **Cãi nhau lần đầu cũng là cột mốc, không phải thất bại.** Cách đóng khung việc này
  là một quyết định thiết kế thật.

### 6.5 Tìm hiểu nhau — hạt câu hỏi
- ⚠️ **"Thi thoảng chèn một câu hỏi", KHÔNG phải "bảng câu hỏi".** Là hạt nhỏ nằm trong
  luồng đang có, không phải một màn hình phải làm cho xong.
- ⚠️ **Tần suất là một phần của thiết kế.** Cùng một kho nội dung hữu hạn: hỏi mỗi ngày
  thì lộ lặp trong vài tuần, hỏi thi thoảng thì dùng được nhiều năm.
- Nội dung sinh từ **dữ liệu của chính người dùng** (danh sách hoạt động, nhật ký, cột
  mốc, ký ức) chứ không chỉ từ kho câu hỏi cố định.
- Bộ 36 câu hỏi Aron và bộ bài câu hỏi sống lại ở đây, nhưng **dưới dạng nguồn hạt
  giống**, không phải bộ đề bắt làm hết.
- Ở chế độ hai người, câu hỏi có thể học từ **chat chung trong app** — nhưng chỉ chat
  trong app, chỉ ở chế độ hai người, và chỉ khi cả hai cùng bật.
- ⚠️ Học ra *"hai đứa hay nhắc tới biển"* ✅ · học ra *"cô ấy hay buồn tối chủ nhật"* ❌

### 6.6 Bản địa hoá Việt Nam — con hào rẻ nhất
Đối thủ ngoại bỏ trống hoàn toàn ô này.
- ⭐ **Xưng hô anh/em và cách gọi riêng.** App phải học và dùng đúng. Xem câu hỏi mở ở
  mục 10 — đây là quyết định thiết kế chạm mọi chuỗi chữ trong app.
- **Lịch âm và dịp lễ Việt:** Tết, Trung thu, 8/3, 20/10, chuỗi ngày 14 hằng tháng.
- **Sống chung với bố mẹ** khiến khoảng-thời-gian-xa-nhau ở VN quan trọng hơn phương Tây.
- **Ra mắt gia đình** ở VN mang nghĩa rất nặng: "họ thấy tương lai với bạn, chấm hết".
  Nếu chạm vào, phải chạm với trọng lượng đúng.

### 6.7 Khoảng giữa — khi hai người không ở cạnh nhau
Chiếm ~90% quỹ thời gian của một mối quan hệ và hiện app đang trống hoàn toàn.
⚠️ **Cảnh báo bao trùm cả mục này: không được biến thành thêm một kênh chat.** App đã
có chat rồi.
- ⭐ **Cùng làm việc riêng trong một phiên chung** — hai người mở phiên, ai làm việc nấy,
  chỉ biết người kia đang ở đó. Ở bên nhau mà không tốn nội dung để nói.
- ⭐ **Hàng chờ "để gặp rồi kể"** — thấy gì hay thì cất vào đây thay vì nhắn ngay, để
  dành cho lúc gặp. Nối khoảng-giữa sang lúc-ở-cạnh-nhau.
- **"Đang nghĩ tới em" một chạm, không cần trả lời.**
- **Trạng thái nhẹ** — đang bận / đang rảnh / đang mệt. ⚠️ **Không phải vị trí.**
- **Nghi thức khép ngày** — 365 lần một năm, nên phải rất nhẹ.
- **Gói hàng chậm** — gửi một thứ có độ trễ cố ý, mở được sau vài ngày.
- **Đếm ngược gắn với một kế hoạch cụ thể** trong danh sách hoạt động, không phải đếm
  ngược suông.
- **Bản tin cuối tuần** tự sinh từ danh sách hoạt động.
- ⭐ **Thoả thuận kỳ vọng liên lạc.** Hai người cùng thống nhất "thế nào là bình thường"
  — bao lâu không nhắn thì không có nghĩa là có chuyện. Chốt bằng mẫu hai chìa khoá.
  Đây là bản thay thế có đạo đức cho ý tưởng hiển thị nhịp nhắn tin (đã bị loại).

### 6.7b ⭐ "Hôm nay đi nhẹ thôi" — thay cho việc theo dõi chu kỳ

Đây là bản dịch được phép của nhu cầu (1) ở 4.0b, và cần hiểu **vì sao nó tốt hơn**.

Cái người kia thực sự muốn **không phải là dữ liệu — mà là một lời cảnh báo để khỏi làm
hỏng việc**. Dữ liệu chỉ là phương tiện. Nếu app đưa thẳng lời cảnh báo, anh ấy nhận
**đúng** cái anh ấy cần, và app **không lưu một byte dữ liệu sức khoẻ nào**.

Thiết kế:
- **Cô ấy bật, không phải anh ấy tra.** Một chạm.
- **Là TRẠNG THÁI, không phải DỰ ĐOÁN.** "Hôm nay em không khoẻ / đang mệt / đi nhẹ
  thôi." Không nêu lý do, và app **không được hỏi** lý do.
- **Tự hết hạn.** Không lưu lịch sử.
- ⚠️ **Ràng cứng: không đếm, không chu kỳ hoá, không dự đoán lần sau.** Cái khoảnh khắc
  app gợi ý *"tháng trước cũng khoảng ngày này"* là lúc nó biến thành app theo dõi chu
  kỳ, và mọi lý do ở 4.0b(1) quay lại đủ.
- **Chỉ tồn tại ở chế độ hai người.** Ở chế độ một người nó không thể tồn tại — người
  kia chưa có tài khoản để mà tự bật.
- Dùng lại nguyên thuỷ "vibes"/"đang nghĩ tới em" đã có trong app.

### 6.7c ⭐⭐ App không chấm điểm anh ấy — app LÀM CHO anh ấy tâm lý hơn

Bản dịch được phép của nhu cầu (2) ở 4.0b. Đây có thể là ý tưởng quan trọng nhất trong
cả brief này, nên đọc chậm.

"Tâm lý" **không phải một đặc điểm để đo. Nó là một hành vi dạy được.**

- App **không thể** trao cho cô ấy tấm phiếu điểm về anh ấy — bị cấm, và nó sẽ đầu độc
  chính mối quan hệ mà sản phẩm định giúp.
- App **hoàn toàn có thể** trao cho cô ấy **kết quả**: nhắc anh ấy đúng lúc.
  *"Hôm nay 20/10."* · *"Hai tuần rồi hai bạn chưa đi đâu."* · *"Cô ấy nhắc tới quán này
  ba lần rồi."*
- **Cùng một nhu cầu. Một bên là phán xét, một bên là huấn luyện.** Luật L1 chặn đúng
  cái xấu và để nguyên cái tốt.

⭐ **Hệ quả về cấu trúc mà bạn cần giữ trong đầu suốt quá trình thiết kế:**
**người được rủ hưởng lợi từ những tính năng mà người rủ dùng.** Sản phẩm dành cho cô
ấy ở chế độ một người **không phải là một bộ màn hình riêng** — nó là **kết quả của việc
anh ấy dùng app tốt**. Điều này chỉ nhìn thấy được khi ta thôi hỏi "màn hình nào cho ai".

⚠️ **Và đây là lý do nó quan trọng:** nhu cầu của người rủ có hình dạng **hoạt động**
("làm gì tiếp theo") nên L1 phục vụ được trọn vẹn. Nhu cầu của người được rủ có hình
dạng **con người** ("người này có đáng không") nên L1 **cấm theo định nghĩa**. Nếu không
cố tình chặn, chế độ một người sẽ tự nhiên trở thành sản phẩm chỉ dành cho một phía —
không phải vì ai muốn thế, mà vì hình học của luật. 6.7c là cách chặn.

### 6.8 Khi hai người ở cạnh nhau — app tự câm
- ⭐ **App tự tắt thông báo khi hai máy ở gần nhau.**
- ⭐ **Chế độ để-điện-thoại-xuống.**
- Chống-phubbing là **định vị công khai** của sản phẩm, có meta-analysis 52 nghiên cứu /
  19.698 người chống lưng. Đây là điểm bán, nên nói ra.
- **Một chạm giữ chỗ khoảnh khắc, điền nội dung sau.**
- **Album tự mở tự đóng theo buổi hẹn.**

### 6.8b Đồng bộ giữa hai máy — phải là tính năng hạng nhất
⚠️ Nghe như việc kỹ thuật, nhưng **16% khiếu nại của cả ngành app cặp đôi đánh đúng vào
đây**, và nó đánh thẳng vào lõi sản phẩm: hai người nhìn hai màn hình khác nhau thì mọi
thứ ở mục 7.1 và 7.2 đều gãy. Cần thiết kế rõ: trạng thái đang đồng bộ · đã đồng bộ ·
mất mạng · và **xử lý khi hai người sửa cùng một thứ cùng lúc**. Đừng để nó thành một
cái spinner vô danh — người dùng phải luôn biết người kia đang thấy gì.


### 6.9 Ký ức tự viết
- ⭐ **Dòng thời gian tự viết** từ danh sách hoạt động + các khoảnh khắc đã giữ chỗ.
  Người dùng chỉ **xác nhận**, không phải ngồi nhập. App đã có module `timeline` nhưng
  đang trống.
- ⭐ **Sau buổi hẹn hỏi đúng một câu**, cả hai trả lời rồi cùng lật bài.
- ⭐ **Ký ức được phép mâu thuẫn** — hai người nhớ khác nhau thì **giữ cả hai bản**,
  không bắt thống nhất. Đây là một quyết định thiết kế đẹp và hiếm, đừng làm mất nó.
- **Ký ức nổi lên theo địa điểm**, không chỉ theo ngày.
- **Kho "chuyện của chúng ta"** — ưu tiên chữ, không phải ảnh.
- **Quyền xoá ký ức khi chia tay.**

### 6.10 Xung đột và sửa chữa
Đây là chỗ chữ "hữu ích" đậm nhất trong cả sản phẩm.
- ⭐⭐ **Nút "em đang giận, chưa nói chuyện được, nhưng anh đừng lo".** Giá trị cao nhất,
  chi phí thấp nhất trong toàn danh mục. Thiết kế then chốt là **đặt ở đâu để bấm được
  lúc đang bực, mà không mời gọi bấm lúc bình thường**.
- **Hẹn giờ nguội** — hoãn cuộc nói chuyện tới một mốc cụ thể, chốt bằng hai chìa khoá.
- **Sửa chữa sau xung đột kiểu Gottman** — ⚠️ **không phân xử ai đúng ai sai.**
- **Bộ sửa chữa cho xung đột đầu tiên.**

### 6.11 Người thứ ba
- **Trang chia sẻ cho người ngoài xem** mà không lộ gì riêng tư.
- **Hai chìa khoá để mời người thứ ba xem một phần.**
- **Ra mắt gia đình** (xem 6.6, rất nặng ở VN).

### 6.12 Đồ đã dựng dở trong app — cần nối dây
Chi phí thấp bất thường vì một nửa đã có sẵn.
- **Lời hứa (`vow`)**: đã có màn hình mobile, chưa có backend. Ứng viên hoàn hảo cho mẫu
  hai chìa khoá. Dùng làm mẫu tham chiếu tốt.
- **Quà bất ngờ**: trong dữ liệu đã có sẵn ô "món đang mong" nhưng chưa có luồng nào
  dùng. Chính là 7.3 dưới đây.
- **Hợp đồng tình yêu (`love_contracts`)**: nối lời hứa với hẹn giờ nguội.
- **Chống ghosting (`anti_ghosting`)**: đã độc đáo sẵn, chưa khai thác.
- ⚠️ **Thú cưng (Love Pet)** đang trôi nổi, chưa gắn vào gì. Nếu gắn thì chỉ được phản
  ánh **nhịp** — có đang cùng nhau làm gì không — **tuyệt đối không phản ánh điểm số**.
  ⭐ **Bản 4:** điều này đã **chuyển từ lời khuyên thành quyết định**. Pet hiện đang ship
  `độ vui` / `cấp độ` / `chuỗi ngày` / `điểm` / `%` — tức nó **đang vi phạm chính câu
  trên**. Xem §9 mục 2. Thiết kế lại pet quanh **trạng thái định tính**, không quanh
  thang đo tích luỹ.

---

## 7. Bốn mẫu dùng lại — thiết kế một lần, dùng khắp nơi

Phần đòn bẩy lớn nhất của cả dự án. Ba mẫu đầu đã tồn tại rải rác trong code (mẫu hai
chìa khoá đang chạy ở 6 module) nhưng **chưa từng được thiết kế thống nhất**.

**7.1 Hai chìa khoá.** Việc hệ trọng cần cả hai đồng ý: đổi theme, sửa lời nhắc, xoá kỷ
niệm, huỷ hẹn, lời hứa, thoả thuận liên lạc. Cần bộ trạng thái đầy đủ: đang chờ người
kia · đã đồng ý · bị từ chối · quá hạn. Kèm ba biến thể:
- **Không phản đối trong 24h** cho việc nhỏ (im lặng là đồng ý).
- **Nửa chìa khoá:** *"anh nghiêng về cái này"* — bày tỏ thiên hướng mà chưa cam kết.
- **Trao quyền thay vì xin phép:** *"để em chọn giúp anh"*.

**7.2 Lật bài.** Cả hai trả lời khi chưa thấy câu của nhau, xong mới cùng lộ. Trạng
thái: đã trả lời đang chờ · cả hai xong, lật.

**7.3 ⭐ Quà bất ngờ — mẫu duy nhất được phép PHÁ hai chìa khoá.** Một món quà mà phải
xin phép thì không còn là quà. Đây là ngoại lệ có chủ đích và cần được thiết kế như một
ngoại lệ rõ ràng, không phải một kẽ hở.

**7.4 Trạng thái rỗng — ⚠️ mục này đã ĐỔI, đọc lại.** Bản trước nói ngày đầu tiên
"không có gì cả" và trạng thái rỗng phải mời gọi ghi thêm. **Điều đó giờ là sai.** Theo
5.0, danh sách hoạt động **đến kèm nội dung sẵn**, nên màn hình đầu tiên không phải là
một trạng thái rỗng mà là một **danh sách để cắt tỉa**.

Trạng thái rỗng thật sự vẫn cần cho: nhật ký riêng, cột mốc, ký ức. Với những chỗ đó,
luật cũ vẫn đúng — **mời gọi mà không cằn nhằn**, không đếm, không nhắc nợ. Nhưng
**đừng thiết kế chế độ một người quanh trạng thái rỗng nữa**; hãy thiết kế nó quanh
việc chọn lọc.

---

## 8. Luật bất di bất dịch

**L1 — Làm việc trên HOẠT ĐỘNG, không làm việc trên CON NGƯỜI.**
App gợi ý *"cuối tuần đi đâu"*, không bao giờ nói *"cô ấy có vẻ đang giận"*. Ba hướng:
ra ngoài (hoạt động) ✅ · vào chính mình (nhật ký) ✅ · **vào người kia ❌**.
Phép thử: nếu người yêu cầm máy lên xem, mọi thứ trên màn hình phải bình thường, vô hại.

**L2 — Nhật ký riêng: không giấu cánh cửa, bỏ ổ khoá.** Luật phản trực giác nhất:
- Khu riêng **hiện diện công khai và đối xứng** — ai cũng có, không giấu. (Phát hiện ra
  một căn phòng **bí mật** tệ hơn nhiều so với phát hiện một căn phòng **khoá**: khoá là
  ranh giới, bí mật là lừa dối. Và hai người dùng chung một bản app, nên thứ gì ẩn cũng
  sẽ bị phát hiện.)
- Cái vô hình là **nội dung** — và **cả việc bên trong có gì hay không**.
- ⚠️ **Không bao giờ hiển thị số lượng mục chưa chia sẻ.** Không badge, không "3 mục
  riêng", không thanh "đã chia sẻ 4/10". **Chia sẻ là cộng thêm, và mờ đục về phần
  còn lại.**
- Không có đường nào — kể cả mật khẩu — để tài khoản này xem của tài khoản kia.
- **Danh sách rò rỉ phải rà khi thiết kế:** thông báo · trạng thái nhẹ · dòng thời gian
  · huy hiệu đếm · tìm kiếm · bản kết xuất dữ liệu · sao lưu · và mọi chỗ vô tình để lộ
  số lượng thứ không chia sẻ.

Lý do: nếu có ổ khoá nhìn thấy được thì một người bạn đời kiểm soát sẽ đòi chìa. Khi sản
phẩm **không có khả năng đó**, câu trả lời trở thành *"app không có chức năng đó"* —
**sản phẩm chịu trách nhiệm thay người dùng.**

**L3 — Không khoá tính năng để ép mời.** Không có "mời người yêu để mở khoá". Đó là mẫu
tăng trưởng quen thuộc và nó phá thẳng yêu cầu ở mục 4.1. Người kia tham gia vì lời mời
đẹp, không vì bị chặn đường. Cùng lý do: **không đặt paywall lên lõi**.

**L4 — Không trưng AI ra.** Không bong bóng chat trợ lý, không icon lấp lánh, không
"hỏi AI". Gợi ý là nội dung biên tập sẵn. Chỉ 19% người dùng còn hào hứng với AI năm
2026, giảm từ 50% hai năm trước.

**L5 — Thỉnh thoảng, không hằng ngày.** Nhắc quá dày sẽ cạn nội dung và biến thành
nghĩa vụ.

**L6 — Đôi khi việc của app là biến mất.** Có tính năng mà thành công nghĩa là người
dùng **không nhìn màn hình**. Đừng thiết kế chúng như tính năng cần tương tác.

**L7 — Xưng hô anh/em**, không phải "bạn" / "đối tác".

**L8 — Không so sánh hai người với nhau.** Không đối chiếu ai làm nhiều hơn.

**L9 — Không báo cáo hành vi người này cho người kia.**

**L10 — Không streak, không chuỗi ngày liên tiếp.** Biến tình cảm thành điểm danh là
hỏng. (Cũng vì thế mà mô hình học theo cấp độ kiểu Duolingo đã bị loại.)

**L11 — Cái gì lưu được thì phải quên được.** Mọi thứ ghi lại đều phải xoá được.

**L12 — Không bảng xếp hạng xã hội.** Không so với cặp khác.

**L13 — Cùng thắng hoặc cùng thua, không bao giờ đấu nhau.** Không có tính năng nào đặt
hai người ở hai phía.

**L14 — ⭐ VIẾT LẠI Ở BẢN 4. Cấm mọi cơ chế làm tăng thời gian trong app vì chính thời
gian đó** — streak, điểm chuyên cần, combo, huy hiệu đếm, thông báo mồi. App giữ chân
bằng **giá trị của việc đã làm xong**, không bằng **nghĩa vụ quay lại**.

Vì sao đổi: bản 3 viết L14 ở dạng **khẳng định** (*app nên gợi "kể với một người bạn
đi"*). Khi lập bản đồ toàn bộ màn hình, **luật đó không đáp xuống bề mặt nào** — và một
luật không có bề mặt là trang trí. Tệ hơn: bản khẳng định khiến app **khuyên về đời sống
xã hội của người dùng**, tức lại đi làm việc trên **con người**, mấp mé đúng thứ L1 cấm.
Dạng **phủ định** thì cưỡng chế được, không tốn màn hình nào, và bao trọn cả L10.

Nền của luật vẫn nguyên: hệ thống hỗ trợ tinh thần của nam giới **xoay quanh quan hệ
tình cảm**, ít bộc lộ ra ngoài, và khi chia tay thì mạng lưới co lại. App không được trở
thành ống xả duy nhất của ai cả. Song sinh với L1: **L1 cấm app phán xét người kia; L14
cấm app biến việc yêu nhau thành điểm danh.**

⚠️ Ghi trung thực để bạn biết mình đang cầm cái gì: đây là luật **chống lại chỉ số tương
tác**. Nếu sau này có áp lực tăng trưởng, đây là luật bị đem ra xin nới **đầu tiên**.

**L15 — ⭐ Giới tính chỉ dùng cho ngôn ngữ, không bao giờ để rẽ nhánh tính năng.**
Xem 4.0. Hệ quả an toàn quan trọng: **không được làm "chế độ an toàn dành cho nữ"**. Một
chế độ gắn với giới sẽ báo cho kẻ có ý kiểm soát biết **ai đang có gì để giấu**. Đối xứng
tuyệt đối cho cả hai phía chính là câu trả lời an toàn.

**L17 — ⭐ Mọi thông tin về người kia chỉ được đến từ CHÍNH NGƯỜI ĐÓ, hoặc từ chính tay
người dùng ghi. App không bao giờ là nguồn.** Có đúng ba nguồn thông tin về người kia:
app tự suy đoán (**cấm**) · người dùng tự quan sát và ghi (**được**, đó là nhật ký) ·
**người kia tự nói về chính mình** (**được**, và ta gần như chưa dùng tới). Luật này là
dạng kiểm tra được của L1: nó biến "không phân tích con người" thành một câu hỏi rất cụ
thể mà bất kỳ ai cũng trả lời được khi nhìn một màn hình — *thông tin này ai đưa vào?*
**Tự khai không phải là giám sát; nó là điều ngược lại.**

**L18 — ⭐ MỚI. Chủ thể khẳng định quyết định tính hợp lệ, không phải chủ đề.**
App được **NÊU** một chủ đề về hai người; app **không được KẾT LUẬN** về họ. Cùng một nội
dung, đổi từ **kết luận** sang **câu hỏi**, thì người khẳng định chuyển từ app sang người
dùng — và nó từ chỗ bị cấm thành hợp lệ, **thành một trò chơi**.

Dạng kiểm tra được: **không màn hình nào được hiển thị một con số nói về hai người.**
Cấm mọi thang `điểm`, `chỉ số`, `%`, `độ hợp`, `cấp độ`. Nếu bạn đang vẽ một thanh tiến
trình hay một vòng tròn phần trăm mô tả *mối quan hệ*, bạn đang vẽ thứ bị cấm.

*Ví dụ có thật, không phải giả định:* app hôm nay đang ship một màn hình **chấm điểm độ
xung khắc giữa hai người theo chiêm tinh**, có số và có thanh lấp đầy. Nó đã được quyết
là phải **đổi vai** — xem §9.

**L19 — ⭐ MỚI. Vai xác định bởi CẤU TRÚC, không bởi câu hỏi.**
Vai (*đang rủ* / *đang được rủ*) **không hỏi người dùng và không suy từ hành vi**. Nó
đọc từ phễu: **người tạo lời mời = đang rủ**, **người mở lời mời = đang được rủ**. Không
xác định được thì dùng **bản trung tính** — **đừng đoán**. Điều này xoá câu hỏi số 6 ở
§10 bản 3.

**L16 — Ngày một phải có giá trị.** Sản phẩm phải dùng được và đáng dùng ngay cả khi
người dùng chưa nhập gì. Xem 5.0. Đây là luật mới và nó phủ định một phần cách chế độ
một người đang được hình dung.

---

## 9. Đã loại — đừng thiết kế lại

Kịch bản thao túng, chấm điểm cơ hội, phân tích tin nhắn của người kia, theo dõi mạng xã
hội, A/B test lời nhắn · đấu trường "ai hiểu ai hơn" · hiển thị nhịp nhắn tin không đối
xứng · học theo cấp độ kiểu Duolingo · streak của nghi thức · giám sát, bảng điểm việc
nhà, kho bằng chứng · đồng bộ chu kỳ và sức khoẻ · chế độ chăm sóc · tính năng ẩn giấu
(xem L2).

⭐ **Hai mục thêm ở bản 4 — và điểm chung của chúng đáng chú ý: cả hai ĐANG CHẠY TRONG
APP.** Luật của dự án này chưa bao giờ được đối chiếu với tập tính năng đang chạy, cho
tới khi có người mở mã nguồn ra xem.

1. **Chấm điểm độ xung khắc theo chiêm tinh** — màn hình `zodiac` hiện có một chỉ số
   xung khắc dạng **số + thanh lấp đầy** cho hai người, kèm ba lời khuyên trong ngày.
   Đó là L18 tầng cấm. **Quyết định: đổi vai, không xoá.** Chiêm tinh chuyển từ *chấm
   điểm cặp đôi* sang **mồi chuyện**: bỏ con số, ba lời khuyên đổi thành **ba câu hỏi**,
   và câu hỏi trong ngày chảy thẳng vào mẫu **lật bài (7.2)**. Cả tên màn hình lẫn tên
   endpoint đều đang mang chữ *"red flag"* và **phải đổi** — tên gọi chính là khái niệm
   bị cấm, để nguyên thì sáu tháng nữa sẽ có người đọc lại luật sai.
   *Cái được:* đây là **máy sinh câu hỏi hằng ngày duy nhất** mà sản phẩm có, và nó
   không bao giờ cạn — thứ mà mọi app cùng loại đều chết vì thiếu.
2. **Bảng điểm của thú cưng** — pet hiện có `độ vui`, `cấp độ`, `chuỗi ngày`, `điểm`,
   `%`. **Quyết định: pet phản ánh NHỊP, không phản ánh ĐIỂM.** Bỏ cấp độ / điểm / phần
   trăm / chuỗi ngày; giữ **tâm trạng** như một trạng thái **định tính** phái sinh từ
   việc hai người có đang cùng làm gì không. (Chuỗi ngày thì L14 đã cấm sẵn.)

**Về đồng bộ chu kỳ:** vẫn loại, **kể cả ở chế độ hai người**. Lý do đúng nằm ở §4.0b(1)
bản 4 — không phải "bất khả thi về cấu trúc".

**Ngoài phạm vi phase này:** chế độ sống chung / cưới / có con · đặt vé và bán hàng ·
sách in cuối năm · hai cặp đi chơi chung · sổ nhớ bạn bè của người kia · chụp chung
hai máy hai góc nhìn · nối giá emoji vào ví hearts (thuộc một idea khác đang đỗ).

---

## 10. Câu hỏi cần bạn quyết hoặc nêu lại

1. 🟡 **MỘT NỬA ĐÃ TRẢ LỜI — Xưng hô.** Đã chốt dùng **anh/em**, và đã đo được: app
   **chưa có trường giới tính nào cả** (không backend, không mobile), nên phải hỏi
   một câu ở onboarding — không có đường tránh. **Vẫn cần bạn:** cặp đồng giới, và cặp
   không muốn dùng anh/em. Câu này chạm **mọi chuỗi chữ** nên càng quyết muộn càng đắt.
2. ✅ **ĐÃ TRẢ LỜI — dùng lại thanh tab hiện có.** App đã có sẵn cơ chế **tab xuất hiện
   / biến mất theo điều kiện** (tab Trò chuyện hôm nay đã làm đúng vậy). Chế độ một
   người hiện **3 tab**, chế độ hai người hiện **5 tab**. Không cần vỏ điều hướng thứ
   hai. Chi tiết: `screen-map.md` §1.
3. Nút "em đang giận" đặt ở đâu để bấm được lúc đang bực mà không mời gọi lúc bình thường?
4. 🟡 **Web** — đã chốt hướng (người thứ hai phải **làm được một việc trước khi tạo tài
   khoản**). Stack và đường deep-link là việc kỹ thuật. **Vẫn cần bạn:** nó trông thế nào.
5. Ở chế độ hai người, nhật ký riêng nằm ở đâu trong điều hướng để vừa **công khai, đối
   xứng** vừa không mời gọi tò mò?
6. ✅ **ĐÃ TRẢ LỜI — không hỏi, cũng không suy. Xem L19.** Vai đọc từ **cấu trúc lời
   mời**: người tạo lời mời đang rủ, người mở lời mời đang được rủ. Không xác định được
   thì dùng **bản trung tính**. Bạn **không** cần vẽ phương án hỏi hay phương án suy —
   nhưng **cần vẽ bản trung tính**, vì nó là trạng thái thật sẽ xảy ra.
7. ⚠️ **VẪN CHƯA GIẢI ĐƯỢC — mâu thuẫn:** 4.2(b) cố tình **hạ** lời mời xuống thành một lời rủ nhẹ
   (*"chọn một quán đi"*), trong khi 4.2 vẫn muốn nó là **khoảnh khắc cảm xúc lớn nhất**
   của sản phẩm. Hai điều này kéo ngược nhau. Có thể lời mời nhẹ đi nhưng *cái được mời
   vào* vẫn nặng — nhưng đó là giả thuyết, chưa ai chứng minh. **Đây là câu hỏi thiết kế
   thật sự thú vị của brief này**, và chúng tôi muốn nghe phương án của bạn.
8. ✅ **ĐÃ TRẢ LỜI — hai thứ, hai phía.** Một bề mặt cho **người gửi** (4.2, chỗ hôm nay
   chỉ là màn hình chờ) và một cho **người nhận** (4.5, bản web). Xem `screen-map.md`
   S-07 và S-08.
9. ⚠️ **VẪN CHƯA AI GIẢI ĐƯỢC** — và bản 4 vẫn không giải được. Nhật ký là của người dùng, nên về nguyên tắc họ
   được đọc lại. Nhưng nếu app hiển thị *"ba tuần qua bạn đã ghi 4 lần 'anh ấy quên'"*
   thì đó là **tự soi**, hay là **app đang dựng hồ sơ buộc tội người kia**? Khoảng cách
   giữa hai thứ đó chỉ là một dòng chữ trên giao diện. ⚠️ **Bản 4 lấy mất một lối thoát:**
   bản 3 gợi ý dùng L14 để trả lời (*app nói "kể với một người bạn đi"*), nhưng L14 giờ
   là **luật phủ định** nên **không còn đưa ra lối thoát đó nữa**. Câu hỏi này giờ trần
   trụi hơn trước. Nếu bạn có cách vẽ ranh giới này, chúng tôi rất muốn nghe.

---

## 11. Trước khi vẽ

App đã chạy và **đã có design system riêng** (bộ token màu, sprite thú cưng, các màn
hình cặp đôi hiện hành). **Audit cái đang có trước** — phần lớn việc là mở rộng ngôn ngữ
thiết kế sẵn có sang chế độ một người, không phải làm lại từ đầu.

## 12. Cần giao

**Danh sách màn hình chính thức là `screen-map.md` §2 (S-01..S-21) — làm việc theo tệp
đó, không theo trí nhớ về mục 4/5/6 ở đây.** Mỗi màn hình vẽ ở **cả hai chế độ**, kèm
đường biến hình giữa chúng. Cộng bốn mẫu dùng lại ở mục 7 và bộ trạng thái rỗng đầy đủ.

⭐ **Sáu màn hình MỚI hoàn toàn** (mọi thứ khác là sửa hoặc nối dây cho cái đang có):
chọn chế độ · Nhà hình thái một người · danh sách hoạt động · một hoạt động · khu riêng ·
máy quyết định. Xem `screen-map.md` §3 để biết từng cái phục vụ gì.

⭐ **Ba việc giá trị cao nhất lại là SỬA màn hình đã có, không phải vẽ mới** — đừng ưu
tiên theo độ "mới": (a) màn hình chờ sau khi gửi lời mời, hôm nay là một cái spinner
trong khi đó là **khoảnh khắc cảm xúc lớn nhất của sản phẩm** · (b) màn hình người thứ
hai, hôm nay **hỏi mã trước rồi mới cho xem nội dung — ngược** · (c) dời nghi thức lời
hứa xuống đúng lúc chuyển chế độ, thay vì bắt hứa ngay giây sau khi quét mã.

Bốn thứ dưới đây mới được thêm và **không được coi là phụ**:
1. **Màn hình người thứ hai (4.5)** — bản web, cho người chưa cài app, gồm cả bước "làm
   được một việc trước khi có tài khoản".
2. **Bộ màn hình gửi lời mời (4.2)** — gồm diễn thử, mời từng phần, và trạng thái hết hạn
   im lặng.
3. **Màn hình chia lại việc lúc đổi chế độ (4.3)**.
4. **Màn hình đầu tiên của chế độ một người theo hướng "cắt tỉa danh sách có sẵn" (5.0)**
   — thay cho hướng trạng thái rỗng ở bản brief trước.
5. **6.7b** trạng thái "hôm nay đi nhẹ thôi" — gồm cả cách nó **biến mất**.
6. **6.7c** hệ thống nhắc khiến người rủ trở nên tâm lý hơn — đây là sản phẩm gián tiếp
   dành cho người được rủ, hãy thiết kế nó với ý thức đó.
