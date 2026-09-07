# Story Requirements: STORY-011 Vỏ hoàng đạo / trắc nghiệm — màn (7)

- Requirement: REQ-016
- Story: STORY-011
- Complexity: standard
- Story-Class: standard
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: STORY-001 (hợp đồng thẻ, runtime) · STORY-004, STORY-005,
  STORY-008 (thứ tự giao hàng SB-174, không phải phụ thuộc runtime)
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules` (R-1/R-1a, R-1b, R-1e,
  R-1g, R-7, R-10, R-13, R-14, SB-174), `## Out of Scope`,
  `## Open Questions`;
  `../../requirements/requirements.md` → `## Story Index`,
  `## Open Question Triage`;
  `../../STORY-001_activity_card_hub/requirements/requirements.md` →
  hợp đồng thẻ (AC-8), nguồn sinh thẻ (AC-9), một hành động chính cấp thẻ
  (AC-11);
  `../../STORY-010_compatibility_lookup/requirements/requirements.md` →
  ranh giới: chỉ số ăn khớp và gói 400 ô thuộc STORY-010, màn này KHÔNG có
  (BR-12 bên đó);
  `../../STORY-006_before_you_go_checklist/requirements/requirements.md` →
  tiền lệ nhãn chức năng không bị OQ-3 chặn (BR-14)

## Business Outcome

Người dùng có **một cớ nhẹ nhàng** để bắt đầu — nhưng cái họ **mang đi được**
sau khi chơi là **ba việc làm được**, không phải một câu phán hay ho. Story này
phủ **J1** và là cửa vào nhẹ nhất của cả requirement: chi phí tham gia gần bằng
không, và mọi lần chơi đều kết thúc bằng thẻ nằm trong kho chung.

Đây là chỗ **duy nhất** trong REQ-016 mà app tự nguyện mặc một cái vỏ giải trí.
Vì thế nó cũng là chỗ dễ tuột tay nhất: một màn kết quả đẹp, đứng một mình, có
nút "chia sẻ" — và app đã thành **app bói toán có kèm to-do list**, đúng thứ
SB-174 cấm. Toàn bộ giá trị của story nằm ở **ràng buộc đầu ra**, không ở kỹ
thuật.

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ.** Người dùng tự chơi, tự nhận ba thẻ, tự đi. Người kia không
cần trả lời, không cần cài app, không cần biết. Nếu một AC chỉ đúng khi người
kia tham gia trắc nghiệm, AC đó sai phạm vi.

### Rủi ro chính: màn kết quả tự đứng được

Cám dỗ lớn nhất là ship một màn kết quả "đẹp" rồi để ba thẻ nằm sau một cú
chạm nữa, hoặc để một biến thể "chỉ xem kết quả". **SB-136 — vỏ, không phải
phán quyết.** Kết quả và ba thẻ là **một bề mặt**, không phải hai bước; nếu
tách ra, người dùng sẽ dừng ở bước một và story mất toàn bộ lý do tồn tại.
Nhóm B dưới đây là tiêu chí nghiệm thu cho đúng điều đó.

## Scope

### In Scope

1. Màn (7) "Vỏ hoàng đạo / trắc nghiệm", **nhóm CỬA VÀO**: có đường vào riêng
   từ menu chính. **Không** khoá vị trí — khác STORY-009 và STORY-010.
2. Nội dung preset **tất định**, ship kèm app, **không AI ở runtime** (R-7):
   các lát hoàng đạo và/hoặc các bộ trắc nghiệm ngắn.
3. **Kết quả LUÔN kết thúc bằng đúng 3 thẻ hoạt động đề xuất** trên **cùng một
   bề mặt kết quả** — không bao giờ có biến thể chỉ hiện nhận định (SC-2,
   SB-136).
4. Đẩy thẻ đã chọn vào màn (1), trạng thái *Mới nghĩ ra*, theo hợp đồng thẻ
   STORY-001.
5. **Đầu vào tự khai** (R-1a, R-1e): dấu hoàng đạo của mình và của người kia,
   hoặc câu trả lời trắc nghiệm, do chính người dùng ghi hoặc đoán.
6. **R-1g** — mọi đoạn nội dung nói về người kia kết thúc bằng **một câu để hỏi
   người thật**.
7. **R-10 định vị**: ngôn ngữ giữ app ở vị trí "trợ lý hoạt động", không trượt
   sang "app bói toán".
8. Nội dung **tham chiếu sổ tay** (STORY-004) để bớt chung chung, **suy giảm êm**
   khi sổ tay rỗng.
9. **Kiểm duyệt nội dung hai lớp** (SB-123) cho toàn bộ kho nội dung.
10. Hoạt động **đầy đủ khi không có mạng**.

### Out of Scope

- **Kết quả trắc nghiệm đứng một mình, không kèm 3 thẻ** — vi phạm SC-2 và
  SB-136. Đây là ranh giới cứng, không phải tuỳ chọn cấu hình.
- **Chấm điểm, xếp hạng, hay bất kỳ nhận định định lượng nào về người kia** —
  R-1e tầng 3 cấm.
- **Chỉ số ăn khớp và gói tra cứu 144/256 ô** — thuộc **STORY-010**, và
  STORY-010 khoá vị trí. Màn này **không** hiển thị chỉ số ăn khớp ở bất kỳ
  dạng nào.
- **Chân dung "theo cách BẠN nhìn"** — STORY-009.
- **Vận mệnh / tử vi hằng ngày**, nội dung đổi mỗi ngày để tạo thói quen mở app
  — mâu thuẫn "không tối ưu DAU" và R-1 cấm (f).
- **Trò chơi "đoán" không thắng thua** (SB-144/145/146) — HOÃN, chưa có màn chủ.
- **Kênh gửi kết quả cho người kia** — việc rủ đi qua thẻ (STORY-001) và xuất
  lời mời (STORY-002). Story này không tự tạo kênh gửi.
- **Chặng 1.5, link hai chiều, feed tin thật, Zalo Mini App, thương mại quà,
  J7** — binding out of scope của REQ-016.

## Acceptance Criteria

### Nhóm A — Cửa vào và định vị

**AC-1.** Given người dùng ở menu chính, when họ tìm màn (7), then có **một
đường vào riêng, thấy được** dẫn tới nó (nhóm CỬA VÀO). Story này **không** áp
luật khoá vị trí R-13 — luật đó chỉ áp cho STORY-009 và STORY-010.

**AC-2.** Given người dùng vào màn (7) lần đầu, when họ bắt đầu, then họ chơi
được **ngay**, không phải điền hồ sơ trước, không phải hoàn tất thiết lập nào
(SC-3).

**AC-3.** Given người dùng bỏ dở giữa chừng, when họ quay lại, then không có nội
dung trách móc, không đếm lần bỏ dở, và họ bắt đầu lại được sạch sẽ
(R-1c/R-1d).

### Nhóm B — SC-2 / SB-136: vỏ, không phải phán quyết

**AC-4.** Given người dùng hoàn tất một lát hoàng đạo hoặc một trắc nghiệm,
when kết quả hiện ra, then màn kết quả kèm **đúng 3 thẻ hoạt động đề xuất** —
không phải 1, không phải 5, không phải "một vài".

**AC-5.** Given bất kỳ đường đi nào tới màn kết quả, when kết quả hiện ra, then
ba thẻ đề xuất nằm trên **cùng bề mặt kết quả** với nhận định, **không** nằm sau
một cú chạm nữa, không nằm ở màn tiếp theo, và không nằm sau một mục "xem thêm"
đóng sẵn (SB-136).

**AC-6.** Given toàn bộ nội dung của story này, when kiểm tra mọi biến thể kết
quả, then **không tồn tại** biến thể nào chỉ hiện nhận định mà không có ba thẻ.
Một biến thể như vậy là **lỗi**, không phải một trạng thái hợp lệ.

**AC-7.** Given màn kết quả, when người dùng chọn một trong ba thẻ đề xuất, then
thẻ đó xuất hiện ở màn (1), trạng thái *Mới nghĩ ra*, theo hợp đồng thẻ
STORY-001 AC-8 với **tiêu đề là trường bắt buộc duy nhất**.

**AC-8.** Given thẻ vừa tạo ở AC-7, when nó được lưu, then nó mang **nguồn
sinh** đọc được (STORY-001 AC-9), và nguồn sinh đó **không bao giờ** hiển thị
như một chỉ số đánh giá người dùng hay người kia.

**AC-9.** Given ba thẻ đề xuất, when người dùng đọc chúng, then mỗi thẻ là
**một hoạt động làm được ngoài đời**, không phải một nhận xét, một lời khuyên
chung, hay một mẹo nhắn tin.

**AC-10.** Given người dùng không chọn thẻ nào, when họ rời màn kết quả, then
không có hệ quả, không nhắc lại, không trách móc — và họ **vẫn** rời đi được
mà không bị chặn (R-1c/R-1d, SC-5).

### Nhóm C — Đầu vào tự khai và luật ba tầng (R-1a, R-1e)

**AC-11.** Given story này cần một dấu hoàng đạo hoặc một câu trả lời về người
kia, when app lấy dữ liệu, then nguồn duy nhất hợp lệ là **người dùng gõ ra**.
App **không** suy ra từ hành vi, nội dung nhắn tin, danh bạ, mạng xã hội, hay
bất kỳ dữ liệu nào app tự thu (R-1(d-sai), R-1b).

**AC-12.** Given người dùng nhập một nhãn hoặc một câu trả lời **thay cho người
kia**, when nội dung dựa trên nó hiển thị, then nó được đóng khung là **phỏng
đoán của người dùng**, không phải sự thật app xác nhận (R-1e tầng 2).

**AC-13.** Given kết quả hiện ra, when người dùng đọc, then **không** có điểm
số, thứ hạng, hay bất kỳ nhận định định lượng nào về người kia (R-1e tầng 3
cấm).

**AC-14.** Given kết quả hiện ra, when người dùng đọc **toàn màn**, then
**không** có chỉ số ăn khớp ở bất kỳ dạng nào — cả DẢI lẫn phần trăm. Chỉ số ăn
khớp thuộc STORY-010 và chỉ sống sau cửa khoá vị trí.

### Nhóm D — Không kết luận (R-1g)

**AC-15.** Given bất kỳ đoạn nội dung nào nói về người kia, when người dùng đọc
hết đoạn, then nó **kết thúc bằng một câu để hỏi người thật**, không bằng một
kết luận (R-1g).

**AC-16.** Given toàn bộ màn kết quả, when người dùng đọc xong, then bài kiểm
tra R-1g đạt: *đọc xong, người dùng muốn hỏi người kia **nhiều hơn**, không phải
ít hơn*.

**AC-17.** Given toàn bộ nội dung của story này, when người dùng đọc, then
không có ngôn ngữ tiên tri, vận mệnh, hay "số phận đã định" — mọi câu giữ màn
này ở đúng vị trí **một cái cớ để bắt chuyện** (R-10).

### Nhóm E — Không tạo thói quen mở app (R-1 cấm (f), không tối ưu DAU)

**AC-18.** Given người dùng mở màn (7) nhiều lần trong một ngày, when nội dung
hiện ra, then app **không** dùng cơ chế nội dung-mới-mỗi-ngày để tạo thói quen
mở app: không tử vi hằng ngày, không "vận mệnh hôm nay", không nội dung khoá
theo ngày.

**AC-19.** Given người dùng dùng story này, when họ tìm chỉ số gắn kết, then
**không** có streak, chuỗi ngày, huy hiệu, hay đếm số lần chơi (R-1 cấm (f)),
và **không** phần nào của story nằm sau paywall (R-14).

**AC-20.** Given người dùng không mở màn (7) trong nhiều ngày, when họ quay lại,
then app **không** hiển thị nội dung trách móc, đếm ngày vắng, hay chuỗi bị đứt.

### Nhóm F — Tất định, ngoại tuyến, không AI (R-7)

**AC-21.** Given cùng một bộ đầu vào, when người dùng chơi lại, then kết quả
**giống hệt** lần trước. Nội dung **không** đổi theo ngày, theo giờ, hay theo
số lần mở (R-7, AC-18).

**AC-22.** Given bất kỳ đường đi nào của story này, when nội dung được sinh,
then app **không** gọi mô hình AI và **không** gọi API ngoài nào (R-7).

**AC-23.** Given thiết bị hoàn toàn không có mạng, when người dùng chơi, then
toàn bộ luồng chạy được và kết quả vẫn kèm đủ ba thẻ, vì nội dung là gói dữ
liệu tĩnh ship kèm app.

### Nhóm G — Tham chiếu sổ tay và suy giảm êm

**AC-24.** Given sổ tay (STORY-004) đã có dữ liệu, when ba thẻ đề xuất được
sinh, then chúng **dùng** dữ liệu đó để bớt chung chung.

**AC-25.** Given sổ tay **rỗng** hoặc STORY-004 chưa được giao, when người dùng
chơi, then story này vẫn cho ra đủ ba thẻ hợp lệ. Sổ tay là **làm giàu tuỳ
chọn**, không phải điều kiện chặn (xem BR-4).

**AC-26.** Given story này đọc sổ tay, when nó chạy, then nó **không** ghi vào
sổ tay và **không** đổi hợp đồng sổ tay hay hợp đồng thẻ (chỉ đọc).

### Nhóm H — Ranh giới đạo đức và cổng cứng

**AC-27.** Given bất kỳ bề mặt nào của story này, when nó hiển thị, then app
**không** hiển thị và **không** lưu chỉ báo hành vi người kia — không "đã xem",
không giờ mở, không đếm lần (R-1b).

**AC-28.** Given người kia **chưa từng và sẽ không bao giờ** tham gia, when
người dùng dùng story này, then **mọi** AC ở trên vẫn đạt được (cổng cứng).

### Nhóm I — Kiểm duyệt hai lớp (SB-123; OQ-3 ĐÃ ĐÓNG bằng D-15)

**AC-29.** Given kho nội dung trắc nghiệm, các lát hoàng đạo, và văn bản ba thẻ
đề xuất, when chúng được đưa vào **bản build người dùng thật**, then điều kiện
ship là **(a)** mọi mục đã qua **cổng nhập chạy được** ở AC-33/AC-34 (R-15c), và
**(b)** trạng thái duyệt ghi lại truy vết được **theo id bền của từng mục**
(AC-30). Kiểm duyệt hai lớp (SB-123) vẫn giữ cho **chất lượng biên tập** — và ở
story này giọng điệu chính là sản phẩm, nên nó vẫn ở mức nghiêm — nhưng
**không** còn là cổng chặn ship và **không** là cơ chế cưỡng chế luật bất biến.
AC này **không còn bị chặn**: OQ-3 đã đóng 2026-09-06 bằng D-15.

### Nhóm J — Nội dung là dữ liệu có cổng nhập (R-15 / D-15)

**AC-30.** Given kho câu hỏi trắc nghiệm, các lát hoàng đạo, văn bản ba thẻ đề
xuất, và **luật ánh xạ câu trả lời → lát nội dung**, when chúng được ship, then
chúng là **gói dữ liệu có lược đồ và định danh bền cho từng mục**, không phải
chuỗi cứng trong widget/code; đổi nguồn nội dung sang CMS ngoài repo **không kéo
theo một lần sửa code** (R-15a).

**AC-31.** Given số câu hỏi trắc nghiệm và số lát hoàng đạo là **thuộc tính dữ
liệu** (N bất kỳ, N ≥ 1), when gói nội dung đổi số mục, then luồng trắc nghiệm,
bề mặt kết quả, và cơ chế cưỡng chế ba thẻ vẫn đạt nguyên vẹn **mà không sửa
code**; **không** AC nào của story này được suy ra từ số mục của bộ seed
(R-15b). **Ngoại lệ có chủ đích:** con số **3** ở BR-2 là hợp đồng bố cục của
bề mặt kết quả, **không** phải N của một gói nội dung — nó không nằm dưới R-15b.

**AC-32.** Given người dùng làm lại trắc nghiệm nhiều lần cho tới khi duyệt hết
kho câu hỏi, when kho hết, then hành vi hết-vòng là **quay lại từ đầu kho theo
cùng thứ tự tất định** hoặc trạng thái êm đã định, **không** thông báo "đã hết",
**không** màn ngõ cụt, và **không** chỉ báo tiến độ, phần trăm, số lần đã làm,
hay số mục còn lại dưới bất kỳ dạng nào. Ràng buộc này chồng lên luật chống thói
quen mở app (AC-18..AC-20): chỉ báo tiến độ ở đây bị cấm bởi **hai luật độc
lập** (R-15b và R-1 cấm (f)).

**AC-33.** Given một mục nội dung ĐẦU RA vi phạm luật bất biến — đo hành vi
người kia (R-1b), tâng bốc, hiển thị %, streak, giọng **phán quyết** thay vì cớ
bắt chuyện (SB-136, BR-1), hoặc câu nói về người kia không kết bằng câu hỏi
(R-1g) — when mục đó được nạp qua cổng nhập nội dung, then cổng **từ chối mục đó
và làm hỏng bản dựng**; vi phạm **không** được phép lọt tới lúc người dùng đọc.
Cổng chạy được kể cả với nội dung do CMS ngoài repo cấp, tức nội dung **không**
đi qua review của repo này (R-15c).

**AC-34.** Given một mục của **bộ câu HỎI trắc nghiệm** vi phạm R-1b ở tầng ĐẦU
VÀO — hỏi về tần suất hay hành vi của người kia thay vì phỏng đoán tự khai của
người dùng — when mục đó được nạp qua cổng nhập, then cổng **từ chối mục đó và
làm hỏng bản dựng**. Cùng tiền lệ STORY-009 AC-37 đã đặt cho bộ câu hỏi chân
dung: một câu **hỏi** sai làm hỏng dữ liệu ngay từ đầu vào và không sửa được ở
đầu ra (R-15c).

## Business Rules

- **BR-1 (SB-136 — vỏ, không phải phán quyết).** Nhận định và ba thẻ là **một
  bề mặt kết quả duy nhất**, không phải hai bước. Tách chúng ra bằng một cú
  chạm, một màn tiếp theo, hay một mục thu gọn là **vi phạm SC-2**, kể cả khi
  ba thẻ vẫn tồn tại đâu đó trong luồng.
- **BR-2 (đúng ba thẻ, là một hợp đồng).** Con số **3** là ràng buộc sản phẩm,
  không phải tham số cấu hình: một thẻ thì thành lời khuyên, năm thẻ thì thành
  danh sách phải chọn. Không có chế độ "hiện thêm".
- **BR-3 (SB-174 — thứ tự giao hàng, không phải phụ thuộc runtime).** Story này
  chỉ được **ship sau** STORY-004 (sổ tay/quà), STORY-005 (mồi chuyện), và
  STORY-008 (kịch bản). Đây là **ràng buộc thứ tự giao hàng**: về mặt kỹ thuật
  story chạy được chỉ với STORY-001 (AC-25), nhưng phủ vỏ hoàng đạo lên một app
  còn chung chung sẽ cho ra một app bói toán có kèm to-do list. Scrum Master
  xếp lịch theo ràng buộc này; Tech Lead **không** được biến nó thành phụ thuộc
  runtime cứng.
- **BR-4 (sổ tay là làm giàu, không phải cổng).** Story này **đọc** sổ tay khi
  có, và suy giảm êm khi không có. Nó không dùng màn kết quả làm đòn bẩy để
  thúc người dùng điền sổ tay — làm vậy là biến cửa vào nhẹ nhất thành một biểu
  mẫu trá hình, ngược SC-3 (cùng tinh thần STORY-006 BR-5).
- **BR-5 (ranh giới với STORY-010).** Chỉ số ăn khớp, DẢI, và gói tra cứu
  144/256 ô thuộc **duy nhất** STORY-010, và chỉ tới được sau cửa khoá vị trí.
  Màn (7) là **cửa vào công khai**; đặt chỉ số ăn khớp lên đây là phá luật R-13
  bằng đường vòng, vì nó đưa nội dung nói-về-người-kia ra menu chính.
- **BR-6 (ranh giới với STORY-009).** Story này **không** hỏi bộ câu hỏi chân
  dung và **không** hiển thị chân dung. Trắc nghiệm ở đây là vỏ giải trí ngắn
  dẫn ra hoạt động; chân dung là công cụ hiểu người kia, khoá vị trí, thuộc
  STORY-009.
- **BR-7 (hợp đồng thẻ STORY-001, chỉ đọc).** Story này tạo thẻ theo mô hình đã
  khoá ở STORY-001 AC-8 và gắn nguồn sinh theo AC-9. Nó **không** thêm trường,
  **không** đổi hợp đồng thẻ, và **không** tự định nghĩa trạng thái thẻ mới.
- **BR-8 (không phụ thuộc story tương lai).** Story này không cần STORY-012
  (pha/widget) để chạy, không phát trạng thái pha, và không vẽ widget.
- **BR-9 (nội dung tất định, cấm xoay vòng theo ngày).** Cùng đầu vào → cùng
  đầu ra, vĩnh viễn (AC-21). Mọi cơ chế làm mới nội dung theo thời gian đều bị
  cấm ở story này, vì đó chính là cơ chế biến "cớ bắt chuyện" thành "thói quen
  mở app".
- **BR-10 (không kênh gửi riêng).** Nếu người dùng muốn rủ, đường đi là: chọn
  thẻ → màn (1) → luồng chuẩn bị/xuất lời mời (STORY-002). Story này **không**
  tự dựng nút gửi, không tự sinh tin nhắn gửi đi, và không tạo ảnh kết quả có
  thương hiệu app để chia sẻ — một ảnh như vậy là phán quyết đứng một mình,
  đúng thứ BR-1 cấm.
- **BR-11 (R-1e — trắc nghiệm nói về NGƯỜI DÙNG là mặc định an toàn).** Khi một
  câu hỏi hoặc một đoạn kết quả nói **về người kia**, nó phải mang nhãn phỏng
  đoán (AC-12) và kết bằng câu-để-hỏi (AC-15). Nội dung nói về **chính người
  dùng** không cần hai ràng buộc đó, nhưng vẫn không được chấm điểm.
- **BR-12 (R-15a — nội dung là dữ liệu, không phải chuỗi trong code).** Kho câu
  hỏi trắc nghiệm, các lát hoàng đạo, văn bản ba thẻ đề xuất, và **luật ánh xạ
  câu trả lời → lát nội dung** là gói dữ liệu có lược đồ, mỗi mục có **id bền**
  dùng làm khoá tham chiếu và khoá truy vết duyệt. Cấm chuỗi nội dung nằm trong
  widget/code. Tiêu chí nghiệm thu: đổi nguồn sang CMS ngoài repo mà **không sửa
  một dòng code nào**. Ràng buộc này quan trọng đặc biệt ở đây vì nội dung hoàng
  đạo là phần dễ bị thay/bổ sung nhất sau khi ship.
- **BR-13 (R-15b — N là thuộc tính dữ liệu; con số 3 KHÔNG phải N).** Số câu hỏi
  trắc nghiệm và số lát hoàng đạo là dữ liệu bản đầu, **không** phải hằng số của
  story; bộ seed 10 mục cho gói **xoay vòng** là giá trị bản đầu. Cấm mọi AC,
  BR, hay bố cục dựa vào "vì có đúng 10 mục nên…" — đặc biệt hành vi hết-vòng
  (AC-32) và chỉ báo tiến độ. **Ranh giới cần giữ rõ:** con số **3** ở BR-2 là
  hợp đồng bố cục của bề mặt kết quả, không phải số mục của một gói nội dung;
  R-15b không nới BR-2, và BR-2 không được viện dẫn để cố định N của gói nội
  dung.
- **BR-14 (R-15c — luật bất biến là CỔNG NHẬP, không phải quy ước biên tập).**
  R-1b (cả tầng đầu ra lẫn tầng đầu vào của bộ câu hỏi), R-1e (BR-11), R-1g,
  SB-136 cấm giọng phán quyết (BR-1), chống tâng bốc, cấm hiển thị %, và cấm
  streak được cưỡng chế ở **tầng lược đồ/validation của cổng nhập nội dung**,
  chạy được trong bản dựng. Nội dung vi phạm bị từ chối tại cổng và làm hỏng bản
  dựng (AC-33, AC-34). Ở story này giọng điệu **chính là** sản phẩm, nên cổng
  nhập là ràng buộc bắt buộc trước ship, không phải bước tuỳ chọn.

## System Integration And Discoverability

- **UI-facing story:** YES.
- **Existing user-visible surface:** YES — màn (1) kho chung (STORY-001) và sổ
  tay (STORY-004). Story này thêm **một destination mới** trong nhóm CỬA VÀO,
  đúng theo bản đồ 11 màn hình.
- **Điểm vào:** đường vào riêng, thấy được, từ menu chính. Direct URL only
  acceptable: **YES** — story này **không** khoá vị trí, khác STORY-009 và
  STORY-010.
- **Lối ra:** ba thẻ đề xuất → màn (1) (AC-7), hoặc rời màn không chọn gì
  (AC-10). Không ngõ cụt (SC-5).
- **Hợp đồng story này TIÊU THỤ (chỉ đọc):** STORY-001 (hợp đồng thẻ AC-8,
  nguồn sinh AC-9), STORY-004 (sổ tay, làm giàu tuỳ chọn).
- **Hợp đồng story này KHÔNG tiêu thụ:** STORY-009 (chân dung), STORY-010 (chỉ
  số ăn khớp), STORY-012 (pha/widget). Story này không hiển thị chỉ số ăn khớp
  ở bất kỳ dạng nào (AC-14).
- **Ràng buộc thứ tự giao hàng:** ship **sau** STORY-004/005/008 (BR-3). Đây là
  đầu vào cho việc xếp lịch, không phải một phụ thuộc runtime.
- **Tích hợp bên ngoài:** **không có, và đó là ràng buộc, không phải hiện
  trạng** (AC-22). Không AI runtime, không dịch vụ nội dung, không nguồn dữ
  liệu chiêm tinh ngoài.

## Open Question Impact

### Scope Items BLOCKED in this story

- **Không còn scope item nào của story này bị chặn bởi câu hỏi mở.** OQ-3 — mục
  duy nhất từng chặn (AC-29) — đã đóng 2026-09-06 bằng D-15.

### Scope Items NOT BLOCKED in this story

- **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user), bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Câu trả lời không phải "chỉ định người duyệt lớp 2" mà là đổi bản
  chất nội dung: dữ liệu có schema + id bền, N là thuộc tính dữ liệu, luật bất
  biến cưỡng chế ở cổng nhập chạy được.
  - **Hết chặn:** ship kho nội dung trắc nghiệm, các lát hoàng đạo, và văn bản
    ba thẻ đề xuất vào bản build người dùng thật (AC-29) không còn chờ user chỉ
    định người duyệt lớp 2. Điều kiện ship nay là qua cổng nhập chạy được cộng
    truy vết duyệt theo id bền.
  - **Thành ràng buộc mới của story:** AC-30..AC-34 và BR-12/BR-13/BR-14.
  - **Điểm riêng của story này vẫn giữ nguyên sức nặng, nhưng đổi cơ chế:** bộ
    câu hỏi trắc nghiệm chịu kiểm duyệt ở tầng **ĐẦU VÀO** — một câu hỏi vi phạm
    R-1b (hỏi tần suất/hành vi của người kia) làm hỏng story ngay từ dữ liệu vào
    và không sửa được ở đầu ra, cùng tiền lệ STORY-009. Sau D-15 điều này
    **không** còn là lý do chặn ship; nó thành **quy tắc validation chạy được**
    ở AC-34. Giọng **phán quyết** (SB-136) cũng vào cổng ở AC-33.
  - **Ranh giới cần giữ rõ:** R-15b áp cho N của gói nội dung, **không** nới
    BR-2 — con số **3** thẻ vẫn là hợp đồng bố cục cứng (AC-31).
  - **Còn lại của SB-123:** kiểm duyệt hai lớp giữ nguyên mức nghiêm cho chất
    lượng biên tập (giọng điệu ở đây chính là sản phẩm), nhưng hạ từ **chặn
    ship** xuống **rủi ro chất lượng nội dung**, sửa được bằng đổi dữ liệu mà
    không sửa code.

- **OQ-3 chưa bao giờ chặn màn, điều hướng, cơ chế, hay cấu trúc dữ liệu.** Cửa vào
  (AC-1..AC-3), **cơ chế cưỡng chế ba thẻ trên một bề mặt** (AC-4..AC-6, AC-10),
  đẩy thẻ (AC-7..AC-9), luật đầu vào tự khai (AC-11..AC-14), chống thói quen mở
  app (AC-18..AC-20), tính tất định/ngoại tuyến (AC-21..AC-23), và suy giảm êm
  khi sổ tay rỗng (AC-24..AC-26) **xây và verify được ngay** bằng nội dung
  placeholder nội bộ.
- **Nhãn chức năng không bị OQ-3 chặn** — tiền lệ STORY-006 BR-14. Nhãn "đây là
  phỏng đoán của bạn" (AC-12) và các nhãn điều hướng/hành động là **nhãn chức
  năng bắt buộc**, phải có mặt ngay từ bản build nội bộ đầu tiên.
- **L45 / OQ-18 — ĐÓNG** (user chốt 2026-09-03: chặng 1 là kho tài sản). Story
  này không chịu tải định vị; ba story chịu tải là STORY-001, STORY-012,
  STORY-013.
- **R-1 mở ở nấc 3 — ĐÓNG, luật bất biến.** Nấc 4 không bao giờ.
- **SB-174 — ĐÓNG, luật bất biến.** Thứ tự "sổ tay/quà/mồi chuyện/kịch bản →
  rồi mới phủ vỏ" không mở lại để thương lượng lịch giao hàng (BR-3).
- **SB-144/145/146 (trò chơi "đoán") — HOÃN**, **không** gán vào story này, dù
  đây là story gần nhất về chủ đề. Ép vào sẽ tạo một hạng mục không có outcome
  riêng (theo triage của requirement).
- **OQ-2 — ĐÓNG ở tầng sản phẩm**, thuộc STORY-001.
- **Chặng 1.5 / link hai chiều / feed tin thật / Zalo Mini App / thương mại /
  J7 — ĐÓNG, binding out of scope** của REQ-016.
- **Số lượng trắc nghiệm, số câu mỗi bộ, luật ánh xạ câu trả lời → nhận định →
  ba thẻ, và định dạng gói dữ liệu** — giao **Tech Lead**. Ràng buộc sản phẩm:
  tất định, ship kèm app, không AI, luôn ra đúng ba thẻ hợp lệ trên mọi đường
  đi.
- **Chi tiết trình bày** (bố cục màn kết quả sao cho ba thẻ nằm cùng bề mặt và
  không bị đẩy khỏi tầm nhìn, cách thể hiện dấu "phỏng đoán", vị trí đường vào
  trong menu chính) — giao **UI/UX Designer trong phạm vi story này**. AC-5 là
  **ràng buộc sản phẩm** UI/UX phải thoả, không phải gợi ý.

## Traceability

| AC | Nguồn ràng buộc |
|----|-----------------|
| AC-1..AC-3 | Nhóm CỬA VÀO (bản đồ 11 màn), SC-3 không điền-trước, R-1c/R-1d |
| AC-4..AC-6 | SC-2 + SB-136 "vỏ, không phải phán quyết", BR-1, BR-2 |
| AC-7..AC-10 | Hợp đồng thẻ STORY-001 AC-8/AC-9, SC-5 không ngõ cụt, R-1c/R-1d |
| AC-11..AC-14 | R-1a, R-1e ba tầng, R-1(d-sai), R-1b, ranh giới STORY-010 (BR-5) |
| AC-15..AC-17 | R-1g và bài kiểm tra nghiệm thu của nó, R-10 định vị |
| AC-18..AC-20 | R-1 cấm (f), R-14, "không tối ưu DAU" của REQ-016 |
| AC-21..AC-23 | R-7 không AI runtime, không API ngoài, BR-9 tất định |
| AC-24..AC-26 | STORY-004 sổ tay (chỉ đọc), BR-4 làm giàu không phải cổng |
| AC-27..AC-28 | R-1b, cổng cứng REQ-016 |
| AC-29 | SB-123 kiểm duyệt hai lớp (chất lượng biên tập); OQ-3 ĐÃ ĐÓNG bằng D-15; tiền lệ STORY-002/009/010 |
| AC-30 | R-15a — schema + id bền, đổi nguồn sang CMS không sửa code |
| AC-31, AC-32 | R-15b — N là thuộc tính dữ liệu; hết-vòng đúng với mọi N; BR-2 (3 thẻ) không phải N |
| AC-33, AC-34 | R-15c — cổng nhập chạy được; R-1b (đầu ra và đầu vào), R-1e, R-1g, SB-136, cấm %, cấm streak |
| BR-12..BR-14 | D-15 / R-15 (`req_master.md` mục 15) |
