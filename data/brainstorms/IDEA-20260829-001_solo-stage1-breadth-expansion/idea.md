# Idea Master: IDEA-20260829-001 Solo Stage-1 Breadth Expansion
Lifecycle: ACTIVE
Development Status: IN_PROGRESS
Source: user
Created: 2026-08-29
Last Updated: 2026-09-03 (vòng 10)
Linked Requirement: N/A — user tuyên bố sẽ BỎ và TẠO LẠI REQ-013 (vòng 8)

## Seed

Original idea (user, 2026-08-29):

> "Chế độ 1 người (chặng 1) của app đang khá 'mờ nhạt', hãy phát triển chặng
> này theo chiều rộng (nghiên cứu mở rộng tính năng)."

## Quan hệ với REQ-013 và IDEA-20260828-002

- Chặng 1 được định nghĩa lần đầu trong `IDEA-20260828-002_couple-feature-expansion`
  và đã bàn giao thành `data/requirements/REQ-013_solo_dating_assistant_stage1`
  (Status: PENDING, chưa breakdown).
- Ý tưởng này KHÔNG thay thế REQ-013. Nó là một vòng brainstorm mở rộng theo
  chiều rộng cho cùng một chặng, chạy trước khi Product Owner khoá story list.
- Mọi ứng viên ở đây phải sống chung với `## Invariant Design Rules` của REQ-013
  (R-1, XD4, khung "chăm sóc nhau", không paywall lõi, không AI ở REQ-013,
  nhật ký riêng-tư-mặc-định). Các luật đó là ràng buộc, không phải thứ đem ra
  brainstorm lại.

## Quyết định đã chốt (2026-08-29, user)

- **D-1 — chặng 1 KHÔNG phục vụ nhóm "chưa có ai".** App phải mang hơi hướng
  cupid: người dùng **đã có một "mối" cụ thể**, chỉ là đối phương chưa cài app.
  Hệ quả: SB-09 bị loại, SB-53 bị PARKED. Hệ quả lớn hơn: chặng 1 **luôn có một
  người thứ hai có thật ở ngoài đời** — đây là chìa khoá giải bài toán giữ chân.
- **D-2 — nhập kết quả ý tưởng này vào `REQ-013`**, không tách requirement mới.
  REQ-013 đang `PENDING` và chưa breakdown nên vẫn kịp sửa `req_master.md`.
- **D-3 — OQ-2 (một "ngăn" hay nhiều "ngăn") chưa chốt.** Đã diễn giải lại bằng
  ngôn ngữ thường trong `development.md` mục `### 2026-08-29 (vòng 2) · Q`.
- **D-4 — nội dung đi đường PRESET + MAD-LIBS + KHUNG NHẠI** (chốt OQ-9). Lý do
  user nêu: AI có thể dùng **sau này, bên ngoài hệ thống**, để sinh ra các preset
  nếu cần. Phân biệt kiến trúc: **AI là công cụ ở khâu SOẠN nội dung, không phải
  phụ thuộc ở khâu CHẠY sản phẩm.** Nhờ vậy `Invariant Design Rule` số 5 của
  REQ-013 ("không AI ở bất kỳ đâu") vẫn đúng nguyên vẹn, D-2 không bị phá, và
  blocker hội tụ được gỡ.
- **D-5 — lời mời là một TÍNH NĂNG, không phải câu tiêu đề** (chốt OQ-10). Định
  vị chặng 1 giữ nguyên "trợ lý hoạt động / chăm sóc nhau". SB-120 bị loại với
  tư cách định vị; cơ chế của nó (SB-101..SB-119) sống tiếp ở tầng tính năng.
  Ghi nhận: D-5 giữ cho sản phẩm qua được **cổng cứng của chính REQ-013** ("chặng
  1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia không?").

- **D-6 — R-1b được duyệt** (chốt OQ-6): cấm đo lường hành vi người kia trên
  link. Không "đã xem", không giờ mở, không đếm lần mở. Chỉ *đã trả lời / chưa
  trả lời*.
- **D-7 — R-1c và R-1d được duyệt** (chốt OQ-11): lời mời luôn có cửa từ chối
  sạch (một chạm, không né, không trêu, app không kịch tính hoá lời từ chối);
  nội dung preset chỉ được đùa về **người gửi**.
- **D-8 — chặng 1.5 thuộc REQ-014** (chốt OQ-8). REQ-013 giữ móc SB-125 (payload
  render được) để sau này không phải thiết kế lại.
- **D-9 — user quyết định MỞ R-1** (trả lời OQ-12). ⚠️ **Chưa có hiệu lực.**
  R-1 nằm trong `REQ-013 ## Invariant Design Rules`; brainstormer không sửa
  được. D-9 là **chỉ thị chờ `scrum-master`/Product Owner thi hành**. Cho tới
  lúc đó, `req_master.md` vẫn nói ngược lại và không được đem D-9 đi làm story.
- **D-10 — `R-1e` (luật ba tầng GHI/ĐOÁN/SUY-CHẤM) và `R-1f` (sổ tay chỉ ghi sở
  thích và sự kiện, không xuất chia sẻ) được duyệt** (chốt OQ-13).
- **D-11 — quà chỉ là Ý TƯỞNG, không thương mại** (chốt OQ-15), **và mở nhánh
  quà handmade dùng đúng chuyên môn của người dùng** thay vì đi mua.
- **D-12 — mở R-1 ở NẤC 3** (chốt OQ-16): mở (a) suy luận tính cách trên dữ liệu
  người dùng tự nhập + (d) chỉ số ăn khớp. Giữ nguyên lệnh cấm (b) đọc tin
  nhắn/theo dõi MXH, (c) so sánh và báo cáo hành vi, (e) kịch bản thao túng và
  A/B test lời nhắn, (f) streak và bảng xếp hạng. **Nấc 4 không bao giờ.**
- **D-13 — mồi chuyện làm bản A + bản A+** (chốt OQ-14): kho câu thường xanh
  cộng **"sự kiện có lịch"**. Feed tin thật (bản B) để REQ-014 đánh giá lại.
- **D-14 — chỉ số ăn khớp hiển thị DẢI, không hiển thị %** (chốt OQ-17).


## Current Business Framing

**Chặng 1 là một trợ lý hoạt động cho một người đang chăm sóc một mối quan hệ
có thật, mà đối phương chưa cài app.** Nó phải dùng được trọn vẹn một mình.

Chẩn đoán "mờ nhạt" sau 4 vòng: không phải thiếu tính năng, mà là (a) **10/13
journey trống**, và (b) **thẻ hoạt động hiện chỉ là một dòng chữ chết**, không
phải một đối tượng có vòng đời — nên không bao giờ có cảm giác "đã xong việc gì".

Bốn nước đi chốt lại:

1. **Thẻ hoạt động là đối tượng có cấu trúc (SB-76)** — giá VNĐ, thời lượng,
   khung giờ, mùa, số người, cần đặt trước, khoảng cách. Đây là nền móng duy
   nhất; thiếu nó thì bộ lọc ngữ cảnh, dải giá và khung mời đều không làm được.
2. **Vòng đời thẻ thay cho streak (SB-77/78)**: ý tưởng → đã lên lịch → đã làm →
   kỷ niệm. Đây là cách hợp lệ để có "kết quả nhìn thấy được" mà không phạm R-1.
3. **Lời mời là một cách XUẤT của thẻ (SB-124)**, dựng bằng **khung nhại** đời
   thường tiếng Việt — hài từ ĐỊNH DẠNG, không từ CÂU CHỮ (SB-103) — cộng ô
   mad-libs do người dùng tự điền. Cơ chế: **vỏ hài hạ rủi ro bị từ chối, ruột
   rõ hạ ma sát trả lời** (SB-102).
4. **Lịch âm × thư viện khung (SB-115)** là nguồn cấp dịp, lấp khoảng lặng giữa
   các buổi hẹn — phần trước đây hoàn toàn trống.

**Ranh giới scope:** chặng 1.5 (link hai chiều để người kia trả lời mà không cần
cài app) là **đề xuất REQ-014**, không phải REQ-013. Nhưng REQ-013 phải để lại
một móc: vật phẩm lời mời thiết kế thành **payload render được (SB-125)**, để
sau này render ra trang link mà không phải thiết kế lại.

**Trung thực về tần suất:** đây là tính năng ý định cao / tần suất thấp (1-2 lời
mời một tuần). Chặng 1 nên tối ưu **"được nhớ tới đúng lúc cần"**, không tối ưu
DAU.

**Rủi ro số 1: sượng.** D-4 hạ rủi ro sản lượng nội dung (AI ngoài hệ thống lo
phần viết), nhưng nút thắt chuyển sang **gu người duyệt** — cần kiểm duyệt hai
lớp (SB-123).

## Cập nhật vòng 5 — vì sao chặng 1 vẫn "chưa hữu dụng"

Chẩn đoán: **app không biết gì về mối quan hệ CỤ THỂ này**, nên mọi gợi ý đều
chung chung. Bốn vòng trước làm ra một **công cụ**; thứ đang thiếu là một **người
bạn đồng hành**.

**Lời giải hợp lệ: người dùng tự kể, app không suy đoán.**

- **Luật ba tầng (SB-126, đề xuất `R-1e`)** — người dùng **GHI** (hợp lệ) ·
  người dùng **ĐOÁN**, app không xác nhận (hợp lệ) · app **SUY LUẬN / CHẤM
  ĐIỂM** về người kia (**cấm**, đã loại ở cycle 4 và cycle 5).
- **Sổ tay mối quan hệ (SB-129)** — lớp dữ liệu còn thiếu. Riêng tư, xoá được,
  chỉ ghi **sở thích và sự kiện**, không ghi **đánh giá con người** (`R-1f`).
  Nó là đầu vào chung của gợi ý quà, mồi chuyện và kịch bản buổi hẹn.
- **Hoàng đạo / trắc nghiệm là LỚP VỎ, không phải phán quyết (SB-136)** — cùng
  kiến trúc với "hài từ ĐỊNH DẠNG". Mọi đầu ra kết thúc bằng một **hành động**,
  không bằng một **nhận định**. Nhãn do người dùng **tự khai**.
- **Bỏ người thắng (SB-145)** — trò "ai hiểu ai hơn" chết ở cycle 5 vì *dạng đấu
  nhau*. Bản hợp lệ không có điểm, đầu ra là *"3 chỗ hai người nghĩ khác nhau"*.
- **Thứ tự không thương lượng (SB-174)**: sổ tay → làm cho quà/mồi chuyện/kịch
  bản hết chung chung → **rồi mới** phủ vỏ hoàng đạo và trắc nghiệm. Làm ngược
  lại sẽ ra một app bói toán có kèm to-do list.

**Ranh giới giữ nguyên:** ý tưởng quà CÓ, thương mại/affiliate KHÔNG
(`## Out of Scope`); feed tin thật cần hạ tầng → đề xuất REQ-014.

## Cập nhật vòng 6 — mở R-1 cho đúng chỗ

**Giới hạn quyền, nói trước.** R-1 là luật cấp requirement. Tôi soạn được đề
xuất, không sửa được luật. Mọi nội dung dưới đây là **đề xuất**.

**R-1 không phải một luật — nó là sáu.** Tách ra: (a) suy luận tính cách từ dữ
liệu user nhập · (b) đọc tin nhắn/theo dõi MXH · (c) so sánh và báo cáo hành vi
· (d) chấm điểm ăn khớp · (e) kịch bản thao túng và A/B test lời nhắn · (f)
streak/bảng xếp hạng. **User đòi (a) và (d); chưa bao giờ đòi (b), (c), (e),
(f).** Đề xuất: mở đúng (a) + (d), giữ nguyên bốn cái còn lại — **nấc 3** trong
thang 5 nấc (SB-176). **Nấc 4 không khuyến nghị dưới bất kỳ hình thức nào.**

**Cơ chế hại đọc lại cho chính xác.** Nghiên cứu nền của R-1 (Stanford, đăng
*Science*) cho thấy nội dung hợp thức hoá làm người ta **tin mình đúng hơn, ít
cân nhắc góc nhìn người kia hơn, ít xin lỗi hơn** — chỉ sau **một** lần tương
tác. Vậy hại nằm ở chỗ **app làm người dùng chắc chắn hơn và tò mò ít đi**,
không nằm ở chỗ app nói về người kia. Cơ chế hẹp thì chặn được bằng thiết kế:

> **`R-1g` — mọi nội dung nói về người kia phải kết thúc bằng MỘT CÂU ĐỂ HỎI
> NGƯỜI THẬT, không được kết thúc bằng một kết luận.**
> Bài kiểm tra: *"đọc xong, người dùng muốn hỏi người kia nhiều hơn hay ít hơn?"*

**Luật 5 không cần sửa.** Chỉ số ăn khớp làm bằng **bảng tra tay** — 12×12 = 144
ô hoàng đạo, 16×16 = 256 ô MBTI — soạn ngoài hệ thống theo D-4, ship như gói dữ
liệu. Runtime tất định, không có AI. **Chính lựa chọn preset ở vòng 4 làm cho
việc mở R-1 ở vòng 6 an toàn hơn**: bảng tra tĩnh không nịnh được, vì nó không
biết người dùng muốn nghe gì. Đổi lại, luật nội dung bắt buộc: **mỗi ô phải có
ít nhất một điểm cọ xát**, không chỉ lời khen.

**Chân dung chặng 1 là chân dung tưởng tượng** — chỉ có một người trong app.
Ghi xuất xứ *"dựa trên những gì BẠN nhập"* trong bố cục, không phải chú thích
nhỏ. Và biến điểm yếu thành cầu: **khi người kia vào app, đối chiếu xem bạn
đoán đúng mấy phần** — đây là phần thưởng chuyển chặng mạnh nhất sinh ra trong
cả 6 vòng.

**Quà: thang CÔNG SỨC thay thang GIÁ TIỀN.** Chỉ mục quà theo **số giờ**, không
theo VNĐ. Hồ sơ kỹ năng ("phiên bản tôi") nâng lên **hạ tầng**, làm đầu vào cho
ma trận **kỹ năng × sổ tay** → ý tưởng quà cụ thể mà không cần trí tuệ gì cả.
Nghiên cứu ủng hộ thẳng: người nhận đánh giá quà tự làm **ý nghĩa hơn quà mua,
kể cả khi kém tinh xảo hơn**. Rủi ro triển khai lớn nhất: hỏi kỹ năng kiểu CV
thì 80% người dùng trả lời "không có" và cả nhánh này sập — **"nhớ dai", "biết
chỗ ăn ngon" cũng phải tính là kỹ năng.**

**Ba xung đột phải xử trước khi làm story:**
1. D-9 vs D-10 — `R-1e` cấm tầng 3, D-9 mở tầng 3. Hoà giải: mở **chỉ trên dữ
   liệu người dùng tự nhập**.
2. D-9 vs `R-1b` — chân dung dựng từ việc user gõ lại hành vi người kia là
   **đo bằng tay**. Ranh giới: **ghi sở thích và sự kiện thì được; ghi tần suất
   và hành vi thì không** ("hay trả lời chậm" ❌).
3. D-9 vs định vị D-5 — chân dung và chỉ số kéo app về phía "app bói toán".
   **Bắt buộc nằm sau một hành động, không nằm ở màn hình chính.**


## Cập nhật vòng 8 (2026-09-03) — MỞ LẠI: idea chưa chín

**Phán quyết của user:** *"chưa chín, chỉ đang có bản nghiên cứu, chưa chuyển hoá
thành các tính năng thực tế, user journey thực tế và mô tả vòng đời user... các
màn hình và ràng buộc màn hình chưa được định nghĩa, mọi thứ đang quá rời rạc để
có thể biến thành app thực tế."*

→ **Development Status: EXPANDED → IN_PROGRESS.** `### ★ BẢN BÀN GIAO CUỐI (v7)`
bị **thu hồi tư cách bàn giao**. Nội dung v7 vẫn đúng và vẫn dùng được — nhưng nó
là **bản nghiên cứu**, không phải bản đặc tả sản phẩm.

### Phê bình đúng, và đúng theo nghĩa đo được (L43)

| Câu hỏi | Kết quả đếm trên PHẦN 2 của v7 |
|---|---|
| Số hạng mục phạm vi | ~20 |
| Được gán **màn hình** | **2** |
| **Ràng buộc màn hình** trong cả 8 vòng | **1** (SB-208) — và là ràng buộc **phủ định** |
| Màn hình gốc của chặng 1 | **không tồn tại** |
| Vòng đời user (ngày 1/7/30) | **không tồn tại** |

Nguyên nhân trực tiếp: journey xuất hiện ở **vòng 2** (L12/L16) rồi **biến mất**;
vòng 3-7 tổ chức lại theo **tầng phụ thuộc dữ liệu**, không theo **thời gian của
người dùng**. Hai lớp đó chưa từng được đối chiếu.

### Ba khiếm khuyết cấu trúc mới phát hiện

- **L44 — lưới journey đã trôi số hiệu.** J1/J6/J7/J9/J12 mang nghĩa khác giữa
  L12 và `## Convergence Notes`. Hệ quả: mục *"Kiểm tra độ phủ bằng lưới journey"*
  kết luận ranh giới REQ-013/REQ-014 "cắt đúng chỗ" **dựa trên bộ số không khớp
  định nghĩa gốc** ⇒ **ranh giới đó hiện CHƯA được chứng minh.**
- **L45 — mâu thuẫn tự bác bị bỏ quên 5 vòng.** L13 (vòng 2): *"không có N7 thì
  chặng 1 mãi là phòng chờ, và mọi tính năng khác chỉ là trang trí cho phòng chờ
  đó."* Rồi D-8 đẩy trọn N7 sang REQ-014. Ghép lại: **theo chính lời của idea,
  toàn bộ phạm vi REQ-013 là "trang trí cho phòng chờ".** Chưa ai bác, chưa ai
  hoà giải.
- **L46 — bài toán NGÀY 1 chưa từng được mô hình hoá.** Tầng 1 là **ba cái hộp
  rỗng** (thẻ, sổ tay, hồ sơ kỹ năng); giá trị nằm ở Tầng 3 và cần cả ba hộp
  đầy. Ngày 1 người dùng thấy ba biểu mẫu trống. Ba rủi ro onboarding **nhân**
  nhau, không cộng. SB-174 đúng về phụ thuộc dữ liệu, **sai về trải nghiệm**.

### ⭐⭐⭐ L47 — lời giải: xương sống đã có sẵn, nó bị xếp nhầm chỗ

Gán thử từng hạng mục trong cả 5 tầng vào **vòng đời thẻ hoạt động** (ý tưởng →
đã lên lịch → đã làm → kỷ niệm): **cả 20 mục đều rơi gọn vào bốn vai** — *nguồn
sinh thẻ* (mồi chuyện A+, quà, quà handmade, lịch âm, kỹ năng→hoạt động, vỏ
hoàng đạo, bảng tra ăn khớp, dán link) · *làm giàu thẻ* (sổ tay, hồ sơ kỹ năng,
chân dung, kịch bản hẹn) · *cửa ra của thẻ* (lời mời, nhật ký, ảnh/ký ức) ·
*trạng thái của thẻ* ("đang đợi", "23h vừa về"). **Không mục nào rơi ra ngoài.**
Và trong hầu hết trường hợp, chính idea đã tự nói điều đó rồi — *"quà là một loại
thẻ"*, *"đổi thẳng thành thẻ hoạt động"*, *"kết thúc bằng 3 thẻ hoạt động"*,
*"một kịch bản có ba cửa ra"*.

> **"Rời rạc" KHÔNG phải vì thiếu mảnh. Rời rạc vì xương sống bị xếp làm một cái
> xương sườn.** Vòng đời thẻ đang nằm chìm trong Tầng 2 dưới cái tên "C2", ngang
> hàng với "dán link" và "dải giá VNĐ". Nó không phải một tính năng — **nó là
> kiến trúc của cả sản phẩm.**

Hệ quả thực tế: **không cần vứt mảnh nào, không cần brainstorm thêm ứng viên
nào.** Cần **đổi trục tổ chức** từ *tầng dữ liệu* sang *vòng đời thẻ* — rồi màn
hình tự rơi ra.

### L48 — năm luật màn hình đề xuất (SC-1..SC-5, chờ duyệt)

- **SC-1** Chặng 1 có đúng **một** màn hình gốc: **danh sách thẻ theo trạng thái**.
- **SC-2** Mọi **máy sinh nội dung** (mồi chuyện, quà, kịch bản, hoàng đạo, chân
  dung, bảng tra) **không phải điểm đến**: vào từ một trạng thái thẻ, **ra bằng
  một thẻ**. → tổng quát hoá SB-208 từ một điều cấm lẻ thành **luật kiến trúc
  dương**, tự động chặn nguy cơ "app bói toán".
- **SC-3** **Sổ tay và hồ sơ kỹ năng là kho ngữ cảnh, không phải tính năng** —
  không có màn hình riêng để "đi điền"; chỉ hỏi **tại chỗ, đúng lúc cần**. Đây là
  lời giải cho L46.
- **SC-4** Mỗi thẻ ở mỗi trạng thái có **đúng một hành động chính**.
- **SC-5** **Không trạng thái nào là ngõ cụt** — kể cả "tạch" (J11) phải có cửa ra
  giữ lại tài sản không gắn với người kia.

### Ba câu hỏi CHẶN việc vẽ màn hình

- **OQ-18** — chặng 1 là **KHO TÀI SẢN** hay **PHÒNG CHỜ**? (từ L45) Có cho phép
  một vòng lặp xã hội tối thiểu nằm trong chặng 1 không, hay chấp nhận một chiều
  hoàn toàn và nhận luôn trần giữ chân RS-D6? **Quyết định này định hình màn hình gốc.**
- **OQ-19** — duyệt nâng **vòng đời thẻ** từ tính năng C2 lên **kiến trúc**, và
  lấy danh sách thẻ làm **màn hình gốc duy nhất**? (từ L47/SC-1)
- **OQ-20** — duyệt **bỏ màn hình riêng** của sổ tay và hồ sơ kỹ năng, đổi sang
  hỏi tại chỗ? (từ L46/SC-3) Mâu thuẫn với cách v7 mô tả chúng như hai "nền móng"
  đứng riêng — cần user chỉ định.

## Đặc tả sản phẩm (vòng 9-10) — journey, vòng đời, màn hình, tính năng

Bốn quyết định của user khớp lại thành một hình kiến trúc duy nhất:

> **Nhiều cửa vào (mỗi tính năng một trang) → một kho chung (danh sách việc-
> cần-làm) → dữ liệu phụ trợ (sổ tay, kỹ năng) không có cửa riêng, chỉ lộ ra
> khi một cửa vào khác cần.**

(OQ-18 = kho tài sản · OQ-19 = đa trang · OQ-19b = gom chung một danh sách ·
OQ-20 = hỏi tại chỗ, không form.)

### A. Lưới 13 journey — bản chuẩn duy nhất, đã phủ đủ có chủ ý

Mỗi journey: cò (trigger) → app làm gì → để lại gì → kéo mở lại bằng gì. Đây
là bản GỐC của vòng 2, **KHÔNG dùng lại bộ số hiệu đã trôi nghĩa** từng xuất
hiện ở một bản kiểm tra độ phủ cũ (bản đó sai, giữ lại trong `development.md`
chỉ để làm bằng chứng lỗi, không dùng làm căn cứ).

| # | Journey | Trạng thái | Tính năng phủ |
|---|---|---|---|
| J1 | Bắt ý tưởng (5 giây, bất kỳ lúc nào) | ✅ | kho mồi C1, dán link C3, gợi ý quà, lịch âm C7, vỏ hoàng đạo |
| J2 | Chọn việc để rủ | ✅ | danh sách việc-cần-làm (đã có) |
| J3 | Rủ — soạn lời rủ, rời app sang Zalo | ✅ | xuất lời mời C5, mồi chuyện |
| J4 | Đợi trả lời | ✅ | "đừng đoán — chuẩn bị" (SB-83), widget theo pha (SB-84) |
| J5 | Đã hẹn được → chuẩn bị | ✅ | widget SB-84, kịch bản hẹn phần "trước", đếm ngược (SB-86) |
| **J6** | **Ngày hẹn, trước giờ đi** | **✅ (mới, vòng 10)** | **"Trước giờ đi" (SB-211)** — checklist tất định |
| J7 | Trong buổi hẹn | ⚪ **cố ý để trống** | app rời khỏi tay lúc này theo triết lý "trợ lý trước/sau", không xen vào lúc đang hẹn |
| J8 | 23h, vừa về tới nhà | ✅ | "về tới nhà chưa?" (SB-85), nhật ký C6, ký ức C4 |
| **J9** | **Sáng hôm sau** | **✅ (mới, vòng 10)** | **"Gửi lời cảm ơn + chốt việc kế tiếp" (SB-212)** |
| J10 | Khoảng lặng giữa hai lần hẹn | ✅ | "món quà đang lớn" (SB-87), nhỏ giọt (SB-99), sổ tay/kỹ năng hỏi tại chỗ |
| J11 | Im lặng kéo dài / bị từ chối | ✅ | đóng ngăn gọn gàng (SB-64), tắt hồi tưởng (SB-65), giữ tài sản không gắn người kia |
| J12 | Cột mốc → mời vào chặng 2 | ➡️ **cắt có chủ đích** sang REQ-014; REQ-013 chỉ giữ payload render được (SB-125) | — |
| J13 | Quay lại sau 3 tháng vắng | ✅ | màn hình không trách móc (SB-100), xoá sạch một thao tác |

**13/13 journey đã được xử lý có chủ ý**: 11 phủ đủ tính năng · 1 cố ý để
trống (J7, quyết định triết lý) · 1 cắt biên giới sang requirement khác (J12,
quyết định phạm vi D-8). **Không còn khoảng trống ngoài ý muốn.**

### B. Vòng đời user theo thời gian thật

- **Phút 1** — mở app lần đầu, hạ cánh ở màn Danh sách việc-cần-làm, **trống**.
  Không có form dài. Lời mời đầu tiên: "dán 1 link em vừa thấy" hoặc "để app
  gợi ý 1 việc theo dịp gần nhất" — chọn 1, có ngay 1-2 thẻ trong 60 giây.
- **Ngày 1** (cùng ngày) — thử một cửa vào khác, ví dụ "Gợi ý quà". App hỏi tại
  chỗ đúng 1 câu nó còn thiếu ("thích màu gì?"), không hỏi cả bộ. Câu trả lời
  rơi vào sổ tay lặng lẽ — không có màn "đã lưu vào hồ sơ" ồn ào.
- **Ngày 7** — một thẻ đã rủ thật ngoài đời (J3, qua Zalo), sang "Đã hẹn ngày".
  Widget đổi nội dung theo pha (đang đợi/sắp hẹn). Tới đúng ngày hẹn, khối
  "Trước giờ đi" (SB-211) tự hiện với checklist khớp loại hoạt động.
- **Sau buổi hẹn** — tối đó (J8): "về tới nhà chưa?", cất ảnh, viết một câu.
  Sáng hôm sau (J9): gợi ý gửi lời cảm ơn thật cho người kia + chốt việc kế
  tiếp — một lần, bỏ qua thì thôi hẳn.
- **Ngày 30** — nhiều thẻ đã sang "Đã thành kỷ niệm"; Danh sách hiện bộ đếm
  "của cải đang lớn" (12 chỗ → 15 chỗ). Sổ tay và hồ sơ kỹ năng đã có vài chục
  trường nhờ tích luỹ tại chỗ, không nhờ một lần điền form. Có thể chạm cột
  mốc J12 — REQ-013 dừng ở chỗ **nhận ra** cột mốc và giữ payload, không tự
  thực hiện lời mời cài app (đó là REQ-014).
- **Lối ra (J11)** — im lặng kéo dài hoặc bị từ chối: một thao tác "đóng ngăn
  gọn gàng", tắt hồi tưởng. Sổ tay + hồ sơ kỹ năng + danh sách địa điểm không
  gắn với một người cụ thể vẫn giữ nguyên cho lần sau.
- **Lối quay lại (J13)** — sau 3 tháng vắng: màn hình không trách móc, hỏi "mở
  lại từ đâu", có nút xoá sạch một thao tác ngay tại đó.

### C. Bản đồ 11 màn hình

**Nhóm KHO (trưng bày, vào trực tiếp từ menu):**

1. **Danh sách việc-cần-làm** — màn "về nhà". Lọc theo 4 trạng thái: *Mới nghĩ
   ra / Đã hẹn ngày / Đã đi rồi / Đã thành kỷ niệm*. Nhận thẻ từ **mọi** cửa
   vào khác. Chi tiết một thẻ tự mở rộng thêm khối "Trước giờ đi" (SB-211) khi
   ngày hẹn = hôm nay, và khối "Cảm ơn + chốt việc kế tiếp" (SB-212) khi thẻ
   vừa chuyển "Đã đi rồi" hôm qua.
2. **Sổ tay người yêu** — chỉ xem/sửa những gì đã tự động thu thập qua các câu
   hỏi tại chỗ; có nút "+ tự thêm" cho ai chủ động muốn điền. Không phải nơi
   onboarding.
3. **Hồ sơ kỹ năng "phiên bản tôi"** — cùng khuôn mẫu với (2).
4. **Nhật ký riêng** — độc lập, riêng tư mặc định, xoá được.

**Nhóm CỬA VÀO (mỗi trang một tính năng, có đường vào từ menu; đầu ra luôn là
một thẻ đẩy vào (1)):**

5. **Gợi ý quà** — chỉ mục theo dịp Việt × giai đoạn quen nhau × sổ tay; nhánh
   "quà không tốn tiền" và quà handmade theo hồ sơ kỹ năng, lọc theo **số giờ**
   không theo VNĐ; bộ lọc "làm được trong 2 tiếng tối nay".
6. **Mồi chuyện** — bản A: kho câu gợi chuyện thường xanh, dùng tại chỗ, không
   thành thẻ. Bản A+: "sự kiện có lịch" (phim ra rạp, lễ hội), đổi thẳng thành
   thẻ hoạt động.
7. **Vỏ hoàng đạo / trắc nghiệm** — kết quả luôn kết thúc bằng 3 thẻ hoạt động
   đề xuất thêm vào (1), không bằng một nhận định đứng một mình.

**Nhóm KHOÁ VỊ TRÍ (không xuất hiện trong menu chính hay tab bar; chỉ tới được
từ một luồng hẹn/quà đang chạy — thực thi luật SB-208 ở tầng điều hướng):**

8. **Chân dung "theo cách BẠN nhìn"** — bảng câu hỏi user trả lời thay người
   kia; ghi rõ xuất xứ "dựa trên những gì BẠN nhập"; vào từ (5) hoặc (9).
9. **Kịch bản buổi hẹn 3 phần** (trước/trong/sau) — vào từ một thẻ "Đã hẹn
   ngày" trong (1); 3 cửa ra: lời mời (→11) / thẻ mới (→1) / nhật ký (→4).
10. **Bảng tra ăn khớp** — đầu ra bắt buộc bộ bốn: *chỗ dễ hợp · chỗ dễ va ·
    1 hoạt động nên thử · 1 câu để hỏi*; hiển thị DẢI, không hiển thị %; vào
    từ (5) hoặc (9).

**Hành động (không chiếm một destination riêng):**

11. **Xuất lời mời** — bottom sheet gắn trên một thẻ ở (1) hoặc ra từ (9), dựng
    bằng khung nhại + mad-libs; cùng renderer này phục vụ cả "lời mời" và
    "lời cảm ơn sau hẹn" (SB-212) như hai danh mục preset khác nhau.

### D. Luật màn hình (SC-1'..SC-6)

- **SC-1'** — nhiều cửa vào, nhưng chỉ **một kho**: mọi thẻ sinh ra ở bất kỳ
  đâu đều nằm trong (1). Không có "danh sách quà riêng" cạnh tranh với (1).
- **SC-2** — (5),(6),(7),(8),(9),(10) không phải điểm dừng chân; mỗi cái có
  một hành động rõ ràng đẩy kết quả sang (1) hoặc (4) hoặc (11).
- **SC-3** — (2) và (3) không có luồng "điền trước"; chỉ điền qua việc dùng
  các cửa vào khác, tại đúng thời điểm cần.
- **SC-4** — mỗi thẻ ở mỗi trạng thái có đúng một hành động chính: *Mới nghĩ
  ra* → "hẹn ngày"; *Đã hẹn ngày* → "chuẩn bị"/"xuất lời mời" (và tự hiện khối
  "Trước giờ đi" đúng hôm hẹn); *Đã đi rồi* → "ghi lại" (và tự hiện khối "cảm
  ơn + chốt việc kế tiếp" sáng hôm sau); *Đã thành kỷ niệm* → "xem lại".
- **SC-5** — không trạng thái nào là ngõ cụt: J11 có cửa đóng gọn gàng tại (1),
  giữ nguyên (2)/(3) cho lần sau.
- **SC-6** — (8) và (10) không bao giờ xuất hiện trong menu chính hay tab bar;
  chỉ tới được bằng một liên kết trong luồng (5)/(9).

### E. Mô tả chi tiết hai tính năng mới (phủ J6, J9)

**SB-211 — "Trước giờ đi" (phủ J6).** Khối mở rộng **tự động** hiện trên chi
tiết thẻ khi thẻ ở trạng thái *Đã hẹn ngày* và ngày hẹn = hôm nay (phản chiếu
lên widget SB-84 như một pha thứ tư). Sinh **tất định** bằng bảng tra tay từ
các trường có sẵn của thẻ (giá, khoảng cách, cần đặt trước, mùa) — không AI,
không gọi API ngoài:

| Điều kiện trên thẻ | Gợi ý hiện ra |
|---|---|
| có giá > 0, hình thức trả tại chỗ | "mang đủ tiền mặt" |
| khoảng cách vượt ngưỡng | "đổ xăng / sạc xe trước khi đi" |
| mùa = mùa mưa theo miền | "mang áo mưa/ô, có phương án B trong nhà" |
| cần đặt trước = có | "xác nhận lại chỗ đã đặt" |
| luôn có | "chia sẻ vị trí" — một lần, qua OS Share Sheet có sẵn, KHÔNG theo dõi thời gian thực, KHÔNG vi phạm R-1b (an toàn cá nhân người dùng, không phải giám sát người kia) |

Chỉ hiện mục khớp trường thật có trên thẻ — một buổi xem phim trong nhà thì
không có dòng "mang áo mưa". Thẻ thiếu trường → khối ngắn hoặc trống, chấp
nhận được. Một hành động chính duy nhất: "Xong hết rồi, đi thôi" — đóng khối.

**SB-212 — "Gửi lời cảm ơn + chốt việc kế tiếp" (phủ J9).** Touchpoint **hướng
ra ngoài**, đối lập trực tiếp với J8 (hướng vào trong) trên cùng một thẻ. Kích
hoạt **một lần**, dạng nhắc nhẹ, sáng hôm sau khi thẻ chuyển *Đã đi rồi*. Bỏ
qua thì thôi hẳn — không lặp lại, không tạo cảm giác tội lỗi (nhất quán luật
"không phạt khi im lặng").

Ba phần, cả ba **tái dùng hạ tầng đã có**, không xây engine mới:
1. **Soạn lời cảm ơn** — tái dùng khung nhại + mad-libs của (11), thêm một
   **danh mục preset mới** "lời cảm ơn sau hẹn" cạnh danh mục "lời mời". Ra
   ảnh/thẻ, người dùng tự copy sang Zalo gửi người kia.
2. **Đính ảnh** — liên kết sang (4)/ký ức, nếu người dùng đã lưu ảnh ở khối
   "23h vừa về" (J8).
3. **Chốt việc kế tiếp** — 2-3 gợi ý nhẹ từ kho mồi (6) hoặc dịp lịch âm gần
   nhất; chọn 1 → thẻ mới vào (1) ở trạng thái *Mới nghĩ ra*. Không bắt buộc.

Cả SB-211 và SB-212 là **mở rộng của màn (1)**, không phải màn hình thứ 12 —
**tổng vẫn là 11 màn hình**. Cả hai tuân thủ nguyên vẹn R-1 (làm việc trên
HOẠT ĐỘNG), R-1c (không kịch tính hoá), và D-1 (chỉ cần thông báo nhắc đủ
mạnh, không cần báo thức thật).

### F. Gán ngược toàn bộ hạng mục nghiên cứu vào bản đồ sản phẩm

| Hạng mục nghiên cứu | Vai trò trong sản phẩm |
|---|---|
| SB-76 thẻ có cấu trúc | mô hình dữ liệu của (1) |
| SB-129 sổ tay | (2) |
| SB-197 hồ sơ kỹ năng | (3) |
| C1 kho mồi + dải giá | nguồn nội dung tĩnh cấp cho (1)/(5) |
| C2 vòng đời thẻ | trạng thái của (1) |
| C3 nhập liệu không ma sát | hành động "+" trong (1) |
| 3a/3b quà + quà handmade | (5) |
| 3c mồi chuyện A/A+ | (6) |
| 3d kịch bản buổi hẹn | (9) |
| 3e chân dung | (8) |
| 3f bảng tra ăn khớp | (10) |
| Tầng 4 vỏ hoàng đạo/trắc nghiệm | (7) |
| Trò chơi "đoán" không thắng thua | phụ trong (6)/(7), chưa gán màn riêng — mở nếu cần |
| C5 xuất lời mời | (11) |
| C7 lịch âm × khung | nguồn cấp dịp cho (1)/(5)/(6) |
| SB-83/SB-84/SB-85 | trạng thái/widget của (1) |
| C4 ký ức / ảnh | thuộc tính thẻ *Đã thành kỷ niệm* trong (1), liên kết (4) |
| SB-206 kỹ năng sinh hoạt động | nhánh trong (5) |
| C6 nhật ký | (4) |
| SB-100 màn quay lại | trạng thái đặc biệt của (1) khi mở lại sau vắng (J13) |
| **SB-211 "Trước giờ đi"** *(mới)* | mở rộng trạng thái *Đã hẹn ngày, hôm nay* trong (1) |
| **SB-212 "Cảm ơn + chốt việc kế tiếp"** *(mới)* | mở rộng trạng thái *Đã đi rồi* trong (1); tái dùng renderer (11); liên kết (4) và (1) |

**Không hạng mục nào rơi ra ngoài bản đồ 11 màn hình.**

### Còn mở, không chặn

- **Trò chơi "đoán" không thắng thua** — chưa gán màn cố định.
- **OQ-2** (một "ngăn" hay nhiều "ngăn") — coi như trả lời một phần: mỗi trạng
  thái trong (1) là một "ngăn" lọc; chi tiết UI để PO/UX chốt.
- **OQ-3** — ai biên tập và duyệt kho nội dung. Câu hỏi nguồn lực, chỉ user
  trả lời được, không chặn cấu trúc sản phẩm.
- **OQ-7** — đường đi chặng 1.5 → REQ-014 (D-8), không đổi.

## Bàn giao

🟡 **Cấu trúc đã đủ để bàn giao; chờ xác nhận cuối của user trước khi đổi
`Development Status` sang `EXPANDED`.**

`## Đặc tả sản phẩm (vòng 9-10)` ở trên **là bản có hiệu lực, tự-đủ** — chứa
đầy đủ lưới journey (13/13 xử lý có chủ ý, không còn khoảng trống ngoài ý
muốn), vòng đời user theo thời gian thật, bản đồ 11 màn hình + luật màn hình,
mô tả chi tiết hai tính năng mới (SB-211, SB-212), và bảng gán ngược toàn bộ
hạng mục nghiên cứu. `### ★ BẢN BÀN GIAO CUỐI (v7)` trong `development.md`
`## Convergence Notes` vẫn đúng về mặt luật (R-1 và các luật đi kèm, luật nội
dung, luật kiến trúc AI) nhưng **không còn là nguồn chính cho phần cấu trúc
sản phẩm** — nguồn chính nay là mục `## Đặc tả sản phẩm` trong chính file này.

**Trước khi chuyển cho `scrum-master`:** cần user xác nhận bản đồ 11 màn hình
+ hai tính năng mới là ổn, hoặc chỉ ra chỗ cần sửa. Sau khi xác nhận, bước kế
tiếp là soạn một bản bàn giao v8 gộp: PHẦN 1 (đề xuất sửa luật, từ v7) + PHẦN
mới (journey/vòng đời/màn hình, từ mục Đặc tả sản phẩm) — chưa soạn.

## Artifacts

- Development: `development.md`
- Checkpoint: `brainstormer-checkpoint.md`

## Routing Notes

- Current owner: brainstormer
- Next action: **trình `## Đặc tả sản phẩm (vòng 9-10)` cho user xác nhận cuối.**
  Nếu chấp nhận → set `Development Status: EXPANDED`, soạn bản bàn giao v8 gộp
  (luật từ v7 + cấu trúc từ Đặc tả sản phẩm), rồi chờ user chuyển cho
  `scrum-master`. Nếu user muốn sửa bản đồ màn hình hoặc mở thêm nhánh → vòng 11.
- 🟡 **Delivery handoff: CHƯA.** Cấu trúc và luật đều đã đủ nội dung, nhưng
  chưa có xác nhận cuối cùng của user và chưa có bản bàn giao v8 gộp. Brainstormer
  KHÔNG ghi vào `data/requirements/`.
- REQ-013 hiện tại: user tuyên bố sẽ **bỏ và tạo lại** → không cần bảo toàn
  tương thích ngược với 22 story đang tồn tại.
