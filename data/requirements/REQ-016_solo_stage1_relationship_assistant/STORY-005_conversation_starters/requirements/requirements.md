# Story Requirements: STORY-005 Mồi chuyện — kho câu thường xanh và sự kiện có lịch

- Requirement: REQ-016
- Story: STORY-005
- Complexity: standard
- Story-Class: standard
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: STORY-001, STORY-004
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules`, `## Out of Scope`,
  `## Open Questions`; `../../requirements/requirements.md` →
  `## Story Index`, `## Open Question Triage`;
  `../../STORY-001_activity_card_hub/requirements/requirements.md` →
  hợp đồng mô hình thẻ và trạng thái

## Business Outcome

Người dùng **hết bí chuyện để nhắn**. Mở app là có sẵn câu gợi chuyện dùng được
ngay cho **đúng người này**, cộng một danh sách sự kiện sắp tới đáng rủ đi.

Story có hai bản, và ranh giới giữa chúng là trọng tâm sản phẩm:

- **Bản A — kho câu thường xanh:** dùng **tại chỗ**, copy đi nhắn, **KHÔNG** trở
  thành thẻ. Một câu mồi là lời nói, không phải kế hoạch.
- **Bản A+ — sự kiện có lịch:** sự kiện có ngày cụ thể (phim ra rạp, lễ hội, dịp
  lịch âm) **đổi thẳng thành thẻ hoạt động** trong kho chung của STORY-001. Một
  sự kiện có ngày là kế hoạch, nên nó thuộc kho thẻ.

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ.** Giá trị là gỡ nút thắt *nghĩ ra chuyện để nói*. Câu mồi hoàn
tất khi nó ra khỏi clipboard/Share Sheet; sự kiện có lịch hoàn tất khi nó thành
thẻ trong kho của người dùng. Không AC nào cần người kia trả lời.

## Scope

### In Scope

1. **Bản A — kho câu gợi chuyện thường xanh**, dùng tại chỗ, copy đi được,
   không tạo thẻ.
2. Riêng-hoá câu mồi bằng **sổ tay** của STORY-004 (sở thích, sự kiện) để hết
   chung chung. Sổ tay trống → vẫn ra câu mồi mặc định, cộng **một** câu hỏi tại
   chỗ dùng đúng cơ chế của STORY-004.
3. **Bản A+ — "sự kiện có lịch"**: mục sự kiện có ngày cụ thể, đổi thẳng thành
   thẻ ở màn (1), trạng thái *Mới nghĩ ra*, mang sẵn ngày của sự kiện.
4. Nguồn dữ liệu sự kiện: **gói dữ liệu tĩnh ship kèm app** + **lịch âm tính tất
   định**. Không API tin tức, không AI ở runtime.
5. Kiểm duyệt nội dung hai lớp (SB-123) cho kho mồi.

### Out of Scope

- **Bản B — feed tin thật** (crawl/API tin tức, tin nóng theo ngày). Đây là
  **binding out of scope** của REQ-016 (`req_master.md` → `## Out of Scope`):
  cần hạ tầng, đánh giá lại ở chặng 1.5. Story này **không** ship một phiên bản
  rút gọn, không ship "feed tĩnh cập nhật hàng tuần", và không để lại nút chờ
  cho nó.
- Một "danh sách mồi chuyện riêng" (đã lưu / yêu thích) cạnh tranh với màn (1) —
  vi phạm SC-1'.
- Gửi tin nhắn thay người dùng, tự động hoá gửi, hẹn giờ gửi.
- Dùng kho mồi làm nguồn cho "chốt việc kế tiếp" sau buổi hẹn — STORY-007.
- Trò chơi "đoán" không thắng thua (SB-144/145/146) — hoãn.
- Chặng 1.5, link hai chiều, Zalo Mini App, thương mại, J7.

## Acceptance Criteria

### Nhóm A — Bản A: kho câu thường xanh, dùng tại chỗ

**AC-1.** Given người dùng mở màn Mồi chuyện, when màn hiện ra, then đã có sẵn
câu gợi chuyện dùng được ngay, **không** cần thao tác thiết lập nào trước đó.

**AC-2.** Given người dùng chọn một câu mồi, when họ dùng nó, then họ copy được
câu đó để đi nhắn, và thao tác này **không tạo thẻ nào** ở màn (1).

**AC-3.** Given người dùng đã dùng nhiều câu mồi, when họ quay lại màn, then màn
này **không giữ** một danh sách "câu đã lưu"/"yêu thích" riêng; bản A không sinh
ra vật phẩm lưu trữ nào (SC-1').

**AC-4.** Given người dùng muốn câu khác, when họ yêu cầu bộ câu tiếp theo, then
app đưa ra bộ khác từ kho, và bản A **không** là ngõ cụt — luôn có đường đi tiếp
hoặc đường sang bản A+ (SC-5).

### Nhóm B — Riêng-hoá bằng sổ tay và hỏi tại chỗ (SB-174, SC-3)

**AC-5.** Given sổ tay đã có sở thích của người kia, when câu mồi được xếp ra,
then nội dung **tham chiếu tới sở thích đã ghi**, không phải câu chung chung.

**AC-6.** Given sổ tay còn trống, when người dùng mở màn, then app **vẫn** ra
câu mồi dùng được, và hỏi tại chỗ **đúng một câu** theo cơ chế của STORY-004 để
lần sau bớt chung chung.

**AC-7.** Given app đang hỏi câu hỏi tại chỗ ở màn này, when người dùng bỏ qua,
then câu mồi vẫn hiển thị bình thường; câu hỏi **không** chặn nội dung (SC-3).

**AC-8.** Given người dùng trả lời câu hỏi tại chỗ ở màn này, when câu trả lời
được lưu, then nó vào **đúng kho sổ tay/kỹ năng của STORY-004**, xem/sửa/xoá
được ở màn (2)/(3); story này **không** tạo kho ngữ cảnh thứ hai.

**AC-9.** Given màn Mồi chuyện, when người dùng dùng màn, then **không tồn tại**
luồng điền-trước/onboarding sổ tay ở đây (SC-3).

### Nhóm C — Bản A+: sự kiện có lịch thành thẻ (SC-2)

**AC-10.** Given danh sách "sự kiện có lịch" đang hiển thị, when người dùng xem,
then mỗi mục có **một ngày cụ thể** và nêu rõ đó là sự kiện gì (ví dụ phim ra
rạp, lễ hội, dịp lịch âm).

**AC-11.** Given một mục "sự kiện có lịch", when người dùng bấm hành động chính,
then một thẻ mới xuất hiện ở màn (1) ở trạng thái *Mới nghĩ ra*, theo đúng mô
hình thẻ STORY-001, **đã mang sẵn ngày của sự kiện**, và mang **nguồn sinh** "sự
kiện có lịch".

**AC-12.** Given một sự kiện đã được đổi thành thẻ, when người dùng quay lại màn
Mồi chuyện, then nơi duy nhất chứa nó là kho chung của màn (1); màn này không
giữ bản sao riêng (SC-1').

**AC-13.** Given một sự kiện đã qua ngày, when danh sách hiển thị, then sự kiện
đã qua **không** còn được chào mời để đổi thành thẻ, và app không nhắc lại nó
như một cơ hội đã lỡ (R-1c/R-1d — không kịch tính hoá).

**AC-14.** Given người dùng đang ở một mục sự kiện, when họ không muốn đổi thành
thẻ, then có đường bỏ qua sạch, một chạm, không hỏi lý do.

### Nhóm D — Tất định, ngoại tuyến, không AI, không bản B

**AC-15.** Given người dùng mở màn khi thiết bị **không có mạng**, when nội dung
hiện ra, then kho câu mồi và danh sách sự kiện **vẫn dùng được đầy đủ**, vì
chúng là gói dữ liệu ship kèm app.

**AC-16.** Given bất kỳ đường đi nào của story này, when nội dung được sinh ra,
then app **không** gọi mô hình AI, **không** gọi API tin tức, và **không** gọi
API nội dung bên ngoài (R-7).

**AC-17.** Given cùng một bộ đầu vào (ngày hiện tại, sổ tay, lựa chọn của người
dùng), when nội dung được xếp ra, then kết quả **tất định như nhau** ở hai lần
chạy khác nhau.

**AC-18.** Given dịp theo lịch âm, when app xác định ngày của dịp đó, then ngày
được **tính tất định trên thiết bị**, không lấy từ dịch vụ ngoài.

**AC-19.** Given toàn bộ bề mặt của story này, when người dùng dùng nó, then
**không** tồn tại feed tin thật, tin nóng theo ngày, hay bất kỳ nội dung nào
được nạp về sau khi cài app — bản B nằm ngoài phạm vi và không có phiên bản rút
gọn ở đây.

### Nhóm E — Ranh giới đạo đức (R-1b, R-1e, R-1g, R-1c/R-1d)

**AC-20.** Given bất kỳ câu mồi nào nói về người kia, when đọc hết câu, then nó
**kết thúc bằng một câu để hỏi người thật**, không bằng một nhận định chốt hạ
(R-1g).

**AC-21.** Given bất kỳ nội dung nào trên màn này, when nội dung hiển thị, then
app **không** hiển thị và **không** lưu chỉ báo hành vi người kia — không "đã
xem", không giờ mở, không tần suất trả lời, không "hôm nay chưa nhắn" (R-1b).

**AC-22.** Given kho câu mồi, when nội dung hiển thị, then **không** câu nào là
kịch bản thao túng, thử nghiệm A/B lời nhắn, hay hứa hẹn phản ứng của người kia;
nội dung đùa chỉ được đùa về **người gửi** (R-1, R-1d).

**AC-23.** Given màn Mồi chuyện, when người dùng dùng màn, then **không** có
streak, chuỗi ngày nhắn tin, huy hiệu, hay cơ chế ép quay lại nào (R-1, cấm
(f)), và không phần nào nằm sau paywall (R-14).

### Nhóm F — Cổng cứng và kiểm duyệt nội dung

**AC-24.** Given người dùng chưa từng có, và sẽ không bao giờ có, phản hồi từ
người kia, when họ dùng story này, then **mọi** AC ở trên vẫn đạt được.

**AC-25.** Given kho nội dung mồi chuyện chuẩn bị ra bản build người dùng thật,
when nội dung được duyệt, then nó đã qua **quy trình kiểm duyệt hai lớp**
(SB-123) cho **chất lượng biên tập** (giọng, độ sượng, tính dùng được). Kiểm
duyệt hai lớp **không** là cơ chế cưỡng chế luật bất biến — việc đó thuộc cổng
nhập chạy được ở AC-29 (R-15c). AC này **không còn bị chặn**: OQ-3 đã đóng
2026-09-06 bằng D-15.

### Nhóm G — Nội dung là dữ liệu có cổng nhập (R-15 / D-15)

**AC-26.** Given kho câu mồi và gói sự kiện có lịch, when chúng được ship,
then chúng là **gói dữ liệu có lược đồ và định danh bền cho từng mục**, không
phải chuỗi cứng trong widget/code; đổi nguồn nội dung sang CMS ngoài repo
**không kéo theo một lần sửa code** (R-15a).

**AC-27.** Given kho câu mồi có **N mục bất kỳ** (N ≥ 1), when người dùng liên
tục yêu cầu bộ câu tiếp theo cho tới khi duyệt hết kho, then hành vi hết-vòng
là **quay lại từ đầu kho theo cùng thứ tự tất định**, **không** thông báo "đã
hết", **không** màn ngõ cụt, và **không** chỉ báo tiến độ hay số mục còn lại
dưới bất kỳ dạng nào. Luật này đúng với mọi N — 3, 10, hay vài trăm — và
**không** AC nào của story này được suy ra từ việc kho seed có 10 mục (R-15b).

**AC-28.** Given số câu hiển thị mỗi lượt là **tham số bố cục**, when kho có N
nhỏ hơn số câu mỗi lượt, then màn vẫn render đúng phần có sẵn mà không báo
lỗi, không ô trống giữ chỗ, và không màn rỗng; when kho có N rất lớn, then
hành vi cuộn/đổi bộ **không đổi** và không có bước tải/đợi mới. Số câu mỗi lượt
**không** đặt ràng buộc nào lên N (R-15b).

**AC-29.** Given một mục nội dung vi phạm luật bất biến — đo hành vi người kia
(R-1b), tâng bốc, hiển thị %, streak, hoặc câu nói về người kia không kết bằng
câu hỏi (R-1g) — when mục đó được nạp qua cổng nhập nội dung, then cổng
**từ chối mục đó và làm hỏng bản dựng**; vi phạm **không** được phép lọt tới
lúc người dùng đọc. Cổng chạy được kể cả với nội dung do CMS ngoài repo cấp,
tức nội dung **không** đi qua review của repo này (R-15c).

**AC-30.** Given gói sự kiện có lịch, when nó được cập nhật (thêm/bớt sự kiện,
đổi năm), then số mục và nội dung là **thuộc tính dữ liệu**; AC nhóm C vẫn đạt
nguyên vẹn mà không sửa code, và danh sách rỗng vẫn rơi vào trạng thái êm đã
định ở nhóm C thay vì lỗi (R-15a/R-15b).

## Business Rules

- **BR-1 (ranh giới A / A+).** Câu mồi thường xanh **không** thành thẻ; sự kiện
  **có ngày cụ thể** thì thành thẻ. Tiêu chí phân loại là **có ngày hay không**,
  không phải chủ đề. Cho bản A tạo thẻ là biến kho thẻ thành sọt rác câu nói.
- **BR-2 (SC-1' — một kho).** Story này không tạo danh sách riêng dưới bất kỳ
  tên nào ("đã lưu", "yêu thích", "để dành"). Bản A không sinh vật phẩm lưu trữ;
  bản A+ ghi thẳng vào kho của STORY-001.
- **BR-3 (hợp đồng thẻ STORY-001).** Thẻ sinh từ bản A+ dùng nguyên mô hình thẻ
  và bốn trạng thái của STORY-001, vào ở *Mới nghĩ ra*, điền sẵn trường **ngày
  hẹn** bằng ngày sự kiện, mang **nguồn sinh** theo AC-9 của STORY-001. Story
  này không thêm trạng thái và không đổi hợp đồng thẻ.
- **BR-4 (SB-174 / SC-3 — dùng lại kho ngữ cảnh).** Riêng-hoá đọc **sổ tay của
  STORY-004**; câu trả lời tại chỗ ghi **về** kho đó. Cấm tạo kho ngữ cảnh thứ
  hai và cấm luồng điền-trước.
- **BR-5 (suy giảm êm).** Sổ tay rỗng, bỏ qua câu hỏi, hoặc không có mạng đều
  cho ra nội dung dùng được. Không trạng thái nào trong ba trạng thái đó là màn
  rỗng hay lỗi chặn.
- **BR-6 (R-7 — không AI ở runtime).** Kho câu mồi và gói sự kiện là **nội dung
  soạn tay** ship kèm app; lịch âm tính tất định trên thiết bị. AI chỉ dùng ngoài
  hệ thống ở khâu soạn nội dung.
- **BR-7 (bản B out of scope, binding).** Không API tin tức, không crawl, không
  nội dung nạp về sau khi cài. Không để lại nút/ô chờ cho bản B trong UI.
- **BR-8 (R-1g — không kết luận).** Mọi câu nói về người kia kết thúc bằng một
  câu để hỏi. Bài kiểm tra: đọc xong, người dùng muốn hỏi người kia **nhiều
  hơn**.
- **BR-9 (R-1b / R-1e).** Không đo lường hành vi người kia, kể cả gián tiếp qua
  nhắc nhở kiểu "lâu rồi chưa nhắn". Ba tầng: user ghi ✅ · user đoán ✅ · app suy
  luận/chấm điểm người kia ❌.
- **BR-10 (R-1c/R-1d — cửa sạch).** Bỏ qua một sự kiện, hoặc không dùng câu nào,
  đều là hành động một chạm, không hỏi lý do, không kịch tính hoá.
- **BR-11 (phạm vi copy).** Người dùng copy được **một câu mồi đã render tại một
  thời điểm**. Đây không phải chức năng xuất sổ tay: cấm copy hàng loạt, cấm xuất
  danh sách, cấm đưa nội dung thô của sổ tay ra ngoài (R-1f).
- **BR-12 (R-13 — khoá vị trí, đối chiếu).** Story này **không** thuộc nhóm khoá
  vị trí: Mồi chuyện có đường vào riêng từ menu chính (nhóm CỬA VÀO). R-13 chỉ
  áp cho STORY-009 và STORY-010.
- **BR-13 (SB-123 — kiểm duyệt hai lớp).** Kho mồi phải qua kiểm duyệt hai lớp
  trước bản build người dùng thật. Rủi ro triển khai #1 là **sượng**, và câu mồi
  là nơi sượng lộ ra rõ nhất vì người dùng gửi nguyên văn cho người thật.
- **BR-14 (R-14 — không paywall lõi).** Kho câu mồi và danh sách sự kiện là phần
  lõi; không đặt sau paywall.
- **BR-15 (R-15a — nội dung là dữ liệu, không phải chuỗi trong code).** Kho câu
  mồi và gói sự kiện là gói dữ liệu có lược đồ, mỗi mục có **id bền** dùng được
  làm khoá tham chiếu. Cấm chuỗi câu mồi nằm trong widget/code. Tiêu chí nghiệm
  thu là: đổi nguồn sang CMS ngoài repo mà **không sửa một dòng code nào**.
- **BR-16 (R-15b — N là thuộc tính dữ liệu).** Bộ seed 10 mục cho gói **xoay
  vòng** là dữ liệu bản đầu, **không** phải hằng số của story. Cấm mọi AC, BR,
  hay bố cục dựa vào "vì có đúng 10 mục nên…" — đặc biệt hành vi hết-vòng
  (AC-27) và chỉ báo tiến độ. Hành vi phải đúng với mọi N, kể cả khi CMS nâng
  lên vài trăm mục.
- **BR-17 (R-15c — luật bất biến là CỔNG NHẬP, không phải quy ước biên tập).**
  R-1b, chống tâng bốc, cấm hiển thị %, cấm streak, và R-1g được cưỡng chế ở
  **tầng lược đồ/validation của cổng nhập nội dung**, chạy được trong bản dựng.
  Nội dung vi phạm bị từ chối tại cổng và làm hỏng bản dựng. Kiểm duyệt hai lớp
  (BR-13) vẫn giữ, nhưng chỉ cho **chất lượng biên tập**: nó là quy ước con
  người, không đáng tin với nội dung CMS tương lai vốn không đi qua review của
  repo này.

## System Integration And Discoverability

- **UI-facing story:** YES.
- **Existing user-visible surface:** YES — kho thẻ ở màn (1) do STORY-001 giao,
  và sổ tay/hỏi-tại-chỗ do STORY-004 giao. Story này gắn lên hai bề mặt đã có.
- **Điểm vào:** đường vào riêng từ menu chính, **nhóm CỬA VÀO** — màn (6).
- **Bề mặt tiêu thụ, không phải bề mặt hợp đồng:** story này **đọc** kho ngữ
  cảnh của STORY-004 và **ghi** vào kho thẻ của STORY-001. Nó không giao hợp
  đồng mới cho story sau; STORY-007 chỉ **đọc lại** kho mồi đã giao.
- **Tích hợp bên ngoài:** chỉ **clipboard / OS Share Sheet** để copy một câu mồi
  (BR-11). Không API tin tức, không API nhắn tin, không dịch vụ AI, không backend
  sinh nội dung.

## Open Question Impact

### Scope Items BLOCKED in this story

- **Không còn scope item nào của story này bị chặn bởi câu hỏi mở.** OQ-3 —
  mục duy nhất từng chặn (AC-25) — đã đóng 2026-09-06 bằng D-15.

### Scope Items NOT BLOCKED in this story

- **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user), bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Câu trả lời không phải "chỉ định người duyệt lớp 2" mà là đổi bản
  chất nội dung: dữ liệu có schema + id bền, N là thuộc tính dữ liệu, luật bất
  biến cưỡng chế ở cổng nhập chạy được.
  - **Hết chặn:** ship kho câu mồi và gói sự kiện vào bản build người dùng thật
    (AC-25) không còn chờ user chỉ định người duyệt lớp 2.
  - **Thành ràng buộc mới của story:** AC-26..AC-30 và BR-15/BR-16/BR-17.
    R-15b **chốt hành vi hết-vòng** của story này (AC-27) là luật tổng quát cho
    mọi N, không phải luật cho N=10.
  - **Còn lại của SB-123:** kiểm duyệt hai lớp giữ nguyên cho chất lượng biên
    tập (BR-13), nhưng hạ từ **chặn ship** xuống **rủi ro chất lượng nội dung**,
    sửa được bằng đổi dữ liệu mà không sửa code.

- **Bản B / feed tin thật — ĐÓNG, binding out of scope** của REQ-016. Không phải
  câu hỏi mở; không mở lại ở story này (AC-19, BR-7). Đánh giá lại ở chặng 1.5.
- **L45 / OQ-18 — ĐÓNG** (user chốt 2026-09-03: chặng 1 là kho tài sản). Story
  này không chịu tải định vị; ba story chịu tải là STORY-001, 012, 013.
- **Chặng 1.5 / link hai chiều / Zalo Mini App / thương mại / J7 — ĐÓNG, binding
  out of scope.**
- **OQ-2 — ĐÓNG ở tầng sản phẩm** và thuộc STORY-001. Story này chỉ đẩy thẻ vào
  ngăn *Mới nghĩ ra*.
- **SB-144/145/146 (trò chơi "đoán") — HOÃN**, không gán vào story này (brainstorm
  ghi rõ "chưa gán màn cố định").
- **Có dùng lại renderer nội dung của STORY-002 cho câu mồi hay không** — quyết
  định kỹ thuật, giao **Tech Lead**. Ở tầng sản phẩm, yêu cầu duy nhất là nội
  dung tất định và copy được; story này **không** khai báo phụ thuộc vào
  STORY-002.
- **Chi tiết trình bày** (cách chuyển bộ câu mồi, bố cục danh sách sự kiện, vị
  trí câu hỏi tại chỗ) — giao **UI/UX Designer trong phạm vi story này**. Là
  quyết định UX, không phải câu hỏi sản phẩm còn mở.

## Traceability

| AC | Nguồn ràng buộc |
|----|-----------------|
| AC-1..AC-4 | Bản A dùng tại chỗ, SC-1', SC-5 |
| AC-5..AC-9 | SB-174, SC-3, kho ngữ cảnh STORY-004 |
| AC-10..AC-14 | Bản A+, SC-2, hợp đồng thẻ STORY-001, R-1c/R-1d |
| AC-15..AC-19 | R-7 không AI ở runtime, C7 lịch âm, bản B out of scope |
| AC-20..AC-23 | R-1, R-1b, R-1d, R-1g, R-14 |
| AC-24 | Cổng cứng REQ-016 |
| AC-25 | SB-123 kiểm duyệt hai lớp (chất lượng biên tập); OQ-3 ĐÃ ĐÓNG bằng D-15 |
| AC-26, AC-30 | R-15a — schema + id bền, đổi nguồn sang CMS không sửa code |
| AC-27, AC-28 | R-15b — N là thuộc tính dữ liệu; hành vi hết-vòng đúng với mọi N |
| AC-29 | R-15c — cổng nhập chạy được; R-1b, R-1g, cấm %, cấm streak |
| BR-15..BR-17 | D-15 / R-15 (`req_master.md` mục 15) |
