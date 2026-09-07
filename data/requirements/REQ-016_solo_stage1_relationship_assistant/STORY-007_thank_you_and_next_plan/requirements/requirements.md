# Story Requirements: STORY-007 "Cảm ơn + chốt việc kế tiếp" (SB-212)

- Requirement: REQ-016
- Story: STORY-007
- Complexity: standard
- Story-Class: standard
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: STORY-001, STORY-002, STORY-003, STORY-005
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules`, `## Out of Scope`,
  `## Open Questions`; `../../requirements/requirements.md` →
  `## Story Index`, `## Open Question Triage`;
  `../../STORY-001_activity_card_hub/requirements/requirements.md` →
  mô hình thẻ (AC-8), hành động chính theo trạng thái (AC-11), vòng đời hai
  chiều (AC-14);
  `../../STORY-002_invite_message_composer/requirements/requirements.md` →
  hợp đồng renderer đa danh mục (AC-20, AC-21, AC-22, BR-13), payload SB-125
  (AC-17), Share Sheet (AC-16), kiểm duyệt hai lớp (AC-23, AC-24);
  `../../STORY-006_before_you_go_checklist/requirements/requirements.md` →
  tiền lệ hành động chính hai tầng (AC-4, AC-5, BR-1) và tiền lệ phụ thuộc pha
  một chiều (AC-24, BR-11)

## Business Outcome

Sau một buổi hẹn vui, **cái đà không nguội đi**. Sáng hôm sau, người dùng được
nhắc **một lần, thật nhẹ** để làm hai việc họ định làm nhưng thường quên: gửi
một lời cảm ơn thật cho người kia, và chốt luôn một việc kế tiếp trước khi cảm
giác vui nhạt đi.

Story này phủ **J9**. Nó là touchpoint **hướng RA NGOÀI** — cố ý đối lập với J8
("23h vừa về tới nhà chưa?", hướng vào trong, thuộc STORY-012). Nó là **mở rộng
của màn (1)**, không phải màn hình thứ 12; tổng vẫn là 11 màn hình.

Cả ba phần đều **tái dùng hạ tầng đã giao**: renderer của STORY-002, nhật ký của
STORY-003, kho mồi của STORY-005, vòng đời thẻ của STORY-001. Story này không
xây engine nội dung mới, không xây kho mới, không xây màn mới.

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ.** Lời cảm ơn do người dùng tự soạn và tự gửi qua OS Share Sheet;
ảnh đính là ảnh của chính người dùng; việc kế tiếp thành một thẻ trong kho của
chính họ. Không AC nào cần người kia trả lời, cài app, hay tồn tại trong hệ
thống. Giá trị của story đạt trọn vẹn **ngay khi người dùng bấm chia sẻ**, không
phụ thuộc điều gì xảy ra sau đó.

## Scope

### In Scope

1. Khối "Cảm ơn + chốt việc kế tiếp" **kích hoạt đúng một lần** cho mỗi thẻ, từ
   sáng hôm sau ngày thẻ chuyển sang *Đã đi rồi*.
2. Khối nằm **bên trong luồng "ghi lại"** của thẻ *Đã đi rồi* — không giành hành
   động chính cấp thẻ (SC-4 giữ nguyên như STORY-001 AC-11 đã khoá).
3. **Phần 1 — soạn lời cảm ơn**: thêm **danh mục preset mới** "lời cảm ơn sau
   hẹn" vào renderer đã có của STORY-002. Chỉ bổ sung **gói dữ liệu preset**,
   không sửa engine (STORY-002 AC-21, BR-13).
4. **Phần 2 — đính ảnh**: nếu người dùng đã lưu ảnh cho buổi hẹn đó (nhật ký
   STORY-003 hoặc trường ảnh/ký ức trên thẻ STORY-001 AC-8), khối cho phép đính
   ảnh đó vào vật phẩm chia sẻ. Chưa có ảnh → phần này **không hiện**.
5. **Phần 3 — chốt việc kế tiếp**: 2-3 gợi ý nhẹ, lấy tất định từ kho mồi
   (STORY-005) hoặc dịp lịch âm gần nhất. Chọn 1 → **thẻ mới** vào màn (1) ở
   trạng thái *Mới nghĩ ra*. **Không bắt buộc.**
6. Vật phẩm lời cảm ơn đi ra qua **OS Share Sheet**, người dùng tự gửi sang Zalo
   hoặc kênh họ chọn.
7. Bản lưu của lời cảm ơn là **payload có cấu trúc render lại được** theo cùng
   hợp đồng SB-125 của STORY-002 AC-17.

### Out of Scope

- **Engine nội dung mới** — bắt buộc tái dùng renderer STORY-002. Sửa engine để
  phục vụ danh mục mới là vi phạm hợp đồng STORY-002 AC-21.
- **Nhắc lại lần hai**, chuỗi nhắc, thông báo đẩy đuổi theo, hay bất kỳ cơ chế
  nào phạt việc bỏ qua.
- **Gửi tin nhắn thay người dùng**; mở kênh gửi trong app; tích hợp API nhắn tin.
- **Đo lường người kia đã đọc/đã trả lời lời cảm ơn chưa** (R-1b).
- **Khối "23h vừa về tới nhà chưa?"** (SB-85, J8) — thuộc STORY-012.
- **Vẽ widget / trạng thái pha lên widget** — thuộc STORY-012.
- **Dựng một nhánh cổng nhập nội dung RIÊNG** cho danh mục "lời cảm ơn sau hẹn".
  Story này dùng lại **cùng lược đồ và cùng cổng nhập** của STORY-002 (STORY-002
  AC-29); thêm danh mục là thay đổi **dữ liệu**, không phải thay đổi code cổng.
- Thêm trường mới vào mô hình thẻ — story này **đọc** mô hình STORY-001 đã khoá.
- Một hành động chính **cấp thẻ** thứ hai cho trạng thái *Đã đi rồi* — vi phạm
  SC-4.
- Sửa mô hình nhật ký của STORY-003, hay tạo bản sao ảnh thứ hai ngoài nhật ký.
- Chặng 1.5, link hai chiều, feed tin thật, Zalo Mini App, thương mại/affiliate
  quà, J7.

## Acceptance Criteria

### Nhóm A — Kích hoạt đúng một lần và ranh giới SC-4

**AC-1.** Given một thẻ chuyển sang *Đã đi rồi*, when người dùng mở chi tiết thẻ
đó lần đầu **vào một ngày lịch sau ngày chuyển**, then khối "Cảm ơn + chốt việc
kế tiếp" hiện ra **một lần**, ở dạng nhắc nhẹ.

**AC-2.** Given thẻ vừa chuyển sang *Đã đi rồi* **trong cùng ngày hôm nay**, when
người dùng mở chi tiết thẻ, then khối **không** hiện — nó là touchpoint của sáng
hôm sau, không phải của tối vừa về (ranh giới với J8).

**AC-3.** Given khối đã hiện ra một lần cho một thẻ, when người dùng mở lại chi
tiết thẻ đó ở bất kỳ lần nào sau đó, then khối **không** hiện lại — dù người dùng
đã dùng đủ ba phần, dùng một phần, hay không dùng phần nào.

**AC-4.** Given một thẻ đã tiêu thụ lượt kích hoạt, when thẻ bị lùi trạng thái
rồi chuyển lại sang *Đã đi rồi* (STORY-001 AC-14 cho phép chuyển hai chiều),
then khối **không** kích hoạt lại. Mỗi thẻ có **đúng một** lượt trong toàn bộ
vòng đời của nó.

**AC-5.** Given một thẻ đang chờ tới lượt kích hoạt, when thẻ rời khỏi trạng thái
*Đã đi rồi* trước khi khối kịp hiện, then lượt kích hoạt bị **huỷ lặng lẽ** —
không hiện ở trạng thái mới, và app không báo cho người dùng biết họ vừa lỡ mất
gì.

**AC-6.** Given một thẻ ở trạng thái *Đã đi rồi*, when thẻ hiển thị ở danh sách
màn (1) và ở chi tiết thẻ, then hành động chính **cấp thẻ** vẫn là **đúng một**
hành động — "ghi lại" như STORY-001 AC-11 đã khoá. Story này **không** thêm hành
động chính cấp thẻ thứ hai (SC-4).

**AC-7.** Given khối đang hiện, when người dùng xem nó, then khối nằm **bên trong
luồng "ghi lại"** của thẻ đó, và mọi hành động chính của khối ("soạn lời cảm ơn",
"chốt việc kế tiếp") ở **mức thị giác thấp hơn rõ rệt** so với hành động chính
cấp thẻ. Người dùng không phải rời luồng "ghi lại" để dùng khối.

### Nhóm B — Phần 1: soạn lời cảm ơn qua renderer STORY-002

**AC-8.** Given người dùng bấm "soạn lời cảm ơn", when nội dung được sinh ra,
then nó đi qua **đúng engine render khung nhại + mad-libs của STORY-002**, chỉ
khác ở tham số **danh mục preset** = "lời cảm ơn sau hẹn" (STORY-002 AC-20).

**AC-9.** Given danh mục "lời cảm ơn sau hẹn" được thêm vào, when nó được giao,
then việc thêm chỉ gồm **bổ sung gói dữ liệu preset**; engine render **không**
bị sửa và hành vi hiện có của STORY-002 (danh mục "lời mời") **không** đổi
(STORY-002 AC-21, BR-13).

**AC-10.** Given cùng một thẻ và cùng một khung nhại được chọn, when lời cảm ơn
được sinh ra ở hai lần khác nhau, then kết quả **giống hệt nhau** (tất định,
không AI ở runtime).

**AC-11.** Given thẻ **thiếu** một hoặc nhiều trường mad-libs, when nội dung được
dựng, then câu vẫn đọc trôi và **không** chứa ô trống, dấu ngoặc rỗng, hay chuỗi
placeholder lộ ra — cùng hành vi STORY-002 AC-6 đã khoá.

**AC-12.** Given người dùng đã chốt một lời cảm ơn, when họ bấm chia sẻ, then vật
phẩm đi ra qua **OS Share Sheet**, và app **không** tự gửi tới bất kỳ ai, không
mở kênh gửi trong app, không tích hợp API nhắn tin.

**AC-13.** Given lời cảm ơn đã xuất, when bản lưu được ghi, then nó là **payload
có cấu trúc render lại được** theo hợp đồng SB-125 (id template, id danh mục
preset, phiên bản preset, tập giá trị đã điền, tham chiếu thẻ nguồn), **không**
phải chuỗi text đã bẹp; payload gắn vào **thẻ nguồn trong kho chung**, không tạo
danh sách thứ hai (SC-1').

### Nhóm C — Phần 2: đính ảnh, và ranh giới riêng tư với nhật ký

**AC-14.** Given người dùng đã lưu ít nhất một ảnh cho buổi hẹn đó (mục nhật ký
STORY-003 gắn với thẻ, hoặc trường ảnh/ký ức trên thẻ theo STORY-001 AC-8), when
khối hiện ra, then phần "đính ảnh" hiện và trỏ tới đúng ảnh đó.

**AC-15.** Given người dùng chưa lưu ảnh nào cho buổi hẹn đó, when khối hiện ra,
then phần "đính ảnh" **không** hiện, và khối vẫn dùng được bình thường ở hai phần
còn lại. App **không** gợi ý, nhắc, hay tạo lối tắt thúc người dùng đi chụp/thêm
ảnh.

**AC-16.** Given phần "đính ảnh" đang hiện, when ảnh được đính vào vật phẩm chia
sẻ, then việc đính là **hành động rõ ràng của người dùng trên từng ảnh**; app
**không bao giờ** tự đính ảnh sẵn, không chọn sẵn, và không đính khi người dùng
chưa bấm.

**AC-17.** Given ảnh nằm trong một mục nhật ký, when người dùng đính ảnh đó, then
**chỉ ảnh** đi ra; **nội dung chữ** của mục nhật ký, ngày giờ ghi, và mọi siêu dữ
liệu riêng tư khác của mục **không** rời thiết bị và **không** xuất hiện trong
vật phẩm chia sẻ.

**AC-18.** Given người dùng đính ảnh từ nhật ký, when app xử lý, then nhật ký
**vẫn riêng-tư-mặc-định**: app không đổi trạng thái riêng tư của mục, không đánh
dấu mục đã chia sẻ, không tạo bản sao ảnh thứ hai nằm ngoài quyền xoá của
STORY-003, và **xoá mục nhật ký về sau vẫn xoá được toàn bộ ảnh của nó**.

### Nhóm D — Phần 3: chốt việc kế tiếp

**AC-19.** Given khối đang hiện, when phần "chốt việc kế tiếp" hiển thị, then nó
đưa ra **2-3 gợi ý**, lấy tất định từ kho mồi của STORY-005 hoặc từ **dịp lịch âm
gần nhất** tính trên thiết bị. Không gọi AI, không gọi API ngoài.

**AC-20.** Given người dùng chọn một gợi ý và xác nhận, when hành động chạy, then
**một thẻ mới** xuất hiện ở màn (1) ở trạng thái *Mới nghĩ ra*, theo đúng mô hình
thẻ và bốn trạng thái của STORY-001 — cùng hợp đồng mà STORY-005 AC-11 đã dùng,
không phải một đường tạo thẻ thứ hai.

**AC-21.** Given gợi ý được chọn gắn với một dịp có ngày cụ thể, when thẻ mới
được tạo, then thẻ mang sẵn **ngày của dịp đó** và người dùng sửa được ngay.

**AC-22.** Given người dùng không chọn gợi ý nào, when họ đóng khối, then
**không** thẻ nào được tạo, không có nhắc lại, và không có dấu chưa-hoàn-thành
nào trên thẻ hay trên màn (1).

**AC-23.** Given phần "chốt việc kế tiếp", when nó hiển thị, then nó được trình
bày là **tuỳ chọn**; người dùng dùng được phần "soạn lời cảm ơn" và đóng khối mà
**không** bị chặn, không bị hỏi lại, không phải bỏ qua một bước bắt buộc.

**AC-24.** Given thẻ mới vừa được tạo từ phần này, when thẻ được lưu, then nó
mang **nguồn sinh** đọc được theo STORY-001 AC-9, và nguồn sinh đó **không bao
giờ** hiển thị như chỉ số đánh giá người dùng hay người kia.

### Nhóm E — Không phạt im lặng, không đo lường người kia

**AC-25.** Given người dùng bỏ qua khối hoặc đóng khối, when họ mở app những lần
sau, then app **không** hiển thị lời trách móc, dấu chưa-hoàn-thành, huy hiệu
thiếu, bộ đếm bỏ lỡ, hay bất kỳ chỉ số nào về việc họ đã không gửi lời cảm ơn.

**AC-26.** Given người dùng đã chia sẻ lời cảm ơn, when app xử lý xong, then app
**không** hiển thị và **không** lưu bất kỳ chỉ báo hành vi nào của người kia —
không "đã xem", không "đã nhận", không giờ mở, không đếm lần, không suy ra "người
ấy chưa phản hồi lời cảm ơn" (R-1b).

**AC-27.** Given bất kỳ nội dung nào trong khối, when đọc toàn văn, then nội dung
đùa (nếu có) **chỉ đùa về người gửi**; cấm mọi câu đùa, nhận xét, hay gán nhãn
nhắm vào người nhận (R-1d).

**AC-28.** Given story này được dùng qua nhiều buổi hẹn, when người dùng nhìn màn
(1) hoặc chi tiết thẻ, then **không** có streak, chuỗi ngày, huy hiệu, bảng xếp
hạng, hay đếm số lần đã gửi lời cảm ơn (R-1, cấm (f)), và **không** phần nào của
story nằm sau paywall (R-14).

### Nhóm F — Tất định, ngoại tuyến, ranh giới story, cổng cứng

**AC-29.** Given thiết bị **không có mạng**, when khối hiện ra, then cả ba phần
vẫn hoạt động đúng cho tới bước Share Sheet, vì nội dung sinh tất định từ gói dữ
liệu tĩnh cộng trường của thẻ (R-7).

**AC-30.** Given bất kỳ đường đi nào của story này, when nội dung được sinh ra,
then app **không** gọi mô hình AI và **không** gọi dịch vụ nội dung ngoài nào.
Tích hợp ngoài duy nhất là **OS Share Sheet** (và image picker của OS nếu bước
đính ảnh cần nó).

**AC-31.** Given STORY-012 **chưa được giao** hoặc bị tắt, when người dùng dùng
story này, then **mọi** AC ở trên vẫn đạt được. Story này **không** vẽ widget,
**không** đọc trạng thái pha của STORY-012, và **không** phụ thuộc khối J8 "23h
vừa về" để lấy ảnh — nguồn ảnh của AC-14 là nhật ký STORY-003 và trường ảnh/ký ức
trên thẻ STORY-001.

**AC-32.** Given người dùng chưa từng có, và sẽ không bao giờ có, phản hồi từ
người kia, when họ dùng story này, then **mọi** AC ở trên vẫn đạt được.

### Nhóm G — Nội dung là dữ liệu có cổng nhập (R-15 / D-15)

**AC-33.** Given danh mục preset "lời cảm ơn sau hẹn", when nó được ship, then
nó là **một danh mục DỮ LIỆU thêm vào gói của STORY-002** — cùng lược đồ, mỗi
mục có **id bền** — chứ không phải chuỗi cứng trong widget/code và không phải
gói dữ liệu riêng có lược đồ riêng. Đổi nguồn nội dung sang CMS ngoài repo
**không kéo theo một lần sửa code** (R-15a, STORY-002 AC-29).

**AC-34.** Given danh mục "lời cảm ơn sau hẹn" có **N preset bất kỳ** (N ≥ 1),
when người dùng liên tục yêu cầu preset tiếp theo cho tới khi duyệt hết danh
mục, then hành vi hết-vòng **giống hệt hành vi renderer của STORY-002**: quay
lại từ đầu theo cùng thứ tự tất định, **không** thông báo "đã hết", **không**
màn ngõ cụt, và **không** chỉ báo tiến độ hay số mục còn lại dưới bất kỳ dạng
nào. Luật này đúng với mọi N, và **không** AC nào của story này được suy ra từ
việc danh mục seed có 10 mục (R-15b).

**AC-35.** Given số gợi ý ở phần 3 nằm trong dải 2-3 mục (AC-19) và kho mồi của
STORY-005 có **N mục bất kỳ**, when N nhỏ hơn số gợi ý cần hiện, then phần 3 vẫn
render đúng phần có sẵn mà không báo lỗi, không ô trống giữ chỗ, và không màn
rỗng; when N rất lớn, then hành vi chọn **không đổi** và không có bước tải/đợi
mới. Dải 2-3 là **tham số bố cục**, không đặt ràng buộc nào lên N (R-15b).

**AC-36.** Given một preset "lời cảm ơn sau hẹn" — hoặc một câu dẫn mới có giọng
điệu do phần 3 sinh ra — vi phạm luật bất biến: đo hành vi người kia (R-1b),
tâng bốc, hiển thị %, streak, hoặc câu nói về người kia không kết bằng câu hỏi
(R-1g), when mục đó được nạp qua **cổng nhập nội dung dùng chung của
STORY-002**, then cổng **từ chối mục đó và làm hỏng bản dựng**; vi phạm
**không** được phép lọt tới lúc người dùng đọc. Story này **không** thêm nhánh
cổng riêng (R-15c, STORY-002 AC-29).

## Business Rules

- **BR-1 (SC-4 — lồng, không cạnh tranh).** *Đã đi rồi* có **đúng một** hành động
  chính cấp thẻ: "ghi lại" (STORY-001 AC-11). Khối này sống **bên trong** luồng
  đó, đúng tiền lệ hai tầng mà STORY-002 ("xuất lời mời" trong "chuẩn bị") và
  STORY-006 ("Trước giờ đi" trong "chuẩn bị") đã đặt. "Soạn lời cảm ơn" và "chốt
  việc kế tiếp" là hành động chính **của khối**, không phải của thẻ.
- **BR-2 (một lượt cho mỗi thẻ, trọn đời).** Lượt kích hoạt gắn vào **thẻ**,
  không gắn vào ngày. Nó được nạp khi thẻ chuyển sang *Đã đi rồi*, chỉ trình bày
  được từ ngày lịch kế tiếp trở đi (AC-1, AC-2), và **tiêu thụ vĩnh viễn** ngay
  lần trình bày đầu tiên (AC-3, AC-4).
- **BR-3 (không có hạn chót, và đó là chủ ý).** Lượt kích hoạt **không** hết hạn
  theo thời gian. Đặt hạn chót sẽ tạo ra một thứ người dùng có thể *trượt* — đúng
  cái mà luật "không phạt khi im lặng" cấm. Rủi ro nhắc muộn được chặn bằng cơ
  chế khác: lượt bị huỷ lặng lẽ khi thẻ rời trạng thái *Đã đi rồi* (AC-5), không
  bằng đồng hồ đếm ngược.
- **BR-4 (hướng ra ngoài, không lấn J8).** Story này là touchpoint **sáng hôm
  sau, hướng ra ngoài**. Khối "23h vừa về tới nhà chưa?" (J8, hướng vào trong) là
  của STORY-012. Điều kiện "không phải cùng ngày" ở AC-2 là ranh giới sản phẩm
  giữa hai touchpoint, không phải chi tiết kỹ thuật.
- **BR-5 (renderer dùng chung, danh mục là DỮ LIỆU).** "Lời cảm ơn sau hẹn" là
  **danh mục preset thứ hai** của engine STORY-002, không phải renderer thứ hai
  và không phải nhánh code. Sửa engine để phục vụ danh mục này là dấu hiệu hợp
  đồng STORY-002 AC-20/AC-21 bị phá — phải quay lại Tech Lead, không vá tại chỗ.
- **BR-6 (R-1c chỉ áp cho lời MỜI).** Lời cảm ơn **không** phải một lời mời, nên
  nó không bắt buộc mang cửa từ chối một chạm như BR-5 của STORY-002. **Ngoại
  lệ bắt buộc:** nếu một preset "lời cảm ơn" có chứa lời rủ nhúng bên trong ("mai
  đi tiếp nhé?"), preset đó **tính là lời mời** và phải mang cửa từ chối một
  chạm. Đây là guardrail cho khâu soạn nội dung, không phải tuỳ chọn biên tập.
- **BR-7 (SB-125 — payload render được).** Lời cảm ơn lưu theo **cùng** hợp đồng
  payload của STORY-002 AC-17. Không lưu chuỗi text đã bẹp, không tạo định dạng
  lưu trữ riêng cho danh mục mới.
- **BR-8 (ranh giới riêng tư nhật ký).** Nhật ký STORY-003 là
  **riêng-tư-mặc-định**. Đính ảnh là hành động **một chiều, có chủ đích, trên
  từng ảnh**: ảnh đi ra, chữ ở lại (AC-17). App không tự đính, không đánh dấu mục
  đã chia sẻ, không tạo bản sao ảnh nằm ngoài quyền xoá một-thao-tác của
  STORY-003 (AC-18).
- **BR-9 (thiếu ảnh là hành vi hợp lệ).** Không có ảnh → phần đính ảnh biến mất
  hoàn toàn, không hiện ở dạng xám/đóng băng, và app **không** dùng khoảng trống
  đó làm đòn bẩy thúc người dùng ghi nhật ký. Làm vậy là biến J9 thành một biểu
  mẫu trá hình, ngược SC-3.
- **BR-10 (phần 3 là tuỳ chọn thật).** "Chốt việc kế tiếp" không được chặn đường
  đóng khối, không hỏi lại, không xác nhận kiểu "bạn chắc không muốn chốt gì
  chứ?". Tuỳ chọn nghĩa là bỏ qua **không tốn thao tác nào**.
- **BR-11 (tạo thẻ qua đúng một đường).** Thẻ mới sinh ra ở đây dùng **cùng** hợp
  đồng tạo thẻ mà STORY-005 AC-11 dùng, vào ở *Mới nghĩ ra*, trong **kho chung**
  duy nhất (SC-1'). Không có "danh sách việc kế tiếp" thứ hai.
- **BR-12 (phụ thuộc pha một chiều, đối chiếu STORY-006 BR-11).** Story này
  **không** vẽ widget và **không cần** STORY-012 để chạy. Khác STORY-006 ở chỗ
  story này cũng **không phát** trạng thái pha mới: J9 đã có touchpoint hiển thị
  riêng của nó là khối trên chi tiết thẻ. Nếu thiết kế làm nảy sinh nhu cầu phát
  pha cho widget, đó là **thay đổi phạm vi** và phải quay lại Product Owner.
- **BR-13 (R-1b — cấm đo lường người kia).** Sau khi lời cảm ơn rời app qua Share
  Sheet, app **mất dấu vết một cách có chủ đích**. Không trạng thái "đã gửi/đã
  nhận", không nhắc "người ấy chưa phản hồi", không đại lượng hành vi nào của
  người kia.
- **BR-14 (R-1g — kết bằng câu hỏi, không bằng kết luận).** Nội dung trong khối
  nói về người kia phải kết thúc bằng **một câu để hỏi người thật**, không bằng
  nhận định. Áp cho cả preset lời cảm ơn lẫn văn bản gợi ý ở phần 3.
- **BR-15 (SB-123 — kiểm duyệt hai lớp, cho CHẤT LƯỢNG BIÊN TẬP).** Preset "lời
  cảm ơn sau hẹn" đi qua hai lớp duyệt cho giọng, độ sượng, và tính dùng được —
  giống hệt ràng buộc STORY-002 đặt cho danh mục "lời mời". Sau D-15, kiểm duyệt
  hai lớp **không** còn là cổng chặn ship và **không** là cơ chế cưỡng chế luật
  bất biến; việc đó thuộc cổng nhập chạy được (BR-18).
- **BR-16 (R-15a — nội dung là dữ liệu, không phải chuỗi trong code).** Danh mục
  "lời cảm ơn sau hẹn" là **dữ liệu thêm vào gói của STORY-002**, cùng lược đồ,
  mỗi mục có **id bền** dùng làm khoá tham chiếu và khoá truy vết duyệt. Cấm
  chuỗi preset nằm trong widget/code. Tiêu chí nghiệm thu: đổi nguồn sang CMS
  ngoài repo mà **không sửa một dòng code nào**.
- **BR-17 (R-15b — N là thuộc tính dữ liệu).** Số preset của danh mục này, và số
  mục kho mồi mà phần 3 đọc lại, là dữ liệu bản đầu, **không** phải hằng số của
  story; bộ seed 10 mục cho gói **xoay vòng** là giá trị bản đầu. Cấm mọi AC,
  BR, hay bố cục dựa vào "vì có đúng 10 mục nên…" — đặc biệt hành vi hết-vòng
  (AC-34) và chỉ báo tiến độ. Dải 2-3 gợi ý ở phần 3 là tham số bố cục, không
  phải ràng buộc lên N (AC-35).
- **BR-18 (R-15c — luật bất biến là CỔNG NHẬP, không phải quy ước biên tập).**
  R-1b, chống tâng bốc, cấm hiển thị %, cấm streak, và R-1g (BR-14) được cưỡng
  chế ở **tầng lược đồ/validation của cổng nhập nội dung**, chạy được trong bản
  dựng. Đây là **cùng một cổng** STORY-002 đã dựng: story này thêm dữ liệu, chứ
  **không** dựng nhánh cổng thứ hai (STORY-002 AC-29). Nội dung vi phạm bị từ
  chối tại cổng và làm hỏng bản dựng.

## System Integration And Discoverability

- **UI-facing story:** YES.
- **Existing user-visible surface:** YES — chi tiết thẻ ở màn (1) do STORY-001
  giao, bên trong luồng "ghi lại" của trạng thái *Đã đi rồi*. Story này gắn lên
  bề mặt đã có, không tạo bề mặt mới.
- **Điểm vào:** **tự động, đúng một lần**, ở lần mở chi tiết thẻ đầu tiên vào một
  ngày sau ngày thẻ chuyển *Đã đi rồi*. Người dùng không phải đi tìm. **Không**
  thêm destination, **không** vào từ menu chính hay tab bar — đúng nghĩa "mở rộng
  của màn (1)", không phải màn hình thứ 12.
- **Tái dùng, không nhân bản:** ba phần nối vào ba hạ tầng đã giao — engine
  render của STORY-002 (danh mục mới, dữ liệu thuần), nhật ký/ảnh của STORY-003
  (chỉ đọc, cộng một hành động đính có chủ đích), và đường tạo thẻ của
  STORY-001/STORY-005 (không nhánh mới). Đây là lý do story ở mức `standard` dù
  chạm bốn story khác.
- **Đối chiếu với STORY-006 trên cùng màn (1):** hai khối mở rộng cùng lồng vào
  luồng cấp thẻ, khác trạng thái và khác thời điểm — "Trước giờ đi" ở *Đã hẹn
  ngày* đúng ngày đi, khối này ở *Đã đi rồi* sáng hôm sau. Cả hai đều không giành
  hành động chính cấp thẻ. UI/UX Designer chốt cách hai khối này cùng tồn tại
  trong một hệ thẻ nhất quán.
- **Hợp đồng story này TIÊU THỤ:** STORY-002 AC-20/AC-21 (renderer nhận danh mục
  làm tham số), STORY-002 AC-17 (payload SB-125), STORY-001 AC-8/AC-9/AC-11/AC-14
  (mô hình thẻ, nguồn sinh, hành động chính, chuyển trạng thái hai chiều),
  STORY-003 (mục nhật ký + ảnh, riêng-tư-mặc-định), STORY-005 AC-11/AC-18 (đổi
  gợi ý thành thẻ, lịch âm tất định).
- **Hợp đồng story này KHÔNG tiêu thụ:** STORY-012. Không đọc trạng thái pha,
  không đọc khối J8, không vẽ widget (AC-31).
- **Tích hợp bên ngoài:** chỉ **OS Share Sheet**, cộng image picker của OS nếu
  bước đính ảnh cần. Không API nhắn tin, không dịch vụ nội dung, không AI.

## Open Question Impact

### Scope Items BLOCKED in this story

- **Không còn scope item nào của story này bị chặn bởi câu hỏi mở.** OQ-3 — mục
  duy nhất từng chặn (kho preset "lời cảm ơn sau hẹn") — đã đóng 2026-09-06 bằng
  D-15.

### Scope Items NOT BLOCKED in this story

- **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user), bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Câu trả lời không phải "chỉ định người duyệt lớp 2" mà là đổi bản
  chất nội dung: dữ liệu có schema + id bền, N là thuộc tính dữ liệu, luật bất
  biến cưỡng chế ở cổng nhập chạy được.
  - **Hết chặn:** ship gói preset "lời cảm ơn sau hẹn" vào bản build người dùng
    thật không còn chờ user chỉ định người duyệt lớp 2. Điều kiện ship nay là
    qua **cổng nhập dùng chung của STORY-002** cộng truy vết duyệt theo id bền.
  - **Thành ràng buộc mới của story:** AC-33..AC-36 và BR-16/BR-17/BR-18.
  - **Ràng buộc ranh giới quan trọng nhất:** story này **dùng lại cùng lược đồ
    và cùng cổng nhập** của STORY-002 (STORY-002 AC-29). Thêm danh mục là thay
    đổi **dữ liệu**; dựng nhánh cổng riêng cho danh mục này là vi phạm phạm vi.
  - **Văn bản gợi ý ở phần 3:** nếu phần "chốt việc kế tiếp" chỉ **hiển thị
    lại** mục có sẵn của STORY-005 thì nội dung đó thuộc gói của STORY-005 và đã
    qua cổng ở đó, không đi qua cổng lần thứ hai ở đây. Nếu thiết kế sinh ra câu
    dẫn mới có giọng điệu, câu đó phải là **dữ liệu** đi qua cùng cổng (AC-36).
  - **Còn lại của SB-123:** kiểm duyệt hai lớp giữ nguyên cho chất lượng biên
    tập (BR-15), nhưng hạ từ **chặn ship** xuống **rủi ro chất lượng nội dung**,
    sửa được bằng đổi dữ liệu mà không sửa code.

- **OQ-3 chưa bao giờ chặn engine, UI, hay luồng.** Theo đúng ranh giới STORY-002 đã
  đặt và tiền lệ STORY-006 về nhãn chức năng: quy tắc kích hoạt một lần (AC-1..
  AC-5), ràng buộc lồng SC-4 (AC-6, AC-7), đấu nối renderer (AC-8, AC-9), Share
  Sheet và payload (AC-12, AC-13), toàn bộ phần đính ảnh (AC-14..AC-18), toàn bộ
  cơ chế tạo thẻ (AC-19..AC-24), và mọi ràng buộc đạo đức (AC-25..AC-32) **xây và
  verify được ngay** bằng nội dung placeholder nội bộ. Nhãn nút và tiêu đề khối
  ("soạn lời cảm ơn", "chốt việc kế tiếp") là **nhãn chức năng**, không phải nội
  dung gửi cho người kia — không bị OQ-3 chặn.
- **L45 / OQ-18 — ĐÓNG** (user chốt 2026-09-03: chặng 1 là kho tài sản). Story
  này không chịu tải định vị; ba story chịu tải là STORY-001, STORY-012,
  STORY-013.
- **Chặng 1.5 / link hai chiều / feed tin thật / Zalo Mini App / thương mại /
  J7 — ĐÓNG, binding out of scope** của REQ-016. Payload SB-125 ở AC-13 chỉ
  **không cản** chặng 1.5 tái dùng; story này không xây phần nào của kênh đó.
- **OQ-2 — ĐÓNG ở tầng sản phẩm** và thuộc STORY-001.
- **Khối J8 "23h vừa về" và widget theo pha — không mở, đã phân công** cho
  STORY-012 (BR-12, AC-31).
- **Định nghĩa kỹ thuật của "sáng hôm sau"** (mốc giờ, múi giờ thiết bị, hành vi
  khi đổi múi giờ) — giao **Tech Lead**. Ràng buộc sản phẩm duy nhất: tất định,
  tính trên thiết bị, và không được biến thành hạn chót người dùng có thể trượt
  (BR-3).
- **Chọn 2 hay 3 gợi ý ở phần 3, và luật chọn mục nào từ kho mồi** — giao **Tech
  Lead** chốt trong bảng tra. Ràng buộc sản phẩm: tất định, không AI, trong dải
  2-3 mục (AC-19).
- **Chi tiết trình bày** (khối mở/đóng thế nào, thứ tự ba phần, cách đính nhiều
  ảnh, cách khối này và "Trước giờ đi" cùng sống trong hệ thẻ) — giao **UI/UX
  Designer trong phạm vi story này**. Là quyết định UX, không phải câu hỏi sản
  phẩm còn mở.
- **SB-144/145/146 (trò chơi "đoán") — HOÃN**, không gán vào story này.

## Traceability

| AC | Nguồn ràng buộc |
|----|-----------------|
| AC-1..AC-5 | SB-212 kích hoạt một lần, J9, luật "không phạt khi im lặng", STORY-001 AC-14 |
| AC-6..AC-7 | SC-4, STORY-001 AC-11, tiền lệ hai tầng STORY-006 AC-4/AC-5 + STORY-002 BR-1 |
| AC-8..AC-11 | STORY-002 AC-20/AC-21/AC-22 + BR-13, R-7 không AI ở runtime |
| AC-12..AC-13 | STORY-002 AC-16/AC-17, SB-125, SC-1' |
| AC-14..AC-18 | STORY-003 riêng-tư-mặc-định + xoá được, SC-3 không thúc điền trước |
| AC-19..AC-24 | STORY-005 AC-11/AC-18, STORY-001 AC-8/AC-9, SC-2 đẩy kết quả ra ngoài |
| AC-25..AC-28 | R-1 nấc 3 cấm (f), R-1b, R-1d, R-14 |
| AC-29..AC-30 | R-7 không AI / không dịch vụ nội dung ngoài |
| AC-31 | Tiền lệ phụ thuộc một chiều STORY-006 AC-24/BR-11, ranh giới J8/STORY-012 |
| AC-32 | Cổng cứng REQ-016 |
| AC-33 | R-15a — schema + id bền, danh mục là DỮ LIỆU thêm vào gói STORY-002 (STORY-002 AC-29) |
| AC-34, AC-35 | R-15b — N là thuộc tính dữ liệu; hết-vòng đúng với mọi N; dải 2-3 là tham số bố cục |
| AC-36 | R-15c — cổng nhập dùng chung của STORY-002; R-1b, R-1g, cấm %, cấm streak |
| BR-16..BR-18 | D-15 / R-15 (`req_master.md` mục 15) |
