# Story Requirements: STORY-002 Xuất lời mời — khung nhại + mad-libs

- Requirement: REQ-016
- Story: STORY-002
- Complexity: complex
- Story-Class: shared-foundation
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: STORY-001
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules`, `## Out of Scope`,
  `## Open Questions`; `../../requirements/requirements.md` →
  `## Open Question Triage`, `## Scope Decision`, `## Story Order And Dependencies`

## Business Outcome

Người dùng rủ được "mối" của mình đi chơi **mà không sượng**: app soạn giúp một
lời mời có duyên, tất định, điền sẵn bằng dữ liệu thật của thẻ, để người dùng
copy sang Zalo gửi.

Story cũng giao **renderer nội dung dùng chung** cho cả requirement: một engine
tất định phục vụ nhiều danh mục preset, trong đó "lời mời" là danh mục ship ở
story này và "lời cảm ơn sau hẹn" là danh mục thứ hai mà STORY-007 sẽ thêm vào
**cùng renderer đó**.

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ.** Giá trị của story là gỡ nút thắt *soạn câu chữ* cho người
dùng. Vật phẩm lời mời hoàn tất khi nó ra khỏi Share Sheet; không AC nào cần
người kia trả lời, cài app, hay tồn tại trong hệ thống.

## Scope

### In Scope

1. Bottom sheet "xuất lời mời" gắn trên một thẻ ở trạng thái *Đã hẹn ngày*
   trong kho chung của STORY-001. Không chiếm destination riêng.
2. Bộ soạn nội dung tất định: **khung nhại** + **mad-libs** điền bằng trường
   thật của thẻ.
3. Kho preset lời mời có phân loại, và **renderer đa danh mục** thiết kế sẵn cho
   danh mục thứ hai của STORY-007 (chỉ thiết kế renderer; không ship danh mục
   thứ hai ở đây).
4. Cửa từ chối sạch một chạm bên trong mọi lời mời sinh ra.
5. Ràng buộc nội dung: preset chỉ được đùa về **người gửi**.
6. Xuất ra qua OS Share Sheet; người dùng tự gửi.
7. Móc SB-125: lưu vật phẩm dưới dạng **payload render được**.
8. Quy trình kiểm duyệt nội dung hai lớp (SB-123) trước khi kho preset vào bản
   build người dùng thật.

### Out of Scope

- Danh mục preset "lời cảm ơn sau hẹn" — STORY-007.
- Link hai chiều / kênh phản hồi trong app — **chặng 1.5, binding out of
  scope**. Story này chỉ để lại payload.
- A/B test lời nhắn, xếp hạng hiệu quả lời mời — **R-1(e) cấm nguyên vẹn**.
- Mọi đo lường việc người nhận đã đọc / đã xem (R-1b).
- Cửa vào thứ hai từ kịch bản buổi hẹn — STORY-008.
- Gửi thay người dùng, kênh gửi trong app, tích hợp Zalo API.

## Acceptance Criteria

### Nhóm A — Cửa vào và ranh giới SC-4

**AC-1.** Given một thẻ ở trạng thái *Đã hẹn ngày* trong kho chung, when người
dùng đi theo hành động chính "chuẩn bị" của thẻ đó, then "xuất lời mời" là một
hành động **đến được trong luồng chuẩn bị**, và bottom lời mời mở ra gắn trên
đúng thẻ đó.

**AC-2.** Given một thẻ ở bất kỳ trạng thái nào trong danh sách, when thẻ hiển
thị ở màn (1), then story này **không** thêm một hành động chính thứ hai lên
thẻ: *Đã hẹn ngày* vẫn có đúng một hành động chính (SC-4 giữ nguyên như
STORY-001 đã khoá).

**AC-3.** Given người dùng đang ở bất kỳ đâu ngoài luồng thẻ, when họ duyệt menu
chính hoặc tab bar, then "xuất lời mời" **không** xuất hiện như một destination
riêng.

### Nhóm B — Soạn nội dung tất định

**AC-4.** Given một thẻ *Đã hẹn ngày* có đủ trường, when bottom sheet mở, then
app hiển thị **ít nhất một** lời mời đã soạn sẵn với các chỗ trống đã điền bằng
trường thật của thẻ (tên hoạt động, ngày hẹn, địa điểm).

**AC-5.** Given kho preset có nhiều khung nhại, when bottom sheet mở, then người
dùng đổi được sang một khung nhại khác và thấy lời mời được soạn lại ngay, vẫn
điền bằng chính dữ liệu thẻ đó.

**AC-6.** Given thẻ **thiếu** một hoặc nhiều trường (không có địa điểm, không có
giờ, không có tên hoạt động cụ thể), when lời mời được soạn, then app vẫn ra một
lời mời **đọc trôi chảy** bằng cách bỏ hẳn mệnh đề thiếu dữ liệu, và **không**
hiển thị placeholder rỗng, dấu ngoặc trống, hay chuỗi kiểu `{địa_điểm}`.

**AC-7.** Given người dùng đã chọn một lời mời, when họ muốn sửa, then họ chỉnh
sửa được toàn văn trước khi chia sẻ, và bản chỉnh sửa là bản được xuất ra.

**AC-8.** Given bất kỳ lời mời nào được sinh ra, when nội dung được tạo, then
toàn bộ nội dung đến từ **preset + mad-libs + khung nhại ship sẵn**, runtime
tất định — không có lời gọi mô hình AI và không có lời gọi API sinh nội dung nào
ở runtime (R-7).

**AC-9.** Given cùng một thẻ và cùng một khung nhại được chọn, when lời mời được
soạn lại, then kết quả **giống hệt** lần trước (tất định, không ngẫu nhiên ẩn).

### Nhóm C — Ranh giới đạo đức của nội dung

**AC-10.** Given bất kỳ lời mời nào được sinh ra, when đọc toàn văn, then nó
chứa sẵn một **đường từ chối một chạm** dành cho người nhận (ví dụ: "bận thì
nhắn 'để hôm khác' nhé"), diễn đạt bình thường, không né, không trêu (R-1c).

**AC-11.** Given bất kỳ preset nào trong kho, when nội dung được duyệt và khi
nó hiển thị cho người dùng, then mọi câu đùa nhắm vào **người gửi**; **không**
preset nào đùa về, nhận xét về, hay gán tính cách cho người nhận (R-1d).

**AC-12.** Given người dùng đánh dấu "chưa trả lời", hoặc người kia từ chối,
when app phản hồi, then **không** có hiệu ứng kịch tính, **không** lời trêu,
**không** gợi ý nhắn lại lần hai kiểu đeo bám, và **không** đếm ngược chờ trả
lời (R-1c/R-1d).

**AC-13.** Given người dùng quay lại thẻ sau khi xuất lời mời, when họ cập nhật
tình hình, then lựa chọn duy nhất là *đã trả lời / chưa trả lời* do chính họ
bấm; app **không** hiển thị và **không** lưu bất kỳ chỉ báo hành vi nào của
người kia — không "đã xem", không giờ mở, không đếm lần gửi (R-1b).

**AC-14.** Given nhiều lời mời đã được xuất theo thời gian, when người dùng dùng
app, then **không** tồn tại bất kỳ bề mặt nào so sánh, chấm điểm, xếp hạng, hay
A/B test hiệu quả các lời mời (R-1e — cấm nguyên vẹn).

**AC-15.** Given một lời mời nhắc tới người kia, when đọc toàn văn, then nội dung
không kết luận về người kia; phần nói về người kia chỉ dùng dữ liệu **user tự
nhập** trên thẻ (R-1e/R-1g).

### Nhóm D — Xuất ra và móc SB-125

**AC-16.** Given người dùng đã chốt một lời mời, when họ bấm chia sẻ, then vật
phẩm đi ra qua **OS Share Sheet**, và app **không** tự gửi tới bất kỳ ai, không
mở kênh gửi trong app, không tích hợp API nhắn tin.

**AC-17.** Given người dùng đã xuất một lời mời, when vật phẩm được lưu lại,
then bản lưu là **payload có cấu trúc render lại được** — tối thiểu gồm id
template, id danh mục preset, phiên bản preset, tập giá trị đã điền, và tham
chiếu tới thẻ nguồn — **không** phải chuỗi text đã bẹp (SB-125).

**AC-18.** Given một payload lời mời đã lưu, when app render lại nó, then kết
quả ra đúng văn bản như lúc xuất, kể cả sau khi app khởi động lại.

**AC-19.** Given payload đã lưu, when định dạng payload được thiết kế, then nó
không giả định bất kỳ kênh phản hồi, link hai chiều, hay bề mặt web nào của
chặng 1.5 — nó chỉ **không cản** việc chặng 1.5 tái dùng, và story này **không**
xây bất kỳ phần nào của kênh đó.

### Nhóm E — Renderer dùng chung

**AC-20.** Given renderer nội dung được giao, when nó được thiết kế, then nó
nhận **danh mục preset** làm tham số đầu vào và tách bạch: (a) engine render,
(b) gói dữ liệu preset theo danh mục, (c) tập biến mad-libs lấy từ thẻ.

**AC-21.** Given STORY-007 sau này thêm danh mục "lời cảm ơn sau hẹn", when
danh mục đó được thêm, then việc thêm chỉ cần **bổ sung gói dữ liệu preset**,
không cần sửa engine render và không cần sửa hành vi của STORY-002.

**AC-22.** Given story này ship, when kho preset được giao, then nó chứa **đúng
một** danh mục đang hoạt động ("lời mời"); danh mục "lời cảm ơn sau hẹn" **không**
được ship ở đây.

### Nhóm F — Kiểm duyệt nội dung (SB-123)

**AC-23.** Given kho preset lời mời chuẩn bị vào bản build người dùng thật, when
nội dung được đưa vào, then mỗi preset đã đi qua **quy trình kiểm duyệt hai
lớp** cho **chất lượng biên tập** (giọng, độ sượng, tính dùng được), và trạng
thái duyệt được ghi lại truy vết được cho từng preset qua **id bền** của preset
đó. Kiểm duyệt hai lớp **không** là cơ chế cưỡng chế luật bất biến — việc đó
thuộc cổng nhập chạy được ở AC-28 (R-15c).

**AC-24.** Given delivery chạy tới bước ship nội dung, when kho preset được đưa
vào bản build người dùng thật, then việc ship **không** còn chờ user chỉ định
người duyệt lớp 2: OQ-3 đã đóng 2026-09-06 bằng D-15. Điều kiện ship là kho
preset **qua được cổng nhập** (AC-28) và có kiểm duyệt biên tập theo AC-23.

### Nhóm G — Nội dung là dữ liệu có cổng nhập (R-15 / D-15)

**AC-25.** Given kho preset lời mời, các khung nhại, và tập biến mad-libs, when
chúng được ship, then chúng là **gói dữ liệu có lược đồ, mỗi preset và mỗi
khung nhại có định danh bền**, không phải chuỗi cứng trong widget/code; đổi
nguồn nội dung sang CMS ngoài repo **không kéo theo một lần sửa code** (R-15a).
Id bền này là cùng một id mà payload SB-125 lưu (BR-9), không phải id thứ hai.

**AC-26.** Given kho preset của một danh mục có **N mục bất kỳ** (N ≥ 1), when
người dùng đổi qua các khung nhại cho tới khi duyệt hết kho, then hành vi
hết-tập là **quay vòng tất định về đầu theo cùng thứ tự**, **không** thông báo
"đã hết", **không** màn ngõ cụt, và **không** chỉ báo tiến độ hay số mục còn
lại dưới bất kỳ dạng nào. Luật này đúng với mọi N — 1, 10, hay vài trăm — và
**không** AC nào của story này được suy ra từ việc kho seed có 10 mục (R-15b).

**AC-27.** Given số khung nhại hiển thị cùng lúc trong bottom sheet là **tham
số bố cục**, when kho có N nhỏ hơn con số đó, then sheet vẫn render đúng phần
có sẵn mà không báo lỗi, không ô trống giữ chỗ, và không sheet rỗng; when kho
có N rất lớn, then hành vi đổi khung **không** đổi và không có bước tải/đợi
mới. Con số hiển thị **không** đặt ràng buộc nào lên N (R-15b).

**AC-28.** Given một preset vi phạm luật bất biến — thiếu cửa từ chối một chạm
(R-1c), đùa nhắm vào người nhận (R-1d), đo hành vi người kia (R-1b), tâng bốc,
hiển thị %, streak, hoặc giọng "chiêu tán tỉnh"/thao túng (R-10, R-1e) — when
preset đó được nạp qua cổng nhập nội dung, then cổng **từ chối preset đó và làm
hỏng bản dựng**; vi phạm **không** được phép lọt tới lúc người dùng đọc. Cổng
chạy được kể cả với preset do CMS ngoài repo cấp, tức nội dung **không** đi qua
review của repo này (R-15c).

**AC-29.** Given renderer đa danh mục (AC-20..AC-22), when STORY-007 thêm danh
mục "lời cảm ơn sau hẹn", then danh mục mới đi qua **cùng lược đồ và cùng cổng
nhập** này mà không thêm nhánh cổng riêng; số danh mục và số preset mỗi danh
mục đều là **thuộc tính dữ liệu** (R-15a/R-15b).

## Business Rules

- **BR-1 (SC-4 giữ nguyên).** Story này **không** thêm hành động chính thứ hai
  lên thẻ. "Xuất lời mời" nằm bên trong luồng "chuẩn bị" của trạng thái *Đã hẹn
  ngày*. Đây là quyết định sản phẩm để STORY-002 và STORY-006 cùng mở rộng một
  trạng thái mà không phá SC-4.
- **BR-2 (SC-1' — một kho).** Lời mời đã xuất **không** tạo ra một danh sách thứ
  hai. Payload gắn vào thẻ nguồn trong kho chung.
- **BR-3 (SC-2 — không điểm dừng chân).** Bottom sheet luôn có đường ra rõ ràng
  quay về thẻ; đóng sheet không làm mất dữ liệu thẻ.
- **BR-4 (R-7 — không AI ở runtime).** Nội dung đi đường PRESET + MAD-LIBS +
  KHUNG NHẠI. AI chỉ được dùng **ngoài hệ thống, ở khâu soạn nội dung**, và sản
  phẩm của nó vào repo như gói dữ liệu tĩnh đã qua kiểm duyệt hai lớp.
- **BR-5 (R-1c).** Mọi lời mời **bắt buộc** chứa cửa từ chối một chạm. Một
  preset không có cửa từ chối là preset không hợp lệ, không phải khuyết điểm nhỏ.
- **BR-6 (R-1d).** Preset chỉ đùa về người gửi. Cấm mọi câu đùa, nhận xét, gán
  nhãn nhắm vào người nhận.
- **BR-7 (R-1e).** Cấm nguyên vẹn A/B test lời nhắn và mọi hình thức xếp hạng
  hiệu quả lời mời.
- **BR-8 (R-1b).** Chỉ *đã trả lời / chưa trả lời*, do user tự bấm. Cấm lưu và
  hiển thị mọi đại lượng hành vi của người kia.
- **BR-9 (SB-125 — payload render được).** Lưu dữ liệu có cấu trúc + id template
  + phiên bản preset, không lưu chuỗi text đã bẹp. Đây là ràng buộc lưu trữ ảnh
  hưởng requirement chặng 1.5, không phải tối ưu kỹ thuật tuỳ chọn.
- **BR-10 (SB-123 — kiểm duyệt hai lớp, phạm vi đã thu hẹp bởi D-15).** Không
  preset nào ra bản build người dùng thật khi chưa qua hai lớp duyệt **về chất
  lượng biên tập**. Sau D-15, đây **không** còn là cơ chế cưỡng chế luật bất
  biến và **không** còn là điểm OQ-3 chặn story này — xem BR-16.
- **BR-11 (R-10 — định vị).** Giọng nội dung là "rủ nhau đi chơi", không phải
  "chiêu tán tỉnh". Cấm mọi khung nội dung dạy thao túng.
- **BR-12 (R-14 — không paywall lõi).** Kho preset lời mời là phần lõi; không
  đặt sau paywall.
- **BR-13 (renderer đa danh mục).** Danh mục là **dữ liệu**, không phải nhánh
  code. STORY-007 phải thêm được danh mục mà không sửa engine.
- **BR-14 (R-15a — nội dung là dữ liệu, không phải chuỗi trong code).** Kho
  preset lời mời, khung nhại, và tập biến mad-libs là gói dữ liệu có lược đồ,
  mỗi mục có **id bền**. BR-13 đã nói danh mục là dữ liệu; BR-14 mở rộng cùng
  luật đó xuống **từng preset**. Cấm câu chữ lời mời nằm trong widget/code.
  Tiêu chí nghiệm thu: đổi nguồn sang CMS ngoài repo mà **không sửa một dòng
  code nào**. Id bền dùng chung với payload SB-125 (BR-9).
- **BR-15 (R-15b — N là thuộc tính dữ liệu).** Bộ seed 10 mục cho mỗi gói
  **xoay vòng** là dữ liệu bản đầu, **không** phải hằng số của story. Cấm mọi
  AC, BR, hay bố cục dựa vào "vì có đúng 10 mục nên…" — đặc biệt hành vi
  hết-tập khi đổi khung nhại (AC-26) và chỉ báo tiến độ. Số khung nhại hiển thị
  cùng lúc là tham số bố cục, không phải ràng buộc lên N (AC-27). Ngoại lệ duy
  nhất là AC-22: "**đúng một** danh mục đang hoạt động" là **ranh giới phạm vi
  story**, không phải giả định về số lượng nội dung.
- **BR-16 (R-15c — luật bất biến là CỔNG NHẬP, không phải quy ước biên tập).**
  R-1b, R-1c, R-1d, R-1e, R-10, chống tâng bốc, cấm hiển thị %, và cấm streak
  được cưỡng chế ở **tầng lược đồ/validation của cổng nhập nội dung**, chạy
  được trong bản dựng: preset vi phạm bị từ chối tại cổng và làm hỏng bản dựng.
  BR-5 đã nói "preset không có cửa từ chối là preset không hợp lệ" — BR-16 biến
  câu đó thành thứ **máy kiểm được**, không phải điều người duyệt phải nhớ.
  Kiểm duyệt hai lớp (BR-10) vẫn giữ, nhưng chỉ cho **chất lượng biên tập**: nó
  là quy ước con người, không đáng tin với nội dung CMS tương lai vốn không đi
  qua review của repo này.

## System Integration And Discoverability

- **UI-facing story:** YES.
- **Existing user-visible surface:** YES — thẻ ở màn (1) do STORY-001 giao. Story
  này gắn lên bề mặt đã có, không tạo bề mặt mới.
- **Điểm vào:** bên trong luồng "chuẩn bị" của một thẻ ở trạng thái *Đã hẹn
  ngày*. **Không** chiếm destination riêng, **không** xuất hiện trong menu chính
  hay tab bar (đúng mô tả "hành động (11)", không phải màn thứ 12).
- **Không phải màn khoá vị trí** theo nghĩa R-13 — R-13 áp cho STORY-009 và
  STORY-010. Ràng buộc điều hướng ở đây là "không có destination riêng", một lý
  do khác.
- **Hợp đồng cho story sau (shared-foundation):** engine render + hình dạng
  payload SB-125 là bề mặt dùng chung. STORY-007 (danh mục cảm ơn) và STORY-008
  (cửa vào thứ hai từ kịch bản) phụ thuộc trực tiếp. Đổi hình dạng payload sau
  story này là thay đổi phá vỡ hợp đồng và ảnh hưởng cả requirement chặng 1.5.
- **Tích hợp bên ngoài:** chỉ **OS Share Sheet** của nền tảng. Không API nhắn
  tin, không Zalo API, không dịch vụ AI, không backend sinh nội dung.

## Open Question Impact

### Scope Items BLOCKED in this story

- **Không còn scope item nào của story này bị chặn bởi câu hỏi mở.** OQ-3 —
  mục duy nhất từng chặn (ship kho preset lời mời, AC-23/AC-24) — đã đóng
  2026-09-06 bằng D-15. Đây là story **đầu tiên** của REQ-016 có kho preset,
  nên nó cũng là story đặt tiền lệ cổng nhập cho STORY-004/005/007/009/010/011.

### Scope Items NOT BLOCKED in this story

- **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user), bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Rủi ro "sượng" vẫn có thật, nhưng cách bảo vệ đã đổi: **không** còn
  là "chờ user chỉ định người duyệt lớp 2", mà là **cổng nhập chạy được**.
  - **Hết chặn:** ship kho preset lời mời vào bản build người dùng thật (AC-23,
    AC-24) và việc story này vào delivery.
  - **Thành ràng buộc mới của story:** AC-25..AC-29 và BR-14/BR-15/BR-16.
    Vì đây là story đầu tiên có preset, lược đồ và cổng nhập nó giao là **tiền
    lệ** cho mọi story preset sau; STORY-007 dùng lại cổng đó, không dựng nhánh
    cổng riêng (AC-29).
  - **Còn lại của SB-123:** kiểm duyệt hai lớp giữ nguyên cho chất lượng biên
    tập (BR-10), hạ từ **chặn ship** xuống **rủi ro chất lượng nội dung**, sửa
    được bằng đổi dữ liệu mà không sửa code (R-15a).

- **Chặng 1.5 / link hai chiều — ĐÓNG, binding out of scope.** Story này để lại
  payload SB-125 và dừng ở đó (AC-19). Không phải câu hỏi mở; không mở lại trong
  REQ-016.
- **L45 / OQ-18 — ĐÓNG** (user chốt 2026-09-03: chặng 1 là kho tài sản). Story
  này không chịu tải định vị; ba story chịu tải là STORY-001, 012, 013. Không
  relitigate.
- **Danh mục "lời cảm ơn sau hẹn" — không mở, đã phân công.** Thuộc STORY-007;
  story này chỉ giao renderer đa danh mục (AC-20..AC-22).
- **Chi tiết trình bày bottom sheet** (số lượng khung nhại hiển thị cùng lúc,
  cách đổi khung, layout xem trước) — giao **UI/UX Designer trong phạm vi story
  này**. Là quyết định UX, không phải câu hỏi sản phẩm còn mở.
- **SB-144/145/146 (trò chơi "đoán") — HOÃN**, không gán vào story này.

## Traceability

| AC | Nguồn ràng buộc |
|----|-----------------|
| AC-1..AC-3 | SC-4, hành động (11) không có destination riêng |
| AC-4..AC-9 | Khung nhại + mad-libs, R-7 không AI ở runtime |
| AC-10..AC-15 | R-1b, R-1c, R-1d, R-1e, R-1g |
| AC-16..AC-19 | SB-125 payload render được, chặng 1.5 out of scope |
| AC-20..AC-22 | Renderer dùng chung cho STORY-007 |
| AC-23..AC-24 | SB-123 kiểm duyệt hai lớp (chất lượng biên tập); OQ-3 ĐÃ ĐÓNG bằng D-15 |
| AC-25, AC-29 | R-15a — schema + id bền, đổi nguồn sang CMS không sửa code; SB-125 (BR-9) |
| AC-26, AC-27 | R-15b — N là thuộc tính dữ liệu; hành vi hết-tập đúng với mọi N |
| AC-28 | R-15c — cổng nhập chạy được; R-1b, R-1c, R-1d, R-1e, R-10, cấm %, cấm streak |
| BR-14..BR-16 | D-15 / R-15 (`req_master.md` mục 15) |
