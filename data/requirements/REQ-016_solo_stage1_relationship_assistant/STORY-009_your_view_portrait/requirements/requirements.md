# Story Requirements: STORY-009 Chân dung "theo cách BẠN nhìn" — màn (8)

- Requirement: REQ-016
- Story: STORY-009
- Complexity: standard
- Story-Class: standard
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: STORY-004
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules` (R-1/R-1a, R-1b, R-1e,
  R-1f, R-1g, R-7, R-13), `## Out of Scope`, `## Open Questions`;
  `../../requirements/requirements.md` → `## Story Index`,
  `## Open Question Triage`;
  `../../STORY-004_relationship_notebook_and_gift_ideas/requirements/requirements.md` →
  cơ chế hỏi-tại-chỗ SC-3 (AC-1, AC-4, AC-5), sổ tay chỉ sở thích + sự kiện,
  luồng gợi ý quà làm cửa vào;
  `../../STORY-008_date_script_three_parts/requirements/requirements.md` →
  cửa vào thứ hai (tuỳ chọn, phụ thuộc một chiều), tiền lệ khoá vị trí BR-1;
  `../../STORY-002_invite_message_composer/requirements/requirements.md` →
  tiền lệ kiểm duyệt hai lớp (AC-23, AC-24)

## Business Outcome

Người dùng **nhìn thấy rõ mình đang đoán gì** về "mối" của mình — và nhờ đó biết
mình cần **hỏi thật** những gì. Story này biến quan sát rời rạc của chính người
dùng thành hiểu biết dùng được, rồi đổ dữ liệu ngược vào sổ tay để các cửa vào
khác (quà, mồi chuyện, kịch bản) bớt chung chung.

Story này phủ **J10**. Nó là **bề mặt R-1 sắc nhất của cả requirement**: người
dùng trả lời một bộ câu hỏi **thay cho người kia**, và app hiển thị kết quả. Toàn
bộ giá trị nằm ở chỗ kết quả được đóng khung đúng — **một chân dung TƯỞNG TƯỢNG
của người dùng**, không phải một hồ sơ về người kia.

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ**, và story này là ví dụ thuần khiết nhất: **toàn bộ** dữ liệu đầu
vào do chính người dùng gõ ra. Người kia không cần trả lời, không cần cài app,
không cần biết chuyện này đang diễn ra. Nếu một AC nào đó chỉ đúng khi người kia
xác nhận, AC đó sai phạm vi.

### Rủi ro chính: trượt ngôn ngữ

Rủi ro số một của story này **không phải kỹ thuật** — nó là ngôn ngữ trượt từ
*"bạn đoán rằng…"* sang *"người ấy là…"*. Một chữ trượt biến app từ "trợ lý chăm
sóc nhau" thành thứ mà R-1 nấc 4 cấm vĩnh viễn. Nhóm B, Nhóm C, và Nhóm D dưới
đây tồn tại để chặn đúng cú trượt đó, và chúng là tiêu chí nghiệm thu, không phải
lời khuyên biên tập.

## Scope

### In Scope

1. Màn (8) "Chân dung theo cách BẠN nhìn": bộ câu hỏi người dùng trả lời **thay**
   người kia, theo cách chính họ nhìn.
2. **Nhãn xuất xứ "dựa trên những gì BẠN nhập" nằm trong BỐ CỤC** của mọi bề mặt
   hiển thị kết quả — không phải chú thích nhỏ, không phải tooltip, không phải
   banner tắt-một-lần.
3. Kết quả chân dung: các phần nội dung sinh **tất định** từ chính câu trả lời
   của người dùng, mỗi phần **kết bằng một câu để hỏi người thật**.
4. **Cửa vào duy nhất**: liên kết bên trong luồng (5) gợi ý quà (STORY-004) đang
   chạy, hoặc luồng (9) kịch bản buổi hẹn (STORY-008) đang chạy nếu story đó đã
   giao.
5. **Khoá vị trí** (R-13 hard-name màn (8)): không menu chính, không tab bar,
   không route trực tiếp.
6. Câu trả lời thuộc loại **sở thích và sự kiện** đổ vào sổ tay của STORY-004 để
   các cửa vào khác dùng lại.
7. Bỏ dở giữa chừng: giữ phần đã trả lời, không thúc ép hoàn thành.
8. Kiểm duyệt nội dung **hai lớp** (SB-123) cho bộ câu hỏi, nội dung chân dung,
   và các câu-để-hỏi.

### Out of Scope

- **Bất kỳ câu nào app tự khẳng định là sự thật về người kia** — R-1e tầng 3 cấm.
- **Chấm điểm, xếp hạng, hay đánh giá con người** người kia — R-1(d-sai) cấm.
- **So sánh và báo cáo hành vi** người kia — R-1(c) cấm.
- **Đọc tin nhắn, theo dõi mạng xã hội, nhập dữ liệu từ bất kỳ nguồn ngoài nào**
  — R-1(b) cấm. Mọi dữ liệu vào màn này đến từ bàn phím của người dùng.
- **Ghi tần suất hoặc hành vi** của người kia — R-1b cấm ("hay trả lời chậm" là
  ví dụ bị cấm đích danh trong luật bất biến).
- **Xuất / chia sẻ / gửi chân dung ra ngoài app** — nhất quán R-1f.
- **Bảng tra ăn khớp** (144 ô hoàng đạo / 256 ô MBTI, chỉ số ăn khớp dạng dải) —
  STORY-010.
- Đường vào từ menu chính, tab bar, hay deep link/route trực tiếp — vi phạm khoá
  vị trí.
- Sửa mô hình sổ tay của STORY-004, hay xây kho ngữ cảnh thứ hai.
- Chặng 1.5, link hai chiều, feed tin thật, Zalo Mini App, thương mại/affiliate
  quà, J7.

## Acceptance Criteria

### Nhóm A — Cửa vào và khoá vị trí (R-13 / SC-6)

**AC-1.** Given người dùng đang ở **luồng gợi ý quà đang chạy** (STORY-004), when
họ bấm liên kết tới chân dung, then màn (8) mở ra trong ngữ cảnh luồng đó.

**AC-2.** Given người dùng duyệt **toàn bộ** menu chính và tab bar, when họ tìm
màn chân dung, then **không** mục nào dẫn tới nó (R-13, SC-6). Đây là ràng buộc
**đạo đức**, không phải ràng buộc điều hướng: một màn nói về người kia không được
đứng sẵn ở nơi người dùng lướt qua hằng ngày.

**AC-3.** Given một route/deep link trỏ thẳng vào màn (8), when nó được mở mà
người dùng **không** đi qua một luồng (5) hoặc (9) đang chạy, then app **không**
hiển thị màn chân dung. Direct URL only acceptable: **NO**.

**AC-4.** Given người dùng đóng màn chân dung, when họ thoát, then họ quay về
**đúng luồng nguồn** đã đưa họ vào, không rơi ra một màn khác và không mất tiến
độ của luồng đó.

**AC-5.** Given **STORY-008 chưa được giao**, when người dùng dùng story này,
then **mọi** AC vẫn đạt được qua cửa vào STORY-004. Cửa vào từ luồng (9) là
**bổ sung**, không phải điều kiện; story này không cần STORY-008 để chạy.

### Nhóm B — Xuất xứ nằm trong BỐ CỤC, không phải chú thích

**AC-6.** Given bất kỳ bề mặt nào hiển thị kết quả chân dung, when nó hiển thị,
then nhãn **"dựa trên những gì BẠN nhập"** là **một phần của bố cục** — hiển thị
ngay ở đầu kết quả, cùng cấp thị giác với nội dung chân dung, **không** phải chú
thích cỡ nhỏ ở chân màn, **không** phải tooltip phải chạm mới thấy, **không**
phải banner tắt-một-lần.

**AC-7.** Given kết quả chân dung dài hơn một màn, when người dùng cuộn, then
nhãn xuất xứ **vẫn đọc được** ở mọi vị trí cuộn — nó không cuộn mất theo nội
dung.

**AC-8.** Given kết quả chân dung hiển thị ở **bất kỳ bề mặt thứ hai nào** (ví dụ
tóm tắt trong luồng quà, thẻ tóm lược, hay bất kỳ nơi nào nội dung chân dung
được nhắc lại), when nó hiển thị, then nhãn xuất xứ đi kèm ở đó **luôn**. Nội
dung chân dung không bao giờ rời khỏi nhãn của nó.

**AC-9.** Given người dùng đọc tiêu đề và khung của màn, when họ đọc, then màn
tự gọi mình là **chân dung TƯỞNG TƯỢNG theo cách người dùng nhìn**, chứ không tự
gọi mình là hồ sơ, profile, phân tích, hay bản đánh giá người kia.

### Nhóm C — Luật ba tầng R-1e và ranh giới suy luận R-1a

**AC-10.** Given người dùng trả lời một câu hỏi thay người kia, when app xử lý
câu trả lời, then app **không** xác nhận, **không** phản bác, và **không** đánh
giá câu đoán đó đúng hay sai (R-1e tầng 2: user ĐOÁN, app không xác nhận).

**AC-11.** Given app sinh ra bất kỳ nội dung suy luận nào, when nội dung được
dựng, then **toàn bộ** đầu vào của nó là **dữ liệu người dùng tự nhập** — câu trả
lời trong màn này cộng sổ tay của STORY-004. Không nguồn nào khác được dùng
(R-1a; R-1e tầng 3 chỉ mở trên dữ liệu user tự nhập).

**AC-12.** Given kết quả chân dung, when người dùng đọc, then **không** có điểm
số, phần trăm, sao, xếp hạng, mức độ, hay bất kỳ đại lượng chấm điểm nào về người
kia (R-1(d-sai)).

**AC-13.** Given kết quả chân dung, when người dùng đọc, then **không** đoạn nào
được viết ở giọng khẳng định về người kia ("người ấy là…", "người ấy luôn…", "cô
ấy/anh ấy thuộc kiểu…"). Mọi đoạn đóng khung là **cách người dùng đang nhìn**
("theo cách bạn kể…", "bạn đang thấy rằng…").

**AC-14.** Given app có dữ liệu về **cả người dùng** (hồ sơ kỹ năng, sở thích của
chính họ), when nội dung được sinh ra, then app được phép nói **trực tiếp về
người dùng**; ranh giới cấm chỉ áp cho các phát ngôn **về người kia**.

**AC-15.** Given bất kỳ đường đi nào, when app chạy story này, then app **không**
đọc tin nhắn, **không** truy cập mạng xã hội, **không** nhập dữ liệu từ danh bạ,
lịch bên ngoài, hay bất kỳ nguồn nào ngoài bàn phím của người dùng (R-1(b)).

### Nhóm D — R-1g: kết bằng câu hỏi, không bằng kết luận

**AC-16.** Given kết quả chân dung có nhiều phần, when người dùng đọc hết **mỗi**
phần, then phần đó kết thúc bằng **một câu để hỏi người thật** — một câu người
dùng có thể nói ra với người kia — không kết thúc bằng một nhận định chốt hạ.

**AC-17.** Given toàn bộ kết quả chân dung, when nó được nghiệm thu, then nó vượt
qua **bài kiểm tra R-1g**: đọc xong, người dùng muốn hỏi người kia **nhiều hơn**,
không phải ít hơn. Đây là tiêu chí nghiệm thu bắt buộc của cả story, không phải
tiêu chí của riêng một preset.

**AC-18.** Given một câu-để-hỏi được sinh ra, when người dùng đọc, then nó là một
câu **hỏi thật, hỏi được**, không phải câu hỏi tu từ, không phải câu dẫn dắt để
người kia trả lời theo hướng định sẵn (ranh giới với R-1e cấm thao túng).

**AC-19.** Given một phần chân dung mà dữ liệu người dùng nhập **quá mỏng** để
nói được điều gì, when phần đó hiển thị, then app **không** bịa nội dung để lấp
đầy: nó hiện thẳng câu-để-hỏi tương ứng, hoặc không hiện phần đó. Chân dung mỏng
là kết quả **hợp lệ**.

### Nhóm E — Ranh giới dữ liệu R-1b / R-1f: sở thích và sự kiện, không tần suất và hành vi

**AC-20.** Given bộ câu hỏi của story này, when nó được duyệt và khi hiển thị,
then **không** câu nào hỏi về **tần suất hoặc hành vi** của người kia — không
"người ấy có hay trả lời chậm không", không "bao lâu người ấy nhắn một lần",
không "người ấy thường online lúc mấy giờ" (R-1b, cấm đích danh).

**AC-21.** Given bộ câu hỏi, when nó được duyệt và khi hiển thị, then các câu hỏi
nằm trong phạm vi **sở thích và sự kiện** — thứ người kia thích, thứ họ từng kể,
dịp quan trọng của họ — chứ không phải đánh giá con người ("người ấy có ích kỷ
không").

**AC-22.** Given người dùng trả lời một câu hỏi thuộc loại **sở thích hoặc sự
kiện**, when họ hoàn tất, then dữ liệu đó xuất hiện trong **sổ tay của
STORY-004**, sửa được, xoá được, và dùng lại được ở các cửa vào khác.

**AC-23.** Given một câu trả lời **không** thuộc loại sở thích/sự kiện (một phỏng
đoán tính cách thuần tuý), when app xử lý, then nó **không** được ghi vào sổ tay
như một sự kiện đã xác lập — sổ tay chỉ chứa sở thích và sự kiện, không chứa đánh
giá con người (R-1f).

**AC-24.** Given chân dung đã sinh ra, when người dùng xem nó, then **không** có
chức năng xuất, chia sẻ, gửi, hay sao chép chân dung ra ngoài app (R-1f). Chân
dung ở lại thiết bị, phục vụ chính người dùng.

### Nhóm F — Bỏ dở, không thúc ép

**AC-25.** Given người dùng đang trả lời bộ câu hỏi, when họ thoát giữa chừng,
then phần đã trả lời **được giữ lại**, và họ quay lại đúng chỗ đang dở ở lần sau.

**AC-26.** Given người dùng bỏ dở, when họ dùng app những lần sau, then app
**không** nhắc lại, **không** hiện thanh tiến độ thúc ép, **không** hiện dấu
chưa-hoàn-thành, và **không** chặn các cửa vào khác vì lý do "chân dung chưa
xong".

**AC-27.** Given người dùng bỏ qua một câu hỏi cụ thể, when họ đi tiếp, then
không có hệ quả nào và câu đó bỏ qua được lại ở lần sau — mọi câu đều **tuỳ
chọn**.

**AC-28.** Given story này, when người dùng dùng nó, then **không** có streak,
chuỗi ngày, huy hiệu, bảng xếp hạng, hay đếm số câu đã trả lời (R-1, cấm (f)), và
**không** phần nào nằm sau paywall (R-14).

### Nhóm G — Tất định, kiểm duyệt, cổng cứng

**AC-29.** Given cùng một bộ câu trả lời và cùng nội dung sổ tay, when chân dung
được sinh ra ở hai lần khác nhau, then kết quả **giống hệt nhau** (tất định).

**AC-30.** Given bất kỳ đường đi nào của story này, when nội dung được sinh ra,
then app **không** gọi mô hình AI ở runtime và **không** gọi dịch vụ ngoài nào;
thiết bị **không có mạng** vẫn dùng được trọn vẹn (R-7).

**AC-31.** Given bộ câu hỏi, nội dung chân dung, và các câu-để-hỏi chuẩn bị vào
bản build người dùng thật, when nội dung được đưa vào, then điều kiện ship là
**(a)** mọi mục đã qua **cổng nhập chạy được** ở AC-36/AC-37 (R-15c), và **(b)**
trạng thái duyệt ghi lại truy vết được **theo id bền của từng mục** (AC-33).
Kiểm duyệt hai lớp (SB-123) vẫn giữ cho **chất lượng biên tập** — giọng, độ
sượng, tính dùng được — nhưng **không** còn là cổng chặn ship và **không** là cơ
chế cưỡng chế luật bất biến. AC này **không còn bị chặn**: OQ-3 đã đóng
2026-09-06 bằng D-15.

**AC-32.** Given người dùng chưa từng có, và sẽ không bao giờ có, phản hồi từ
người kia, when họ dùng story này, then **mọi** AC ở trên vẫn đạt được — toàn bộ
đầu vào đến từ chính họ.

### Nhóm H — Nội dung là dữ liệu có cổng nhập (R-15 / D-15)

**AC-33.** Given bộ câu hỏi, các đoạn chân dung, và kho câu-để-hỏi, when chúng
được ship, then chúng là **gói dữ liệu có lược đồ và định danh bền cho từng
mục** — gồm cả luật ánh xạ câu trả lời → đoạn nội dung — không phải chuỗi cứng
trong widget/code; đổi nguồn nội dung sang CMS ngoài repo **không kéo theo một
lần sửa code** (R-15a).

**AC-34.** Given số câu hỏi và số đoạn chân dung là **thuộc tính dữ liệu** (N
bất kỳ, N ≥ 1), when gói nội dung đổi số mục, then bố cục bộ câu hỏi, cơ chế
lưu-bỏ-dở (AC-25..AC-28), và cách hiện chân dung vẫn đạt nguyên vẹn **mà không
sửa code**; **không** AC nào của story này được suy ra từ số mục của bộ seed
(R-15b).

**AC-35.** Given kho **câu-để-hỏi** có N mục bất kỳ, when người dùng liên tục
yêu cầu câu-để-hỏi tiếp theo cho tới khi duyệt hết kho, then hành vi hết-vòng là
**quay lại từ đầu kho theo cùng thứ tự tất định**, **không** thông báo "đã hết",
**không** màn ngõ cụt, và **không** chỉ báo tiến độ, phần trăm hoàn thành, hay
số mục còn lại dưới bất kỳ dạng nào — kể cả chỉ báo tiến độ của bộ câu hỏi
(R-15b, và R-1 cấm (f) + cấm %).

**AC-36.** Given một mục nội dung ĐẦU RA vi phạm luật bất biến — đo hành vi
người kia (R-1b), tâng bốc, hiển thị %, streak, dẫn dắt cảm xúc (R-1e), hoặc
đoạn chân dung không kết bằng một câu-để-hỏi (R-1g) — when mục đó được nạp qua
cổng nhập nội dung, then cổng **từ chối mục đó và làm hỏng bản dựng**; vi phạm
**không** được phép lọt tới lúc người dùng đọc. Cổng chạy được kể cả với nội
dung do CMS ngoài repo cấp, tức nội dung **không** đi qua review của repo này
(R-15c).

**AC-37.** Given một mục của **bộ câu HỎI** vi phạm R-1b ở tầng ĐẦU VÀO — hỏi về
tần suất hay hành vi của người kia thay vì sở thích/sự kiện (BR-6) — when mục đó
được nạp qua cổng nhập, then cổng **từ chối mục đó và làm hỏng bản dựng**. Đây
là điểm riêng của story này: một câu **hỏi** sai làm hỏng dữ liệu ngay từ đầu
vào và **không** sửa được ở đầu ra, nên nó phải bị chặn ở cổng chứ không ở khâu
biên tập (R-15c).

## Business Rules

- **BR-1 (R-13 — khoá vị trí là ràng buộc ĐẠO ĐỨC).** Màn (8) được luật bất biến
  13 gọi tên đích danh. Lý do không phải gọn gàng điều hướng: một màn nói **về
  người kia** không được đứng sẵn trong menu/tab bar để người dùng lướt vào mỗi
  ngày. Nó chỉ có nghĩa **bên trong một luồng đang chạy** cần tới nó. Đây là điểm
  khác với STORY-008 (màn (9) khoá vị trí vì gắn-thẻ, không vì R-13) — xem
  STORY-008 BR-1a.
- **BR-2 (xuất xứ là BỐ CỤC, không phải chú thích).** "Dựa trên những gì BẠN
  nhập" phải chịu được ba phép thử: (a) thấy ngay không cần cuộn, (b) vẫn thấy
  khi đã cuộn, (c) đi theo nội dung sang mọi bề mặt khác. Một chú thích cỡ nhỏ ở
  chân màn **không đạt** BR này. Lý do: xuất xứ là thứ duy nhất giữ chân dung ở
  đúng tầng 2 của R-1e; giấu nó đi là đẩy cả story sang tầng 3.
- **BR-3 (R-1e ba tầng, ranh giới chính xác).** User **GHI** ✅ · user **ĐOÁN**,
  app **không xác nhận** ✅ · app **SUY LUẬN / CHẤM ĐIỂM** về người kia ❌. Story
  này sống ở tầng 2. Tầng 3 chỉ mở **trên dữ liệu user tự nhập** (R-1a) — nghĩa
  là app được phép sắp xếp, nhóm, và phản chiếu lại câu trả lời của người dùng,
  **không** được phép thêm vào một kết luận mà dữ liệu đó không nói.
- **BR-4 (giọng văn là tiêu chí nghiệm thu, không phải phong cách).** Mọi phát
  ngôn về người kia viết ở giọng **"theo cách bạn nhìn"**. Một preset viết
  "người ấy là…" là preset **không hợp lệ**, phải trả về khâu soạn nội dung —
  không phải một sắc thái để tranh luận. Đây là chỗ rủi ro #1 của story cắn vào
  (xem `## Business Outcome`).
- **BR-5 (R-1g — kết bằng câu hỏi, hỏi được).** Mỗi phần kết bằng **một câu để
  hỏi người thật**, và câu đó phải **hỏi được ngoài đời**: không tu từ, không dẫn
  dắt. Bài kiểm tra nghiệm thu của cả story: đọc xong, người dùng muốn hỏi người
  kia **nhiều hơn** (AC-17).
- **BR-6 (R-1b — sở thích + sự kiện ✅, tần suất + hành vi ❌).** Ranh giới này
  quyết định **bộ câu hỏi được phép chứa gì**, không chỉ quyết định app lưu gì.
  "Người ấy thích ăn gì" ✅ · "người ấy có hay trả lời chậm không" ❌. Một câu hỏi
  vi phạm ranh giới này làm hỏng story ngay từ đầu vào, không sửa được ở đầu ra.
- **BR-7 (R-1f — sổ tay không chứa đánh giá con người, không xuất ra).** Chỉ câu
  trả lời loại **sở thích/sự kiện** chảy vào sổ tay (AC-22). Phỏng đoán tính cách
  ở lại trong phạm vi chân dung, không được nâng cấp thành dữ kiện trong sổ tay
  (AC-23). Chân dung **không** có chức năng xuất/chia sẻ (AC-24).
- **BR-8 (R-1(b) — không nguồn ngoài, tuyệt đối).** Mọi byte dữ liệu về người kia
  trong story này đến từ **bàn phím của người dùng**. Không tin nhắn, không mạng
  xã hội, không danh bạ, không lịch ngoài. Đây là điều làm cho R-1a cho phép suy
  luận ở đây mà không cho phép ở chỗ khác.
- **BR-9 (chân dung mỏng là kết quả hợp lệ).** Dữ liệu ít → chân dung ngắn, hoặc
  chỉ còn câu-để-hỏi. App **không** bịa để lấp đầy và **không** dùng khoảng trống
  làm đòn bẩy ép người dùng trả lời thêm (SC-3, AC-19, AC-26).
- **BR-10 (SC-3 — không điền trước, mọi câu tuỳ chọn).** Bộ câu hỏi không phải
  onboarding và không phải biểu mẫu bắt buộc. Bỏ dở, bỏ qua từng câu, và quay lại
  sau đều là đường đi hợp lệ, không hệ quả.
- **BR-11 (R-7 — tất định, không AI ở runtime).** Nội dung đi đường PRESET +
  MAD-LIBS. AI chỉ dùng **ngoài hệ thống, ở khâu soạn nội dung**, và sản phẩm của
  nó vào repo như gói dữ liệu tĩnh đã qua kiểm duyệt hai lớp.
- **BR-12 (SB-123 — kiểm duyệt hai lớp, mức nghiêm nhất, cho CHẤT LƯỢNG BIÊN
  TẬP).** Đây là story có rủi ro "sượng" **cao nhất** trong REQ-016 vì nội dung
  nói trực tiếp về người kia, nên kiểm duyệt hai lớp giữ nguyên mức nghiêm nhất
  cho giọng và độ sượng. Nhưng sau D-15 nó **không** còn là cổng chặn ship và
  **không** là cơ chế cưỡng chế luật bất biến — việc đó thuộc cổng nhập chạy
  được (BR-17). Kiểm duyệt hai lớp là quy ước con người, không đáng tin với nội
  dung CMS tương lai vốn không đi qua review của repo này.
- **BR-13 (phụ thuộc một chiều với STORY-008 và STORY-010).** Cửa vào từ luồng
  (9) là **bổ sung** khi STORY-008 đã giao (AC-5). Bảng tra ăn khớp là STORY-010,
  một story khác; story này **không** hiển thị chỉ số ăn khớp, không dải, không
  %. Theo tiền lệ STORY-006 BR-11: story này chạy trọn vẹn khi hai story kia chưa
  tồn tại.
- **BR-14 (R-14 — không paywall lõi).** Chân dung là phần lõi của chặng 1; không
  đặt phần nào sau paywall.
- **BR-15 (R-15a — nội dung là dữ liệu, không phải chuỗi trong code).** Bộ câu
  hỏi, các đoạn chân dung, kho câu-để-hỏi, và **luật ánh xạ câu trả lời → đoạn
  nội dung** là gói dữ liệu có lược đồ, mỗi mục có **id bền** dùng được làm khoá
  tham chiếu và khoá truy vết duyệt. Cấm chuỗi nội dung nằm trong widget/code.
  Tiêu chí nghiệm thu: đổi nguồn sang CMS ngoài repo mà **không sửa một dòng
  code nào**.
- **BR-16 (R-15b — N là thuộc tính dữ liệu).** Số câu hỏi, số đoạn chân dung, và
  số câu-để-hỏi là dữ liệu bản đầu, **không** phải hằng số của story; bộ seed 10
  mục cho gói **xoay vòng** (kho câu-để-hỏi) là giá trị bản đầu. Cấm mọi AC, BR,
  hay bố cục dựa vào "vì có đúng N mục nên…" — đặc biệt hành vi hết-vòng (AC-35)
  và chỉ báo tiến độ. Điều này siết thêm ràng buộc đã có: story này vốn đã cấm
  hiển thị % và chỉ số, nên chỉ báo tiến độ theo số mục cũng bị cấm bằng hai
  luật độc lập.
- **BR-17 (R-15c — luật bất biến là CỔNG NHẬP, không phải quy ước biên tập).**
  R-1b (cả tầng đầu ra lẫn tầng đầu vào của bộ câu hỏi, xem BR-6), R-1e cấm dẫn
  dắt, R-1g, chống tâng bốc, cấm hiển thị %, và cấm streak được cưỡng chế ở
  **tầng lược đồ/validation của cổng nhập nội dung**, chạy được trong bản dựng.
  Nội dung vi phạm bị từ chối tại cổng và làm hỏng bản dựng (AC-36, AC-37). Vì
  story này là story rủi ro cao nhất, cổng nhập ở đây là **bắt buộc trước khi
  ship**, không phải bước tuỳ chọn.

## System Integration And Discoverability

- **UI-facing story:** YES.
- **Existing user-visible surface:** YES — luồng gợi ý quà của STORY-004. Story
  này gắn một liên kết vào luồng đã có, không tạo destination mới.
- **Điểm vào:** **duy nhất**, từ một liên kết bên trong luồng (5) gợi ý quà đang
  chạy, hoặc luồng (9) kịch bản buổi hẹn đang chạy nếu STORY-008 đã giao. **Direct
  URL only acceptable: NO** — điều hướng thẳng bằng route là vi phạm khoá vị trí
  (AC-3).
- **Vị trí trong nhóm khoá vị trí:** màn (8) đứng cùng nhóm với màn (9) và màn
  (10). Màn (8) và màn (10) bị **R-13 gọi tên đích danh** vì lý do đạo đức (chúng
  nói về người kia); màn (9) thuộc nhóm vì gắn-thẻ. Cùng ràng buộc điều hướng,
  khác lý do — quan trọng với UI/UX Designer khi thiết kế ba màn này.
- **Luồng dữ liệu hai chiều với sổ tay (STORY-004):** story này **đọc** sổ tay để
  câu hỏi và chân dung bớt chung chung, và **ghi ngược** các câu trả lời loại sở
  thích/sự kiện vào sổ tay để quà, mồi chuyện, và kịch bản dùng lại. Đây là lý do
  duy nhất story này phụ thuộc STORY-004 về **hạ tầng**, không chỉ về cửa vào.
- **Hợp đồng story này TIÊU THỤ:** STORY-004 (kho sổ tay đọc/ghi, luồng quà làm
  cửa vào, cơ chế hỏi-tại-chỗ), STORY-008 (cửa vào thứ hai, tuỳ chọn).
- **Hợp đồng story này KHÔNG tiêu thụ:** STORY-010 (bảng tra ăn khớp), STORY-012
  (widget/pha). Story này không hiển thị chỉ số ăn khớp ở bất kỳ dạng nào.
- **Tích hợp bên ngoài:** **không có, và đó là ràng buộc, không phải hiện trạng**
  (BR-8). Không AI runtime, không dịch vụ nội dung, không nguồn dữ liệu ngoài.

## Open Question Impact

### Scope Items BLOCKED in this story

- **Không còn scope item nào của story này bị chặn bởi câu hỏi mở.** OQ-3 — mục
  duy nhất từng chặn (AC-31) — đã đóng 2026-09-06 bằng D-15.

### Scope Items NOT BLOCKED in this story

- **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user), bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Câu trả lời không phải "chỉ định người duyệt lớp 2" mà là đổi bản
  chất nội dung: dữ liệu có schema + id bền, N là thuộc tính dữ liệu, luật bất
  biến cưỡng chế ở cổng nhập chạy được.
  - **Hết chặn:** ship bộ câu hỏi, nội dung chân dung, và các câu-để-hỏi vào bản
    build người dùng thật (AC-31) không còn chờ user chỉ định người duyệt lớp 2.
    Điều kiện ship nay là qua cổng nhập chạy được cộng truy vết duyệt theo id
    bền.
  - **Thành ràng buộc mới của story:** AC-33..AC-37 và BR-15/BR-16/BR-17.
  - **Điểm riêng của story này vẫn giữ nguyên sức nặng, nhưng đổi cơ chế:** bộ
    câu hỏi chịu kiểm duyệt ở tầng **ĐẦU VÀO**, không chỉ đầu ra — một câu
    **hỏi** sai (vi phạm BR-6: tần suất/hành vi) làm hỏng story ngay từ dữ liệu
    vào và không sửa được ở đầu ra. Sau D-15 điều này **không** còn là lý do
    chặn ship; nó thành **quy tắc validation chạy được** ở AC-37.
  - **Còn lại của SB-123:** kiểm duyệt hai lớp giữ nguyên mức nghiêm nhất cho
    chất lượng biên tập (BR-12), nhưng hạ từ **chặn ship** xuống **rủi ro chất
    lượng nội dung**, sửa được bằng đổi dữ liệu mà không sửa code.

- **OQ-3 chưa bao giờ chặn màn, điều hướng, bố cục, hay cơ chế.** Ràng buộc khoá vị trí
  (AC-1..AC-5), **bố cục nhãn xuất xứ** (AC-6..AC-9), ràng buộc không-chấm-điểm
  và không-nguồn-ngoài (AC-10..AC-15), cơ chế lưu-bỏ-dở (AC-25..AC-28), đường ghi
  vào sổ tay (AC-22, AC-23), và tính tất định/ngoại tuyến (AC-29, AC-30) **xây và
  verify được ngay** bằng nội dung placeholder nội bộ. Bản thân chuỗi "dựa trên
  những gì BẠN nhập" là **nhãn chức năng bắt buộc**, không phải nội dung có giọng
  điệu — theo tiền lệ STORY-006 BR-14, nó không bị OQ-3 chặn và phải có mặt ngay
  từ bản build nội bộ đầu tiên.
- **L45 / OQ-18 — ĐÓNG** (user chốt 2026-09-03: chặng 1 là kho tài sản). Story
  này không chịu tải định vị; ba story chịu tải là STORY-001, STORY-012,
  STORY-013.
- **R-1 mở ở nấc 3 — ĐÓNG, luật bất biến.** Việc app được suy luận tính cách trên
  dữ liệu user tự nhập là **quyết định đã khoá** (R-1a), không phải câu hỏi mở của
  story này. Nấc 4 không bao giờ.
- **Chặng 1.5 / link hai chiều / feed tin thật / Zalo Mini App / thương mại / J7
  — ĐÓNG, binding out of scope** của REQ-016.
- **OQ-2 — ĐÓNG ở tầng sản phẩm** và thuộc STORY-001.
- **Chỉ số ăn khớp và bảng tra 144/256 ô — không mở, đã phân công** cho STORY-010
  (BR-13).
- **SB-144/145/146 (trò chơi "đoán") — HOÃN**, không gán vào story này, dù nó là
  story gần nhất về chủ đề.
- **Số lượng câu hỏi, cách nhóm câu hỏi thành các phần chân dung, và luật ánh xạ
  câu trả lời → đoạn nội dung** — giao **Tech Lead** chốt trong gói dữ liệu tra
  cứu. Ràng buộc sản phẩm: tất định, ship kèm app, không AI, và mọi phần kết bằng
  một câu-để-hỏi.
- **Chi tiết trình bày** (nhãn xuất xứ hiện thị giác thế nào để đạt BR-2, bố cục
  bộ câu hỏi, cách hiện chân dung mỏng, vị trí liên kết trong luồng quà) — giao
  **UI/UX Designer trong phạm vi story này**. BR-2 là **ràng buộc sản phẩm**
  UI/UX phải thoả, không phải gợi ý; cách thoả nó là quyết định UX.

## Traceability

| AC | Nguồn ràng buộc |
|----|-----------------|
| AC-1..AC-4 | R-13 / SC-6 khoá vị trí, cửa vào từ luồng (5) STORY-004 |
| AC-5 | Phụ thuộc một chiều với STORY-008, tiền lệ STORY-006 BR-11 |
| AC-6..AC-9 | Đặc tả C.8 "ghi rõ xuất xứ", BR-2, R-1e tầng 2 |
| AC-10..AC-15 | R-1e ba tầng, R-1a, R-1(b), R-1(c), R-1(d-sai) |
| AC-16..AC-19 | R-1g và bài kiểm tra nghiệm thu của nó, ranh giới R-1e cấm dẫn dắt |
| AC-20..AC-24 | R-1b (sở thích+sự kiện ✅ / tần suất+hành vi ❌), R-1f, STORY-004 sổ tay |
| AC-25..AC-28 | SC-3 không điền trước, R-1c/R-1d cửa sạch, R-1 cấm (f), R-14 |
| AC-29..AC-30 | R-7 không AI ở runtime, không dịch vụ ngoài |
| AC-31 | SB-123 kiểm duyệt hai lớp (chất lượng biên tập); OQ-3 ĐÃ ĐÓNG bằng D-15; tiền lệ STORY-002 AC-23/AC-24 |
| AC-32 | Cổng cứng REQ-016 |
| AC-33 | R-15a — schema + id bền, đổi nguồn sang CMS không sửa code |
| AC-34, AC-35 | R-15b — N là thuộc tính dữ liệu; hành vi hết-vòng đúng với mọi N; R-1 cấm (f), cấm % |
| AC-36, AC-37 | R-15c — cổng nhập chạy được; R-1b (đầu ra và đầu vào), R-1e, R-1g, cấm %, cấm streak |
| BR-15..BR-17 | D-15 / R-15 (`req_master.md` mục 15) |
