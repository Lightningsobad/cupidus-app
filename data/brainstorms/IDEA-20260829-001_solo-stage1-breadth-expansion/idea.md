# Idea Master: IDEA-20260829-001 Solo Stage-1 Breadth Expansion
Lifecycle: ACTIVE
Development Status: EXPANDED
Source: user
Created: 2026-08-29
Last Updated: 2026-08-29
Linked Requirement: N/A (liên quan nhưng CHƯA bàn giao — xem `## Quan hệ với REQ-013`)

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


## Bàn giao

**Bản có hiệu lực để chuyển cho `scrum-master`:**
`development.md` → `## Convergence Notes` → `### ★ BẢN BÀN GIAO CUỐI (v7)`.

Gồm PHẦN 0 (tóm tắt) · **PHẦN 1 — đề xuất sửa `Invariant Design Rules`** ·
PHẦN 2 (phạm vi, xếp 5 tầng theo thứ tự bắt buộc) · PHẦN 3 (giữ ngoài REQ-013) ·
PHẦN 4 (rủi ro + câu hỏi mang theo).

⚠️ **Product Owner phải xử lý PHẦN 1 TRƯỚC PHẦN 2** — phạm vi phụ thuộc vào kết
quả sửa luật. Ba khối "Bổ sung vòng 4/5/6" trong cùng mục là **lịch sử suy
luận**, không dùng làm đầu vào.

Ba nền móng dữ liệu song song mà việc gộp làm lộ ra: **thẻ hoạt động có cấu
trúc** (tả *việc*) · **sổ tay mối quan hệ** (tả *người kia*) · **hồ sơ kỹ năng**
(tả *người dùng*). Sáu vòng trước chỉ nhìn thấy từng cái một.

## Artifacts

- Development: `development.md`
- Checkpoint: `brainstormer-checkpoint.md`

## Routing Notes

- Current owner: brainstormer
- Next action: **không còn việc brainstorm nào bị chặn.** Đã hội tụ.
- Đầu ra chờ bàn giao: bản nháp **"Đề xuất bổ sung cho REQ-013"** trong
  `development.md` mục `## Convergence Notes`.
- Delivery handoff: explicit user switch to `scrum-master` only. Brainstormer
  KHÔNG ghi vào `data/requirements/`.
