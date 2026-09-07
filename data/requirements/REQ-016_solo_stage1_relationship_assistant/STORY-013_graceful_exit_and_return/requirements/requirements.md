# Story Requirements: STORY-013 Lối ra khi im lặng/bị từ chối, và lối quay lại sau vắng

- Requirement: REQ-016
- Story: STORY-013
- Complexity: standard
- Story-Class: standard
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: STORY-001 (bắt buộc — hợp đồng thẻ, bốn ngăn, cờ *đã trả lời*) ·
  STORY-004 (bắt buộc — sổ tay + hồ sơ kỹ năng phải sống sót) ·
  STORY-002/003/008/009/010/011/012 (tuỳ chọn, suy giảm êm: đã giao thì bị bao,
  chưa giao thì không tồn tại để bao)
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules` (R-1 cấm (f), R-1b,
  R-1c/R-1d, R-1e, R-1f, R-1g, R-7 không AI runtime, R-12, R-13 khoá vị trí),
  `### Cổng cứng`, `## Out of Scope`, `## Open Questions`;
  `../../requirements/requirements.md` → `## Open Question Triage` (L45/OQ-18 —
  story chịu tải định vị "kho tài sản"), `### Business Rules And Guardrails`,
  `## Story Order And Dependencies`;
  `../../STORY-001_activity_card_hub/requirements/requirements.md` → AC-16
  (xoá thẻ không kịch tính hoá, không hỏi lý do), AC-17 (cờ trả lời do user
  bấm), AC-20 (cấm streak), AC-21 (SC-1' một kho), AC-23 (cổng cứng);
  `../../STORY-003_private_journal/requirements/requirements.md` → AC-12/AC-13
  (xoá toàn bộ một thao tác, không file ảnh mồ côi) — tiền lệ cho "xoá sạch";
  `../../STORY-004_relationship_notebook_and_gift_ideas/requirements/requirements.md`
  → BR-4 (ranh giới sổ tay), BR-15 (hình dạng dữ liệu sổ tay + hồ sơ kỹ năng là
  hợp đồng dùng chung);
  `../../STORY-012_phase_status_and_widget/requirements/requirements.md` →
  BR-5/BR-6/BR-7 và AC-26 (bộ đếm không phạt sự vắng mặt).

## Business Outcome

Người dùng bị từ chối, bị im lặng kéo dài, hoặc bỏ app ba tháng vẫn có **một
cách đóng lại gọn gàng** và **một cách quay lại không bị trách móc**, để app
không bao giờ trở thành "nơi tôi sợ mở".

Đây là bằng chứng cụ thể nhất cho định vị đã khoá ở OQ-18/L45 (2026-09-03):
chặng 1 là **kho tài sản**, không phải phòng chờ. Nếu đóng ngăn mà mất sạch,
chặng 1 đúng là phòng chờ. Tài sản **không gắn người kia sống sót nguyên vẹn**
qua cả J11 lẫn J13 chính là thứ chứng minh điều ngược lại. Story này là một
trong ba story chịu tải định vị (cùng STORY-001 và STORY-012).

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ, và đây là story chứng minh mạnh nhất.** J11 kích hoạt **chính
xác** trong tình huống người kia không tham gia; J13 chỉ đọc thời điểm mở app
gần nhất của **chính người dùng**. Không AC nào của story này cần người kia
làm bất cứ điều gì.

### Rủi ro chính: đây là bề mặt nguy hiểm cảm xúc nhất của cả requirement

Ba cú trượt, cả ba đều vi phạm luật bất biến:

1. **Kịch tính hoá lời từ chối.** Hiệu ứng an ủi, câu "bạn ổn chứ?", hỏi lý do
   đóng ngăn, gợi ý "thử nhắn lại xem" — R-1c cấm nguyên vẹn. Chuẩn đúng là
   **hiểu ngầm và ít lời**, không phải đồng cảm phô ra.
2. **Trách móc trá hình ở màn quay lại.** "Bạn đã vắng 92 ngày", trạng thái xám
   đi, "chuỗi bị đứt", thanh phục hồi, lời chào có định lượng thời gian — R-1
   cấm (f), và STORY-012 BR-6 đã đóng đúng ranh giới này cho bộ đếm.
3. **Đóng ngăn ăn nhầm tài sản.** Xoá hồ sơ kỹ năng "phiên bản tôi" hoặc thẻ ý
   tưởng chưa từng gắn người kia là phá đúng thứ story này sinh ra để bảo vệ.

## Scope

### In Scope

1. **SB-64 "đóng ngăn gọn gàng" (J11)**: một thao tác đóng lại toàn bộ vật liệu
   **gắn người** — thẻ đã gắn người, lời mời, chân dung, kết quả ăn khớp, sổ
   tay người yêu — mà không xoá tài sản không gắn người.
2. **SB-65 "tắt hồi tưởng"**: sau khi đóng ngăn, app ngừng **chủ động hiện lại**
   ký ức, ảnh, trạng thái pha, widget, và nhắc nhở liên quan tới người đó.
3. **Kho đã đóng (closed drawer)**: vật liệu đã đóng được **giữ lại và tra cứu
   được** ở một chỗ tường minh, chỉ vào được khi người dùng chủ động vào; và
   xoá hẳn được từ chính chỗ đó.
4. **Định nghĩa "gắn người" ở tầng dữ liệu** — cái gì đóng, cái gì sống sót
   (Nhóm B). Đây là hạt nhân của story.
5. **SB-100 màn quay lại không trách móc (J13)**: mở lại sau vắng dài → màn hỏi
   "mở lại từ đâu", không đếm ngày, không chuỗi đứt, không trạng thái suy giảm.
6. **Xoá sạch một thao tác** ngay tại màn quay lại, xoá thật, không bản sao ẩn.
7. **SC-5 không ngõ cụt**, kể cả sau khi đóng ngăn.

### Out of Scope (binding — chép từ `story_master.md`)

- Xoá tài khoản / dữ liệu ngoài phạm vi chặng 1.
- Bất kỳ lời nhắc quay lại, chuỗi nhắc, email/thông báo "chúng tôi nhớ bạn" nào.
- Đếm ngày vắng, chuỗi bị đứt, streak — R-1 cấm (f).
- Kịch tính hoá việc bị từ chối, gợi ý nhắn lại kiểu đeo bám — R-1c cấm.
- Lưu trữ ẩn dữ liệu đã "xoá sạch".
- Ghi lý do đóng ngăn dưới dạng đánh giá con người — R-1f cấm.

Thêm ở tầng requirement:

- **Không đổi hình dạng dữ liệu sổ tay / hồ sơ kỹ năng.** STORY-004 BR-15 sở
  hữu hợp đồng đó; story này chỉ **phân loại và lọc**, không định nghĩa lại.
- **Không tạo kho thứ hai.** Kho đã đóng là một **bộ lọc trên kho thẻ của
  STORY-001**, không phải danh sách song song (SC-1' / STORY-001 AC-21).
- **Không xoá và không đóng nhật ký riêng** (xem BR-6). STORY-003 sở hữu vòng
  đời nhật ký.
- **Không quyết định trình bày**: bố cục màn quay lại, mức ma sát bước xác
  nhận, vị trí lối vào "đóng ngăn" — giao UI/UX Designer.
- **Không có tầng ngoài phạm vi chặng 1.** "Xoá sạch" xoá dữ liệu chặng 1, đúng
  như `story_master.md` giới hạn.

## Acceptance Criteria

### Nhóm A — J11 đóng ngăn gọn gàng (SB-64)

**AC-1.** Given người dùng có vật liệu gắn người (thẻ đã gắn người, lời mời,
chân dung, kết quả ăn khớp, sổ tay người yêu), when họ chọn "đóng ngăn gọn
gàng" và xác nhận **một** lần, then **toàn bộ** vật liệu gắn người đang tồn tại
chuyển sang trạng thái *đã đóng* trong một thao tác, không phải đóng từng mục.

**AC-2.** Given hành động đóng ngăn đang chạy, when app hỏi xác nhận, then bước
xác nhận **chỉ** nêu phạm vi tác động dưới dạng dữ kiện (cái gì đóng, cái gì
giữ), và **không** hỏi lý do, **không** hỏi "bạn chắc chứ", **không** đưa lời
an ủi, **không** đề nghị giữ lại, **không** khảo sát (R-1c, R-1f, tiền lệ
STORY-001 AC-16).

**AC-3.** Given người dùng vừa đóng ngăn xong, when app phản hồi, then phản hồi
là **một xác nhận trung tính đã hoàn tất**, không hiệu ứng chuyển cảnh cảm xúc,
không hình minh hoạ an ủi, không âm thanh, không câu động viên (R-1c).

**AC-4.** Given app ở bất kỳ đâu trong luồng đóng ngăn, when người dùng đọc mọi
chữ hiển thị, then **không** có gợi ý liên lạc lại, nhắn lại, thử lần nữa, hay
bất kỳ nội dung nào ngụ ý người dùng nên tiếp tục theo đuổi (R-1c).

**AC-5.** Given người dùng đã đóng ngăn, when họ mở lại luồng đóng ngăn, then
hành động này **không** ghi bất kỳ lý do, nhãn, hay nhận định nào về người kia
vào hệ thống — không tồn tại trường dữ liệu nào để chứa nhận định đó (R-1f).

### Nhóm B — Kiểm kê tường minh: cái gì đóng, cái gì sống sót

**AC-6.** Given hệ thống cần biết một bản ghi có "gắn người" hay không, when
phân loại, then quy tắc là **tất định và ở tầng dữ liệu**: một bản ghi gắn
người khi và chỉ khi nó (a) là phát biểu **về người kia**, hoặc (b) mang một
trường trỏ tới người kia. Không có phân loại theo cảm tính, theo từ khoá tự do,
hay theo suy luận nội dung (R-7 — không AI ở runtime).

**AC-7.** Given quy tắc AC-6, when áp lên dữ liệu chặng 1 hiện có, then **danh
mục ĐÓNG** là đúng tập sau, không hơn:

| Vật liệu | Sở hữu bởi | Vì sao gắn người |
|---|---|---|
| Sổ tay người yêu (sở thích + sự kiện của người kia) | STORY-004 | Là phát biểu về người kia |
| Chân dung "theo cách BẠN nhìn" | STORY-009 | Là phát biểu về người kia |
| Kết quả bảng tra ăn khớp | STORY-010 | Dựng trên dữ liệu người kia |
| Lời mời / lời cảm ơn đã soạn hoặc đã xuất | STORY-002 | Trỏ tới người kia |
| Thẻ **đã gắn người**: thẻ từng xuất lời mời, thẻ mang cờ *đã trả lời / chưa trả lời*, hoặc thẻ *Đã đi rồi* / *Đã thành kỷ niệm* của buổi hẹn với người đó | STORY-001 | Mang trường trỏ tới người kia |
| Kịch bản buổi hẹn gắn thẻ đã gắn người | STORY-008 | Thuộc thẻ đã gắn người |
| Trạng thái pha, đếm ngược, widget của thẻ đã gắn người | STORY-012 | Thuộc thẻ đã gắn người |

**AC-8.** Given quy tắc AC-6, when áp lên dữ liệu chặng 1 hiện có, then **danh
mục SỐNG SÓT NGUYÊN VẸN** là đúng tập sau, và không mục nào trong đó bị đóng,
bị ẩn, bị xám, hay bị đánh dấu:

| Vật liệu | Sở hữu bởi | Vì sao KHÔNG gắn người |
|---|---|---|
| Hồ sơ kỹ năng "phiên bản tôi" | STORY-004 | Là phát biểu về **chính người dùng** |
| Thẻ ý tưởng chưa từng gắn người (điển hình: *Mới nghĩ ra*, chưa xuất lời mời, không cờ trả lời) | STORY-001 | Chỉ là ý tưởng hoạt động |
| Địa điểm, loại hoạt động, thời lượng ghi trên các thẻ sống sót | STORY-001 | Thuộc tính hoạt động, không thuộc tính người |
| Nhật ký riêng và ảnh đính kèm | STORY-003 | Là ghi chép riêng của người dùng (BR-6) |
| Kho nội dung preset, chỉ mục quà, bảng tra tay | STORY-004/005/010/011 | Dữ liệu ship kèm app |
| Bộ đếm "của cải đang lớn" | STORY-012 | Xem BR-5 |

**AC-9.** Given người dùng vừa đóng ngăn, when họ mở màn Hồ sơ kỹ năng và duyệt
các thẻ sống sót, then **mọi** mục ở AC-8 còn nguyên nội dung và còn dùng được
ngay cho một mối quan hệ khác, không cần khôi phục, không ở trạng thái chờ.

**AC-10.** Given một vật liệu mà quy tắc AC-6 không phân loại được dứt khoát,
when hệ thống xử lý, then nó được coi là **KHÔNG gắn người** và **sống sót** —
lỗi an toàn nghiêng về giữ tài sản, không nghiêng về xoá.

### Nhóm C — SB-65 tắt hồi tưởng

**AC-11.** Given đã đóng ngăn, when người dùng dùng app những ngày sau đó, then
app **không chủ động** hiện lại ký ức, ảnh, trạng thái pha, widget, thông báo,
đếm ngược, hay bất kỳ nội dung nào thuộc danh mục ĐÓNG ở AC-7.

**AC-12.** Given đã đóng ngăn, when hệ thống sinh nội dung gợi ý ở bất kỳ cửa
vào nào, then nội dung đó **không** dùng sổ tay người yêu đã đóng làm nguyên
liệu; các cửa vào đó suy giảm êm về mức chung như khi sổ tay còn trống.

**AC-13.** Given đã đóng ngăn, when đến bất kỳ mốc thời gian nào (kỷ niệm, dịp
lễ, ngày hẹn cũ), then app **không** sinh thông báo, nhắc nhở, hay nội dung
tưởng niệm nào liên quan tới người đó.

### Nhóm D — Kho đã đóng: giữ được, tra được, xoá được

**AC-14.** Given vật liệu đã đóng, when người dùng chủ động vào chỗ chứa kho đã
đóng, then họ xem lại được đầy đủ vật liệu đó — nó **không** bị xoá ngầm và
**không** phải thùng rác ẩn.

**AC-15.** Given kho đã đóng đang mở, when người dùng chọn xoá hẳn phần đã
đóng, then trong **một** thao tác xác nhận, toàn bộ vật liệu đã đóng (kể cả ảnh
đính kèm thuộc vật liệu đó) bị xoá thật, không bản sao ẩn, không file mồ côi
(tiền lệ STORY-003 AC-12/AC-13).

**AC-16.** Given kho đã đóng tồn tại, when app chạy luồng thường ngày, then app
**không bao giờ** tự đề xuất, nhắc, hay dẫn người dùng vào kho đã đóng — lối
vào chỉ có một chiều do người dùng khởi xướng (R-1c, chống nagging).

**AC-17.** Given người dùng chủ động mở lại ngăn đã đóng, when họ xác nhận,
then vật liệu quay lại luồng thường ngày, và app **không** đưa bất kỳ lời bình
luận, chúc mừng, hay khích lệ nào về việc mở lại.

### Nhóm E — J13 màn quay lại không trách móc (SB-100)

**AC-18.** Given người dùng không mở app trong một khoảng vượt ngưỡng vắng,
when họ mở lại, then màn quay lại hiện **một lần** và hỏi "mở lại từ đâu".

**AC-19.** Given ngưỡng vắng ở AC-18, when hệ thống quyết định có hiện màn quay
lại hay không, then đầu vào **duy nhất** là một phép so sánh boolean giữa thời
điểm hiện tại và thời điểm mở app gần nhất với **một hằng số ngưỡng cố định**
(mặc định sản phẩm: 30 ngày). Không nhiều bậc ngưỡng, không leo thang theo độ
dài vắng, không chuỗi lịch sử các lần vắng được lưu, không giá trị nào của phép
so sánh này được hiển thị cho người dùng.

**AC-20.** Given màn quay lại đang hiện, when người dùng đọc toàn bộ nội dung
màn, then **không** có: số ngày vắng, ngày mở app lần trước, "chuỗi bị đứt",
huy hiệu mất, thanh phục hồi, trạng thái xám hoặc mờ đi, nhãn "cũ"/"bỏ quên",
hay bất kỳ chỉ số định lượng nào về khoảng vắng (R-1 cấm (f), SB-100).

**AC-21.** Given màn quay lại đang hiện, when người dùng đọc lời chào, then lời
chào **không** đề cập tới sự vắng mặt dưới bất kỳ hình thức nào — không "lâu
quá không gặp", không "chào mừng trở lại sau một thời gian", không "chúng tôi
nhớ bạn" (R-1c + `Out of Scope`).

**AC-22.** Given màn quay lại đang hiện, when nó liệt kê lựa chọn "mở lại từ
đâu", then các lựa chọn là một tập cố định, tất định, dựng từ **tài sản sống
sót** (ví dụ: mở kho thẻ · mở hồ sơ kỹ năng/sổ tay · bắt đầu một việc mới), mỗi
lựa chọn dẫn thẳng tới một màn dùng được, và **không** lựa chọn nào được chấm
điểm, xếp hạng, hay gắn nhãn "nên làm trước".

**AC-23.** Given màn quay lại, when nó được kích hoạt, then điều kiện kích hoạt
**chỉ** là sự vắng mặt của **chính người dùng** — không bao giờ là việc người
kia không trả lời, không bao giờ là trạng thái của một thẻ (R-1b, cổng cứng).

**AC-24.** Given người dùng bỏ qua màn quay lại, when họ chọn bất kỳ lối đi
nào, then màn không hiện lại trong phiên đó và app vào thẳng trạng thái dùng
được bình thường — màn quay lại **không** là cổng chặn.

### Nhóm F — Xoá sạch một thao tác

**AC-25.** Given màn quay lại đang hiện, when người dùng tìm cách xoá hết, then
nút "xoá sạch" nằm **ngay trên màn đó**, cách **một** thao tác, không phải đi
tìm trong cài đặt.

**AC-26.** Given người dùng chọn "xoá sạch", when họ xác nhận **một** lần, then
**toàn bộ** dữ liệu chặng 1 do người dùng tạo bị xoá: thẻ ở cả bốn ngăn, kho đã
đóng, sổ tay, hồ sơ kỹ năng, nhật ký và ảnh đính kèm, chân dung, kết quả ăn
khớp, lời mời đã soạn, trạng thái bộ đếm.

**AC-27.** Given việc xoá sạch đã hoàn tất, when kiểm tra hệ thống, then
**không** còn bản sao ẩn, thùng rác, bản nháp sót, hàng đợi hoàn tác, hay file
ảnh mồ côi trên thiết bị (tiền lệ STORY-003 AC-13).

**AC-28.** Given bước xác nhận xoá sạch, when người dùng đọc, then nó nêu phạm
vi bị xoá và tính không hoàn tác dưới dạng dữ kiện, và **không** dùng lời can
ngăn, không gợi cảm giác mất mát, không đề nghị giữ lại, không hỏi lý do
(R-1c/R-1d).

**AC-29.** Given việc xoá sạch đã hoàn tất, when người dùng ở lại app, then app
về đúng **trạng thái rỗng lần đầu** của STORY-001 AC-1 và dùng được ngay —
không màn hình tiễn biệt, không ngõ cụt (SC-5).

### Nhóm G — SC-5, cổng cứng, và nhất quán với bộ đếm

**AC-30.** Given người dùng ở bất kỳ trạng thái nào — vừa đóng ngăn, vừa quay
lại sau vắng, hay vừa xoá sạch — when họ xem màn (1), then luôn có **ít nhất
một** đường đi tiếp dùng được ngay, không trạng thái nào là ngõ cụt (SC-5).

**AC-31.** Given người dùng vắng mặt bất kỳ bao lâu, when họ mở lại app, then
**không** có tài sản nào bị suy giảm, hết hạn, xám đi, hay bị dọn tự động vì lý
do thời gian; mọi thay đổi tài sản đều bắt nguồn từ một hành động tường minh
của người dùng (nhất quán STORY-012 BR-6/AC-26).

**AC-32.** Given toàn bộ story này, when người kia không bao giờ tham gia, then
mọi AC ở trên vẫn đạt được, và không AC nào cần người kia làm gì (cổng cứng,
tiền lệ STORY-001 AC-23).

## Business Rules

- **BR-1 (đóng ngăn ≠ xoá).** "Đóng ngăn gọn gàng" là **đổi trạng thái hiển
  thị** của vật liệu gắn người, không phải xoá. Xoá chỉ xảy ra qua AC-15 (xoá
  kho đã đóng) hoặc AC-26 (xoá sạch), cả hai đều do người dùng chọn tường minh.
- **BR-2 (quy tắc gắn người là tất định).** Phân loại ở AC-6 chạy trên **cấu
  trúc dữ liệu**, không trên nội dung chữ. Không quét văn bản, không suy luận,
  không AI ở runtime (R-7). Trường hợp mơ hồ → giữ tài sản (AC-10).
- **BR-3 (không sở hữu chéo hình dạng dữ liệu).** Story này **đọc** hợp đồng
  thẻ của STORY-001 và hợp đồng sổ tay/kỹ năng của STORY-004 (BR-15); nó chỉ
  thêm trạng thái *đã đóng* ở tầng của chính nó. Ranh giới kỹ thuật chính xác
  giao Tech Lead; ràng buộc sản phẩm là **không đổi ngữ nghĩa** hai hợp đồng đó.
- **BR-4 (một kho, không danh sách thứ hai).** Kho đã đóng là bộ lọc, không
  phải kho song song (SC-1' / STORY-001 AC-21).
- **BR-5 (nhất quán bộ đếm — không dựng luật song song).** Bộ đếm "của cải đang
  lớn" do STORY-012 sở hữu; STORY-013 **không** định nghĩa lại nó. Hai ràng
  buộc story này thêm vào: (a) đóng ngăn là **hành động tường minh của người
  dùng**, cùng hạng với xoá ở STORY-012 AC-29, nên STORY-012 BR-6 ("vắng mặt
  không bao giờ làm bộ đếm giảm") vẫn đúng nguyên vẹn; (b) app **không** được
  kể câu chuyện thay đổi quanh bộ đếm sau khi đóng ngăn — không so sánh
  trước/sau, không "bạn đã mất N", không hiệu ứng giảm.
- **BR-6 (nhật ký không bị đóng và không bị xoá bởi đóng ngăn).** Nhật ký riêng
  là ghi chép của **chính người dùng** về cảm xúc của họ, không phải phát biểu
  về người kia, kể cả khi có nhắc tên. Đóng ngăn **chỉ** dừng việc app **chủ
  động** hiện lại nội dung nhật ký (AC-11); nó không xoá và không khoá mục nào.
  Chỉ người dùng xoá nhật ký, qua STORY-003.
- **BR-7 (không đo lường, không leo thang ở J13).** Ngưỡng vắng là **một hằng
  số, một phép so sánh boolean, một lần hiện** (AC-19). Bất kỳ thiết kế nào có
  nhiều bậc ngưỡng, nội dung nhắc leo thang theo độ dài vắng, hay lưu chuỗi
  lịch sử vắng đều là **streak trá hình** và bị R-1 cấm (f).
- **BR-8 (không kênh ra ngoài).** Story này **không** sinh thông báo đẩy, email,
  hay tin nhắn nào — cả lúc đóng ngăn lẫn lúc vắng mặt. "Chúng tôi nhớ bạn" nằm
  trong `Out of Scope`, và im lặng là hành vi đúng.
- **BR-9 (không ghi nhận định về người kia).** Đóng ngăn không tạo trường lý do,
  nhãn cảm xúc, hay đánh giá con người nào (R-1f, AC-5).
- **BR-10 (SC-5 vs J11 — hoà giải tường minh).** "Không ngõ cụt" và "có lối ra"
  không mâu thuẫn: **đóng một ngăn không phải một ngõ cụt vì hai thứ vẫn còn** —
  tập tài sản sống sót ở AC-8, và lối đi tiếp luôn có ở AC-30. Ngõ cụt là trạng
  thái **không còn gì để làm tiếp**; sau đóng ngăn người dùng còn nguyên kho thẻ
  ý tưởng, hồ sơ kỹ năng, và nhật ký. Đó là lý do lối ra này an toàn để tồn tại.
- **BR-11 (xoá sạch phải thật).** Ràng buộc là **hoàn tất trong một thao tác
  xác nhận** và **không dư lượng** (AC-26/AC-27). Mức ma sát và bố cục bước xác
  nhận giao UI/UX Designer, với trần cứng: không can ngăn, không cảm xúc hoá.
- **BR-12 (phụ thuộc một chiều).** Story này bao **những gì đang tồn tại**. Nếu
  STORY-002/008/009/010/011/012 chưa giao, quy tắc AC-6 vẫn chạy đúng trên tập
  dữ liệu nhỏ hơn; không AC nào yêu cầu một story tương lai phải có mặt.
- **BR-13 (R-13 khoá vị trí, đối chiếu).** Story này không thêm lối vào menu
  chính hay tab bar cho chân dung (STORY-009) hay bảng tra ăn khớp (STORY-010);
  kho đã đóng cũng không được đặt ở nơi làm hai màn đó lộ ra ngoài luồng.

## System Integration And Discoverability

- **UI-facing story:** YES.
- **Existing user-visible surface:** YES — trạng thái đặc biệt của màn (1) do
  STORY-001 giao, cộng màn Hồ sơ kỹ năng/sổ tay do STORY-004 giao. **Không phải
  màn hình thứ 12.**
- **Điểm vào J11:** "đóng ngăn gọn gàng" là **hành động phụ** trên màn (1) —
  không phải hành động chính của thẻ, và không được cạnh tranh với hành động
  chính hai tầng mà STORY-001 đã khoá.
- **Điểm vào J13:** màn quay lại **tự hiện** khi mở app sau khi vượt ngưỡng vắng
  (AC-19), một lần, không chặn (AC-24).
- **Điểm vào kho đã đóng:** một chỗ tường minh do người dùng chủ động vào; app
  không bao giờ dẫn tới (AC-16).
- **Điểm vào xoá sạch:** trên chính màn quay lại, một thao tác (AC-25).
- **Không tích hợp bên ngoài.** Không thông báo đẩy, không email, không dịch vụ
  bên thứ ba (BR-8).

## Open Question Impact

### Scope Items BLOCKED in this story

**Không có mục nào bị chặn.** Story này vào delivery được ngay.

- **OQ-3 (ai duyệt kho nội dung preset) — ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 →
  luật R-15** (`req_master.md` mục 15). **Vẫn không chạm story này.** Triage ở
  `../../requirements/requirements.md` liệt kê STORY-002/004/005/007/009/010/011
  là story bị ảnh hưởng; STORY-013 không nằm trong đó. Story này **không ship
  kho nội dung preset nào** — chữ của nó là chuỗi giao diện cố định, và ràng
  buộc sản phẩm cho chữ đó đã được nêu dứt khoát ở AC-2/AC-3/AC-4/AC-21/AC-28
  (trung tính, không an ủi, không nhắc vắng mặt). Vì không có gói nội dung
  preset, **R-15a/R-15b/R-15c không thêm ràng buộc nào cho story này**. Nếu về
  sau ai đó muốn biến lời chào màn quay lại thành nội dung preset xoay vòng,
  việc đó **mới** kéo story vào phạm vi R-15 và phải quay lại Product Owner.

### Scope Items NOT BLOCKED in this story

- **L45 / OQ-18 — ĐÓNG, không mở lại.** User đã chốt 2026-09-03: chặng 1 là
  **kho tài sản**. Story này là một trong ba story chịu tải định vị đó, và
  AC-7/AC-8 là chỗ định vị được **thi hành** chứ không chỉ được tuyên bố. Nếu
  L45 bị mở lại và đổi câu trả lời, story này đổi **khung**, không đổi ranh
  giới. Không chặn.
- **R-1 cấm (f) vs màn quay lại — ĐÓNG bằng luật bất biến.** AC-19/AC-20/AC-21
  và BR-7 là định nghĩa vận hành của ranh giới, không phải lời hứa biên tập.
- **Nhất quán với bộ đếm STORY-012 — ĐÓNG bằng đối chiếu, không bằng luật mới.**
  BR-5 trỏ thẳng vào STORY-012 BR-5/BR-6/BR-7 và AC-26 thay vì dựng một luật
  song song. Không cần user quyết.
- **"Danh sách địa điểm" trong `story_master.md` In Scope 3 — làm rõ, không mâu
  thuẫn.** REQ-016 **không có** thực thể "danh sách địa điểm" đứng riêng, và
  SC-1' cấm tạo một danh sách thứ hai cạnh màn (1). Địa điểm tồn tại như
  **trường của thẻ** (STORY-001; STORY-002 AC-6, STORY-008 dùng trường này).
  Vì vậy "danh sách địa điểm sống sót" được thi hành đúng nghĩa qua AC-8: địa
  điểm sống sót cùng các thẻ sống sót. Đây là diễn giải, không phải thu hẹp
  `Out of Scope` binding.
- **Ngưỡng vắng mặc định 30 ngày (AC-19)** — con số là **hằng số sản phẩm chỉnh
  được**, không phải hợp đồng dữ liệu. J13 kể chuyện "khoảng ba tháng" như tình
  huống minh hoạ; ràng buộc cứng là **một** ngưỡng, không bậc thang (BR-7).
  Chỉnh giá trị không cần đổi AC nào.
- **Mức ma sát bước xác nhận và bố cục màn quay lại** — giao UI/UX Designer
  trong phạm vi story này, dưới trần cứng AC-2/AC-3/AC-20/AC-21/AC-28.
- **Vị trí chính xác của lối vào kho đã đóng** — giao UI/UX Designer, ràng buộc
  sản phẩm duy nhất: app không bao giờ dẫn tới (AC-16) và không phá R-13 (BR-13).

## Traceability

| AC | Nguồn |
|----|-------|
| AC-1..AC-5 | SB-64 J11, R-1c/R-1d, R-1f, STORY-001 AC-16 |
| AC-6..AC-10 | "kho tài sản" OQ-18/L45, R-7 không AI runtime, STORY-001/003/004 ownership |
| AC-11..AC-13 | SB-65 tắt hồi tưởng, `Out of Scope` không nhắc quay lại |
| AC-14..AC-17 | BR-1 đóng ≠ xoá, chống nagging R-1c, tiền lệ STORY-003 AC-12/AC-13 |
| AC-18..AC-24 | SB-100 J13, R-1 cấm (f), R-1b, STORY-012 BR-6/AC-26 |
| AC-25..AC-29 | Xoá sạch một thao tác, STORY-003 AC-12/AC-13, STORY-001 AC-1, SC-5 |
| AC-30..AC-32 | SC-5, cổng cứng, STORY-001 AC-23, STORY-012 BR-6 |
