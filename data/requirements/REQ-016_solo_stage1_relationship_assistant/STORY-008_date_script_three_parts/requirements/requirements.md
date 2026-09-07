# Story Requirements: STORY-008 Kịch bản buổi hẹn 3 phần — màn (9)

- Requirement: REQ-016
- Story: STORY-008
- Complexity: standard
- Story-Class: standard
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: STORY-001, STORY-002, STORY-003, STORY-004
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules` (R-1e, R-1g, R-7, R-13,
  SB-174), `## Out of Scope` (J7), `## Open Questions`;
  `../../requirements/requirements.md` → `## Story Index`,
  `## Open Question Triage`;
  `../../STORY-001_activity_card_hub/requirements/requirements.md` →
  mô hình thẻ (AC-8), hành động chính "chuẩn bị" của *Đã hẹn ngày* (AC-11),
  không ngõ cụt (AC-13);
  `../../STORY-002_invite_message_composer/requirements/requirements.md` →
  cửa ra "xuất lời mời" (AC-1, AC-3), renderer (AC-20), khoá vị trí trong luồng
  thẻ;
  `../../STORY-004_relationship_notebook_and_gift_ideas/requirements/requirements.md` →
  cơ chế hỏi-tại-chỗ SC-3 (AC-1, AC-4, AC-5), sổ tay rỗng là hợp lệ (AC-8);
  `../../STORY-006_before_you_go_checklist/requirements/requirements.md` →
  tiền lệ đồng cư trong luồng "chuẩn bị" (AC-5, BR-1)

## Business Outcome

Người dùng **bước ra khỏi nhà với sự tự tin**, thay vì nỗi lo "ngồi im không
biết nói gì". Trước buổi hẹn, họ mở được một kịch bản ba phần — **trước / trong
/ sau** — nói về **đúng người này**, suy ra từ trường của thẻ và sổ tay họ đã ghi,
không phải lời khuyên hẹn hò chung chung trên mạng.

Story này phủ **J5**. Nó đứng **sau** sổ tay theo thứ tự không thương lượng
SB-174: kịch bản chỉ hết chung chung khi đã có kho ngữ cảnh của STORY-004 để
đọc.

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ.** Kịch bản sinh từ trường thẻ của người dùng, sổ tay do chính họ
ghi, và gói preset ship kèm app. Giá trị đạt trọn vẹn **trước khi buổi hẹn diễn
ra** — ở khoảnh khắc người dùng đọc xong và thấy bớt lo. Không AC nào cần người
kia trả lời, cài app, hay tồn tại trong hệ thống.

### Ranh giới J5 / J7 — điều làm story này khó

Phần "trong buổi hẹn" là **nội dung chuẩn bị trước, đọc trước khi đi**. Nó
**không** phải một bề mặt đồng hành lúc đang hẹn. J7 được **cố ý để trống** theo
triết lý "trợ lý trước/sau" — app rời khỏi tay lúc đang hẹn. Đây là quyết định
sản phẩm, không phải thiếu sót, và Nhóm C dưới đây tồn tại để nó không bị làm
trôi trong khâu thiết kế hay triển khai.

## Scope

### In Scope

1. Màn (9) "Kịch bản buổi hẹn", nội dung **ba phần**: trước / trong / sau.
2. Nội dung sinh **tất định** bằng preset + mad-libs từ (a) trường của thẻ — loại
   hoạt động, địa điểm, thời lượng, trong nhà/ngoài trời — và (b) sổ tay của
   STORY-004.
3. **Cửa vào duy nhất**: bên trong luồng "chuẩn bị" của một thẻ *Đã hẹn ngày* ở
   màn (1).
4. **Khoá vị trí** theo nhóm màn (8)/(9)/(10): không có trong menu chính, không
   có trong tab bar, không route trực tiếp tới được.
5. **Ba cửa ra bắt buộc** (SC-2): "xuất lời mời" (→ STORY-002) · "tạo thẻ mới"
   (→ màn (1), *Mới nghĩ ra*) · "ghi vào nhật ký" (→ STORY-003).
6. Sổ tay trống → kịch bản vẫn ra bản mặc định dùng được, cộng **một câu hỏi tại
   chỗ** theo đúng cơ chế SC-3 mà STORY-004 đã giao.
7. Kiểm duyệt nội dung **hai lớp** (SB-123) trước khi kho kịch bản vào bản build
   người dùng thật.

### Out of Scope

- **Mọi touchpoint chạy TRONG lúc đang hẹn (J7).** Không thông báo, không màn
  hiện lên, không nhắc theo giờ, không chế độ "đang hẹn", không bấm giờ, không
  checklist thời gian thực. Phần "trong" là chữ đọc trước khi đi.
- **Kịch bản thao túng, gài bẫy, "chiêu" gây ấn tượng** và **A/B test lời nói** —
  R-1e cấm nguyên vẹn.
- **Chấm điểm buổi hẹn, chấm điểm phản ứng của người kia, đánh giá kịch bản nào
  "hiệu quả hơn"** — R-1e tầng 3 cấm.
- Đường vào từ menu chính, tab bar, hay deep link/route trực tiếp — vi phạm khoá
  vị trí.
- Cửa ra thứ tư, hay biến màn này thành nơi đọc lại/lưu trữ kịch bản cũ (SC-2:
  không phải điểm dừng chân).
- Màn (8) chân dung và màn (10) bảng tra ăn khớp — STORY-009/STORY-010 **thêm**
  liên kết đi ra từ màn này về sau; story này không xây chúng.
- Sửa mô hình thẻ (STORY-001), mô hình sổ tay (STORY-004), hay engine renderer
  (STORY-002).
- Ghi âm, chép lại, hay lưu bất kỳ nội dung nào diễn ra trong buổi hẹn thật.
- Chặng 1.5, link hai chiều, feed tin thật, Zalo Mini App, thương mại/affiliate
  quà.

## Acceptance Criteria

### Nhóm A — Cửa vào duy nhất và khoá vị trí

**AC-1.** Given người dùng đang ở một thẻ *Đã hẹn ngày*, when họ đi theo hành
động chính "chuẩn bị" của thẻ đó, then "kịch bản buổi hẹn" là một hành động
**đến được trong luồng chuẩn bị**, và mở ra màn (9) gắn với **đúng thẻ đó**.

**AC-2.** Given màn (9) mở ra, when nội dung hiển thị, then nội dung khớp **loại
hoạt động và các trường của chính thẻ nguồn**, không phải một kịch bản chung
không gắn thẻ.

**AC-3.** Given người dùng duyệt **toàn bộ** menu chính và tab bar, when họ tìm
màn kịch bản, then **không** mục nào dẫn thẳng tới nó. Màn (9) thuộc **nhóm khoá
vị trí** cùng màn (8) và màn (10).

**AC-4.** Given một route/deep link trỏ thẳng vào màn (9), when nó được mở mà
người dùng **không** đi qua một thẻ *Đã hẹn ngày* đang chạy, then app **không**
hiển thị màn kịch bản. Direct URL only acceptable: **NO**.

**AC-5.** Given một thẻ **không** ở trạng thái *Đã hẹn ngày*, when người dùng mở
chi tiết thẻ, then đường vào màn (9) **không** xuất hiện.

**AC-6.** Given người dùng ở trong luồng "chuẩn bị" của một thẻ *Đã hẹn ngày*,
when họ nhìn các hành động trong luồng đó, then "kịch bản buổi hẹn" **không**
thêm một hành động chính **cấp thẻ** thứ hai: *Đã hẹn ngày* vẫn có đúng một hành
động chính "chuẩn bị" (SC-4, STORY-001 AC-11).

### Nhóm B — Nội dung ba phần, sinh tất định

**AC-7.** Given màn (9) mở ra, when nội dung hiển thị, then nó có **đúng ba
phần** rõ ràng: **trước** buổi hẹn · **trong** buổi hẹn · **sau** buổi hẹn.

**AC-8.** Given cùng một thẻ, cùng nội dung sổ tay, và cùng lựa chọn của người
dùng, when kịch bản được sinh ra ở hai lần mở khác nhau, then nội dung **giống
hệt nhau** (tất định).

**AC-9.** Given sổ tay có mục liên quan tới loại hoạt động của thẻ, when kịch bản
được sinh ra, then nội dung **có nhắc tới ngữ cảnh cụ thể đó**, không dừng ở lời
khuyên chung chung (SB-174: kịch bản đứng sau sổ tay là để đạt điều này).

**AC-10.** Given một trường của thẻ hoặc một mục sổ tay **không có giá trị**,
when kịch bản được sinh ra, then đoạn phụ thuộc dữ liệu đó vẫn đọc trôi và
**không** chứa ô trống, dấu ngoặc rỗng, hay chuỗi placeholder lộ ra.

**AC-11.** Given thiết bị **không có mạng**, when màn (9) mở ra, then toàn bộ ba
phần vẫn đúng và đầy đủ, vì nội dung sinh từ gói preset ship kèm app cộng dữ liệu
cục bộ.

**AC-12.** Given bất kỳ đường đi nào của story này, when nội dung được sinh ra,
then app **không** gọi mô hình AI và **không** gọi dịch vụ nội dung ngoài nào
(R-7).

### Nhóm C — Ranh giới J7: app rời khỏi tay lúc đang hẹn

**AC-13.** Given người dùng đã đọc phần "trong buổi hẹn", when họ đóng app và đi
hẹn, then app **không** gửi thông báo, **không** hiện màn hình, **không** rung,
và **không** yêu cầu bất kỳ thao tác nào trong suốt khoảng thời gian buổi hẹn.

**AC-14.** Given phần "trong buổi hẹn" hiển thị, when người dùng đọc nó, then nó
được trình bày là **nội dung chuẩn bị trước** — không có bộ đếm giờ, không có
checklist tick-theo-thời-gian-thực, không có nút "bắt đầu buổi hẹn", không có
bước nào ngụ ý người dùng mở app lúc đang ngồi với người kia.

**AC-15.** Given app biết ngày và giờ hẹn từ thẻ, when thời điểm đó tới, then app
**không** dùng thông tin đó để kích hoạt bất kỳ bề mặt nào của story này. Dữ liệu
lịch dùng để **chuẩn bị trước**, không để can thiệp trong lúc hẹn.

**AC-16.** Given buổi hẹn đã diễn ra xong, when người dùng quay lại app, then
story này **không** hỏi buổi hẹn diễn ra thế nào, **không** chấm điểm, và
**không** yêu cầu báo cáo kết quả. Việc ghi lại sau buổi hẹn thuộc cửa ra "nhật
ký" (STORY-003) và thuộc STORY-007, do người dùng chủ động.

### Nhóm D — Ba cửa ra bắt buộc (SC-2)

**AC-17.** Given màn (9) đang mở, when người dùng xem các hành động, then có
**đủ ba cửa ra**: "xuất lời mời" · "tạo thẻ mới" · "ghi vào nhật ký".

**AC-18.** Given người dùng bấm "xuất lời mời", when hành động chạy, then luồng
xuất lời mời của **STORY-002** mở ra gắn trên đúng thẻ nguồn — không phải một
engine soạn nội dung thứ hai.

**AC-19.** Given người dùng bấm "tạo thẻ mới", when họ xác nhận, then một thẻ mới
xuất hiện ở màn (1) ở trạng thái *Mới nghĩ ra*, theo đúng mô hình thẻ và bốn
trạng thái của STORY-001, trong **kho chung** duy nhất (SC-1').

**AC-20.** Given người dùng bấm "ghi vào nhật ký", when hành động chạy, then một
mục nhật ký được tạo hoặc mở ở màn (4) **mang sẵn ngữ cảnh của thẻ**, và mục đó
vẫn **riêng-tư-mặc-định** theo STORY-003.

**AC-21.** Given người dùng đọc xong màn (9) mà không chọn cửa ra nào, when họ
đóng màn, then họ quay về **đúng thẻ nguồn** trong luồng "chuẩn bị", không bị rơi
ra màn khác và không mất dữ liệu thẻ.

**AC-22.** Given màn (9), when người dùng dùng nó, then màn **không** tích luỹ
lịch sử kịch bản đã đọc, **không** có danh sách "kịch bản của tôi", và **không**
có bề mặt nào mời người dùng ở lại đọc tiếp — nó đẩy một kết quả ra ngoài rồi
kết thúc (SC-2).

### Nhóm E — Sổ tay trống, và hỏi tại chỗ

**AC-23.** Given sổ tay còn **trống hoàn toàn**, when màn (9) mở ra, then kịch
bản **vẫn ra được bản mặc định dùng được** cho cả ba phần; màn không chặn, không
báo lỗi, không yêu cầu điền trước.

**AC-24.** Given kịch bản cần một trường sổ tay chưa có, when màn (9) hiển thị,
then app hỏi **đúng một câu** theo cơ chế hỏi-tại-chỗ của **STORY-004**, dùng
luôn câu trả lời và âm thầm lưu vào sổ tay. Story này **gọi lại** cơ chế đó,
không xây cơ chế hỏi thứ hai.

**AC-25.** Given người dùng **bỏ qua** câu hỏi tại chỗ, when họ tiếp tục, then
kịch bản vẫn hiển thị bản mặc định, và app **không** nhắc lại, không chặn cửa ra,
không hiện thông điệp kiểu "sổ tay của bạn còn thiếu thông tin" (SC-3).

### Nhóm F — Ranh giới đạo đức của nội dung

**AC-26.** Given bất kỳ đoạn nào nói về người kia, when đọc hết đoạn, then nó kết
thúc bằng **một câu để hỏi người thật**, không bằng một nhận định chốt hạ (R-1g).
Bài kiểm tra: đọc xong, người dùng muốn hỏi người kia **nhiều hơn**.

**AC-27.** Given toàn bộ kho kịch bản, when nội dung được duyệt và khi hiển thị,
then **không** preset nào dạy thao túng, gài bẫy, "chiêu" gây ấn tượng, hay kịch
bản dẫn dắt người kia vào một phản ứng định sẵn (R-1e).

**AC-28.** Given story này, when nó chạy, then **không** tồn tại A/B test lời
nói, **không** xếp hạng "kịch bản nào hiệu quả hơn", và **không** thu thập kết
quả buổi hẹn để tối ưu nội dung (R-1e).

**AC-29.** Given bất kỳ nội dung nào trong màn (9), when nó hiển thị, then app
**không** hiển thị và **không** lưu chỉ báo hành vi của người kia — không tần
suất, không "hay trả lời chậm", không nhận xét con người. Chỉ **sở thích và sự
kiện** từ sổ tay được dùng (R-1b, R-1f).

**AC-30.** Given nội dung có đùa, when đọc toàn văn, then câu đùa **chỉ nhắm vào
người gửi/người dùng**; cấm mọi câu đùa, nhận xét, hay gán nhãn nhắm vào người
kia (R-1d).

### Nhóm G — Kiểm duyệt nội dung và cổng cứng

**AC-31.** Given kho kịch bản chuẩn bị vào bản build người dùng thật, when nội
dung được đưa vào, then mỗi preset đã đi qua **quy trình kiểm duyệt hai lớp**
(SB-123) cho **chất lượng biên tập** (giọng, độ sượng, tính dùng được), và
trạng thái duyệt ghi lại truy vết được cho từng preset qua **id bền** của
preset đó. Kiểm duyệt hai lớp **không** là cơ chế cưỡng chế luật bất biến —
việc đó thuộc cổng nhập chạy được ở AC-36 (R-15c). Kho kịch bản **không còn bị
chặn ship** vì thiếu người duyệt lớp 2: OQ-3 đã đóng 2026-09-06 bằng D-15.

**AC-32.** Given người dùng chưa từng có, và sẽ không bao giờ có, phản hồi từ
người kia, when họ dùng story này, then **mọi** AC ở trên vẫn đạt được; và story
này **không** cần STORY-009, STORY-010, hay STORY-012 để chạy — hai story kia
chỉ **thêm** liên kết đi ra từ màn này về sau.

### Nhóm H — Nội dung là dữ liệu có cổng nhập (R-15 / D-15)

**AC-33.** Given kho kịch bản ba phần và các khung mad-libs của nó, when chúng
được ship, then chúng là **gói dữ liệu có lược đồ, mỗi preset có định danh
bền**, không phải chuỗi cứng trong widget/code; đổi nguồn nội dung sang CMS
ngoài repo **không kéo theo một lần sửa code** (R-15a).

**AC-34.** Given kho kịch bản có **N preset bất kỳ** (N ≥ 1), when một thẻ *Đã
hẹn ngày* mở màn (9), then phép chọn preset là **hàm toàn phần và tất định**:
không thẻ nào rơi vào trạng thái "không có kịch bản". Nếu loại hoạt động của
thẻ không khớp preset chuyên biệt nào, thì rơi về preset tổng quát và **vẫn đủ
ba phần** (AC-7). Luật này đúng với mọi N — 1, 10, hay vài trăm — và **không**
AC nào của story này được suy ra từ việc kho seed có 10 mục mỗi gói (R-15b).

**AC-35.** Given màn (9), when người dùng dùng màn, then **không** hiển thị số
preset còn lại, chỉ báo tiến độ duyệt kho, hay thông báo "đã xem hết kịch
bản". Nếu về sau có cơ chế xem một kịch bản khác cho cùng thẻ, then hành vi khi
duyệt hết tập là **quay vòng tất định về đầu**, không màn ngõ cụt, không thông
báo "đã hết" — và luật đó phát biểu theo N, không theo một con số cố định
(R-15b, cùng luật với STORY-005 AC-27).

**AC-36.** Given một preset vi phạm luật bất biến — đo hành vi người kia
(R-1b), tâng bốc, hiển thị %, streak, đùa nhắm vào người kia (AC-30), hoặc
đoạn nói về người kia không kết bằng câu hỏi (R-1g) — when preset đó được nạp
qua cổng nhập nội dung, then cổng **từ chối preset đó và làm hỏng bản dựng**;
vi phạm **không** được phép lọt tới lúc người dùng đọc. Cổng chạy được kể cả
với preset do CMS ngoài repo cấp, tức nội dung **không** đi qua review của repo
này (R-15c).

**AC-37.** Given lược đồ mad-libs của một preset, when một slot dữ liệu không
có giá trị, then cổng nhập bảo đảm AC-10 đạt được **cho mọi preset trong kho ở
mọi N** — không ô trống, không dấu ngoặc rỗng, không chuỗi placeholder lộ ra —
chứ không phải kiểm bằng mắt từng preset lúc biên tập (R-15a/R-15c).

## Business Rules

- **BR-1 (khoá vị trí — màn (9) thuộc nhóm (8)/(9)/(10)).** Đặc tả mục C gộp ba
  màn (8), (9), (10) vào nhóm **"KHOÁ VỊ TRÍ"**, trong khi luật bất biến 13 /
  SC-6 chỉ **gọi tên** chân dung (màn 8) và bảng tra ăn khớp (màn 10). Phán quyết
  sản phẩm: **màn (9) là khoá vị trí theo tư cách thành viên nhóm.** Lý do là
  bản chất của màn, không phải suy diễn từ danh sách: kịch bản chỉ có nghĩa khi
  gắn với **một buổi hẹn cụ thể đang chạy**, nên nó chỉ tới được từ một thẻ *Đã
  hẹn ngày*. Một mục "Kịch bản buổi hẹn" đứng trong tab bar sẽ mở ra một màn
  không biết mình đang nói về buổi hẹn nào — chính là kiểu chung chung mà SB-174
  tồn tại để chống. `story_master.md` đã khoá điều này ("nhóm KHOÁ VỊ TRÍ",
  "Direct URL only acceptable: NO") và AC-3/AC-4/AC-5 thi hành nó.
- **BR-1a (ranh giới với R-13).** Ràng buộc của màn (9) đến từ **tư cách thành
  viên nhóm khoá vị trí + tính gắn-thẻ**, không phải từ R-13 (R-13 hard-name màn
  (8) và màn (10) vì lý do đạo đức khác: chúng nói **về người kia**). Hai lý do
  khác nhau, cùng một hệ quả điều hướng. Ghi rõ ở đây để story sau không nhầm màn
  (9) với một bề mặt R-13.
- **BR-2 (SC-4 — lồng, không cạnh tranh).** *Đã hẹn ngày* có **đúng một** hành
  động chính cấp thẻ: "chuẩn bị" (STORY-001 AC-11). "Kịch bản buổi hẹn" là một
  đường đi **bên trong** luồng đó, ở mức thị giác thấp hơn — cùng chỗ "xuất lời
  mời" (STORY-002 AC-1) và "Trước giờ đi" (STORY-006 AC-5) đang sống. Ba thứ này
  đồng cư trong một luồng chuẩn bị và khác nhau về thời điểm/mục đích; UI/UX
  Designer chốt cách chúng cùng tồn tại mà không rối.
- **BR-3 (J7 là quyết định, không phải khoảng trống chờ lấp).** Phần "trong buổi
  hẹn" = **chữ chuẩn bị trước**. Bất kỳ đề xuất nào biến nó thành bề mặt đồng
  hành lúc đang hẹn — thông báo theo giờ, bộ đếm, chế độ "đang hẹn", nhắc chủ đề
  thời gian thực — là **lấn phạm vi requirement**, phải quay lại Product Owner,
  không được coi là cải tiến UX. Đây là ranh giới cứng, không phải sở thích.
- **BR-4 (R-7 — tất định, không AI ở runtime).** Nội dung đi đường PRESET +
  MAD-LIBS + KHUNG NHẠI, sinh từ (trường thẻ, sổ tay, lựa chọn của người dùng).
  AI chỉ dùng **ngoài hệ thống, ở khâu soạn nội dung**, và sản phẩm của nó vào
  repo như gói dữ liệu tĩnh đã qua kiểm duyệt hai lớp.
- **BR-5 (SB-174 — đứng sau sổ tay).** Story này phụ thuộc STORY-004 **về nội
  dung**, không chỉ về kỹ thuật. Ship kịch bản trước khi sổ tay hết chung chung
  sẽ cho ra đúng thứ requirement muốn tránh. Thứ tự này không thương lượng.
- **BR-6 (SC-2 — ba cửa ra, không phải điểm dừng chân).** Màn (9) **phải đẩy một
  kết quả ra ngoài**: một lời mời, một thẻ, hoặc một mục nhật ký. Nó không tích
  luỹ lịch sử, không có kho kịch bản cá nhân, không mời người dùng ở lại. Cửa ra
  thứ tư cần quyết định sản phẩm mới.
- **BR-7 (cửa ra gọi lại, không nhân bản).** Ba cửa ra dùng **đúng** hạ tầng đã
  giao: STORY-002 cho lời mời, STORY-001 cho thẻ mới, STORY-003 cho nhật ký. Xây
  bản sao rút gọn của bất kỳ hạ tầng nào trong số đó là vi phạm ranh giới story.
- **BR-8 (SC-3 — hỏi tại chỗ, không điền trước).** Câu hỏi trong màn này dùng
  **cơ chế hỏi-tại-chỗ của STORY-004**: đúng một câu, dùng luôn, âm thầm lưu, bỏ
  qua được không hệ quả. Không luồng onboarding, không biểu mẫu, không chặn.
- **BR-9 (sổ tay trống là hành vi hợp lệ).** Bản kịch bản mặc định phải **thật sự
  dùng được**, không phải một vỏ rỗng thúc người dùng đi điền sổ tay. Dùng màn
  này làm đòn bẩy ép điền dữ liệu là biến J5 thành biểu mẫu trá hình, ngược SC-3.
- **BR-10 (R-1e — cấm thao túng và A/B test).** Kho kịch bản là **gợi ý để người
  dùng tự tin hơn**, không phải chiêu tác động lên người kia. Cấm nguyên vẹn:
  kịch bản dẫn dắt phản ứng, A/B test lời nói, xếp hạng hiệu quả, chấm điểm buổi
  hẹn hay phản ứng của người kia.
- **BR-11 (R-1g — kết bằng câu hỏi).** Mọi đoạn nói về người kia kết thúc bằng
  **một câu để hỏi người thật**. Một preset kết thúc bằng nhận định chốt hạ là
  preset **không hợp lệ**, không phải khuyết điểm nhỏ.
- **BR-12 (R-1b/R-1f — chỉ sở thích và sự kiện).** Kịch bản đọc sổ tay ở đúng
  ranh giới STORY-004 đã khoá: **sở thích + sự kiện** ✅, **tần suất + hành vi** ❌.
  Không đại lượng nào về người kia được sinh ra, hiển thị, hay lưu ở đây.
- **BR-13 (SB-123 — kiểm duyệt hai lớp, phạm vi đã thu hẹp bởi D-15).** Không
  preset kịch bản nào ra bản build người dùng thật khi chưa qua hai lớp duyệt
  **về chất lượng biên tập**. Sau D-15, đây **không** còn là cơ chế cưỡng chế
  luật bất biến và **không** còn là điểm OQ-3 cắn vào story này — xem BR-18.
- **BR-14 (R-14 — không paywall lõi).** Kịch bản buổi hẹn là phần lõi của chặng
  1; không đặt phần nào sau paywall.
- **BR-15 (không phụ thuộc story tương lai).** STORY-009 (chân dung) và STORY-010
  (bảng tra ăn khớp) sẽ **thêm** liên kết khoá vị trí đi ra từ màn này. Phụ thuộc
  đó là **một chiều**: story này phải chạy trọn vẹn khi hai story kia chưa tồn
  tại (AC-32), đúng tiền lệ STORY-006 BR-11 đặt cho quan hệ với STORY-012.
- **BR-16 (R-15a — nội dung là dữ liệu, không phải chuỗi trong code).** Kho
  kịch bản ba phần và khung mad-libs là gói dữ liệu có lược đồ, mỗi preset có
  **id bền** dùng làm khoá truy vết trạng thái duyệt (AC-31). Cấm câu chữ kịch
  bản nằm trong widget/code. Tiêu chí nghiệm thu: đổi nguồn sang CMS ngoài repo
  mà **không sửa một dòng code nào**.
- **BR-17 (R-15b — N là thuộc tính dữ liệu).** Bộ seed 10 mục cho mỗi gói
  **xoay vòng** là dữ liệu bản đầu, **không** phải hằng số của story. Cấm mọi
  AC, BR, hay bố cục dựa vào "vì có đúng 10 mục nên…" — đặc biệt phép chọn
  preset (AC-34), hành vi hết-tập, và chỉ báo tiến độ (AC-35). Hành vi phải
  đúng với mọi N, kể cả khi CMS nâng lên vài trăm preset.
- **BR-18 (R-15c — luật bất biến là CỔNG NHẬP, không phải quy ước biên tập).**
  R-1b, R-1f, R-1g, chống tâng bốc, cấm hiển thị %, cấm streak, và ranh giới
  đùa của AC-30 được cưỡng chế ở **tầng lược đồ/validation của cổng nhập nội
  dung**, chạy được trong bản dựng: preset vi phạm bị từ chối tại cổng và làm
  hỏng bản dựng. Kiểm duyệt hai lớp (BR-13) vẫn giữ, nhưng chỉ cho **chất lượng
  biên tập**: nó là quy ước con người, không đáng tin với nội dung CMS tương lai
  vốn không đi qua review của repo này.

## System Integration And Discoverability

- **UI-facing story:** YES.
- **Existing user-visible surface:** YES — thẻ *Đã hẹn ngày* ở màn (1) do
  STORY-001 giao, bên trong luồng "chuẩn bị".
- **Điểm vào:** **duy nhất**, từ luồng "chuẩn bị" của một thẻ *Đã hẹn ngày*. Màn
  (9) **không** xuất hiện trong menu chính hay tab bar. **Direct URL only
  acceptable: NO** — điều hướng thẳng bằng route là vi phạm khoá vị trí (AC-4).
- **Vị trí trong nhóm khoá vị trí:** màn (9) đứng cùng nhóm với màn (8) và màn
  (10), nhưng vì lý do khác — xem BR-1 và BR-1a. Điều này quan trọng với UI/UX
  Designer: ba màn có cùng ràng buộc điều hướng, khác ràng buộc nội dung.
- **Đồng cư trong luồng "chuẩn bị":** ba thứ cùng lồng vào hành động "chuẩn bị"
  của một thẻ *Đã hẹn ngày* — "xuất lời mời" (STORY-002, dùng **trước khi rủ**),
  "kịch bản buổi hẹn" (story này, dùng **trước khi đi**), "Trước giờ đi"
  (STORY-006, mở **đúng ngày đi**). Không thứ nào giành hành động chính cấp thẻ.
- **Hợp đồng story này TIÊU THỤ:** STORY-001 AC-8/AC-11 (mô hình thẻ, hành động
  chính), STORY-002 AC-1/AC-20 (luồng xuất lời mời, renderer), STORY-003 (mục
  nhật ký riêng-tư-mặc-định), STORY-004 AC-1/AC-4/AC-5 (cơ chế hỏi-tại-chỗ, kho
  sổ tay).
- **Hợp đồng story này KHÔNG tiêu thụ:** STORY-009, STORY-010, STORY-012.
- **Tích hợp bên ngoài:** không có. Cửa ra "xuất lời mời" đi tiếp tới OS Share
  Sheet **thuộc phạm vi STORY-002**, không phải tích hợp mới của story này.

## Open Question Impact

### Scope Items BLOCKED in this story

- **Không còn scope item nào của story này bị chặn bởi câu hỏi mở.** OQ-3 —
  mục duy nhất từng chặn (ship gói preset kịch bản, AC-31) — đã đóng 2026-09-06
  bằng D-15.

### Scope Items NOT BLOCKED in this story

- **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user), bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Kho kịch bản ba phần vẫn là loại nội dung nhạy nhất trong REQ (chạm
  cả R-1e lẫn R-1g), nhưng cách bảo vệ đã đổi: **không** còn là "chờ user chỉ
  định người duyệt lớp 2", mà là **cổng nhập chạy được**.
  - **Hết chặn:** ship gói preset kịch bản vào bản build người dùng thật
    (AC-31) không còn chờ user chỉ định người duyệt lớp 2.
  - **Thành ràng buộc mới của story:** AC-33..AC-37 và BR-16/BR-17/BR-18.
    R-15b **chốt hành vi hết-tập/chọn preset** của story này (AC-34, AC-35) là
    luật tổng quát cho mọi N, không phải luật cho N=10.
  - **Còn lại của SB-123:** kiểm duyệt hai lớp giữ nguyên cho chất lượng biên
    tập (BR-13), hạ từ **chặn ship** xuống **rủi ro chất lượng nội dung**, sửa
    được bằng đổi dữ liệu mà không sửa code (R-15a).
- **OQ-3 chưa bao giờ chặn màn, điều hướng, hay cơ chế.** Toàn bộ ràng buộc khoá vị trí
  (AC-1..AC-6), cấu trúc ba phần và tính tất định (AC-7..AC-12), ranh giới J7
  (AC-13..AC-16), ba cửa ra (AC-17..AC-22), và cơ chế hỏi-tại-chỗ (AC-23..AC-25)
  **xây và verify được ngay** bằng nội dung placeholder nội bộ. Nhãn ba phần
  ("trước / trong / sau") và nhãn ba cửa ra là **nhãn chức năng**, không phải nội
  dung có giọng điệu — theo đúng tiền lệ STORY-006 BR-14, chúng không bị OQ-3
  chặn.
- **Màn (9) có phải khoá vị trí không — ĐÓNG, quyết định ở BR-1.** Đặc tả mục C
  (nhóm 8/9/10) và luật bất biến 13 (hard-name 8 và 10) không mâu thuẫn: chúng
  nói hai chuyện khác nhau. Màn (9) khoá vị trí vì gắn-thẻ, màn (8)/(10) khoá
  thêm vì lý do đạo đức R-13. Không phải câu hỏi mở.
- **L45 / OQ-18 — ĐÓNG** (user chốt 2026-09-03: chặng 1 là kho tài sản). Story
  này không chịu tải định vị; ba story chịu tải là STORY-001, STORY-012,
  STORY-013.
- **J7 — ĐÓNG, binding out of scope** và là **quyết định**, không phải thiếu sót
  (BR-3). Không mở lại trong phạm vi REQ-016.
- **Chặng 1.5 / link hai chiều / feed tin thật / Zalo Mini App / thương mại —
  ĐÓNG, binding out of scope** của REQ-016.
- **OQ-2 — ĐÓNG ở tầng sản phẩm** và thuộc STORY-001.
- **SB-144/145/146 (trò chơi "đoán") — HOÃN**, không gán vào story này.
- **Danh sách trường thẻ và mục sổ tay nào lái phần nào của kịch bản**, cùng cấu
  trúc bảng tra — giao **Tech Lead** chốt trong gói dữ liệu. Ràng buộc sản phẩm
  duy nhất: tất định, ship kèm app, không dịch vụ ngoài, không AI.
- **Chi tiết trình bày** (ba phần cuộn hay tab, vị trí ba cửa ra, cách màn (9)
  đồng cư với "xuất lời mời" và "Trước giờ đi" trong luồng chuẩn bị, cách hiển
  thị câu hỏi tại chỗ) — giao **UI/UX Designer trong phạm vi story này**. Là
  quyết định UX, không phải câu hỏi sản phẩm còn mở.

## Traceability

| AC | Nguồn ràng buộc |
|----|-----------------|
| AC-1..AC-2 | STORY-001 AC-11 "chuẩn bị", tiền lệ vào-trong-luồng STORY-002 AC-1 |
| AC-3..AC-5 | Đặc tả mục C nhóm khoá vị trí (8)/(9)/(10), SC-6, BR-1 |
| AC-6 | SC-4, STORY-001 AC-11, tiền lệ hai tầng STORY-002 AC-2 + STORY-006 AC-4 |
| AC-7..AC-10 | Đặc tả C.9 ba phần, SB-174 đứng sau sổ tay, hợp đồng thẻ STORY-001 AC-8 |
| AC-11..AC-12 | R-7 không AI ở runtime, không dịch vụ ngoài |
| AC-13..AC-16 | J7 binding out of scope, triết lý "trợ lý trước/sau", BR-3 |
| AC-17..AC-22 | SC-2 ba cửa ra, SC-1' một kho, STORY-002/001/003 hợp đồng cửa ra |
| AC-23..AC-25 | SC-3, STORY-004 AC-1/AC-4/AC-5, sổ tay rỗng hợp lệ STORY-004 AC-8 |
| AC-26..AC-30 | R-1g, R-1e, R-1b, R-1d, R-1f |
| AC-31 | SB-123 kiểm duyệt hai lớp (chất lượng biên tập); OQ-3 ĐÃ ĐÓNG bằng D-15 |
| AC-32 | Cổng cứng REQ-016, phụ thuộc một chiều (BR-15) |
| AC-33, AC-37 | R-15a — schema + id bền, đổi nguồn sang CMS không sửa code |
| AC-34, AC-35 | R-15b — N là thuộc tính dữ liệu; chọn preset và hết-tập đúng với mọi N |
| AC-36 | R-15c — cổng nhập chạy được; R-1b, R-1e, R-1g, AC-30, cấm %, cấm streak |
| BR-16..BR-18 | D-15 / R-15 (`req_master.md` mục 15) |
