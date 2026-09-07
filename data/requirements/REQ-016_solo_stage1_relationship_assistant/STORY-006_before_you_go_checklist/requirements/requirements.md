# Story Requirements: STORY-006 "Trước giờ đi" — checklist tất định (SB-211)

- Requirement: REQ-016
- Story: STORY-006
- Complexity: standard
- Story-Class: standard
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: STORY-001
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules`, `## Out of Scope`,
  `## Open Questions`; `../../requirements/requirements.md` →
  `## Story Index`, `## Open Question Triage`;
  `../../STORY-001_activity_card_hub/requirements/requirements.md` →
  hợp đồng mô hình thẻ, trạng thái, và SC-4;
  `../../STORY-002_invite_message_composer/requirements/requirements.md` →
  tiền lệ lồng vào luồng "chuẩn bị" (AC-1, AC-2, BR-1)

## Business Outcome

Người dùng **không tới nơi mới phát hiện thiếu thứ cần mang**. Đúng ngày hẹn,
mở thẻ ra là có sẵn một danh sách ngắn, nhắc đúng những thứ **buổi hẹn cụ thể
này** cần — suy ra từ chính trường người dùng đã điền trên thẻ.

Story này phủ **J6**, journey trước đây bị trống ngoài ý muốn (khác J7 "trong
buổi hẹn", vốn được cố ý để trống). Nó là **mở rộng của màn (1)**, không phải
màn hình thứ 12 — tổng vẫn là 11 màn hình.

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ.** Checklist sinh hoàn toàn từ trường trên thẻ của người dùng và
một gói dữ liệu tĩnh. Không AC nào cần người kia trả lời, cài app, hay tồn tại
trong hệ thống.

## Scope

### In Scope

1. Khối "Trước giờ đi" **tự động mở** trên chi tiết thẻ khi thẻ ở trạng thái
   *Đã hẹn ngày* **và** ngày hẹn = hôm nay.
2. Khối nằm **bên trong luồng "chuẩn bị"** của thẻ — không giành hành động chính
   cấp thẻ (SC-4 giữ nguyên như STORY-001 đã khoá).
3. Nội dung sinh **tất định bằng bảng tra tay** từ trường có sẵn của thẻ:

   | Điều kiện trên thẻ | Gợi ý hiện ra |
   |---|---|
   | có giá > 0, hình thức trả tại chỗ | "mang đủ tiền mặt" |
   | khoảng cách vượt ngưỡng | "đổ xăng / sạc xe trước khi đi" |
   | mùa = mùa mưa theo miền | "mang áo mưa/ô, có phương án B trong nhà" |
   | cần đặt trước = có | "xác nhận lại chỗ đã đặt" |
   | luôn có | "chia sẻ vị trí" |

4. **Chỉ hiện mục khớp trường thật có trên thẻ.** Thẻ thưa trường → khối ngắn
   hoặc trống, và đó là hành vi đúng.
5. **Một hành động chính trong phạm vi khối**: "Xong hết rồi, đi thôi" — đóng
   khối.
6. "Chia sẻ vị trí" đi qua **OS Share Sheet, một lần**.
7. Phát ra **trạng thái pha "trước giờ đi"** như dữ liệu để STORY-012 đọc và
   phản chiếu lên widget. Story này **định nghĩa** pha; STORY-012 **vẽ** nó.

### Out of Scope

- **Vẽ pha thứ tư lên widget** — STORY-012. Story này chỉ giao trạng thái pha.
- Báo thức thật / thông báo cưỡng bức.
- **Theo dõi vị trí thời gian thực**, chia sẻ vị trí liên tục, hay bất kỳ hình
  thức định vị nào của người kia (R-1b).
- Gọi API thời tiết, bản đồ, giao thông, hay bất kỳ dịch vụ ngoài nào.
- Bất kỳ mục checklist nào không suy được từ một trường thật trên thẻ.
- Thêm trường mới vào mô hình thẻ — story này **đọc** mô hình STORY-001 đã khoá.
- Một hành động chính cấp thẻ thứ hai cho trạng thái *Đã hẹn ngày* — vi phạm
  SC-4.
- Chặng 1.5, link hai chiều, feed tin thật, Zalo Mini App, thương mại, J7.

## Acceptance Criteria

### Nhóm A — Điều kiện hiển thị và ràng buộc lồng (SC-4)

**AC-1.** Given một thẻ ở trạng thái *Đã hẹn ngày* có ngày hẹn = **hôm nay**,
when người dùng mở chi tiết thẻ, then khối "Trước giờ đi" **mở sẵn tự động**,
không cần thao tác bật.

**AC-2.** Given ngày hẹn của thẻ **không** phải hôm nay (kể cả ngày mai hoặc hôm
qua), when người dùng mở chi tiết thẻ, then khối "Trước giờ đi" **không** hiện.

**AC-3.** Given một thẻ **không** ở trạng thái *Đã hẹn ngày*, when người dùng mở
chi tiết thẻ, then khối **không** hiện, kể cả khi thẻ có ngày trùng hôm nay.

**AC-4.** Given một thẻ ở trạng thái *Đã hẹn ngày*, when thẻ hiển thị ở danh
sách màn (1) và ở chi tiết thẻ, then hành động chính **cấp thẻ** vẫn là **đúng
một** hành động — "chuẩn bị" như STORY-001 đã khoá. Story này **không** thêm
hành động chính cấp thẻ thứ hai (SC-4).

**AC-5.** Given khối "Trước giờ đi" đang hiện, when người dùng xem nó, then khối
nằm **bên trong luồng "chuẩn bị"** của thẻ đó, cùng nơi "xuất lời mời" của
STORY-002 sống; "Xong hết rồi, đi thôi" là hành động chính **trong phạm vi
khối**, ở mức thị giác thấp hơn rõ rệt so với hành động chính cấp thẻ.

**AC-6.** Given người dùng đang ở bất kỳ đâu ngoài luồng thẻ, when họ duyệt menu
chính hoặc tab bar, then "Trước giờ đi" **không** xuất hiện như một destination
riêng; nó không phải màn hình thứ 12.

### Nhóm B — Bảng tra tất định từ trường thật

**AC-7.** Given thẻ có giá > 0 và trả tại chỗ, khoảng cách vượt ngưỡng, và cần
đặt trước = có, when khối hiện ra, then **đúng ba dòng tương ứng** cộng dòng
"chia sẻ vị trí" xuất hiện, không dòng nào khác.

**AC-8.** Given một thẻ xem phim trong nhà không rơi vào điều kiện mùa mưa, when
khối hiện ra, then **không** có dòng "mang áo mưa/ô".

**AC-9.** Given một trường trên thẻ **không có giá trị**, when khối hiện ra,
then dòng phụ thuộc trường đó **không** xuất hiện; app không đoán, không điền
mặc định, và không hiện dòng ở dạng xám/đóng băng.

**AC-10.** Given cùng một thẻ với cùng bộ trường và cùng ngày, when khối được
sinh ra ở hai lần mở khác nhau, then nội dung khối **giống hệt nhau** (tất
định).

**AC-11.** Given điều kiện mùa mưa, when app xác định nó, then kết quả suy ra
**tất định theo miền và ngày** từ gói dữ liệu ship kèm app, **không** gọi dịch
vụ thời tiết.

### Nhóm C — Thẻ thưa trường là hành vi hợp lệ

**AC-12.** Given một thẻ gần như trống trường, when khối hiện ra, then khối chỉ
còn dòng "chia sẻ vị trí" hoặc **trống**, và đây là kết quả hợp lệ, không phải
lỗi.

**AC-13.** Given khối ngắn hoặc trống, when người dùng xem nó, then app **không**
hiện lời nhắc, gợi ý, hay lối tắt thúc người dùng đi điền thêm trường vào thẻ,
và không hiện thông điệp kiểu "thẻ của bạn còn thiếu thông tin".

**AC-14.** Given khối rỗng hoàn toàn, when chi tiết thẻ hiển thị, then màn chi
tiết thẻ vẫn dùng được bình thường và không có khoảng trống/khung rỗng gây hiểu
là lỗi tải.

### Nhóm D — Đóng khối

**AC-15.** Given khối đang hiện, when người dùng bấm "Xong hết rồi, đi thôi",
then khối đóng lại và **không hiện lại cho thẻ đó trong ngày**.

**AC-16.** Given người dùng đã đóng khối cho một thẻ hôm nay, when họ mở lại chi
tiết thẻ đó trong cùng ngày, then vẫn có đường **mở lại khối bằng tay** — đóng
khối không phải ngõ cụt (SC-5).

**AC-17.** Given người dùng đóng khối, when hành động chạy, then app **không**
đổi trạng thái thẻ và **không** kịch tính hoá hành động — không chúc mừng, không
hỏi lại, không thông điệp cảm xúc.

### Nhóm E — "Chia sẻ vị trí": an toàn cá nhân, không giám sát

**AC-18.** Given người dùng bấm "chia sẻ vị trí", when hành động chạy, then app
mở **OS Share Sheet một lần** và **không** bật bất kỳ chế độ theo dõi vị trí
liên tục nào.

**AC-19.** Given hành động chia sẻ vị trí đã chạy, when app xử lý xong, then app
**không lưu** vị trí đã chia sẻ, **không lưu** người nhận, và **không** tạo lịch
sử chia sẻ.

**AC-20.** Given tính năng này, when nó hiển thị và hoạt động, then đối tượng
được chia sẻ là **vị trí của chính người dùng**, do chính người dùng chủ động
gửi cho người họ chọn. App **không** truy vấn, suy ra, lưu, hay hiển thị vị trí
của **người kia** ở bất kỳ đâu (R-1b).

**AC-21.** Given người dùng không muốn chia sẻ vị trí, when họ bỏ qua dòng đó,
then không có hệ quả nào — không nhắc lại, không cảnh báo an toàn, không chặn
hành động "Xong hết rồi, đi thôi".

### Nhóm F — Tất định, ngoại tuyến, không AI, không API ngoài

**AC-22.** Given thiết bị **không có mạng**, when khối hiện ra, then toàn bộ nội
dung khối vẫn đúng và đầy đủ, vì nó sinh tất định từ trường của thẻ cộng gói dữ
liệu tĩnh.

**AC-23.** Given bất kỳ đường đi nào của story này, when khối được sinh ra, then
app **không** gọi mô hình AI và **không** gọi API ngoài nào — không thời tiết,
không bản đồ, không giao thông, không dịch vụ nội dung (R-7).

**AC-24.** Given khối "Trước giờ đi" đang ở trạng thái hoạt động cho một thẻ,
when trạng thái đó tồn tại, then app phát ra **trạng thái pha "trước giờ đi"**
đọc được cho STORY-012; story này **không** vẽ widget.

### Nhóm G — Ranh giới đạo đức và cổng cứng

**AC-25.** Given bất kỳ nội dung nào trong khối, when nó hiển thị, then app
**không** hiển thị và **không** lưu chỉ báo hành vi người kia — không "đã xem",
không xác nhận từ người kia, không "người ấy đã đọc kế hoạch" (R-1b).

**AC-26.** Given bất kỳ dòng nào trong khối, when nội dung hiển thị, then nó là
**việc người dùng tự làm được**, không phải nhận định về người kia và không phải
kịch bản gây ấn tượng (R-1e, R-1g).

**AC-27.** Given khối "Trước giờ đi", when người dùng dùng nó, then **không** có
streak, chuỗi ngày, huy hiệu, hay đếm số lần hoàn thành checklist (R-1, cấm
(f)), và **không** phần nào nằm sau paywall (R-14).

**AC-28.** Given người dùng chưa từng có, và sẽ không bao giờ có, phản hồi từ
người kia, when họ dùng story này, then **mọi** AC ở trên vẫn đạt được.

### Nhóm H — Nội dung là dữ liệu có cổng nhập (R-15 / D-15)

**AC-29.** Given **bảng tra tay** ship kèm app (BR-3) sinh các dòng checklist,
when nó được ship, then nó là **gói dữ liệu có lược đồ và định danh bền cho từng
dòng**, không phải chuỗi cứng trong widget/code; đổi nguồn bảng tra sang CMS
ngoài repo **không kéo theo một lần sửa code** (R-15a). Ràng buộc này áp **kể cả
khi** các dòng chỉ là nhãn chức năng (BR-14): R-15a áp cho **mọi** nội dung
preset, không riêng nội dung có giọng điệu.

**AC-30.** Given bảng tra có **N dòng bất kỳ** cho một tổ hợp (trường thẻ, ngày,
miền), when N nhỏ tới mức khối chỉ có một dòng hoặc không dòng nào, then khối
vẫn rơi vào trạng thái **thưa là hợp lệ** đã định ở AC-12..AC-14 mà không báo
lỗi và không ô trống giữ chỗ; when N lớn, then bố cục khối **không đổi** và
không có bước tải/đợi mới. Số dòng là **thuộc tính dữ liệu**; **không** AC nào
của story này được suy ra từ số dòng của bảng tra bản đầu (R-15b).

**AC-31.** Given một dòng bảng tra vi phạm luật bất biến — trượt từ **nhãn chức
năng** sang nội dung có giọng điệu nói về người kia (BR-14), đo hành vi người
kia (R-1b), tâng bốc, hiển thị %, hoặc đếm số lần hoàn thành checklist (AC-27) —
when dòng đó được nạp qua cổng nhập nội dung, then cổng **từ chối dòng đó và làm
hỏng bản dựng**. Đây là cách BR-14 chuyển từ **phán quyết phạm vi** thành **quy
tắc chạy được**: điều kiện giữ story này ngoài phạm vi nội dung-cần-duyệt-gu nay
được cưỡng chế tự động, không phụ thuộc người soạn bảng tra tương lai (R-15c).

## Business Rules

- **BR-1 (SC-4 — lồng, không cạnh tranh).** *Đã hẹn ngày* có **đúng một** hành
  động chính cấp thẻ: "chuẩn bị" (STORY-001 AC-11). "Trước giờ đi" sống **bên
  trong** luồng đó, đúng tiền lệ STORY-002 đã đặt cho "xuất lời mời". "Xong hết
  rồi, đi thôi" là hành động chính **của khối**, không phải của thẻ.
- **BR-2 (điều kiện hiển thị hai vế).** Khối chỉ mở khi **trạng thái = *Đã hẹn
  ngày*** VÀ **ngày hẹn = hôm nay**. Thiếu một vế thì không hiện. Không có chế
  độ "hiện sớm 1 ngày".
- **BR-3 (bảng tra tay, tất định).** Nội dung khối là hàm thuần của (trường trên
  thẻ, ngày, miền) qua một bảng tra ship kèm app. Cùng đầu vào → cùng đầu ra.
- **BR-4 (chỉ dòng có dữ liệu).** Một dòng chỉ hiện khi trường nó phụ thuộc
  **thực sự có giá trị** trên thẻ. Cấm đoán, cấm giá trị mặc định, cấm dòng xám.
- **BR-5 (khối thưa là đúng, không phải lỗi).** Thẻ thưa trường cho khối ngắn
  hoặc trống. App **không** dùng khối này làm đòn bẩy để thúc người dùng điền
  thêm trường — làm vậy là biến J6 thành một biểu mẫu trá hình, ngược SC-3.
- **BR-6 (R-7 — không AI, không API ngoài).** Không thời tiết, không bản đồ,
  không giao thông, không dịch vụ AI. Mùa mưa suy tất định theo miền và ngày.
- **BR-7 (chia sẻ vị trí = an toàn của người dùng).** Một lần, qua OS Share
  Sheet, do người dùng chủ động, về vị trí của **chính họ**. Không theo dõi thời
  gian thực, không lưu lịch sử, không người nhận mặc định. Ranh giới với R-1b rõ
  ràng: R-1b cấm **đo lường người kia**; đây là người dùng tự phát tín hiệu an
  toàn về mình, không phải quan sát người kia.
- **BR-8 (không đổi trạng thái thẻ).** Đóng khối là hành vi của khối. Việc thẻ
  chuyển sang *Đã đi rồi* là hành động khác, thuộc vòng đời STORY-001.
- **BR-9 (SC-5 — không ngõ cụt).** Khối đã đóng vẫn mở lại được bằng tay trong
  ngày.
- **BR-10 (hợp đồng thẻ STORY-001, chỉ đọc).** Story này **đọc** các trường
  giá, khoảng cách, cần đặt trước, trong nhà/ngoài trời, ngày hẹn từ mô hình thẻ
  đã khoá ở STORY-001 AC-8. Nó **không** thêm trường và không đổi hợp đồng thẻ.
- **BR-11 (ranh giới với STORY-012).** Story này **định nghĩa và phát ra** trạng
  thái pha "trước giờ đi"; STORY-012 **vẽ** pha đó lên widget. Vẽ widget ở đây
  là lấn phạm vi; không phát trạng thái pha là để STORY-012 thiếu đầu vào.
- **BR-12 (R-13 — khoá vị trí, đối chiếu).** Khối này không có destination riêng
  và không xuất hiện trong menu chính hay tab bar. Ràng buộc ở đây là "mở rộng
  của màn (1)", một lý do khác với R-13 (chỉ áp cho STORY-009 và STORY-010).
- **BR-13 (R-1c/R-1d — cửa sạch).** Bỏ qua khối, đóng khối, hoặc không dùng dòng
  nào đều không sinh hệ quả, không nhắc lại, không trách móc.
- **BR-14 (không nội dung preset cần duyệt gu).** Các dòng checklist là **nhãn
  chức năng** ("mang đủ tiền mặt"), không phải nội dung có giọng điệu gửi cho
  người kia. Đây là lý do story này **không** chịu kiểm duyệt hai lớp của OQ-3
  và chưa bao giờ bị chặn. Sau D-15, ranh giới này **không** còn chỉ là phán
  quyết phạm vi: nó là quy tắc cổng nhập chạy được (AC-31, BR-17).
- **BR-15 (R-15a — bảng tra là dữ liệu, không phải chuỗi trong code).** Bảng tra
  tay ở BR-3 là gói dữ liệu có lược đồ, mỗi dòng có **id bền**. Cấm chuỗi
  checklist nằm trong widget/code. Ràng buộc này áp **kể cả** khi nội dung chỉ
  là nhãn chức năng: R-15a áp cho mọi nội dung preset. Tiêu chí nghiệm thu: đổi
  nguồn sang CMS ngoài repo mà **không sửa một dòng code nào**.
- **BR-16 (R-15b — N là thuộc tính dữ liệu).** Số dòng bảng tra cho mỗi tổ hợp
  (trường thẻ, ngày, miền) là dữ liệu bản đầu, **không** phải hằng số của story.
  Cấm mọi AC, BR, hay bố cục dựa vào số dòng của bảng tra bản đầu — đặc biệt
  trạng thái **khối thưa là hợp lệ** (AC-30), vốn phải đúng với mọi N kể cả
  N = 0.
- **BR-17 (R-15c — luật bất biến là CỔNG NHẬP, không phải quy ước biên tập).**
  Ranh giới BR-14 (nhãn chức năng, không phải nội dung có giọng điệu), R-1b,
  R-1e, chống tâng bốc, cấm hiển thị %, và cấm đếm số lần hoàn thành được cưỡng
  chế ở **tầng lược đồ/validation của cổng nhập nội dung**, chạy được trong bản
  dựng (AC-31). Nếu quá trình thiết kế làm nảy sinh nội dung có giọng điệu trong
  khối, cổng nhập **bắt được ngay** thay vì để nó lọt như một thay đổi phạm vi
  im lặng.

## System Integration And Discoverability

- **UI-facing story:** YES.
- **Existing user-visible surface:** YES — chi tiết thẻ ở màn (1) do STORY-001
  giao. Story này gắn lên bề mặt đã có, không tạo bề mặt mới.
- **Điểm vào:** **tự động**, bên trong luồng "chuẩn bị" của thẻ *Đã hẹn ngày*
  đúng ngày hẹn. Người dùng không phải đi tìm. **Không** thêm destination,
  **không** vào từ menu chính hay tab bar — đúng nghĩa "mở rộng của màn (1)",
  không phải màn hình thứ 12.
- **Đồng cư với STORY-002 trong cùng luồng "chuẩn bị":** "xuất lời mời"
  (STORY-002) và "Trước giờ đi" (story này) cùng lồng trong luồng chuẩn bị của
  một thẻ *Đã hẹn ngày*. Chúng khác nhau về thời điểm: lời mời dùng **trước khi
  chốt/rủ**, checklist mở **đúng ngày đi**. Cả hai đều không giành hành động
  chính cấp thẻ. UI/UX Designer chốt cách hai thứ này cùng tồn tại trên một màn.
- **Hợp đồng cho story sau:** trạng thái pha "trước giờ đi" (AC-24) là đầu vào
  của STORY-012 (widget theo pha). Đây là phụ thuộc một chiều: STORY-012 đọc,
  story này không cần STORY-012 để chạy được.
- **Tích hợp bên ngoài:** chỉ **OS Share Sheet** của nền tảng, một lần, cho hành
  động chia sẻ vị trí. Không API thời tiết, bản đồ, giao thông, hay AI.

## Open Question Impact

### Scope Items BLOCKED in this story

- **NONE.** Story này **không** ship kho nội dung preset có giọng điệu: bảng tra
  gồm các nhãn chức năng suy ra từ trường thật của thẻ (BR-14), không phải câu
  chữ người dùng gửi cho người kia. Vì vậy **OQ-3 không chặn story này** — khác
  STORY-002, STORY-004, STORY-005. Không có câu hỏi mở nào cần user trả lời
  trước khi story này vào delivery.

### Scope Items NOT BLOCKED in this story

- **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 → luật R-15** (`req_master.md`
  mục 15). **Kiểm duyệt hai lớp vẫn không áp cho story này** (lý do ở trên) và
  story này chưa bao giờ bị chặn. Nhưng **R-15 thì có áp**: story ship một
  **bảng tra tay kèm app** (BR-3), nên nó là gói dữ liệu có schema + id bền, cấm
  chuỗi cứng trong widget/code (R-15a); số dòng là thuộc tính dữ liệu và trạng
  thái "khối thưa là hợp lệ" phải đúng với mọi N kể cả N = 0 (R-15b); ranh giới
  BR-14 thành **quy tắc cổng nhập chạy được** (R-15c). Chi tiết: AC-29..AC-31,
  BR-15..BR-17. Đây là **mở rộng ràng buộc, không phải mở rộng phạm vi**.
  Nếu quá trình thiết kế làm nảy sinh nội dung có giọng điệu trong khối, đó vẫn
  là **thay đổi phạm vi** và phải quay lại Product Owner — nay cổng nhập bắt
  được nó (AC-31) thay vì im lặng nhận rủi ro "sượng".
- **L45 / OQ-18 — ĐÓNG** (user chốt 2026-09-03: chặng 1 là kho tài sản). Story
  này không chịu tải định vị; ba story chịu tải là STORY-001, 012, 013.
- **Chặng 1.5 / link hai chiều / feed tin thật / Zalo Mini App / thương mại / J7
  — ĐÓNG, binding out of scope** của REQ-016. Riêng **J7 "trong buổi hẹn" là
  quyết định, không phải thiếu sót**: story này dừng ở ngưỡng cửa, đúng triết lý
  "trợ lý trước/sau".
- **OQ-2 — ĐÓNG ở tầng sản phẩm** và thuộc STORY-001.
- **Vẽ pha thứ tư lên widget — không mở, đã phân công** cho STORY-012 (BR-11).
- **Ngưỡng cụ thể** ("khoảng cách vượt ngưỡng" là bao nhiêu km, ranh giới mùa
  mưa theo miền, ngưỡng "giá > 0 trả tại chỗ") — giao **Tech Lead** chốt trong
  gói dữ liệu tra cứu. Ràng buộc sản phẩm duy nhất: tất định, ship kèm app,
  không gọi dịch vụ ngoài.
- **Chi tiết trình bày** (khối mở/đóng thế nào, thứ tự dòng, cách đồng cư với
  bottom sheet lời mời của STORY-002) — giao **UI/UX Designer trong phạm vi
  story này**. Là quyết định UX, không phải câu hỏi sản phẩm còn mở.
- **SB-144/145/146 (trò chơi "đoán") — HOÃN**, không gán vào story này.

## Traceability

| AC | Nguồn ràng buộc |
|----|-----------------|
| AC-1..AC-3 | SB-211 điều kiện hai vế, J6 |
| AC-4..AC-6 | SC-4, STORY-001 AC-11, tiền lệ lồng của STORY-002 AC-1/AC-2 |
| AC-7..AC-11 | Bảng tra tay tất định, R-7, hợp đồng thẻ STORY-001 AC-8 |
| AC-12..AC-14 | SC-3 không thúc điền trước, khối thưa là hợp lệ |
| AC-15..AC-17 | SC-5 không ngõ cụt, R-1c/R-1d |
| AC-18..AC-21 | An toàn cá nhân người dùng, ranh giới R-1b |
| AC-22..AC-24 | R-7 không AI/không API ngoài, hợp đồng pha cho STORY-012 |
| AC-25..AC-27 | R-1 nấc 3, R-1b, R-1e, R-1g, R-14 |
| AC-28 | Cổng cứng REQ-016 |
| AC-29 | R-15a — bảng tra là dữ liệu có schema + id bền, áp cả cho nhãn chức năng |
| AC-30 | R-15b — số dòng là thuộc tính dữ liệu; khối thưa hợp lệ với mọi N kể cả N = 0 |
| AC-31 | R-15c — cổng nhập chạy được; BR-14, R-1b, R-1e, cấm %, cấm đếm số lần |
| BR-15..BR-17 | D-15 / R-15 (`req_master.md` mục 15) |
