# Story Requirements: STORY-012 Trạng thái theo pha, widget, và bộ đếm "của cải đang lớn"

- Requirement: REQ-016
- Story: STORY-012
- Complexity: complex
- Story-Class: standard
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: STORY-001 (bắt buộc) · STORY-003, STORY-004, STORY-006 (làm giàu
  tuỳ chọn, suy giảm êm)
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules` (R-1 cấm (f), R-1b,
  R-1c/R-1d, R-1e, R-1g, R-7, R-14), `## Out of Scope`, `## Open Questions`;
  `../../requirements/requirements.md` → `## Story Index`,
  `## Open Question Triage` (L45 — story chịu tải định vị "kho tài sản"),
  `## Coverage Map`;
  `../../STORY-001_activity_card_hub/requirements/requirements.md` →
  hợp đồng thẻ (AC-8), bốn ngăn/vòng đời (AC-10..AC-12), cờ *đã trả lời / chưa
  trả lời* (AC-17), cấm chỉ báo hành vi người kia (AC-18), cấm streak (AC-20),
  và **AC-22 giao bộ đếm "của cải đang lớn" cho story này**;
  `../../STORY-006_before_you_go_checklist/requirements/requirements.md` →
  **AC-24 / BR-11: STORY-006 PHÁT trạng thái pha "trước giờ đi", story này VẼ**

## Business Outcome

Người dùng dùng app **1-2 lần một tuần** vẫn được **nhắc đúng lúc cần** mà
không bị làm phiền, và mỗi lần mở đều thấy **"của cải" của mình đang lớn dần**
— một lý do quay lại **không phụ thuộc vào việc có ai đang chờ trả lời**.

Story này phủ **J4, J5, J10** và mặt user-visible duy nhất của **J12 (nhận
diện cột mốc)**. Nó là **bề mặt VẼ**: nó tiêu thụ trạng thái pha do story khác
phát ra và trạng thái thẻ do STORY-001 sở hữu. Nó **không** định nghĩa pha mới
cho story khác và **không** yêu cầu story nào phải đổi để nó chạy được.

Đây là một trong **ba story chịu tải cho định vị "chặng 1 là KHO TÀI SẢN"**
(cùng STORY-001 và STORY-013). Bộ đếm "của cải đang lớn" chính là câu trả lời
sản phẩm cho L45/OQ-18: lý do quay lại là **N3 — tài sản đang lớn**, không phải
**N7 — có người đang chờ trả lời** (N7 nằm ngoài phạm vi REQ-016).

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ.** Mọi pha đọc từ **thẻ của chính người dùng**. Bộ đếm đếm
**tài sản của chính người dùng**. Không AC nào cần người kia trả lời, xác nhận,
hay tồn tại trong hệ thống.

### Rủi ro chính: hai cú trượt, cả hai đều vi phạm luật bất biến

1. **Trượt sang đo lường người kia.** Pha "đang đợi" là nơi cám dỗ lớn nhất:
   thêm "đã xem", thêm "gửi 2 ngày trước, thường thì...", thêm bất kỳ ước lượng
   nào về người kia. **R-1b cấm.** Nguồn dữ liệu hợp lệ duy nhất về phản hồi là
   cờ *đã trả lời / chưa trả lời* do chính người dùng bấm (STORY-001 AC-17).
   SB-83 tồn tại đúng để chặn cú này: **"đừng đoán — chuẩn bị"**.
2. **Trượt sang streak.** Một bộ đếm là thứ dễ biến thành chuỗi ngày nhất trong
   cả requirement. **R-1 cấm (f) nguyên vẹn.** Ranh giới cứng: bộ đếm đếm
   **tài sản tích luỹ**, không bao giờ đếm **ngày liên tiếp**, và **không bao
   giờ giảm vì người dùng vắng mặt**. Nhóm G và BR-5/BR-6/BR-7 là tiêu chí
   nghiệm thu cho đúng điều đó.

## Scope

### In Scope

1. **SB-83 "Đừng đoán — chuẩn bị" (J4)**: khi có thẻ đã rủ mà người dùng đánh
   dấu *chưa trả lời*, màn (1) hướng sang **một việc chuẩn bị cụ thể**, không
   hướng sang việc phỏng đoán người kia.
2. **SB-84 widget theo pha**: widget màn hình chính của hệ điều hành đổi nội
   dung theo pha của thẻ gần nhất — *đang đợi · sắp hẹn · đúng ngày hẹn ·
   khoảng lặng*.
3. **SB-86 đếm ngược** tới ngày hẹn trên thẻ *Đã hẹn ngày*.
4. **SB-85 "về tới nhà chưa?" (J8)**: một nhắc nhẹ khoảng 23h tối ngày hẹn, dẫn
   **vào trong** — cất ảnh và viết một câu vào nhật ký (STORY-003).
5. **SB-87 "món quà đang lớn"**: hiển thị tiến triển của một ý tưởng quà cần
   thời gian, trong khoảng lặng giữa hai lần hẹn (J10).
6. **SB-99 nhỏ giọt**: nội dung nhỏ giọt trong khoảng lặng, **tần suất thấp**.
7. **Bộ đếm "của cải đang lớn"** trên màn (1) (STORY-001 AC-22 giao): kho đang
   lớn tới đâu. Đây là **mặt user-visible duy nhất của việc nhận diện cột mốc
   J12** trong REQ-016.
8. **Thông báo là nhắc nhẹ (D-1)**: đủ mạnh để thấy, không phải báo thức thật,
   **tắt được toàn bộ**, và bỏ qua thì thôi hẳn.

### Out of Scope

- **Tự thực hiện lời mời cài app khi chạm cột mốc J12** — chặng 1.5, ngoài
  phạm vi. REQ-016 dừng ở chỗ *nhận ra* cột mốc.
- **Guardrail payload SB-125** — thuộc **STORY-002**, không phải story này.
- **Streak, chuỗi ngày, huy hiệu, bảng xếp hạng, mục tiêu số** — R-1 cấm (f).
- **Mọi chỉ báo hành vi người kia**: "đã xem", giờ mở, số lần mở, tần suất trả
  lời, ước lượng thời gian trả lời — R-1b cấm.
- **Báo thức thật, thông báo cưỡng bức không tắt được, thông báo lặp lại khi
  người dùng đã bỏ qua.**
- **Nội dung nhỏ giọt hằng ngày** để thúc mở app — mâu thuẫn "không tối ưu
  DAU".
- **Khối "Trước giờ đi" (STORY-006) và "Cảm ơn + chốt việc kế tiếp"
  (STORY-007)** — story này chỉ **phản chiếu** pha của chúng.
- **Định nghĩa pha mới buộc story khác phải phát ra** — vi phạm phụ thuộc một
  chiều (BR-1).
- **Chặng 1.5, link hai chiều, feed tin thật, Zalo Mini App, thương mại quà,
  J7** — binding out of scope của REQ-016.

## Acceptance Criteria

### Nhóm A — Phụ thuộc một chiều: story này VẼ, không PHÁT

**AC-1.** Given STORY-006 phát ra trạng thái pha "trước giờ đi" (STORY-006
AC-24), when pha đó tồn tại, then story này **đọc** và vẽ nó lên widget, và
**không** yêu cầu STORY-006 thay đổi hợp đồng của nó (BR-11 bên STORY-006).

**AC-2.** Given STORY-006 **chưa** được giao, when người dùng dùng story này,
then pha thứ tư suy biến gọn gàng về pha "đúng ngày hẹn" suy từ trường *ngày
hẹn* trên thẻ (STORY-001 AC-8), và **mọi AC còn lại vẫn đạt được**.

**AC-3.** Given toàn bộ REQ-016, when kiểm tra phụ thuộc, then **không story
nào** cần STORY-012 để chạy được. Story này là bề mặt vẽ; gỡ nó ra không làm
hỏng story nào khác.

**AC-4.** Given bất kỳ pha nào, when nó được suy ra, then nguồn dữ liệu **duy
nhất** hợp lệ là: trạng thái thẻ và các trường thẻ do STORY-001 sở hữu (AC-8,
AC-10, AC-11), cờ *đã trả lời / chưa trả lời* do người dùng bấm (STORY-001
AC-17), và trạng thái pha do story khác phát ra (AC-1). Story này **không** tạo
trường mới trên thẻ và **không** đổi hợp đồng thẻ.

### Nhóm B — SB-83 "Đừng đoán — chuẩn bị" (J4)

**AC-5.** Given có một thẻ đã rủ mà người dùng đánh dấu *chưa trả lời*, when họ
mở màn (1), then app hướng họ sang **một việc chuẩn bị cụ thể, làm được ngay**.

**AC-6.** Given pha "đang đợi", when nội dung pha hiển thị, then **không** có
bất kỳ suy đoán nào về người kia: không "có lẽ người ấy đang bận", không ước
lượng thời gian trả lời, không so sánh với những lần trước, không thống kê nào
(R-1b, SB-83).

**AC-7.** Given pha "đang đợi" kéo dài nhiều ngày, when người dùng mở app, then
app **không** đếm số ngày đợi, **không** leo thang nội dung nhắc, và **không**
gợi ý người dùng nhắn thúc.

**AC-8.** Given người dùng bấm *đã trả lời*, when cờ đổi, then pha cập nhật
theo; và cờ đó **chỉ** đổi khi chính người dùng bấm (STORY-001 AC-17).

### Nhóm C — SB-84 widget theo pha

**AC-9.** Given người dùng tự thêm widget theo cơ chế của hệ điều hành, when
widget hiển thị, then nội dung khớp **pha của thẻ gần nhất** trong bốn pha:
*đang đợi · sắp hẹn · đúng ngày hẹn · khoảng lặng*. Mỗi pha hiển thị một **nhãn-mí
pha** (eyebrow) kèm một **chỉ báo pha riêng của pha**. Chữ nhãn-mí lấy từ gói nội
dung đã ship (AC-37) và chỉ là **tên pha chung chung** — không giờ, không đếm
ngày, không tên thẻ, không gì về người kia (AC-7, AC-11, AC-12). Vá 2026-09-17:
thêm nhãn-mí pha + chấm màu theo pha; thiết kế là mốc chuẩn; đóng D-10. Vá
2026-09-25: chỉ báo pha là **chấm màu đặc** ở ba pha *đang đợi · sắp hẹn ·
khoảng lặng*, và là **glyph tia chớp** ở pha *đúng ngày hẹn* (canvas
`sb-84-widget-bon-pha`); hình dạng của từng token do
`architecture/contract-summary.md` §3a định, không lặp lại ở đây; đóng D-13.

**AC-10.** Given thẻ gần nhất chuyển từ "sắp hẹn" sang "đúng ngày hẹn", when
widget làm mới, then nội dung widget đổi sang pha thứ tư, phản chiếu khối
"Trước giờ đi" (AC-1/AC-2).

**AC-11.** Given widget nằm trên màn hình người khác nhìn thấy được, when nó
hiển thị, then nó **không** hiển thị nội dung nhật ký (STORY-003 riêng-tư-mặc-
định), **không** hiển thị nội dung sổ tay, và **không** hiển thị nhận định nào
về người kia (R-1f, R-1e).

**AC-12.** Given bất kỳ pha nào trên widget, when nó hiển thị, then nó chỉ phản
ánh **thẻ của người dùng** — không một chỉ báo nào về hành vi người kia (R-1b).

**AC-13.** Given người dùng **không** thêm widget, when họ dùng app, then toàn
bộ tính năng còn lại vẫn đầy đủ. Widget là bề mặt bổ trợ, không phải điều kiện.

### Nhóm D — SB-86 đếm ngược

**AC-14.** Given một thẻ *Đã hẹn ngày* có ngày trong tương lai, when người dùng
xem thẻ, then có **đếm ngược** tới ngày hẹn.

**AC-15.** Given ngày hẹn đã qua mà thẻ chưa đổi trạng thái, when người dùng
xem thẻ, then app hiển thị trung tính và **không** trách móc, không đếm ngày
trễ, không hối thúc (R-1c/R-1d).

### Nhóm E — SB-85 "về tới nhà chưa?" (J8, hướng vào trong)

**AC-16.** Given hôm nay là ngày hẹn của một thẻ, when tới **khoảng 23h**, then
app gửi **một** nhắc nhẹ "về tới nhà chưa?" dẫn tới **cất ảnh** và **viết một
câu vào nhật ký**. Nhắc mở một **màn check-in dạng modal toàn màn hình**, chỉ
tới được từ nhắc 23h — không phải một đích điều hướng mới, không phải "màn 12",
nhất quán với "Direct URL: N/A". Khối ngữ cảnh chỉ đọc **tên buổi hẹn** từ các
trường thẻ STORY-001 (BR-12); đọc không được thì bỏ khối đó, không bao giờ chặn
màn. Có **ba ô ảnh tuỳ chọn**. Có hai **chip mô tả không bấm được**: một chip
nói câu viết được lưu vào **nhật ký**, một chip nói chỉ người dùng đọc được. Câu
viết **không bao giờ** được ghi vào **sổ tay** (STORY-004). Vá 2026-09-17: màn
check-in modal, khối ngữ cảnh, ba ô ảnh, hai chip mô tả; chữ chip canvas "+ ghi
vào sổ tay" không áp dụng — một hành động ghi thật sang sổ tay STORY-004 là
requirement riêng, chờ user xác nhận có mở hay không; thiết kế là mốc chuẩn;
đóng D-6 (gồm D-7/D-8/D-9).

**AC-17.** Given người dùng bỏ qua nhắc ở AC-16, when thời gian trôi, then app
**không nhắc lại** về buổi hẹn đó — bỏ qua thì thôi hẳn. Dòng trấn an ở chân màn
check-in chỉ được hứa điều AC-17/BR-10 bảo đảm (không nhắc lại). Vá 2026-09-17:
giới hạn lời hứa của dòng trấn an chân màn; thiết kế là mốc chuẩn; đóng D-6 (gồm
D-7/D-8/D-9).

**AC-18.** Given STORY-003 (nhật ký) chưa được giao, when nhắc ở AC-16 kích
hoạt, then cửa ra "viết một câu" suy biến gọn gàng và phần cất ảnh vẫn dùng
được; nhắc này **không** chặn vì thiếu STORY-003. Chip "lưu vào nhật ký" (AC-16)
ẩn **cùng lúc** với cửa ra "viết một câu". Vá 2026-09-17: chip nhật ký ẩn theo
cửa ra "viết một câu"; thiết kế là mốc chuẩn; đóng D-6 (gồm D-7/D-8/D-9).

**AC-19.** Given nội dung của nhắc này, when người dùng đọc, then nó hỏi **về
người dùng** ("về tới nhà chưa?"), **không** hỏi về người kia và không yêu cầu
người dùng đánh giá buổi hẹn hay đánh giá người kia (J8 hướng vào trong).

### Nhóm F — SB-87 "món quà đang lớn" và SB-99 nhỏ giọt (J10, khoảng lặng)

**AC-20.** Given người dùng có một ý tưởng quà cần thời gian (từ luồng
STORY-004), when họ ở trong khoảng lặng giữa hai lần hẹn, then app hiển thị
**tiến triển của chính việc người dùng đang làm**, không phải một dự đoán về
phản ứng của người kia.

**AC-21.** Given STORY-004 chưa được giao hoặc người dùng không có ý tưởng quà
nào đang chạy, when họ ở khoảng lặng, then bề mặt "món quà đang lớn" **không
hiện**, và đó là trạng thái đúng chứ không phải lỗi — app **không** dùng chỗ
trống này để thúc người dùng tạo dữ liệu.

**AC-22.** Given khoảng lặng, when nội dung nhỏ giọt xuất hiện, then tần suất
là **thấp** và **không bao giờ hằng ngày** (BR-9).

**AC-23.** Given bất kỳ nội dung nhỏ giọt nào, when người dùng đọc, then nó nói
về **tài sản và việc làm được của chính người dùng**, không nói về người kia và
không đưa ra nhận định nào về người kia (R-1b, R-1e).

### Nhóm G — Bộ đếm "của cải đang lớn" (J12 nhận diện, chống streak)

**AC-24.** Given người dùng có nhiều thẻ đã chuyển *Đã thành kỷ niệm* theo thời
gian, when họ mở màn (1), then bộ đếm "của cải đang lớn" phản ánh **đúng** số
đó và tăng lên khi có thêm kỷ niệm.

**AC-25.** Given bộ đếm, when giá trị của nó được tính, then nó là **lực lượng
của một tập tài sản bền** (số thẻ/kỷ niệm đã tích luỹ) — **không** phải hàm của
thời gian, **không** phải số ngày liên tiếp, **không** phải nhịp độ hoạt động
(R-1 cấm (f)).

**AC-26.** Given người dùng **không mở app trong nhiều ngày hoặc nhiều tuần**,
when họ mở lại, then bộ đếm **giữ nguyên giá trị**, và app **không** hiển thị
nội dung trách móc, không đếm ngày vắng, không "chuỗi bị đứt", không phục hồi
chuỗi.

**AC-27.** Given bộ đếm hiển thị, when người dùng đọc, then **không** có mục
tiêu số, không có thanh tiến độ tới một cột mốc bắt buộc, không có hạn chót, và
không có so sánh với người dùng khác (R-1 cấm (f)).

**AC-28.** Given người dùng chạm một cột mốc tích luỹ, when app nhận ra, then
app **dừng ở chỗ hiển thị** cột mốc đó cho người dùng. App **không** đề nghị mời
người kia cài app và **không** mở bất kỳ luồng hai chiều nào — chặng 1.5 ngoài
phạm vi.

**AC-29.** Given người dùng xoá một thẻ, when bộ đếm cập nhật, then nó phản ánh
trung thực kho hiện tại, và app **không** kịch tính hoá việc giảm — không cảnh
báo, không hỏi lý do, không thông điệp cảm xúc (R-1c/R-1d, STORY-001 AC-16).

### Nhóm H — Thông báo nhắc nhẹ (D-1)

**AC-30.** Given người dùng **tắt thông báo** của app, when các mốc nhắc tới,
then app **không gửi thông báo nào**, và **mọi tính năng còn lại vẫn dùng được
bình thường**.

**AC-31.** Given bất kỳ thông báo nào của story này, when nó được gửi, then nó
là **nhắc nhẹ**: không âm báo thức, không toàn màn hình, không lặp lại, không
yêu cầu thao tác để tắt.

**AC-32.** Given người dùng muốn chỉnh, when họ vào cài đặt, then họ tắt được
**từng loại nhắc** của story này một cách độc lập, không phải chấp nhận trọn
gói.

### Nhóm I — Ranh giới đạo đức, tất định, và cổng cứng

**AC-33.** Given bất kỳ bề mặt nào của story này (màn (1), widget, thông báo),
when nó hiển thị, then app **không** hiển thị và **không** lưu bất kỳ chỉ báo
hành vi nào của người kia (R-1b, STORY-001 AC-18).

**AC-34.** Given bất kỳ nội dung pha hoặc nội dung nhỏ giọt nào, when nó được
sinh, then nó đến từ **preset / bảng tra ship kèm app**, tất định, và app
**không** gọi mô hình AI, **không** gọi API ngoài nào (R-7).

**AC-35.** Given người dùng duyệt toàn app, when họ tìm chỉ số gắn kết, then
**không** có streak, chuỗi ngày, huy hiệu, hay bảng xếp hạng nào (R-1 cấm (f)),
và **không** phần nào của story nằm sau paywall (R-14).

**AC-36.** Given người kia **chưa từng và sẽ không bao giờ** tham gia, when
người dùng dùng story này, then **mọi** AC ở trên vẫn đạt được (cổng cứng).

### Nhóm J — Nội dung là dữ liệu có cổng nhập (R-15 / D-15)

**AC-37.** Given nội dung theo pha, nội dung nhắc, và nội dung nhỏ giọt (AC-34),
when chúng được ship, then chúng là **gói dữ liệu có lược đồ và định danh bền
cho từng mục**, không phải chuỗi cứng trong **widget**/code. Ràng buộc này cắn
mạnh nhất ở đây vì bề mặt chính của story là một widget: chuỗi nằm trong mã
widget là vi phạm trực tiếp. Đổi nguồn nội dung sang CMS ngoài repo **không kéo
theo một lần sửa code** (R-15a). **Nhãn-mí pha** (AC-9) là một trường mới của
mỗi mục pha trong gói nội dung, có id bền — không bao giờ là chuỗi trong mã
widget/native (Android XML, iOS Swift, cầu nối Dart). **Chỉ báo pha** (chấm màu
đặc ở ba pha, glyph tia chớp ở pha *đúng ngày hẹn* theo D-13) là design token
theo pha, không phải nội dung — kể cả khi nó là glyph, nó vẫn là token, không
phải một mục nội dung phải nằm trong gói. Vá 2026-09-17: thêm trường nhãn-mí
pha và phân loại chấm màu là token; thiết kế là mốc chuẩn; đóng D-10.

**AC-38.** Given kho nội dung nhỏ giọt có **N mục bất kỳ** (N ≥ 0), when khoảng
lặng kéo dài tới lúc duyệt hết kho, then hành vi hết-tập là **im lặng** — đúng
trạng thái rỗng đã định ở AC-21 — **không** thông báo "đã hết", **không** màn
ngõ cụt, **không** hạ trần tần suất BR-9 để lấp chỗ trống, và **không** chỉ báo
tiến độ hay số mục còn lại dưới bất kỳ dạng nào. Luật này đúng với mọi N, và
**không** AC nào của story này được suy ra từ số mục của bộ seed (R-15b).

**AC-39.** Given một mục nội dung pha / nhắc / nhỏ giọt vi phạm luật bất biến —
nói **về người kia** hay đưa nhận định về người kia (R-1b, R-1e, AC-23), tâng
bốc, hiển thị %, hoặc streak/chuỗi ngày (AC-35) — when mục đó được nạp qua cổng
nhập nội dung, then cổng **từ chối mục đó và làm hỏng bản dựng**. Đây là cách
BR-14 chuyển từ **ranh giới biên tập** thành **quy tắc chạy được**: điều kiện
giữ story này ngoài phạm vi nội dung-nói-về-người-kia nay được cưỡng chế tự
động, không phụ thuộc người soạn nội dung tương lai (R-15c).

## Business Rules

- **BR-1 (phụ thuộc một chiều — story này VẼ).** STORY-006 **định nghĩa và phát
  ra** trạng thái pha "trước giờ đi" (AC-24 / BR-11 bên đó); story này **vẽ** nó.
  Story này **không** được yêu cầu story khác phát thêm trạng thái, đổi hợp đồng,
  hay chờ nó. Và không story nào được phép phụ thuộc ngược vào STORY-012 (AC-3).
- **BR-2 (suy giảm êm là hành vi đúng).** Thiếu STORY-003, STORY-004, hoặc
  STORY-006 thì phần liên quan **biến mất gọn gàng**, không hiện trạng thái lỗi,
  không hiện chỗ trống mời gọi. Đây là ràng buộc thiết kế, không phải xử lý
  ngoại lệ.
- **BR-3 (R-1b — nguồn dữ liệu phản hồi duy nhất).** Chỉ cờ *đã trả lời / chưa
  trả lời* do chính người dùng bấm (STORY-001 AC-17). Cấm lưu, tính, suy ra,
  hiển thị, hoặc **suy đoán** bất kỳ đại lượng hành vi nào của người kia — kể cả
  khi nó chỉ dùng nội bộ để chọn nội dung pha.
- **BR-4 (SB-83 — pha "đang đợi" nói về VIỆC, không nói về NGƯỜI).** Nội dung
  pha đợi phải là **một việc người dùng tự làm được**. Bài kiểm tra: bỏ hoàn
  toàn sự tồn tại của người kia ra khỏi câu, câu đó còn đứng được không? Nếu
  không, câu đó vi phạm SB-83.
- **BR-5 (bộ đếm = lực lượng tập, không phải hàm thời gian).** Giá trị bộ đếm
  được định nghĩa **duy nhất** là số phần tử của một tập tài sản bền do người
  dùng tích luỹ. Bất kỳ công thức nào có tham số thời gian, ngày liên tiếp,
  nhịp độ, hay khoảng cách giữa hai lần hoạt động đều là **streak trá hình** và
  bị R-1 cấm (f).
- **BR-6 (bộ đếm không bao giờ phạt sự vắng mặt).** Không hoạt động **không**
  làm bộ đếm giảm, không làm nó xám đi, không sinh thông báo, không sinh nội
  dung nhắc. Bộ đếm chỉ giảm khi **người dùng chủ động xoá** tài sản (AC-29).
- **BR-7 (bộ đếm không có đích).** Không mục tiêu, không thanh tiến độ, không
  cột mốc bắt buộc, không phần thưởng. Nó **mô tả**, không **thúc**. Đây là
  điểm phân biệt "kho tài sản" (N3) với cơ chế gắn kết mà R-1 cấm.
- **BR-8 (J12 dừng ở NHẬN RA).** REQ-016 chỉ **nhận ra** cột mốc và hiển thị nó.
  Việc biến cột mốc thành hành động mời cài app thuộc **chặng 1.5**, ngoài phạm
  vi. Guardrail payload SB-125 thuộc **STORY-002**, không phải story này.
- **BR-9 (trần tần suất nhỏ giọt).** Nội dung nhỏ giọt trong khoảng lặng **tối
  đa một lần mỗi tuần** và **không bao giờ hằng ngày**. Con số này là **ràng
  buộc sản phẩm** khớp tần suất thật của người dùng (1-2 lời mời một tuần);
  Tech Lead và UI/UX không được nới nó để "tăng tương tác".
- **BR-10 (bỏ qua thì thôi hẳn).** Mọi nhắc của story này chỉ kích hoạt **một
  lần** cho một sự kiện. Không leo thang, không nhắc lại, không nhắc bù khi mở
  app sau đó (R-1c/R-1d, cùng tinh thần SB-212 của STORY-007).
- **BR-11 (widget là bề mặt công cộng).** Widget có thể bị người khác nhìn thấy.
  Vì vậy nó chịu ràng buộc chặt hơn màn trong app: không nội dung nhật ký,
  không nội dung sổ tay, không nhận định về người kia (AC-11). Trường cụ thể
  nào được lên widget do UI/UX chốt **trong** ràng buộc này.
- **BR-12 (hợp đồng thẻ STORY-001, chỉ đọc).** Story này đọc trạng thái và
  trường thẻ đã khoá ở STORY-001. Nó **không** thêm trường, **không** đổi vòng
  đời thẻ, và **không** tự chuyển trạng thái thẻ thay người dùng.
- **BR-13 (R-7 — tất định, không AI).** Mọi nội dung pha, nội dung nhắc, và nội
  dung nhỏ giọt đến từ preset/bảng tra ship kèm app. Cùng đầu vào → cùng đầu ra.
  Không AI runtime, không API ngoài.
- **BR-14 (nội dung của story này không nói về người kia).** Đây là ranh giới
  giữ story này **ngoài** phạm vi kiểm duyệt hai lớp của OQ-3: nội dung ở đây là
  app nói với người dùng về **tài sản và việc của chính người dùng**. Nếu một
  dòng nội dung nào trượt sang nói **về người kia**, nó vừa vi phạm BR-4/AC-23,
  vừa lập tức kế thừa ràng buộc kiểm duyệt hai lớp (SB-123). Sau D-15, ranh giới
  này **không** còn chỉ là quy ước biên tập: nó là quy tắc cổng nhập chạy được
  (AC-39, BR-17).
- **BR-15 (R-15a — nội dung là dữ liệu, không phải chuỗi trong code).** Nội dung
  pha, nội dung nhắc, và kho nhỏ giọt là gói dữ liệu có lược đồ, mỗi mục có **id
  bền**. Cấm chuỗi nội dung nằm trong mã **widget**/code — ràng buộc gắt nhất
  của story này, vì widget là nơi dễ nhúng chuỗi cứng nhất. Tiêu chí nghiệm thu:
  đổi nguồn sang CMS ngoài repo mà **không sửa một dòng code nào**. Nhãn-mí pha
  là trường của mỗi mục pha, có id bền, cấm nằm trong mã widget/native (Android
  XML, iOS Swift, cầu nối Dart); chỉ báo pha là design token, không phải nội
  dung — dù vẽ bằng chấm màu đặc hay bằng glyph tia chớp (pha *đúng ngày hẹn*,
  D-13), nó vẫn là token, nên không kéo theo mục nội dung mới nào trong gói. Vá
  2026-09-17: nhãn-mí pha là dữ liệu, chấm màu là token; thiết kế là mốc chuẩn;
  đóng D-10.
- **BR-16 (R-15b — N là thuộc tính dữ liệu).** Số mục kho nhỏ giọt và số biến
  thể nội dung mỗi pha là dữ liệu bản đầu, **không** phải hằng số của story; bộ
  seed 10 mục cho gói **xoay vòng** là giá trị bản đầu. Cấm mọi AC, BR, hay bố
  cục dựa vào "vì có đúng 10 mục nên…" — đặc biệt hành vi hết-tập (AC-38) và chỉ
  báo tiến độ. **Trần tần suất BR-9 không phải N:** nó là ràng buộc sản phẩm
  cứng, và kho cạn **không bao giờ** là lý do nới nó.
- **BR-17 (R-15c — luật bất biến là CỔNG NHẬP, không phải quy ước biên tập).**
  R-1b, R-1e, ranh giới BR-14, chống tâng bốc, cấm hiển thị %, và cấm streak
  được cưỡng chế ở **tầng lược đồ/validation của cổng nhập nội dung**, chạy được
  trong bản dựng (AC-39). Lý do riêng của story này: nội dung ở đây trông vô hại
  nhất trong REQ-016, nên nó là chỗ dễ trượt nhất khi người soạn nội dung tương
  lai không đọc BR-14.

## System Integration And Discoverability

- **UI-facing story:** YES, gồm cả **bề mặt widget của hệ điều hành**.
- **Existing user-visible surface:** YES — màn (1), chi tiết thẻ, và nhật ký
  (khi STORY-003 đã giao). Story này **không** tạo màn hình thứ 12; nó là trạng
  thái đặc biệt của màn (1) cộng một widget hệ điều hành.
- **Điểm vào:** widget do **người dùng tự thêm** theo cơ chế của hệ điều hành;
  các pha còn lại **tự hiện** trong màn (1) mà người dùng không phải đi tìm.
  Direct URL only acceptable: **N/A** — không có destination riêng.
- **Hợp đồng story này TIÊU THỤ (chỉ đọc):** STORY-001 (AC-8 trường thẻ, AC-10
  bốn ngăn, AC-11 hành động chính, AC-17 cờ trả lời, AC-22 giao bộ đếm),
  STORY-006 (AC-24 pha "trước giờ đi", tuỳ chọn), STORY-003 (cửa ra nhật ký,
  tuỳ chọn), STORY-004 (ý tưởng quà đang chạy, tuỳ chọn).
- **Hợp đồng story này PHÁT RA:** **không có.** Story này là bề mặt cuối; nó
  không phát trạng thái cho story nào khác tiêu thụ (AC-3).
- **Ranh giới với STORY-002:** guardrail payload SB-125 thuộc STORY-002. Story
  này chỉ hiển thị **việc nhận ra** cột mốc (BR-8).
- **Tích hợp bên ngoài:** chỉ **cơ chế widget và cơ chế thông báo của hệ điều
  hành**. Không AI runtime, không dịch vụ nội dung, không nguồn dữ liệu ngoài
  (AC-34).

## Open Question Impact

### Scope Items BLOCKED in this story

- **NONE.** Story này **không** nằm trong danh sách story chịu kiểm duyệt hai
  lớp của OQ-3 ở tầng requirement (STORY-002/004/005/007/009/010/011), và lý do
  là ranh giới nội dung ở BR-14: nội dung ở đây là app nói với người dùng về
  **tài sản và việc của chính người dùng**, không phải nội dung có giọng điệu
  nói về người kia hay gửi cho người kia. Cùng tiền lệ STORY-006 BR-14 đã đặt
  cho nhãn chức năng. **Điều kiện của phán quyết này:** nếu kho nội dung nhỏ
  giọt (SB-99) hay nội dung pha trượt sang nói về người kia, nó vi phạm AC-23
  **trước**, và khi đó kế thừa luôn ràng buộc kiểm duyệt hai lớp (SB-123).
  Từ D-15, điều kiện này được cưỡng chế ở cổng nhập (AC-39), không còn phụ thuộc
  người soạn nội dung tự nhớ.

### Scope Items NOT BLOCKED in this story

- **L45 / OQ-18 — ĐÓNG** (user chốt 2026-09-03: chặng 1 là **kho tài sản**,
  không phải phòng chờ). Story này là **một trong ba story chịu tải** cho định
  vị đó: bộ đếm "của cải đang lớn" (N3) là lý do quay lại được chọn thay cho
  "có người đang chờ trả lời" (N7, ngoài phạm vi). Nếu L45 bị mở lại và **đổi**
  câu trả lời, story này phải **đổi khung**, không phải đổi ranh giới.
- **Trần giữ chân RS-D6 — rủi ro tồn dư được chấp nhận có ý thức.** Không được
  chữa bằng streak/bảng xếp hạng (R-1 cấm (f), BR-5..BR-7), không được chữa
  bằng vòng lặp xã hội (chặng 1.5, ngoài phạm vi). Đây là ràng buộc đóng, không
  phải câu hỏi mở của story này.
- **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 → luật R-15** (`req_master.md`
  mục 15). **Kiểm duyệt hai lớp vẫn không áp cho story này** (xem mục BLOCKED ở
  trên và BR-14) và story này chưa bao giờ bị chặn. Nhưng **R-15 thì có áp**:
  story này ship nội dung pha / nhắc / nhỏ giọt dạng preset (AC-34, BR-13), nên
  nó là **gói dữ liệu có schema + id bền**, cấm chuỗi cứng trong mã widget
  (R-15a); **N là thuộc tính dữ liệu**, kho nhỏ giọt cạn thì im lặng chứ không
  hạ trần tần suất BR-9 (R-15b); ranh giới BR-14 thành **quy tắc cổng nhập chạy
  được** (R-15c). Chi tiết: AC-37..AC-39, BR-15..BR-17. Đây là **mở rộng ràng
  buộc, không phải mở rộng phạm vi** — không màn, luồng, hay chức năng mới.
- **R-1b — ĐÓNG, luật bất biến.** "Chỉ *đã trả lời / chưa trả lời*" không mở lại
  dưới dạng "chỉ một chỉ báo nhỏ để widget thông minh hơn".
- **R-1 cấm (f) — ĐÓNG, luật bất biến.** Bộ đếm tích luỹ **không** phải một
  ngoại lệ của luật cấm streak; nó là **cách duy nhất** thoả luật đó mà vẫn cho
  người dùng lý do quay lại. BR-5/BR-6/BR-7 là định nghĩa vận hành của ranh
  giới này, không phải lời khuyên.
- **OQ-2 — ĐÓNG ở tầng sản phẩm**, thuộc STORY-001.
- **Chặng 1.5 / link hai chiều / feed tin thật / Zalo Mini App / thương mại /
  J7 — ĐÓNG, binding out of scope** của REQ-016.
- **Cơ chế làm mới widget, lịch chạy nhắc 23h theo múi giờ thiết bị, cách lưu
  trạng thái "đã nhắc rồi", định dạng gói nội dung nhỏ giọt, và ranh giới
  backend/mobile** — giao **Tech Lead**. Ràng buộc sản phẩm: tất định, ship kèm
  app, không AI, một sự kiện nhắc đúng một lần.
- **Chi tiết trình bày** (bộ đếm hiện ở đâu trên màn (1) để đọc như "tài sản"
  chứ không như điểm số, bố cục bốn pha trên widget, cách thể hiện đếm ngược,
  trường nào được lên widget trong ràng buộc BR-11) — giao **UI/UX Designer
  trong phạm vi story này**. AC-11, AC-25, và AC-27 là **ràng buộc sản phẩm**
  UI/UX phải thoả, không phải gợi ý.

## Traceability

| AC | Nguồn ràng buộc |
|----|-----------------|
| AC-1..AC-4 | STORY-006 AC-24/BR-11 phụ thuộc một chiều, hợp đồng thẻ STORY-001 |
| AC-5..AC-8 | SB-83 "đừng đoán — chuẩn bị" (J4), R-1b, STORY-001 AC-17 |
| AC-9..AC-13 | SB-84 widget theo pha, R-1b, R-1f, BR-11 widget là bề mặt công cộng, D-10 (2026-09-17) |
| AC-14..AC-15 | SB-86 đếm ngược, R-1c/R-1d không trách móc |
| AC-16..AC-19 | SB-85 "về tới nhà chưa?" (J8 hướng vào trong), STORY-003 tuỳ chọn, D-6 (2026-09-17) |
| AC-20..AC-23 | SB-87 "món quà đang lớn" (J10), SB-99 nhỏ giọt, BR-9 trần tần suất |
| AC-24..AC-29 | STORY-001 AC-22, J12 nhận diện cột mốc, R-1 cấm (f), BR-5..BR-8 |
| AC-30..AC-32 | D-1 nhắc nhẹ, tắt được toàn bộ, BR-10 bỏ qua thì thôi hẳn |
| AC-33..AC-36 | R-1b, R-7 không AI/không API ngoài, R-14, cổng cứng REQ-016 |
| AC-37 | R-15a — schema + id bền, cấm chuỗi cứng trong mã widget, D-10 (2026-09-17) |
| AC-38 | R-15b — N là thuộc tính dữ liệu; kho nhỏ giọt cạn thì im lặng, không nới BR-9 |
| AC-39 | R-15c — cổng nhập chạy được; BR-14, R-1b, R-1e, cấm %, cấm streak |
| BR-15..BR-17 | D-15 / R-15 (`req_master.md` mục 15) |
